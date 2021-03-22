import classes
import ./ansi
import ./widget
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

        # Store vars
        this.isBlocking = true
        this.question = question
        this.defaultValue = defaultValue
        this.mask = mask


    ## Render
    method render() : string =

        # Show the question
        var output = fgYellow("> ") & this.question

        # Show the default value if necessary
        if this.defaultValue.len() > 0 and this.value.len() == 0:
            output &= fgDarkGray(" [" & this.defaultValue & "]")

        # Show input prompt
        output &= fgYellow(" => ")

        # Show current input, or show mask
        if this.mask.len() > 0:
            output &= repeat(this.mask, this.value.len())
        else:
            output &= this.value

        # Done
        return output


    ## Called when the user inputs a character
    method onCharacterInput(chr : char) =

        # Check for special codes
        let code = chr.int()
        if code == 8:

            # Backspace key! Remove a character
            if this.value.len() > 0: this.value = this.value.substr(0, this.value.len() - 2)
            return

        elif code == 13:

            # Enter key! Finish this
            this.isBlocking = false
            echo ""
            return

        elif code == 127:

            # Delete key!
            return

        elif code <= 31:

            # Ignore other control characters
            return

        # Add it to the current value
        this.value &= chr