<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 고객관리 > 전화업무 통합관리 > Happy Call > 설문상세
-- 작성자 : 최보성
-- 최초 작성일 : 2020-04-07 19:54:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

	$(document).ready(function () {
		// 버튼 노출 제어
		if (${map.happycall_mile_cd ne '01'}) {
			$("#_goNewMile").prop("disabled", "true");
			$("#_goExceptMile").prop("disabled", "true");
		}
	});

	// 문자발송
	function fnSendSms() {
		var param = {
			"name" : $M.getValue("cust_name"),
			"hp_no" : $M.getValue("hp_no")
		};

		openSendSmsPanel($M.toGetParam(param));
	}

	// 마일리지 적립
	function goNewMile() {
		var msg = "마일리지를 적립하시겠습니까?"
		var frm = document.main_form;
		$M.goNextPageAjaxMsg(msg, '/serv/serv040404/save/mile', $M.toValueForm(frm), {method : 'POST'},
				function(result) {
					if(result.success) {
						window.location.reload();
						window.opener.goSearch();
					}
				}
		);
	}

	// 마일리지 적립제외
	function goExceptMile() {
		var msg = "적립제외 처리하시겠습니까?"
		var frm = document.main_form;
		$M.goNextPageAjaxMsg(msg, '/serv/serv040404/except/mile', $M.toValueForm(frm), {method : 'POST'},
				function(result) {
					if(result.success) {
						window.location.reload();
						window.opener.goSearch();
					}
				}
		);
	}

	// 닫기
    function fnClose() {
    	window.close();
    }

	// 2024-07-24 황빛찬 (Q&A : 23515 / 21967) 설문상세 정비지시서, 서비스일지 팝업 호출 버튼 추가
	// 정비지시서 상세 팝업 호출
	function goJobReportPopup() {
		var param = {
			"s_job_report_no" : $M.getValue("job_report_no")
		};
		$M.goNextPage("/serv/serv0101p01", $M.toGetParam(param), {popupStatus : ""});
	}

	// 2024-07-24 황빛찬 (Q&A : 23515 / 21967) 설문상세 정비지시서, 서비스일지 팝업 호출 버튼 추가
	// 서비스일지 상세 팝업 호출
	function goAsRepairPopup() {
		var params = {
			"s_job_report_no" : $M.getValue("job_report_no")
		}
		$M.goNextPageAjax("/serv/serv0101p01/search", $M.toGetParam(params), {method : "GET"},
			function(result) {
				if(result.success) {
					if (result.asRepairMap === undefined) {
						alert("작성된 서비스일지가 없습니다.");
					} else {
						params.s_as_no = result.asRepairMap.as_no;
						$M.goNextPage('/serv/serv0102p01', $M.toGetParam(params), {popupStatus : ""});
					}
				}
			}
		);
	}


	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<input type="hidden" name="job_report_no" value="${map.job_report_no}">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
<!-- 폼테이블1 -->					
			<div>
				<table class="table-border mt5">
					<colgroup>
						<col width="100px">
						<col width="">
						<col width="100px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th class="th-gray text-right">고객명</th>
							<td>
								<input type="text" id="cust_name" name="cust_name" value="${map.cust_name}" class="form-control width120px" readonly="readonly">
							</td>
							<th class="th-gray text-right">연락처</th>
							<td>
								<div class="input-group width140px">
									<input type="text" id="hp_no" name="hp_no" value="${map.hp_no}" class="form-control border-right-0" readonly="readonly">
									<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSendSms();" ><i class="material-iconsforum"></i></button>
								</div>
							</td>
						</tr>		
						<tr>
							<th class="th-gray text-right">정비일</th>
							<td>
								<input type="text" class="form-control width120px" id="job_st_dt" name="job_st_dt" dateformat="yyyy-MM-dd" readonly="readonly" value="${map.job_st_dt}">
							</td>
							<th class="th-gray text-right">정비완료일</th>
							<td>
								<input type="text" class="form-control width120px" id="job_ed_dt" name="job_ed_dt" readonly="readonly" dateformat="yyyy-MM-dd" value="${map.job_ed_dt}">
							</td>
						</tr>	
						<tr>
							<th class="th-gray text-right">모델명</th>
							<td>
								<input type="text" value="${map.machine_name }" class="form-control" readonly="readonly">
							</td>
							<th class="th-gray text-right">차대번호</th>
							<td>
								<input type="text" value="${map.body_no }" class="form-control" readonly="readonly">
							</td>
						</tr>							
					</tbody>
				</table>
			</div>					
<!-- /폼테이블1 -->
<!-- 폼테이블2 -->	
			<div>
				<table class="table-border mt10">
					<colgroup>
						<col width="100px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right">제목</th>
							<td>${map.survey_title }</td>									
						</tr>
						<c:forEach var="list" items="${list}" varStatus="status">
							<tr>
								<th rowspan="2" class="text-right">질의${status.count}</th>
								<td>${list.ques_title }</td>							
							</tr>
							<tr>
								<td>답변 : ${list.answer }</td>							
							</tr>
						</c:forEach>		
					</tbody>
				</table>
			</div>	
<!-- /폼테이블2 -->						
			<div class="btn-group mt10">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>