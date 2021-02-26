// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"
import {Socket} from "phoenix"
import NProgress from "nprogress"
import {LiveSocket} from "phoenix_live_view"
import {signInWithEmailPassword} from "./firebase"

let Hooks = {}
Hooks.newBallotForm = {
    mounted() {
        this.el.addEventListener("submit", e => {
            e.preventDefault()
            const ballot_voter = e.target.querySelector("#ballot_voter").value
            const email = e.target.querySelector("#email").value
            const password = e.target.querySelector("#password").value

            signInWithEmailPassword(email, password).then(userCredentials => {
                this.pushEvent("submit_new_ballot", {ballot_voter, userId: userCredentials.user.uid})
            })

            // const x = signInWithEmailPassword(email, password)
            // console.log(x)
            // this.pushEvent("submit_new_ballot", {ballot_voter, userCredential: x})

            // this.pushEvent("submit_new_ballot", {ballot_voter, email, password})
        }, false)
    }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}, hooks: Hooks})

// Show progress bar on live navigation and form submits
window.addEventListener("phx:page-loading-start", info => NProgress.start())
window.addEventListener("phx:page-loading-stop", info => NProgress.done())

// Dismiss alert bars by clicking on the close button
let dismissButton = document.querySelector('.alert [data-dismiss="alert"]')
if (dismissButton) {
    dismissButton.addEventListener("click", e => {
        const alertDiv = e.path[1]
        alertDiv.style.display = "none"
    })
}

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

