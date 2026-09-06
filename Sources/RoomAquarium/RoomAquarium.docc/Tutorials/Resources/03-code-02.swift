import SwiftUI
import RealityKit
import AquariumContent

struct AquariumView: View {
    // 화면이 유지되는 동안 같은 트래킹 세션을 사용하기 위해 @State로 저장합니다.
    @State private var trackingSession = SpatialTrackingSession()

    var body: some View {
        RealityView { content in
            // 가상 카메라 대신 후면 카메라 영상을 배경으로 씁니다.
            content.camera = .spatialTracking

            if let scene = try? await Entity(named: "Scene",
                                             in: aquariumContentBundle) {
                content.add(scene)
            }
        }
    }
}

#Preview {
    AquariumView()
}
