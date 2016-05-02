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
  
  /**
   Enqueues a command to execute a kernel on a device.
   
   - parameter kernel:           A valid kernel object. The OpenCL context associated with kernel and command_queue must be the same.
   - parameter globalWorkSize:   Points to an array of unsigned values that describe the number of global work-items in `globalWorkSize.count` dimensions that will execute the kernel function. The total number of global work-items is computed as `globalWorkSize[0]` *...* `globalWorkSize[globalWorkSize.count - 1]`.
   - parameter globalWorkOffset: Can be used to specify an array of `globalWorkSize.count` unsigned values that describe the offset used to calculate the global ID of a work-item. If globalWorkOffset is nil, the global IDs start at offset (0, 0, ... 0).
   - parameter localWorkSize:    Points to an array of `globalWorkSize.count` unsigned values that describe the number of work-items that make up a work-group (also referred to as the size of the work-group) that will execute the kernel specified by kernel. The total number of work-items in a work-group is computed as `localWorkSize[0]` *... * `localWorkSize[localWorkSize.count - 1]`. The total number of work-items in the work-group must be less than or equal to the `CL_DEVICE_MAX_WORK_GROUP_SIZE` value specified in table of OpenCL Device Queries for `Device.getInfo` and the number of work-items specified in `localWorkSize[0]`,... `localWorkSize[localWorkSize.count - 1]` must be less than or equal to the corresponding values specified by `CL_DEVICE_MAX_WORK_ITEM_SIZES[0]`,.... `CL_DEVICE_MAX_WORK_ITEM_SIZES[localWorkSize.count - 1]`. The explicitly specified `localWorkSize` will be used to determine how to break the global work-items specified by `globalWorkSize` into appropriate work-group instances. If `localWorkSize` is specified, the values specified in `globalWorkSize[0]`,... `globalWorkSize[globalWorkSize.count - 1]` must be evenly divisible by the corresponding values specified in localWorkSize[0],... `localWorkSize[localWorkSize.count - 1]`. localWorkSize can also be a nil value in which case the OpenCL implementation will determine how to be break the global work-items into appropriate work-group instances.
   - parameter eventWaitList:    Specify events that need to complete before this particular command can be executed. If eventWaitList is nil, then this particular command does not wait on any event to complete. The events specified in eventWaitList act as synchronization points. The context associated with events in eventWaitList and command_queue must be the same. The memory associated with eventWaitList can be reused or freed after the function returns.
   - parameter event:            Returns an event object that identifies this particular kernel execution instance. Event objects are unique and can be used to identify a particular kernel execution instance later on. If event is NULL, no event will be created for this kernel execution instance and therefore it will not be possible for the application to query or queue a wait for this particular kernel execution instance.
   
   - throws: CLError
   
   - seealso: https://www.khronos.org/registry/cl/sdk/1.2/docs/man/xhtml/clEnqueueNDRangeKernel.html
   */
  public func enqueue(
    kernel: Kernel.Prepared,
    globalWorkSize:[size_t],
    globalWorkOffset:[size_t]? = nil,
    localWorkSize:[size_t]? = nil,
    eventWaitList:[Event]? = nil,
    event: Event? = nil) throws {
    
    
    let eventWaitListIDs = eventWaitList?.filter{$0.id != nil}.map{$0.id!}
    var kernelEvent: cl_event = nil
    
    let status = withResolvedPointers(globalWorkOffset, b: localWorkSize, c: eventWaitListIDs) {(globalWorkOffsetPtr, localWorkSizePtr, eventWaitListIDsPtr) -> cl_int in
      clEnqueueNDRangeKernel(self.id, kernel.id,
                             cl_uint(globalWorkSize.count),
                             globalWorkOffsetPtr,
                             globalWorkSize,
                             localWorkSizePtr,
                             (eventWaitList != nil) ? cl_uint(eventWaitListIDs!.count) : 0,
                             eventWaitListIDsPtr,
                             &kernelEvent)
    }
    try CLError.check(status)
    
    
    if event != nil {
      event!.set(kernelEvent)
    }
  }
  
  /**
   Enqueue commands to read from a buffer object to host memory.
   
   - parameter buffer:        Refers to a valid buffer object.
   - parameter range:         The offset and size in bytes in the buffer object to read.
   - parameter eventWaitList: Specify events that need to complete before this particular command can be executed. If eventWaitList is nil, then this particular command does not wait on any event to complete. The events specified in eventWaitList act as synchronization points. The context associated with events in eventWaitList and command_queue must be the same. The memory associated with eventWaitList can be reused or freed after the function returns.
   - parameter event:         Returns an event object that identifies this particular read command and can be used to query or queue a wait for this particular command to complete. event can be nil in which case it will not be possible for the application to query the status of this command or queue a wait for this command to complete. If the eventWaitList and the event arguments are not nil, the event argument should not refer to an element of the eventWaitList array.
   
   - throws: CLError
   
   - seealso: https://www.khronos.org/registry/cl/sdk/1.2/docs/man/xhtml/clEnqueueReadBuffer.html
   */
  public func enqueueRead(buffer:Memory, range: Range<size_t>? = nil, eventWaitList:[Event]? = nil, event: Event? = nil) throws {
    let offset = range?.startIndex ?? 0
    let size = range.map {$0.count} ?? Int(buffer.size)
    let blocking = cl_bool((event == nil) ? CL_TRUE : CL_FALSE)
    let eventWaitListIDs = eventWaitList?.filter{$0.id != nil}.map{$0.id!}
    var kernelEvent: cl_event = nil
    let status = withResolvedPointer(eventWaitListIDs) {
      clEnqueueReadBuffer(self.id, buffer.id, blocking, offset, size, buffer.data, (eventWaitList != nil) ? cl_uint(eventWaitListIDs!.count) : 0,
                          $0,
                          &kernelEvent)
    }
    try CLError.check(status)
    
    
    if event != nil {
      event!.set(kernelEvent)
    }
  }
}