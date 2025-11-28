

# 🎵 Music Explorer App

A Flutter application that allows users to search, preview, and manage their favorite songs.
This README explains **complete setup steps** and **how the project works** after you clone it.

---

# 📦 1. Project Setup After Cloning

Follow these steps to run the project for the first time.

---

## ✅ Step 1: Install Flutter (If not installed)

Check Flutter installation:

```sh
flutter --version
```

If not installed:
[https://docs.flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install)

---

## ✅ Step 2: Clone the Repository

```sh
git clone <your-repo-url>
cd music_explorer_app
```

---

## ✅ Step 3: Get Project Dependencies

Run:

```sh
flutter pub get
```

This installs all plugins like:

* provider
* shimmer
* audioplayers
* shared_preferences
* http
* etc.

---

## ✅ Step 4: Run the App

To run on emulator / device:

```sh
flutter run
```

Or specify device:

```sh
flutter run -d chrome
flutter run -d android
flutter run -d ios
```

---

# 📱 2. How to Navigate Inside the App

After running the app:

### ▶ Home Screen Appears

* You will see a **list of music tracks**.
* These tracks come from an API (like iTunes Search API).

### ▶ Tap on Any Song

When you tap on a song card, you are navigated to:

---

# 🎧 3. Song Detail Page (This Page You Showed in Code)

This page shows:

### ✔ Album Artwork

Full-size image of the song.

### ✔ Song Information

* Track Name
* Artist Name
* Album Name

### ✔ 30-Second Audio Preview

The page has a built-in **audio player** using `audioplayers`.

You can:

* ▶ Play the 30-second preview
* ⏸ Pause
* ⏪ Rewind 5 seconds
* ⏩ Forward 5 seconds
* 🎚 Move timeline slider
* Time formatting (00:00 – 00:30)

If the song completes, it automatically restarts.

---

# 💖 4. Favorites Feature

The song detail page includes a **Favorite** / **Unfavorite** button.

It uses:

* `Provider`
* Local storage via `SharedPreferences`

Once favorited, it appears in your favorites list.

---

# ✨ 5. Shimmer Loading Effect

When the detail page loads:

* A **shimmer skeleton loader** appears for 1 second
* After that, full page content is displayed

This gives a smooth UI experience.

---

# 🎚 6. Audio Player Logic Explained

* Uses `AudioPlayer` from `audioplayers`
* Handles:

  * Duration listener
  * Position listener
  * Repeat on complete
* Limits preview to **30 seconds**
* Auto-stops after 30 seconds using a `Timer`

---

# 📁 7. Folder Structure

```
lib/
 ├── main.dart
 ├── provider/
 │     ├── song_provider.dart
 │     └── theme_provider.dart
 ├── screen/
 │     ├── home_screen.dart
 │     ├── song_detail_page.dart  ← (Your Page)
 ├── theme/
 │     ├── app_theme.dart
 │     ├── app_colors.dart
 │     └── app_spacing.dart
 ├── widgets/
 │     └── song_card.dart
 └── utils/
       └── helpers.dart
```

---

# 🧪 8. How to Build APK

```sh
flutter build apk
```

Release build:

```sh
flutter build apk --release
```

APK will be located in:

```
build/app/outputs/flutter-apk/app-release.apk
```

---

# 🌐 9. Internet Permission (Auto-enabled)

Flutter automatically adds internet permission, but to be safe:

`android/app/src/main/AndroidManifest.xml`

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

---

# 🚀 10. Features Summary

| Feature             | Description                    |
| ------------------- | ------------------------------ |
| Song Search         | Search and browse songs        |
| Audio Player        | Preview songs for 30 seconds   |
| Favorites           | Add/remove favorite tracks     |
| Dark/Light Mode     | Theme switching                |
| Shimmer UI          | Smooth loading skeleton        |
| Provider State Mgmt | Efficient & clean architecture |

---

# 🛠 11. Technologies Used

* Flutter 3.x+
* Provider (State Management)
* Audioplayers Plugin
* Shimmer Loading
* SharedPreferences
* Material Design 3

---

# 🎯 12. Future Enhancements

* Download full songs
* Custom playlists
* Offline mode
* Animation improvements

