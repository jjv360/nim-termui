import classes
import bitops
import terminal
when defined(windows):
    import winlean

## Represents a key event, kinda following the JavaScript standard defined at https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent
class KeyboardEvent:

    ## Returns a Boolean that is true if the Alt (Option or ⌥ on OS X) key was active when the key event was generated.
    var altKey = false

    ## Returns a string with the code value of the physical key represented by the event.
    # var code = ""

    ## Returns a Boolean that is true if the Ctrl key was active when the key event was generated.
    var ctrlKey = false

    ## Returns a string representing the key value of the key represented by the event. This can be used for saving the typed character to a text field, etc.
    ## If the length of this string is 1, it is most likely an input character and not a control key.
    var key = ""

    ## Returns a Boolean that is true if the Meta key (on Mac keyboards, the ⌘ Command key; on Windows keyboards, the Windows key (⊞)) was active when the key event was generated.
    var metaKey = false

    ## Returns a Boolean that is true if the Shift key was active when the key event was generated.
    var shiftKey = false


## Read the next key input
proc readTerminalInput*() : KeyboardEvent =

    # Create new event
    let event = KeyboardEvent.init()

    # Check OS
    when defined(windows):

        # Get handle to terminal
        let fd = getStdHandle(STD_INPUT_HANDLE)
        var keyEvent = KEY_EVENT_RECORD()
        var numRead: cint = 0

        # Read input
        while true:

            # Read it
            let success = readConsoleInput(fd, addr keyEvent, 1, addr numRead) != 0
            if not success or numRead == 0:
                raiseAssert("Unable to read from the terminal.")

            # Skip events unrelated to the keyboard
            if keyEvent.eventType != 1:
                continue

            # Skip key UP events, we only want key DOWN
            if keyEvent.bKeyDown == 0:
                continue
            
            # We can use this event
            break

        # Process control keys
        var event = KeyboardEvent.init()
        if bitand(keyEvent.dwControlKeyState, 0x0001) != 0: event.altKey = true     # <-- RIGHT_ALT_PRESSED 
        if bitand(keyEvent.dwControlKeyState, 0x0002) != 0: event.altKey = true     # <-- LEFT_ALT_PRESSED 
        if bitand(keyEvent.dwControlKeyState, 0x0004) != 0: event.ctrlKey = true    # <-- RIGHT_CTRL_PRESSED  
        if bitand(keyEvent.dwControlKeyState, 0x0008) != 0: event.ctrlKey = true    # <-- LEFT_CTRL_PRESSED  
        if bitand(keyEvent.dwControlKeyState, 0x0010) != 0: event.shiftKey = true   # <-- SHIFT_PRESSED   

        # Process character code
        event.key = $char(keyEvent.uChar)

        # Read virtual key code for control keys
        if keyEvent.wVirtualKeyCode == 0x08: event.key = "Backspace"                # <-- VK_BACK
        if keyEvent.wVirtualKeyCode == 0x09: event.key = "Tab"                      # <-- VK_TAB
        if keyEvent.wVirtualKeyCode == 0x0C: event.key = "Clear"                    # <-- VK_CLEAR
        if keyEvent.wVirtualKeyCode == 0x0D: event.key = "Enter"                    # <-- VK_RETURN
        if keyEvent.wVirtualKeyCode == 0x10: event.key = "Shift"                    # <-- VK_SHIFT
        if keyEvent.wVirtualKeyCode == 0x11: event.key = "Control"                  # <-- VK_CONTROL
        if keyEvent.wVirtualKeyCode == 0x12: event.key = "Alt"                      # <-- VK_MENU
        if keyEvent.wVirtualKeyCode == 0x14: event.key = "CapsLock"                 # <-- VK_CAPITAL
        if keyEvent.wVirtualKeyCode == 0x1B: event.key = "Escape"                   # <-- VK_ESCAPE
        if keyEvent.wVirtualKeyCode == 0x25: event.key = "ArrowLeft"                # <-- VK_LEFT
        if keyEvent.wVirtualKeyCode == 0x26: event.key = "ArrowUp"                  # <-- VK_UP
        if keyEvent.wVirtualKeyCode == 0x27: event.key = "ArrowRight"               # <-- VK_RIGHT
        if keyEvent.wVirtualKeyCode == 0x28: event.key = "ArrowDown"                # <-- VK_DOWN
        if keyEvent.wVirtualKeyCode == 0x2E: event.key = "Delete"                   # <-- VK_DELETE


    else:

        # Get first code
        let chr1 = getch()
        if chr1.int == 27:

            # Keyboard control command, this next char should be '['
            let chr2 = getch()

            # Next should be the arrow direction
            let chr3 = getch()
            if chr3 == 'A': event.key = "ArrowUp"
            if chr3 == 'B': event.key = "ArrowDown"
            if chr3 == 'C': event.key = "ArrowRight"
            if chr3 == 'D': event.key = "ArrowLeft"

        elif chr1.int == 127:

            # Enter key
            event.key = "Backspace"

        elif chr1.int == 13:

            # Enter key
            event.key = "Enter"

        elif chr1.int > 31:

            # Normal key
            event.key = $chr1


    # Done
    return event