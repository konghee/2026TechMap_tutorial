# RoomAquarium

RealityKit과 Reality Composer Pro로 **아이패드 카메라 너머, 내 방 안에 아쿠아리움을 만드는**
DocC 튜토리얼입니다. RealityKit을 처음 접하는 사람을 위해 썼습니다.

**튜토리얼 보기 → [한국어](https://konghee.github.io/2026TechMap_tutorial/tutorials/roomaquarium) · [English](https://konghee.github.io/2026TechMap_tutorial/en/tutorials/roomaquarium)**

> **English** — A beginner's DocC tutorial for RealityKit and Reality Composer Pro: build
> an aquarium scene, bring it to life without code, then float it in your own room on iPhone or iPad
> and make it react to a tap. Read it at the English link above. The rest of this README is
> in Korean and covers how the catalog is built and maintained.

## 무엇을 만드나

| 챕터 | 내용 | 코드 | 필요 환경 |
|---|---|---|---|
| 1. Scene 조립하기 | iOS 앱 프로젝트와 RCP 패키지 연결, 해마 배치, `RealityView`로 불러오기 | `AquariumView` 작성 | 시뮬레이터 가능 |
| 2. 살아 움직이게 하기 | 파티클 기포, 타임라인 + 비헤이비어로 유영, 소리 준비 | **0줄** | 시뮬레이터 가능 |
| 3. 내 방에 놓기 | 카메라 패스스루, 오클루전·그림자, RCP에서 만든 탭 연출 | 몇 줄 추가 | **실기기(iPhone 또는 iPad)** |

전체를 관통하는 주제는 **RCP와 코드의 경계**입니다. 모양·배치·움직임·소리는 RCP에서 만들고,
코드는 화면에 띄우고 탭을 넘기는 일만 합니다(`applyTapForBehaviors()`). WWDC24 세션
[Compose interactive 3D content in Reality Composer Pro](https://developer.apple.com/videos/play/wwdc2024/10102/)와
그 [공식 샘플](https://developer.apple.com/documentation/realitykit/composing-interactive-3d-content-with-realitykit-and-reality-composer-pro)의
구조를 따릅니다.

## 요구사항

- **Xcode 26 기준으로 작성**했습니다(Reality Composer Pro 포함). 다른 버전에서는 RCP의 패널
  위치나 메뉴 이름이 다를 수 있습니다.
- 배포 대상 iOS / iPadOS **18 이상** (`RealityView`, `SpatialTrackingSession`,
  `applyTapForBehaviors()`)
- Chapter 3은 iPhone 또는 iPad 실기기가 필요합니다. 설명과 화면은 iPad 기준입니다.

에셋은 따로 준비하지 않아도 됩니다. 해마 모델은 Apple의
[AR Quick Look Gallery](https://developer.apple.com/augmented-reality/quick-look/)에서,
고래 울음소리는 Reality Composer Pro의 Asset Library에서 받습니다(Chapter 1에서 안내).

## 따라 하다 막히면

| 증상 | 원인과 해결 |
|---|---|
| Xcode에서 실행하자마자 멈추고 `Render` 스레드에 `__pthread_kill` | Xcode의 Metal 디버그 검사. **Edit Scheme > Run > Diagnostics**에서 **Metal API Validation**을 끕니다. 디버그 실행에서만 생깁니다. |
| 화면이 비어 있음 | Xcode 콘솔에 `Scene 로드 실패:`가 찍혔는지 봅니다. Scene 이름이나 패키지 연결(Chapter 1 섹션 1)을 확인합니다. |
| 해마가 실제 물체에 가려지지 않음 | 콘솔의 `지원되지 않는 기능:` 출력을 봅니다. 기기가 지원하지 않는 기능은 오류 없이 빠집니다. |
| 해마를 탭해도 반응이 없음 | Collision 영역이 해마를 감싸는지 확인합니다. RCP의 Collision 크기는 미터가 아니라 **엔티티 로컬 단위**라, scale이 0.01이면 로컬 12가 12cm입니다. |

---

## 리포지토리 구조

```
Sources/RoomAquarium/RoomAquarium.docc/   한국어 카탈로그 (원본)
  RoomAquarium.md                          랜딩 페이지
  RoomAquarium.tutorial                    목차
  Tutorials/0N-*.tutorial                  챕터 본문
  Tutorials/Resources/                     이미지(.png)와 코드 스니펫(.swift)
  theme-settings.json                      색·글꼴
Localizations/en/Catalog/                  영어 오버레이 (아래 "한국어 / 영어")
Web/site.js                                배포 시 주입하는 스크립트 (UI 한글화, 언어 전환 버튼)
Tools/                                     placeholder·다이어그램 생성기, 영어 오버레이 스크립트
.github/workflows/deploy-docc.yml          main에 push하면 GitHub Pages로 배포
CAPTURE-CHECKLIST.md                       스크린샷 현황과 촬영 규격
WORKLOG.md                                 무엇을 왜 바꿨는지 누적 기록
```

## 기여하는 법

1. 브랜치를 만들어 작업하고 PR을 엽니다. `main`에 merge되면 자동으로 배포됩니다.
2. 한국어 본문을 고쳤다면 영어 오버레이의 같은 파일도 고칩니다(아래).
3. PR 전에 두 가지를 확인합니다.
   - **DocC 경고 0**: 아래 "로컬 미리보기"의 빌드 명령을 한국어·영어 각각 돌려 `warning:`이
     없는지 봅니다. DocC는 Step 하나에 **문단 2개**까지만 받습니다. 설명을 더 넣으려면
     `> Tip:` / `> Note:` 같은 알림 상자를 씁니다.
   - **참조 무결성**: 아래 "참조 무결성 검사"에서 누락이 0이어야 합니다.

코드 스니펫은 `0N-code-0M.swift`로 단계마다 완성된 파일을 하나씩 둡니다.
`@Code(..., previousFile:)`를 주면 이전 파일과의 차이가 강조됩니다. 챕터를 넘어가도 됩니다
(Chapter 3의 첫 코드는 Chapter 1의 마지막 코드와 비교됩니다).

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
미리보기 대신 경고만 확인하려면 `preview-documentation`을 `generate-documentation`으로 바꿉니다.

> 미리보기에는 `Web/site.js`가 주입되지 않아서 **UI 한글화와 언어 전환 버튼이 보이지
> 않습니다.** 그것까지 보려면 아래 "배포본과 똑같이 확인하기"를 쓰세요.

## 한국어 / 영어

한 리포지토리에서 두 벌을 빌드합니다. 하위 경로가 같아서 언어 전환은 `/en` 세그먼트를
넣고 빼는 것으로 끝납니다. 사이트 루트(`/2026TechMap_tutorial/`)는 저장된 선택이나
브라우저 언어를 보고 둘 중 하나로 보냅니다.

| | 주소 | 소스 |
|---|---|---|
| 한국어 | `/2026TechMap_tutorial/tutorials/roomaquarium/...` | `Sources/RoomAquarium/RoomAquarium.docc/` |
| English | `/2026TechMap_tutorial/en/tutorials/roomaquarium/...` | 위 카탈로그 + `Localizations/en/Catalog/` 오버레이 |

영어는 **오버레이**입니다. `Localizations/en/Catalog/`에 있는 파일만 한국어 카탈로그를
덮어쓰고, 없는 것(이미지, `theme-settings.json`)은 한국어 원본을 그대로 씁니다.
현재 랜딩 페이지와 **Chapter 1~3 전부**가 번역돼 있습니다.

```
Localizations/en/Catalog/
  RoomAquarium.md, RoomAquarium.tutorial
  Tutorials/
    01-BuildingTheScene.tutorial, 02-BringingItToLife.tutorial, 03-PlacingInYourRoom.tutorial
    Resources/
      01-code-02…05.swift, 03-code-01…04.swift   주석과 로그 문구만 영어인 코드
      03-section3.png                             (현재 미사용 — 삭제된 섹션의 다이어그램)
```

> **한국어 본문을 고치면 영어 파일도 같이 고쳐야 합니다.** 오버레이 파일은 한국어 원본을
> **통째로** 덮어쓰기 때문에, 한쪽만 고치면 `/`와 `/en`의 내용이 어긋납니다. 코드
> 스니펫도 마찬가지로, 한국어 코드를 바꾸면 영어판의 같은 파일을 주석만 영어로 바꿔
> 맞춥니다.

### UI 언어는 어떻게 한글이 되었나

DocC 렌더러에는 한국어(`ko-KR`) 메시지 카탈로그가 이미 들어 있지만(`예상 시간`,
`{number}단계`, `다음` …) 기본 locale이 `en-US`로 고정돼 있습니다. `Web/site.js`가 하는 일:

1. vue-i18n의 locale을 `ko-KR`로 바꾸고 setter를 막습니다. 라우터가 페이지를 옮길 때마다
   `en-US`로 되돌리기 때문입니다. `<html lang>`도 같은 이유로 붙잡아 둡니다.
2. `Chapter {number}` / `Section {number}` 두 라벨은 영어로 되돌립니다. 본문에서
   "Chapter 2에서 등록한"처럼 쓰기 때문입니다.
3. i18n을 거치지 않고 DocC가 JSON에 직접 넣는 문구(`Get started`, `Documentation` /
   `Videos` / `Sample Code`, 알림 상자의 `Note` / `Important`, 소요 시간 등)를 치환합니다.
4. 네비게이션 바 오른쪽에 언어 전환 버튼을 붙입니다.

## 문서 외형 손보기

| 파일 | 바꿀 수 있는 것 |
|---|---|
| `RoomAquarium.docc/theme-settings.json` | 색, 글꼴 **패밀리**, 모서리 반경 (`--color-*`, `--typography-*`, `--border-radius`) |
| `Web/site.js` | 그 밖의 CSS(글자 **크기**, 행간)와 UI 한글화, 언어 전환 버튼 |

`theme-settings.json`의 `theme.color.tutorial-hero-background` 같은 키는 CSS 변수
`--color-tutorial-hero-background`가 됩니다. 값에 `{"light": ..., "dark": ...}`를 쓰면
라이트/다크를 따로 줄 수 있습니다.

글자 크기는 `Web/site.js`의 `:root { font-size: 17px; }` 한 줄이 기준입니다. DocC의
치수가 전부 `rem`이라 이 값만 바꾸면 전체가 같은 비율로 바뀝니다.

> DocC의 커스텀 헤더(`header.html`)는 쓰지 않습니다. 그 내용은 `<template>` 안에 들어가
> 실행되지 않기 때문에, 배포 워크플로가 `Web/site.js`를 각 `index.html`의 앱 번들 **앞에**
> 직접 끼워 넣습니다.

## 배포

배포 주소: **https://konghee.github.io/2026TechMap_tutorial/**

`main`에 push(또는 PR merge)하면 `.github/workflows/deploy-docc.yml`이 한국어·영어를 빌드하고
`site.js`를 주입해 GitHub Pages에 올립니다. 짧은 간격으로 여러 번 push하면 앞의 실행은
취소되고 마지막 것만 배포됩니다(정상입니다).

- 리포 이름이 `--hosting-base-path`(`2026TechMap_tutorial`)와 같아야 경로가 맞습니다. 리포
  이름을 바꾸면 워크플로의 `--hosting-base-path`와 루트 리다이렉트 경로도 함께 바꿉니다.
- `--target RoomAquarium`은 Swift 타깃 이름이라 리포 이름과 별개입니다. 문서 경로
  `/tutorials/roomaquarium`도 여기서 나옵니다.
- Settings > Pages > Source는 **GitHub Actions**여야 합니다.

### 배포본과 똑같이 확인하기

`site.js` 주입까지 포함해 로컬에서 보려면 워크플로와 같은 단계를 밟습니다.

```bash
swift package --allow-writing-to-directory docs generate-documentation \
  --target RoomAquarium --disable-indexing --transform-for-static-hosting \
  --hosting-base-path 2026TechMap_tutorial --output-path docs

./Tools/overlay-en.sh /tmp/en
(cd /tmp/en && swift package --allow-writing-to-directory "$OLDPWD/docs" generate-documentation \
  --target RoomAquarium --disable-indexing --transform-for-static-hosting \
  --hosting-base-path 2026TechMap_tutorial/en --output-path "$OLDPWD/docs/en")

cp Web/site.js docs/site.js && cp Web/site.js docs/en/site.js
find docs -name index.html -print0 | xargs -0 sed -i '' \
  -e 's#<script defer="defer" src="\([^"]*\)js/chunk-vendors#<script defer="defer" src="\1site.js"></script><script defer="defer" src="\1js/chunk-vendors#'

# baseUrl이 절대 경로라 경로를 맞춰서 띄웁니다
mkdir -p /tmp/serve && ln -sfn "$PWD/docs" /tmp/serve/2026TechMap_tutorial
(cd /tmp/serve && python3 -m http.server 8765)
```

`http://localhost:8765/2026TechMap_tutorial/tutorials/roomaquarium` 접속.

## 스크린샷

본문이 참조하는 이미지 **46장은 모두 촬영이 끝났습니다.** 다시 찍거나 새 스텝을 추가할 때의
규격과 네이밍은 `CAPTURE-CHECKLIST.md`에 있습니다. 같은 파일명으로 덮어쓰면 바로 반영됩니다.

네이밍 규칙:

- `NN-intro` / `NN-sectionK` — 챕터 도입·섹션 대표 이미지
- `NN-sK-stepM` — 챕터 NN, 섹션 K, 스텝 M의 스크린샷
- `NN-sK-result` — 섹션 완료 결과 화면
- `chN-card` / `toc-intro` — 목차 카드와 표지

새로 넣는 이미지는 긴 변 2400px 이하로 줄여 주세요(`sips -Z 2400 파일.png`). 표지와
Chapter 3 사진은 투명한 모서리가 있는 기기 목업이라 JPEG로 바꾸면 안 됩니다.

### 참조 무결성 검사

모든 `@Image(source:)`와 `@Code(file:)` 참조가 실제 파일과 맞는지 확인합니다.
영어는 오버레이를 씌운 트리(`./Tools/overlay-en.sh /tmp/en-check`)에서 같은 검사를 돌립니다.

```bash
cd Sources/RoomAquarium/RoomAquarium.docc && python3 - <<'PY'
import re, pathlib
res = pathlib.Path("Tutorials/Resources")
imgs, codes = set(), set()
for t in pathlib.Path(".").rglob("*.tutorial"):
    s = re.sub(r"<!--.*?-->", "", t.read_text(), flags=re.S)
    imgs  |= set(re.findall(r'@Image\(\s*source:\s*"([^"]+)"', s))
    codes |= set(re.findall(r'@Code\([^)]*?file:\s*"([^"]+)"', s))
    codes |= set(re.findall(r'previousFile:\s*"([^"]+)"', s))
png   = {p.stem for p in res.glob("*.png")}
swift = {p.name for p in res.glob("*.swift")}
print("누락 이미지:", sorted(imgs - png)   or "없음")
print("누락 코드  :", sorted(codes - swift) or "없음")
print("고아 이미지:", len(png - imgs), "장 / 고아 코드:", len(swift - codes), "개")
PY
```

**누락은 반드시 0이어야 합니다.** 고아(참조되지 않는 파일)는 0이 아닙니다. 삭제된
Chapter 4 "여러 마리로 늘리기"와 Chapter 3 세 번째 섹션 "Notification 왕복"의 리소스
(`04-*`, `ch4-card`, `03-section3`, `03-s3-*` 등)를 되살릴 때를 위해 남겨 두었기 때문입니다.
본문은 커밋 `dbbf720` 이전에 있습니다.

## placeholder와 다이어그램

- placeholder 생성기: `Tools/MakePlaceholder.swift`(`makeph`)와 `Tools/sync-placeholder-list.py`.
  지금은 모든 컷이 촬영돼 있으므로 **`generate-placeholders.sh`(전체 재생성)는 쓰지 마세요.**
  찍어 둔 사진을 덮어씁니다. 새 스텝용으로 한 장만 필요할 때:

  ```bash
  cd Tools && swiftc -O MakePlaceholder.swift -o makeph
  ./makeph ../Sources/RoomAquarium/RoomAquarium.docc/Tutorials/Resources "03-s2-step7|설명"
  ```

- 다이어그램 생성기: `Tools/MakeDiagrams.swift`. 지금 본문에서 쓰는 다이어그램은 없습니다
  (`03-section3`, `04-section1`, `04-section2`는 삭제된 섹션용).
  `swiftc`가 실패하면 `xcrun --toolchain XcodeDefault swiftc`를 씁니다.
