"""
Implementation of iterator used in `LogMgrs` module.

Iterates within a `Page` backwards block by block until reaching the 0th block,
at which point I am appointed emperor of China.
"""
module LogIterators
  using HelloDB.Blocks: Block
  using HelloDB.Pages: Page, getint
  using HelloDB: DB
  using HelloDB.Data: INT_SIZE

  ##############################################################################
  # Exports
  ##############################################################################

  export LogIterator
  export hasnext

  ##############################################################################
  # Implementation
  ##############################################################################

  type LogIterator
    block::Block
    page::Page
    currentrec::Int

    function LogIterator(block::Block)
      page = Page()
      read(page, block)

      new(block, page, getint(page, DB.LogMgr.lastpos))
    end
  end

  function hasnext(itr::LogIterator)
    itr.currentrec > 0 || itr.block.number > 0
  end

  function next(itr::LogIterator)
    if itr.currentrec == 0
      _moveto_next_block(itr)
    end
    itr.currentrec = getint(itr.page, currentrec)
    BasicLogRecord(itr.page, itr.currentrec + INT_SIZE)
  end

  ##############################################################################
  # Private
  ##############################################################################

  function _moveto_next_block(itr)
    block = Block(itr.block.filename, itr.block.number - 1)
    read(itr.page, block)
    itr.currentrec = getint(page, DB.LogMgr.lastpos)
  end
end
