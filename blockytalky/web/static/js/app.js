import {Socket} from "phoenix"
/* after page loads DOM elements */
 //common page elements:
 //humane is the popup notification for logging messages to the client
  humane.baseCls = 'humane-libnotify';
  humane.clickToClose = true;
  humane.error = humane.spawn({ addnCls: 'humane-libnotify-error', timeout: 1000 });
 //foundation.js for pretty widgets and dropdowns
 $(document).foundation(); //init
 //sockets and channels
 let socket = new Socket("/ws");
 socket.connect();
 let hw_chan = socket.chan("hardware:values", {});
 let comm_chan = socket.chan("comms:message",{});
 let uc_chan = socket.chan("uc:command", {});
 //join
 hw_chan.join().receive("ok", chan => {
   console.log("Hw Success!");
 });
 comm_chan.join().receive("ok", chan => {
   console.log("Comm Success!");
 });
 uc_chan.join().receive("ok", chan =>{
   console.log("UserCode Success!");
 });
 //callbacks on message received
hw_chan.on("all", payload => {
  //console.log("received hardware message: " + payload.body)
  //find corresponding label and fill it with the value
  var sensor_obj = payload.body;
  for(var key in sensor_obj){
    $("div").find("[data-name='" + key + "']").find(".sensor-value").text(sensor_obj[key]);
  }
});
comm_chan.on("message", payload => {
  humane.log("received message: " + payload.body);
});
uc_chan.on("progress", payload => {
  humane.log("System: " + payload.body)
});
uc_chan.on("error", payload => {
  humane.error("System Error: " + payload.body)
});
/* App object */
var App = {
  //Blockly
  workspace: Blockly.inject('blocklyDiv',
      {media: '/media/',
       toolbox: document.getElementById('toolbox')}),
  download_code: function (){
    humane.log("Downloading code from " + $(".name-header").text() +" to  the browser!");
    console.log("downloading code from btu")
    uc_chan.push("download", {body: ""})
    .receive("ok", (save_file) =>{
      if(save_file.xml && save_file.xml != "<xml></xml>"){
        App.workspace.clear();
        var xml = Blockly.Xml.textToDom(save_file.xml);
        Blockly.Xml.domToWorkspace(App.workspace,xml);
      }
      humane.log("System: Code Downloaded from " + $(".name-header").text())
    });
  }
};
console.log(App);

//button-bar callbacks:
$(".run-button").click(function(){
  socket.flushSendBuffer();
  humane.log("Telling "+$(".name-header").text()+" to run code!");
  uc_chan.push("run", {body: ":ok"});
});
$(".stop-button").click(function(){
  socket.flushSendBuffer();
  humane.log("Telling "+$(".name-header").text()+" to stop code!");
  uc_chan.push("stop", {body: ":ok"})
});
$(".upload-button").click(function(){
  socket.flushSendBuffer();
  humane.log("Uploading code from the browser to "+ $(".name-header").text() +"!");
  var payload = {
    xml: new XMLSerializer().serializeToString(Blockly.Xml.workspaceToDom(App.workspace)),
    code: Blockly.Elixir.workspaceToCode(App.workspace)
  };
  uc_chan.push("upload", {body: payload})
});
$(".download-button").click(function(){
  App.download_code();
});
//help buttons
$(".tour-button").click(function(){
  App.workspace.clear();
});
$(".clear-button").click(function(){
  App.workspace.clear();
});
$(".save-button").click(function(){
  var text = new XMLSerializer().serializeToString(Blockly.Xml.workspaceToDom(App.workspace));
  var filename = $(".name-header").text() + "blockytalky_program.xml";
  var element = document.createElement('a');
  element.setAttribute('href', 'data:text/xml;charset=utf-8,' + encodeURIComponent(text));
  element.setAttribute('download', filename);
  element.style.display = 'none';
  document.body.appendChild(element);

  element.click();

  document.body.removeChild(element);
});
$(document).on('change','#fileupload', function(e){
  console.log("loading file:");
  console.log(e);
  var file = e.target.files[0];
  if (!file) {
    return;
  }
  var reader = new FileReader();
  reader.onload = function(e) {
    var contents = e.target.result;
    console.log(contents);
    Blockly.Xml.domToWorkspace(App.workspace, Blockly.Xml.textToDom(contents));
  };
  reader.readAsText(file);
  e.targetvalue = null;
});
$(".shutdown-button").click(function(){
  App.workspace.clear();
});

$(".sensor-select-option").click(function(){
  option = $(this).find("a")
  //get the sensor id and the type id and push on websocket
});

//global stuff
window.App = App;
$(document).ready(function() {
    humane.log("Loading code from btu... please wait :)")
});
window.onload = function() {
  console.log("window on load fn");
  var load_code_on_init = window.setInterval(function(){
    if(uc_chan.canPush()){
        window.clearInterval(load_code_on_init);
        App.download_code();
        console.log("on load download")
    }
  }, 100);
};
export default App
