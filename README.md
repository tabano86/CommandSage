# CommandSage

A **production-ready** WoW Classic addon offering advanced auto-completion for slash commands. Features:

- **Dynamic Command Discovery** (built-in, macros, forced fallback commands).
- **Trie + Fuzzy Matching** for partial/typo input.
- **Context & Adaptive Learning** (stubs for advanced usage).
- **“Next-decade” auto-complete UI** with highlight effects, clickable suggestions, animations.
- **Persistent Usage & History** across sessions—never retype frequent commands again.
- **Local Build & CI** with `scripts/build.sh` and `.github/workflows/curseforge.yml`.

## Quick Start

1. Download or clone into `Interface/AddOns/CommandSage`.
2. Launch WoW Classic.
3. Type partial slash commands (e.g. `"/cmds"`) to see suggestions. Click or press Enter to accept.
4. `/cmdsage scan` rescans commands, `/cmdsage debug` shows stats, `/cmdsage fallback` toggles fallback.

## Building

```bash
cd CommandSage
chmod +x scripts/build.sh
./scripts/build.sh
# => dist/CommandSage-1.0.zip
```

License
MIT License

Author
<Your Name or Team> - 2023. Signed off by: <Your Name> your@email.com
