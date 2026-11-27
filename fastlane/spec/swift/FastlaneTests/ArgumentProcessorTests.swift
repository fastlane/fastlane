// ArgumentProcessorTests.swift
// Copyright (c) 2026 FastlaneTools

import XCTest
@testable import Fastlane

final class ArgumentProcessorTests: XCTestCase {
    func testReadsTheLaneAndItsParameters() {
        let processor = ArgumentProcessor(args: ["Runner", "lane", "beta", "notes", "a note", "logMode", "verbose"])

        XCTAssertEqual(processor.currentLane, "beta")
        XCTAssertEqual(processor.laneParameters(), ["notes": "a note"])
    }

    func testReadsTheServerPortAndTimeout() {
        let processor = ArgumentProcessor(args: ["Runner", "lane", "beta", "swiftServerPort", "2345", "timeoutSeconds", "42"])

        XCTAssertEqual(processor.port, 2345)
        XCTAssertEqual(processor.commandTimeout, 42)
    }

    func testDefaultsToPort2000() {
        XCTAssertEqual(ArgumentProcessor(args: ["Runner", "lane", "beta"]).port, 2000)
    }
}
