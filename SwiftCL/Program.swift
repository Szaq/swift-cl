//
//  Program.swift
//  ReceiptRecognizer
//
//  Created by Lukasz Kwoska on 25/11/14.
//  Copyright (c) 2014 Spinal Development. All rights reserved.
//

import Foundation
import OpenCL

public enum CompilationType {
  case None
  case Compile
  case CompileAndLink
}

/**
*  OpenCL Program
*/
public class Program {
  
  public struct BuildInfo {
    let buildStatus: cl_build_status
    let options: String
    let buildLog: String
    let binaryType: cl_program_binary_type
  }
  
  public let id: cl_program
  
  public init(id: cl_program) {
    self.id = id
  }
  
  public init?(
    context: Context,
    sources:[String],
    compilationType: CompilationType = .CompileAndLink,
    errorHandler: ((cl_int, String) -> Void)? = nil
    ) {
    var result: cl_int = 0
    
    var sourceStrings = [UnsafePointer<Int8>]()
    var sourceLengths = [size_t]()
    
    for source: NSString in sources {
      sourceStrings.append(source.UTF8String)
      sourceLengths.append(size_t(source.length))
    }
    
    id = clCreateProgramWithSource(context.id, cl_uint(sources.count), &sourceStrings, &sourceLengths, &result)
    if result != CL_SUCCESS {
      if let handler = errorHandler {
        handler(result, "Failed to create Program")
      }
      return nil
    }
    
    if compilationType != .None {
      if !self.compile(devices: nil, headers: nil, errorHandler) {
        return nil
      }
    }
    
    if compilationType == .CompileAndLink {
      if let newID = linkPrograms(context, [self], options:nil, devices: nil, errorHandler:errorHandler) {
        id = newID.id
      }
      else {
        return nil
      }
    }
  }
  
  convenience public init?(
    context: Context,
    path: String,
    compilationType: CompilationType = .CompileAndLink,
    errorHandler: ((cl_int, String) -> Void)? = nil
    ) {
      
      if let source = String(contentsOfFile: path) {
        self.init(context:context, sources:[source], compilationType:compilationType, errorHandler:errorHandler)
      }
      else {
        if let handler = errorHandler {
          handler(-1, "Failed to read file \(path)")
        }

        self.init(id: nil)
        return nil
      }
  }

  convenience public init?(
    context: Context,
    loadFromResource fileName: String,
    inBundle bundle: NSBundle,
    compilationType: CompilationType = .CompileAndLink,
    errorHandler: ((cl_int, String) -> Void)? = nil
    ) {
      if let path = bundle.pathForResource(fileName.stringByDeletingPathExtension, ofType: fileName.pathExtension) {
        if let source = String(contentsOfFile: path) {
          self.init(context:context, sources:[source], compilationType:compilationType, errorHandler:errorHandler)
          return
        }
        else {
          if let handler = errorHandler {
            handler(-1, "Failed to read file \(path)")
          }
        }
      }
      else {
        if let handler = errorHandler {
          handler(-1, "Failed to find file \(fileName)")
        }
      }
      self.init(id: nil)
      return nil
  }
  
  
  convenience public init?(
    context: Context,
    loadFromMainBundle fileName: String,
    compilationType: CompilationType = .CompileAndLink,
    errorHandler: ((cl_int, String) -> Void)? = nil
    ) {
      self.init(context: context, loadFromResource:fileName, inBundle: NSBundle.mainBundle(), compilationType: compilationType, errorHandler: errorHandler)
  }


  
  public init?(context:Context, programs:[Program], options: String? = nil, devices:[cl_device_id]? = nil, errorHandler:((cl_int, String) -> Void)? = nil) {
    
    if let newID = linkPrograms(context, programs, options:nil, devices: nil, errorHandler:errorHandler) {
      id = newID.id
    }
    else {
      id = nil
      return nil
    }
  }
  
  
    
  public func compile(devices:[cl_device_id]? = nil, options: String? = nil, headers:[String:Program]? = nil, errorHandler:((cl_int, String) -> Void)? = nil) -> Bool {
    
    let options = Array((options ?? "").nulTerminatedUTF8).map {unsafeBitCast($0, Int8.self)}
    
    let headersNames = headers?.keys.array
    let headersPrograms = headersNames?.map {headers![$0]!.id}
    let headersNamesUTF = headersNames?.map { (name:String) -> UnsafePointer<Int8> in
      let utf8String = Array(name.nulTerminatedUTF8)
      var pointer = UnsafeMutablePointer<UInt8>.alloc(utf8String.count)
      pointer.initializeFrom(utf8String)
      return UnsafePointer<Int8>(pointer)
    }
    

    
    let result = withResolvedPointers(devices, headersNamesUTF, headersPrograms) { (devicesPtr, headersNamesPtr, headersProgramsPtr) -> cl_int in
      
      let haveHeaders = (headersProgramsPtr != nil)
      
      return clCompileProgram(self.id,
        (devicesPtr != nil) ? cl_uint(devices!.count) : 0,
        devicesPtr,
        options,
        haveHeaders ? cl_uint(headersPrograms!.count) : 0,
        headersProgramsPtr,
        UnsafeMutablePointer<UnsafePointer<Int8>>(headersNamesPtr),
        nil, nil)
    }
    
    if result != CL_SUCCESS {
      if let handler = errorHandler {
        if let devices: [cl_device_id] = getInfo(CL_PROGRAM_DEVICES, defValue:nil, errorHandler: { handler($1, "Get devices error.") }) {
          if devices.count > 0 {
            let log: String? = getBuildInfo(CL_PROGRAM_BUILD_LOG, device: devices[0])
            handler(result, log ?? "")
            return false
          }
        }
        
        handler(result, "")
      }
      return false
    }
    
    return true
  }
  
  public func getBuildInfo<T:IntegerLiteralConvertible>(param:Int32, device:cl_device_id, errorHandler:((Int32, cl_device_id, cl_int) -> Void)? = nil) -> T? {
    var t:T = 0
    let result = clGetProgramBuildInfo(id, device, cl_program_build_info(param), size_t(sizeof(T)), &t, nil)
    
    if result != CL_SUCCESS {
      if let handler = errorHandler {
        handler(param, device, result)
      }
      return nil
    }
    
    return t
  }
  
  public func getBuildInfo(param:Int32, device:cl_device_id, errorHandler:((Int32, cl_device_id, cl_int) -> Void)? = nil) -> String? {
    var length: size_t = 0
    let result = clGetProgramBuildInfo(id, device, cl_program_build_info(param), 0, nil, &length)
    if result != CL_SUCCESS {
      if let handler = errorHandler {
        handler(param, device, result)
      }
      return nil
    }
    
    var value = [Int8](count:Int(length), repeatedValue:0)
    let result2 = clGetProgramBuildInfo(id, device, cl_program_build_info(param), length, &value, &length)
    if  result2 != CL_SUCCESS {
      if let handler = errorHandler {
        handler(param, device, result2)
      }
      return nil
    }
    
    return NSString(UTF8String: value)

  }
  
  public func getBuildInfo(device:cl_device_id, errorHandler:((Int32, cl_device_id, cl_int) -> Void)? = nil) -> BuildInfo {
    return BuildInfo(
       buildStatus: getBuildInfo(CL_PROGRAM_BUILD_STATUS, device: device, errorHandler:errorHandler) ?? 0,
      options: getBuildInfo(CL_PROGRAM_BUILD_OPTIONS, device: device, errorHandler:errorHandler) ?? "",
      buildLog: getBuildInfo(CL_PROGRAM_BUILD_LOG, device: device, errorHandler:errorHandler) ?? "",
      binaryType: getBuildInfo(CL_PROGRAM_BINARY_TYPE, device: device, errorHandler:errorHandler) ?? 0
    )
  }
  
  
  
  public func getInfo<T:IntegerLiteralConvertible>(param:Int32, errorHandler:((Int32, cl_int) -> Void)? = nil) -> T? {
    var t:T = 0
    let result = clGetProgramInfo(id, cl_program_build_info(param), size_t(sizeof(T)), &t, nil)
    
    if result != CL_SUCCESS {
      if let handler = errorHandler {
        handler(param, result)
      }
      return nil
    }
    return t
  }
  
  public func getInfo<T:NilLiteralConvertible>(param:Int32, errorHandler:((Int32, cl_int) -> Void)? = nil) -> T? {
    var t:T = nil
    let result = clGetProgramInfo(id, cl_program_build_info(param), size_t(sizeof(T)), &t, nil)
    
    if result != CL_SUCCESS {
      if let handler = errorHandler {
        handler(param, result)
      }
      return nil
    }
    return t
  }
  
  public func getInfo(param:Int32, errorHandler:((Int32, cl_int) -> Void)? = nil) -> String? {
    var length: size_t = 0
    let result = clGetProgramInfo(id, cl_program_info(param), 0, nil, &length)
    if result != CL_SUCCESS {
      if let handler = errorHandler {
        handler(param, result)
      }
      return nil
    }
    
    var value = [Int8](count:Int(length), repeatedValue:0)
    let result2 = clGetProgramInfo(id, cl_program_info(param), length, &value, &length)
    if  result2 != CL_SUCCESS {
      if let handler = errorHandler {
        handler(param, result2)
      }
      return nil
    }
    
    return NSString(UTF8String: value)
  }
  
  public func getInfo<T>(param: Int32, defValue:T, errorHandler: ((Int32, cl_int) -> Void)? = nil) -> [T]? {
    var arraySize: size_t = 0
    let result = clGetProgramInfo(id, cl_program_info(param), UInt(sizeof(T)), nil, &arraySize)
    if  result != CL_SUCCESS {
      if let handler = errorHandler {
        handler(param, result)
      }
      return nil
    }
    
    var array = [T](count: Int(arraySize) / sizeof(T), repeatedValue:defValue)
    let result2 = clGetProgramInfo(id, cl_context_info(param), UInt(arraySize), &array, nil)
    if  result2 != CL_SUCCESS {
      if let handler = errorHandler {
        handler(param, result2)
      }
      return nil
    }
    
    return array
  }

  
  public func getKernelNames(errorHandler:((Int32, cl_int) -> Void)? = nil) -> [String] {
    if let names: String = getInfo(CL_PROGRAM_KERNEL_NAMES, errorHandler:errorHandler) {
      return names.componentsSeparatedByString(";")
    }
    else {
      return [String]()
    }
  }
}

public func linkPrograms(context:Context, programs:[Program], options: String? = nil, devices:[cl_device_id]? = nil, errorHandler:((cl_int, String) -> Void)? = nil) -> Program? {
  let programIDs = programs.map {$0.id}
  let options = Array((options ?? "").nulTerminatedUTF8).map{unsafeBitCast($0, Int8.self)}
  
  let contextDevices = context.getInfo().deviceIDs
  
  var result: cl_int = 0
  var newID: cl_program
  if let devices = devices {
    newID = clLinkProgram(context.id, cl_uint(devices.count), devices, options, cl_uint(programIDs.count), programIDs, nil, nil, &result)
  }
  else {
    newID = clLinkProgram(context.id, 0, nil, options, cl_uint(programIDs.count), programIDs, nil, nil, &result)
  }
  if result != CL_SUCCESS {
    let buildInfo = Program(id: newID).getBuildInfo(contextDevices[0])
    if let handler = errorHandler {
      handler(result, buildInfo.buildLog)
    }
    return nil
  }
  return Program(id:newID)
}
