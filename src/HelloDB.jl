module HelloDB
  ##############################################################################
  # Constants && Globals
  ##############################################################################

  const BLOCK_SIZE = 400
  global DB = false

  ##############################################################################
  # Includes
  ##############################################################################

  for (dir, filename) in [
      ("FileMgr", "Blocks.jl"),
      ("FileMgr", "FileMgrs.jl"),
      ("FileMgr", "Pages.jl"),
    ]

    include(joinpath(dir, filename))
  end

  using HelloDB.FileMgrs

  ##############################################################################
  # Exports
  ##############################################################################

  export Database,
         FileMgrs,
           Blocks,
           Pages

  export DB, BLOCK_SIZE

  export reset, setdb, dropdb, is_dbdir

  ##############################################################################
  # Implementation
  ##############################################################################

  type Database
    filemgr::FileMgr

    function Database(dbname::AbstractString)
      new(FileMgr(dbname))
    end
  end


  ##############################################################################
  # Globals
  ##############################################################################

  function reset()
    global DB
    DB = false
  end

  function dropdb(db::Database)
    if is_dbdir(db.filemgr.dbdir)
      rm(db.filemgr.dbdir; recursive=true)
      reset()
    else
      throw("YOU ALMOST DELETED $(db.filemgr.dbdir) YOU DINGUS!!")
    end
  end

  """
  To prevent screwing up wrong dir. A true dbdir has a .dbdir file
  """
  function is_dbdir(dirpath::AbstractString)
    length(filter(x->x==".dbdir", readdir(dirpath))) == 1
  end

  function setdb(dbname)
    global DB
    DB = Database(dbname)
  end
end
