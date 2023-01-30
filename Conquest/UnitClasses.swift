//
//  UnitClasses.swift
//  Test
//
//  Created by Marvin Fishingpole on 11/20/21.
//

import Foundation


/*case hp = 0
case strength = 1
case speed = 2
case evasion = 3
case precision = 4
case defense = 5
case movement = 6
case fortune = 7*/






public enum UnitClass: Listable, CaseIterable {
    
    case swordsman, trainee
    
    
    public func getStats() -> [Int] {
        switch self {
        case .swordsman:
            return [40, 60, 40, 30, 50, 30, 0, 0]
            
        case .trainee:
            return [40, 40, 30, 30, 40, 30, 0, 0]
            
            
        }
    }
    
    public func getListName() -> String {
        switch self {
        case .trainee:
            return "Trainee"
        case .swordsman:
            return "Swordsman"
        }
    }
    
    
    
    
    
}








