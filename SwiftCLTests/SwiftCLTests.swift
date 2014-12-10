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
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testContextCreate() {
      if let context = Context(fromType: CL_DEVICE_TYPE_CPU) {
        if let referenceCount: cl_uint = context.getInfo(CL_CONTEXT_REFERENCE_COUNT) {
          XCTAssertEqual(referenceCount, cl_uint(1), "Wrong refence count")
        }
        else {
          XCTFail("Failed to get reference count")
        }
      }
      else {
        XCTFail("Failed to create context")
      }
  }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
