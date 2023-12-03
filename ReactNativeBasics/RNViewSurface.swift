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
            ForEach($renderTree, id: \.self) { (treeElement: Binding<RenderElement>) in
                
                var log1 = print("treeElement.wrappedValue.type");
                var log2 = print(treeElement.wrappedValue.type);
                
                if (treeElement.wrappedValue.type == "Button") {
                    Button(action: {
                        jsContext?.evaluateScript("HandleButtonClickEvent(" + treeElement.wrappedValue.id + ")")
                        
                        syncViewState()
                    }, label: {
                        let labelText: String = treeElement.wrappedValue.props["__innerHTML"] as! String;
                        Text(labelText)
                    })
                } else if (treeElement.wrappedValue.type == "Label") {
                    let labelText: String = treeElement.wrappedValue.props["__innerHTML"] as! String;
                    Text(labelText)
                }
            }
        }
        .padding()
        .onAppear {
            jsContext?.evaluateScript("RenderJSApp()")
            
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
