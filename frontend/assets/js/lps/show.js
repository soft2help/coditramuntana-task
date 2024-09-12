
$(async () => {
    pages.logged();
    loadLp(lpId, (attributes) => {
        renderLp(attributes, (name, description, _) => {
            $(".name").html(name);
            $(".description").html(description);
        });
    });
});





