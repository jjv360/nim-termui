import ../src/termui
import strformat
import os

# Do a fake login
echo "== Welcome to a fake user survey! Do not enter any real information. =="
echo ""
echo "Please enter your login details to continue..."
let username = termuiAsk("Username:")
let password = termuiAskPassword("Password:")

# Show login progress bar
var loader = termuiSpinner("Logging you in...")
for i in 0 .. 2:
    loader.update(fmt"Logging in ({i}s)...")
    sleep(1000)
loader.warn("Login failed! Retrying...")

# Show second login attempt
loader = termuiSpinner("Logging you in...")
for i in 0 .. 2:
    loader.update(fmt"Logging in ({i}s)...")
    sleep(1000)

# login complete
loader.complete("Successfully logged in!")

# Fake login complete
echo ""
echo fmt"Welcome {username}, your password length is {password.len()}. Enter the following details to set up a new package."

# Ask for information
discard termuiAsk("Package name?", defaultValue = "com.user.pkg")
discard termuiConfirm("Override existing package?")
discard termuiSelect("What kind of package?", options = @["Library", "Executable", "Hybrid (both)"])
discard termuiSelectMultiple("What categories to use?", options = @["Books", "Business", "Entertainment", "Finance", "Food & Drink", "Lifestyle", "Music", "Navigation", "News", "Productivity", "Reference", "Sports", "Travel", "Utilities", "Weather"])

# Progress bar
let progress = termuiProgress("0% : Uploading package.json")
for i in 0 ..< 100:
    sleep(20)
    progress.update(i / 100, fmt"{i}% : Uploading package.json")
progress.complete("Uploaded package.json successfully.")

# Progress bar
let progress2 = termuiProgress("Uploading package.data...")
for i in 0 ..< 100:
    sleep(100)
    progress2.update(i / 100, fmt"{i}% : Uploading package.data...")
progress2.complete("Uploaded package.data successfully.")