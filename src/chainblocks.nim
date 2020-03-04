import os, macros, typetraits, tables

const
  modulePath = currentSourcePath().splitPath().head
  cbheader = "-I" & modulePath & "/../../chainblocks/include"

{.passC: cbheader.}

type
  FourCC* = distinct int32

  CBBool* {.importc: "CBBool", header: "chainblocks.h", nodecl.} = bool
  CBInt* {.importc: "CBInt", header: "chainblocks.h", nodecl.} = int64
  CBInt2* {.importc: "CBInt2", header: "chainblocks.h".} = object
  CBInt3* {.importc: "CBInt3", header: "chainblocks.h".} = object
  CBInt4* {.importc: "CBInt4", header: "chainblocks.h".} = object
  CBInt8* {.importc: "CBInt8", header: "chainblocks.h".} = object
  CBInt16* {.importc: "CBInt16", header: "chainblocks.h".} = object
  CBFloat* {.importc: "CBFloat", header: "chainblocks.h".} = float64
  CBFloat2* {.importc: "CBFloat2", header: "chainblocks.h".} = object
  CBFloat3* {.importc: "CBFloat3", header: "chainblocks.h".} = object
  CBFloat4* {.importc: "CBFloat4", header: "chainblocks.h".} = object
  CBColor* {.importc: "struct CBColor", header: "chainblocks.h".} = object
    r*,g*,b*,a*: uint8
  CBPointer* {.importc: "CBPointer", header: "chainblocks.h".} = pointer
  CBString* {.importc: "CBString", header: "chainblocks.h".} = object
  CBSeq* {.importc: "CBSeq", header: "chainblocks.h".} = object
    elements*: ptr UncheckedArray[CBVar]
    len*: uint32
    cap*: uint32
  CBTable* {.importc: "struct CBTable", header: "chainblocks.h".} = object
    opaque: pointer
    api: ptr CBTableInterface
  CBStrings* {.importc: "CBStrings", header: "chainblocks.h".} = object
    elements*: ptr UncheckedArray[CBString]
    len*: uint32
    cap*: uint32
  CBEnum* {.importc: "CBEnum", header: "chainblocks.h".} = distinct int32
  CBChain* {.importc: "struct CBChain", header: "chainblocks.h".} = object
  CBChainPtr* = ptr CBChain
  CBNode* {.importc: "struct CBNode", header: "chainblocks.h".} = object
  CBContextObj* {.importc: "struct CBContext", header: "chainblocks.h".} = object
  CBContext* = ptr CBContextObj

  CBEnumInfo* {.importc: "CBEnumInfo", header: "chainblocks.h".} = object
    name*: cstring
    labels*: CBStrings

  CBImage* {.importc: "struct CBImage", header: "chainblocks.h".} = object
    width*: uint16
    height*: uint16
    channels*: uint8
    flags*: uint8
    data*: ptr UncheckedArray[uint8]

  CBTableForEachCallback {.importc: "CBTableForEachCallback", header: "chainblocks.h".} = proc(key: cstring; value: ptr CBVar; data: pointer): CBBool {.cdecl.}

  CBTableInterface {.importc: "CBTableInterface", header: "chainblocks.h".} = object
    tableForEach: proc(table: CBTable; cb: CBTableForEachCallback; data: pointer) {.cdecl.}
    tableSize: proc(table: CBTable): csize_t {.cdecl.}
    tableContains: proc(table: CBTable; key: cstring): CBBool {.cdecl.}
    tableAt: proc(table: CBTable; key: cstring): ptr CBVar {.cdecl.}
    tableRemove: proc(table: CBTable; key: cstring) {.cdecl.}
    tableClear: proc(table: CBTable) {.cdecl.}
    tableFree: proc(table: CBTable) {.cdecl.}

  CBType* {.importc: "CBType", header: "chainblocks.h", size: sizeof(uint8), pure.} = enum
    None,
    Any,
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
    Block,      # a block, useful for future introspection blocks!
    StackIndex, # an index in the stack, used as cheap ContextVar
    EndOfBlittableTypes = 50, # anything below this is not blittable (ish)
    Bytes, # pointer + size
    String,
    Path,       # An OS filesystem path
    ContextVar, # A string label to find from CBContext variables
    Image,
    Seq,
    Table,
    Chain,
    Object,

  # exportc to avoid mangling
  ObjectInfo* {.exportc.} = object
    vendorId: FourCC
    typeId: FourCC

  TableInfo* {.exportc.} = object
    keys: CBStrings
    types: CBTypesInfo
      
  CBTypeInfo* {.importc: "struct CBTypeInfo", header: "chainblocks.h".} = object
    basicType*: CBType
    seqTypes*: CBTypesInfo
    `object`*: ObjectInfo
    table*: TableInfo

  CBTypesInfo* {.importc: "CBTypesInfo", header: "chainblocks.h".} = object
    elements*: ptr UncheckedArray[CBTypeInfo]
    len*: uint32
    cap*: uint32

  CBObjectInfo* {.importc: "struct CBObjectInfo", header: "chainblocks.h".} = object
    name*: cstring
    serialize*: proc(p: pointer, data: ptr ptr uint8, dataLen: ptr csize_t, handle: ptr CBPointer): CBBool {.cdecl.}
    free*: proc(handle: CBPointer) {.cdecl.}
    deserialize*: proc(data: ptr UncheckedArray[uint8], dataLen: ptr csize_t): pointer {.cdecl.}
    reference*: proc(p: pointer) {.cdecl.}
    release*: proc(p: pointer) {.cdecl.}

  CBParameterInfo* {.importc: "struct CBParameterInfo", header: "chainblocks.h".} = object
    name*: cstring
    valueTypes*: CBTypesInfo
    help*: cstring
  
  CBParametersInfo* {.importc: "CBParametersInfo", header: "chainblocks.h".} = object
    elements*: ptr UncheckedArray[CBParameterInfo]
    len*: uint32
    cap*: uint32

  CBExposedTypeInfo* {.importc: "struct CBExposedTypeInfo", header: "chainblocks.h".} = object
    name*: cstring
    help*: cstring
    exposedType*: CBTypeInfo

  CBExposedTypesInfo* {.importc: "struct CBExposedTypesInfo", header: "chainblocks.h".} = object
    elements*: ptr UncheckedArray[CBExposedTypeInfo]
    len*: uint32
    cap*: uint32

  CBValidationResult* {.importc: "struct CBValidationResult", header: "chainblocks.h".} = object
    outputType*: CBTypeInfo
    exposedInfo*: CBExposedTypesInfo
  
  CBChainState* {.importc: "CBChainState", header: "chainblocks.h".} = enum
    Continue, # Even if None returned, continue to next block
    Restart, # Restart the chain from the top
    Stop # Stop the chain execution

  CBVarPayload* {.importc: "struct CBVarPayload", header: "chainblocks.h".} = object
    chainState*: CBChainState
    objectValue*: CBPointer
    objectVendorId*: FourCC
    objectTypeId*: FourCC
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

  CBVar* {.importc: "struct CBVar", header: "chainblocks.h".} = object
    payload*: CBVarPayload
    valueType*: CBType

  CBVarConst* = object
    value*: CBVar

  CBNameProc* {.importc: "CBNameProc", header: "chainblocks.h".} = proc(b: ptr CBlock): cstring {.cdecl.}
  CBHelpProc* {.importc: "CBHelpProc", header: "chainblocks.h".} = proc(b: ptr CBlock): cstring {.cdecl.}

  CBSetupProc* {.importc: "CBSetupProc", header: "chainblocks.h".} = proc(b: ptr CBlock) {.cdecl.}
  CBDestroyProc* {.importc: "CBDestroyProc", header: "chainblocks.h".} = proc(b: ptr CBlock) {.cdecl.}

  CBInputTypesProc*{.importc: "CBInputTypesProc", header: "chainblocks.h".}  = proc(b: ptr CBlock): CBTypesInfo {.cdecl.}
  CBOutputTypesProc* {.importc: "CBOutputTypesProc", header: "chainblocks.h".} = proc(b: ptr CBlock): CBTypesInfo {.cdecl.}

  CBExposedVariablesProc* {.importc: "CBExposedVariablesProc", header: "chainblocks.h".} = proc(b: ptr CBlock): CBExposedTypesInfo {.cdecl.}
  CBRequiredVariablesProc* {.importc: "CBRequiredVariablesProc", header: "chainblocks.h".} = proc(b: ptr CBlock): CBExposedTypesInfo {.cdecl.}

  CBParametersProc* {.importc: "CBParametersProc", header: "chainblocks.h".} = proc(b: ptr CBlock): CBParametersInfo {.cdecl.}
  CBSetParamProc* {.importc: "CBSetParamProc", header: "chainblocks.h".} = proc(b: ptr CBlock; index: cint; val: CBVar) {.cdecl.}
  CBGetParamProc* {.importc: "CBGetParamProc", header: "chainblocks.h".} = proc(b: ptr CBlock; index: cint): CBVar {.cdecl.}

  CBComposeProc*{.importc: "CBComposeProc", header: "chainblocks.h".} = proc(b: ptr CBlock; data: CBInstanceData): CBTypeInfo {.cdecl.}

  CBWarmupProc* {.importc: "CBWarmupProc", header: "chainblocks.h".} = proc(b: ptr CBlock; context: CBContext) {.cdecl.}
  CBActivateProc* {.importc: "CBActivateProc", header: "chainblocks.h".} = proc(b: ptr CBlock; context: CBContext; input: CBVar): CBVar {.cdecl.}
  CBCleanupProc* {.importc: "CBCleanupProc", header: "chainblocks.h".} = proc(b: ptr CBlock) {.cdecl.}

  CBMutateProc* {.importc: "CBMutateProc", header: "chainblocks.h".} = proc(b: ptr CBlock; options: CBTable) {.cdecl.}

  CBlock* {.importc: "struct CBlock", header: "chainblocks.h".} = object
    inlineBlockId*: uint8
    
    name*: CBNameProc
    help*: CBHelpProc
    
    setup*: CBSetupProc
    destroy*: CBDestroyProc
    
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

    mutate*: CBMutateProc

  CBlockPtr* = ptr CBlock

  CBBlockConstructor* {.importc: "CBBlockConstructor", header: "chainblocks.h".} = proc(): ptr CBlock {.cdecl.}
 
  CBlocks* {.importc: "CBlocks", header: "chainblocks.h".} = object
    elements*: ptr UncheckedArray[CBlockPtr]
    len*: uint32
    cap*: uint32

  CBCallback* {.importc: "CBCallback", header: "chainblocks.h".} = proc(): void {.cdecl.}

  CBInstanceData* {.importc: "struct CBInstanceData", header: "chainblocks.h".} = object
    self* {.importc: "block"}: ptr CBlock
    inputType*: CBTypeInfo
    stack*: CBTypesInfo
    shared*: CBExposedTypesInfo

  CBValidationCallback = proc(blk: CBlockPtr; errormsg: cstring; nonfatal: CBBool; data: pointer) {.cdecl.}

  CBCore* {.importc: "struct CBCore", header: "chainblocks.h".} = object
    tableNew: proc(): CBTable {.cdecl.}
    cloneVar: proc(dst: pointer; src: pointer) {.cdecl.}
    destroyVar: proc(v: pointer) {.cdecl.}
    suspend: proc(ctx: CBContext; seconds: float64): CBVar {.cdecl.}
    referenceVariable: proc(ctx: CBContext; name: cstring): ptr CBVar {.cdecl.}
    releaseVariable: proc(v: ptr CBVar) {.cdecl.}
    registerBlock: proc(name: cstring; ctor: CBBlockConstructor) {.cdecl.}
    registerObjectType: proc(vendorId, typeId: int32; info: CBObjectInfo) {.cdecl.}
    throwException: proc(msg: cstring) {.cdecl.}
    seqFree: proc(s: ptr CBSeq) {.cdecl.}
    expTypesFree: proc(s: ptr CBExposedTypesInfo) {.cdecl.}
    seqPush: proc(s: ptr CBSeq; val: ptr CBVar) {.cdecl.}
    seqResize: proc(s: ptr CBSeq; size: uint32) {.cdecl.}
    seqFastDelete: proc(s: ptr CBSeq; idx: uint32) {.cdecl.}
    seqSlowDelete: proc(s: ptr CBSeq; idx: uint32) {.cdecl.}
    seqInsert: proc(s: ptr CBSeq; idx: uint32; val: ptr CBVar) {.cdecl.}
    seqPop: proc(s: ptr CBSeq): CBVar {.cdecl.}
    log: proc(msg: cstring) {.cdecl.}
    createBlock: proc(name: cstring): CBlockPtr {.cdecl.}
    validateSetParam: proc(blk: CBlockPtr; index: cint; param: CBVar; cb: CBValidationCallback; data: pointer): CBBool {.cdecl.}
    createChain: proc(name: cstring; blocks: CBlocks; looped, unsafe: CBBool): CBChainPtr {.cdecl.}
    destroyChain: proc(chain: CBChainPtr) {.cdecl.}
    validateChain: proc(chain: CBChainPtr; cb: CBValidationCallback; userData: pointer; data: CBInstanceData): CBValidationResult {.cdecl.}
    createNode: proc(): ptr CBNode {.cdecl.}
    destroyNode: proc(node: ptr CBNode) {.cdecl.}
    schedule: proc(node: ptr CBNode; chain: CBChainPtr) {.cdecl.}
    tick: proc(node: ptr CBNode): CBBool {.cdecl.}
    sleep: proc(seconds: float64; runCallbacks: CBBool) {.cdecl.}

  TCBArrays = CBSeq | CBStrings | CBlocks | CBTypesInfo | CBExposedTypesInfo | CBParametersInfo

  Var* = distinct CBVar

proc `==`*(a, b: FourCC): bool {.borrow.}

const
  ABI_VERSION = 0x20200101
 
proc startup(_: type[CBCore]): CBCore =
  proc chainblocksInterface(abiVersion: uint32): CBCore {.importc: "chainblocksInterface", header: "chainblocks.h".}
  return chainblocksInterface(ABI_VERSION)

let
  Core = CBCore.startup()

proc `=destroy`(v: var Var) {.inline.} =
  Core.destroyVar(addr v)

proc `=`(dst: var Var; source: Var) {.inline.} =
  zeroMem(addr dst, sizeof(CBVar))
  Core.cloneVar(addr dst, unsafeaddr source)

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
  v.elements[index] = value

proc `[]=`*(t: var CBTable; key: string; val: CBVar) =
  var varPtr = t.api[].tableAt(t, key.cstring)
  varPtr[] = val

proc `[]`*(t: var CBTable; key: string): var CBVar =
  var varPtr = t.api[].tableAt(t, key.cstring)
  varPtr[]

proc `[]`*(t: CBTable; key: string): CBVar =
  var varPtr = t.api[].tableAt(t, key.cstring)
  varPtr[]

proc suspend*(context: CBContext; seconds: float64): CBVar {.inline.} =
  var frame = getFrameState()
  result = Core.suspend(context, seconds)
  setFrameState(frame)

proc reference*(name: cstring; context: CBContext): ptr CBVar {.inline.} = Core.referenceVariable(context, name)
proc release*(v: ptr CBVar) {.inline.} = Core.releaseVariable(v)

include chainblocks/varsugar
  
type SupportedTypes = seq[CBVar] | SomeFloat | SomeInteger | array[3, int32] | array[4, int32] | array[2, float64]


proc intoCBVar*[T](value: T): CBVar =
  zeroMem(addr result, sizeof(CBVar))

  when T is SomeInteger:
    result.valueType = CBType.Int
    static:
      assert T.high <= int64.high
    result.intValue = value.int64

  when T is SomeFloat:
    result.valueType = CBType.Float
    static:
      assert T.high <= float64.high
    result.floatValue = value.float64

  when T is seq[CBVar]:
    result.valueType = CBType.Seq
    assert value.len <= uint32.high.int
    result.seqValue.len = value.len.uint32
    result.seqValue.cap = 0
    result.seqValue.elements = cast[ptr UncheckedArray[CBVar]](unsafeaddr value[0])

  when T is array[3, int32]:
    result.valueType = CBType.Int3
    copyMem(addr result.int3Value, unsafeaddr value[0], sizeof(T))

  when T is array[4, int32]:
    result.valueType = CBType.Int4
    copyMem(addr result.int4Value, unsafeaddr value[0], sizeof(T))

  when T is array[2, float64]:
    result.valueType = CBType.Float2
    copyMem(addr result.float2Value, unsafeaddr value[0], sizeof(T))

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

proc info*(
  t: static[CBType],
  vendorId: FourCC = 0.FourCC,
  typeId: FourCC = 0.FourCC,
  seqTypes: openarray[CBTypeInfo] = [],
  tableKeys: openarray[cstring] = [],
  tableTypes: openarray[CBTypeInfo] = []): CBTypeInfo =
  zeroMem(addr result, sizeof(CBTypeInfo))
  when t == CBType.Table:
    doAssert tableKeys.len == tableTypes.len
    if tableKeys.len > 0:
      result = CBTypeInfo(
        basicType: CBType.Table,
        table: TableInfo(
          keys: CBStrings(
            elements: cast[ptr UncheckedArray[CBString]](unsafeaddr tableKeys[0]),
            len: tableKeys.len.uint32,
            cap: 0
          ),
          types: CBTypesInfo(
            elements: cast[ptr UncheckedArray[CBTypeInfo]](unsafeaddr tableTypes[0]),
            len: tableTypes.len.uint32,
            cap: 0
          )
        )
      )
    else:
      result = CBTypeInfo(basicType: CBType.Table)
  when t == CBType.Seq:
    if seqTypes.len > 0:
      result = CBTypeInfo(basicType: CBType.Seq,
                          seqTypes: CBTypesInfo(
                            elements: cast[ptr UncheckedArray[CBTypeInfo]](unsafeaddr seqTypes[0]),
                            len: seqTypes.len.uint32,
                            cap: 0))
    else:
      result = CBTypeInfo(basicType: CBType.Seq)
  when t == CBType.Object:
    result = CBTypeInfo(basicType: CBType.Object, `object`: ObjectInfo(vendorId: vendorId, typeId: typeId))
  else:
    result = CBTypeInfo(basicType: t)

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

macro generateCBTypeInfos(t: CBType): untyped =
  var
    xType = ident($t & "Type")
    xData = ident($t & "Data")
    xSeqType = ident($t & "SeqType")
    xTypes = ident($t & "Types")
    xSeqData = ident($t & "SeqData")
    xSeqTypes = ident($t & "SeqTypes")
  result = quote do:
    let
      `xType`* = `t`.info()
      `xData` = [`xType`]
      `xSeqType`* = CBType.Seq.info(seqTypes = `xData`)
      `xTypes`* = CBTypesInfo.unsafe_from(`xData`)
      `xSeqData` = [`xSeqType`]
      `xSeqTypes`* = CBTypesInfo.unsafe_from(`xSeqData`)

let
  NoneType* = CBType.None.info()
  
generateCBTypeInfos CBType.Any
generateCBTypeInfos CBType.Bool
generateCBTypeInfos CBType.Int
generateCBTypeInfos CBType.Int2
generateCBTypeInfos CBType.Int3
generateCBTypeInfos CBType.Int4
generateCBTypeInfos CBType.Int8
generateCBTypeInfos CBType.Int16
generateCBTypeInfos CBType.Float
generateCBTypeInfos CBType.Float2
generateCBTypeInfos CBType.Float3
generateCBTypeInfos CBType.Float4
generateCBTypeInfos CBType.Color
generateCBTypeInfos CBType.Chain
generateCBTypeInfos CBType.Block
generateCBTypeInfos CBType.Bytes
generateCBTypeInfos CBType.String
generateCBTypeInfos CBType.Path
generateCBTypeInfos CBType.ContextVar
generateCBTypeInfos CBType.Image
generateCBTypeInfos CBType.Seq
generateCBTypeInfos CBType.Table
  
# Block interface/default

type
  BlockWithWarmup* = concept var x
    x.warmup(CBContext)
  BlockWithCompose* = concept var x
    x.compose(CBInstanceData) is CBTypeInfo
  BlockWithCustomName* = concept var x
    x.name is cstring
  BlockWithMutate* = concept var x
    x.mutate(CBTable)

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

proc registerBlock*(name: cstring; initProc: CBBlockConstructor) {.inline.} = Core.registerBlock(name, initProc)
proc registerObjectType*(vendorId, typeId: FourCC; info: CBObjectInfo) {.inline.} = Core.registerObjectType(vendorId.int32, typeId.int32, info)

proc callDestroy*[T](obj: var T) = `=destroy`(obj)

proc throwException*(msg: cstring) {.inline.} = Core.throwException(msg)

proc log*(msg: cstring) {.inline.} = Core.log(msg)

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

    mutateProc = ident($blk & "_mutate")
  
  result = quote do:
    # import macros # used!
    
    type
      `rtNameValue` = object
        pre: CBlock
        sb: `blk`
      
      `rtName`* = ptr `rtNameValue`

    when `blk` is BlockWithCustomName:
      proc `nameProc`*(b: `rtName`): cstring {.cdecl.} =
        b.sb.name()
    else:
      proc name*(b: `blk`): cstring =
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
      dealloc(b)
    proc `inputTypesProc`*(b: `rtName`): CBTypesInfo {.cdecl.} =
      b.sb.inputTypes()
    proc `outputTypesProc`*(b: `rtName`): CBTypesInfo {.cdecl.} =
      b.sb.outputTypes()
    proc `exposedVariablesProc`*(b: `rtName`): CBExposedTypesInfo {.cdecl.} =
      b.sb.exposedVariables()
    proc `requiredVariablesProc`*(b: `rtName`): CBExposedTypesInfo {.cdecl.} =
      b.sb.requiredVariables()
    when `blk` is BlockWithCompose:
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
    when `blk` is BlockWithWarmup:
      proc `warmupProc`*(b: `rtName`; context: CBContext) {.cdecl.} =
        const msg =  `namespace` & `blockName` & " has warmup proc!"
        {.hint: msg.}
        b.sb.warmup(context)
    proc `activateProc`*(b: `rtName`; context: CBContext; input: CBVar): CBVar {.cdecl.} =
      try:
        result = b.sb.activate(context, input)
      except:
        throwException getCurrentExceptionMsg()
    proc `cleanupProc`*(b: `rtName`) {.cdecl.} =
      b.sb.cleanup()
    when `blk` is BlockWithMutate:
      proc `mutateProc`*(b: `rtName`; options: CBTable) {.cdecl.} =
        const msg =  `namespace` & `blockName` & " has mutate proc!"
        {.hint: msg.}
        b.sb.mutate(options)
    
    registerBlock(`namespace` & `blockName`) do -> ptr CBlock {.cdecl.}:
      result = cast[ptr CBlock](alloc0(sizeof(`rtNameValue`)))
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
      when `blk` is BlockWithCompose:
        result.compose = cast[CBComposeProc](`composeProc`.pointer)
      when `blk` is BlockWithWarmup:
        result.warmup = cast[CBWarmupProc](`warmupProc`.pointer)
      when `blk` is BlockWithMutate:
        result.mutate = cast[CBMutateProc](`mutateProc`.pointer)
      result.activate = cast[CBActivateProc](`activateProc`.pointer)
      result.cleanup = cast[CBCleanupProc](`cleanupProc`.pointer)

    # also run static init
    `blk`.init()

# must link like -Wl,--whole-archive -lhttp -Wl,--no-whole-archive

type
  ChainInfo = object
    name: string
    looped: bool
    unsafe: bool
    blocks: seq[CBlockPtr]

proc Chain(
  name: string,
  looped: bool = false,
  unsafe: bool = false): ChainInfo =
  result = ChainInfo(
    name: name,
    looped: looped,
    unsafe: unsafe
  )

proc Block(name: string; params: varargs[Var]): seq[ptr CBlock] =
  let
    blk = Core.createBlock(name.cstring)
  doAssert blk != nil, "Failed to create block: " & name

  blk.setup(blk)

  let paramInfos = blk.parameters(blk)

  var i = 0
  for param in params:
    let cb: CBValidationCallback = proc(blk: CBlockPtr; errormsg: cstring; nonfatal: CBBool; data: pointer) {.cdecl.} =
      Core.log(errormsg)
    doAssert Core.validateSetParam(blk, i.cint, param.CBVar, cb, nil), "Failed block set param validation: " & name & " param: " & $(paramInfos.elements[i].name)

    blk.setParam(blk, i.cint, param.CBVar)

    inc i
  return @[blk]

proc Block(blks: seq[ptr CBlock]; name: string; params: varargs[Var]): seq[ptr CBlock] =
  result = blks
  result.add(Block(name, params)[0])

proc Block(chain: ChainInfo, name: string; params: varargs[Var]): ChainInfo =
  result = chain
  result.blocks.add(Block(name, params)[0])

proc Run(info: ChainInfo): Var {.discardable.} =
  let
    blocks = CBlocks(
      elements: cast[ptr UncheckedArray[CBlockPtr]](info.blocks[0].unsafeaddr),
      len: info.blocks.len.uint32,
      cap: 0
    )
    chain = Core.createChain(info.name, blocks, info.looped, info.unsafe)
    cb: CBValidationCallback = proc(blk: CBlockPtr; errormsg: cstring; nonfatal: CBBool; data: pointer) {.cdecl.} =
      doAssert nonfatal, "Fatal error during chain validation: " & $errormsg & " block: " & $(blk.name(blk))
    validation = Core.validateChain(chain, cb, nil, CBInstanceData())

  Core.expTypesFree(validation.exposedInfo.unsafeaddr)

  let
    node = Core.createNode()

  Core.schedule(node, chain)

  while Core.tick(node):
    Core.sleep(0, true)

  Core.destroyChain(chain)
  Core.destroyNode(node)

when isMainModule and defined(testing):
  type
    CBPow2Block = object
      inputValue: float
      myseq: seq[byte]
      params: array[1, CBVar]

  var v: CBVar
  echo v

  var
    x: Var = 10
    y: Var
    z: Var
    sv: Var = "Hello"
    i: int
    tab = newTableVar()
  y = x
  z = x
  i = z
  tab["test"] = x.CBVar
  echo tab["test"]
  echo $(cast[cstring](sv.CBVar.stringValue))

  var cbseq = newSeqVar()
  echo x.CBVar
  cbseq.add(move(x))
  echo x.CBVar

  var s: string = sv

  Chain("test")
  .Block("Msg", "Hello")
  .Block("Msg", "World")
  .Block("Log")
  .Block("Const", 10)
  .Block("Math.Add", 10)
  .Block("Log")
  .Run()

  let
    info1 = CBType.Object.info()
    p1 = CBParameterInfo.info("P1", AnyTypes)
    pmsa = [p1]
    pms = CBParametersInfo.unsafeFrom(pmsa)

  let
    sinkCC = "sink".toFourCC
    sharedNetworkInfo = CBType.Object.info(vendorId = sinkCC)
    intVar = 10.intoCBVar
  var
    idata: CBInstanceData
  idata.self = nil

  block one:
    var
      se = newSeqVar()
      s1: Var = "Hello"
      s2: Var = "World"
      s3: Var = "Ciao"
    se.add(move(s1))
    se.add(move(s2))
    echo se.pop().CBVar
    se[0] = move(s3)

  echo "done"

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
  
