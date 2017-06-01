import Darwin
import SwiftCLI

CLI.setup(name: "thunder", version: "1.0.0")

CLI.router = ThunderRouter()
CLI.versionCommand = VersionCommand()
CLI.helpCommand = HelpCommand()

CLI.register(command: InitCommand())
CLI.register(command: BuildCommand())
CLI.register(command: UpdateCommand())
CLI.register(command: PullCommand())
CLI.register(command: CleanCommand())
CLI.register(command: CleanAllCommand())
CLI.register(command: AddEnvironmentCommand())
CLI.register(command: CreateTaskCommand())

CommandAliaser.alias(from: "help", to: "--help")
CommandAliaser.alias(from: "-h", to: "--help")
CommandAliaser.alias(from: "-v", to: "--version")

exit(CLI.go())
