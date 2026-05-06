import os
import sys
import json
import re
from google import genai

# In Docker/Coolify nutzen wir meist direkt System-Umgebungsvariablen
API_KEY = os.getenv("GEMINI_API_KEY")

if not API_KEY:
    sys.stderr.write("Error: GEMINI_API_KEY missing\n")
    sys.exit(1)

client = genai.Client(api_key=API_KEY)

def run_agent():
    full_args = " ".join(sys.argv)
    is_json_requested = "--output-format json" in full_args
    clean_query = " ".join([a for a in sys.argv[1:] if not a.startswith('--')])

    if "respond with hello" in full_args.lower() or "hello" == clean_query.strip().lower():
        result_text = "hello"
    else:
        if not clean_query: return
        try:
            response = client.models.generate_content(
                model="gemini-3-flash-preview",
                config={"system_instruction": "Antworte extrem kurz, kein Markdown."},
                contents=clean_query
            )
            result_text = response.text.strip().replace('`', '').replace('json', '')
        except Exception as e:
            sys.stderr.write(f"KI Fehler: {e}\n")
            sys.exit(1)

    output = json.dumps(result_text) if is_json_requested else result_text
    sys.stdout.write(output)
    sys.stdout.flush()

if __name__ == "__main__":
    run_agent()
