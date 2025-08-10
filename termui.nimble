# Package

version       = "0.1.10"
author        = "jjv360"
description   = "Simple UI components for the terminal."
license       = "MIT"
srcDir        = "src"
installExt    = @["nim"]


# Dependencies

requires "nim >= 1.4.4"
requires "classes >= 0.3.17"
requires "elvis >= 0.5.0"


# Note: Since these tests require user input, we can't use the normal `nimble test` command
task test, "Test": 
    exec "nim compile --run tests/test.nim"