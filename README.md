# openshock-android
> Companion app for managing openshock-compatible devices
>
> 
![lang](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white) ![os1](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)

Flutter application to manage and control openshock devices from your phone

# Testing
Get both [flutter](https://flutter.dev/) and [android studio](https://developer.android.com/studio), make sure to be able to reach flutter from any terminal by running 

`flutter --version`

then cd in the repository folder and run the following commands. You'll be greeted by a first time setup that will check for platform tools, dependencies and possible missing stuff. build artifacts won't be saved when building for android unless running the build command

```bash
flutter run
```

# Installing
### **Release builds are currently broken! if you know how to flutter shoot me a dm on discord @olbiaphlee, we can get in touch to get it to work!**
Grab one of the builds from the releases page or run:
```bash
flutter build apk
```

production artifacts will be found in the `build\app\outputs\apk\` directory
