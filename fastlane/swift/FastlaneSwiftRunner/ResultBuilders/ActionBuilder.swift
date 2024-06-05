//
//  ActionBuilder.swift
//  FastlaneRunner
//
//  Created by Desislava Dimitrova on 5.06.24.
//  Copyright © 2024 Joshua Liebowitz. All rights reserved.
//

import Foundation

@resultBuilder
public struct ActionBuilder {
    public static func buildBlock(_ text: String) -> String {
        return text
    }
    
    public static func buildBlock(_ text: String) -> LaneAction {
        IncrementBuildNumber {
            text
        }
    }
}
