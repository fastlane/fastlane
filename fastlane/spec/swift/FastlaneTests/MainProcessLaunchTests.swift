// MainProcessLaunchTests.swift
// Copyright (c) 2026 FastlaneTools

import XCTest
@testable import Fastlane

/// How the Swift Package Manager runner chooses the fastlane it starts, and checks its port.
final class MainProcessLaunchTests: XCTestCase {
    private var directory: String!
    private var originalWorkingDirectory: String!
    private let variables = ["FASTLANE_SPM_BIN", "BUNDLE_GEMFILE"]
    private var originalVariables: [String: String] = [:]

    override func setUp() {
        super.setUp()
        directory = (NSTemporaryDirectory() as NSString).appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(atPath: directory + "/project/sub/deeper", withIntermediateDirectories: true, attributes: nil)
        // Resolve /var to /private/var so paths compare equal to currentDirectoryPath
        let resolved = realpath(directory, nil)!
        directory = String(cString: resolved)
        free(resolved)
        originalWorkingDirectory = FileManager.default.currentDirectoryPath
        for name in variables {
            originalVariables[name] = ProcessInfo.processInfo.environment[name]
            unsetenv(name)
        }
    }

    override func tearDown() {
        FileManager.default.changeCurrentDirectoryPath(originalWorkingDirectory)
        for name in variables {
            if let value = originalVariables[name] {
                setenv(name, value, 1)
            } else {
                unsetenv(name)
            }
        }
        try? FileManager.default.removeItem(atPath: directory)
        super.tearDown()
    }

    private func createFile(_ path: String, executable: Bool = false) {
        FileManager.default.createFile(atPath: directory + "/" + path, contents: Data(), attributes: [.posixPermissions: executable ? 0o755 : 0o644])
    }

    func testFindsTheGemfileFromASubdirectory() {
        createFile("project/Gemfile")
        FileManager.default.changeCurrentDirectoryPath(directory + "/project/sub/deeper")

        XCTAssertEqual(MainProcess().bundleRootDirectory(), directory + "/project")
        XCTAssertEqual(MainProcess().fastlaneLaunchArguments(), ["bundle", "exec", "fastlane"])
    }

    func testFindsGemsRb() {
        createFile("project/gems.rb")
        FileManager.default.changeCurrentDirectoryPath(directory + "/project/sub")

        XCTAssertEqual(MainProcess().bundleRootDirectory(), directory + "/project")
    }

    func testUsesTheBinstubNextToTheGemfile() throws {
        try FileManager.default.createDirectory(atPath: directory + "/project/bin", withIntermediateDirectories: true, attributes: nil)
        createFile("project/Gemfile")
        createFile("project/bin/fastlane", executable: true)
        FileManager.default.changeCurrentDirectoryPath(directory + "/project/sub")

        XCTAssertEqual(MainProcess().fastlaneLaunchArguments(), [directory + "/project/bin/fastlane"])
    }

    func testPrefersBundleGemfile() {
        createFile("project/Gemfile")
        FileManager.default.changeCurrentDirectoryPath(directory + "/project/sub")
        setenv("BUNDLE_GEMFILE", directory + "/elsewhere/Gemfile", 1)

        XCTAssertEqual(MainProcess().bundleRootDirectory(), directory + "/elsewhere")
    }

    func testResolvesARelativeBundleGemfileFromTheWorkingDirectory() {
        FileManager.default.changeCurrentDirectoryPath(directory + "/project")
        setenv("BUNDLE_GEMFILE", "sub/Gemfile", 1)

        XCTAssertEqual(MainProcess().bundleRootDirectory(), directory + "/project/sub")
    }

    func testUsesFastlaneOnThePathWithoutAGemfile() {
        FileManager.default.changeCurrentDirectoryPath(directory + "/project/sub")

        XCTAssertNil(MainProcess().bundleRootDirectory())
        XCTAssertEqual(MainProcess().fastlaneLaunchArguments(), ["fastlane"])
    }

    func testLetsTheShellSplitFastlaneSpmBin() {
        setenv("FASTLANE_SPM_BIN", "'/path with spaces/fastlane'", 1)

        XCTAssertEqual(MainProcess().fastlaneLaunchArguments(), ["/bin/sh", "-c", "exec '/path with spaces/fastlane' \"$@\"", "sh"])
    }

    func testIgnoresABlankFastlaneSpmBin() {
        setenv("FASTLANE_SPM_BIN", "   ", 1)
        FileManager.default.changeCurrentDirectoryPath(directory + "/project")

        XCTAssertEqual(MainProcess().fastlaneLaunchArguments(), ["fastlane"])
    }

    func testSeesAPortHeldOnEitherLocalhostAddress() {
        for family in [AF_INET, AF_INET6] {
            let (listener, port) = listen(family: family)
            XCTAssertTrue(MainProcess().isAddressInUse(family: family, port: port), "family \(family)")
            close(listener)
            XCTAssertFalse(MainProcess().isAddressInUse(family: family, port: port), "family \(family) after closing")
        }
    }

    /// Listens on a free port of the loopback address of that family, and returns the socket and its port.
    private func listen(family: Int32) -> (Int32, UInt32) {
        let listener = socket(family, SOCK_STREAM, 0)
        var storage = sockaddr_storage()
        var length: socklen_t
        if family == AF_INET {
            var address = sockaddr_in()
            address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
            address.sin_family = sa_family_t(AF_INET)
            address.sin_addr.s_addr = inet_addr("127.0.0.1")
            length = socklen_t(MemoryLayout<sockaddr_in>.size)
            memcpy(&storage, &address, Int(length))
        } else {
            var address = sockaddr_in6()
            address.sin6_len = UInt8(MemoryLayout<sockaddr_in6>.size)
            address.sin6_family = sa_family_t(AF_INET6)
            address.sin6_addr = in6addr_loopback
            length = socklen_t(MemoryLayout<sockaddr_in6>.size)
            memcpy(&storage, &address, Int(length))
        }
        withUnsafeMutablePointer(to: &storage) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { pointer in
                XCTAssertEqual(Darwin.bind(listener, pointer, length), 0)
                XCTAssertEqual(Darwin.listen(listener, 1), 0)
                XCTAssertEqual(getsockname(listener, pointer, &length), 0)
            }
        }
        let port = family == AF_INET
            ? withUnsafePointer(to: &storage) { $0.withMemoryRebound(to: sockaddr_in.self, capacity: 1) { $0.pointee.sin_port } }
            : withUnsafePointer(to: &storage) { $0.withMemoryRebound(to: sockaddr_in6.self, capacity: 1) { $0.pointee.sin6_port } }
        return (listener, UInt32(UInt16(bigEndian: port)))
    }
}
