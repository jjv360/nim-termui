![](https://img.shields.io/badge/status-beta-orange)
![](https://img.shields.io/badge/windows-✓-green)
![](https://img.shields.io/badge/mac-✓-green)
![](https://img.shields.io/badge/linux-%3F-lightgray)

# Nim Terminal UI

This library provides simple UI components for the terminal. To install, run:

```sh
nimble install termui
```

## Examples

```nim
import termui

# Ask for user input
let name = termuiAsk("What is your name?", defaultValue = "John")

# Ask for password
let password = termuiAskPassword("Enter your password:")

# Select from a list
let gender = termuiSelect("What is your gender?", options = @["Male", "Female"])

# Select multiple
let categories = termuiSelectMultiple("Select categories:", options = @["Games", "Productivity", "Utilities"])

# Confirmation
let confirmed = termuiConfirm("Are you sure you want to continue?")

# Progress bar
let progress = termuiProgress("Uploading file...")
progress.update(0.1)
progress.complete("Finished!")
progress.warn("Couldn't upload!")
progress.fail("No internet access!")

# Spinner (requires --threads:on when compiling)
let spinner = termuiSpinner("Checking your internet...")
spinner.update("Almost done...")
spinner.complete("Finished!")
spinner.warn("Couldn't test!")
spinner.fail("No internet access!")
```