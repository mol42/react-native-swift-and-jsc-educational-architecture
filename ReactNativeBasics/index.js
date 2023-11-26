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

class SimpleReactNativeEngine {
    
    constructor() {
        this.renderTree = []
    }
    
    getRenderTree() {
        return this.renderTree;
    }
    
    initRenderTree() {
        this.renderTree = []
    }
    
    resetRenderTree() {
        this.renderTree = []
    }
    
    createElement(type, data, state, callback) {
        console.log("JS: SimpleReactNative.createElement");
        
        const element = {
            id: String(this.renderTree.length + 1), // for both sides
            state, // for the JS side
            type, // for the native side
            data, // for the native side
            callback // JS side
        };
        
        this.renderTree.push(element);
        
        return element;
    }
    
    removeElement(elementId) {
        const elementIndex = this.findElementIndexById(elementId);
        
        if (elementIndex > -1) {
            this.renderTree.splice(elementIndex, 1);
        }
    }
    
    invokeEventForTheElement(elementId) {
        console.log("JS: SimpleReactNative.invokeEventForTheElement " + elementId);
        const targetElement = this.findElementById(elementId);
        
        if (targetElement) {
            const callback = targetElement.callback;
            
            if (callback) {
                callback(targetElement);
            }
        }
    }
    
    findElementById(elementId) {
        let targetElement = null;
        
        for( let i = 0; i < this.renderTree.length; i++) {
            let element = this.renderTree[i];
            if (element.id == elementId) {
                targetElement = element;
                break;
            }
        }
        
        return targetElement;
    }
    
    findElementIndexById(elementId) {
        let targetElement = null;
        
        for( let i = 0; i < this.renderTree.length; i++) {
            let element = this.renderTree[i];
            if (element.id == elementId) {
                return i;
            }
        }
        
        return -1;
    }
}

const simpleReactNativeEngineInstance = new SimpleReactNativeEngine();

function RenderJSApp() {
    console.log("JS: CreateReacNativeTree on JS");
    
    simpleReactNativeEngineInstance.initRenderTree();
    
    simpleReactNativeEngineInstance.createElement("Button", "Test Button", {clickCount: 0}, (targetElement) => {
        targetElement.state.clickCount += 1;
        targetElement.data = `Test Button 1 Clicked (${targetElement.state.clickCount})`;
        
        if (targetElement.state.clickCount === 5) {
            simpleReactNativeEngineInstance.createElement("Text", "Test Text for 5th click", null, null);
        }
    });
    
    const textElement = simpleReactNativeEngineInstance.createElement("Text", "Test Text", null, null);
    
    simpleReactNativeEngineInstance.createElement("Button", "Test Button", {clickCount: 0}, (targetElement) => {
        targetElement.state.clickCount += 1;
        targetElement.data = `Test Button 2 Clicked (${targetElement.state.clickCount})`;
        
        if (targetElement.state.clickCount === 5) {
            simpleReactNativeEngineInstance.removeElement(textElement.id);
        }
    });
    
    console.log(JSON.stringify(simpleReactNativeEngineInstance.getRenderTree()));

    requestNativeRender();
}

function HandleButtonClickEvent(elementId) {
    console.log("JS: HandleButtonClickEvent on JS");
    console.log("JS: elementId: " + elementId);

    simpleReactNativeEngineInstance.invokeEventForTheElement(elementId);
    
    requestNativeRender();
}

function requestNativeRender() {
    const nativeBridge = RNExampleBridge.getInstance(); // Not JSON based bridge!
    const renderTree = simpleReactNativeEngineInstance.getRenderTree();
    
    // Start informing UI about the changes
    nativeBridge.resetNativeRenderTree()
    
    for (let i = 0; i < renderTree.length; i++) {
        const element = renderTree[i];
        nativeBridge.addToNativeRenderTree(element.type, element.id, element.data);
    }
}

console.log("JS: Hello World!!!")
