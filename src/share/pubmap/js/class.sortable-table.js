class SortableTable {
  constructor(tableElement, lastFlat) {
    this.table = tableElement;
    this.lastFlat = lastFlat;
    this.table.classList.add("sortable");

    // Initialize the sorting functionality
    this._initializeSort();
  }

  // Extract integers from a comma-delimited list of links (for "flats" columns)
  _extractIntegers(cell) {
    const links = Array.from(cell.querySelectorAll("a"));
    const values = links.map((link) => parseInt(link.textContent.trim(), 10));
    return values.filter((value) => !isNaN(value)); // Filter out invalid integers
  }

  // Sort by the first integer in the list (for "flats" columns)
  _sortFlatList(rowA, rowB, columnIndex) {
    const cellA = rowA.cells[columnIndex];
    const cellB = rowB.cells[columnIndex];

    const integersA = this._extractIntegers(cellA);
    const integersB = this._extractIntegers(cellB);

    const lastValueA =
      integersA.length > 0 ? integersA[integersA.length - 1] : null;
    const lastValueB =
      integersB.length > 0 ? integersB[integersB.length - 1] : null;

    // If the last value is the predefined lastFlat value, move this row to the bottom
    const valueA = lastValueA === this.lastFlat ? Infinity : integersA[0];
    const valueB = lastValueB === this.lastFlat ? Infinity : integersB[0];

    return valueA - valueB; // Numeric sorting for the first value
  }

  // Sort by numeric value (for single integers in flat column)
  _sortNumeric(rowA, rowB, columnIndex) {
    const cellA = rowA.cells[columnIndex];
    const cellB = rowB.cells[columnIndex];

    const valueA = parseInt(cellA.textContent.trim(), 10);
    const valueB = parseInt(cellB.textContent.trim(), 10);

    if (isNaN(valueA) || isNaN(valueB)) return 0; // Handle invalid numbers

    return valueA - valueB; // Numeric sorting
  }

  // Sort by text content (for normal columns)
  _sortDefault(rowA, rowB, columnIndex) {
    const cellA = rowA.cells[columnIndex];
    const cellB = rowB.cells[columnIndex];

    const valueA = cellA.textContent.trim();
    const valueB = cellB.textContent.trim();

    // Use localeCompare for string-based sorting
    return valueA.localeCompare(valueB, undefined, { sensitivity: "base" });
  }

  // Sort the table by the clicked column
  _sortTable(columnIndex, header) {
    const rows = Array.from(this.table.querySelectorAll("tbody tr"));
    const isAscending = header.classList.contains("sorted-asc");

    // Remove previous sorted classes
    this.table.querySelectorAll("th").forEach((th) => {
      th.classList.remove("sorted-asc", "sorted-desc");
    });

    // Toggle sorting direction
    if (isAscending) {
      header.classList.add("sorted-desc");
    } else {
      header.classList.add("sorted-asc");
    }

    rows.sort((rowA, rowB) => {
      let result;

      // Call the appropriate sorting method based on the header class
      if (
        header.classList.contains("flat") ||
        header.classList.contains("manuscript")
      ) {
        // Check for 'flat' class
        result = this._sortNumeric(rowA, rowB, columnIndex); // Use _sortNumeric for single integers
      } else if (header.classList.contains("flats")) {
        // Check for 'flats' class
        result = this._sortFlatList(rowA, rowB, columnIndex); // Use _sortFlatList for comma-separated values
      } else {
        result = this._sortDefault(rowA, rowB, columnIndex); // Default sorting for other columns
      }

      // Return the sorted result depending on the direction
      return isAscending ? result : -result;
    });

    rows.forEach((row) => this.table.querySelector("tbody").appendChild(row)); // Reorder rows
  }

  // Initialize the sort functionality for the table
  _initializeSort() {
    const headers = this.table.querySelectorAll("thead th");

    headers.forEach((header, index) => {
      header.addEventListener("click", () => this._sortTable(index, header));
    });
  }
}
