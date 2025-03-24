<%@ page contentType="text/html;charset=utf-8" language="java"%>
<!DOCTYPE html>
<html lang="ko">
<head>
	<link rel="shortcut icon" type="image/x-icon" href="/static/static/img/favicon.ico" />
	<%-- <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/> --%>
	<script type="text/javascript" src="/static/js/jquery.min.js?version=1.6"></script>
	<script type="text/javascript" src="/static/js/jquery.mfactory-2.2.js?version=1.6"></script>
	<link rel="stylesheet" type="text/css" href="/static/css/style-certificate.css?version=1.6" />
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
<body class="certificate pc">
    <div>
        <h2><img src="/static/img/top-logo.png" alt=""></h2>
        <ul class="certificate-info">
            <li>YK건기는 사내 보안강화로 인해 외부인 접속을 제한합니다.</li>
            <li>사내 직원은 아래 내용을 확인 하신 후 단계별로 진행하시기 바랍니다.</li>
        </ul>
    </div>
    <div class="process pc">
        <h3>PC용</h3>
        <div class="process-info">
            <ul class="">
<%--                <li>
                    <div class="img-icon">
                        <img src="/static/img/pc-step1.png" alt="">
                    </div>
                    <div class="title">
                        ① 관리부에 인증등록요청
                    </div>
                    <div class="com">
                        메일 또는 전화로 인증등록을<br>관리부에 요청
                    </div>
                </li>--%>
                <li>
                    <div class="img-icon">
                        <img src="/static/img/pc-step2.png" alt="">
                    </div>
                    <div class="title">
                        ① YK Security 파일다운로드
                    </div>
                    <div class="com">
                        화면 하단YK Security 아이콘 클릭 후<br>설치 파일 다운로드
                    </div>
                </li>
                <li>
                    <div class="img-icon">
                        <img src="/static/img/pc-step3.png" alt="">
                    </div>
                    <div class="title">
                        ② YK Security 파일 실행
                    </div>
                    <div class="com">
                        다운로드 된 파일을 내 컴퓨터에<br>설치
                    </div>
                </li>
                <li>
                    <div class="img-icon">
                        <img src="/static/img/pc-step4.png" alt="">
                    </div>
                    <div class="title">
                        ③ 본인 인증 (1회만)
                    </div>
                    <div class="com">
                        직원정보에 등록된 본인번호로<br>문자인증(최초 1회 만 실시)
                    </div>
                </li>
            </ul>
            <div class="final-info">
                <i class="icon-btn-arrright"></i>인증 후 바탕화면에 설치된 아이콘(YK건기ERP) 클릭 시 ERP접속 가능
            </div>
            <div class="btn-install">
                 <a href="${bean.pc_url}">
                     <i class="icon-btn-yklogo"></i>
                     <span>설치파일 다운로드</span>
                 </a>
            </div>
        </div>
     
    </div>
</body>
</html>