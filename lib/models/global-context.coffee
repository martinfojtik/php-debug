{serializeArray,deserializeArray, insertOrdered,arrayRemove} = require '../helpers'
{Emitter, Disposable} = require 'event-kit'

module.exports =
class GlobalContext
  atom.deserializers.add(this)
  # @version = '1a'
  constructor: ->
    @emitter = new Emitter
    @breakpoints = []
    @watchpoints = []
    @consoleMessages = []
    @debugContexts = []

    @onSessionEnd () =>
      delete @debugContexts[0]
      @debugContexts = []

  serialize: -> {
    deserializer: 'GlobalContext'
    data: {
      version: @constructor.version
      breakpoints: serializeArray(@getBreakpoints())
      watchpoints: serializeArray(@getWatchpoints())
    }
  }

  @deserialize: ({data}) ->
    context = new GlobalContext()
    breakpoints = deserializeArray(data.breakpoints)
    context.setBreakpoints(breakpoints)
    watchpoints = deserializeArray(data.watchpoints)
    context.setWatchpoints(watchpoints)
    return context

  addBreakpoint: (breakpoint) ->
    insertOrdered  @breakpoints, breakpoint
    data = {
      added: [breakpoint]
    }
    @notifyBreakpointsChange(data)

  removeBreakpoint: (breakpoint) ->
    removed = arrayRemove(@breakpoints, breakpoint)
    if removed
      data = {
        removed: [removed]
      }
      @notifyBreakpointsChange(data)
      return removed

  updateBreakpoint: (breakpoint) ->
    @remoteBreakpoint(breakpoint)
    @addBreakpoint(breakpoint)

  setBreakpoints: (breakpoints) ->
    removed = @breakpoints
    @breakpoints = breakpoints
    data = {
      added: breakpoints
      removed: removed
    }
    @notifyBreakpointsChange(data)

  setWatchpoints: (watchpoints) ->
    @watchpoints = watchpoints
    data = {
      added: watchpoints
    }
    @notifyWatchpointsChange()

  removeWatchpoint: (watchpoint) ->
    removed = arrayRemove(@watchpoints, watchpoint)
    if removed
      data = {
        removed: [removed]
      }
      @notifyWatchpointsChange()
      return removed

  getBreakpoints: ->
    return @breakpoints

  addDebugContext: (debugContext) ->
    @debugContexts.push debugContext

  getCurrentDebugContext: () =>
    return @debugContexts[0]

  addWatchpoint: (watchpoint) ->
    insertOrdered  @watchpoints, watchpoint
    @notifyWatchpointsChange()

  getWatchpoints: ->
    return @watchpoints

  addConsoleMessage: (message) ->
    @consoleMessages.push message
    @notifyConsoleMessage(message)

  getConsoleMessages: (idx) ->
    result =
      lines: @consoleMessages[idx...]
      total: @consoleMessages.length
    return result

  nextConsoleCommand: () ->
    @notifyNextConsoleCommand();
    
  previousConsoleCommand: () ->
    @notifyPreviousConsoleCommand();

  clearConsoleMessages: ->
    @consoleMessages = []
    @notifyConsoleMessagesCleared()

  setContext: (context) ->
    @context = context

  getContext: ->
    return @context

  clearContext: ->

  onPreviousConsoleCommand: (callback) ->
    @emitter.on 'php-debug.previousConsoleCommand', callback

  notifyPreviousConsoleCommand: () ->
    @emitter.emit 'php-debug.previousConsoleCommand'

  onNextConsoleCommand: (callback) ->
    @emitter.on 'php-debug.nextConsoleCommand', callback

  notifyNextConsoleCommand: () ->
    @emitter.emit 'php-debug.nextConsoleCommand'

  onConsoleMessage: (callback) ->
    @emitter.on 'php-debug.consoleMessage', callback

  notifyConsoleMessage: (data) ->
    @emitter.emit 'php-debug.consoleMessage', data

  onConsoleMessagesCleared: (callback) ->
    @emitter.on 'php-debug.consoleMessagesCleared', callback

  notifyConsoleMessagesCleared: (data) ->
    @emitter.emit 'php-debug.consoleMessagesCleared', data

  onBreakpointsChange: (callback) ->
    @emitter.on 'php-debug.breakpointsChange', callback

  notifyBreakpointsChange: (data) ->
    @emitter.emit 'php-debug.breakpointsChange', data

  onWatchpointsChange: (callback) ->
    @emitter.on 'php-debug.watchpointsChange', callback

  notifyWatchpointsChange: (data) ->
    @emitter.emit 'php-debug.watchpointsChange', data

  onBreak: (callback) ->
    @emitter.on 'php-debug.break', callback

  notifyBreak: (data) ->
    @emitter.emit 'php-debug.break', data

  onContextUpdate: (callback) ->
    @emitter.on 'php-debug.contextUpdate', callback

  notifyContextUpdate: (data) ->
    @emitter.emit 'php-debug.contextUpdate', data

  onStackChange: (callback) ->
    @emitter.on 'php-debug.stackChange', callback

  notifyStackChange: (data) ->
    @emitter.emit 'php-debug.stackChange', data

  onSessionEnd: (callback) ->
    @emitter.on 'php-debug.sessionEnd', callback

  notifySessionEnd: (data) ->
    @emitter.emit 'php-debug.sessionEnd', data

  onSocketError: (callback) ->
    @emitter.on 'php-debug.socketError', callback

  notifySocketError: (data) ->
    @emitter.emit 'php-debug.socketError', data

  onSessionStart: (callback) ->
    @emitter.on 'php-debug.sessionStart', callback

  notifySessionStart: (data) ->
    @emitter.emit 'php-debug.sessionStart', data

  onRunning: (callback) ->
    @emitter.on 'php-debug.running', callback

  notifyRunning: (data) ->
    @emitter.emit 'php-debug.running', data
