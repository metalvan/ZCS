express = require('express')
app = express()
app.use(express["static"](__dirname + "/client"))

http = require('http').createServer(app)
http.listen 3000
io = require('socket.io').listen(http)


class Object



class Moveable extends Object



class Zombie extends Moveable



class Player extends Moveable



class Connection
  constructor: (@socket) ->




io.sockets.on 'connection', (socket) -> new Connection socket
