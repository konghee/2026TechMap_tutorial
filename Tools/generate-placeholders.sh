#!/bin/zsh
# placeholder 이미지 일괄 생성기.
#   swiftc -O MakePlaceholder.swift -o makeph   # 최초 1회 빌드
#   ./generate-placeholders.sh                  # 전체 재생성
# 개별 생성:  ./makeph <출력디렉터리> "파일명|설명" ...
#
# 이 목록은 .tutorial 파일의 @Image(source:alt:)에서 뽑아낸 것입니다.
# 스텝을 추가·삭제했다면 Tools/sync-placeholder-list.py 로 다시 뽑으세요.
set -e
SP="$(cd "$(dirname "$0")" && pwd)"
OUT="$SP/../Sources/RoomAquarium/RoomAquarium.docc/Tutorials/Resources"

"$SP/makeph" "$OUT" \
"toc-intro|아이패드 화면 속 방 안에 떠 있는 가상 아쿠아리움" \
"ch1-card|Reality Composer Pro 뷰포트에 배치된 아쿠아리움 씬" \
"ch2-card|기포 파티클이 올라오는 아쿠아리움 씬" \
"ch3-card|실제 방에 AR로 배치된 아쿠아리움" \
"ch4-card|방 안을 떠다니는 해마 여러 마리" \
"01-intro|RCP 뷰포트에 배치된 아쿠아리움 씬" \
"01-section1|Xcode 프로젝트 내비게이터에 추가된 RealityKitContent 패키지" \
"01-s1-step1|Xcode 새 프로젝트 생성 화면에서 iOS App 템플릿 선택" \
"01-s1-step2|Minimum Deployments를 iOS 18.0으로 설정" \
"01-s1-step3|Xcode 메뉴에서 Reality Composer Pro 실행" \
"01-s1-step4|RCP 새 프로젝트 저장 다이얼로그" \
"01-s1-step5|앱 타깃에 RealityKitContent 라이브러리 추가" \
"01-s1-step6|import RealityKitContent 자동완성과 빌드 성공" \
"01-section2|RCP 계층 패널과 뷰포트" \
"01-s2-step1|rkassets 폴더에 추가된 seahorse.usdz와 WhaleCry.usdz" \
"01-s2-step2|계층 패널의 Root 엔티티와 Scene.usda" \
"01-s2-step3|Seahorse 엔티티의 Transform 인스펙터" \
"01-s2-step4|납작한 원기둥으로 만든 바닥" \
"01-s2-step5|Seahorse에 추가한 Collision과 Input Target 컴포넌트" \
"01-s2-step6|정리된 씬 계층 구조와 저장" \
"01-section3|시뮬레이터에 표시된 아쿠아리움 씬" \
"01-s3-result|시뮬레이터에서 회전 중인 아쿠아리움 씬" \
"02-intro|기포가 올라오는 아쿠아리움 씬" \
"02-section1|RCP 파티클 이미터 인스펙터" \
"02-s1-step1|Seahorse에 Particle Emitter 컴포넌트 추가" \
"02-s1-step2|Emitter Shape과 Birth Rate 설정" \
"02-s1-step3|Acceleration Y와 Opacity Over Life 설정" \
"02-s1-step4|시뮬레이터에서 올라가는 기포" \
"02-section2|RCP 타임라인 편집기와 애니메이션 액션" \
"02-s2-step1|Seahorse 인스펙터의 Animation Library 컴포넌트" \
"02-s2-step2|SwimLoop 타임라인 생성" \
"02-s2-step3|Animation 액션의 Target과 Loop 설정" \
"02-s2-step4|Behaviors의 On Added To Scene 트리거와 SwimLoop 연결" \
"02-s2-result|헤엄치는 해마" \
"02-section3|RCP 오디오 라이브러리 인스펙터" \
"02-s3-step1|rkassets 폴더의 WhaleCry.usdz" \
"02-s3-step2|Seahorse에 Audio Library 컴포넌트 추가" \
"02-s3-step3|Audio Library 리소스 목록에 등록된 WhaleCry" \
"03-intro|실제 방에 배치된 AR 아쿠아리움" \
"03-section1|카메라 패스스루로 본 방과 월드 원점" \
"03-s1-step1|빌드 세팅의 카메라 권한 문구" \
"03-s1-step2|RCP에서 Floor 엔티티 삭제" \
"03-s1-result|실기기에서 방 안에 떠 있는 아쿠아리움" \
"03-section2|탭에 반응하는 해마" \
"03-s2-step1|TapSeahorse 타임라인의 Emphasize와 Play Audio 액션" \
"03-s2-step2|On Tap 트리거와 TapSeahorse 연결" \
"03-s2-result|탭에 반응해 회전하는 해마" \
"03-s3-step1|타임라인에 배치한 두 개의 Notification 액션" \
"03-s3-result|탭에 반응해 배지가 뜬 화면" \
"04-intro|방 안을 떠다니는 해마 여러 마리" \
"04-s1-result|복제됐지만 움직이지도 반응하지도 않는 해마 여덟 마리" \
"04-s2-step1|RCP 인스펙터에 나타난 SeahorseComponent와 노브들" \
"04-s2-result|각자 다른 박자로 떠다니는 해마 여덟 마리" \
"04-section3|RCP 인스펙터에서 해마 노브를 조절하는 모습" \
"04-s3-step1|RCP에서 swimSpeed를 조절하는 인스펙터" \
"04-s3-result|노브를 바꿔 성격이 달라진 해마들" \
"04-section4|RCP의 빈 마커 엔티티와 거기서 생겨난 해마들" \
"04-s4-step1|RCP에서 Transform으로 빈 마커 엔티티를 만드는 모습" \
"04-s4-step2|인스펙터에 추가된 SpawnPoint 컴포넌트와 count 필드" \
"04-s4-step3|마커 주변에 모여 떠다니는 해마 무리" \
"04-s4-result|완성된 아쿠아리움"

echo "placeholder 61장 생성 완료 -> $OUT"
