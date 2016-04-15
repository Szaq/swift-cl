//
//  Buffer.swift
//  ReceiptRecognizer
//
//  Created by Lukasz Kwoska on 03/12/14.
//  Copyright (c) 2014 Spinal Development. All rights reserved.
//

import Foundation
import OpenCL

public class Memory {
  public let id: cl_mem
  public let size: UInt
  
  public init(id: cl_mem, hostPtr: UnsafeMutablePointer<Void> = nil) {
    self.id = id
    data = hostPtr
    size = 0
  }
  
  public let data: UnsafeMutablePointer<Void>
  
  public init(context:Context, flags: Int32, size: UInt, hostPtr: UnsafeMutablePointer<Void> = nil) throws {
    
    data = hostPtr
    self.size = size
    let ptr: UnsafeMutablePointer<Void> = ((flags & CL_MEM_USE_HOST_PTR) != 0) ? data : nil
    
    var status: cl_int = 0
    self.id = clCreateBuffer(context.id, cl_mem_flags(flags), Int(size), ptr, &status)
    try CLError.check(status)
  }
}