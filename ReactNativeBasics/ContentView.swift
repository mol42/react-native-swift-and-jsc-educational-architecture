//
//  ContentView.swift
//  ReactNativeBasics
//
//  Created by Typhoon Y on 11/25/23.
//

import SwiftUI
import JavaScriptCore

struct ContentView: View {
    // var result: String;
    
    init() {
        // let context = JSContext()!
        // let resultFromJS = context.evaluateScript("1 + 2 + 3")
        // self.result = resultFromJS!.toString()
        let context = JSContext()
        
        // 2. Register `_console.log` function that we can capture the log
        // Handy tool, so the user can use their existing JS code
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
        
        context?.evaluateScript("RenderButton()")
    }
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Test")
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
