import SwiftUI
import RealityKit
import RealityKitContent

struct AquariumView: View {
    /// 주위에 풀어놓을 해마 마릿수.
    private static let seahorseCount = 8

    @State private var trackingSession = SpatialTrackingSession()
    @State private var isStartled = false

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
                print("이 기기에서 쓸 수 없는 기능: \(unavailable.sceneUnderstanding)")
            }
            #endif

            guard let scene = try? await Entity(named: "Scene",
                                                in: realityKitContentBundle) else { return }
            content.add(scene)

            // 한 마리를 세워두는 대신, 이걸 원본 삼아 복제해서 주위에 풀어놓습니다.
            // 원본은 계층에서 빼둡니다. 안 그러면 원본까지 한 마리로 보입니다.
            if let template = scene.findEntity(named: "Seahorse") {
                let parent = template.parent
                template.removeFromParent()

                for _ in 0..<Self.seahorseCount {
                    let seahorse = template.clone(recursive: true)
                    seahorse.position = Self.scatter()
                    parent?.addChild(seahorse)
                }
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
        .onReceive(notificationTrigger) { output in
            guard let name = output.userInfo?["RealityKit.NotificationTrigger.Identifier"]
                    as? String else { return }
            switch name {
            case "SeahorseStartled": isStartled = true
            case "SeahorseCalmed":   isStartled = false
            default: break
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
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isStartled)
    }

    /// 원점을 중심으로 한 도넛(안쪽은 비움) 위의 임의 지점을 고릅니다.
    /// 안쪽을 비워두지 않으면 해마가 내 얼굴을 뚫고 지나갑니다.
    private static func scatter() -> SIMD3<Float> {
        let radius = Float.random(in: 0.3...0.8)
        let angle = Float.random(in: 0..<(2 * .pi))
        return [radius * sin(angle), Float.random(in: -0.2...0.5), radius * cos(angle)]
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
