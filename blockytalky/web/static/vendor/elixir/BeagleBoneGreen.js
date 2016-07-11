/**
 * Visual Block Language
 * BT BeagleBoneGreen component related blocks
 * @fileoverview Generate Elixir for BT <-> BeagleBoneGreen
 * @author maya.lassiter@gmail.com (Maya Lassiter)
 * Generated with: https://blockly-demo.appspot.com/static/demos/blockfactory/index.html
 */

'use strict';

goog.provide('Blockly.Elixir.beaglebonegreen');

goog.require('Blockly.Elixir');
Blockly.Blocks['beaglebonegreen_when_button'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("When button on port: ")
        .appendField(new Blockly.FieldDropdown(["UART", ":UART"]), "port")
        .appendField(new Blockly.FieldDropdown([["is pressed", "1"], ["is released", "0"]]), "status");
    this.appendStatementInput("DO")
        .setCheck(null);
    this.setInputsInline(true);
    this.setColour(160);
    this.setTooltip('');
    this.setHelpUrl('');
  }
};
Blockly.Elixir['beaglebonegreen_when_button'] = function(block) {
  var dropdown_port = block.getFieldValue('port');
  var dropdown_status = block.getFieldValue('status');
  var statements_do = Blockly.Elixir.statementToCode(block, 'DO');
  var code = 'when_sensor ' + dropdown_port + ' == '+ dropdown_status + ' do\ '+ statements_do + '\n end\n';
  Blockly.Elixir.macros_.push(code);
  return code;
};
Blockly.Blocks['beaglebonegreen_while_button'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("While button on port: ")
        .appendField(new Blockly.FieldDropdown(["UART", ":UART"]), "port")
        .appendField(new Blockly.FieldDropdown([["is pressed", "1"], ["is released", "0"]]), "status");
    this.appendStatementInput("DO")
        .setCheck(null);
    this.setInputsInline(true);
    this.setColour(20);
    this.setTooltip('');
    this.setHelpUrl('');
  }
};
Blockly.Elixir['beaglebonegreen_while_button'] = function(block) {
  var dropdown_port = block.getFieldValue('port');
  var dropdown_status = block.getFieldValue('status');
  var statements_do = Blockly.Elixir.statementToCode(block, 'DO');
  var code = 'while_sensor ' + dropdown_port + ' == ' + dropdown_status + ' do\n ' + statements_do + '\n end\n';
  Blockly.Elixir.macros_.push(code);
  return code;
};

Blockly.Blocks['beaglebonegreen_when_port'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("When value of port: ")
        .appendField(new Blockly.FieldDropdown([["I2C", ":I2C"], ["UART", ":UART"]]), "port")
        .appendField(new Blockly.FieldDropdown([["equals", "=="], ["does not equal", "!="], ["is less than", "<"], ["is less than or equal to", "<="], ["is great than", ">"], ["is greater than or equal to", ">="]]), "comp");
    this.appendValueInput("NUM")
        .setCheck("Number");
    this.appendStatementInput("DO")
        .setCheck(null);
    this.setInputsInline(true);
    this.setColour(160);
    this.setTooltip('');
    this.setHelpUrl('');
  }
};
Blockly.Elixir['beaglebonegreen_when_port'] = function(block) {
  var dropdown_port = block.getFieldValue('port');
  var dropdown_comp = block.getFieldValue('comp');
  var value_name = Blockly.Elixir.valueToCode(block, 'NUM', Blockly.Elixir.ORDER_ATOMIC);
  var statements_do = Blockly.Elixir.statementToCode(block, 'DO');
  var code = 'when_sensor ' + dropdown_port + ' ' + dropdown_comp + ' ' + value_name + ' do\n ' + statements_do + '\n end\n';
  Blockly.Elixir.macros_.push(code);
};
Blockly.Blocks['beaglebonegreen_while_port'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("While value of port: ")
        .appendField(new Blockly.FieldDropdown([["I2C", ":I2C"], ["UART", ":UART"]]), "port")
        .appendField(new Blockly.FieldDropdown([["equals", "=="], ["does not equal", "!="], ["is less than", "<"], ["is less than or equal to", "<="], ["is great than", ">"], ["is greater than or equal to", ">="]]), "comp");
    this.appendValueInput("NUM")
        .setCheck("Number");
    this.appendStatementInput("DO")
        .setCheck(null);
    this.setInputsInline(true);
    this.setColour(20);
    this.setTooltip('');
    this.setHelpUrl('');
  }
};
Blockly.Elixir['beaglebonegreen_while_port'] = function(block) {
  var dropdown_port = block.getFieldValue('port');
  var dropdown_comp = block.getFieldValue('comp');
  var value_name = Blockly.Elixir.valueToCode(block, 'NUM', Blockly.Elixir.ORDER_ATOMIC);
  var statements_do = Blockly.Elixir.statementToCode(block, 'DO');
  var code = 'while_sensor ' + dropdown_port + ' ' + dropdown_comp + ' ' + value_name + ' do\n ' + statements_do + '\n end\n';
  Blockly.Elixir.macros_.push(code);
  return code;
};

Blockly.Blocks['beaglebonegreen_when_range'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("When value of port: ")
        .appendField(new Blockly.FieldDropdown([["I2C", ":I2C"], ["UART", ":UART"]]), "port");
    this.appendValueInput("NUM1")
        .setCheck("Number")
        .appendField("is")
        .appendField(new Blockly.FieldDropdown([["in", "true"], ["not", "false"]]), "range")
        .appendField("between");
    this.appendValueInput("NUM2")
        .setCheck("Number");
    this.appendStatementInput("DO")
        .setCheck(null);
    this.setInputsInline(true);
    this.setColour(160);
    this.setTooltip('');
    this.setHelpUrl('');
  }
};
Blockly.Elixir['beaglebonegreen_when_range'] = function(block) {
  var dropdown_port = block.getFieldValue('port');
  var dropdown_range = block.getFieldValue('range');
  var value_num1 = Blockly.Elixir.valueToCode(block, 'NUM1', Blockly.Elixir.ORDER_ATOMIC);
  var value_num2 = Blockly.Elixir.valueToCode(block, 'NUM2', Blockly.Elixir.ORDER_ATOMIC);
  var statements_do = Blockly.Elixir.statementToCode(block, 'DO');
  var code = 'when_sensor ' + dropdown_range + ' ' + dropdown_port + ' in ' + value_num1 + '..' + value_num2 + ' do\n ' + statements_do + '\n end\n';
  Blockly.Elixir.macros_.push(code);
  return code;
};

Blockly.Blocks['beaglebonegreen_while_range'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("While value of port: ")
        .appendField(new Blockly.FieldDropdown([["I2C", ":I2C"], ["UART", ":UART"]]), "port");
    this.appendValueInput("NUM1")
        .setCheck("Number")
        .appendField("is")
        .appendField(new Blockly.FieldDropdown([["in", "true"], ["not", "false"]]), "range")
        .appendField("between");
    this.appendValueInput("NUM2")
        .setCheck("Number");
    this.appendStatementInput("DO")
        .setCheck(null);
    this.setInputsInline(true);
    this.setColour(20);
    this.setTooltip('');
    this.setHelpUrl('');
  }
};
Blockly.Elixir['beaglebonegreen_while_range'] = function(block) {
  var dropdown_port = block.getFieldValue('port');
  var dropdown_range = block.getFieldValue('range');
  var value_num1 = Blockly.Elixir.valueToCode(block, 'NUM1', Blockly.Elixir.ORDER_ATOMIC);
  var value_num2 = Blockly.Elixir.valueToCode(block, 'NUM2', Blockly.Elixir.ORDER_ATOMIC);
  var statements_do = Blockly.Elixir.statementToCode(block, 'DO');

  var code = 'while_sensor ' + dropdown_range + ' ' + dropdown_port + ' in ' + value_num1 + '..' + value_num2 + ' do\n ' + statements_do + '\n end\n';
  Blockly.Elixir.macros_.push(code);
  return code;
};
Blockly.Blocks['beaglebonegreen_get_value'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("Get value of port")
        .appendField(new Blockly.FieldDropdown([["I2C", ":I2C"], ["UART", ":UART"]]), "port");
    this.setInputsInline(true);
    this.setOutput(true, "Number");
    this.setColour(260);
    this.setTooltip('');
    this.setHelpUrl('');
  }
};
Blockly.Elixir['beaglebonegreen_get_value'] = function(block) {
  var dropdown_port = block.getFieldValue('port');
  var code = 'get_sensor_value('+dropdown_port+')\n';
  return [code, Blockly.Elixir.ORDER_NONE];
};
Blockly.Blocks['beaglebonegreen_set_value'] = {
  init: function() {
    this.appendValueInput("VALUE")
        .setCheck("Number")
        .appendField("Set component on port")
        .appendField(new Blockly.FieldDropdown([["I2C", ":I2C"], ["UART", ":UART"]]), "port")
        .appendField("to value:");
    this.setInputsInline(true);
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour(120);
    this.setTooltip('');
    this.setHelpUrl('');
  },
  onchange: function() {
    var val = Blockly.Elixir.valueToCode(this, 'VALUE', Blockly.Elixir.ORDER_ATOMIC);
    
    if (val < 0 || val > 1023) {
      this.setWarningText("Value must be between 0 and 1023");
    } else {
      this.setWarningText(null);
    }
  }
};
Blockly.Elixir['beaglebonegreen_set_value'] = function(block) {
  var dropdown_port = block.getFieldValue('port');
  var value = Blockly.Elixir.valueToCode(block, 'VALUE', Blockly.Elixir.ORDER_ATOMIC);
  var code = 'gp_set_value('+dropdown_port+','+value+')\n';
  return code;
};
Blockly.Blocks['beaglebonegreen_set_digital'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("Turn component on port")
        .appendField(new Blockly.FieldDropdown([["I2C", ":I2C"], ["UART", ":UART"]]), "port")
        .appendField(new Blockly.FieldDropdown([["on", "1"], ["off", "0"]]), "value");
    this.setInputsInline(true);
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setColour(120);
    this.setTooltip('');
    this.setHelpUrl('');
  }
};
Blockly.Elixir['beaglebonegreen_set_digital'] = function(block) {
  var dropdown_port = block.getFieldValue('port');
  var value = block.getFieldValue('value');
  var code = 'gp_set_value('+dropdown_port+','+value+')\n';
  return code;
};
Blockly.Blocks['beaglebonegreen_get_temp'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("Get temperature from port")
        .appendField(new Blockly.FieldDropdown([["I2C", ":I2C"], ["UART", ":UART"]]), "port");
    this.setInputsInline(true);
    this.setOutput(true, "Number");
    this.setColour(260);
    this.setTooltip('');
    this.setHelpUrl('');
  }
};
Blockly.Elixir['beaglebonegreen_get_temp'] = function(block) {
  var dropdown_port = block.getFieldValue('port');
  var code = 'gp_get_temp('+dropdown_port+')\n';
  return [code, Blockly.Elixir.ORDER_NONE];
};
Blockly.Blocks['beaglebonegreen_get_hum'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("Get humidity from port")
        .appendField(new Blockly.FieldDropdown([["I2C", ":I2C"], ["UART", ":UART"]]), "port");
    this.setInputsInline(true);
    this.setOutput(true, "Number");
    this.setColour(260);
    this.setTooltip('');
    this.setHelpUrl('');
  }
};
Blockly.Elixir['beaglebonegreen_get_hum'] = function(block) {
  var dropdown_port = block.getFieldValue('port');
  var code = 'gp_get_hum('+dropdown_port+')\n';
  return [code, Blockly.Elixir.ORDER_NONE];
};
