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
                print("이 기기에서 쓸 수 없는 기능: \(unavailable.sceneUnderstanding)")
            }
            #endif

            if let scene = try? await Entity(named: "Scene",
                                             in: realityKitContentBundle) {
                content.add(scene)
            }
        }
        .modifier(SimulatorCameraControls())
        // 탭 처리가 이게 전부입니다.
        //
        // 충돌 도형(Collision)과 입력 타깃(Input Target), 그리고 "탭하면
        // TapSeahorse 타임라인을 재생하라"는 배선이 전부 RCP에 저작돼 있어서,
        // 코드는 "탭이 일어났다"만 전달하면 됩니다.
        //
        // 무엇이 일어날지는 이 코드가 모릅니다. 연출을 바꾸고 싶으면
        // Xcode가 아니라 RCP에서 타임라인을 고치면 됩니다.
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
