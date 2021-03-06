//
//  Buffer.swift
//  ReceiptRecognizer
//
//  Created by Lukasz Kwoska on 04/12/14.
//  Copyright (c) 2014 Spinal Development. All rights reserved.
//

import Foundation
import OpenCL

public class Buffer<T : IntegerLiteralConvertible>: Memory {
  public private(set) var objects: [T]
  
  public init(context:Context, count:Int, readOnly: Bool = false) throws {
   
    let flags = readOnly ? CL_MEM_READ_ONLY : CL_MEM_READ_WRITE
    
    objects = [T](count:count, repeatedValue:0)
    try super.init(context: context, flags: flags, size: UInt(sizeof(T) * count), hostPtr: &objects)
  }

  public init(context:Context, copyFrom:[T], readOnly: Bool = false) throws {
    
    let flags = CL_MEM_USE_HOST_PTR | (readOnly ? CL_MEM_READ_ONLY : CL_MEM_READ_WRITE)
    objects = copyFrom
    
    try super.init(context: context, flags: flags, size: UInt(sizeof(T) * objects.count), hostPtr: &objects)
  }
}