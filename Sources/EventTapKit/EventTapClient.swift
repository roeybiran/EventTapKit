import Carbon
import Dependencies
import DependenciesMacros

@DependencyClient
public struct EventTapClient {
  public typealias Callback = (_ type: CGEventType, _ event: CGEvent) -> CGEvent?
  public var start: (_ events: [CGEventType], _ place: CGEventTapPlacement, _ callback: @escaping Callback) -> Void
  public var stop: () -> Void
  public var getIsEnabled: () -> Bool = { false }
  public var setIsEnabled: (_ enabled: Bool) -> Void
}

extension EventTapClient: DependencyKey {
  public static let liveValue: Self = {
    let instance = EventTapManager(manager: MachPortLive())
    return Self(
      start: { events, place, callback in
        instance.start(eventsOfInterest: events, place: place, internalCallback: _callback, clientCallback: callback)
      },
      stop: instance.stop,
      getIsEnabled: instance.getIsEnabled,
      setIsEnabled: instance.setIsEnabled
    )
  }()

  public static let testValue = Self()
}

extension DependencyValues {
  public var eventTapClient: EventTapClient {
    get { self[EventTapClient.self] }
    set { self[EventTapClient.self] = newValue }
  }
}

// see CGEventTapCallback
func _callback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, userInfo: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
  let instance = Unmanaged<EventTapManager<MachPortLive>>.fromOpaque(userInfo!).takeUnretainedValue()
  return instance.eventHandler(type: type, event: event).map { Unmanaged.passUnretained($0) }
}

