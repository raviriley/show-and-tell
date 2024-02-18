import base64
import os
import sys
import threading
import time
from io import BytesIO

import numpy as np
import serial
from flask import Flask, jsonify, render_template, request
from hume import HumeBatchClient
from hume.models.config import FaceConfig
from numpy import dot
from numpy.linalg import norm
from openai import OpenAI
from PIL import Image

app = Flask(__name__)


# IMAGES


@app.route("/upload", methods=["POST"])
def upload_image():
    # Parse the JSON data
    print("Hello world!", file=sys.stderr)
    data = request.get_json()

    # Extract the base64 image data
    base64_image = data.get("image")
    if not base64_image:
        return jsonify({"error": "No image data found"}), 400

    # Decode the base64 string
    image_data = base64.b64decode(base64_image)

    # Convert binary data to image
    image = Image.open(BytesIO(image_data))

    width, height = image.size

    # Setting the points for cropped image
    left = 20
    top = 250
    right = width - 20
    bottom = height - 250

    # Cropped image of above dimension
    # (It will not change original image)
    im1 = image.crop((left, top, right, bottom))

    # Save or process the image as needed
    image_path = "uploaded_image.jpg"
    image.save(image_path)
    image1_path = "uploaded_image_crop.jpg"
    im1.save(image1_path)

    # send to Hume
    client = HumeBatchClient("a6nLyAAG6WerOIyqNiaUfdljGEBxPSNpflWtScb0O521e7we")
    filepaths = ["uploaded_image_crop.jpg"]
    config = FaceConfig()
    job = client.submit_job(None, [config], files=filepaths)
    print(job)
    print("Hume running...")
    details = job.await_complete()
    results = job.get_predictions()
    first = results[0]
    emotions = first["results"]["predictions"][0]["models"]["face"]["grouped_predictions"][0]["predictions"][0][
        "emotions"
    ]
    sorted_audio_emotions = sorted(emotions, key=lambda x: x["score"], reverse=True)
    top_emotion = sorted_audio_emotions[0]

    print("top emotion: ", top_emotion)

    # Assuming saving the image was successful
    return jsonify({"message": f"Image uploaded successfully - top emotion {top_emotion}", "emotion": top_emotion}), 200


# SIGN LANGUAGE

# Dataset of sign language readings
# sign_language_dataset = {'Hello': [4000, 4000, 4000, 4000, 4000, 4000],
# 'I Love You': [4000, 4000, 750, 750, 4000, 4000],
# 'You': [750, 4000, 750, 750, 750, 4000],
# 'Thumbs Up': [4000, 750, 750, 750, 750, 4000],
# 'A': [4000, 750, 750, 750, 750, 4000],
# 'B': [750, 4000, 4000, 4000, 4000, 4000],
# 'C': [2750, 2750, 2750, 2750, 2750, 4000],
# 'D': [2750, 4000, 2750, 2750, 2750, 4000],
# 'E': [750, 2750, 2750, 2750, 2750, 4000],
# 'F': [750, 750, 4000, 4000, 4000, 4000],
# 'G': [4000, 4000, 750, 750, 750, 4000],
# 'H ': [2750, 4000, 4000, 750, 750, 4000],
# 'I ': [750, 750, 750, 750, 4000, 750],
# 'J': [750, 750, 750, 750, 4000, 750],
# 'K': [4000, 4000, 4000, 750, 750, 750],
# 'L': [4000, 4000, 750, 750, 750, 750],
# 'M': [2750, 750, 750, 750, 750, 750],
# 'N': [750, 750, 750, 750, 750, 750],
# 'O': [750, 2750, 2750, 2750, 2750, 4000],
# 'P': [2750, 4000, 2750, 750, 750, 750],
# 'Q': [2750, 4000, 750, 750, 750, 750],
# 'R': [750, 750, 2750, 750, 750, 750],
# 'S': [750, 750, 750, 750, 750, 750],
# 'T': [750, 750, 750, 750, 750, 750],
# 'U': [750, 4000, 4000, 750, 750, 750],
# 'V': [750, 2750, 2750, 750, 750, 750],
# 'W': [750, 4000, 4000, 4000, 750, 750],
# 'X': [750, 2750, 750, 750, 750, 750],
# 'Y': [4000, 750, 750, 750, 4000, 750],
# 'Z': [750, 4000, 750, 750, 750, 750],
# 'stop': [750, 750, 750, 750, 750, 750],
# }

# Dataset of sign language readings
# thumb, index, middle, ring, pinky, palm
sign_language_dataset = {
    "stop": [750, 750, 750, 750, 750, 750],
    "I Love You": [4000, 4000, 750, 750, 4000, 4000],
    "You": [750, 4000, 750, 750, 750, 4000],
    "how": [2750, 2750, 2750, 2750, 2750, 4000],
    "hello": [4000, 4000, 4000, 4000, 4000, 4000],
    "okay": [2750, 750, 4000, 4000, 4000, 4000],
    "peace": [750, 4000, 4000, 750, 750, 4000],
    "A": [4000, 750, 750, 750, 750, 4000],
    "B": [750, 4000, 4000, 4000, 4000, 4000],
    "C": [2750, 2750, 2750, 2750, 2750, 4000],
    "D": [2750, 4000, 2750, 2750, 2750, 4000],
    "E": [750, 2750, 2750, 2750, 2750, 4000],
    "F": [750, 750, 4000, 4000, 4000, 4000],
    "G": [4000, 4000, 750, 750, 750, 4000],
    "H ": [2750, 4000, 4000, 750, 750, 4000],
    "I ": [750, 750, 750, 750, 4000, 750],
    "J": [750, 750, 750, 750, 4000, 750],
    "K": [4000, 4000, 4000, 750, 750, 750],
}

client = OpenAI(api_key="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")

sameWordCounter = 0
spokenText = []
words = []
reading = True
ready = True
active = False


def cosine_similarity(A, B):
    return dot(A, B) / (norm(A) * norm(B))


def computeSum(A, B):
    if len(A) != len(B):
        raise ValueError("Lists must have the same length")
    sum = 0
    for i in range(len(A)):
        sum += (A[i] - B[i]) ** 2
    return sum


def compare_readings(sensorArray, sign_language_dataset):
    best = float("inf")
    best_key = ""
    for key, value in sign_language_dataset.items():
        difference = computeSum(sensorArray, value)
        if difference < best:
            best = difference
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
                    "content": "I will be passing you glosses of American Sign Language (ASL) words and phrases. Please provide the spoken English translation. do not add any other words to the output. DO NOT ADD ANY OTHER WORDS TO THE OUTPUT OTHER THAN SMALL MODIFIERS",
                },
                {"role": "user", "content": prompt},
                {"role": "assistant", "content": "How are you?"},
                {"role": "assistant", "content": "I love you"},
            ],
        )

        # Extract the text from the response
        generated_text = completion.choices[0].message.content
        print("Spoken text:", generated_text)
        spokenText.append(generated_text)
        ready = True
        return generated_text

    except Exception as e:
        print(f"An error occurred: {str(e)}")


# RECIEVING FROM ARDUINO
# Replace '/dev/ttyUSB0' with your serial port and adjust baudrate


def startHandCapture():
    while True:
        try:
            ser = serial.Serial("/dev/cu.usbmodem101", 9600)
            global words, sameWordCounter, reading, ready
            while True:
                data = ser.readline()
                if data:
                    sensorCapture = data.decode("utf-8").strip()
                    print(sensorCapture)
                    # convert sensorCapture to an array of integers based on seperating the string by a delimiter
                    sensorArray = sensorCapture.split(",")
                    # only take the first 6
                    sensorArray = sensorArray[:6]  # TODO CHANGED
                    # cast every element in the array to an integer
                    try:
                        sensorArray = [int(i) for i in sensorArray]
                    except:
                        continue
                    print(sensorArray)
                    try:
                        word = compare_readings(sensorArray, sign_language_dataset)  # Process the data
                    except Exception as e:
                        # go to next loop
                        print(f"An error occurred: {str(e)}")

                        continue

                    # if word == 'stop' and ready == True:
                    #     ready = False
                    #     spokenText = callOpenAI(words)
                    #     # write to file
                    #     with open('output.txt', 'w') as f:
                    #         # write the words to the file
                    #         f.write(spokenText)
                    #     words = []

                    # check if equal to the last word received
                    # print(active)
                    # if active:
                    if len(words) == 0 or words[-1] != word:
                        words.append(word)  # Append the word to the array
                    # else:
                    #     sameWordCounter += 1

                    print("word: ", word)
                    print("words: ", words)
                    time.sleep(2)  # Wait for 2 seconds before processing the next piece of data
        except Exception as e:
            print(f"An error occurred: {str(e)}")
            return


# startHandCapture()


def stopHandCapture():
    global reading
    reading = False
    spokenText = callOpenAI(words)
    words = []
    return spokenText


connectionCheck = True


@app.route("/get_spoken_text", methods=["GET"])
def start_capture():
    global reading, active, spokenText, words
    reading = True
    active = True
    # returnable = callOpenAI(spokenText)
    returnable = words
    print("open ai", callOpenAI(words))
    words = []

    # startHandCapture() # MAKE THIS ASYNC
    # while connectionCheck:
    #     if checkConnection():
    #         connectionCheck = False
    #         startHandCapture()
    if returnable:
        return jsonify({"spokenText": returnable}), 200
    else:
        return jsonify({"spokenText": "No spoken text available"}), 404


# Make sure to not call startHandCapture() directly as before.
# Remove or comment out the direct call to startHandCapture() at the end of your script.


def checkConnection():
    try:
        ser = serial.Serial("/dev/cu.usbmodem2101", 9600)
        return True
    except:
        return False


if __name__ == "__main__":
    thread = threading.Thread(target=startHandCapture)
    thread.start()
    app.run(debug=True, port=5000)
