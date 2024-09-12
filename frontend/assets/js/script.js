function getSegment(segment) {
    return window.location.pathname.split('/')[segment];
}

function reloadAfter(inMiliseconds) {
    setTimeout(() => {
        window.location.reload();
    }, inMiliseconds)
}

