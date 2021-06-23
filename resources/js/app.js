import Nprogress from "nprogress";

let loadingTimeout = null;
Nprogress.configure({ showSpinner: false, minimum: 0.4 });
window.addEventListener("elm-loading", function({ detail: loading }) {
    clearTimeout(loadingTimeout);

    if (loading) {
        loadingTimeout = setTimeout(Nprogress.start, 180);
    } else {
        Nprogress.done();
    }
});
