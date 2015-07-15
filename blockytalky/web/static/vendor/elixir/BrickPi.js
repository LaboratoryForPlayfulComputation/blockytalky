/**
 * Visual Block Language
 * BT Brick Pi sensor and motor related blocks
 * @fileoverview Generate Elixir for BT <-> Brickpi
 * @author matthew.ahrens@tufts.edu (Matthew Ahrens)
 * Generated with: https://blockly-demo.appspot.com/static/demos/blockfactory/index.html
 */
 'use strict';

 goog.provide('Blockly.Elixir.brickpi');

 goog.require('Blockly.Elixir');
 //when touch / sensor
 Blockly.Blocks['when_touch'] = {
   init: function() {
     this.appendDummyInput()
         .appendField("When touch sensor on port:")
         .appendField(new Blockly.FieldDropdown([["Port 1", "PORT_1"], ["Port 2", "PORT_2"], ["Port 3", "PORT_3"], ["Port 4", "PORT_4"]]), "port")
         .appendField(new Blockly.FieldDropdown([["is pressed", "1"], ["is released", "0"]]), "status");
     this.appendStatementInput("DO")
         .setCheck(['BP','Event','Message']);
     this.setInputsInline(true);
     this.setColour(160);
     this.setTooltip('');
     this.setHelpUrl('http://www.example.com/');
   }
 };
 Blockly.Elixir['when_touch'] = function(block) {
   var dropdown_port = block.getFieldValue('port');
   var dropdown_status = block.getFieldValue('status');
   var statements_do = Blockly.Elixir.statementToCode(block, 'DO');
   // TODO: Assemble Elixir into code variable.
   var code = 'when_sensor "'+ dropdown_port +'" == '+ dropdown_status + ' do\n '+statements_do +'\n end\n';
   Blockly.Elixir.macros_.push(code);
   return code;
 };
 Blockly.Blocks['when_sensor'] = {
   init: function() {
     this.appendDummyInput()
         .appendField("When value of port:")
         .appendField(new Blockly.FieldDropdown([["Port 1", "PORT_1"], ["Port 2", "PORT_2"], ["Port 3", "PORT_3"], ["Port 4", "PORT_4"], ["Motor 1", "PORT_A"], ["Motor 2", "PORT_B"], ["Motor 3", "PORT_C"], ["Motor 4", "PORT_D"]]), "port")
         .appendField(new Blockly.FieldDropdown([["equals", "=="], ["does not equal", "!="], ["is less than", "<"], ["is less than or equal to", "<="], ["is greater than", ">"], ["is greater than or equal to", ">="]]), "comp");
     this.appendValueInput("NUM")
         .setCheck("Number");
     this.appendStatementInput("DO")
         .setCheck(['BP','Event','Message']);
     this.setInputsInline(true);
     this.setColour(160);
     this.setTooltip('');
     this.setHelpUrl('http://www.example.com/');
   }
 };
Blockly.Elixir['when_sensor'] = function(block) {
  var dropdown_port = block.getFieldValue('port');
  var dropdown_comp = block.getFieldValue('comp');
  var value_name = Blockly.Elixir.valueToCode(block, 'NUM', Blockly.Elixir.ORDER_ATOMIC);
  var statements_do = Blockly.Elixir.statementToCode(block, 'DO');
  // TODO: Assemble Elixir into code variable.
  var code = 'when_sensor "'+ dropdown_port +'" '+dropdown_comp+' '+ value_name + ' do\n '+statements_do +'\n end\n';
  Blockly.Elixir.macros_.push(code);
  return code;
};
Blockly.Blocks['when_sensor_range'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("When value of port:")
        .appendField(new Blockly.FieldDropdown([["Port 1", "PORT_1"], ["Port 2", "PORT_2"], ["Port 3", "PORT_3"], ["Port 4", "PORT_4"], ["Motor 1", "PORT_A"], ["Motor 2", "PORT_B"], ["Motor 3", "PORT_C"], ["Motor 4", "PORT_D"]]), "port");
    this.appendValueInput("NUM1")
        .setCheck("Number")
        .appendField("is")
        .appendField(new Blockly.FieldDropdown([["in", "true"], ["not", "false"]]), "range")
        .appendField("between");
    this.appendValueInput("NUM2")
        .setCheck("Number");
    this.appendStatementInput("DO")
        .setCheck(['BP','Event','Message']);
    this.setInputsInline(true);
    this.setColour(160);
    this.setTooltip('');
    this.setHelpUrl('http://www.example.com/');
  }
};
Blockly.Elixir['when_sensor_range'] = function(block) {
  var dropdown_port = block.getFieldValue('port');
  var dropdown_range = block.getFieldValue('range');
  var value_num1 = Blockly.Elixir.valueToCode(block, 'NUM1', Blockly.Elixir.ORDER_ATOMIC);
  var value_num2 = Blockly.Elixir.valueToCode(block, 'NUM2', Blockly.Elixir.ORDER_ATOMIC);
  var statements_do = Blockly.Elixir.statementToCode(block, 'DO');
  // TODO: Assemble Elixir into code variable.
  var code = 'when_sensor "'+dropdown_port+'" in '+value_num1+'..'+value_num2+' do\n '+statements_do+'\n end\n';
  Blockly.Elixir.macros_.push(code);
  return code;
};

//while
Blockly.Blocks['while_touch'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("While touch sensor on port:")
        .appendField(new Blockly.FieldDropdown([["Port 1", "PORT_1"], ["Port 2", "PORT_2"], ["Port 3", "PORT_3"], ["Port 4", "PORT_4"]]), "port")
        .appendField(new Blockly.FieldDropdown([["is pressed", "1"], ["is released", "0"]]), "status");
    this.appendStatementInput("DO")
        .setCheck(['BP','Event','Message']);
    this.setInputsInline(true);
    this.setColour(20);
    this.setTooltip('');
    this.setHelpUrl('http://www.example.com/');
  }
};
Blockly.Elixir['while_touch'] = function(block) {
  var dropdown_port = block.getFieldValue('port');
  var dropdown_status = block.getFieldValue('status');
  var statements_do = Blockly.Elixir.statementToCode(block, 'DO');
  // TODO: Assemble Elixir into code variable.
  var code = 'while_sensor "'+ dropdown_port +'" == '+ dropdown_status + ' do\n '+statements_do +'\n end\n';
  Blockly.Elixir.macros_.push(code);
  return code;
};
Blockly.Blocks['while_sensor'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("While value of port:")
        .appendField(new Blockly.FieldDropdown([["Port 1", "PORT_1"], ["Port 2", "PORT_2"], ["Port 3", "PORT_3"], ["Port 4", "PORT_4"], ["Motor 1", "PORT_A"], ["Motor 2", "PORT_B"], ["Motor 3", "PORT_C"], ["Motor 4", "PORT_D"]]), "port")
        .appendField(new Blockly.FieldDropdown([["equals", "=="], ["does not equal", "!="], ["is less than", "<"], ["is less than or equal to", "<="], ["is greater than", ">"], ["is greater than or equal to", ">="]]), "comp");
    this.appendValueInput("NUM")
        .setCheck("Number");
    this.appendStatementInput("DO")
        .setCheck(['BP','Event','Message']);
    this.setInputsInline(true);
    this.setColour(20);
    this.setTooltip('');
    this.setHelpUrl('http://www.example.com/');
  }
};
Blockly.Elixir['while_sensor'] = function(block) {
 var dropdown_port = block.getFieldValue('port');
 var dropdown_comp = block.getFieldValue('comp');
 var value_name = Blockly.Elixir.valueToCode(block, 'NUM', Blockly.Elixir.ORDER_ATOMIC);
 var statements_do = Blockly.Elixir.statementToCode(block, 'DO');
 // TODO: Assemble Elixir into code variable.
 var code = 'while_sensor "'+ dropdown_port +'" '+dropdown_comp+' '+ value_name + ' do\n '+statements_do +'\n end\n';
 Blockly.Elixir.macros_.push(code);
 return code;
};
Blockly.Blocks['while_sensor_range'] = {
 init: function() {
   this.appendDummyInput()
       .appendField("While value of port:")
       .appendField(new Blockly.FieldDropdown([["Port 1", "PORT_1"], ["Port 2", "PORT_2"], ["Port 3", "PORT_3"], ["Port 4", "PORT_4"], ["Motor 1", "PORT_A"], ["Motor 2", "PORT_B"], ["Motor 3", "PORT_C"], ["Motor 4", "PORT_D"]]), "port");
   this.appendValueInput("NUM1")
       .setCheck("Number")
       .appendField("is")
       .appendField(new Blockly.FieldDropdown([["in", "true"], ["not", "false"]]), "range")
       .appendField("between");
   this.appendValueInput("NUM2")
       .setCheck("Number");
   this.appendStatementInput("DO")
       .setCheck(['BP','Event','Message']);
   this.setInputsInline(true);
   this.setColour(20);
   this.setTooltip('');
   this.setHelpUrl('http://www.example.com/');
 }
};
Blockly.Elixir['while_sensor_range'] = function(block) {
 var dropdown_port = block.getFieldValue('port');
 var dropdown_range = block.getFieldValue('range');
 var value_num1 = Blockly.Elixir.valueToCode(block, 'NUM1', Blockly.Elixir.ORDER_ATOMIC);
 var value_num2 = Blockly.Elixir.valueToCode(block, 'NUM2', Blockly.Elixir.ORDER_ATOMIC);
 var statements_do = Blockly.Elixir.statementToCode(block, 'DO');
 var code = 'while_sensor "'+dropdown_port+'" in '+value_num1+'..'+value_num2+' do\n '+statements_do+'\n end\n';
 Blockly.Elixir.macros_.push(code);
 return code;
};

//values
Blockly.Blocks['get_sensor'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("Get value of ")
        .appendField(new Blockly.FieldDropdown([["Port 1", "PORT_1"], ["Port 2", "PORT_2"], ["Port 3", "PORT_3"], ["Port 4", "PORT_4"], ["Motor 1", "PORT_A"], ["Motor 2", "PORT_B"], ["Motor 3", "PORT_C"], ["Motor 4", "PORT_D"]]), "port");
    this.setInputsInline(true);
    this.setOutput(true, "Number");
    this.setColour(260);
    this.setTooltip('');
    this.setHelpUrl('http://www.example.com/');
  }
};
Blockly.Elixir['get_sensor'] = function(block) {
  var dropdown_port = block.getFieldValue('port');
  var code = 'get_sensor_value("'+dropdown_port+'")\n';
  return [code, Blockly.Elixir.ORDER_NONE];
};
Blockly.Blocks['set_motor'] = {
  init: function() {
    this.appendValueInput("SPEED")
        .setCheck("Number")
        .appendField("Set motor")
        .appendField(new Blockly.FieldDropdown([["1", "\"PORT_A\""], ["2", "\"PORT_B\""], ["3", "\"PORT_C\""], ["4", "\"PORT_D\""]]), "NAME")
        .appendField("speed to:");
    this.setInputsInline(true);
    this.setPreviousStatement(true, ['BP','Event','Message']);
    this.setNextStatement(true, 'BP');
    this.setColour(120);
    this.setTooltip('');
    this.setHelpUrl('http://www.example.com/');
  }
};
Blockly.Elixir['set_motor'] = function(block) {
  var dropdown_name = block.getFieldValue('NAME');
  var value_speed = Blockly.Elixir.valueToCode(block, 'SPEED', Blockly.Elixir.ORDER_ATOMIC);
  // TODO: Assemble Elixir into code variable.
  var code = 'bp_set_motor_speed('+dropdown_name+','+value_speed+')\n';
  return code;
};
