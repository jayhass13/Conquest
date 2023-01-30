//
//  ContentView.swift
//  Conquest
//
//  Created by Marvin Fishingpole on 1/11/23.
//

import SwiftUI
import SpriteKit

struct StartView: View {
    
    var scene: StartScene {
        let s = StartScene()
        s.size = CGSize(width: 100, height: 100)
        s.scaleMode = .resizeFill
        return s
    }
    
    var backgroundScene:SKScene {
        let s = SKScene()
        s.scaleMode = .resizeFill
        s.backgroundColor = .blue
        return s
    }
    
    
    var body: some View {
        
        ZStack {
            
            SpriteView(scene: backgroundScene)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .ignoresSafeArea()
            
            SpriteView(scene: self.scene)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            
        }
        
    }
    
}

