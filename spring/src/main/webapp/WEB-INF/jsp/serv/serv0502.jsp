<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 서비스관리 > 서비스업무평가-센터 > null > null
-- 작성자 : 손광진
-- 최초 작성일 : 2020-04-08 11:37:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>
	
		var tab_id;

		// 아이프레임 로딩체크 추가 by 이강원
		var tabLoad = [false, false, false];
		function fnLoadFrame(num) {
			tabLoad[num] = true;
		}
	
		$(document).ready(function() {
			$('ul.tabs-c li a').click(function() {
			    tab_id = $(this).attr('data-tab');

				// 아이프레임이 로드됬는지 확인함
				var tabNum = tab_id.substr(5, 1);
				if (tabLoad[tabNum-1] == false) {
					alert("잠시만 기다려주세요.");
					return false;
				}
				
			    $('ul.tabs-c li a').removeClass('active');
			    $('.tabs-inner').removeClass('active');
			 
			    $(this).addClass('active');
			    $("#"+tab_id).addClass('active');
			    
			});
		});
	
	</script>
</head>
<body>
	<form id="main_form" name="main_form">
		<div class="layout-box">
		<!-- contents 전체 영역 -->
				<div class="content-wrap">
					<div class="content-box">
		<!-- 메인 타이틀 -->
						<div class="main-title">
							<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
						</div>
		<!-- /메인 타이틀 -->
						<div class="contents">
							<ul class="tabs-c">
								<li class="tabs-item">
									<a href="#" class="tabs-link font-12 active" data-tab="inner1">집계표</a>
								</li>
								<%-- [재호 Q&A 21031] MBO 탭 이동 요청 --%>
<%--								<li class="tabs-item">--%>
<%--									<a href="#" class="tabs-link font-12" data-tab="inner2">MBO</a>--%>
<%--								</li>--%>
								<li class="tabs-item">
									<a href="#" class="tabs-link font-12" data-tab="inner3">실적분석</a>
								</li>
							</ul>												
							<div id="inner1" class="tabs-inner active"  style="height: 690px;"> 
								<iframe src="/serv/serv050201" id="contentFrame1" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no" onload="fnLoadFrame(0)"></iframe>
							</div>
							<div id="inner2" class="tabs-inner " style="height: 690px;">
								<%-- [재호] 새로운 MBO 창을 위해 serv050204 로 수정 --%>
								<%-- [재호 Q&A 21031] MBO 탭 이동 요청 --%>
								<%--<iframe src="/serv/serv050202" id="contentFrame2" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="yes" onload="fnLoadFrame(1)"></iframe>--%>
<%--								<iframe src="/serv/serv050204" id="contentFrame2" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="yes" onload="fnLoadFrame(1)"></iframe>--%>
							</div>	
							<div id="inner3" class="tabs-inner " style="height: 690px;"> 
								<iframe src="/serv/serv050203" id="contentFrame3" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="yes" onload="fnLoadFrame(2)"></iframe>
							</div>		
						</div>
					</div>		
				</div>
		<!-- /contents 전체 영역 -->	
		</div>	
	</form>
</body>
</html>