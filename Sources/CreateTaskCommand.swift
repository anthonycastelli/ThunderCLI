//
//  CreateTaskCommand.swift
//  FlockCLI
//
//  Created by Jake Heiser on 10/27/16.
//
//

import SwiftCLI
import Rainbow
import PathKit

class CreateTaskCommand: ThunderCommand {
    
    let name = "--create"
    let shortDescription = "Creates a task with the given name"
    
    let taskName = Parameter()
    
    let taskSuffix = "Task"
    
    public func execute() throws {
        var name = taskName.value
        if name.hasSuffix(taskSuffix) {
            name = name.substring(to: name.index(name.endIndex, offsetBy: taskSuffix.characters.count))
        }
        
        let namespace: String?
        if let colonIndex = name.characters.index(of: ":") {
            namespace = name.substring(to: colonIndex)
            name = name.substring(from: name.index(after: colonIndex))
        } else {
            namespace = nil
        }
        
        let namespaceSegment = namespace?.capitalized ?? ""
        let taskSegment = name.capitalized + taskSuffix
        let fileName = namespaceSegment + taskSegment + ".swift"
        let path = Path.deployDirectory + fileName
        if path.exists {
            throw CLIError.error("\(path) already exists".red)
        }
        
        try write(contents: template(for: name, in: namespace), to: path)
        try createLink(at: Path.thunderDirectory + fileName, pointingTo: ".." + path, logPath: path)
        
        print("What's left to do:".yellow)
        print("1. Replace <NameThisGroup> at the top of your new file with a custom name")
        print("2. In your Thunderfile, add `Thunder.use(WhateverINamedIt)`")
    }
    
    func template(for name: String, in namespace: String?) -> String {
        let taskName = name.capitalized + taskSuffix
        var lines = [
            "import Thunder",
            "",
            "extension Thunder {",
            "   public static let <NameThisGroup>: [Task] = [",
            "       \(taskName)()",
            "   ]",
            "}",
            "",
            "// Delete if no custom Config properties are needed",
            "extension Config {",
            "   // public static var myVar = \"\"",
            "}",
            "",
            "class \(taskName): Task {",
            "   let name = \"\(name)\""
        ]
        if let namespace = namespace {
            lines.append("   let namespace = \"\(namespace)\"")
        }
        lines += [
            "",
            "   func run(on server: Server) throws {",
            "      // Do work",
            "   }",
            "}",
            ""
        ]
        return lines.joined(separator: "\n")
    }
    
}
