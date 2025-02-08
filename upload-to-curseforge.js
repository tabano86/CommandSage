#!/usr/bin/env node
"use strict";

const fs = require("fs");
const path = require("path");
const archiver = require("archiver");
const fetch = require("node-fetch");
const FormData = require("form-data");

// ----- Configuration variables -----
const addonFolder = "CommandSage";
const distDir = path.join(process.cwd(), "dist");
const curseforgeProjectId = process.env.CURSEFORGE_PROJECT_ID;
const curseforgeToken = process.env.CURSEFORGE_TOKEN;
const gameVersions = ["1.13.2"];
const releaseType = "release"; // or "beta", etc.

// ----- Package the addon into a zip file -----
function packageAddon(version) {
    return new Promise((resolve, reject) => {
        if (!fs.existsSync(distDir)) {
            fs.mkdirSync(distDir);
        }
        const zipPath = path.join(distDir, `${addonFolder}-${version}.zip`);
        const output = fs.createWriteStream(zipPath);
        const archive = archiver("zip", { zlib: { level: 9 } });

        output.on("close", () => {
            console.log(`➤ [Packaging] Created ${zipPath} (${archive.pointer()} bytes)`);
            resolve(zipPath);
        });

        archive.on("error", (err) => reject(err));

        archive.pipe(output);
        // Exclude folders that shouldn’t be packaged.
        archive.directory(addonFolder, addonFolder, (entry) => {
            const skipDirs = [".git", ".github", "tests", "scripts", "dist"];
            for (const skip of skipDirs) {
                if (entry.name.startsWith(skip)) return false;
            }
            return entry;
        });
        archive.finalize();
    });
}

// ----- Build metadata for CurseForge upload -----
function buildMetadata(version, changelog) {
    return {
        releaseType,
        changelog,
        changelogType: "markdown",
        displayName: `${addonFolder}-${version}`,
        gameVersions,
    };
}

// ----- Upload the zip file to CurseForge -----
async function uploadToCurseForge(zipPath, metadata) {
    const url = `https://api.curseforge.com/v1/projects/${curseforgeProjectId}/upload-file`;
    const fileStream = fs.createReadStream(zipPath);

    const formData = new FormData();
    formData.append("metadata", JSON.stringify(metadata));
    formData.append("file", fileStream);

    console.log("➤ [Upload] Uploading to CurseForge...");
    const response = await fetch(url, {
        method: "POST",
        headers: {
            "x-api-token": curseforgeToken,
        },
        body: formData,
    });
    if (!response.ok) {
        const errText = await response.text();
        throw new Error(`Upload failed: ${response.status} ${response.statusText}\n${errText}`);
    }
    const data = await response.json();
    console.log("➤ [Upload] Upload successful. Response:");
    console.log(JSON.stringify(data, null, 2));
}

async function main() {
    try {
        // The version is automatically determined by semantic-release.
        const version = process.env.ADDON_VERSION || process.argv[2];
        if (!version) {
            console.error("ERROR: No version specified. Set ADDON_VERSION env var or pass as argument.");
            process.exit(1);
        }
        // Read CHANGELOG.md if available
        const changelog = fs.existsSync("CHANGELOG.md")
            ? fs.readFileSync("CHANGELOG.md", "utf8")
            : "";
        console.log(`➤ [Upload] Starting upload for version ${version}`);
        const zipPath = await packageAddon(version);
        const metadata = buildMetadata(version, changelog);
        console.log("➤ [Upload] Metadata prepared:");
        console.log(JSON.stringify(metadata, null, 2));
        await uploadToCurseForge(zipPath, metadata);
    } catch (err) {
        console.error("➤ [Upload] Error:", err);
        process.exit(1);
    }
}

main();
