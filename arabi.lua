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

luatexbase.provides_module(arabi.module)

arabi.options = {
    locale = "default",
    global = false,
}

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

function arabi.month(locale, month)
    local l = locale or arabi.options.locale
    local m = month  or tex.month
    return months[l][m]
end

function arabi.today(locale)
    local l = locale or arabi.options.locale
    local d = string.format("%d %s %d", tex.day, arabi.month(l), tex.year)
    return d
end

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

function arabi.catcodes()
    local arabic_letters = {
        "ا", "ء", "أ", "إ", "آ", "ب", "ت", "ث", "ج", "ح", "خ", "د",
        "ذ", "ر", "ز", "س", "ش", "ص", "ض", "ط", "ظ", "ع", "غ", "ف",
        "ق", "ك", "ل", "م", "ن", "ه", "ة", "و", "ؤ", "ي", "ى", "ئ",
    }

    for c in pairs(arabic_letters) do
        tex.sprint(string.format([[\catcode`%s=11]], c))
    end
end
