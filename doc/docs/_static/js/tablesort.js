document$.subscribe(function() {
    let tables = document.querySelectorAll("article table:not([class])");
    tables.forEach(function(table) {
        new Tablesort(table);
    });
});
