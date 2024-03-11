import base64
import json
import os
import threading
import time

import numpy as np
import serial

# websocket
from flask import Flask, jsonify, render_template
from flask_socketio import SocketIO, emit
from numpy import dot
from numpy.linalg import norm
from openai import OpenAI

# import pyaudio

# Flask App
app = Flask(__name__)
socketio = SocketIO(app)

# Dataset of sign language readings
sign_language_dataset = {
    "A": [3916, 3939, 4015, 4004, 3950, 4036],
    "B": [4034, 4100, 3966, 4034, 4067, 3976],
    "C": [3966, 3950, 3950, 3899, 3956, 4046],
    "D": [4035, 4030, 4075, 3956, 3965, 3956],
    "E": [4059, 3975, 4140, 3967, 4012, 4053],
    "F": [3976, 3957, 4039, 4041, 4007, 3934],
    "G": [3956, 3952, 3934, 4031, 4052, 3957],
    "H": [4049, 4024, 4093, 4016, 3882, 4002],
    "I": [3952, 3998, 3989, 4026, 4008, 3937],
    "J": [3994, 4042, 3939, 4015, 4034, 3960],
    "K": [4082, 3998, 3996, 3998, 3850, 3961],
    "L": [4032, 3983, 3970, 3981, 4034, 4067],
    "M": [4029, 3991, 4004, 3908, 4020, 3954],
    "N": [4058, 4002, 3983, 3985, 4012, 3986],
    "O": [4039, 4100, 3963, 4020, 4024, 3979],
    "P": [4051, 4037, 3950, 4004, 4024, 3922],
    "Q": [3937, 4055, 3977, 4010, 4022, 4005],
    "R": [3966, 4057, 4024, 4024, 3981, 3935],
    "S": [3944, 3983, 3847, 4003, 3997, 4105],
    "T": [4005, 3954, 3963, 4071, 4028, 3981],
    "U": [4011, 4056, 3957, 4001, 4063, 3926],
    "V": [4005, 4121, 4006, 4027, 4132, 3951],
    "W": [3994, 3959, 3983, 3974, 3958, 3926],
    "X": [3986, 3939, 3963, 3975, 3944, 4008],
    "Y": [3951, 3955, 3949, 4071, 3942, 4083],
    "Z": [3961, 3943, 4052, 4006, 4010, 4001],
}


client = OpenAI(api_key="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")


def cosine_similarity(A, B):
    return dot(A, B) / (norm(A) * norm(B))


def compare_readings(sensorArray, sign_language_dataset):
    best = 0
    best_key = ""
    for key, value in sign_language_dataset.items():
        similarity = cosine_similarity(sensorArray, value)
        if similarity > best:
            best = similarity
            best_key = key
    return best_key


# post request to openAI
def callOpenAI(words):
    try:
        # Join the words into a single string as prompt for the API
        prompt = " ".join(words)

        # Call the OpenAI API with the prompt
        completion = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[
                {
                    "role": "system",
                    "content": "I will be passing you glosses of American Sign Language (ASL) words and phrases. Please provide the spoken English translation.",
                },
                {"role": "user", "content": prompt},
            ],
        )

        # Extract the text from the response
        generated_text = completion.choices[0].message.content
        print("Spoken text:", generated_text)
        spokenText.append(generated_text)
        return generated_text

    except Exception as e:
        print(f"An error occurred: {str(e)}")


# RECIEVING FROM ARDUINO
# Replace '/dev/ttyUSB0' with your serial port and adjust baudrate
# ser = serial.Serial("/dev/cu.usbmodem2101", 9600)

sameWordCounter = 0
spokenText = []
words = []
reading = False


def startHandCapture():
    global words, sameWordCounter, reading
    while reading:
        data = ser.readline()
        if data:
            sensorCapture = data.decode("utf-8").strip()
            print(sensorCapture)
            # convert sensorCapture to an array of integers based on seperating the string by a delimiter
            sensorArray = sensorCapture.split(",")
            # cast every element in the array to an integer
            sensorArray = [int(i) for i in sensorArray]
            print(sensorArray)
            try:
                word = compare_readings(sensorArray, sign_language_dataset)  # Process the data
            except:
                # go to next loop
                continue
            # check if equal to the last word received
            if len(words) == 0 or words[-1] != word:
                words.append(word)  # Append the word to the array
            # else:
            #     sameWordCounter += 1

            # if sameWordCounter == 3:
            #     callOpenAI(words)
            #     sameWordCounter = 0
            #     words = []
            print("word: ", word)
            print("words: ", words)
            time.sleep(2)  # Wait for 2 seconds before processing the next piece of data


def stopHandCapture():
    global reading
    reading = False


# HUME EMOTION VISION
def storeImage(json):
    image_data = json["image"]
    image_bytes = base64.b64decode(image_data)
    # Make sure the 'assets' directory exists
    assets_directory = "./assets"
    if not os.path.exists(assets_directory):
        os.makedirs(assets_directory)
    # Define the full path where the image will be stored
    image_path = os.path.join(assets_directory, "image.jpg")
    with open(image_path, "wb") as image_file:
        image_file.write(image_bytes)
    print("Image stored at:", image_path)


from hume import HumeBatchClient
from hume.models.config import FaceConfig


def callHumeAPI():
    client = HumeBatchClient("a6nLyAAG6WerOIyqNiaUfdljGEBxPSNpflWtScb0O521e7we")
    filepaths = ["./assets/image.jpg"]
    config = FaceConfig()
    job = client.submit_job(None, [config], files=filepaths)

    print(job)
    print("Running...")

    details = job.await_complete()

    # job.download_predictions("predictions.json")
    results = job.get_predictions()
    # print(type(results))
    print(results)
    first = results[0]
    emotions = first["results"]["predictions"][0]["models"]["face"]["grouped_predictions"][0]["predictions"][0][
        "emotions"
    ]
    sorted_audio_emotions = sorted(emotions, key=lambda x: x["score"], reverse=True)
    print("sorted emotions: ", sorted_audio_emotions)
    print("top emotion: ", sorted_audio_emotions[0])
    return sorted_audio_emotions[0]


# WEB SOCKET
@socketio.on("connect")
def handle_connect():
    print("Client connected")


@socketio.on("disconnect")
def handle_disconnect():
    print("Client disconnected")


# JSON format: {'type': type, 'data': data}


@socketio.on("image")
def handleImage(json):
    print("Received image")
    global streaming_active, reading
    storeImage(json)
    emotion = callHumeAPI()


# @socketio.on('speech')
# def handleSpeech(json):
# probably on frontend


@socketio.on("signRequest")
def handleSignRequest(json):
    if json == "start" and not reading:
        startHandCapture()
        reading = True
        # socketio.read_from_port(ser)
        emit("Started transcription")

    elif json == "stop" and reading:
        stopHandCapture()
        emit("words", words)
        words = []


if __name__ == "__main__":
    socketio.run(app)
