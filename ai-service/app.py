import os
import numpy as np
import tensorflow as tf
from flask import Flask, request, jsonify
from tensorflow.keras.models import load_model
from PIL import Image
import time 
from flask_cors import CORS
from tensorflow.keras.preprocessing.image import img_to_array

# gpus = tf.config.list_physical_devices('GPU')
# if gpus:
#     try:
#         for gpu in gpus:
#             tf.config.experimental.set_memory_growth(gpu, True)
#         print("Success: Memory Growth diaktifkan untuk GPU.")
#     except RuntimeError as e:
#         print(f"Error pada konfigurasi GPU: {e}")


app = Flask(__name__)
CORS(app)

model = load_model("glaucoma_model_v2.keras")

def preprocess_image(image):
    image = image.resize((224, 224))
    image = img_to_array(image)
    image = np.expand_dims(image, axis=0)
    return image
@app.route("/predict", methods=["POST"])
def predict():
    if 'file' not in request.files:
        return jsonify({"status": "error", "message": "File tidak ditemukan"}), 400
        
    file = request.files["file"]
    start_time = time.time() 
    
    try:
        image = Image.open(file).convert("RGB")
        processed = preprocess_image(image)

        prediction_raw = model.predict(processed, verbose=0)[0][0]
        prediction = float(prediction_raw)
        
        threshold = 0.3
        is_glaucoma = prediction > threshold
        label = "RG (Glaukoma)" if is_glaucoma else "NRG (Normal)"
        
    
        if prediction > 0.8:
            advice = "Sangat Disarankan: Segera lakukan pemeriksaan mendalam ke Dokter Spesialis Mata."
        elif prediction > threshold:
            advice = "Peringatan: Terdeteksi gejala awal, disarankan konsultasi medis."
        else:
            advice = "Kondisi Normal: Tetap jaga kesehatan mata dan rutin periksa berkala."

        execution_time = time.time() - start_time 

        return jsonify({
            "status": "success",
            "data": {
                "filename": file.filename,
                "prediction": label,
                "confidence_score": round(prediction, 4),
                "threshold_config": threshold,
                "analysis": {
                    "is_glaucoma": is_glaucoma,
                    "model_version": "EfficientNetB0-V2-PENS",
                    "inference_time_sec": round(execution_time, 3),
                    "input_size": "224x224"
                },
                "medical_advice": advice
            },
            "timestamp": time.strftime("%Y-%m-%d %H:%M:%S")
        })

    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500
    
if __name__ == "__main__":
    print("🚀 Server Flask Berjalan di http://localhost:5000")
    app.run(host='0.0.0.0', port=5000, debug=False)