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

@objc protocol RNJSExports: JSExport {
    func clearViewList()
    func updateViewList(_ newView: JSValue)
    static func getInstance() -> RNExampleBridge
}

class RNExampleBridge: NSObject, RNJSExports {
    static let shared = RNExampleBridge()
    var viewList: [String] = []
    var jsContext: JSContext?
    
    override init() {
        self.jsContext = nil
    }
    
    public func clearViewList() {
        print("SWIFT: RNExampleBridge.clearViewList")
        self.viewList = []
    }
    
    public func updateViewList(_ newView: JSValue) {
        print("---------------")
        print("SWIFT: RNExampleBridge.updateViewList")
        print(newView.toString())
        print("---------------")
        self.viewList.append(newView.toString())
    }
    
    class func getInstance() -> RNExampleBridge {
      return shared
    }
}
