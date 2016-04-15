//
//  Device.swift
//  SwiftCL
//
//  Created by Lukasz Kwoska on 05/12/14.
//  Copyright (c) 2014 Spinal Development. All rights reserved.
//

import Foundation
import OpenCL

public struct Device : CustomStringConvertible {
  
  public struct Vendor {
    let ID: cl_uint
    let name: String
  }
  
  public struct FPConfig {
    let halfPrecision: cl_device_fp_config?
    let singlePrecision: cl_device_fp_config
    let doublePrecision: cl_device_fp_config?
  }
  
  public struct Width {
    let charVector: cl_uint
    let shortVector: cl_uint
    let intVector: cl_uint
    let longVector: cl_uint
    let floatVector: cl_uint
    let doubleVector: cl_uint
  }
  
  public struct GlobalMem {
    let size: cl_ulong
    let cacheLineSize: cl_uint
    let cacheType: cl_device_mem_cache_type
    let cacheSize: cl_ulong
  }
  
  public struct LocalMem {
    let type: cl_device_local_mem_type
    let size: cl_ulong
  }
  
  public struct Image {
    let image3DMaxWidth: size_t
    let image3DMaxHeight: size_t
    let image3DMaxDepth: size_t
    let image2DMaxWidth: size_t
    let image2DMaxHeight: size_t
    let maxBufferSize: size_t
    let maxArraySize: size_t
    let support: cl_bool
  }
  
  public struct Max {
    let workItemSizes: [size_t]
    let workItemDimensions: cl_uint
    let workGroupSize: size_t
    let samplers: cl_uint
    let readImageArgs: cl_uint
    let writeImageArgs: cl_uint
    let parameterSize: size_t
    let memAllocSize: cl_ulong
    let constantBufferSize: cl_ulong
    let constantArgs: cl_uint
    let computeUnits: cl_uint
    let clockFrequency: cl_uint
  }
  
  let name: String
  let vendor: Vendor
  let version: String
  let openCLCVersion: String
  let deviceProfile: String
  let deviceType: cl_device_type
  let available: cl_bool
  let driverVersion: String
  let platformID: cl_platform_id
  let fpConfig: FPConfig
  let queueProperties: cl_command_queue_properties
  let profilingTimerResolution: size_t
  let preferredWidth: Width
  let nativeWidth: Width
  let minDataTypeAlignSize: cl_uint
  let memBaseAddrAlign: cl_uint
  let hostUnifiedMemory: cl_bool
  let max: Max
  let localMem: LocalMem
  let globalMem: GlobalMem
  let image: Image
  let executionCapabilities: cl_device_exec_capabilities
  let errorCorrectionSupport: cl_bool
  let endianLittle: cl_bool
  let compilerAvailable: cl_bool
  let linkerAvailable: cl_bool
  let addressBits: cl_uint
  let buildInKernels: String
  let printfBufferSize: size_t
  let preferredInteropUserSync: cl_bool
  let referenceCount: cl_uint
  let extensions: String
  
  public var description: String {return "\(vendor.name) \(name) (\(version))"}
}


extension Device {

  public static func getInfo<T:IntegerLiteralConvertible>(deviceID:cl_device_id, param: Int32) throws -> T {
    
    var value: T = 0
    try CLError.check(clGetDeviceInfo(deviceID, cl_device_info(param), sizeof(T), &value, nil))
    return value
  }
  
  public static func getInfo<T:NilLiteralConvertible>(deviceID:cl_device_id, param: Int32) throws -> T {
    
    var value: T = nil
    try CLError.check(clGetDeviceInfo(deviceID, cl_device_info(param), sizeof(T), &value, nil))
    return value
  }
  
  public static func getInfo(deviceID:cl_device_id, param: Int32) throws -> String {
    
    var length: Int = 0
    try CLError.check(clGetDeviceInfo(deviceID, cl_device_info(param), sizeof(Int), nil, &length))
    
    var value = [Int8](count:Int(length), repeatedValue:0)
    try CLError.check(clGetDeviceInfo(deviceID, cl_device_info(param), length, &value, &length))
    
    guard let infoString = String(UTF8String: value) else {throw CLError.UTF8ConversionError}
    return infoString
  }
  
  public static func getInfo<T:IntegerLiteralConvertible> (deviceID:cl_device_id, param: Int32, count: Int) throws -> [T] {
    
    var value = [T](count:count, repeatedValue:0)
    try CLError.check(clGetDeviceInfo(deviceID, cl_device_info(param), sizeof(T) * count, &value, nil))
    return value
  }
  
  public static func listIDs(platformID: cl_platform_id, deviceType:cl_device_type) throws -> [cl_device_id] {
    
    var count: cl_uint = 0
    try CLError.check(clGetDeviceIDs(platformID, deviceType, 0, nil, &count))
    
    var deviceIDs = [cl_platform_id](count:Int(count), repeatedValue:nil)
    try CLError.check(clGetDeviceIDs(platformID, deviceType, count, &deviceIDs, &count))
    
    return deviceIDs
  }
  
  public static func getInfo(ID: cl_device_id) throws -> Device {
    
    let vendor = Device.Vendor(
      ID: try getInfo(ID, param: CL_DEVICE_VENDOR_ID),
      name: try getInfo(ID, param: CL_DEVICE_VENDOR)
    )
    
    let preferedWidth = Device.Width(
      charVector: try getInfo(ID, param: CL_DEVICE_PREFERRED_VECTOR_WIDTH_CHAR),
      shortVector: try getInfo(ID, param: CL_DEVICE_PREFERRED_VECTOR_WIDTH_SHORT),
      intVector: try getInfo(ID, param: CL_DEVICE_PREFERRED_VECTOR_WIDTH_INT),
      longVector: try getInfo(ID, param: CL_DEVICE_PREFERRED_VECTOR_WIDTH_LONG),
      floatVector: try getInfo(ID, param: CL_DEVICE_PREFERRED_VECTOR_WIDTH_FLOAT),
      doubleVector: try getInfo(ID, param: CL_DEVICE_PREFERRED_VECTOR_WIDTH_DOUBLE)
    )
    
    let nativeWidth = Device.Width(
      charVector: try getInfo(ID, param: CL_DEVICE_NATIVE_VECTOR_WIDTH_CHAR),
      shortVector: try getInfo(ID, param: CL_DEVICE_NATIVE_VECTOR_WIDTH_CHAR),
      intVector: try getInfo(ID, param: CL_DEVICE_NATIVE_VECTOR_WIDTH_CHAR),
      longVector: try getInfo(ID, param: CL_DEVICE_NATIVE_VECTOR_WIDTH_CHAR),
      floatVector: try getInfo(ID, param: CL_DEVICE_NATIVE_VECTOR_WIDTH_CHAR),
      doubleVector: try getInfo(ID, param: CL_DEVICE_NATIVE_VECTOR_WIDTH_CHAR)
    )
    
    let fpConfig = Device.FPConfig(
      halfPrecision: try getInfo(ID, param: CL_DEVICE_HALF_FP_CONFIG),
      singlePrecision: try getInfo(ID, param: CL_DEVICE_SINGLE_FP_CONFIG),
      doublePrecision: try getInfo(ID, param: CL_DEVICE_DOUBLE_FP_CONFIG)
    )
    
    let dimensions: cl_uint = try getInfo(ID, param: CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS)
    
    let deviceMax = Device.Max(
      workItemSizes: try getInfo(ID, param: CL_DEVICE_MAX_WORK_ITEM_SIZES, count: Int(dimensions)),
      workItemDimensions: dimensions,
      workGroupSize: try getInfo(ID, param: CL_DEVICE_MAX_WORK_GROUP_SIZE),
      samplers: try getInfo(ID, param: CL_DEVICE_MAX_SAMPLERS),
      readImageArgs: try getInfo(ID, param: CL_DEVICE_MAX_READ_IMAGE_ARGS),
      writeImageArgs: try getInfo(ID, param: CL_DEVICE_MAX_WRITE_IMAGE_ARGS),
      parameterSize: try getInfo(ID, param: CL_DEVICE_MAX_PARAMETER_SIZE),
      memAllocSize: try getInfo(ID, param: CL_DEVICE_MAX_MEM_ALLOC_SIZE),
      constantBufferSize: try getInfo(ID, param: CL_DEVICE_MAX_CONSTANT_BUFFER_SIZE),
      constantArgs: try getInfo(ID, param: CL_DEVICE_MAX_CONSTANT_ARGS),
      computeUnits: try getInfo(ID, param: CL_DEVICE_MAX_COMPUTE_UNITS),
      clockFrequency: try getInfo(ID, param: CL_DEVICE_MAX_CLOCK_FREQUENCY)
    )
    
    let globalMem = Device.GlobalMem(
      size: try getInfo(ID, param: CL_DEVICE_GLOBAL_MEM_SIZE),
      cacheLineSize: try getInfo(ID, param: CL_DEVICE_GLOBAL_MEM_CACHELINE_SIZE),
      cacheType: try getInfo(ID, param: CL_DEVICE_GLOBAL_MEM_CACHE_TYPE),
      cacheSize: try getInfo(ID, param: CL_DEVICE_GLOBAL_MEM_CACHE_SIZE)
    )
    
    let localMem = Device.LocalMem(
      type: try getInfo(ID, param: CL_DEVICE_LOCAL_MEM_TYPE),
      size: try getInfo(ID, param: CL_DEVICE_LOCAL_MEM_SIZE)
    )
    
    let image = Device.Image(
      image3DMaxWidth: try getInfo(ID, param: CL_DEVICE_IMAGE3D_MAX_WIDTH),
      image3DMaxHeight: try getInfo(ID, param: CL_DEVICE_IMAGE3D_MAX_HEIGHT),
      image3DMaxDepth: try getInfo(ID, param: CL_DEVICE_IMAGE3D_MAX_DEPTH),
      image2DMaxWidth: try getInfo(ID, param: CL_DEVICE_IMAGE2D_MAX_WIDTH),
      image2DMaxHeight: try getInfo(ID, param: CL_DEVICE_IMAGE2D_MAX_HEIGHT),
      maxBufferSize: try getInfo(ID, param: CL_DEVICE_IMAGE_MAX_BUFFER_SIZE),
      maxArraySize: try getInfo(ID, param: CL_DEVICE_IMAGE_MAX_ARRAY_SIZE),
      support: try getInfo(ID, param: CL_DEVICE_IMAGE_SUPPORT)
    )
    
    let platformID: cl_platform_id = try getInfo(ID, param: CL_DEVICE_PLATFORM)
    
    let device = Device(
      name: try getInfo(ID, param: CL_DEVICE_NAME),
      vendor: vendor,
      version: try getInfo(ID, param: CL_DEVICE_VERSION),
      openCLCVersion: try getInfo(ID, param: CL_DEVICE_OPENCL_C_VERSION),
      deviceProfile: try getInfo(ID, param: CL_DEVICE_PROFILE),
      deviceType: try getInfo(ID, param: CL_DEVICE_TYPE),
      available: try getInfo(ID, param: CL_DEVICE_AVAILABLE),
      driverVersion: try getInfo(ID, param: CL_DRIVER_VERSION),
      platformID: platformID,
      fpConfig: fpConfig,
      queueProperties: try getInfo(ID, param: CL_DEVICE_QUEUE_PROPERTIES),
      profilingTimerResolution: try getInfo(ID, param: CL_DEVICE_PROFILING_TIMER_RESOLUTION),
      preferredWidth: preferedWidth,
      nativeWidth: nativeWidth,
      minDataTypeAlignSize: try getInfo(ID, param: CL_DEVICE_MIN_DATA_TYPE_ALIGN_SIZE),
      memBaseAddrAlign: try getInfo(ID, param: CL_DEVICE_MEM_BASE_ADDR_ALIGN),
      hostUnifiedMemory: try getInfo(ID, param: CL_DEVICE_HOST_UNIFIED_MEMORY),
      max: deviceMax,
      localMem: localMem,
      globalMem: globalMem,
      image: image,
      executionCapabilities: try getInfo(ID, param: CL_DEVICE_EXECUTION_CAPABILITIES),
      errorCorrectionSupport: try getInfo(ID, param: CL_DEVICE_ERROR_CORRECTION_SUPPORT),
      endianLittle: try getInfo(ID, param: CL_DEVICE_ENDIAN_LITTLE),
      compilerAvailable: try getInfo(ID, param: CL_DEVICE_COMPILER_AVAILABLE),
      linkerAvailable: try getInfo(ID, param: CL_DEVICE_LINKER_AVAILABLE),
      addressBits: try getInfo(ID, param: CL_DEVICE_ADDRESS_BITS),
      buildInKernels: try getInfo(ID, param: CL_DEVICE_BUILT_IN_KERNELS),
      printfBufferSize: try getInfo(ID, param: CL_DEVICE_PRINTF_BUFFER_SIZE),
      preferredInteropUserSync: try getInfo(ID, param: CL_DEVICE_PREFERRED_INTEROP_USER_SYNC),
      referenceCount: try getInfo(ID, param: CL_DEVICE_REFERENCE_COUNT),
      extensions: try getInfo(ID, param: CL_DEVICE_EXTENSIONS)
    )
    
    return device
  }
  
  public static func list(platformID: cl_platform_id, deviceType:cl_device_type) throws -> [Device] {
    return try listIDs(platformID, deviceType: deviceType).map {ID in try getInfo(ID)}
  }
}