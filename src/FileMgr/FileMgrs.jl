"""
HelloDB saves data into files. Data is broken up into blocks, and
fetched/manipulated within a `Page` buffer.
"""
module FileMgrs
  using HelloDB
  using HelloDB.Blocks
  ##############################################################################
  # Exports
  ##############################################################################

  export FileMgr
  export append

  ##############################################################################
  # Implementation
  ##############################################################################

  type FileMgr
    dbdir::AbstractString
    isNew::Bool
    openfiles::Dict{AbstractString, IOStream}

    function FileMgr(dbname::AbstractString)
      # create db directory
      dbdir = homedir() * "/$dbname"
      isnew = false

      if !isdir(dbdir)
        isnew = true
        mkdir(dbdir)
        _make_dbdir_file(dbdir)
      end

      # clear leftover temp files
      tempfiles = filter(f->startswith(f, "temp"), readdir(dbdir))
      [rm(dbdir + "/$file") for file in tempfiles]

      new(dbdir, isnew, Dict())
    end

    function FileMgr()
      new("foo", false, Dict())
    end
  end

  """
  Fill `buf` based on `block` filename and position.
  """
  function Base.read(filemgr::FileMgr, block::Block, buf::IOBuffer)
    _clear(buf)
    file = _getfile(filemgr, block.filename)
    seek(file, block.number * buf.maxsize)
    write(buf, readbytes(file, buf.maxsize))
  end

  function Base.write(filemgr::FileMgr, block::Block, buf::IOBuffer)
    seekstart(buf)
    file = _getfile(filemgr, block.filename)
    seek(file, block.number * buf.maxsize)
    written = write(file, readbytes(buf))
    flush(file)
    written
  end

  """
  Append contents of `buffer` to file `filename`.
  """
  function append(filemgr::FileMgr, filename::AbstractString, buffer::IOBuffer)
    file = _getfile(filemgr, filename)
    blocknum = size(filemgr, filename)
    block = Block(filename, blocknum)
    write(filemgr, block, buffer)
    block
  end

  function size(filemgr::FileMgr, filename)
    file = _getfile(filemgr, filename)
    ratio = filesize(file) / HelloDB.BLOCK_SIZE
    if ratio % HelloDB.BLOCK_SIZE != 0
      round(Int, floor(ratio)) + 1
    else
      ratio + 1
    end
  end

  ##############################################################################
  # Private
  ##############################################################################

  function _clear(buf::IOBuffer)
    buf.size = 0
  end

  # TODO: better filename handling.
  function _getfile(filemgr::FileMgr, filename)
    filename = basename(filename)
    if haskey(filemgr.openfiles, filename)
      filemgr.openfiles[filename]
    else
      file = open(filemgr.dbdir * "/$filename", "a+")
      filemgr.openfiles[filename] = file
      file
    end
  end

  """
  Will prevent you from catastrophe.
  """
  function _make_dbdir_file(dbdir)
    filepath = dbdir * "/.dbdir"
    file = open(dbdir * "/.dbdir", "w")
    close(file)
  end
end
