/**
 * @license
 * Visual Blocks Language
 *
 * BlockyTalky
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
 * @fileoverview Generating Elixir for variable blocks.
 * @author matthew.ahrens@tufts.edu (Matthew Ahrens)
 */
'use strict';

goog.provide('Blockly.Elixir.variables');

goog.require('Blockly.Elixir');


Blockly.Elixir['variables_get'] = function(block) {
  // Variable getter.
  var code = Blockly.Elixir.variableDB_.getName(block.getFieldValue('VAR'),
      Blockly.Variables.NAME_TYPE);
  return [code, Blockly.Elixir.ORDER_ATOMIC];
};

Blockly.Elixir['variables_set'] = function(block) {
  // Variable setter.
  var argument0 = Blockly.Elixir.valueToCode(block, 'VALUE',
      Blockly.Elixir.ORDER_NONE) || 'nil';
  var varName = Blockly.Elixir.variableDB_.getName(block.getFieldValue('VAR'),
      Blockly.Variables.NAME_TYPE);
  return varName + ' = ' + argument0 + '\n';
};
