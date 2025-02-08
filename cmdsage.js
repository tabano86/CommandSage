#!/usr/bin/env node
"use strict";

const { Command } = require("commander");
const { spawnSync, spawn } = require("child_process");
const os = require("os");
const fs = require("fs");
const path = require("path");

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
        proc.on("exit", (code) => {
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
    await runCommand("luacheck", ["."]);
}

async function buildAddon(outputFile) {
    // (Assume your build script simply packages your addon folder into a zip.)
    // Here you can call your packaging logic. For simplicity, we’ll call upload-to-curseforge.js later.
    console.log("➤ [Build] Building addon...");
    // (Your build process might include updating the .toc version; see next step in workflow.)
}

async function clean() {
    const distDir = path.join(process.cwd(), "dist");
    if (fs.existsSync(distDir)) {
        fs.rmSync(distDir, { recursive: true, force: true });
        console.log("➤ [Clean] Removed dist/ directory.");
    } else {
        console.log("➤ [Clean] No dist/ directory found.");
    }
}

async function ci() {
    try {
        console.log("➤ [CI] Running Lua lint...");
        await lintLua();
        console.log("➤ [CI] Running tests...");
        await runTests({});
        console.log("➤ [CI] Building addon...");
        await buildAddon();
        console.log("➤ [CI] Pipeline complete.");
    } catch (err) {
        console.error("➤ [CI] Pipeline failed:", err);
        process.exit(1);
    }
}

async function release(options) {
    try {
        await ci();
        await buildAddon(options.output);
        console.log("➤ [Release] Release complete.");
    } catch (err) {
        console.error("➤ [Release] Release failed:", err);
        process.exit(1);
    }
}

const program = new Command();
program
    .name("cmdsage")
    .description("CommandSage CLI – testing, building, linting, and packaging for CurseForge.")
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
    .description("Build the addon (packaging will be done by upload-to-curseforge.js)")
    .option("-o, --output <file>", "Name of the output zip file")
    .action(options => {
        buildAddon(options.output).catch(err => {
            console.error(err);
            process.exit(1);
        });
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
    .description("Run lint, tests, and build (CI pipeline)")
    .action(() => {
        ci();
    });

program
    .command("release")
    .description("Run CI pipeline and perform release packaging")
    .option("-o, --output <file>", "Output zip file name")
    .action(options => {
        release(options);
    });

program.parseAsync(process.argv).catch(err => {
    console.error(err);
    process.exit(1);
});
