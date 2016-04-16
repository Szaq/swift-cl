//
//  Context.swift
//  ReceiptRecognizer
//
//  Created by Lukasz Kwoska on 24/11/14.
//  Copyright (c) 2014 Spinal Development. All rights reserved.
//

import Foundation
import OpenCL

/**
 An OpenCL context is created with one or more devices. Contexts are used by the OpenCL runtime 
 for managing objects such as command-queues, memory, program and kernel objects and for executing
 kernels on one or more devices specified in the context.
 */
public class Context {
  /**
   *  Properties which can be used to initialize Context
   */
  public struct Properties {
    /// Specifies the platform to use.
    public var platformID: cl_platform_id?
    /**
     Specifies whether the user is responsible for synchronization between OpenCL and other APIs.
     Please refer to the specific sections in the OpenCL 1.2 extension specification that describe
     sharing with other APIs for restrictions on using this flag.
     */
    
    public var interopUserSync: cl_bool?
    
    /// Additional initialization properties
    public var additionalProperties: [cl_context_properties]?
    
    ///Initialize with empty properties
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
  
  /**
   *  Informations describing Context
   */
  public struct Info {
    /**
     Context reference count. The reference count returned should be considered immediately stale.
     It is unsuitable for general use in applications.
     This feature is provided for identifying memory leaks.
     */
    public let referenceCount: cl_uint
    
        /// Number of devices in Context
    public let numDevices: cl_uint
    
    ///  List of devices in context
    public let deviceIDs: [cl_device_id]
    
    ///Properties specified during initialization
    public let properties:[cl_context_properties: Int]
  }
  
  /// Context identifier
  public let id: cl_context
  
  /**
   Initialize Context with existing Context identifier
   - remark: Upon destruction this object will release underlying OpenCL context
   */
  public init(id: cl_context) {
    self.id = id
  }
  
  /**
   Initialize Context with concreet devices.
   
   - parameter deviceIDs:  Devices to use
   - parameter properties: Additional initialization properties
   
   - seealso: https://www.khronos.org/registry/cl/sdk/1.2/docs/man/xhtml/clCreateContext.html
   
   - throws: CLError
   */
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
   
  - seealso:
    - https://www.khronos.org/registry/cl/sdk/1.2/docs/man/xhtml/clCreateContext.html
    - https://www.khronos.org/registry/cl/sdk/1.2/docs/man/xhtml/clCreateContextFromType.html
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
  
  /**
   Query information about a context
   
   - parameter param: An enumeration constant that specifies the information to query
   
   - throws: CLError
   
   - returns: Result of querying
   
   - seealso: https://www.khronos.org/registry/cl/sdk/1.2/docs/man/xhtml/clGetContextInfo.html
   */
  public func getInfo<T: IntegerLiteralConvertible>(param: Int32) throws -> T {
    
    var value: T = 0
    try CLError.check(clGetContextInfo(id, cl_context_info(param), sizeof(T), &value, nil))
    
    return value
  }
  
  /**
   Query information about a context.
   
   - parameter param: An enumeration constant that specifies the information to query
   - parameter defValue: Default value for elements of returned array
   
   - throws: CLError
   
   - returns: Array of result of querying
   
   - seealso: https://www.khronos.org/registry/cl/sdk/1.2/docs/man/xhtml/clGetContextInfo.html
   */
  public func getInfo<T>(param: Int32, defValue:T) throws -> [T] {
    var arraySize: size_t = 0
    try CLError.check(clGetContextInfo(id, cl_context_info(param), sizeof(T), nil, &arraySize))
    
    var array = [T](count: Int(arraySize) / sizeof(T), repeatedValue:defValue)
    try CLError.check(clGetContextInfo(id, cl_context_info(param), arraySize, &array, nil))
    return array
  }
  
  /**
   Query information about a context.
   
   - parameter param: An enumeration constant that specifies the information to query
   
   - throws: CLError
   
   - returns: Dictionary of context properties.
   
   - seealso: https://www.khronos.org/registry/cl/sdk/1.2/docs/man/xhtml/clGetContextInfo.html
   */
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

  /**
   Get all informations about this context.
   
   - throws: CLError
   
   - returns: Informations describing this context
   
   - seealso: https://www.khronos.org/registry/cl/sdk/1.2/docs/man/xhtml/clGetContextInfo.html
   */
  public func getInfo() throws -> Info {
    
    return Info(
      referenceCount: try getInfo(CL_CONTEXT_REFERENCE_COUNT),
      numDevices: try getInfo(CL_CONTEXT_NUM_DEVICES),
      deviceIDs: try getInfo(CL_CONTEXT_DEVICES, defValue: nil),
      properties: try getInfo(CL_CONTEXT_PROPERTIES)
    )
  }
  
}