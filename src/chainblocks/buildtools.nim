import os

const
  modulePath = currentSourcePath().splitPath().head
  cbpath = modulePath & "/../../../chainblocks"
  cblibpath = modulePath & "/../../../chainblocks/build"
  cblibpathEnv = getenv("CB_LIB_PATH")

type
  Features* = enum
    None,
    Run,
    Test,
    Release,
    CDebug,
    StaticLib,
    NoNimTraces,
    FullDeps
    CppBuild
    Trace

proc build*(filename: string; features: set[Features] = {}): string =
  var (_, name, _) = splitFile(filename)
  var cmd = "nim "
  if CppBuild in features:
    cmd &= " cpp "
  else:
    cmd &= " c "
  cmd &= " --gc:arc"
  if Release in features:
    cmd &= " -d:danger "
  if Trace in features:
    cmd &= " -d:TRACE "
  if Run in features:
    cmd &= " --passL:-lstdc++ "
    if cblibpathEnv.len > 0:
      cmd &= " -r --passL:-L" & cblibpathEnv & " --passL:-lcb_static "
    else:
      cmd &= " -r --passL:-L" & cblibpath & " --passL:-lcb_static "
    cmd &= """ --passL:""" & cbpath & """/deps/snappy/build/libsnappy.a """
    when defined windows:
      cmd &= " --passL:-fuse-ld=lld "
      cmd &= """ --passL:"-lboost_context-mt -lboost_filesystem-mt -lntdll -lOle32 -lImm32 -lWinmm -lGdi32 -lVersion -lOleAut32 -lSetupAPI -lPsapi -lD3D11 -lDXGI -lws2_32" """
      if FullDeps in features:
        cmd &= """ --passL:""" & cbpath & """/deps/bimg/.build/win64_mingw-gcc/bin/libbimgRelease.a """
        cmd &= """ --passL:""" & cbpath & """/external/SDL2-2.0.10/x86_64-w64-mingw32/lib/libSDL2.a """
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
        cmd &= """ --passL:""" & cbpath & """/deps/bimg/.build/osx64_clang/bin/libbimgRelease.a """
        cmd &= """ --passL:""" & cbpath & """/external/SDL2-2.0.10/build/libSDL2.a """
        cmd &= " --passL:-liconv "
  if StaticLib in features:
    cmd &= " --app:staticlib -d:auto_nim_main --noMain -o:" & name & ".a "
  if Test in features:
    cmd &= " -d:testing "
  if CDebug in features:
    cmd &= " --passC:-g "
  elif Release notin features:
    cmd &= " --debugger:native "
  if NoNimTraces in features:
    cmd &= " -d:noSignalHandler --stackTrace:off --lineTrace:off "
  cmd &= filename
  echo cmd
  return cmd
