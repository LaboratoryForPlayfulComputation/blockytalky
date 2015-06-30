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
 * @fileoverview Generating Elixir for list blocks.
 * @author matthew.ahrens@tufts.edu (Matthew Ahrens)
 */
'use strict';

goog.provide('Blockly.Elixir.lists');

goog.require('Blockly.Elixir');


Blockly.Elixir['lists_create_empty'] = function(block) {
  // Create an empty list.
  return ['[]', Blockly.Elixir.ORDER_ATOMIC];
};

Blockly.Elixir['lists_create_with'] = function(block) {
  // Create a list with any number of elements of any type.
  var code = new Array(block.itemCount_);
  for (var n = 0; n < block.itemCount_; n++) {
    code[n] = Blockly.Elixir.valueToCode(block, 'ADD' + n,
        Blockly.Elixir.ORDER_NONE) || 'nil';
  }
  code = '[' + code.join(', ') + ']';
  return [code, Blockly.Elixir.ORDER_ATOMIC];
};

Blockly.Elixir['lists_repeat'] = function(block) {
  // Create a list with one element repeated.
  var argument0 = Blockly.Elixir.valueToCode(block, 'ITEM',
      Blockly.Elixir.ORDER_NONE) || 'nil';
  var argument1 = Blockly.Elixir.valueToCode(block, 'NUM',
      Blockly.Elixir.ORDER_MULTIPLICATIVE) || '0';
  var code = '[' + argument0 + '] |> Stream.cycle |> Stream.take(' + argument1') |> Enum.to_list';
  return [code, Blockly.Elixir.ORDER_FUNCTION_CALL];
};

Blockly.Elixir['lists_length'] = function(block) {
  // List length.
  var argument0 = Blockly.Elixir.valueToCode(block, 'VALUE',
      Blockly.Elixir.ORDER_NONE) || '[]';
  return ['length(' + argument0 + ')', Blockly.Elixir.ORDER_FUNCTION_CALL];
};

Blockly.Elixir['lists_isEmpty'] = function(block) {
  // Is the list empty?
  var argument0 = Blockly.Elixir.valueToCode(block, 'VALUE',
      Blockly.Elixir.ORDER_NONE) || '[]';
  var code = 'Enum.empty?(' + argument0 + ')';
  return [code, Blockly.Elixir.ORDER_FUNCTION_CALL];
};

Blockly.Elixir['lists_indexOf'] = function(block) {
  // Find an item in the list.
  var argument0 = Blockly.Elixir.valueToCode(block, 'FIND',
      Blockly.Elixir.ORDER_NONE) || '[]';
  var argument1 = Blockly.Elixir.valueToCode(block, 'VALUE',
      Blockly.Elixir.ORDER_MEMBER) || '\'\'';
  var code;
  if (block.getFieldValue('END') == 'FIRST') {
    /*var functionName = Blockly.Elixir.provideFunction_(
        'first_index',
        ['def ' + Blockly.Elixir.FUNCTION_NAME_PLACEHOLDER_ + '(myList, elem):',
         '  try: theIndex = myList.index(elem) + 1',
         '  except: theIndex = 0',
         '  return theIndex']);
    code = functionName + '(' + argument1 + ', ' + argument0 + ')';*/
    code = argument1 + ' |> Enum.find_index( &(&1 == ' + argument0 + '))';
    return [code, Blockly.Elixir.ORDER_FUNCTION_CALL];
  } else {
    // var functionName = Blockly.Elixir.provideFunction_(
    //     'last_index',
    //     ['def ' + Blockly.Elixir.FUNCTION_NAME_PLACEHOLDER_ + '(myList, elem):',
    //      '  try: theIndex = len(myList) - myList[::-1].index(elem)',
    //      '  except: theIndex = 0',
    //      '  return theIndex']);
    // code = functionName + '(' + argument1 + ', ' + argument0 + ')';
    code = argument1 + ' |> Enum.reverse |> Enum.find_index(&(&1 == '+ argument0 +')) |> (&(length('+ argument1 +') - (&1 + 1))).()'
    return [code, Blockly.Elixir.ORDER_FUNCTION_CALL];
  }
};

Blockly.Elixir['lists_getIndex'] = function(block) {
  // Get element at index.
  // Note: Until January 2013 this block did not have MODE or WHERE inputs.
  var mode = block.getFieldValue('MODE') || 'GET';
  var where = block.getFieldValue('WHERE') || 'FROM_START';
  var at = Blockly.Elixir.valueToCode(block, 'AT',
      Blockly.Elixir.ORDER_UNARY_SIGN) || '1';
  var list = Blockly.Elixir.valueToCode(block, 'VALUE',
      Blockly.Elixir.ORDER_MEMBER) || '[]';

  if (where == 'FIRST') {
    if (mode == 'GET') {
      //var code = list + '[0]';
      var code = list + ' |> List.first'
      return [code, Blockly.Elixir.ORDER_MEMBER];
    } else {
      //var code = list + '.pop(0)';
      var code = '[head | tail] = ' + list + '; tail'
      return code + '\n';
    }
  } else if (where == 'LAST') {
    if (mode == 'GET') {
      var code = list + '|> List.last';
      return [code, Blockly.Elixir.ORDER_MEMBER];
    } else {
        var code = '[head | tail] = ' + list ' |> Enum.reverse; Enum.reverse(tail)'
        return code + '\n';
    }
  } else if (where == 'FROM_START') {
    // Blockly uses one-based indicies.
    if (Blockly.isNumber(at)) {
      // If the index is a naked number, decrement it right now.
      at = parseInt(at, 10) - 1;
    } else {
      // If the index is dynamic, decrement it in code.
      at =  '(' + at  + '-1)';
    }
    if (mode == 'GET') {
      var code = list + '|> Enum.at(' + at + ')';
      return [code, Blockly.Elixir.ORDER_MEMBER];
    } else {
      var code = list + '.pop(' + at + ')';
      return code + '\n';
    }
  } else if (where == 'FROM_END') {
    if (mode == 'GET') {
      var code = list + '|> List.delete_at('+ at +')';
      return [code, Blockly.Elixir.ORDER_MEMBER];
    } else {
      var code = list + '|> List.deleta_at(length('+ list + ') - '+ at +' + 1)';
      return code + '\n';
    }
  } else if (where == 'RANDOM') {
    if (mode == 'GET') {
      code = list ' |> Enum.shuffle |> List.first';
      return [code, Blockly.Elixir.ORDER_FUNCTION_CALL];
    } else {
      code = list '|> Enum.delete_at(:random.uniform(length('+list+') - 1))';
      return code + '\n';
    }
  }
  throw 'Unhandled combination (lists_getIndex).';
};

Blockly.Elixir['lists_setIndex'] = function(block) {
  // Set element at index.
  // Note: Until February 2013 this block did not have MODE or WHERE inputs.
  var list = Blockly.Elixir.valueToCode(block, 'LIST',
      Blockly.Elixir.ORDER_MEMBER) || '[]';
  var mode = block.getFieldValue('MODE') || 'GET';
  var where = block.getFieldValue('WHERE') || 'FROM_START';
  var at = Blockly.Elixir.valueToCode(block, 'AT',
      Blockly.Elixir.ORDER_NONE) || '1';
  var value = Blockly.Elixir.valueToCode(block, 'TO',
      Blockly.Elixir.ORDER_NONE) || 'None';
  // Cache non-trivial values to variables to prevent repeated look-ups.
  // Closure, which accesses and modifies 'list'.
  function cacheList() {
    if (list.match(/^\w+$/)) {
      return '';
    }
    var listVar = Blockly.Elixir.variableDB_.getDistinctName(
        'tmp_list', Blockly.Variables.NAME_TYPE);
    var code = listVar + ' = ' + list + '\n';
    list = listVar;
    return code;
  }
  if (where == 'FIRST') {
    if (mode == 'SET') {
      return '[ _ | tail ] = ' + list + '; [ ' + value + ' | tail]'
    } else if (mode == 'INSERT') {
      return '['+ value + '|'+ list +']' + '\n';
    }
  } else if (where == 'LAST') {
    if (mode == 'SET') {
      return '[ _ | tail ] = ' + list + ' |> Enum.reverse ; [ ' + value + ' | tail] |> Enum.reverse'
    } else if (mode == 'INSERT') {
      return list + '++ [' + value + ']' + '\n';
    }
  } else if (where == 'FROM_START') {
    // Blockly uses one-based indicies.
    if (Blockly.isNumber(at)) {
      // If the index is a naked number, decrement it right now.
      at = parseInt(at, 10) - 1;
    } else {
      // If the index is dynamic, decrement it in code.
      at = '(' + at + '-1)';
    }
    if (mode == 'SET') {
      return list + '|> List.replace_at(' + at + ',' + value + ')\n';
    } else if (mode == 'INSERT') {
      return list + '|> List.insert_at(' + at + ',' + value + ')\n';
    }
  } else if (where == 'FROM_END') {
    if (mode == 'SET') {
      return list + '|> Enum.reverse |> List.replace_at(' + at + ',' + value + ') |> Enum.reverse \n';
    } else if (mode == 'INSERT') {
      return list + '|> Enum.reverse |> List.insert_at(' + at + ',' + value + ') |> Enum.reverse \n';
    }
  } else if (where == 'RANDOM') {
    at = ':random.uniform(length('+list+')-1)'
    if (mode == 'SET') {
      return list + '|> List.replace_at(' + at + ',' + value + ')\n';
    } else if (mode == 'INSERT') {
      return list + '|> List.insert_at(' + at + ',' + value + ')\n';
    }
  }
  throw 'Unhandled combination (lists_setIndex).';
};

// Blockly.Elixir['lists_getSublist'] = function(block) {
//   // Get sublist.
//   var list = Blockly.Elixir.valueToCode(block, 'LIST',
//       Blockly.Elixir.ORDER_MEMBER) || '[]';
//   var where1 = block.getFieldValue('WHERE1');
//   var where2 = block.getFieldValue('WHERE2');
//   var at1 = Blockly.Elixir.valueToCode(block, 'AT1',
//       Blockly.Elixir.ORDER_ADDITIVE) || '1';
//   var at2 = Blockly.Elixir.valueToCode(block, 'AT2',
//       Blockly.Elixir.ORDER_ADDITIVE) || '1';
//   if (where1 == 'FIRST' || (where1 == 'FROM_START' && at1 == '1')) {
//     at1 = '';
//   } else if (where1 == 'FROM_START') {
//     // Blockly uses one-based indicies.
//     if (Blockly.isNumber(at1)) {
//       // If the index is a naked number, decrement it right now.
//       at1 = parseInt(at1, 10) - 1;
//     } else {
//       // If the index is dynamic, decrement it in code.
//       at1 = 'int(' + at1 + ' - 1)';
//     }
//   } else if (where1 == 'FROM_END') {
//     if (Blockly.isNumber(at1)) {
//       at1 = -parseInt(at1, 10);
//     } else {
//       at1 = '-int(' + at1 + ')';
//     }
//   }
//   if (where2 == 'LAST' || (where2 == 'FROM_END' && at2 == '1')) {
//     at2 = '';
//   } else if (where1 == 'FROM_START') {
//     if (Blockly.isNumber(at2)) {
//       at2 = parseInt(at2, 10);
//     } else {
//       at2 = 'int(' + at2 + ')';
//     }
//   } else if (where1 == 'FROM_END') {
//     if (Blockly.isNumber(at2)) {
//       // If the index is a naked number, increment it right now.
//       // Add special case for -0.
//       at2 = 1 - parseInt(at2, 10);
//       if (at2 == 0) {
//         at2 = '';
//       }
//     } else {
//       // If the index is dynamic, increment it in code.
//       Blockly.Elixir.definitions_['import_sys'] = 'import sys';
//       at2 = 'int(1 - ' + at2 + ') or sys.maxsize';
//     }
//   }
//   var code = list + '[' + at1 + ' : ' + at2 + ']';
//   return [code, Blockly.Elixir.ORDER_MEMBER];
// };
//
// Blockly.Elixir['lists_split'] = function(block) {
//   // Block for splitting text into a list, or joining a list into text.
//   var mode = block.getFieldValue('MODE');
//   if (mode == 'SPLIT') {
//     var value_input = Blockly.Elixir.valueToCode(block, 'INPUT',
//         Blockly.Elixir.ORDER_MEMBER) || '\'\'';
//     var value_delim = Blockly.Elixir.valueToCode(block, 'DELIM',
//         Blockly.Elixir.ORDER_NONE);
//     var code = value_input + '.split(' + value_delim + ')';
//   } else if (mode == 'JOIN') {
//     var value_input = Blockly.Elixir.valueToCode(block, 'INPUT',
//         Blockly.Elixir.ORDER_NONE) || '[]';
//     var value_delim = Blockly.Elixir.valueToCode(block, 'DELIM',
//         Blockly.Elixir.ORDER_MEMBER) || '\'\'';
//     var code = value_delim + '.join(' + value_input + ')';
//   } else {
//     throw 'Unknown mode: ' + mode;
//   }
//   return [code, Blockly.Elixir.ORDER_FUNCTION_CALL];
// };
