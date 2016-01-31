module TestFileMgrPages
  using Base.Test
  using HelloDB.Pages

  function test_getint()
    page = Page(realfile=false)
    write(page.contents, 5, 2, 6)
    @test getint(page, 1 * sizeof(Int)) == 2
  end

  function test_setint()
    page = Page(realfile=false)
    write(page.contents, 0, 0, 0, 0)
    setint(page, 2, 1)
    seek(page.contents, 2)
    @test read(page.contents, Int) == 1
  end

  function test_getstring()
    page = Page(realfile=false)
    write(page.contents, 0x00, 5, 'P', 'e', 'n', 'i', 's', 0x00)
    @test getstring(page, 1) == "Penis"
  end

  function test_setstring()
    page = Page(realfile=false)
    write(page.contents, 0x00, 0x00)
    setstring(page, 2, "boobs")
    @test getstring(page, 2) == "boobs"
    @test page.contents.size == 2 + length("boobs") + sizeof(Int)
  end

  function test_read()
  end

  @test string_size(2) == sizeof(Int) + (2) # TODO; not sizeof(Char) == 4

  test_getint()
  test_setint()
  test_getstring()
  test_setstring()
  test_read()
end
