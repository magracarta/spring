<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 출하시임의비용처리 > null
-- 작성자 : 정재호
-- 최초 작성일 : 2022-11-11 10:00:00
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var tab_id;

		// 아이프레임 로딩체크 추가 by 김태훈
		var tabLoad = [false, false];
		function fnLoadFrame(num) {
			tabLoad[num] = true;
		}

		$(document).ready(function() {

			setTimeout(function(){
				$('ul.tabs-c li a').click(function() {
					tab_id = $(this).attr('data-tab');

					// 아이프레임이 로드됬는지 확인함
					var tabNum = tab_id.substr(5, 1);
					if (tabLoad[tabNum-1] == false) {
						alert("잠시만 기다려주세요.");
						console.error(tabNum, "아이프레임이 아직 로드안됨 =>", tabLoad);
						return false;
					}

					if (tab_id == 'inner1' || tab_id == undefined) {
						iframe = document.getElementById("contentFrame1");
					} else if (tab_id == 'inner2') {
						iframe = document.getElementById("contentFrame2");
					}

					if (iframe.contentWindow.createAUIGrid) {
						iframe.contentWindow.createAUIGrid();
					}
					if (iframe.contentWindow.goSearch) {
						iframe.contentWindow.goSearch();
					}

					$('ul.tabs-c li a').removeClass('active');
					$('.tabs-inner').removeClass('active');

					$(this).addClass('active');
					$("#"+tab_id).addClass('active');
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
				<!-- 탭 -->
				<div class="contents">
					<ul class="tabs-c">
						<li class="tabs-item">
							<a href="#" class="tabs-link font-12 active"  data-tab="inner1">원가 미 반영</a>
						</li>
						<li class="tabs-item">
							<a href="#" class="tabs-link font-12"  data-tab="inner2">원가반영</a>
						</li>
					</ul>
					<!-- /탭 -->

					<!-- /메인 타이틀 -->

					<div id="inner1" class="tabs-inner active"  style="height: 850px;">
						<iframe src="/acnt/acnt040601" id="contentFrame1" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no" onload="fnLoadFrame(0)"></iframe>
					</div>
					<div id="inner2" class="tabs-inner " style="height: 850px;">
						<iframe src="/acnt/acnt040602" id="contentFrame2" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no" onload="fnLoadFrame(1)"></iframe>
					</div>
				</div>
			</div>
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
		</div>
		<!-- /contents 전체 영역 -->
	</div>
</form>
</body>
</html>