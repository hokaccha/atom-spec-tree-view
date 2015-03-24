{Disposable, CompositeDisposable} = require 'atom'
{View, $$} = require 'atom-space-pen-views'
parser = require './parser'
{TreeView} = require './tree-view'

module.exports =
class SpecTreeView extends View
  @content: ->
    @div class: 'spec-tree-view tool-panel focusable-panel'

  initialize: ->
    @treeView = new TreeView
    @append(@treeView)
    @disposables = new CompositeDisposable
    @states = new WeakMap()
    @handleEvents()

  handleEvents: ->
    @treeView.onSelect ({item}) =>
      position = [item.line - 1, 0]
      editor = atom.workspace.getActiveTextEditor()
      editor.scrollToBufferPosition(position, center: true)
      editor.setCursorBufferPosition(position)
      editor.moveToFirstCharacterOfLine()

  handleEditorEvents: (editor) ->
    @editorHandlers?.dispose()
    @editorHandlers = null

    if @states.has(editor)
      @editorHandlers = new CompositeDisposable
      @editorHandlers.add editor.onDidSave => @setState(editor)

  toggle: (editor) ->
    if @states.has(editor)
      @removeState(editor)
    else
      @setState(editor)

    @handleEditorEvents(editor)

  setState: (editor) ->
    try
      specTree = parser.parse(editor.getText())
    catch e
      console.error e.message

    @states.set(editor, specTree || [])
    @render(editor)

  removeState: (editor) ->
    @states.delete(editor)
    @render(editor)

  render: (editor) ->
    tree = @states.get(editor)

    if tree
      @treeView.setRoot({ label: 'root', children: tree })
      @panel.show()
    else
      @panel.hide()

  attach: ->
    @panel = atom.workspace.addRightPanel(item: this, visible: false)
    @disposables.add new Disposable =>
      @panel.destroy()
      @panel = null

    @disposables.add atom.workspace.onDidChangeActivePaneItem (editor) =>
      @handleEditorEvents(editor)
      @render(editor)

  detach: ->
    @disposables.dispose()
    @editorHandlers?.dispose()

  destroy: ->
    @detach()
