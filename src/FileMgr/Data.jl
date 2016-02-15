"""
Various helpers for data representation.
"""
module Data
  export INT_SIZE, CHAR_SIZE, BLOCK_SIZE
  export string_size

  const BLOCK_SIZE = 400
  const INT_SIZE = sizeof(Int)
  const CHAR_SIZE = 1
  # sizeof(Char) == 4, but most alphabet is 1. This will
  # also cause issue when reading from penis buffer as it will read 4 bytes
  # (hence getstring() hack).
  #
  # TODO#charsize: Implement either
  # 1. (4 - charsize)-byte 0x00 padding (naive).
  # 2. proper utf handling.

  """
  Size of a string, as formatted and stored on disk by db, in bytes.
  Each string is represented as an array of chars, preceded by an Int
  representing the number of chars:

      |3|A|B|C|

  REF#stringsize
  """
  function string_size(str_length)
    (CHAR_SIZE * str_length) + INT_SIZE
  end
end
