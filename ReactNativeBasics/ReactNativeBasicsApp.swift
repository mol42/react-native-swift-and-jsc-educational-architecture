//
//  ReactNativeBasicsApp.swift
//  ReactNativeBasics
//
//  Created by Typhoon Y on 11/25/23.
//

import SwiftUI
import JavaScriptCore
import Foundation
import JavaScriptCore

// NOTE: link for JSTimer doc
// https://stackoverflow.com/questions/21100190/using-setinterval-settimeout-in-javascriptcore-framework-for-objectivec
let timerJSSharedInstance = TimerJS()

@objc protocol TimerJSExport : JSExport {

    func setTimeout(_ callback : JSValue,_ ms : Double) -> String

    func clearTimeout(_ identifier: String)

    func setInterval(_ callback : JSValue,_ ms : Double) -> String

}

// Custom class must inherit from `NSObject`
@objc class TimerJS: NSObject, TimerJSExport {
    var timers = [String: Timer]()

    static func registerInto(jsContext: JSContext, forKeyedSubscript: String = "timerJS") {
        jsContext.setObject(timerJSSharedInstance,
                            forKeyedSubscript: forKeyedSubscript as (NSCopying & NSObjectProtocol))
        jsContext.evaluateScript(
            "function setTimeout(callback, ms) {" +
            "    return timerJS.setTimeout(callback, ms)" +
            "}" +
            "function clearTimeout(indentifier) {" +
            "    timerJS.clearTimeout(indentifier)" +
            "}" +
            "function setInterval(callback, ms) {" +
            "    return timerJS.setInterval(callback, ms)" +
            "}"
        )
    }

    func clearTimeout(_ identifier: String) {
        let timer = timers.removeValue(forKey: identifier)

        timer?.invalidate()
    }


    func setInterval(_ callback: JSValue,_ ms: Double) -> String {
        return createTimer(callback: callback, ms: ms, repeats: true)
    }

    func setTimeout(_ callback: JSValue, _ ms: Double) -> String {
        return createTimer(callback: callback, ms: ms , repeats: false)
    }

    func createTimer(callback: JSValue, ms: Double, repeats : Bool) -> String {
        let timeInterval  = ms/1000.0

        let uuid = NSUUID().uuidString

        // make sure that we are queueing it all in the same executable queue...
        // JS calls are getting lost if the queue is not specified... that's what we believe... ;)
        DispatchQueue.main.async(execute: {
            let timer = Timer.scheduledTimer(timeInterval: timeInterval,
                                             target: self,
                                             selector: #selector(self.callJsCallback),
                                             userInfo: callback,
                                             repeats: repeats)
            self.timers[uuid] = timer
        })


        return uuid
    }

    @objc func callJsCallback(_ timer: Timer) {
        let callback = (timer.userInfo as! JSValue)

        callback.call(withArguments: nil)
    }
}

@main
struct ReactNativeBasicsApp: App {
    var jsContext: JSContext;
    var bridgeInstance: RNExampleBridge
    
    init() {
        let context = JSContext()
        // Javascript Engines are very light libraries that can run JS code and expects
        // some functionalities to be provided by the host system
        // for example HTTP request, console.log's, setTimeout, setInterval etc are
        // all needs to be provided by the host system
        // JavascriptCore does not provide implementation for setTimeout, setInterval etc
        // this is expected since JS Engines are merely a library that runs JS codebase
        // and expects the Host environment to provide some functionality like setTimeout,
        // XHTTPRequest etc
        
        // -- Configura timer related host integrations
        TimerJS.registerInto(jsContext: context!)
        
        // -- Configura console.log host integration
        let consoleLog: @convention(block) (String) -> Void = {message in
          print(message)
        }
        
        context?.setObject(consoleLog, forKeyedSubscript: "_consoleLog" as NSString)

        // --- Configure exception handler
        context?.exceptionHandler = { context, exception in
            print("JS Error: \(exception!)") // Do not use force unwrap `!`
        }

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
