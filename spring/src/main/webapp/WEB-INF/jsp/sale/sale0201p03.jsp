<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 장비관리 > 장비생산발주 > null > 발주옵션 편집
-- 작성자 : 황빛찬
-- 최초 작성일 : 2024-06-21 13:22:00
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var orderText;

		$(document).ready(function() {
			orderText = window.opener.parentOrderText;
			$M.setValue("order_text", orderText);
		});

		function fnClose() {
			window.close();
		}

		// 적용
		function goApply() {
			if (confirm("변경사항을 적용하시겠습니까?\n해당 내용은 생산발주 화면에서 저장시 저장됩니다.") == false) {
				return;
			}

			var param = {
				"order_text" : $M.getValue("order_text"),
				"seq_no" : "${inputParam.seq_no}"
			}
			opener.fnOrderTextApply(param);
			fnClose();
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
			<textarea class="form-control mt5" style="height: 300px; background: #fff" id="order_text" name="order_text">${order_text}</textarea>
			<div class="btn-group mt5">
				<div class="left">
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
					</div>
					<!-- /검색결과 -->
				</div>
			</div>
		</div>
	</div>
	<!-- /팝업 -->
</form>
</body>
</html>