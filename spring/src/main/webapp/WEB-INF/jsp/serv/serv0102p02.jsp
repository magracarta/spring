<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 정비 > 서비스일지 > null > 서비스일지결재
-- 작성자 : 성현우
-- 최초 작성일 : 2020-07-21 19:54:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	var auiGridParts;
	var auiGridAsTodo;
	
	$(document).ready(function() {
		fnInit();
		// 부품내역 Grid
		createAUIGridParts();
		// 미결사항 Grid
		createAUIGridAsTodo();
	});

	function fnInit() {
		var readType = '${inputParam.read_type}';
		if(readType == "R") {
			$("#standard_hour").prop("readonly", true);
			$("#rework_ync_n").prop("disabled", true);
			$("#rework_ync_y").prop("disabled", true);
			$("#rework_ync_c").prop("disabled", true);
			$("#rework_point").prop("disabled", true);
			$("#before_btn").prop("disabled", true);
			$("#before_miss_btn").prop("disabled", true);
			$("#origin_appr_cost_yn").prop("disabled", true);
			$("#appr_repair_hour").prop("readonly", true);
			$("#appr_travel_km").prop("readonly", true);
			$("#appr_part_amt").prop("readonly", true);
			$("#travel_expense").prop("readonly", true);
			$("#work_total_amt").prop("readonly", true);
			$("#appr_part_amt_2").prop("readonly", true);
// 			$("#cowoker_btn").prop("disabled", true);
			$("#repair_level_1").prop("disabled", true);
			$("#repair_level_2").prop("disabled", true);
			$("#repair_level_3").prop("disabled", true);
			$("#repair_skill_1").prop("disabled", true);
			$("#repair_skill_2").prop("disabled", true);
			$("#repair_skill_3").prop("disabled", true);
			$("#repair_skill_4").prop("disabled", true);
			$("#special_review_1").prop("disabled", true);
			$("#special_review_2").prop("disabled", true);
			$("#special_review_3").prop("disabled", true);
			$("#doc_delay_yn_y").prop("disabled", true);
			$("#doc_delay_yn_n").prop("disabled", true);
			
			// 결정사항조회로 들어올시 결재 관련 버튼 숨김처리.
			$("#_goRequestApproval").addClass("dpn");
			$("#_goApproval").addClass("dpn");
			$("#_goApprCancel").addClass("dpn");
		}

		var result = ${_result};
		var cmd = "${cmd}";
		var currentDate = $M.getCurrentDate();

		if(cmd == "C") {
			if(result.as_dt == currentDate) {
				$M.setValue("doc_delay_yn", "N");
			} else {
				$M.setValue("doc_delay_yn", "Y");
			}
		}
		
		// 공임배분
		fnSetRepairCowoker(${cowokerListJson});
	}

	// 종전작업자
	function setBeforMem(data) {
		$M.setValue("before_mem_no", data.mem_no);
		$M.setValue("before_mem_name", data.mem_name);
	}

	// 종전과실자
	function setBeforMissMem(data) {
		$M.setValue("before_miss_mem_no", data.mem_no);
		$M.setValue("before_miss_mem_name", data.mem_name);
	}

	function fnChangePartAmt() {
		var apprPartAmt = $M.getValue("appr_part_amt");
		$M.setValue("appr_part_amt_2", apprPartAmt);
	}

	// 공임배분 -> 상세페이지에서만 호출 가능.
	function goRepairCowoker() {

		var workTotalAmt = '${result.work_total_amt}';
		
		// 채상무님 9.28일 회의 지시사항
		if($M.toNum(workTotalAmt) == 0) {
			if (confirm("공임 총합이 0원입니다. 무상정비에서는 공임배분을 할 수 없습니다.\n유상정비가 맞습니까?") == false) {
				return false;
			}
		}

		var param = {
			"parent_js_name" : "fnSetRepairCowoker",
			"work_total_amt" : $M.setComma(workTotalAmt),
			"s_as_no" : $M.getValue("as_no"),
			"s_job_report_no" : $M.getValue("job_report_no"),
			"s_type" : "D",
			"read_type" : '${inputParam.read_type}'
		};

		var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=500, height=450, left=0, top=0";
		$M.goNextPage('/serv/serv0102p03', $M.toGetParam(param), {popupStatus : popupOption});
	}


	// 공임배분 Data Setting
	function fnSetRepairCowoker(data) {
		var frm = document.main_form;
		
		var co_as_no = [];
		var co_mem_no = [];
		var co_work_rate = [];
		var co_work_amt = [];
		var co_cmd = [];

		for(var i in data) {
			co_as_no.push($M.getValue("as_no"));
			co_mem_no.push(data[i].mem_no);
			co_work_rate.push(data[i].work_rate);
			co_work_amt.push(data[i].work_amt);
			co_cmd.push("Y");
		}

		var option = {
			isEmpty : true
		};

		$M.setValue(frm, "co_as_no_str", $M.getArrStr(co_as_no, option));
		$M.setValue(frm, "co_mem_no_str", $M.getArrStr(co_mem_no, option));
		$M.setValue(frm, "co_work_rate_str", $M.getArrStr(co_work_rate, option));
		$M.setValue(frm, "co_work_amt_str", $M.getArrStr(co_work_amt, option));
		$M.setValue(frm, "co_cmd_str", $M.getArrStr(co_cmd, option));

		var cowoker = data.length > 0 ? data[0].mem_name : '';
		var cowokerCnt = data.length - 1;
		if(data.length > 1) {
			cowoker += " 외" + cowokerCnt + "명";
		}

		$M.setValue("cowoker", cowoker);
		$M.setValue("co_type", "S");
	}

	// 미결사항
	function goAsTodo() {
		var machineSeq = $M.getValue("machine_seq");
		if(machineSeq == '') {
			alert("차대번호 조회를 먼저 진행해주세요.");
			return;
		}

		var params = {
			"__s_machine_seq" : machineSeq,
			"__s_as_no" : $M.getValue("as_no"),
			"__page_type" : $M.nvl($M.getValue("page_type"), "N"),
			"parent_js_name" : "fnSetJobOrder"
		};
		var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=450, left=0, top=0";
		$M.goNextPage('/serv/serv0101p07', $M.toGetParam(params), {popupStatus : popupOption});
	}

	function fnSetJobOrder(data) {
		console.log(data);
		AUIGrid.setGridData(auiGridAsTodo, data);
	}

	function goAsReport() {
		var asNo = $M.getValue("as_report");
		asNo = asNo.split("#");
		var param = {
			"s_as_no" : asNo[0]
		};

		var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=900, left=0, top=0";
		if(asNo[1].indexOf("R") != -1) {
			$M.goNextPage('/serv/serv0102p01', $M.toGetParam(param), {popupStatus: popupOption});
		} else {
			$M.goNextPage('/serv/serv0102p12', $M.toGetParam(param), {popupStatus: popupOption});
		}
	}

	// 그리드생성
	function createAUIGridParts() {
		var gridPros = {
			// 행 구별 필드명 지정
			rowIdField : "_$uid",
			// 수정 여부
			editable : false,
			// RowNumber
			showRowNumColumn : true,
			// fixedColumnCount : 2,
		};

		var columnLayout = [
			{
				headerText : "부품번호",
				dataField : "part_no",
				style : "aui-center",
				width : "10%"
			},
			{
				headerText : "부품명",
				dataField : "part_name",
				style : "aui-left",
				width : "50%"
			},
			{
				headerText : "구분",
				dataField : "normal_yn_name",
				style : "aui-center",
				width : "10%"
			},
			{
				headerText : "구분코드",
				dataField : "normal_yn",
				visible : false
			},
			{
				headerText : "수량",
				dataField : "use_qty",
				style : "aui-center",
				dataType : "numeric",
				formatString : "#,##0",
				width : "10%"
			},
			{
				headerText : "단가",
				dataField : "unit_price",
				style : "aui-right",
				dataType : "numeric",
				formatString : "#,##0",
				width : "10%"
			},
			{
				headerText : "금액",
				dataField : "bill_amount",
				style : "aui-right",
				dataType : "numeric",
				formatString : "#,##0",
				width : "10%"
			}
		];


		// 실제로 #grid_wrap에 그리드 생성
		auiGridParts = AUIGrid.create("#auiGridParts", columnLayout, gridPros);
		// 그리드 갱신
		AUIGrid.setGridData(auiGridParts, ${partList});
	}	

	// 미결사항 그리드
	function createAUIGridAsTodo() {
		var gridPros = {
			showRowNumColumn : false,
		};

		var columnLayout = [
			{
				headerText : "예정일자",
				dataField : "plan_dt",
				style : "aui-center",
				width : "20%",
				dataType : "date",
				formatString : "yyyy-mm-dd",
			},
			{
				headerText : "미결사항",
				dataField : "todo_text",
				style : "aui-left",
				width : "40%",
			},
			{
				headerText : "처리사항",
				dataField : "proc_text",
				style : "aui-left",
				width : "40%",
			},
			{
				headerText : "AS미결번호",
				dataField : "as_todo_seq",
				visible : false
			},
			{
				headerText : "장비대장번호",
				dataField : "machine_seq",
				visible : false
			}
		];

		// 실제로 #grid_wrap에 그리드 생성
		auiGridAsTodo = AUIGrid.create("#auiGridAsTodo", columnLayout, gridPros);
		// 그리드 갱신
		AUIGrid.setGridData(auiGridAsTodo, ${asTodoList});
	}	
	
	// 상신취소
	function goApprCancel() {
		var param = {
			appr_job_seq : "${apprBean.appr_job_seq}",
			seq_no : "${apprBean.seq_no}",
			appr_cancel_yn : "Y"
		};
		openApprPanel("goApprovalResultCancel", $M.toGetParam(param));
	}
	
	function goApprovalResultCancel(result) {
		$M.goNextPageAjax('/session/check', '', {method : 'GET'},
				function(result) {
			    	if(result.success) {
			    		alert("결재취소가 완료됐습니다.");	
			    		location.reload();
					}
				}
			);
	}

	// 결재요청
	function goRequestApproval() {
		goApproval(true);
	}

	// 결재처리
	function goApproval(isRequest) {
		// 21.9.17 채상무님 요청으로 비용있는데 무상결재하려고하면 물어보는것 추가
		if ($M.getValue("origin_appr_cost_yn") == "N") {
			var coworker = $M.getValue("cowoker");
			if (coworker != "") {
				// 채상무님 9.28일 회의 지시사항
				alert("무상정비를 공임배분한 채로 결재할 수 없습니다.");
				return false;
			}
			var amt = $M.toNum($M.getValue("normal_y_amt")) + $M.toNum($M.getValue("travel_expense")) + $M.toNum($M.getValue("work_total_amt")) + $M.toNum($M.getValue("normal_n_amt")) + $M.toNum($M.getValue("appr_part_amt_2"));
			if (amt != 0) {
				if (confirm("비용이 있는데 무상처리하시겠습니까?") == false) {
					return false;
				}
			}
		} 
		
		var frm = document.main_form;
		//validationcheck
		if($M.validation(frm,
				{field:["origin_appr_cost_yn", "appr_repair_hour", "appr_travel_km", "travel_expense"
					, "standard_hour", "rework_point", "rework_ync", "repair_level", "repair_skill", "special_review", "doc_delay_yn"]})==false) {
			return;
		};
		
		// 결재여부와 상관없이 무조건 저장 후 결재여부에 따라 재진행하도록 수정
		goSavePreAppr(isRequest);

		if(isRequest == undefined){
			var param = {
					appr_job_seq : "${apprBean.appr_job_seq}",
					seq_no : "${apprBean.seq_no}",
					writer_appr_yn : $M.getValue("v_yn") == "Y" ?  "N" : "",
					appr_reject_only : "${apprBean.appr_reject_only}",
			};
			$M.setValue("save_mode", "approval"); // 승인
			openApprPanel("goApprovalResult", $M.toGetParam(param));
		}
	}

	// 결재처리 후
	function goApprovalResult(result) {
		if(result.appr_status_cd == '03') {
			alert("반려가 완료됐습니다.");
			location.reload();
		} else {
			setTimeout(goSave, 600);
		}
	}

	function goSave() {
		var frm = document.main_form;
		if($M.validation(frm) == false) {
			return;
		}

		if($M.getValue("rework_ync") != "N") {
			$M.setValue(frm, "before_repair_dt", $M.getCurrentDate("yyyymmdd"));
		}

		$M.setValue(frm, "appr_part_amt", $M.toNum($M.getValue("appr_part_amt")));
		$M.setValue(frm, "travel_expense", $M.toNum($M.getValue("travel_expense")));
		$M.setValue(frm, "work_total_amt", $M.toNum($M.getValue("work_total_amt")));
		$M.setValue(frm, "cmd", "U");

		$M.goNextPageAjax(this_page + "/save", frm, {method : "POST"},
			function(result) {
				if(result.success) {
					alert("처리가 완료됐습니다.");
					fnClose();
					window.opener.location.reload();
				}
			}
		);
	}
	
	function goSavePreAppr(isRequest){
		if(isRequest != undefined) {
			$M.setValue("save_mode", "appr"); // 요청
			if(!confirm("결재요청 하시겠습니까?")) {
				return ;
			}
		} else {
			$M.setValue("save_mode", "approval"); // 체크
		}
		var frm = document.main_form;
		if($M.validation(frm) == false) {
			return;
		}
		
		if($M.getValue("rework_ync") != "N") {
			$M.setValue(frm, "before_repair_dt", $M.getCurrentDate("yyyymmdd"));
		}

		$M.setValue(frm, "appr_part_amt", $M.toNum($M.getValue("appr_part_amt")));
		$M.setValue(frm, "travel_expense", $M.toNum($M.getValue("travel_expense")));
		$M.setValue(frm, "work_total_amt", $M.toNum($M.getValue("work_total_amt")));

		$M.goNextPageAjax(this_page + "/save", frm, {method : "POST"},
			function(result) {
				if(result.success) {
					if(isRequest != undefined) {
						alert("처리가 완료됐습니다.");
						fnClose();
						window.opener.location.reload();
					}
				}
			}
		);
	}

	function changeTotalHour() {
		var totalHour = $M.toNum('${totResult.tot_standard_hour}');
		var standardHour = $M.toNum($M.getValue("standard_hour"));

		$M.setValue("tot_standard_hour", totalHour + standardHour);
	}

	// 닫기
    function fnClose() {
    	window.close();
    }
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" id="as_no" name="as_no" value="${result.as_no}">
<input type="hidden" id="machine_seq" name="machine_seq" value="${result.machine_seq}">
<input type="hidden" id="__s_cust_no" name="__s_cust_no" value="${result.cust_no}">
<input type="hidden" id="before_mem_no" name="before_mem_no">
<input type="hidden" id="before_miss_mem_no" name="before_miss_mem_no">
<input type="hidden" id="appr_job_seq" name="appr_job_seq" value="${result.appr_job_seq}">
<input type="hidden" id="save_mode" name="save_mode">
<input type="hidden" id="cmd" name="cmd" value="${cmd}">
<input type="hidden" id="v_yn" name="v_yn" value="${result.v_yn}">
<c:forEach var="list" items="${apprList}" varStatus="status">
	<input type="hidden" id="apprNum${status.count}" name="appr_mem_no" value="${list.appr_mem_no}" readonly="readonly" class="apprLineMemNo">
</c:forEach>
<input type="hidden" name="auto_appr_yn" id="auto_appr_yn" alt="자동결재여부" value="${apprBean.auto_appr_yn}" required="required"/>
<input type="hidden" name="auto_appr_cnt" id="auto_appr_cnt" alt="자동결재대상수" value="${apprBean.auto_appr_cnt}" required="required"/>
<input type="hidden" name="appr_org_code_str" id="appr_org_code_str" alt="결재레벨부서" value="${apprBean.appr_org_code_str}"/>
<input type="hidden" name="appr_grade_str" id="appr_grade_str" alt="결재레벨직급" value="${apprBean.appr_grade_str}"/>
<input type="hidden" name="appr_mem_str" id="appr_mem_str" alt="결재레벨사용자" value="${apprBean.appr_mem_str}"/>
<input type="hidden" name="writer_appr_yn_str" id="writer_appr_yn_str" alt="전결가능여부"/>
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
<!-- 폼테이블 -->					
			<div>
<!-- 정비지시서 -->
				<table class="table-border mt5">
					<colgroup>
						<col width="90px">
						<col width="">
						<col width="90px">
						<col width="">
						<col width="90px">
						<col width="">
						<col width="90px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right">모델명</th>
							<td>
								<input type="text" class="form-control width120px" id="machine_name" name="machine_name" readonly="readonly" value="${result.machine_name}">
							</td>
							<th class="text-right">차대번호</th>
							<td>
								<input type="text" class="form-control width180px" id="body_no" name="body_no" readonly="readonly" value="${result.body_no}">
							</td>
							<th class="text-right">출하일자</th>
							<td>
								<div class="input-group dev_nf">
									<input type="text" class="form-control border-right-0 calDate" id="out_dt" name="out_dt" dateformat="yyyy-MM-dd" disabled="disabled" value="${result.out_dt}">
                                </div>
							</td>
							<th class="text-right">가동시간</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width70px">
										<input type="text" class="form-control width120px text-right" id="op_hour" name="op_hour" readonly="readonly" format="decimal" value="${result.op_hour}">
									</div>
									<div class="col width33px">
										hr
									</div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">정비지시서</th>
							<td colspan="3">
								<div class="form-row inline-pd widthfix">
									<div class="col-auto">
										<input type="text" id="job_report_no" name="job_report_no" class="form-control width120px" readonly="readonly" value="${result.job_report_no}">
									</div>
									<div class="col-6">
										<jsp:include page="/WEB-INF/jsp/common/commonCustJob.jsp">
											<jsp:param name="li_type" value="__cust_dtl#__ledger"/>
										</jsp:include>
									</div>
								</div>
							</td>
							<th class="text-right essential-item">규정시간</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width70px">
										<c:set var="standard_hour" value="${empty apprResult.standard_hour ? result.repair_hour : apprResult.standard_hour}"/>
										<input type="text" class="form-control text-right essential-bg" id="standard_hour" name="standard_hour" required="required" alt="규정시간" value="${standard_hour}" onchange="changeTotalHour()">
<%-- 										<input type="text" class="form-control text-right essential-bg" id="standard_hour" name="standard_hour" required="required" alt="규정시간" value="${apprResult.standard_hour}"> --%>
									</div>
									<div class="col width33px">
										hr
									</div>
								</div>
							</td>
							<th class="text-right essential-item">재작업</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-auto">
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" id="rework_ync_n" name="rework_ync" required="required" alt="재작업" value="N" <c:if test="${apprResult.rework_ync == 'N'}">checked="checked"</c:if> checked="checked" >
											<label class="form-check-label" for="rework_ync_n">N</label>
										</div>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" id="rework_ync_y" name="rework_ync" required="required" alt="재작업" value="Y" <c:if test="${apprResult.rework_ync == 'Y'}">checked="checked"</c:if>>
											<label class="form-check-label" for="rework_ync_y">Y</label>
										</div>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" id="rework_ync_c" name="rework_ync" required="required" alt="재작업" value="C" <c:if test="${apprResult.rework_ync == 'C'}">checked="checked"</c:if>>
											<label class="form-check-label" for="rework_ync_c">C</label>
										</div>
									</div>
									<div class="col-auto">
										<select class="form-control width60px essential-bg" id="rework_point" name="rework_point" required="required" alt="재평가산율">
											<option value="0" <c:if test="${apprResult.rework_point == '0'}">selected="selected"</c:if> >X0</option>
											<option value="1" <c:if test="${apprResult.rework_point == '1'}">selected="selected"</c:if> >X1</option>
											<option value="2" <c:if test="${apprResult.rework_point == '2'}">selected="selected"</c:if> >X2</option>
											<option value="3" <c:if test="${apprResult.rework_point == '3'}">selected="selected"</c:if> >X3</option>
											<option value="4" <c:if test="${apprResult.rework_point == '4'}">selected="selected"</c:if> >X4</option>
											<option value="5" <c:if test="${apprResult.rework_point == '5'}">selected="selected"</c:if> >X5</option>
										</select>
									</div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">종전일자</th>
							<td colspan="3">
								<div class="input-group dev_nf">
									<input type="text" class="form-control border-right-0 calDate" id="before_repair_dt" name="before_repair_dt" dateformat="yyyy-MM-dd" disabled="disabled" alt="시작일" value="${apprResult.before_repair_dt}">
                                </div>
							</td>
							<th class="text-right">종전작업자</th>
							<td>
								<div class="input-group width120px">
									<input type="text" class="form-control border-right-0" id="before_mem_name" name="before_mem_name" readonly="readonly" value="${apprResult.before_mem_name}">
									<button type="button" class="btn btn-icon btn-primary-gra" id="before_btn" name="before_btn" onclick="javascript:openMemberOrgPanel('setBeforMem', 'N');"><i class="material-iconssearch"></i></button>
								</div>
							</td>
							<th class="text-right">정비과실자</th>
							<td>
								<div class="input-group width120px">
									<input type="text" class="form-control border-right-0" id="before_miss_mem_name" name="before_miss_mem_name" readonly="readonly" value="${apprResult.before_miss_mem_name}">
									<button type="button" class="btn btn-icon btn-primary-gra" id="before_miss_btn" name="before_miss_btn" onclick="javascript:openMemberOrgPanel('setBeforMissMem', 'N');"><i class="material-iconssearch"></i></button>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">총 규정시간</th>
							<td colspan="3">
								<div class="form-row inline-pd widthfix">
									<div class="col width70px">
										<input type="text" class="form-control text-right" id="tot_standard_hour" name="tot_standard_hour" readonly="readonly" value="${totResult.tot_standard_hour + standard_hour}">
									</div>
									<div class="col width33px">
										hr
									</div>
								</div>
							</td>
							<th class="text-right">총 작업시간</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width70px">
										<c:set var="repair_hour" value="${empty apprResult.appr_repair_hour ? result.repair_hour : apprResult.appr_repair_hour}"/>
										<input type="text" class="form-control text-right" id="tot_repair_hour" name="tot_repair_hour" readonly="readonly" value="${totResult.tot_repair_hour + repair_hour}">
									</div>
									<div class="col width33px">
										hr
									</div>
								</div>
							</td>
							<th class="text-right">서비스일지</th>
							<td>
								<select class="form-control width140px" id="as_report" name="as_report" onchange="javascript:goAsReport();">
									<option value="">- 선택 - </option>
									<c:forEach var="item" items="${asList}">
										<option value="${item.as_no}">${item.repair_name}</option>
									</c:forEach>
								</select>
							</td>
						</tr>
					</tbody>
				</table>
<!-- /정비지시서 -->
			</div>
<!-- /폼테이블 -->	
<!-- 폼테이블2 -->
			<div class="row mt10">
<!-- 처리사항 -->
				<div class="col-4">
					<div class="title-wrap">
						<h4>처리사항</h4>
					</div>	
					<table class="table-border mt5">
						<colgroup>
							<col width="90px">
							<col width="">
						</colgroup>
						<tbody>
							<tr>
								<th class="text-right">Claim유무</th>
								<td colspan="3">
									<select class="form-control width90px" id="cost_yn" name="cost_yn" disabled="disabled">
										<option value="Y" <c:if test="${'Y' eq result.cost_yn}">selected="selected"</c:if> >유상</option>
										<option value="N" <c:if test="${'N' eq result.cost_yn}">selected="selected"</c:if> >무상</option>
									</select>
								</td>
							</tr>
							<tr>
								<th class="text-right">작업시간</th>
								<td colspan="3">
									<div class="form-row inline-pd widthfix">
										<div class="col width70px">
											<input type="text" class="form-control text-right" id="repair_hour" name="repair_hour" readonly="readonly" value="${result.repair_hour}">
										</div>
										<div class="col width33px">
											hr
										</div>
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right">이동거리</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width70px">
											<input type="text" class="form-control text-right" id="travel_km" name="travel_km" readonly="readonly" value="${result.travel_km}">
										</div>
										<div class="col width33px">
											km
										</div>
									</div>
								</td>
								<th class="text-right">이동시간</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width70px">
											<input type="text" class="form-control text-right" id="move_hour" name="move_hour" required="required" readonly="readonly" alt="이동시간" value="${result.move_hour}">
										</div>
										<div class="col width33px">
											hr
										</div>
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right">부품비용</th>
								<td colspan="3">
									<div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control text-right" id="part_amt" name="part_amt" datatype="int" format="decimal" readonly="readonly" value="${result.part_total_amt}">
										</div>
										<div class="col width16px">원</div>
									</div>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
<!-- /처리사항 -->
<!-- 결정사항 -->
				<div class="col-4">
					<div class="title-wrap">
						<h4>결정사항</h4>
					</div>	
					<table class="table-border mt5">
						<colgroup>
							<col width="90px">
							<col width="">
						</colgroup>
						<tbody>
							<tr>
								<th class="text-right essential-item">Claim유무</th>
								<td colspan="3"><c:set var="origin_cost_yn" value="${cmd eq 'C' ? result.cost_yn : apprResult.appr_cost_yn }"/>
									<select class="form-control width90px essential-bg" id="origin_appr_cost_yn" name="origin_appr_cost_yn" required="required" alt="Claim유무">
										<option value="Y" ${origin_cost_yn eq 'Y' ? 'selected="selected"' : '' }>유상</option>
										<option value="N" ${origin_cost_yn eq 'N' ? 'selected="selected"' : '' }>무상</option>
									</select>
								</td>
							</tr>
							<tr>
								<th class="text-right essential-item">작업시간</th>
								<td colspan="3">
									<div class="form-row inline-pd widthfix">
										<div class="col width70px">
											<c:choose>
												<c:when test="${cmd eq 'C'}">
													<input type="text" class="form-control text-right essential-bg" id="appr_repair_hour" name="appr_repair_hour" required="required" alt="작업시간" value="${result.repair_hour}">
												</c:when>
												<c:otherwise>
													<input type="text" class="form-control text-right essential-bg" id="appr_repair_hour" name="appr_repair_hour" required="required" alt="작업시간" value="${apprResult.appr_repair_hour}">
												</c:otherwise>
											</c:choose>
										</div>
										<div class="col width33px">
											hr
										</div>
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right">이동거리</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width70px">
											<c:choose>
												<c:when test="${cmd eq 'C'}">
													<input type="text" class="form-control text-right" id="appr_travel_km" name="appr_travel_km" required="required" readonly="readonly" alt="이동거리" value="${result.travel_km}">
												</c:when>
												<c:otherwise>
													<input type="text" class="form-control text-right" id="appr_travel_km" name="appr_travel_km" required="required" readonly="readonly" alt="이동거리" value="${apprResult.appr_travel_km}">
												</c:otherwise>
											</c:choose>
										</div>
										<div class="col width33px">
											km
										</div>
									</div>
								</td>
								<th class="text-right">이동시간</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width70px">
											<input type="text" class="form-control text-right" id="move_hour" name="move_hour" required="required" readonly="readonly" alt="이동시간" value="${result.move_hour}">
										</div>
										<div class="col width33px">
											hr
										</div>
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right">부품비용</th>
								<td colspan="3">
									<div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<c:choose>
												<c:when test="${cmd eq 'C'}">
<%-- 													<input type="text" class="form-control text-right" id="appr_part_amt" name="appr_part_amt" required="required" readonly="readonly" alt="부품비용" datatype="int" format="decimal" value="${result.part_total_amt}"> --%>
													<input type="text" class="form-control text-right" id="appr_part_amt" name="appr_part_amt" readonly="readonly" alt="부품비용" datatype="int" format="decimal" value="${result.part_total_amt}">
												</c:when>
												<c:otherwise>
<%-- 													<input type="text" class="form-control text-right" id="appr_part_amt" name="appr_part_amt" required="required" readonly="readonly" alt="부품비용" datatype="int" format="decimal" value="${apprResult.appr_part_amt}"> --%>
													<input type="text" class="form-control text-right" id="appr_part_amt" name="appr_part_amt" readonly="readonly" alt="부품비용" datatype="int" format="decimal" value="${apprResult.appr_part_amt}">
												</c:otherwise>
											</c:choose>
										</div>
										<div class="col width16px">원</div>
									</div>
								</td>
							</tr>
						</tbody>
					</table>				
				</div>
<!-- /결정사항 -->
<!-- 결재의견 -->
				<div class="col-4">
					<div class="title-wrap">
						<h4>결재의견</h4>
					</div>
					<table class="table mt5">
						<colgroup>
							<col width="40px">
							<col width="">
							<col width="60px">
							<col width="">
						</colgroup>
						<thead>
						<tr>
							<td colspan="5">
								<div class="fixed-table-container" style="width: 100%; height: 150px;"> <!-- height값 인라인 스타일로 주면 타이틀 영역이 고정됨  -->
									<div class="fixed-table-wrapper">
										<table class="table-border doc-table md-table">
											<colgroup>
												<col width="40px">
												<col width="140px">
												<col width="55px">
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
				</div>
<!-- /결재의견 -->
			</div>
<!-- /폼테이블2 -->
<!-- 폼테이블3 -->
			<div>
<!-- 비용내역 -->
				<div class="title-wrap mt10">
					<h4>비용내역</h4>
				</div>
				<table class="table-border mt5">
					<colgroup>
						<col width="90px">
						<col width="">
						<col width="90px">
						<col width="">
						<col width="90px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right">순정</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width100px">
										<input type="text" class="form-control text-right" id="normal_y_amt" name="normal_y_amt" datatype="int" format="decimal" readonly="readonly" value="${normal_y_amt}">
									</div>
									<div class="col width16px">원</div>
								</div>
							</td>
							<th class="text-right">출장비</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width100px">
										<%--<c:choose>
											<c:when test="${cmd eq 'C'}">
												<input type="text" class="form-control text-right" id="travel_expense" name="travel_expense" readonly="readonly" alt="출장비" datatype="int" format="decimal" value="${result.travel_final_expense}">
											</c:when>
											<c:otherwise>
												<input type="text" class="form-control text-right" id="travel_expense" name="travel_expense" readonly="readonly" alt="출장비" datatype="int" format="decimal" value="${apprResult.travel_expense}">
											</c:otherwise>
										</c:choose>--%>
										<!-- 2021.04.19 정비지시서 기준으로 출력 (채평석 상무님 요청사항) -->
										<input type="text" class="form-control text-right" id="travel_expense" name="travel_expense" readonly="readonly" alt="출장비" datatype="int" format="decimal" value="${result.travel_final_expense}">
									</div>
									<div class="col width16px">원</div>
								</div>
							</td>
							<th class="text-right">공임</th>
							<td colspan="6">
								<div class="form-row inline-pd widthfix">
									<div class="col width100px">
										<%--<c:choose>
											<c:when test="${cmd eq 'C'}">
												<input type="text" class="form-control text-right" id="work_total_amt" name="work_total_amt" readonly="readonly" alt="공임" datatype="int" format="decimal" value="${result.work_total_amt}">
											</c:when>
											<c:otherwise>
												<input type="text" class="form-control text-right" id="work_total_amt" name="work_total_amt" readonly="readonly" alt="공임" datatype="int" format="decimal" value="${apprResult.work_total_amt}">
											</c:otherwise>
										</c:choose>--%>
										<!-- 2021.04.19 정비지시서 기준으로 출력 (채평석 상무님 요청사항) -->
										<input type="text" class="form-control text-right" id="work_total_amt" name="work_total_amt" readonly="readonly" alt="공임" datatype="int" format="decimal" value="${result.work_total_amt}">
									</div>
									<div class="col width16px">원</div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">비품</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width100px">
										<input type="text" class="form-control text-right" id="normal_n_amt" name="normal_n_amt" datatype="int" format="decimal" readonly="readonly" value="${normal_n_amt}">
									</div>
									<div class="col width16px">원</div>
								</div>
							</td>
							<th class="text-right">부품비</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width100px">
										<%--<c:choose>
											<c:when test="${cmd eq 'C'}">
												<input type="text" class="form-control text-right" id="appr_part_amt_2" name="appr_part_amt_2" datatype="int" format="decimal" readonly="readonly" value="${result.part_total_amt}">
											</c:when>
											<c:otherwise>
												<input type="text" class="form-control text-right" id="appr_part_amt_2" name="appr_part_amt_2" datatype="int" format="decimal" readonly="readonly" value="${apprResult.appr_part_amt}">
											</c:otherwise>
										</c:choose>--%>
										<!-- 2021.04.19 정비지시서 기준으로 출력 (채평석 상무님 요청사항) -->
										<input type="text" class="form-control text-right" id="appr_part_amt_2" name="appr_part_amt_2" datatype="int" format="decimal" readonly="readonly" value="${result.part_total_amt}">
									</div>
									<div class="col width16px">원</div>
								</div>
							</td>
							<th class="text-right">동행인</th>
							<td colspan="6">
								<div class="form-row inline-pd">
									<div class="col-2">
										<input type="text" class="form-control" id="cowoker" name="cowoker" readonly="readonly" value="${cowoker}">
										<c:forEach var="item" items="${cowokerList}" varStatus="status">
											<div id="cowoker_div_${item.row_num}">
												<div>
													<input type="hidden" id="co_as_no_${item.row_num}" name="co_as_no_${item.row_num}" value="${item.as_no}">
													<input type="hidden" id="co_mem_no_${item.row_num}" name="co_mem_no_${item.row_num}" value="${item.mem_no}">
													<input type="hidden" id="co_work_rate_${item.row_num}" name="co_work_rate_${item.row_num}" value="${item.work_rate}">
													<input type="hidden" id="co_work_amt_${item.row_num}" name="co_work_amt_${item.row_num}" value="${item.work_amt}">
												</div>
											</div>
										</c:forEach>
									</div>
									<div class="col-2">
										<button type="button" class="btn btn-primary-gra" id="cowoker_btn" name="cowoker_btn" onclick="javascript:goRepairCowoker();">공임배분</button>
									</div>
								</div>
							</td>
						</tr>
					</tbody>
				</table>
<!-- /비용내역 -->
			</div>
<!-- /폼테이블3 -->
<!-- 그리드영역 -->
			<div class="mt10">
				<div id="auiGridParts" style="margin-top: 5px; height: 150px;"></div>
			</div>
<!-- /그리드영역 -->
<!-- 폼테이블4 -->
			<div class="row mt10">
<!-- 비용내역 -->
				<div class="col-8">
					<div class="title-wrap">
						<h4>비용내역</h4>
					</div>	
					<table class="table-border mt5">
						<colgroup>
							<col width="150px">
							<col width="">
							<col width="150px">
							<col width="">
						</colgroup>
						<tbody>
							<tr style="height: 50px">
								<th class="text-right essential-item">정비난이도</th>
								<td>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="repair_level_1" name="repair_level" required="required" alt="정비난이도" value="1" <c:if test="${apprResult.repair_level == '1'}">checked="checked"</c:if> >
										<label class="form-check-label" for="repair_level_1">어려움</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="repair_level_2" name="repair_level" required="required" alt="정비난이도" value="2" <c:if test="${apprResult.repair_level == '2'}">checked="checked"</c:if> checked="checked">
										<label class="form-check-label" for="repair_level_2">보통</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="repair_level_3" name="repair_level" required="required" alt="정비난이도" value="3" <c:if test="${apprResult.repair_level == '3'}">checked="checked"</c:if> >
										<label class="form-check-label" for="repair_level_3">쉬움</label>
									</div>
								</td>
								<th class="text-right essential-item">정비기능수준</th>
								<td>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="repair_skill_1" name="repair_skill" required="required" alt="정비기능수준" value="1" <c:if test="${apprResult.repair_skill == '1'}">checked="checked"</c:if> >
										<label class="form-check-label" for="repair_skill_1">좋음</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="repair_skill_2" name="repair_skill" required="required" alt="정비기능수준" value="2" <c:if test="${apprResult.repair_skill == '2'}">checked="checked"</c:if> checked="checked" >
										<label class="form-check-label" for="repair_skill_2">보통</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="repair_skill_3" name="repair_skill" required="required" alt="정비기능수준" value="3" <c:if test="${apprResult.repair_skill == '3'}">checked="checked"</c:if> >
										<label class="form-check-label" for="repair_skill_3">낮음</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="repair_skill_4" name="repair_skill" required="required" alt="정비기능수준" value="4" <c:if test="${apprResult.repair_skill == '4'}">checked="checked"</c:if> >
										<label class="form-check-label" for="repair_skill_4">부주의</label>
									</div>
								</td>
							</tr>
							<tr style="height: 50px">
								<th class="text-right essential-item">특이사항내용<br>비중검토</th>
								<td>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="special_review_1" name="special_review" required="required" alt="특이사항내용 비중검토" value="1" <c:if test="${apprResult.special_review == '1'}">checked="checked"</c:if> >
										<label class="form-check-label" for="special_review_1">좋음</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="special_review_2" name="special_review" required="required" alt="특이사항내용 비중검토" value="2" <c:if test="${apprResult.special_review == '2'}">checked="checked"</c:if> checked="checked">
										<label class="form-check-label" for="special_review_2">작성</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="special_review_3" name="special_review" required="required" alt="특이사항내용 비중검토" value="0" <c:if test="${apprResult.special_review == '0'}">checked="checked"</c:if> >
										<label class="form-check-label" for="special_review_3">없음</label>
									</div>
								</td>
								<th class="text-right essential-item">서비스일지<br>작성여부</th>
								<td>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="doc_delay_yn_y" name="doc_delay_yn" required="required" alt="서비스일지 작성여부" value="N" <c:if test="${apprResult.doc_delay_yn == 'N'}">checked="checked"</c:if>>
										<label class="form-check-label" for="doc_delay_yn_y">정상</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="doc_delay_yn_n" name="doc_delay_yn" required="required" alt="서비스일지 작성여부" value="Y" <c:if test="${apprResult.doc_delay_yn == 'Y'}">checked="checked"</c:if>>
										<label class="form-check-label" for="doc_delay_yn_n">밀림</label>
									</div>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
<!-- /비용내역 -->
<!-- 미결사항 -->
				<div class="col-4">
					<div class="title-wrap">
						<h4>미결사항</h4>
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
					</div>	
					<div id="auiGridAsTodo" style="margin-top: 5px; height: 100px;"></div>
				</div>
<!-- /미결사항 -->
			</div>
<!-- /폼테이블4 -->
			<div class="btn-group mt10">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/><jsp:param name="appr_yn" value="Y"/></jsp:include>
				</div>
			</div>
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>