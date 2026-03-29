"""
Evo Edge TTS API.
Usage: python api.py
API: http://127.0.0.1:8890
Docs: http://127.0.0.1:8890/docs
"""

import hashlib
import io
import time
from pathlib import Path

import edge_tts
import uvicorn
from fastapi import FastAPI, Form, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse, StreamingResponse
from pydantic import BaseModel
from pydub import AudioSegment

HOST = "127.0.0.1"
PORT = 8890
APP_DIR = Path(__file__).resolve().parent
ROOT_DIR = APP_DIR.parent
OUTPUT_DIR = ROOT_DIR / "output"
OUTPUT_DIR.mkdir(exist_ok=True)

BIN_DIR = ROOT_DIR / "bin"
if (BIN_DIR / "ffmpeg.exe").exists():
    AudioSegment.converter = str(BIN_DIR / "ffmpeg.exe")

VOICE_PROFILES = {
    "default": {
        "label": "Natural",
        "speed": "+0%",
        "pitch": "+0Hz",
        "volume": "+0%",
    },
    "clear_female": {
        "label": "Clear Female",
        "speed": "-5%",
        "pitch": "+0Hz",
        "volume": "+0%",
    },
    "clear_male": {
        "label": "Clear Male",
        "speed": "-3%",
        "pitch": "+0Hz",
        "volume": "+0%",
    },
    "girl_child": {
        "label": "Child Girl",
        "speed": "+18%",
        "pitch": "+12Hz",
        "volume": "+3%",
    },
    "boy_child": {
        "label": "Child Boy",
        "speed": "+10%",
        "pitch": "+8Hz",
        "volume": "+2%",
    },
}

SUPPORTED_FORMATS = {"mp3", "wav"}


class HealthResponse(BaseModel):
    status: str
    service: str
    version: str
    engine: str
    host: str
    port: int


async def list_edge_voices():
    fallback = [
        {"name": "en-US-AriaNeural", "gender": "Female", "locale": "en-US"},
        {"name": "en-US-GuyNeural", "gender": "Male", "locale": "en-US"},
        {"name": "pt-BR-AntonioNeural", "gender": "Male", "locale": "pt-BR"},
        {"name": "pt-BR-FranciscaNeural", "gender": "Female", "locale": "pt-BR"},
        {"name": "pt-BR-ThalitaNeural", "gender": "Female", "locale": "pt-BR"},
        {"name": "es-ES-AlvaroNeural", "gender": "Male", "locale": "es-ES"},
        {"name": "es-ES-ElviraNeural", "gender": "Female", "locale": "es-ES"},
        {"name": "fr-FR-DeniseNeural", "gender": "Female", "locale": "fr-FR"},
        {"name": "fr-FR-HenriNeural", "gender": "Male", "locale": "fr-FR"},
        {"name": "de-DE-KatjaNeural", "gender": "Female", "locale": "de-DE"},
        {"name": "de-DE-ConradNeural", "gender": "Male", "locale": "de-DE"},
        {"name": "ja-JP-NanamiNeural", "gender": "Female", "locale": "ja-JP"},
        {"name": "ja-JP-KeitaNeural", "gender": "Male", "locale": "ja-JP"},
    ]

    try:
        voices = await edge_tts.list_voices()
    except Exception:
        return fallback

    supported_langs = ("en-", "de-", "fr-", "ja-", "es-", "pt-")
    target_voices = []
    seen_names = set()
    for voice in voices:
        short_name = voice.get("ShortName", "")
        locale = voice.get("Locale", "")
        if (
            (locale.startswith(supported_langs) or short_name.startswith(supported_langs))
            and short_name
            and short_name not in seen_names
        ):
            seen_names.add(short_name)
            target_voices.append(
                {
                    "name": short_name,
                    "gender": voice.get("Gender", ""),
                    "locale": locale,
                }
            )

    return sorted(target_voices, key=lambda item: item["name"]) or fallback


async def synthesize_edge_audio(text: str, voice: str, speed: str, pitch: str, volume: str):
    communicate = edge_tts.Communicate(
        text=text,
        voice=voice,
        rate=speed,
        pitch=pitch,
        volume=volume,
    )

    mp3_buf = io.BytesIO()
    try:
        async for chunk in communicate.stream():
            if chunk["type"] == "audio":
                mp3_buf.write(chunk["data"])
    except Exception as exc:
        raise HTTPException(
            status_code=503,
            detail=f"Failed to connect to the Edge-TTS service: {exc}",
        ) from exc

    if mp3_buf.tell() == 0:
        raise HTTPException(status_code=500, detail="Edge-TTS did not return audio.")

    mp3_buf.seek(0)
    return mp3_buf


def convert_mp3_to_wav(mp3_buf: io.BytesIO) -> io.BytesIO:
    try:
        audio_segment = AudioSegment.from_mp3(mp3_buf)
    except Exception as exc:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to convert Edge-TTS MP3 to WAV: {exc}",
        ) from exc

    wav_buf = io.BytesIO()
    audio_segment.export(wav_buf, format="wav")
    wav_buf.seek(0)
    return wav_buf


def save_output(audio_bytes: bytes, text: str, output_format: str) -> str:
    text_hash = hashlib.md5(text.encode("utf-8")).hexdigest()[:8]
    output_filename = f"edge_{text_hash}_{int(time.time())}.{output_format}"
    output_path = OUTPUT_DIR / output_filename
    output_path.write_bytes(audio_bytes)
    return output_filename


app = FastAPI(title="Evo Edge TTS API", version="3.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def root():
    return JSONResponse(
        {
            "service": "Evo Edge TTS API",
            "status": "online",
            "version": app.version,
            "engine": "edge-tts",
            "ui_file": str(ROOT_DIR / "ui" / "index.html"),
            "docs_url": f"http://{HOST}:{PORT}/docs",
            "endpoints": {
                "GET /health": "Quick status",
                "GET /edge-tts/voices": "List Edge-TTS voices",
                "GET /edge-tts/profiles": "List ready-to-use profiles",
                "POST /edge-tts": "Generate audio via multipart form",
            },
        }
    )


@app.get("/health", response_model=HealthResponse)
def health():
    return HealthResponse(
        status="ok",
        service="Evo Edge TTS API",
        version=app.version,
        engine="edge-tts",
        host=HOST,
        port=PORT,
    )


@app.get("/models")
def list_models():
    return []


@app.get("/references")
def list_references():
    return []


@app.post("/tts")
async def text_to_speech_disabled():
    raise HTTPException(status_code=410, detail="Legacy F5-TTS support was removed. Use /edge-tts.")


@app.post("/tts/json")
async def text_to_speech_json_disabled():
    raise HTTPException(status_code=410, detail="Legacy F5-TTS support was removed. Use /edge-tts.")


@app.post("/upload-reference")
async def upload_reference_disabled():
    raise HTTPException(status_code=410, detail="Reference upload was removed with F5-TTS.")


@app.get("/edge-tts/voices")
async def edge_tts_voices():
    return await list_edge_voices()


@app.get("/edge-tts/profiles")
def edge_tts_profiles():
    return [{"id": key, **value} for key, value in VOICE_PROFILES.items()]


@app.post("/edge-tts")
async def edge_tts_generate(
    text: str = Form(...),
    voice: str = Form(default="pt-BR-FranciscaNeural"),
    speed: str = Form(default="+0%"),
    pitch: str = Form(default="+0Hz"),
    volume: str = Form(default="+0%"),
    profile: str = Form(default="default"),
    output_format: str = Form(default="mp3"),
):
    clean_text = text.strip()
    if not clean_text:
        raise HTTPException(status_code=400, detail="Text cannot be empty.")

    if output_format not in SUPPORTED_FORMATS:
        raise HTTPException(status_code=400, detail="Invalid format. Use mp3 or wav.")

    profile_cfg = VOICE_PROFILES.get(profile)
    if profile_cfg is not None:
        speed = profile_cfg["speed"]
        pitch = profile_cfg["pitch"]
        volume = profile_cfg["volume"]

    t0 = time.time()
    mp3_buf = await synthesize_edge_audio(
        text=clean_text,
        voice=voice,
        speed=speed,
        pitch=pitch,
        volume=volume,
    )

    if output_format == "wav":
        audio_buf = convert_mp3_to_wav(mp3_buf)
        media_type = "audio/wav"
    else:
        audio_buf = mp3_buf
        media_type = "audio/mpeg"

    audio_bytes = audio_buf.getvalue()
    output_filename = save_output(audio_bytes, clean_text, output_format)
    elapsed = time.time() - t0

    return StreamingResponse(
        io.BytesIO(audio_bytes),
        media_type=media_type,
        headers={
            "X-Generation-Time": f"{elapsed:.2f}s",
            "X-Voice": voice,
            "X-Engine": "edge-tts",
            "X-Profile": profile,
            "X-Speed": speed,
            "X-Pitch": pitch,
            "X-Volume": volume,
            "X-Output-Format": output_format,
            "X-Output-File": output_filename,
            "Content-Disposition": f'inline; filename="{output_filename}"',
        },
    )


if __name__ == "__main__":
    print(f"\n{'=' * 56}")
    print("  Evo Edge TTS API")
    print(f"  API:  http://{HOST}:{PORT}")
    print(f"  Docs: http://{HOST}:{PORT}/docs")
    print(f"  UI:   {ROOT_DIR / 'ui' / 'index.html'}")
    print(f"{'=' * 56}\n")
    uvicorn.run(app, host=HOST, port=PORT)
