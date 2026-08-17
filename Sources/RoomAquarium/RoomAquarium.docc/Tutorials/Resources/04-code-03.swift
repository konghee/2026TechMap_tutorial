/*
Abstract:
해마 한 마리의 설정값, 런타임 상태, 그리고 매 프레임 갱신을 맡는 시스템.

애플의 `HeroPlantComponent.swift`와 같은 구성입니다. 한 파일 안에 세 가지가
같이 있습니다.

  1. `SeahorseComponent`       — RCP 인스펙터에 뜨는 노브. Codable이어야 합니다.
  2. `SeahorseRuntimeComponent` — 프레임마다 바뀌는 상태. Codable이 아닙니다.
  3. `SeahorseSystem`          — 1이 붙는 순간 2를 만들고, 매 프레임 2를 굴립니다.

이 파일이 앱 타깃이 아니라 RealityKitContent 패키지 안에 있는 것이 핵심입니다.
Reality Composer Pro는 이 패키지의 Swift 소스를 훑어서 `Component, Codable`을
찾아내고, 그 저장 프로퍼티를 인스펙터 UI로 만들어 줍니다. 앱 타깃에 두면
RCP는 이 타입을 영영 볼 수 없습니다.
*/

import RealityKit
import Foundation
import Combine

// 해마의 기분. 평소에는 idle이고, 탭을 받으면 잠깐 startled가 됩니다.
public enum SeahorseState: String, Codable {
    case idle
    case startled
}

/// 해마의 설정값. **RCP 인스펙터에 그대로 노출됩니다.**
///
/// 여기에는 사람이 눈으로 보고 조절할 값만 둡니다. 매 프레임 변하는 값은
/// `SeahorseRuntimeComponent`가 따로 들고 있습니다. 이 분리가 애플 방식의
/// 핵심입니다 — 디자이너는 RCP에서 숫자만 만지고, 코드는 상태만 관리합니다.
///
/// 길이 단위는 미터입니다. 해마 prim 자체의 scale(0.01)은 자식 메시에만
/// 걸리고, `entity.position`은 부모인 `Root` 공간 = 미터이기 때문입니다.
public struct SeahorseComponent: Component, Codable {

    /// 앞으로 나아가는 속도 (m/s).
    public var swimSpeed: Float = 0.08

    /// 방향을 트는 속도 (rad/s). 클수록 급하게 꺾습니다.
    public var turnRate: Float = 0.6

    /// 위아래로 까딱이는 폭 (m).
    public var bobAmplitude: Float = 0.03

    /// 까딱이는 빠르기 (rad/s).
    public var bobSpeed: Float = 1.6

    /// 원점 기준 바깥 반경 (m). 이 밖으로는 못 나갑니다.
    ///
    /// 기본값은 **창 안에서 보는 시뮬레이터 기준**입니다. 카메라가 원점을
    /// 가까이서 보고 있어서, 이보다 크면 해마가 카메라 뒤로 돌아가 화면에서
    /// 사라집니다. 패스스루로 방 안에 서서 볼 때는 `2.0`쯤으로 키우세요 —
    /// **코드가 아니라 RCP 인스펙터에서** 바꾸면 됩니다.
    public var roamRadius: Float = 0.9

    /// 원점 기준 안쪽 반경 (m).
    /// 앱을 켠 자리 — 즉 내 얼굴이 있는 자리 — 는 비워둬야 뚫고 지나가지 않습니다.
    public var innerRadius: Float = 0.25

    /// 떠다닐 높이 범위 (m). 원점이 0이라 음수가 아래쪽입니다.
    public var minHeight: Float = -0.25
    public var maxHeight: Float = 0.6

    /// 경계에서 이만큼 남았을 때부터 미리 돌아섭니다 (m).
    public var softMargin: Float = 0.25

    /// 놀랐을 때 속도가 몇 배가 되는지.
    public var startledSpeedMultiplier: Float = 3.0

    /// 모델의 머리가 +Z를 향한다고 보고 계산합니다.
    /// 해마가 뒤로 헤엄치는 것처럼 보이면 이 값을 `3.14159`로 바꾸세요.
    public var modelYawOffset: Float = 0

    public init() {
    }
}

/// 해마의 런타임 상태.
///
/// `SeahorseComponent`와 달리 Codable이 아닙니다. RCP에 노출할 필요가 없고,
/// 노출해서도 안 되는 값들이기 때문입니다. 이 컴포넌트는 사람이 붙이지 않습니다 —
/// `SeahorseSystem`이 `SeahorseComponent`가 붙는 걸 보고 자동으로 만들어 줍니다.
@MainActor
public struct SeahorseRuntimeComponent: Component {

    /// RCP에서 조절한 설정값을 그대로 참조합니다.
    internal var settingsSource: SeahorseComponent?

    /// 현재 기분. 타임라인이 보낸 Notification을 받아 앱이 바꿔 줍니다.
    internal var currentState: SeahorseState = .idle

    /// 지금 향하고 있는 방향과 향하려는 방향 (rad, y축 회전).
    internal var heading: Float = 0
    internal var targetHeading: Float = 0

    /// 까딱임을 뺀 기준 높이와, 서서히 옮겨갈 목표 높이 (m).
    internal var baseHeight: Float = 0
    internal var targetHeight: Float = 0

    /// 까딱임의 위상. 마리마다 달라야 군무처럼 안 보입니다.
    internal var bobPhase: Float = 0

    /// 다음 방향 전환까지 남은 시간 (초).
    internal var timeToRetarget: Float = 0

    /// 초기화 전에 상태가 바뀌는 걸 막습니다.
    private var initialized = false

    public init() {
    }

    /// 해마가 지금 평온한지.
    public func isIdle() -> Bool {
        currentState == .idle
    }

    /// 기분을 바꿉니다. 앱이 타임라인 Notification을 받아 호출합니다.
    public mutating func setState(newState: SeahorseState) {
        guard initialized, newState != currentState else { return }
        currentState = newState
    }

    /// `SeahorseSystem`이 `SeahorseComponent`를 발견했을 때 한 번 호출합니다.
    public mutating func initialize(entity: Entity, settingsComponent: SeahorseComponent) {
        settingsSource = settingsComponent

        // 마리마다 다른 성격을 뽑습니다. 복제본이 여덟 마리여도
        // 각자 다른 방향, 다른 높이, 다른 박자로 시작합니다.
        heading = Float.random(in: 0..<(2 * .pi))
        targetHeading = heading
        baseHeight = entity.position.y
        targetHeight = Float.random(in: settingsComponent.minHeight...settingsComponent.maxHeight)
        bobPhase = Float.random(in: 0..<(2 * .pi))
        timeToRetarget = Float.random(in: 0...3)

        playSwimLoop(entity: entity)

        initialized = true
    }

    /// 유영 애니메이션을 재생 지점과 속도를 어긋나게 해서 재생합니다.
    ///
    /// RCP의 Behaviors(On Added To Scene)에 맡기지 않는 이유가 있습니다.
    /// 그러면 복제본 전부가 같은 프레임에 같은 지점에서 시작해 군무가 됩니다.
    /// 애플의 `HeroRobotRuntimeComponent.initialize`도 같은 자리에서
    /// `AnimationLibraryComponent`를 꺼내 직접 재생합니다.
    private func playSwimLoop(entity: Entity) {
        guard let clip = findSwimLoop(entity: entity) else {
            print("[Seahorse] 유영 애니메이션을 찾지 못했습니다. AnimationLibrary를 확인하세요.")
            return
        }

        let controller = entity.playAnimation(clip.repeat())
        controller.time = Double.random(in: 0...2)
        controller.speed = Float.random(in: 0.8...1.2)
    }

    /// 재생할 유영 클립을 찾습니다.
    ///
    /// > 확인된 사실: **RCP에서 만든 타임라인은 `AnimationLibraryComponent`에
    /// > 타임라인 이름으로 올라오지 않습니다.** 해마의 라이브러리에도, 씬 루트의
    /// > 라이브러리에도 `"SwimLoop"` 키는 없습니다. 타임라인을 재생하는 공식
    /// > 경로는 RCP의 Behaviors(그리고 `applyTapForBehaviors()`)뿐입니다.
    /// >
    /// > 그래서 코드에서 마리마다 재생 시점을 어긋나게 하려면 타임라인이 아니라
    /// > **usdz에 들어 있는 원본 클립**을 직접 재생해야 합니다.
    ///
    /// 혹시 향후 RCP가 타임라인을 라이브러리로 노출하게 되면 그쪽을 우선 씁니다.
    ///
    /// - Warning: `library.animations`를 `map`이나 `forEach`로 훑으면
    ///   RealityKit 내부에서 트랩이 납니다. 키 조회(`animations["..."]`)만 쓰세요.
    private func findSwimLoop(entity: Entity) -> AnimationResource? {
        if let library = entity.components[AnimationLibraryComponent.self],
           let clip = library.animations["SwimLoop"] {
            return clip
        }

        return entity.availableAnimations.first
    }
}

/// `SeahorseComponent`가 붙은 엔티티를 찾아 런타임 컴포넌트를 만들고,
/// 매 프레임 해마를 조금씩 움직입니다.
///
/// System은 "매 프레임 실행되는 규칙"입니다. 우리가 부르는 게 아니라
/// RealityKit이 프레임마다 `update`를 불러 줍니다.
@MainActor
public class SeahorseSystem: System {

    /// 런타임 컴포넌트를 가진 엔티티만 골라내는 질의입니다.
    private static let query = EntityQuery(where: .has(SeahorseRuntimeComponent.self))

    private var subscription: Cancellable?

    public required init(scene: Scene) {
        // 씬 어딘가에 SeahorseComponent가 붙는 순간을 구독합니다.
        // RCP에서 붙인 것도, 코드에서 복제해 추가한 것도 모두 여기로 옵니다.
        // 이 덕분에 뷰 코드에는 "런타임 상태를 만들어라"는 문장이 한 줄도 없습니다.
        subscription = scene.subscribe(
            to: ComponentEvents.DidAdd.self,
            componentType: SeahorseComponent.self, { event in
                self.createRuntimeComponent(entity: event.entity)
            }
        )
    }

    public func update(context: SceneUpdateContext) {
        let deltaTime = Float(context.deltaTime)
        guard deltaTime > 0 else { return }

        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            entity.components[SeahorseRuntimeComponent.self]?.swim(entity: entity,
                                                                   deltaTime: deltaTime)
        }
    }

    private func createRuntimeComponent(entity: Entity) {
        guard let settingsComponent = entity.components[SeahorseComponent.self] else { return }

        var runtimeComponent = SeahorseRuntimeComponent()
        runtimeComponent.initialize(entity: entity, settingsComponent: settingsComponent)

        entity.components.set(runtimeComponent)
    }
}

// MARK: - 매 프레임 유영

extension SeahorseRuntimeComponent {

    /// 한 프레임만큼 해마를 움직입니다.
    ///
    /// 기준점은 바닥이 아니라 **월드 원점 — 앱을 켠 순간 기기가 있던 자리**입니다.
    /// 그래서 평면 인식을 기다릴 필요가 없고, 시뮬레이터에서도 똑같이 동작합니다.
    internal mutating func swim(entity: Entity, deltaTime: Float) {
        guard let settings = settingsSource else { return }

        // 놀란 동안에는 더 빨리 헤엄치고 더 급하게 까딱입니다.
        let agitation = currentState == .startled ? settings.startledSpeedMultiplier : 1
        var position = entity.position

        // 일정 시간마다 새 방향과 새 높이를 고릅니다.
        timeToRetarget -= deltaTime
        if timeToRetarget <= 0 {
            targetHeading = heading + Float.random(in: -1.4...1.4)
            targetHeight = Float.random(in: settings.minHeight...settings.maxHeight)
            timeToRetarget = Float.random(in: 2.5...6)
        }

        // 울타리를 벗어나려 하면 목표 방향을 덮어씁니다.
        // heading은 forward = (sin, 0, cos) 규약이라, 원점 쪽은 atan2(-x, -z)입니다.
        let distance = sqrt(position.x * position.x + position.z * position.z)
        if distance > settings.roamRadius - settings.softMargin {
            targetHeading = atan2(-position.x, -position.z)   // 안쪽으로
        } else if distance < settings.innerRadius {
            targetHeading = atan2(position.x, position.z)     // 바깥으로
        }

        // 목표 방향으로 조금씩 돌립니다. 각도 차를 -π...π로 접어야
        // 359도 돌아가는 대신 가까운 쪽으로 돕니다.
        var delta = (targetHeading - heading).truncatingRemainder(dividingBy: 2 * .pi)
        if delta > .pi { delta -= 2 * .pi }
        if delta < -.pi { delta += 2 * .pi }
        let maxTurn = settings.turnRate * deltaTime
        heading += max(-maxTurn, min(maxTurn, delta))

        // 앞으로 나아가고, 목표 높이로 서서히 떠오르거나 가라앉습니다.
        let forward = SIMD3<Float>(sin(heading), 0, cos(heading))
        position += forward * (settings.swimSpeed * agitation * deltaTime)
        baseHeight += (targetHeight - baseHeight) * min(1, deltaTime * 0.4)
        bobPhase += settings.bobSpeed * agitation * deltaTime

        // 울타리를 넘어선 경우를 대비한 최종 안전장치입니다.
        let radius = sqrt(position.x * position.x + position.z * position.z)
        if radius > settings.roamRadius {
            let shrink = settings.roamRadius / radius
            position.x *= shrink
            position.z *= shrink
        }
        baseHeight = min(settings.maxHeight, max(settings.minHeight, baseHeight))
        position.y = baseHeight + settings.bobAmplitude * sin(bobPhase)

        entity.position = position
        // 해마는 늘 서 있으므로 y축 회전만 줍니다.
        entity.orientation = simd_quatf(angle: heading + settings.modelYawOffset,
                                        axis: [0, 1, 0])
    }
}
