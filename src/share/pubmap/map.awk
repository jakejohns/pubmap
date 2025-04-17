#!/usr/bin/env -S awk -f

BEGIN {
    FS="\t"
    if (! TEMPLATE_DIR) {
        print "Error: No template directory. Use -v TEMPLATE_DIR=path/to/templates" > "/dev/stderr"
        exit 1
    }

    TEMPLATE["element"] = loadTemplate("element.html")
    TEMPLATE["flat"]    = loadTemplate("flat.html")
    TEMPLATE["spread"]  = loadTemplate("spread.html")
    TEMPLATE["section"]  = loadTemplate("section-map.html")
}

function loadTemplate(name,     path, template)
{
    path = TEMPLATE_DIR "/" name
    template = ""

    while ((getline line < path) > 0) {
        template = template line "\n"
    }

    if (! template) {
        printf "Error: Could not read template %s\n", TEMPLATE_FILE > "/dev/stderr"
        exit 1
    }

    return template;
}

NR == 1 {
    for (i=1; i<=NF; i++) {
        COLS[$i] = i
    }
}

function eleIndex(flat, name, count, list, bp,    cur)
{
    if (count < 2) return ""
    Found[name]++
    cur = Found[name]
    if (bp) if (list ~ ","flat"$") { cur =1 } else { cur = cur + 1 }
    return sprintf("<span class=\"index\">(%d/%d)</span>", cur, count)
}

function eleJumps(flat, name, count, list, bp,    last, flats, key, jump)
{
    if (count < 2) return ""
    last = split(list, flats, ",")
    if (bp) { # jumps from back page
        if (flats[last] == flat) {
            jump = sprintf("cont: p%s", flats[1])
        } else if (flat == flats[1]) {
            jump = "from: backpage"
        }
    } else {
        for (key in flats) {
            if (flats[key] == flat) {
                if (flats[key + 1] && flats[key + 1] != flat + 1) {
                    jump = sprintf("cont: p%s", flats[key + 1])
                }
                if (flats[key - 1] && flats[key - 1] != flat - 1) {
                    jump = sprintf("from: p%s", flats[key - 1])
                }
            }
        }
    }
    if (jump) return sprintf("<span class=\"jump\">%s</span>", jump);
}

function openSplit(weight)
{
    return sprintf("<div style=\"flex-grow: %s;\" class=\"split\">", weight)
}

NR > 1 {
    element = TEMPLATE["element"]

    for (pattern in COLS) {
        gsub("\\{" pattern "\\}", $COLS[pattern], element)
    }

    gsub(/\{INDEX\}/, eleIndex($COLS["FLAT"], $COLS["NAME"], $COLS["FLAT_COUNT"], $COLS["FLAT_LIST"], $COLS["BP"]), element)
    gsub(/\{JUMPS\}/, eleJumps($COLS["FLAT"], $COLS["NAME"], $COLS["FLAT_COUNT"], $COLS["FLAT_LIST"], $COLS["BP"]), element)

    for (i=0; i<$COLS["SPLIT_OPEN"]; i++) element = openSplit($COLS["WEIGHT"]) element
    for (i=0; i<$COLS["SPLIT_CLOSE"]; i++) element = element "</div>"

    flat_no = $COLS["FLAT"]

    if (! FlatElements[flat_no]) {
        FlatCount++
    } else {
        FlatElements[flat_no] = FlatElements[flat_no] "\n"
    }

    FlatElements[flat_no] = FlatElements[flat_no] element
}

function formatFlat(number,     flat)
{
    flat = TEMPLATE["flat"]
    gsub(/\{FLAT_NO\}/, number, flat)
    gsub(/\{ELEMENTS\}/, FlatElements[number], flat)
    return flat
}

function formatSpread(left, right,  spread)
{
    spread = TEMPLATE["spread"]
    gsub(/\{LEFT\}/, formatFlat(left), spread)
    gsub(/\{RIGHT\}/, formatFlat(right), spread)
    return spread
}

function formatMap(     map)
{
    map = formatSpread(FlatCount, 1)
    for (i=2; i<FlatCount; i+=2) {
        map = map "\n" formatSpread(i, i+1);
    }
    return map
}

END {
    template = TEMPLATE["section"]
    gsub(/\{MAP\}/, formatMap(), template)
    print template
}
