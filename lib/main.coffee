{CompositeDisposable} = require 'atom'

module.exports =
  activate: ->
    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.commands.add 'atom-workspace',
      'spec-tree-view:toggle', =>
        editor = atom.workspace.getActiveTextEditor()
        @getView().toggle(editor)

  deactivate: ->
    @subscriptions?.dispose()
    @view?.destroy()
    @view = null

  getView: ->
    unless @view
      SpecTreeView = require './spec-tree-view'
      @view = new SpecTreeView()
      @view.attach()
    @view
