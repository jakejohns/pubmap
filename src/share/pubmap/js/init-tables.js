(function () {
  const tables = [
    document.getElementById("article-table"),
    document.getElementById("extra-table"),
  ];
  tables.forEach((table) => {
    if (table) {
      new SearchableTable(table);
      new SortableTable(table);
    }
  });
})();
