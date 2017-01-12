/**
 * Visual Block Language
 * OSC Messaging related blocks
 * @fileoverview Generate Elixir for OSCMessaging
 * @author annie.kelly@colorado.edu (Annie Kelly)
 * Generated with: https://blockly-demo.appspot.com/static/demos/blockfactory/index.html
 */
 'use strict';

 goog.provide('Blockly.Elixir.btmessaging');

 goog.require('Blockly.Elixir');

//receive osc
Blockly.Blocks['receive_osc'] = {
  init: function() {
    this.appendValueInput("msg")
        .setCheck(null)
        .appendField("When I receive OSC message:");
    this.appendStatementInput("DO")
        .setCheck(null)
        .appendField("do:");
    this.setInputsInline(true);
    this.setColour(160);
    this.setTooltip('');
    this.setHelpUrl('http://www.example.com/');
  }
};
Blockly.Elixir['receive_osc'] = function(block) {
  var value_msg = Blockly.Elixir.valueToCode(block, 'msg', Blockly.Elixir.ORDER_ATOMIC);
  var statements_do = Blockly.Elixir.statementToCode(block, 'DO');
  var code = 'when_receive_osc('+value_msg+') do\n '+statements_do+' end\n';
  Blockly.Elixir.macros_.push(code);
  console.log(code);
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
        .setCheck("Lists")
        .setAlign(Blockly.ALIGN_CENTRE);
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour(120);
    this.setTooltip('This block is for sending OSC messages to addresses within or outside the network.' +
      'The destination must be in the format <IP_ADDRESS>:<PORT>, and the parameters must be stored in a list.');
    this.setHelpUrl('http://www.example.com/');
  }
};
Blockly.Elixir['osc'] = function(block) {
  var value_message = Blockly.Elixir.valueToCode(block, 'MESSAGE', Blockly.Elixir.ORDER_ATOMIC);
  var value_ip = Blockly.Elixir.valueToCode(block, 'IP', Blockly.Elixir.ORDER_ATOMIC);
  var value_port = Blockly.Elixir.valueToCode(block, 'PORT', Blockly.Elixir.ORDER_ATOMIC);
  var value_params = Blockly.Elixir.valueToCode(block, 'PARAMS', Blockly.Elixir.ORDER_ATOMIC);
  var code = 'send_osc('+ value_message +','+ value_ip +','+ value_port +','+ value_params+')\n';
  return code;
};

Blockly.Blocks['get_osc_args'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("get arguments list");
    this.setOutput(true, null);
    this.setColour(270);
    this.setTooltip('');
    this.setHelpUrl('');
  }
};
Blockly.Elixir['get_osc_args'] = function(block) {
  // TODO: Assemble JavaScript into code variable.
  var code = "get(:dequeued_osc_args)";
  // TODO: Change ORDER_NONE to the correct strength.
  return [code, Blockly.Elixir.ORDER_NONE];
  //return [code, Blockly.Elixir.ORDER_ATOMIC];
};

Blockly.Blocks['get_osc_sender'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("get sender");
    this.setOutput(true, null);
    this.setColour(270);
    this.setTooltip('');
    this.setHelpUrl('');
  }
};
Blockly.Elixir['get_osc_sender'] = function(block) {
  // TODO: Assemble JavaScript into code variable.
  var code = "get(:dequeued_osc_sender)";
  // TODO: Change ORDER_NONE to the correct strength.
  return [code, Blockly.Elixir.ORDER_NONE];
  //return [code, Blockly.Elixir.ORDER_ATOMIC];
};

