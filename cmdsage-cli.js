#!/usr/bin/env node
"use strict";

const { Command } = require("commander");
const fs = require("fs");
const path = require("path");
const os = require("os");
const { spawnSync, spawn } = require("child_process");
const archiver = require("archiver");
const fetch = require("node-fetch");
const FormData = require("form-data");

// ---------- Helper Functions ----------

function isWindows() {
    return os.platform() === "win32";
}

function isWSL() {
    return process.platform === "linux" && os.release().toLowerCase().includes("microsoft");
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

// ---------- Test & Lint ----------

async function runTests(options) {
    console.log("➤ [Test] Running Lua tests using busted...");
    if (!toolExists("busted")) {
        console.error("Error: 'busted' is not installed or not in PATH.");
        process.exit(1);
    }
    const args = ["--pattern=test_.*\\.lua", "tests"];
    if (options.grep) args.push("--filter=" + options.grep);
    await runCommand("busted", args);
    console.log("➤ [Test] All tests passed.");
}

async function lintLua() {
    console.log("➤ [Lint] Running luacheck on Lua files...");
    if (!toolExists("luacheck")) {
        console.error("Error: 'luacheck' is not installed or not in PATH.");
        process.exit(1);
    }
    await runCommand("luacheck", ["."]);
    console.log("➤ [Lint] Linting complete.");
}

// ---------- Packaging ----------

function listPackageFiles() {
    const addonFolder = "CommandSage";
    const skipDirs = [".git", ".github", "tests", "scripts", "dist"];
    let filesList = [];

    function walk(dir) {
        const files = fs.readdirSync(dir);
        for (const file of files) {
            const fullPath = path.join(dir, file);
            const stat = fs.statSync(fullPath);
            if (stat.isDirectory()) {
                if (skipDirs.some(skip => fullPath.includes(skip))) continue;
                walk(fullPath);
            } else {
                filesList.push(path.relative(process.cwd(), fullPath));
            }
        }
    }
    walk(addonFolder);
    return filesList;
}

function buildMetadata(version, changelog) {
    const addonFolder = "CommandSage";
    const gameVersions = ["1.13.2"];
    const releaseType = "release";
    return {
        releaseType,
        changelog,
        changelogType: "markdown",
        displayName: `${addonFolder}-${version}`,
        gameVersions,
    };
}

async function packageAddon(version) {
    console.log(`➤ [Package] Packaging addon version ${version}...`);
    const addonFolder = "CommandSage";
    const distDir = path.join(process.cwd(), "dist");
    if (!fs.existsSync(distDir)) {
        fs.mkdirSync(distDir);
    }
    const zipPath = path.join(distDir, `${addonFolder}-${version}.zip`);
    const output = fs.createWriteStream(zipPath);
    const archive = archiver("zip", { zlib: { level: 9 } });

    output.on("close", () => {
        console.log(`➤ [Package] Created ${zipPath} (${archive.pointer()} bytes).`);
    });

    archive.on("error", (err) => { throw err; });
    archive.pipe(output);
    archive.directory(addonFolder, addonFolder, (entry) => {
        const skipDirs = [".git", ".github", "tests", "scripts", "dist"];
        for (const skip of skipDirs) {
            if (entry.name.startsWith(skip)) return false;
        }
        return entry;
    });
    await archive.finalize();
    return zipPath;
}

// ---------- CurseForge Upload ----------

async function uploadToCurseForge(zipPath, metadata) {
    console.log("➤ [Upload] Uploading addon to CurseForge...");
    const curseforgeProjectId = process.env.CURSEFORGE_PROJECT_ID;
    const curseforgeToken = process.env.CURSEFORGE_TOKEN;
    const url = `https://api.curseforge.com/v1/projects/${curseforgeProjectId}/upload-file`;
    const fileStream = fs.createReadStream(zipPath);
    const formData = new FormData();
    formData.append("metadata", JSON.stringify(metadata));
    formData.append("file", fileStream);

    const response = await fetch(url, {
        method: "POST",
        headers: { "x-api-token": curseforgeToken },
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

// ---------- Clean ----------

async function clean() {
    const distDir = path.join(process.cwd(), "dist");
    if (fs.existsSync(distDir)) {
        fs.rmSync(distDir, { recursive: true, force: true });
        console.log("➤ [Clean] Removed dist/ directory.");
    } else {
        console.log("➤ [Clean] No dist/ directory found.");
    }
}

// ---------- CI Pipeline (Dry Run) ----------

async function ci() {
    try {
        console.log("➤ [CI] Running lint...");
        await lintLua();
        console.log("➤ [CI] Running tests...");
        await runTests({});
        console.log("➤ [CI] Listing package files (dry run)...");
        const version = process.env.ADDON_VERSION || "0.0.0";
        const files = listPackageFiles();
        console.log("➤ [CI] Files to be packaged:");
        files.forEach(f => console.log("  • " + f));
        const changelog = fs.existsSync("CHANGELOG.md") ? fs.readFileSync("CHANGELOG.md", "utf8") : "";
        const metadata = buildMetadata(version, changelog);
        console.log("➤ [CI] Metadata prepared:");
        console.log(JSON.stringify(metadata, null, 2));
        console.log("➤ [CI] Dry-run complete.");
    } catch (err) {
        console.error("➤ [CI] Pipeline failed:", err);
        process.exit(1);
    }
}

// ---------- Full Release Pipeline ----------

async function release(options) {
    try {
        await ci();
        const version = process.env.ADDON_VERSION || process.argv[2];
        if (!version) {
            console.error("ERROR: No version specified. Set ADDON_VERSION or pass as an argument.");
            process.exit(1);
        }
        console.log(`➤ [Release] Building addon version ${version}...`);
        const changelog = fs.existsSync("CHANGELOG.md") ? fs.readFileSync("CHANGELOG.md", "utf8") : "";
        const zipPath = await packageAddon(version);
        const metadata = buildMetadata(version, changelog);
        console.log("➤ [Release] Metadata prepared:");
        console.log(JSON.stringify(metadata, null, 2));
        await uploadToCurseForge(zipPath, metadata);
        console.log("➤ [Release] Release complete.");
    } catch (err) {
        console.error("➤ [Release] Release failed:", err);
        process.exit(1);
    }
}

// ---------- File Copy to Clipboard ----------

async function copyFiles(excludePatterns, exts) {
    const sourceDir = process.cwd();
    const extensions = (exts && exts.length)
        ? exts.map(ext => (ext.startsWith(".") ? ext.toLowerCase() : "." + ext.toLowerCase()))
        : [".lua", ".toc"];
    let clipboardContent = "";

    function walk(dir) {
        const files = fs.readdirSync(dir);
        for (const file of files) {
            const fullPath = path.join(dir, file);
            const stat = fs.statSync(fullPath);
            if (stat.isDirectory()) {
                if (fullPath.toLowerCase().includes("libs")) continue;
                walk(fullPath);
            } else {
                const ext = path.extname(file).toLowerCase();
                if (extensions.includes(ext)) {
                    if (excludePatterns && excludePatterns.some(pat => file.includes(pat))) continue;
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
            if (isWSL()) {
                const proc = spawnSync("clip.exe", { input: clipboardContent });
                if (proc.status !== 0) throw new Error("clip.exe failed");
                console.log("➤ [Copy] Content copied to clipboard via clip.exe.");
            } else {
                const clipboardy = require("clipboardy");
                clipboardy.writeSync(clipboardContent);
                console.log("➤ [Copy] Content copied to clipboard.");
            }
        } catch (e) {
            console.error("➤ [Copy] Clipboard error:", e);
            console.log(clipboardContent);
        }
    } else {
        console.log("➤ [Copy] No content found to copy.");
    }
}

// ---------- Main CLI ----------

const program = new Command();
program
    .name("cmdsage")
    .description("CommandSage CLI – run tests, lint, build, package, and release your WoW addon.")
    .version("2.0.0");

program
    .command("test")
    .description("Run Lua tests using busted")
    .option("-g, --grep <pattern>", "Filter tests by pattern")
    .action(options => {
        runTests(options).catch(err => {
            console.error(err);
            process.exit(1);
        });
    });

program
    .command("lint")
    .description("Lint Lua files using luacheck")
    .action(() => {
        lintLua().catch(err => {
            console.error(err);
            process.exit(1);
        });
    });

program
    .command("build")
    .description("Build and package the addon. Use --dry-run to list files and metadata without packaging.")
    .option("--dry-run", "Dry run: show file list and metadata without creating zip")
    .action(async (options) => {
        const version = process.env.ADDON_VERSION || "0.0.0";
        if (options.dryRun) {
            console.log("➤ [Dry Run] Listing package files:");
            const files = listPackageFiles();
            files.forEach(file => console.log("  • " + file));
            const changelog = fs.existsSync("CHANGELOG.md") ? fs.readFileSync("CHANGELOG.md", "utf8") : "";
            const metadata = buildMetadata(version, changelog);
            console.log("➤ [Dry Run] Metadata:");
            console.log(JSON.stringify(metadata, null, 2));
        } else {
            try {
                await packageAddon(version);
            } catch (err) {
                console.error(err);
                process.exit(1);
            }
        }
    });

program
    .command("upload")
    .description("Build the addon and upload it to CurseForge")
    .action(async () => {
        const version = process.env.ADDON_VERSION || "0.0.0";
        const changelog = fs.existsSync("CHANGELOG.md") ? fs.readFileSync("CHANGELOG.md", "utf8") : "";
        const zipPath = await packageAddon(version);
        const metadata = buildMetadata(version, changelog);
        await uploadToCurseForge(zipPath, metadata);
    });

program
    .command("release")
    .description("Run full release: lint, test, build, and upload to CurseForge")
    .option("-o, --output <file>", "Optional output zip filename")
    .action((options) => {
        release(options);
    });

program
    .command("clean")
    .description("Clean the dist/ directory")
    .action(() => {
        clean().catch(err => {
            console.error(err);
            process.exit(1);
        });
    });

program
    .command("ci")
    .description("Run CI pipeline dry run: lint, test, and list package files")
    .action(() => {
        ci();
    });

program
    .command("files")
    .description("List all files that will be packaged")
    .action(() => {
        const files = listPackageFiles();
        console.log("➤ [Files] Package file list:");
        files.forEach(file => console.log("  • " + file));
    });

program
    .command("copy")
    .description("Copy .lua and .toc file contents to clipboard")
    .option("-e, --exclude <patterns...>", "Exclude files matching these patterns")
    .option("-x, --extensions <extensions...>", "File extensions to include (default: .lua, .toc)")
    .action(options => {
        copyFiles(options.exclude, options.extensions).catch(err => {
            console.error(err);
            process.exit(1);
        });
    });

program.parseAsync(process.argv).catch(err => {
    console.error(err);
    process.exit(1);
});
