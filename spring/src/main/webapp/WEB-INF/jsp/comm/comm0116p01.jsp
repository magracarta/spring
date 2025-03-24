<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 정보수정 > 인사고과정보 > null > null
-- 작성자 : 김경빈
-- 최초 작성일 : 2024-05-28 17:29:44
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

			if (${not empty inputParam.tapId}) {
				fnGoTap("${inputParam.tapId}");
			}
		});

		function fnGoTap(tab_id) {
			$('ul.tabs-c li a').removeClass('active');
			$('.tabs-inner').removeClass('active');

			var url = '';
			switch (tab_id) {
				case 'inner1': // 소속원평가
					url = '/comm/comm0116p0101/${inputParam.s_mem_no}';
					break;
				case 'inner2': // 실적평가
					url = '/acnt/acnt0601p0103/${inputParam.s_mem_no}/2';
					break;
				case 'inner3': // 급여/손익
					url = '/acnt/acnt0601p0107/${inputParam.s_mem_no}';
					break;
				case 'inner4': // 복리후생
					url = '/acnt/acnt0601p0105/${inputParam.s_mem_no}';
					break;
				case 'inner5': // 부서평가
					url = '/comm/comm0116p0102/${inputParam.s_mem_no}';
					break;
			}

			$("#" + tab_id).html('<iframe src="' + url + '" id="contentFrame" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no"></iframe>');

			$("a[data-tab="+tab_id+"]").addClass('active');
			$("#" + tab_id).addClass('active');
		}

		// 닫기
		function fnClose() {
			window.close();
		}

	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
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
					<h4>${memInfo.mem_name }(${memInfo.org_name })</h4>
				</div>
				<!-- 탭 -->
				<ul class="tabs-c pr mt5">
					<c:if test="${'Y' eq hr_mon_eval_yn}">
					<li class="tabs-item">
						<a href="#" class="tabs-link font-12 active" data-tab="inner1">소속원평가</a>
					</li>
					</c:if>
					<c:if test="${'Y' eq eval_perform_yn}" >
					<li class="tabs-item">
						<a href="#" class="tabs-link font-12" data-tab="inner2">실적평가</a>
					</li>
					</c:if>
					<li class="tabs-item">
						<a href="#" class="tabs-link font-12 <c:if test="${'N' eq hr_mon_eval_yn}">active</c:if>" data-tab="inner3">급여/손익</a>
					</li>
					<li class="tabs-item">
						<a href="#" class="tabs-link font-12" data-tab="inner4">복리후생</a>
					</li>
					<c:if test="${'Y' eq org_eval_yn}" >
					<li class="tabs-item">
						<a href="#" class="tabs-link font-12" data-tab="inner5">부서평가</a>
					</li>
					</c:if>
				</ul>
				<!-- /탭 -->
				<div id="inner1" class="tabs-inner <c:if test="${'Y' eq hr_mon_eval_yn}">active</c:if>" style="height: 700px;"> <%-- 소속원평가 --%>
					<c:if test="${'Y' eq hr_mon_eval_yn}">
					<iframe src="/comm/comm0116p0101/${inputParam.s_mem_no}" id="contentFrame1" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no"></iframe>
					</c:if>
				</div>
				<div id="inner2" class="tabs-inner" style="height: 1150px;"></div> <!-- 실적평가 -->
				<div id="inner3" class="tabs-inner <c:if test="${'N' eq hr_mon_eval_yn}">active</c:if>" style="height: 1200px;">
					<c:if test="${'N' eq hr_mon_eval_yn}">
					<iframe src="/acnt/acnt0601p0107/${inputParam.s_mem_no}" id="contentFrame3" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no"></iframe>
					</c:if>
				</div> <!-- 급여/손익 -->
				<div id="inner4" class="tabs-inner" style="height: 600px;"></div> <!-- 복리후생 -->
				<c:if test="${'Y' eq org_eval_yn}" >
				<div id="inner5" class="tabs-inner" style="height: 600px;"></div> <!-- 부서평가 -->
				</c:if>
			</div>
		</div>
	</div>
	<!-- /팝업 -->
</form>
</body>
</html>