function renderPagination(meta) {
    const paginationContainer = $('.pagination');
    paginationContainer.empty();  // Clear the previous pagination

    // Previous button
    const prevDisabled = meta.current_page === 1 ? 'disabled opacity-50 cursor-not-allowed' : '';
    paginationContainer.append(`
          <button class="prev-page px-4 py-2 mx-1 border rounded ${prevDisabled} bg-gray-200" data-page="${meta.prev_page}">
              Previous
          </button>
      `);

    // Page numbers
    for (let i = 1; i <= meta.total_pages; i++) {
        const activeClass = meta.current_page === i ? 'active bg-gray-700 text-white' : 'bg-gray-200';
        paginationContainer.append(`
              <button class="page px-4 py-2 mx-1 border rounded ${activeClass}" data-page="${i}">
                  ${i}
              </button>
          `);
    }

    // Next button
    const nextDisabled = meta.current_page === meta.total_pages ? 'disabled opacity-50 cursor-not-allowed' : '';
    paginationContainer.append(`
          <button class="next-page px-4 py-2 mx-1 border rounded ${nextDisabled} bg-gray-200" data-page="${meta.next_page}">
              Next
          </button>
      `);

}


function clickPagination(callback) {
    $(document).on("click", ".page, .prev-page, .next-page", function () {
        const page = $(this).data('page');
        if (!$(this).hasClass('disabled')) {
            // Call your function to load data for the selected page
            callback(page);
        }
    });
}