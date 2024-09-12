

$(async () => {
    pages.logged();
    getArtists(() => {
        loadLp(lpId, (attributes) => {
            renderLp(attributes, (name, description, artist_id) => {
                $("#lp-name").val(name);
                $("#lp-description").val(description);
                $("#artist-select").val(artist_id);
            });
        });
    });
    editLpEvent();
});


function editLpEvent() {
    $(".edit-lp").on("click", async function () {
        await api.put(`/lps/${lpId}`, {
            data: {
                attributes: getFormLp()
            }
        }).then((response) => {
            noti.success("Lps", "Lp edited");
            reloadAfter(3000);
        });
    });
}


