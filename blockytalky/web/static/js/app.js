import {Socket} from "phoenix"
/* after page loads DOM elements */
 //common page elements:
 //humane is the popup notification for logging messages to the client
  //humane.baseCls = 'humane-libnotify';
  //humane.clickToClose = true;
  //humane.error = humane.spawn({ addnCls: 'humane-libnotify-error', timeout: 2000 });
  var system_log;
  var message_log;
  function sys_log(message, type){
    if(system_log != null)
    {
      system_log.close();
    }
    if(type == null){
      type = "alert"
    }
    system_log = noty({
      text: message,
      theme: "blockytalkyTheme",
      layout: "topLeft",
      type: type
    });
  }
  function msg_log(message){
    if(message_log != null)
    {
      message_log.close();
    }
    message_log = noty({
      text:message,
      theme:"blockytalkyTheme",
      layout:"topRight"
    });
  }
 //foundation.js for pretty widgets and dropdowns
 $(document).foundation(); //init
 //sockets and channels
 let socket = new Socket("/ws");
 socket.connect();
 let hw_chan = socket.channel("hardware:values");
 let comm_chan = socket.channel("comms:message");
 let uc_chan = socket.channel("uc:command");
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
hw_chan.on("sensor_changed", payload => {
  var port_id = payload.port_id;
  var sensor_label = payload.sensor_label;
  console.log("sensor_changed " + port_id + ":" + sensor_label);

  sys_log("System: Port Changed!" );

  $(".sensor-select[data-name='" + port_id + "']").text(sensor_label);
});
comm_chan.on("message", payload => {

  msg_log("received message: " + payload.body);
});
comm_chan.on("say", payload => {

  msg_log("say:" + payload.body);
})
uc_chan.on("progress", payload => {

  sys_log("System: " + payload.body);
});
uc_chan.on("error", payload => {

  sys_log("System Error: " + payload.body, "error");
});
/* App object */
var App = {
  //Blockly
  workspace: Blockly.inject('blocklyDiv',
      {media: '/media/',
       toolbox: document.getElementById('toolbox')}),
  download_code: function (){

    sys_log("Downloading code from " + $(".name-header").text() +" to  the browser!");
    console.log("downloading code from btu")
    uc_chan.push("download", {body: ""})
    .receive("ok", (save_file) =>{
      if(save_file.xml && save_file.xml != "<xml></xml>"){
        App.workspace.clear();
        var xml = Blockly.Xml.textToDom(save_file.xml);
        Blockly.Xml.domToWorkspace(App.workspace,xml);
      }

      sys_log("System: Code Downloaded from " + $(".name-header").text())
    });
  }
};


//button-bar callbacks:
$(".run-button").click(function(){
  socket.flushSendBuffer();

  sys_log("Telling "+$(".name-header").text()+" to run code!");
  uc_chan.push("run", {body: ":ok"});
});
$(".stop-button").click(function(){
  socket.flushSendBuffer();

  sys_log("Telling "+$(".name-header").text()+" to stop code!");
  uc_chan.push("stop", {body: ":ok"})
});
$(".upload-button").click(function(){
  socket.flushSendBuffer();

  sys_log("Uploading code from the browser to "+ $(".name-header").text() +"!");
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
  $(document).foundation('joyride', 'start');
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
  //console.log("loading file:");
  //console.log(e);
  var file = e.target.files[0];
  if (!file) {
    return;
  }
  var reader = new FileReader();
  reader.onload = function(e) {
    var contents = e.target.result;
    //console.log(contents);
    App.workspace.clear();
    Blockly.Xml.domToWorkspace(App.workspace, Blockly.Xml.textToDom(contents));
  };
  reader.readAsText(file);
  e.targetvalue = null;
});
$(".shutdown-button").click(function(){
  //send signal to BTU to shutdown
  //It will broadcast back to all connected clients to shutdown
});
$(".fullscreen-button").click(function(){
   $(".container").append($(App.workspace.toolbox_.HtmlDiv));
   //move trashcan

   $('body')[0].webkitRequestFullscreen(Element.ALLOW_KEYBOARD_INPUT);

});

var changeHandler = function(e){
    var bDiv = $('#blocklyDiv');

    if(window.screen.availTop == 0 ){
     bDiv.height("100vh");
    }
    else {
      bDiv.height(window.screen.height - bDiv.offset().top);
    }
     false;
  }
  document.addEventListener("fullscreenchange", changeHandler, false);
  document.addEventListener("webkitfullscreenchange", changeHandler, false);
  document.addEventListener("mozfullscreenchange", changeHandler, false);

$(".sensor-select-option").click(function(){
  var option = $(this).find("label");
  //get the sensor id and the type id and push on websocket
  var hw_v    = option.data("hw")
  var sensor = option.data("sensor");
  var value  = option.data("value");
  console.log("change sensor: " + sensor + " to: " + value);
  hw_chan.push("change_sensor_type", {hw: hw_v, port_id: sensor, sensor_type: value});
  $("body").click(); //close dropdown since it isn't an anchor tag
});
$(".sample-select-option").click(function(){
  var option = $(this).find("label");
  //get the sample num and the file name and push on websocket
  var sample_num    = option.data("sample-num")
  var value  = option.data("value");
  console.log("change sample: " + sample_num + " to: " + value);
  hw_chan.push("change_sensor_type", {hw: hw_v, port_id: sensor, sensor_type: value});
  $("body").click(); //close dropdown since it isn't an anchor tag
});

//global stuff
window.App = App;
$(document).ready(function() {

    sys_log("Connecting to btu... please wait :)");
    $(".icon-bar .item").addClass("disabled");
    $("#sensors-bin button").addClass("disabled");
    $("body").dimBackground();
});
window.onload = function() {
  console.log("window on load fn");
  var load_code_on_init = window.setInterval(function(){
    if(uc_chan.canPush()){
        window.clearInterval(load_code_on_init);
        $(".icon-bar .item").removeClass("disabled");
        $("#sensors-bin button").removeClass("disabled");
        var bDiv = $('#blocklyDiv');
        bDiv.height("100vh")
        $.undim();
        App.download_code();
        console.log("on load download");
    }
  }, 100);
};
$.noty.themes.blockytalkyTheme = {
    name    : 'blockytalkyTheme',
    helpers : {
        borderFix: function() {
            if(this.options.dismissQueue) {
                var selector = this.options.layout.container.selector + ' ' + this.options.layout.parent.selector;
                switch(this.options.layout.name) {
                    case 'top':
                        $(selector).css({borderRadius: '0px 0px 0px 0px'});
                        $(selector).last().css({borderRadius: '0px 0px 5px 5px'});
                        break;
                    case 'topCenter':
                    case 'topLeft':
                    case 'topRight':
                    case 'bottomCenter':
                    case 'bottomLeft':
                    case 'bottomRight':
                    case 'center':
                    case 'centerLeft':
                    case 'centerRight':
                    case 'inline':
                        $(selector).css({borderRadius: '0px 0px 0px 0px'});
                        $(selector).first().css({'border-top-left-radius': '5px', 'border-top-right-radius': '5px'});
                        $(selector).last().css({'border-bottom-left-radius': '5px', 'border-bottom-right-radius': '5px'});
                        break;
                    case 'bottom':
                        $(selector).css({borderRadius: '0px 0px 0px 0px'});
                        $(selector).first().css({borderRadius: '5px 5px 0px 0px'});
                        break;
                    default:
                        break;
                }
            }
        }
    },
    modal   : {
        css: {
            position       : 'fixed',
            width          : '100%',
            height         : '100%',
            backgroundColor: '#fff',
            zIndex         : 10000,
            opacity        : 0.3,
            display        : 'none',
            left           : 0,
            top            : 0
        }
    },
    style   : function() {

        this.$bar.css({
            overflow  : 'hidden',
            background: "url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABsAAAAoCAQAAAClM0ndAAAAhklEQVR4AdXO0QrCMBBE0bttkk38/w8WRERpdyjzVOc+HxhIHqJGMQcFFkpYRQotLLSw0IJ5aBdovruMYDA/kT8plF9ZKLFQcgF18hDj1SbQOMlCA4kao0iiXmah7qBWPdxpohsgVZyj7e5I9KcID+EhiDI5gxBYKLBQYKHAQoGFAoEks/YEGHYKB7hFxf0AAAAASUVORK5CYII=') repeat-x scroll left top #fff",
            textAlign : 'center'
        });

        this.$message.css({
            fontSize  : '13px',
            lineHeight: '16px',
            textAlign : 'center',
            padding   : '8px 10px 9px',
            width     : 'auto',
            position  : 'relative'
        });

        this.$closeButton.css({
            position  : 'absolute',
            top       : 4, right: 4,
            width     : 10, height: 10,
            background: "url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAQAAAAnOwc2AAAAxUlEQVR4AR3MPUoDURSA0e++uSkkOxC3IAOWNtaCIDaChfgXBMEZbQRByxCwk+BasgQRZLSYoLgDQbARxry8nyumPcVRKDfd0Aa8AsgDv1zp6pYd5jWOwhvebRTbzNNEw5BSsIpsj/kurQBnmk7sIFcCF5yyZPDRG6trQhujXYosaFoc+2f1MJ89uc76IND6F9BvlXUdpb6xwD2+4q3me3bysiHvtLYrUJto7PD/ve7LNHxSg/woN2kSz4txasBdhyiz3ugPGetTjm3XRokAAAAASUVORK5CYII=)",
            display   : 'none',
            cursor    : 'pointer'
        });

        this.$buttons.css({
            padding        : 5,
            textAlign      : 'right',
            borderTop      : '1px solid #ccc',
            backgroundColor: '#fff'
        });

        this.$buttons.find('button').css({
            marginLeft: 5
        });

        this.$buttons.find('button:first').css({
            marginLeft: 0
        });

        this.$bar.on({
            mouseenter: function() {
                $(this).find('.noty_close').stop().fadeTo('normal', 1);
            },
            mouseleave: function() {
                $(this).find('.noty_close').stop().fadeTo('normal', 0);
            }
        });

        switch(this.options.layout.name) {
            case 'top':
                this.$bar.css({
                    borderRadius: '0px 0px 5px 5px',
                    borderBottom: '2px solid #eee',
                    borderLeft  : '2px solid #eee',
                    borderRight : '2px solid #eee',
                    boxShadow   : "0 2px 4px rgba(0, 0, 0, 0.1)"
                });
                break;
            case 'topCenter':
            case 'center':
            case 'bottomCenter':
            case 'inline':
                this.$bar.css({
                    borderRadius: '5px',
                    border      : '1px solid #0f0f0f',
                    boxShadow   : "0 2px 4px rgba(0, 0, 0, 0.1)"
                });
                this.$message.css({fontSize: '13px', textAlign: 'center'});
                break;
            case 'topLeft':
            case 'topRight':
            case 'bottomLeft':
            case 'bottomRight':
            case 'centerLeft':
            case 'centerRight':
                this.$bar.css({
                    borderRadius: '5px',
                    border      : '1px solid #555',
                    boxShadow   : "0 2px 4px rgba(0, 0, 0, 0.1)"
                });
                this.$message.css({fontSize: '13px', textAlign: 'left'});
                break;
            case 'bottom':
                this.$bar.css({
                    borderRadius: '5px 5px 0px 0px',
                    borderTop   : '2px solid #eee',
                    borderLeft  : '2px solid #eee',
                    borderRight : '2px solid #eee',
                    boxShadow   : "0 -2px 4px rgba(0, 0, 0, 0.1)"
                });
                break;
            default:
                this.$bar.css({
                    border   : '2px solid #fff',
                    boxShadow: "0 2px 4px rgba(0, 0, 0, 0.1)"
                });
                break;
        }

        switch(this.options.type) {
            case 'alert':
            case 'notification':
                this.$bar.css({backgroundColor: '#232', borderColor: '#CCC', color: '#fff', opacity: 0.9});
                break;
            case 'warning':
                this.$bar.css({backgroundColor: '#FFEAA8', borderColor: '#FFC237', color: '#826200'});
                this.$buttons.css({borderTop: '1px solid #FFC237'});
                break;
            case 'error':
                this.$bar.css({backgroundColor: 'red', borderColor: 'darkred', color: '#FFF'});
                this.$message.css({fontWeight: 'bold'});
                this.$buttons.css({borderTop: '1px solid darkred'});
                break;
            case 'information':
                this.$bar.css({backgroundColor: '#57B7E2', borderColor: '#0B90C4', color: '#FFF'});
                this.$buttons.css({borderTop: '1px solid #0B90C4'});
                break;
            case 'success':
                this.$bar.css({backgroundColor: 'lightgreen', borderColor: '#50C24E', color: 'darkgreen'});
                this.$buttons.css({borderTop: '1px solid #50C24E'});
                break;
            default:
                this.$bar.css({backgroundColor: '#FFF', borderColor: '#CCC', color: '#444'});
                break;
        }
    },
    callback: {
        onShow : function() {
            $.noty.themes.defaultTheme.helpers.borderFix.apply(this);
        },
        onClose: function() {
            $.noty.themes.defaultTheme.helpers.borderFix.apply(this);
        }
    }
};

export default App
