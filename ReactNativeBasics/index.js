function isObject(val) {
    if (val === null) {
        return false;
    }
    return ((typeof val === 'function') || (typeof val === 'object'));
}

var console = {
    log: function(message) {
        if (isObject(message)) {
            _consoleLog(JSON.stringify(message, null, '\t'));
        } else {
            _consoleLog(message);
        }
    }
}

/**  simple.react.js START */
const ReactInnerContext = {
    elementId: 0,
    activeId: null,
    stateMap: {},
    hookIdMap: {},
    virtualDomTree: null
};

const Fragment = "fragment";

function requestReRender(elementId) {
    const existingDomTree = ReactInnerContext.virtualDomTree;
    // our framework expects function that creates the
    // virtual dom tree
    const newVirtualDomTree = createElement(existingDomTree.type);
    renderVirtualDom(newVirtualDomTree, ReactInnerContext.rootDOMElement, true);
}

function createOrGetMap(map, activeElementId) {
    const resultArray = [];

    if (typeof map[activeElementId] === "undefined") {
        map[activeElementId] = {};
        resultArray.push(false);
    } else {
        resultArray.push(true);
    }

    resultArray.push(map[activeElementId]);

    return resultArray;
}

function useState(initialState) {
    const activeElementId = ReactInnerContext.activeId;
    const [hookIdMapAlreadyCreated, activeHookIdMap] = createOrGetMap(ReactInnerContext.hookIdMap, activeElementId);
    const [activeStateMapAlreadyCreated, activeStateMap] = createOrGetMap(ReactInnerContext.stateMap, activeElementId);

    if (!hookIdMapAlreadyCreated) {
        activeHookIdMap[activeElementId] = 0;
    }
    const activeHookId = activeHookIdMap[activeElementId]++;

    if (!activeStateMapAlreadyCreated) {
        activeStateMap[activeHookId] = initialState;
    } else {
        if (typeof activeStateMap[activeHookId] === "undefined") {
            activeStateMap[activeHookId] = initialState;
        }
    }

    const stateUpdater = function(newState) {
        activeStateMap[activeHookId] = newState;
        setTimeout(function() {
            requestReRender(activeElementId);
        }, 50);
    };

    return [activeStateMap[activeHookId], stateUpdater];
}

function createElement(nodeTypeOrFunction, props, ...children) {
    let treeNode = {
        $$id: `element-${ReactInnerContext.elementId++}`,
        $$parentId: null,
        type: nodeTypeOrFunction,
        props: props || {},
        children: null,
        $$nativeElement: null // will be filled later
    };

    if (typeof nodeTypeOrFunction === "function") {
        // thanks to single thread abilitiy of JS we can create
        // id values for the hooks to use
        ReactInnerContext.activeId = treeNode.$$id;
        treeNode.children = [nodeTypeOrFunction(props, children)];
        applyParentToChildren(treeNode.children, treeNode.$$id);
    } else {
        if (children != null && children.length === 1 && typeof children[0] === "string") {
            treeNode.props.__innerHTML = children[0];
        } else {
            if (children != null && children.length > 0) {
                treeNode.children = children;
                applyParentToChildren(treeNode.children, treeNode.$$id);
            }
        }
    }

    return treeNode;
}

function applyParentToChildren(children, parentId) {
    if (children != null && children.length > 0) {
        children.forEach(child => {
            child.$$parentId = parentId;
        });
    }
}

function renderVirtualDom(virtualDomTree, rootDOMElement, replacePreviousRoot) {
    ReactInnerContext.activeId = -1;
    ReactInnerContext.elementId = 0;
    ReactInnerContext.hookIdMap = {};

    ReactInnerContext.virtualDomTree = virtualDomTree;
    ReactInnerContext.rootDOMElement = rootDOMElement;
    ReactInnerContext.rootRenderer(virtualDomTree, rootDOMElement, replacePreviousRoot);
}

function createRoot(rootDOMElement) {
    return {
        render: function(virtualDomTree) {
            console.log("virtualDomTree");
            console.log(JSON.stringify(virtualDomTree));
            renderVirtualDom(virtualDomTree, rootDOMElement);
        }
    };
}

function findAndInvokeEventHandlerOfElement(elementNodeInVirtualDomTree, elementId, eventKey, evt) {
    const elemNode = elementNodeInVirtualDomTree;
    
    console.log("findAndInvokeEventHandlerOfElement")
    console.log(elemNode.$$id)
    console.log(elementId)
    console.log("")

    if (elemNode.$$id === elementId) {
        elemNode.props?.events[eventKey]?.(evt);
    } else {
        if (elemNode.children) {
            if (Array.isArray(elemNode.children)) {
                elemNode.children.forEach((singleElement) => {
                    findAndInvokeEventHandlerOfElement(singleElement, elementId, eventKey, evt);
                });
            } else {
                findAndInvokeEventHandlerOfElement(elemNode.children, elementId, eventKey, evt);
            }
        }
    }
}

/**
 * BELOW 2 METHODS ARE USED FOR GLOBAL PURPOSES
 */
function __informNativeEvent(elementId, eventKey, evt) {
    const {
        virtualDomTree
    } = ReactInnerContext;
    findAndInvokeEventHandlerOfElement(virtualDomTree, elementId, eventKey, evt);
}

function __registerRootRenderer(rootRenderer) {
    ReactInnerContext.rootRenderer = rootRenderer;
}

/**  simple.react.js END */
/** React Native Renderer START */
const ReactRenderContext = {};

function doRenderRoot(virtualDomTree, rootDOMElement) {
    const nativeBridge = RNExampleBridge.getInstance();
    nativeBridge.resetNativeRenderTree()

    syncVirtualDomToNative(virtualDomTree);

    // nativeBridge.printNativeTreeMap();
    nativeBridge.doRender()
}

// simple tree traversal
function syncVirtualDomToNative(node) {
    if (node === null || typeof node === "undefined" || node.length === 0) {
        return;
    }

    if (Array.isArray(node)) {
        node.forEach((singleNode) => {
            syncSingleNodeToNative(singleNode);
            syncVirtualDomToNative(singleNode.children);
        });
    } else {
        syncSingleNodeToNative(node);
    }

    syncVirtualDomToNative(node.children);
}

function syncSingleNodeToNative(singleNode) {
    const nativeBridge = RNExampleBridge.getInstance();

    let resolvedType = typeof singleNode.type === "function" ? "Function" : singleNode.type;
    nativeBridge.addNodeToNativeTree(singleNode.$$parentId, singleNode.$$id, resolvedType, singleNode.props, null);
}

function __handleButtonClickEvent(elementId) {
    console.log("JS: HandleButtonClickEvent on JS");
    console.log("JS: elementId: " + elementId);

    __informNativeEvent(elementId, "click");

    // requestReRender(elementId);
}

__registerRootRenderer(doRenderRoot);
/** React Native Renderer END */

/*
function App() {
    return createElement(
        "Fragment", {},
        createElement(
            "Button", {
                __innerHTML: "Tayfun"
            }
        ),
        createElement(
            "Label", {
                __innerHTML: "Tayfun 2"
            }
        )
    )
}
*/

function RenderJSApp() {
    console.log("RenderJSApp")
    createRoot(null).render(createElement(
            "Button", {
                __innerHTML: "Tayfun",
                events: {
                    click: () => {
                        console.log("Button clicked");
                    }
                }
            }
        )
    )
}
