//
//  Leader.swift
//  Game
//
//  Created by Marvin Fishingpole on 5/14/21.
//  Copyright © 2021 None. All rights reserved.
//

import Foundation
import SpriteKit


public class Leader {
    
    private var money:Int = 0
    private var currentUnits:[Unit]
    private var currentProvinces:[Province]
    private var inventory:[UnitWeapon] = []
    public var color:UIColor
    
    public var player:Bool
    
    
    init(units: [Unit], provinces: [Province], color: UIColor, player: Bool) {
        self.currentUnits = units
        self.currentProvinces = provinces
        self.color = color
        self.player = player
    }
    
    public func getMoney() -> Int {
        return self.money
    }
    
    public func addMoney(amount: Int) {
        self.money += amount
    }
    
    public func deductMoney(amount:Int) {
        self.money -= amount
    }
    
    
    public func getCurrentUnits() -> [Unit] {
        return self.currentUnits
    }
    
    public func getAvailableUnits() -> [Unit] {
        var au:[Unit] = []
        
        for unit in currentUnits {
            if !unit.hasActedThisMonth() {au.append(unit)}
        }
        return au
    }
    
    public func newMonth() {
        for unit in currentUnits {
            unit.newDay()
        }
    }
    
    
    
    public func getProvinces() -> [Province] {
        return self.currentProvinces
    }
    
    public func gainProvince(newProvince:Province) {
        
        newProvince.getOwner()?.loseProvince(lostProvince: newProvince)
        
        self.currentProvinces.append(newProvince)
        newProvince.setOwner(newOwner: self)

    }
    
    public func loseProvince(lostProvince:Province) {
        
        if let i = self.currentProvinces.firstIndex(of: lostProvince) {
            self.currentProvinces.remove(at: i)
        }
    }
    
    
    public func addUnit(newUnit: Unit, province: Province) {
        self.currentUnits.append(newUnit)
        newUnit.setLeader(leader: self)
        province.stationUnit(newUnit: newUnit)
    }
    
    public func removeUnit(unit: Unit) {
        
        if self.currentUnits.contains(unit) {
            let pos = self.currentUnits.firstIndex(of: unit)!
            self.currentUnits.remove(at: pos)
            
        } else {
            print("Unit not belonging to province from which it was removed")
        }
    }
    
    
    
    
    public func transferDefeatedUnits(defeatedProvince: Province) {
        
        var provinceUnits = defeatedProvince.getCurrentUnits()
        
        if self.player {
            
            
        } else {
            
            for province in self.currentProvinces {
                
                if province === defeatedProvince { continue }
                
                while !province.isFull() && !provinceUnits.isEmpty {
                    
                    province.stationUnit(newUnit: provinceUnits.first!)
                    provinceUnits.removeFirst()
                }
            }
            
            if !provinceUnits.isEmpty {
                
                for unit in provinceUnits {
                    unit.unitLetGo()
                }
            }
        }
    }
    
    
    
    
    
    
    public func addWeapon(newWeapon: UnitWeapon) {
        self.inventory.append(newWeapon)
    }
    
    
    
    
    
    deinit {
        print("Leader Deinit")
    }
    
}


