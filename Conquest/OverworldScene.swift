//
//  OverworldScene.swift
//  Test
//
//  Created by Marvin Fishingpole on 9/23/21.
//

import Foundation
import SpriteKit

public enum MenuActionWorld: CaseIterable {
    case end
}



public class OverworldScene : SKScene {
    
    private let cameraNode = SKCameraNode()
    
    private var leaders:[Leader] = []
    private var provinces:[Province] = []
    
    public var adjList:[[Int]] = []
    
    private var selectedProvince:Province?
    
    private var currentLeaderTurn = 0
    
    public override func didMove(to view: SKView) {
        
        if !self.adjList.isEmpty {
            self.addPinchPanTap()
            return
        }
        
        self.addCamera()
        self.addPinchPanTap()
        self.addProvincesLeaders()
        self.addMenuButton()
        
    }

    
    
    private func addCamera() {
    
        self.addChild(cameraNode)
        self.camera = cameraNode
        self.camera!.zPosition = 5
    }
    
    private func addPinchPanTap() {
        
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinchToZoom(sender:)))
        self.view?.addGestureRecognizer(pinch)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panToDrag(sender:)))
        self.view?.addGestureRecognizer(pan)
    }
    
    
    public func getLeaders() -> [Leader] {
        return self.leaders
    }
    
    public func deselectProvince() {
        self.selectedProvince = nil
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
    
    
    
    
    private func addProvincesLeaders() {
        
        if !self.adjList.isEmpty {
            return
        }
        
        var positions:[CGPoint] = []
        positions.reserveCapacity(19)
        adjList = .init(repeating: [], count: 19)
        
        positions.append(.zero)
        positions.append(.init(x: 50, y: 10))
        positions.append(.init(x: 100, y: 30))
        positions.append(.init(x: 200, y: 70))
        positions.append(.init(x: 40, y: 80))
        positions.append(.init(x: 80, y: -100))
        positions.append(.init(x: 20, y: -50))
        positions.append(.init(x: -40, y: -70))
        positions.append(.init(x: -100, y: -80))
        positions.append(.init(x: -200, y: -100))
        positions.append(.init(x: -110, y: 40))
        positions.append(.init(x: -60, y: 110))
        positions.append(.init(x: 10, y: 160))
        positions.append(.init(x: -110, y: 160))
        positions.append(.init(x: -160, y: 100))
        positions.append(.init(x: -260, y: 80))
        positions.append(.init(x: -220, y: 140))
        positions.append(.init(x: -160, y: 240))
        positions.append(.init(x: -240, y: 300))
        
        
        adjList[0] = [1, 6, 4, 7, 10, 11]
        adjList[1] = [0, 4, 2, 5, 6]
        adjList[2] = [1, 3, 4]
        adjList[3] = [2]
        adjList[4] = [0, 1, 2, 11, 12]
        adjList[5] = [1, 6]
        adjList[6] = [5, 7, 0, 1]
        adjList[7] = [0, 6, 8, 10]
        adjList[8] = [7, 9, 10]
        adjList[9] = [8, 14]
        adjList[10] = [0, 7, 8, 11, 14]
        adjList[11] = [0, 4, 10, 12, 13, 14]
        adjList[12] = [4, 11, 13]
        adjList[13] = [11, 12, 14, 16, 17]
        adjList[14] = [9, 10, 11, 13, 15]
        adjList[15] = [14, 16]
        adjList[16] = [13, 15, 17, 18]
        adjList[17] = [16, 13, 18]
        adjList[18] = [16, 17]
        
        var i = 0
        for pos in positions {
            
            let r = CGFloat(Int.random(in: 0...255))
            let g = CGFloat(Int.random(in: 0...255))
            let b = CGFloat(Int.random(in: 0...255))
                
            let col = UIColor(red: r / 255, green: g / 255, blue: b / 255, alpha: 1)
                
            let province = Province(id: i)
                
            var player = false
            
            if i == 0 {
                player = true
            }
            
            let newLeader = Leader(units: [], provinces: [province], color: col, player: player)
                
            if i == 0 {
                    
                for j in 0...1 {
                        
                    let starterUnit = Unit(hp: 20, strength: 4, range: 8, isPlayer: true, name: String(j))
                    newLeader.addUnit(newUnit: starterUnit, province: province)

                }
                    
            } else {
                
                for _ in 0...Int.random(in: 0..<5) {
                    let starterUnit = Unit(hp: 10, strength: 1, range: 8, isPlayer: false, name: "Name")
                    newLeader.addUnit(newUnit: starterUnit, province: province)

                }
                
            }
                
                
            province.size = .init(width: 20, height: 20)
            province.position = pos
            self.addChild(province)
                
            leaders.append(newLeader)
            provinces.append(province)
            province.setOwner(newOwner: newLeader)
                
                
            i += 1
        }
    }
    
    
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if (self.hasActions() || camera!.hasActions()) {
            return
        }
        
        if self.camera!.childNode(withName: "MenuNode") != nil {
            self.removeMenuButtons()
            return
        } 
        
        let touchLocation = touches.first!.location(in: self)
        let nodesAtLocation = self.getNodes(point: touchLocation)
        
        //There should only be a max of one of each at any given touch location
        var provinces: [Province] = []
        
        for node in nodesAtLocation {
            
            if node is Province {
                provinces.append(node as! Province)
            }
        }
        
        self.selectProvince(province: provinces.first)
        
        
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
    
    
    
    private func selectProvince(province: Province?) {
        
        if self.selectedProvince != nil {
            
            if self.camera!.childNode(withName: "ChooseNode") != nil ||
                self.camera!.childNode(withName: "BarracksNode") != nil ||
                self.camera!.childNode(withName: "InfoNode") != nil ||
                self.camera!.childNode(withName: "RecruitNode") != nil ||
                self.camera!.childNode(withName: "ArmoryNode") != nil ||
                self.camera!.childNode(withName: "InvestNode") != nil {
                
                self.selectedProvince!.deselect(battleStarting: false)
                return
            }
            
            self.selectedProvince!.deselect(battleStarting: false)
            self.selectedProvince = nil
            
            if province != nil {
                
                self.selectedProvince = province
                province!.addActions()
                
                self.cameraNode.run(SKAction.move(to: province!.position, duration: 0.1))
            }
            
        } else if province != nil {
            
            self.selectedProvince = province
            province!.addActions()
            self.cameraNode.run(SKAction.move(to: province!.position, duration: 0.1))
            
        }
        
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
        
        
        for action in MenuActionWorld.allCases {
            
            let translation = CGAffineTransform(translationX: 0,
                                                y: buttonYOffset)
            
            let buttonPos = CGPoint(x: buttonXPosition, y: buttonYPosition).applying(translation)
            addMenuButton(action: action, position: buttonPos, base: baseNode)
            
            buttonYOffset -= defaultButtonHeight
        }
    }
    
    private func addMenuButton(action: MenuActionWorld, position: CGPoint, base: SKSpriteNode) {
        
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
    
    public func provinceBattleEnd(challenger: Leader, defender: Leader, province: Province, won: Bool) {
        //If the challenger won
        if won {
            challenger.gainProvince(newProvince: province)
            defender.transferDefeatedUnits(defeatedProvince: province)
        }
        
        if self.currentLeaderTurn != 0 {
            self.enemyTurn()
        }
        
    }
    
    private func enemyTurn() {
        
        print("Enemy Turn")
        
        func conductLeaderTurn() {
            
            var leader = leaders[currentLeaderTurn]
            
            while (leader.getProvinces().isEmpty || leader.player) {
                
                currentLeaderTurn += 1
                
                if currentLeaderTurn >= leaders.count {
                    leaders[0].newMonth()
                    return
                }
                
                leader = leaders[currentLeaderTurn]
            }
            
            let wait = SKAction.wait(forDuration: 0.5)
            let pan = SKAction.move(to: leader.getProvinces().first!.position, duration: 0.2)
            
            self.cameraNode.run(SKAction.sequence([pan, wait]), withKey: "InitialPan")
            print("Turn of leader " + String(leader.getProvinces().first!.getID()))
            
            var currentLeaderUnits = leader.getCurrentUnits()
            
            currentLeaderUnits.sort {
                $0.getLevel() < $1.getLevel()
            }
            
            var leaderStrength = 0
            
            for i in 0...8 {
                if i >= currentLeaderUnits.count {
                    break
                }
                leaderStrength += currentLeaderUnits[i].getLevel()
            }
            
            var checkedProvinces:[Int] = []
            var alreadyAttacked = false
            
            for prov in leader.getProvinces() {
                
                for adjProvID in adjList[prov.getID()] {
                    
                    if (checkedProvinces.contains(adjProvID)) {
                        continue
                    }
                    
                    let adjProv = provinces[adjProvID]
                    
                    //Can't attack yourself 
                    if adjProv.getOwner()! === leader { continue }
                    
                    var provinceStrength = 0
                    
                    for unit in adjProv.getCurrentUnits() {
                        provinceStrength += unit.getLevel()
                    }
                    
                    let rand = Int.random(in: 0...10)
                    
                    if leaderStrength >= provinceStrength && alreadyAttacked == false && rand > 7 {
                        
                        var units:[Unit] = []
                        
                        if currentLeaderUnits.count < 8 {
                            units = currentLeaderUnits
                        } else {
                            units = Array(currentLeaderUnits.prefix(upTo: 8))
                        }
                        
                        let cost = units.count * 0
                        
                        if cost <= leader.getMoney() {
                            
                            leader.deductMoney(amount: cost)
                            
                            if adjProv.getOwner()!.player {
                                challengePlayer(challengerUnits: units, challenger: leader, province: adjProv)
                                return
                            } else {
                                challengeProvince(province: adjProv, challenger: leader, units: units)
                            }
                            
                        }
                        
                        alreadyAttacked = true
                    }
                    
                    checkedProvinces.append(adjProvID)
                }
            }
            
            currentLeaderTurn += 1
            
            if currentLeaderTurn < leaders.count {
                
                if let action = cameraNode.action(forKey: "Challenge") {
                    
                    let duration = action.duration
                    cameraNode.run(SKAction.wait(forDuration: duration + 1), completion: conductLeaderTurn)
                    
                } else {
                    cameraNode.run(SKAction.wait(forDuration: 1), completion: conductLeaderTurn)
                }
            } else {
                currentLeaderTurn = 0
            }
        }
        
        conductLeaderTurn()
    }
    
    
    
    
    
    private func challengeProvince(province: Province, challenger: Leader, units: [Unit]) {
        
        print("Leader of Province " + String(challenger.getProvinces().first!.getID()) +  " has challenged Province " + String(province.getID()))
        
        var duration = 0.5
        
        if let action = cameraNode.action(forKey: "InitialPan") {
            duration += action.duration
        }
        
        let wait = SKAction.wait(forDuration: duration)
        let pan = SKAction.move(to: province.position, duration: 0.5)
        
        cameraNode.run(action: SKAction.sequence([wait, pan]), withKey: "Challenge", optionalCompletion: {
            [unowned self] in
            
            if self.simulateBattle(challenger: challenger,
                              unitsChallenger: units,
                              defender: province.getOwner()!,
                              unitsDefender: province.getCurrentUnits(),
                              province: province) {
                
                province.getOwner()!.transferDefeatedUnits(defeatedProvince: province)
                challenger.gainProvince(newProvince: province)
                
                for unit in units {
                    province.stationUnit(newUnit: unit)
                }
                
                print("Attack Succeeded")
            } else {
                print("Attack Failed")
            }
            
            
        })
    }
    
    //Returns whether challenger wins
    private func simulateBattle(challenger: Leader, unitsChallenger: [Unit], defender: Leader, unitsDefender: [Unit], province: Province) -> Bool {
        
        return (Int.random(in: 0...10) < 5)
    }
    
    
    private func challengePlayer(challengerUnits: [Unit], challenger: Leader, province: Province) {
        
        self.currentLeaderTurn += 1
        
        print("Leader of Province " + String(challenger.getProvinces().first!.getID()) +  " has challenged Province " + String(province.getID()))
        
        var duration = 0.5
        
        if let action = cameraNode.action(forKey: "InitialPan") {
            
            duration += action.duration
        }
        
        let wait = SKAction.wait(forDuration: duration)
        let pan = SKAction.move(to: province.position, duration: 0.5)
        
        cameraNode.run(action: SKAction.sequence([wait, pan]), withKey: "Challenge", optionalCompletion: nil)
        
        let enemyNode = InfoGenerator.generateUnitList(units: challengerUnits)
        let allyNode = InfoGenerator.generateUnitList(units: province.getCurrentUnits())
        
        enemyNode.position = .init(x: -80, y: 0)
        allyNode.position = .init(x: 80, y: 0)
        
        self.camera?.addChild(enemyNode)
        self.camera?.addChild(allyNode)
        
        let middle = (enemyNode.position.x + allyNode.position.x) / 2
        let buttonWidth = enemyNode.size.width * 1.5
        let buttonHeight = enemyNode.size.height / 8
        
        let label = SKLabelNode(text: "Accept Challenge?")
        label.position = .init(x: middle, y: 150)
        
        let acceptButton = ButtonNode(texture: nil, color: .green, size: .init(width: buttonWidth, height: buttonHeight))
        let declineButton = ButtonNode(texture: nil, color: .red, size: .init(width: buttonWidth, height: buttonHeight))
        
        acceptButton.position = .init(x: middle - (buttonWidth / 2), y: -150)
        declineButton.position = .init(x: middle + (buttonWidth / 2), y: -150)
        
        self.camera?.addChild(acceptButton)
        self.camera?.addChild(declineButton)
        self.camera?.addChild(label)
        
        acceptButton.action = {
            [weak self] () in
            
            acceptButton.removeFromParent()
            declineButton.removeFromParent()
            label.removeFromParent()
            enemyNode.removeFromParent()
            allyNode.removeFromParent()
            
            self!.view!.presentScene(BattleScene(size: self!.size,
                                                 attackingUnits: challengerUnits,
                                                 defendingUnits: province.getCurrentUnits(),
                                                 returnScene: self!,
                                                 province: province))
        }
        
        
        declineButton.action = {
            [weak self] () in
            
            acceptButton.removeFromParent()
            declineButton.removeFromParent()
            label.removeFromParent()
            enemyNode.removeFromParent()
            allyNode.removeFromParent()
            
            challenger.gainProvince(newProvince: province)
            
            self!.enemyTurn()
        }
    }
    
    
    
    
    
    
    deinit {
        print("OverworldScene Deinit")
    }
    
}


