<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 서비스관리 > 신)서비스업무평가-센터 > null > null
-- 작성자 : 황빛찬
-- 최초 작성일 : 2023-12-01 15:48:00
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var tab_id;

		// 아이프레임 로딩체크 추가 by 이강원
		var tabLoad = [false, false, false];
		function fnLoadFrame(num) {
			tabLoad[num] = true;
		}

		$(document).ready(function() {
			setTimeout(function() {
				$('ul.tabs-c li a').click(function() {
					tab_id = $(this).attr('data-tab');

					$('ul.tabs-c li a').removeClass('active');
					$('.tabs-inner').removeClass('active');

					$(this).addClass('active');
					$("#"+tab_id).addClass('active');

					var startYear = $M.getValue("s_start_year");
					var startMon = $M.getValue("s_start_mon");
					var endYear = $M.getValue("s_end_year");
					var endMon = $M.getValue("s_end_mon");

					if (tab_id == 'inner2') {
						startYear = $M.toNum(startYear) - 1;
						endYear = $M.toNum(endYear) - 1;
						$("#contentFrame2")[0].contentWindow.$("#s_start_year").val(startYear);
						$("#contentFrame2")[0].contentWindow.$("#s_start_mon").val(startMon);
						$("#contentFrame2")[0].contentWindow.$("#s_end_year").val(endYear);
						$("#contentFrame2")[0].contentWindow.$("#s_end_mon").val(endMon);
					}

				});
			}, 1000);
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
									<a href="#" class="tabs-link font-12 active" data-tab="inner1">매출현황</a>
								</li>
								<li class="tabs-item">
									<a href="#" class="tabs-link font-12" data-tab="inner2">전년도 매출현황</a>
								</li>
								<%-- [재호 Q&A 21031] MBO 탭 이동 요청 --%>
								<li class="tabs-item">
									<a href="#" class="tabs-link font-12" data-tab="inner3">MBO</a>
								</li>
							</ul>
							<div id="inner1" class="tabs-inner active"  style="height: 800px;">
								<iframe src="/serv/serv051401" id="contentFrame1" name="contentFrame" frameborder="0" style="width:100%; height: 800px;" scrolling="no" onload="fnLoadFrame(0)"></iframe>
							</div>
							<div id="inner2" class="tabs-inner " style="height: 800px;">
								<iframe src="/serv/serv051402" id="contentFrame2" name="contentFrame" frameborder="0" style="width:100%; height: 800px;" scrolling="yes" onload="fnLoadFrame(1)"></iframe>
							</div>
							<%-- [재호 Q&A 21031] MBO 탭 이동 요청 --%>
							<div id="inner3" class="tabs-inner " style="height: 800px;">
								<iframe src="/serv/serv050204" id="contentFrame3" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="yes" onload="fnLoadFrame(2)"></iframe>
							</div>
								<input type="text" id="s_start_year" name="s_start_year" style="visibility: hidden;" dateformat="yyyy">
								<input type="text" id="s_start_mon" name="s_start_mon" style="visibility: hidden;" dateformat="MM">
								<input type="text" id="s_end_year" name="s_end_year" style="visibility: hidden;" dateformat="yyyy">
								<input type="text" id="s_end_mon" name="s_end_mon" style="visibility: hidden;" dateformat="MM">
						</div>
					</div>		
				</div>
		<!-- /contents 전체 영역 -->	
		</div>	
	</form>
</body>
</html>