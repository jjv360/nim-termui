import classes
import ./widget
import ./ansi
import ./buffer
import ./input
import elvis

## Select field
class TermuiSelectField of TermuiWidget:

    ## The user's question
    var question = ""

    ## Input values
    var options : seq[string]

    ## Currently selected option
    var selectedIndex = 0

    ## Maximum items to display
    var maxItems = 5

    ## Constructor
    method init(question : string, options : seq[string]) =
        super.init()

        # Store vars
        this.question = question
        this.options = options
        this.buffer.cursorVisible = false


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
            this.buffer.setForegroundColor()
            this.buffer.write(this.options[this.selectedIndex])
            return

        # Calculate offset
        let smallestOffset = 0
        let biggestOffset = max(this.options.len - this.maxItems, 0)
        var offset = this.selectedIndex - (this.maxItems / 2).int
        if offset < smallestOffset: offset = smallestOffset
        if offset > biggestOffset: offset = biggestOffset

        # Show each option
        for i in offset ..< min(offset + this.maxItems, this.options.len):

            # Move to position
            this.buffer.moveTo(2, i+1 - offset)

            # Draw selector icon
            this.buffer.setForegroundColor(ansiForegroundLightBlue)
            this.buffer.write(this.selectedIndex == i ? "> " ! "  ")

            # Draw option name
            this.buffer.setForegroundColor(this.selectedIndex == i ? ansiForegroundGreen ! "")
            this.buffer.write(this.options[i])

            # Draw selector icon
            this.buffer.setForegroundColor(ansiForegroundLightBlue)
            this.buffer.write(this.selectedIndex == i ? " <" ! "  ")


    ## Overrride character input
    method onInput(event : KeyboardEvent) =
    
        # Check what character was pressed
        if event.key == "Enter":

            # Enter key! Finish this
            this.finish()

        elif event.key == "ArrowUp":

            # Up arrow!
            this.selectedIndex -= 1
            if this.selectedIndex < 0:
                this.selectedIndex = this.options.len - 1
        
        elif event.key == "ArrowDown":

            # Down arrow!
            this.selectedIndex += 1
            if this.selectedIndex >= this.options.len:
                this.selectedIndex = 0