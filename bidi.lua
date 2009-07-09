--  Copyright (C) 2009 by Khaled Hosny <khaledhosny@eglug.org>
--  
--  This work is under the CC0 license.


bidi  = { }

bidi.module = {
  name = "bidi",
  version = 0.4,
  date = "2009/04/29",
  description = "Bidirectional typesetting in LuaTeX",
  author = "Khaled Hosny",
  copyright = "Khaled Hosny",
  license = "CC0",
}

luatextra.provides_module(bidi.module)

dofile(kpse.find_file("char-def.lua"))
local data = characters.data

local function newtextdir(dir)
  local n = node.new("whatsit",7)
  n.dir = dir
  return n
end

function bidi.mirroring(hlist)
  local rtl = false
  if tex.textdir == "TRT" then
    rtl = true
  elseif tex.textdir == "TLT" then
    rtl = false
  end
  for n in node.traverse(hlist) do
    if n.id == node.id('hlist') then
      bidi.mirroring(n.list)
    end
    if n.id == node.id("whatsit") and n.subtype == 7 then
      if n.dir == "+TRT" or n.dir == "-TLT" then
        rtl = true
      elseif n.dir == "-TRT" or n.dir == "+TLT" then
        rtl = false
      end
    end
    if n.id == node.id('glyph') then
      if rtl then
      local char = n.char
      local mirror = data[char].mirror
        if mirror then
          n.char = mirror
        end
      end
    end
  end
  return hlist
end

function bidi.numbers(hlist)
  local num = false

  for n in node.traverse(hlist) do
    if n.id == node.id('hlist') then
      bidi.numbers(n.list)
    end
    if n.id == node.id('glyph') then
      local dir  = data[n.char].direction
      --texio.write_nl(dir)
      --if dir == "ar" or dir == "es" or dir == "cs" then dir = "en" end
      if num then
        if dir == "en" then
        else
          hlist, inserted = node.insert_before(hlist,n,newtextdir("-TLT"))
          num = false
        end
      elseif dir == "en" then
        if n.next and n.next.id == node.id('glyph') then
          hlist, inserted = node.insert_before(hlist,n,newtextdir("+TLT"))
          num = true
end
      end
    elseif num then
      hlist, inserted = node.insert_before(hlist,n,newtextdir("-TLT"))
      num = false
    end
  end
  return hlist
end

callback.add("pre_linebreak_filter", bidi.mirroring, "BiDi mirroring", 1)
callback.add("pre_linebreak_filter", bidi.numbers, "BiDi number handling", 2)
callback.add("hpack_filter", bidi.mirroring, "BiDi mirroring", 1)
callback.add("hpack_filter", bidi.numbers, "BiDi number handling", 2)
