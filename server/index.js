const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const http = require("http");
const Document = require('./models/document');

const authRouter = require("./routes/auth");
const documentRouter = require("./routes/document");

const Port = process.env.PORT | 3001;
const DB = "mongodb+srv://mclark:WaterBo1@cluster0.bqg5yzq.mongodb.net/?retryWrites=true&w=majority"

const app = express();
var server = http.createServer(app);
var io = require("socket.io")(server);


app.use(cors());
app.use(express.json())
app.use(authRouter);
app.use(documentRouter);

mongoose.connect(DB).then((data)=> {
    console.log("db connection successful")
}).catch((e) => console.error(e));

io.on('connection', (socket) => {
    socket.on('join', (docId) => {
        socket.join(docId);
        console.log("socket connected " + socket.id);
    })

    socket.on('typing', (data) => {
        socket.broadcast.to(data.room).emit('changes', data);
    })

    socket.on('save', (data) => {
        saveData(data);
    })

    socket.on('leaveRoom', (docId) => {
        socket.leave(docId);
        console.log("socket disconnected " + socket.id);
    })
})
const saveData = async (data) => {
    let document = await Document.findById(data.room);
    if(document) {
        document.contents = data.delta;
        await document.save();
    }
}

server.listen(Port, "0.0.0.0", () => {
    console.log(`server running at port ${Port}`);
});