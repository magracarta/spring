<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 판매관리 > 장비판매현황-연간 > null > 연간장비판매현황상세(전체집계)
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2019-12-19 14:23:48
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
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <h2>연간장비판매현황상세</h2>
            <button type="button" class="btn btn-icon"><i class="material-iconsclose"></i></button>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">	
			<div class="title-wrap">		
				<h4>2019-09월 조회결과</h4>
				<div class="condition-items">
					<button type="button" class="btn btn-default"><i class="icon-btn-excel inline-btn"></i>엑셀다운로드</button>
				</div>				
			</div>	
			<div style="margin-top: 5px; height: 300px; border: 1px solid #ffcc00;">그리드영역</div>
<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">		
				<div class="left">
					총 <strong class="text-primary">25</strong>건
				</div>				
				<div class="right">
					<button type="button" class="btn btn-info" style="width: 50px;">닫기</button>
				</div>
			</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
<!-- /상단 폼테이블 -->
        </div>
    </div>
<!-- /팝업 -->

</form>
</body>
</html>