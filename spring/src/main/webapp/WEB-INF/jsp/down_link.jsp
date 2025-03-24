<%@ page contentType="text/html;charset=utf-8" language="java" %><%@ include file="/WEB-INF/jsp/common/commonForAll.jsp" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <link rel="shortcut icon" type="image/x-icon" href="/static/img/favicon.ico"/>
  <script type="text/javascript" src="/static/js/jquery.min.js?version=1.6"></script>
  <script type="text/javascript" src="/static/js/jquery.mfactory-2.2.js?version=1.6"></script>
  <title>YK건기 고객용 앱</title>
</head>

<%--
  [재호] 앱 다운 페이지 설명
  - 앱을 다운로드 할 수 있는 안내 페이지
  - Android 의 경우
    - YK 고객앱 있을 경우 : 앱 오픈
    - YK 고객앱 없을 경우 : 플레이스토어 이동
  - Ios 의 경우 (사파리 보안 문제로 앱 체크 로직을 수행 할 수 없어서 앱 스토어 이동으로 고정)
    - YK 고객앱 여부 상관 없이 앱스토어 이동
    
  [Android 앱 체크 방식]
  - A. Android 는 바로 고객앱 호출 (앱이 있든 없든 우선 호출)
  - B. intervalSch 함수에서 0.3 마다 웹뷰 비활성화 체크
    - 웹뷰가 비활성화 됐다는 뜻은 ~/down/link 로 진입했던 브라우저가 내려가고 앱이 열렸다는 뜻
  - C. setTimeout 시간(2.5초) 까지 검사 후 웹뷰가 비활성화 되지 않았다면 앱이 없다고 판단함
    - 앱이 없다 판단 후 플레이스토어 이동
--%>

<script type="text/javascript">
  var deviceType = "${device_type}";
  var downLink = "${down_link}";
  var appLink = "${app_link}";

  var timer;
  var schInterval;

  // 앱 다운 체크 인터벌 삭제
  function clearTimer() {
    clearInterval(schInterval);
    clearTimeout(timer);
  }

  // 앱 다운 체크 인터벌
  function intervalSch() {
    if (document.webkitHidden || document.hidden) { 
      // 웹뷰 비활성화 체크
      clearTimer(); 
    } else {
      // 웹뷰 활성화
      console.log("타이머 동작");
    }
  }

  if(deviceType === 'IOS') {
    // 앱스토어 링크 호출
    location.href = downLink;
  } else {
    // [A]
    location.href = appLink;

    // [B]
    schInterval = setInterval(intervalSch, 300);

    // [C]
    timer = setTimeout(function () {
      location.href = downLink // 플레이스토어 이동
      clearInterval(schInterval); // 앱 체크 interval 종료
    }, 2500);
  }

</script>

<body>
</body>
</html>
