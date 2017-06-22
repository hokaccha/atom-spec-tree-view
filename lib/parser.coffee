esprima = require 'esprima'
estraverse = require 'estraverse'

types = ['describe', 'context', 'it']
parserOptions = {
  loc: true,
  sourceType: 'module',
  tolerant: true
}

module.exports.parse = (source) ->
  return traverse(esprima.parse(source, parserOptions))

isTarget = (node) ->
  node.type == 'CallExpression' && types.indexOf(node.callee.name) != -1;

isFinish = (node) ->
  node.callee.name == 'it';

traverse = (ast) ->
  children = [];

  estraverse.traverse ast,
    enter: (node) ->
      return unless isTarget(node)

      child = {
        type: node.callee.name
        text: node.arguments[0].value
        line: node.loc.start.line
      }

      if !isFinish(node)
        child.children = traverse(node.arguments[1].body)

      children.push child
      @skip();

  return children
