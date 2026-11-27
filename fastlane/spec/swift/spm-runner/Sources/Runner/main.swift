// main.swift
// Copyright (c) 2026 FastlaneTools

import Fastlane
import Foundation

class Fastfile: LaneFile {
    /// Records whether fastlane ran through `bundle exec`
    func recordLane() {
        sh(command: "echo \"bundler=${BUNDLE_BIN_PATH:-none}\" > \(ProcessInfo.processInfo.environment["SPM_RUNNER_MARKER"]!)")
    }

    /// Fails, so the runner's exit status can be checked
    func failLane() {
        sh(command: "exit 3")
    }
}

Main().run(with: Fastfile())
