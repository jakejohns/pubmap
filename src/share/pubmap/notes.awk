BEGIN {
    NotesSectionStart = 0
    InList = 0
    HasNoteContent = 0
}

# Check for the line starting with ### to mark the beginning of content
/^###$/ {
    NotesSectionStart = 1
    next  # Skip this line
}

# Once we have found the marker, start processing
NotesSectionStart == 1 {

    # Ignore empty lines before content starts
    if ($0 ~ /^$/ && !HasNoteContent) {
        next
    }

    # Found content!
    if ($0 !~ /^$/ && !HasNoteContent) {
        HasNoteContent = 1
    }

    # Headings h1...h6 (# Something)
    if ($0 ~ /^#+ /) {
        level = length($0) - length(substr($0, index($0, " ")))  # Count the `#` symbols
        header_content = substr($0, level + 2)  # Skip the `#` characters and space
        print "<h" level ">" header_content "</h" level ">"
        next
    }

    # Handle bold text (**bold** or __bold__)
    while ($0 ~ /\*\*[^*]+\*\*/ || $0 ~ /__[^_]+__/) {
        if ($0 ~ /\*\*[^*]+\*\*/) {
            match($0, /\*\*[^*]+\*\*/)
            bold_text = substr($0, RSTART + 2, RLENGTH - 4)  # Skip the '**' around the bold text
            sub(/\*\*[^*]+\*\*/, "<b>" bold_text "</b>")
        }
        if ($0 ~ /__[^_]+__/) {
            match($0, /__[^_]+__/)
            bold_text = substr($0, RSTART + 2, RLENGTH - 4)  # Skip the '__' around the bold text
            sub(/__[^_]+__/, "<b>" bold_text "</b>")
        }
    }

    # Handle italic text (*italic* or _italic_)
    while ($0 ~ /\*[^*]+\*/ || $0 ~ /_[^_]+_/) {
        if ($0 ~ /\*[^*]+\*/) {
            match($0, /\*[^*]+\*/)
            italic_text = substr($0, RSTART + 1, RLENGTH - 2)  # Skip the '*' around the italic text
            sub(/\*[^*]+\*/, "<i>" italic_text "</i>")
        }
        if ($0 ~ /_[^_]+_/) {
            match($0, /_[^_]+_/)
            italic_text = substr($0, RSTART + 1, RLENGTH - 2)  # Skip the '_' around the italic text
            sub(/_[^_]+_/, "<i>" italic_text "</i>")
        }
    }

    while (index($0, "[")) {
        start = index($0, "[") + 1
        end = index($0, "]")
        link_text = substr($0, start, end - start)

        # Find the URL part, starting after the closing parenthesis
        start_url = index($0, "(") + 1
        end_url = index($0, ")")
        url = substr($0, start_url, end_url - start_url)

        # Replace the markdown link with HTML anchor tag
        $0 = substr($0, 1, index($0, "[") - 1) "<a href=\"" url "\">" link_text "</a>" substr($0, end_url + 1)
    }

    # Handle unordered lists (e.g., - Item or * Item)
    if ($0 ~ /^[-*] /) {
        if (InList == 0) {
            print "<ul>"
            InList = 1
        }
        print "<li>" substr($0, 3) "</li>"
        next
    }

    # Close the unordered list if a list is finished
    if (InList == 1 && !($0 ~ /^[-*] /)) {
        print "</ul>"
        InList = 0
    }

    # Handle paragraphs (any text not part of a header, list, or formatting)
    print "<p>" $0 "</p>"
}

END {
    if (InList == 1) {
        print "</ul>"
        InList = 0
    }
}
