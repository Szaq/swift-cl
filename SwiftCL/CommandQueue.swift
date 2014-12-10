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
  
  :param: context    Valid OpenCL context
  :param: device     Device associated with this context. If not specified then random device from this context will
                     be selected.
  :param: properties Optional properties (CL_QUEUE_OUT_OF_ORDER_EXEC_MODE_ENABLE, CL_QUEUE_PROFILING_ENABLE).
  :param: errorHanndler Optional handler that will be called if eny error occurs.
  
  :returns: Created Command Queue or nil if f
  */
  public init?(context: Context, device:cl_device_id? = nil, properties: cl_command_queue_properties = 0,
    errorHandler:((cl_int) -> Void)? = nil) {

      var deviceFromContext: cl_device_id? = nil
      
      if device == nil {
        if let devices: [cl_device_id] = context.getInfo(CL_CONTEXT_DEVICES,
          defValue: nil,
          errorHandler: { (param: Int32, error: cl_int) -> Void in
            if let handler = errorHandler {
              handler(error)
            }
        }) {
          if devices.count > 0 {
            deviceFromContext = devices[0]
          }
          else {
            id = COpaquePointer(bitPattern: 0)
            return nil
          }
        }
      }
      
      if (device != nil) && (deviceFromContext != nil) {
        if let handler = errorHandler {
          handler(NoDeviceError)
        }
        id = COpaquePointer(bitPattern: 0)
        return nil
      }
      
      var result: cl_int = 0
      id = clCreateCommandQueue(context.id, device ?? deviceFromContext!, properties, &result)
      if result != CL_SUCCESS {
        if let handler = errorHandler {
          handler(result)
        }
        return nil
      }
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
      
      
      
      let result = withResolvedPointers(globalWorkOffset, localWorkSize, eventWaitListIDs) {(globalWorkOffsetPtr, localWorkSizePtr, eventWaitListIDsPtr) -> cl_int in
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
    let size = range.map {UInt(count($0))} ?? buffer.size
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