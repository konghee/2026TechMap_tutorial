import SwiftUI
import RealityKit
import RealityKitContent

@main
struct RoomAquariumApp: App {

    init() {
        // 등록은 **반드시 여기서** 해야 합니다. RealityView의 클로저 안에서
        // 등록하면 늦습니다.
        //
        // SeahorseSystem은 생성될 때 ComponentEvents.DidAdd를 구독해서,
        // 씬에 SeahorseComponent가 붙는 순간 런타임 컴포넌트를 만들어 줍니다.
        // 그런데 시스템이 실제로 생성되는 시점은 registerSystem()을 부른
        // 순간이 아니라 **씬이 처음 갱신될 때**입니다. RealityView 클로저 안에서
        // 등록하면 그 안의 content.add(scene)이 먼저 일어나 버려서,
        // 구독을 시작했을 땐 이벤트가 이미 지나간 뒤입니다.
        //
        // 증상이 고약합니다. 컴파일도 되고, 앱도 켜지고, 해마도 보이고,
        // 에러도 안 납니다. 그냥 아무것도 안 움직입니다.
        SeahorseComponent.registerComponent()
        SeahorseSystem.registerSystem()

        // 순서가 있습니다. SpawnPointSystem은 첫 프레임에 해마를 복제해 씬에
        // 넣는데, 그 복제본이 살아 움직이려면 그 순간 SeahorseSystem의
        // DidAdd 구독이 이미 걸려 있어야 합니다.
        //
        // 시스템은 등록 순서대로 만들어지고, 만들어지는 일(init)은 어느
        // 시스템의 update보다도 먼저 끝납니다. 그래서 아래에 두면 안전합니다.
        SpawnPointComponent.registerComponent()
        SpawnPointSystem.registerSystem()
    }

    // RealityKit에도 `Scene`이 있어서 그냥 `some Scene`이라고 쓰면 모호해집니다.
    var body: some SwiftUI.Scene {
        WindowGroup {
            AquariumView()
        }
    }
}
