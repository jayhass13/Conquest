//
//  Extensions.swift
//  Test
//
//  Created by Marvin Fishingpole on 8/22/22.
//

import Foundation
import SpriteKit

extension SKNode {
    
    func run(action: SKAction!, withKey: String!, optionalCompletion:(() -> Void)?) {
            if let completion = optionalCompletion
            {
                let completionAction = SKAction.run(completion)
                let compositeAction = SKAction.sequence([ action, completionAction ])
                self.run(compositeAction, withKey: withKey )
            }
            else
            {
                self.run( action, withKey: withKey )
            }
    }
}



