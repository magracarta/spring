<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 판매관리 > 장비판매현황-연간 > null > null
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var tab_id;
		$(document).ready(function() {
			$('ul.tabs-c li a').click(function() {
			    tab_id = $(this).attr('data-tab');
				
			    $('ul.tabs-c li a').removeClass('active');
			    $('.tabs-inner').removeClass('active');
			 
			    $(this).addClass('active');
			    $("#"+tab_id).addClass('active');
			    
			});
		});
	</script>
</head>
<body>
<div class="layout-box">
<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
<!-- 메인 타이틀 -->
				<div class="main-title">
<!-- 					<h2>장비판매현황-연간</h2> -->
					<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
				</div>
<!-- /메인 타이틀 -->
				<div class="contents">
					<ul class="tabs-c">
						<li class="tabs-item">
							<a href="#" class="tabs-link font-12 active" data-tab="inner1">연간집계</a>
						</li>
						<li class="tabs-item">
							<a href="#" class="tabs-link font-12" data-tab="inner2">전체집계</a>
						</li>
					</ul>
<!-- 기본 -->					
					<div id="inner1" class="tabs-inner active"  style="height: 700px;"> 
						<iframe src="/sale/sale040201" id="contentFrame1" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no"></iframe>
					</div>
					<div id="inner2" class="tabs-inner " style="height: 950px;"> 
						<iframe src="/sale/sale040202" id="contentFrame2" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no"></iframe> 
					</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
				</div>
			</div>		
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
		</div>
<!-- /contents 전체 영역 -->	
</div>	
</body>
</html>