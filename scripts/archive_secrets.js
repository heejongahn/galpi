const { execSync } = require("child_process");

const secretFiles = [
  // Android build:
  "android/key.properties",
  "android/app/serviceAccount.json",
  "android/app/upload.keystore",

  //Firebase:
  "android/app/google-services.json",
  "ios/GoogleService-Info.plist"
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
