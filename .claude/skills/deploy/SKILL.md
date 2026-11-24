---
name: deploy
description: 만든 것을 인터넷에 올려 링크로 공유할 수 있게 돕는다(GitHub Pages, Netlify Drop, Vercel 중 가장 쉬운 것 추천). 사용자가 "/deploy", "배포", "인터넷에 올려줘", "친구한테 보여주고 싶어", "링크 만들어줘"라고 할 때 사용.
---

# /deploy — 인터넷에 올리기

배포는 외부에 공개하는 일이라 **각 단계마다 사용자 동의**를 받으세요. 가입·결제·push는 사용자가 직접 하거나 명시적으로 허락해야 합니다.

## 1. 먼저 점검

- `/review` 절차의 🔴 항목(특히 비밀 키 노출)이 없는지 확인하세요. 있으면 배포 전에 고치자고 하세요.
- `/save`로 저장돼 있는지 확인하세요.

## 2. 방법 고르기 (추천을 하나 제시)

| 프로젝트 종류 | 추천 | 이유 |
|---|---|---|
| HTML 파일만 있음, GitHub 모름 (가장 쉬움) | **Netlify Drop** (app.netlify.com/drop) | `my-project` 폴더를 끌어다 놓으면 끝 |
| HTML/CSS/JS 파일만 있음, GitHub에 올려둠 | **GitHub Pages** | 무료, 저장(push)하면 자동 반영 |
| `package.json`이 있는 프로젝트 (Vite, React, Next.js 등) | **Vercel** | 빌드까지 자동 |
| 서버·데이터베이스가 필요함 | 상황 설명 후 함께 결정 | 비밀 키 설정 등 추가 작업 필요 |

## 3. 단계별 안내

선택한 방법의 단계를 번호로 안내하세요. 사용자가 클릭해야 하는 버튼 이름을 정확히 적으세요.
- **Netlify Drop**: 브라우저에서 app.netlify.com/drop 열기 → 파일 탐색기에서 `my-project` 폴더를 통째로 끌어다 놓기 → 주소 확인
- **GitHub Pages**: GitHub Pages는 하위 폴더를 바로 올릴 수 없어서 자동 배포 설정 파일이 필요해요.
  1. (동의를 받고) `templates/github-pages.yml`을 `.github/workflows/deploy-pages.yml`로 복사하고 `/save`
  2. 사용자가 레포 → **Settings** → **Pages** → Source를 **GitHub Actions**로 선택
  3. (동의를 받고) push → 레포의 **Actions** 탭에서 초록 체크 확인 → 1~2분 뒤 `https://아이디.github.io/레포이름/`
- **Vercel**: Add New → Project → 레포 선택 → **Root Directory**를 `my-project`로 바꾸기 → Deploy
- 환경변수(비밀 키)가 필요하면 `.env`를 올리지 말고 배포 서비스의 "Environment Variables" 설정 화면에 넣도록 안내하세요.

## 4. 끝나면

- 주소를 알려주고, 휴대폰으로도 열어보라고 하세요.
- `my-project/PROJECT.md`의 "현재 상태"에 배포 주소와 방법을 적으세요.
