import Carbon

protocol MachPortProtocol {
  associatedtype RunLoopSource: Hashable
  associatedtype MachPort: Hashable
  func createEventTap(tap: CGEventTapLocation, place: CGEventTapPlacement, options: CGEventTapOptions, eventsOfInterest: CGEventMask, callback: CGEventTapCallBack, userInfo: UnsafeMutableRawPointer?) -> MachPort?
  func getEnabled(tap: MachPort) -> Bool
  func setEnabled(tap: MachPort, isEnabled: Bool)
  func invalidate(machPort: MachPort)
  func createRunLoopSource(port: MachPort, order: CFIndex) -> RunLoopSource
  func add(source: RunLoopSource, to runLoop: CFRunLoop, mode: CFRunLoopMode)
  func remove(source: RunLoopSource, from runLoop: CFRunLoop, mode: CFRunLoopMode)
}
