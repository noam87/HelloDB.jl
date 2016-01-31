module TestFileMgrBlock
  using Base.Test
  using HelloDB.Blocks

  block1 = Block("foo", 1)
  block2 = Block("bar", 2)

  @test block1 == block1
  @test block1 != block2

  @test hash(block1) != hash(block2)
  @test hash(block1) == hash(block1)

  @test tostring(block1) == "Block[filename: foo, number: 1]"
end
