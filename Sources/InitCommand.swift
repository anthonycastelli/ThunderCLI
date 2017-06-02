//
//  InitCommand.swift
//  FlockCLI
//
//  Created by Jake Heiser on 10/26/16.
//
//

import Foundation
import SwiftCLI
import Rainbow
import PathKit

class InitCommand: ThunderCommand {
  
    let name = "--init"
    let shortDescription = "Initializes Thunder in the current directory"
    
    func execute() throws {
        guard !thunderIsInitialized else {
            throw CLIError.error("Flock has already been initialized".red)
        }
        
        try checkExisting()
        
        try createFiles()
        
        build()
        
        try updateGitIgnore()
        
        print("Successfully initialized Thunder!".green)
        
        printInstructions()
    }
    
    func checkExisting() throws {
        for path in [Path.thunderDirectory, Path.thunderfile, Path.packageFile] {
            if path.exists {
                throw CLIError.error("\(path) must not already exist".red)
            }
        }
    }
    
    func createFiles() throws {
        print("Creating Thunder files...".yellow)
        
        let alwaysCreator = EnvironmentCreator(env: "always", defaults: alwaysDefaults())
        let productionCreator = EnvironmentCreator(env: "production", defaults: productionDefaults())
        let stagingCreator = EnvironmentCreator(env: "staging", defaults: stagingDefaults())
        
        guard alwaysCreator.canCreate && productionCreator.canCreate && stagingCreator.canCreate else {
            throw CLIError.error("deploy/Always.swift, deploy/Production.swift, and deploy/Staging.swift must not already exist".red)
        }
        
        // Create files
        
        try createDirectory(at: Path.thunderDirectory)
        try createDirectory(at: Path.deployDirectory)
        
        try write(contents: packageDefault(), to: Path.packageFile)
        try write(contents: dependenciesDefault(), to: Path.dependenciesFile)
        
        try write(contents: flockfileDefault(), to: Path.thunderfile)
        try createLink(at: Path.mainFile, pointingTo: Path("..") + Path.thunderfile, logPath: Path.thunderfile)
        
        try createEnvironment(with: alwaysCreator)
        try createEnvironment(with: productionCreator)
        try createEnvironment(with: stagingCreator)
        
        print("Successfully created Thunder files".green)
    }
    
    func build() {
        print("Downloading and building dependencies...".yellow)
        Builder.build(silent: true)
        print("Successfully downloaded dependencies".green)
    }
    
    func updateGitIgnore() throws {
        print("Adding Thunder files to .gitignore...".yellow)
        
        let appendText = [
            "",
            "# Thunder",
            Path.buildDirectory.description,
            Path.packagesDirectory.description,
            ""
        ].joined(separator: "\n")
        
        let gitIgnorePath = Path(".gitignore")
        
        if gitIgnorePath.exists {
            guard let gitIgnore = OutputStream(toFileAtPath: gitIgnorePath.description, append: true) else {
                throw CLIError.error("Couldn't open .gitignore stream")
            }
            gitIgnore.open()
            gitIgnore.write(appendText, maxLength: appendText.characters.count)
            gitIgnore.close()
        } else {
            try gitIgnorePath.write(appendText)
        }
        
        print("Successfully added Thunder files to .gitignore".green)
    }
    
    func printInstructions() {
        print()
        print("IN ORDER FOR THUNDER TO WORK CORRECTLY".yellow)
        print("Follow these steps:".yellow)
        print("1. Update the required fields in \(Path.deployDirectory)/Always.swift")
        print("2. Add your production and staging servers to \(Path.deployDirectory)/Production.swift and \(Path.deployDirectory)/Staging.swift respectively")
        print()
        print("To add Thunder dependencies:".yellow)
        print("1. Add the url and version of the dependency to \(Path.dependenciesFile)")
        print("2. in your Thunderfile, at the top of the file import your dependency and below add `Thunder.use(Dependency)`")
    }
    
    // MARK: - Defaults
    
    private func packageDefault() -> String {
        return [
            "// Don't change!",
            "",
            "import PackageDescription",
            "import Foundation",
            "",
            "let package = Package(",
            "   name: \"Thunderfile\"",
            ")",
            "",
            "let url = URL(fileURLWithPath: \"../\(Path.dependenciesFile)\")",
            "if let data = try? Data(contentsOf: url),",
            "    let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: [[String: Any]]],",
            "    let dependencies = json[\"dependencies\"] {",
            "    ",
            "    for dependency in dependencies {",
            "        guard let url = dependency[\"url\"] as? String else {",
            "            print(\"Ignoring invalid dependency \\(dependency)\")",
            "            continue",
            "        }",
            "        let dependencyPackage: Package.Dependency",
            "        if let version = dependency[\"version\"] as? String, let packageVersion = Version(version) {",
            "            dependencyPackage = Package.Dependency.Package(url: url, packageVersion)",
            "        } else if let major = dependency[\"major\"] as? Int {",
            "            if let minor = dependency[\"minor\"] as? Int {",
            "                dependencyPackage = Package.Dependency.Package(url: url, majorVersion: major, minor: minor)",
            "            } else {",
            "                dependencyPackage = Package.Dependency.Package(url: url, majorVersion: major)",
            "            }",
            "        } else {",
            "            print(\"Ignoring invalid dependency \\(url)\")",
            "            continue",
            "        }",
            "        package.dependencies.append(dependencyPackage)",
            "    }",
            "}",
            ""
        ].joined(separator: "\n")
    }
  
    private func flockfileDefault() -> String {
      return [
            "import Thunder",
            "",
            "Thunder.configure(.always, with: Always()) // Located at \(Path.deployDirectory)/Always.swift",
            "Thunder.configure(.env(\"production\"), with: Production()) // Located at \(Path.deployDirectory)/Production.swift",
            "Thunder.configure(.env(\"staging\"), with: Staging()) // Located at \(Path.deployDirectory)/Staging.swift",
            "",
            "Thunder.run()",
            ""
        ].joined(separator: "\n")
    }
    
    private func dependenciesDefault() -> String {
        return [
            "{",
            "   \"dependencies\" : [",
            "       {",
            "           \"url\" : \"https://github.com/anthonycastelli/Thunder\",",
            "           \"major\": 1",
            "       }",
            "   ]",
            "}",
            ""
        ].joined(separator: "\n")
    }
    
    private func productionDefaults() -> [String] {
      return [
            "// Config.SSHAuthMethod = .key(\"/path/to/mykey\")",
            "// Servers.add(ip: \"9.9.9.9\", user: \"user\", roles: [.app, .db, .web])"
      ]
    }
    
    private func stagingDefaults() -> [String] {
        return [
            "// Servers.add(SSHHost: \"StagingServer\", roles: [.app, .db, .web])"
        ]
    }
    
    private func alwaysDefaults() -> [String] {
        
        return [
            "// UPDATE THESE VALUES BEFORE USING THUNDER:",
            "Config.projectName = nil",
            "Config.executableName = nil // Same as Config.projectName unless your project is divided into modules",
            "Config.repoURL = nil",
            "",
            "// IF YOU PLAN TO RUN `thunder tools` AS THE ROOT USER BUT `thunder deploy` AS A DEDICATED DEPLOY USER,",
            "// (as you should, see https://github.com/jakeheis/Flock/blob/master/README.md#permissions)",
            "// SET THIS VARIABLE TO THE NAME OF YOUR (ALREADY CREATED) DEPLOY USER BEFORE RUNNING `flock tools`:",
            "// Config.supervisordUser = \"deploy:deploy\"",
            "",
            "// Optional config:",
            "// Config.deployDirectory = \"/home/deploy/www\"",
        ]
    }
  
}
