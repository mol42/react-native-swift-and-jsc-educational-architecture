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

struct RenderElement: Hashable {
    var id: String;
    var type: String;
    var data: String;
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
        print("SWIFT: RNExampleBridge.resetNativeRenderTree")
        self.nativeRenderTree = []
    }
    
    public func addToNativeRenderTree(_ elementType: JSValue,_ id: JSValue,_ data: JSValue) {
        print("---------------")
        print("SWIFT: RNExampleBridge.addToNativeRenderTree")
        print(elementType.toString())
        print(data.toString())
        print("---------------")
        var element = RenderElement(id: id.toString(), type: elementType.toString(), data: data.toString())
        print("SWIFT: element.data")
        print(element.data);
        self.nativeRenderTree.append(element)
    }
    
    class func getInstance() -> RNExampleBridge {
      return shared
    }
}
