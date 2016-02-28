include("../src/HelloDB.jl")

module TestHelpers
  using HelloDB: setdb, dropdb, DB

  function set_test_db()
    setdb("test_db")
  end

  function drop_test_db()
    if DB != false
      dropdb(DB)
    end
  end

  function src_require(filename)
    require("../src/$(filename)")
  end
end
