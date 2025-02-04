$version: "2"

namespace smithy.ruby.tests

operation Operation {
  input: OperationInputOutput
  output: OperationInputOutput
}

structure OperationInputOutput {
  // https://smithy.io/2.0/spec/simple-types.html
  blob: Blob
  boolean: Boolean
  string: String
  byte: Byte
  short: Short
  integer: Integer
  long: Long
  float: Float
  double: Double
  bigInteger: BigInteger
  bigDecimal: BigDecimal
  timestamp: Timestamp
  document: Document
  enum: Enum
  intEnum: IntEnum

  // https://smithy.io/2.0/spec/aggregate-types.html
  list: List
  map: Map
  structure: Structure
  union: Union
}

blob Blob

boolean Boolean

string String

byte Byte

short Short

integer Integer

long Long

float Float

double Double

bigInteger BigInteger

bigDecimal BigDecimal

timestamp Timestamp

document Document

enum Enum {
  FOO = "bar"
}

intEnum IntEnum {
  BAZ = 1
}

list List {
  member: String
}

map Map {
  key: String
  value: String
}

union Union {
  string: String
  structure: Structure
}

structure Structure {
  member: String
}
