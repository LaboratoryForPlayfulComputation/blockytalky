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
        .appendField("Microbit Button")
        .appendField(new Blockly.FieldDropdown([["A is","a"], ["B is","b"]]), "button")
        .appendField(new Blockly.FieldDropdown([["pressed","1"], ["released","0"]]), "status");
    this.appendStatementInput("DO")
        .setCheck(null);
    this.setOutput(true, "Boolean");
    this.setColour(230);
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
        .appendField("set GroupID to");
    this.appendValueInput("groupID")
        .setCheck("Number");
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour(330);
    this.setTooltip('');
    this.setHelpUrl('');
  }
};

Blockly.Elixir['set_group'] = function(block) {
  var value_groupid = Blockly.Elixir.valueToCode(block, 'groupID', Blockly.Elixir.ORDER_ATOMIC);
  // TODO: Assemble JavaScript into code variable.
  var code = 'set('+value_group+')\n';
  // TODO: Change ORDER_NONE to the correct strength.
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


Blockly.Blocks['radiosend'] = {
  init: function() {
    this.appendValueInput("NAME")
        .setCheck(["String", "Number"])
        .appendField("Send value through radio");
    this.setInputsInline(false);
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour(230);
    this.setTooltip('');
    this.setHelpUrl('');
  }
};

Blockly.Elixir['radiosend'] = function(block) {
  var value_name = Blockly.Elixir.valueToCode(block, 'NAME', Blockly.Elixir.ORDER_ATOMIC);
  // TODO: Assemble JavaScript into code variable.
  var code = '...;\n';
  return code;
};

Blockly.Blocks['radio_receive'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("on radio received");
    this.appendStatementInput("thenDo")
        .setCheck(null)
        .appendField(new Blockly.FieldDropdown([["recievednumber","receivednumber"], ["variable","variable"], ["item,","item"]]), "data");
    this.setColour(90);
    this.setTooltip('');
    this.setHelpUrl('');
  }
};

