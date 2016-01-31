module FileMgrTest
  using Base.Test
  using HelloDB.FileMgrs

  function test_init()
    dbname = "some_test_db"
    dbdir = homedir() * "/$dbname"
    @test !isdir(dbdir)
    FileMgr(dbname)
    @test isdir(dbdir)
    rm(dbdir)
  end

  test_init()
end
