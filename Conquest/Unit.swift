//
//  Unit.swift
//  Game
//
//  Created by Marvin Fishingpole on 12/20/19.
//  Copyright © 2019 None. All rights reserved.
//

import Foundation
import SpriteKit


//Notes about units:
//Always add the unit to its parent first, then set its position, so the current tile can be initialized first

/*

 Protocol for adding units to a leader:
 Call Leader.addUnit() with parameters of Unit and Province, this one call will take care of all the others like setting all relationships and such

*/



public enum BaseUnitAction : CaseIterable {
    case move, attack, info, wait, none
}

public enum UnitStats : Int {
    
    case hp = 0
    case strength = 1
    case speed = 2
    case evasion = 3
    case precision = 4
    case defense = 5
    case movement = 6
    case fortune = 7
}



public class Unit: Listable, Equatable {

    
    private var stats:[Int] = Array(repeating: 0, count: 8)
    private var statModifiers:[Int] = Array(repeating: 0, count: 8)
    private var xp: Int = 0 {
        didSet {
            print("new xp is " + String(xp))
            if xp >= 100 {
                xp = xp % 100
                self.levelUp()
            }
        }
    }
    private var level: Int = 1
    
    private weak var currentLeader:Leader?
    private weak var currentProvince:Province?
    
    private var currentWeapon:UnitWeapon? = .init(power: Weapon.getBasePower(.shortsword)(), stats: Weapon.getBaseStats(.shortsword)(), range: Weapon.getRange(.shortsword)())
    private var currentClass:UnitClass = .trainee
    
    private var player:Bool = false
    private var name:String = ""
    
    private var movedThisTurn:Bool = false
    private var actedThisTurn:Bool = false
    
    private var actedThisMonth:Bool = false
    
    private weak var currentTile:Tile? = nil
    public weak var origTile:Tile? = nil
    
    public var pendingAction:BaseUnitAction = .none
    
    private let battleNode: SKSpriteNode = SKSpriteNode(texture: nil, color: .gray, size: .init(width: 40, height: 40))

    //MARK: Initializers
    
    init(hp: Int, strength: Int, range: Int, isPlayer: Bool, name: String) {
        
        self.stats[UnitStats.hp.rawValue] = hp
        self.stats[UnitStats.strength.rawValue] = strength
        self.stats[UnitStats.movement.rawValue] = range
        self.player = isPlayer
        self.name = name
        
    }
    
    //MARK: Getters + Setters

    public func loseHP(damage: Int) {
        
        if getStat(stat: .hp) - damage <= 0 {
            
            self.setModifier(stat: .hp, modifier: getBase(stat: .hp) * -1)
            self.unitDied()
        } else {
            self.addToModifier(stat: .hp, modifier: damage * -1)
        }
    }
    
    public func healUnit(amount: Int) {
        
        if getStat(stat: .hp) + amount >= getBase(stat: .hp) {
            setModifier(stat: .hp, modifier: 0)
        } else {
            addToModifier(stat: .hp, modifier: amount)
        }
    }
    
    public func isPlayer() -> Bool {
        return self.player
    }
    
    public func getCurrentTile() -> Tile? {
        
        return self.currentTile
    }
    
    public func getClass() -> UnitClass {
        return self.currentClass
    }
    
    public func getStat(stat: UnitStats) -> Int {
        return stats[stat.rawValue] + statModifiers[stat.rawValue]
    }
    
    public func getBase(stat: UnitStats) -> Int {
        return stats[stat.rawValue]
    }
    
    public func addToModifier(stat: UnitStats, modifier: Int) {
        statModifiers[stat.rawValue] += modifier
    }
    
    public func setModifier(stat: UnitStats, modifier: Int) {
        statModifiers[stat.rawValue] = modifier
    }
    
    public func setBaseStat(stat: UnitStats, base: Int) {
        stats[stat.rawValue] = base
    }
    
    public func addToBase(stat:UnitStats, modifier: Int) {
        stats[stat.rawValue] += modifier
    }
    
    public func getLevel() -> Int {
        return self.level
    }
    
    public func getLeader() -> Leader? {
        return self.currentLeader
    }
    
    public func getProvince() -> Province? {
        return self.currentProvince
    }
    
    public func setProvince(newProvince: Province) {
        self.currentProvince = newProvince
    }
    
    public func setLeader(leader: Leader) {
        self.currentLeader = leader
        self.battleNode.color = leader.color
    }
    
    public func changeClass(newClass: UnitClass) {
        self.currentClass = newClass
    }
    

    public func getBattleNode() -> SKSpriteNode {
        return self.battleNode
    }
    
    //MARK: Unit Status Functions
    
    private func unitDied() {
        
        self.currentTile?.currentUnit = nil
        self.battleNode.isHidden = true
        
    }
    
    public func unitLetGo() {
        
        self.currentProvince?.removeUnit(unit: self)
        self.currentLeader?.removeUnit(unit: self)
        
        self.currentProvince = nil
        
    }
    
    
    //MARK: Unit Battle Functions
    
    public func setPosition(newPos: CGPoint) {
        self.preMove()
        self.battleNode.position = newPos
        self.postMove()
    }
    
    public func unitHasActed() {
        
        self.actedThisTurn = true
        self.origTile = self.currentTile
        
        if (self.isPlayer()) {
            self.deselect()
        }
    }
    
    public func unitHasActedOverworld() {
        self.actedThisMonth = true
    }
    
    public func newDay() {
        self.actedThisMonth = false
    }
    
    public func hasActedThisTurn() -> Bool {
        return self.actedThisTurn
    }
    
    public func hasMovedThisTurn() -> Bool {
        return self.movedThisTurn
    }
    
    public func hasActedThisMonth() -> Bool {
        return self.actedThisMonth
    }
    
    
    //======================================================================================
    //MARK: Actions
    //======================================================================================
    
    public func deselect() {
        
        if (self.movedThisTurn) {
            self.movedThisTurn = false
            self.setPosition(newPos: self.origTile!.getCenter())
        }
        
        self.removeActions()
        self.removeUnitInfo()
    }
    
    public func newTurn() {
        self.actedThisTurn = false
        self.movedThisTurn = false
    }
    
    
    
    
    
    public func addActions() {
        
        let buttonXPosition:CGFloat = 125
        let buttonYPosition:CGFloat = 25
        var buttonYOffset:CGFloat = 35
        
        let defaultButtonHeight:CGFloat = 25
        
        let baseNode = SKSpriteNode(texture: nil, color: .clear, size: .zero)
        baseNode.name = "ActionNode"
        
        self.battleNode.scene!.camera!.addChild(baseNode)
        
        for action in BaseUnitAction.allCases {
            
            if action == .none {
                continue
            } else if (self.movedThisTurn && action == .move) {
                continue
            }
            
            let translation = CGAffineTransform(translationX: 0,
                                                y: buttonYOffset)
            
            let buttonPos = CGPoint(x: buttonXPosition, y: buttonYPosition).applying(translation)
            addBaseButton(action: action, position: buttonPos, baseNode: baseNode)
            
            buttonYOffset -= defaultButtonHeight
        }
    }
    
    
    
    public func removeActions() {
        
        assert(self.battleNode.scene != nil)
        let s = self.battleNode.scene!
        
        if let node = s.camera!.childNode(withName: "ActionNode") {
            
            node.removeAllChildren()
            node.removeFromParent()
        }
    }
    
    
    
    private func addBaseButton(action: BaseUnitAction, position: CGPoint, baseNode: SKSpriteNode) {
        
        let defaultButtonWidth:CGFloat = 60
        let defaultButtonHeight:CGFloat = 25
        let defaultFontSize:CGFloat = 25
        
        let baseButton = ButtonNode(color: .black, size: CGSize(width: defaultButtonWidth * 2,
                                                                height: defaultButtonHeight * 2))
        
        switch action {
        case .attack:
            baseButton.setText(text: "Attack", fontSize: defaultFontSize, fontColor: .white)
            baseButton.action = {
                [weak self] () in
                
                self?.removeActions()
                self?.removeUnitInfo()
                self?.highlightAttackableTiles()
                
            }
            break
            
        case .move:
            baseButton.setText(text: "Move", fontSize: defaultFontSize, fontColor: .white)
            
            baseButton.action = {
                [weak self] () in
                
                self?.removeActions()
                self?.removeUnitInfo()
                self?.highlightMoveableTiles()
            }
            break
            
        case .wait:
            baseButton.setText(text: "Wait", fontSize: defaultFontSize, fontColor: .white)
            
            baseButton.action = {
                [weak self] () in
                
                self?.removeActions()
                self?.removeUnitInfo()
                self?.waitUnit()
            }
            
        case .info:
            baseButton.setText(text: "Info", fontSize: defaultFontSize, fontColor: .white)
            
            baseButton.action = {
                [weak self] () in
                
                self?.removeActions()
                self?.removeUnitInfo()
                _ = self?.showStatInfo()
            }
            
        default: break
        }
        
        baseButton.addButton(parent: baseNode, position: position)
    }
    
    

    public func addUnitInfo() -> SKSpriteNode {
        
        let baseWidth:CGFloat = 250
        let baseHeight:CGFloat = 100
        
        let infoYOffset:CGFloat = -100
        
        let baseNode = SKSpriteNode(texture: nil, color: .black, size: CGSize(width: baseWidth, height: baseHeight))
        baseNode.position = CGPoint.zero.applying(CGAffineTransform(translationX: 0, y: infoYOffset))
        baseNode.name = "BaseInfo"
        
        let unitHP:Int = getStat(stat: .hp)
        let unitMaxHP:Int = getBase(stat: .hp)
        let unitPower:Int = getStat(stat: .strength)
        
        let text:String = "HP:" + String(unitHP) + "/" + String(unitMaxHP) + "\n" +
        "Atk:\t" + String(unitPower)
        
        let infoNode = SKLabelNode(text: text)
        infoNode.fontColor = .white
        infoNode.fontSize = 25
        infoNode.position = CGPoint(x: 50, y: -10)
        infoNode.numberOfLines = 2
        baseNode.addChild(infoNode)
        
        return baseNode
    }
    

    public func removeUnitInfo() {
        
        assert(self.battleNode.scene is BattleScene)
        let scene = self.battleNode.scene as! BattleScene
        
        if let childNode = scene.camera!.childNode(withName: "BaseInfo") {
            
            childNode.removeFromParent()
        }
    }
    
    
    public func removeUnitActionInfo() {
        assert(self.battleNode.scene is BattleScene)
        let battleScene = self.battleNode.scene as! BattleScene
        
        if let childNode = battleScene.camera!.childNode(withName: "ActionInfo") {
            
            childNode.removeFromParent()
        }
    }
    
    
    

    ///Actions have 2 components, highlighting where the action is applicable and actually performing it
    
    //Move Action
    
    public func highlightMoveableTiles() {
        
        if self.battleNode.parent is TileMap {
            
            let tilemap = self.battleNode.parent as! TileMap
            
            let moveableTiles = tilemap.getTiles(withinRange: getStat(stat: .movement), from: self.currentTile!,
                                                 ignoresUnit: false, isPlayer: self.player, ignoresTerrain: false,
                                                 includesUnit: false, recordsPath: true)
            
            
            tilemap.highlightedTiles = moveableTiles
            
            self.pendingAction = .move
            
        } else {
            
            print("Unit is not a child of tilemap")
        }
    }
    
    
    public func moveUnit(_ movements: [CGVector], _ newTile: Tile) -> [SKAction] {
        
        if movements.isEmpty {
            return []
        }
        
        self.origTile = self.currentTile
        preMove()
        var actions:[SKAction] = []
        
        for vector in movements {
            actions.append(SKAction.move(by: vector, duration: 0.25))
        }
        self.movedThisTurn = true
        
        return actions
    }
    
    public func waitUnit() {
        self.unitHasActed()
    }
    
    //Attack action
    
    public func highlightAttackableTiles() {
        
        if self.battleNode.parent is TileMap {
            
            let tilemap = self.battleNode.parent as! TileMap
            
            var attackableTileswithUnits:[Tile] = []
            let attackableTiles = tilemap.getTiles(withinRange: 1, from: self.currentTile!, ignoresUnit: true, isPlayer: true, ignoresTerrain: true, includesUnit: true, recordsPath: false)
            
            for tile in attackableTiles {
                if tile.currentUnit != nil && tile.currentUnit !== self {
                    attackableTileswithUnits.append(tile)
                }
            }
            
            tilemap.highlightedTiles = attackableTileswithUnits
            
            self.pendingAction = .attack
            
        } else {
            
            print("Unit is not a child of tilemap")
        }
    }
    
    public func performAttack(_ attackedUnit: Unit?) {
        
        if (attackedUnit != nil) {
        
            let info = getAttackInfo(attackedUnit)!
            
            for _ in 1...info.1 {
                var dmg = info.0
                var rng = Int.random(in: 0...100)
                if (rng > info.2) {
                    print("miss")
                    continue
                }
                rng = Int.random(in: 0...100)
                if (rng < info.3) {
                    dmg = dmg * 3
                    print("crit")
                }
                
                attackedUnit!.loseHP(damage: dmg)
                print("Unit attacked unit for " + String(dmg) + " damage")
            }
            
            if (attackedUnit!.getStat(stat: .hp) > 0) {
                
                let info = attackedUnit!.getAttackInfo(self)!
                
                for _ in 1...info.1 {
                    var dmg = info.0
                    var rng = Int.random(in: 0...100)
                    if (rng > info.2) {
                        print("miss")
                        continue
                    }
                    rng = Int.random(in: 0...100)
                    if (rng < info.3) {
                        dmg = dmg * 3
                        print("crit")
                    }
                    
                    self.loseHP(damage: dmg)
                    print("Unit counterattacked unit for " + String(dmg) + " damage")
                }
            } else {
                print("unit did not cattack because dead")
            }
            
            let battleScene = battleNode.scene as! BattleScene
            self.pendingAction = .none
            battleScene.selectedUnit = nil
            
            if (self.isPlayer()) {
                self.xp += self.calculateActionXP(initiated: true, unit: attackedUnit)
            }
            
            if (attackedUnit!.isPlayer()) {
                attackedUnit!.xp += attackedUnit!.calculateActionXP(initiated: false, unit: attackedUnit!)
            }
            
            self.unitHasActed()
        }
    }
    
    
    
    
    //returns in order, damage, num of attacks, hit chance and crit chance
    public func getAttackInfo(_ attackedUnit: Unit?) -> (Int, Int, Int, Int)? {
        
        if (attackedUnit == nil) {
            return nil
        }
        
        var attackDamage = self.getStat(stat: .strength) - attackedUnit!.getStat(stat: .defense)
        
        if attackDamage < 0 {
            attackDamage = 0
        }
        
        var numAttacks:Int = self.getStat(stat: .speed) - attackedUnit!.getStat(stat: .speed) / 2
        
        if numAttacks <= 0 {
            numAttacks = 1
        }
        
        var hitChance = 100 + self.getStat(stat: .precision) - attackedUnit!.getStat(stat: .evasion)
        
        if (hitChance > 100) {
            hitChance = 100
        } else if hitChance < 0 {
            hitChance = 0
        }
        
        var critChance = self.getStat(stat: .precision) - attackedUnit!.getStat(stat: .fortune)
        
        if (critChance < 0) {
            critChance = 0
        } else if critChance > 100 {
            critChance = 100
        }
        return (attackDamage, numAttacks, hitChance, critChance)
    }
    
    
    
    
    public func showAttackInfo(_ attackedUnit: Unit?, _ tile: Tile) {
        
        if (attackedUnit == nil) {
            return
        }
        
        let ingInfo = self.getAttackInfo(attackedUnit)
        let edInfo = attackedUnit!.getAttackInfo(self)
        
        let infoNode = SKSpriteNode(texture: nil, color: .black, size: .init(width: 160, height: 150))
        infoNode.position = .init(x: 120, y: 100)
        infoNode.zPosition = 3
        
        let ingDmg = SKLabelNode(text: String(ingInfo!.0))
        let ingNum = SKLabelNode(text: "x" + String(ingInfo!.1))
        let ingHit = SKLabelNode(text: String(ingInfo!.2))
        let ingCrit = SKLabelNode(text: String(ingInfo!.3))
        
        let dmg = SKLabelNode(text: "Dmg")
        dmg.fontSize = 20
        let acc = SKLabelNode(text: "Acc")
        acc.fontSize = 20
        let crit = SKLabelNode(text: "Crit")
        crit.fontSize = 20
        
        let edDmg = SKLabelNode(text: String(edInfo!.0))
        let edNum = SKLabelNode(text: "x" + String(edInfo!.1))
        let edHit = SKLabelNode(text: String(edInfo!.2))
        let edCrit = SKLabelNode(text: String(edInfo!.3))
        
        infoNode.addChild(ingDmg)
        ingDmg.position = .init(x: -50, y: 40)
        infoNode.addChild(ingHit)
        ingHit.position = .init(x: -50, y: -10)
        infoNode.addChild(ingCrit)
        ingCrit.position = .init(x: -50, y: -60)
        
        infoNode.addChild(dmg)
        dmg.position = .init(x: 0, y: 40)
        infoNode.addChild(acc)
        acc.position = .init(x: 0, y: -10)
        infoNode.addChild(crit)
        crit.position = .init(x: 0, y: -60)
        
        infoNode.addChild(edDmg)
        edDmg.position = .init(x: 50, y: 40)
        infoNode.addChild(edHit)
        edHit.position = .init(x: 50, y: -10)
        infoNode.addChild(edCrit)
        edCrit.position = .init(x: 50, y: -60)
        
        if edInfo!.1 == 1 {
            infoNode.addChild(ingNum)
            ingNum.position = .init(x: -35, y: 50)
            ingNum.fontSize = 20
            
        }
        
        if ingInfo!.1 == 1 {
            infoNode.addChild(edNum)
            edNum.position = .init(x: 65, y: 50)
            edNum.fontSize = 20
        }
        
        let button = ButtonNode(color: .red, size: .init(width: 160, height: 40))
        
        button.action = {
            [weak self] () in
            self?.removeUnitActionInfo()
            
            self?.performAttack(attackedUnit!)
        }
        
        assert(self.battleNode.scene is BattleScene)
        let scene = self.battleNode.scene as! BattleScene
        button.addButton(parent: infoNode, position: .init(x: 0, y: -95))
        infoNode.name = "ActionInfo"
        scene.camera!.addChild(infoNode)

    }
    
    public func showStatInfo() -> SKSpriteNode {
        
        let infoNode = SKSpriteNode(texture: nil, color: .black, size: .init(width: 200, height: 300))
        infoNode.position = .init(x: 0, y: 0)
        infoNode.zPosition = 3
        
        let str = SKLabelNode(text: "Str " + String(self.getStat(stat: .strength)))
        str.fontSize = 16
        let hp = SKLabelNode(text: "HP " + String(self.getStat(stat: .hp)))
        hp.fontSize = 16
        let spd = SKLabelNode(text: "Spd " + String(self.getStat(stat: .speed)))
        spd.fontSize = 16
        let eva = SKLabelNode(text: "Eva " + String(self.getStat(stat: .evasion)))
        eva.fontSize = 16
        let pre = SKLabelNode(text: "Pre " + String(self.getStat(stat: .precision)))
        pre.fontSize = 16
        let def = SKLabelNode(text: "Def " + String(self.getStat(stat: .defense)))
        def.fontSize = 16
        let mov = SKLabelNode(text: "Mov " + String(self.getStat(stat: .movement)))
        mov.fontSize = 16
        let fort = SKLabelNode(text: "For " + String(self.getStat(stat: .fortune)))
        fort.fontSize = 16
        
        /*case hp = 0
        case strength = 1
        case speed = 2
        case evasion = 3
        case precision = 4
        case defense = 5
        case movement = 6
        case fortune = 7*/
        
        infoNode.addChild(hp)
        hp.position = .init(x: -50, y: 100)
        infoNode.addChild(str)
        str.position = .init(x: -50, y: 50)
        infoNode.addChild(spd)
        spd.position = .init(x: -50, y: 0)
        infoNode.addChild(eva)
        eva.position = .init(x: -50, y: -50)
        infoNode.addChild(pre)
        pre.position = .init(x: 50, y: 100)
        infoNode.addChild(def)
        def.position = .init(x: 50, y: 50)
        infoNode.addChild(mov)
        mov.position = .init(x: 50, y: 0)
        infoNode.addChild(fort)
        fort.position = .init(x: 50, y: -50)
        
        
        let scene = self.battleNode.scene as! BattleScene
        infoNode.name = "StatInfo"
        scene.camera!.addChild(infoNode)
        
        return infoNode
    }
    
    
    public func preMove() {
        self.currentTile?.currentUnit = nil
    }
    
    
    public func postMove() {
        
        assert(self.battleNode.parent! is TileMap)
        
        let tilemap = self.battleNode.parent! as! TileMap
        
        self.currentTile = tilemap.getTile(at: self.battleNode.position)
        self.currentTile?.currentUnit = self
        
        if self.isPlayer() && self.movedThisTurn {
            self.addActions()
        }
        
        
    }
    
    
    public func calculateActionXP(initiated: Bool, unit: Unit?) -> Int {
        
        if (initiated) {
            let leveldiff = self.getLevel() - unit!.getLevel()
            var expGained = 100 - (leveldiff * 6)
            if (expGained <= 0) {
                expGained = 1
            }
            return expGained
            
        }
        return 0
    }
    
    public func levelUp() {
        
        let node = self.showStatInfo()
        node.name = "LevelNode"
        
        var index = 0
        
        for i in 0...1 {
            
            for j in 0...3 {
                
                let classStat = self.currentClass.getStats()[index]
                var weapStat = 0
                
                if self.currentWeapon != nil {
                    weapStat = self.currentWeapon!.getStat(i: index)
                }
                
                let total = classStat + weapStat
                
                var b = total / 100
                let r = total % 100
                
                
                let random = Int.random(in: 0...99)
                
                if random <= r {
                    b += 1
                }
                
                stats[index] += b
                
                let x = -20 + (100 * i)
                let y = 100 - (50 * j)
                
                
                if b > 0 {
                    
                    let addNode = SKLabelNode(text: "+" + String(b))
                    addNode.fontSize = 16
                    addNode.position = .init(x: x, y: y)
                    node.addChild(addNode)
                }
                
                
                index += 1
                
            }
        }
    }
    
    
    
    
    //CONFORMING TO PROTOCOLS
    
    
    public func getListName() -> String {
        return self.name
    }
    
    public static func == (lhs: Unit, rhs: Unit) -> Bool {
        return lhs === rhs
    }
    
    
    deinit {
        print("Unit deinit")
    }
    
    
    
}


