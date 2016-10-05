oxide.addMessageHandler("RUN_JAVASCRIPT", function (msg) {
    var event = new CustomEvent("QMLmessage", {detail: msg.args});
    document.dispatchEvent(event);
    msg.reply({result: eval(msg.args["script"])});
});

oxide.addMessageHandler("GET_HTML", function (msg) {
    var event = new CustomEvent("QMLmessage", {detail: msg.args});
    document.dispatchEvent(event);
    msg.reply({html: document.documentElement.innerHTML});
});

oxide.addMessageHandler("SET_HTML", function (msg) {
    var event = new CustomEvent("QMLmessage", {detail: msg.args});
    document.dispatchEvent(event);
    document.documentElement.innerHTML = msg.args["html"];
    msg.reply({});
});
