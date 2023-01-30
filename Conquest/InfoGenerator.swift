//
//  InfoGenerator.swift
//  Test
//
//  Created by Marvin Fishingpole on 9/8/22.
//

import Foundation
import SpriteKit

public enum InfoGenerator {
    
    
    //Unit list for display when attacking/defending province for player
    static func generateUnitList(units: [Unit]) -> SKSpriteNode {
        
        let nodeWidth = 80
        let nodeHeight = 240
        let heightPerUnit = nodeHeight / 8
        let fontSize:CGFloat = 8
        
        let baseNode = SKSpriteNode(texture: nil, color: .black, size: .init(width: nodeWidth, height: nodeHeight))
        
        var i = 0
        for unit in units {
            
            let unitBaseNode = SKSpriteNode(texture: nil, color: .black, size: .init(width: nodeWidth, height: heightPerUnit))
            
            let r = CGFloat(Int.random(in: 0...255))
            let g = CGFloat(Int.random(in: 0...255))
            let b = CGFloat(Int.random(in: 0...255))
                
                
            let col = UIColor(red: r / 255, green: g / 255, blue: b / 255, alpha: 1)
            unitBaseNode.color = col
            
            
            
            let unitNameL = SKLabelNode(text: unit.getListName())
            let currentClassL = SKLabelNode(text: unit.getClass().getListName())
            let currentLevelL = SKLabelNode(text: "Lv: " + String(unit.getLevel()))
            unitNameL.fontSize = fontSize
            currentLevelL.fontSize = fontSize
            currentClassL.fontSize = fontSize
            
            unitBaseNode.addChild(unitNameL)
            unitBaseNode.addChild(currentClassL)
            unitBaseNode.addChild(currentLevelL)
            
            unitNameL.position = .init(x: 0, y: 8)
            currentLevelL.position = .init(x: 0, y: 0)
            currentClassL.position = .init(x: 0, y: -8)
            
            baseNode.addChild(unitBaseNode)
            
            let top = Int(baseNode.size.height / 2)
            
            unitBaseNode.position = .init(x: 0, y: top + (i * -heightPerUnit))
            
            i += 1
        }
        return baseNode
    }
    
    
    
    
    
    
    
}






