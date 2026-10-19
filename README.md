# Shetkari AI (शेतकरी AI) 🌾🤖

> **Your 24/7 Digital Agriculture Assistant & Crop Health Expert**

**Shetkari AI** is an AI-powered smart agricultural Flutter application designed to assist farmers with instant crop disease detection, localized weather forecasts, live mandi/market prices, government scheme guidance, and interactive multi-lingual AI assistance (Marathi & English) with voice support.

---

## 📋 Table of Contents
- [Key Features](#key-features)
- [Disease PDF Report Generation](#disease-pdf-report-generation)
- [Tech Stack & Architecture](#tech-stack--architecture)
- [Directory & Project Structure](#directory--project-structure)
- [Getting Started](#getting-started)
- [Configuration & API Setup](#configuration--api-setup)
- [Features Overview](#features-overview)
- [Disclaimer](#disclaimer)

---

## Key Features

- **📸 AI Crop Disease Diagnosis**: Capture or upload crop images to instantly analyze crop health, identify diseases, and view detailed symptoms along with organic & chemical treatment options.
- **📄 Instant PDF Report Generation**: Automatically generate formatted, shareable, and printable PDF reports for any crop analysis with full **Devanagari (Marathi)** and **English** font support.
- **💬 Multilingual AI Chatbot**: Conversational assistant powered by Google Gemini 1.5, answering agricultural questions in Marathi (मराठी) and English.
- **🎙️ Voice Input & Text-To-Speech (TTS)**: Hands-free interaction with Speech-To-Text listening and double-tap Text-To-Speech voice output.
- **🌤️ Real-Time Weather & Alerts**: Localized weather conditions (temperature, humidity, wind speed) and weather warnings to protect crops.
- **📈 Live Mandi / Market Rates**: Track current crop prices and price trends across various agricultural markets (APMC Mandis).
- **🏛️ Government Schemes**: Information and guidance on agricultural schemes like PM-KISAN, PM Fasal Bima Yojana, Kisan Credit Card, etc.
- **🌐 Dual Language Support**: Dynamic language switching between Marathi (मराठी) and English.
- **☁️ Firebase Integration**: Persistent chat history and profile management powered by Cloud Firestore.

---

## Disease PDF Report Generation

Anyone using **Shetkari AI** can easily generate, view, download, print, or share a comprehensive crop diagnosis report in PDF format.

### How to Generate a Report:

1. **Open the App**: Launch **Shetkari AI** on Mobile, Tablet, or Web.
2. **Navigate to Disease Detection**: Tap on the **Disease Detection (रोग निदान)** tab on the navigation bar.
3. **Capture / Select Image**:
   - Tap **Camera** to capture a photo of the affected crop/leaf.
   - Tap **Gallery** to upload an existing photo.
4. **AI Analysis**: The app utilizes Gemini Vision AI to analyze the photo and extract structured findings:
   - Crop Name
   - Detected Disease
   - Symptoms
   - Organic Remedies
   - Chemical Remedies & Recommended Dosages
   - Preventive Measures
5. **Generate PDF**:
   - Scroll down on the result screen and tap **"Download PDF Report"** (अहवाल डाउनलोड करा).
   - The app dynamically compiles the image, farmer profile details, timestamp, and AI-analyzed treatment steps using Devanagari script support (`NotoSansDevanagari`).
6. **Print or Share**:
   - **Mobile (Android/iOS)**: Open system print preview or share the PDF directly via WhatsApp, Email, or Google Drive.
   - **Web**: Directly opens browser PDF layout preview to save or print.

---

## Tech Stack & Architecture

- **Framework**: [Flutter](https://flutter.dev/) (Dart SDK `^3.11.0`)
- **State Management**: [Flutter Riverpod](https://pub.dev/packages/flutter_riverpod) (`^2.5.1`)
- **AI Models**: Google Generative AI / Gemini API (`google_generative_ai: ^0.4.5`, Gemini 1.5 Flash / Vision)
- **PDF Generation & Printing**: `pdf: ^3.10.8`, `printing: ^5.11.1`
- **Backend & Database**: Firebase Core (`firebase_core: ^3.10.1`), Cloud Firestore (`cloud_firestore: ^5.6.2`)
- **Voice Services**: `speech_to_text: ^7.4.0`, `flutter_tts: ^4.0.2`
- **Location & Mapping**: `geolocator: ^12.0.0`, `geocoding: ^3.0.0`
- **Fonts & UI Design**: Material 3, `google_fonts` (`Mukta` for Marathi, `Poppins` for English)
- **Media & File Handling**: `image_picker: ^1.1.2`, `path_provider: ^2.1.2`

---

## Directory & Project Structure

```text
lib/
├── firebase_options.dart         # Firebase multi-platform configuration
├── main.dart                     # Main app entry point, navigation & UI screens
└── src/
    ├── core/
    │   ├── config/
    │   │   └── app_config.dart   # API Keys and app constants
    │   ├── localization/
    │   │   ├── app_translations.dart   # Marathi & English translation dictionary
    │   │   └── language_provider.dart  # Language state notifier
    │   └── navigation/
    │       └── navigation_provider.dart # Navigation index notifier
    └── features/
        ├── auth/                  # Authentication & user setup
        ├── chat/                  # AI Chatbot & Firestore chat history
        │   └── chat_provider.dart
        ├── disease/               # Image analysis & PDF report generation
        │   ├── disease_provider.dart
        │   └── report_generator.dart
        ├── market/                # Mandi / Market prices feature
        │   └── market_provider.dart
        ├── profile/               # Farmer profile & nickname state
        │   └── profile_provider.dart
        ├── schemes/               # Government schemes & guidance screen
        │   └── schemes_screen.dart
        └── weather/               # Live weather API & alerts
            └── weather_provider.dart
```

---

## Getting Started

### Prerequisites

Ensure you have the following installed on your development machine:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>= 3.11.0`)
- [Dart SDK](https://dart.dev/get-dart)
- Android Studio / VS Code with Flutter extension
- Firebase Project configured for Flutter
- Google Gemini API Key

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-username/shetkariai.git
   cd shetkariai
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**:
   - Place your `google-services.json` in `android/app/`.
   - Configure `lib/firebase_options.dart` with your Firebase credentials.

4. **Run the App**:
   ```bash
   flutter run
   ```

---

## Configuration & API Setup

API credentials can be configured in `lib/src/core/config/app_config.dart`:

```dart
class AppConfig {
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY';
  static const String openWeatherApiKey = 'YOUR_OPENWEATHER_API_KEY';
  static const String dataGovApiKey = 'YOUR_DATA_GOV_API_KEY';
}
```

---

## Features Overview

| Feature | Description | Supported Languages |
| :--- | :--- | :--- |
| **Disease Diagnosis** | Upload photo $\rightarrow$ Get structured diagnosis with organic & chemical cure | Marathi / English |
| **PDF Report** | Export report with crop details, remedies & disclaimer | Marathi / English |
| **AI Advisory** | Gemini-powered assistant for daily farming queries | Marathi / English |
| **Voice Command** | Voice prompt input and speech readout | Marathi / English |
| **Live Weather** | Local weather forecast, humidity, wind & warnings | Global / Multi-city |
| **Market Rates** | APMC Market rate updates & price trends | Local Mandis |
| **Govt Schemes** | Guidance on PM-KISAN, Insurance & Loans | Marathi / English |

---

## Disclaimer

*The diagnostic reports and advice generated by **Shetkari AI** are produced by Artificial Intelligence models. While designed to provide accurate guidance, farmers are advised to consult local certified agricultural experts or official government agricultural extension officers for critical farm management decisions.*

---

Made with ❤️ for Farmers 🌾
#   S h e t k a r i A I  
 #   S h e t k a r i A I  
 