import os
import numpy as np
import tensorflow as tf
from flask import Flask, request, jsonify
from tensorflow.keras.models import load_model
from PIL import Image


gpus = tf.config.list_physical_devices('GPU')
if gpus:
    try:
        for gpu in gpus:
            tf.config.experimental.set_memory_growth(gpu, True)
        print("Success: Memory Growth diaktifkan untuk GPU.")
    except RuntimeError as e:
        print(f"Error pada konfigurasi GPU: {e}")

app = Flask(__name__)

model = load_model("models/glaucoma_model.keras")

def preprocess_image(image):
    image = image.resize((224, 224))
    image = np.array(image) / 255.0
    image = np.expand_dims(image, axis=0)
    return image

@app.route("/predict", methods=["POST"])
def predict():
    if 'file' not in request.files:
        return jsonify({"error": "File tidak ditemukan"}), 400
        
    file = request.files["file"]
    
    try:
        image = Image.open(file).convert("RGB")
        processed = preprocess_image(image)

        # Melakukan prediksi
        prediction = model.predict(processed)[0][0]
        label = "Glaucoma" if prediction > 0.5 else "Tidak Glaucoma"

        return jsonify({
            "probability": float(prediction),
            "prediction": label
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000, debug=False)