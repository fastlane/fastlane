import ArgumentParser
import Fastlane

@main
struct Fastlane: ParsableCommand {
  static let configuration = CommandConfiguration(
    abstract: "Peforming fastlane operations.",
    subcommands: [Lane.self]
  )
}

extension Fastlane {
    struct Lane: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Runs the given lane.")
        
        @Argument(help: "The name of a lane to execute.")
        var name: String
        
        @Argument(help: "The parameters.")
        var params: [String] = []
        
        mutating func run() throws {
            Main().run(with: FastFile())
        }
    }
}
