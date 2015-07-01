/**
 * Visual Block Language
 * BrickPi related blocks
 * @fileoverview Generate Elixir for brickpi blocks
 * @author matthew.ahrens@tufts.edu (Matthew Ahrens)
 */
 // 'use strict'

 if(!Blockly.Language) Blockly.Language= {};
 //constant

 /* Block Language Definitions and Elixir implementations */
 // events
 // values
 Blockly.Language.sensor_touch= {
   category:"Sensors",
   helpUrl:"",
   init:function() {
   this.setColour(50);
   this.appendDummyInput("")
       .appendTitle("Touch Sensor:");
   this.appendDummyInput("")
       .appendTitle("Port")
       .appendTitle(new Blockly.FieldDropdown([["1","1"],["2","2"],
           ["3","3"],["4","4"]]),"port");
   this.appendDummyInput("")
       .appendTitle(new Blockly.FieldDropdown([["is pressed","1"],["is released","0"]]),"status");
   this.setInputsInline(true);
   this.setOutput(true, 'Boolean');
   this.setPreviousStatement(false);
   this.setNextStatement(false);
   this.setTooltip("Returns the status of a touch sensor");
   }
};
Blockly.Elixir.sensor_touch=function() {
   var p=this.getTitleValue("port") - 1;
   var s=this.getTitleValue("status");
   code = '(bp_get_sensor_value('+p+') == ' + s + ')';
   return [code, Blockly.Elixir.ORDER_ATOMIC];
};
