// Overseer web-frontend heart goes here

// Global variables
var websocket;
var reconnect = null;

///////////   Event handlers   ///////////
$(document).ready(init);

// Auto resize divs
$(document).ready(resize);
$(window).resize(resize);

// "Freeze" command output refreshing
$("#playpause").click(function() {
    togglePause();
});

// Menu items select
$(document).on('click', "a.cmd", function(e){
    e.preventDefault();
    var cmd = $(this).html();
    window.history.pushState("string", "!", cmd);
    resetLinks();
    $(this).blur().toggleClass("current");
    $("#output-body").html('<pre></pre>');
    $("#updated").html("");
    $(this).parent("li").toggleClass("current");
    sendTxt(cmd);
});

///////////   Internal functions   ///////////
// App init
function init() {
    window.paused = true;
    if(!("WebSocket" in window)){
        $('#output').html('<p><span style="color: red;">websockets are not supported </span></p>');
        $("#menu-container").hide();
    } else {
        connect();
        togglePause();
    };
};

// Just resize
function resize() {
    var height = $(window).height() - 32;
    $("#menu, #output").height(height);
};

// Websocket connector
function connect()
{
    wsHost = "ws://" + document.location.host + "/ws"
    websocket = new WebSocket(wsHost);
    websocket.onopen = function(evt) { onOpen(evt) };
    websocket.onclose = function(evt) { onClose(evt) };
    websocket.onmessage = function(evt) { onMessage(evt) };
};

// Websocket onOpen
function onOpen(evt) {
    window.clearInterval(reconnect);
    reconnect = null;
};

// Websocket onClose
function onClose(evt) {
    $("title").html("[DOWN] " + window.hostname);
    if (!reconnect) {
        reconnect = setInterval(connect, 5000); // auto reconnect attempts every 5 seconds after fail
    }
};

// Receiving messages from websocket
function onMessage(evt) {
    var msg = evt.data;
    var data = msg.split("||");
    if (data.length > 2) {
        window.hostname = data[0];
        $("title").html("[UP] " + window.hostname);
        $("#menu ul").html("");
        for (var i = 1; i < data.length; i++) {
            $("#menu ul").append("<li><a class=\"cmd\" href=\"/" + encodeURI(data[i]) + "\">" + data[i] + "</a></li>");
        };
        checkUrl();
    } else {
        if (data[0].substr(0,2) == "$$") {
            $("#command").html("# " + data[0].substr(2));
        } else {
            if(!(window.paused)) {
                datetime();
                $("#output-body").html('<pre>' + msg + '</pre>');
            };
        }
    };
};

// Sending plain text to socket
function sendTxt(txt) {
    if(websocket.readyState == websocket.OPEN){
        websocket.send(txt);
    };
};

function resetLinks() {
    $("#menu li, #menu a.cmd").each( function () {
        $(this).removeClass("current");
    });
};

// Get current date and time formatted
function datetime() {
    var c = new Date();
    var date = c.getDate() + "." + (c.getMonth()<9 ? "0" : "") + (c.getMonth() + 1) + '.' + c.getFullYear();
    var time = c.getHours() + ":" + (c.getMinutes()<10 ? "0" : "") + c.getMinutes() + ":" + (c.getSeconds()<10 ? "0" : "") + c.getSeconds();
    $("#updated").html("Updated " + time + " " + date);
};

function togglePause() {
    if (window.paused) {
        $("#playpause").html("&#x25AE;&#x25AE;").css("color", "#0000ff");
        window.paused = false;
    } else {
        $("#playpause").html("&#x25B6;").css("color", "#00a000");
        window.paused = true;
    }
};

// GET "processing"
function checkUrl() {
    var query = document.location.pathname;
    $('a[href$="' + query + '"]:first').click();
};
