//
//  Context.swift
//  ReceiptRecognizer
//
//  Created by Lukasz Kwoska on 24/11/14.
//  Copyright (c) 2014 Spinal Development. All rights reserved.
//

import Foundation
import OpenCL

public class Context {
  public struct Properties {
    public var platformID: cl_platform_id?
    public var interopUserSync: cl_bool?
    public var additionalProperties: [cl_context_properties]?
    public init() {
    }
    
    private func toCL() -> [COpaquePointer] {
      var props = [COpaquePointer]()
      
      func appendPointer(key:Int32, value:COpaquePointer) {
        props.append(COpaquePointer(bitPattern: Word(key)))
        props.append(value)
      }
      
      func append(key:Int32, value:Word) {
        props.append(COpaquePointer(bitPattern: Word(key)))
        props.append(COpaquePointer(bitPattern: value))
      }
      
      if let platformID = platformID {
        appendPointer(CL_CONTEXT_PLATFORM, platformID)
        
      }
      
      if let interopUserSync = interopUserSync {
        append(CL_CONTEXT_INTEROP_USER_SYNC, Word(interopUserSync))
      }
      
      if let additionalProperties = additionalProperties {
        for i in stride(from: 0, to: additionalProperties.count, by: 2) {
          let key = additionalProperties[i]
          let value = additionalProperties[i + 1]
          append(Int32(key), value)
        }
      }
      
      props.append(nil)
      return props
    }
  }
  
  public struct Info {
    public let referenceCount: cl_uint
    public let numDevices: cl_uint
    public let deviceIDs: [cl_device_id]
    public let properties:[cl_context_properties: Int]
  }
  
  public let id: cl_context
  
  public init(id: cl_context) {
    self.id = id
  }
  
  public init?(deviceIDs: [cl_device_id], properties: Properties? = nil, errorHandler: ((cl_int) -> Void)? = nil) {
    var error: cl_int = 0
    if let properties = properties {
      let properties = properties.toCL()
      id = clCreateContext(UnsafePointer<cl_context_properties>(properties), cl_uint(deviceIDs.count), deviceIDs, nil, nil, &error)
    }
    else {
      id = clCreateContext(nil, cl_uint(deviceIDs.count), deviceIDs, nil, nil, &error)
    }
    
    if (error != CL_SUCCESS) {
      if let handler = errorHandler {
        handler(error)
      }
      return nil
    }
  }
  
  /**
  Create Context
  
  :param: deviceType   Type of device to use: CL_DEVICE_TYPE_xxx
  :param: properties   Optional properties:
  :param: errorHandler Optional error handler
  
  :returns: Created Context
  */
  public init?(fromType deviceType:Int32, properties: Properties? = nil, errorHandler: ((cl_int) -> Void)? = nil) {
    var error: cl_int = 0
    if let properties = properties {
      let properties = properties.toCL()
      id = clCreateContextFromType(UnsafePointer<cl_context_properties>(properties), cl_device_type(deviceType), nil, nil, &error)
    }
    else {
      id = clCreateContextFromType(nil, cl_device_type(deviceType), nil, nil, &error)
    }
    
    if (error != CL_SUCCESS) {
      if let handler = errorHandler {
        handler(error)
      }
      return nil
    }
  }
  
  deinit {
    clReleaseContext(self.id)
  }
  
  public func getInfo<T: IntegerLiteralConvertible>(param: Int32, errorHandler: ((Int32, cl_int) -> Void)? = nil) -> T? {
    var value: T = 0
    let result = clGetContextInfo(id, cl_context_info(param), UInt(sizeof(T)), &value, nil)
    if  result != CL_SUCCESS {
      if let handler = errorHandler {
        handler(param, result)
      }
      return nil
    }
    
    return value
  }
  
  public func getInfo<T>(param: Int32, defValue:T, errorHandler: ((Int32, cl_int) -> Void)? = nil) -> [T]? {
    var arraySize: size_t = 0
    let result = clGetContextInfo(id, cl_context_info(param), UInt(sizeof(T)), nil, &arraySize)
    if  result != CL_SUCCESS {
      if let handler = errorHandler {
        handler(param, result)
      }
      return nil
    }

    var array = [T](count: Int(arraySize) / sizeof(T), repeatedValue:defValue)
    let result2 = clGetContextInfo(id, cl_context_info(param), UInt(arraySize), &array, nil)
    if  result2 != CL_SUCCESS {
      if let handler = errorHandler {
        handler(param, result2)
      }
      return nil
    }

    return array
  }
  
  public func getInfo(param: Int32, errorHandler: ((Int32, cl_int) -> Void)? = nil) -> [cl_context_properties: Int]? {
    var result = [cl_context_properties: Int]()

    var array: [cl_context_properties]? = getInfo(param, defValue: cl_context_properties(0), errorHandler)
    
    if let array = array {
      for i in stride(from: 0, to: array.count, by: 2) {
        let key = array[i]
        if key != 0 {
          let value = array[i + 1]
          result[key] = value
        }
      }
    }
    
    return result
  }

  
  public func getInfo(errorHandler: ((Int32, cl_int) -> Void)? = nil) -> Info {
    
    return Info(
      referenceCount: getInfo(CL_CONTEXT_REFERENCE_COUNT, errorHandler: errorHandler) ?? 0,
      numDevices: getInfo(CL_CONTEXT_NUM_DEVICES, errorHandler: errorHandler) ?? 0,
      deviceIDs: getInfo(CL_CONTEXT_DEVICES, defValue: nil, errorHandler: errorHandler) ?? [cl_device_id](),
      properties: getInfo(CL_CONTEXT_PROPERTIES, errorHandler: errorHandler) ?? [cl_context_properties: Int]()
    )
  }
  
}