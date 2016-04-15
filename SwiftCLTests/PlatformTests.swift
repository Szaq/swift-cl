//
//  PlatformTests.swift
//  SwiftCL
//
//  Created by Łukasz Kwoska on 15/04/16.
//  Copyright © 2016 Spinal Development. All rights reserved.
//

import XCTest
import SwiftCL

class PlatformTests: XCTestCase {

  func testListPlatformIDs() {
    XCTAssertGreaterThan(try Platform.listIDs().count, 0)
  }
  
  func testListPlatforms() {
    XCTAssertGreaterThan(try Platform.list().count, 0)
  }
}
