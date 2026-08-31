import SwiftUI
import RealityKit
import RealityKitContent

struct AquariumView: View {
    // The view has to hold the session so tracking stays alive while it is on screen.
    @State private var trackingSession = SpatialTrackingSession()

    var body: some View {
        RealityView { content in
            // Use the rear camera feed as the background instead of a virtual camera.
            content.camera = .spatialTracking

            // Turn on occlusion, so real objects hide the seahorse, and floor shadows.
            // These only switch on for devices that can reconstruct the scene (LiDAR).
            let unavailable = await trackingSession.run(
                .init(tracking: [], sceneUnderstanding: [.occlusion, .shadow])
            )
            if let unavailable {
                print("Unavailable on this device: \(unavailable.sceneUnderstanding)")
            }

            if let scene = try? await Entity(named: "Scene",
                                             in: realityKitContentBundle) {
                content.add(scene)
            }
        }
    }
}

#Preview {
    AquariumView()
}
