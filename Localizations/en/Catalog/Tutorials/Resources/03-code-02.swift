import SwiftUI
import RealityKit
import RealityKitContent

struct AquariumView: View {
    @State private var trackingSession = SpatialTrackingSession()

    var body: some View {
        RealityView { content in
            // The simulator has neither passthrough nor world tracking, so skip it all.
            #if !targetEnvironment(simulator)
            content.camera = .spatialTracking

            let unavailable = await trackingSession.run(
                .init(tracking: [], sceneUnderstanding: [.occlusion, .shadow])
            )
            if let unavailable {
                print("Unavailable on this device: \(unavailable.sceneUnderstanding)")
            }
            #endif

            if let scene = try? await Entity(named: "Scene",
                                             in: realityKitContentBundle) {
                content.add(scene)
            }
        }
        .modifier(SimulatorCameraControls())
    }
}

/// The simulator has no passthrough, so let the virtual camera be dragged around.
/// On a device, camera controls cannot be combined with passthrough
/// (.spatialTracking), so attach nothing — you move the iPad itself to look around.
private struct SimulatorCameraControls: ViewModifier {
    func body(content: Content) -> some View {
        #if targetEnvironment(simulator)
        content.realityViewCameraControls(.orbit)
        #else
        content
        #endif
    }
}

#Preview {
    AquariumView()
}
