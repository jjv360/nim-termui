import classes
import terminal
import ./ansi
import ./buffer
import ./input
import os
import strutils

## Check if on Windows, and if so then define some useful win32 APIs we're going to call later
when defined(windows):
    import winlean

    ## Flag to enable ANSI support in the terminal
    const ENABLE_VIRTUAL_TERMINAL_PROCESSING = 0x0004

    ## Retrieves the current input mode of a console's input buffer or the current output mode of a console screen buffer.
    proc GetConsoleMode(hConsoleHandle: Handle, dwMode: ptr DWORD): WINBOOL{. stdcall, dynlib: "kernel32", importc: "GetConsoleMode" .}

    ## Sets the input mode of a console's input buffer or the output mode of a console screen buffer.
    proc SetConsoleMode(hConsoleHandle: Handle, dwMode : DWORD) : WINBOOL {. stdcall, dynlib: "kernel32", importc: "SetConsoleMode" .}


## Allow ANSI codes on Windows
proc enableAnsiOnWindowsConsole() =

    # Prepare the Windows terminal for ANSI color codes: SetConsoleMode ENABLE_VIRTUAL_TERMINAL_PROCESSING
    when defined(windows):

        # Get Handle to the Windows terminal
        let hTerm = getStdHandle(STD_OUTPUT_HANDLE)

        # Get current console mode flags
        var flags : DWORD = 0
        let success = GetConsoleMode(hTerm, addr flags)
        if success != 0:

            # Add the processing flag in
            flags = flags or ENABLE_VIRTUAL_TERMINAL_PROCESSING

            # Set the terminal mode
            discard SetConsoleMode(hTerm, flags)


## Parent class for widgets
class TermuiWidgetBase:

    ## Render inline with user input, or render outside in a thread
    var isThreaded = false

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

        # If rendering continuously, start thread now
        if this.isThreaded:
            this.startThread()
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
        if not this.isThreaded:
            this.renderFrame()
            this.buffer.finish()

        # In the case where threading is not supported but this widget wanted to be threaded,
        # we can still draw our last frame here. It's something, at least...
        when not compileOption("threads"):
            if this.isThreaded:
                this.renderFrame()
                this.buffer.finish()


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

            # Create thread
            var this2 = this
            this.thread.createThread(proc(thisPtr : pointer) {.thread.} =

                # Run thread code
                var this = cast[TermuiWidget](thisPtr)
                this.runThread()

                # Remove GC reference
                # sleep(2000)
                # GC_unref(this)

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
            if this.isThreaded:
                this.isFinished = true
                this.thread.joinThread()

            # Continue
            super.finish()