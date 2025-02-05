#!/usr/bin/env node
"use strict";

const fs = require("fs");
const path = require("path");
const { exec } = require("child_process");

if (process.argv.length < 4) {
    console.error("Usage: publish-curseforge.js <zipPath> <curseforgeToken>");
    process.exit(1);
}

const zipPath = process.argv[2];
const token = process.argv[3];

if (!fs.existsSync(zipPath)) {
    console.error("Zip file not found:", zipPath);
    process.exit(1);
}

console.log("Uploading", zipPath, "to CurseForge with token", token);
// Replace the following command with your real API call.
// For example, using curl:
const curlCmd = `curl -X POST "https://api.curseforge.com/v1/addon/upload" -H "x-api-key: ${token}" -F "file=@${zipPath}"`;
exec(curlCmd, (err, stdout, stderr) => {
    if (err) {
        console.error("Upload failed:", err);
        process.exit(1);
    }
    console.log("Upload response:", stdout);
});
