# Cordova Testflight Detector
Detect how the app is installed on iOS and Android.

## Installation
Simply run
```
cordova plugin add https://github.com/quintenadema/cordova-plugin-testflight-detector
```

## Usage
Check the installed method
```
const installedMethod = await testflightDetector.check();
console.log(installedMethod);
```

`installedMethod` can be one of the following:
- `debug` means the app was installed via TestFlight or sideloaded
- `production` means the app was installed via the official App / Play store
