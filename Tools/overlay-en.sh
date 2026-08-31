#!/bin/sh
#
# 영어 빌드용 패키지 트리를 만듭니다.
#
#   ./Tools/overlay-en.sh <dest>
#
# 한국어 카탈로그를 통째로 복사한 뒤 Localizations/en/Catalog/ 의 파일만
# 덮어씁니다. 오버레이에 없는 것(아직 번역하지 않은 챕터, 이미지 대부분,
# theme-settings.json)은 한국어 원본을 그대로 상속합니다.
#
# 원본 트리는 건드리지 않으므로 CI 와 로컬 미리보기가 같은 스크립트를 씁니다.
set -eu

if [ $# -ne 1 ]; then
    echo "usage: $0 <dest>" >&2
    exit 2
fi

ROOT=$(cd "$(dirname "$0")/.." && pwd)
DEST=$1
CATALOG=Sources/RoomAquarium/RoomAquarium.docc

rm -rf "$DEST"
mkdir -p "$DEST"

rsync -a --exclude '.git' --exclude '.build' --exclude 'docs' "$ROOT/" "$DEST/"
rsync -a "$ROOT/Localizations/en/Catalog/" "$DEST/$CATALOG/"

echo "영어 빌드 트리 준비 완료: $DEST"
