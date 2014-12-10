//
//  Event.swift
//  ReceiptRecognizer
//
//  Created by Lukasz Kwoska on 28/11/14.
//  Copyright (c) 2014 Spinal Development. All rights reserved.
//

import Foundation
import OpenCL

public class Event {
  private(set) var id: cl_event?
  public init() {
    
  }
  
  public func set(id: cl_event) {
    self.id = id
  }
}