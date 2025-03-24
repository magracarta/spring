<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 정비 > 정비지시서 > null > 정비만족도
-- 작성자 : 성현우
-- 최초 작성일 : 2020-07-02 19:54:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

	// 확인
    function goSave() {
    	var custPoint = $M.getValue("cust_point");

		try {
			opener.${inputParam.parent_js_name}(custPoint);
			window.close();
		} catch(e) {
			alert("호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.");
		}
    }

	// 닫기
    function fnClose() {
    	window.close();
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
					처리후 수정이 불가하오니 발생공임 및 출장비,<br>부품청구금액을 확인 후 처리하세요!				
				</div>
				<div class="s-check">
					<h3>정비만족도평가</h3>
					<div class="pb10">
						<div class="form-check form-check-inline">
							<input class="form-check-input" type="radio" id="cust_point_10" name="cust_point" value="10">
							<label class="form-check-label" for="cust_point_10">매우만족</label>
						</div>
						<div class="form-check form-check-inline">
							<input class="form-check-input" type="radio" id="cust_point_8" name="cust_point" value="8">
							<label class="form-check-label" for="cust_point_8">만족</label>
						</div>
						<div class="form-check form-check-inline">
							<input class="form-check-input" type="radio" id="cust_point_5" name="cust_point" value="5" checked="checked">
							<label class="form-check-label" for="cust_point_5">보통</label>
						</div>
						<div class="form-check form-check-inline">
							<input class="form-check-input" type="radio" id="cust_point_3" name="cust_point" value="3">
							<label class="form-check-label" for="cust_point_3">불만</label>
						</div>
						<div class="form-check form-check-inline">
							<input class="form-check-input" type="radio" id="cust_point_1" name="cust_point" value="1">
							<label class="form-check-label" for="cust_point_1">매우불만</label>
						</div>
					</div>
				</div>
			</div>
			<div class="btn-group mt10">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>