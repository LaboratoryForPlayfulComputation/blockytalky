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
     this.setPreviousStatement(true, 'Message');
     this.setNextStatement(true, 'Message');
     this.setColour(120);
     this.setTooltip('');
     this.setHelpUrl('http://www.example.com/');
   }
 };
   Blockly.Elixir['send'] = function(block) {
  var value_msg = Blockly.Elixir.valueToCode(block, 'msg', Blockly.Elixir.ORDER_ATOMIC);
  var value_to = Blockly.Elixir.valueToCode(block, 'to', Blockly.Elixir.ORDER_ATOMIC);
  var code = 'send_message('+value_msg+','+value_to+')\n';
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
    this.setPreviousStatement(true, 'Message');
    this.setNextStatement(true, 'Message');
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
