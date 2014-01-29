config = require 'config'
fs     = require 'fs'
_      = require 'underscore'

isTimedLog = (log) -> isStartLog(log) or isEndLog(log)

isStartLog = (log) -> 
  log["@fields"]? and log["@fields"]["timestart-id"]

isEndLog = (log) -> 
  log["@fields"]? and log["@fields"]["timeend-id"]


dicoCacheTimedLogs = {}

parse = (params, done) ->
  data = params
  if data.logs?
    data.logs = data.logs.replace(/[\n\r\t]*/g, '')
    console.log data.logs
    data.logs = JSON.parse(data.logs) if data.logs?

    logsToWrite = data.logs.filter (log) -> not isTimedLog log
    write { logs: logsToWrite, application: data.application }
    timedLogs = data.logs.filter (log) -> isTimedLog(log)
    dicoCacheTimedLogs[data.application] ?= []
    dicoCacheTimedLogs[data.application] = dicoCacheTimedLogs[data.application].concat timedLogs
    processTimedLogs()

  done null, true

write = ({ logs, application }, done) ->
  logsStr = logs.map((l) -> JSON.stringify(l)).join("\n")
  logsStr += "\n" if logs.length > 0
  fs.appendFile "#{config.data.folder}/#{application}.log", logsStr, (err) -> 
    console.error(err) if err?
    done(null, true) if done?


processTimedLogs = ({}, done) -> 
  for application, cacheTimedLogs of dicoCacheTimedLogs
    cacheTimedLogs.sort()
    starts = cacheTimedLogs.filter isStartLog
    ends = cacheTimedLogs.filter isEndLog

    extracted = []
    starts.forEach (start) ->
      id = start["@fields"]["timestart-id"]
      time = start["@timestamp"]
      type = start["@type"]

      matchingEnds = ends.filter (end) ->
        (end["@timestamp"] > time) and (end["@type"] == type) and (end["@fields"]["timeend-id"] == id)

      if matchingEnds.length > 0
        end = matchingEnds[0]
        duration = end["@timestamp"] - start["@timestamp"]

        fields = _.extend start["@fields"], end["@fields"]
        event = start
        event["@fields"] = fields
        event["@fields"]["duration"] = duration

        delete event["@fields"]["timestart-id"]
        delete event["@fields"]["timeend-id"]

        extracted.push event

    write { logs: extracted, application: application }
    cacheTimedLogs = []


module.exports = {
  parse
}
