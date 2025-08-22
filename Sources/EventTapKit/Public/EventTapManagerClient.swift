import Carbon
import Dependencies
import DependenciesMacros
import RBKit

// MARK: - EventTapManagerClient

@DependencyClient

public struct EventTapManagerClient {
  public typealias ID = String
  public typealias Callback = (_ type: CGEventType, _ event: CGEvent) -> CGEvent?

  public var start: (_ id: ID, _ events: [CGEventType], _ place: CGEventTapPlacement, _ callback: @escaping Callback) -> Void
  public var stop: (_ id: ID) -> Void
  public var getIsEnabled: (_ id: ID) -> Bool = { _ in false }
  public var setIsEnabled: (_ id: ID, _ enabled: Bool) -> Void
}

// MARK: DependencyKey

extension EventTapManagerClient: DependencyKey {
  public static let liveValue: Self = {
    let instance = EventTapManager(
      cgEventClient: CGEventClientLive(),
      cfMachPortClient: CFMachPortClientLive(),
      cfRunLoopClient: CFRunLoopClientLive())
    return Self(
      start: instance.start,
      stop: instance.stop,
      getIsEnabled: instance.getIsEnabled,
      setIsEnabled: instance.setIsEnabled)
  }()

  public static let testValue = Self()
}

extension DependencyValues {
  public var eventTapClient: EventTapManagerClient {
    get { self[EventTapManagerClient.self] }
    set { self[EventTapManagerClient.self] = newValue }
  }
}
