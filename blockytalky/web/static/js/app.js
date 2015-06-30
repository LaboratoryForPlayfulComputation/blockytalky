import {Socket} from "phoenix"
/* after page loads DOM elements */
 //common page elements:
 let jumbotron = $(".jumbotron")
 let socket = new Socket("/ws")
 socket.connect()
 let chan = socket.chan("hardware:mock", {})
 chan.join().receive("ok", chan => {
   console.log("Success!")
 })
chan.on("hw_msg", payload => {
  console.log("received hardware message: " + payload)
  jumbotron.find(".lead").text(payload.body)
})
/* Blockly */
let workspace = Blockly.inject('blocklyDiv',
    {media: '/media/',
     toolbox: document.getElementById('toolbox')});
/* App object returned to Dom */
let App = {
}

export default App
