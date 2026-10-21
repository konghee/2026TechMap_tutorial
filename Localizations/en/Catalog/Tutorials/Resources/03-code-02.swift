import SwiftUI
import RealityKit
import AquariumContent

struct AquariumView: View {
    // Keep the session in @State so the same one stays alive while the view is on screen.
    @State private var trackingSession = SpatialTrackingSession()

    var body: some View {
        RealityView { content in
            // Use the rear camera feed as the background instead of a virtual camera.
            content.camera = .spatialTracking

            do {
                let scene = try await Entity(named: "Scene",
                                             in: aquariumContentBundle)
                content.add(scene)
            } catch {
                // A misspelled name or a missing bundle lands here.
                print("Failed to load Scene:", error)
            }
        }
    }
}

#Preview {
    AquariumView()
}
