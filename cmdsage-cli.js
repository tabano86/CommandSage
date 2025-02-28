#!/usr/bin/env node
"use strict";

// ----------------------
// Dependencies
// ----------------------
const { Command } = require("commander");
const fs = require("fs");
const path = require("path");
const os = require("os");
const { spawnSync, spawn } = require("child_process");
const archiver = require("archiver");
const FormData = require("form-data");

// Dynamic import for node‑fetch (ESM module)
const fetch = (...args) =>
    import("node-fetch").then(({ default: fetch }) => fetch(...args));

// ----------------------
// Utility Functions
// ----------------------
function isWindows() {
    return os.platform() === "win32";
}

function toolExists(toolName) {
    const cmd = isWindows() ? "where" : "which";
    const check = spawnSync(cmd, [toolName], { encoding: "utf-8" });
    return check.status === 0;
}

function runCommand(command, args, options = {}) {
    return new Promise((resolve, reject) => {
        const proc = spawn(command, args, { stdio: "inherit", shell: true, ...options });
        proc.on("error", reject);
        proc.on("exit", code => {
            if (code !== 0) {
                reject(new Error(`${command} exited with code ${code}`));
            } else {
                resolve();
            }
        });
    });
}

// ----------------------
// Determine Project Folder
// ----------------------
const DEFAULT_FOLDER = "CommandSage";
let projectFolder = fs.existsSync(path.join(process.cwd(), DEFAULT_FOLDER))
    ? DEFAULT_FOLDER
    : ".";
if (projectFolder === ".") {
    console.log(`Folder '${DEFAULT_FOLDER}' not found – using current directory as project folder.`);
}

// ----------------------
// Allowed File Extensions
// ----------------------
const ALLOWED_EXTENSIONS = [
    "toc", "lua", "xml", "blp", "tga", "png", "jpg", "jpeg", "gif", "jar", "zip"
];

// ----------------------
// Load Manifest Template
// ----------------------
function loadManifestTemplate(version) {
    const templatePath = path.join(projectFolder, "manifest.template.json");
    if (!fs.existsSync(templatePath)) {
        return null;
    }
    try {
        const raw = fs.readFileSync(templatePath, "utf8");
        let manifest = JSON.parse(raw);
        // Update the version to match the build version.
        manifest.version = version;
        const manifestContent = JSON.stringify(manifest, null, 2);
        // Use excludeFiles from the manifest template if provided.
        const excludes = Array.isArray(manifest.excludeFiles) ? manifest.excludeFiles : [];
        return { manifestContent, excludes };
    } catch (e) {
        console.error("Error reading manifest.template.json:", e);
        return null;
    }
}

// ----------------------
// List Package Files (Dry Run)
// ----------------------
function listPackageFiles(folder) {
    function walk(dir) {
        const entries = fs.readdirSync(dir);
        for (const entry of entries) {
            const fullPath = path.join(dir, entry);
            const stat = fs.statSync(fullPath);
            if (stat.isDirectory()) {
                walk(fullPath);
            } else {
                const ext = path.extname(entry).slice(1).toLowerCase();
                if (ALLOWED_EXTENSIONS.includes(ext)) {
                    console.log(path.relative(process.cwd(), fullPath));
                }
            }
        }
    }
    walk(folder);
}

// ----------------------
// Add Files to Archive with Version & Manifest Sync
// ----------------------
function addFilesToArchive(archive, folder, version, extraExcludes = []) {
    // Build the exclusion list.
    // First, always exclude the manifest template itself.
    let excludes = ["manifest.template.json", ...extraExcludes];
    // Also allow overrides via env var if needed.
    if (process.env.CURSEFORGE_EXCLUDES) {
        excludes = excludes.concat(
            process.env.CURSEFORGE_EXCLUDES.split(",").map(s => s.trim())
        );
    }

    function walk(dir) {
        const entries = fs.readdirSync(dir);
        for (const entry of entries) {
            const fullPath = path.join(dir, entry);
            const stat = fs.statSync(fullPath);
            if (stat.isDirectory()) {
                walk(fullPath);
            } else {
                const relPath = path.relative(folder, fullPath).replace(/\\/g, "/");
                // Skip excluded files.
                if (excludes.includes(relPath)) {
                    console.log(`➤ Skipping excluded file: ${relPath}`);
                    continue;
                }
                const ext = path.extname(entry).slice(1).toLowerCase();
                // For .toc files, update version (if applicable)
                if (ext === "toc") {
                    let content = fs.readFileSync(fullPath, "utf8");
                    const versionRegex = /^(##\s*Version:\s*).*/mi;
                    if (versionRegex.test(content)) {
                        content = content.replace(versionRegex, `$1${version}`);
                    } else {
                        console.warn(`Warning: No version line found in ${relPath}. Appending version info.`);
                        content += `\n## Version: ${version}\n`;
                    }
                    if (process.env.INTERFACE_VERSION) {
                        const interfaceRegex = /^(##\s*Interface:\s*).*/mi;
                        if (interfaceRegex.test(content)) {
                            content = content.replace(interfaceRegex, `$1${process.env.INTERFACE_VERSION}`);
                        } else {
                            console.warn(`Warning: No interface line found in ${relPath}. Appending interface info.`);
                            content += `\n## Interface: ${process.env.INTERFACE_VERSION}\n`;
                        }
                    }
                    archive.append(content, { name: relPath });
                } else {
                    archive.file(fullPath, { name: relPath });
                }
            }
        }
    }
    walk(folder);
}

// ----------------------
// Package Project Function (Addon/Modpack)
// ----------------------
function packageProject(version, dryRun = false) {
    return new Promise((resolve, reject) => {
        const distDir = path.join(process.cwd(), "dist");
        if (!fs.existsSync(distDir)) {
            fs.mkdirSync(distDir);
        }
        const outputZip = path.join(distDir, `CommandSage-${version}.zip`);
        if (dryRun) {
            console.log("➤ [Dry Run] Listing package files:");
            listPackageFiles(projectFolder);
            resolve(null);
            return;
        }
        const output = fs.createWriteStream(outputZip);
        const archive = archiver("zip", { zlib: { level: 9 } });
        output.on("close", () => {
            console.log(`➤ Packaged project: ${outputZip} (${archive.pointer()} total bytes)`);
            resolve(outputZip);
        });
        archive.on("error", err => reject(err));
        archive.pipe(output);

        // Load manifest template (if present) to update version and get list of files to exclude.
        const manifestData = loadManifestTemplate(version);
        let manifestExcludes = [];
        if (manifestData) {
            manifestExcludes = manifestData.excludes;
            // Add the generated manifest.json file to the archive.
            archive.append(manifestData.manifestContent, { name: "manifest.json" });
            console.log("➤ Included generated manifest.json in the package.");
        }

        // Add remaining files, excluding files per manifest and any other excludes.
        addFilesToArchive(archive, projectFolder, version, manifestExcludes);

        archive.finalize();
    });
}

// ----------------------
// CurseForge Upload Functions
// ----------------------
function buildMetadata(version, changelog) {
    const gameVersions = process.env.GAME_VERSIONS
        ? process.env.GAME_VERSIONS.split(",").map(s => s.trim())
        : ["1.19.2"];
    return {
        releaseType: "release",
        changelog: changelog,
        changelogType: "markdown",
        displayName: `CommandSage-${version}`,
        gameVersions: gameVersions
    };
}

async function uploadToCurseForge(zipPath, metadata) {
    if (!zipPath) {
        console.log("Dry run mode – skipping upload.");
        return;
    }
    const curseforgeProjectId = process.env.CURSEFORGE_PROJECT_ID;
    const curseforgeToken = process.env.CURSEFORGE_TOKEN;
    if (!curseforgeProjectId || !curseforgeToken) {
        throw new Error("CURSEFORGE_PROJECT_ID or CURSEFORGE_TOKEN environment variable not set.");
    }
    const url = `https://api.curseforge.com/v1/projects/${curseforgeProjectId}/upload-file`;
    const fileStream = fs.createReadStream(zipPath);
    const formData = new FormData();
    formData.append("metadata", JSON.stringify(metadata));
    formData.append("file", fileStream);

    console.log("➤ Uploading to CurseForge...");
    const response = await fetch(url, {
        method: "POST",
        headers: { "x-api-token": curseforgeToken },
        body: formData
    });
    if (!response.ok) {
        const errText = await response.text();
        throw new Error(`Upload failed: ${response.status} ${response.statusText}\n${errText}`);
    }
    const data = await response.json();
    console.log("➤ Upload successful. Response:");
    console.log(JSON.stringify(data, null, 2));
}

// ----------------------
// Build Command Wrapper
// ----------------------
async function buildProject(versionOverride, dryRun) {
    const version = process.env.ADDON_VERSION || versionOverride || "0.0.0";
    console.log(`➤ Building project version ${version}`);
    const zipPath = await packageProject(version, dryRun);
    return { zipPath, version };
}

// ----------------------
// CLI Definition using Commander
// ----------------------
const program = new Command();

program
    .name("cmdsage-cli")
    .description("CLI for CommandSage: test, lint, build, copy, clean, ci, release, and upload to CurseForge.")
    .version("2.0.0");

program
    .command("test")
    .description("Run Lua tests using busted")
    .option("-g, --grep <pattern>", "Filter tests by pattern")
    .action(async options => {
        if (!toolExists("busted")) {
            console.error("Error: 'busted' is not installed or not in PATH.");
            process.exit(1);
        }
        const args = ["--pattern=test_.*\\.lua", "tests"];
        if (options.grep) args.push("--filter=" + options.grep);
        try {
            await runCommand("busted", args);
        } catch (err) {
            console.error(err);
            process.exit(1);
        }
    });

program
    .command("lint")
    .description("Lint Lua files using luacheck")
    .action(async () => {
        if (!toolExists("luacheck")) {
            console.error("Error: 'luacheck' is not installed or not in PATH.");
            process.exit(1);
        }
        try {
            await runCommand("luacheck", ["."]);
        } catch (err) {
            console.error(err);
            process.exit(1);
        }
    });

program
    .command("build")
    .description("Build the project into a zip file in the dist/ directory (syncs manifest and version)")
    .option("--dry-run", "List files that would be packaged, without creating a zip")
    .option("-o, --output <version>", "Override version (or use as version)")
    .action(async options => {
        try {
            const { zipPath } = await buildProject(options.output, options.dryRun);
            if (!options.dryRun && zipPath) {
                console.log(`➤ Build complete: ${zipPath}`);
            }
        } catch (err) {
            console.error("Build failed:", err);
            process.exit(1);
        }
    });

program
    .command("copy")
    .description("Copy contents of .lua and .toc files to the clipboard")
    .option("-e, --exclude <patterns...>", "Exclude files matching these patterns")
    .option("-x, --extensions <extensions...>", "File extensions to include (default: lua, toc)")
    .action(async options => {
        const sourceDir = process.cwd();
        const exts = (options.extensions && options.extensions.length)
            ? options.extensions.map(ext => (ext.startsWith(".") ? ext.toLowerCase().slice(1) : ext.toLowerCase()))
            : ["lua", "toc"];
        let clipboardContent = "";
        function walk(dir) {
            const entries = fs.readdirSync(dir);
            for (const entry of entries) {
                const fullPath = path.join(dir, entry);
                const stat = fs.statSync(fullPath);
                if (stat.isDirectory()) {
                    if (["node_modules", "dist", ".git", ".github", ".idea", ".run", "tests"].includes(entry.toLowerCase()))
                        continue;
                    walk(fullPath);
                } else {
                    const ext = path.extname(entry).slice(1).toLowerCase();
                    if (exts.includes(ext)) {
                        if (options.exclude && options.exclude.some(pat => entry.includes(pat))) continue;
                        const relPath = path.relative(sourceDir, fullPath);
                        clipboardContent += `File: ${relPath}\n`;
                        try {
                            const content = fs.readFileSync(fullPath, "utf8");
                            clipboardContent += "```lua\n" + content + "\n```\n";
                        } catch (e) {
                            clipboardContent += `Error reading file: ${fullPath}\n`;
                        }
                    }
                }
            }
        }
        walk(sourceDir);
        if (clipboardContent) {
            try {
                const clipboardy = require("clipboardy");
                clipboardy.writeSync(clipboardContent);
                console.log("➤ Content copied to clipboard.");
            } catch (e) {
                console.error("Clipboard error:", e);
                console.log(clipboardContent);
            }
        } else {
            console.log("No content found to copy.");
        }
    });

program
    .command("clean")
    .description("Remove the dist/ directory")
    .action(async () => {
        const distDir = path.join(process.cwd(), "dist");
        if (fs.existsSync(distDir)) {
            fs.rmSync(distDir, { recursive: true, force: true });
            console.log("➤ dist/ directory removed.");
        } else {
            console.log("No dist/ directory found.");
        }
    });

program
    .command("ci")
    .description("Run lint, tests, and build (CI pipeline)")
    .action(async () => {
        try {
            console.log("➤ Running Lua lint...");
            await runCommand("luacheck", ["."]);
            console.log("➤ Running tests...");
            await runCommand("busted", ["--pattern=test_.*\\.lua", "tests"]);
            console.log("➤ Building project...");
            await buildProject();
            console.log("➤ CI pipeline complete.");
        } catch (err) {
            console.error("CI pipeline failed:", err);
            process.exit(1);
        }
    });

program
    .command("release")
    .description("Run CI pipeline, build the project, and upload to CurseForge")
    .option("-o, --output <version>", "Override version (or use as version)")
    .action(async options => {
        try {
            console.log("➤ Running CI pipeline for release...");
            await runCommand("luacheck", ["."]);
            await runCommand("busted", ["--pattern=test_.*\\.lua", "tests"]);
            const { zipPath, version } = await buildProject(options.output, false);
            const ver = process.env.ADDON_VERSION || options.output || version || "0.0.0";
            let changelog = "";
            if (fs.existsSync("CHANGELOG.md")) {
                changelog = fs.readFileSync("CHANGELOG.md", "utf8");
            }
            const metadata = buildMetadata(ver, changelog);
            console.log("➤ Metadata prepared:");
            console.log(JSON.stringify(metadata, null, 2));
            await uploadToCurseForge(zipPath, metadata);
            console.log("➤ Release complete.");
        } catch (err) {
            console.error("Release failed:", err);
            process.exit(1);
        }
    });

// ----------------------
// Parse Command Line
// ----------------------
program.parseAsync(process.argv).catch(err => {
    console.error(err);
    process.exit(1);
});
