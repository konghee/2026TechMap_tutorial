import SwiftUI
import RealityKit
import AquariumContent

struct AquariumView: View {
    @State private var trackingSession = SpatialTrackingSession()
    @State private var isStartled = false

    /// RCP 타임라인의 Notification 액션은 전부 이 이름 하나로 날아옵니다.
    /// 어느 액션인지는 userInfo의 Identifier로 구분합니다.
    private let notificationTrigger = NotificationCenter.default
        .publisher(for: Notification.Name("RealityKit.NotificationTrigger"))

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
        .gesture(
            TapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    _ = value.entity.applyTapForBehaviors()
                }
        )
        // 타임라인이 정한 시각에 알림이 도착합니다.
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
                Text("해마가 놀랐어요!")
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

#Preview {
    AquariumView()
}
