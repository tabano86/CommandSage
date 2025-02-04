# CommandSage 🎮✨

**CommandSage** is a powerful, next-generation addon for World of Warcraft Classic that revolutionizes your slash-command experience with intelligent autocompletion, fuzzy matching, and advanced features.

![Version](https://img.shields.io/badge/Version-4.0-blue)
![Game Version](https://img.shields.io/badge/WoW-Classic%2011.4.0-yellow)

## 🌟 Key Features

### Core Functionality
- **Smart Autocomplete** - Context-aware command suggestions
- **Fuzzy Matching** - Tolerant to typos and partial matches
- **Command History** - Learns from your usage patterns
- **Parameter Hints** - Color-coded parameter suggestions
- **Snippet System** - Custom command expansions

### Advanced Features
- **Shell Context** - Use `/cd` to enter command contexts
- **Terminal Commands** - 50+ utility commands like `/cls`, `/time`, `/ping`
- **Performance Tools** - Built-in metrics and optimization
- **Accessibility Options** - High contrast mode and scaling
- **Custom Themes** - Dark, Light, and Classic UI themes

## 🚀 Quick Start

1. **Install:**
   ```
   Copy to Interface/AddOns/CommandSage/
   ```

2. **Basic Usage:**
  - Type `/cmdsage` for help
  - Use `/cmdsage tutorial` for interactive guide
  - Access settings with `/cmdsage config`

3. **First Steps:**
  - Try typing a partial command to see suggestions
  - Use Tab/Arrow keys to navigate suggestions
  - Press Enter to complete the command

## ⚙️ Configuration

### Command Line
```
/cmdsage config
```

### Key Settings
| Setting | Values | Description |
|---------|--------|-------------|
| uiTheme | dark/light/classic | Interface theme |
| uiScale | 0.8-2.0 | UI scaling factor |
| fuzzyMatchTolerance | 0-5 | Typo tolerance |
| animateAutoType | true/false | Typing animation |

### GUI Configuration
Open settings panel with:
```
/cmdsage gui
```

## 🔧 Advanced Features

### Shell Context
```
/cd macro # Enter macro context new test # Creates new macro 'test' /cd .. # Exit context
```

### Terminal Commands
- `/cls` - Clear chat
- `/pwd` - Show current zone
- `/time` - Server time
- `/uptime` - Session duration
- `/mem` - Memory usage
- `/gold` - Gold across characters
- And 45+ more commands!

## 🎯 Performance

Monitor addon performance:

```
/cmdsage perf
```

Displays:
- Memory usage
- Command count
- Trie node stats
- Suggestion latency

## 🎨 Accessibility

Built-in accessibility features:
- High contrast mode
- Scalable UI
- Color customization
- Clear, readable fonts

## 📘 Documentation

Full documentation:
- [Configuration Guide](link)
- [Command Reference](link)
- [API Documentation](link)
- [Performance Tips](link)

## 🤝 Support
(coming soon...)

[//]: # (- Report issues on [GitHub]&#40;link&#41;)

[//]: # (- Join our [Discord]&#40;link&#41;)

[//]: # (- Visit the [Wiki]&#40;link&#41;)

## 📜 License

MIT License - See LICENSE file for details.

---
*World of Warcraft® and Blizzard Entertainment® are trademarks or registered trademarks of Blizzard Entertainment, Inc.*
