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
    GdbDebug,
    StaticLib,
    NoNimTraces,
    FullDeps
    CppBuild

proc build(filename: string; features: set[Features] = {}) =
  var (_, name, _) = splitFile(filename)
  var cmd = "nim "
  if CppBuild in features:
    cmd &= " cpp "
  else:
    cmd &= " c "
  cmd &= " --gc:arc"
  if Release in features:
    cmd &= " -d:danger "
  if Run in features:
    cmd &= " --passL:-lstdc++ "
    cmd &= " -r --passL:-L../chainblocks/build --passL:-lcb_static "
    cmd &= """ --passL:../chainblocks/deps/snappy/build/libsnappy.a """
    when defined windows:
      cmd &= " --passL:-fuse-ld=lld "
      cmd &= """ --passL:"-lboost_context-mt -lboost_filesystem-mt -lntdll -lOle32 -lImm32 -lWinmm -lGdi32 -lVersion -lOleAut32 -lSetupAPI -lPsapi -lD3D11 -lDXGI -lws2_32" """
      if FullDeps in features:
        cmd &= """ --passL:../chainblocks/deps/bimg/.build/win64_mingw-gcc/bin/libbimgRelease.a """
        cmd &= """ --passL:../chainblocks/external/SDL2-2.0.10/x86_64-w64-mingw32/lib/libSDL2.a """
    elif defined linux:
      cmd &= """ --passL:"-lboost_context -pthread -ldl -lrt" """
    elif defined osx:
      cmd &= " --passL:-L/usr/local/lib "
      cmd &= " --passL:-lboost_context-mt "
      if FullDeps in features:
        cmd &= """ --passL:"-framework Foundation" """
        cmd &= """ --passL:"-framework Cocoa" """
        cmd &= """ --passL:"-framework CoreAudio" """
        cmd &= """ --passL:"-framework AudioToolbox" """
        cmd &= """ --passL:"-framework CoreVideo" """
        cmd &= """ --passL:"-framework ForceFeedback" """
        cmd &= """ --passL:"-framework IOKit" """
        cmd &= """ --passL:"-framework Carbon" """
        cmd &= """ --passL:"-framework QuartzCore" """
        cmd &= """ --passL:"-framework Metal" """
        cmd &= """ --passL:../chainblocks/deps/bimg/.build/osx64_clang/bin/libbimgRelease.a """
        cmd &= """ --passL:../chainblocks/external/SDL2-2.0.10/build/libSDL2.a """
        cmd &= " --passL:-liconv "
  if StaticLib in features:
    cmd &= " --app:staticlib -d:auto_nim_main --noMain -o:" & name & ".a "
  if Test in features:
    cmd &= " -d:testing "
  if GdbDebug in features:
    cmd &= " --passC:-g "
  elif Release notin features:
    cmd &= " --debugger:native "
  if NoNimTraces in features:
    cmd &= " -d:noSignalHandler --stackTrace:off --lineTrace:off "
  cmd &= filename
  exec cmd

task compile, "Build all":
  build "src/chainblocks.nim"

task test, "Build all":
  build "src/chainblocks.nim", {Run, Test}

task testcpp, "Build all":
  build "src/chainblocks.nim", {Run, Test, CppBuild}

task testfull, "Build all":
  build "src/chainblocks.nim", {Run, Test, FullDeps}

task gdb, "Build all":
  build "src/chainblocks.nim", {Run, Test, GdbDebug}

task libs, "Build static libs":
  build "src/chainblocks.nim", {StaticLib}
