#!/usr/bin/env python3
"""generate-placeholders.sh의 이미지 목록을 .tutorial 파일에서 다시 뽑아냅니다.

스텝을 추가·삭제한 뒤 이걸 돌리면 목록이 본문과 다시 맞습니다.
설명 문구는 @Image의 alt 텍스트를 그대로 씁니다.

    cd Tools && python3 sync-placeholder-list.py
    ./generate-placeholders.sh
"""

import collections
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
DOCC = ROOT / "Sources/RoomAquarium/RoomAquarium.docc"
SCRIPT = ROOT / "Tools/generate-placeholders.sh"

IMAGE = re.compile(r'@Image\(\s*source:\s*"([^"]+)"\s*,\s*alt:\s*"([^"]+)"\s*\)')

# placeholder로 덮어쓰면 안 되는 이미지 — 코드로 그린 다이어그램들.
# 여기 넣어 두면 generate-placeholders.sh 목록에서 빠집니다.
HANDMADE = {
    "03-section3",   # 이 셋은 Tools/MakeDiagrams.swift 로 생성합니다
    "04-section1",
    "04-section2",
}

HEADER = """#!/bin/zsh
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

"$SP/makeph" "$OUT" \\
"""


def collect():
    """목차 → 챕터 순서로 (파일명, 설명) 쌍을 모읍니다."""
    pairs = collections.OrderedDict()
    files = [DOCC / "RoomAquarium.tutorial"] + sorted((DOCC / "Tutorials").glob("*.tutorial"))
    for path in files:
        if not path.exists():
            continue
        for name, alt in IMAGE.findall(path.read_text()):
            if name in HANDMADE:
                continue
            pairs.setdefault(name, alt)
    return pairs


def main():
    pairs = collect()
    if not pairs:
        sys.exit("@Image 참조를 하나도 찾지 못했습니다. 경로를 확인하세요.")

    lines = [HEADER.rstrip("\n")]
    entries = [f'"{name}|{alt}" \\' for name, alt in pairs.items()]
    entries[-1] = entries[-1].rstrip(" \\")
    lines.extend(entries)
    lines.append("")
    lines.append(f'echo "placeholder {len(pairs)}장 생성 완료 -> $OUT"')

    SCRIPT.write_text("\n".join(lines) + "\n")
    SCRIPT.chmod(0o755)
    print(f"{SCRIPT.relative_to(ROOT)} 갱신: {len(pairs)}장")

    # 더 이상 참조되지 않는 PNG를 알려 줍니다(삭제는 하지 않습니다).
    res = DOCC / "Tutorials/Resources"
    orphans = sorted({p.stem for p in res.glob("*.png")} - set(pairs) - HANDMADE)
    if orphans:
        print("이제 안 쓰는 이미지:", ", ".join(orphans))
        print("확인 후 지우세요:")
        for name in orphans:
            print(f"  rm {(res / (name + '.png')).relative_to(ROOT)}")


if __name__ == "__main__":
    main()
