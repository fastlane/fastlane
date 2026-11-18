// main.swift
// Copyright (c) 2026 FastlaneTools

import Fastlane
import Foundation

class Fastfile: LaneFile {
    /// Records whether fastlane ran through `bundle exec`
    func recordLane() {
        sh(command: "echo \"bundler=${BUNDLE_BIN_PATH:-none}\" > \(ProcessInfo.processInfo.environment["SPM_RUNNER_MARKER"]!)")
    }
}

Main().run(with: Fastfile())
