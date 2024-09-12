const endpoint = "/artists"
const artistId = getSegment(3);

function getFormArtist() {
    return {
        name: $("#artist-name").val(),
        description: $("#artist-description").val()
    }
}

async function loadArtist(artistId, callback) {
    await api.get(`/artists/${artistId}`).then((response) => {
        callback(response.data.data)
        renderArtist(response.data.data)
    });
}

function renderArtist(attributes, callback) {
    const { name, description, lp_count } = attributes;

    callback(name, description, lp_count)

}