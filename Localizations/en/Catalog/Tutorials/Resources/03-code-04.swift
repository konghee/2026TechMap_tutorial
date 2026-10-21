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

            // Turn on occlusion, so real objects can hide the seahorse, and shadows.
            // Features the device doesn't support are dropped silently, so log them.
            if let unavailable = await trackingSession.run(
                .init(tracking: [], sceneUnderstanding: [.occlusion, .shadow])
            ) {
                print("Unavailable on this device:", unavailable.sceneUnderstanding)
            }

            do {
                let scene = try await Entity(named: "Scene",
                                             in: aquariumContentBundle)
                content.add(scene)
            } catch {
                // A misspelled name or a missing bundle lands here.
                print("Failed to load Scene:", error)
            }
        }
        .gesture(
            TapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    _ = value.entity.applyTapForBehaviors()
                }
        )
    }
}

#Preview {
    AquariumView()
}
