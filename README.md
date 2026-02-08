<div align="center">
  <img width="600" src="assets/branding/playstore_icon.png" alt="Velvet Notes Logo">

**Velvet Notes & Recorder**  
<i>“Notes that look simple — but feel secure.”</i>

A privacy-focused notes application built with Flutter.<br>
Velvet Notes presents itself as a clean notes app while offering advanced audio and video recording capabilities designed for discretion, control, and local-only data storage.

Built for users who value privacy, speed, and simplicity.

Built with Flutter — not just another wrapper 😉

<a href="https://instagram.com/eunbyul._.aakash">
  <img alt="Instagram Page" src="https://img.shields.io/badge/Instagram-Follow-E4405F?style=for-the-badge&logo=instagram&logoColor=white">
</a>
<a href="www.linkedin.com/in/eunbyul-aakash">
  <img alt="LinkedIn Profile" src="https://img.shields.io/badge/LinkedIn-Connect-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white">
</a>
<a href="#">
  <img alt="Google Play" src="https://img.shields.io/badge/Google_Play-Coming_Soon-34A853?style=for-the-badge&logo=google-play&logoColor=white">
</a>

---

![Velvet Notes – Notes Screen](assets/branding/play_screenshots/1.png)

![Velvet Notes – Recorder Screen](assets/branding/play_screenshots/5.png)

</div>

## 🎯 Objective

- Provide a **discreet notes-style interface** as the default user experience  
- Enable **gesture-based access** to recording tools with no visible entry point  
- Support **audio and video recording** while maintaining user awareness inside the app  
- Store all data **locally** to ensure privacy and control  

## 🌃 Key Features

- 📝 Create, edit, and delete notes
- 🖤 Dark enhanced UI with a minimal design
- 🧠 Gesture-based access (tap empty area 5 times within ~1.2 seconds)
- 🎙 Audio recording with background continuation
- 📹 Video recording with live preview (screen visible)
- 🔁 Background recording support
- 🛡️ In-app banner indicator when recording is active
- 💾 Local-only storage (no cloud, no external access)
- 🚫 No login, no analytics, no tracking
- 📖 Fully open-source

## 🧩 Application Modes

### Notes Interface (Default Home Screen)
- Appears as a standard notes application
- Used for daily tasks, reminders, and writing
- Acts as the primary visible interface

### Recorder Interface
- Accessible via gesture
- Supports two modes:
  - **Audio recording**
  - **Video recording**
- No visible recorder buttons on the notes screen

## ✨ UX Highlights

- Helps track daily responsibilities, errands, and reminders
- Gesture-based entry keeps the UI clean
- In-app banner informs the user when recording is active
- Foreground indicator for background recording awareness

## 🛠 Architecture & Tech Stack

### Framework
- **Flutter (Dart)**
- Material Design components

### Recording Technology
- **Audio:** `record` plugin
- **Video:** `camera` plugin
- **Background service:** `flutter_foreground_task`

### Storage
- **Notes:** SQLite (`sqflite`)
- **Recordings:** Internal app-private storage  
  (accessible only inside the app)

## 📜 ⬇️ Installation Guide

Velvet Notes & Recorder is currently available via source build.<br>
Google Play release is coming soon.

<table>
  <tr>
    <th>Platform</th>
    <th>Installation Method</th>
  </tr>
  <tr>
    <td>Android</td>
    <td>
      <p>📲 Google Play (Coming Soon)</p>
      <p>🧪 Build from source (below)</p>
    </td>
  </tr>
</table>

## 🕳️ Building from Source

<a href="https://github.com/eunbyulaakash/Valvet-Shadow-Recorder/actions">
  <img alt="GitHub Workflow Status" src="https://img.shields.io/github/actions/workflow/status/eunbyulaakash/Valvet-Shadow-Recorder/flutter.yml?label=Build%20Status">
</a>

### Requirements
- Flutter SDK
- Android SDK
- Android device or emulator

### Steps

```bash
git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git
cd YOUR_REPO
flutter pub get
flutter run
```
## 👥 Team

**Aakash Maurya** — Founder & Lead Developer  
<sub>AK Innovations</sub>

## 💼 License

Velvet Notes & Recorder is open source and licensed under the **Proprietary License**.  
See the [LICENSE](LICENSE) file for more information.

<details>
  <summary>
    <h2><code>[Click to show]</code> 🙏 Services & Dependencies</h2>
  </summary>

### Core Services

- **Flutter** — Cross-platform UI framework
- **Android background services** — Continuous background execution
- **Local storage** — Secure on-device file handling
- **permission_handler**
- **encrypt**

### Key Flutter Packages

- cupertino_icons
- provider
- record
- camera
- path_provider
- path
- permission_handler
- sqflite
- intl
- open_filex
- flutter_foreground_task

</details>

<div align="center">
  <h4>© Copyright AK Innovations 2025</h4>
</div>
