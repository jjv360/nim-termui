import classes
import ./ansi
import ./widget
import ./buffer
import ./input
import strutils

## Input field
class TermuiInputField of TermuiWidget:

    ## The user's question
    var question = ""

    ## The default value, if the user presses Enter with no text entered
    var defaultValue = ""

    ## Mask characters
    var mask = ""

    ## Current value
    var value = ""

    ## Constructor
    method init(question : string, defaultValue : string = "", mask : string = "") =
        super.init()

        # Store vars
        this.question = question
        this.defaultValue = defaultValue
        this.mask = mask


    ## Render
    method render() =

        # Clear the buffer
        this.buffer.clear()

        # Draw indicator
        this.buffer.moveTo(0, 0)
        this.buffer.setForegroundColor(ansiForegroundYellow)
        this.buffer.write("> ")
        
        # Show the question
        this.buffer.setForegroundColor()
        this.buffer.write(this.question)

        # Show the default value if necessary
        if this.defaultValue.len() > 0 and this.value.len() == 0:
            this.buffer.setForegroundColor(ansiForegroundDarkGray)
            this.buffer.write(" [" & this.defaultValue & "]")

        # Show input prompt
        this.buffer.setForegroundColor(ansiForegroundYellow)
        this.buffer.write(" => ")

        # Show current input, or show mask
        this.buffer.setForegroundColor()
        if this.mask.len() > 0:
            this.buffer.write(repeat(this.mask, this.value.len()))
        else:
            this.buffer.write(this.value)


    ## Called when the user inputs a character
    method onInput(event : KeyboardEvent) =

        # Check for special codes
        if event.key == "Backspace":

            # Backspace key! Remove a character
            if this.value.len() > 0: this.value = this.value.substr(0, this.value.len() - 2)
            return

        elif event.key == "Enter":

            # Enter key! Finish this
            if this.value.len == 0: this.value = this.defaultValue
            this.finish()
            return

        elif event.key == "Delete":

            # Delete key!
            return

        elif event.key.len != 1:

            # Ignore other control characters
            return

        # Add it to the current value
        this.value &= event.key