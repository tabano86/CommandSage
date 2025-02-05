#!/usr/bin/env node
"use strict";

const { spawn } = require("child_process");
const { exec } = require("child_process");
const path = require("path");
const os = require("os");
const fs = require("fs");
const clipboardy = require("clipboardy");
const archiver = require("archiver");

function usage() {
    console.log(`Usage: cmdsage <command> [options]

Commands:
  test         Run tests (calls "busted" with a custom pattern)
  build        Build the addon into dist/CommandSage.zip
  copy         Copy file contents (from .toc, .yml, .md, .lua, .bat files excluding Libs) to the clipboard
  help         Display this help message

Examples:
  cmdsage test
  cmdsage build
  cmdsage copy`);
    process.exit(1);
}

if (process.argv.length < 3) {
    usage();
}

const command = process.argv[2].toLowerCase();
const args = process.argv.slice(3);
const isWindows = os.platform() === "win32";

switch (command) {
    case "test":
        runTests(args);
        break;
    case "build":
        buildAddon(args);
        break;
    case "copy":
        copyFiles(args);
        break;
    case "help":
        usage();
        break;
    default:
        console.error("Unknown command:", command);
        usage();
        break;
}

function runTests(args) {
    const proc = spawn("busted", [`--pattern=test_.*\\.lua`, "tests", ...args], { stdio: "inherit", shell: true });
    proc.on("exit", (code) => process.exit(code));
}

function buildAddon(args) {
    const distDir = path.join(process.cwd(), "dist");
    if (!fs.existsSync(distDir)) {
        fs.mkdirSync(distDir, { recursive: true });
    }
    const zipPath = path.join(distDir, "CommandSage.zip");
    if (fs.existsSync(zipPath)) {
        fs.unlinkSync(zipPath);
    }
    const output = fs.createWriteStream(zipPath);
    const archive = archiver("zip", { zlib: { level: 9 } });
    output.on("close", () => {
        console.log(`Build complete. ${archive.pointer()} total bytes written.`);
    });
    archive.on("error", (err) => {
        console.error("Build failed:", err);
        process.exit(1);
    });
    archive.pipe(output);
    // Include all files, excluding .git, dist, tests, scripts, and hidden files.
    archive.glob("**/*", {
        cwd: process.cwd(),
        ignore: ["**/.git/**", "dist/**", "tests/**", "scripts/**", "**/.*"]
    });
    archive.finalize();
}

function copyFiles(args) {
    const sourceDir = process.cwd();
    const excludePatterns = args;
    const extensions = [".toc", ".yml", ".md", ".lua", ".bat"];
    let clipboardContent = "";
    function walk(dir) {
        const files = fs.readdirSync(dir);
        for (const file of files) {
            const fullPath = path.join(dir, file);
            const stat = fs.statSync(fullPath);
            if (stat.isDirectory()) {
                if (fullPath.includes("Libs")) continue;
                walk(fullPath);
            } else {
                const ext = path.extname(file).toLowerCase();
                if (extensions.includes(ext)) {
                    let skip = false;
                    for (const pat of excludePatterns) {
                        if (file.includes(pat)) {
                            skip = true;
                            break;
                        }
                    }
                    if (skip) continue;
                    const relPath = path.relative(sourceDir, fullPath);
                    clipboardContent += `File: ${relPath}\n`;
                    try {
                        const content = fs.readFileSync(fullPath, "utf8");
                        clipboardContent += "```powershell\n" + content + "\n```\n";
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
            clipboardy.writeSync(clipboardContent);
            console.log("Content copied to clipboard.");
        } catch (e) {
            console.error("Clipboard error:", e);
            console.log("Outputting content:\n", clipboardContent);
        }
    } else {
        console.log("No content found to copy.");
    }
}
