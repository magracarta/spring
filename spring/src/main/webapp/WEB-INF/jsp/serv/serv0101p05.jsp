<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 정비 > 정비지시서 > null > 사전예약문자발송여부
-- 작성자 : 성현우
-- 최초 작성일 : 2020-04-07 19:54:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

	// 확인
	function fnConfirm() {
		var params = {
			"reserve_sms_send_target_yn" : "Y",
			"reserve_n" : "Y"
		};

		try {
			opener.${inputParam.parent_js_name}(params);
			window.close();
		} catch(e) {
			alert("호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.");
		}
	}

	// 닫기
	function fnClose() {
		var params = {
			"reserve_sms_send_target_yn" : "N",
			"reserve_n" : "Y"
		};

		try {
			opener.${inputParam.parent_js_name}(params);
			window.close();
		} catch(e) {
			alert("호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.");
		}
	}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">		
			<div class="satisfaction-survey-item">				
				<div class="s-commemt">			
					[${inputParam.s_in_dt}]일에 [${inputParam.s_cust_name}] 고객님의 사전예약 설정이 완료되었습니다.<br>
					예약 1일 전에 예약내용 문자발송을 하시겠습니까?			
				</div>
			</div>
			<div class="btn-group mt10">
				<div class="center">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>