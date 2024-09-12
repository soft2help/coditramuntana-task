var currentPage = 1;
$(async () => {
    pages.logged();
    loadLps(currentPage);
    clickPagination((page) => {
        loadLps(page)
    });
    initActions();
});

function getFilterArtist() {
    const params = new URLSearchParams(window.location.search);
    // Get the value of `filter[artist_name]`
    return params.get('filter[artist_name]');
}

async function loadLps(page) {
    let queryFilterArtist = "";
    let artistName = getFilterArtist();

    if (artistName) {
        queryFilterArtist = `&filter[artist_name]=${artistName}`;
    }

    await api.get(`${endpoint}?page[page]=${page}${queryFilterArtist}`).then((response) => {
        renderLpsList(response.data.data)
        renderPagination(response.data.meta);
    });
    currentPage = page;
}

function renderLpsList(data) {
    $(".lps-list").html("");
    const lpsList = $(".lps-list");

    data.forEach(lp => {
        const id = lp.id;
        const { name, description } = lp.attributes;

        const listItem = `
    <div class="artist-item bg-white shadow rounded-lg p-6 mb-4">
      <h2 class="text-2xl font-semibold text-gray-800">${name}</h2>
      <p class="text-gray-600">Description: <span class="font-medium">${description}</span></p>

      <!-- Action buttons: Show, Edit, Delete -->
      <div class="mt-4">
        <button class="show-lp bg-blue-500 text-white px-4 py-2 rounded mr-2" data-id="${id}">
          Show
        </button>
        <button class="edit-lp bg-yellow-500 text-white px-4 py-2 rounded mr-2" data-id="${id}">
          Edit
        </button>
        <button class="delete-lp bg-red-500 text-white px-4 py-2 rounded" data-id="${id}">
          Delete
        </button>
      </div>
    </div>
  `;

        lpsList.append(listItem);
    });
}

function initActions() {
    //show
    $(document).on('click', '.show-lp', function () {
        const lpId = $(this).data('id');
        pages.lps.show(lpId);
    });

    // Edit lp
    $(document).on('click', '.edit-lp', function () {
        const lpId = $(this).data('id');
        pages.lps.edit(lpId);
    });

    // Delete artist
    $(document).on('click', '.delete-lp', async function () {
        const lpId = $(this).data('id');
        if (confirm('Are you sure you want to delete this lp?')) {
            await api.delete(`/lps/${lpId}`);
            noti.success("Artist", "Artist was deleted");
            // Optionally, you can remove the artist from the DOM

            loadLps(currentPage);
        }
    });
}
