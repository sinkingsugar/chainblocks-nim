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

import os

type
  Features = enum
    None,
    Run,
    Test,
    Release,
    CDebug,
    StaticLib

proc build(filename: string; features: set[Features] = {}) =
  var (_, name, _) = splitFile(filename)
  var cmd = "nim cpp --gc:arc -d:noSignalHandler --stackTrace:off --lineTrace:off"
  if Release in features:
    cmd &= " -d:danger "
  if Run in features:
    cmd &= " -r "
  if StaticLib in features:
    cmd &= " --app:staticlib -d:auto_nim_main --noMain -o:" & name & ".a "
  if Test in features:
    cmd &= " -d:test_block "
  if CDebug in features:
    cmd &= " --passC:-g "
  cmd &= filename
  exec cmd

task compile, "Build all":
  build "src/chainblocks.nim"

task test, "Build all":
  build "src/chainblocks.nim", {StaticLib, Test, CDebug}

task libs, "Build static libs":
  build "src/chainblocks.nim", {StaticLib}
