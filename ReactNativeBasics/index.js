/*****************************************************************************************************/
/* React Native helper method initialization **/
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

/*****************************************************************************************************/

/**  simple.react.js START */
const ReactInnerContext = {
    elementId: 0,
    activeId: null,
    stateMap: {},
    hookIdMap: {},
    activeTreeNode: null,
    virtualDomTree: null
};

const Fragment = "fragment";

function resetReactContext() {
    ReactInnerContext.elementId = 0;
    ReactInnerContext.hookIdMap = {};
    ReactInnerContext.activeStateParent = null;
}

function requestReRender(elementId) {
    resetReactContext();
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
    const { $$id, $$parentId } = ReactInnerContext.activeStateParent;
    const { hookIdMap, stateMap } = ReactInnerContext;
    const activeStateId = $$parentId || "NULL";
    const [hookIdMapAlreadyCreated, activeHookIdMap] = createOrGetMap(hookIdMap, activeStateId);
    const [activeStateMapAlreadyCreated, activeStateMap] = createOrGetMap(stateMap, activeStateId);
    
    if (!hookIdMapAlreadyCreated) {
        activeHookIdMap["id"] = 0;
    }
    
    const activeHookId = activeHookIdMap["id"]++;
    
    if (!activeStateMapAlreadyCreated && !hookIdMapAlreadyCreated) {
        activeStateMap[activeHookId] = initialState;
    } else {
        if (typeof activeStateMap[activeHookId] === "undefined") {
            activeStateMap[activeHookId] = initialState;
        }
    }

    const stateUpdater = function(newState) {
        activeStateMap[activeHookId] = newState;
        requestReRender(activeStateId);
        setTimeout(function() {
            requestReRender($$parentId, $$id);
        }, 20);
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
        ReactInnerContext.activeStateParent = treeNode;
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
            if (child != null) {
                child.$$parentId = parentId;
            }
        });
    }
}

function renderVirtualDom(virtualDomTree, rootDOMElement, replacePreviousRoot) {
    ReactInnerContext.virtualDomTree = virtualDomTree;
    ReactInnerContext.rootDOMElement = rootDOMElement;
    ReactInnerContext.rootRenderer(virtualDomTree, rootDOMElement, replacePreviousRoot);
}

function createRoot(rootDOMElement) {
    return {
        render: function(virtualDomTree) {
            resetReactContext();
            renderVirtualDom(virtualDomTree, rootDOMElement);
        }
    };
}

function findAndInvokeEventHandlerOfElement(elementNodeInVirtualDomTree, elementId, eventKey, evt) {
    const elemNode = elementNodeInVirtualDomTree;
    
    if (elemNode === null) {
        return;
    }
    
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
/*****************************************************************************************************/
/** React Native Renderer START */
const ReactRenderContext = {};

function doRenderRoot(virtualDomTree, rootDOMElement) {
    const nativeBridge = RNExampleBridge.getInstance();
    nativeBridge.resetNativeRenderTree()

    syncVirtualDomToNative(virtualDomTree.children);
}

// simple tree traversal
function syncVirtualDomToNative(node) {
    if (node === null || typeof node === "undefined" || node.length === 0) {
        return;
    }

    if (Array.isArray(node)) {
        node.forEach((singleNode) => {
            if (singleNode !== null) {
                syncSingleNodeToNative(singleNode);
                syncVirtualDomToNative(singleNode.children);
            }
        });
    } else {
        syncSingleNodeToNative(node);
    }

    syncVirtualDomToNative(node.children);
}

function syncSingleNodeToNative(singleNode) {
    if (singleNode === null) {
        return;
    }
    
    const nativeBridge = RNExampleBridge.getInstance();
    
    let resolvedType = typeof singleNode.type === "function" ? "Function" : singleNode.type;
    nativeBridge.addNodeToNativeTree(singleNode.$$parentId, singleNode.$$id, resolvedType, singleNode.props, null);
}

function __handleButtonClickEvent(elementId) {
    __informNativeEvent(elementId, "click");
}

__registerRootRenderer(doRenderRoot);
/** React Native Renderer END */

/* Start of index.js **/

function App() {
  const [showDate, setShowDate] = useState(false);
  const [labelCount, setLabelCount] = useState(2);
  let labelItems = [];
    
  if (labelCount > 0) {
      labelItems = [];
      for (let i = 0; i < labelCount; i++) {
          let renderedElement;
          if (i % 5 === 0) {
              renderedElement = createElement("Button", {
                __innerHTML: `Button (${i})`,
                events: {
                  click: function() {
                      setShowDate(i % 7 === 0);
                      setLabelCount(i % 10 === 0 ? i + 2 : i - 1);
                  }
                }
              });
          } else {
              renderedElement = createElement("Label", {
              __innerHTML: `Label (${i})`
              });
          }
          labelItems.push(renderedElement);
      }
  }
    
  return createElement(
    "Button",
    {
      __innerHTML: showDate ? `Tayfun - ${new Date().getTime()}` : "Tayfun",
      events: {
        click: () => {
          console.log("App.Button.click.labelCount: " + labelCount);
          setShowDate(true);
          setLabelCount(labelCount + 1);
        }
      }
    },
    ...labelItems
  );
}

function __RenderJSApp() {
    console.log("__RenderJSApp")
    createRoot(null).render(createElement(App, null))
}
