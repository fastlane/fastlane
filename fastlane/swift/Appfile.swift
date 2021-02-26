// Appfile.swift
// Copyright (c) 2021 FastlaneTools

var appIdentifier: String { return "" } // The bundle identifier of your app
var appleID: String { return "" } // Your Apple email address

var teamID: String { return "" } // Developer Portal Team ID
var itcTeam: String? { return nil } // App Store Connect Team ID (may be nil if no team)

// you can even provide different app identifiers, Apple IDs and team names per lane:
// More information: https://docs.fastlane.tools/advanced/#appfile

// Please don't remove the lines below
// They are used to detect outdated files
// FastlaneRunnerAPIVersion [0.9.1]
