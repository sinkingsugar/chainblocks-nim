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

template valueType*(v: Var): auto = v.CBVar.valueType
template chainState*(v: Var): auto = v.CBVar.payload.chainState
template objectValue*(v: Var): auto = v.CBVar.payload.objectValue
template objectVendorId*(v: Var): auto = v.CBVar.payload.objectVendorId
template objectTypeId*(v: Var): auto = v.CBVar.payload.objectTypeId
template boolValue*(v: Var): auto = v.CBVar.payload.boolValue
template intValue*(v: Var): auto = v.CBVar.payload.intValue
template int2Value*(v: Var): auto = v.CBVar.payload.int2Value
template int3Value*(v: Var): auto = v.CBVar.payload.int3Value
template int4Value*(v: Var): auto = v.CBVar.payload.int4Value
template int8Value*(v: Var): auto = v.CBVar.payload.int8Value
template int16Value*(v: Var): auto = v.CBVar.payload.int16Value
template floatValue*(v: Var): auto = v.CBVar.payload.floatValue
template float2Value*(v: Var): auto = v.CBVar.payload.float2Value
template float3Value*(v: Var): auto = v.CBVar.payload.float3Value
template float4Value*(v: Var): auto = v.CBVar.payload.float4Value
template stringValue*(v: Var): auto = v.CBVar.payload.stringValue
template colorValue*(v: Var): auto = v.CBVar.payload.colorValue
template imageValue*(v: Var): auto = v.CBVar.payload.imageValue
template seqValue*(v: Var): auto = v.CBVar.payload.seqValue
template seqLen*(v: Var): auto = v.CBVar.payload.seqLen
template tableValue*(v: Var): auto = v.CBVar.payload.tableValue
template chainValue*(v: Var): auto = v.CBVar.payload.chainValue
template blockValue*(v: Var): auto = v.CBVar.payload.blockValue
template enumValue*(v: Var): auto = v.CBVar.payload.enumValue
template enumVendorId*(v: Var): auto = v.CBVar.payload.enumVendorId
template enumTypeId*(v: Var): auto = v.CBVar.payload.enumTypeId

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
template chainValue*(v: CBVarConst): auto = v.value.payload.chainValue
template blockValue*(v: CBVarConst): auto = v.value.payload.blockValue
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
template `chainValue=`*(v: CBVar, val: auto) = v.payload.chainValue = val
template `blockValue=`*(v: CBVar, val: auto) = v.payload.blockValue = val
template `enumValue=`*(v: CBVar, val: auto) = v.payload.enumValue = val
template `enumVendorId=`*(v: CBVar, val: auto) = v.payload.enumVendorId = val
template `enumTypeId=`*(v: CBVar, val: auto) = v.payload.enumTypeId = val

template `valueType=`*(v: Var, val: auto) = v.CBVar.valueType = val
template `chainState=`*(v: Var, val: auto) = v.CBVar.payload.chainState = val
template `objectValue=`*(v: Var, val: auto) = v.CBVar.payload.objectValue = val
template `objectVendorId=`*(v: Var, val: auto) = v.CBVar.payload.objectVendorId = val
template `objectTypeId=`*(v: Var, val: auto) = v.CBVar.payload.objectTypeId = val
template `boolValue=`*(v: Var, val: auto) = v.CBVar.payload.boolValue = val
template `intValue=`*(v: Var, val: auto) = v.CBVar.payload.intValue = val
template `int2Value=`*(v: Var, val: auto) = v.CBVar.payload.int2Value = val
template `int3Value=`*(v: Var, val: auto) = v.CBVar.payload.int3Value = val
template `int4Value=`*(v: Var, val: auto) = v.CBVar.payload.int4Value = val
template `int8Value=`*(v: Var, val: auto) = v.CBVar.payload.int8Value = val
template `int16Value=`*(v: Var, val: auto) = v.CBVar.payload.int16Value = val
template `floatValue=`*(v: Var, val: auto) = v.CBVar.payload.floatValue = val
template `float2Value=`*(v: Var, val: auto) = v.CBVar.payload.float2Value = val
template `float3Value=`*(v: Var, val: auto) = v.CBVar.payload.float3Value = val
template `float4Value=`*(v: Var, val: auto) = v.CBVar.payload.float4Value = val
template `stringValue=`*(v: Var, val: auto) = v.CBVar.payload.stringValue = val
template `colorValue=`*(v: Var, val: auto) = v.CBVar.payload.colorValue = val
template `imageValue=`*(v: Var, val: auto) = v.CBVar.payload.imageValue = val
template `seqValue=`*(v: Var, val: auto) = v.CBVar.payload.seqValue = val
template `seqLen=`*(v: Var, val: auto) = v.CBVar.payload.seqLen = val
template `tableValue=`*(v: Var, val: auto) = v.CBVar.payload.tableValue = val
template `chainValue=`*(v: Var, val: auto) = v.CBVar.payload.chainValue = val
template `blockValue=`*(v: Var, val: auto) = v.CBVar.payload.blockValue = val
template `enumValue=`*(v: Var, val: auto) = v.CBVar.payload.enumValue = val
template `enumVendorId=`*(v: Var, val: auto) = v.CBVar.payload.enumVendorId = val
template `enumTypeId=`*(v: Var, val: auto) = v.CBVar.payload.enumTypeId = val

iterator items*(arr: CBVar | Var): CBVar {.inline.} =
  assert arr.valueType == CBType.Seq
  for i in 0..<arr.seqValue.len:
    yield arr.seqValue.elements[i]

iterator mitems*(arr: var CBVar | var Var): var CBVar {.inline.} =
  assert arr.valueType == CBType.Seq
  for i in 0..<arr.seqValue.len:
    yield arr.seqValue.elements[i]

proc `[]`*(v: CBVar | Var; index: int): CBVar {.inline, noinit.} =
  assert v.valueType == CBType.Seq
  assert index < v.seqValue.len.int
  v.seqValue.elements[index]

proc `[]=`*(v: var CBVar | var Var; index: int; value: auto) {.inline.} =
  assert v.valueType == CBType.Seq
  assert index < v.seqValue.len.int
  v.seqValue.elements[index] = value

proc `[]=`*(v: var CBVar | var Var; key: string; val: CBVar) =
  assert v.valueType == CBType.Table
  var t = v.tableValue
  var varPtr = t.api[].tableAt(t, key.cstring)
  varPtr[] = val

proc `[]`*(v: var CBVar | var Var; key: string): var CBVar =
  assert v.valueType == CBType.Table
  var t = v.tableValue
  var varPtr = t.api[].tableAt(t, key.cstring)
  varPtr[]

proc `[]`*(v: CBVar | Var; key: string): CBVar =
  assert v.valueType == CBType.Table
  var t = v.tableValue
  var varPtr = t.api[].tableAt(t, key.cstring)
  varPtr[]

proc newTableVar*(): Var =
  var table = Core.tableNew()
  result.valueType = CBType.Table
  result.tableValue = table

proc len*(v: Var): int {.inline.} =
  assert v.valueType == CBType.Seq
  v.seqValue.len.int

proc setLen*(v: var Var; newLen: Natural) {.inline.} =
  assert v.valueType == CBType.Seq
  Core.seqResize(addr v.seqValue, newLen.uint32)

proc add*(v: var Var; val: CBVar) {.inline.} =
  assert v.valueType == CBType.Seq
  Core.seqPush(addr v.seqValue, unsafeaddr val)

proc del*(v: var Var; i: Natural) {.inline.} =
  assert v.valueType == CBType.Seq
  Core.seqFastDelete(addr v.seqValue, i.uint32)

proc delete*(v: var Var; i: Natural) {.inline.} =
  assert v.valueType == CBType.Seq
  Core.seqSlowDelete(addr v.seqValue, i.uint32)

proc insert*(v: var Var; val: CBVar; idx = 0.Natural) =
  assert v.valueType == CBType.Seq
  Core.seqInsert(addr v.seqValue, idx.uint32, unsafeaddr val)
