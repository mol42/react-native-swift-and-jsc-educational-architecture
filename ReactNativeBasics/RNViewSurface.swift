//
//  RNViewSurface.swift
//  ReactNativeBasics
//
//  Created by Typhoon Y on 11/25/23.
//

import Foundation
import SwiftUI
import JavaScriptCore

struct RNViewSurface: View {
    @State private var viewList: [String] = []
    var jsContext: JSContext?
    var bridgeInstance: RNExampleBridge?
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            
            Text("Test")
            
            List($viewList, id: \.self) { (viewType: Binding<String>) in
                Button(action: {
                    jsContext?.evaluateScript("HandleButtonClickEvent()")
                    
                    syncViewState()
                }, label: {
                    Text(viewType.wrappedValue)
                })
            }
        }
        .padding()
        .onAppear {
            jsContext?.evaluateScript("CreateReacNativeTree()")
            
            syncViewState()
        }
    }
    
    /**
     This state sync triggers render since the state will change so it is a double featured function
     */
    func syncViewState() {
        viewList.removeAll()
        
        bridgeInstance?.viewList.forEach({ viewType in
            viewList.append(viewType)
        })
    }
}

struct RNViewSurface_Previews: PreviewProvider {
    static var previews: some View {
        RNViewSurface(jsContext: nil, bridgeInstance: nil)
    }
}
