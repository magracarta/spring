<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 정비 > 정비지시서 > null > 기간별 점검표 변경
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2020-04-07 19:54:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		// Cap정비
		function goSave() {
			var params = {
				"cap_use_yn" : "Y",
			};

			try {
				opener.${inputParam.parent_js_name}(params);
				window.close();
			} catch(e) {
				alert("호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.");
			}
		}

		// 일반정비
		function goModify() {
			var params = {
				"cap_use_yn" : "N",
				"job_type_cd" : "4",
			};

			try {
				opener.${inputParam.parent_js_name}(params);
				window.close();
			} catch(e) {
				alert("호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.");
			}
		}

		// 초기정비
		function goSaveRate() {
			var params = {
				"cap_use_yn" : "N",
        "job_type_cd" : "4",
				"job_type2_cd" : "2",
			};

			try {
				opener.${inputParam.parent_js_name}(params);
				window.close();
			} catch(e) {
				alert("호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.");
			}
		}

		// 종료정비
		function goTempSave() {
			var params = {
				"cap_use_yn" : "N",
        "job_type_cd" : "4",
				"job_type2_cd" : "3",
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
					정비구분을 선택해주세요.
				</div>
			</div>
			<div class="btn-group mt10">
				<div class="center">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
			<div class="btn-group mt10">
				<div class="center">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_M"/></jsp:include>
				</div>
			</div>
		</div>
	</div>
	<!-- /팝업 -->
</form>
</body>
</html>
