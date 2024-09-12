var currentPage = 1;
$(async () => {
    pages.logged();
    loadArtists(currentPage);
    clickPagination((page) => {
        loadArtists(page);
    });
    initActions();
});

async function loadArtists(page) {
    await api.get(`${endpoint}?page[page]=${page}`).then((response) => {
        renderArtistList(response.data.data)
        renderPagination(response.data.meta);
    });
    currentPage = page;
}



function renderArtistList(data) {
    $(".artist-list").html("");
    const artistList = $(".artist-list");

    data.forEach(artist => {
        const id = artist.id;
        const { name, description } = artist.attributes;

        const listItem = `
    <div class="artist-item bg-white shadow rounded-lg p-6 mb-4">
      <h2 class="text-2xl font-semibold text-gray-800">${name}</h2>
      <p class="text-gray-600">Description: <span class="font-medium">${description}</span></p>

      <!-- Action buttons: Show, Edit, Delete -->
      <div class="mt-4">
        <button class="show-artist bg-blue-500 text-white px-4 py-2 rounded mr-2" data-id="${id}">
          Show
        </button>
        <button class="edit-artist bg-yellow-500 text-white px-4 py-2 rounded mr-2" data-id="${id}">
          Edit
        </button>
        <button class="delete-artist bg-red-500 text-white px-4 py-2 rounded" data-id="${id}">
          Delete
        </button>
      </div>
    </div>
  `;

        artistList.append(listItem);
    });
}

function initActions() {
    //show
    $(document).on('click', '.show-artist', function () {
        const artistId = $(this).data('id');
        // Add your logic to show artist details (e.g., navigate to a details page)
        pages.artists.show(artistId);
    });

    // Edit artist
    $(document).on('click', '.edit-artist', function () {
        const artistId = $(this).data('id');
        pages.artists.edit(artistId);
    });

    // Delete artist
    $(document).on('click', '.delete-artist', async function () {
        const artistId = $(this).data('id');
        if (confirm('Are you sure you want to delete this artist?')) {
            // Add your logic to delete the artist

            await api.delete(`/artists/${artistId}`);
            noti.success("Lps", "Lp was deleted");
            // Optionally, you can remove the artist from the DOM

            loadArtists(currentPage);

        }
    });
}
