config = require 'config'
fs     = require 'fs'

timedLog = (log) -> 
  log["@fields"] and (log["@fields"]["timestart-id"] or log["@fields"]["timestart-end"])

write = (params, done) ->
  data = params
  data.logs = JSON.parse(data.logs) if data.logs?
  if data.logs?
    logsToWrite = data.logs.filter (log) -> not timedLog(log)
      
    logsToWrite = logsToWrite.logs.map((l) -> JSON.stringify(l)).join("\n") + "\n"
    fs.appendFile "#{config.data.folder}/#{data.application}.log", logs, (err) -> 
      console.error(err) if err?

    timedLogs = data.logs.filter (log) -> timedLog(log)
    console.log timedLogs

  done null, true

module.exports = {
  write
}
