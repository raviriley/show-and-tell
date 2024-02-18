from datetime import datetime
import os
import wave

import json
import cv2
import numpy as np
import openai
import pyaudio
import pygame
from dotenv import load_dotenv
from flask import Flask, Response, jsonify
from gtts import gTTS
from hume import HumeBatchClient
from hume.models.config import FaceConfig
from hume.models.config import ProsodyConfig

app = Flask(__name__)

HUME_API_KEY = ""

def generate_frames():
    hog = cv2.HOGDescriptor()
    hog.setSVMDetector(cv2.HOGDescriptor_getDefaultPeopleDetector())
    cap = cv2.VideoCapture(1)
    while True:
        success, frame = cap.read()
        if not success:
            break
        frame = cv2.resize(frame, (640, 480))
        boxes, weights = hog.detectMultiScale(
            frame, winStride=(4, 4), padding=(8, 8), scale=1.05, useMeanshiftGrouping=False
        )
        boxes = np.array([[x, y, x + w, y + h] for (x, y, w, h) in boxes])
        for (xA, yA, xB, yB) in boxes:
            cv2.rectangle(frame, (xA, yA), (xB, yB), (0, 255, 0), 2)
        ret, buffer = cv2.imencode(".jpg", frame)
        frame = buffer.tobytes()
        yield (b"--frame\r\n" b"Content-Type: image/jpeg\r\n\r\n" + frame + b"\r\n")


@app.route("/video")
def video():
    return Response(generate_frames(), mimetype="multipart/x-mixed-replace; boundary=frame")


def postAudioHume():

    client = HumeBatchClient(HUME_API_KEY)
    filepaths = ["output.wav"]
    config = ProsodyConfig()
    job = client.submit_job(None, [config], files=filepaths)

    print(job)
    print("Running...")

    details = job.await_complete()

    results = job.get_predictions()

    # Extract the top emotion
    print(results)
    # json_string = results.strip('[]')
    # json_object = json.loads(json_string)
    # emotions = json_object['results']['predictions'][0]['models']['prosody']['grouped_predictions'][0]['predictions'][0]['emotions']
    emotions = results[0]["results"]["predictions"][0]["models"]["prosody"]["grouped_predictions"][0]["predictions"][0]["emotions"]

    # sort emotions by score
    emotions.sort(key=lambda x: x["score"], reverse=True)

    sorted_audio_emotions = emotions[:3]

    print("sorted emotions: ", sorted_audio_emotions)
    for emotion in sorted_audio_emotions:
        print(f"{emotion['name']}: {float(emotion['score']) * 100}")

    return sorted_audio_emotions

""" todo
def imageHume(filepath):

    client = HumeBatchClient(HUME_API_KEY)
    filepaths = ["output.jpg"]
    config = FaceConfig()
    job = client.submit_job(None, [config], files=filepaths)

    print(job)
    print("Running...")

    details = job.await_complete()

    results = job.get_predictions()

    # Extract the top emotion
    json_string = results.strip('[]')
    json_object = json.loads(json_string)

    emotions = json_object['results']['predictions'][0]['models']['face']['grouped_predictions'][0]['predictions'][0]['emotions']

    sorted_audio_emotions = sorted(emotions, key=lambda x: x['score'], reverse=True)

    print("sorted emotions: ", sorted_audio_emotions)

    return sorted_audio_emotions
"""


@app.route("/process_audio", methods=["GET"])
def process_audio():
    load_dotenv()
    os.getenv("OPENAI_API_KEY")

    # Step 1: Play the help.wav audio
    pygame.mixer.init()
    pygame.mixer.music.load("help.wav")
    pygame.mixer.music.play()
    while pygame.mixer.music.get_busy():
        continue

    # Step 2: Stream and record audio for 5 seconds
    p = pyaudio.PyAudio()
    FORMAT = pyaudio.paInt16
    CHANNELS = 1
    RATE = 44100
    CHUNK = 1024
    RECORD_SECONDS = 5
    WAVE_OUTPUT_FILENAME = "output.wav"

    stream = p.open(format=FORMAT, channels=CHANNELS, rate=RATE, input=True, frames_per_buffer=CHUNK)
    frames = []
    for i in range(0, int(RATE / CHUNK * RECORD_SECONDS)):
        audio_data = stream.read(CHUNK)
        frames.append(audio_data)
    stream.stop_stream()
    stream.close()
    p.terminate()
    print("Recording finished")

    wf = wave.open(WAVE_OUTPUT_FILENAME, "wb")
    wf.setnchannels(CHANNELS)
    wf.setsampwidth(p.get_sample_size(FORMAT))
    wf.setframerate(RATE)
    wf.writeframes(b"".join(frames))
    wf.close()

    # Step 3: Transcribe the recorded audio
    audio_file = open("output.wav", "rb")
    transcript = openai.Audio.transcribe("whisper-1", audio_file)["text"]

    # Step 4: Generate GPT-3 response
    pre_prompt = f"""Act as a relief SPOT robot for a human in a disaster scenario Human:  {transcript}. reply in the language of the human. 

    reassure the human that help is on its way, and that they are safe. state that images, voice, and geolocation data is being sent in real time to the rescue teams. 

    just return the text to be spoken by the robot in the language of the human. do not return any other data. do not repeat the human input. just reply to it using above instructions
    """
    response = openai.Completion.create(engine="text-davinci-002", prompt=pre_prompt, max_tokens=100)
    generation = response.choices[0].text.strip()

    # Step 5: Speak out the GPT-3 response
    tts = gTTS(text=generation, lang="en")
    tts.save("gpt_response.mp3")
    pygame.mixer.music.load("gpt_response.mp3")
    pygame.mixer.music.play()
    while pygame.mixer.music.get_busy():
        continue

    try:
        sorted_audio_emotions = postAudioHume()
        face_emotion = [{"name": "Stressed", "score": 0.4763}]
    except:
        sorted_audio_emotions = [{"name": "Stressed", "score": 0.4763}]
        face_emotion = [{"name": "Stressed", "score": 0.4763}]

    urgency_level = 8


    summary_prompt = f'''
    SPOT robots are identifying survivors in war torn areas and are sending visual and auditory data to remote a paramedic team. Act as the summariser for the paramedic team. The data being sent has an audio transcription of the survivor ({transcript}), a facial emotion analysis using HUME and confidences({sorted_audio_emotions}), a auditory emotion analysis using HUME and confidences ({face_emotion}), and urgency level ({urgency_level}). Generate a summary that can provide brief actionable insights to this paramedic team. ideate and come up with a nice actionable summary for the paramedics team. your job is to solely act as the summariser.
    '''
    
    summary = openai.Completion.create(engine="text-davinci-002", prompt=summary_prompt, max_tokens=800)
    summary = summary.choices[0].text.strip()

    response_dict = {
        "timestamp": datetime.now().strftime("%m/%d/%Y %H:%M:%S"),
        "location": "12.9716° N, 77.5946° E",
        "face_emotions": face_emotion,
        "audio_emotions": sorted_audio_emotions,
        "text": transcript,
        "urgency_level": urgency_level,
        "summary": summary,
    }

    # Return the dictionary as a JSON object
    return jsonify(response_dict)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001)
