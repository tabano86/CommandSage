#!/usr/bin/env node
"use strict";

const { Command } = require("commander");
const path = require("path");
const os = require("os");
const fs = require("fs");
const { spawnSync, spawn } = require("child_process");
const clipboardy = require("clipboardy");
const archiver = require("archiver");

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

async function runTests(options) {
    if (!toolExists("busted")) {
        console.error("Error: 'busted' is not installed or not in PATH.");
        process.exit(1);
    }
    const args = ["--pattern=test_.*\\.lua", "tests"];
    if (options.grep) args.push("--filter=" + options.grep);
    await runCommand("busted", args);
}

async function lintLua() {
    if (!toolExists("luacheck")) {
        console.error("Error: 'luacheck' is not installed or not in PATH.");
        process.exit(1);
    }
    await runCommand("luacheck", [".", "--exclude-files", "**/Libs/**"]);
}

async function buildAddon(outputName) {
    const distDir = path.join(process.cwd(), "dist");
    if (!fs.existsSync(distDir)) fs.mkdirSync(distDir, { recursive: true });
    const zipName = outputName || "CommandSage.zip";
    const zipPath = path.join(distDir, zipName);
    if (fs.existsSync(zipPath)) fs.unlinkSync(zipPath);
    await new Promise((resolve, reject) => {
        const output = fs.createWriteStream(zipPath);
        const archive = archiver("zip", { zlib: { level: 9 } });
        output.on("close", () => {
            console.log(`Build complete. ${archive.pointer()} total bytes written to ${zipPath}.`);
            resolve();
        });
        archive.on("error", err => reject(err));
        archive.pipe(output);
        archive.glob("**/*", {
            cwd: process.cwd(),
            ignore: ["**/.git/**", "dist/**", "tests/**", "scripts/**", "**/.*"]
        });
        archive.finalize();
    });
}

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

async function clean() {
    const distDir = path.join(process.cwd(), "dist");
    if (fs.existsSync(distDir)) {
        fs.rmSync(distDir, { recursive: true, force: true });
        console.log("dist/ directory removed.");
    } else {
        console.log("No dist/ directory found.");
    }
}

// Consolidated CI command: lint, test, then build.
async function ci() {
    try {
        console.log("Running Lua lint...");
        await lintLua();
        console.log("Running tests...");
        await runTests({});
        console.log("Building addon...");
        await buildAddon();
        console.log("CI pipeline complete.");
    } catch (err) {
        console.error("CI pipeline failed:", err);
        process.exit(1);
    }
}

// Release command: runs CI then builds final package.
async function release(options) {
    try {
        await ci();
        await buildAddon(options.output);
        console.log("Release complete.");
    } catch (err) {
        console.error("Release failed:", err);
        process.exit(1);
    }
}

const program = new Command();

program
    .name("cmdsage")
    .description("Enhanced WoW plugin CLI for testing, building, linting, copying, and more.")
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
    .description("Build the addon into a zip file in dist/")
    .option("-o, --output <file>", "Name of the output zip file")
    .action(options => {
        buildAddon(options.output).catch(err => {
            console.error(err);
            process.exit(1);
        });
    });

program
    .command("copy")
    .description("Copy contents of .lua and .toc files to clipboard")
    .option("-e, --exclude <patterns...>", "Exclude files matching these patterns")
    .option("-x, --extensions <extensions...>", "File extensions to include (default: .lua, .toc)")
    .action(options => {
        copyFiles(options.exclude, options.extensions).catch(err => {
            console.error(err);
            process.exit(1);
        });
    });

program
    .command("clean")
    .description("Remove the dist/ directory")
    .action(() => {
        clean().catch(err => {
            console.error(err);
            process.exit(1);
        });
    });

program
    .command("ci")
    .description("Run lint, tests, and build (CI pipeline)")
    .action(() => {
        ci();
    });

program
    .command("release")
    .description("Run CI pipeline and perform release packaging")
    .option("-o, --output <file>", "Name of the output zip file for release")
    .action(options => {
        release(options);
    });

program.parseAsync(process.argv).catch(err => {
    console.error(err);
    process.exit(1);
});
