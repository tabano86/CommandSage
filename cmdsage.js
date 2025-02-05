#!/usr/bin/env node
"use strict";

const { Command } = require("commander");
const path = require("path");
const os = require("os");
const fs = require("fs");
const { spawnSync, spawn } = require("child_process");
const clipboardy = require("clipboardy");
const archiver = require("archiver");

function toolExists(toolName) {
    const check = spawnSync(isWindows() ? "where" : "which", [toolName], { encoding: "utf-8" });
    return check.status === 0;
}

function isWindows() {
    return os.platform() === "win32";
}

// Detect if running in WSL by checking os.release()
function isWSL() {
    return process.platform === "linux" && os.release().toLowerCase().includes("microsoft");
}

function runTests(options) {
    if (!toolExists("busted")) {
        console.error("Error: 'busted' is not installed or not in PATH.");
        process.exit(1);
    }
    const args = ["--pattern=test_.*\\.lua", "tests"];
    if (options.grep) args.push("--filter=" + options.grep);
    const proc = spawn("busted", args, { stdio: "inherit", shell: true });
    proc.on("exit", code => process.exit(code));
}

function buildAddon(outputPath) {
    const distDir = path.join(process.cwd(), "dist");
    if (!fs.existsSync(distDir)) fs.mkdirSync(distDir, { recursive: true });
    const zipName = outputPath || "CommandSage.zip";
    const zipPath = path.join(distDir, zipName);
    if (fs.existsSync(zipPath)) fs.unlinkSync(zipPath);
    const output = fs.createWriteStream(zipPath);
    const archive = archiver("zip", { zlib: { level: 9 } });
    output.on("close", () => {
        console.log(`Build complete. ${archive.pointer()} total bytes written.`);
    });
    archive.on("error", err => {
        console.error("Build failed:", err);
        process.exit(1);
    });
    archive.pipe(output);
    archive.glob("**/*", {
        cwd: process.cwd(),
        ignore: ["**/.git/**", "dist/**", "tests/**", "scripts/**", "**/.*"]
    });
    archive.finalize();
}

function copyFiles(excludePatterns, exts) {
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
            // On WSL, use clip.exe from Windows; otherwise, use clipboardy.
            if (isWSL()) {
                const proc = spawnSync("clip.exe", { input: clipboardContent });
                if (proc.status !== 0) {
                    throw new Error("clip.exe failed");
                }
                console.log("Content copied to clipboard (via clip.exe).");
            } else {
                clipboardy.writeSync(clipboardContent);
                console.log("Content copied to clipboard.");
            }
        } catch (e) {
            console.error("Clipboard error:", e);
            console.log(clipboardContent);
        }
    } else {
        console.log("No content found to copy.");
    }
}

function lintLua() {
    if (!toolExists("luacheck")) {
        console.error("Error: 'luacheck' is not installed or not in PATH.");
        process.exit(1);
    }
    const proc = spawn("luacheck", [".", "--exclude-files", "**/Libs/**"], { stdio: "inherit", shell: true });
    proc.on("exit", code => process.exit(code));
}

function clean() {
    const distDir = path.join(process.cwd(), "dist");
    if (fs.existsSync(distDir)) {
        fs.rmSync(distDir, { recursive: true, force: true });
        console.log("dist/ directory removed.");
    } else {
        console.log("No dist/ directory found.");
    }
}

const program = new Command();

program
    .name("cmdsage")
    .description("Enhanced WoW plugin CLI for testing, building, linting, copying, and more.")
    .version("1.0.0");

program
    .command("test")
    .description("Run Lua tests with busted")
    .option("-g, --grep <pattern>", "Run tests matching pattern")
    .action(options => runTests(options));

program
    .command("build")
    .description("Build the addon into dist/CommandSage.zip (or specified filename)")
    .option("-o, --output <file>", "Name of the output zip file")
    .action(options => buildAddon(options.output));

program
    .command("copy")
    .description("Copy file contents to clipboard with specified extensions")
    .option("-e, --exclude <patterns...>", "Exclude files with matching patterns")
    .option("-x, --extensions <extensions...>", "File extensions to include (default: .lua, .toc)")
    .action(options => copyFiles(options.exclude, options.extensions));

program
    .command("lint")
    .description("Lint Lua files using luacheck")
    .action(() => lintLua());

program
    .command("clean")
    .description("Remove dist/ directory")
    .action(() => clean());

program.parse(process.argv);

if (!process.argv.slice(2).length) {
    program.outputHelp();
}
