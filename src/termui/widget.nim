import classes
import terminal
import ./ansi
import os

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


## Compare two strings, and return the index of the first character where they differ, or
## return -1 if they are an exact match.
# proc compare(str1 : string, str2 : string) : int =

#     # Go through each character
#     for i in 0 ..< max(str1.len(), str2.len()):

#         # If the one string is longer than the other, stop here
#         if i >= str1.len() or i >= str2.len():
#             return i

#         # Compare characters
#         if str1[i] != str2[i]:
#             return i

#     # It's an exact match!
#     return -1


## Parent class for widgets
class TermuiWidgetBase:

    ## Render inline with user input, or render outside in a thread
    var renderInBackgroundContinuously = false

    ## Set to false to end the background render thread
    var renderInBackgroundShouldContinue = false

    ## When start() is called this is set to true. Will block until this becomes false.
    var isBlocking = false

    ## Last frame buffer
    var lastFrame = ""

    ## Render function, subclasses should override this to return the new values
    method render() : string = ""

    ## Called when the user inputs a character while we are blocking
    method onCharacterInput(chr : char) = discard

    ## Start rendering. This will block until isBlocking becomes false. Subclasses should make it false.
    method start() =

        # Enable ANSI support for Windows terminals
        enableAnsiOnWindowsConsole()

        # If rendering continuously, start thread now
        if this.renderInBackgroundContinuously:
            this.startThread()
            return

        # Start rendering on same thread as user input
        while true:

            # Render next frame
            this.renderFrame()

            # Stop if done
            if not this.isBlocking:
                break

            # Wait for user input
            let chr = getch()
            this.onCharacterInput(chr)


    ## Render the next frame. This can be called either on the main thread or a background thread, depending
    ## if renderInBackgroundContinuously is true or not.
    method renderFrame() = 

        # Get next line output
        let line = this.render()
        if line != this.lastFrame:

            # Clear line
            stdout.write(ansiEraseLine)

            # Print output
            stdout.write(line)

            # Store it
            this.lastFrame = line

    ## Starts the backgound thread. Called on the main thread.
    method startThread() = raiseAssert("In order to use this widget, you must compile your app with the --threads:on flag.")


# Check for thread support
when not compileOption("threads"):

    # Just use the base class
    class TermuiWidget of TermuiWidgetBase

else:

    

    # Create subclass with thread support
    class TermuiWidget of TermuiWidgetBase:

        ## Thread
        var thread : Thread[pointer]

        ## Starts the backgound thread. Called on the main thread.
        method startThread() =

            # Prevent this item from being garbage collected
            GC_ref(this)

            # Create thread
            this.renderInBackgroundShouldContinue = true
            this.thread.createThread(proc(thisPtr : pointer) {.thread.} =

                # Run thread code
                let this = cast[TermuiWidget](thisPtr)
                this.runThread()

                # Remove GC reference
                sleep(100)
                GC_unref(this)

            , cast[pointer](this))


        ## Runs on a background thread
        method runThread() {.thread.} =

            # Continually re-render
            while true:

                # Check if should end
                if not this.renderInBackgroundShouldContinue:
                    break

                # Render next frame
                this.renderFrame()

                # Wait a bit
                sleep(int(1000 / 30))