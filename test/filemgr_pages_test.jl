module TestFileMgrPages
  using Base.Test
  using HelloDB.Pages
  using HelloDB.Blocks
  using HelloDB

  function test_getint()
    page = Page(false)
    write(page.contents, 5, 2, 6)
    @test getint(page, 1 * sizeof(Int)) == 2
  end

  function test_setint()
    page = Page(false)
    write(page.contents, 0, 0, 0, 0)
    setint(page, 2, 1)
    seek(page.contents, 2)
    @test read(page.contents, Int) == 1
  end

  function test_getstring()
    page = Page(false)
    write(page.contents, 0x00, 5, 'P', 'e', 'n', 'i', 's', 0x00)
    @test getstring(page, 1) == "Penis"
  end

  function test_setstring()
    page = Page(false)
    write(page.contents, 0x00, 0x00)
    setstring(page, 2, "boobs")
    @test getstring(page, 2) == "boobs"
    @test page.contents.size == 2 + length("boobs") + sizeof(Int)
  end

  function test_read()
    dbname = "test_filemgr_pages_read"
    setdb(dbname)
    filename = DB.filemgr.dbdir * "/test_read"

    f = open(filename, "w+")
    write(f, 2, 'h', 'i')
    close(f)

    block = Block(filename, 0)
    page = Page()
    read(page, block)
    @test getstring(page, 0) == "hi"
    dropdb(DB)
  end

  function test_write()
    dbname = "test_filemgr_pages_write"
    setdb(dbname)
    filename = "test_write"

    block1 = Block(filename, 0)
    block2 = Block(filename, 1)
    block3 = Block(filename, 4)

    page1 = Page()
    setstring(page1, 0, "STRING ONE")

    page = Page()
    setstring(page, 0, "STRING TWO")

    write(page1, block1)
    write(page, block2)
    write(page1, block3)

    readpage1 = Page()
    readpage2 = Page()
    readpage3 = Page()

    read(readpage1, block1)
    read(readpage2, block2)
    read(readpage3, block3)

    @test getstring(readpage1, 0) == "STRING ONE"
    @test getstring(readpage2, 0) == "STRING TWO"
    @test getstring(readpage3, 0) == "STRING ONE"
    dropdb(DB)
  end

  function test_append()
    dbname = "test_filemgr_pages_append"
    setdb(dbname)
    filename = "test_append"

    block1 = Block(filename, 0)
    block2 = Block(filename, 2)

    page1 = Page()
    setstring(page1, 0, "ABC")

    newpage = Page()
    setstring(newpage, 0, "DEF")

    write(page1, block1)
    write(page1, block2)
    newblock = append(newpage, filename)

    readpage1 = Page()
    readpage2 = Page()
    readpage3 = Page()

    read(readpage1, block1)
    read(readpage2, block2)
    read(readpage3, newblock)

    @test getstring(readpage1, 0) == "ABC"
    @test getstring(readpage2, 0) == "ABC"
    @test getstring(readpage3, 0) == "DEF"
    @test newblock.number == 3

    dropdb(DB)
  end

  @test string_size(2) == sizeof(Int) + (2) # TODO; not sizeof(Char) == 4

  test_getint()
  test_setint()
  test_getstring()
  test_setstring()
  test_read()
  test_write()
  test_append()
end
