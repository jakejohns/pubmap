#!/usr/bin/env -S awk -f

BEGIN {
    FS="\t"
    if (! TEMPLATE_DIR) {
        print "Error: No template directory. Use -v TEMPLATE_DIR=path/to/templates" > "/dev/stderr"
        exit 1
    }

    TEMPLATE["article"] = loadTemplate("tr-bev.html")
    TEMPLATE["section"] = loadTemplate("section-bev.html")
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

    if ($COLS["TYPE"] != "major") next;
    if (Found[$COLS["STORY_ID"]]) next;
    Found[$COLS["STORY_ID"]] = 1;

    row = TEMPLATE["article"];
    story_id = $COLS["STORY_ID"]
    for (pattern in COLS) {
        gsub("\\{" pattern "\\}", $COLS[pattern], row)
    }
    Articles[story_id] = row
}

function formatTable(     table)
{
    table = ""
    for (i in Articles) {
        if (table != "") table = table "\n"
        table = table Articles[i]
    }
    return table
}

END {
    template = TEMPLATE["section"]
    gsub(/\{ARTICLES\}/, formatTable(), template)
    print template
}
