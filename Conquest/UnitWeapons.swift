//
//  UnitWeapons.swift
//  Test
//
//  Created by Marvin Fishingpole on 10/31/21.
//

import Foundation
import SpriteKit


/*case hp = 0
case strength = 1
case speed = 2
case evasion = 3
case precision = 4
case defense = 5
case movement = 6
case fortune = 7*/


public class UnitWeapon {
    
    private let stats:[Int]
    private let power:Int
    private let range: (Int, Int)
    
    
    public init(power: Int, stats: [Int], range: (Int, Int)) {
        self.stats = stats
        self.power = power
        self.range = range
    }
    
    public func getStat(i: Int) -> Int {
        return self.stats[i]
    }
}

public enum Weapon: Listable, CaseIterable {
    
    case shortsword, longsword, greatsword, dagger, dirk, baselard, shortbow, longbow, greatbow

    public func getBasePower() -> Int {
        switch self {
        case .longsword:
            return 10
        case .shortsword:
            return 8
        case .greatsword:
            return 12
        case .dagger:
            return 4
        case .dirk:
            return 6
        case .baselard:
            return 8
        case .shortbow:
            return 8
        case .longbow:
            return 10
        case .greatbow:
            return 12
        }
        
    }
    
    public func getBaseStats() -> [Int] {
        switch self {
        case .longsword:
            return [20, 20, 30, 30, 20, 0, 0, 0]
        case .shortsword:
            return [10, 10, 20, 20, 10, 0, 0, 0]
        case .greatsword:
            return [30, 30, 40, 40, 30, 20, 0, 0]
        case .dagger:
            return [10, 0, 30, 30, 20, 0, 0, 0]
        case .dirk:
            return [20, 10, 40, 30, 30, 0, 0, 0]
        case .baselard:
            return [20, 20, 50, 50, 50, 0, 0, 0]
        case .shortbow:
            return [10, 20, 20, 0, 30, 0, 0, 0]
        case .longbow:
            return [20, 40, 30, 0, 40, 10, 0, 0]
        case .greatbow:
            return [30, 50, 50, 10, 50, 20, 0, 0]
            
        }
    
    }
    
    public func getRange() -> (Int, Int) {
        
        switch self {
        case .longsword,
         .dagger,
        .shortsword,
        .greatsword,
        .dirk,
        .baselard:
                
            return (1, 1)
            
        case .shortbow,
            .longbow,
            .greatbow:
            return (2, 2)
        }
        
        
    }
    
    public func getListName() -> String {
        switch self {
        case .longsword:
            return "Longsword"
        case .shortsword:
            return "Shortsword"
        case .greatsword:
            return "Greatsword"
        case .dagger:
            return "Dagger"
        case .dirk:
            return "Dirk"
        case .baselard:
            return "Baselard"
        case .shortbow:
            return "Shortbow"
        case .longbow:
            return "Longbow"
        case .greatbow:
            return "Greatbow"
        }
    }
}


public enum armoryWeapons  {
    
    static let level1:[Weapon] = [.dagger, .shortsword, .shortbow]
    static let level2:[Weapon] = [.dagger, .shortsword, .shortbow, .dirk, .longsword, .longbow]
    static let level3:[Weapon] = [.dagger, .shortsword, .shortbow, .dirk, .longsword, .longbow, .baselard, .greatsword, .greatbow]
    
    
}

























