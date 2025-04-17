class SearchableTable {
  constructor(tableElement) {
    this.table = tableElement;

    // Create the search control container (div.search-ctrl)
    this.searchCtrl = document.createElement("div");
    this.searchCtrl.className = "search-ctrl";

    // Create the search input element
    this.searchInput = document.createElement("input");
    this.searchInput.type = "text";
    this.searchInput.className = "search-input";
    this.searchInput.placeholder = "Search this table...";

    // Create the clear button
    this.clearButton = document.createElement("button");
    this.clearButton.className = "clear-btn";
    this.clearButton.textContent = "Clear";

    // Create the row count indicator
    this.rowCountIndicator = document.createElement("div");
    this.rowCountIndicator.className = "row-count";

    // Append the input, clear button, and row count indicator to the search control div
    this.searchCtrl.appendChild(this.searchInput);
    this.searchCtrl.appendChild(this.clearButton);
    this.searchCtrl.appendChild(this.rowCountIndicator);

    // Insert the search control div after the table
    this.table.parentNode.insertBefore(this.searchCtrl, this.table.nextSibling);

    // Initialize search and clear button functionalities
    this._initializeSearch();
    this._initializeClearButton();
  }

  // Initialize the search functionality for the table
  _initializeSearch() {
    this.searchInput.addEventListener("keyup", () => this._filterRows());
  }

  // Initialize the clear button functionality
  _initializeClearButton() {
    this.clearButton.addEventListener("click", () => {
      this.searchInput.value = "";
      this._filterRows();
    });
  }

  // Filter rows based on the search query
  _filterRows() {
    const query = this.searchInput.value.toLowerCase();
    const rows = this.table.querySelectorAll("tbody tr");
    let visibleCount = 0;

    rows.forEach((row) => {
      const rowCells = Array.from(row.querySelectorAll("td, th"));
      const rowText = rowCells
        .map((cell) => cell.textContent.toLowerCase())
        .join(" ");

      if (rowText.includes(query)) {
        row.style.display = ""; // Show the row if it matches
        visibleCount++;
      } else {
        row.style.display = "none"; // Hide the row if it doesn't match
      }
    });

    this._updateRowCount(visibleCount, rows.length);
  }

  // Update the row count indicator
  _updateRowCount(visibleCount, totalRows) {
    this.rowCountIndicator.textContent = `${visibleCount} of ${totalRows} rows displayed`;
  }
}
