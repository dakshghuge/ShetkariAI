# Shetkari AI (शेतकरी AI) 🌾🤖

[![Live Demo](https://img.shields.io/badge/Live_Demo-shetkariai--250ef.web.app-brightgreen?style=for-the-badge&logo=googlechrome)](https://shetkariai-250ef.web.app/)
[![Flutter](https://img.shields.io/badge/Framework-Flutter_3.x-02569B?style=for-the-badge&logo=flutter)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Backend-Firebase_Firestore-FFCA28?style=for-the-badge&logo=firebase)](https://firebase.google.com/)
[![Gemini AI](https://img.shields.io/badge/AI_Engine-Google_Gemini_1.5-8E44AD?style=for-the-badge&logo=google)](https://ai.google.dev/)

> **Empowering Farmers with AI-Driven Crop Health Diagnosis, Instant PDF Report Generation, Live Market Rates, and 24/7 Multilingual Voice Advisory.**

🌐 **Live Web Application**: [https://shetkariai-250ef.web.app/](https://shetkariai-250ef.web.app/)

---

## 📌 Table of Contents
- [Executive Summary](#-executive-summary)
- [Live Application & Access](#-live-application--access)
- [End-to-End System Pipeline & Workflow](#-end-to-end-system-pipeline--workflow)
  - [1. High-Level Architecture](#1-high-level-architecture)
  - [2. Disease Detection & PDF Report Pipeline](#2-disease-detection--pdf-report-pipeline)
  - [3. Voice & Chat Advisory Workflow](#3-voice--chat-advisory-workflow)
- [Disease PDF Report Generation](#-disease-pdf-report-generation)
- [Key Features](#-key-features)
- [Tech Stack & Architecture](#-tech-stack--architecture)
- [Directory & Project Structure](#-directory--project-structure)
- [Getting Started](#-getting-started)
- [Configuration & API Management](#-configuration--api-management)
- [Roadmap & Future Scope](#-roadmap--future-scope)
- [Disclaimer](#-disclaimer)

---

## 📌 Executive Summary

**Shetkari AI (शेतकरी AI)** serves as a 24/7 Digital Agricultural Officer designed to solve critical challenges faced by farmers. Leveraging computer vision and large language models (Google Gemini 1.5), Shetkari AI enables farmers to scan diseased crops, receive instant scientific diagnosis with organic & chemical treatment remedies, download/print official PDF diagnostic reports, access live market rates (APMC Mandis), and communicate in regional languages like **Marathi (मराठी)** and **English** using voice or text.

---

## 🌐 Live Application & Access

The application is deployed and live across platforms:
- 🔗 **Live Web App**: [https://shetkariai-250ef.web.app/](https://shetkariai-250ef.web.app/)
- **Cross-Platform Support**: Web Browsers (Chrome/Safari/Edge), Android, iOS, Windows, Linux.

---

## 🔄 End-to-End System Pipeline & Workflow

### 1. High-Level Architecture

```text
  +-----------------------------------------------------------------------------------+
  |                                 USER INTERFACE                                    |
  |    Flutter Multiplatform App (Web / Android / iOS) | Marathi & English Support    |
  +-----------------------------------------------------------------------------------+
                                         |
     +-----------------------------------+-----------------------------------+
     |                                   |                                   |
     v                                   v                                   v
+------------------+           +------------------+           +----------------------+
| Disease Vision   |           | Multilingual Chat|           | Weather & Market     |
| Scanner Module   |           | & Voice Advisory |           | Services             |
+------------------+           +------------------+           +----------------------+
     |                                   |                                   |
     | (Image Bytes / Base64)            | (Turn-based Prompt)               | (Geolocator / Query)
     v                                   v                                   v
+------------------------------------------------------------------------------------+
|                             DYNAMIC MODEL DISCOVERY                                |
|           Selects Best Available Model (e.g. Gemini 1.5 Flash Vision / Chat)        |
+------------------------------------------------------------------------------------+
     |                                   |                                   |
     v                                   v                                   v
+------------------+           +------------------+           +----------------------+
| Gemini Vision AI |           | Gemini LLM Engine|           | OpenWeather &        |
| Image Parsing    |           | Speech-to-Text   |           | APMC Mandi APIs      |
+------------------+           +------------------+           +----------------------+
     |                                   |                                   |
     | (Structured Response)             | (Response Stream / Sync)          | (Live Weather/Prices)
     v                                   v                                   v
+------------------+           +------------------+           +----------------------+
| PDF Report Engine|           | Cloud Firestore  |           | Real-time UI Cards   |
| (Devanagari Font)|           | Chat History Sync|           | & Alert Banners      |
+------------------+           +------------------+           +----------------------+
     |                                                                       |
     v                                                                       v
+------------------------------------------------------------------------------------+
|                              OUTPUT & ACTION LAYER                                 |
|      - Downloadable & Shareable PDF Report (Print / WhatsApp / Email)               |
|      - Interactive Voice TTS Response (Marathi & English)                          |
|      - Localized Mandi Prices & Weather Warnings                                  |
+------------------------------------------------------------------------------------+
```

---

### 2. Disease Detection & PDF Report Pipeline

```text
[Farmer Takes / Selects Photo]
              │
              ▼
[Image Pre-Processing & Quality Optimization] (1024x1024, JPEG compression)
              │
              ▼
[Base64 Encoding & API Dispatch] (Gemini 1.5 Flash Vision API)
              │
              ▼
[AI Structured Analysis] ──► Extracts: - Crop Name
                                       - Disease Name
                                       - Symptoms
                                       - Organic Remedies
                                       - Chemical Remedies & Dosages
                                       - Preventive Measures
              │
              ▼
[Resilient Section Parser] (Cleans Markdown, parses regional/English labels)
              │
              ▼
[UI Result Render] ──► Displays expandable detailed cards on app
              │
              ▼
[Trigger: Download PDF Report]
              │
              ▼
[PDF Engine Pipeline]
   ├── 1. Load Devanagari Fonts (NotoSansDevanagari Regular & Bold)
   ├── 2. Embed High-Res Compressed Crop Image Bytes
   ├── 3. Format Farmer Profile, Timestamp & Structured Findings
   ├── 4. Render Standardized Printable A4 Layout
   └── 5. Dispatch to Printing / Download / Web Share Service
              │
              ▼
[Output PDF File Ready] (ShetkariAI_Report.pdf)
```

---

### 3. Voice & Chat Advisory Workflow

```text
[Farmer Voice Input] ──► [Speech-To-Text Engine] ──► [Converted Text Query]
                                                              │
                                                              ▼
[Context-Aware Prompt Pipeline] ◄── [Farmer Profile & Language Preference]
              │
              ▼
[Gemini 1.5 Chat Engine] ──► [Contextual Agricultural Advice]
              │
              ├──► [Save Chat History to Cloud Firestore]
              │
              └──► [Text-To-Speech Engine] ──► [Audio Readout in Marathi/English]
```

---

## 📄 Disease PDF Report Generation

Anyone using **Shetkari AI** (on mobile or the live web app) can generate a formal agricultural disease diagnosis report in seconds.

### Step-by-Step Report Generation Process:

1. **Access the Web or Mobile App**:
   - Open [https://shetkariai-250ef.web.app/](https://shetkariai-250ef.web.app/) in any web browser or open the mobile app.
2. **Enter Profile Nickname**:
   - Enter your name/nickname (e.g., *Shetkari Mitra* / *Rahul Patil*).
3. **Navigate to Disease Detection**:
   - Click on **Disease Detection (रोग निदान)** from the bottom navigation bar or home menu.
4. **Capture or Upload Crop Image**:
   - Click **Camera** to snap a photo of diseased leaves/crops, or **Gallery** to select an existing photo.
5. **Analyze Image**:
   - The system automatically triggers the Gemini Vision pipeline to detect crop species, pathology, symptoms, and organic/chemical remedies.
6. **Generate & Export PDF Report**:
   - Click on the red **"Download PDF Report" (अहवाल डाउनलोड करा)** button.
   - The app dynamically compiles the PDF with full **Devanagari script rendering** (`NotoSansDevanagari`), crop image, remedies, date, farmer nickname, and official agricultural disclaimers.
7. **Print / Share**:
   - **On Web**: Instantly opens browser PDF preview window to save or print directly.
   - **On Mobile**: Opens the system share drawer to share via WhatsApp, Email, or save to Device Files.

---

## ✨ Key Features

| Feature | Description | Support |
| :--- | :--- | :--- |
| **📸 AI Crop Disease Diagnosis** | Instant image scanning to detect crop diseases and prescribe treatments | Marathi & English |
| **📄 PDF Report Engine** | Generates formatted, printable PDF diagnostic reports with Devanagari font support | Marathi & English |
| **💬 Multilingual AI Chat** | Conversational assistant for farming, soil, pest, and crop advisories | Marathi & English |
| **🎙️ Speech & TTS Advisory** | Voice search and double-tap voice readout for low-literacy accessibility | Marathi & English |
| **🌤️ Weather & Crop Alerts** | Real-time weather monitoring (temperature, humidity, wind) and hazard warnings | Geolocation / Auto |
| **📈 Live APMC Mandi Rates** | Live crop prices, market trends (up/down), and location-specific rates | Local Mandis |
| **🏛️ Govt Schemes Portal** | Guidance and eligibility details for PM-KISAN, Insurance, and Credit Schemes | Marathi & English |
| **☁️ Cloud Sync** | Persistent chat history and profile management using Firebase Cloud Firestore | Multi-device |

---

## 🛠️ Tech Stack & Architecture

| Layer | Technology / Package | Purpose |
| :--- | :--- | :--- |
| **Frontend Framework** | Flutter 3.x (Dart 3.11) | Cross-platform UI for Web, Android, iOS, Windows |
| **State Management** | `flutter_riverpod: ^2.5.1` | Reactive state management and dependency injection |
| **AI Vision & Chat** | `google_generative_ai: ^0.4.5` / Gemini 1.5 | Disease vision analysis and turn-based chat |
| **PDF Generation** | `pdf: ^3.10.8` | High-performance PDF document composition |
| **PDF Printing & Sharing** | `printing: ^5.11.1` | Cross-platform PDF layout rendering and sharing |
| **Devanagari Fonts** | `PdfGoogleFonts.notoSansDevanagariRegular()` | Marathi Devanagari script rendering in PDFs |
| **Backend & Cloud DB** | `firebase_core: ^3.10.1`, `cloud_firestore: ^5.6.2` | Profile storage and persistent chat logs |
| **Voice & Speech** | `speech_to_text: ^7.4.0`, `flutter_tts: ^4.0.2` | Speech-To-Text listening & Text-To-Speech audio output |
| **Location Services** | `geolocator: ^12.0.0`, `geocoding: ^3.0.0` | GPS location lookup for weather and mandi rates |
| **Typography & UI** | Google Fonts (`Mukta` & `Poppins`), Material 3 | Modern, responsive agricultural UI design |

---

## 📂 Directory & Project Structure

```text
shetkariai/
├── web/                           # Web deployment assets & index.html
├── android/                       # Android native project configuration
├── lib/
│   ├── firebase_options.dart      # Multi-platform Firebase configuration
│   ├── main.dart                  # App entry point, main navigation & screens
│   └── src/
│       ├── core/
│       │   ├── config/
│       │   │   └── app_config.dart          # API Keys & endpoint definitions
│       │   ├── localization/
│       │   │   ├── app_translations.dart   # Marathi & English translation dictionary
│       │   │   └── language_provider.dart  # Language state manager
│       │   └── navigation/
│       │       └── navigation_provider.dart# Bottom navigation state manager
│       └── features/
│           ├── auth/                        # User onboarding & profile setup
│           ├── chat/                        # Gemini AI chat & Firestore sync
│           │   └── chat_provider.dart
│           ├── disease/                     # AI Disease detection & PDF Report Engine
│           │   ├── disease_provider.dart
│           │   └── report_generator.dart
│           ├── market/                      # APMC Mandi market rates
│           │   └── market_provider.dart
│           ├── profile/                     # Farmer profile & preference settings
│           │   └── profile_provider.dart
│           ├── schemes/                     # Government schemes guide
│           │   └── schemes_screen.dart
│           └── weather/                     # Live OpenWeather integration & alerts
│               └── weather_provider.dart
└── pubspec.yaml                   # Project dependencies and Flutter configuration
```

---

## 🚀 Getting Started

### 1. Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>= 3.11.0`)
- [Dart SDK](https://dart.dev/get-dart)
- Chrome / Android Studio / VS Code
- Google Gemini API Key ([Get Key](https://aistudio.google.com/))
- Firebase Account configured for Flutter

### 2. Local Setup & Installation

```bash
# Clone the project repository
git clone https://github.com/your-username/shetkariai.git

# Navigate into project directory
cd shetkariai

# Install project dependencies
flutter pub get

# Launch on Web or Device
flutter run -d chrome
```

---

## ⚙️ Configuration & API Management

Configure API keys in `lib/src/core/config/app_config.dart`:

```dart
class AppConfig {
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY';
  static const String openWeatherApiKey = 'YOUR_OPENWEATHER_API_KEY';
  static const String dataGovApiKey = 'YOUR_DATA_GOV_API_KEY';
}
```

---

## 🛣️ Roadmap & Future Scope

- [x] **Live Web Deployment**: Web app live at `https://shetkariai-250ef.web.app/`
- [x] **Devanagari PDF Report Engine**: Instant downloadable disease reports.
- [ ] **Offline TFlite Crop Models**: Edge AI detection for remote offline farms.
- [ ] **Community Farmer Forum**: Peer-to-peer farmer knowledge sharing.
- [ ] **IoT Soil Sensor Sync**: Direct integration with soil moisture and NPK hardware sensors.

---

## ⚠️ Disclaimer

*The diagnostic reports and advice generated by **Shetkari AI** are produced by Artificial Intelligence algorithms. While engineered to provide high-accuracy agricultural guidance, farmers are advised to consult local agricultural extension officers or certified agronomists for official crop management decisions.*

---

**Shetkari AI (शेतकरी AI) — Dedicated to Empowering Farmers Worldwide 🌾**  
🌐 [Try Live Web App: https://shetkariai-250ef.web.app/](https://shetkariai-250ef.web.app/)

