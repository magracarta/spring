<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 고객현황 > 견적서관리 > null > null
-- 작성자 : 김태훈
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var tab_id;

		<%-- 여기에 스크립트 넣어주세요. --%>
		$(document).ready(function() {
			// fnInit();
			$('ul.tabs-c li a').click(function() {
				tab_id = $(this).attr('data-tab');

				$('ul.tabs-c li a').removeClass('active');
				$('.tabs-inner').removeClass('active');

				$(this).addClass('active');
				$("#"+tab_id).addClass('active');
			});
		});

		// 목록과 등록페이지 화면크기 재설정
		function fnStyleChange(machineYn, pageType) {
			if (machineYn == 'Y') {
				if (pageType == "search") {
					$("#inner2").css("height", "700px");
				} else if (pageType == "add") {
					$("#inner2").css("height", "1200px");
				}
			} else {
				if (pageType == "search") {
					$("#inner1").css("height", "700px");
				} else if (pageType == "add") {
					$("#inner1").css("height", "1300px");
				}
			}
		}

	</script>
</head>
<body>
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
					<c:if test="${page.fnc.F00033_001 ne 'Y'}">
						<li class="tabs-item">
							<a href="#" class="tabs-link font-12 active"  data-tab="inner1">수주/정비/렌탈</a>
						</li>
						<li class="tabs-item">
							<a href="#" class="tabs-link font-12"  data-tab="inner2">장비 견적서</a>
						</li>
					</c:if>
					<c:if test="${page.fnc.F00033_001 eq 'Y'}">
						<li class="tabs-item">
							<a href="#" class="tabs-link font-12 active"  data-tab="inner2">장비 견적서</a>
						</li>
					</c:if>

				</ul>
				<!-- /탭 -->

				<!-- /메인 타이틀 -->

				<c:if test="${page.fnc.F00033_001 ne 'Y'}">
					<div id="inner1" class="tabs-inner active"  style="height: 1300px;">
						<iframe src="/cust/cust010710" id="contentFrame1" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no"></iframe>
					</div>
					<div id="inner2" class="tabs-inner" style="height: 850px;">
						<iframe src="/cust/cust010711" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no"></iframe>
					</div>
				</c:if>
				<c:if test="${page.fnc.F00033_001 eq 'Y'}">
					<div id="inner2" class="tabs-inner active" style="height: 850px;">
						<iframe src="/cust/cust010711" id="contentFrame2" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no"></iframe>
					</div>
				</c:if>
			</div>
		</div>
		<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
	</div>
	<!-- /contents 전체 영역 -->
</div>
</body>
</html>