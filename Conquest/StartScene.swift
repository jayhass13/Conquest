//
//  StartScreen.swift
//  Test
//
//  Created by Marvin Fishingpole on 10/5/21.
//

import Foundation
import SpriteKit


public class StartScene:SKScene {
    
    var startButton:ButtonNode = ButtonNode()
    
    public override func didMove(to view: SKView) {
        addButtons()
        
    }
    
    
    private func addButtons() {
        
        startButton = ButtonNode(texture: nil, color: .blue, size: .init(width: 100, height: 20))
        startButton.setText(text: "Start", fontSize: 10, fontColor: .white)
        
        startButton.action = {
            [weak self] () in
            
            self?.view?.presentScene(OverworldScene(size: (self?.view?.frame.size)!))
             
        }
        startButton.addButton(parent: self, position: .init(x: self.frame.midX, y: self.frame.midY))
    }
    

    deinit {
        print("StartScreen Deinit")
    }
    

    
}




