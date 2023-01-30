//
//  ScrollNode.swift
//  Test
//
//  Created by Marvin Fishingpole on 1/9/22.
//

import Foundation
import SpriteKit

//Actual scrolling functionality, not the best working so don't really use for now


public class ScrollNode<T: Listable>: SKSpriteNode {
    
    private let list:[T] = []
    private var selected:[T] = []
    private var oldY:CGFloat = 0
    private var nodes:[SKSpriteNode] = []
    
    public init(size: CGSize) {
        super.init(texture: nil, color: .black, size: .init(width: size.width, height: size.height))
        
        self.isUserInteractionEnabled = true
    }
    
    public func addNode(parent: SKNode, pos: CGPoint) {
        
        parent.addChild(self)
        self.position = pos
        
        for i in 0...10 {
            
            let r = CGFloat(Int.random(in: 0...255))
            let g = CGFloat(Int.random(in: 0...255))
            let b = CGFloat(Int.random(in: 0...255))
            
            let col = UIColor(red: r / 255, green: g / 255, blue: b / 255, alpha: 1)
            
            let newPos:CGPoint = .init(x: 0, y: -CGFloat((20 * i)) + (self.size.height / 2) - 10)
            let node = SKSpriteNode(texture: nil, color: col, size: .init(width: (self.size.width / 10) * 8, height: 20))
            node.position = newPos
            self.addChild(node)
            
            nodes.append(node)
        }
        
        let leftBorder = SKSpriteNode(texture: nil, color: .blue, size: .init(width: self.size.width / 10, height: self.size.height))
        leftBorder.position = .init(x: (-self.size.width / 2), y: 0)
        
        let rightBorder = SKSpriteNode(texture: nil, color: .blue, size: .init(width: self.size.width / 10, height: self.size.height))
        rightBorder.position = .init(x: self.size.width / 2, y: 0)
        
        let upBorder = SKSpriteNode(texture: nil, color: .blue, size: .init(width: self.size.width, height: self.size.height / 10))
        upBorder.position = .init(x: 0, y: self.size.height / 2)
        
        let downBorder = SKSpriteNode(texture: nil, color: .blue, size: .init(width: self.size.width, height: self.size.height / 10))
        downBorder.position = .init(x: 0, y: -self.size.height / 2)
        
        self.addChild(leftBorder)
        self.addChild(rightBorder)
        self.addChild(upBorder)
        self.addChild(downBorder)
        
        
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touchLocation = touches.first!.location(in: self)
        self.oldY = touchLocation.y
    }
    
    
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touchLocation = touches.first!.location(in: self)
        let translation = touchLocation.y - self.oldY
                
        for node in nodes {
            node.position.y += translation
        
            if node.frame.minY > (self.size.height / 2) || node.frame.maxY < (-self.size.height / 2) {
                
                node.isHidden = true
                
            } else {
                node.isHidden = false
                
                
            }
            
            
            
        }
        self.oldY = touchLocation.y
    }
    
    
    
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    
    
    
    
}


