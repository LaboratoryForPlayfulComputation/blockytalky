/**
 * Visual Block Language
 * BT Music
 * @fileoverview Generate Elixir for BT <-> SonicPi
 * @author matthew.ahrens@tufts.edu (Matthew Ahrens)
 * Generated with: https://blockly-demo.appspot.com/static/demos/blockfactory/index.html
 */
'use strict';

goog.provide('Blockly.Elixir.music');

goog.require('Blockly.Elixir');
//motif and playing
Blockly.Blocks['defmotif'] = {
  init: function() {
    this.appendValueInput("NAME")
        .setCheck("String")
        .appendField("Create the motif:");
    this.appendStatementInput("DO")
        .setCheck(null)
        .appendField("as:");
    this.setColour(290);
    this.setTooltip('');
    this.setHelpUrl('http://www.example.com/');
  }
};
Blockly.Elixir['defmotif'] = function(block) {
  var value_name = Blockly.Elixir.valueToCode(block, 'NAME', Blockly.Elixir.ORDER_ATOMIC);
  var statements_do = Blockly.Elixir.statementToCode(block, 'DO');
  // TODO: Assemble Elixir into code variable.
  var code = '...';
  return code;
};

//play
Blockly.Blocks['play_synth'] = {
  init: function() {
    this.appendValueInput("NOTES")
        .setCheck(["String", "Array", "Number"])
        .appendField("play ");
    this.appendValueInput("BEATS")
        .setCheck("Number")
        .appendField(" for");
    this.appendDummyInput()
        .appendField("beats");
    this.setInputsInline(true);
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setColour(290);
    this.setTooltip('');
    this.setHelpUrl('http://www.example.com/');
  }
};
Blockly.Elixir['play_synth'] = function(block) {
  var value_notes = Blockly.Elixir.valueToCode(block, 'NOTES', Blockly.Elixir.ORDER_ATOMIC);
  var value_beats = Blockly.Elixir.valueToCode(block, 'BEATS', Blockly.Elixir.ORDER_ATOMIC);
  // TODO: Assemble Elixir into code variable.
  var code = '...';
  return code;
};
Blockly.Blocks['rest'] = {
  init: function() {
    this.appendValueInput("AMOUNT")
        .setCheck("Number")
        .appendField("rest for");
    this.appendDummyInput()
        .appendField(new Blockly.FieldDropdown([["beats", ":beats"], ["measures", ":measures"], ["option", "OPTIONNAME"]]), "UNITS");
    this.setInputsInline(true);
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setColour(290);
    this.setTooltip('');
    this.setHelpUrl('http://www.example.com/');
  }
};
Blockly.Elixir['rest'] = function(block) {
  var value_amount = Blockly.Elixir.valueToCode(block, 'AMOUNT', Blockly.Elixir.ORDER_ATOMIC);
  var dropdown_units = block.getFieldValue('UNITS');
  // TODO: Assemble Elixir into code variable.
  var code = '...';
  return code;
};
Blockly.Blocks['play_sample'] = {
  init: function() {
    this.appendValueInput("BEATS")
        .setCheck("String")
        .appendField("play sample");
    this.setInputsInline(true);
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setColour(290);
    this.setTooltip('');
    this.setHelpUrl('http://www.example.com/');
  }
};
Blockly.Elixir['play_sample'] = function(block) {
  var value_beats = Blockly.Elixir.valueToCode(block, 'BEATS', Blockly.Elixir.ORDER_ATOMIC);
  // TODO: Assemble Elixir into code variable.
  var code = '...';
  return code;
};
Blockly.Blocks['wait_for'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("wait for:")
        .appendField(new Blockly.FieldDropdown([["downbeat", ":down_beat"], ["option", ":up_beat"], ["beat 1", ":beat1"], ["beat 2", ":beat2"], ["beat 3", ":beat3"], ["beat 4", ":beat4"]]), "UNITS");
    this.setInputsInline(true);
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setColour(290);
    this.setTooltip('');
    this.setHelpUrl('http://www.example.com/');
  }
};
Blockly.Elixir['wait_for'] = function(block) {
  var dropdown_units = block.getFieldValue('UNITS');
  // TODO: Assemble Elixir into code variable.
  var code = '...';
  return code;
};
Blockly.Blocks['cue'] = {
  init: function() {
    this.appendValueInput("MOTIF")
        .setCheck("String")
        .appendField("cue motif:");
    this.setInputsInline(true);
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setColour(290);
    this.setTooltip('');
    this.setHelpUrl('http://www.example.com/');
  }
};
Blockly.Elixir['cue'] = function(block) {
  var value_motif = Blockly.Elixir.valueToCode(block, 'MOTIF', Blockly.Elixir.ORDER_ATOMIC);
  // TODO: Assemble Elixir into code variable.
  var code = '...';
  return code;
};
Blockly.Blocks['sync_to_parent'] = {
  init: function() {
    this.appendValueInput("PARENT")
        .setCheck("String")
        .appendField("sync to BTU");
    this.setInputsInline(true);
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setColour(290);
    this.setTooltip('');
    this.setHelpUrl('http://www.example.com/');
  }
};
Blockly.Elixir['sync_to_parent'] = function(block) {
  var value_parent = Blockly.Elixir.valueToCode(block, 'PARENT', Blockly.Elixir.ORDER_ATOMIC);
  // TODO: Assemble Elixir into code variable.
  var code = '...';
  return code;
};
