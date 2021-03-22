import classes
import ./ansi
import ./widget
import ./spinners
import strutils
import times


## Input field
class TermuiSpinner of TermuiWidget:

    ## Status text
    var statusText = ""

    ## Spinner
    var spinnerIcon : Spinner

    ## Current spinner frame
    var currentFrame = 0

    ## Last frame update
    var lastFrameUpdate : float = cpuTime()

    ## Constructor
    method init(statusText : string = "Loading...", spinnerIcon : Spinner) =

        # Store vars
        this.isBlocking = true
        this.statusText = statusText
        this.spinnerIcon = spinnerIcon


    ## Render
    method render() : string =

        # Check if the frame should be advanced
        let lastFrameMillis = (cpuTime() - this.lastFrameUpdate) * 1000
        if lastFrameMillis >= this.spinnerIcon.interval.float():

            # Increase frame
            this.lastFrameUpdate = cpuTime()
            this.currentFrame += 1

            # Reset to 0 if gone past the end
            if this.currentFrame >= this.spinnerIcon.frames.len():
                this.currentFrame = 0

        # Draw frame icon
        var output = ""
        output &= fgYellow(this.spinnerIcon.frames[this.currentFrame])

        # Add text
        output &= " "
        output &= this.statusText
        return output

        