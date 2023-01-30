//
//  Util.swift
//  Test
//
//  Created by Marvin Fishingpole on 12/23/22.
//

import Foundation
import SpriteKit


public class Util {
    
    public class ButtonHolder:SKSpriteNode {
        
        private var numButtons = 0
        private var maxButtons = -1
        
        public init(texture: SKTexture?, color: UIColor, size: CGSize, name: String, maxButtons: Int) {
            
            super.init(texture: texture, color: color, size: size)
            self.name = name
            self.maxButtons = maxButtons
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public func addButton() -> ButtonNode {
            
            let bh = self.size.height / CGFloat(maxButtons)
            
            let buttonNode = ButtonNode(texture: nil,
                                        color: .black,
                                        size: .init(width: self.size.width, height: bh))
            
            let h = self.frame.maxY - (bh * CGFloat(numButtons))
            buttonNode.addButton(parent: self, position: .init(x: 0, y: h))
            numButtons += 1
            
            return buttonNode
        }
        
    }
    
    

    
}


