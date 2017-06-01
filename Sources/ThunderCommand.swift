//
//  FlockCommand.swift
//  FlockCLI
//
//  Created by Jake Heiser on 10/26/16.
//
//

import SwiftCLI
import PathKit
import Rainbow

protocol ThunderCommand: Command {}

extension ThunderCommand {
    
    var thunderIsInitialized: Bool {
        return Path.thunderDirectory.exists
    }
    
    func guardThunderIsInitialized() throws {
        if !thunderIsInitialized {
            throw CLIError.error("Thunder has not been initialized in this directory yet - run `thunder --init`".red)
        }
    }
    
}
