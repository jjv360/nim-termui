import ../src/termui
import strformat
import os
import asyncdispatch

# Async function
proc start() {.async.} =

    # Do a fake login
    echo "== Welcome to a fake user survey! Do not enter any real information. =="
    echo ""
    echo "Please enter your login details to continue..."
    let username = termuiAsk("Username:")
    let password = termuiAskPassword("Password:")

    # Show login progress bar
    echo ""
    let spinner = termuiSpinner("Logging you in...")
    sleep(3000)
    # spinner.complete("Successfully logged in!")

    # Fake login complete
    echo ""
    echo fmt"Welcome {username}, Your password length is {password.len()}."


# Start
waitFor start()