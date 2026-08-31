import SwiftUI
import RealityKit
import RealityKitContent

struct AquariumView: View {
    @State private var trackingSession = SpatialTrackingSession()
    @State private var isStartled = false

    /// Every Notification action in an RCP timeline arrives under this one name.
    /// Which action fired is told apart by the Identifier in userInfo.
    private let notificationTrigger = NotificationCenter.default
        .publisher(for: Notification.Name("RealityKit.NotificationTrigger"))

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
        .gesture(
            TapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    _ = value.entity.applyTapForBehaviors()
                }
        )
        // The notification arrives at the time the timeline decided.
        .onReceive(notificationTrigger) { output in
            guard let name = output.userInfo?["RealityKit.NotificationTrigger.Identifier"]
                    as? String else { return }

            switch name {
            case "SeahorseStartled":
                isStartled = true
            case "SeahorseCalmed":
                isStartled = false
            default:
                break
            }
        }
        .overlay(alignment: .top) {
            if isStartled {
                Text("The seahorse is startled!")
                    .font(.title2.bold())
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(.thinMaterial, in: .capsule)
                    .padding(.top, 40)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isStartled)
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
