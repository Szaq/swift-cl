//
//  Simulation.swift
//  SwiftCL
//
//  Created by Lukasz Kwoska on 05/12/14.
//  Copyright (c) 2014 Spinal Development. All rights reserved.
//

import Foundation
import OpenCL
import SwiftCL

class Simulation {
  
  let queue: CommandQueue
  let kernel: Kernel
  let bufferA: Buffer<Float>
  let bufferB: Buffer<Float>
  
  init() throws {
    
    let context = try Context(fromType: CL_DEVICE_TYPE_GPU)
    
    queue = try CommandQueue(context: context)
    let program = try Program(context: context, loadFromMainBundle: "Simulation.cl")
    kernel = try Kernel(program: program, name: "simulationStep")
    bufferA = try Buffer<Float>(context: context, copyFrom: [0.0, 0.0, 1.0, 1.0], readOnly: true)
    bufferB = try Buffer<Float>(context: context, copyFrom: [4, 5, 6, 7])
    }
    
  func step() throws -> [Float] {
    let preparedKernel = try kernel.setArgs(bufferA, bufferB, bufferB)
    try queue.enqueue(preparedKernel, globalWorkSize: [4])
    try queue.enqueueRead(bufferB)
    
    return bufferB.objects
  }
}