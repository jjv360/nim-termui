import terminal
import termui/ansi
import termui/widget
import termui/inputfield
import termui/spinner
import termui/spinners

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
