from flask import Flask, jsonify
import os

app = Flask(__name__)


@app.route("/")
def index():
    return jsonify(message="Hello from the AKS CI/CD demo service", status="running")


@app.route("/health")
def health():
    return jsonify(status="ok"), 200


@app.route("/version")
def version():
    return jsonify(version=os.environ.get("APP_VERSION", "dev")), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 5000)))
