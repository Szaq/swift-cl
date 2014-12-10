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
  
  public init?(context:Context,
    flags: Int32,
    size: UInt,
    hostPtr: UnsafeMutablePointer<Void> = nil,
    errorHandler:((cl_int) -> Void)? = nil) {
      data = hostPtr
      self.size = size
      var result: cl_int = 0
      let ptr: UnsafeMutablePointer<Void> = ((flags & CL_MEM_USE_HOST_PTR) != 0) ? data : nil
      self.id = clCreateBuffer(context.id, cl_mem_flags(flags), size, ptr, &result)
      
      if result != CL_SUCCESS {
        if let handler = errorHandler {
          handler(result)
        }
        return nil
      }
  }
}