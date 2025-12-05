const express = require("express");
const app = express();
const server = require("http").createServer(app);
const io = require("socket.io")(server);

app.use(express.static(__dirname + "/"));

let players = {};
let tasks = ["Topla 5 elma", "Evini temizle", "Arkadaşını ziyaret et"];

io.on("connection", socket => {
    console.log("Player connected:", socket.id);

    players[socket.id] = {
        id: socket.id,
        x: 400,
        y: 300,
        name: "Player" + socket.id.substring(0, 4),
        money: 0,
        task: tasks[Math.floor(Math.random()*tasks.length)]
    };

    socket.emit("currentPlayers", players);
    socket.broadcast.emit("newPlayer", players[socket.id]);

    // Hareket
    socket.on("move", data => {
        if(players[socket.id]) {
            players[socket.id].x = data.x;
            players[socket.id].y = data.y;
            io.emit("playerMoved", players);
        }
    });

    // Görev tamamla
    socket.on("completeTask", () => {
        if(players[socket.id]) {
            players[socket.id].money += 100; // her görev 100 para
            players[socket.id].task = tasks[Math.floor(Math.random()*tasks.length)];
            io.emit("playerUpdated", players[socket.id]);
        }
    });

    // Chat
    socket.on("chatMessage", msg => {
        io.emit("chatMessage", { id: socket.id, name: players[socket.id].name, msg });
    });

    socket.on("disconnect", () => {
        console.log("Player disconnected:", socket.id);
        delete players[socket.id];
        io.emit("playerDisconnected", socket.id);
    });
});

server.listen(3000, () => {
    console.log("Server running at http://localhost:3000");
});
