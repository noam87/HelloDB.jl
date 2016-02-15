module LogRecords
  using HelloDB.Pages: Page, getint
  using HelloDB.Data: CHAR_SIZE, INT_SIZE, string_size

  abstract AbstractLogRecord

  type BasicLogRecord <: AbstractLogRecord
    page::Page
    pos::Int
  end

  function nextint(record::AbstractLogRecord)
    result = getint(record.page, record.pos)
    record.pos += INT_SIZE
    result
  end

  function next_string(record::AbstractLogRecord)
    result = getstring(record.page, record.pos)
    record.pos += string_size(length(result))
  end
end
