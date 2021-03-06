include("TestHelpers.jl")

using Base.Test
using DataFrames
using TestHelpers: drop_test_db

fatalerrors = length(ARGS) > 0 && ARGS[1] == "-f"
quiet = length(ARGS) > 0 && ARGS[1] == "-q"
anyerrors = false

my_tests = [
  "filemgr_block.jl",
  "filemgr_pages_test.jl",
  "filemgr_test.jl",
  "logmgrs_test.jl"
]

println("Running tests:")

for my_test in my_tests
  try
    include(my_test)
    drop_test_db()
    println("\t\033[1m\033[32mPASSED\033[0m: $(my_test)")
  catch e
    anyerrors = true
    drop_test_db()
    println("\t\033[1m\033[31mFAILED\033[0m: $(my_test)")
    if fatalerrors
      rethrow(e)
    elseif !quiet
      showerror(STDOUT, e, backtrace())
      println()
    end
  end
end

if anyerrors
  throw("Tests failed")
end
