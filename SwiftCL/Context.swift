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
        props.append(COpaquePointer(bitPattern: Int(key)))
        props.append(value)
      }
      
      func append(key:Int32, value:Int) {
        props.append(COpaquePointer(bitPattern: Int(key)))
        props.append(COpaquePointer(bitPattern: value))
      }
      
      if let platformID = platformID {
        appendPointer(CL_CONTEXT_PLATFORM, value: platformID)
        
      }
      
      if let interopUserSync = interopUserSync {
        append(CL_CONTEXT_INTEROP_USER_SYNC, value: Int(interopUserSync))
      }
      
      if let additionalProperties = additionalProperties {
        for i in 0.stride(to: additionalProperties.count, by: 2) {
          let key = additionalProperties[i]
          let value = additionalProperties[i + 1]
          append(Int32(key), value: value)
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
  
  public init(deviceIDs: [cl_device_id], properties: Properties? = nil) throws {
    
    var status: cl_int = 0
    
    if let properties = properties {
      let properties = properties.toCL()
      id = clCreateContext(UnsafePointer<cl_context_properties>(properties), cl_uint(deviceIDs.count), deviceIDs, nil, nil, &status)
    } else {
      id = clCreateContext(nil, cl_uint(deviceIDs.count), deviceIDs, nil, nil, &status)
    }
    
    try CLError.check(status)
  }
  
  /**
  Create Context
  
  - parameter deviceType:   Type of device to use: CL_DEVICE_TYPE_xxx
  - parameter properties:   Optional properties:
  
  - returns: Created Context
  */
  public init(fromType deviceType:Int32, properties: Properties? = nil) throws {
    
    var status: cl_int = 0
    
    if let properties = properties {
      let propertiesPtr = properties.toCL()
      id = clCreateContextFromType(UnsafePointer<cl_context_properties>(propertiesPtr), cl_device_type(deviceType), nil, nil, &status)
    }
    else {
      id = clCreateContextFromType(nil, cl_device_type(deviceType), nil, nil, &status)
    }
    
    try CLError.check(status)
  }
  
  deinit {
    clReleaseContext(self.id)
  }
  
  public func getInfo<T: IntegerLiteralConvertible>(param: Int32) throws -> T {
    
    var value: T = 0
    try CLError.check(clGetContextInfo(id, cl_context_info(param), sizeof(T), &value, nil))
    
    return value
  }
  
  public func getInfo<T>(param: Int32, defValue:T) throws -> [T] {
    var arraySize: size_t = 0
    try CLError.check(clGetContextInfo(id, cl_context_info(param), sizeof(T), nil, &arraySize))
    
    var array = [T](count: Int(arraySize) / sizeof(T), repeatedValue:defValue)
    try CLError.check(clGetContextInfo(id, cl_context_info(param), arraySize, &array, nil))
    return array
  }
  
  public func getInfo(param: Int32) throws -> [cl_context_properties: Int] {
    var result = [cl_context_properties: Int]()

    if let array = try getInfo(param, defValue: cl_context_properties(0)) as [cl_context_properties]? {
      for i in 0.stride(to: array.count, by: 2) {
        let key = array[i]
        if key != 0 {
          let value = array[i + 1]
          result[key] = value
        }
      }
    }
    
    return result
  }

  
  public func getInfo() throws -> Info {
    
    return Info(
      referenceCount: try getInfo(CL_CONTEXT_REFERENCE_COUNT),
      numDevices: try getInfo(CL_CONTEXT_NUM_DEVICES),
      deviceIDs: try getInfo(CL_CONTEXT_DEVICES, defValue: nil),
      properties: try getInfo(CL_CONTEXT_PROPERTIES)
    )
  }
  
}