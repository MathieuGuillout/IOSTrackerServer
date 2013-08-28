bf = require 'barefoot'
express = require 'express'
config = require 'config'
fs = require 'fs'

app = express()

app.configure () ->
  app.use express.cookieParser()
  app.use express.bodyParser()
  app.use app.router

app.all '*', (req, res, next) -> 
  console.log new Date(), req.url
  next()

app.get '/:application/i', bf.webService (params, done) -> 
  data = params
  data.metrics = JSON.parse(data.metrics) if data.metrics?
  data.logs = JSON.parse(data.logs) if data.logs?
  if data.logs?
    logs = data.logs.map((l) -> JSON.stringify(l)).join("\n") + "\n"
    fs.appendFile "#{config.data.folder}/#{data.application}.log", logs, (err) -> 
      console.error(err) if err?
      console.log "Log file written"

  done null, null


# STARTING THE WEB SERVER
process.setuid(config.uid) if config.uid
app.listen config.web.port
console.log new Date()
console.log "--->  Logs has been restarted on port #{config.web.port}"
