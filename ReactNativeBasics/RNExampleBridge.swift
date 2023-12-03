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
    var identifier: String {
        return UUID().uuidString
    }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(identifier)
    }
    
    public static func == (lhs: RenderElement, rhs: RenderElement) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    var id: String;
    var type: String;
    var props: Dictionary<AnyHashable, Any>;
}

@objc protocol RNJSExports: JSExport {
    func resetNativeRenderTree()
    func addToNativeRenderTree(_ elementType: JSValue,_ id: JSValue,_ data: JSValue)
    static func getInstance() -> RNExampleBridge
}

class RNExampleBridge: NSObject, RNJSExports {
    static let shared = RNExampleBridge()
    var nativeRenderTree: [RenderElement] = []
    var jsContext: JSContext?
    
    override init() {
        self.jsContext = nil
    }
    
    public func resetNativeRenderTree() {
        print("---------------")
        print("SWIFT: RNExampleBridge.resetNativeRenderTree")
        print("---------------")
        self.nativeRenderTree = []
    }
    
    public func addToNativeRenderTree(_ elementType: JSValue,_ id: JSValue,_ props: JSValue) {
        print("---------------")
        print("SWIFT: RNExampleBridge.addToNativeRenderTree")
        var element = RenderElement(id: id.toString(), type: elementType.toString(), props: props.toDictionary())
        print("SWIFT: element.type: " + element.type)
        print("SWIFT: element.data: " + element.props.keys.description)
        print("---------------")
        self.nativeRenderTree.append(element)
    }
    
    class func getInstance() -> RNExampleBridge {
      return shared
    }
}
