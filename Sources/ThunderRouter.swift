//
//  FlockRouter.swift
//  FlockCLI
//
//  Created by Jake Heiser on 10/30/16.
//
//

import SwiftCLI

class ThunderRouter: Router {
    
    func route(commands: [Command], arguments: ArgumentList) -> Command? {
        // Just ran `thunder`
        guard let name = arguments.head else {
            return nil
        }
        
        // Ran something like `thunder --init`
        if let command = commands.first(where: { $0.name == name.value }) {
            arguments.remove(node: name)
            return command
        }
        
        // Ran something like `thunder --notreal`
        if name.value.hasPrefix("-") {
            return nil
        }
        
        // Ran something like `thunder deploy`
        return ForwardCommand()
    }
    
}
