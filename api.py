<<<<<<< HEAD
from flask_cors import CORS
from flask import Flask, request, jsonify
=======
from flask import Flask, request, jsonify
from flask_cors import CORS
>>>>>>> d0981a1 (Ajout du support CORS pour Flutter)
import joblib
import numpy as np

app = Flask(__name__)
CORS(app)

# Charger les modèles
model_inj = joblib.load("model_injecteur.pkl")
model_fuel = joblib.load("model_carburant.pkl")
scaler = joblib.load("scaler.pkl")

@app.route("/")
def home():
    return "API opérationnelle 🚗"

@app.route("/predict", methods=["POST"])
def predict():
    data = request.get_json()

    try:
        fuel_per_rpm = data["fuel_rate"] / data["rpm"]
        temp_vs_speed = data["engine_temp"] / (data["speed"] + 1)
        maf_vs_throttle = data["maf"] / (data["throttle_pos"] + 1)

        features = np.array([
            data["rpm"], data["fuel_rate"], data["throttle_pos"],
            data["speed"], data["engine_temp"], data["maf"],
            fuel_per_rpm, temp_vs_speed, maf_vs_throttle
        ]).reshape(1, -1)

        features_scaled = scaler.transform(features)
        pred_inj = model_inj.predict(features_scaled)[0]
        pred_fuel = model_fuel.predict(features_scaled)[0]

        return jsonify({
            "injector_fault": bool(pred_inj),
            "fuel_overconsumption": bool(pred_fuel)
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 400

if __name__ == "__main__":
    app.run(debug=True)
