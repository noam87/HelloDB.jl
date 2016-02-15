"""
> Those who cannot remember the past, are condemned to repeat it. -- Wiz Khalifa

### The Logging Algorithm

1. Allocate one page (P) to hold the contents of the last block of the logfile.
2. When a new log record is submitted:
  1. If there's no room in P, write P to disk and clear its contents.
  2. Else add the new log records to P.
3. When DB requests that a log be written to disk:
  1. If that record is in P, write P to disk.

Each log record is identified by a Log Record Number (LSN).
"""
module LogMgrs
  using HelloDB.Pages: Page, append, setint, setstring
  import HelloDB.Pages: append
  using HelloDB.Blocks: Block
  using HelloDB.FileMgrs: FileMgr, size
  using HelloDB: DB
  using HelloDB.Data: INT_SIZE, BLOCK_SIZE, string_size
  using HelloDB.LogIterators: LogIterator

  ##############################################################################
  # Exports
  ##############################################################################

  export LogMgr, append, flush, iterator

  ##############################################################################
  # Implementation
  ##############################################################################

  type LogMgr
    logfile::AbstractString
    logpage::Page
    currentblock::Block
    currentpos::Int
    lastpos::Int

    function LogMgr()
      logfile = DB.filemgr.dbdir * "/log"
      LogMgr(logfile)
    end

    function LogMgr(logfile::AbstractString)
      logsize = size(DB.filemgr, logfile)
      logpage = Page()
      lastpos = 0

      if (logsize == 0)
        currentpos = INT_SIZE
        _set_last_record_pos(logpage, currentpos, lastpos)
        currentblock = append(logpage, logfile)
      else
        currentblock = Block(logfile, logsize - 1)
        read(logpage, currentblock)
        currentpos = _get_last_record_pos(logpage, lastpos) + INT_SIZE
      end

      new(logfile, logpage, currentblock, currentpos, lastpos)
    end
  end

  RecVal = Union{Int, AbstractString}

  """
  Add a new record to the log. Returns int value of record LSN.
  A log record is an array of chars and ints (vals),
  the constraint being that they must fit into a page.
  """
  function append(logmgr::LogMgr, record::Vector)
    recsize = INT_SIZE
    [ recsize += _size(val) for val in record ]
    if logmgr.currentpos + record >= BLOCK_SIZE
      _flush(logmgr)
      _append_newblock(logmgr)
    end
    [ _appendval(logmgr, val) for val in record]
    _finalize_record(logmgr)
    _currentlsn(logmgr)
  end

  """
  Flush lsn into logpage if lsn >= the current lsn.
  """
  function flush(logmgr::LogMgr, lsn)
    if lsn >=  _currentlsn(logmgr)
      _flush(logmgr)
    end
  end

  """
  Flushes content then returns new LogIterator.
  """
  function iterator(logmgr::LogMgr)
    _flush(logmgr)
    LogIterator(logmgr.currentblock)
  end

  ##############################################################################
  # Private
  ##############################################################################

  function _append_newblock(logmgr::LogMgr)
    _set_last_record_pos(logmgr, 0)
    logmgr.currentblock = append(logmgr.logpage, logmgr.logfile)
    logmgr.currentpos = INT_SIZE
  end

  function _appendval(logmgr::LogMgr, val::AbstractString)
    setstring(logmgr.logpage, logmgr.currentpos, val)
    logmgr.currentpos += _size(val)
  end

  function _appendval(logmgr::LogMgr, val::Int)
    setint(logmgr.logpage, logmgr.currentpos, val)
    logmgr.currentpos += _size(val)
  end

  function _currentlsn(logmgr::LogMgr)
    logmgr.currentblock.number
  end

  """
  The structure of a logpage is thus:

  1. The first value on the page is an Int that points end of the last record.
  2. At the end of each record, there is an Int value that points to the
  location of the end of the previous record.

      (Normalized to 1-byte chars and ints for simplicity; in actuality each
      string is of length CHAR_SIZE * string_length + INT_SIZE
      (see REF#stringsize))

      |0|a|b|c|0|          <- logpage after appending "abc".
      |7|a|b|c|0|d|e|4|    <- logpage after appending "de"

  """
  function _finalize_record(logmgr::LogMgr)
    lastpos = _get_last_record_pos(logmgr)
    setint(logmgr.logpage, logmgr.currentpos, lastpos)
    logmgr.currentpos += INT_SIZE
  end

  function _flush(logmgr)
    write(logmgr.logpage, currentblock)
  end

  function _get_last_record_pos(logmgr::LogMgr)
    _get_last_record_pos(logmgr.logpage, logmgr.lastpos)
  end

  function _get_last_record_pos(page::Page, pos::Int)
    getint(page, pos)
  end

  function _set_last_record_pos(logmgr::LogMgr, pos::Int)
    _set_last_record_pos(logmgr.logpage, logmgr.lastpos, pos)
  end

  function _set_last_record_pos(page::Page, lastpos::Int, pos::Int)
    setint(page, lastpos, pos)
  end

  function _size(val::AbstractString)
    string_size(length(val))
  end

  function _size(val::Int)
    INT_SIZE
  end
end
