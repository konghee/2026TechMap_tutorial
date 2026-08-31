# RoomAquarium

RealityKit과 Reality Composer Pro로 **아이패드 방 안에 아쿠아리움을 만드는** DocC 튜토리얼 카탈로그입니다. 대상 독자는 RealityKit을 처음 접하는 완전 초보자입니다.

WWDC24 세션 [Compose interactive 3D content in Reality Composer Pro](https://developer.apple.com/videos/play/wwdc2024/10102/)와 그 [공식 샘플](https://developer.apple.com/documentation/realitykit/composing-interactive-3d-content-with-realitykit-and-reality-composer-pro)이 보여주는 구조를 그대로 따릅니다.

## 관통 주제 — RCP와 코드의 경계

| | 맡는 일 |
|---|---|
| **Reality Composer Pro** | 모양·배치·컴포넌트·연출과 그 타이밍 |
| **코드** | 여러 개를 관리하고 매 프레임 상태를 굴리는 일 |
| **비헤이비어** | 코드 → RCP (`applyTapForBehaviors()`) |
| **Notification 액션** | RCP → 코드 (`NotificationCenter`) |

## 커리큘럼

| 챕터 | 내용 | 필요 환경 |
|---|---|---|
| 1. Scene 조립하기 · *Building the Scene* | RCP 패키지 생성·연결, 씬 조립, 충돌 도형 저작, RealityView 로딩 | 시뮬레이터 가능 |
| 2. 살아 움직이게 하기 · *Bringing It to Life* | 파티클 기포, 타임라인 + 비헤이비어 유영, 오디오 재료 — **코드 0줄** | 시뮬레이터 가능 |
| 3. 내 방에 놓기 · *Placing It in Your Room* | 카메라 패스스루, RCP 저작 탭 연출, Notification 왕복 | 패스스루만 **실기기(iPad)** |
| 4. 여러 마리로 늘리기 · *Many of Them* | 복제, 설정/런타임 컴포넌트 분리, System, RCP에서 성격 조절, **마커로 마릿수·배치까지 RCP 이관** | 시뮬레이터 가능 |

## 요구사항

- **Xcode 26 기준으로 작성**했습니다 (Reality Composer Pro 내장). 그 이전 버전에서도 코드는 동작하지만 RCP의 패널 위치와 메뉴 이름이 다를 수 있습니다.
- 배포 대상: iOS / iPadOS **18 이상** (`RealityView`, `targetedToAnyEntity()`, `applyTapForBehaviors()`, `SpatialTrackingSession`)
- Chapter 3의 카메라 패스스루: 실제 iPad. 탭과 알림은 시뮬레이터에서도 확인됩니다.
- 문서 빌드: Swift 5.9+ 또는 macOS 러너의 GitHub Actions

## 에셋

튜토리얼은 완성 프로젝트의 에셋을 그대로 씁니다. 독자가 직접 3D 모델이나 음원을 구하러 다닐 필요가 없습니다.

- `seahorse.usdz` — 해마 모델, 유영 애니메이션 내장
- `WhaleCry.usdz` — 고래 울음소리

내려받는 곳: [konghee/SpatialComputing](https://github.com/konghee/SpatialComputing)

## 로컬 미리보기

한국어:

```bash
swift package --disable-sandbox preview-documentation --target RoomAquarium
```

영어(오버레이를 덮어쓴 임시 트리에서 빌드합니다):

```bash
./Tools/overlay-en.sh .build/en-preview
cd .build/en-preview && swift package --disable-sandbox preview-documentation --target RoomAquarium
```

브라우저에서 `http://localhost:8080/tutorials/roomaquarium` 접속.

> 미리보기에는 `Web/site.js`가 주입되지 않습니다. **UI 한글화와 언어 전환
> 버튼은 미리보기에서 보이지 않습니다.** 그것까지 확인하려면 아래 "정적
> 빌드로 통째로 확인하기"를 쓰세요.

## 문서 외형 손보기

손댈 수 있는 곳은 두 군데입니다.

| 파일 | 바꿀 수 있는 것 |
|---|---|
| `RoomAquarium.docc/theme-settings.json` | 색, 글꼴 **패밀리**, 모서리 반경 (`--color-*`, `--typography-*`, `--border-radius`) |
| `Web/site.js` | 그 밖의 모든 CSS — 글자 **크기**, 행간, 한글 줄바꿈 — 과 UI 한글화, 언어 전환 버튼 |

`theme-settings.json`의 `theme.color.tutorial-hero-background` 같은 키는 그대로
CSS 변수 `--color-tutorial-hero-background`가 됩니다. 값에 `{"light": ..., "dark": ...}`를
쓰면 라이트/다크를 따로 줄 수 있습니다. 이 파일은 렌더러가 런타임에 직접
fetch 하므로 별도 플래그가 필요 없습니다.

글자 크기는 `Web/site.js`의 `:root { font-size: 18px }` 한 줄이 기준점입니다.
DocC의 모든 치수가 `rem`이라 이 값만 바꾸면 전체가 같은 비율로 커지고 작아집니다
(렌더러 기본값은 17px).

> **`header.html`(커스텀 헤더)은 쓰지 않습니다.** DocC의
> `--experimental-enable-custom-templates`는 그 파일을
> `<template id="custom-header">` 안에 넣는데, `custom-header` 커스텀 엘리먼트를
> 정의하는 코드가 렌더러에 없고 `<template>` 안의 `<script>`는 실행되지
> 않습니다. 즉 아무 효과가 없습니다. 그래서 배포 워크플로가 `Web/site.js`를
> 각 `index.html`의 앱 번들 **앞에** 직접 끼워 넣습니다.

## 한국어 / 영어

한 리포지토리에서 두 벌을 빌드합니다. 하위 경로가 같아서 언어 전환은
`/en` 세그먼트를 넣고 빼는 것으로 끝납니다.

| | 주소 | 소스 |
|---|---|---|
| 한국어 | `/2026TechMap_tutorial/tutorials/roomaquarium/...` | `Sources/RoomAquarium/RoomAquarium.docc/` |
| English | `/2026TechMap_tutorial/en/tutorials/roomaquarium/...` | 위 카탈로그 + `Localizations/en/Catalog/` 오버레이 |

영어는 **오버레이**입니다. `Localizations/en/Catalog/`에 넣은 파일만 한국어
카탈로그를 덮어쓰고, 없는 것(아직 번역하지 않은 챕터, 이미지 대부분,
`theme-settings.json`)은 한국어 원본을 그대로 상속합니다.

현재 번역된 것은 **랜딩 페이지와 Chapter 3**입니다. Chapter 1 / 2 / 4는
영어 빌드에서도 한국어 본문이 나옵니다 — 번역하려면 같은 경로에 파일을
추가하기만 하면 됩니다.

```
Localizations/en/Catalog/
  RoomAquarium.md
  RoomAquarium.tutorial
  Tutorials/
    03-PlacingInYourRoom.tutorial
    Resources/
      03-code-01…04.swift      주석이 영어인 코드
      03-section3.png          영어 다이어그램 (같은 파일명으로 덮어씀)
```

한글 텍스트가 그려진 다이어그램은 `Tools/MakeDiagrams.swift`가 만듭니다.
두 번째 인자로 언어를 줍니다.

```bash
cd Tools
xcrun --toolchain XcodeDefault swiftc -O MakeDiagrams.swift -o makediagrams
./makediagrams ../Sources/RoomAquarium/RoomAquarium.docc/Tutorials/Resources
./makediagrams ../Localizations/en/Catalog/Tutorials/Resources en
```

### UI 언어는 어떻게 한글이 되었나

DocC 렌더러에는 한국어(`ko-KR`) 메시지 카탈로그가 **이미 통째로 들어있습니다**
(`예상 시간`, `{number}단계`, `다음` …). 다만 기본 locale이 `en-US`로 고정되어
있어 쓰이지 않을 뿐입니다. `Web/site.js`가 하는 일:

1. vue-i18n의 locale을 `ko-KR`로 바꾸고 **setter를 막습니다.** 라우터가
   페이지를 옮길 때마다 `en-US`로 되돌리기 때문에, 막지 않으면 챕터를
   클릭하는 순간 영어로 돌아갑니다. `<html lang>`도 같은 이유로 붙잡아 둡니다.
2. `Chapter {number}` / `Section {number}` 두 라벨만 다시 영어로 덮어씁니다.
   본문에서 "Chapter 2에서 등록한"처럼 쓰기 때문입니다.
3. i18n을 거치지 않고 DocC가 JSON에 직접 박아 넣는 문구
   (`Get started`, `Documentation` / `Videos` / `Sample Code`, `View more`,
   알림 상자의 `Note` / `Important`, 소요 시간 `2hr 35min`)를 치환합니다.

### 정적 빌드로 통째로 확인하기

`site.js` 주입까지 포함해 배포본과 같은 것을 로컬에서 보려면:

```bash
# 워크플로와 같은 4단계
swift package --allow-writing-to-directory docs generate-documentation \
  --target RoomAquarium --disable-indexing --transform-for-static-hosting \
  --hosting-base-path 2026TechMap_tutorial --output-path docs

./Tools/overlay-en.sh /tmp/en
(cd /tmp/en && swift package --allow-writing-to-directory "$PWD/../docs" generate-documentation \
  --target RoomAquarium --disable-indexing --transform-for-static-hosting \
  --hosting-base-path 2026TechMap_tutorial/en --output-path "$OLDPWD/docs/en")

cp Web/site.js docs/site.js && cp Web/site.js docs/en/site.js
find docs -name index.html -print0 | xargs -0 sed -i '' \
  -e 's#<script defer="defer" src="\([^"]*\)js/chunk-vendors#<script defer="defer" src="\1site.js"></script><script defer="defer" src="\1js/chunk-vendors#'

# baseUrl 이 절대경로라 경로를 맞춰서 띄워야 합니다
mkdir -p /tmp/serve && ln -sfn "$PWD/docs" /tmp/serve/2026TechMap_tutorial
(cd /tmp/serve && python3 -m http.server 8765)
```

`http://localhost:8765/2026TechMap_tutorial/tutorials/roomaquarium` 접속.

## GitHub Pages 배포

배포 주소: **https://konghee.github.io/2026TechMap_tutorial/tutorials/roomaquarium**

1. 이 폴더를 **`2026TechMap_tutorial`이라는 이름의 Public 리포지토리**로 push 합니다.
   (`--hosting-base-path`가 `2026TechMap_tutorial`로 맞춰져 있으므로 리포 이름도 같아야
   경로가 일치합니다. 리포 이름을 바꾸면 워크플로의 `--hosting-base-path`와 루트
   리다이렉트 경로도 같이 바꿔야 합니다.)
2. 리포지토리 **Settings > Pages > Source**를 **GitHub Actions**로 설정합니다.
3. `main` 브랜치에 push 하면 `.github/workflows/deploy-docc.yml`이 자동으로 빌드·배포합니다.

> `--target RoomAquarium`은 **Swift 타깃 이름**이라 리포 이름과 별개입니다. 그대로 두세요.
> 문서 안의 경로 `/tutorials/roomaquarium`도 타깃 이름에서 나온 것이라 바뀌지 않습니다.

수동 배포를 원하면 위 "정적 빌드로 통째로 확인하기"의 명령을 그대로 쓰고
`docs/`를 올리면 됩니다. 한국어만 빌드한 채로 올리면 `/en`이 404가 되니
두 언어를 함께 빌드하세요.

## 스크린샷 교체 안내

`Sources/RoomAquarium/RoomAquarium.docc/Tutorials/Resources/` 안의 `*.png` 64장 중 **61장이 placeholder**입니다 (다이어그램 3장은 코드로 그려 완성). **각 이미지에 파일명과 "무엇을 찍어야 하는지"가 적혀 있으므로**, 열어 보고 그대로 캡처해 같은 이름으로 덮어쓰면 됩니다. 자세한 목록은 `CAPTURE-CHECKLIST.md`에 있습니다.

네이밍 규칙:

- `NN-intro` / `NN-sectionK` — 챕터 도입·섹션 대표 이미지
- `NN-sK-stepM` — 챕터 NN, 섹션 K, 스텝 M의 GUI 스크린샷
- `NN-sK-result` — 섹션 완료 결과 화면
- `chN-card` / `toc-intro` — 목차 카드와 표지

전체 59개 스텝 중 **40개가 이미지 전용 GUI 스텝**이므로, 실제 캡처 전까지는 튜토리얼이 절반만 완성된 상태입니다.

## 참조 무결성 검사

모든 `@Image(source:)`와 `@Code(file:)` 참조가 실제 파일과 1:1로 맞는지 확인합니다.

영어 오버레이는 없는 파일을 한국어 원본에서 상속하므로, 오버레이만 따로
검사하면 "누락"이 잘못 뜹니다. 오버레이를 씌운 트리에서 검사하세요.

```bash
./Tools/overlay-en.sh /tmp/en-check   # 영어를 검사할 때만
cd Sources/RoomAquarium/RoomAquarium.docc && python3 - <<'PY'
import re, pathlib
res = pathlib.Path("Tutorials/Resources")
imgs, codes = set(), set()
for t in pathlib.Path(".").rglob("*.tutorial"):
    s = t.read_text()
    imgs  |= set(re.findall(r'@Image\(\s*source:\s*"([^"]+)"', s))
    codes |= set(re.findall(r'@Code\([^)]*file:\s*"([^"]+)"', s))
png   = {p.stem for p in res.glob("*.png")}
swift = {p.name for p in res.glob("*.swift")}
print("누락 이미지:", sorted(imgs - png)   or "없음")
print("고아 이미지:", sorted(png - imgs)   or "없음")
print("누락 코드  :", sorted(codes - swift) or "없음")
print("고아 코드  :", sorted(swift - codes) or "없음")
PY
```

## 실기 검증된 사항

본문의 함정 설명은 전부 iPad Air 11" (M4) / iOS 26.5 시뮬레이터에서 실제로 재현·확인한 것입니다.

| 사항 | 확인 결과 |
|---|---|
| 컴포넌트·시스템 등록 위치 | `App.init()`이어야 함. `RealityView` 클로저에서 하면 `ComponentEvents.DidAdd`를 놓쳐 **에러 없이 아무것도 안 움직임** |
| `Notification`의 `SourceEntity` | 액션의 Target이 아니라 **타임라인을 재생한 엔티티**(우리 씬에서는 항상 `Root`) |
| RCP 타임라인과 `AnimationLibraryComponent` | 타임라인은 **이름으로 조회되지 않음.** `animations["SwimLoop"]`은 `nil` |
| `library.animations.map(_:)` | **크래시**(`EXC_BREAKPOINT`). 키 조회만 안전 |
| `clone(recursive:)` | 컴포넌트는 따라오지만 **비헤이비어는 안 따라옴** |
| 복제본의 `applyTapForBehaviors()` | **전부 `false`.** 복제본만 남기면 탭이 아무 데서도 안 먹음 → 원본을 씬에 남기고 폴백 |
| `clone(recursive:)`과 런타임 컴포넌트 | 진행 중인 런타임 컴포넌트까지 복사됨. 단 `DidAdd`가 `components.set`으로 덮어써서 결과는 정상 |
| `ComponentEvents.DidAdd` | 복제본에서도 정상 발동 (8마리 확인) |
| RCP Collision extent 단위 | 미터가 아니라 **엔티티 로컬 단위**. scale 0.01이면 로컬 12 = 12cm |
| `import RealityKit` + `import SwiftUI` | `some Scene`이 모호해짐 → `some SwiftUI.Scene` |
| Swift에서 지운 프로퍼티 | `Scene.usda`에는 옛 값이 남음. 무시되므로 무해하지만 파일을 읽을 때 헷갈림 |
| **Attachments API** | **iOS/iPadOS에 없음 — visionOS 전용.** iOS 26.5 SDK의 `_RealityKit_SwiftUI`에 `Attachment` 심볼 자체가 없음 |

## 아직 실기기에서 확인이 필요한 것

- Chapter 3의 패스스루(`content.camera = .spatialTracking`)와 `SpatialTrackingSession`의 오클루전·그림자
- Chapter 4 마지막 스텝에서 언급하는 `scene.raycast(mask: .sceneUnderstanding)` 벽 회피 (LiDAR 기기 전용, 본문 코드에는 포함되지 않음)

## placeholder 다시 만들기

스텝을 추가·삭제하면 목록을 본문에서 다시 뽑은 뒤 재생성합니다.

```bash
cd Tools
swiftc -O MakePlaceholder.swift -o makeph   # 최초 1회만
python3 sync-placeholder-list.py            # 본문에서 목록 재추출
./generate-placeholders.sh                  # 전체 재생성

# 한 장만 필요할 때
./makeph ../Sources/RoomAquarium/RoomAquarium.docc/Tutorials/Resources \
  "04-s2-step1|여기에 무엇을 찍을지 설명"
```

`sync-placeholder-list.py`는 `.tutorial`의 `@Image(source:alt:)`를 그대로 읽어 목록을 만들기 때문에, 본문과 목록이 어긋날 일이 없습니다. 더 이상 쓰이지 않는 PNG도 함께 알려 줍니다.

손으로 만든 이미지는 `HANDMADE` 집합에 등록해 두면 placeholder 재생성에서 제외됩니다. 현재 다이어그램 3장이 등록돼 있습니다.

## 다이어그램

스크린샷으로 찍을 수 없는 3장은 코드로 그렸습니다.

| 파일 | 내용 |
|---|---|
| `03-section3` | 타임라인 Notification 액션 → 코드 수신부 |
| `04-section1` | 원점을 비워둔 도넛 배치 (위에서 내려다본 그림) |
| `04-section2` | 설정 컴포넌트 / System / 런타임 컴포넌트의 관계 |

```bash
cd Tools
xcrun --toolchain XcodeDefault swiftc -O MakeDiagrams.swift -o makediagrams
./makediagrams ../Sources/RoomAquarium/RoomAquarium.docc/Tutorials/Resources

# 영어판 — 두 번째 인자로 언어를 줍니다.
# 아직 영어 라벨이 있는 03-section3 만 그립니다.
./makediagrams ../Localizations/en/Catalog/Tutorials/Resources en
```

900×560을 2배(1800×1120)로 렌더링해 레티나에서도 글자가 또렷합니다.

`04-section1` / `04-section2`는 아직 한글 라벨뿐이라 영어 모드에서 건너뜁니다.
Chapter 4를 번역할 때 `MakeDiagrams.swift`의 `L(ko, en)`으로 라벨을 채우고
실행부의 언어 분기를 풀면 됩니다.

> `swiftc`를 그냥 쓰면 실패할 수 있습니다. PATH에 Swift 개발 스냅샷 툴체인이 걸려 있으면
> stdlib를 못 찾기 때문에 `xcrun --toolchain XcodeDefault`를 붙입니다.
