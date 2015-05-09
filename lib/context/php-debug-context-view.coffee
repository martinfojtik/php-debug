{Disposable} = require 'atom'
{$, ScrollView} = require 'atom-space-pen-views'
ContextView = require './context-view'

module.exports =
class PhpDebugContextView extends ScrollView
  @content: ->
    @div class: 'php-debug php-debug-context-view pane-item native-key-bindings padded', style: "overflow:auto;", tabindex: -1, =>
      @div outlet: 'contextViewList', class:'php-debug-contexts'

  serialize: ->
    deserializer: @constructor.name
    uri: @getURI()

  getURI: -> @uri

  getTitle: -> "Context"

  initialize: (params) ->
    super
    @GlobalContext = params.context
    @GlobalContext.onContextUpdate @showContexts

  onDidChangeTitle: -> new Disposable ->
  onDidChangeModified: -> new Disposable ->

  isEqual: (other) ->
    other instanceof PhpDebugContextView

  # setDebugContext: (context) ->
  #   @debugContext = context
  #   @showContexts()

  showContexts: =>
    if @contextViewList
      @contextViewList.empty()
    contexts = @GlobalContext.getCurrentDebugContext()
    for index, context of contexts.scopeList
      if context == undefined
        continue
      @contextViewList.append(new ContextView(context))
