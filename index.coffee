bf      = require 'barefoot'
express = require 'express'
config  = require 'config'
fs      = require 'fs'

logger  = require './controllers/logger'

app = express()

app.configure () ->
  app.use express.cookieParser()
  app.use express.bodyParser()
  app.use app.router


app.all '*', (req, res, next) -> 
  console.log new Date(), req.url
  next()


app.get '/:application/i', bf.webService(logger.parse)


process.setuid(config.uid) if config.uid
app.listen config.web.port

console.log new Date()
console.log "--->  Tracking server has been restarted on port #{config.web.port}"
