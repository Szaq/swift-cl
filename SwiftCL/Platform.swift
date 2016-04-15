//
//  OpenCLObject.swift
//  ReceiptRecognizer
//
//  Created by Lukasz Kwoska on 21/11/14.
//  Copyright (c) 2014 Spinal Development. All rights reserved.
//

import Foundation
import OpenCL

///OpenCL Platform
public struct Platform : CustomStringConvertible{
  public let id: cl_platform_id
  public let profile: String
  public let version: String
  public let name: String
  public let vendor: String
  public let extensions: String
  
  public var description: String { return "ID: \(id)\nName: \(name)"
    + "\nVendor: \(vendor)\nVersion: \(version)\nProfile: \(profile)\nExtensions: \(extensions)"}
}


public func listPlatformIDs() -> [cl_platform_id]? {
  var count: cl_uint = 0
  if clGetPlatformIDs(0, nil, &count) != CL_SUCCESS {
    return nil
  }
  
  var platformIDs = [cl_platform_id](count:Int(count), repeatedValue:nil)
  if clGetPlatformIDs(count, &platformIDs, &count) != CL_SUCCESS {
    return nil
  }
  
  return platformIDs
}

public func getPlatformInfo(
  platformID:cl_platform_id,
  param: Int32,
  errorHandler: ((cl_platform_id, Int32, cl_int) -> Void)? = nil) -> String? {
    
    var length: Int = 0
    let result = clGetPlatformInfo(platformID, cl_platform_info(param), sizeof(Int), nil, &length)
    if result != CL_SUCCESS {
      if let handler = errorHandler {
        handler(platformID, param, result)
      }
      return nil
    }
    
    var value = [Int8](count:Int(length), repeatedValue:0)
    let result2 = clGetPlatformInfo(platformID, cl_platform_info(param), length, &value, &length)
    if  result2 != CL_SUCCESS {
      if let handler = errorHandler {
        handler(platformID, param, result2)
      }
      return nil
    }
    
    return NSString(UTF8String: value) as? String
}


public func listPlatforms() -> [Platform]? {
  if let platformIDs = listPlatformIDs() {
    var platforms = [Platform]()
    for ID in platformIDs {
      platforms.append(Platform(
        id:ID,
        profile: getPlatformInfo(ID, param: CL_PLATFORM_PROFILE) ?? "",
        version: getPlatformInfo(ID, param: CL_PLATFORM_VERSION) ?? "",
        name: getPlatformInfo(ID, param: CL_PLATFORM_NAME) ?? "",
        vendor: getPlatformInfo(ID, param: CL_PLATFORM_VENDOR) ?? "",
        extensions: getPlatformInfo(ID, param: CL_PLATFORM_EXTENSIONS) ?? ""
        ))
    }
    return platforms
  }
  return nil
}
