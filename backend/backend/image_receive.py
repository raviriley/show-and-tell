from flask import Flask, request, jsonify
import base64
import os
from io import BytesIO
from PIL import Image

app = Flask(__name__)

@app.route('/upload', methods=['POST'])
def upload_image():
    # Parse the JSON data
    data = request.get_json()
    
    # Extract the base64 image data
    base64_image = data.get('image')
    if not base64_image:
        return jsonify({'error': 'No image data found'}), 400
    
    # Decode the base64 string
    image_data = base64.b64decode(base64_image)
    
    # Convert binary data to image
    image = Image.open(BytesIO(image_data))
    
    # Save or process the image as needed
    image_path = 'uploaded_image.jpg'
    image.save(image_path)
    
    # Assuming saving the image was successful
    return jsonify({'message': 'Image uploaded successfully', 'image_path': image_path}), 200

if __name__ == '__main__':
    app.run(debug=True, port=5000)
