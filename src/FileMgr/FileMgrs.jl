"""
HelloDB saves data into files. Data is broken up into blocks, and
fetched/manipulated within a `Page` buffer.

Strings are saved withing a page as an int, representing the length of the
string, followed by chars.
"""
module FileMgrs
  using HelloDB
  using HelloDB.Blocks
  using HelloDB.Data: BLOCK_SIZE
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
        log("creating new dbdir file at=($(dbdir))")
        mkdir(dbdir)
        _make_dbdir_file(dbdir)
      end

      # clear leftover temp files
      tempfiles = filter(f->startswith(f, "temp"), readdir(dbdir))
      log("clearing tempfiles")
      [rm(dbdir + "/$file") for file in tempfiles]

      log("initializing new FileMgr")
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

  """
  Size of file `filename`, in blocks`::Block`.
  """
  function size(filemgr::FileMgr, filename::AbstractString)
    file = _getfile(filemgr, filename)
    ratio = filesize(file) / BLOCK_SIZE
    if ratio % BLOCK_SIZE != 0
      round(Int, floor(ratio)) + 1
    else
      ratio
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
