config = require 'config'
fs     = require 'fs'

write = (params, done) ->
  data = params
  data.logs = JSON.parse(data.logs) if data.logs?
  if data.logs?
    logs = data.logs.map((l) -> JSON.stringify(l)).join("\n") + "\n"
    fs.appendFile "#{config.data.folder}/#{data.application}.log", logs, (err) -> 
      console.error(err) if err?

  done null, true

module.exports = {
  write
}
