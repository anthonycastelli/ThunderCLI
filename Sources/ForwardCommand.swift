//
//  ForwardCommand.swift
//  FlockCLI
//
//  Created by Jake Heiser on 10/26/16.
//
//

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

import Foundation
import SwiftCLI
import PathKit

class ForwardCommand: ThunderCommand {
    
    let name = ""
    let shortDescription = ""
    
    let optional = OptionalCollectedParameter()
    
    func execute() throws {
        try guardThunderIsInitialized()
        
        let result = Builder.build()
        if result == false {
            throw CLIError.error("Error: Thunder must be successfully built before tasks can be run".red)
        }
        
        execv(Path.executable.description, CommandLine.unsafeArgv)
    }
    
}
