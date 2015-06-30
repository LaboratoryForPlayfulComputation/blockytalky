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
 * @fileoverview Generating Elixir for text blocks.
 * @author matthew.ahrens@tufts.edu (Matthew Ahrens)
 */
'use strict';

goog.provide('Blockly.Elixir.texts');

goog.require('Blockly.Elixir');


Blockly.Elixir['text'] = function(block) {
  // Text value.
  var code = Blockly.Elixir.quote_(block.getFieldValue('TEXT'));
  return [code, Blockly.Elixir.ORDER_ATOMIC];
};

Blockly.Elixir['text_join'] = function(block) {
  // Create a string made up of any number of elements of any type.
  //Should we allow joining by '-' or ',' or any other characters?
  var code;
  if (block.itemCount_ == 0) {
    return ['""', Blockly.Elixir.ORDER_ATOMIC];
  } else if (block.itemCount_ == 1) {
    var argument0 = Blockly.Elixir.valueToCode(block, 'ADD0',
        Blockly.Elixir.ORDER_NONE) || '""';
    code = 'inspect(' + argument0 + ')';
    return [code, Blockly.Elixir.ORDER_FUNCTION_CALL];
  } else if (block.itemCount_ == 2) {
    var argument0 = Blockly.Elixir.valueToCode(block, 'ADD0',
        Blockly.Elixir.ORDER_NONE) || '""';
    var argument1 = Blockly.Elixir.valueToCode(block, 'ADD1',
        Blockly.Elixir.ORDER_NONE) || '""';
    var code = 'inspect(' + argument0 + ') <> inspect(' + argument1 + ')';
    return [code, Blockly.Elixir.ORDER_UNARY_SIGN];
  } else {
    var code = [];
    for (var n = 0; n < block.itemCount_; n++) {
      code[n] = Blockly.Elixir.valueToCode(block, 'ADD' + n,
          Blockly.Elixir.ORDER_NONE) || '';
    }
    var tempVar = Blockly.Elixir.variableDB_.getDistinctName('temp_value',
        Blockly.Variables.NAME_TYPE);
    code = 'Enum.join [' + code.join(', ') + ']';
    return [code, Blockly.Elixir.ORDER_FUNCTION_CALL];
  }
};

Blockly.Elixir['text_append'] = function(block) {
  // Append to a variable in place.
  var varName = Blockly.Elixir.variableDB_.getName(block.getFieldValue('VAR'),
      Blockly.Variables.NAME_TYPE);
  var argument0 = Blockly.Elixir.valueToCode(block, 'TEXT',
      Blockly.Elixir.ORDER_NONE) || '\'\'';
  return varName + ' = inspect(' + varName + ') <> inspect(' + argument0 + ')\n';
};

Blockly.Elixir['text_length'] = function(block) {
  // String length.
  var argument0 = Blockly.Elixir.valueToCode(block, 'VALUE',
      Blockly.Elixir.ORDER_NONE) || '""';
  return ['String.length(' + argument0 + ')', Blockly.Elixir.ORDER_FUNCTION_CALL];
};

Blockly.Elixir['text_isEmpty'] = function(block) {
  // Is the string null?
  var argument0 = Blockly.Elixir.valueToCode(block, 'VALUE',
      Blockly.Elixir.ORDER_NONE) || '""';
  var code = 'String.length(' + argument0 + ') > 0';
  return [code, Blockly.Elixir.ORDER_LOGICAL_NOT];
};

Blockly.Elixir['text_indexOf'] = function(block) {
  // Search the text for a substring.
  // Should we allow for non-case sensitive???
  var operator = block.getFieldValue('END') == 'FIRST' ? 'find' : 'rfind';
  var argument0 = Blockly.Elixir.valueToCode(block, 'FIND',
      Blockly.Elixir.ORDER_NONE) || '""';
  var argument1 = Blockly.Elixir.valueToCode(block, 'VALUE',
      Blockly.Elixir.ORDER_MEMBER) || '""';
  //var code = argument1 + '.' + operator + '(' + argument0 + ') + 1';
  var code = '{index,_} = Regex.run(~r|' + argument0 +'|,'+argument1+', return: :index) |> List.first; index'

  return [code, Blockly.Elixir.ORDER_MEMBER];
};

Blockly.Elixir['text_charAt'] = function(block) {
  // Get letter at index.
  // Note: Until January 2013 this block did not have the WHERE input.
  var where = block.getFieldValue('WHERE') || 'FROM_START';
  var at = Blockly.Elixir.valueToCode(block, 'AT',
      Blockly.Elixir.ORDER_UNARY_SIGN) || '1';
  var text = Blockly.Elixir.valueToCode(block, 'VALUE',
      Blockly.Elixir.ORDER_MEMBER) || '\'\'';
  switch (where) {
    case 'FIRST':
      var code = text + '[0]';
      return [code, Blockly.Elixir.ORDER_MEMBER];
    case 'LAST':
      var code = text + '[-1]';
      return [code, Blockly.Elixir.ORDER_MEMBER];
    case 'FROM_START':
      // Blockly uses one-based indicies.
      if (Blockly.isNumber(at)) {
        // If the index is a naked number, decrement it right now.
        at = parseInt(at, 10) - 1;
      } else {
        // If the index is dynamic, decrement it in code.
        at = '(' + at + ' -1)';
      }
      var code = 'String.at('+text+','+at+')';
      return [code, Blockly.Elixir.ORDER_MEMBER];
    case 'FROM_END':
      var code = 'String.at('+text+',(String.length('+str+') - '+at+'))';
      return [code, Blockly.Elixir.ORDER_MEMBER];
    case 'RANDOM':
      var code = text + '|> String.at(:random.uniform(String.length('+text+')) - 1)';
      return [code, Blockly.Elixir.ORDER_MEMBER];
  }
  throw 'Unhandled option (text_charAt).';
};

Blockly.Elixir['text_getSubstring'] = function(block) {
  // Get substring.
  var text = Blockly.Elixir.valueToCode(block, 'STRING',
      Blockly.Elixir.ORDER_MEMBER) || '""';
  var where1 = block.getFieldValue('WHERE1');
  var where2 = block.getFieldValue('WHERE2');
  var at1 = Blockly.Elixir.valueToCode(block, 'AT1',
      Blockly.Elixir.ORDER_ADDITIVE) || '1';
  var at2 = Blockly.Elixir.valueToCode(block, 'AT2',
      Blockly.Elixir.ORDER_ADDITIVE) || '1';
  if (where1 == 'FIRST' || (where1 == 'FROM_START' && at1 == '1')) {
    at1 = '';
  } else if (where1 == 'FROM_START') {
    // Blockly uses one-based indicies.
    if (Blockly.isNumber(at1)) {
      // If the index is a naked number, decrement it right now.
      at1 = parseInt(at1, 10) - 1;
    } else {
      // If the index is dynamic, decrement it in code.
      at1 = '(' + at1 + ' - 1)';
    }
  } else if (where1 == 'FROM_END') {
    if (Blockly.isNumber(at1)) {
      at1 = -parseInt(at1, 10);
    } else {
      at1 = '-(' + at1 + ')';
    }
  }
  if (where2 == 'LAST' || (where2 == 'FROM_END' && at2 == '1')) {
    at2 = '';
  } else if (where1 == 'FROM_START') {
    if (Blockly.isNumber(at2)) {
      at2 = parseInt(at2, 10);
    } else {
      at2 = '(' + at2 + ')';
    }
  } else if (where1 == 'FROM_END') {
    if (Blockly.isNumber(at2)) {
      // If the index is a naked number, increment it right now.
      at2 = 1 - parseInt(at2, 10);
      if (at2 == 0) {
        at2 = '';
      }
    } else {
      // If the index is dynamic, increment it in code.
      // Add special case for -0.
      at2 = '(1 - ' + at2 + ')';
    }
  }
  var code = text + '|> binary_part(' + at1 + ' , ' + at2 + ')';
  return [code, Blockly.Elixir.ORDER_MEMBER];
};

Blockly.Elixir['text_changeCase'] = function(block) {
  // Change capitalization.
  var OPERATORS = {
    'UPPERCASE': 'String.upcase ',
    'LOWERCASE': 'String.downcase ',
    'TITLECASE': 'String.capitalize '
  };
  var operator = OPERATORS[block.getFieldValue('CASE')];
  var argument0 = Blockly.Elixir.valueToCode(block, 'TEXT',
      Blockly.Elixir.ORDER_MEMBER) || '\'\'';
  var code =  operator + argument0;
  return [code, Blockly.Elixir.ORDER_MEMBER];
};

Blockly.Elixir['text_trim'] = function(block) {
  // Trim spaces.
  var OPERATORS = {
    'LEFT': 'String.lstrip ',
    'RIGHT': 'String.rstrip ',
    'BOTH': 'String.strip '
  };
  var operator = OPERATORS[block.getFieldValue('MODE')];
  var argument0 = Blockly.Elixir.valueToCode(block, 'TEXT',
      Blockly.Elixir.ORDER_MEMBER) || '\'\'';
  var code = operator + argument0;
  return [code, Blockly.Elixir.ORDER_MEMBER];
};
/* replace this with channel based messaging or something similar, but for now
this file is "domain" non-specific. that is, it does not care about blockytalky
specific implementation */
Blockly.Elixir['text_print'] = function(block) {
  // Print statement.
  var argument0 = Blockly.Elixir.valueToCode(block, 'TEXT',
      Blockly.Elixir.ORDER_NONE) || '""';
  return 'IO.puts(' + argument0 + ')\n';
};
