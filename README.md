# CommandSage

**CommandSage** is a next-generation addon for WoW Classic that supercharges your slash-command experience.  
It features a robust autocomplete, fuzzy matching, context awareness, a snippet system, plus advanced goodies like partial fallback, usage learning, a built-in "terminal" with 50+ extra commands, and more!

---
## **Features**

- **Context-Aware Suggestions**  
  Detects in-combat vs out-of-combat scenarios, blacklisted commands, or even shell context (`/cd <cmd>`).
- **Fuzzy Matching + Partial Fallback**  
  Automatically corrects minor typos; if no prefix match is found, it can check the entire command library.
- **Animated Auto-Type**  
  Optionally simulates each keystroke for extra flair.
- **Snippet System & Parameter Hints**  
  Snippet expansions (e.g. `/dance fancy`) and color-coded param suggestions.
- **Persistent History**  
  Auto-learns from your usage; frequently used commands float to the top.
- **Favorites & Blacklisting**  
  Mark slash commands as favorites or block them from suggestions entirely.
- **Terminal Goodies**  
  Over 50 built-in slash commands reminiscent of real OS terminals, including `/cls`, `/pwd`, `/ping`, `/mem`, `/gold`, and more.
- **UI Customization**  
  Themes (dark/light/classic), scale, highlight color, advanced styling toggles, partial or strict matching.
- **Optional Licensing Gating**  
  Example logic to show how you can lock "pro" features behind a license key.

---
## **Why Use CommandSage?**

1. **Efficiency Boost**: Type far fewer characters for repeated slash commands.
2. **Discoverability**: Auto-scans built-in, fallback, macro, or custom commands.
3. **User-Friendly**: Visual autocomplete panel, keyboard navigation, optional GUI config.
4. **Customizable**: Tweak nearly everything—search mode, theme, scale, advanced keybinds, snippet expansions, etc.

---
## **Installation**

1. Download or clone the repository into your `Interface/AddOns/CommandSage/` folder.
2. Restart WoW or use `/reload`.
3. You’re done! Type `/cmdsage` to see usage.

*(Optional) You can place a **screenshot** or **video** demonstration below:*
[Add a screenshot here if you'd like] [Add a video link here if you'd like]


---
## **Usage**

- **Basic**: Type `/cmdsage` to see usage instructions.
- **Tutorial**: `/cmdsage tutorial` to open the in-game tutorial frame.
- **Re-scan**: `/cmdsage scan` if you added new commands/macros externally.
- **Fallback**: `/cmdsage fallback` or `/cmdsage nofallback` to toggle fallback mode.
- **Debug**: `/cmdsage debug` for diagnostic info (discovered commands, usage data, etc.).
- **Config**: `/cmdsage config <key> <value>` to set preferences.
- **GUI**: `/cmdsage gui` to open the config panel with checkboxes for quick toggles.

---
## **Configuration**

Some popular config keys you might set via `/cmdsage config <key> <value>`:
- `uiTheme` (dark|light|classic)
- `uiScale` (e.g. `1.2`)
- `fuzzyMatchTolerance` (numeric, default = 2)
- `animateAutoType` (true|false)
- `partialFuzzyFallback` (true|false)

You can also open the config GUI:  
`/cmdsage gui`

Check or uncheck the boxes to instantly apply changes!

---
## **Shell Context**

Try typing:  
`/cd macro`

Now you can just type `new test` (without `/macro new test`). Use `/cd ..` to go back.

---
## **Terminal Features**

If `enableTerminalGoodies` is ON, you get commands like:
- `/cls` (clear chat)
- `/whoami`, `/time`, `/uptime`, `/ping`, `/fps`, `/mem`, `/gold`, `/bagspace`, etc.
- Over 50 fun or helpful commands, from `/rand` and `/dice` to `/reminder 30 Feed the dog!`

---
## **Performance Dashboard**

Check how many Trie nodes are in memory, total discovered commands, and approximate addon RAM usage:  

`/run CommandSage_Performance:ShowDashboard()`

Toggles an in-game frame showing performance stats.

---
## **Screenshots or Video**

*(Insert your own visuals showing the autocomplete suggestions, config panel, etc.)*

---
## **Support & Feedback**

- [GitHub Issues](#) or [CurseForge Comments](#)
- For general feedback, you can also post in this thread.
- If you like this addon, consider leaving a star or positive review!

---
## **License**

CommandSage is licensed under an open license of your choice (e.g., MIT). See the source for details.  
All trademarked content (World of Warcraft, etc.) is property of Blizzard Entertainment.

Enjoy CommandSage, and happy /commanding!
