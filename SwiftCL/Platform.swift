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


public func listPlatformIDs() throws -> [cl_platform_id] {
  var count: cl_uint = 0
  try CLError.check(clGetPlatformIDs(0, nil, &count))
  
  var platformIDs = [cl_platform_id](count:Int(count), repeatedValue:nil)
  try CLError.check(clGetPlatformIDs(count, &platformIDs, &count))
  
  return platformIDs
}

public func getPlatformInfo(platformID: cl_platform_id, param: Int32) throws -> String {
  
  var length: Int = 0
  try CLError.check(clGetPlatformInfo(platformID, cl_platform_info(param), sizeof(Int), nil, &length))
  
  var value = [CChar](count:Int(length), repeatedValue:0)
  try CLError.check(clGetPlatformInfo(platformID, cl_platform_info(param), length, &value, &length))
  
  guard let infoString = String(UTF8String:value) else {throw CLError.UTF8ConversionError }
  return infoString
}


public func listPlatforms() throws -> [Platform] {
  return try listPlatformIDs().map {ID in
      Platform(
        id:ID,
        profile: try getPlatformInfo(ID, param: CL_PLATFORM_PROFILE) ,
        version: try getPlatformInfo(ID, param: CL_PLATFORM_VERSION),
        name: try getPlatformInfo(ID, param: CL_PLATFORM_NAME),
        vendor: try getPlatformInfo(ID, param: CL_PLATFORM_VENDOR),
        extensions: try getPlatformInfo(ID, param: CL_PLATFORM_EXTENSIONS)
        )
    }
  
}
