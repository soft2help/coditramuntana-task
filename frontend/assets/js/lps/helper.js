const endpoint = "/lps"
const lpId = getSegment(3);

async function loadLp(lpId, callback) {
    console.log(lpId);
    await api.get(`${endpoint}/${lpId}`).then((response) => {
        callback(response.data.data.attributes)
    });
}

function renderLp(attributes, callback) {
    const { name, description, artist_id } = attributes;
    callback(name, description, artist_id)
}

function getFormLp() {
    return {
        name: $("#lp-name").val(),
        description: $("#lp-description").val(),
        artist_id: $("#artist-select").val()
    }
}

async function getArtists(callback) {
    await api.get(`/artists?page[per_page]=100`).then((response) => {
        loadSelectArtists(response.data.data)
        if (typeof callback === "function") {
            callback(response.data.data);  // Pass the artist data to the callback
        }
    });
}

function loadSelectArtists(artists) {
    const select = $("#artist-select");

    // Clear the loading text
    select.empty();

    // Add a default option
    select.append('<option value="" disabled selected>Select an Artist</option>');

    // Populate the select with artists
    artists.forEach(artist => {
        const id = artist.id;
        const { name, _ } = artist.attributes;
        select.append(`<option value="${id}">${name}</option>`);
    });
}