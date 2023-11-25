function isObject(val) {
  if (val === null) { return false;}
  return ( (typeof val === 'function') || (typeof val === 'object') );
}

var console = { log: function(message) {
  if (isObject(message)) {
    _consoleLog(JSON.stringify(message, null, '\t'));
  } else {
    _consoleLog(message);
  }
}}

function RenderButton() {
    console.log("Hello World from RenderButton!")
    //
    const instance = RNExampleBridge.getInstance()
    console.log(instance?.greet())
}

console.log("Hello World from JS!!!")
