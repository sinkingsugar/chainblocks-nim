import nimline
import os, macros

const
  modulePath = currentSourcePath().splitPath().head
cppincludes(modulePath & "/../../chainblocks/include")
cppincludes(modulePath & "/../../chainblocks/src/core")
cppincludes(modulePath & "/../../chainblocks/deps/easyloggingpp/src")
cppincludes(modulePath & "/../../chainblocks/deps/nameof/include")
cppincludes(modulePath & "/../../chainblocks/deps/magic_enum/include")
{.passC: "-std=c++17".}

type
  CBInt* {.importcpp: "CBInt", header: "chainblocks.hpp", nodecl.} = int64
  CBInt2* {.importcpp: "CBInt2", header: "chainblocks.hpp".} = object
  CBInt3* {.importcpp: "CBInt3", header: "chainblocks.hpp".} = object 
  CBInt4* {.importcpp: "CBInt4", header: "chainblocks.hpp".} = object 
  CBInt8* {.importcpp: "CBInt8", header: "chainblocks.hpp".} = object 
  CBInt16* {.importcpp: "CBInt16", header: "chainblocks.hpp".} = object 
  CBFloat* {.importcpp: "CBFloat", header: "chainblocks.hpp".} = float64
  CBFloat2* {.importcpp: "CBFloat2", header: "chainblocks.hpp".} = object 
  CBFloat3* {.importcpp: "CBFloat3", header: "chainblocks.hpp".} = object 
  CBFloat4* {.importcpp: "CBFloat4", header: "chainblocks.hpp".} = object 
  CBColor* {.importcpp: "CBColor", header: "chainblocks.hpp".} = object
    r*,g*,b*,a*: uint8
  CBPointer* {.importcpp: "CBPointer", header: "chainblocks.hpp".} = pointer
  CBString* {.importcpp: "CBString", header: "chainblocks.hpp".} = distinct cstring
  CBSeq* {.importcpp: "CBSeq", header: "chainblocks.hpp".} = object
    elements: ptr UncheckedArray[CBVar]
    len: int32
    cap: int32
  CBTable* {.importcpp: "CBTable", header: "chainblocks.hpp".} = object
    opaque: pointer
    api: pointer # TODO
  CBStrings* {.importcpp: "CBStrings", header: "chainblocks.hpp".} = object
    elements: ptr UncheckedArray[CBString]
    len: int32
    cap: int32
  CBEnum* {.importcpp: "CBEnum", header: "chainblocks.hpp".} = distinct int32

  
  CBChain* {.importcpp: "CBChain", header: "chainblocks.hpp".} = object
  CBChainPtr* = ptr CBChain

  CBNode* {.importcpp: "CBNode", header: "chainblocks.hpp".} = object

  CBContextObj* {.importcpp: "CBContext", header: "chainblocks.hpp".} = object
  CBContext* = ptr CBContextObj

  CBEnumInfo* {.importcpp: "CBEnumInfo", header: "chainblocks.hpp".} = object
    name*: cstring
    labels*: CBStrings

  CBImage* {.importcpp: "CBImage", header: "chainblocks.hpp".} = object
    width*: uint16
    height*: uint16
    channels*: uint8
    flags*: uint8
    data*: ptr UncheckedArray[uint8]

  CBType* {.importcpp: "CBType", header: "chainblocks.hpp", size: sizeof(uint8).} = enum
      None,
      Any,
      Object,
      Enum,
      Bool,
      Int,        # A 64bits int
      Int2,       # A vector of 2 64bits ints
      Int3,       # A vector of 3 32bits ints
      Int4,       # A vector of 4 32bits ints
      Int8,       # A vector of 8 16bits ints
      Int16,      # A vector of 16 8bits ints
      Float,      # A 64bits float
      Float2,     # A vector of 2 64bits floats
      Float3,     # A vector of 3 32bits floats
      Float4,     # A vector of 4 32bits floats
      Color,      # A vector of 4 uint8
      Chain,      # sub chains, e.g. IF/ELSE
      Block,      # a block, useful for future introspection blocks!
      StackIndex, # an index in the stack, used as cheap ContextVar
      
      EndOfBlittableTypes = 50, # anything below this is not blittable (not exactly
                                # but for cloneVar mostly)
      
      Bytes, # pointer + size
      String,
      Path,       # An OS filesystem path
      ContextVar, # A string label to find from CBContext variables
      Image,
      Seq,
      Table,
      
  CBTypeInfo* {.importcpp: "CBTypeInfo", header: "chainblocks.hpp".} = object
    basicType*: CBType
    seqTypes*: CBTypesInfo

  CBTypesInfo* {.importcpp: "CBTypesInfo", header: "chainblocks.hpp".} = object
    elements: ptr UncheckedArray[CBTypeInfo]
    len: int32
    cap: int32

  CBObjectInfo* {.importcpp: "CBObjectInfo", header: "chainblocks.hpp".} = object
    name*: cstring

  CBParameterInfo* {.importcpp: "CBParameterInfo", header: "chainblocks.hpp".} = object
    name*: cstring
    valueTypes*: CBTypesInfo
    help*: cstring
  
  CBParametersInfo* {.importcpp: "CBParametersInfo", header: "chainblocks.hpp".} = object
    elements: ptr UncheckedArray[CBParameterInfo]
    len: int32
    cap: int32

  CBExposedTypeInfo* {.importcpp: "CBExposedTypeInfo", header: "chainblocks.hpp".} = object
    name*: cstring
    help*: cstring
    exposedType*: CBTypeInfo

  CBExposedTypesInfo* {.importcpp: "CBExposedTypesInfo", header: "chainblocks.hpp".} = object
    elements: ptr UncheckedArray[CBExposedTypeInfo]
    len: int32
    cap: int32

  CBValidationResult* {.importcpp: "CBValidationResult", header: "chainblocks.hpp".} = object
    outputType*: CBTypeInfo
    exposedInfo*: CBExposedTypesInfo
  
  CBChainState* {.importcpp: "CBChainState", header: "chainblocks.hpp".} = enum
    Continue, # Even if None returned, continue to next block
    Restart, # Restart the chain from the top
    Stop # Stop the chain execution

  CBVarPayload* {.importcpp: "CBVarPayload", header: "chainblocks.hpp".} = object
    chainState*: CBChainState
    objectValue*: CBPointer
    objectVendorId*: int32
    objectTypeId*: int32
    boolValue*: bool
    intValue*: CBInt
    int2Value*: CBInt2
    int3Value*: CBInt3
    int4Value*: CBInt4
    int8Value*: CBInt8
    int16Value*: CBInt16
    floatValue*: CBFloat
    float2Value*: CBFloat2
    float3Value*: CBFloat3
    float4Value*: CBFloat4
    stringValue*: CBString
    colorValue*: CBColor
    imageValue*: CBImage
    seqValue*: CBSeq
    tableValue*: CBTable
    chainValue*: CBChainPtr
    blockValue*: ptr CBlock
    enumValue*: CBEnum
    enumVendorId*: int32
    enumTypeId*: int32

  CBVar* {.importc: "CBVar", header: "chainblocks.hpp".} = object
    payload*: CBVarPayload
    valueType*: CBType

  CBVarConst* = object
    value*: CBVar

  CBNameProc* {.importcpp: "CBNameProc", header: "chainblocks.hpp".} = proc(b: ptr CBlock): cstring {.cdecl.}
  CBHelpProc* {.importcpp: "CBHelpProc", header: "chainblocks.hpp".} = proc(b: ptr CBlock): cstring {.cdecl.}

  CBSetupProc* {.importcpp: "CBSetupProc", header: "chainblocks.hpp".} = proc(b: ptr CBlock) {.cdecl.}
  CBDestroyProc* {.importcpp: "CBDestroyProc", header: "chainblocks.hpp".} = proc(b: ptr CBlock) {.cdecl.}

  CBPreChainProc* {.importcpp: "CBPreChainProc", header: "chainblocks.hpp".} = proc(b: ptr CBlock; context: CBContext) {.cdecl.}
  CBPostChainProc* {.importcpp: "CBPostChainProc", header: "chainblocks.hpp".} = proc(b: ptr CBlock; context: CBContext) {.cdecl.}

  CBInputTypesProc*{.importcpp: "CBInputTypesProc", header: "chainblocks.hpp".}  = proc(b: ptr CBlock): CBTypesInfo {.cdecl.}
  CBOutputTypesProc* {.importcpp: "CBOutputTypesProc", header: "chainblocks.hpp".} = proc(b: ptr CBlock): CBTypesInfo {.cdecl.}

  CBExposedVariablesProc* {.importcpp: "CBExposedVariablesProc", header: "chainblocks.hpp".} = proc(b: ptr CBlock): CBExposedTypesInfo {.cdecl.}
  CBRequiredVariablesProc* {.importcpp: "CBRequiredVariablesProc", header: "chainblocks.hpp".} = proc(b: ptr CBlock): CBExposedTypesInfo {.cdecl.}

  CBParametersProc* {.importcpp: "CBParametersProc", header: "chainblocks.hpp".} = proc(b: ptr CBlock): CBParametersInfo {.cdecl.}
  CBSetParamProc* {.importcpp: "CBSetParamProc", header: "chainblocks.hpp".} = proc(b: ptr CBlock; index: int; val: CBVar) {.cdecl.}
  CBGetParamProc* {.importcpp: "CBGetParamProc", header: "chainblocks.hpp".} = proc(b: ptr CBlock; index: int): CBVar {.cdecl.}

  CBInferTypesProc*{.importcpp: "CBInferTypesProc", header: "chainblocks.hpp".}  = proc(b: ptr CBlock; inputType: CBTypeInfo; consumables: CBExposedTypesInfo): CBTypeInfo {.cdecl.}

  CBActivateProc* {.importcpp: "CBActivateProc", header: "chainblocks.hpp".} = proc(b: ptr CBlock; context: CBContext; input: CBVar): CBVar {.cdecl.}
  CBCleanupProc* {.importcpp: "CBCleanupProc", header: "chainblocks.hpp".} = proc(b: ptr CBlock) {.cdecl.}

  CBlock* {.importcpp: "CBlock", header: "chainblocks.hpp".} = object
    inlineBlockId*: uint8
    
    name*: CBNameProc
    help*: CBHelpProc
    
    setup*: CBSetupProc
    destroy*: CBDestroyProc
    
    preChain*: CBPreChainProc
    postChain*: CBPostChainProc
    
    inputTypes*: CBInputTypesProc
    outputTypes*: CBOutputTypesProc
    
    exposedVariables*: CBExposedVariablesProc
    requiredVariables*: CBRequiredVariablesProc
    
    parameters*: CBParametersProc
    setParam*: CBSetParamProc
    getParam*: CBGetParamProc

    inferTypes*: CBInferTypesProc

    activate*: CBActivateProc
    cleanup*: CBCleanupProc

  CBBlockConstructor* {.importcpp: "CBBlockConstructor", header: "chainblocks.hpp".} = proc(): ptr CBlock {.cdecl.}
  CBlocks* {.importcpp: "CBlocks", header: "chainblocks.hpp".} = object
    elements: ptr UncheckedArray[CBlock]
    len: int32
    cap: int32

  CBCallback* {.importcpp: "CBCallback", header: "chainblocks.hpp".} = proc(): void {.cdecl.}

  CBSeqLike* = CBSeq | CBTypesInfo | CBParametersInfo | CBStrings | CBExposedTypesInfo | CBlocks
  CBIntVectorsLike* = CBInt2 | CBInt3 | CBInt4 | CBInt8 | CBInt16
  CBFloatVectorsLike* = CBFloat2 | CBFloat3 | CBFloat4

# when appType != "lib" or defined(forceCBRuntime):
#   proc `~quickcopy`*(clonedVar: var CBVar): int {.importcpp: "chainblocks::destroyVar(#)", header: "runtime.hpp", discardable.}
#   proc quickcopy*(dst: var CBVar; src: var CBvar): int {.importcpp: "chainblocks::cloneVar(#, #)", header: "runtime.hpp", discardable.}
# else:
#   # they exist in chainblocks.nim
#   proc `~quickcopy`*(clonedVar: var CBVar): int {.importc: "cbDestroyVar", cdecl, discardable.}
#   proc quickcopy*(dst: var CBVar; src: var CBvar): int {.importc: "cbCloneVar", cdecl, discardable.}

# proc `=destroy`*(v: var CBVarConst) {.inline.} = discard `~quickcopy` v.value

var AllIntTypes* = { Int, Int2, Int3, Int4, Int8, Int16 }
var AllFloatTypes* = { Float, Float2, Float3, Float4 }

proc suspendInternal(context: CBContext; seconds: float64): CBVar {.importcpp: "chainblocks::suspend(#, #)", header: "runtime.hpp".}
proc suspend*(context: CBContext; seconds: float64): CBVar {.inline.} =
  var frame = getFrameState()
  result = suspendInternal(context, seconds)
  setFrameState(frame)

template chainState*(v: CBVar): auto = v.payload.chainState
template objectValue*(v: CBVar): auto = v.payload.objectValue
template objectVendorId*(v: CBVar): auto = v.payload.objectVendorId
template objectTypeId*(v: CBVar): auto = v.payload.objectTypeId
template boolValue*(v: CBVar): auto = v.payload.boolValue
template intValue*(v: CBVar): auto = v.payload.intValue
template int2Value*(v: CBVar): auto = v.payload.int2Value
template int3Value*(v: CBVar): auto = v.payload.int3Value
template int4Value*(v: CBVar): auto = v.payload.int4Value
template int8Value*(v: CBVar): auto = v.payload.int8Value
template int16Value*(v: CBVar): auto = v.payload.int16Value
template floatValue*(v: CBVar): auto = v.payload.floatValue
template float2Value*(v: CBVar): auto = v.payload.float2Value
template float3Value*(v: CBVar): auto = v.payload.float3Value
template float4Value*(v: CBVar): auto = v.payload.float4Value
template stringValue*(v: CBVar): auto = v.payload.stringValue
template colorValue*(v: CBVar): auto = v.payload.colorValue
template imageValue*(v: CBVar): auto = v.payload.imageValue
template seqValue*(v: CBVar): auto = v.payload.seqValue
template seqLen*(v: CBVar): auto = v.payload.seqLen
template tableValue*(v: CBVar): auto = v.payload.tableValue
template tableLen*(v: CBVar): auto = v.payload.tableLen
template chainValue*(v: CBVar): auto = v.payload.chainValue
template blockValue*(v: CBVar): auto = v.payload.blockValue
template enumValue*(v: CBVar): auto = v.payload.enumValue
template enumVendorId*(v: CBVar): auto = v.payload.enumVendorId
template enumTypeId*(v: CBVar): auto = v.payload.enumTypeId

template valueType*(v: CBVarConst): auto = v.value.valueType
template chainState*(v: CBVarConst): auto = v.value.payload.chainState
template objectValue*(v: CBVarConst): auto = v.value.payload.objectValue
template objectVendorId*(v: CBVarConst): auto = v.value.payload.objectVendorId
template objectTypeId*(v: CBVarConst): auto = v.value.payload.objectTypeId
template boolValue*(v: CBVarConst): auto = v.value.payload.boolValue
template intValue*(v: CBVarConst): auto = v.value.payload.intValue
template int2Value*(v: CBVarConst): auto = v.value.payload.int2Value
template int3Value*(v: CBVarConst): auto = v.value.payload.int3Value
template int4Value*(v: CBVarConst): auto = v.value.payload.int4Value
template int8Value*(v: CBVarConst): auto = v.value.payload.int8Value
template int16Value*(v: CBVarConst): auto = v.value.payload.int16Value
template floatValue*(v: CBVarConst): auto = v.value.payload.floatValue
template float2Value*(v: CBVarConst): auto = v.value.payload.float2Value
template float3Value*(v: CBVarConst): auto = v.value.payload.float3Value
template float4Value*(v: CBVarConst): auto = v.value.payload.float4Value
template stringValue*(v: CBVarConst): auto = v.value.payload.stringValue
template colorValue*(v: CBVarConst): auto = v.value.payload.colorValue
template imageValue*(v: CBVarConst): auto = v.value.payload.imageValue
template seqValue*(v: CBVarConst): auto = v.value.payload.seqValue
template seqLen*(v: CBVarConst): auto = value.v.payload.seqLen
template tableValue*(v: CBVarConst): auto = v.value.payload.tableValue
template tableLen*(v: CBVarConst): auto = v.value.payload.tableLen
template chainValue*(v: CBVarConst): auto = v.value.payload.chainValue
template blockValue*(v: CBVar): auto = v.value.payload.blockValue
template enumValue*(v: CBVarConst): auto = v.value.payload.enumValue
template enumVendorId*(v: CBVarConst): auto = v.value.payload.enumVendorId
template enumTypeId*(v: CBVarConst): auto = v.value.payload.enumTypeId

template `chainState=`*(v: CBVar, val: auto) = v.payload.chainState = val
template `objectValue=`*(v: CBVar, val: auto) = v.payload.objectValue = val
template `objectVendorId=`*(v: CBVar, val: auto) = v.payload.objectVendorId = val
template `objectTypeId=`*(v: CBVar, val: auto) = v.payload.objectTypeId = val
template `boolValue=`*(v: CBVar, val: auto) = v.payload.boolValue = val
template `intValue=`*(v: CBVar, val: auto) = v.payload.intValue = val
template `int2Value=`*(v: CBVar, val: auto) = v.payload.int2Value = val
template `int3Value=`*(v: CBVar, val: auto) = v.payload.int3Value = val
template `int4Value=`*(v: CBVar, val: auto) = v.payload.int4Value = val
template `int8Value=`*(v: CBVar, val: auto) = v.payload.int8Value = val
template `int16Value=`*(v: CBVar, val: auto) = v.payload.int16Value = val
template `floatValue=`*(v: CBVar, val: auto) = v.payload.floatValue = val
template `float2Value=`*(v: CBVar, val: auto) = v.payload.float2Value = val
template `float3Value=`*(v: CBVar, val: auto) = v.payload.float3Value = val
template `float4Value=`*(v: CBVar, val: auto) = v.payload.float4Value = val
template `stringValue=`*(v: CBVar, val: auto) = v.payload.stringValue = val
template `colorValue=`*(v: CBVar, val: auto) = v.payload.colorValue = val
template `imageValue=`*(v: CBVar, val: auto) = v.payload.imageValue = val
template `seqValue=`*(v: CBVar, val: auto) = v.payload.seqValue = val
template `seqLen=`*(v: CBVar, val: auto) = v.payload.seqLen = val
template `tableValue=`*(v: CBVar, val: auto) = v.payload.tableValue = val
template `tableLen=`*(v: CBVar, val: auto) = v.payload.tableLen = val
template `chainValue=`*(v: CBVar, val: auto) = v.payload.chainValue = val
template `blockValue=`*(v: CBVar, val: auto) = v.payload.blockValue = val
template `enumValue=`*(v: CBVar, val: auto) = v.payload.enumValue = val
template `enumVendorId=`*(v: CBVar, val: auto) = v.payload.enumVendorId = val
template `enumTypeId=`*(v: CBVar, val: auto) = v.payload.enumTypeId = val

# registerCppType CBChain
# registerCppType CBNode
# registerCppType CBContextObj
# registerCppType CBInt2
# registerCppType CBInt3
# registerCppType CBInt4
# registerCppType CBInt8
# registerCppType CBInt16
# registerCppType CBFloat2
# registerCppType CBFloat3
# registerCppType CBFloat4

# Make those optional
template help*(b: auto): cstring = ""
template setup*(b: auto) = discard
template destroy*(b: auto) = discard
template exposedVariables*(b: auto): CBExposedTypesInfo = CBExposedTypesInfo()
template requiredVariables*(b: auto): CBExposedTypesInfo = CBExposedTypesInfo()
template parameters*(b: auto): CBParametersInfo = CBParametersInfo()
template setParam*(b: auto; index: int; val: CBVar) = discard
template getParam*(b: auto; index: int): CBVar = CBVar(valueType: None)
template cleanup*(b: auto) = discard

# Allocators using cpp to properly construct in C++ fashion (we have some blocks that need this)
template cppnew*(pt, typ1, typ2: untyped): untyped = emitc(`pt`, " = reinterpret_cast<", `typ1`, "*>(new ", `typ2`, "());")
template cppnew*(pt, typ1, typ2, a1: untyped): untyped = emitc(`pt`, " = reinterpret_cast<", `typ1`, "*>(new ", `typ2`, "(", `a1`, "));")
template cppnew*(pt, typ1, typ2, a1, a2: untyped): untyped = emitc(`pt`, " = reinterpret_cast<", `typ1`, "*>(new ", `typ2`, "(", `a1`, ", ", `a2`, "));")
template cppnew*(pt, typ1, typ2, a1, a2, a3: untyped): untyped = emitc(`pt`, " = reinterpret_cast<", `typ1`, "*>(new ", `typ2`, "(", `a1`, ", ", `a2`, ", ", `a3`, "));")
template cppdel*(pt: untyped): untyped = emitc("delete ", `pt`, ";")

proc registerBlock*(name: cstring; initProc: CBBlockConstructor) {.importcpp: "chainblocks::registerBlock(@)", header: "runtime.hpp".}

macro chainblock*(blk: untyped; blockName: string; namespaceStr: string = ""; testCode: untyped = nil): untyped =
  var
    rtName = ident($blk & "RT")
    rtNameValue = ident($blk & "RTValue")
    macroName {.used.} = ident($blockName)
    namespace = if $namespaceStr != "": $namespaceStr & "." else: ""
    testName {.used.} = ident("test_" & $blk)

    nameProc = ident($blk & "_name")
    helpProc = ident($blk & "_help")

    setupProc = ident($blk & "_setup")
    destroyProc = ident($blk & "_destroy")
    
    preChainProc = ident($blk & "_preChain")
    postChainProc = ident($blk & "_postChain")
    
    inputTypesProc = ident($blk & "_inputTypes")
    outputTypesProc = ident($blk & "_outputTypes")
    
    exposedVariablesProc = ident($blk & "_exposedVariables")
    requiredVariablesProc = ident($blk & "_requiredVariables")
    
    parametersProc = ident($blk & "_parameters")
    setParamProc = ident($blk & "_setParam")
    getParamProc = ident($blk & "_getParam")
    
    inferTypesProc = ident($blk & "_inferTypes")
    
    activateProc = ident($blk & "_activate")
    cleanupProc = ident($blk & "_cleanup")
  
  result = quote do:
    # import macros # used!
    
    type
      `rtNameValue` = object
        pre: CBlock
        sb: `blk`
      
      `rtName`* = ptr `rtNameValue`
    
    template name*(b: `blk`): string =
      (`namespace` & `blockName`)
    proc `nameProc`*(b: `rtName`): cstring {.cdecl.} =
      (`namespace` & `blockName`)
    proc `helpProc`*(b: `rtName`): cstring {.cdecl.} =
      b.sb.help()
    proc `setupProc`*(b: `rtName`) {.cdecl.} =
      b.sb.setup()
    proc `destroyProc`*(b: `rtName`) {.cdecl.} =
      b.sb.destroy()
      cppdel(b)
    proc `inputTypesProc`*(b: `rtName`): CBTypesInfo {.cdecl.} =
      b.sb.inputTypes()
    proc `outputTypesProc`*(b: `rtName`): CBTypesInfo {.cdecl.} =
      b.sb.outputTypes()
    proc `exposedVariablesProc`*(b: `rtName`): CBExposedTypesInfo {.cdecl.} =
      b.sb.exposedVariables()
    proc `requiredVariablesProc`*(b: `rtName`): CBExposedTypesInfo {.cdecl.} =
      b.sb.requiredVariables()
    proc `parametersProc`*(b: `rtName`): CBParametersInfo {.cdecl.} =
      b.sb.parameters()
    proc `setParamProc`*(b: `rtName`; index: int; val: CBVar) {.cdecl.} =
      b.sb.setParam(index, val)
    proc `getParamProc`*(b: `rtName`; index: int): CBVar {.cdecl.} =
      b.sb.getParam(index)
    proc `activateProc`*(b: `rtName`; context: CBContext; input: CBVar): CBVar {.cdecl.} =
      try:
        b.sb.activate(context, input)
      except:
        echo getCurrentExceptionMsg()
        raise
    proc `cleanupProc`*(b: `rtName`) {.cdecl.} =
      b.sb.cleanup()
    
    registerBlock(`namespace` & `blockName`) do -> ptr CBlock {.cdecl.}:
      # https://stackoverflow.com/questions/7546620/operator-new-initializes-memory-to-zero
      # Memory will be memset to 0x0, because we call T()
      cppnew(result, CBlock, `rtNameValue`)
      # DO NOT CHANGE THE FOLLOWING, this sorcery is needed to build with msvc 19ish
      # Moreover it's kinda nim's fault, as it won't generate a C cast without `.pointer`
      result.name = cast[CBNameProc](`nameProc`.pointer)
      result.help = cast[CBHelpProc](`helpProc`.pointer)
      result.setup = cast[CBSetupProc](`setupProc`.pointer)
      result.destroy = cast[CBDestroyProc](`destroyProc`.pointer)
      
      # pre post are optional!
      when compiles((var x: `blk`; x.preChain(nil))):
        result.preChain = cast[CBPreChainProc](`preChainProc`.pointer)
      when compiles((var x: `blk`; x.postChain(nil))):
        result.postChain = cast[CBPostChainProc](`postChainProc`.pointer)
      
      result.inputTypes = cast[CBInputTypesProc](`inputTypesProc`.pointer)
      result.outputTypes = cast[CBOutputTypesProc](`outputTypesProc`.pointer)
      result.exposedVariables = cast[CBExposedVariablesProc](`exposedVariablesProc`.pointer)
      result.requiredVariables = cast[CBRequiredVariablesProc](`requiredVariablesProc`.pointer)
      result.parameters = cast[CBParametersProc](`parametersProc`.pointer)
      result.setParam = cast[CBSetParamProc](`setParamProc`.pointer)
      result.getParam = cast[CBGetParamProc](`getParamProc`.pointer)
      
      when compiles((var x: `blk`; discard x.inferTypes(CBTypeInfo(), nil))):
        result.inferTypes = cast[CBInferTypesProc](`inferTypesProc`.pointer)
      
      result.activate = cast[CBActivateProc](`activateProc`.pointer)
      result.cleanup = cast[CBCleanupProc](`cleanupProc`.pointer)

when isMainModule or defined(test_block):
  var v: CBVar
  echo v

  type
    CBPow2Block = object
      inputValue: float
      params: array[1, CBVar]
  
  proc inputTypes*(b: var CBPow2Block): CBTypesInfo = CBTypesInfo()
  proc outputTypes*(b: var CBPow2Block): CBTypesInfo = CBTypesInfo()
  proc parameters*(b: var CBPow2Block): CBParametersInfo = CBParametersInfo()
  proc setParam*(b: var CBPow2Block; index: int; val: CBVar) = b.params[0] = val
  proc getParam*(b: var CBPow2Block; index: int): CBVar = b.params[0]
  proc activate*(b: var CBPow2Block; context: CBContext; input: CBVar): CBVar =
    echo "Yes nim..."
    CBVar()

  chainblock CBPow2Block, "Pow2StaticBlock"
  
# var
#   Empty* = CBVar(valueType: None, payload: CBVarPayload(chainState: Continue))
#   RestartChain* = CBVar(valueType: None, payload: CBVarPayload(chainState: Restart))
#   StopChain* = CBVar(valueType: None, payload: CBVarPayload(chainState: Stop))

# # Vectors
# proc `[]`*(v: CBIntVectorsLike; index: int): int64 {.inline, noinit.} = v.toCpp[index].to(int64)
# proc `[]=`*(v: var CBIntVectorsLike; index: int; value: int64) {.inline.} = v.toCpp[index] = value
# proc `[]`*(v: CBFloatVectorsLike; index: int): float64 {.inline, noinit.} = v.toCpp[index].to(float64)
# proc `[]=`*(v: var CBFloatVectorsLike; index: int; value: float64) {.inline.} = v.toCpp[index] = value

# # CBTable
# proc initTable*(t: var CBTable) {.inline.} =
#   t = nil
#   invokeFunction("stbds_shdefault", t, Empty).to(void)
# proc freeTable*(t: var CBTable) {.inline.} = invokeFunction("stbds_shfree", t).to(void)
# proc len*(t: CBTable): int {.inline.} = invokeFunction("stbds_shlen", t).to(int)
# iterator mitems*(t: CBTable): var CBNamedVar {.inline.} =
#   for i in 0..<t.len:
#     yield t[i]
# proc incl*(t: var CBTable; pair: CBNamedVar) {.inline.} = invokeFunction("stbds_shputs", t, pair).to(void)
# proc incl*(t: var CBTable; k: cstring; v: CBVar) {.inline.} = invokeFunction("stbds_shput", t, k, v).to(void)
# proc excl*(t: CBTable; key: cstring) {.inline.} = invokeFunction("stbds_shdel", t, key).to(void)
# proc find*(t: CBTable; key: cstring): int {.inline.} = invokeFunction("stbds_shgeti", t, key).to(int)
# converter toCBVar*(t: CBTable): CBVar {.inline.} = CBVar(valueType: Table, payload: CBVarPayload(tableValue: t))

# # CBSeqLikes
# proc initSeq*(s: var CBSeqLike) {.inline.} = s = nil
# proc freeSeq*(cbs: var CBSeqLike) {.inline.} = invokeFunction("stbds_arrfree", cbs).to(void)
# proc freeSeq*(cbs: var CBSeq) {.inline.} = invokeFunction("stbds_arrfree", cbs).to(void)
# proc len*(s: CBSeqLike): int {.inline.} = invokeFunction("stbds_arrlen", s).to(int)
# iterator mitems*(s: CBSeq): var CBVar {.inline.} =
#   for i in 0..<s.len:
#     yield s[i]
# iterator mitems*(s: CBTypesInfo): var CBTypeInfo {.inline.} =
#   for i in 0..<s.len:
#     yield s[i]
# iterator mitems*(s: CBParametersInfo): var CBParameterInfo {.inline.} =
#   for i in 0..<s.len:
#     yield s[i]
# iterator mitems*(s: CBStrings): var CBString {.inline.} =
#   for i in 0..<s.len:
#     yield s[i]
# iterator mitems*(s: CBExposedTypesInfo): var CBExposedTypeInfo {.inline.} =
#   for i in 0..<s.len:
#     yield s[i]
# proc push*[T](cbs: var CBSeqLike, val: T) {.inline.} = invokeFunction("stbds_arrpush", cbs, val).to(void)
# proc push*(cbs: var CBExposedTypesInfo, val: CBExposedTypeInfo) {.inline.} = invokeFunction("stbds_arrpush", cbs, val).to(void)
# proc push*(cbs: var CBSeq, val: CBVar) {.inline.} = invokeFunction("stbds_arrpush", cbs, val).to(void)
# proc pop*(cbs: var CBSeq): CBVar {.inline.} = invokeFunction("stbds_arrpop", cbs).to(CBVar)
# proc clear*(cbs: var CBSeqLike) {.inline.} = invokeFunction("stbds_arrsetlen", cbs, 0).to(void)
# proc clear*(cbs: var CBSeq) {.inline.} = invokeFunction("stbds_arrsetlen", cbs, 0).to(void)
# proc setLen*(cbs: var CBSeq; newLen: int) {.inline.} = invokeFunction("stbds_arrsetlen", cbs, newLen).to(void)
# iterator items*(s: CBParametersInfo): CBParameterInfo {.inline.} =
#   for i in 0..<s.len:
#     yield s[i]
# iterator items*(s: CBSeq): CBVar {.inline.} =
#   for i in 0..<s.len:
#     yield s[i]
# iterator items*(s: CBStrings): CBString {.inline.} =
#   for i in 0..<s.len:
#     yield s[i]
# proc `~@`*[IDX, CBVar](a: array[IDX, CBVar]): CBSeq =
#   initSeq(result)
#   for v in a:
#     result.push v

# # Strings
# proc toCBStrings*(strings: var StbSeq[cstring]): CBStrings {.inline.} =
#   # strings must be kept alive!
#   initSeq(result)
#   for str in strings.mitems:
#     result.push(str)

# proc `$`*(s: CBString): string {.inline.} = $cast[cstring](s)
# converter toString*(s: CBString): string {.inline.} = $s.cstring
# converter toString*(s: string): CBString {.inline.} = s.cstring.CBString
# converter toStringVar*(s: string): CBVar {.inline.} =
#   result.valueType = String
#   result.payload.stringValue = s.cstring.CBString

# converter toCBVar*(s: GbString): CBVar {.inline.} =
#   result.valueType = String
#   result.payload.stringValue = s.cstring.CBString

# converter toCBString*(s: GbString): CBString {.inline.} = s.cstring.CBString
# converter toGbString*(s: CBString): GbString {.inline.} = s.cstring.GbString

# # Allocators using cpp to properly construct in C++ fashion (we have some blocks that need this)
# template cppnew*(pt, typ1, typ2: untyped): untyped = emitc(`pt`, " = reinterpret_cast<", `typ1`, "*>(new ", `typ2`, "());")
# template cppnew*(pt, typ1, typ2, a1: untyped): untyped = emitc(`pt`, " = reinterpret_cast<", `typ1`, "*>(new ", `typ2`, "(", `a1`, "));")
# template cppnew*(pt, typ1, typ2, a1, a2: untyped): untyped = emitc(`pt`, " = reinterpret_cast<", `typ1`, "*>(new ", `typ2`, "(", `a1`, ", ", `a2`, "));")
# template cppnew*(pt, typ1, typ2, a1, a2, a3: untyped): untyped = emitc(`pt`, " = reinterpret_cast<", `typ1`, "*>(new ", `typ2`, "(", `a1`, ", ", `a2`, ", ", `a3`, "));")
# template cppdel*(pt: untyped): untyped = emitc("delete ", `pt`, ";")
