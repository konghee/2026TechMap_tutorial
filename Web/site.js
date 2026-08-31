/*
  RoomAquarium 튜토리얼 사이트 스크립트.

  왜 이 파일이 따로 있는가
  ------------------------
  DocC의 --experimental-enable-custom-templates 는 header.html 을
  <template id="custom-header"> 안에 집어넣는데, 이 커스텀 엘리먼트를 정의하는
  코드가 렌더러 어디에도 없습니다. <template> 안의 <script> 는 inert 라
  실행되지 않으므로 그 경로로는 아무것도 넣을 수 없습니다.

  그래서 빌드 후에 워크플로가 이 파일을 각 index.html 의 앱 번들 "앞"에
  defer 스크립트로 끼워 넣습니다. 앱보다 먼저 실행돼야 fetch 가로채기가
  첫 데이터 요청을 놓치지 않습니다.

  하는 일
  -------
  (a) 타이포그래피 보정
  (b) 한국어 빌드에서 렌더러 UI 를 ko-KR 로 고정
  (c) Chapter / Section 라벨만 영어로 되돌리기
  (d) DocC 가 JSON 에 직접 박아 넣은 영어 문구 치환
  (e) 우측 하단 언어 전환 버튼
*/
(function () {
  "use strict";

  // window.baseUrl 은 앱 셸이 head 에서 먼저 정의합니다.
  // 한국어: "/2026TechMap_tutorial/", 영어: "/2026TechMap_tutorial/en/"
  var BASE = window.baseUrl || "/";
  var IS_EN = /\/en\/$/.test(BASE);
  var KO_BASE = IS_EN ? BASE.replace(/en\/$/, "") : BASE;
  var EN_BASE = IS_EN ? BASE : BASE + "en/";
  var STORAGE_KEY = "roomaquarium.lang";

  /* ---------------------------------------------------------------- (a) */

  function injectStyles() {
    if (document.getElementById("rq-site-style")) return;
    var css = [
      /* 사이트 전체 기준 크기.
         DocC 의 치수는 전부 rem 이고 그 값들이 17px 기준으로 계산돼 있습니다
         (.8235294118rem = 14/17, 2.8235294118rem = 48/17). 그런데 렌더러가
         :root 를 지정하지 않아 브라우저 기본값(보통 16px)으로 떨어집니다.
         17px 로 못박아 DocC 가 의도한 비율을 되찾습니다. */
      ":root { font-size: 17px; }",

      /* 스텝 카드 본문. 기본 14px 은 한글에 작습니다. */
      ".steps { font-size: 0.875rem !important; line-height: 1.75 !important; }",

      /* 본문 문단 행간. 기본 1.47 은 한글에 답답합니다. */
      ".content p, .intro p, .steps p { line-height: 1.7; }",

      /* 언어 전환 알약 — 네비게이션 바 오른쪽 끝.
         .nav-content 는 DocC 가 position:relative 로 잡아 두고 max-width 와
         좌우 패딩을 가지므로, 여기에 절대 배치하면 제목과 같은 선에 맞습니다.
         그리드/플렉스 어느 쪽으로 바뀌든 레이아웃을 건드리지 않습니다. */
      "#rq-lang-switch {",
      "  position: absolute; z-index: 3;",
      "  right: var(--nav-padding, 22px);",
      "  top: 50%; transform: translateY(-50%);",
      "  display: flex; padding: 2px; gap: 2px;",
      "  border-radius: 999px;",
      "  border: 1px solid var(--color-figure-blue, #0071e3);",
      "  background: transparent;",
      "  font-size: 0.7rem; line-height: 1;",
      "}",
      "#rq-lang-switch button {",
      "  appearance: none; -webkit-appearance: none; cursor: pointer;",
      "  border: 0; border-radius: 999px;",
      "  padding: 0.45em 0.85em;",
      "  font: inherit; font-weight: 500; white-space: nowrap;",
      "  background: transparent;",
      "  color: var(--color-figure-blue, #0071e3);",
      "}",
      "#rq-lang-switch button[aria-pressed=\"true\"] {",
      "  background: var(--color-figure-blue, #0071e3);",
      "  color: #fff;",
      "}",
      "#rq-lang-switch button:focus-visible {",
      "  outline: 2px solid currentColor; outline-offset: 2px;",
      "}",
      /* 랜딩의 네비게이션은 짙은 남색이라 라이트 모드의 파랑은 대비가 낮습니다. */
      ".theme-dark #rq-lang-switch { border-color: #409cff; }",
      ".theme-dark #rq-lang-switch button { color: #8cc2ff; }",
      ".theme-dark #rq-lang-switch button[aria-pressed=\"true\"] {",
      "  background: #409cff; color: #fff;",
      "}",
      /* 735px 아래에서는 DocC 가 챕터 드롭다운을 오른쪽 끝 메뉴 트리거
         (.nav-menucta, 21px)로 접습니다. 그 자리를 비켜 줍니다. */
      "@media only screen and (max-width: 735px) {",
      "  #rq-lang-switch {",
      "    font-size: 0.62rem;",
      "    right: calc(var(--nav-padding, 22px) + 2rem);",
      "  }",
      "  #rq-lang-switch button { padding: 0.4em 0.6em; }",
      "}",
      /* 아주 좁은 화면에서는 제목과 부딪힙니다. DocC 의 서브헤드
         (\"RoomAquarium Tutorials\" 의 Tutorials)를 접어 자리를 만듭니다. */
      "@media only screen and (max-width: 480px) {",
      "  .nav-title .subhead { display: none; }",
      "  #rq-lang-switch { font-size: 0.58rem; }",
      "}"
    ];

    if (!IS_EN) {
      // 한글은 어절 단위로 줄바꿈해야 읽힙니다. 없으면 "시뮬레이/터만으로"처럼 잘립니다.
      css.push("body { word-break: keep-all; overflow-wrap: break-word; }");
    }

    var style = document.createElement("style");
    style.id = "rq-site-style";
    style.textContent = css.join("\n");
    document.head.appendChild(style);
  }

  /* ---------------------------------------------------------------- (d) */

  // DocC 가 렌더 JSON 에 직접 써 넣는 영어입니다. i18n 카탈로그로는 잡히지 않습니다.
  var DATA_STRINGS = {
    "Get started": "시작하기",
    "Documentation": "문서",
    "Videos": "비디오",
    "Sample Code": "샘플 코드",
    "View more": "더 보기",
    "Watch videos": "비디오 보기"
  };

  // 알림 상자(> Note:, > Important: ...)의 제목도 i18n 이 아니라 JSON 의
  // "name" 으로 옵니다. 값은 렌더러의 ko-KR 카탈로그(aside-kind)와 맞춥니다.
  // "name" 에는 모듈 이름(RoomAquarium)도 들어오므로 이 목록에 있는 값만 바꿉니다.
  var ASIDE_NAMES = {
    "Note": "참고",
    "Important": "중요",
    "Warning": "경고",
    "Tip": "팁",
    "Experiment": "실험",
    "Beta": "베타",
    "Deprecated": "제거됨"
  };

  // 랜딩 히어로의 소요 시간("2hr 35min")은 Hero 컴포넌트가 JSON 값을 그대로
  // 찍습니다 — 다른 자리와 달리 i18n 을 거치지 않습니다.
  function localizeDuration(value) {
    if (!/^[\d\s]*(hr|min)/.test(value)) return value;
    return value
      .replace(/(\d+)\s*hrs?/g, "$1시간")
      .replace(/(\d+)\s*mins?/g, "$1분");
  }

  // 사람이 읽는 문구가 들어가는 키만 건드립니다.
  // "role":"documentation" 같은 소문자 식별자는 손대지 않습니다.
  var TEXT_KEYS = { title: 1, text: 1, overridingTitle: 1 };

  function localizeData(node, key) {
    var i, k;
    if (Array.isArray(node)) {
      for (i = 0; i < node.length; i += 1) node[i] = localizeData(node[i], key);
      return node;
    }
    if (node && typeof node === "object") {
      for (k in node) {
        if (Object.prototype.hasOwnProperty.call(node, k)) {
          node[k] = localizeData(node[k], k);
        }
      }
      return node;
    }
    if (typeof node === "string") {
      if (TEXT_KEYS[key] === 1 &&
          Object.prototype.hasOwnProperty.call(DATA_STRINGS, node)) {
        return DATA_STRINGS[node];
      }
      if (key === "name" &&
          Object.prototype.hasOwnProperty.call(ASIDE_NAMES, node)) {
        return ASIDE_NAMES[node];
      }
      if (key === "estimatedTime") return localizeDuration(node);
    }
    return node;
  }

  function patchFetch() {
    if (typeof window.fetch !== "function") return;
    var original = window.fetch;

    window.fetch = function (input, init) {
      var url = typeof input === "string" ? input : (input && input.url) || "";
      var call = original.apply(this, arguments);
      if (!/\/data\/.*\.json(\?|$)/.test(url)) return call;

      return call.then(function (response) {
        // 앱은 response.redirected 와 schemaVersion 을 검사하므로 형태를 유지합니다.
        if (!response.ok || response.redirected) return response;
        return response.text().then(function (body) {
          var data;
          try {
            data = JSON.parse(body);
          } catch (e) {
            return new Response(body, {
              status: response.status,
              statusText: response.statusText,
              headers: response.headers
            });
          }
          return new Response(JSON.stringify(localizeData(data, null)), {
            status: response.status,
            statusText: response.statusText,
            headers: response.headers
          });
        });
      });
    };
  }

  /* ------------------------------------------------------------ (b), (c) */

  function lockKoreanLocale(i18n) {
    var proto = Object.getPrototypeOf(i18n);
    var descriptor = Object.getOwnPropertyDescriptor(proto, "locale");
    if (!descriptor || !descriptor.get || !descriptor.set) return false;

    // 반응형 setter 로 한 번 넣어 즉시 리렌더시킵니다.
    descriptor.set.call(i18n, "ko-KR");

    // 각 뷰의 beforeRouteEnter 가 페이지를 옮길 때마다 locale 을 en-US 로
    // 되돌립니다. getter 는 원래 것에 위임해 반응성을 유지하고 setter 만 막습니다.
    Object.defineProperty(i18n, "locale", {
      configurable: true,
      get: function () { return descriptor.get.call(i18n); },
      set: function () {}
    });

    // 구조를 가리키는 라벨은 영어로 되돌립니다. 본문에서 "Chapter 2에서
    // 등록한"처럼 쓰기 때문에 화면 라벨도 같은 말이어야 읽힙니다.
    // mergeLocaleMessage 는 깊은 병합이라 나머지 한국어 문구는 그대로입니다.
    if (typeof i18n.mergeLocaleMessage === "function") {
      i18n.mergeLocaleMessage("ko-KR", {
        tutorials: {
          title: "Tutorial | Tutorials",     // 네비게이션 서브헤드
          step: "Step {number}",             // 스텝 카드 라벨
          "section-of": "{number} of {total}", // 네비게이션의 "1 of 3"
          sections: { chapter: "Chapter {number}" }
        },
        sections: { title: "Section {number}" }
      });
    }

    return true;
  }

  // 라우터는 locale 뿐 아니라 <html lang> 도 페이지를 옮길 때마다 en-US 로
  // 되돌립니다. 스크린 리더와 CJK 글리프 선택이 걸려 있으니 붙잡아 둡니다.
  function pinHtmlLang(lang) {
    var html = document.documentElement;
    if (html.lang !== lang) html.lang = lang;
    if (typeof MutationObserver !== "function") return;
    new MutationObserver(function () {
      if (html.lang !== lang) html.lang = lang;
    }).observe(html, { attributes: true, attributeFilter: ["lang"] });
  }

  function whenAppMounted(callback) {
    var tries = 0;
    (function poll() {
      // 마운트된 루트 엘리먼트는 id="app" 을 유지하고, Vue 2 는 $el.__vue__ 를 세팅합니다.
      var el = document.getElementById("app");
      var vm = el && el.__vue__;
      if (vm && vm.$root && vm.$root.$i18n) {
        callback(vm.$root.$i18n);
        return;
      }
      tries += 1;
      if (tries > 600) return; // 약 10초. 렌더러가 바뀌었으면 조용히 포기합니다.
      requestAnimationFrame(poll);
    })();
  }

  /* ---------------------------------------------------------------- (e) */

  function urlFor(lang) {
    var path = location.pathname;
    var rest = path.indexOf(BASE) === 0 ? path.slice(BASE.length) : "";
    return (lang === "en" ? EN_BASE : KO_BASE) + rest + location.search + location.hash;
  }

  function remember(lang) {
    try {
      localStorage.setItem(STORAGE_KEY, lang);
    } catch (e) {
      /* 프라이빗 모드 등에서 막혀도 전환 자체는 되어야 합니다. */
    }
  }

  function buildSwitcher() {
    var wrap = document.createElement("div");
    wrap.id = "rq-lang-switch";
    wrap.setAttribute("role", "group");
    wrap.setAttribute("aria-label", IS_EN ? "Language" : "언어 선택");

    [
      { lang: "ko", label: "한국어" },
      { lang: "en", label: "English" }
    ].forEach(function (item) {
      var active = IS_EN ? item.lang === "en" : item.lang === "ko";
      var button = document.createElement("button");
      button.type = "button";
      button.textContent = item.label;
      button.lang = item.lang;
      button.setAttribute("aria-pressed", active ? "true" : "false");
      button.addEventListener("click", function () {
        remember(item.lang);
        if (active) return;
        // SPA 라우터를 거치지 않습니다 — 언어마다 별개의 정적 빌드입니다.
        location.assign(urlFor(item.lang));
      });
      wrap.appendChild(button);
    });

    return wrap;
  }

  // 라우터가 페이지를 옮기면 Vue 가 네비게이션을 통째로 다시 그리면서
  // 우리 버튼도 같이 날아갑니다. 사라지면 도로 붙입니다.
  function keepSwitcherMounted() {
    var scheduled = false;

    function mount() {
      scheduled = false;
      var nav = document.querySelector(".nav-content");
      if (!nav || nav.querySelector("#rq-lang-switch")) return;
      nav.appendChild(buildSwitcher());
    }

    function schedule() {
      if (scheduled) return;
      scheduled = true;
      requestAnimationFrame(mount);
    }

    mount();
    if (typeof MutationObserver === "function") {
      new MutationObserver(schedule).observe(document.body, {
        childList: true,
        subtree: true
      });
    }
  }

  /* ------------------------------------------------------------------- */

  if (!IS_EN) patchFetch();       // 앱의 첫 데이터 요청보다 먼저 걸어야 합니다.
  injectStyles();
  keepSwitcherMounted();
  if (!IS_EN) {
    pinHtmlLang("ko");
    whenAppMounted(lockKoreanLocale);
  }
})();
