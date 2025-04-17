#!/usr/bin/env -S awk -f

BEGIN {
    REPLACE["NAME"]     = NAME     ? NAME : "UNKNOWN"
    REPLACE["DATE"]     = DATE     ? DATE :  ""
    REPLACE["REVISION"] = REVISION ? REVISION : ""
    REPLACE["CSS"]      = CSS      ? CSS : ""
    REPLACE["JS"]       = JS       ? JS : ""
    REPLACE["NOTES"]    = NOTES    ? NOTES : ""

    gsub(/\\n/, "\n", REPLACE["CSS"]);
    gsub(/\\n/, "\n", REPLACE["JS"]);
    gsub(/\\n/, "\n", REPLACE["MAIN"]);
    gsub(/\\n/, "\n", REPLACE["NOTES"]);

    MAIN = MAIN ? MAIN : ""
    for (pattern in REPLACE) {
        MAIN = replace("{" pattern "}", REPLACE[pattern], MAIN)
    }
    REPLACE["MAIN"] = MAIN
}

function replace(pattern, value, string,    idx, output)
{
    output = string
    idx = index(output, pattern)
    # Loop until no more occurrences are found
    while (idx > 0) {
        output = substr(output, 1, idx - 1) value substr(output, idx + length(pattern))
        idx = index(output, pattern)
    }
    return output
}

{
    output = $0
    for (pattern in REPLACE) {
        output = replace("{" pattern "}", REPLACE[pattern], output)
    }
    print output
}
