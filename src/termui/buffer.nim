import classes
import unicode
import terminal
import ./ansi

## Represents a character on the screen
class Character:

    ## The character in this spot
    var character : Rune = " ".runeAt(0)

    ## The ANSI style code in this spot
    var ansiStyle = ""



## Represents a terminal screen buffer. Used for efficiently displaying and updating text in the
## terminal without using fullscreen mode.
class TerminalBuffer:

    ## Character buffer
    var characterBuffer : seq[seq[Character]]

    ## Screen buffer, represents what's actually on the screen
    var screenBuffer : seq[seq[Character]]
    var screenCursorX = 0
    var screenCursorY = 0
    var screenLastAnsiStyle = ""

    ## Current width
    var width = 0

    ## Current height
    var height = 0

    ## Current ansi style format
    var ansiStyle = ""
    var fontStyle = ""
    var fgColor = ""
    var bgColor = ""

    ## Current cursor position for writing text
    var textCursorX = 0
    var textCursorY = 0

    ## Should the cursor be visible?
    var cursorVisible = true

    ## Thread ID of the thread which first wrote data to the buffer
    var ownerThreadID : int = -1

    ## True if the draw() call has not been done yet.
    var isFirstDraw = true

    ## Number of lines we are controlling
    var numLines = 1
    

    ## Set background color
    method setBackgroundColor(ansiStyle : string = "") {.gcsafe.} =
        this.bgColor = ansiStyle
        this.ansiStyle = this.bgColor & this.fgColor & this.fontStyle


    ## Set foreground color
    method setForegroundColor(ansiStyle : string = "") {.gcsafe.} =
        this.fgColor = ansiStyle
        this.ansiStyle = this.bgColor & this.fgColor & this.fontStyle


    ## Set font style
    method setFontStyle(ansiStyle : string = "") {.gcsafe.} =
        this.fontStyle = ansiStyle
        this.ansiStyle = this.bgColor & this.fgColor & this.fontStyle


    ## Throw an error if we are not on the same thread that first modified this buffer. This
    ## is due to nim's Seq type being entirely un-thread-safe, as in the data literally gets
    ## corrupted just by accessing it from another thread which added items to it!
    method checkThread() {.gcsafe.} =

        # Only if thread support is enabled...
        when compileOption("threads"):

            # Check if first run
            if this.ownerThreadID == -1:
                this.ownerThreadID = getThreadID()
                return

            # Compare thread IDs
            if this.ownerThreadID != getThreadID():
                raiseAssert("Only the thread which first used the TerminalBuffer is allowed to access it.")

            


    ## Clear all data
    method clear() {.gcsafe.} =

        # Check thread
        this.checkThread()

        # Go through all characters and set to empty
        for line in this.characterBuffer:
            for chr in line:
                chr.character = " ".runeAt(0)
                chr.ansiStyle = ""


    ## Get character at position
    method charAt(x : int, y : int, screenBuffer : bool = false) : Character {.gcsafe.} =

        # Check thread
        this.checkThread()

        # Check which one they want
        if screenBuffer:

            # Ensure cell exists, then return it
            while this.screenBuffer.len <= y: this.screenBuffer.add(newSeq[Character]())
            while this.screenBuffer[y].len <= x: this.screenBuffer[y].add(Character.init())
            return this.screenBuffer[y][x]

        else:

            # Ensure cell exists, then return it
            while this.characterBuffer.len <= y: this.characterBuffer.add(newSeq[Character]())
            while this.characterBuffer[y].len <= x: this.characterBuffer[y].add(Character.init())
            return this.characterBuffer[y][x]


    ## Move cursor to position
    method moveTo(x, y: int) {.gcsafe.} =
        this.textCursorX = x
        this.textCursorY = y


    ## Check if a specific line is empty
    method isLineEmpty(line : int) : bool {.gcsafe.} =

        # Check thread
        this.checkThread()

        # Go through line
        for chr in this.screenBuffer[line]:
            if $chr.character != " ":
                return false

        # Line is empty
        return true


    ## Draw text
    method write(text : string) {.gcsafe.} =

        # Check thread
        this.checkThread()

        # Get terminal width
        let maxWidth = terminalWidth() - 1

        # Go through each character
        for rune in text.toRunes():

            # Set character cell
            var cell = this.charAt(this.textCursorX, this.textCursorY)
            cell.ansiStyle = this.ansiStyle
            cell.character = rune

            # Move cursor forwards one
            this.textCursorX += 1
            if this.textCursorX >= maxWidth:

                # Move to beginning of next line
                this.textCursorX = 0
                this.textCursorY += 1



    ## Draw the change from the screen buffer
    method draw() {.gcsafe.} =

        # Check thread
        this.checkThread()

        # Get terminal width
        let maxWidth = terminalWidth() - 1

        # Check if this is the first draw
        if this.isFirstDraw:

            # Move cursor to the start of the line and save this as our 0, 0 position
            this.isFirstDraw = false
            stdout.write(ansiEraseLine())
            this.screenCursorX = 0
            this.screenCursorY = 0

        # Go through every cell
        var didUpdateSomething = false
        for x in 0 ..< maxWidth:
            for y in 0 ..< this.characterBuffer.len:

                # Compare, ignore if it's the same
                let cellCharacter = this.charAt(x, y, screenBuffer = false)
                let cellScreen = this.charAt(x, y, screenBuffer = true)
                if cellCharacter.character == cellScreen.character and cellCharacter.ansiStyle == cellScreen.ansiStyle:
                    continue

                # First update this loop, hide the cursor
                if not didUpdateSomething:
                    hideCursor()
                    didUpdateSomething = true

                # If we have moved onto a new line that we are not controlling, extend the terminal buffer by printing a newline
                while y >= this.numLines:

                    # Move down if necessary to get to the bottom of the lines we control
                    let offsetY = this.numLines - this.screenCursorY - 1
                    if offsetY > 0: stdout.write(ansiMoveCursorDown(offsetY))

                    # Create a new line
                    this.numLines += 1
                    stdout.write("\n" & ansiEraseLine())
                    this.screenCursorY = this.numLines - 1
                    this.screenCursorX = 0

                # Find cursor offset
                let offsetX = x - this.screenCursorX
                let offsetY = y - this.screenCursorY
                
                # Move horizontally
                if offsetX > 0: stdout.write(ansiMoveCursorRight(offsetX))
                if offsetX < 0: stdout.write(ansiMoveCursorLeft(-offsetX))
                this.screenCursorX = x
                
                # Move vertically
                if offsetY > 0: stdout.write(ansiMoveCursorDown(offsetY))
                if offsetY < 0: stdout.write(ansiMoveCursorUp(-offsetY))
                this.screenCursorY = y

                # Check if ANSI style has changed
                if cellCharacter.ansiStyle != this.screenLastAnsiStyle:

                    # Set the new style
                    this.screenLastAnsiStyle = cellCharacter.ansiStyle
                    stdout.write(ansiResetStyle)
                    stdout.write(cellCharacter.ansiStyle)

                # Write the new character
                stdout.write(cellCharacter.character)
                this.screenCursorX += 1
                # if this.screenCursorX >= maxWidth:
                #     this.screenCursorX = 0
                #     this.screenCursorY += 1

                # Store updated character
                cellScreen.character = cellCharacter.character
                cellScreen.ansiStyle = cellCharacter.ansiStyle

        # If we updated something and hid the cursor, show it again
        if didUpdateSomething and this.cursorVisible:
            
            # Move it to the correct position... Find cursor offset
            let offsetX = this.textCursorX - this.screenCursorX
            let offsetY = this.textCursorY - this.screenCursorY
            
            # Move horizontally
            if offsetX > 0: stdout.write(ansiMoveCursorRight(offsetX))
            if offsetX < 0: stdout.write(ansiMoveCursorLeft(-offsetX))
            this.screenCursorX = this.textCursorX
            
            # Move vertically
            if offsetY > 0: stdout.write(ansiMoveCursorDown(offsetY))
            if offsetY < 0: stdout.write(ansiMoveCursorUp(-offsetY))
            this.screenCursorY = this.textCursorY

            # Show it
            showCursor()

        
        # Flush changes
        if didUpdateSomething:
            stdout.flushFile()


    ## Clean up the terminal for standard output again
    method finish() {.gcsafe.} =

        # Show cursor in case it was hidden
        if not this.cursorVisible:
            showCursor()

        # Find last line with text in it
        var lastY = 0
        for i in countdown(this.numLines-1, 0):
            if not this.isLineEmpty(i):
                lastY = i
                break

        # Move cursor to the end of the widget
        let offsetY = lastY - this.screenCursorY
        if offsetY > 0: stdout.write(ansiMoveCursorDown(offsetY))
        if offsetY < 0: stdout.write(ansiMoveCursorUp(-offsetY))
        this.screenCursorY = lastY

        # Reset terminal style
        stdout.write(ansiResetStyle)

        # Move cursor to a new fresh line
        echo ""