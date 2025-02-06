# BUG_TRACKER.md

Below are 20 predicted issues that could arise in the next 5 weeks, with 15 already fixed.

1. **(Fixed)** Rainbow border in the autocomplete frame occasionally flickers when the user quickly toggles advanced
   styling.
    - *Resolution:* Added throttling to the color-shift in `CommandSage_AutoComplete.lua`.
2. **(Fixed)** `/3dspin` command: potential crash if no 3D environment is detected in certain builds.
    - *Resolution:* Added a check for `WorldFrame` existence in `CommandSage_Terminal.lua`.
3. **(Fixed)** `/color` command not clamping RGB values properly, leading to black or white text.
    - *Resolution:* Implemented clamp logic from `0.0` to `1.0` in `CommandSage_Terminal.lua`.
4. **(Fixed)** Chat input halo sometimes remains after switching chat tabs.
    - *Resolution:* Removed leftover references after chat tab change in `CommandSage_Core.lua`.
5. **(Fixed)** Voice input simulation triggers an error if typed text is empty.
    - *Resolution:* Added a nil/empty check in `CommandSage_MultiModal.lua`.
6. **(Fixed)** Usage chart in the config GUI does not display if usage data is empty.
    - *Resolution:* Fallback to "No data" message in the new chart code in `CommandSage_ConfigGUI.lua`.
7. **(Fixed)** Param suggestions with glow overlaps standard text if advanced styling is disabled.
    - *Resolution:* Conditioned glow overlay in `CommandSage_ParameterHelper.lua` on `advancedStyling`.
8. **(Fixed)** AR “Rune ring” flickers in windowed mode with vsync off.
    - *Resolution:* Limited update frequency in `CommandSage_AROverlays.lua`.
9. **(Fixed)** Emote sticker occasionally appears behind other UI elements.
    - *Resolution:* Elevated the `DrawLayer` to "OVERLAY" for sticker textures in `CommandSage_AROverlays.lua`.
10. **(Fixed)** Large text mode not resetting after UI reload.
    - *Resolution:* Added a forced reset on reload in `CommandSage_UIAccessibility.lua`.
11. **(Fixed)** Shell context can remain stuck if user forcibly unloads the addon (rare).
    - *Resolution:* Cleared `currentContext` on ADDON_UNLOADED event in `CommandSage_ShellContext.lua`.
12. **(Fixed)** Macro scanning might skip macros with identical names if SHIFT is pressed.
    - *Resolution:* Merged a known bugfix in `CommandSage_Discovery.lua`.
13. **(Fixed)** Fuzzy match can degrade performance with large sets of commands.
    - *Resolution:* Slight caching of Levenshtein calls in `CommandSage_FuzzyMatch.lua`.
14. **(Fixed)** Windows build script fails if Bash is not installed or wsl not found.
    - *Resolution:* Provided a fallback in `scripts/build.bat`.
15. **(Fixed)** Parameter suggestions sometimes do not refresh if typed too quickly.
    - *Resolution:* Rate-limited text updates in `CommandSage_AutoComplete.lua`.
16. **(Unfixed)** Potential memory spike if user has 1,000+ macros discovered.
    - *Plan:* Expand optional pagination in `CommandSage_Discovery`.
17. **(Unfixed)** TTS readback can produce overlapping voices with repeated commands.
    - *Plan:* Throttle TTS calls in `CommandSage_UIAccessibility.lua`.
18. **(Unfixed)** /donate link can fail on certain localizations of the WoW client.
    - *Plan:* Add localization checks or fallback links.
19. **(Unfixed)** 3D spin might cause glitch if the user’s character is in a vehicle seat.
    - *Plan:* Check for `UnitInVehicle` in `CommandSage_Terminal.lua`.
20. **(Unfixed)** Combining color + 3dspin might yield unexpected behavior in minimal clients.
    - *Plan:* Possibly disallow simultaneous calls or queue them.

15 issues marked **(Fixed)**, 5 remain unresolved.
