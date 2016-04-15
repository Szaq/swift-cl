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
  
  private (set) var id: cl_program
  
  public init(id: cl_program) {
    self.id = id
  }
  
  public init(
    context: Context,
    sources:[String],
    compilationType: CompilationType = .CompileAndLink) throws {
    
    var status: cl_int = 0
    
    var sourceStrings = [UnsafePointer<Int8>]()
    var sourceLengths = [size_t]()
    
    for source: NSString in sources {
      sourceStrings.append(source.UTF8String)
      sourceLengths.append(size_t(source.length))
    }
    
    id = clCreateProgramWithSource(context.id, cl_uint(sources.count), &sourceStrings, &sourceLengths, &status)
    try CLError.check(status)
    
    if compilationType != .None {
        try compile()
    }
    
    if compilationType == .CompileAndLink {
      id = try linkPrograms(context, programs: [self], options:nil, devices: nil).id
    }
  }
  
  convenience public init?(
    context: Context,
    path: String,
    compilationType: CompilationType = .CompileAndLink) throws {
    
    let source = try String(contentsOfFile: path)
    try self.init(context:context, sources:[source], compilationType:compilationType)
  }

  convenience public init(
    context: Context,
    loadFromResource fileName: String,
    inBundle bundle: NSBundle,
    compilationType: CompilationType = .CompileAndLink) throws {
        let nsFileName = fileName as NSString
        guard let path = bundle.pathForResource(nsFileName.stringByDeletingPathExtension, ofType: nsFileName.pathExtension)
          else {throw CLError.FileNotFound}
    let source = try String(contentsOfFile: path)
    try self.init(context:context, sources:[source], compilationType:compilationType)
  }
  
  
  convenience public init(context: Context,
                          loadFromMainBundle fileName: String,
                          compilationType: CompilationType = .CompileAndLink) throws {
    try self.init(context: context, loadFromResource:fileName, inBundle: NSBundle.mainBundle(), compilationType: compilationType)
  }
  
  
  
  public init(context:Context, programs:[Program], options: String? = nil, devices:[cl_device_id]? = nil) throws {
    id = try linkPrograms(context, programs: programs, options:nil, devices: nil).id
  }
    
  public func compile(devices:[cl_device_id]? = nil, options: String? = nil, headers:[String:Program]? = nil) throws {
    
    let options = Array((options ?? "").nulTerminatedUTF8).map {unsafeBitCast($0, Int8.self)}
    
    let headersNames = headers.map {Array($0.keys)}
    let headersPrograms = headersNames?.map {headers![$0]!.id}
    let headersNamesUTF = headersNames?.map { (name:String) -> UnsafePointer<Int8> in
      let utf8String = Array(name.nulTerminatedUTF8)
      let pointer = UnsafeMutablePointer<UInt8>.alloc(utf8String.count)
      pointer.initializeFrom(utf8String)
      return UnsafePointer<Int8>(pointer)
    }
    

    
    let status = withResolvedPointers(devices, b: headersNamesUTF, c: headersPrograms) { (devicesPtr, headersNamesPtr, headersProgramsPtr) -> cl_int in
      
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
    
    guard status == CL_SUCCESS else {
      let devices:[cl_device_id]? = try? getInfo(CL_PROGRAM_DEVICES, defValue:nil)
      let buildInfo: BuildInfo? = devices?.first.flatMap { return try? self.getBuildInfo($0)}
      throw CLError.BuildError(reason: CLError.fromInt(status), buildInfo: buildInfo)
      }
  }
  
  public func getBuildInfo<T:IntegerLiteralConvertible>(param:Int32, device:cl_device_id) throws -> T {
    var info:T = 0
    try CLError.check(clGetProgramBuildInfo(id, device, cl_program_build_info(param), size_t(sizeof(T)), &info, nil))
    
    return info
  }
  
  public func getBuildInfo(param:Int32, device:cl_device_id) throws -> String {
    var length: size_t = 0
    try CLError.check(clGetProgramBuildInfo(id, device, cl_program_build_info(param), 0, nil, &length))
    
    var value = [CChar](count:Int(length), repeatedValue:0)
    try CLError.check(clGetProgramBuildInfo(id, device, cl_program_build_info(param), length, &value, &length))
    
    guard let infoString = String(UTF8String: value) else {throw CLError.UTF8ConversionError}
    return infoString
  }
  
  public func getBuildInfo(device:cl_device_id) throws -> BuildInfo {
    return BuildInfo(
       buildStatus: try getBuildInfo(CL_PROGRAM_BUILD_STATUS, device: device),
      options: try getBuildInfo(CL_PROGRAM_BUILD_OPTIONS, device: device),
      buildLog: try getBuildInfo(CL_PROGRAM_BUILD_LOG, device: device),
      binaryType: try getBuildInfo(CL_PROGRAM_BINARY_TYPE, device: device)
    )
  }
  
  public func getInfo<T:IntegerLiteralConvertible>(param:Int32) throws -> T {
    var info:T = 0
    try CLError.check(clGetProgramInfo(id, cl_program_build_info(param), size_t(sizeof(T)), &info, nil))
    
    return info
  }
  
  public func getInfo<T:NilLiteralConvertible>(param:Int32) throws -> T {
    var info:T = nil
    try CLError.check(clGetProgramInfo(id, cl_program_build_info(param), size_t(sizeof(T)), &info, nil))
    
    return info
  }
  
  public func getInfo(param:Int32) throws -> String {
    var length: size_t = 0
    try CLError.check(clGetProgramInfo(id, cl_program_info(param), 0, nil, &length))
    
    var value = [CChar](count:Int(length), repeatedValue:0)
    try CLError.check(clGetProgramInfo(id, cl_program_info(param), length, &value, &length))
    
    guard let infoString = String(UTF8String: value) else {throw CLError.UTF8ConversionError}
    return infoString
  }
  
  public func getInfo<T>(param: Int32, defValue:T) throws -> [T] {
    var arraySize: size_t = 0
    try CLError.check(clGetProgramInfo(id, cl_program_info(param), sizeof(T), nil, &arraySize))
    
    var array = [T](count: Int(arraySize) / sizeof(T), repeatedValue:defValue)
    try CLError.check(clGetProgramInfo(id, cl_context_info(param), arraySize, &array, nil))
    
    return array
  }

  
  public func getKernelNames() throws -> [String] {
    let names: String = try getInfo(CL_PROGRAM_KERNEL_NAMES)
    return names.componentsSeparatedByString(";")
  }
}

public func linkPrograms(context:Context, programs:[Program], options: String? = nil, devices:[cl_device_id]? = nil) throws -> Program {
  let programIDs = programs.map {$0.id}
  let options = Array((options ?? "").nulTerminatedUTF8).map{unsafeBitCast($0, Int8.self)}
  
  let contextDevices = try context.getInfo().deviceIDs
  
  var status: cl_int = 0
  var newID: cl_program
  if let devices = devices {
    newID = clLinkProgram(context.id, cl_uint(devices.count), devices, options, cl_uint(programIDs.count), programIDs, nil, nil, &status)
  } else {
    newID = clLinkProgram(context.id, 0, nil, options, cl_uint(programIDs.count), programIDs, nil, nil, &status)
  }
  
  guard status == CL_SUCCESS else {
    let buildInfo = try? Program(id: newID).getBuildInfo(contextDevices[0])
    throw CLError.BuildError(reason: CLError.fromInt(status), buildInfo: buildInfo)
  }
  
  return Program(id:newID)
}
