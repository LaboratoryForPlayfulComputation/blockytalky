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
 * @fileoverview Generating Elixir for procedure blocks.
 * @author matthew.ahrens@tufts.edu (Matthew Ahrens)
 */
'use strict';

goog.provide('Blockly.Elixir.procedures');

goog.require('Blockly.Elixir');


Blockly.Elixir['procedures_defreturn'] = function(block) {
  // Define a procedure with a return value.
  // First, add a 'global' statement for every variable that is assigned.
  var globals = Blockly.Variables.allVariables(block);
  for (var i = globals.length - 1; i >= 0; i--) {
    var varName = globals[i];
    if (block.arguments_.indexOf(varName) == -1) {
      globals[i] = Blockly.Elixir.variableDB_.getName(varName,
          Blockly.Variables.NAME_TYPE);
    } else {
      // This variable is actually a parameter name.  Do not include it in
      // the list of globals, thus allowing it be of local scope.
      //globals.splice(i, 1);
    }
  }
  //TODO global variables?
  //globals = globals.length ? '  global ' + globals.join(', ') + '\n' : '';
  var funcName = Blockly.Elixir.variableDB_.getName(block.getFieldValue('NAME'),
      Blockly.Procedures.NAME_TYPE);
  var branch = Blockly.Elixir.statementToCode(block, 'STACK');
  if (Blockly.Elixir.STATEMENT_PREFIX) {
    branch = Blockly.Elixir.prefixLines(
        Blockly.Elixir.STATEMENT_PREFIX.replace(/%1/g,
        '\'' + block.id + '\''), Blockly.Elixir.INDENT) + branch;
  }
  if (Blockly.Elixir.INFINITE_LOOP_TRAP) {
    branch = Blockly.Elixir.INFINITE_LOOP_TRAP.replace(/%1/g,
        '"' + block.id + '"') + branch;
  }
  var returnValue = Blockly.Elixir.valueToCode(block, 'RETURN',
      Blockly.Elixir.ORDER_NONE) || '';
  if (!branch) {
    branch = Blockly.Elixir.PASS;
  }
  var args = [];
  for (var x = 0; x < block.arguments_.length; x++) {
    args[x] = Blockly.Elixir.variableDB_.getName(block.arguments_[x],
        Blockly.Variables.NAME_TYPE);
  }
  var code = 'def ' + funcName + '(' + args.join(', ') + ') do \n' +
      globals + branch + returnValue +'\n end \n';
  code = Blockly.Elixir.scrub_(block, code);
  Blockly.Elixir.definitions_[funcName] = code;
  return null;
};

// Defining a procedure without a return value uses the same generator as
// a procedure with a return value.
Blockly.Elixir['procedures_defnoreturn'] =
    Blockly.Elixir['procedures_defreturn'];

Blockly.Elixir['procedures_callreturn'] = function(block) {
  // Call a procedure with a return value.
  var funcName = Blockly.Elixir.variableDB_.getName(block.getFieldValue('NAME'),
      Blockly.Procedures.NAME_TYPE);
  var args = [];
  for (var x = 0; x < block.arguments_.length; x++) {
    args[x] = Blockly.Elixir.valueToCode(block, 'ARG' + x,
        Blockly.Elixir.ORDER_NONE) || 'nil';
  }
  var code = funcName + '(' + args.join(', ') + ')';
  return [code, Blockly.Elixir.ORDER_FUNCTION_CALL];
};

Blockly.Elixir['procedures_callnoreturn'] = function(block) {
  // Call a procedure with no return value.
  var funcName = Blockly.Elixir.variableDB_.getName(block.getFieldValue('NAME'),
      Blockly.Procedures.NAME_TYPE);
  var args = [];
  for (var x = 0; x < block.arguments_.length; x++) {
    args[x] = Blockly.Elixir.valueToCode(block, 'ARG' + x,
        Blockly.Elixir.ORDER_NONE) || 'nil';
  }
  var code = funcName + '(' + args.join(', ') + ')\n';
  return code;
};

Blockly.Elixir['procedures_ifreturn'] = function(block) {
  // Conditionally return value from a procedure.
  var condition = Blockly.Elixir.valueToCode(block, 'CONDITION',
      Blockly.Elixir.ORDER_NONE) || 'False';
  var code = 'if ' + condition + ' do \n';
  if (block.hasReturnValue_) {
    var value = Blockly.Elixir.valueToCode(block, 'VALUE',
        Blockly.Elixir.ORDER_NONE) || 'nil';
    code += value + '\n';
  } else {
    code += '  :ok\n';
  }
  return code;
};
