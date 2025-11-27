//

import Dependencies
import EventTapKit
import SwiftUI

struct ContentView: View {
  @Dependency(\.eventTapClient) var tapClient

  var body: some View {
    VStack {
      Image(systemName: "globe")
        .imageScale(.large)
        .foregroundStyle(.tint)
      Text("Hello, world!")
    }
    .padding()
    .onAppear {
      tapClient.start(id: "foo", events: [.keyDown], place: .headInsertEventTap) { _, event in
        print("key", event)
        return event
      }
      tapClient.start(id: "scrollWheel", events: [.scrollWheel], place: .headInsertEventTap) { _, event in
        print("scroll", event)
        return nil
      }
    }
  }
}

#Preview {
  ContentView()
}
