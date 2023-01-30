//
//  Province.swift
//  Game
//
//  Created by Marvin Fishingpole on 5/12/21.
//  Copyright © 2021 None. All rights reserved.
//

import Foundation
import SpriteKit



public enum BaseProvinceAction: CaseIterable {
    case attack, transfer, barracks, armory, mine, train, invest, info
}



public class Province: SKSpriteNode {
    
    private weak var currentOwner:Leader? = nil
    private var currentUnits:[Unit] = []
    
    private var id:Int
    
    private var barracksLevel = (1, 0)
    private var armoryLevel = (1, 0)
    private var trainingLevel = (1, 0)
    private var mineLevel = (1, 0)
    
    
    
    init(id: Int) {
        self.id = id
        super.init(texture: nil, color: .red, size: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public func getID() -> Int {
        return self.id
    }
    
    public func getOwner() -> Leader? {
        return self.currentOwner  
    }
    
    public func getCurrentUnits() -> [Unit] {
        return self.currentUnits
    }
    
    public func setOwner(newOwner: Leader) {
        self.currentOwner = newOwner
        self.color = newOwner.color
    }
    
    //USE THIS FUNCTION TO HANDLE TRANSFERING UNITS
    public func stationUnit(newUnit: Unit) {
        
        let oldProvince = newUnit.getProvince()
        oldProvince?.removeUnit(unit: newUnit)
        
        self.currentUnits.append(newUnit)
        newUnit.setProvince(newProvince: self)
    }
    
    public func removeUnit(unit: Unit) {
        
        if self.currentUnits.contains(unit) {
            let pos = self.currentUnits.firstIndex(of: unit)!
            self.currentUnits.remove(at: pos)
            
        } else {
            print("Unit not belonging to province from which it was removed")
        }
    }
    
    public func isFull() -> Bool {
        return self.currentUnits.count > 7
    }
    
    public func hasActiveUnits() -> Bool {
        return !self.currentUnits.allSatisfy({$0.hasActedThisMonth()})
    }
    
    
    public func addActions() {
        
        let buttonXPosition:CGFloat = 125
        let buttonYPosition:CGFloat = 25
        var buttonYOffset:CGFloat = 35
        
        let defaultButtonHeight:CGFloat = 25
        
        assert(self.scene != nil)
        let overworld = self.scene! as! OverworldScene
        
        
        let baseNode = SKSpriteNode(texture: nil, color: .clear, size: .zero)
        baseNode.name = "ActionNode"
        
        self.scene!.camera!.addChild(baseNode)
        
        for action in BaseProvinceAction.allCases {
            
            if action == .attack {
                
                if self.currentOwner === overworld.getLeaders()[0] {
                    continue
                }
                
                var isAdj = false
                let player = overworld.getLeaders()[0]
                
                for owned in player.getProvinces() {
                    if overworld.adjList[owned.id].contains(self.id) {
                        isAdj = true
                        break
                    }
                }
                
                if !isAdj {
                    continue
                }
                
            } else if action == .transfer ||
                        action == .barracks ||
                        action == .armory ||
                        action == .mine ||
                        action == .train ||
                        action == .invest {
                let player = overworld.getLeaders()[0]
                
                if self.currentOwner !== player {
                    continue
                }
            }
            
            let translation = CGAffineTransform(translationX: 0,
                                                y: buttonYOffset)
            
            let buttonPos = CGPoint(x: buttonXPosition, y: buttonYPosition).applying(translation)
            addBaseButton(action: action, position: buttonPos, base: baseNode)
            
            buttonYOffset -= defaultButtonHeight
        }
    }

    
    public func addBaseButton(action: BaseProvinceAction, position: CGPoint, base: SKSpriteNode) {
        
        assert(self.scene != nil)
        
        let defaultButtonWidth:CGFloat = 60
        let defaultButtonHeight:CGFloat = 25
        let defaultFontSize:CGFloat = 25
        
        let baseButton = ButtonNode(color: .black, size: CGSize(width: defaultButtonWidth * 2,
                                                                height: defaultButtonHeight * 2))
        
        switch action {
        case .attack:
            baseButton.setText(text: "Attack", fontSize: defaultFontSize, fontColor: .white)
            
            assert(self.scene is OverworldScene)
            
            baseButton.action = {
                [weak self] () in
                
                print("Attack Selected")
                
                self?.removeActions()
                self?.attackProvince()
                
                
            }
            
        case .transfer:
            baseButton.setText(text: "Transfer", fontSize: defaultFontSize, fontColor: .white)
            
            assert(self.scene is OverworldScene)
        
            baseButton.action = {
                
                [weak self] in ()
                
                print("Transfer Selected")
                
                self?.removeActions()
                self?.transferUnits()
            }
            
        case .barracks:
            baseButton.setText(text: "Barracks", fontSize: defaultFontSize, fontColor: .white)
            
            assert(self.scene is OverworldScene)
        
            baseButton.action = {
                
                [weak self] in ()
                
                print("Barracks Selected")
                
                self?.removeActions()
                self?.openBarracks()
            }
            
            
        case .armory:
            baseButton.setText(text: "Armory", fontSize: defaultFontSize, fontColor: .white)
        
            baseButton.action = {
                
                [weak self] in ()
                
                print("Transfer Selected")
                
                self?.removeActions()
                self?.openArmory()
                
            }
            
            
        case .info:
            baseButton.setText(text: "Info", fontSize: defaultFontSize, fontColor: .white)
            
            baseButton.action = {
                
                [weak self] in ()
                
                self?.removeActions()
                self?.getInfo()
            
            }
            
        case .mine:
            baseButton.setText(text: "Mine", fontSize: defaultFontSize, fontColor: .white)
            
            baseButton.action = {
                
                [weak self] in ()
                
                self?.removeActions()
                self?.mineProvince()
            }
            
        case .train:
            baseButton.setText(text: "Train", fontSize: defaultFontSize, fontColor: .white)
            
            baseButton.action = {
                
                [weak self] in ()
                
                self?.removeActions()
                self?.trainProvince()
                
            }
            
        case .invest:
            
            baseButton.setText(text: "Invest", fontSize: defaultFontSize, fontColor: .white)
            
            baseButton.action = {
                
                [weak self] in ()
                
                self?.removeActions()
                self?.investProvince()
                
            }
            
        }
        
        
        baseButton.zPosition = 5
        baseButton.addButton(parent: base, position: position)
        
    }
    
    
    private func getAvailableUnits() -> [Unit] {
        var notMoved:[Unit] = []
        for unit in self.currentUnits {
            if !unit.hasActedThisMonth() {
                notMoved.append(unit)
            }
        }
        return notMoved
    }
    
    
    private func addChooseNode(units: [Unit]) -> (PageNode<Unit>, ButtonNode) {
        
        let oScene = self.scene as! OverworldScene
        
        let node = PageNode(list: units, size: .init(width: 200, height: 200))
        node.name = "ChooseNode"
        node.addNode(pos: .init(x: 0, y: 50), parent: oScene.camera!, numPerPage: 5, maxChosen: 8)
        
        let goButton = ButtonNode(texture: nil, color: .yellow, size: .init(width: 60, height: 60))
        goButton.addButton(parent: node, position: .init(x: (node.size.width / 2) + goButton.size.width / 2, y: 0))
        
        return (node, goButton)
    }
    
    
    
    private func attackProvince() {
        
        let oScene = self.scene as! OverworldScene
        
        let cNode = addChooseNode(units: oScene.getLeaders()[0].getAvailableUnits())
        
        cNode.1.action = {
            [weak self, weak n = cNode.0, weak o = oScene] in ()
            
            if (n!.getAdded().isEmpty) {
                return
            }
            
            o?.view?.presentScene(BattleScene(size: oScene.size, attackingUnits: cNode.0.getAdded(), defendingUnits: (self!.currentUnits), returnScene: oScene, province: self!))
            
            self?.deselect(battleStarting: true)
        }
    }
    
    private func openBarracks() {
        
        let oScene = self.scene as! OverworldScene
        
        let node = SKSpriteNode(texture: nil, color: .black, size: .init(width: 100, height: 100))
        node.name = "BarracksNode"
        node.position = .zero
        oScene.camera!.addChild(node)
        
        let recruitButton = ButtonNode(texture: nil, color: .black, size: .init(width: 100, height: 50))
        recruitButton.setText(text: "Recruit", fontSize: 10, fontColor: .white)
        recruitButton.addButton(parent: node, position: .zero)
        
        recruitButton.action = {
            [weak self, weak node] in ()
            
            self?.recruitUnit()
            node?.removeFromParent()
  
        }
    }
    
    private func recruitUnit() {
        
        let oScene = self.scene as! OverworldScene
        
        let node = CycleNode<UnitClass>(list: UnitClass.allCases, size: .init(width: 200, height: 20))
        node.addNode(pos: .zero, parent: oScene.camera!)
        node.name = "RecruitNode"
        
        let yesButton = ButtonNode(texture: nil, color: .black, size: .init(width: 100, height: 20))
        yesButton.setText(text: "Recruit", fontSize: 10, fontColor: .white)
        yesButton.addButton(parent: node, position: .init(x: 0, y: -node.size.height))
        
        yesButton.action = {
            [weak self, weak player = self.currentOwner, weak node] in ()
            
            let newUnit = Unit(hp: 10, strength: 1, range: 5, isPlayer: true, name: "Name")
            newUnit.changeClass(newClass: node!.getSelected())
            
            player?.addUnit(newUnit: newUnit, province: self!)
            self?.deselect(battleStarting: false)
        }
    }
    
    private func openArmory() {
        
        let oScene = self.scene as! OverworldScene
        
        let node = PageNode<Weapon>(list: Weapon.allCases, size: .init(width: 150, height: 300))
        node.name = "ArmoryNode"
        
        node.addNode(pos: .init(x: 0, y: 50), parent: oScene.camera!, numPerPage: 5, maxChosen: 1)
        
        let yesButton = ButtonNode(texture: nil, color: .black, size: .init(width: 50, height: 50))
        yesButton.setText(text: "Purchase", fontSize: 10, fontColor: .white)
        yesButton.addButton(parent: node, position: .init(x: (node.size.width / 2) + (yesButton.size.width / 2), y: 0))
        
        yesButton.action = {
            [weak player = self.currentOwner, weak node, weak self] in ()
            
            if node!.getAdded().isEmpty {
                return
            }
            
            let selectedType = node!.getAdded().first!
            let newWeapon = UnitWeapon(power: selectedType.getBasePower(),
                                       stats: selectedType.getBaseStats(),
                                       range: selectedType.getRange())
            
            player!.addWeapon(newWeapon: newWeapon)
            
            self?.deselect(battleStarting: false)
        }
        
        
    }

    private func transferUnits() {
        
        let oScene = self.scene as! OverworldScene
        let player = oScene.getLeaders().first!
        
        let cNode = addChooseNode(units: player.getCurrentUnits())
        
        cNode.1.action = {
            [weak self, weak n = cNode.0] in ()
            
            let selected = n!.getAdded()
            
            if (selected.isEmpty) {
                return
            }
            
            for unit in selected {
                self!.stationUnit(newUnit: unit)
            }
            self!.deselect(battleStarting: false)
        }
    }
    
    
    
    private func mineProvince() {
        
        let cNode = addChooseNode(units: getAvailableUnits())
        
        cNode.1.action = {
            [weak self, weak n = cNode.0] in ()
            
            
            let mineAmountPerUnit = 250
            let selected = n!.getAdded()
            
            for unit in selected {
                unit.unitHasActedOverworld()
            }
            
            let amount = selected.count * (self?.mineLevel.0)! * mineAmountPerUnit
            self?.currentOwner?.addMoney(amount: amount)
            
            self?.deselect(battleStarting: false)
            print("Received " + String(amount) + " Gold")
        }
    }
        
    private func trainProvince() {
        
        let oScene = self.scene as! OverworldScene
        let cNode = addChooseNode(units: getAvailableUnits())
        
        cNode.1.action = {
            [weak self, weak n = cNode.0, weak s = oScene] in ()
            
            let selected = n!.getAdded()
            
            for unit in selected {
                unit.unitHasActedOverworld()
            }
            
            var defendingUnits:[Unit] = []
            
            for _ in 0...3 {
                defendingUnits.append(Unit(hp: 10, strength: 1, range: 1, isPlayer: false, name: "Name"))
            }
            
            let trainingScene = BattleScene(size: oScene.size, attackingUnits: selected, defendingUnits: defendingUnits, returnScene: oScene, province: self!)
            
            s!.view!.presentScene(trainingScene)
        }
    }
    
    
    
    private func investProvince() {
        
        let cNode = addChooseNode(units: getAvailableUnits())
        
        cNode.1.action = {
            [weak self, weak n = cNode.0] in ()
            self!.openInvestMenu(units: n!.getAdded())
            n?.removeFromParent()
        }
    }
    
    private func openInvestMenu(units: [Unit]) {
        let oScene = self.scene! as! OverworldScene
        
        let defaultButtonWidth = 60
        let defaultButtonHeight = 25
        let numActions = 4
        
        
        
        let investNode = Util.ButtonHolder(texture: nil,
                                           color: .black,
                                           size: .init(width: defaultButtonWidth, height: defaultButtonHeight * numActions),
                                           name: "InvestNode",
                                           maxButtons: numActions)
        
        oScene.camera!.addChild(investNode)
        investNode.position = .zero
        
        for i in 0...3 {
            
            let buttonNode = investNode.addButton()
            
            switch i {
            case 0:
                buttonNode.setText(text: "Barracks", fontSize: 10, fontColor: .white)
                buttonNode.action = {
                    [weak self, weak n = investNode] in ()
                    self!.invest(units: units, target: .barracks, n: n!)
                }
                break
            case 1:
                buttonNode.setText(text: "Armory", fontSize: 10, fontColor: .white)
                buttonNode.action = {
                    [weak self, weak n = investNode] in ()
                    self!.invest(units: units, target: .armory, n: n!)
                }
                break
            case 2:
                buttonNode.setText(text: "Trainer", fontSize: 10, fontColor: .white)
                buttonNode.action = {
                    [weak self, weak n = investNode] in ()
                    self!.invest(units: units, target: .train, n: n!)
                }
                break
            case 3:
                buttonNode.setText(text: "Mine", fontSize: 10, fontColor: .white)
                buttonNode.action = {
                    [weak self, weak n = investNode] in ()
                    self!.invest(units: units, target: .mine, n: n!)
                }
                break
            default:
                break
            }
        }
    }
    
    private func invest(units: [Unit], target: BaseProvinceAction, n: Util.ButtonHolder) {
        
        let amountToAdd = units.count * 50
        
        switch target {
            
        case .armory:
            self.armoryLevel.1 += amountToAdd
            if (self.armoryLevel.1 >= 100) {
                self.armoryLevel.0 += 1
                self.armoryLevel.1 = self.armoryLevel.1 % 100
                self.upgradeArmory()
            }
            
            break
        case .barracks:
            self.barracksLevel.1 += amountToAdd
            if (self.barracksLevel.1 >= 100) {
                self.barracksLevel.0 += 1
                self.barracksLevel.1 = self.barracksLevel.1 % 100
                self.upgradeBarracks()
            }
            break
        case .mine:
            self.mineLevel.1 += amountToAdd
            if (self.mineLevel.1 >= 100) {
                self.mineLevel.0 += 1
                self.mineLevel.1 = self.mineLevel.1 % 100
            }
            break
            
        case .train:
            self.trainingLevel.1 += amountToAdd
            if (self.trainingLevel.1 >= 100) {
                self.trainingLevel.0 += 1
                self.trainingLevel.1 = self.trainingLevel.1 % 100
                self.upgradeTrainer()
            }
            break
        default:
            assert(false)
            break
        }
        
        for unit in units {
            unit.unitHasActedOverworld()
        }
        
        n.removeFromParent()
        
    }
    
    
    private func upgradeArmory() {
        
        
        
        
        
    }
    
    
    private func upgradeBarracks() {
        
    }
    
    
    
    private func upgradeTrainer() {
        
        
    }
    

    private func getInfo() {
        
        let infoNode = SKSpriteNode(texture: nil, color: .black, size: .init(width: 200, height: 200))
        infoNode.name = "InfoNode"
        
        for i in 0...1 {
            for j in 0...3 {
                
                let id = j + (i * 4)
                
                if id < self.currentUnits.count {
                    
                    let unitNode = ButtonNode(texture: nil, color: .blue, size: .init(width: infoNode.size.width / 2, height: infoNode.size.height / 4))
                    
                    let x:CGFloat = (-infoNode.size.width / 4) + ((infoNode.size.width / 2) * CGFloat(i))
                    let y:CGFloat = ((3 * infoNode.size.height) / 8) - ((infoNode.size.height / 4) * CGFloat(j))
                    
                    let pos:CGPoint = .init(x: x, y: y)
                    
                    unitNode.addButton(parent: infoNode, position: pos)
                    
                    unitNode.setText(text: self.currentUnits[id].getListName(), fontSize: 10, fontColor: .white)
                    
                    unitNode.action = {
                        
                        [weak self, weak scene = self.scene as? OverworldScene] in ()
                        
                        let unit = self!.currentUnits[id]
                        let node = unit.addUnitInfo()
                        
                        node.name = "UnitInfo"
                        
                        scene?.camera!.addChild(node)
                        
                    }
                }
            }
        }
            
        self.scene!.camera!.addChild(infoNode)
            
    }
    
    
    
    
    public func removeActions() {
        
        assert(self.scene != nil)
        let s = self.scene!
        
        if let node = s.camera!.childNode(withName: "ActionNode") {
            
            node.removeAllChildren()
            node.removeFromParent()
        }
    }
    
    
    
    
    public func deselect(battleStarting: Bool) {
        
        let oScene = self.scene as! OverworldScene
        
        if let node = oScene.camera!.childNode(withName: "ChooseNode") {
            
            node.removeFromParent()
            
            if !battleStarting {
                self.addActions()
            }
            return
            
        } else if let node = oScene.camera!.childNode(withName: "InfoNode") {
            
            if let iNode = oScene.camera!.childNode(withName: "UnitInfo") {
                iNode.removeFromParent()
                return
            }
            
            node.removeFromParent()
            self.addActions()
            return
            
        } else if let node = oScene.camera!.childNode(withName: "BarracksNode") {
            
            node.removeFromParent()
            self.addActions()
            return
            
        } else if let node = oScene.camera!.childNode(withName: "RecruitNode") {
            
            node.removeFromParent()
            self.openBarracks()
            return
            
        } else if let node = oScene.camera!.childNode(withName: "ArmoryNode") {
            
            node.removeFromParent()
            self.addActions()
            return
            
        } else if let node = oScene.camera!.childNode(withName: "InvestNode") {
            
            node.removeFromParent()
            self.investProvince()
            return
        }
        
        self.removeActions()
    }

    
    
    deinit {
        print("Province Deinit")
    }
    
}
