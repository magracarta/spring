<%@ page contentType="text/html;charset=utf-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <link rel="shortcut icon" type="image/x-icon" href="/static/img/favicon.ico"/>
  <script type="text/javascript" src="/static/js/jquery.min.js?version=1.6"></script>
  <script type="text/javascript" src="/static/js/jquery.mfactory-2.2.js?version=1.6"></script>
  <title>YK건기 직원용 앱 다운로드</title>
  <link rel="stylesheet" type="text/css" href="../static/css/yk-tablet.css"/>
</head>

<script type="text/javascript">

  $(document).ready(function () {
    fnCheckAppVer();
  });

  function goAppDown(deviceTypeCd, url) {
    if (fnCheckAppVer(deviceTypeCd)) {
      window.location.href = url;
    }
  }

  function fnCheckAppVer(gubun) {
    if (gubun == 'CUST_AND') {
      if (${empty custAndApp}) {
        alert("안드로이드 고객앱 버전정보가 존재하지 않습니다. 관리자에게 문의해주세요.");
        return false;
      }
      if (${empty custAndApp.url}) {
        alert("안드로이드 고객앱 설치정보가 존재하지 않습니다. 관리자에게 문의해주세요.");
        return false;
      }
    } else if (gubun == 'CUST_IOS') {
      if (${empty custIosApp}) {
        alert("아이폰 고객앱 버전정보가 존재하지 않습니다. 관리자에게 문의해주세요.");
        return false;
      }
      if (${empty custIosApp.url}) {
        alert("아이폰 고객앱 설치정보가 존재하지 않습니다. 관리자에게 문의해주세요.");
        return false;
      }
    } else {
      if (${empty memApp}) {
        alert("직원앱 버전정보가 존재하지 않습니다. 관리자에게 문의해주세요.");
        return false;
      }
      if (${empty memApp.url}) {
        alert("직원앱 설치정보가 존재하지 않습니다. 관리자에게 문의해주세요.");
        return false;
      }
    }

    return true;
  }

</script>

<body>
<div class="app-download-container">
  <div class="header">
    <img src="../static/img/app-download/app-download-top-logo.svg" alt="" style="height: 33px;">
    <span class="logo-text">직원용 앱</span>
  </div>

  <div class="app-download-info">
    직원용 앱 사용을 위해서는 아래 내용을 확인 하신 후 단계별로 진행하시기 바랍니다.
  </div>

  <div class="row">
    <div class="col">
      <div class="step-group">
        <div class="step">STEP 1</div>
        <div class="step-info">
          탭에서 메일확인
        </div>
        <img src="../static/img/app-download/img-step-1.svg" alt="" class="img-step">
        <div class="step-comment">
          수신된 메일에서<br>URL터치
        </div>
      </div>
    </div>
    <div class="col">
      <div class="step-group">
        <div class="step">STEP 2</div>
        <div class="step-info">
          설치파일다운로드
        </div>
        <img src="../static/img/app-download/img-step-2.svg" alt="" class="img-step">
        <div class="step-comment">
          하단 설치파일<br>다운로드 버튼터치
        </div>
      </div>
    </div>
    <div class="col">
      <div class="step-group">
        <div class="step">STEP 3</div>
        <div class="step-info">
          설치 및 실행
        </div>
        <img src="../static/img/app-download/img-step-3.svg" alt="" class="img-step">
        <div class="step-comment">
          설치 후 앱 실행
        </div>
      </div>
    </div>
    <div class="col">
      <div class="step-group">
        <div class="step">STEP 4</div>
        <div class="step-info">
          로그인
        </div>
        <img src="../static/img/app-download/img-step-4.svg" alt="" class="img-step">
        <div class="step-comment">
          ERP계정으로<br>로그인
        </div>
      </div>
    </div>
    <div class="col">
      <div class="step-group">
        <div class="step">STEP 5</div>
        <div class="step-info">
          본인인증(1회만)
        </div>
        <img src="../static/img/app-download/img-step-5.svg" alt="" class="img-step">
        <div class="step-comment">
          직원정보에 등록된<br>
          본인 번호로 문자인증<br>
          (최초 1회 만 실시)
        </div>
      </div>
    </div>

    <div class="col">
      <div class="step-group step-ok">
        <img src="../static/img/app-download/img-step-ok.svg" alt="" class="img-step">
        <div class="step-comment">
          인증 이후<br>앱 사용 가능
        </div>
      </div>
    </div>
  </div>

  <div class="install-info">
    <h3>설치 시 주의사항</h3>
    <ul>
      <li>
        - 설치 중 "출처를 알 수 없는 앱"에서 YK건기 앱을 허용하셔야 문제없이 설치 및 사용이 가능합니다.
      </li>
      <li>
        - 설정 > 보안 및 개인정보보호 > 출처를 알 수 없는 앱 설치 > YK건기를 허용으로 변경해 주시기 바랍니다.
      </li>
    </ul>
  </div>

  <div class="pb-16">
    <button class="btn-download" onclick="javascript:goAppDown('MEM_AND', '${memApp.url}');">
      <img src="../static/img/app-download/app-download-bottom-logo-white.svg" alt="" style="height: 24px;">
      <span>직원앱 설치파일 다운로드</span>
    </button>
  </div>
  <div class="pb-16" style="display: flex; justify-content: space-evenly;">
    <c:if test="${not empty custAndApp}">
      <div>
        <button class="btn-download" onclick="javascript:goAppDown('CUST_AND', '${custAndApp.url}');">
          <span>고객앱 안드로이드 설치파일</span>
        </button>
      </div>
    </c:if>
  </div>
  <div class="pb-100" style="display: flex; justify-content: space-evenly;">
    <c:if test="${not empty custIosApp}">
      <div>
        <button class="btn-download" onclick="javascript:goAppDown('CUST_IOS', '${custIosApp.url}');">
          <span>고객앱 아이폰 설치파일</span>
        </button>
      </div>
    </c:if>
  </div>
</div>

</body>

</html>