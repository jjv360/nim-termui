import classes
import ./widget
import ./ansi
import elvis

## Input field
class TermuiConfirmField of TermuiWidget:

    ## The user's question
    var question = ""

    ## Confirm value
    var value = false

    ## Complete
    var isComplete = false

    ## Constructor
    method init(question : string) =

        # Store vars
        this.isBlocking = true
        this.question = question


    ## Render
    method render() : string =

        # Show the question
        var output = fgYellow("> ") & this.question

        # Show input prompt or result
        if this.isComplete:
            output &= fgYellow(" => ") & (this.value ? "Yes" ! "No")
        else:
            output &= fgYellow(" (y/n) ")

        # Done
        return output


    ## Overrride character input
    method onCharacterInput(chr : char) =
    
        # Check what character was pressed
        if chr == 'y' or chr == 'Y':
            this.value = true
            this.isBlocking = false
            this.isComplete = true
            this.renderFrame()
            echo ""
        elif chr == 'n' or chr == 'N':
            this.value = false
            this.isBlocking = false
            this.isComplete = true
            this.renderFrame()
            echo ""