$(async () => {
    pages.logged();
    newArtist();
});


function newArtist() {
    $(".add-artist").on("click", async function () {
        await api.post(`${endpoint}`, {
            data: {
                attributes: getFormArtist()
            }
        }).then((response) => {
            noti.success("Artist", "Artist added");
            reloadAfter(3000);
        });
    });
}
