import nimline
import os, macros, typetraits

const
  modulePath = currentSourcePath().splitPath().head
cppincludes(modulePath & "/../../chainblocks/include")
cppincludes(modulePath & "/../../chainblocks/src/core")
cppincludes(modulePath & "/../../chainblocks/deps/easyloggingpp/src")
cppincludes(modulePath & "/../../chainblocks/deps/nameof/include")
cppincludes(modulePath & "/../../chainblocks/deps/magic_enum/include")
{.passC: "-std=c++17".}

type
  FourCC* = distinct int32
  
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
    elements*: ptr UncheckedArray[CBVar]
    len*: uint32
    cap*: uint32
  CBTable* {.importcpp: "CBTable", header: "chainblocks.hpp".} = object
    opaque: pointer
    api: pointer # TODO
  CBStrings* {.importcpp: "CBStrings", header: "chainblocks.hpp".} = object
    elements*: ptr UncheckedArray[CBString]
    len*: uint32
    cap*: uint32
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

  # exportc to avoid mangling
  ObjectInfo* {.exportc.} = object
    vendorId: uint32
    typeId: uint32
      
  CBTypeInfo* {.importcpp: "CBTypeInfo", header: "chainblocks.hpp".} = object
    basicType*: CBType
    seqTypes*: CBTypesInfo
    `object`*: ObjectInfo

  CBTypesInfo* {.importcpp: "CBTypesInfo", header: "chainblocks.hpp".} = object
    elements*: ptr UncheckedArray[CBTypeInfo]
    len*: uint32
    cap*: uint32

  CBObjectInfo* {.importcpp: "CBObjectInfo", header: "chainblocks.hpp".} = object
    name*: cstring

  CBParameterInfo* {.importcpp: "CBParameterInfo", header: "chainblocks.hpp".} = object
    name*: cstring
    valueTypes*: CBTypesInfo
    help*: cstring
  
  CBParametersInfo* {.importcpp: "CBParametersInfo", header: "chainblocks.hpp".} = object
    elements*: ptr UncheckedArray[CBParameterInfo]
    len*: uint32
    cap*: uint32

  CBExposedTypeInfo* {.importcpp: "CBExposedTypeInfo", header: "chainblocks.hpp".} = object
    name*: cstring
    help*: cstring
    exposedType*: CBTypeInfo

  CBExposedTypesInfo* {.importcpp: "CBExposedTypesInfo", header: "chainblocks.hpp".} = object
    elements*: ptr UncheckedArray[CBExposedTypeInfo]
    len*: uint32
    cap*: uint32

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

  CBComposeProc*{.importcpp: "CBComposeProc", header: "chainblocks.hpp".} = proc(b: ptr CBlock; data: CBInstanceData): CBTypeInfo {.cdecl.}

  CBWarmupProc* {.importcpp: "CBWarmupProc", header: "chainblocks.hpp".} = proc(b: ptr CBlock; context: CBContext) {.cdecl.}
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

    compose*: CBComposeProc

    warmup*: CBWarmupProc
    activate*: CBActivateProc
    cleanup*: CBCleanupProc

  CBBlockConstructor* {.importcpp: "CBBlockConstructor", header: "chainblocks.hpp".} = proc(): ptr CBlock {.cdecl.}
  CBlocks* {.importcpp: "CBlocks", header: "chainblocks.hpp".} = object
    elements: ptr UncheckedArray[CBlock]
    len: uint32
    cap: uint32

  CBCallback* {.importcpp: "CBCallback", header: "chainblocks.hpp".} = proc(): void {.cdecl.}

  CBInstanceData* {.importcpp: "CBInstanceData", header: "chainblocks.hpp".} = object
    self {.importcpp: "block"}: ptr CBlock
    inputType*: CBTypeInfo
    stack*: CBTypesInfo
    shared*: CBExposedTypesInfo

  TCBArrays = CBSeq | CBStrings | CBlocks | CBTypesInfo | CBExposedTypesInfo | CBParametersInfo

iterator items*(arr: TCBArrays): auto {.inline.} =
  for i in 0..<arr.len:
    yield arr.elements[i]

iterator mitems*(arr: var TCBArrays): var auto {.inline.} =
  for i in 0..<arr.len:
    yield arr.elements[i]

proc `[]`*(v: TCBArrays; index: int): auto {.inline, noinit.} =
  assert index < v.len.int
  v.elements[index]

proc `[]=`*(v: var TCBArrays; index: int; value: auto) {.inline.} =
  assert index < v.len.int
  v.elements = value

proc suspendInternal(context: CBContext; seconds: float64): CBVar {.importcpp: "chainblocks::suspend(#, #)", header: "runtime.hpp".}
proc suspend*(context: CBContext; seconds: float64): CBVar {.inline.} =
  var frame = getFrameState()
  result = suspendInternal(context, seconds)
  setFrameState(frame)

proc referenceVariable*(context: CBContext; name: cstring): ptr CBVar {.importcpp: "chainblocks::referenceVariable(#, #)", header: "runtime.hpp".}
proc reference*(name: cstring; context: CBContext): ptr CBVar {.inline.} = referenceVariable(context, name)
proc release*(v: ptr CBVar) {.importcpp: "chainblocks::releaseVariable(#)", header: "runtime.hpp".}

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
  
type SupportedTypes = SomeOrdinal | seq[CBVar]

proc intoCBVar*[T](value: T): CBVar =
  zeroMem(addr result, sizeof(CBVar))

  when T is SomeOrdinal:
    result.valueType = CBType.Int
    assert T.high <= int64.high
    result.intValue = value.int64

  when T is seq[CBVar]:
    result.valueType = CBType.Seq
    assert value.len <= uint32.high.int
    result.seqValue.len = value.len.uint32
    result.seqValue.cap = 0
    result.seqValue.elements = cast[ptr UncheckedArray[CBVar]](unsafeaddr value[0])

  # else, won't work it seems
  when T isnot SupportedTypes:
    const msg = typedesc[T].name & " intoCBVar is still a TODO!"
    {.error: msg.}

proc toFourCC*(c1, c2, c3, c4: char): FourCC {.compileTime.} =
  return FourCC((ord(c1).cint and 255) + ((ord(c2).cint and 255) shl 8) +
    ((ord(c3).cint and 255) shl 16) + ((ord(c4).cint and 255) shl 24))

proc toFourCC*(str: string): FourCC {.compileTime.} =
  doAssert(str.len == 4, "To make a FourCC from a string the string needs to be exactly 4 chars long")
  return toFourCC(str[0], str[1], str[2], str[3])

proc info*(t: static[CBType],
           vendorId: uint32 = 0,
            typeId: uint32 = 0,
           seqTypes: openarray[CBTypeInfo] = []): CBTypeInfo =
  zeroMem(addr result, sizeof(CBTypeInfo))
  when t == CBType.Any:
    result = CBTypeInfo(basicType: CBType.Any)
  when t == CBType.Float:
    result = CBTypeInfo(basicType: CBType.Float)
  when t == CBType.Int:
    result = CBTypeInfo(basicType: CBType.Int)
  when t == CBType.Seq:
    result = CBTypeInfo(basicType: CBType.Seq,
                        seqTypes: CBTypesInfo(
                          elements: cast[ptr UncheckedArray[CBTypeInfo]](unsafeaddr seqTypes[0]),
                          len: seqTypes.len.uint32,
                          cap: 0))
  when t == CBType.Object:
    result = CBTypeInfo(basicType: CBType.Object, `object`: ObjectInfo(vendorId: vendorId, typeId: typeId)) 
  else:
    discard

proc unsafeFrom*(_: type[CBTypesInfo]; infos: openarray[CBTypeInfo]): CBTypesInfo =
  zeroMem(addr result, sizeof(CBTypesInfo))
  result.elements = cast[ptr UncheckedArray[CBTypeInfo]](unsafeaddr infos[0])
  result.len = infos.len.uint32
  result.cap = 0

proc info*(_: type[CBParameterInfo]; name, help: static[cstring]; types: CBTypesInfo): CBParameterInfo =
  zeroMem(addr result, sizeof(CBParameterInfo))
  result.name = name
  result.help = help
  result.valueTypes = types

proc info*(_: type[CBParameterInfo]; name: static[string]; types: CBTypesInfo): CBParameterInfo =
  return CBParameterInfo.info(name, "", types)

proc unsafeFrom*(_: type[CBParametersInfo]; infos: openarray[CBParameterInfo]): CBParametersInfo =
  zeroMem(addr result, sizeof(CBParametersInfo))
  result.elements = cast[ptr UncheckedArray[CBParameterInfo]](unsafeaddr infos[0])
  result.len = infos.len.uint32
  result.cap = 0

proc info*(_: type[CBExposedTypeInfo]; name, help: static[cstring]; typeInfo: CBTypeInfo): CBExposedTypeInfo =
  zeroMem(addr result, sizeof(CBExposedTypeInfo))
  result.name = name
  result.help = help
  result.exposedType = typeInfo

proc info*(_: type[CBExposedTypeInfo]; name: static[string]; typeInfo: CBTypeInfo): CBExposedTypeInfo =
  return CBExposedTypeInfo.info(name, "", typeInfo)

proc unsafeFrom*(_: type[CBExposedTypesInfo]; infos: openarray[CBExposedTypeInfo]): CBExposedTypesInfo =
  zeroMem(addr result, sizeof(CBExposedTypesInfo))
  result.elements = cast[ptr UncheckedArray[CBExposedTypeInfo]](unsafeaddr infos[0])
  result.len = infos.len.uint32
  result.cap = 0

let
  NoneType* = CBType.None.info()
  
  AnyType* = CBType.Any.info()
  anysData = [AnyType]
  AnySeqType* = CBType.Seq.info(seqTypes = anysData)
  AnyTypes* = CBTypesInfo.unsafe_from(anysData)
  anySeqsData = [AnySeqType]
  AnySeqTypes* = CBTypesInfo.unsafe_from(anySeqsData)

  FloatType* = CBType.Float.info()
  floatsData = [FloatType]
  FloatSeqType* = CBType.Seq.info(seqTypes = floatsData)
  FloatTypes* = CBTypesInfo.unsafe_from(floatsData)
  floatSeqsData = [FloatSeqType]
  FloatSeqTypes* = CBTypesInfo.unsafe_from(floatSeqsData)

  IntType* = CBType.Int.info()
  intsData = [IntType]
  IntSeqType* = CBType.Seq.info(seqTypes = intsData)
  IntTypes* = CBTypesInfo.unsafe_from(intsData)
  intSeqsData = [IntSeqType]
  IntSeqTypes* = CBTypesInfo.unsafe_from(intSeqsData)
  
# Block interface/default
  
proc help*(b: auto): cstring =
  const msg = typedesc[type(b)].name & " is using default help proc"
  {.hint: msg.}
  ""
proc init*(T: type[auto]) =
  const msg = typedesc[T].name & " is using default init proc"
  {.hint: msg.}
proc setup*(b: auto) =
  const msg = typedesc[type(b)].name & " is using default setup proc"
  {.hint: msg.}
proc destroy*(b: auto) =
  const msg = typedesc[type(b)].name & " is using default destroy proc"
  {.hint: msg.}
proc inputTypes*(b: auto): CBTypesInfo =
  const msg = typedesc[type(b)].name & " is using default inputTypes proc with AnyTypes"
  {.warning: msg.}
  AnyTypes
proc outputTypes*(b: auto): CBTypesInfo =
  const msg = typedesc[type(b)].name & " is using default outputTypes proc with AnyTypes"
  {.warning: msg.}
  AnyTypes
proc exposedVariables*(b: auto): CBExposedTypesInfo =
  zeroMem(addr result, sizeof(CBExposedTypesInfo))
  const msg = typedesc[type(b)].name & " is using default exposedVariables proc"
  {.hint: msg.}
proc requiredVariables*(b: auto): CBExposedTypesInfo =
  zeroMem(addr result, sizeof(CBExposedTypesInfo))
  const msg = typedesc[type(b)].name & " is using default requiredVariables proc"
  {.hint: msg.}
proc parameters*(b: auto): CBParametersInfo =
  zeroMem(addr result, sizeof(CBParametersInfo))
  const msg = typedesc[type(b)].name & " is using default parameters proc"
  {.hint: msg.}
proc setParam*(b: auto; index: int; val: CBVar) =
  const msg = typedesc[type(b)].name & " is using default setParam proc"
  {.hint: msg.}
proc getParam*(b: auto; index: int): CBVar =
  zeroMem(addr result, sizeof(CBVar))
  const msg = typedesc[type(b)].name & " is using default getParam proc"
  {.hint: msg.}
proc cleanup*(b: auto) =
  const msg = typedesc[type(b)].name & " is using default cleanup proc"
  {.hint: msg.}
proc activate*(b: auto; context: CBContext; input: CBVar): CBVar =
  zeroMem(addr result, sizeof(CBVar))
  const msg = typedesc[type(b)].name & " is using default activate proc"
  {.warning: msg.}

# Allocators using cpp to properly construct in C++ fashion (we have some blocks that need this)
template cppnew*(pt, typ1, typ2: untyped): untyped = emitc(`pt`, " = reinterpret_cast<", `typ1`, "*>(new ", `typ2`, "());")
template cppnew*(pt, typ1, typ2, a1: untyped): untyped = emitc(`pt`, " = reinterpret_cast<", `typ1`, "*>(new ", `typ2`, "(", `a1`, "));")
template cppnew*(pt, typ1, typ2, a1, a2: untyped): untyped = emitc(`pt`, " = reinterpret_cast<", `typ1`, "*>(new ", `typ2`, "(", `a1`, ", ", `a2`, "));")
template cppnew*(pt, typ1, typ2, a1, a2, a3: untyped): untyped = emitc(`pt`, " = reinterpret_cast<", `typ1`, "*>(new ", `typ2`, "(", `a1`, ", ", `a2`, ", ", `a3`, "));")
template cppdel*(pt: untyped): untyped = emitc("delete ", `pt`, ";")
proc throwCBException*(msg: string) = emitc("throw chainblocks::CBException(", `msg`.cstring, ");")
proc throwCBException*(msg: cstring) = emitc("throw chainblocks::CBException(", `msg`, ");")

proc registerBlock*(name: cstring; initProc: CBBlockConstructor) {.importcpp: "chainblocks::registerBlock(@)", header: "runtime.hpp".}

proc callDestroy*[T](obj: var T) = `=destroy`(obj)

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
    
    composeProc = ident($blk & "_compose")

    warmupProc = ident($blk & "_warmup")
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
      callDestroy(b.sb)
      cppdel(b)
    proc `inputTypesProc`*(b: `rtName`): CBTypesInfo {.cdecl.} =
      b.sb.inputTypes()
    proc `outputTypesProc`*(b: `rtName`): CBTypesInfo {.cdecl.} =
      b.sb.outputTypes()
    proc `exposedVariablesProc`*(b: `rtName`): CBExposedTypesInfo {.cdecl.} =
      b.sb.exposedVariables()
    proc `requiredVariablesProc`*(b: `rtName`): CBExposedTypesInfo {.cdecl.} =
      b.sb.requiredVariables()
    when compiles((var x: `blk`; discard x.compose(CBInstanceData()))):
      proc `composeProc`*(b: `rtName`; data: CBInstanceData): CBTypeInfo =
        const msg =  `namespace` & `blockName` & " has compose proc!"
        {.hint: msg.}
        b.sb.compose(data)
    proc `parametersProc`*(b: `rtName`): CBParametersInfo {.cdecl.} =
      b.sb.parameters()
    proc `setParamProc`*(b: `rtName`; index: int; val: CBVar) {.cdecl.} =
      b.sb.setParam(index, val)
    proc `getParamProc`*(b: `rtName`; index: int): CBVar {.cdecl.} =
      b.sb.getParam(index)
    when compiles((var x: `blk`; x.warmup(nil))):
      proc `warmupProc`*(b: `rtName`; context: CBContext) {.cdecl.} =
        const msg =  `namespace` & `blockName` & " has warmup proc!"
        {.hint: msg.}
        b.sb.warmup(context)
    proc `activateProc`*(b: `rtName`; context: CBContext; input: CBVar): CBVar {.cdecl.} =
      try:
        result = b.sb.activate(context, input)
      except:
        throwCBException getCurrentExceptionMsg()
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
      result.inputTypes = cast[CBInputTypesProc](`inputTypesProc`.pointer)
      result.outputTypes = cast[CBOutputTypesProc](`outputTypesProc`.pointer)
      result.exposedVariables = cast[CBExposedVariablesProc](`exposedVariablesProc`.pointer)
      result.requiredVariables = cast[CBRequiredVariablesProc](`requiredVariablesProc`.pointer)
      result.parameters = cast[CBParametersProc](`parametersProc`.pointer)
      result.setParam = cast[CBSetParamProc](`setParamProc`.pointer)
      result.getParam = cast[CBGetParamProc](`getParamProc`.pointer)
      when compiles((var x: `blk`; discard x.compose(CBInstanceData()))):
        result.compose = cast[CBComposeProc](`composeProc`.pointer)
      when compiles((var x: `blk`; x.warmup(nil))):
        result.warmup = cast[CBWarmupProc](`warmupProc`.pointer)
      result.activate = cast[CBActivateProc](`activateProc`.pointer)
      result.cleanup = cast[CBCleanupProc](`cleanupProc`.pointer)

    # also run static init
    `blk`.init()

# must link like -Wl,--whole-archive -lhttp -Wl,--no-whole-archive
      
when isMainModule or defined(test_block):
  type
    CBPow2Block = object
      inputValue: float
      myseq: seq[byte]
      params: array[1, CBVar]
  
  var v: CBVar
  echo v

  let
    info1 = CBType.Object.info()
    p1 = CBParameterInfo.info("P1", AnyTypes)
    pmsa = [p1]
    pms = CBParametersInfo.unsafeFrom(pmsa)

  let
    sinkCC = "sink".toFourCC.uint32
    sharedNetworkInfo = CBType.Object.info(vendorId = sinkCC)
    intVar = 10.intoCBVar
  var
    idata: CBInstanceData
  idata.self = nil

  proc inputTypes*(b: var CBPow2Block): CBTypesInfo = AnyTypes
  proc outputTypes*(b: var CBPow2Block): CBTypesInfo = AnyTypes
  proc parameters*(b: var CBPow2Block): CBParametersInfo = pms
  proc compose*(b: var CBPow2Block; data: CBInstanceData): CBTypeInfo = AnyType
  proc setParam*(b: var CBPow2Block; index: int; val: CBVar) = b.params[0] = val
  proc getParam*(b: var CBPow2Block; index: int): CBVar = b.params[0]
  proc activate*(b: var CBPow2Block; context: CBContext; input: CBVar): CBVar =
    echo "Yes nim..."
    CBVar()
  
  chainblock CBPow2Block, "Pow2StaticBlock"
  
