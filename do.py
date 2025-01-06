import os
import sys
import json
import time
import io
import argparse
#from openai import OpenAI, RateLimitError, APIError
import openai
from openai import OpenAI
import requests
from pydub import AudioSegment
from pydub.playback import play
import pyttsx3

import threading

# Create a global lock object (mutex)
llm_lock = threading.Lock()

def initTTS():
    global engine

    engine = pyttsx3.init()
    engine.setProperty('rate', 180)
    engine.setProperty('volume', 1)
    voice = engine.getProperty('voices')
    engine.setProperty('voice', voice[1].id)

def initVar():
    global EL_key
    global OAI_key
    global EL_voice
    global video_id
    global tts_type
    global OAI
    global EL

    # Load configuration data from JSON file
    try:
        with open("config.json", "r") as json_file:
            data = json.load(json_file)
    except:
        print("Unable to open JSON file.")
        exit()

    # Set up the OAI configuration from the JSON data
    OAI_key = os.getenv('_OAI_KEY_FROM_ENV_', data["keys"][0]["OAI_key"])  # Fetch from env or fallback to JSON
    OAI = OpenAI(api_key=OAI_key)  # Initialize OpenAI client with API key

    # Set up the rest of the OAI configurations
    OAI.model = data["OAI_data"][0]["model"]
    OAI.prompt = data["OAI_data"][0]["prompt"]
    OAI.temperature = data["OAI_data"][0]["temperature"]
    OAI.max_tokens = data["OAI_data"][0]["max_tokens"]
    OAI.top_p = data["OAI_data"][0]["top_p"]
    OAI.frequency_penalty = data["OAI_data"][0]["frequency_penalty"]
    OAI.presence_penalty = data["OAI_data"][0]["presence_penalty"]

    # Set up the ElevenLabs (EL) configuration from the JSON data
    EL_key = data["keys"][0]["EL_key"]
    EL_voice = data["EL_data"][0]["voice"]

    # TTS options
    tts_list = ["pyttsx3", "EL"]

    # Argument parsing setup
    parser = argparse.ArgumentParser()
    parser.add_argument("-id", "--video_id", type=str)
    parser.add_argument("-tts", "--tts_type", default="pyttsx3", choices=tts_list, type=str)

    args = parser.parse_args()

    video_id = args.video_id
    tts_type = args.tts_type

    # Initialize TTS engine if needed
    if tts_type == "pyttsx3":
        initTTS()

def Controller_TTS(message):
    if tts_type == "EL":
        EL_TTS(message)
    elif tts_type == "pyttsx3":
        pyttsx3_TTS(message)


def pyttsx3_TTS(message):

    engine.say(message)
    engine.runAndWait()


def EL_TTS(message):

    url = f'https://api.elevenlabs.io/v1/text-to-speech/{EL.voice}'
    headers = {
        'accept': 'audio/mpeg',
        'xi-api-key': EL.key,
        'Content-Type': 'application/json'
    }
    data = {
        'text': message,
        'voice_settings': {
            'stability': 0.75,
            'similarity_boost': 0.75
        }
    }

    response = requests.post(url, headers=headers, json=data, stream=True)
    audio_content = AudioSegment.from_file(io.BytesIO(response.content), format="mp3")
    play(audio_content)

def llm(message):
    start_sequence = " #########"

    with llm_lock:
        print("Calling the LLM...")
        retries = 5
        backoff_factor = 1  # Factor to increase wait time on each retry (in seconds)

        for attempt in range(retries):
            try:
                # Prepare messages as a list of dictionaries
                messages = [
                    {"role": "system", "content": OAI.prompt},
                    {"role": "user", "content": message}
                ]

                # Requesting a completion using the OpenAI client (OAI)
                response = OAI.completions.create(
                    model=OAI.model,  # Make sure OAI.model is set correctly
                    prompt=OAI.prompt + "\n\n#########\n" + message + "\n#########\n",  # Construct the prompt
                    temperature=OAI.temperature,  # Optional, can be left out if you don't want to set it
                    max_tokens=OAI.max_tokens,  # Optional, can be left out if you don't want to set it
                    top_p=OAI.top_p,  # Optional, can be left out if you don't want to set it
                    frequency_penalty=OAI.frequency_penalty,  # Optional, can be left out if you don't want to set it
                    presence_penalty=OAI.presence_penalty  # Optional, can be left out if you don't want to set it
                )

                # Extract the generated text from the response
                return response['choices'][0]['message']['content']
            except openai.RateLimitError as e:
                if attempt < retries - 1:  # If it's not the last attempt
                    print(f"Rate limit exceeded. Retrying in {backoff_factor} seconds...")
                    time.sleep(backoff_factor)
                    backoff_factor *= 2  # Exponential backoff
                else:
                    print(f"Rate limit exceeded. No more retries. Error: {e}")
                    raise e
            except openai.APIError as e:
                print(f"API error: {e}")
                print("An error occurred while contacting the API.  Please try again.")
                raise e
            except Exception as e:
                print(f"An error occurred: {e}")
                raise e

def read_chat():
    print("Enter a message: ", end="", flush=True)
    message = sys.stdin.readline().strip()

    if message:
        response = llm(message)
        print(response)
        Controller_TTS(response)

if __name__ == "__main__":
    initVar()
    print("\n\Running!\n\n")

    while True:
        read_chat()
        print("\n\nReset!\n\n")
        time.sleep(2)
