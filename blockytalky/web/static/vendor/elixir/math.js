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
 * @fileoverview Generating Elixir for math blocks.
 * @author matthew.ahrens@tufts.edu (Matthew Ahrens)
 */
'use strict';

goog.provide('Blockly.Elixir.math');

goog.require('Blockly.Elixir');


Blockly.Elixir['math_number'] = function(block) {
  // Numeric value.
  var code = parseFloat(block.getFieldValue('NUM'));
  var order = code < 0 ? Blockly.Elixir.ORDER_UNARY_SIGN :
              Blockly.Elixir.ORDER_ATOMIC;
  return [code, order];
};

Blockly.Elixir['math_arithmetic'] = function(block) {
  // Basic arithmetic operators, and power.
  var OPERATORS = {
    'ADD': [' + ', Blockly.Elixir.ORDER_ADDITIVE],
    'MINUS': [' - ', Blockly.Elixir.ORDER_ADDITIVE],
    'MULTIPLY': [' * ', Blockly.Elixir.ORDER_MULTIPLICATIVE],
    'DIVIDE': [' / ', Blockly.Elixir.ORDER_MULTIPLICATIVE]
    //'POWER': [' pow ', Blockly.Elixir.ORDER_EXPONENTIATION]
  };

  ;
  if(block.getFieldValue('OP') !== 'POWER' ){
    var tuple = OPERATORS[block.getFieldValue('OP')];
    var operator = tuple[0];
    var order = tuple[1];
    var argument0 = Blockly.Elixir.valueToCode(block, 'A', order) || '0';
    var argument1 = Blockly.Elixir.valueToCode(block, 'B', order) || '0';
    var code = argument0 + operator + argument1;
    return [code, order];
  }
  else {
    return [':math.pow('+argument0+','+arugment1+')',Blockly.Elixir.ORDER_FUNCION_CALL]
  }

  // In case of 'DIVIDE', division between integers returns different results
};

Blockly.Elixir['math_single'] = function(block) {
  // Math operators with single operand.
  var operator = block.getFieldValue('OP');
  var code;
  var arg;
  if (operator == 'NEG') {
    // Negation is a special case given its different operator precedence.
    var code = Blockly.Elixir.valueToCode(block, 'NUM',
        Blockly.Elixir.ORDER_UNARY_SIGN) || '0';
    return ['-' + code, Blockly.Elixir.ORDER_UNARY_SIGN];
  }
  if (operator == 'SIN' || operator == 'COS' || operator == 'TAN') {
    arg = Blockly.Elixir.valueToCode(block, 'NUM',
        Blockly.Elixir.ORDER_MULTIPLICATIVE) || '0';
  } else {
    arg = Blockly.Elixir.valueToCode(block, 'NUM',
        Blockly.Elixir.ORDER_NONE) || '0';
  }
  // First, handle cases which generate values that don't need parentheses
  // wrapping the code.
  switch (operator) {
    case 'ABS':
      code = ':math.abs(' + arg + ')';
      break;
    case 'ROOT':
      code = ':math.sqrt(' + arg + ')';
      break;
    case 'LN':
      code = ':math.log(' + arg + ')';
      break;
    case 'LOG10':
      code = ':math.log10(' + arg + ')';
      break;
    case 'EXP':
      code = ':math.exp(' + arg + ')';
      break;
    case 'POW10':
      code = 'math.pow(10,' + arg + ')';
      break;
    case 'ROUND':
      code = 'round(' + arg + ')';
      break;
    case 'ROUNDUP':
      code = 'Float.ceil(' + arg + ')';
      break;
    case 'ROUNDDOWN':
      code = 'Float.floor(' + arg + ')';
      break;
    case 'SIN':
      code = ':math.sin(' + arg + ' / 180.0 * math.pi)';
      break;
    case 'COS':
      code = ':math.cos(' + arg + ' / 180.0 * math.pi)';
      break;
    case 'TAN':
      code = ':math.tan(' + arg + ' / 180.0 * math.pi)';
      break;
  }
  if (code) {
    return [code, Blockly.Elixir.ORDER_FUNCTION_CALL];
  }
  // Second, handle cases which generate values that may need parentheses
  // wrapping the code.
  switch (operator) {
    case 'ASIN':
      code = ':math.asin(' + arg + ') / (:math.pi * 180)';
      break;
    case 'ACOS':
      code = ':math.acos(' + arg + ') / (:math.pi * 180)';
      break;
    case 'ATAN':
      code = ':math.atan(' + arg + ') / (:math.pi * 180)';
      break;
    default:
      throw 'Unknown math operator: ' + operator;
  }
  return [code, Blockly.Elixir.ORDER_MULTIPLICATIVE];
};

Blockly.Elixir['math_constant'] = function(block) {
  // Constants: PI, E, the Golden Ratio, sqrt(2), 1/sqrt(2).
  var CONSTANTS = {
    'PI': [':math.pi', Blockly.Elixir.ORDER_MEMBER],
    'E': [':math.exp(1)', Blockly.Elixir.ORDER_MEMBER],
    'GOLDEN_RATIO': ['(1 + :math.sqrt(5)) / 2', //floating point division
                     Blockly.Elixir.ORDER_MULTIPLICATIVE],
    'SQRT2': [':math.sqrt(2)', Blockly.Elixir.ORDER_MEMBER],
    'SQRT1_2': [':math.sqrt(1.0 / 2)', Blockly.Elixir.ORDER_MEMBER],
  };
  var constant = block.getFieldValue('CONSTANT');
  return CONSTANTS[constant];
};

Blockly.Elixir['math_number_property'] = function(block) {
  // Check if a number is even, odd, prime, whole, positive, or negative
  // or if it is divisible by certain number. Returns true or false.
  var number_to_check = Blockly.Elixir.valueToCode(block, 'NUMBER_TO_CHECK',
      Blockly.Elixir.ORDER_MULTIPLICATIVE) || '0';
  var dropdown_property = block.getFieldValue('PROPERTY');
  var code;
  if (dropdown_property == 'PRIME') {
    Blockly.Elixir.definitions_['require_integer'] = 'require Integer';
    var functionName = Blockly.Elixir.provideFunction_(
        'math_isPrime',
        ['def ' + Blockly.Elixir.FUNCTION_NAME_PLACEHOLDER_ + '(n) do',
         '  # https://en.wikipedia.org/wiki/Primality_test#Naive_methods',
         '  # If n is not a number but a string, try parsing it.',
         '  if is_binary(n) do',
         '    {n,_} = Float.parse(n)',
         '  end                     ',
         '  cond do',
         '    n == 2 or n == 3 -> true',
         '    # False if n is negative, is 1, or not whole,' +
             ' or if n is divisible by 2 or 3.',
         '    n <= 1 or rem(n,1) != 0 or rem(n,2) == 0 or rem(n,3) == 0 -> false',
         '    # Check all the numbers of form 6k +/- 1, up to sqrt(n).',
         '    false in (for x <- 6..(round(math.sqrt(n)) + 2) do',
         '      if rem(n, (x - 1)) == 0 or rem(n, (x + 1)) == 0, do: false, else: true',
         '    end) -> false',
         '    true -> true',
         '  end']);
    code = functionName + '(' + number_to_check + ')';
    return [code, Blockly.Elixir.ORDER_FUNCTION_CALL];
  }
  switch (dropdown_property) {
    case 'EVEN':
      code = 'rem('+number_to_check + ',2) == 0';
      break;
    case 'ODD':
      code = 'rem('+number_to_check + ',2) == 1';
      break;
    case 'WHOLE':
      code = '{whole, rem} = inspect ' + number_to_check + '|> Integer.parse; rem == ""';
      break;
    case 'POSITIVE':
      code = number_to_check + ' > 0'
      break;
    case 'NEGATIVE':
      code = number_to_check + ' < 0';
      break;
    case 'DIVISIBLE_BY':
      var divisor = Blockly.Elixir.valueToCode(block, 'DIVISOR',
          Blockly.Elixir.ORDER_MULTIPLICATIVE);
      // If 'divisor' is some code that evals to 0, Elixir will raise an error.
      if (!divisor || divisor == '0') {
        return ['false', Blockly.Elixir.ORDER_ATOMIC];
      }
      code = 'rem (' + number_to_check + ' , ' + divisor + ')' + ' == 0';
      break;
  }
  return [code, Blockly.Elixir.ORDER_RELATIONAL];
};

Blockly.Elixir['math_change'] = function(block) {
  // Add to a variable in place.
  var argument0 = Blockly.Elixir.valueToCode(block, 'DELTA',
      Blockly.Elixir.ORDER_ADDITIVE) || '0';
  var varName = Blockly.Elixir.variableDB_.getName(block.getFieldValue('VAR'),
      Blockly.Variables.NAME_TYPE);
  return varName + ' = '+ varName + ' + (' +argument0 + ')\n';
};

// Rounding functions have a single operand.
Blockly.Elixir['math_round'] = Blockly.Elixir['math_single'];
// Trigonometry functions have a single operand.
Blockly.Elixir['math_trig'] = Blockly.Elixir['math_single'];

Blockly.Elixir['math_on_list'] = function(block) {
  // Math functions for lists.
  var func = block.getFieldValue('OP');
  var list = Blockly.Elixir.valueToCode(block, 'LIST',
      Blockly.Elixir.ORDER_NONE) || '[]';
  var code;
  switch (func) {
    case 'SUM':
      code = 'Enum.sum(' + list + ')';
      break;
    case 'MIN':
      code = 'Enum.min(' + list + ')';
      break;
    case 'MAX':
      code = 'Enum.max(' + list + ')';
      break;
    case 'AVERAGE':
      code = list + '|> Enum.filter(fn x -> is_integer(x) or is_float(x) end) |> (fn list -> Enum.sum(list) / length(list) end).()';
      break;
    case 'MEDIAN':
      code = '{t1,t2} = Enum.split(Enum.sort('+list+'),div(length('+list+'),2)); [head|_] = t2; head';
      break;
    case 'MODE':
      code = '{l, m} = ' + list + '\n|> Enum.reduce(%{}, fn(x, acc) -> Map.put(acc,x,(if Map.has_key?(acc,x),'+
      ' do: Map.get(acc,x) + 1, else: 0)) end) \n|> Enum.sort(fn {k1,v1}, {k2,v2} -> v1 > v2 end)'+
      ' \n|> Enum.reduce({[],0}, fn {key,val}, {list,max} ->'+
      ' if val >= max, do: {list ++ [key], val}, else: {list, max} end); l ';
      break;
    case 'STD_DEV':
      var functionName = Blockly.Elixir.provideFunction_(
          'math_standard_deviation',
          ['def ' + Blockly.Elixir.FUNCTION_NAME_PLACEHOLDER_ + '(numbers) do',
           '  n = length(numbers)',
           '  unless n == 0, do',
           '    mean = Enum.sum(numbers) / n',
           '    variance = Enum.sum( for x <- numbers, do: :math.pow(x - mean, 2)) / n',
           '    :math.sqrt(variance)',
           '  else 0',
           '  end',
           'end']);
      code = functionName + '(' + list + ')';
      break;
    case 'RANDOM':
      code = 'Enum.at('+list+',:random.uniform(length('+list+')-1))';
      break;
    default:
      throw 'Unknown operator: ' + func;
  }
  return [code, Blockly.Elixir.ORDER_FUNCTION_CALL];
};

Blockly.Elixir['math_modulo'] = function(block) {
  // Remainder computation.
  var argument0 = Blockly.Elixir.valueToCode(block, 'DIVIDEND',
      Blockly.Elixir.ORDER_MULTIPLICATIVE) || '0';
  var argument1 = Blockly.Elixir.valueToCode(block, 'DIVISOR',
      Blockly.Elixir.ORDER_MULTIPLICATIVE) || '0';
  var code = 'rem(' + argument0 + ',' + argument1 + ')';
  return [code, Blockly.Elixir.ORDER_MULTIPLICATIVE];
};

Blockly.Elixir['math_constrain'] = function(block) {
  // Constrain a number between two limits.
  var argument0 = Blockly.Elixir.valueToCode(block, 'VALUE',
      Blockly.Elixir.ORDER_NONE) || '0';
  var argument1 = Blockly.Elixir.valueToCode(block, 'LOW',
      Blockly.Elixir.ORDER_NONE) || '0';
  var argument2 = Blockly.Elixir.valueToCode(block, 'HIGH',
      Blockly.Elixir.ORDER_NONE) || 'float(\'inf\')';
  var code = 'cond do\n'+
             argument0 + ' < ' + argument1 + '->' + argument1 + '\n' +
             argument0 + ' > ' + argument2 + '->' + argument2 + '\n' +
             'true -> '+ argument0 +'\n end \n';
  return [code, Blockly.Elixir.ORDER_FUNCTION_CALL];
};

Blockly.Elixir['math_random_int'] = function(block) {
  // Random integer between [X] and [Y].
  var argument0 = Blockly.Elixir.valueToCode(block, 'FROM',
      Blockly.Elixir.ORDER_NONE) || '0';
  var argument1 = Blockly.Elixir.valueToCode(block, 'TO',
      Blockly.Elixir.ORDER_NONE) || '0';
  var code = ':random.uniform(' + argument1 + ' - ' + argument0 + ') + ' + argument0;
  return [code, Blockly.Elixir.ORDER_FUNCTION_CALL];
};

Blockly.Elixir['math_random_float'] = function(block) {
  // Random fraction between 0 and 1.
  return [':random.uniform()', Blockly.Elixir.ORDER_FUNCTION_CALL];
};

Blockly.Blocks['math_scale'] = {
  init: function() {
    this.appendValueInput("NAME")
        .setCheck("Number")
        .appendField(new Blockly.FieldDropdown([["multiply", "multiply"], ["divide", "divide"]]), "scale_type")
        .appendField(new Blockly.FieldVariable("item"), "NAME")
        .appendField("by");
    this.setPreviousStatement(true, null);
    this.setNextStatement(true, null);
    this.setTooltip('');
    this.setHelpUrl('http://www.example.com/');
  }
};
Blockly.Elixir['math_scale'] = function(block) {
  var dropdown_scale_type = block.getFieldValue('scale_type');
  var variable_name = Blockly.Elixir.variableDB_.getName(block.getFieldValue('NAME'), Blockly.Variables.NAME_TYPE);
  var value = Blockly.Elixir.valueToCode(block, 'NAME', Blockly.Elixir.ORDER_ATOMIC);
  // TODO: Assemble JavaScript into code variable.
  var code = 'math_scale("' + variable_name + '", "' + dropdown_scale_type + '", ' + value + ');\n';
  console.log(code);
  return code;
};