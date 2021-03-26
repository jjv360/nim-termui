import classes
import ./widget
import ./ansi
import ./buffer
import ./input
import elvis

## Input field
class TermuiConfirmField of TermuiWidget:

    ## The user's question
    var question = ""

    ## Confirm value
    var value = false

    ## Constructor
    method init(question : string) =
        super.init()

        # Store vars
        this.question = question


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

        # Show input prompt or result
        if this.isFinished:
            this.buffer.setForegroundColor(ansiForegroundYellow)
            this.buffer.write(" => ")
            this.buffer.setForegroundColor()
            this.buffer.write(this.value ? "Yes" ! "No")
        else:
            this.buffer.setForegroundColor(ansiForegroundYellow)
            this.buffer.write(" (y/n) ")


    ## Overrride character input
    method onInput(event : KeyboardEvent) =
    
        # Check what character was pressed
        if event.key == "y" or event.key == "Y":
            this.value = true
            this.finish()
        elif event.key == "n" or event.key == "N":
            this.value = false
            this.finish()