//
//  AppDelegate.swift
//  SampleSwiftCLApp
//
//  Created by Lukasz Kwoska on 05/12/14.
//  Copyright (c) 2014 Spinal Development. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  @IBOutlet weak var window: NSWindow!


  func applicationDidFinishLaunching(aNotification: NSNotification) {
    // Insert code here to initialize your application
    if let simulation = Simulation() {
      for i in 0..<10 {
        let values = simulation.step()
        println("Values = \(values)")
      }
    }
    
  }

  func applicationWillTerminate(aNotification: NSNotification) {
    // Insert code here to tear down your application
  }


}

