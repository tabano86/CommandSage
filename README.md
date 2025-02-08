# CommandSage 🚀✨

![CommandSage Logo](Assets/Logo_1024_1024.png)

**CommandSage** is a next-generation WoW Classic addon that revolutionizes your slash-command experience with
intelligent autocompletion, fuzzy matching, and context-aware suggestions—plus a host of fun visual enhancements.

![Version](https://img.shields.io/badge/Version-4.3-blue)  
![Game Version](https://img.shields.io/badge/WoW-Classic%2011.4.0-yellow)

---

## Table of Contents

1. [Key Features](#key-features)
2. [Quick Start](#quick-start)
3. [Configuration](#configuration)
4. [Advanced Commands](#advanced-commands)
5. [Performance](#performance)
6. [Automated Releases & CurseForge Packaging](#automated-releases--curseforge-packaging)
7. [CI/CD & Release Pipeline](#cicd--release-pipeline)
8. [Support & Licensing](#support--licensing)

---

## 🌟 Key Features

- **Smart Autocomplete**  
  Enjoy fuzzy, context-aware suggestions for your slash commands.

- **Command History & Analytics**  
  Track, analyze, and learn from your command usage.

- **Shell Context**  
  Change contexts easily using commands like `/cd <command>`.

- **Parameter Hints & Snippets**  
  Receive inline hints and auto-complete common command formats.

- **Performance Dashboard**  
  Monitor memory usage, trie node counts, and other vital stats.

- **Accessibility Options**  
  Toggle high contrast and large text modes for a better experience.

- **Visual Enhancements**  
  Add flair with rainbow borders, spinning icons, and more fun visuals.

---

## 🚀 Quick Start

1. **Install Addon:**  
   Copy the entire `CommandSage` folder into your `Interface/AddOns/` directory in your WoW Classic installation.

2. **Get Started In-Game:**  
   Type `/cmdsage tutorial` for an interactive guide.

3. **Configure:**
    - Use `/cmdsage gui` to change settings via the graphical interface.
    - Alternatively, use CLI commands such as:  
      `/cmdsage config uiTheme dark`

---

## 🔧 Configuration

You can adjust various settings via in-game commands or the GUI panel (`/cmdsage gui`). Some of the configurable options
include:

- **uiTheme:** Choose from `dark`, `light`, or `classic`.
- **uiScale:** Set a numeric value between `0.8` and `2.0` for UI scaling.
- **fuzzyMatchTolerance:** An integer from `0` (strict) to `5` (lenient) for typo tolerance.
- **animateAutoType:** Toggle animated auto-typing with `true` or `false`.

Below is an overview of available settings:

| Setting               | Values             | Description                         |
|-----------------------|--------------------|-------------------------------------|
| `uiTheme`             | dark/light/classic | Interface theme selection           |
| `uiScale`             | 0.8–2.0            | UI scaling factor                   |
| `fuzzyMatchTolerance` | 0–5                | Fuzzy matching sensitivity          |
| `animateAutoType`     | true/false         | Enable/disable animated auto-typing |
| ...                   | ...                | More settings available             |

---

## 🔮 Advanced Commands

CommandSage offers a wide range of slash/terminal commands:

- `/cls` – Clears your chat.
- `/pwd` – Displays your current zone and subzone.
- `/uptime` – Shows the session uptime.
- `/donate` or `/coffee` – Provides donation information.
- `/3dspin` – Activates a 3D environment spin.
- `/color 1 0 0` – Changes in-game chat color.
- `/cmdsage perf` – Displays performance statistics.

For a complete list, run `/cmdsage` or refer to the in-game documentation.

---

## 🏆 Performance

Run the command:
`/cmdsage perf`

This displays key statistics such as:

- Memory usage
- Total discovered commands
- Trie node counts

---

## 📦 Automated Releases & CurseForge Packaging

Our CI/CD pipeline is fully automated. Here’s how it works:

### How It Works

1. **Commit & Merge:**  
   Use Conventional Commit messages when pushing changes to `main`.

2. **Automated Versioning:**  
   Semantic-release analyzes your git history, bumps the version, and pushes a new tag (e.g., `v4.3.0`).

3. **CI/CD Workflow:**
    - **Testing & Linting:** The workflow runs Lua tests and lint checks.
    - **Building & Packaging:** The addon is built and packaged into a zip file.
    - **Uploading:** A Node.js script automatically uploads the packaged addon to CurseForge.

4. **Required Secrets:**  
   Ensure that your repository’s secrets include:
    - `GITHUB_TOKEN`
    - `NPM_TOKEN`
    - `CURSEFORGE_PROJECT_ID`
    - `CURSEFORGE_TOKEN`

No manual tagging is required—simply merge your changes and push!

---

## 📦 CI/CD & Release Pipeline

A comprehensive GitHub Actions workflow (see `.github/workflows/release.yml`) handles:

- Checkout of the full codebase.
- Installation of Node.js and dependencies.
- Running tests (e.g., `node cmdsage.js test`).
- Executing semantic-release on new tags.
- Updating the version in your TOC file.
- Building and packaging the addon as a zip file.
- Uploading the zip to CurseForge via a Node.js upload script.

Make sure your repository settings include the required secrets listed above.

---

## 🙏 Support & Licensing

For support, type `/cmdsage help` in-game or refer to our [documentation](#).

CommandSage is released under the MIT License.  
*World of Warcraft® is a trademark of Blizzard Entertainment, Inc.*
