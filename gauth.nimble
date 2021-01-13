# Package

version       = "0.2.0"
author        = "nick133"
description   = "Google TOTP Authentificator for command line"
license       = "MIT"
srcDir        = "src"
bin           = @["gauth"]

# Dependencies

requires "nim >= 1.4.2", "otp"

task release, "Build stripped release":
  selfExec("c --passC:-fpic --passC:-fpie --gc:orc -d:release -d:strip " & srcDir & "/gauth.nim")
