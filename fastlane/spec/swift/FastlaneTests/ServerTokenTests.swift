// ServerTokenTests.swift
// Copyright (c) 2026 FastlaneTools

import XCTest
@testable import Fastlane

final class ServerTokenTests: XCTestCase {
    func testCreatesARandomTokenOnlyThisUserCanRead() {
        let first = MainProcess().createServerToken()
        let second = MainProcess().createServerToken()
        defer {
            try? FileManager.default.removeItem(atPath: first.directory)
            try? FileManager.default.removeItem(atPath: second.directory)
        }

        XCTAssertEqual(first.token.count, 64)
        XCTAssertNotEqual(first.token, second.token)
        XCTAssertEqual(try? String(contentsOfFile: first.file, encoding: .utf8), first.token)
        XCTAssertEqual(permissions(first.directory), 0o700)
        XCTAssertEqual(permissions(first.file), 0o600)
    }

    private func permissions(_ path: String) -> Int {
        let attributes = try! FileManager.default.attributesOfItem(atPath: path)
        return (attributes[.posixPermissions] as! NSNumber).intValue
    }
}
