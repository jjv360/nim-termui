import ../src/termui
import ../src/termui/spinner
import strformat
import os

# Do a fake login
echo "== Welcome to a fake user survey! Do not enter any real information. =="
echo ""
echo "Please enter your login details to continue..."
let username = termuiAsk("Username:")
let password = termuiAskPassword("Password:")

# Show login progress bar
let loader : TermuiSpinner = termuiSpinner("Logging you in...")
for i in 0 .. 2:
    loader.update(fmt"Logging in ({i}s)...")
    sleep(1000)

# login complete
loader.complete("Successfully logged in!")
# loader.warn("Could not connect.")
# loader.fail("Could not connect.")

# Fake login complete
echo ""
echo fmt"Welcome {username}, your password length is {password.len()}. Enter the following details to set up a new package."

# Ask for information
discard termuiAsk("Package name?", defaultValue = "com.user.pkg")
discard termuiConfirm("Override existing package?")
discard termuiSelect("What kind of package?", options = @["Library", "Executable", "Hybrid (both)"])