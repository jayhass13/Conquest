//
//  Tile.swift
//  Game
//
//  Created by Marvin Fishingpole on 12/21/19.
//  Copyright © 2019 None. All rights reserved.
//

import Foundation
import SpriteKit

public class Tile: SKShapeNode {
    
    private var tileTexture:SKTexture = SKTexture()
    private var center:CGPoint = CGPoint.zero
    private var rowIndex:Int = 0
    private var colIndex:Int = 0
    
    private var movementCost:Int = 0
    
    public var currentUnit:Unit? = nil
    
    public var highlightPath:[CGVector]? = nil 
    
    public var isHighlighted = false {
        
        didSet {
            
            if isHighlighted {
                self.alpha = 0.5
                
            } else {
                self.alpha = 1
            }
        }
    }
    

    override init() {
        super.init()
    }
    
    init(width: Int,
         height: Int,
         center: CGPoint,
         texture: SKTexture,
         rowIndex: Int,
         colIndex: Int,
         moveCost: Int) {
        
        //self.tileWidth = width
        //self.tileHeight = height
        self.center = center
        self.tileTexture = texture
        self.rowIndex = rowIndex
        self.colIndex = colIndex
        self.movementCost = moveCost
        
        super.init()
        
        drawTile()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func drawTile() {
        
        let tileWidth = 64
        let tileHeight = 64
        
        let upRightPoint = center.applying(CGAffineTransform(translationX: CGFloat(tileWidth / 2), y: CGFloat(tileHeight / 2)))
        let downRightPoint = center.applying(CGAffineTransform(translationX: CGFloat(tileWidth / 2), y: -CGFloat(tileHeight / 2)))
        let upLeftPoint = center.applying(CGAffineTransform(translationX: -CGFloat(tileWidth / 2), y: CGFloat(tileHeight / 2)))
        let downLeftPoint = center.applying(CGAffineTransform(translationX: -CGFloat(tileWidth / 2), y: -CGFloat(tileHeight / 2)))
        let points = [upLeftPoint, upRightPoint, downRightPoint, downLeftPoint, upLeftPoint]
        
        /*let upPoint = center.applying(CGAffineTransform(translationX: 0, y: CGFloat(tileHeight / 2)))
        let downPoint = center.applying(CGAffineTransform(translationX: 0, y: -CGFloat(tileHeight / 2)))
        let leftPoint = center.applying(CGAffineTransform(translationX: -CGFloat(tileWidth / 2), y: 0))
        let rightPoint = center.applying(CGAffineTransform(translationX: CGFloat(tileWidth / 2), y: 0))
        let points = [leftPoint, upPoint, rightPoint, downPoint, leftPoint]*/
        
        let tilePath = CGMutablePath()
        
        tilePath.move(to: upLeftPoint)
        tilePath.addLines(between: points)
        
        self.lineWidth = 2
        self.path = tilePath
        self.fillColor = .white
        self.fillTexture = tileTexture
         
    }
    
    public func getRow() -> Int {return self.rowIndex}
    
    public func getCol() -> Int {return self.colIndex}
    
    public func getCenter() -> CGPoint {return self.center}
    
    public func getMoveCost() -> Int {return self.movementCost}
    
    deinit {
        print("Tile deinit")
    }
    
}
