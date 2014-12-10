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
  
  let queue: CommandQueue!
  let kernel: Kernel!
  let bufferA: Buffer<Float>!
  let bufferB: Buffer<Float>!
  
  init?() {
    if let context = Context(fromType: CL_DEVICE_TYPE_GPU) {
      
      if let queue = CommandQueue(context: context) {
        self.queue = queue
        
        if let program = Program(context: context, loadFromMainBundle: "Simulation.cl") {
          
          if let kernel = Kernel(program: program, name: "simulationStep") {
            self.kernel = kernel
          }
          
          if let buffer = Buffer<Float>(context: context, copyFrom: [0.0, 0.0, 1.0, 1.0], readOnly: true) {
            bufferA = buffer
          }
          
          if let buffer = Buffer<Float>(context: context, copyFrom: [4, 5, 6, 7]) {
            bufferB = buffer
          }
          
          if (kernel == nil || bufferA == nil || bufferB == nil) {
            return nil
          }
        }
      }
    }
    return nil
  }
  
  func step() -> [Float] {
    if let preparedKernel = kernel.setArgs(bufferA, bufferB, bufferB) {
      queue.enqueue(preparedKernel, globalWorkSize: [4])
      queue.enqueueRead(bufferB)
    }
    return bufferB.objects
  }
  
}