# Time Words

**Time Words** is an Apple Watch and iPhone application that tells the time **in words**, rounding to the nearest five minutes, with a human touch that indicates if it is **just past** or **almost** the time. It supports four languages: English, Spanish, Japanese, and Catalan.

## 📱 Platforms

- **iOS 18.0+** (iPhone app + Home Screen widgets)
- **watchOS 10.0+** (standalone Watch App + complications & Lock Screen widgets)

## 🎯 Key Features

- **Human‑style time**: Rounds minutes to 5‑minute increments with prefixes like “just past,” “almost,” or “exactly.”
- **Multi‑language**: English, Spanish, Japanese (kanji/hiragana), and Catalan (quarts system).
- **Tap to switch**: Cycle through languages by tapping anywhere in the Watch App or iPhone app; updates instantly across all widgets and complications.
- **WidgetKit integration**: Small, Medium, Large widgets for iPhone Home Screen; Lock Screen Inline & Rectangular for iOS 16+.
- **Complications**: AppIntentTimelineProvider for per‑minute updates in watch faces.
- **Dynamic sizing**: Text scales to fill available space using custom SwiftUI views (`SingleLineSizedText` & `ThreeLineSizedText`).

## 🚀 Installation & Build

1. **Clone** this repository:
   ```bash
   git clone https://github.com/your-username/TimeWords.git
   cd TimeWords
   ```
2. **Open** the Xcode project:
   ```bash
   open TimeWords.xcodeproj
   ```
3. **Configure Signing**:
   - Select your Team and ensure provisioning profiles are set for both iOS and watchOS targets.
   - Adjust Bundle Identifiers if necessary (e.g., `com.yourcompany.timewords`).
4. **Run on Simulator or Device**:
   - **iPhone**: Choose the `TimeWords-iOS` scheme, build (⌘B), and run (⌘R).
   - **Apple Watch**: Choose the `TimeWords-WatchApp` scheme with a paired Watch & iPhone simulator/device.
5. **Archive** for TestFlight/App Store:
   - Select **Any iOS Device (ARM)** as the run destination.
   - **Product → Archive** in Xcode, then **Distribute App** → **App Store Connect** → **Upload**.

## 🗂️ Project Structure

```
TimeWords/
├── Shared/
│   └── TimeFormatter.swift    # Core logic: convert Date → spoken time
├── TimeWordsApp/              # iOS App & WidgetKit Extension
│   ├── TimeWordsApp.swift     # Main SwiftUI app entry
│   └── Widgets/               # Widget Extension
│       ├── TimeWordsWidget.swift
│       └── Supporting files…
├── TimeWordsWatchApp/         # watchOS standalone App & Complications
│   ├── ContentView.swift      # Watch App UI
│   └── ComplicationProvider.swift
├── LICENSE                    # MIT License
└── README.md                  # This file
```

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

1. **Fork** the project.
2. Create your feature branch: `git checkout -b feature/YourFeature`.
3. Commit your changes: `git commit -m 'Add some feature'`.
4. Push to the branch: `git push origin feature/YourFeature`.
5. Open a **Pull Request**.

## 📄 License

Distributed under the **MIT License**. See [LICENSE](LICENSE) for details.

> *Time told beautifully is priceless.*

