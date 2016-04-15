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
  
  init?() {
    
      guard let context = Context(fromType: CL_DEVICE_TYPE_GPU),
        queue = CommandQueue(context: context),
        program = Program(context: context, loadFromMainBundle: "Simulation.cl"),
        kernel = Kernel(program: program, name: "simulationStep"),
        bufferA = Buffer<Float>(context: context, copyFrom: [0.0, 0.0, 1.0, 1.0], readOnly: true),
        bufferB = Buffer<Float>(context: context, copyFrom: [4, 5, 6, 7])
        else {return nil}
      
      self.queue = queue
      self.kernel = kernel
      self.bufferA = bufferA
      self.bufferB = bufferB
    }
    
    func step() -> [Float] {
      if let preparedKernel = kernel.setArgs(bufferA, bufferB, bufferB) {
        queue.enqueue(preparedKernel, globalWorkSize: [4])
        queue.enqueueRead(bufferB)
      }
      return bufferB.objects
  }
}