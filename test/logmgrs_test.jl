module TestLogMgrs
  using Base.Test
  using HelloDB.LogMgrs: LogMgr, append, flush, iterator
  using TestHelpers: set_test_db, drop_test_db
  using HelloDB: DB
  using HelloDB.Data: INT_SIZE, BLOCK_SIZE
  using HelloDB.LogIterators: LogIterator

  function test_init()
    # with no previous logfile
    set_test_db()
    filemgr = LogMgr()
    logfile = DB.filemgr.dbdir * "/log"
    @test isfile(logfile)
    @test filemgr.currentpos == INT_SIZE

    # with previous existing logfile
    file = open(logfile, "w")
    write(file, "foo bar baz")
    close(file)
    logmgr = LogMgr()
    @test logmgr.currentpos > INT_SIZE
    drop_test_db()
  end

  function test_append()
    set_test_db()
    logmgr = LogMgr()
    lsn = append(logmgr, ["FOO", "BAR"])
    @test lsn == 0
    lsn = append(logmgr, [ASCIIString(fill('a', BLOCK_SIZE))])
    @test lsn == 1
    drop_test_db()
  end

  function test_flush()
    set_test_db()
    logmgr = LogMgr()
    append(logmgr, ["FOO", "BAR"])
    flush(logmgr, 1)
    logmgr = LogMgr()
    @test logmgr.currentpos > INT_SIZE
    drop_test_db()
  end

  function test_iterator()
    set_test_db()
    logmgr = LogMgr()
    append(logmgr, ["FOO", "BAR"])
    it = iterator(logmgr)
    @test typeof(it) ==  LogIterator

    # test that prev block flushed
    logmgr = LogMgr()
    @test logmgr.currentpos > INT_SIZE
    drop_test_db()
  end

  test_init()
  test_append()
  test_flush()
  test_iterator()
end
