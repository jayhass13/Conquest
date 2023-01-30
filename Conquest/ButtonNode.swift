//
//  ButtonNode.swift
//  Game
//
//  Created by Marvin Fishingpole on 1/18/20.
//  Copyright © 2020 None. All rights reserved.
//

import Foundation
import SpriteKit

public class ButtonNode:SKSpriteNode {
    
    public var action: (() -> Void)?
    private var label:SKLabelNode = SKLabelNode()
    
    private var isSelected = false;
    
    override public var position: CGPoint {
        
        didSet {
            label.position = position
        }
    }
    
    public override init(texture: SKTexture?,
                         color: UIColor,
                         size: CGSize) {
        
        super.init(texture: texture, color: color, size: size)

        isUserInteractionEnabled = true
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public func setText(text: String, fontSize: CGFloat, fontColor: UIColor) {
        
        label.text = text
        label.fontSize = fontSize
        label.fontColor = fontColor
    }
    
    public func addButton(parent: SKNode, position: CGPoint) {
        
        self.position = position
        self.label.position = .zero
        parent.addChild(self)
        self.addChild(self.label)
    }
    
    public func removeButton() {
        
        label.removeFromParent()
        self.removeFromParent()
    }
    
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isSelected = true
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        print("Touched")
        
        guard let touch_location = touches.first else {return}
        
        let location = touch_location.location(in: parent!)
        
        if (isSelected && self.contains(location)) {
            action!()
        }
    }
    
    
    deinit {
        
        var t:String = "No Text"
        
        if self.label.text != nil {
            t = self.label.text!
        }
        
        print("Button Deinit " + t)
    }
    
    
    
    
    
    
    
    
}
