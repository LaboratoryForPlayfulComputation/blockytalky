/**
 * @license
 * Visual Blocks Language
 *
 * Copyright 2012 Google Inc.
 * https://developers.google.com/blockly/
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 * @fileoverview Generating Elixir for microbit blocks.
 * @author sahana.sadagopan@colorado.edu (Sahana Sadagopan)
 * Generated with:https://blockly-demo.appspot.com/static/demos/blockfactory/index.html#pjgeta
 */
'use strict';

goog.provide('Blockly.Elixir.microbit');

goog.require('Blockly.Elixir');
Blockly.Blocks['microbit_button'] = {
  init: function() {
    this.appendDummyInput()
        .appendField(new Blockly.FieldImage("https://images.duckduckgo.com/iu/?u=https%3A%2F%2Fcdn2.iconfinder.com%2Fdata%2Ficons%2Fmetro-uinvert-dock%2F256%2FSignal.png&f=1", 15, 15, "*"))
        .appendField("on radio received")
        .appendField(new Blockly.FieldDropdown([["name ","name"], ["received numer","received_number"],["value","value"]]), "button")
        .appendField(new Blockly.FieldDropdown([["value","1"], ["name","0"]]), "status");
    this.appendStatementInput("DO")
        .setCheck(null);
    this.setPreviousStatement(true, null);
    this.setColour(90);
    this.setTooltip('');
    this.setHelpUrl('');
  }
};
Blockly.Elixir['microbit_button'] = function(block) {
  var dropdown_button = block.getFieldValue('Button');
  var dropdown_name = block.getFieldValue('status');
  var statements_do = Blockly.Elixir.statementToCode(block, 'DO');
  var code = dropdown_button+'=='+dropdown_name + statements_do ;
  return [code, Blockly.Elixir.ORDER_NONE];
};

Blockly.Blocks['set_group'] = {
  init: function() {
    this.appendDummyInput()
        .appendField(new Blockly.FieldImage("https://images.duckduckgo.com/iu/?u=https%3A%2F%2Fcdn2.iconfinder.com%2Fdata%2Ficons%2Fmetro-uinvert-dock%2F256%2FSignal.png&f=1", 15, 15, "*"))
        .appendField("set GroupID to");
    this.appendValueInput("groupID")
        .setCheck("Number");
    this.setInputsInline(true);
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour(90);
    this.setTooltip('');
    this.setHelpUrl('');
  }
};

Blockly.Elixir['set_group'] = function(block) {
  var value_groupid = Blockly.Elixir.valueToCode(block, 'groupID', Blockly.Elixir.ORDER_ATOMIC);
  var code = 'send_val('+value_groupid+')\n';
  return code;
};


Blockly.Blocks['Sendmicrobit_value'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("send value through USB");
    this.appendValueInput("inputdata")
        .setCheck("Number");
    this.setInputsInline(true);
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour(90);
    this.setTooltip('');
    this.setHelpUrl('');
  }
};

Blockly.Elixir['Sendmicrobit_value'] = function(block) {
  var value_inputdata = Blockly.Elixir.valueToCode(block, 'inputdata', Blockly.Elixir.ORDER_ATOMIC);
  var code = 'send_val('+value_inputdata+')\n';
  return code;
};


Blockly.Blocks['radio_send'] = {
  init: function() {
    this.appendDummyInput()
        .appendField(new Blockly.FieldImage("https://images.duckduckgo.com/iu/?u=https%3A%2F%2Fcdn2.iconfinder.com%2Fdata%2Ficons%2Fmetro-uinvert-dock%2F256%2FSignal.png&f=1", 15, 15, "*"))
        .appendField("radio send number");
    this.appendValueInput("Number")
        .setCheck("Number");
    this.setInputsInline(true);
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour(90);
    this.setTooltip('');
    this.setHelpUrl('');
  }
};
Blockly.Elixir['radio_send'] = function(block) {
  var value_number = Blockly.Elixir.valueToCode(block, 'Number', Blockly.Elixir.ORDER_ATOMIC);
  var code = 'send_no('+value_number+')\n';
  return code;
};
Blockly.Blocks['radio_receive'] = {
  init: function() {
    this.appendDummyInput()
        .appendField(new Blockly.FieldImage("https://images.duckduckgo.com/iu/?u=https%3A%2F%2Fcdn2.iconfinder.com%2Fdata%2Ficons%2Fmetro-uinvert-dock%2F256%2FSignal.png&f=1", 15, 15, "*"))
        .appendField("on radio received");
    this.appendStatementInput("thenDo")
        .setCheck(null)
        .appendField(new Blockly.FieldDropdown([["recievednumber","receivednumber"], ["variable","variable"], ["item,","item"]]), "data");
    this.setColour(90);
    this.setTooltip('');
    this.setHelpUrl('');
  }
};

Blockly.Elixir['radio_receive'] = function(block) {
  var dropdown_data = block.getFieldValue('data');
  var statements_thendo = Blockly.Elixir.statementToCode(block, 'thenDo');
  var code = dropdown_data + '\n';
  return code;
};

Blockly.Blocks['received'] = {
  init: function() {
    this.appendDummyInput()
        .appendField(new Blockly.FieldImage("https://images.duckduckgo.com/iu/?u=https%3A%2F%2Fcdn2.iconfinder.com%2Fdata%2Ficons%2Fmetro-uinvert-dock%2F256%2FSignal.png&f=1", 15, 15, "*"))
        .appendField("on radio received")
        .appendField(new Blockly.FieldDropdown([["received string","recieved_str"], ["string","str"]]), "str");
    this.appendStatementInput("NAME")
        .setCheck(null);
    this.setColour(90);
    this.setTooltip('');
    this.setHelpUrl('');
  }
};

Blockly.Elixir['received'] = function(block) {
  var dropdown_str = block.getFieldValue('str');
  var statements_name = Blockly.Elixir.statementToCode(block, 'NAME');
  var code = statement_name +'\n';
  return [code,Blockly.Elixir.ORDER_NONE];
};

Blockly.Blocks['send_key'] = {
  init: function() {
    this.appendDummyInput()
        .appendField(new Blockly.FieldImage("https://images.duckduckgo.com/iu/?u=https%3A%2F%2Fcdn2.iconfinder.com%2Fdata%2Ficons%2Fmetro-uinvert-dock%2F256%2FSignal.png&f=1", 15, 15, "*"))
        .appendField("radio send key value");
    this.appendValueInput("NAME")
        .setCheck("String");
    this.appendValueInput("key_value")
        .setCheck("Number");
    this.setInputsInline(true);
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour(90);
    this.setTooltip('');
    this.setHelpUrl('');
  }
};


Blockly.Elixir['send_key'] = function(block) {
  var value_name = Blockly.Elixir.valueToCode(block, 'NAME', Blockly.Elixir.ORDER_ATOMIC);
  var value_key_value = Blockly.Elixir.valueToCode(block, 'key_value', Blockly.Elixir.ORDER_ATOMIC);
  var code = 'serial_wrap('+value_name+','+value_key_value+')\n';
  return code;
};

