import sys
from flask import Flask, request, jsonify
import base64
import os
from io import BytesIO
from PIL import Image
from hume import HumeBatchClient
from hume.models.config import FaceConfig

app = Flask(__name__)

@app.route('/upload', methods=['POST'])
def upload_image():
    # Parse the JSON data
    print('Hello world!', file=sys.stderr)
    data = request.get_json()
    
    # Extract the base64 image data
    base64_image = data.get('image')
    if not base64_image:
        return jsonify({'error': 'No image data found'}), 400
    
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
    image_path = 'uploaded_image.jpg'
    image.save(image_path)
    image1_path = 'uploaded_image_crop.jpg'
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
    return jsonify({'message': f'Image uploaded successfully - top emotion {top_emotion}', 'emotion': top_emotion}), 200

if __name__ == '__main__':
    app.run(debug=True, port=5000)
