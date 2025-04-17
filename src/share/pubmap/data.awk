#!/usr/bin/env -S awk -f

BEGIN {
    FS=","
    OFS="\t"

    MPF = MPF ? MPF : 6

    EleId = 0;
    StoryCount = 1;
}

$0 ~ /^###/ { exit; }

function trim(str)
{
    sub(/^[[:space:]]+/, "", str)
    sub(/[[:space:]]+$/, "", str)
    return str
}

function getName(spec)
{
    gsub(/<|>|\^|#.*|:[0-9]+|@|\]|\[|\*|_|\(|\)/, "", spec)
    return trim(spec)
}

function isMinor(spec) { return match(spec, /\*/) ; }

function getType(spec) { return isMinor(spec) ? "minor" : "major" ; }

function getWeight(spec) {
    if (match(spec, /:[0-9]+/)) {
        return substr(spec, RSTART + 1, RLENGTH - 1)
    }
    return 1
}

function countSplitOpen(spec) { return gsub(/\[|\(/, "", spec); }
function countSplitClose(spec) { return gsub(/\]|\)/, "", spec); }

function getDesc(str) {
    pos = index(str, "#");
    if (pos > 0) {
        str = trim(substr(str, pos + 1))
        gsub(/\]|\)/, "", str)
        return str;
    }
    return "..."
}

function getHoriz(spec)
{
    if (index(spec, "<") > 0) return "left";
    if (index(spec, ">") > 0) return "right";
    return "none";
}

function getAlign(spec)
{
    if (index(spec, "_") > 0) return "right";
    return "none";
}

function getVert(spec)
{
    if (index(spec, "^") > 0) return "top";
    return "none";
}

{
    delete flat_ele
    flat_volume = 0
    for (i=1; i <= NF; i++) {
        EleId++

        flat_ele[i] = EleId;
        name = getName($i)

        FlatEles[NR] = FlatEles[NR] "#" name "#"

        Flat[EleId] = NR
        Pos[EleId] = NF
        Spec[EleId] = trim($i)
        Name[EleId] = name
        Type[EleId] = getType($i)
        Weight[EleId] = getWeight($i)
        SplitOpen[EleId] = countSplitOpen($i)
        SplitClose[EleId] = countSplitClose($i)
        Horiz[EleId] = getHoriz($i)
        Vert[EleId] = getVert($i)
        Desc[EleId] = getDesc($i)
        Align[EleId] = getAlign($i)

        Story[EleId] = StoryId[name] ? StoryId[name] : (StoryId[name] = StoryCount++)

        if (EleFlatList[name] != "") EleFlatList[name] = EleFlatList[name] ","
        EleFlatList[name] = EleFlatList[name] NR
        EleFlatCount[name]++

        if (! isMinor($i)) {
            flat_volume = flat_volume + Weight[EleId]
        }
    }

    for (i=1; i <= NF; i++) {
        eid = flat_ele[i]
        Pages[eid] = sprintf("%.1f", MPF * (Weight[eid]/flat_volume))
        TotalPages[Name[eid]] = TotalPages[Name[eid]] + Pages[eid]
    }
    FlatCount++
}

function printInstance(eid)
{
    print eid,
          Flat[eid],
          Story[eid],
          Pos[eid],
          Name[eid],
          Type[eid],
          Weight[eid],
          SplitOpen[eid],
          SplitClose[eid],
          Horiz[eid],
          Vert[eid],
          Align[eid],
          Desc[eid],
          Pages[eid],
          TotalPages[Name[eid]],
          EleFlatCount[Name[eid]],
          EleFlatList[Name[eid]],
          (FlatEles[FlatCount] ~ "#" Name[eid] "#") ? 1 : 0,
          Spec[eid]
}

END {
    print "ID",
          "FLAT",
          "STORY_ID",
          "POS",
          "NAME",
          "TYPE",
          "WEIGHT",
          "SPLIT_OPEN",
          "SPLIT_CLOSE",
          "HORIZ",
          "VERT",
          "ALIGN",
          "DESC",
          "PAGES",
          "TOTAL_PAGES",
          "FLAT_COUNT",
          "FLAT_LIST",
          "BP",
          "SPEC"

    for (i=1; i<=EleId; i++) {
        printInstance(i)
    }
}
