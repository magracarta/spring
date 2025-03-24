<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 자산 > 인사관리 > null > 직원관리상세
-- 작성자 : 손광진
-- 최초 작성일 : 2020-05-15 10:03:57
-- 2022-12-19 jsk : erp3-2차 권한관리 수정
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

				$('ul.tabs-c li a').removeClass('active');
				$('.tabs-inner').removeClass('active');

				var url = '';
				switch (tab_id) {
					case "inner1": // 상세정보
						url = '/acnt/acnt0601p0101/${inputParam.s_mem_no}';
						break;
					case "inner5": // 급여/손익
						url = '/acnt/acnt0601p0107/${inputParam.s_mem_no}';
						break;
					case "inner6": // 복리후생
						url = '/acnt/acnt0601p0105/${inputParam.s_mem_no}';
						break;
				}
				// 2022-12-16 jsk 기타설정 탭 제거
				// else if(tab_id == "inner7") {
				// 	url = '/acnt/acnt0601p0106/${inputParam.s_mem_no}';
				// }

				$("#"+tab_id).html('<iframe src="' + url + '" id="contentFrame" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no"></iframe>');

				$(this).addClass('active');
				$("#" + tab_id).addClass('active');
			});
		});

		function fnReport(gubun, memNo) {
			var reportName = '';
			switch (gubun) {
				case '1' :
					reportName = 'acnt/acnt0601p01_01.crf';
					break;
				case '2' :
					reportName = 'acnt/acnt0601p01_02.crf';
					break;
				case '3' :
					reportName = 'acnt/acnt0601p01_03.crf';
					break;
			}

			openReportPanel(reportName, 's_mem_no=' + memNo);
		}

		function fnClose() {
			window.close();
		}

		// 고과평가상세 팝업 호출
		function goPopupEvalDtl() {
			var param = {
				"s_mem_no": "${inputParam.s_mem_no}",
			};

			$M.goNextPage("/acnt/acnt0605p01", $M.toGetParam(param), {popupStatus: "", method: "POST"});
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
					<h4>직원관리 - ${memInfo.mem_name }(${memInfo.org_name })</h4>
					<div class="right">
						<button type="button" class="btn btn-primary-gra" onclick="goPopupEvalDtl()">고과평가상세</button>
					</div>
				</div>
				<!-- 탭 -->
				<ul class="tabs-c pr mt5">
					<li class="tabs-item">
						<a href="#" class="tabs-link font-12 active" data-tab="inner1">상세정보</a>
					</li>
					<%-- 탭 노출 권한 --%>
					<c:if test="${tab_auth_yn eq 'Y'}">
						<li class="tabs-item">
							<a href="#" class="tabs-link font-12" data-tab="inner5">급여/손익</a>
						</li>
						<li class="tabs-item">
							<a href="#" class="tabs-link font-12" data-tab="inner6">복리후생</a>
						</li>
					</c:if>

					<c:if test="${report_show_yn eq 'Y'}">
						<li class="tabs-c-right-btn">
							<!-- 2차 개발로 MY > 기안문서로 이동 210617 김상덕 -->
							<button type="button" class="btn btn-md btn-rounded btn-outline-primary" onclick="javascript:fnReport('1', '${inputParam.s_mem_no}');"><i class="material-iconsprint text-primary"></i> 경조금지급신청서 출력</button>
							<button type="button" class="btn btn-md btn-rounded btn-outline-primary" onclick="javascript:fnReport('2', '${inputParam.s_mem_no}');"><i class="material-iconsprint text-primary"></i> 경력증명서 출력</button>
							<button type="button" class="btn btn-md btn-rounded btn-outline-primary" onclick="javascript:fnReport('3', '${inputParam.s_mem_no}');"><i class="material-iconsprint text-primary"></i> 재직증명서 출력</button>
						</li>
					</c:if>
				</ul>
				<!-- /탭 -->
				<%-- 상세정보 --%>
				<div id="inner1" class="tabs-inner active" style="height: 860px;">
						<iframe src="/acnt/acnt0601p0101/${inputParam.s_mem_no}" id="contentFrame1" name="contentFrame" frameborder="0" style="width:100%; height: 100%;" scrolling="no"></iframe>
				</div>
				<!-- 급여/손익 -->
				<div id="inner5" class="tabs-inner" style="height: 1600px;"></div>
				<!-- 복리후생 -->
				<div id="inner6" class="tabs-inner" style="height: 600px;"></div>
			</div>
		</div>
	</div>
	<!-- /팝업 -->
</form>
</body>
</html>