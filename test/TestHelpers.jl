include("../src/HelloDB.jl")

module TestHelpers
  function src_require(filename)
    require("../src/$(filename)")
  end
end
