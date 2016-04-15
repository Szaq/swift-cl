//
//  Kernel.swift
//  ReceiptRecognizer
//
//  Created by Lukasz Kwoska on 28/11/14.
//  Copyright (c) 2014 Spinal Development. All rights reserved.
//

import Foundation
import OpenCL


public class Kernel {
  
  public class Prepared {
    public let id: cl_kernel
    
    public init(id: cl_kernel) {
      self.id = id
    }
  }
  
  let id: cl_kernel
  
  public init(id:cl_kernel) {
    self.id = id
  }
  
  public init (program: Program, name: String) throws {
    var status: cl_int = 0
    id = clCreateKernel(program.id, Array(name.nulTerminatedUTF8).map {unsafeBitCast($0, Int8.self)}, &status)
    try CLError.check(status)
  }
  
  public func setArgs<A, B, C, D, E, F, G, H, I>(a:A, _ b:B, _ c:C, _ d:D, _ e:E, _ f:F, _ g:G, _ h:H, i: I) throws -> Prepared {
    
    try setArg(cl_uint(0), a)
    try setArg(cl_uint(1), b)
    try setArg(cl_uint(2), c)
    try setArg(cl_uint(3), d)
    try setArg(cl_uint(4), e)
    try setArg(cl_uint(5), f)
    try setArg(cl_uint(6), g)
    try setArg(cl_uint(7), h)
    try setArg(cl_uint(8), i)
    
    return Prepared(id:id)
  }
  
  public func setArgs<A, B, C, D, E, F, G, H>(a:A, _ b:B, _ c:C, _ d:D, _ e:E, _ f:F, _ g:G, _ h:H) throws -> Prepared {
    
    try setArg(cl_uint(0), a)
    try setArg(cl_uint(1), b)
    try setArg(cl_uint(2), c)
    try setArg(cl_uint(3), d)
    try setArg(cl_uint(4), e)
    try setArg(cl_uint(5), f)
    try setArg(cl_uint(6), g)
    try setArg(cl_uint(7), h)
    
    return Prepared(id:id)
  }
  
  public func setArgs<A, B, C, D, E, F, G>(a:A, _ b:B, _ c:C, _ d:D, _ e:E, _ f:F, _ g:G) throws -> Prepared {
    
    try setArg(cl_uint(0), a)
    try setArg(cl_uint(1), b)
    try setArg(cl_uint(2), c)
    try setArg(cl_uint(3), d)
    try setArg(cl_uint(4), e)
    try setArg(cl_uint(5), f)
    try setArg(cl_uint(6), g)
    
    return Prepared(id:id)
  }
  
  public func setArgs<A, B, C, D, E, F>(a:A, _ b:B, _ c:C, _ d:D, _ e:E, _ f:F) throws -> Prepared {
    
    try setArg(cl_uint(0), a)
    try setArg(cl_uint(1), b)
    try setArg(cl_uint(2), c)
    try setArg(cl_uint(3), d)
    try setArg(cl_uint(4), e)
    try setArg(cl_uint(5), f)
    
    return Prepared(id:id)
  }
  
  public func setArgs<A, B, C, D, E>(a:A, _ b:B, _ c:C, _ d:D, _ e:E) throws -> Prepared {
    
    try setArg(cl_uint(0), a)
    try setArg(cl_uint(1), b)
    try setArg(cl_uint(2), c)
    try setArg(cl_uint(3), d)
    try setArg(cl_uint(4), e)
    
    return Prepared(id:id)
  }
  
  public func setArgs<A, B, C, D>(a:A, _ b:B, _ c:C, _ d:D) throws -> Prepared {
    
    try setArg(cl_uint(0), a)
    try setArg(cl_uint(1), b)
    try setArg(cl_uint(2), c)
    try setArg(cl_uint(3), d)
    
    return Prepared(id:id)
  }
  
  public func setArgs<A, B, C>(a:A, _ b:B, _ c:C) throws -> Prepared {
    
    try setArg(cl_uint(0), a)
    try setArg(cl_uint(1), b)
    try setArg(cl_uint(2), c)
    
    return Prepared(id:id)
  }
  
  public func setArgs<A, B>(a:A, _ b:B) throws -> Prepared {
    
    try setArg(cl_uint(0), a)
    try setArg(cl_uint(1), b)
    
    return Prepared(id:id)
  }
  
  public func setArgs<A>(a:A) throws -> Prepared {
    
    try setArg(cl_uint(0), a)
    
    return Prepared(id:id)
  }
  
  private func setArg<T>(idx: cl_uint, _ arg:T) throws {
    if let arg = arg as? Memory {
      return try setArg(idx, arg)
    }
    
    var argCopy = arg
    try CLError.check(clSetKernelArg(id, idx, size_t(sizeof(T)), &argCopy))
  }
  
  private func setArg(idx: cl_uint, _ arg:Memory) throws {
    var argCopy = arg.id
    try CLError.check(clSetKernelArg(id, idx, size_t(sizeof(cl_mem)), &argCopy))
  }
  
}