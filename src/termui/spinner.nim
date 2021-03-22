import classes
import ./ansi
import ./widget
import ./spinners
import times
import terminal

## States
type SpinnerState = enum
    Running, Complete, Warning, Error

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

    ## Current state
    var state : SpinnerState = Running

    ## Constructor
    method init(statusText : string = "Loading...", spinnerIcon : Spinner) =

        # Store vars
        this.renderInBackgroundContinuously = true
        this.statusText = statusText
        this.spinnerIcon = spinnerIcon

        # Disable cursor
        hideCursor()


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
        if this.state == Running:

            # Draw progress frame
            output &= fgLightBlue(this.spinnerIcon.frames[this.currentFrame])

        elif this.state == Complete:

            # Draw checkmark
            output &= fgGreen("√")

        elif this.state == Warning:

            # Draw warning icon
            output &= fgYellow("!")

        elif this.state == Error:

            # Draw error icon
            output &= fgRed("!")

        # Add text
        output &= " "
        output &= this.statusText
        return output


    ## Update text
    method update(text : string) =
        this.statusText = text


    ## Finish with completion
    method complete(text : string = "") =

        # Update text
        if text.len() > 0:
            this.statusText = text

        # Update state re-render
        this.state = Complete
        this.renderInBackgroundShouldContinue = false
        this.renderFrame()
        echo ""

        # Show cursor again
        showCursor()
        

    ## Finish with warning
    method warn(text : string = "") =

        # Update text
        if text.len() > 0:
            this.statusText = text

        # Update state re-render
        this.state = Warning
        this.renderInBackgroundShouldContinue = false
        this.renderFrame()
        echo ""

        # Show cursor again
        showCursor()
        

    ## Finish with error
    method fail(text : string = "") =

        # Update text
        if text.len() > 0:
            this.statusText = text

        # Update state re-render
        this.state = Error
        this.renderInBackgroundShouldContinue = false
        this.renderFrame()
        echo ""

        # Show cursor again
        showCursor()