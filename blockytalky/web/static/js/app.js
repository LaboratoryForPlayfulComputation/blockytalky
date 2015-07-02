import {Socket} from "phoenix"
/* after page loads DOM elements */
 //common page elements:
 //humane is the popup notification for logging messages to the client
  humane.baseCls = 'humane-libnotify';
  humane.clickToClose = true;
  humane.error = humane.spawn({ addnCls: 'humane-libnotify-error', timeout: 1000 });
 //foundation.js for pretty widgets and dropdowns
 $(document).foundation() //init
 //sockets and channels
 let socket = new Socket("/ws")
 socket.connect()
 let hw_chan = socket.chan("hardware:values", {})
 let comm_chan = socket.chan("comms:message",{})
 //join
 hw_chan.join().receive("ok", chan => {
   console.log("Hw Success!")
 })
 comm_chan.join().receive("ok", chan => {
   console.log("Comm Success!")
 })
 //callbacks on message received
hw_chan.on("all", payload => {
  //console.log("received hardware message: " + payload.body)
  //find corresponding label and fill it with the value
  var sensor_obj = payload.body;
  for(var key in sensor_obj){
    $("div").find("[data-name='" + key + "']").find(".sensor-value").text(sensor_obj[key]);
  }
})
comm_chan.on("message", payload => {
  console.log(payload.body);
  humane.log("received message: " + payload.body);
})
/* App object */
var App = {
  //Blockly
  workspace: Blockly.inject('blocklyDiv',
      {media: '/media/',
       toolbox: document.getElementById('toolbox')}),
}
console.log(App)

//button-bar callbacks:
$(".run-button").click(function(){
  humane.log("Telling BTU to run code!");
});

export default App
