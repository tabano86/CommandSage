#!/usr/bin/env node
"use strict";

const fs = require("fs");
const path = require("path");
const archiver = require("archiver");
const fetch = require("node-fetch");

//–– Configuration ––
// The folder name of your add-on (must be a single top-level directory)
const addonFolder = "CommandSage";
// The output directory for the packaged zip file
const distDir = path.join(process.cwd(), "dist");
// The CurseForge API endpoint –– your project ID comes from your CurseForge project settings
const curseforgeProjectId = process.env.CURSEFORGE_PROJECT_ID;
const curseforgeToken = process.env.CURSEFORGE_TOKEN;
// The game version(s) for your add-on. Adjust as needed.
const gameVersions = ["1.13.2"];
// The release type (usually "release")
const releaseType = "release";

//–– Utility Functions ––

/**
 * Package the add-on folder into a zip file.
 * The zip will contain a single top-level folder (addonFolder).
 * Unwanted files/folders (like .git, tests, scripts, etc.) are excluded.
 */
function packageAddon(version) {
    return new Promise((resolve, reject) => {
        if (!fs.existsSync(distDir)) {
            fs.mkdirSync(distDir);
        }
        const outputZip = path.join(distDir, `${addonFolder}-${version}.zip`);
        const output = fs.createWriteStream(outputZip);
        const archive = archiver("zip", { zlib: { level: 9 } });

        output.on("close", () => {
            console.log(`➤ Packaged addon: ${outputZip} (${archive.pointer()} total bytes)`);
            resolve(outputZip);
        });

        archive.on("error", (err) => {
            reject(err);
        });

        archive.pipe(output);
        // Include the addon folder
        // Exclude unwanted subdirectories
        archive.directory(addonFolder, addonFolder, (entry) => {
            const skipDirs = [".git", ".github", "tests", "scripts", "dist"];
            for (const skip of skipDirs) {
                if (entry.name.startsWith(skip)) {
                    return false;
                }
            }
            return entry;
        });
        archive.finalize();
    });
}

/**
 * Build the metadata JSON required by CurseForge.
 */
function buildMetadata(version, changelog) {
    return {
        releaseType,
        changelog,
        changelogType: "markdown",
        displayName: `${addonFolder}-${version}`,
        gameVersions,
    };
}

/**
 * Upload the zip file to CurseForge.
 */
async function uploadToCurseForge(zipPath, metadata) {
    const url = `https://api.curseforge.com/v1/projects/${curseforgeProjectId}/upload-file`;
    const fileStream = fs.createReadStream(zipPath);

    const formData = new (require("form-data"))();
    formData.append("metadata", JSON.stringify(metadata));
    formData.append("file", fileStream);

    console.log("➤ Uploading to CurseForge...");
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
    console.log("➤ Upload successful. Response:");
    console.log(JSON.stringify(data, null, 2));
}

//–– Main Execution ––
async function main() {
    try {
        // Expect version and changelog to be passed as arguments or environment variables.
        const version = process.env.ADDON_VERSION || process.argv[2];
        const changelog = process.env.CHANGELOG || fs.existsSync("CHANGELOG.md") ? fs.readFileSync("CHANGELOG.md", "utf8") : "";
        if (!version) {
            console.error("ERROR: No version specified. Set ADDON_VERSION env var or pass as first argument.");
            process.exit(1);
        }
        console.log(`➤ Starting upload for version ${version}`);
        const zipPath = await packageAddon(version);
        const metadata = buildMetadata(version, changelog);
        console.log("➤ Metadata prepared:");
        console.log(JSON.stringify(metadata, null, 2));
        await uploadToCurseForge(zipPath, metadata);
    } catch (err) {
        console.error("Upload error:", err);
        process.exit(1);
    }
}

main();
