//
//  BattleScene.swift
//  Game
//
//  Created by Marvin Fishingpole on 12/21/19.
//  Copyright © 2019 None. All rights reserved.
//

import Foundation
import SpriteKit


public enum MenuActionBattle: CaseIterable {
    case end
}



public class BattleScene: SKScene {
    
    private let cameraNode = SKCameraNode()
    
    private let battleMap = TileMap(numRows: 5, numCols: 5)
    private let returnScene:OverworldScene
    private let battleProvince:Province
    
    private var attackingUnits:Dictionary<SKSpriteNode, Unit> = [:]
    private var defendingUnits:Dictionary<SKSpriteNode, Unit> = [:]
    
    
    private var unitActionsRemaining:Int = 0 {
        didSet {
            
            if (unitActionsRemaining == 0) {
                
                if self.camera!.childNode(withName: "LevelNode") == nil {
                    self.camera!.run(SKAction.wait(forDuration: 1))
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        self.enemyTurn()
                    })
                }
            }
        }
    }
    
    
    public var selectedUnit:Unit?
    
    //==================================================================
                        //MARK: Initializers for the scene
    //==================================================================
   
    public init(size: CGSize, attackingUnits: [Unit], defendingUnits: [Unit], returnScene: OverworldScene, province: Province) {
        
        self.returnScene = returnScene
        self.battleProvince = province
        
        super.init(size: size)
        
        self.addMapAndCamera()
        self.addUnits(attacking: attackingUnits, defending: defendingUnits)
    }
    
    public override func didMove(to view: SKView) {
        self.addPinchPanTap()
        self.addMenuButton()
        self.startTurn()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func addPinchPanTap() {
        
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinchToZoom(sender:)))
        self.view?.addGestureRecognizer(pinch)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panToDrag(sender:)))
        self.view?.addGestureRecognizer(pan)
    }
    
    private func addMapAndCamera() {
        
        self.camera = cameraNode
        self.camera?.zPosition = 5
        self.addChild(cameraNode)
        self.addChild(battleMap)
    }
    
    private func addUnits(attacking: [Unit], defending: [Unit]) {
        
        let playerRow = 0
        let enemyRow = battleMap.getNumRows() - 1
        
        var enemyCols:[Int] = []
        var playerCols:[Int] = []
        
        
        for unit in defending {
            
            var enemyCol = Int.random(in: 0...(battleMap.getNumCols() - 1))
            
            while (enemyCols.contains(enemyCol)) {
                enemyCol = Int.random(in: 0...(battleMap.getNumCols() - 1))
            }
            enemyCols.append(enemyCol)
            
            battleMap.addChild(unit.getBattleNode())
            unit.setPosition(newPos: battleMap.centerOfTile(row: enemyRow, col: enemyCol))
            defendingUnits[unit.getBattleNode()] = unit
            
        }
        
        
        for unit in attacking {
            
            var playerCol = Int.random(in: 0...(battleMap.getNumCols() - 1))
            
            while (playerCols.contains(playerCol)) {
                playerCol = Int.random(in: 0...(battleMap.getNumCols() - 1))
            }
            playerCols.append(playerCol)
            
            battleMap.addChild(unit.getBattleNode())
            unit.setPosition(newPos: battleMap.centerOfTile(row: playerRow, col: playerCol))
            attackingUnits[unit.getBattleNode()] = unit
            
        }
        unitActionsRemaining = defendingUnits.count
    }
    
    
    
    
    //==================================================================
                        //MARK: Gestures and Handling Taps
    //==================================================================
    
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if (self.hasActions() || camera!.hasActions()) {
            return
        }
        
        let touchLocation = touches.first!.location(in: self)
        let nodesAtLocation = self.getNodes(point: touchLocation)
        
        if self.camera!.childNode(withName: "MenuNode") != nil {
            self.removeMenuButtons()
            return
        } else if let n = self.camera!.childNode(withName: "LevelNode") {
            n.removeFromParent()
            
            if self.unitActionsRemaining == 0 {
                self.camera!.run(SKAction.wait(forDuration: 1))
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    self.enemyTurn()
                })
            }
            return
        }
        
        
        //There should only be a max of one of each at any given touch location
        var units: [Unit] = []
        var tiles: [Tile] = []
        
        for node in nodesAtLocation {
            
            if node is Tile {
                
                tiles.append(node as! Tile)
                
            } else if node is SKSpriteNode {
                
                let n = node as! SKSpriteNode
                
                if defendingUnits[n] != nil {
                    units.append(defendingUnits[n]!)
                } else if attackingUnits[n] != nil {
                    units.append(attackingUnits[n]!)
                }
            }
        }
        
        var performedAction = false
        
        if !tiles.isEmpty {
            
            for tile in tiles {
                
                if tile.isHighlighted {
                    assert(selectedUnit != nil)
                    tileAction(tile, selectedUnit!)
                    performedAction = true
                }
            }
        }
            
        if !performedAction {
            self.selectUnit(unit: units.first)
        }
    }

    
    @objc func panToDrag(sender: UIPanGestureRecognizer) {
        
        if sender.state == .changed {
            
            if (camera!.hasActions()) {
                return
            }
            
            camera!.position.x = camera!.position.x - (sender.translation(in: self.view).x * camera!.xScale)
            camera!.position.y = camera!.position.y + (sender.translation(in: self.view).y * camera!.xScale)
            
            sender.setTranslation(CGPoint.zero, in: self.view)
            
            
        }
    }
    
    
    
    private var lastScale:CGFloat = 1
    
    @objc func pinchToZoom(sender: UIPinchGestureRecognizer) {
        
        if camera!.hasActions() {
            return
        }
        
        func checkRange(scale: CGFloat) {
            
            if scale > 10000 {
                
                camera?.setScale(10000)
            } else if scale < 0.000001 {
                camera?.setScale(0.000001)
            }
        }
        
        switch sender.state {
            
            case .changed:
                camera?.setScale(lastScale / sender.scale)
                checkRange(scale: camera!.xScale)
            
            case .ended:
                lastScale = camera!.xScale
            
            default:
                return
        }
    }
    
    
    
    private func getNodes(point: CGPoint) -> [SKNode] {
        
        let potentialNodes = nodes(at: point)
        var actualNodes:[SKNode] = []
        
        for node in potentialNodes {
            
            if node.contains(point) {
                
                actualNodes.append(node)
            }
        }
        
        return actualNodes
    }
    
    
    
    //MARK: Actions
    
    private func selectUnit(unit: Unit?) {
        
        if (self.selectedUnit == nil) && (unit != nil) {
            
            self.selectedUnit = unit
            self.cameraNode.run(SKAction.move(to: unit!.getBattleNode().position, duration: 0.1))
            
            if (unit!.isPlayer() && !unit!.hasActedThisTurn()) {
                unit!.addActions()
            }
            let node = unit!.addUnitInfo()
            self.camera!.addChild(node)
            
        } else if (selectedUnit != nil) && (selectedUnit !== unit) {
            
            if (selectedUnit!.pendingAction != .none) {
                selectedUnit!.removeUnitActionInfo()
                selectedUnit!.addActions()
                battleMap.highlightedTiles = []
                selectedUnit!.pendingAction = .none
                return
            } else if let infoNode = self.camera!.childNode(withName: "StatInfo") {
                infoNode.removeFromParent()
                selectedUnit!.addActions()
                return
            }
            
            selectedUnit!.deselect()
            self.selectedUnit = nil
        }
    }
    
    
    private func tileAction(_ tile: Tile, _ unit: Unit) {
        
        switch unit.pendingAction {
        case .attack:
            
            unit.showAttackInfo(tile.currentUnit, tile)
            
        case .move:
            
            camera!.position = unit.getCurrentTile()!.getCenter()
            let movements = SKAction.sequence(unit.moveUnit(tile.highlightPath!, tile))
            camera!.run(movements)
            unit.getBattleNode().run(movements, completion: unit.postMove)
            unit.pendingAction = .none
            
        default:
            break;
        }
        
        battleMap.highlightedTiles = []
        
    }
    
    public func unitHasMoved() {
        unitActionsRemaining -= 1
        self.selectedUnit = nil
    }
    
    public func addMenuButton() {
        
        let menuButton = ButtonNode(texture: nil, color: .gray, size: .init(width: 50, height: 50))
        var pos:CGPoint = .init(x: ((-self.view!.frame.width / 2) + 25),
                                y: ((self.view!.frame.height / 2)) - 25)
        
        pos = convert(pos, to: self.camera!)
        
        menuButton.addButton(parent: self.camera!, position: pos)
        menuButton.setText(text: "Menu", fontSize: 16, fontColor: .white)
        
        menuButton.action = {
            [weak self] in ()
            self?.addMenuActions()
        }
    }
    
    private func addMenuActions() {
        
        let buttonXPosition:CGFloat = 0
        let buttonYPosition:CGFloat = 0
        var buttonYOffset:CGFloat = 35
        
        let defaultButtonHeight:CGFloat = 25
        
        let baseNode = SKSpriteNode(texture: nil, color: .clear, size: .zero)
        baseNode.name = "MenuNode"
        self.camera!.addChild(baseNode)
        
        
        for action in MenuActionBattle.allCases {
            
            let translation = CGAffineTransform(translationX: 0,
                                                y: buttonYOffset)
            
            let buttonPos = CGPoint(x: buttonXPosition, y: buttonYPosition).applying(translation)
            addMenuButton(action: action, position: buttonPos, base: baseNode)
            
            buttonYOffset -= defaultButtonHeight
        }
    }
    
    private func addMenuButton(action: MenuActionBattle, position: CGPoint, base: SKSpriteNode) {
        
        let defaultWidth = 100
        let defaultHeight = 25
        
        let button = ButtonNode(texture: nil, color: .black, size: .init(width: defaultWidth, height: defaultHeight))
        button.addButton(parent: base, position: position)
        
        
        switch action {
            case .end:
            
                button.action = {
                    [weak self] in ()
                    self?.removeMenuButtons()
                    self?.enemyTurn()
            }
        }
    }
    
    private func removeMenuButtons() {
        
        if let node = self.camera!.childNode(withName: "MenuNode") {
            node.removeFromParent()
            node.removeAllChildren()
        }
    }
    
    
    
    
    private func startTurn() {
        
        if checkIfEnd() {
            return
        }
        
        var liveUnits = 0
        
        for unit in defendingUnits.values {
            
            if unit.getStat(stat: .hp) != 0 {
                unit.newTurn()
                
                liveUnits += 1
            }
        }
        
        //Have this uncommented because you need enemy units to have not moved this turn, else when you select them on player turn they will go back to their old previous tile
        for unit in attackingUnits.values {
            unit.newTurn()
        }
        
        unitActionsRemaining = liveUnits
        
        print("player turn")
    }
    
    
    public func checkIfEnd() -> Bool {
        
        var allDead = true
        
        for attackingUnit in attackingUnits.values {
            if attackingUnit.getStat(stat: .hp) != 0 {
                allDead = false
                break
            }
        }
        
        if allDead {
            endBattle(won: false) //All challenger units are dead
            return true
        }
        
        allDead = true
        
        for defendingUnit in defendingUnits.values {
            if defendingUnit.getStat(stat: .hp) != 0 {
                allDead = false
                break
            }
        }
        
        if allDead {
            endBattle(won: true)
            return true
        }
        
        return false
    }
    
    public func endBattle(won: Bool) {
        
        for unit in defendingUnits.values {
            unit.healUnit(amount: unit.getBase(stat: .hp))
            unit.newTurn()
        }
        
        for unit in attackingUnits.values {
            unit.healUnit(amount: unit.getBase(stat: .hp))
            unit.newTurn()
        }
        
        view?.presentScene(returnScene)
        
        
        let challenger = attackingUnits.values.first!.getLeader()!
        let defender = defendingUnits.values.first!.getLeader()
        
        if defender != nil {
            returnScene.provinceBattleEnd(challenger: challenger, defender: defender!, province: battleProvince, won: won)
            
        } 
        
    }
    

    
    
    private var enemyUnitCounter = 0
    
    private func enemyTurn() {
        print("Enemy turn")
        
        if checkIfEnd() {
            return
        }
        
        var units:[Unit] = []
        
        if !attackingUnits.first!.value.isPlayer() {
            units = Array(attackingUnits.values)
        } else {
            units = Array(defendingUnits.values)
        }
        
        
        while enemyUnitCounter < units.count {
            let unit = units[enemyUnitCounter]
            
            if (unit.getStat(stat: .hp) > 0) {
                let tiles = battleMap.getAIOptions(unit: unit, attackRange: 1)
                
                if !tiles.isEmpty {
                    unitAct(unitActing: unit, unitToAttack: tiles[0].1, tileAttackedFrom: tiles[0].0)
                    return
                }
            }
            
            enemyUnitCounter += 1
        }
        
        enemyUnitCounter = 0
        self.startTurn()
    }
    
    private func unitAct(unitActing: Unit, unitToAttack: Unit, tileAttackedFrom: Tile) {
        
        var movement:SKAction
        
        if (tileAttackedFrom.highlightPath!.count == 0) {
            movement = SKAction()
        } else {
            movement = SKAction.sequence(unitActing.moveUnit(tileAttackedFrom.highlightPath!, tileAttackedFrom))
        }
        
        let attack = SKAction.run {
            unitActing.performAttack(unitToAttack)
        }
        
        let postMove = SKAction.run {
            unitActing.postMove()
        }
        
        let wait = SKAction.wait(forDuration: 1)
        let unitActions = [wait, movement, postMove, attack, wait]
        let cameraActions = [wait, movement, wait]
        
        camera!.position = unitActing.getCurrentTile()!.getCenter()
        camera!.run(SKAction.sequence(cameraActions))
        
        enemyUnitCounter += 1
        
        unitActing.getBattleNode().run(SKAction.sequence(unitActions), completion: enemyTurn)
    }
    
    
    
    
    
    
    
    
    
    deinit {
        print("BattleScene Deinit")
    }
    
    
}







