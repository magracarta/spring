<%@ page contentType="text/html;charset=utf-8" language="java"%>
<!DOCTYPE html>
<html lang="ko">
<head>
	<link rel="shortcut icon" type="image/x-icon" href="/static/img/favicon.ico" />
	<link rel="stylesheet" href="/static/css/style-m.css">
	<%-- <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/> --%>
	<script type="text/javascript" src="/static/js/jquery.min.js?version=1.6"></script>
	<script type="text/javascript" src="/static/js/jquery.mfactory-2.2.js?version=1.6"></script>

</head>
<script type="text/javascript">

	$(document).ready(function(){
		
	});
	
	/* function goPcDown() {
		if ("${pc_down_url}" == "") {
			alert("다운로드 URL이 없습니다.");
			return false;
		}
    } */

</script>
<body>

<!-- 이 페이지는 개별 모바일 페이지로 css와 이미지를 따로 사용합니다.-->
<!-- style-m.css / icons-m.png -->

<!-- 상단타이틀영역 -->
	<div class="main-title-m">
		<h1>
			<img src="/static/img/top-logo-m.png" alt="" style="width: 113px">
		</h1>	
		<button type="button">
			<i class="icon-btn-close"></i>
		</button>
	</div>
<!-- /상단타이틀영역 -->
<!-- contents 전체 영역 -->
    <div class="content-wrap">

        <ul class="certificate-com">
            <li>YK건기는 사내 보안강화로 인해 외부인 접속을 제한합니다.</li>
            <li>사내 직원은 아래 내용을 확인 하신 후 단계별로 진행하시기 바랍니다.</li>
        </ul>
        <div class="process">
            <h3>Mobile용 - 안드로이드에서만 가능 (아이폰 사용불가)</h3>
            <div class="process-info">
                <ul>
                    <li>
                        <div class="img-icon">
                            <img src="/static/img/pc-step2-2.png" alt="">
                        </div>
                        <div class="body">
                            <div class="title">
                                ① YK Security 앱설치
                            </div>
                            <div class="com">
                                Google Play Store에서<br>“YK Security”프로그램 검색 후 설치
                            </div>
                        </div>
                    </li>
                    <li>
                        <div class="img-icon">
                            <img src="/static/img/pc-step4.png" alt="">
                        </div>
                        <div class="body">
                            <div class="title">
                                ② 본인 인증 (1회만)
                            </div>
                            <div class="com">
                                직원정보에 등록된 본인번호로 문자인증(최초 1회 만 실시)
                            </div>
                        </div>
                    </li>
                </ul>
                <div class="final-info">
                    >> 인증 후 바탕화면에 설치된 아이콘 클릭 시 ERP접속 가능
                </div>
                <div class="btn-install">
                     <a href="${bean.and_url}">설치파일 다운로드</a>
                </div>
            </div>
         
        </div>
    </div>
<!-- /contents 전체 영역 -->	
</body>
</html>