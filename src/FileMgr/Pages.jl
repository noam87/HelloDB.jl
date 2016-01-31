module Pages
  using HelloDB.FileMgrs
  using HelloDB.Blocks

  ##############################################################################
  # Exports
  ##############################################################################

  export Page
  export string_size, read!, write!, getint, setint, getstring, setstring
  export BLOCK_SIZE, INT_SiZE, CHAR_SIZE

  ##############################################################################
  # Constants
  ##############################################################################

  const BLOCK_SIZE = 400
  const INT_SiZE = sizeof(Int)
  const CHAR_SIZE = 1 # TODO: or sizeof(Char) == 4 ??? I don't know things.

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
  function append!(page::Page, filename)
    append!(page.filemgr, page.contents)
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
  function read!(page::Page, block::Block)
    read!(page.filemgr, block, page.contents)
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
  function write!(page::Page, block::Block)
    write!(page.filemgr, block, page.contents)
  end
end
