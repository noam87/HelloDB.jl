module Pages
  using HelloDB.FileMgrs
  using HelloDB.Blocks
  using HelloDB

  ##############################################################################
  # Exports
  ##############################################################################

  export Page
  export string_size, getint, setint, getstring, setstring, append
  export BLOCK_SIZE, INT_SiZE, CHAR_SIZE

  ##############################################################################
  # Constants
  ##############################################################################

  const BLOCK_SIZE = HelloDB.BLOCK_SIZE
  const INT_SiZE = sizeof(Int)
  const CHAR_SIZE = 1
  # sizeof(Char) == 4, but most alphabet is 1. This will
  # also cause issue when reading from buffer as it will read 4 bytes
  # (hence getstring() hack).
  #
  # TODO: Implement either
  # 1. (4 - charsize)-byte 0x00 padding (naive).
  # 2. proper utf handling.

  ##############################################################################
  # Implementation
  ##############################################################################

  """
  Before performing disk IO, data is manipulated within a `Pgae`.
  Data is broken up into `Block` objects, which are then saved to file.
  """
  type Page
    contents::IOBuffer
    filemgr::FileMgr

    function Page(realfile=true)
      buffer = IOBuffer(BLOCK_SIZE)

      if realfile
        filemgr = DB.filemgr
      else
        filemgr = FileMgr()
      end

      new(buffer, filemgr)
    end
  end

  """
  Append `page` contents to file `filename`.
  """
  function append(page::Page, filename)
    FileMgrs.append(page.filemgr, filename, page.contents)
  end

  """
  Gets the first byte in `page.contents` buffer as `Int`.
  This represents the length of string starting at the pointer position.
  """
  function getint(page::Page, offset::Int)
    seek(page.contents, offset)
    read(page.contents, Int)
  end

  """
  Like `getint()` but for a string of `Char`.
  """
  function getstring(page::Page, offset::Int)
    seek(page.contents, offset)
    str_len = read(page.contents, Int)
    AbstractString(map(x->Char(x), readbytes(page.contents, str_len)))
  end

  """
  Fill contents of `page` based on `block` filename and position.
  """
  function Base.read(page::Page, block::Block)
    read(page.filemgr, block, page.contents)
  end

  """
  Insert `val` into `page.contents` byte buffer at offset `offset`.
  """
  function setint(page::Page, offset::Int, val::Int)
    seek(page.contents, offset)
    write(page.contents, val)
  end

  """
  Like `setint()` but for a string of `Char`.
  """
  function setstring(page::Page, offset::Int, str::AbstractString)
    seek(page.contents, offset)
    write(page.contents, length(str))
    write(page.contents, IOBuffer(str))
  end

  """
  Strings will be represented as arrays of the form `[str_length, chars...]`.
  """
  function string_size(n)
    INT_SiZE + (n * CHAR_SIZE)
  end

  """
  Write to `block` from `page` contents.
  """
  function Base.write(page::Page, block::Block)
    write(page.filemgr, block, page.contents)
  end
end
