module HelloDB
  ##############################################################################
  # Constants && Globals
  ##############################################################################

  global DB = false

  ##############################################################################
  # Includes
  ##############################################################################

  for (dir, filename) in [
      ("FileMgr", "Data.jl"),
      ("FileMgr", "Blocks.jl"),
      ("FileMgr", "FileMgrs.jl"),
      ("FileMgr", "Pages.jl"),
      ("logging", "LogRecords.jl"),
      ("logging", "LogIterators.jl"),
      ("logging", "LogMgrs.jl"),
    ]

    include(joinpath(dir, filename))
  end

  using HelloDB.FileMgrs
  using HelloDB.LogMgrs: LogMgr

  ##############################################################################
  # Exports
  ##############################################################################

  export Database,
         Data,
         FileMgrs,
           Blocks,
           Pages,
         LogMgrs,
           LogRecords,
           LogIterators

  export DB

  export reset, setdb, dropdb, is_dbdir

  ##############################################################################
  # Implementation
  ##############################################################################

  type Database
    dbname
    filemgr
    logmgr

    function Database(dbname::AbstractString)
      new(dbname, false, false)
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

  using Debug
  function setdb(dbname)
    global DB
    DB = Database(dbname)
    DB.filemgr = FileMgr(dbname)
    DB.logmgr = LogMgr()
  end
end
