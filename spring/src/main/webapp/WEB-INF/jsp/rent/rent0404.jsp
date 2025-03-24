<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 렌탈현황 > 렌탈장비 수요분석 > null > null
-- 작성자 : 정윤수
-- 최초 작성일 : 2024-01-18 13:36:21
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		let tab_id;

		$(document).ready(function() {
			// tab 제어
			$('ul.tabs-c li a').click(function() {
			    tab_id = $(this).attr('data-tab');

			    $('ul.tabs-c li a').removeClass('active');
			    $('.tabs-inner').removeClass('active');

			    $(this).addClass('active');
			    $("#"+tab_id).addClass('active');
			});
		});

		/* 하위 iframe 내 페이지에서 공통으로 사용 할 함수 */

		// 뒤에 % 붙이는 커스텀 Label Function
		function percentageLabelFunction(rowIndex, columnIndex, value, headerText, item) {
			return !value ? "" : Math.round(value) + "%";
		}

	</script>
</head>
<body>
<form id="main_form" name="main_form">
	<div class="layout-box">
		<div class="content-wrap">
			<div class="content-box">
				<!-- 메인 타이틀 -->
				<div class="main-title">
					<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
				</div>
				<!-- /메인 타이틀 -->
				<!-- contents -->
				<div class="contents">
					<!-- 탭 -->
					<ul class="tabs-c">
						<li class="tabs-item">
							<a href="#" class="tabs-link font-12 active" data-tab="inner1">고객별</a>
						</li>
						<li class="tabs-item">
							<a href="#" class="tabs-link font-12" data-tab="inner2" >모델별</a>
						</li>
					</ul>
					<!-- /탭 -->
					<div id="inner1" class="tabs-inner active"  style="height: 780px;">
						<iframe src="/rent/rent040401" id="contentFrame1" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no"></iframe>
					</div>
					<div id="inner2" class="tabs-inner " style="height: 780px;">
						<iframe src="/rent/rent040402" id="contentFrame2" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no"></iframe>
					</div>
				</div>
				<!-- /contents -->
			</div>
		</div>
	</div>
	<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
</form>
</body>
</html>