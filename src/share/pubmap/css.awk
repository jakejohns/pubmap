#!/usr/bin/env -S awk -f

function css(file,  line) {
    while ((getline line < file) > 0) {
        gsub(/^[ \t]+|[ \t]+$/, "", line);
        printf "%s", line;
        if (line ~ /}|@/) { print; }
    }
}
BEGIN {
    for (i in ARGV) (i > 1) && css(ARGV[i])
    print ":root{" ;
}
FILENAME == "-" { printf("  --color%d: %s;\n", NR, $0) }
END { print "}" ; }
