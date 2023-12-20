# Openshock Mobile Companion
> Companion app for managing openshock-compatible devices
> 
> Minimum supported Android API: 31 (Android 12).
> Minimum required iOS version: 14
> 

![lang](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white) ![os1](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white) ![os1](https://img.shields.io/badge/iOS-050505?style=for-the-badge&logo=apple&logoColor=white) 

Flutter application to manage and control openshock devices from your phone.

Current build status(android): [![Nightly Android](https://github.com/NotLugozzi/openshock-android/actions/workflows/build-android.yml/badge.svg)](https://github.com/NotLugozzi/openshock-android/actions/workflows/build-android.yml)

# Installing
## Stable release channel
Grab one of the builds from the releases page or run:
```bash
flutter build apk
```
Production artifacts will be found in the `build\app\outputs\apk\` directory.

## RRC (Rolling Release Channel)
There's also a Rolling release available as a GitHub Actions artifact. It runs every time I commit, so it might be up to date but also potentially broken.

# Building for Android
Make sure you have [Flutter](https://flutter.dev/), [Android Studio](https://developer.android.com/studio), and [Visual Studio Code](https://code.visualstudio.com/) installed. Install the suggested Flutter, Dart, and linting extensions in Visual Studio Code.

Run the following commands to ensure all dependencies are met:
```bash
flutter doctor
```

You'll be guided through a first-time setup that checks for platform tools, dependencies, and missing components.

Once the setup is complete you can navigate to the repo folder and run
```bash
flutter run
```
If you want to build debug you can also run 
```bash
flutter build apk --debug
```
Build artifacts for Android are saved under `build\app\outputs\apk`.


# Building for iOS (manual installation required)
Make sure you have [Flutter](https://flutter.dev/), [xCode and Apple Developer Tools](https://apps.apple.com/en/app/xcode/id497799835?mt=12), [cocoapods](https://formulae.brew.sh/formula/cocoapods), and [Visual Studio Code](https://code.visualstudio.com/) installed.
Install the suggested Flutter, Dart, and linting extensions in Visual Studio Code and set up xcode for "iOS on iphone" developement. Once that is done, go in the project's folder and run the following command to ensure that your build environment is properly configured, any missing component will be highlighted
```bash
flutter doctor
```

Once you've done that, from the same terminal, run this command to generate a .IPA file - once you're done it's a matter of sideloading it to your device. since i've never owned an apple device i have no idea how to do that. iOS artifacts are saved in `build/ios/runner/`
```bash
flutter build ios --debug
```
