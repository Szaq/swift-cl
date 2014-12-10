//
//  Device.swift
//  SwiftCL
//
//  Created by Lukasz Kwoska on 05/12/14.
//  Copyright (c) 2014 Spinal Development. All rights reserved.
//

import Foundation
import OpenCL

public struct Device : Printable {
  
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


public func getDeviceInfo<T:IntegerLiteralConvertible>(
  deviceID:cl_device_id,
  param: Int32,
  errorHandler:((cl_device_id,Int32,cl_int)->Void)? = nil) -> T? {
    
    var value: T = 0
    let result = clGetDeviceInfo(deviceID, cl_device_info(param), UInt(sizeof(T)), &value, nil)
    if result != CL_SUCCESS {
      if let handler = errorHandler {
        handler(deviceID, param, result)
      }
      return nil
    }
    return value
}

public func getDeviceInfo<T:NilLiteralConvertible>(
  deviceID:cl_device_id,
  param: Int32,
  errorHandler:((cl_device_id,Int32,cl_int)->Void)? = nil) -> T? {
    
    var value: T = nil
    let result = clGetDeviceInfo(deviceID, cl_device_info(param), UInt(sizeof(T)), &value, nil)
    if result != CL_SUCCESS {
      if let handler = errorHandler {
        handler(deviceID, param, result)
      }
      return nil
    }
    return value
}

public func getDeviceInfo(
  deviceID:cl_device_id,
  param: Int32,
  errorHandler:((cl_device_id,Int32,cl_int)->Void)? = nil) -> String? {
    
    var length: UInt = 0
    let result = clGetDeviceInfo(deviceID, cl_device_info(param), UInt(sizeof(UInt)), nil, &length)
    if result != CL_SUCCESS {
      if let handler = errorHandler {
        handler(deviceID, param, result)
      }
      return nil
    }
    
    var value = [Int8](count:Int(length), repeatedValue:0)
    let result2 = clGetDeviceInfo(deviceID, cl_device_info(param), length, &value, &length)
    if  result2 != CL_SUCCESS {
      if let handler = errorHandler {
        handler(deviceID, param, result2)
      }
      return nil
    }
    
    return NSString(UTF8String: value)
}


public func getDeviceInfo<T:IntegerLiteralConvertible> (
  deviceID:cl_device_id,
  param: Int32,
  count: Int,
  errorHandler:((cl_device_id,Int32,cl_int)->Void)? = nil) -> [T]? {
    var value = [T](count:count, repeatedValue:0)
    let result = clGetDeviceInfo(deviceID, cl_device_info(param), UInt(sizeof(T) * count), &value, nil)
    if result != CL_SUCCESS {
      if let handler = errorHandler {
        handler(deviceID, param, result)
      }
      return nil
    }
    return value
}

public func listDeviceIDs(platformID: cl_platform_id, deviceType:cl_device_type) -> [cl_device_id]? {
  
  var count: cl_uint = 0
  if clGetDeviceIDs(platformID, deviceType, 0, nil, &count) != CL_SUCCESS {
    return nil
  }
  
  var deviceIDs = [cl_platform_id](count:Int(count), repeatedValue:nil)
  if clGetDeviceIDs(platformID, deviceType, count, &deviceIDs, &count) != CL_SUCCESS {
    return nil
  }
  
  return deviceIDs
}

public func getDeviceInfo(ID:cl_device_id, errorHandler:((cl_device_id,Int32,cl_int)->Void)? = nil) -> Device? {
  let vendor = Device.Vendor(
    ID: getDeviceInfo(ID, CL_DEVICE_VENDOR_ID, errorHandler: errorHandler) ?? 0,
    name: getDeviceInfo(ID, CL_DEVICE_VENDOR, errorHandler: errorHandler) ?? ""
  )
  
  let fpConfig = Device.FPConfig(
    halfPrecision: getDeviceInfo(ID, CL_DEVICE_HALF_FP_CONFIG, errorHandler: errorHandler) ?? 0,
    singlePrecision: getDeviceInfo(ID, CL_DEVICE_SINGLE_FP_CONFIG, errorHandler: errorHandler) ?? 0,
    doublePrecision: getDeviceInfo(ID, CL_DEVICE_DOUBLE_FP_CONFIG, errorHandler: errorHandler) ?? 0
  )
  
  let preferedWidth = Device.Width(
    charVector: getDeviceInfo(ID, CL_DEVICE_PREFERRED_VECTOR_WIDTH_CHAR, errorHandler: errorHandler) ?? 0,
    shortVector: getDeviceInfo(ID, CL_DEVICE_PREFERRED_VECTOR_WIDTH_SHORT, errorHandler: errorHandler) ?? 0,
    intVector: getDeviceInfo(ID, CL_DEVICE_PREFERRED_VECTOR_WIDTH_INT, errorHandler: errorHandler) ?? 0,
    longVector: getDeviceInfo(ID, CL_DEVICE_PREFERRED_VECTOR_WIDTH_LONG, errorHandler: errorHandler) ?? 0,
    floatVector: getDeviceInfo(ID, CL_DEVICE_PREFERRED_VECTOR_WIDTH_FLOAT, errorHandler: errorHandler) ?? 0,
    doubleVector: getDeviceInfo(ID, CL_DEVICE_PREFERRED_VECTOR_WIDTH_DOUBLE, errorHandler: errorHandler) ?? 0
  )
  
  let nativeWidth = Device.Width(
    charVector: getDeviceInfo(ID, CL_DEVICE_NATIVE_VECTOR_WIDTH_CHAR, errorHandler: errorHandler) ?? 0,
    shortVector: getDeviceInfo(ID, CL_DEVICE_NATIVE_VECTOR_WIDTH_CHAR, errorHandler: errorHandler) ?? 0,
    intVector: getDeviceInfo(ID, CL_DEVICE_NATIVE_VECTOR_WIDTH_CHAR, errorHandler: errorHandler) ?? 0,
    longVector: getDeviceInfo(ID, CL_DEVICE_NATIVE_VECTOR_WIDTH_CHAR, errorHandler: errorHandler) ?? 0,
    floatVector: getDeviceInfo(ID, CL_DEVICE_NATIVE_VECTOR_WIDTH_CHAR, errorHandler: errorHandler) ?? 0,
    doubleVector: getDeviceInfo(ID, CL_DEVICE_NATIVE_VECTOR_WIDTH_CHAR, errorHandler: errorHandler) ?? 0
  )
  
  let dimensions: cl_uint = getDeviceInfo(ID, CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS, errorHandler: errorHandler) ?? 0
  
  let deviceMax = Device.Max(
    workItemSizes: getDeviceInfo(
      ID,
      CL_DEVICE_MAX_WORK_ITEM_SIZES,
      Int(dimensions),
      errorHandler: errorHandler) ?? [size_t](),
    workItemDimensions: dimensions,
    workGroupSize: getDeviceInfo(ID, CL_DEVICE_MAX_WORK_GROUP_SIZE, errorHandler: errorHandler) ?? 0,
    samplers: getDeviceInfo(ID, CL_DEVICE_MAX_SAMPLERS, errorHandler: errorHandler) ?? 0,
    readImageArgs: getDeviceInfo(ID, CL_DEVICE_MAX_READ_IMAGE_ARGS, errorHandler: errorHandler) ?? 0,
    writeImageArgs: getDeviceInfo(ID, CL_DEVICE_MAX_WRITE_IMAGE_ARGS, errorHandler: errorHandler) ?? 0,
    parameterSize: getDeviceInfo(ID, CL_DEVICE_MAX_PARAMETER_SIZE, errorHandler: errorHandler) ?? 0,
    memAllocSize: getDeviceInfo(ID, CL_DEVICE_MAX_MEM_ALLOC_SIZE, errorHandler: errorHandler) ?? 0,
    constantBufferSize: getDeviceInfo(ID, CL_DEVICE_MAX_CONSTANT_BUFFER_SIZE, errorHandler: errorHandler) ?? 0,
    constantArgs: getDeviceInfo(ID, CL_DEVICE_MAX_CONSTANT_ARGS, errorHandler: errorHandler) ?? 0,
    computeUnits: getDeviceInfo(ID, CL_DEVICE_MAX_COMPUTE_UNITS, errorHandler: errorHandler) ?? 0,
    clockFrequency: getDeviceInfo(ID, CL_DEVICE_MAX_CLOCK_FREQUENCY, errorHandler: errorHandler) ?? 0
  )
  
  let globalMem = Device.GlobalMem(
    size: getDeviceInfo(ID, CL_DEVICE_GLOBAL_MEM_SIZE, errorHandler: errorHandler) ?? 0,
    cacheLineSize: getDeviceInfo(ID, CL_DEVICE_GLOBAL_MEM_CACHELINE_SIZE, errorHandler: errorHandler) ?? 0,
    cacheType: getDeviceInfo(ID, CL_DEVICE_GLOBAL_MEM_CACHE_TYPE, errorHandler: errorHandler) ?? 0,
    cacheSize: getDeviceInfo(ID, CL_DEVICE_GLOBAL_MEM_CACHE_SIZE, errorHandler: errorHandler) ?? 0
  )
  
  let localMem = Device.LocalMem(
    type: getDeviceInfo(ID, CL_DEVICE_LOCAL_MEM_TYPE, errorHandler: errorHandler) ?? 0,
    size: getDeviceInfo(ID, CL_DEVICE_LOCAL_MEM_SIZE, errorHandler: errorHandler) ?? 0
  )
  
  let image = Device.Image(
    image3DMaxWidth: getDeviceInfo(ID, CL_DEVICE_IMAGE3D_MAX_WIDTH, errorHandler: errorHandler) ?? 0,
    image3DMaxHeight: getDeviceInfo(ID, CL_DEVICE_IMAGE3D_MAX_HEIGHT, errorHandler: errorHandler) ?? 0,
    image3DMaxDepth: getDeviceInfo(ID, CL_DEVICE_IMAGE3D_MAX_DEPTH, errorHandler: errorHandler) ?? 0,
    image2DMaxWidth: getDeviceInfo(ID, CL_DEVICE_IMAGE2D_MAX_WIDTH, errorHandler: errorHandler) ?? 0,
    image2DMaxHeight: getDeviceInfo(ID, CL_DEVICE_IMAGE2D_MAX_HEIGHT, errorHandler: errorHandler) ?? 0,
    maxBufferSize: getDeviceInfo(ID, CL_DEVICE_IMAGE_MAX_BUFFER_SIZE, errorHandler: errorHandler) ?? 0,
    maxArraySize: getDeviceInfo(ID, CL_DEVICE_IMAGE_MAX_ARRAY_SIZE, errorHandler: errorHandler) ?? 0,
    support: getDeviceInfo(ID, CL_DEVICE_IMAGE_SUPPORT, errorHandler: errorHandler) ?? 0
  )
  
  let platformID: cl_platform_id = getDeviceInfo(ID, CL_DEVICE_PLATFORM, errorHandler: errorHandler) ?? nil
  
  let device = Device(
    name: getDeviceInfo(ID, CL_DEVICE_NAME, errorHandler: errorHandler) ?? "",
    vendor: vendor,
    version: getDeviceInfo(ID, CL_DEVICE_VERSION, errorHandler: errorHandler) ?? "",
    openCLCVersion: getDeviceInfo(ID, CL_DEVICE_OPENCL_C_VERSION, errorHandler: errorHandler) ?? "",
    deviceProfile: getDeviceInfo(ID, CL_DEVICE_PROFILE, errorHandler: errorHandler) ?? "",
    deviceType: getDeviceInfo(ID, CL_DEVICE_TYPE, errorHandler: errorHandler) ?? 0,
    available: getDeviceInfo(ID, CL_DEVICE_AVAILABLE, errorHandler: errorHandler) ?? 0,
    driverVersion: getDeviceInfo(ID, CL_DRIVER_VERSION, errorHandler: errorHandler) ?? "",
    platformID: platformID,
    fpConfig: fpConfig,
    queueProperties: getDeviceInfo(ID, CL_DEVICE_QUEUE_PROPERTIES, errorHandler: errorHandler) ?? 0,
    profilingTimerResolution: getDeviceInfo(ID, CL_DEVICE_PROFILING_TIMER_RESOLUTION, errorHandler: errorHandler) ?? 0,
    preferredWidth: preferedWidth,
    nativeWidth: nativeWidth,
    minDataTypeAlignSize: getDeviceInfo(ID, CL_DEVICE_MIN_DATA_TYPE_ALIGN_SIZE, errorHandler: errorHandler) ?? 0,
    memBaseAddrAlign: getDeviceInfo(ID, CL_DEVICE_MEM_BASE_ADDR_ALIGN, errorHandler: errorHandler) ?? 0,
    hostUnifiedMemory: getDeviceInfo(ID, CL_DEVICE_HOST_UNIFIED_MEMORY, errorHandler: errorHandler) ?? 0,
    max: deviceMax,
    localMem: localMem,
    globalMem: globalMem,
    image: image,
    executionCapabilities: getDeviceInfo(ID, CL_DEVICE_EXECUTION_CAPABILITIES, errorHandler: errorHandler) ?? 0,
    errorCorrectionSupport: getDeviceInfo(ID, CL_DEVICE_ERROR_CORRECTION_SUPPORT, errorHandler: errorHandler) ?? 0,
    endianLittle: getDeviceInfo(ID, CL_DEVICE_ENDIAN_LITTLE, errorHandler: errorHandler) ?? 0,
    compilerAvailable: getDeviceInfo(ID, CL_DEVICE_COMPILER_AVAILABLE, errorHandler: errorHandler) ?? 0,
    linkerAvailable: getDeviceInfo(ID, CL_DEVICE_LINKER_AVAILABLE, errorHandler: errorHandler) ?? 0,
    addressBits: getDeviceInfo(ID, CL_DEVICE_ADDRESS_BITS, errorHandler: errorHandler) ?? 0,
    buildInKernels: getDeviceInfo(ID, CL_DEVICE_BUILT_IN_KERNELS, errorHandler: errorHandler) ?? "",
    printfBufferSize: getDeviceInfo(ID, CL_DEVICE_PRINTF_BUFFER_SIZE, errorHandler: errorHandler) ?? 0,
    preferredInteropUserSync: getDeviceInfo(ID, CL_DEVICE_PREFERRED_INTEROP_USER_SYNC, errorHandler: errorHandler) ?? 0,
    referenceCount: getDeviceInfo(ID, CL_DEVICE_REFERENCE_COUNT, errorHandler: errorHandler) ?? 0,
    extensions: getDeviceInfo(ID, CL_DEVICE_EXTENSIONS, errorHandler: errorHandler) ?? ""
  )
  
  return device
}

public func listDevices(
  platformID: cl_platform_id,
  deviceType:cl_device_type,
  errorHandler:((cl_device_id,Int32,cl_int)->Void)? = nil) -> [Device]? {
    
    if let deviceIDs = listDeviceIDs(platformID, deviceType) {
      var devices = [Device]()
      
      for ID: cl_device_id in deviceIDs {
        if let device = getDeviceInfo(ID, errorHandler:errorHandler) {
          devices.append(device)
        }
      }
      return devices
    }
    return nil
}
