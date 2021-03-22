# Nim Terminal UI

This library provides simple UI components for the terminal.

## Examples

```nim
import asyncdispatch
import termui

# This is an async library, so you must run within an async function
proc start() {.async.} =

    # Ask for user input
    let name = await termuiAsk("What is your name?", defaultValue = "John")

    # Ask for password
    let password = await termuiAskPassword("Enter your password:")

    # Select from a list
    let gender = await termuiSelect("What is your gender?", options = @["Male", "Female"])

    # Select multiple
    let categories = await termuiSelectMultiple("Select categories:", options = @["Games", "Productivity", "Utilities"])

    # Confirmation
    let confirmed = await termuiConfirm("Are you sure you want to continue?")

    # Spinner
    let spinner = termuiSpinner("Checking your internet...")
    spinner.update("Almost done...")
    spinner.complete("Finished!")
    spinner.warn("Couldn't test!")
    spinner.fail("No internet access!")

# Run it
waitFor start()
```