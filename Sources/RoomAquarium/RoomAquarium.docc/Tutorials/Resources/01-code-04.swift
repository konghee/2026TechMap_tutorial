import SwiftUI
import RealityKit
import AquariumContent

struct AquariumView: View {
    var body: some View {
        RealityView { content in
            // RCP에서 저장한 "Scene"을 불러옵니다.
            if let scene = try? await Entity(named: "Scene",
                                             in: realityKitContentBundle) {
                content.add(scene)
            }
        }
        // 드래그 회전 · 핀치 줌 카메라 조작이 생깁니다.
        .realityViewCameraControls(.orbit)
    }
}

#Preview {
    AquariumView()
}
