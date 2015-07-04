/**
 * @license
 * Visual Blocks Language
 *
 * Extension of Blockly for Elixir and Elixir like DSLs
 * Specifically, for use with Blockytalky
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
 * @fileoverview Helper functions for generating Elixir for blocks.
 * @author matthew.ahrens@tufts.edu (Matthew Ahrens)
 */
'use strict';

goog.provide('Blockly.Elixir');

goog.require('Blockly.Generator');


/**
 * Elixir code generator.
 * @type !Blockly.Generator
 */
Blockly.Elixir = new Blockly.Generator('Elixir');
/**
 * List of illegal variable names.
 * This is not intended to be a security feature.  Blockly is 100% client-side,
 * so bypassing this list is trivial.  This is intended to prevent users from
 * accidentally clobbering a built-in object or function.
 * @private
 */
Blockly.Elixir.addReservedWords(
    // import keyword
    // print ','.join(keyword.kwlist)
    'after,alias,and,as,assert,def,defp,defdelegate,defmodule,defmacro,defmacrop,defimpl,defcallback,else,except,fn,for,if,import,in,not,or,raise,rescue,try,' +
    'true,false' +
    'set, get' + //custom macros
    'abs,apply,binary_part,binding, case,cd,clear,c,cond,div,exit,flush,get_and_updated_in,get_in,h,hd,inspect,is_atom,is_binary,is_bitstring,is_boolean,is_float,is_function,is_integer,is_list,is_map,is_nil,is_number,is_pid,is_port,is_reference,is_tuple,l,length,ls,macro_exported?,make_ref,map_size,match?,max,min,node,put_elem,put_in,pwd,quote,r,raise,receive,rem,require,reraise,respawn,round,s,self,send,sigil_C,sigil_R,sigil_S,sigilW,sigil_c,sigil_r,sigil_s,sigil_w,spawn,spawn_link,spawn_monitor,struct,super,t,throw,tl,to_char_list,to_string,trunc,try,tuple_size,unless,unqoute,unquote_splicing,update_in,use,v,var');

/**
 * Order of operation ENUMs.
 */
Blockly.Elixir.ORDER_ATOMIC = 0;            // 0 "" ...
Blockly.Elixir.ORDER_COLLECTION = 1;        // tuples, lists, dictionaries
Blockly.Elixir.ORDER_STRING_CONVERSION = 1; // `expression...`
Blockly.Elixir.ORDER_MEMBER = 2;            // . []
Blockly.Elixir.ORDER_FUNCTION_CALL = 2;     // ()
//Blockly.Elixir.ORDER_EXPONENTIATION = 3;    // **
Blockly.Elixir.ORDER_UNARY_SIGN = 4;        // + -
Blockly.Elixir.ORDER_BITWISE_NOT = 4;       // ~~~
Blockly.Elixir.ORDER_MULTIPLICATIVE = 5;    // * / div rem
Blockly.Elixir.ORDER_ADDITIVE = 6;          // + -
Blockly.Elixir.ORDER_BITWISE_SHIFT = 7;     // <<< >>>
Blockly.Elixir.ORDER_BITWISE_AND = 8;       // &&&
Blockly.Elixir.ORDER_BITWISE_XOR = 9;       // ^^^
Blockly.Elixir.ORDER_BITWISE_OR = 10;       // |||
Blockly.Elixir.ORDER_RELATIONAL = 11;       // in, not in, ===, !==
                                            //     <, <=, >, >=, <>, !=, ==
Blockly.Elixir.ORDER_LOGICAL_NOT = 12;      // not
Blockly.Elixir.ORDER_LOGICAL_AND = 13;      // and
Blockly.Elixir.ORDER_LOGICAL_OR = 14;       // or
Blockly.Elixir.ORDER_CONDITIONAL = 15;      // if else
Blockly.Elixir.ORDER_LAMBDA = 16;           // lambda
Blockly.Elixir.ORDER_NONE = 99;             // (...)

/**
 * Empty conditionals are not allowed in Elixir.
 */
Blockly.Elixir.PASS = '  :ok\n';

/**
 * Initialise the database of variable names.
 * @param {!Blockly.Workspace} workspace Workspace to generate code from.
 */
Blockly.Elixir.init = function(workspace) {
  // Create a dictionary of definitions to be printed before the code.
  Blockly.Elixir.definitions_ = Object.create(null);
  // Create a dictionary mapping desired function names in definitions_
  // to actual function names (to avoid collisions with user functions).
  Blockly.Elixir.functionNames_ = Object.create(null);

  if (!Blockly.Elixir.variableDB_) {
    Blockly.Elixir.variableDB_ =
        new Blockly.Names(Blockly.Elixir.RESERVED_WORDS_);
  } else {
    Blockly.Elixir.variableDB_.reset();
  }
};

/**
 * TODO Add docs to this, we edited it in a domain specific way.
 * We added Blockytalky specific boilerplate, mostly to get around statelessness
 * Prepend the generated code with the variable definitions.
 * @param {string} code Generated code.
 * @return {string} Completed code.
 */
Blockly.Elixir.finish = function(code) {
  var definitions = [];
  for (var name in Blockly.Elixir.definitions_) {
    if(name !== "variables")
      definitions.push(Blockly.Elixir.definitions_[name]);
  }
  definitions = definitions.join('\n')
  header = 'defmodule Blockytalky.UserCode do\n' +
            '  use Blockytalky.DSL '
  footer = 'end\n'
  return header + definitions + footer; //ignore code outside of definitions for now
};

/**
 * Naked values are top-level blocks with outputs that aren't plugged into
 * anything.
 * @param {string} line Line of generated code.
 * @return {string} Legal line of code.
 */
Blockly.Elixir.scrubNakedValue = function(line) {
  return line + '\n';
};

/**
 * Encode a string as a properly escaped Elixir string, complete with quotes.
 * @param {string} string Text to encode.
 * @return {string} Elixir string.
 * @private
 */
Blockly.Elixir.quote_ = function(string) {
  // TODO: This is a quick hack.  Replace with goog.string.quote
  string = string.replace(/\\/g, '\\\\')
                 .replace(/\n/g, '\\\n')
                 .replace(/\%/g, '\\%')
                 .replace(/"/g, '\\\"');
  return '"' + string + '"';
};

/**
 * Common tasks for generating Elixir from blocks.
 * Handles comments for the specified block and any connected value blocks.
 * Calls any statements following this block.
 * @param {!Blockly.Block} block The current block.
 * @param {string} code The Elixir code created for this block.
 * @return {string} Elixir code with comments and subsequent blocks added.
 * @private
 */
Blockly.Elixir.scrub_ = function(block, code) {
  var commentCode = '';
  // Only collect comments for blocks that aren't inline.
  if (!block.outputConnection || !block.outputConnection.targetConnection) {
    // Collect comment for this block.
    var comment = block.getCommentText();
    if (comment) {
      commentCode += Blockly.Elixir.prefixLines(comment, '# ') + '\n';
    }
    // Collect comments for all value arguments.
    // Don't collect comments for nested statements.
    for (var x = 0; x < block.inputList.length; x++) {
      if (block.inputList[x].type == Blockly.INPUT_VALUE) {
        var childBlock = block.inputList[x].connection.targetBlock();
        if (childBlock) {
          var comment = Blockly.Elixir.allNestedComments(childBlock);
          if (comment) {
            commentCode += Blockly.Elixir.prefixLines(comment, '# ');
          }
        }
      }
    }
  }
  var nextBlock = block.nextConnection && block.nextConnection.targetBlock();
  var nextCode = Blockly.Elixir.blockToCode(nextBlock);
  return commentCode + code + nextCode;
};
