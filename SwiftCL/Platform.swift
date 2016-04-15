//
//  OpenCLObject.swift
//  ReceiptRecognizer
//
//  Created by Lukasz Kwoska on 21/11/14.
//  Copyright (c) 2014 Spinal Development. All rights reserved.
//

import Foundation
import OpenCL

/**
 OpenCL Platform
 
  - seealso: http://www.khronos.org/registry/cl/specs/opencl-1.2.pdf#page=33
 */
public struct Platform : CustomStringConvertible {
  ///Platform identifier
  public let id: cl_platform_id
  
  /**
   OpenCL profile string. Returns the profile name supported by the implementation. The profile name returned can be one of the following strings:
   
   FULL_PROFILE - if the implementation supports the OpenCL specification (functionality defined as part of the core specification and does not require any extensions to be supported).
   
   EMBEDDED_PROFILE - if the implementation supports the OpenCL embedded profile. The embedded profile is defined to be a subset for each version of OpenCL.
   */
  public let profile: String
  
  /**
   OpenCL version string. Returns the OpenCL version supported by the implementation. This version string has the following format:
   
   OpenCL<space><major_version.minor_version><space><platform-specific information>
   
   The major_version.minor_version value returned will be 1.2.
 */
  public let version: String
  
  ///Platform name string.
  public let name: String
  
  ///Platform vendor string.
  public let vendor: String
  
  /**
   Space-separated list of extension names (the extension names themselves do not contain any spaces) supported by the platform. Extensions defined here must be supported by all devices associated with this platform.
   */
  public let extensions: String
  
  ///Textual platform description
  public var description: String { return "ID: \(id)\nName: \(name)"
    + "\nVendor: \(vendor)\nVersion: \(version)\nProfile: \(profile)\nExtensions: \(extensions)"}
}


extension Platform {
  /**
   Obtain the list of identifiers of available platforms.
   
   - throws: CLError
   
   - returns: List of platform identifiers
   
   - seealso: https://www.khronos.org/registry/cl/sdk/1.2/docs/man/xhtml/clGetPlatformIDs.html
   */
  public static func listIDs() throws -> [cl_platform_id] {
    var count: cl_uint = 0
    try CLError.check(clGetPlatformIDs(0, nil, &count))
    
    var platformIDs = [cl_platform_id](count:Int(count), repeatedValue:nil)
    try CLError.check(clGetPlatformIDs(count, &platformIDs, &count))
    
    return platformIDs
  }
  
  /**
   Get specific information about the OpenCL platform.
   
   - parameter platformID: Platform identifier
   - parameter param:      An enumeration constant that identifies the platform information being queried. For possible values check the khronos link.
   
   - throws: CLError
   
   - returns: Value for requested param
   
   - seealso: https://www.khronos.org/registry/cl/sdk/1.2/docs/man/xhtml/clGetPlatformInfo.html
   */
  public static func getInfo(platformID: cl_platform_id, param: Int32) throws -> String {
    
    var length: Int = 0
    try CLError.check(clGetPlatformInfo(platformID, cl_platform_info(param), sizeof(Int), nil, &length))
    
    var value = [CChar](count:Int(length), repeatedValue:0)
    try CLError.check(clGetPlatformInfo(platformID, cl_platform_info(param), length, &value, &length))
    
    guard let infoString = String(UTF8String:value) else {throw CLError.UTF8ConversionError }
    return infoString
  }
  
  /**
   Obtain the list of platforms available.
   
   - throws: CLError
   
   - returns: List of platforms
   
   - seealso: https://www.khronos.org/registry/cl/sdk/1.2/docs/man/xhtml/clGetPlatformIDs.html
   */
  
  public static func list() throws -> [Platform] {
    return try listIDs().map {ID in
      Platform(
        id:ID,
        profile: try getInfo(ID, param: CL_PLATFORM_PROFILE) ,
        version: try getInfo(ID, param: CL_PLATFORM_VERSION),
        name: try getInfo(ID, param: CL_PLATFORM_NAME),
        vendor: try getInfo(ID, param: CL_PLATFORM_VENDOR),
        extensions: try getInfo(ID, param: CL_PLATFORM_EXTENSIONS)
      )
    }
  }
}
