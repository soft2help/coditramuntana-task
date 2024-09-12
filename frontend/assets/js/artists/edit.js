$(async () => {
    pages.logged();
    loadArtist(artistId, (data) => {
        renderArtist(data)
    });
    editArtist();
});



function renderArtist(artist) {
    const id = artist.id;
    const { name, description, _ } = artist.attributes;

    $("#artist-name").val(name);
    $("#artist-description").val(description);
}

function editArtist() {
    $(".edit-artist").on("click", async function () {
        await api.put(`${endpoint}/${artistId}`, {
            data: {
                attributes: getFormArtist()
            }
        }).then((response) => {
            noti.success("Artist", "Artist edited");
            reloadAfter(3000);
        });
    });
}

