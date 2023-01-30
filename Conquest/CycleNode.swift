//
//  CycleNode.swift
//  Test
//
//  Created by Marvin Fishingpole on 1/8/22.
//

import Foundation
import SpriteKit

//Left and right buttons for selecting one thing from a list


public class CycleNode<T: Listable>: SKSpriteNode {
    
    private var list:[T]
    private var current:T?
    private var index = 0
    
    public init(list: [T], size: CGSize) {
        
        self.list = list
        self.current = list.first
        
        super.init(texture: nil, color: .black, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func getSelected() -> T {
        return self.current!
    }
    
    public func addNode(pos: CGPoint, parent:SKNode) {
        
        let leftButton = ButtonNode(texture: nil, color: .red, size: .init(width: self.size.width / 4, height: self.size.height))
        
        leftButton.addButton(parent: self, position: .init(x: self.position.x - (self.size.width / 2), y: self.position.y))
        let rightButton = ButtonNode(texture: nil, color: .green, size: .init(width: self.size.width / 4, height: self.size.height))
        rightButton.addButton(parent: self, position: .init(x: self.position.x + (self.size.width / 2), y: self.position.y))
        
        let labelNode = SKLabelNode(text: self.current!.getListName())
        labelNode.fontSize = 10
        self.addChild(labelNode)
        labelNode.position = .zero
        
        leftButton.action = {
            
            [weak self] in ()
            
            if self == nil {
                print("Self Nil Error")
            }
            
            self?.index -= 1
            if self?.index == -1 {
                self!.index = self!.list.count - 1
            }
            
            self?.current = self?.list[self!.index]
            labelNode.text = self?.current?.getListName()
        }
        
        rightButton.action = {
            
            [weak self] in ()
            
            if self == nil {
                print("Self Nil Error")
            }
            
            self?.index += 1
            if self?.index == self!.list.count {
                self!.index = 0
            }
            
            self?.current = self?.list[self!.index]
            labelNode.text = self?.current?.getListName()
        }
        
        parent.addChild(self)
        self.position = pos
        
    }
    
    
    
    
    
    
}
