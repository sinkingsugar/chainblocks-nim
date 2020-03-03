# Package

version       = "0.1.0"
author        = "Giovanni Petrantoni"
description   = "Chainblocks nim bridge"
license       = "BSD-3-Clause"
srcDir        = "src"

backend       = "cpp"

# Dependencies

requires "nim >= 1.0.6"
requires "nimline >= 0.1.7"

import src/chainblocks/buildtools

task compile, "Build all":
  exec build("src/chainblocks.nim")

task test, "Build all":
  exec build("src/chainblocks.nim", {Run, Test})

task testcpp, "Build all":
  exec build("src/chainblocks.nim", {Run, Test, CppBuild})

task testfull, "Build all":
  exec build("src/chainblocks.nim", {Run, Test, FullDeps})

task gdb, "Build all":
  exec build("src/chainblocks.nim", {Run, Test, GdbDebug})

task libs, "Build static libs":
  exec build("src/chainblocks.nim", {StaticLib})
