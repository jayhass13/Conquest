//
//  PageNode.swift
//  Test
//
//  Created by Marvin Fishingpole on 10/11/21.
//

import Foundation
import SpriteKit


public protocol Listable {
    func getListName() -> String
}


public class PageNode<T: Equatable & Listable>: SKSpriteNode {
    
    private var list: [T]
    private var pageNumber = 0
    private var buttonNodes: [ButtonNode] = []
    private var labelNodes: [SKLabelNode] = []
    private var added: [T] = []
    
    
    public init(list: [T], size: CGSize) {
        
        self.list = list
        
        super.init(texture: nil, color: .black, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public func getAdded() -> [T] {
        return self.added
    }
    
    
    public func addNode(pos: CGPoint, parent: SKNode, numPerPage: Int, maxChosen: Int) {
    
        let numPages:Int = Int(ceil(Double(list.count) / 5.0))
        
        
        if (numPages > 1) {
            
            let nextButton = ButtonNode(texture: nil, color: .green, size: .init(width: self.size.width / 2, height: self.size.height / 10))
            let prevButton = ButtonNode(texture: nil, color: .red, size: .init(width: self.size.width / 2, height: self.size.height / 10))
            
            nextButton.position = .init(x: (self.size.width / 4),
                                        y: (self.size.height / -2) - (nextButton.size.height / 2))
            
            prevButton.position = .init(x: (self.size.width / -4),
                                        y: (self.size.height / -2) - (prevButton.size.height / 2))
            
            
            self.addChild(nextButton)
            self.addChild(prevButton)
            
            nextButton.action = {
                [weak self] in ()
                
                if self!.pageNumber < numPages - 1{
                    self!.pageNumber = self!.pageNumber + 1
                    
                    var i = 0
                    
                    for button in self!.buttonNodes {
                        
                        let newItemN = i + (self!.pageNumber * self!.buttonNodes.count)
                        
                        if (newItemN < self!.list.count) {
                            let newItem = self!.list[newItemN]
                            
                            button.setText(text: newItem.getListName(), fontSize: 10, fontColor: .white)
                            
                            if self!.added.contains(newItem) {
                                button.color = .darkGray
                            } else {
                                button.color = .black
                            }
                        } else {
                            button.setText(text: "", fontSize: 10, fontColor: .white)
                            button.color = .black
                        }
                        
                        i += 1
                    }
                }
            }
            
            prevButton.action = {
                [weak self] in ()
                
                if self!.pageNumber > 0 {
                    self!.pageNumber = self!.pageNumber - 1
                    
                    var i = 0
                    
                    for button in self!.buttonNodes {
                        
                        let newItemN = i + (self!.pageNumber * self!.buttonNodes.count)
                        
                        if (newItemN < self!.list.count) {
                            let newItem = self!.list[newItemN]
                            
                            button.setText(text: newItem.getListName(), fontSize: 10, fontColor: .white)
                            
                            if self!.added.contains(newItem) {
                                button.color = .darkGray
                            } else {
                                button.color = .black
                            }
                            
                        } else {
                            button.setText(text: "", fontSize: 10, fontColor: .white)
                        }
                        i += 1
                    }
                }
            }
        }
        
        
        let w = self.size.width
        //Offset startX so that the top and bottom line up
        let startX = (-self.size.width / 2 + (w / (CGFloat(maxChosen) * 2)))
        
        //Line up each of the choose nodes and calculate their positions, then add them
        for i in 0...maxChosen - 1 {
            
            let x:CGFloat = CGFloat(i) * (w / CGFloat(maxChosen)) + CGFloat(startX)
            let y:CGFloat = ((-3 * self.size.height) / 4)
            let pos = CGPoint(x: x, y: y)
            
            let labelBase = SKSpriteNode(texture: nil, color: .black, size: .init(width: Int(w) / maxChosen, height: Int(self.size.height) / 5))
            labelBase.position = pos
            let label = SKLabelNode()
            label.fontSize = 10
            label.fontColor = .white
            self.addChild(labelBase)
            labelBase.addChild(label)
            
            labelNodes.append(label)
        }
        
        //Set up the actual buttons on the page
        
        let buttonHeight:CGFloat = self.size.height / CGFloat(numPerPage)
        let topY:CGFloat = self.position.y + (self.size.height / 2) - (buttonHeight / 2)
        
        for i in 0...numPerPage - 1 {
            
            if (list.count < i + 1) {
                break
            }
            
            let unitButton = ButtonNode(texture: nil, color: .black, size: .init(width: self.size.width, height: buttonHeight))
            unitButton.setText(text: list[i].getListName(), fontSize: 10, fontColor: .white)
            unitButton.addButton(parent: self, position: .init(x: 0, y: topY - (buttonHeight * CGFloat(i))))
            buttonNodes.append(unitButton)
            
            unitButton.action = {
                [weak self, weak node = unitButton] in ()
                
                let unitN = self?.buttonNodes.firstIndex(of: node!)
                let unitIndex = unitN! + (self!.buttonNodes.count * self!.pageNumber)
                
                if unitIndex >= self!.list.count {
                    return
                }
                
                let selectedUnit = self!.list[unitIndex]
                
                if self!.added.contains(selectedUnit) {
                    
                    let i = self!.added.firstIndex(of: selectedUnit)!
                    self!.added.remove(at: i)
                    
                    for j in i...(self!.labelNodes.count - 1) {
                        
                        if (j == self!.labelNodes.count - 1) {
                            self?.labelNodes[j].text = ""
                        } else {
                            self?.labelNodes[j].text = self?.labelNodes[j + 1].text
                        }
                    }
                    
                    node?.color = .black
                    
                    
                } else {
                    if self?.added.count != self?.labelNodes.count {
                        
                        if !self!.added.contains(selectedUnit) {
                            self?.labelNodes[self!.added.count].text = selectedUnit.getListName()
                            
                            print(selectedUnit.getListName())
                            self?.added.append(selectedUnit)
                            
                            node?.color = .darkGray
                        }
                    }
                }
            }
        }
        
        
        
        
        self.position = pos
        parent.addChild(self)
    }
     
    
    
    
    deinit {
        print("Page Node deinit")
    }
    
    
    
    
}










