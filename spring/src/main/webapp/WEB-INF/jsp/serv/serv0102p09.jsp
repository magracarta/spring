<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 정비 > 서비스일지 > null > 전화상담일지결재
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2020-04-07 19:54:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

	var auiGridAsTodos;
	
	$(document).ready(function() {
		// AUIGrid 생성
		createAUIGrid();
		// 초기 Setting
		fnInit();
	});

	// 초기 Setting
	function fnInit() {
		var readType = '${inputParam.read_type}';
		if(readType == "R") {
			$("#as_call_hour").prop("readonly", true);
			$("#appr_call_hour").prop("readonly", true);
			$('input[name="appr_call_result"]').prop("disabled", true);
		}
	}

	// 미결사항
	function goAsTodo() {

		var params = {
			"__s_machine_seq" : $M.getValue("machine_seq"),
			"__s_as_no" : $M.getValue("as_no"),
			"__page_type" : $M.nvl($M.getValue("page_type"), "N"),
			"parent_js_name" : "fnSetJobOrder"
		};
		var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=450, left=0, top=0";
		$M.goNextPage('/serv/serv0101p07', $M.toGetParam(params), {popupStatus : popupOption});
	}

	function fnSetJobOrder() {

	}

	//그리드생성
	function createAUIGrid() {
		var gridPros = {
			showStateColumn : false,
			showRowNumColumn : true,
			editable : false
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

		auiGridAsTodos = AUIGrid.create("#auiGridAsTodos", columnLayout, gridPros);
		AUIGrid.setGridData(auiGridAsTodos, ${asTodoList});

		$("#auiGridAsTodos").resize();
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
	
	// 결재처리
	function goApproval() {
		var param = {
				appr_job_seq : "${apprBean.appr_job_seq}",
				seq_no : "${apprBean.seq_no}",
				writer_appr_yn : $M.getValue("v_yn") == "Y" ?  "N" : "",
				appr_reject_only : "${apprBean.appr_reject_only}",
		};

		// 승인
		$M.setValue("save_mode", "approval");
		openApprPanel("goApprovalResult", $M.toGetParam(param));
	}

	// 결재처리 후
	function goApprovalResult(result) {
		if(result.appr_status_cd == '03') {
			alert("반려가 완료됐습니다.");
			location.reload();
		} else {
			setTimeout(goUpdate, 600);
		}
	}

	// 결재요청
	function goRequestApproval() {
		if(confirm("결재요청 하시겠습니까?")) {
			$M.setValue("save_mode", "appr");
			goUpdate();
		}
	}
	
	function goUpdate() {
		var frm = document.main_form;
		// validationcheck
		if($M.validation(frm,
				{field:["as_call_hour", "appr_call_hour", "appr_call_result"]})==false) {
			return;
		};

		$M.goNextPageAjax(this_page + "/update", frm, {method : "POST"},
			function(result) {
				if(result.success) {
					alert("처리가 완료됐습니다.");
					fnClose();
					window.opener.location.reload();
				}
			}
		);
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
<input type="hidden" id="as_call_type_cd" name="as_call_type_cd" value="${result.as_call_type_cd}">
<input type="hidden" id="machine_seq" name="machine_seq" value="${result.machine_seq}">
<input type="hidden" id="appr_job_seq" name="appr_job_seq" value="${result.appr_job_seq}">
<input type="hidden" id="save_mode" name="save_mode" />
<input type="hidden" id="v_yn" name="v_yn" value="${result.v_yn}" />
<c:forEach var="list" items="${apprList}" varStatus="status">
	<input type="hidden" id="apprNum${status.count}" name="appr_mem_no" value="${list.appr_mem_no}" readonly="readonly" class="apprLineMemNo">
</c:forEach>
<input type="hidden" name="auto_appr_yn" id="auto_appr_yn" alt="자동결재여부" value="${apprBean.auto_appr_yn}" required="required"/>
<input type="hidden" name="auto_appr_cnt" id="auto_appr_cnt" alt="자동결재대상수" value="${apprBean.auto_appr_cnt}" required="required"/>
<input type="hidden" name="appr_org_code_str" id="appr_org_code_str" alt="결재레벨부서" value="${apprBean.appr_org_code_str}"/>
<input type="hidden" name="appr_grade_str" id="appr_grade_str" alt="결재레벨직급" value="${apprBean.appr_grade_str}"/>
<input type="hidden" name="appr_mem_str" id="appr_mem_str" alt="결재레벨사용자" value="${apprBean.appr_mem_str}"/>
<input type="hidden" name="writer_appr_yn_str" id="writer_appr_yn_str" alt="전결가능여부"/>
<input type="hidden" id="cust_no" name="cust_no" value="${result.cust_no}">
<input type="hidden" id="cust_name" name="cust_name" value="${result.cust_name}">
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
<!-- 통화시간 -->
				<table class="table-border mt5">
					<colgroup>
						<col width="90px">
						<col width="">
						<col width="90px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right essential-item">통화시간</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width70px">
										<input type="text" class="form-control text-right essential-bg" id="as_call_hour" name="as_call_hour" required="required" alt="통화시간" format="decimal" value="${result.as_call_hour}">
									</div>
									<div class="col width33px">
										hr
									</div>
								</div>
							</td>
							<th class="text-right essential-item">결정시간</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width70px">
										<input type="text" class="form-control text-right essential-bg" id="appr_call_hour" name="appr_call_hour" required="required" alt="결정시간" format="decimal" value="${result.appr_call_hour eq '' ? result.as_call_hour : result.appr_call_hour}">
									</div>
									<div class="col width33px">
										hr
									</div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">평가</th>
							<td>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" id="appr_call_result_0" name="appr_call_result" value="0" required="required" alt="평가" <c:if test="${'0' eq result.appr_call_result}">checked="checked"</c:if> >
									<label class="form-check-label">좋음</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" id="appr_call_result_1" name="appr_call_result" value="1" required="required" alt="평가" <c:if test="${'1' eq result.appr_call_result}">checked="checked"</c:if> >
									<label class="form-check-label">일반</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" id="appr_call_result_2" name="appr_call_result" value="2" required="required" alt="평가" <c:if test="${'2' eq result.appr_call_result}">checked="checked"</c:if> >
									<label class="form-check-label">없음</label>
								</div>
							</td>
							<th class="text-right">결재일시</th>
							<td>
								<input type="text" class="form-control" id="process_date" name="process_date" dateFormat="yyyy-MM-dd" readonly="readonly" value="${result.process_date}">
							</td>
						</tr>						
					</tbody>
				</table>
<!-- /통화시간 -->
			</div>
<!-- /폼테이블 -->

<!-- 폼테이블2 -->
			<div>
<!-- 결재의견 -->
				<div class="title-wrap mt10">
					<div class="left">
						<h4>결재자의견</h4>
					</div>
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
							<div class="fixed-table-container" style="width: 100%; height: 110px;"> <!-- height값 인라인 스타일로 주면 타이틀 영역이 고정됨  -->
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
<!-- /결재의견 -->
			</div>
<!-- /폼테이블2 -->

<!-- 폼테이블3 -->
			<div>
<!-- 미결사항 -->
				<div class="title-wrap mt10">
					<h4>미결사항</h4>
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
				</div>
				<div id="auiGridAsTodos" style="margin-top: 5px; height: 100px;"></div>
<!-- /미결사항 -->
			</div>
<!-- /폼테이블3 -->

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