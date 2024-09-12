$(async () => {
    pages.logged();
    newLpEvent();
    getArtists();
});

function newLpEvent() {
    $(".add-lp").on("click", async function () {
        await api.post(`/lps`, {
            data: {
                attributes: getFormLp()
            }
        }).then((response) => {
            noti.success("Lp", "Lp added");
            reloadAfter(3000);
        });
    });
}


