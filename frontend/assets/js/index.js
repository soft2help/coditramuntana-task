let endpoint = "/report/lps";
$(async  ()=>{
    pages.logged();
    loadReport(1);
    clickPagination();
});

async function loadReport(page){
    await api.get(`${endpoint}?page[page]=${page}`).then((response) => {
        console.log(response.data)
        renderLPList(response.data.data)
        renderPagination(response.data.meta);
    });
}

function clickPagination(){
    $(document).on("click", ".page, .prev-page, .next-page", function() {
        const page = $(this).data('page');
        if (!$(this).hasClass('disabled')) {
            // Call your function to load data for the selected page
            loadReport(page);
        }
    });
}

function renderLPList(data) {
    const lpList = $(".lp-list");
    lpList.empty(); // Clear the list before rendering
  
    data.forEach(lp => {
      const { lp_name, artist_name, song_count, authors_list } = lp.attributes;
      const listItem = `
        <div class="lp-item bg-white shadow rounded-lg p-6 mb-4">
          <h2 class="text-2xl font-semibold text-gray-800">${lp_name}</h2>
          <p class="text-gray-600">Artist: <span class="font-medium">${artist_name}</span></p>
          <p class="text-gray-600">Songs: <span class="font-medium">${song_count}</span></p>
          <p class="text-gray-600">Authors: <span class="font-medium">${authors_list}</span></p>
        </div>
      `;
      lpList.append(listItem);
    });
}
  
