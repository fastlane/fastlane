//
//  LaneBuilder.swift
//  FastlaneRunner
//
//  Created by Desislava Dimitrova on 5.06.24.
//  Copyright © 2024 Joshua Liebowitz. All rights reserved.
//

import Foundation

@resultBuilder
public struct LaneBuilder {
    public static func buildBlock(_ version: String = "0.0.1", _ actions: LaneAction...) ->  [LaneAction] {
        let incrementBuildNumberAction = IncrementBuildNumber {
            version
        }
        
        return [incrementBuildNumberAction] + actions
    }
    
    public static func buildBlock(_ text: String) -> LaneAction {
        IncrementBuildNumber {
            text
        }
    }
}
