//
//  ReactNativeBasicsApp.swift
//  ReactNativeBasics
//
//  Created by Typhoon Y on 11/25/23.
//

import SwiftUI
import JavaScriptCore

@main
struct ReactNativeBasicsApp: App {
    var jsContext: JSContext;
    var bridgeInstance: RNExampleBridge
    
    init() {
        let context = JSContext()

        context?.exceptionHandler = { context, exception in
            print("JS Error: \(exception!)") // Do not use force unwrap `!`
        }
        
        let consoleLog: @convention(block) (String) -> Void = {message in
          print(message)
        }
        
        context?.setObject(consoleLog, forKeyedSubscript: "_consoleLog" as NSString)

        guard let path = Bundle.main.path(forResource: "index", ofType: "js"),
          let script = try? String(contentsOfFile: path, encoding: .utf8) else {
            fatalError("cannot load script")
        }

        context?.evaluateScript(script)
        
        context?.setObject(RNExampleBridge.self, forKeyedSubscript: "RNExampleBridge" as (NSCopying & NSObjectProtocol))
        
        self.jsContext = context!
        self.bridgeInstance = RNExampleBridge.shared;
        self.bridgeInstance.jsContext = context;
    }
    
    var body: some Scene {
        WindowGroup {
            RNViewSurface(jsContext: jsContext, bridgeInstance: bridgeInstance)
        }
    }
}
