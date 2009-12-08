arabic        = { }

arabic.module = {
  name        = "arabic",
  version     = 0.4,
  date        = "2009/04/29",
  description = "Bidirectional typesetting in LuaTeX",
  author      = "Khaled Hosny",
  copyright   = "Khaled Hosny",
  license     = "CC0",
}

luatextra.provides_module(arabic.module)

dofile(kpse.find_file("arabic-char.lua"))
local data = characters.data

local function newtextdir(dir)
  local n = node.new("whatsit",7)
  n.dir = dir
  return n
end

function arabic.mirroring(hlist)
  local rtl = false
  if tex.textdir == "TRT" then
    rtl = true
  elseif tex.textdir == "TLT" then
    rtl = false
  end
  for n in node.traverse(hlist) do
    if n.id == node.id('hlist') then
      arabic.mirroring(n.list)
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

function arabic.numbers(hlist)
  local num = false

  for n in node.traverse(hlist) do
    if n.id == node.id('hlist') then
      arabic.numbers(n.list)
    end
    if n.id == node.id('glyph') then
      local dir  = data[n.char].direction
      --texio.write_nl(n.char)
      --texio.write_nl(dir)
      --if dir == "ar" or dir == "es" or dir == "cs" then dir = "en" end
      if num then
        if dir == "en" or dir == "an" then
        else
          hlist, inserted = node.insert_before(hlist,n,newtextdir("-TLT"))
          num = false
        end
      elseif dir == "en" or dir == "an" then
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

callback.add("pre_linebreak_filter", arabic.mirroring, "BiDi mirroring",       1)
callback.add("pre_linebreak_filter", arabic.numbers,   "BiDi number handling", 2)
callback.add("hpack_filter",         arabic.mirroring, "BiDi mirroring",       1)
callback.add("hpack_filter",         arabic.numbers,   "BiDi number handling", 2)

arabic.months = {
	default = {
		"يناير", "فبراير", "مارس",
		"أبريل", "مايو", "يونيو",
		"يوليو", "أغسطس", "سبتمبر",
		"أكتوبر", "نوفمبر", "ديسمبر",
	},
	mashriq = {
		"كانون الثاني", "شباط", "آذار",
		"نيسان", "أيار", "حزيران",
		"تموز", "آب", "أيلول",
		"تشرين الأول", "تشرين الثاني", "كانون الأول",
	},
	libya = {
		"أي النار", "النوار", "الربيع",
		"الطير", "الماء", "الصيف",
		"ناصر", "هانيبال", "الفاتح",
		"التمور", "الحرث", "الكانون",
	},
	morocco = {
		"يناير", "فبراير", "مارس",
		"أبريل", "ماي", "يونيو",
		"يوليوز", "غشت", "شتنبر",
		"أكتوبر", "نونبر", "دجنبر",
	},
	algeria = {
		"جانفي", "فيفري", "مارس",
		"أفريل", "ماي", "جوان",
		"جويلية", "أوت", "سبتمبر",
		"أكتوبر", "نوفمبر", "ديسمبر",
	},
	mauritania = {
		"يناير", "فبراير", "مارس",
		"إبريل", "مايو", "يونيو",
		"يوليو", "أغشت", "شتمبر",
		"أكتوبر", "نوفمبر", "دجمبر",
	},
}

arabic.months.tunisia = arabic.months.algeria

function arabic.month(n,locale)
	tex.sprint(arabic.months[locale][n])
end
