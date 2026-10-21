import SwiftUI
import RealityKit
import AquariumContent

struct AquariumView: View {
    var body: some View {
        RealityView { content in
            // Load the "Scene" you saved in RCP.
            if let scene = try? await Entity(named: "Scene",
                                             in: aquariumContentBundle) {
                content.add(scene)
            }
        }
        // Adds camera controls: drag to orbit, pinch to zoom.
        .realityViewCameraControls(.orbit)
    }
}

#Preview {
    AquariumView()
}
