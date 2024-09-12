$(async () => {
    pages.logged();
    loadArtist(artistId, (data) => {
        renderArtist(data.attributes, (name, description, lp_count) => {
            $(".name").html(name);
            $(".description").html(description);
            $(".lp-count").html(lp_count);

            $(".show-lps").attr("href", `/lps?filter[artist_name]=${name}`);
        })
    });
});
