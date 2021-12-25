// SocketClientDelegateProtocol.swift
// Copyright (c) 2021 FastlaneTools

//
//  ** NOTE **
//  This file is provided by fastlane and WILL be overwritten in future updates
//  If you want to add extra functionality to this project, create a new file in a
//  new group so that it won't be marked for upgrade
//

import Foundation

protocol SocketClientDelegateProtocol: class {
    func connectionsOpened()
    func connectionsClosed()
    func commandExecuted(serverResponse: SocketClientResponse, completion: (SocketClient) -> Void)
}

// Please don't remove the lines below
// They are used to detect outdated files
// FastlaneRunnerAPIVersion [0.9.2]
