import os
# ── Suppress GPU/TF warnings
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'
os.environ['TF_ENABLE_ONEDNN_OPTS'] = '0'

import numpy as np
import tensorflow as tf
import cv2
import matplotlib.pyplot as plt
from tensorflow.keras.preprocessing import image
from tensorflow.keras.applications.efficientnet import preprocess_input

tf.get_logger().setLevel('ERROR')

# ─────────────────────────────
# 1. LOAD MODEL
# ─────────────────────────────
model = tf.keras.models.load_model("glaucoma_model_v2.keras")
model.build((None,224,224,3))

print("\nModel Loaded ✓")
model.summary()

# ─────────────────────────────
# 2. LOAD & PREPROCESS IMAGE
# ─────────────────────────────
def load_and_preprocess(img_path):

    img = image.load_img(img_path, target_size=(224,224))

    img_array = image.img_to_array(img)

    img_array = np.expand_dims(img_array,axis=0)

    img_array = preprocess_input(img_array)

    return img_array


# ─────────────────────────────
# 3. GRAD-CAM
# ─────────────────────────────
def make_gradcam_heatmap(img_array, model):

    # ambil backbone
    efficientnet = model.get_layer("efficientnetb0")

    # conv terakhir
    last_conv_layer = efficientnet.get_layer("top_conv")

    # model dari input -> conv layer
    conv_model = tf.keras.models.Model(
        inputs=efficientnet.input,
        outputs=last_conv_layer.output
    )

    # classifier setelah EfficientNet
    classifier_input = tf.keras.Input(shape=last_conv_layer.output.shape[1:])

    x = classifier_input
    x = model.layers[1](x)   # GlobalAveragePooling
    x = model.layers[2](x)   # BatchNorm
    x = model.layers[3](x)   # Dropout
    output = model.layers[4](x)  # Dense

    classifier_model = tf.keras.Model(classifier_input, output)

    with tf.GradientTape() as tape:

        conv_outputs = conv_model(img_array)

        tape.watch(conv_outputs)

        preds = classifier_model(conv_outputs)

        pred_index = tf.argmax(preds[0])

        class_channel = preds[:, pred_index]

    grads = tape.gradient(class_channel, conv_outputs)

    pooled_grads = tf.reduce_mean(grads, axis=(0,1,2))

    conv_outputs = conv_outputs[0]

    heatmap = conv_outputs @ pooled_grads[..., tf.newaxis]

    heatmap = tf.squeeze(heatmap)

    heatmap = tf.maximum(heatmap,0) / tf.math.reduce_max(heatmap)

    return heatmap.numpy()
# ─────────────────────────────
# 4. OVERLAY HEATMAP
# ─────────────────────────────
def overlay_gradcam(img_path, heatmap, alpha=0.4):

    img = cv2.imread(img_path)

    img = cv2.resize(img,(224,224))

    heatmap = cv2.resize(heatmap,(224,224))

    heatmap_uint8 = np.uint8(255 * heatmap)

    heatmap_color = cv2.applyColorMap(
        heatmap_uint8,
        cv2.COLORMAP_JET
    )

    superimposed = cv2.addWeighted(
        img,
        1-alpha,
        heatmap_color,
        alpha,
        0
    )

    return superimposed


# ─────────────────────────────
# 5. RUN PREDICTION
# ─────────────────────────────
img_path = "picture/RG/BEH-1.png"

img_array = load_and_preprocess(img_path)

pred = model.predict(img_array, verbose=0)

label = "GLAUKOMA" if pred[0][0] > 0.5 else "NORMAL"

confidence = pred[0][0] if pred[0][0] > 0.5 else 1 - pred[0][0]

print("\nHasil Prediksi")
print("==============")
print(f"Hasil     : {label}")
print(f"Confidence: {confidence*100:.2f}%")

# ─────────────────────────────
# 6. GENERATE HEATMAP
# ─────────────────────────────
heatmap = make_gradcam_heatmap(img_array, model)

result = overlay_gradcam(img_path, heatmap)

# ─────────────────────────────
# 7. SAVE RESULT
# ─────────────────────────────
cv2.imwrite("heatmap_result.jpg", result)

print("\nHeatmap disimpan: heatmap_result.jpg")

# ─────────────────────────────
# 8. DISPLAY RESULT
# ─────────────────────────────
plt.figure(figsize=(10,4))

plt.subplot(1,2,1)

orig = cv2.imread(img_path)

orig = cv2.resize(orig,(224,224))

plt.imshow(cv2.cvtColor(orig,cv2.COLOR_BGR2RGB))

plt.title("Foto Retina Asli")

plt.axis("off")

plt.subplot(1,2,2)

plt.imshow(cv2.cvtColor(result,cv2.COLOR_BGR2RGB))

plt.title(f"{label} ({confidence*100:.1f}%)")

plt.axis("off")

plt.tight_layout()

plt.savefig("gradcam_output.png", dpi=150, bbox_inches='tight')

plt.show()

print("\nSelesai ✓")