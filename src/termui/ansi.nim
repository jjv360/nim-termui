# https://github.com/molnarmark/colorize
const ansiResetStyle* = "\e[0m"

# foreground colors
const ansiForegroundRed* = "\e[31m"
const ansiForegroundGreen* = "\e[32m"
const ansiForegroundYellow* = "\e[33m"
const ansiForegroundDarkGray* = "\e[90m"
const ansiForegroundLightGreen* = "\e[92m"
const ansiForegroundLightBlue* = "\e[94m"
# proc fgRed*(s: string): string = "\e[31m" & s & reset()
# proc fgBlack*(s: string): string = "\e[30m" & s & reset()
# proc fgGreen*(s: string): string= "\e[32m" & s & reset()
# proc fgYellow*(s: string): string= "\e[33m" & s & reset()
# proc fgBlue*(s: string): string= "\e[34m" & s & reset()
# proc fgMagenta*(s: string): string= "\e[35m" & s & reset()
# proc fgCyan*(s: string): string= "\e[36m" & s & reset()
# proc fgLightGray*(s: string): string= "\e[37m" & s & reset()
# proc fgDarkGray*(s: string): string= "\e[90m" & s & reset()
# proc fgLightRed*(s: string): string= "\e[91m" & s & reset()
# proc fgLightGreen*(s: string): string= "\e[92m" & s & reset()
# proc fgLightYellow*(s: string): string= "\e[93m" & s & reset()
# proc fgLightBlue*(s: string): string= "\e[94m" & s & reset()
# proc fgLightMagenta*(s: string): string= "\e[95m" & s & reset()
# proc fgLightCyan*(s: string): string= "\e[96m" & s & reset()
# proc fgWhite*(s: string): string= "\e[97m" & s & reset()

# # background colors
# proc bgBlack*(s: string): string= "\e[40m" & s & reset()
# proc bgRed*(s: string): string= "\e[41m" & s & reset()
# proc bgGreen*(s: string): string= "\e[42m" & s & reset()
# proc bgYellow*(s: string): string= "\e[43m" & s & reset()
# proc bgBlue*(s: string): string= "\e[44m" & s & reset()
# proc bgMagenta*(s: string): string= "\e[45m" & s & reset()
# proc bgCyan*(s: string): string= "\e[46m" & s & reset()
# proc bgLightGray*(s: string): string= "\e[47m" & s & reset()
# proc bgDarkGray*(s: string): string= "\e[100m" & s & reset()
# proc bgLightRed*(s: string): string= "\e[101m" & s & reset()
# proc bgLightGreen*(s: string): string= "\e[102m" & s & reset()
# proc bgLightYellow*(s: string): string= "\e[103m" & s & reset()
# proc bgLightBlue*(s: string): string= "\e[104m" & s & reset()
# proc bgLightMagenta*(s: string): string= "\e[105m" & s & reset()
# proc bgLightCyan*(s: string): string= "\e[106m" & s & reset()
# proc bgWhite*(s: string): string= "\e[107m" & s & reset()

# # formatting functions
const ansiBold* = "\e[1m"
const ansiUnderline* = "\e[2m"
# proc bold*(s: string): string= "\e[1m" & s & reset()
# proc underline*(s: string): string= "\e[4m" & s & reset()
# proc hidden*(s: string): string= "\e[8m" & s & reset()
# proc invert*(s: string): string= "\e[7m" & s & reset()

# cursor control
proc ansiMoveCursorToBeginningOfLine*() : string = "\r"
proc ansiMoveCursorUp*(numLines : int = 1) : string = "\e[" & $numLines & "A"
proc ansiMoveCursorDown*(numLines : int = 1) : string = "\e[" & $numLines & "B"
proc ansiMoveCursorRight*(numColumns : int = 1) : string = "\e[" & $numColumns & "C"
proc ansiMoveCursorLeft*(numColumns : int = 1) : string = "\e[" & $numColumns & "D"
proc ansiSaveCursorPosition*() : string = "\e[s"
proc ansiRestoreCursorPosition*() : string = "\e[u"
proc ansiEraseLine*() : string = "\e[2K" & ansiMoveCursorToBeginningOfLine()



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
proc enableAnsiOnWindowsConsole*() =

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