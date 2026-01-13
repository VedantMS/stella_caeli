# Stella Caeli 🌌  
*A Mobile Planetarium & Constellation Visualization App*

Stella Caeli is a Flutter-based mobile application that visualizes the night sky in real time using astronomical data, device orientation, and observer location.  
The project is developed as a **Final Year Computer Science project** with a focus on clean architecture, astronomy fundamentals, and interactive visualization.

---

## ✨ Features

- **Live Sky View**
  - Real-time star positions based on current date, time, and location
  - Device-orientation–based camera movement

- **Manual Time & Location Mode**
  - Simulate the sky for different countries and dates
  - Educational exploration of seasonal constellations

- **Constellation Visualization**
  - Line-based constellation rendering
  - Selectable constellations with directional guidance (arrow navigation)

- **Constellation Information Pages**
  - Mythology and historical background
  - Best months for observation
  - Famous stars per constellation

- **Minimalist UI**
  - Indoor planetarium-style dark theme
  - Reticle-based interaction model

---

## 🧠 Architecture Overview

The application follows a **modular, service-oriented architecture**:

- **Controllers**
  - `SkyController` – Orchestrates sky updates
  - `SettingsController` – Handles live/manual modes

- **Services**
  - Astronomy engine (RA/Dec → Alt/Az conversion)
  - Orientation service (sensor fusion)
  - Location & time services

- **State Management**
  - Central `SkyState` model
  - Reactive UI updates via `AnimatedBuilder`

This separation ensures **maintainability, testability, and clarity**.

---

## 📊 Astronomical Data

- **Star Catalog**
  - Hipparcos catalog (filtered subset)
  - Right Ascension, Declination, magnitude

- **Constellations**
  - Manually curated constellation line data
  - Supports multiple classical constellations

---

## 🛠 Tech Stack

- **Framework:** Flutter (Dart)
- **Sensors:** `sensors_plus`
- **Location:** `geolocator`
- **Persistence:** `shared_preferences`
- **Platform:** Android (APK build)

---

## 🚀 Installation (Local APK)

1. Download the APK from the GitHub Releases section
2. Enable **Install from unknown sources** on Android
3. Install and run the app

> The app is intended for **educational and academic use** and is not published on the Play Store.

---


## ⚠️ Limitations

- Limited star catalog (performance-focused)
- No deep-sky objects yet (nebulae, galaxies)
- Android-only build for now

---

## 🎓 Academic Context

- **Project Type:** Final Year Project (B.Sc. Computer Science)
- **Focus Areas:**
  - Computational astronomy
  - Sensor-driven visualization
  - Mobile application architecture

---

## 📜 License

This project is developed for academic purposes.  
All astronomical data sources are publicly available.

---

## 👤 Author

**Vedant Salunke**  
B.Sc. Computer Science  
