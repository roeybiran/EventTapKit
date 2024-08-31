import Carbon

struct MachPortLive: MachPortProtocol {
  func createEventTap(tap: CGEventTapLocation, place: CGEventTapPlacement, options: CGEventTapOptions, eventsOfInterest: CGEventMask, callback: CGEventTapCallBack, userInfo: UnsafeMutableRawPointer?) -> CFMachPort? {
    CGEvent.tapCreate(tap: tap, place: place, options: options, eventsOfInterest: eventsOfInterest, callback: callback, userInfo: userInfo)
  }

  func getEnabled(tap: CFMachPort) -> Bool {
    CGEvent.tapIsEnabled(tap: tap)
  }

  func setEnabled(tap: CFMachPort, isEnabled: Bool) {
    CGEvent.tapEnable(tap: tap, enable: isEnabled)
  }

  func createRunLoopSource(port: CFMachPort, order: CFIndex) -> CFRunLoopSource {
    CFMachPortCreateRunLoopSource(kCFAllocatorDefault, port, order)
  }

  func remove(source: CFRunLoopSource, from runLoop: CFRunLoop, mode: CFRunLoopMode) {
    CFRunLoopRemoveSource(runLoop, source, mode)
  }

  func invalidate(machPort: CFMachPort) {
    CFMachPortInvalidate(machPort)
  }

  func add(source: RunLoopSource, to runLoop: CFRunLoop, mode: CFRunLoopMode) {
    CFRunLoopAddSource(runLoop, source, mode)
  }

  typealias MachPort = CFMachPort
  typealias RunLoopSource = CFRunLoopSource
}
