![](https://img.shields.io/badge/status-unstable-lightgray)
![](https://img.shields.io/badge/windows-✓-green)
![](https://img.shields.io/badge/linux-%3F-lightgray)
![](https://img.shields.io/badge/mac-%3F-lightgray)

# Nim Terminal UI

This library provides simple UI components for the terminal.

## Examples

```nim
import termui

# Ask for user input
let name = termuiAsk("What is your name?", defaultValue = "John")

# Ask for password
let password = termuiAskPassword("Enter your password:")

# Select from a list
let gender = termuiSelect("What is your gender?", options = @["Male", "Female"])

# Select multiple (TODO)
# let categories = termuiSelectMultiple("Select categories:", options = @["Games", "Productivity", "Utilities"])

# Confirmation
let confirmed = termuiConfirm("Are you sure you want to continue?")

# Spinner (requires --threads:on flag when compiling)
let spinner = termuiSpinner("Checking your internet...")
spinner.update("Almost done...")
spinner.complete("Finished!")
spinner.warn("Couldn't test!")
spinner.fail("No internet access!")
```