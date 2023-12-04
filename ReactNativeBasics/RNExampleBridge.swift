//
//  RNExampleBridge.swift
//  ReactNativeBasics
//
//  Created by Typhoon Y on 11/25/23.
//
import SwiftUI
import Foundation
import JavaScriptCore

var emptyFunction: () -> String = { return "" }

struct RenderElement: Hashable, Equatable {

    public func hash(into hasher: inout Hasher) {
        return hasher.combine(parentId + "_" + id + "_" + type)
    }
    
    public static func == (lhs: RenderElement, rhs: RenderElement) -> Bool {
        return lhs.id == rhs.id && lhs.parentId == rhs.parentId;
    }
    
    func copy(with zone: NSZone? = nil) -> RenderElement {
        let copy = RenderElement(parentId: parentId,id: id, type: type, props: props, children: children)
        return copy
    }
    
    var parentId: String;
    var id: String;
    var type: String;
    var props: Dictionary<AnyHashable, Any>;
    var children: [RenderElement];
}

@objc protocol RNJSExports: JSExport {
    func resetNativeRenderTree()
    func addNodeToNativeTree(_ parentId: JSValue,_ id: JSValue, _ elementType: JSValue, _ props: JSValue)
    static func getInstance() -> RNExampleBridge
}

class RNExampleBridge: NSObject, RNJSExports {
    static let shared = RNExampleBridge()
    var tempNativeRenderTreeMap: Dictionary<String, [RenderElement]> = [:];
    var nativeRenderTree: [RenderElement] = [];
    var jsContext: JSContext?
    var lastOperationTime: Int = 0;
    
    override init() {
        self.jsContext = nil
    }
    
    public func resetNativeRenderTree() {
        print("---------------");
        print("SWIFT: RNExampleBridge.resetNativeRenderTree");
        print("---------------");
        self.nativeRenderTree = [];
        self.tempNativeRenderTreeMap = [:];
    }
    
    public func addNodeToNativeTree(_ parentId: JSValue,_ id: JSValue, _ elementType: JSValue, _ props: JSValue) {
        print("---------------")
        print("SWIFT: RNExampleBridge.addToNativeRenderTree")
        let resolvedParentId = (parentId.isNull ? "NULL" : parentId.toString()) ?? "";
        let resolvedProps = (props.isNull ? [:] : props.toDictionary()) ?? [:];
        var nodeElement = RenderElement(parentId: resolvedParentId, id: id.toString(), type: elementType.toString(), props: resolvedProps, children: [])
        print("SWIFT: nodeElement.type: " + nodeElement.type)
        print("SWIFT: nodeElement.data: " + nodeElement.props.keys.description)
        print("---------------")
        
        // Due to SwiftUI state management whatever added will be re-rendered
        self.nativeRenderTree.append(nodeElement);
    }
    
    class func getInstance() -> RNExampleBridge {
      return shared
    }
}
