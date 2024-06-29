import Carbon

/// EventTapManager
/// ## See Also:
/// - [All about macOS event observation](https://docs.google.com/presentation/d/1nEaiPUduh1vjks0rDVRTcJaEULbSWWh1tVdG2HF_XSU/htmlpresent)
/// - [Mac OS X Internals, Bonus Content, Chapter 2: An Overview of Mac OS X, Receiving, Filtering, and Modifying Key Presses and Releases](https://web.archive.org/web/20200503003001/http://osxbook.com/book/bonus/chapter2/alterkeys/)
/// - [github.com/pqrs-org/osx-event-observer-examples](https://github.com/pqrs-org/osx-event-observer-examples)
/// - https://github.com/lwouis/alt-tab-macos/blob/70ee681757628af72ed10320ab5dcc552dcf0ef6/src/logic/events/KeyboardEvents.swift#L84
/// - https://github.com/zenangst/KeyboardCowboy/blob/main/App/Sources/Core/Runners/MachPortCoordinator.swift
/// - https://github.com/zenangst/MachPort/blob/main/Sources/MachPort/MachPortEventController.swift
/// - https://github.com/rxhanson/Rectangle/blob/59080f5cdb23dee5f3ae3ad76b1e5ee62f344a37/Rectangle/Utilities/EventMonitor.swift#L75
/// - https://stackoverflow.com/questions/31891002/how-do-you-use-cgeventtapcreate-in-swift
/// - https://stackoverflow.com/questions/15573376/registereventhotkey-cmdtab-in-mountain-lion
/// - https://stackoverflow.com/questions/3237338/shortcutrecorder-record-cmdtab
/// - https://stackoverflow.com/questions/26673329/using-cgeventtapcreate-trouble-with-parameters-in-swift
/// - https://stackoverflow.com/questions/2969110/cgeventtapcreate-breaks-down-mysteriously-with-key-down-events
/// - https://github.com/JanX2/ShortcutRecorder
/// - https://github.com/numist/Switch/blob/7d5cda1411c939a5229c80e6b194ae79d6fc41ef/Switch/SWEventTap.m#L175
/// - https://stackoverflow.com/questions/33294620/how-to-cast-self-to-unsafemutablepointervoid-type-in-swift
final class EventTapManager<T: MachPortProtocol> {

  // MARK: Lifecycle

  init(
    manager: T,
    machPort: T.MachPort? = nil,
    runLoopSource: T.RunLoopSource? = nil
  ) {
    self.machPortManager = manager
    self.machPort = machPort
    self.runLoopSource = runLoopSource
  }

  deinit {
    stop()
  }

  // MARK: Internal

  func start(
    eventsOfInterest: [CGEventType],
    place: CGEventTapPlacement = .headInsertEventTap,
    internalCallback: CGEventTapCallBack,
    clientCallback: EventTapClient.Callback? = nil
  ) {
    let eventsOfInterestMask = (eventsOfInterest + [.tapDisabledByTimeout, .tapDisabledByUserInput])
      .map { 1 << $0.rawValue }
      .reduce(CGEventMask(), |)

    machPort = machPortManager.createEventTap(
      tap: .cgSessionEventTap,
      place: place,
      options: .defaultTap,
      eventsOfInterest: eventsOfInterestMask,
      callback: internalCallback,
      userInfo: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
    )
    runLoopSource = machPortManager.createRunLoopSource(port: machPort, order: 0)
    machPortManager.add(source: runLoopSource, to: CFRunLoopGetMain(), mode: .commonModes)

    self.clientCallback = clientCallback
  }

  func stop() {
    guard let runLoopSource, let machPort else { return }
    machPortManager.remove(source: runLoopSource, from: CFRunLoopGetMain(), mode: .commonModes)
    machPortManager.invalidate(machPort: machPort)
  }

  func getIsEnabled() -> Bool {
    guard let machPort else { return false }
    return machPortManager.getEnabled(tap: machPort)
  }

  func setIsEnabled(_ enabled: Bool) {
    guard let machPort else { return }
    machPortManager.setEnabled(tap: machPort, isEnabled: enabled)
  }

  func eventHandler(type: CGEventType, event: CGEvent) -> CGEvent? {
    clientCallback?(type, event)
  }

  // MARK: Private

  private let machPortManager: T
  private var machPort: T.MachPort?
  private var runLoopSource: T.RunLoopSource?
  private var clientCallback: EventTapClient.Callback?
}
