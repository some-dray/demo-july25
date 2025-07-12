from flask import Flask, render_template
from markupsafe import Markup
import os
import json
from collections import Counter

app = Flask(__name__)

@app.route('/')
def index():
    report_path = '/app/grype-report.json'
    image_name = os.getenv("IMAGE_NAME", "Unknown Image")
    vulnerabilities = []
    summary = {
        'Critical': 0,
        'High': 0,
        'Medium': 0,
        'Low': 0,
        'Negligible': 0,
        'Unknown': 0
    }

    try:
        with open(report_path, 'r') as f:
            data = json.load(f)
            vulnerabilities = data.get('matches', [])
            
            # Calculate summary
            severities = [match['vulnerability']['severity'] for match in vulnerabilities]
            summary = Counter(severities)

    except FileNotFoundError:
        print(f"Report file not found at {report_path}")
    except json.JSONDecodeError:
        print(f"Could not decode JSON from {report_path}")
    except Exception as e:
        print(f"Error processing report file: {e}")

    return render_template('index.html', 
                             image_name=image_name, 
                             vulnerabilities=vulnerabilities,
                             summary=summary)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)