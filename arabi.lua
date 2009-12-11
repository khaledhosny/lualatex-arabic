arabi           = { }

arabi.module    = {
    name        = "arabi",
    version     = 0.5,
    date        = "2009/12/11",
    description = "Arabi Arabic typesetting system",
    author      = "Khaled Hosny & Hans Hagans",
    copyright   = "Khaled Hosny",
    license     = "GPLv3",
}

luatextra.provides_module(arabi.module)

dofile(kpse.find_file("arabi-char.lua"))
local data = characters.data

local function newtextdir(dir)
    local n = node.new("whatsit",7)
    n.dir = dir
    return n
end

function arabi.mirroring(hlist)
    local rtl = false
    if tex.textdir == "TRT" then
        rtl = true
    elseif tex.textdir == "TLT" then
        rtl = false
    end
    for n in node.traverse(hlist) do
        if n.id == node.id('hlist') then
            arabi.mirroring(n.list)
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

function arabi.numbers(hlist)
    local num = false

    for n in node.traverse(hlist) do
        if n.id == node.id('hlist') then
            arabi.numbers(n.list)
        end
        if n.id == node.id('glyph') then
            local dir  = data[n.char].direction
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

callback.add("pre_linebreak_filter", arabi.mirroring, "BiDi mirroring",       1)
callback.add("pre_linebreak_filter", arabi.numbers,   "BiDi number handling", 2)
callback.add("hpack_filter",         arabi.mirroring, "BiDi mirroring",       1)
callback.add("hpack_filter",         arabi.numbers,   "BiDi number handling", 2)

local months = {
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

months.tunisia = months.algeria

function arabi.month(n,locale) return tex.sprint(months[locale][n]) end

local abjad = {
    { "ا", "ب", "ج", "د", "ه", "و", "ز", "ح", "ط" },
    { "ي", "ك", "ل", "م", "ن", "س", "ع", "ف", "ص" },
    { "ق", "ر", "ش", "ت", "ث", "خ", "ذ", "ض", "ظ" },
    { "غ" },
}

function arabi.abjad(n)
    local result = ""
    if n >= 1000 then
        for i=1,math.floor(n/1000) do
            result = result .. abjad[4][1]
        end
        n = math.mod(n,1000)
    end
    if n >= 100 then
        result = result .. abjad[3][math.floor(n/100)]
        n = math.mod(n, 100)
    end
    if n >= 10 then
        result = result .. abjad[2][math.floor(n/10)]
        n = math.mod(n, 10)
    end
    if n >= 1 then
        result = result .. abjad[1][math.floor(n/1)]
    end
    if result == "ه" then result = "ه‍" end
    return result
end

function arabi.abjadnumerals(n) return tex.sprint(arabi.abjad(n)) end
