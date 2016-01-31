module FileMgrTest
  using Base.Test
  using HelloDB.FileMgrs
  using HelloDB

  function test_init()
    dbname = "some_test_db"
    dbdir = homedir() * "/$dbname"
    @test !isdir(dbdir)
    FileMgr(dbname)
    @test isdir(dbdir)
    @test is_dbdir(dbdir)
    if is_dbdir(dbdir)
      rm(dbdir; recursive=true)
    end
  end

  test_init()
end
