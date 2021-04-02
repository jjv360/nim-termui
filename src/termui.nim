import termui/widget
import termui/inputfield
import termui/spinner
import termui/spinners
import termui/confirmfield
import termui/selectfield
import termui/selectmultiplefield
import termui/progressbar
import termui/ansi

export spinner
export spinners
export progressbar

## Ask for some input from the user
proc termuiAsk*(question : string, defaultValue : string = "", mask : string = "") : string =

    # Create widget
    let widget = TermuiInputField.init(question, defaultValue, mask)
    widget.start()

    # Return result, or default value if no value was entered
    if widget.value.len() == 0:     return defaultValue
    else:                           return widget.value


## Ask for a password from the user
proc termuiAskPassword*(question : string) : string =
    return termuiAsk(question, mask = "•")


## Show a spinner. Remember to call spinner.complete() when done.
proc termuiSpinner*(text : string = "Please wait...", spinnerIcons : Spinner = Spinners[Line]) : TermuiSpinner =

    # Create widget
    let widget = TermuiSpinner.init(text, spinnerIcons)
    widget.start()
    return widget


## Ask for confirmation from the user
proc termuiConfirm*(question : string) : bool =

    # Create widget
    let widget = TermuiConfirmField.init(question)
    widget.start()
    return widget.value


## Ask for a single selection
proc termuiSelect*(question : string, options : seq[string]) : string =

    # Create widget
    let widget = TermuiSelectField.init(question, options)
    widget.start()
    return options[widget.selectedIndex]


## Ask for multiple selection
proc termuiSelectMultiple*(question : string, options : seq[string]) : seq[string] =

    # Create widget
    let widget = TermuiSelectMultipleField.init(question, options, @[])
    widget.start()

    # Create list of selected items
    var selectedList : seq[string]
    for i in 0 ..< options.len:
        if widget.selectedItems[i]:
            selectedList.add(options[i])

    # Done
    return selectedList


## Show a progress bar. Remember to call progressbar.complete() when done.
proc termuiProgress*(text : string = "Please wait...") : TermuiProgressBar =

    # Create widget
    let widget = TermuiProgressBar.init(text)
    widget.start()
    return widget


## Show a label output, as if it has been entered in a text field
proc termuiLabel*(text : string, value : string) =

    # Just output it here
    echo ansiEraseLine() & ansiForegroundYellow & "> " & ansiResetStyle & text & ansiForegroundYellow & " => " & ansiResetStyle & value