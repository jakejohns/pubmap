#!/usr/bin/env -S awk -f

BEGIN {
    FS="\t"
    if (! TEMPLATE_DIR) {
        print "Error: No template directory. Use -v TEMPLATE_DIR=path/to/templates" > "/dev/stderr"
        exit 1
    }

    MPF = MPF ? MPF : 6

    TEMPLATE["article"] = loadTemplate("tr-articles.html")
    TEMPLATE["extra"] = loadTemplate("tr-extras.html")
    TEMPLATE["section"] = loadTemplate("section-ee.html")
}

function loadTemplate(name,     path, template)
{
    path = TEMPLATE_DIR "/" name
    template = ""

    while ((getline line < path) > 0) {
        template = template line "\n"
    }

    if (! template) {
        printf "Error: Could not read template %s\n", name > "/dev/stderr"
        exit 1
    }

    return template;
}

NR == 1 {
    for (i=1; i<=NF; i++) {
        COLS[$i] = i
    }
}

NR > 1 {
    if (! Flats[$COLS["FLAT"]]) { Flats[$COLS["FLAT"]] = 1; FlatCount = FlatCount + 1 }
    if (Found[$COLS["STORY_ID"]]) next;
    Found[$COLS["STORY_ID"]] = 1;

    if ($COLS["TYPE"] == "major"){
        row = TEMPLATE["article"];
        PageTotal = PageTotal + $COLS["TOTAL_PAGES"]
    } else {
        row = TEMPLATE["extra"];
    }

    story_id = $COLS["STORY_ID"]
    for (pattern in COLS) {
        gsub("\\{" pattern "\\}", $COLS[pattern], row)
    }
    gsub(/\{FLAT_LINKS\}/, flatLinks($COLS["FLAT_LIST"]), row)

    if ($COLS["TYPE"] == "major") {
        Articles[story_id] = row
    } else {
        Extras[story_id] = row
    }
}

function formatArticleTable(     table)
{
    table = ""
    for (i in Articles) {
        if (table != "") table = table "\n"
        table = table Articles[i]
    }

    return table
}

function formatExtrasTable(     table)
{
    table = ""
    for (i in Extras) {
        if (table != "") table = table "\n"
        table = table Extras[i]
    }
    return table
}

function flatLinks(flatList,    items, i, attr, output)
{
    split(flatList, items, ",")
    output = ""
    for (i in items) {
        if (output != "") output = output ","
        output = output sprintf("<a class=\"flatlink\" href=\"#flat-%d\">%d</a>", items[i], items[i])
    }
    return output
}

END {
    template = TEMPLATE["section"]
    article_foot = sprintf("<th>TOTAL</th><td id=\"flat-count\">%d</td><td>~%.1f</td>", FlatCount, PageTotal)
    gsub(/\{ARTICLES\}/, formatArticleTable(), template)
    gsub(/\{ARTICLE_FOOT\}/, article_foot, template)
    gsub(/\{EXTRAS\}/, formatExtrasTable(), template)
    gsub(/\{MPF\}/, MPF, template)
    print template
}
