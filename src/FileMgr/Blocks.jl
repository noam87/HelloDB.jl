module Blocks
  ##############################################################################
  # Exports
  ##############################################################################

  export Block
  export ==, tostring

  ##############################################################################
  # Implementation
  ##############################################################################

  """
  Represents a unique block of data within a file.
  """
  type Block
    filename::AbstractString
    number::Int
  end

  function ==(a::Block, b::Block)
    a.filename == b.filename && a.number == b.number
  end

  function !=(a::Block, b::Block)
    !(a == b)
  end

  function Base.hash(block::Block)
    hash(tostring(block))
  end

  # Pretty print
  function Base.show(io::IO, block::Block)
    tostring(block)
  end

  function tostring(block::Block)
    "Block[filename: $(block.filename), number: $(block.number)]"
  end
end
