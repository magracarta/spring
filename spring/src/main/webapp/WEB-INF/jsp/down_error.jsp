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

	$(document).ready(function() {
		
	});
	
	/* function goPcDown() {
		if ("${pc_down_url}" == "") {
			alert("다운로드 URL이 없습니다.");
			return false;
		}
		var param = {
  			contentType : "application/octet-stream"
   		}
		$M.goNextPage("${pc_down_url}", $M.toGetParam(param), {method : "GET", target : '_blank'});
    } */

</script>
<body class="certificate pc">
    <div>
        <h2><img src="/static/img/top-logo.png" alt=""></h2>
        <ul class="certificate-info">
            <li class="msg">
                <span class="text-danger">접속오류!</span>
                <span>아래 내용을 확인 하시기 바랍니다.</span>
                <div class="underline-bg"></div>
            </li>
        </ul>
    </div>
    <ul class="faq">
        <li>         
            1. YK Security 보안 프로그램이 실행 중인지 확인하시기 바랍니다. 만약 프로그램 설치가 안됐으면 아래 설치파일을 다운로드 후 설치하시기 바랍니다.
            <div class="btn-install">
                <a href="${bean.pc_url}">
                    <i class="icon-btn-yklogo"></i>
                    <span>설치파일 다운로드</span>
                </a>
           </div>
        </li>
        <li>         
            2. 프로그램 설치 후 최초 1회 본인 인증을 완료했는지 확인하시기 바랍니다. 인증은 직원정보에 등록된 본인 휴대전화로 보안코드가 전송됩니다. 
        </li>
        <li>
            3. 프로그램 설치도 본인인증1회도 완료했는데 접속이 안되는 경우에는 프로그램을 제거 후 재 설치를 하시기 바랍니다.     
        </li>
    </ul>
    <div class="inquiry">
        문의사항 : 02-0000-0000
    </div>   
</body>
</html>