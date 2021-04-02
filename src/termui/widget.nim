import classes
import terminal
import ./ansi
import ./buffer
import ./input
import os
import strutils


## Widget draw modes
type TermuiWidgetDrawMode* = enum

    ## The widget start() method will block until the widget is finished. The widget will receive key events,
    ## and will redraw after each one.
    TermuiRedrawOnUserInput,

    ## The widget will continually redraw on a background thread. It will not receive key events.
    TermuiRedrawInThread,

    ## The widget will redraw only when the caller updates the widget. It will not receive key events.
    TermuiRedrawManually


## Last terminal mode
when not defined(windows):
    import termios

    # From terminal.nim
    proc setRaw(fd: FileHandle, time: cint = TCSAFLUSH) =
        var mode: Termios
        discard fd.tcGetAttr(addr mode)
        mode.c_iflag = mode.c_iflag and not Cflag(BRKINT or ICRNL or INPCK or
        ISTRIP or IXON)
        mode.c_oflag = mode.c_oflag and not Cflag(OPOST)
        mode.c_cflag = (mode.c_cflag and not Cflag(CSIZE or PARENB)) or CS8
        mode.c_lflag = mode.c_lflag and not Cflag(ECHO or ICANON or IEXTEN or ISIG)
        mode.c_cc[VMIN] = 1.cuchar
        mode.c_cc[VTIME] = 0.cuchar
        discard fd.tcSetAttr(time, addr mode)

    var lastTermiosMode: Termios


## Parent class for widgets
class TermuiWidgetBase:

    ## Redraw mode
    var redrawMode : TermuiWidgetDrawMode = TermuiRedrawOnUserInput

    ## True once this component is done and no longer updating
    var isFinished = false

    ## Frame buffer
    var buffer : TerminalBuffer = TerminalBuffer.init()

    ## Render function, subclasses should override this and update the buffer
    method render() = discard

    ## Called when the user inputs something on the keyboard while we are blocking
    method onInput(event : KeyboardEvent) = discard

    ## Start rendering. This will block until isBlocking becomes false. Subclasses should make it false.
    method start() =

        # Enable ANSI support for Windows terminals
        enableAnsiOnWindowsConsole()

        # TODO: Enable UTF8 output for Windows terminals (chcp 65001)

        # Prevent keyboard echoing on Linux/mac
        when not defined(windows):
            let fd = getFileHandle(stdin)
            discard fd.tcGetAttr(addr lastTermiosMode)
            fd.setRaw()

        # If rendering continuously, start thread now
        if this.redrawMode == TermuiRedrawInThread:
            this.startThread()
            return

        # If rendering on updates only, just draw one frame now
        if this.redrawMode == TermuiRedrawManually:
            this.renderFrame()
            return

        # Start rendering on same thread as user input
        while true:

            # Stop if done
            if this.isFinished:
                break

            # Render next frame
            this.renderFrame()

            # Wait for user input
            let event = readTerminalInput()
            this.onInput(event)


    ## Render the next frame. This can be called either on the main thread or a background thread, depending
    ## if renderInBackgroundContinuously is true or not.
    method renderFrame() = 

        # Allow subclass to update the buffer
        this.render()

        # Draw buffer to the screen
        this.buffer.draw()


    ## Finish this widget
    method finish() =

        # Stop the loop
        this.isFinished = true

        # Run one last output just in case it changed when finishing
        if this.redrawMode != TermuiRedrawInThread:
            this.renderFrame()
            this.buffer.finish()

        # In the case where threading is not supported but this widget wanted to be threaded,
        # we can still draw our last frame here. It's something, at least...
        when not compileOption("threads"):
            if this.redrawMode == TermuiRedrawInThread:
                this.renderFrame()
                this.buffer.finish()

        # Restore keyboard echoing
        when not defined(windows):
            let fd = getFileHandle(stdin)
            discard fd.tcSetAttr(TCSADRAIN, addr lastTermiosMode)


    ## Starts the background thread. Called on the main thread.
    method startThread() = 
    
        # Not supported! Let's just draw one iteration now
        this.renderFrame()


# Check for thread support
when not compileOption("threads"):

    # Just use the base class
    class TermuiWidget of TermuiWidgetBase

else:

    # Extra imports
    # import locks

    # Create subclass with thread support
    class TermuiWidget of TermuiWidgetBase:

        ## Thread
        var thread : Thread[pointer]

        ## Starts the backgound thread. Called on the main thread.
        method startThread() =

            # HACK: Lock it so the instance doesn't get garbage collected. Without this, it is giving a SIGSEGV at random places AFTER the widget
            # is already completed and the thread ended! I don't understand it at all.
            GC_ref(this)

            # Create thread
            this.thread.createThread(proc(thisPtr : pointer) {.thread.} =

                # Run thread code
                var this = cast[TermuiWidget](thisPtr)
                this.runThread()

            , cast[pointer](this))


        ## Runs on a background thread
        method runThread() {.thread.} =

            # Continually re-render
            while true:

                # Check if should end
                if this.isFinished:
                    break

                # Render next frame
                this.renderFrame()

                # Wait a bit
                sleep(int(1000 / 30))

            # Render one more time before exiting
            this.renderFrame()

            # Clean up the terminal
            this.buffer.finish()


        ## Finish this widget
        method finish() =

            # Kill the thread, wait for it to finish
            if this.redrawMode == TermuiRedrawInThread:
                this.isFinished = true
                this.thread.joinThread()

                # HACK: Unlock this for garbage collection. Well, normally, right? Except doing this triggers that same SIGSEGV at random intervals.
                # Unfortunately, we're going to have to just waste this memory for now...
                #GC_unref(this)

            # Continue
            super.finish()