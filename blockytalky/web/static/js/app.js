import {Socket} from "phoenix"

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
let App = {
}

export default App
