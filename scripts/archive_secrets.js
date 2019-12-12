const { execSync } = require("child_process");

const flavors = ["dev", "prod"];

const firebaseSecretFiles = flavors
  .map(flavor => [
    `android/app/src/${flavor}/google-services.json`,
    `ios/config/${flavor}/GoogleService-Info.plist`
  ])
  .reduce((accm, curr) => accm.concat(curr), []);

const secretFiles = [
  // Android build:
  "android/key.properties",
  "android/app/serviceAccount.json",
  "android/app/upload.keystore",

  //Firebase:
  ...firebaseSecretFiles,

  // Environment:
  ...flavors.map(flavor => `.env.${flavor}`)
];

async function archiveSecrets() {
  console.log(
    [
      "💾  Archiving files:",
      ...secretFiles.map(filename => `📄  ${filename}`)
    ].join("\n")
  );

  try {
    execSync(`tar cf secrets.tar ${secretFiles.join(" ")}`);
    console.log(`🎉  Successfully archived ${secretFiles.length} files.`);
  } catch (e) {
    console.log(`An error occured during archiving:`);
    console.log(e);
  }
}

archiveSecrets();
