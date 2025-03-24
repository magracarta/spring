<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 서비스관리 > 센터 별 월 예정사항 > 월 예정사항 등록 > null
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2021-04-09 14:09:45
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
<form id="main_form" name="main_form">
<div class="layout-box">
<!-- contents 전체 영역 -->
	<div class="content-wrap">
		<div class="content-box">
<!-- 상세페이지 타이틀 -->
			<div class="main-title detail">
				<div class="detail-left">
					<button type="button" class="btn btn-outline-light"><i class="material-iconskeyboard_backspace text-default"></i></button>
					<h2>제목넣어 주세요.</h2>
				</div>
			</div>
<!-- /상세페이지 타이틀 -->
			<div class="contents">
<!-- 폼테이블 -->	
			<%-- 컨텐츠 내용 넣어주세요. --%>
				<div class="btn-group mt10">
					<div class="right"><%-- 버튼위치는 pos param 에 따라 나옴 (없으면 기본 상단나옴) T_CODE.CODE_VALUE='BTN_POS' 참고 --%>
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						<button type="button" class="btn btn-info" style="width: 60px;">저장</button>
						<button type="button" class="btn btn-info" style="width: 60px;">목록</button>
					</div>
				</div>
<!-- /폼테이블 -->	
			</div>						
		</div>		
	</div>
<!-- /contents 전체 영역 -->	
</div>
</form>	
</body>
</html>