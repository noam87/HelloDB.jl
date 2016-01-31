"""
HelloDB saves data into files. Data is broken up into blocks, and
fetched/manipulated within a `Page` buffer.
"""
module FileMgrs
  ##############################################################################
  # Exports
  ##############################################################################

  export FileMgr
  export read!

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
      end

      # clear leftover temp files
      tempfiles = filter(f->startswith("temp"), readdir(dbdir))
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
  function read!(fmgr::FileMgr, block::Block, buf::IOBuffer)
    clear(buf)
    file = getfile(block.filename)
    seek(file, block.number * buf.maxsize)
    write(buf, readbytes(file, buf.maxsize))
  end


  ##############################################################################
  # Private
  ##############################################################################

  function clear!(buf::IOBuffer)
    buf.size = 0
  end

  function getfile()
  end
end
