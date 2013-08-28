config = require 'config'

write = (params, done) ->
  data = params
  data.logs = JSON.parse(data.logs) if data.logs?
  if data.logs?
    logs = data.logs.map((l) -> JSON.stringify(l)).join("\n") + "\n"
    fs.appendFile "#{config.data.folder}/#{data.application}.log", logs, (err) -> 
      console.error(err) if err?
      console.log "Log file written"

  done null, true

module.exports = {
  write
}
