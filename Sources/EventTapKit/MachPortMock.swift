import Carbon

struct Call {
  let funcName: String
  let args: Any

  init(_ funcName: String, _ args: Any) {
    self.funcName = funcName
    self.args = args
  }
}

final class MachPortMock: MachPortProtocol {
  var calls = [Call]()

  var _createEventTap: (
    _ tap: CGEventTapLocation,
    _ place: CGEventTapPlacement,
    _ options: CGEventTapOptions,
    _ eventsOfInterest: CGEventMask,
    _ callback: CGEventTapCallBack,
    _ userInfo: UnsafeMutableRawPointer?
  ) -> String? = { _, _, _, _, _, _ in fatalError() }

  func createEventTap(
    tap: CGEventTapLocation,
    place: CGEventTapPlacement,
    options: CGEventTapOptions,
    eventsOfInterest: CGEventMask,
    callback: CGEventTapCallBack,
    userInfo: UnsafeMutableRawPointer?
  ) -> String? {
    calls.append(.init("createEventTap", [
      tap,
      place,
      options,
      eventsOfInterest,
      callback,
      userInfo as Any,
    ]))
    return _createEventTap(tap, place, options, eventsOfInterest, callback, userInfo)
  }

  var _getEnabled: (_ tap: String) -> Bool = { _ in fatalError() }

  func getEnabled(tap: String) -> Bool {
    calls.append(.init("getEnabled", tap))
    return _getEnabled(tap)
  }

  var _setEnabled: (_ tap: String, _ isEnabled: Bool) -> Void = { _, _ in fatalError() }

  func setEnabled(tap: String, isEnabled: Bool) {
    calls.append(.init("setEnabled", [tap, isEnabled]))
    // _setEnabled(tap, isEnabled)
  }

  var _invalidate: (_ machPort: String) -> Void = { _ in fatalError() }

  func invalidate(machPort: String) {
    calls.append(.init("invalidate", machPort as Any))
    // _invalidate(machPort)
  }

  var _createRunLoopSource: (
    _ port: String,
    _ order: CFIndex
  ) -> String = { _, _ in fatalError() }

  func createRunLoopSource(port: String, order: CFIndex) -> String {
    calls.append(.init("createRunLoopSource", [port as Any, order]))
    return _createRunLoopSource(port, order)
  }

  var _add: (
    _ source: String,
    _ runLoop: CFRunLoop,
    _ mode: CFRunLoopMode
  ) -> Void = { _, _, _ in fatalError() }

  func add(source: String, to runLoop: CFRunLoop, mode: CFRunLoopMode) {
    calls.append(.init("add", [source as Any, runLoop as Any, mode as Any]))
    // _add(source, runLoop, mode)
  }

  var _remove: (
    _ source: String,
    _ runLoop: CFRunLoop,
    _ mode: CFRunLoopMode
  ) -> Void = { _, _, _ in fatalError() }

  func remove(source: String, from runLoop: CFRunLoop, mode: CFRunLoopMode) {
    calls.append(.init("remove", [source as Any, runLoop as Any, mode as Any]))
    // _remove(source, runLoop, mode)
  }

  typealias MachPort = String
  typealias RunLoopSource = String
  typealias Allocator = String
}
