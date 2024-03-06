---
last modified: 2023-11-08
---

<div align="center">
<h2> 시간담 : 시간과 추억을 담다.</h2>
  
![1](https://github.com/6eom9eun/timeDam/assets/104510730/a7aae994-909e-48d5-9d99-594894285d8d)

고령자의 추억, 일상 기록 및 인지 활동 참여를 위한 생성형 AI 앱
</div><br>

`제5회 K-디지털 트레이닝 해커톤`  
`KT 에이블스쿨 4기 : 버스커버스커`<br>
- 프로젝트 이름 : 시간담
- 프로젝트 지속기간 : 2023. 9 ~ 2023. 11

- What?
    - 고령자의 추억, 일상 기록 및 인지 활동 참여를 위한 생성형 AI 앱
    - 단어, 음성, 사진 중 하나 이상을 첨부하면 생성형 AI를 활용하여 문장과 이미지를 생성하여 사용자 앱에 기록하는 서비스 개발
    - **1061명(222팀) 중 52팀 선발 예선 진출 성공**
- How?
    1. 개발 리드
        1. Flutter & Firebase 기반 소셜 로그인, 글 작성 및 이미지 업로드, 저장, Provider를 통한 상태관리
        2. LLM(GPT)의 Prompt Engineering을 통해 맞춤 결과 생성 후 기록
        3. Flutter + Firebase를 통해 풀스택 개발
             -  <details><summary>담당한 기능</summary>
               
                - 로그인 기능, 회원 기능
                - firebase 연동 + 구글 OAuth
                - 달력에 업로드한 날짜에 이벤트 표시, 달력을 통해서 직관적인 CRUD
                - 상태관리를 위해 provider 패턴 사용
                - 플라스크와 데이터 주고받기
                - 로딩 기능
                - STT(Speech-to-Text)
                - background_fetch + geolocator + openweather api + kakao rest api를 통해서 백그라운드에서 위치 정보 수집, 해당 위치의 날씨 수집하여 고령자를 고려한 장소를 검색하여 추천
                - 수집한 날씨에 맞게 사용자에게 lottie 아이콘으로 직관적으로 표시</details>

---
<details><summary>Demo</summary>
  
<div align="center">
  
![스크린샷 2024-03-06 16 00 02](https://github.com/6eom9eun/timeDam/assets/104510730/457dd528-fdd7-42d0-a5c2-8d25e21bb515)
![스크린샷 2024-03-06 16 00 13](https://github.com/6eom9eun/timeDam/assets/104510730/358c2d08-dcc2-4a68-8c43-ebd233ffb0d7)
![스크린샷 2024-03-06 16 00 22](https://github.com/6eom9eun/timeDam/assets/104510730/bef4487b-6fd5-43ca-8110-7838e3678db3)</div></details>


