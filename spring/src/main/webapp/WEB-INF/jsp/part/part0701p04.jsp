<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 코드관리 > 부품마스터등록/수정 > null > 부품그룹코드조회
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2020-01-10 17:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>
	</script>
</head>
<body>
<!-- 팝업 -->
	<div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
		<div class="main-title">
			<h2>부품그룹코드조회</h2>
			<button type="button" class="btn btn-icon"><i class="material-iconsclose"></i></button>
		</div>
<!-- /타이틀영역 -->
		<div class="content-wrap">
<!-- 폼테이블 -->
			<div style="margin-top: 5px; height: 100px; border: 1px solid #ffcc00;">그리드영역</div>
<!-- /폼테이블 -->
			<div class="btn-group mt10">
				<div class="left">
					총 <strong class="text-primary">25</strong>건
				</div>	
				<div class="right">
					<button type="button" class="btn btn-info">닫기</button>
				</div>
			</div>
		</div>
	</div>
<!-- /팝업 -->
</body>
</html>