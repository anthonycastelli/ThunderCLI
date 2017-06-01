//
//  Paths.swift
//  FlockCLI
//
//  Created by Jake Heiser on 10/26/16.
//
//

import PathKit

extension Path {
    static let deployDirectory = Path("config/deploy")
    static let thunderDirectory = Path(".thunder")
    static let packagesDirectory = thunderDirectory + "Packages"
    static let buildDirectory = thunderDirectory + ".build"
    
    static let packageFile = thunderDirectory + "Package.swift"
    static let dependenciesFile = deployDirectory + "ThunderDependencies.json"
    static let mainFile = thunderDirectory + "main.swift"
    static let thunderfile = Path("Thunderfile")
    
    static let executable = buildDirectory + "debug/thunderfile"
}

func createDirectory(at path: Path) throws {
    log(action: "create", description: path.description)
    try path.mkpath()
}

func write(contents: String, to path: Path) throws {
    log(action: "write", description: path.description)
    try path.write(contents)
}

func createLink(at new: Path, pointingTo existing: Path, logPath: Path) throws {
    log(action: "link", description: "\(logPath.description) -> \(new.description)")
    try new.symlink(existing)
}

func createEnvironment(with creator: EnvironmentCreator) throws {
    log(action: "env", description: creator.env)
    try creator.create()
}

private func log(action: String, description: String) {
    var paddedAction =  ""
    for _ in 0..<(12 - action.characters.count) {
        paddedAction.append(" ")
    }
    paddedAction.append(action)
    print("\(paddedAction.magenta)   \(description)")
}
