# galpi

![Galpi app image](https://github.com/heejongahn/galpi/raw/master/docs/static/galpi.gif)

Book logging app made with Flutter.

## Build

Following secret files are required for build.

Android build:

- `android/key.properties`
- `android/app/serviceAccount.json`
- `android/app/upload.keystore`

Firebase:

- `android/app/google-services.json`
- `ios/GoogleService-Info.plist`

For CI build, these files should also be uploaded to travis after encryption.

```sh
yarn secrets:archive
yarn secrets:sync
```

## Deployment

### iOS

```
flutter build ios --build-number=$(date "+%Y%m%d%H%M%S")
```

### Android

(TBD)
