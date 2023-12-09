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
        VStack (alignment: .leading) {
            
            List($renderTree, id: \.self) { (treeElement: Binding<RenderElement>) in
                if (treeElement.wrappedValue.type == "Button") {
                    Button(action: {
                        jsContext?.evaluateScript("__handleButtonClickEvent('" + treeElement.wrappedValue.id + "')")
                        syncViewState()
                    }, label: {
                        Text(treeElement.wrappedValue.props["__innerHTML"] as! String);
                    })
                } else if (treeElement.wrappedValue.type == "Label") {
                    Text(treeElement.wrappedValue.props["__innerHTML"] as! String);
                }
            }
        }
        .padding()
        .onAppear {
            jsContext?.evaluateScript("__RenderJSApp()")
            
            syncViewState()
        }
    }
    
    /**
     This state sync triggers render since the state will change so it is a double featured function
     */
    func syncViewState() {
        renderTree.removeAll()
        
        bridgeInstance?.nativeRenderTree.forEach({ treeNode in
            renderTree.append(treeNode)
        })
    }
}

struct RNViewSurface_Previews: PreviewProvider {
    static var previews: some View {
        RNViewSurface(jsContext: nil, bridgeInstance: nil)
    }
}
