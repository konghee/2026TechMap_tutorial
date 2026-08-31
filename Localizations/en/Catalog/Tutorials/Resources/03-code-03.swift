import SwiftUI
import RealityKit
import RealityKitContent

struct AquariumView: View {
    @State private var trackingSession = SpatialTrackingSession()

    var body: some View {
        RealityView { content in
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
        // This is all there is to handling a tap.
        //
        // The collision shape, the input target, and the wiring that says "on tap,
        // play the TapSeahorse timeline" are all authored in RCP, so the code only
        // has to report that a tap happened.
        //
        // This code does not know what will happen next. To change the performance,
        // you edit the timeline in RCP — not Xcode.
        .gesture(
            TapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    _ = value.entity.applyTapForBehaviors()
                }
        )
    }
}

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
