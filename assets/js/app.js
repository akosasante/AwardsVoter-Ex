// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative paths, for example:
import socket from "./socket"

document.addEventListener('DOMContentLoaded', (event) => {
  // Finally, connect to the socket:
  let path = window.location.pathname.split("/").reverse()
  if (path[0] === "scoreboard") {
    let showName = path[1];
    socket.connect();
    // Now that you are connected, you can join channels with a topic:
    const channelName = `ballots:${showName}`;
    let channel = socket.channel(channelName);
    console.dir(channel);

    channel.on("update_scores", resp => {
      console.log("GOT update_scores: ", resp);
      channel.push("get_scores", {show_name: showName})
        .receive("ok", res => console.log(res))
    });
    
    channel.join()
      .receive("ok", resp => { console.log("Joined successfully", resp) })
      .receive("error", resp => { console.log("Unable to join", resp) });
  }
});