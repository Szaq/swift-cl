//
//  SwiftCLTests.swift
//  SwiftCLTests
//
//  Created by Lukasz Kwoska on 05/12/14.
//  Copyright (c) 2014 Spinal Development. All rights reserved.
//

import Cocoa
import XCTest
import SwiftCL
import OpenCL

class SwiftCLTests: XCTestCase {
  
    func testContextCreate() throws {
      
      let context = try Context(fromType: CL_DEVICE_TYPE_CPU)
      let referenceCount: cl_uint = try context.getInfo(CL_CONTEXT_REFERENCE_COUNT)
      XCTAssertEqual(referenceCount, cl_uint(1), "Wrong refence count")
  }
  
  func testHaveDevices() throws {
    let context = try Context(fromType: CL_DEVICE_TYPE_CPU)
    XCTAssertGreaterThan(try context.getInfo().numDevices, 0)
  }
  
  func testGetInfo() throws {
    let context = try Context(fromType: CL_DEVICE_TYPE_CPU)
    let info = try context.getInfo()
    XCTAssertGreaterThan(info.numDevices, 0)
    XCTAssertEqual(info.deviceIDs.count, Int(info.numDevices))
    XCTAssertEqual(info.properties.count, 0)
  }
}
