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

const RenderTree = []

function CreateReacNativeTree() {
    console.log("CreateReacNativeTree on JS")

    RenderTree.push("Test Button");
    
    console.log(JSON.stringify(RenderTree))
    
    requestNativeRender();
}

function HandleButtonClickEvent() {
    console.log("HandleButtonClickEvent on JS")
    RenderTree[0] = "Test Button Clicked"
    
    requestNativeRender();
}

function requestNativeRender() {
    const bridge = RNExampleBridge.getInstance()
    
    bridge.clearViewList()
    
    for (let i = 0; i < RenderTree.length; i++) {
        console.log("updateViewList on JS", RenderTree[i])
        bridge.updateViewList(RenderTree[i]);
    }
}

console.log("Hello World from JS!!!")
