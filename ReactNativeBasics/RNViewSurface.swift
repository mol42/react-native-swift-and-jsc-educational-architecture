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
    @State private var renderTree: [RenderElement] = []
    var jsContext: JSContext?
    var bridgeInstance: RNExampleBridge?
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            
            Text("Test")
            
            List($renderTree, id: \.self) { (treeElement: Binding<RenderElement>) in
                if (treeElement.wrappedValue.type == "Button") {
                    Button(action: {
                        jsContext?.evaluateScript("HandleButtonClickEvent(" + treeElement.wrappedValue.id + ")")
                        
                        syncViewState()
                    }, label: {
                        Text(treeElement.wrappedValue.data)
                    })
                } else {
                    Text(treeElement.wrappedValue.data)
                }
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
        renderTree.removeAll()
        
        bridgeInstance?.nativeRenderTree.forEach({ treeElement in
            renderTree.append(treeElement)
        })
    }
}

struct RNViewSurface_Previews: PreviewProvider {
    static var previews: some View {
        RNViewSurface(jsContext: nil, bridgeInstance: nil)
    }
}
