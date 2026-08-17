/*
Abstract:
해마의 설정값. RCP 인스펙터에 그대로 노출되는 노브들입니다.

이 파일은 앱 타깃이 아니라 **RealityKitContent 패키지 안**에 있어야 합니다.
Reality Composer Pro는 이 패키지의 Swift 소스를 훑어서 `Component, Codable`을
찾아내고, 그 저장 프로퍼티를 인스펙터 UI로 만들어 줍니다. 앱 타깃에 두면
RCP는 이 타입을 영영 볼 수 없습니다.
*/

import RealityKit

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
