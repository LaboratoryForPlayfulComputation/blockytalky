/**
 * Visual Block Language
 * BT Messaging related blocks
 * @fileoverview Generate Elixir for BT Messaging
 * @author matthew.ahrens@tufts.edu (Matthew Ahrens)
 * Generated with: https://blockly-demo.appspot.com/static/demos/blockfactory/index.html
 */
 'use strict';

 goog.provide('Blockly.Elixir.btmessaging');

 goog.require('Blockly.Elixir');
 //send
 Blockly.Blocks['send'] = {
   init: function() {
     this.appendValueInput("msg")
         .setCheck(null)
         .appendField("Send message:");
     this.appendValueInput("to")
         .setCheck("String")
         .appendField("to:");
     this.setInputsInline(true);
     this.setPreviousStatement(true, ['Music','BP','Event','Message']);
     this.setNextStatement(true, ['Music','BP','Event','Message']);
     this.setColour(120);
     this.setTooltip('');
     this.setHelpUrl('http://www.example.com/');
   }
 };
   Blockly.Elixir['send'] = function(block) {
  var value_msg = Blockly.Elixir.valueToCode(block, 'msg', Blockly.Elixir.ORDER_ATOMIC);
  var value_to = Blockly.Elixir.valueToCode(block, 'to', Blockly.Elixir.ORDER_ATOMIC);
  var context = ':top';
  if (Blockly.Elixir.context != null){
    context = Blockly.Elixir.context;
  }
  var code = 'send_message('+value_msg+','+value_to+', context: ' + context + ')\n';
  return code;
};
 //receive
 Blockly.Blocks['receive'] = {
  init: function() {
    this.appendValueInput("msg")
        .setCheck(null)
        .appendField("When I receive message:");
    this.appendStatementInput("DO")
        .setCheck(null)
        .appendField("do:");
    this.setInputsInline(true);
    this.setColour(160);
    this.setTooltip('');
    this.setHelpUrl('http://www.example.com/');
  }
};
Blockly.Elixir['receive'] = function(block) {
  var value_msg = Blockly.Elixir.valueToCode(block, 'msg', Blockly.Elixir.ORDER_ATOMIC);
  var statements_do = Blockly.Elixir.statementToCode(block, 'DO');
  var code = 'when_receive('+value_msg+') do\n '+statements_do+' end\n';
  Blockly.Elixir.macros_.push(code);
  return code;
};
 //say
Blockly.Blocks['say'] = {
  init: function() {
    this.appendValueInput("msg")
        .setCheck(null)
        .appendField("Say:");
    this.setInputsInline(true);
    this.setPreviousStatement(true, ['BP','Event','Message']);
    this.setNextStatement(true, ['BP','Event','Message']);
    this.setColour(120);
    this.setTooltip('');
    this.setHelpUrl('http://www.example.com/');
  }
};
Blockly.Elixir['say'] = function(block) {
  var value_msg = Blockly.Elixir.valueToCode(block, 'msg', Blockly.Elixir.ORDER_ATOMIC);
  // TODO: Assemble Elixir into code variable.
  var code = 'say('+value_msg+')\n';
  return code;
};
Blockly.Blocks['osc'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("Send OSC message");
    this.appendValueInput("MESSAGE")
        .setCheck(null)
        .setAlign(Blockly.ALIGN_CENTRE);
    this.appendDummyInput()
        .appendField("to");
    this.appendValueInput("IP")
        .setCheck(null)
        .setAlign(Blockly.ALIGN_CENTRE);
    this.appendValueInput("PORT")
        .setCheck(null)
        .setAlign(Blockly.ALIGN_CENTRE);        
    this.appendDummyInput()
        .appendField("with parameters");
    this.appendValueInput("PARAMS")
        //.setCheck("Lists")
        .setAlign(Blockly.ALIGN_CENTRE);
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour(120);
    this.setTooltip('This block is for sending OSC messages to addresses within or outside the network.' +
      'The destination must be in the format <IP_ADDRESS>:<PORT>, and the parameters must be stored in a list.');
    this.setHelpUrl('http://www.example.com/');
  }
};
/* TO DO 
- remove string slicing stuff, find a better method of fixing the quotation mark bug
- allow parameters to be lists, floats, ints, strings, etc.
- need to add a when I receive OSC block...
*/
Blockly.Elixir['osc'] = function(block) {
  var value_message = Blockly.Elixir.valueToCode(block, 'MESSAGE', Blockly.Elixir.ORDER_ATOMIC).slice(1, -1);
  var value_ip = Blockly.Elixir.valueToCode(block, 'IP', Blockly.Elixir.ORDER_ATOMIC).slice(1, -1);
  var value_port = Blockly.Elixir.valueToCode(block, 'PORT', Blockly.Elixir.ORDER_ATOMIC);
  var value_params = Blockly.Elixir.valueToCode(block, 'PARAMS', Blockly.Elixir.ORDER_ATOMIC).slice(1, -1);
  var code = 'send_osc(\''+ value_message +'\',\''+ value_ip +'\','+ value_port +',"'+ value_params+'")\n';
  return code;
};