import XCTest
@testable import EventTapKit

func mockInternalCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, userInfo: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
  assertionFailure()
  return nil
}

final class EventTapManagerTests: XCTestCase {
  func test_start_calls() async throws {
    let mock = MachPortMock()
    let sut = EventTapManager(manager: mock)
    sut.start(eventsOfInterest: [.keyDown, .flagsChanged], internalCallback: mockInternalCallback)

    let a = 1 << CGEventType.keyDown.rawValue
    let b = 1 << CGEventType.flagsChanged.rawValue
    let c = 1 << CGEventType.tapDisabledByTimeout.rawValue
    let d = 1 << CGEventType.tapDisabledByUserInput.rawValue
    let mask = CGEventMask(a | b | c | d)

    let calls = mock.calls.map(\.args)

    XCTAssertEqual(calls.count, 3)
    let call0 = calls[0] as! Array<Any>
    XCTAssertEqual(call0.count, 6)
    XCTAssertEqual(call0[0] as! CGEventTapLocation, .cgSessionEventTap)
    XCTAssertEqual(call0[1] as! CGEventTapPlacement, .headInsertEventTap)
    XCTAssertEqual(call0[2] as! CGEventTapOptions, .defaultTap)
    XCTAssertEqual(call0[3] as! CGEventMask, mask)
    XCTAssertTrue(call0[4] is CGEventTapCallBack)
    XCTAssertEqual(call0[5] as! UnsafeMutableRawPointer, UnsafeMutableRawPointer(Unmanaged.passUnretained(sut).toOpaque()))
    let call1 = calls[1] as! Array<Any>
    XCTAssertEqual(call1.count, 2)
    XCTAssertEqual(call1[0] as! String, "TAP")
    XCTAssertEqual(call1[1] as! CFIndex, 0)
    let call2 = calls[2] as! Array<Any>
    XCTAssertEqual(call2.count, 3)
    XCTAssertEqual(call2[0] as! String, "RUN_LOOP_SOURCE")
    XCTAssertEqual((call2[1] as! CFRunLoop), CFRunLoopGetMain())
    XCTAssertEqual((call2[2] as! CFRunLoopMode), .commonModes)

    let funcs = mock.calls.map(\.funcName)

    XCTAssertEqual(funcs, ["createEventTap", "createRunLoopSource", "add"])
  }

  func test_stop_calls() async throws {
    let mock = MachPortMock()
    let sut = EventTapManager(manager: mock, machPort: "A", runLoopSource: "B")
    sut.stop()

    let calls = mock.calls.map(\.args)
    XCTAssertEqual(calls.count, 2)
    let call0 = calls[0] as! Array<Any>
    XCTAssertEqual(call0.count, 3)
    XCTAssertEqual(call0[0] as! String, "B")
    XCTAssertEqual((call0[1] as! CFRunLoop), CFRunLoopGetMain())
    XCTAssertEqual((call0[2] as! CFRunLoopMode), .commonModes)
    XCTAssertEqual(calls[1] as! String, "A")

    let funcNames = mock.calls.map(\.funcName)
    XCTAssertEqual(funcNames, ["remove", "invalidate"])
  }

  func test_getIsEnabled_calls() async throws {
    let mock = MachPortMock()
    mock._getEnabled = { _ in false }
    let sut = EventTapManager(manager: mock, machPort: "A")

    XCTAssertEqual(sut.getIsEnabled(), false)

    let args = mock.calls.map(\.args)
    XCTAssertEqual(args as! [String], ["A"])

    let funcs = mock.calls.map(\.funcName)
    XCTAssertEqual(funcs, ["getEnabled"])
  }

  func test_getIsEnabled_withoutMachPort_shouldNoOp() async throws {
    let mock = MachPortMock()
    let sut = EventTapManager(manager: mock)
    _ = sut.getIsEnabled()
    XCTAssertEqual(mock.calls.isEmpty, true)
  }

  func test_setIsEnabled_calls() async throws {
    let mock = MachPortMock()
    let sut = EventTapManager(manager: mock, machPort: "F")

    sut.setIsEnabled(true)

    let funcs = mock.calls.map(\.funcName)
    XCTAssertEqual(funcs, ["setEnabled"])

    let args = mock.calls.map(\.args) as! [[Any]]

    XCTAssertEqual(args.count, 1)
    XCTAssertEqual(args[0].count, 2)
    let c0 = args[0][0] as! String
    let c1 = args[0][1] as! Bool
    XCTAssertEqual(c0, "F")
    XCTAssertEqual(c1, true)
  }

  func test_setIsEnabled_withoutMachPort_shouldNoOp() async throws {
    let mock = MachPortMock()
    let sut = EventTapManager(manager: mock)
    sut.setIsEnabled(false)
    XCTAssertEqual(mock.calls.isEmpty, true)
  }

  func test_eventHandler_shouldCallClientCallback() async throws {
    let mock = MachPortMock()
    let sut = EventTapManager(manager: mock)
    var clientCallbackCalls = 0

    sut.start(eventsOfInterest: [], internalCallback: mockInternalCallback) { _, _ in
      clientCallbackCalls += 1
      return nil
    }

    _ = sut.eventHandler(type: .flagsChanged, event: .init(keyboardEventSource: nil, virtualKey: 0, keyDown: true)!)

    XCTAssertEqual(clientCallbackCalls, 1)
  }
}
