/**
* Visual Block Language
* BT WeMo related blocks
* @fileoverview Generate Elixir for BT control of Belkin WeMo products
* @author ben.shapiro@colorado.edu (Ben Shapiro)
* Generated with: https://blockly-demo.appspot.com/static/demos/blockfactory/index.html
**/

'use strict';

goog.provide('Blockly.Elixir.wemo');

goog.require('Blockly.Elixir');

Blockly.Blocks['wemo_set'] = {
  init: function() {
   this.appendValueInput("device")
       .setCheck(null)
       .appendField("Set device ");
   this.appendDummyInput()
       .appendField("state to ")
       .appendField(new Blockly.FieldDropdown([
         ["On",":on"],
         ["Off",":off"],
         ["Opposite",":toggle"]]), "STATE")
   this.setInputsInline(true);
   this.setPreviousStatement(true, ['Music','BP','Event','Message']);
   this.setNextStatement(true, ['Music','BP','Event','Message']);
   this.setColour(120);
   this.setTooltip('Sets the state of a nearby WeMo device');
  }
};

Blockly.Elixir['wemo_set'] = function(block) {
  var value_state =  block.getFieldValue('STATE');
  var value_device_name = Blockly.Elixir.valueToCode(block, 'device', Blockly.Elixir.ORDER_ATOMIC);

  var context = ':top';
  if (Blockly.Elixir.context != null){
    context = Blockly.Elixir.context;
  }
  var code = 'wemo_set_state('+value_device_name+','+value_state+')\n';
  return code;
}
