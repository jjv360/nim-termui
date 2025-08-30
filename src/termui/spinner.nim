import classes
import ./ansi
import ./widget
import ./spinners
import ./buffer
import times

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
    var lastFrameUpdate : float = epochTime()

    ## Current state
    var state : SpinnerState = Running

    ## Constructor
    method init(statusText : string = "Loading...", spinnerIcon : Spinner) =
        super.init()

        # Store vars
        this.redrawMode = TermuiRedrawInThread
        this.buffer.cursorVisible = false
        this.statusText = statusText
        this.spinnerIcon = spinnerIcon


    ## Render
    method render() =

        # Check if the frame should be advanced
        let lastFrameMillis = (epochTime() - this.lastFrameUpdate) * 1000
        if lastFrameMillis >= this.spinnerIcon.interval.float():

            # Increase frame
            this.lastFrameUpdate = epochTime()
            this.currentFrame += 1

            # Reset to 0 if gone past the end
            if this.currentFrame >= this.spinnerIcon.frames.len():
                this.currentFrame = 0

        # Clear the buffer
        this.buffer.clear()

        # Draw frame icon
        if this.state == Running:

            # Draw progress frame
            this.buffer.moveTo(0, 0)
            this.buffer.setForegroundColor(ansiForegroundLightBlue)
            this.buffer.write(this.spinnerIcon.frames[this.currentFrame])

        elif this.state == Complete:

            # Draw checkmark
            this.buffer.moveTo(0, 0)
            this.buffer.setForegroundColor(ansiForegroundGreen)
            this.buffer.write("√")

        elif this.state == Warning:

            # Draw warning icon
            this.buffer.moveTo(0, 0)
            this.buffer.setForegroundColor(ansiForegroundYellow)
            this.buffer.write("!")

        elif this.state == Error:

            # Draw error icon
            this.buffer.moveTo(0, 0)
            this.buffer.setForegroundColor(ansiForegroundRed)
            this.buffer.write("!")

        # Add text
        this.buffer.setForegroundColor()
        this.buffer.write(" ")
        this.buffer.write(this.statusText)


    ## Update text
    method update(text : string) =

        # Update text
        this.statusText = text

        # Redraw frame if no thread support
        when not compileOption("threads"):
            this.renderFrame()


    ## Finish with completion
    method complete(text : string = "") =

        # Update text
        if text.len() > 0:
            this.statusText = text

        # Update state re-render
        this.state = Complete
        this.finish()
        

    ## Finish with warning
    method warn(text : string = "") =

        # Update text
        if text.len() > 0:
            this.statusText = text

        # Update state re-render
        this.state = Warning
        this.finish()
        

    ## Finish with error
    method fail(text : string = "") =

        # Update text
        if text.len() > 0:
            this.statusText = text

        # Update state re-render
        this.state = Error
        this.finish()