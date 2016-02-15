"""
Before performing disk IO, data is manipulated within a `Pgae`.
Data is broken up into `Block` objects, which are then saved to file.
"""
module Pages
  using HelloDB.FileMgrs
  using HelloDB.Blocks
  using HelloDB.Data: INT_SIZE, CHAR_SIZE, BLOCK_SIZE
  using HelloDB: DB

  ##############################################################################
  # Exports
  ##############################################################################

  export Page
  export string_size, getint, setint, getstring, setstring, append

  ##############################################################################
  # Implementation
  ##############################################################################

  type Page
    contents::IOBuffer
    filemgr::FileMgr

    """
    Page() is initialized with the Database file manage (`DB.filemgr`).
    For testing purposes, one may initialize a `Page` with an empty
    filemanager which will not write to disk by negating the
    `realfile` initialization parameter: `Page(false)`.
    """
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
  (This may represnt the length of string starting at the pointer position.)
  """
  function getint(page::Page, offset::Int)
    seek(page.contents, offset)
    read(page.contents, Int)
  end

  """
  Like `getint()` but for a string of `Char`.
  First we get the string's expected length (represented by an int at the
  beginning of the char sequence), next we red the chars into a string.
  """
  function getstring(page::Page, offset::Int)
    seek(page.contents, offset)
    str_len = read(page.contents, Int)
    # We assume all chars are stored on disk as single-byte, then convert these
    # hex values to an array of chars in memory, then to a string
    # (grep TODO#charsize).
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
    INT_SIZE + (n * CHAR_SIZE)
  end

  """
  Write to `block` from `page` contents.
  """
  function Base.write(page::Page, block::Block)
    write(page.filemgr, block, page.contents)
  end
end
