import classes
import ./ansi
import ./widget
import ./spinners
import ./buffer
import times
import terminal
import strutils

## States
type ProgressBarState = enum
    Running, Complete, Warning, Error

## Input field
class TermuiProgressBar of TermuiWidget:

    ## Status text
    var statusText = ""

    ## Current progress from 0 to 1
    var progress = 0.0

    ## Current state
    var state : ProgressBarState = Running

    ## Length of the bar
    var barLength = 16

    ## Constructor
    method init(statusText : string) =
        super.init()

        # Store vars
        this.redrawMode = TermuiRedrawManually
        this.buffer.cursorVisible = false
        this.statusText = statusText


    ## Render
    method render() {.gcsafe.} =

        # Clear the buffer
        this.buffer.clear()
        this.buffer.moveTo(0, 0)

        # Draw frame icon
        if this.state == Complete:

            # Draw checkmark
            this.buffer.setForegroundColor(ansiForegroundGreen)
            this.buffer.write("√ ")
            this.buffer.setForegroundColor()
            this.buffer.write(this.statusText)
            return

        elif this.state == Warning:

            # Draw warning icon
            this.buffer.setForegroundColor(ansiForegroundYellow)
            this.buffer.write("! ")
            this.buffer.setForegroundColor()
            this.buffer.write(this.statusText)
            return

        elif this.state == Error:

            # Draw error icon
            this.buffer.setForegroundColor(ansiForegroundRed)
            this.buffer.write("! ")
            this.buffer.setForegroundColor()
            this.buffer.write(this.statusText)
            return

        # Draw progress bar
        let numFilled = (this.progress * this.barLength.float).int
        let numEmpty = this.barLength - numFilled
        this.buffer.setForegroundColor(ansiForegroundYellow)
        this.buffer.write("[")
        this.buffer.write("■".repeat(numFilled))
        this.buffer.setForegroundColor(ansiForegroundLightGreen)
        this.buffer.write(" ".repeat(numEmpty))
        this.buffer.setForegroundColor(ansiForegroundYellow)
        this.buffer.write("] ")

        # Draw text
        this.buffer.setForegroundColor()
        this.buffer.write(this.statusText)


    ## Update text
    method update(progress : float, text : string = "") {.gcsafe.} =

        # Update text
        this.progress = progress
        if text.len > 0:
            this.statusText = text

        # Redraw frame if no thread support
        this.renderFrame()


    ## Finish with completion
    method complete(text : string = "") {.gcsafe.} =

        # Update text
        if text.len() > 0:
            this.statusText = text

        # Update state re-render
        this.state = Complete
        this.finish()
        

    ## Finish with warning
    method warn(text : string = "") {.gcsafe.} =

        # Update text
        if text.len() > 0:
            this.statusText = text

        # Update state re-render
        this.state = Warning
        this.finish()
        

    ## Finish with error
    method fail(text : string = "") {.gcsafe.} =

        # Update text
        if text.len() > 0:
            this.statusText = text

        # Update state re-render
        this.state = Error
        this.finish()
