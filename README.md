# EvoEdgeTTS Portable

EvoEdgeTTS is a portable, easy-to-use interface and API for Text-To-Speech synthesis using Microsoft Edge. The main advantage of this project is its **portability** and focus on end users: you don't need to know how to code, use the terminal, or manually install Python/FFmpeg. The system handles everything automatically on the first run!

## 🚀 How to Download and Install (For Regular Users)

This project is designed to be 100% "Plug and Play". Follow these steps:

1. **Download the project**: Click the green **Code** button (at the top of this page) and select **Download ZIP**.
2. **Extract the files**: Unzip the downloaded file to a folder on your computer (e.g., `Documents` or `Desktop`).
3. **Automatic Installation**: 
   - Double-click the **`Install.bat`** file.
   - A black screen will open. The system will silently download Portable Python and FFmpeg, and configure everything for your computer automatically. This might take a few minutes depending on your internet connection.
   - Wait for the **[SUCCESS]** message and press any key to close the window.
4. **Use the program**: 
   - Double-click the **`start.bat`** file.
   - The EvoEdgeTTS interface will magically open in your web browser!

*Note: If you forget to click `Install.bat` and open `start.bat` directly, the system will warn you to run the installer first.*

---

## 🛠️ For Developers and Advanced Users

EvoEdgeTTS runs a local FastAPI server and provides a clean, responsive UI natively.

### Project Structure
- `app/api.py`: Contains the FastAPI implementation and native audio generation logic using `edge-tts`.
- `ui/index.html`: Visual interface (pure HTML, CSS, and JS) that consumes the local API.
- `scripts/`: PowerShell/Batch scripts responsible for environment automation and initialization.
- `Install.bat` and `start.bat`: Root shortcuts for easy access.
- `output/`: Folder where generated audio files (MP3/WAV) are saved (created automatically).

### API Routes (Port 8890)
When the system is running (via `start.bat`), the following endpoints are available:
- Interface: `http://127.0.0.1:8890`
- Swagger Documentation: `http://127.0.0.1:8890/docs`
- Status: `GET /health`
- List Voices: `GET /edge-tts/voices`
- List Profiles: `GET /edge-tts/profiles`
- Generate Audio: `POST /edge-tts` (Accepts parameters via Multipart Form)

### Building Your Own Release ZIP
If you have modified the code and want to generate your own "Plug and Play" `.zip` file for distribution:
1. Open PowerShell.
2. Navigate to the project folder.
3. Run the command: `.\scripts\build_portable.ps1`
4. The ready-to-use file will be generated in the `dist/edge-tts-portable.zip` folder.

---

## ⚙️ Technologies Used
- **Python Embeddable** (100% isolated, does not clutter the user's PC)
- **FastAPI** & **Uvicorn**
- **edge-tts**
- **FFmpeg** & **pydub** (downloaded at runtime for WAV conversion, no PATH configuration needed)
- UI built entirely with modern **HTML/CSS/JS**.

---
**Legal Note:** This project is not affiliated with or supported by Microsoft. Audio generation is based on the free read-aloud APIs included in the Edge browser services.
