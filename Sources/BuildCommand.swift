//
//  BuildCommand.swift
//  FlockCLI
//
//  Created by Jake Heiser on 10/26/16.
//
//

import SwiftCLI

class BuildCommand: ThunderCommand {
    
    let name = "--build"
    let shortDescription = "Builds Thunder in the current directory"
    
    func execute() throws {
        try guardThunderIsInitialized()
        
        Builder.build()
    }
    
}

class CleanCommand: ThunderCommand {
    let name = "--clean"
    let shortDescription = "Cleans Thunder's build directory"
    
    func execute() throws {
        try guardThunderIsInitialized()
        
        try Builder.clean()
    }
    
}

class CleanAllCommand: ThunderCommand {
    let name = "--clean-all"
    let shortDescription = "Cleans Thunder's build directory and Packages directory"
    
    func execute() throws {
        try guardThunderIsInitialized()
        
        try Builder.clean(includeDependencies: true)
    }
    
}

class PullCommand: ThunderCommand {
    let name = "--pull"
    let shortDescription = "Debug only; use --update instead"
    
    func execute() throws {
        try guardThunderIsInitialized()
        
        try Builder.pull()
    }
    
}


class UpdateCommand: ThunderCommand {
    let name = "--update"
    let shortDescription = "Updates Thunder's dependencies in the current project"
    
    func execute() throws {
        try guardThunderIsInitialized()
        
        try Builder.update()
    }
    
}
