import SwiftUI
import RealityKit
import AquariumContent

struct AquariumView: View {
    @State private var trackingSession = SpatialTrackingSession()

    var body: some View {
        RealityView { content in
            content.camera = .spatialTracking

            let unavailable = await trackingSession.run(
                .init(tracking: [], sceneUnderstanding: [.occlusion, .shadow])
            )

            if let scene = try? await Entity(named: "Scene",
                                             in: realityKitContentBundle) {
                content.add(scene)
            }
        }
        .modifier(SimulatorCameraControls())
    }
}

#Preview {
    AquariumView()
}
