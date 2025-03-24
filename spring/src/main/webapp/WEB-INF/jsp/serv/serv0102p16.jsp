<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp" /><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt"%><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%><%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 정비 > 서비스일지 > null > 전화상담일지 상세 > 크게보기 팝업
-- 작성자 : 성현우
-- 최초 작성일 : 2021-02-17 11:51:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp" />
	<script type="text/javascript">
		function fnClose() {
			window.close();
		}
	</script>
</head>
<body class="bg-white">
	<form id="main_form" name="main_form" style="height: 100%">
		<!-- 팝업 -->
		<div class="popup-wrap width-100per" style="height: 100%">
			<!-- 타이틀영역 -->
			<div class="main-title">
				<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp" />
			</div>
			<div class="content-wrap" style="height: 94%">
				<!-- /타이틀영역 -->
				<c:choose>
					<c:when test="${fn:contains(as_call_text, '</p>') || fn:contains(as_call_text, '</span>') || fn:contains(as_call_text, '</div>')}">
						<div contenteditable="true" style="height: 100%; overflow-y: scroll;" class="form-control mt5 editor">${as_call_text}</div>
					</c:when>
					<c:otherwise>
						<textarea class="form-control mt5" style="height: 100%; background: #fff" id="as_call_text" name="as_call_text" required="required" alt="상담내역" readonly="readonly">${as_call_text}</textarea>
					</c:otherwise>
				</c:choose>
				
				<div class="btn-group mt10">
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R" /></jsp:include>
					</div>
				</div>
			</div>
		</div>
		<!-- /팝업 -->
	</form>
</body>
</html>