//
//  CommandQueue.swift
//  ReceiptRecognizer
//
//  Created by Lukasz Kwoska on 24/11/14.
//  Copyright (c) 2014 Spinal Development. All rights reserved.
//

import Foundation
import OpenCL

public class CommandQueue {
  
  public struct Info {
    public let context: cl_context
    public let device: cl_device_id
    public let referenceCount: cl_uint
    public let properties: [cl_command_queue_properties: Int]
  }

  //Device not found
  public let NoDeviceError: cl_int = -25
  
  public let id: cl_command_queue
  
  public init(id: cl_command_queue) {
    self.id = id
  }
  
  /**
  Create Command Queue
  
  - parameter context:    Valid OpenCL context
  - parameter device:     Device associated with this context. If not specified then random device from this context will
                     be selected.
  - parameter properties: Optional properties (CL_QUEUE_OUT_OF_ORDER_EXEC_MODE_ENABLE, CL_QUEUE_PROFILING_ENABLE).
  - parameter errorHanndler: Optional handler that will be called if eny error occurs.
  
  - returns: Created Command Queue or nil if f
  */
  public init(context: Context, device:cl_device_id? = nil, properties: cl_command_queue_properties = 0) throws {
    
    guard let selectedDevice: cl_device_id = try device ?? context.getInfo(CL_CONTEXT_DEVICES, defValue: nil).first
      else {throw CLError.DeviceNotFound}
    
      var status: cl_int = 0
      id = clCreateCommandQueue(context.id, selectedDevice, properties, &status)
      try CLError.check(status)
  }
  
  public func enqueue(
    kernel: Kernel.Prepared,
    globalWorkSize:[size_t],
    globalWorkOffset:[size_t]? = nil,
    localWorkSize:[size_t]? = nil,
    eventWaitList:[Event]? = nil,
    event: Event? = nil) -> cl_int {
      
      
      let eventWaitListIDs = eventWaitList?.filter{$0.id != nil}.map{$0.id!}
      var kernelEvent: cl_event = nil
      
      
      
      let result = withResolvedPointers(globalWorkOffset, b: localWorkSize, c: eventWaitListIDs) {(globalWorkOffsetPtr, localWorkSizePtr, eventWaitListIDsPtr) -> cl_int in
        clEnqueueNDRangeKernel(self.id, kernel.id,
          cl_uint(globalWorkSize.count),
          globalWorkOffsetPtr,
          globalWorkSize,
          localWorkSizePtr,
          (eventWaitList != nil) ? cl_uint(eventWaitListIDs!.count) : 0,
          eventWaitListIDsPtr,
          &kernelEvent)
      }
      
      
      if event != nil {
        event!.set(kernelEvent)
      }
      return result
  }
  
  public func enqueueRead(buffer:Memory, range: Range<size_t>? = nil, eventWaitList:[Event]? = nil, event: Event? = nil) -> cl_int {
    let offset = range?.startIndex ?? 0
    let size = range.map {$0.count} ?? Int(buffer.size)
    let blocking = cl_bool((event == nil) ? CL_TRUE : CL_FALSE)
    let eventWaitListIDs = eventWaitList?.filter{$0.id != nil}.map{$0.id!}
    var kernelEvent: cl_event = nil
    let result = withResolvedPointer(eventWaitListIDs) {
      clEnqueueReadBuffer(self.id, buffer.id, blocking, offset, size, buffer.data, (eventWaitList != nil) ? cl_uint(eventWaitListIDs!.count) : 0,
      $0,
      &kernelEvent)
    }
    
    
    if event != nil {
      event!.set(kernelEvent)
    }
    return result
  }
  
  public func enqueueWrite(buffer:Memory) {
    
  }
}