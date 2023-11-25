//
//  RNExampleBridge.swift
//  ReactNativeBasics
//
//  Created by Typhoon Y on 11/25/23.
//

import Foundation
import JavaScriptCore

@objc protocol RNJSExports: JSExport {
   func greet() -> String
   func greetMe(_ name: String) -> String
   static func getInstance() -> RNExampleBridge
   //any other properties you may want to export to JS runtime
   //var greetings: String {get set}
}

class RNExampleBridge: NSObject, RNJSExports {
    public func greet() -> String {
      return "Hello World from Swift!"
    }

    public func greetMe(_ name: String) -> String {
      return "Hello, " + name + "!"
    }
    class func getInstance() -> RNExampleBridge {
      return RNExampleBridge()
    }
}
