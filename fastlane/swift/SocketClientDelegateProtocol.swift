//
//  SocketClientDelegateProtocol.swift
//  FastlaneSwiftRunner
//
//  Created by Joshua Liebowitz on 8/12/17.
//  Copyright © 2017 Joshua Liebowitz. All rights reserved.
//

import Foundation

protocol SocketClientDelegateProtocol: class {
    func connectionsOpened()
    func connectionsClosed()
    func commandExecuted(serverResponse: SocketClientResponse)
}

// Please don't remove the lines below
// They are used to detect outdated files
// FastlaneRunnerAPIVersion [0.9.1]
