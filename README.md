# galpi

![Galpi app image](https://github.com/heejongahn/galpi/raw/master/docs/static/galpi.gif)

Book logging app made with Flutter.

## Build

There are some secret files required for the build.
These files include credentials for android build, firebase and more.
For CI build, they should also be uploaded to travis CI (as env variables) after encryption.

Encryption and upload of secrets are done by npm scripts. (Node and Travis CI is needed)
For more details, see `scripts/archive_secrets.js` file.

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
