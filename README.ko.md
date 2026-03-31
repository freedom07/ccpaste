<div align="center">

<p><a href="README.md">English</a> | 한국어</p>

# ccpaste

**Claude Code 터미널 출력 → 리치텍스트 클립보드**

[![macOS](https://img.shields.io/badge/macOS-13.0%2B-black?logo=apple&logoColor=white)](https://github.com/freedom07/ccpaste)
[![Swift](https://img.shields.io/badge/Swift-5.9%2B-F05138?logo=swift&logoColor=white)](https://swift.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![GitHub release](https://img.shields.io/github/v/release/freedom07/ccpaste?include_prereleases)](https://github.com/freedom07/ccpaste/releases)
[![Build](https://github.com/freedom07/ccpaste/actions/workflows/build.yml/badge.svg)](https://github.com/freedom07/ccpaste/actions/workflows/build.yml)

<kbd>⌘</kbd><kbd>⇧</kbd><kbd>C</kbd> 한 번이면 복사한 터미널 텍스트가 어디에든 깔끔하게 붙여넣어집니다.

[설치](#설치) · [사용법](#사용법) · [동작 원리](#동작-원리) · [기여하기](#기여하기)

</div>

---

## 문제

Claude Code(또는 터미널)의 출력을 복사해서 Notion, Slack, Google Docs에 붙여넣으면:

- 마크다운 마커(`**`, `` ``` ``)가 그대로 보임
- ANSI 이스케이프 코드(`[0m`, `[32m`)가 섞여 나옴
- 모든 구조가 한 줄로 뭉개져서 읽을 수 없음
- Claude UI 마커(⏺▶◼●)가 그대로 노출

**ccpaste**는 단축키 하나로 이 문제를 해결합니다.

## 데모

```
┌─────────────────────────────────────────────┐
│  터미널 (Cmd+C)                              │
│  **볼드**, `코드`, - 리스트                    │
│  ANSI 색상, Claude 마커 ⏺                    │
└──────────────┬──────────────────────────────┘
               │
         ⌘ + ⇧ + C
               │
               ▼
┌─────────────────────────────────────────────┐
│  Notion / Slack / Google Docs (Cmd+V)       │
│  볼드, 코드, • 리스트                         │
│  깔끔하게 포맷된 리치텍스트                      │
└─────────────────────────────────────────────┘
```

## 기능

- **단축키 하나** — <kbd>⌘</kbd><kbd>⇧</kbd><kbd>C</kbd>로 클립보드를 리치텍스트로 변환
- **ANSI 제거** — 모든 터미널 색상/스타일 이스케이프 코드 제거
- **Claude Code 대응** — UI 마커(⏺▶◼●) 자동 제거
- **GFM 지원** — 테이블, 취소선, 자동 링크, 태스크 리스트 ([cmark-gfm](https://github.com/github/cmark-gfm))
- **Box-drawing 테이블** — 유니코드 박스 테이블을 마크다운 테이블로 변환
- **인라인 CSS** — 다크 테마 코드블록, 스타일 테이블, 제목 서식
- **네이티브 macOS** — 메뉴바 앱, Electron 없음, 별도 설치 필요 없음
- **경량** — < 2MB, 밀리초 단위로 실행

## 지원 앱

| 앱 | 테이블 | 코드블록 | 리스트 | 볼드/이탤릭 | 인용문 |
|-----|:------:|:-----------:|:-----:|:-----------:|:-----------:|
| Notion | ✅ | ✅ | ✅ | ✅ | ✅ |
| Google Docs | ✅ | ✅ | ✅ | ✅ | ✅ |
| Apple Mail | ✅ | ✅ | ✅ | ✅ | ✅ |
| Slack | ❌¹ | ✅ | ✅ | ✅ | ✅ |

<sup>¹ Slack은 HTML 테이블 붙여넣기를 지원하지 않습니다. ccpaste가 아닌 Slack의 제한사항입니다.</sup>

## 설치

### 한 줄 설치

```bash
curl -sL https://github.com/freedom07/ccpaste/releases/latest/download/ccpaste.app.zip -o /tmp/ccpaste.zip && unzip -o /tmp/ccpaste.zip -d /Applications && rm /tmp/ccpaste.zip && xattr -cr /Applications/ccpaste.app && open /Applications/ccpaste.app
```

### 소스에서 빌드

```bash
git clone https://github.com/freedom07/ccpaste.git
cd ccpaste
bash build.sh
cp -r .build/release/ccpaste.app /Applications/
open /Applications/ccpaste.app
```

### GitHub Releases에서 다운로드

[Releases](https://github.com/freedom07/ccpaste/releases)에서 최신 `.app.zip`을 다운로드하고 압축을 풀어 `/Applications`로 드래그하세요.

> **참고:** 앱이 아직 공증되지 않았으므로 macOS에서 Gatekeeper 경고가 표시될 수 있습니다.
> 앱을 우클릭 → "열기" → "열기"를 클릭하거나, 터미널에서 실행:
> ```bash
> xattr -cr /Applications/ccpaste.app
> ```

### 삭제

```bash
killall ccpaste; rm -rf /Applications/ccpaste.app
```

### 요구사항

- macOS 13.0 (Ventura) 이상
- Swift 5.9+ (소스 빌드 시)

## 사용법

1. 터미널에서 텍스트를 <kbd>⌘</kbd><kbd>C</kbd>로 **복사**
2. <kbd>⌘</kbd><kbd>⇧</kbd><kbd>C</kbd>로 **변환**
3. 원하는 앱에서 <kbd>⌘</kbd><kbd>V</kbd>로 **붙여넣기**

화면 하단에 토스트 알림으로 변환 결과를 확인할 수 있습니다:
- ✅ **Rich text ready** — 성공
- ❌ **No text in clipboard** — 클립보드가 비어있음

메뉴바의 📄 아이콘을 클릭하면 메뉴 접근 및 종료가 가능합니다.

## 동작 원리

```
Cmd+Shift+C
    │
    ▼
ClipboardManager.readPlainText()
    │
    ▼
TerminalNormalizer.normalize()
    ├── ANSI 이스케이프 코드 제거 (CSI, OSC, SGR)
    ├── Claude UI 마커 제거 (⏺▶◼●)
    ├── Box-drawing 테이블 → 마크다운 변환
    └── 들여쓰기 정규화
    │
    ▼
MarkdownConverter.toHTML()
    └── cmark-gfm + GFM 확장
    │
    ▼
HTMLStyler.applyStyles()
    ├── 코드블록: 다크 테마 (#1e1e1e)
    ├── 인라인 코드: 라이트 그레이 (#f5f5f5)
    ├── 테이블: 테두리 + 패딩
    ├── 인용문: 왼쪽 테두리
    └── 제목: 볼드 + 크기 차등
    │
    ▼
ClipboardManager.writeRichText()
    └── NSPasteboard: .html + .string
    │
    ▼
토스트: "✅ Rich text ready"
```

### 아키텍처

```
Sources/ccpaste/
├── main.swift              # 진입점
├── AppDelegate.swift       # 메뉴바 + Carbon 글로벌 핫키 + 파이프라인
├── TerminalNormalizer.swift # ANSI 제거 + Claude 마커 + box-drawing
├── MarkdownConverter.swift  # cmark-gfm 래퍼 (MD → HTML)
├── HTMLStyler.swift         # 인라인 CSS 스타일링
├── ClipboardManager.swift   # NSPasteboard 읽기/쓰기
└── ToastWindow.swift        # 부동 토스트 알림
```

### 주요 기술 결정

| 결정 | 선택 | 이유 |
|------|------|------|
| 글로벌 핫키 | Carbon `RegisterEventHotKey` | 접근성 권한 불필요 |
| MD → HTML | [libcmark_gfm](https://github.com/KristopherGBaker/libcmark_gfm) | GFM 테이블, 취소선, 자동 링크 |
| 클립보드 형식 | HTML + plain text | NSPasteboard를 통한 범용 앱 호환 |
| 스타일링 | 인라인 CSS | `<style>` 블록은 대부분 붙여넣기 대상에서 제거됨 |
| 앱 유형 | LSUIElement 메뉴바 앱 | Dock 아이콘 없음, 창 없음 |

## 문제 해결

<details>
<summary><strong>Cmd+Shift+C가 동작하지 않음</strong></summary>

다른 앱이 이 단축키를 이미 사용하고 있을 수 있습니다. 시스템 설정 → 키보드 → 키보드 단축키에서 충돌을 확인하세요.
</details>

<details>
<summary><strong>Gatekeeper가 앱을 차단함</strong></summary>

앱이 아직 공증되지 않았습니다. 우클릭 → "열기" → "열기"를 클릭하거나:
```bash
xattr -cr /Applications/ccpaste.app
```
</details>

<details>
<summary><strong>Slack에서 테이블이 제대로 안 나옴</strong></summary>

Slack은 HTML 테이블 붙여넣기를 지원하지 않습니다. 이것은 Slack의 제한사항입니다. Notion, Google Docs, Apple Mail에서는 정상적으로 렌더링됩니다.
</details>

<details>
<summary><strong>메뉴바 아이콘이 안 보임</strong></summary>

메뉴바 아이콘이 많으면 노치 뒤에 숨겨질 수 있습니다. 단축키(<kbd>⌘</kbd><kbd>⇧</kbd><kbd>C</kbd>)는 아이콘 표시와 관계없이 동작합니다.
</details>

## 로드맵

- [ ] 설정 창 (단축키 변경, 로그인 시 자동 실행)
- [ ] 터미널 복사 자동 감지 (단축키 불필요)
- [ ] 복잡한 box-drawing 테이블 지원
- [ ] 코드 서명 + 공증
- [ ] Homebrew Cask (`brew install --cask ccpaste`)
- [ ] 코드블록 구문 강조

## 기여하기

기여를 환영합니다! PR을 제출하기 전에 [CONTRIBUTING.md](CONTRIBUTING.md)를 읽어주세요.

## 라이선스

[MIT](LICENSE) © 2026 yun

## 감사의 말

- [cmark-gfm](https://github.com/github/cmark-gfm) — GitHub Flavored Markdown 파서
- [libcmark_gfm](https://github.com/KristopherGBaker/libcmark_gfm) — cmark-gfm Swift 래퍼
- Claude Code 출력을 Notion에 붙여넣을 때의 고통에서 영감을 받았습니다

---

<div align="center">

**ccpaste가 유용했다면 ⭐를 눌러주세요**

</div>
