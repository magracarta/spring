<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 근무관리 > null > 연장근로신청서
-- 작성자 : 성현우
-- 최초 작성일 : 2020-04-09 11:51:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

	var reqInHour = "";
	var reqInMin = "";
	var reqOutHour = "";
	var reqOutMin = "";
	var approvalInHour = "";
	var approvalInMin = "";
	var approvalOutHour = "";
	var approvalOutMin = "";
	$(document).ready(function () {
		fnInit();
	});

	function fnInit() {
		var apprProcStatusCd = "${list.appr_proc_status_cd}";
		console.log(apprProcStatusCd);
		if(apprProcStatusCd != "" && apprProcStatusCd != "00" && apprProcStatusCd != "01") {
			$("#req_in_hour").prop("disabled", true);
			$("#req_in_min").prop("disabled", true);
			$("#req_out_hour").prop("disabled", true);
			$("#req_out_min").prop("disabled", true);

			$("#approval_in_hour").prop("disabled", true);
			$("#approval_in_min").prop("disabled", true);
			$("#approval_out_hour").prop("disabled", true);
			$("#approval_out_min").prop("disabled", true);

			$("#remark").prop("disabled", true);
		}

		setInterval(reqCalcTime, 100);
		setInterval(approvalCalcTime, 100);
	}

	// 신청시간 입력 시 승인시간 setting
	function fnSetAppr() {
		$M.setValue("approval_in_hour", $M.getValue("req_in_hour"));
		$M.setValue("approval_in_min", $M.getValue("req_in_min"));
		$M.setValue("approval_out_hour", $M.getValue("req_out_hour"));
		$M.setValue("approval_out_min", $M.getValue("req_out_min"));
	}

	function reqCalcTime() {
		var sReqInHour = $M.getValue("req_in_hour");
		var sReqInMIn = $M.getValue("req_in_min");
		var sReqOutHour = $M.getValue("req_out_hour");
		var sReqOutMin = $M.getValue("req_out_min");

		if(reqInHour != sReqInHour) {
			reqInHour = sReqInHour;
		}

		if(reqInMin != sReqInMIn) {
			reqInMin = sReqInMIn;
		}

		if(reqOutHour != sReqOutHour) {
			reqOutHour = sReqOutHour;
		}

		if(reqOutMin != sReqOutMin) {
			reqOutMin = sReqOutMin;
		}

		var lapsetime = 0;
		var reqInTime = getTime(reqInHour, reqInMin);
		var reqOutTime = getTime(reqOutHour, reqOutMin);

		if(reqOutTime.getTime() < reqInTime.getTime()) {
			reqOutTime.setDate(reqOutTime.getDate() + 1);
		}

		try {
			lapsetime = (Math.floor(((reqOutTime.getTime() - reqInTime.getTime()) / 1000 / 60 / 60) * 10) / 10) ;
			//5시간이상 근무 시 점시시간 한시간 포함한다.
			if(lapsetime >= 5) {
				lapsetime--;
			}

			var temp = (lapsetime + '').split(".");
			var templapsetime0 = temp[0];
			var templapsetime1 = temp[1];

			if(templapsetime1 >= 5) {
				templapsetime1 = 5
			} else {
				templapsetime1 = 0
			}

			if(templapsetime0 <= 0) {
				lapsetime = 0;
			} else {
				lapsetime = templapsetime0 + '.' + templapsetime1;
			}
		} catch(Exception) {
		}
		// $("#req_time").val(lapsetime);
		$M.setValue("req_time", lapsetime);
	}

	function approvalCalcTime() {
		var sApprovalInHour = $M.getValue("approval_in_hour");
		var sApprovalInMin = $M.getValue("approval_in_min");
		var sApprovalOutHour = $M.getValue("approval_out_hour");
		var sApprovalOutMin = $M.getValue("approval_out_min");

		if(approvalInHour != sApprovalInHour) {
			approvalInHour = sApprovalInHour;
		}

		if(approvalInMin != sApprovalInMin) {
			approvalInMin = sApprovalInMin;
		}

		if(approvalOutHour != sApprovalOutHour) {
			approvalOutHour = sApprovalOutHour;
		}

		if(approvalOutMin != sApprovalOutMin) {
			approvalOutMin = sApprovalOutMin;
		}

		var lapsetime = 0;
		var approvalInTime = getTime(approvalInHour, approvalInMin);
		var approvalOutTime = getTime(approvalOutHour, approvalOutMin);

		if(approvalOutTime.getTime() < approvalInTime.getTime()) {
			approvalOutTime.setDate(approvalOutTime.getDate() + 1);
		}

		try {
			lapsetime = (Math.floor(((approvalOutTime.getTime() - approvalInTime.getTime()) / 1000 / 60 / 60) * 10) / 10) ;
			//5시간이상 근무 시 점시시간 한시간 포함한다.
			if(lapsetime >= 5) {
				lapsetime--;
			}

			var temp = (lapsetime + '').split(".");
			var templapsetime0 = temp[0];
			var templapsetime1 = temp[1];

			if(templapsetime1 >= 5) {
				templapsetime1 = 5
			} else {
				templapsetime1 = 0
			}

			if(templapsetime0 <= 0) {
				lapsetime = 0;
			} else {
				lapsetime = templapsetime0 + '.' + templapsetime1;
			}
		} catch(Exception) {
		}
		// $("#approval_time").val(lapsetime);
		$M.setValue("approval_time", lapsetime);
	}

	function getTime(hour, min) {
		var d = new Date();

		if("" == hour) {
			hour = 0;
		}

		if("" == min) {
			min = 0;
		}

		return new Date(d.getFullYear(), d.getMonth(), d.getDay(), Number(hour), Number(min));
	}

	// 결재요청
	function goRequestApproval() {
		goSave('requestAppr');
	}

	// 저장
	function goSave(isRequestAppr) {
		var frm = document.main_form;

		if($M.getValue("mem_no") != '${SecureUser.mem_no}') {
			alert("결재요청 및 저장은 본인만 할 수 있습니다.");
			return;
		}

		//validationcheck
		if($M.validation(frm,
				{field:["req_in_hour", "req_in_min", "req_out_hour", "req_out_min", "remark"]}) == false) {
			return;
		};

		// 총 승인된 연장근무시간
		var totApprTime = $M.getValue("tot_appr_time");
		// 최대 신청할 수 있는 연장근무시간
		var addLimitHour = $M.getValue("add_limit_hour");
		// 현재 신청한 연장근무시간
		var approvalTime = $M.getValue("approval_time");
		var lastApprTime = parseFloat(totApprTime) + parseFloat(approvalTime);

		if(lastApprTime > addLimitHour) {
			alert("신청가능한 연장근무시간을 초과하였습니다.\n(최대 : " + addLimitHour + "시간 / 현재 : " + lastApprTime + "시간)");
			return;
		}

		var reqInTi = $M.getValue("req_in_hour") + $M.getValue("req_in_min");
		var reqOutTi = $M.getValue("req_out_hour") + $M.getValue("req_out_min");
		var approvalInTi = $M.getValue("approval_in_hour") + $M.getValue("approval_in_min");
		var approvalOutTi = $M.getValue("approval_out_hour") + $M.getValue("approval_out_min");

		$M.setValue("req_in_ti", reqInTi);
		$M.setValue("req_out_ti", reqOutTi);
		$M.setValue("approval_in_ti", approvalInTi);
		$M.setValue("approval_out_ti", approvalOutTi);

		var msg = "";
		if(isRequestAppr != undefined) {
			// 결재요청 Setting
			$M.setValue("save_mode", "appr");
			msg = "결재요청 하시겠습니까?";
		} else {
			$M.setValue("save_mode", "save");
			msg = "저장 하시겠습니까?";
		}

		$M.goNextPageAjaxMsg(msg, this_page + "/save", frm, {method : 'POST'},
		 function(result) {
			 if(result.success) {
			 	alert("처리가 완료되었습니다.");
			 	fnClose();
			 	window.opener.goSearch();
			 }
		 });
	}

	// 닫기
	function fnClose() {
		window.close();
	}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" id="save_mode" name="save_mode"> <!-- appr(결재요청 후 저장), save(저장) -->
<input type="hidden" id="mem_work_add_seq" name="mem_work_add_seq" value="${inputParam.s_mem_work_add_seq}">
<input type="hidden" id="mem_no" name="mem_no" value="${inputParam.s_mem_no}">
<input type="hidden" id="org_code" name="org_code" value="${inputParam.s_org_code}">
<input type="hidden" id="appr_proc_status_cd" name="appr_proc_status_cd" value="${result.appr_proc_status_cd}">
<input type="hidden" id="req_in_ti" name="req_in_ti">
<input type="hidden" id="req_out_ti" name="req_out_ti">
<input type="hidden" id="approval_in_ti" name="approval_in_ti">
<input type="hidden" id="approval_out_ti" name="approval_out_ti">
<input type="hidden" id="tot_appr_time" name="tot_appr_time" value="${tot_appr_time}">
<input type="hidden" id="add_limit_hour" name="add_limit_hour" value="${inputParam.add_limit_hour}">
<input type="hidden" id="appr_job_seq" name="appr_job_seq" value="${list.appr_job_seq}">

<div class="popup-wrap width-100per">
<!-- 메인 타이틀 -->
<div class="main-title">
	<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"></jsp:include>
</div>
<!-- /메인 타이틀 -->
<div class="content-wrap">
	<div class="title-wrap half-print" style="min-width: 1000px;">
		<div class="doc-info" style="flex: 1;">
			<h4>연장근무신청서</h4>
			<div class="btn-group">
				<div class="right dpf ml5">
					<p class="text-warning mr5">${excess_msg}</p>
				</div>
			</div>
		</div>
		<!-- 결재영역 -->
		<div class="p10" style="margin-left: 10px;">
			<jsp:include page="/WEB-INF/jsp/common/apprHeader.jsp"></jsp:include>
		</div>
		<!-- /결재영역 -->
	</div>
	<table class="table-border mt10">
		<colgroup>
			<col width="140px">
			<col width="">
			<col width="140px">
			<col width="">
			<col width="">
			<col width="">
		</colgroup>
		<tbody>
		<tr>
			<th class="text-right">작성일자</th>
			<td colspan="3">
				<input type="text" class="form-control width120px" name="s_work_dt" id="s_work_dt" dateFormat="yyyy-MM-dd" value="${inputParam.s_work_dt}" readonly="readonly">
			</td>
			<th class="text-right">작성자</th>
			<td colspan="3">
				<input type="text" class="form-control width120px" name="s_mem_name" id="s_mem_name" readonly="readonly" value="${inputParam.s_mem_name}">
			</td>
		</tr>
		<tr>
			<th class="text-right essential-item">신청시간</th>
			<td colspan="3">
				<div class="form-row inline-pd widthfix">
					<div class="col width40px">
						<input type="text" id="req_in_hour" name="req_in_hour" class="form-control text-right essential-bg" minlength="2" maxlength="2" datatype="int" required="required" value="${list.req_in_hour}" alt="신청시간 출근(시)" onchange="javascript:fnSetAppr()">
					</div>
					<div class="col width16px">시</div>
					<div class="col width35px">
						<input type="text" id="req_in_min" name="req_in_min" class="form-control text-right essential-bg" minlength="2" maxlength="2" datatype="int" required="required" value="${list.req_in_min}" alt="신청시간 출근(분)" onchange="javascript:fnSetAppr()">
					</div>
					<div class="col width16px">분</div>
					<div class="col width16px text-center">~</div>
					<div class="col width35px">
						<input type="text" id="req_out_hour" name="req_out_hour" class="form-control text-right essential-bg" minlength="2" maxlength="2" datatype="int" required="required" value="${list.req_out_hour}" alt="신청시간 퇴근(시)" onchange="javascript:fnSetAppr()">
					</div>
					<div class="col width16px">시</div>
					<div class="col width35px">
						<input type="text" id="req_out_min" name="req_out_min" class="form-control text-right essential-bg" minlength="2" maxlength="2" datatype="int" required="required" value="${list.req_out_min}" alt="신청시간 퇴근(분)" onchange="javascript:fnSetAppr()">
					</div>
					<div class="col width16px">분</div>
					<div class="col width35px">
						<input type="text" id="req_time" name="req_time" class="form-control text-right" minlength="2" maxlength="2" datatype="int" readonly="readonly" value="${list.req_time}">
					</div>
					<div class="col width35px">시간</div>
				</div>
			</td>
			<th class="text-right">승인시간</th>
			<td colspan="3">
				<div class="form-row inline-pd widthfix">
					<div class="col width40px">
						<input type="text" id="approval_in_hour" name="approval_in_hour" class="form-control text-right" readonly="readonly" minlength="2" maxlength="2" datatype="int" value="${list.approval_in_hour}">
					</div>
					<div class="col width16px">시</div>
					<div class="col width35px">
						<input type="text" id="approval_in_min" name="approval_in_min" class="form-control text-right" readonly="readonly" minlength="2" maxlength="2" datatype="int" value="${list.approval_in_min}">
					</div>
					<div class="col width16px">분</div>
					<div class="col width16px text-center">~</div>
					<div class="col width35px">
						<input type="text" id="approval_out_hour" name="approval_out_hour" class="form-control text-right" readonly="readonly" minlength="2" maxlength="2" datatype="int" value="${list.approval_out_hour}">
					</div>
					<div class="col width16px">시</div>
					<div class="col width35px">
						<input type="text" id="approval_out_min" name="approval_out_min" class="form-control text-right" readonly="readonly" minlength="2" maxlength="2" datatype="int" value="${list.approval_out_min}">
					</div>
					<div class="col width16px">분</div>
					<div class="col width35px">
						<input type="text" id="approval_time" name="approval_time" class="form-control text-right" minlength="2" maxlength="2" datatype="int" readonly="readonly" value="${list.approval_time}">
					</div>
					<div class="col width35px">시간</div>
				</div>
			</td>
		</tr>
		<tr>
			<th class="text-right essential-item">연장근로사유</th>
			<td colspan="7">
				<textarea class="form-control essential-bg" id="remark" name="remark" style="height: 70px;" required="required" alt="연장근로상유">${list.remark}</textarea>
			</td>
		</tr>
		<tr>
			<th class="text-right">결재의견</th>
			<td colspan="7">
				<div class="fixed-table-container" style="width: 100%; height: 100px;"> <!-- height값 인라인 스타일로 주면 타이틀 영역이 고정됨  -->
					<div class="fixed-table-wrapper">
						<table class="table-border doc-table md-table">
							<colgroup>
								<col width="140px">
								<col width="">
								<col width="140px">
								<col width="">
							</colgroup>
							<thead>
							<!-- 퍼블리싱 파일의 important 속성 때문에 dev에 선언한 클래스가 안되서 인라인 CSS로함 -->
							<tr><th class="th" style="font-size: 12px !important">구분</th>
								<th class="th" style="font-size: 12px !important">결재일시</th>
								<th class="th" style="font-size: 12px !important">담당자</th>
								<th class="th" style="font-size: 12px !important">특이사항</th>
							</tr></thead>
							<tbody>
							<c:forEach var="list" items="${apprMemoList}">
								<tr>
									<td class="td" style="text-align: center; font-size: 12px !important">${list.appr_status_name }</td>
									<td class="td" style="font-size: 12px !important">${list.proc_date }</td>
									<td class="td" style="text-align: center; font-size: 12px !important">${list.appr_mem_name }</td>
									<td class="td" style="font-size: 12px !important">${list.memo }</td>
								</tr>
							</c:forEach>
							</tbody>
						</table>
					</div>
				</div>
			</td>
		</tr>
		</tbody>
	</table>
	<div class="btn-group mt10">
		<div class="right">
			<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
		</div>
	</div>
</div>
</div>
</form>
</body>
</html>