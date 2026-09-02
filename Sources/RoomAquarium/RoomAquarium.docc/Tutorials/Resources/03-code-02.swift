import SwiftUI
import RealityKit
import AquariumContent

struct AquariumView: View {
    @State private var trackingSession = SpatialTrackingSession()

    var body: some View {
        RealityView { content in
            // 시뮬레이터에는 패스스루도 월드 트래킹도 없으므로 통째로 건너뜁니다.
            #if !targetEnvironment(simulator)
            content.camera = .spatialTracking

            let unavailable = await trackingSession.run(
                .init(tracking: [], sceneUnderstanding: [.occlusion, .shadow])
            )
            if let unavailable {
                print("이 기기에서 쓸 수 없는 기능: \(unavailable.sceneUnderstanding)")
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

/// 시뮬레이터에는 패스스루가 없으니 가상 카메라를 드래그로 돌려볼 수 있게 합니다.
/// 실기기에서는 카메라 컨트롤을 패스스루(.spatialTracking)와 같이 쓸 수 없으므로
/// 아무것도 붙이지 않습니다. 대신 아이패드를 직접 들고 움직여서 둘러봅니다.
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
