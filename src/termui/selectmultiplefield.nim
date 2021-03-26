import classes
import ./widget
import ./ansi
import ./buffer
import elvis
import strutils

## Select field
class TermuiSelectMultipleField of TermuiWidget:

    ## The user's question
    var question = ""

    ## Input values
    var options : seq[string]

    ## Cursor index
    var cursorIndex = 0

    ## Currently selected option
    var selectedItems : seq[bool]

    ## Maximum items to display
    var maxItems = 5

    ## Constructor
    method init(question : string, options : seq[string], defaultValue : seq[bool] = @[]) =
        super.init()

        # Store vars
        this.question = question
        this.options = options
        this.buffer.cursorVisible = false

        # Expand selectedItems
        this.selectedItems = defaultValue
        while this.selectedItems.len < this.options.len:
            this.selectedItems.add(false)


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

        # If finished, show the selected option instead
        if this.isFinished:

            # Show picked value
            this.buffer.setForegroundColor(ansiForegroundYellow)
            this.buffer.write(" => ")

            # Create a list of selected items
            var selectedText : seq[string]
            for i in 0 ..< this.options.len:
                if this.selectedItems[i]:
                    selectedText.add(this.options[i])

            # Create text
            let txt = selectedText.join(", ")

            # Output it
            this.buffer.setForegroundColor()
            this.buffer.write(txt)
            return

        # Calculate length of longest option
        var longestLen = 0
        for opt in this.options:
            if opt.len > longestLen:
                longestLen = opt.len

        # Calculate offset
        let smallestOffset = 0
        let biggestOffset = max(this.options.len - this.maxItems, 0)
        var offset = this.cursorIndex - (this.maxItems / 2).int
        if offset < smallestOffset: offset = smallestOffset
        if offset > biggestOffset: offset = biggestOffset

        # Show each option
        for i in offset ..< min(offset + this.maxItems, this.options.len):

            # Move to position
            this.buffer.moveTo(2, i+1 - offset)

            # Draw selector icon
            this.buffer.setForegroundColor(this.selectedItems[i] ? ansiForegroundGreen ! "")
            this.buffer.write(this.selectedItems[i] ? "√ " ! "  ")

            # Draw option name
            this.buffer.write(this.options[i])

            # Draw cursor if necessary
            if this.cursorIndex == i:
                this.buffer.setForegroundColor(ansiForegroundLightBlue)
                this.buffer.write(" ".repeat(longestLen - this.options[i].len))
                this.buffer.write(" <-- ")
                this.buffer.setForegroundColor(ansiForegroundDarkGray)
                this.buffer.write("space to select")



    ## Overrride character input
    method onCharacterInput(chr : char) =
    
        # Check what character was pressed
        let code = chr.int()
        if code == 13:

            # Enter key! Finish this
            this.finish()
            return

        elif code == 32:

            # Space key! Toggle the current one
            this.selectedItems[this.cursorIndex] = not this.selectedItems[this.cursorIndex]


    ## Called when the user inputs a special keycode, like an arrow press etc
    method onControlInput(chr : char) = 

        # Check what was pressed
        let code = chr.int()
        if code == 72:

            # Up arrow!
            this.cursorIndex -= 1
            if this.cursorIndex < 0:
                this.cursorIndex = this.options.len - 1
        
        elif code == 80:

            # Down arrow!
            this.cursorIndex += 1
            if this.cursorIndex >= this.options.len:
                this.cursorIndex = 0