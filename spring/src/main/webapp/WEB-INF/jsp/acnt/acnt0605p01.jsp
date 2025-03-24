<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 인사 > 고과평가관리 > null > 고과평가 상세
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2021-04-09 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var tab_id;

		$(document).ready(function () {
			$('ul.tabs-c li a').click(function () {
				tab_id = $(this).attr('data-tab');
				fnGoTap(tab_id);
			});
			
			var tapId = "${inputParam.tapId}";
			fnGoTap(tapId == "" ? "inner3" : tapId);
		});
		
		function fnGoTap(tab_id) {
			$('ul.tabs-c li a').removeClass('active');
			$('.tabs-inner').removeClass('active');

			var url = '';
			if(tab_id == "inner1") { // 월 평가서
				url = '/acnt/acnt0605p0101/${inputParam.s_mem_no}';
			} else if(tab_id == "inner2") { // 실적평가
				url = '/acnt/acnt0601p0103/${inputParam.s_mem_no}/1';
			} else if(tab_id == "inner3") { // 인사고과
				url = '/acnt/acnt0605p0102/${inputParam.s_mem_no}';
			}

			$("#"+tab_id).html('<iframe src="' + url + '" id="contentFrame" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no"></iframe>');

			$("a[data-tab="+tab_id+"]").addClass('active');
			$("#" + tab_id).addClass('active');
		}

		function fnClose() {
			window.close();
		}

	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<input type="hidden" id="work_gubun_cd" name="work_gubun_cd" value="${memInfo.work_gubun_cd}"/>
	<!-- 팝업 -->
	<div class="popup-wrap width-100per">
		<!-- 타이틀영역 -->
		<div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
		</div>
		<!-- /타이틀영역 -->
		<div class="content-wrap">
			<div>
				<div class="title-wrap">
					<h4>${memInfo.mem_name}(${memInfo.org_name})</h4>
				</div>
				<!-- 탭 -->
				<ul class="tabs-c pr mt5">
					<%-- 본인 페이지 열람인 경우 월 평가서 숨김 --%>
					<c:if test="${SecureUser.mem_no ne inputParam.s_mem_no}">
					<li class="tabs-item">
						<a href="#" class="tabs-link font-12" data-tab="inner1">월 평가서</a>
					</li>
					</c:if>

					<c:if test="${'Y' eq eval_perform_yn}" > <%-- 실적평가 노출 여부 --%>
					<li class="tabs-item">
						<a href="#" class="tabs-link font-12" data-tab="inner2">실적평가</a>
					</li>
					</c:if>

					<li class="tabs-item">
						<a href="#" class="tabs-link font-12" data-tab="inner3">인사고과</a>
					</li>
				</ul>
				<!-- /탭 -->
				<div id="inner1" class="tabs-inner" style="height: 700px;"></div> <!-- 월 평가서 -->
				<div id="inner2" class="tabs-inner" style="height: 1150px;"></div> <!-- 실적평가 -->
				<div id="inner3" class="tabs-inner active" style="height: 1020px;"></div> <!-- 인사고과 -->
			</div>
		</div>
	</div>
	<!-- /팝업 -->
</form>
</body>
</html>