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
  
  public init?(program: Program, name: String, errorHandler: ((cl_int) -> Void)? = nil) {
    var result: cl_int = 0
    id = clCreateKernel(program.id, Array(name.nulTerminatedUTF8).map {unsafeBitCast($0, Int8.self)}, &result)
    if result != CL_SUCCESS {
      if let handler = errorHandler {
        handler(result)
      }
      return nil
    }
  }
  
  public func setArgs<A>(a:A, errorHandler:((cl_int) -> Void)? = nil) -> Prepared? {
    if !setArg(0, a, errorHandler) {
      return nil
    }
    
    return Prepared(id:id)
  }

  public func setArgs<A, B>(a:A, _ b:B, errorHandler:((cl_int) -> Void)? = nil) -> Prepared? {
    if !setArg(0, a, errorHandler) {
      return nil
    }

    if !setArg(1, b, errorHandler) {
      return nil
    }

    return Prepared(id:id)
  }
  
  public func setArgs<A, B, C>(a:A, _ b:B, _ c:C, errorHandler:((cl_int) -> Void)? = nil) -> Prepared? {
    if !setArg(cl_uint(0), a, errorHandler) {
      return nil
    }
    
    if !setArg(cl_uint(1), b, errorHandler) {
      return nil
    }
    
    if !setArg(cl_uint(2), c) {
      return nil
    }
    
    return Prepared(id:id)
  }
  
  public func setArgs<A, B, C, D>(a:A, _ b:B, _ c:C, _ d:D, errorHandler:((cl_int) -> Void)? = nil) -> Prepared? {
    if !setArg(cl_uint(0), a, errorHandler) {
      return nil
    }
    
    if !setArg(cl_uint(1), b, errorHandler) {
      return nil
    }
    
    if !setArg(cl_uint(2), c) {
      return nil
    }
    
    if !setArg(cl_uint(3), d) {
      return nil
    }
    
    return Prepared(id:id)
  }
  
  public func setArgs<A, B, C, D, E>(a:A, _ b:B, _ c:C, _ d:D, _ e:E,
    errorHandler:((cl_int) -> Void)? = nil) -> Prepared? {
      if !setArg(cl_uint(0), a, errorHandler) {
        return nil
      }
      
      if !setArg(cl_uint(1), b, errorHandler) {
        return nil
      }
      
      if !setArg(cl_uint(2), c) {
        return nil
      }
      
      if !setArg(cl_uint(3), d) {
        return nil
      }
      
      if !setArg(cl_uint(4), e) {
        return nil
      }
      
      return Prepared(id:id)
  }
  
  public func setArgs<A, B, C, D, E, F>(a:A, _ b:B, _ c:C, _ d:D, _ e:E, _ f:F,
    errorHandler:((cl_int) -> Void)? = nil) -> Prepared? {
      if !setArg(cl_uint(0), a, errorHandler) {
        return nil
      }
      
      if !setArg(cl_uint(1), b, errorHandler) {
        return nil
      }
      
      if !setArg(cl_uint(2), c) {
        return nil
      }
      
      if !setArg(cl_uint(3), d) {
        return nil
      }
      
      if !setArg(cl_uint(4), e) {
        return nil
      }
      
      if !setArg(cl_uint(5), f) {
        return nil
      }
      
      return Prepared(id:id)
  }

  public func setArgs<A, B, C, D, E, F, G>(a:A, _ b:B, _ c:C, _ d:D, _ e:E, _ f:F, _ g:G,
    errorHandler:((cl_int) -> Void)? = nil) -> Prepared? {
      if !setArg(cl_uint(0), a, errorHandler) {
        return nil
      }
      
      if !setArg(cl_uint(1), b, errorHandler) {
        return nil
      }
      
      if !setArg(cl_uint(2), c) {
        return nil
      }
      
      if !setArg(cl_uint(3), d) {
        return nil
      }
      
      if !setArg(cl_uint(4), e) {
        return nil
      }
      
      if !setArg(cl_uint(5), f) {
        return nil
      }
      
      if !setArg(cl_uint(6), g) {
        return nil
      }
      
      return Prepared(id:id)
  }
  
  public func setArgs<A, B, C, D, E, F, G, H>(a:A, _ b:B, _ c:C, _ d:D, _ e:E, _ f:F, _ g:G, _ h:H,
    errorHandler:((cl_int) -> Void)? = nil) -> Prepared? {
      if !setArg(cl_uint(0), a, errorHandler) {
        return nil
      }
      
      if !setArg(cl_uint(1), b, errorHandler) {
        return nil
      }
      
      if !setArg(cl_uint(2), c) {
        return nil
      }
      
      if !setArg(cl_uint(3), d) {
        return nil
      }
      
      if !setArg(cl_uint(4), e) {
        return nil
      }
      
      if !setArg(cl_uint(5), f) {
        return nil
      }
      
      if !setArg(cl_uint(6), g) {
        return nil
      }
      
      if !setArg(cl_uint(7), h) {
        return nil
      }

      return Prepared(id:id)
  }
  
  public func setArgs<A, B, C, D, E, F, G, H, I>(a:A, _ b:B, _ c:C, _ d:D, _ e:E, _ f:F, _ g:G, _ h:H, i: I,
    errorHandler:((cl_int) -> Void)? = nil) -> Prepared? {
    if !setArg(cl_uint(0), a, errorHandler) {
      return nil
    }
    
    if !setArg(cl_uint(1), b, errorHandler) {
      return nil
    }
    
    if !setArg(cl_uint(2), c) {
      return nil
    }
    
    if !setArg(cl_uint(3), d) {
      return nil
    }
    
    if !setArg(cl_uint(4), e) {
      return nil
    }
    
    if !setArg(cl_uint(5), f) {
      return nil
    }
    
    if !setArg(cl_uint(6), g) {
      return nil
    }
    
    if !setArg(cl_uint(7), h) {
      return nil
    }
    
    if !setArg(cl_uint(8), i) {
      return nil
    }
    
    return Prepared(id:id)
  }

  
  private func setArg<T>(idx: cl_uint, _ arg:T, errorHandler:((cl_int) -> Void)? = nil) -> Bool {
    if let arg = arg as? Memory {
      return setArg(idx, arg, errorHandler)
    }
    var argCopy = arg
    let result = clSetKernelArg(id, idx, size_t(sizeof(T)), &argCopy)
    if result != CL_SUCCESS {
      if let handler = errorHandler {
        handler(result)
      }
      return false
    }
    return true
  }
  
  private func setArg(idx: cl_uint, _ arg:Memory, errorHandler:((cl_int) -> Void)? = nil) -> Bool {
    var argCopy = arg.id
    let result = clSetKernelArg(id, idx, size_t(sizeof(cl_mem)), &argCopy)
    if result != CL_SUCCESS {
      if let handler = errorHandler {
        handler(result)
      }
      return false
    }
    return true
  }
  
 }