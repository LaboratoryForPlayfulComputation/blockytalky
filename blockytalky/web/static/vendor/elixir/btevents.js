/**
 * Visual Block Language
 * BT Time / Event related blocks
 * @fileoverview Generate Elixir for BT Events
 * @author matthew.ahrens@tufts.edu (Matthew Ahrens)
 * Generated with: https://blockly-demo.appspot.com/static/demos/blockfactory/index.html
 */
 'use strict';

 goog.provide('Blockly.Elixir.events');

 goog.require('Blockly.Elixir');
 Blockly.Blocks['when_start'] = {
   init: function() {
     this.appendDummyInput()
         .appendField("When I start");
     this.appendStatementInput("DO")
         .setCheck(null)
         .appendField("do:");
     this.setColour(160);
     this.setTooltip('');
     this.setHelpUrl('http://www.example.com/');
   }
 };
 Blockly.Elixir['when_start'] = function(block) {
   var statements_do = Blockly.Elixir.statementToCode(block, 'DO');
   var code = 'start do\n '+ statements_do +' \nend';
   Blockly.Elixir.macros_.push(code);
   return code;
 };
 Blockly.Blocks['repeatedly_do'] = {
   init: function() {
     this.appendDummyInput()
         .appendField("Repeatedly");
     this.appendStatementInput("DO")
         .setCheck(null)
         .appendField("do:");
     this.setColour(20);
     this.setTooltip('');
     this.setHelpUrl('http://www.example.com/');
   }
 };
 Blockly.Elixir['repeatedly_do'] = function(block) {
   var statements_do = Blockly.Elixir.statementToCode(block, 'DO');
   var code = 'repeatedly do\n '+ statements_do +' \nend';
   Blockly.Elixir.macros_.push(code);
   return code;
 };
Blockly.Blocks['for_time'] = {
  init: function() {
    this.appendValueInput("TIME")
        .setCheck("Number")
        .appendField("For");
    this.appendDummyInput()
        .appendField("seconds");
    this.appendStatementInput("DO")
        .setCheck(null)
        .appendField("repeatedly do:");
    this.setInputsInline(true);
    this.setPreviousStatement(true, null);
    this.setNextStatement(false, null);
    this.setColour(20);
    this.setTooltip('');
    this.setHelpUrl('http://www.example.com/');
  }
};
Blockly.Elixir['for_time'] = function(block) {
  var value_time = Blockly.Elixir.valueToCode(block, 'TIME', Blockly.Elixir.ORDER_ATOMIC);
  var statements_do = Blockly.Elixir.statementToCode(block, 'DO');
  var code = 'for_time('+value_time+') do\n '+statements_do+' \n end';
  Blockly.Elixir.macros_.push(code);
  return code;
};
Blockly.Blocks['in_time'] = {
  init: function() {
    this.appendValueInput("TIME")
        .setCheck("Number")
        .appendField("In");
    this.appendDummyInput()
        .appendField("seconds");
    this.appendStatementInput("DO")
        .setCheck(null)
        .appendField("do once:");
    this.setInputsInline(true);
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour(160);
    this.setTooltip('');
    this.setHelpUrl('http://www.example.com/');
  }
};
Blockly.Elixir['in_time'] = function(block) {
  var value_time = Blockly.Elixir.valueToCode(block, 'TIME', Blockly.Elixir.ORDER_ATOMIC);
  var statements_do = Blockly.Elixir.statementToCode(block, 'DO');
  var code = 'in_time('+value_time+') do\n '+statements_do+' \n end';
  Blockly.Elixir.macros_.push(code);
  return code;
};
