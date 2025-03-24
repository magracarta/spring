<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 고객관리 > 전화업무 통합관리 > 전체 > null
-- 작성자 : 성현우
-- 최초 작성일 : 2020-10-20 19:54:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

	var auiGridDICall; // DI Call
	var auiGridEndCall;
	var auiGridHappyCall;
	var auiGridDealCall;
	var auiGridRegular;
	var auiGridCap;

	var cnt = 1;
	$(document).ready(function() {
		createAUIGridDICall(); // DI Call 그리드
		createAUIGridEndCall(); // 종료점검 Call 그리드
		createAUIGridHappyCall(); // Happy Call 그리드
		// createAUIGridDealCall(); // 미수금 Call 그리드
		createAUIGridRegular(); // 정기검사 Call 그리드
		createAUIGridCap(); // Cap Call 그리드

		fnInit();
	});
	
	function fnInit() {
		var now = $M.getCurrentDate("yyyyMMdd");
		$M.setValue("s_start_dt", now);
		$M.setValue("s_end_dt", now);

		var org = ${orgBeanJson};
		if(org.org_gubun_cd != "BASE") {
			$("#s_center_org_code").prop("disabled", true);
		}
	}
	
	// DI Call 그리드
	function createAUIGridDICall() {
		var gridPros = {
			rowIdField : "_$uid",
			showRowNumColumn: true
		};
		
		var columnLayout = [
			{
				headerText: "고객명",
				dataField: "cust_name",
				width : "70", 
				minWidth : "70",
				style: "aui-center"
			},
			{
				headerText: "차대번호",
				dataField: "body_no",
				width : "90", 
				minWidth : "90",
				style: "aui-center aui-popup"
			},
			{
				headerText: "연락처",
				dataField: "hp_no",
				width : "80", 
				minWidth : "80",
				style: "aui-center"
			},
			{
				headerText: "출하일자",
				dataField: "out_dt",
				style: "aui-center",
				dataType: "date",
				width : "65", 
				minWidth : "65",
				formatString: "yy-mm-dd"
			},
			{
				headerText: "처리기한",
				dataField: "deadline_dt",
				style: "aui-center",
				dataType: "date",
				width : "65", 
				minWidth : "65",
				formatString: "yy-mm-dd"
			},
			{
				headerText: "AS번호",
				dataField: "as_no",
				visible: false
			},
			{
				headerText: "장비대장번호",
				dataField: "machine_seq",
				visible: false
			}
		];

		// 실제로 #grid_wrap에 그리드 생성
		auiGridDICall = AUIGrid.create("#auiGridDICall", columnLayout, gridPros);
		// 그리드 갱신
		AUIGrid.setGridData(auiGridDICall, []);
		$("#auiGridDICall").resize();

		AUIGrid.bind(auiGridDICall, "cellClick", function(event) {
			if (event.dataField == "body_no") {
				var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1300, height=840, left=0, top=0";
				var params = {};
				if (event.item.as_no == "") {
					params.s_machine_seq = event.item.machine_seq;
					params.as_call_type_cd = "1";
					$M.goNextPage('/serv/serv0102p13', $M.toGetParam(params), {popupStatus: popupOption});
				} else {
					params.s_as_no = event.item.as_no;
					$M.goNextPage('/serv/serv0102p06', $M.toGetParam(params), {popupStatus: popupOption});
				}
			}
		});	
	}
	
	// 종료점검 Call
	function createAUIGridEndCall() {
		var gridPros = {
			rowIdField : "_$uid",
			showRowNumColumn: true
		};
		
		var columnLayout = [
			{
				headerText : "고객명",
				dataField : "cust_name",
				width : "70", 
				minWidth : "70",
				style : "aui-center"
			},
			{
				headerText : "차대번호",
				dataField : "body_no",
				width : "90", 
				minWidth : "90",
				style : "aui-center aui-popup",
			},
			{
				headerText : "연락처",
				dataField : "hp_no",
				width : "80", 
				minWidth : "80",
				style : "aui-center",
			},
			{
				headerText : "판매일",
				dataField : "out_dt",
				style : "aui-center",
				dataType: "date",
				width : "65", 
				minWidth : "65",
				formatString : "yy-mm-dd",
			},
			{
				headerText : "처리기한",
				dataField : "deadline_dt",
				style : "aui-center",
				dataType: "date",
				width : "65", 
				minWidth : "65",
				formatString : "yy-mm-dd",
			},
			{
				headerText: "AS번호",
				dataField: "as_no",
				visible: false
			},
			{
				headerText: "장비대장번호",
				dataField: "machine_seq",
				visible: false
			}
		];

		// 실제로 #grid_wrap에 그리드 생성
		auiGridEndCall = AUIGrid.create("#auiGridEndCall", columnLayout, gridPros);
		// 그리드 갱신
		AUIGrid.setGridData(auiGridEndCall, []);

		AUIGrid.bind(auiGridEndCall, "cellClick", function (event) {
			if (event.dataField == "body_no") {
				var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1300, height=840, left=0, top=0";
				var params = {};
				if (event.item.as_no == "") {
					params.s_machine_seq = event.item.machine_seq;
					params.as_call_type_cd = "3";
					$M.goNextPage('/serv/serv0102p13', $M.toGetParam(params), {popupStatus: popupOption});
				} else {
					params.s_as_no = event.item.as_no;
					$M.goNextPage('/serv/serv0102p06', $M.toGetParam(params), {popupStatus: popupOption});
				}
			}
		});
	}
	
	// Happy Call
	function createAUIGridHappyCall() {
		var gridPros = {
			rowIdField : "_$uid",
			showRowNumColumn: true
		};
		
		var columnLayout = [
			{
				headerText : "고객명",
				dataField : "cust_name",
				width : "70", 
				minWidth : "70",
				style : "aui-center"
			},
			{
				headerText : "차대번호",
				dataField : "body_no",
				width : "100", 
				minWidth : "100",
				style : "aui-center aui-popup"
			},
			{
				headerText : "연락처",
				dataField : "hp_no",
				width : "80", 
				minWidth : "80",
				style : "aui-center"
			},
			{
				headerText : "정비완료일",
				dataField : "job_ed_dt",
				style : "aui-center",
				width : "65", 
				minWidth : "65",
				dataType: "date",
				formatString : "yy-mm-dd",
			},
			{
				headerText : "응답여부",
				dataField : "reply_yn",
				style : "aui-center",
				width : "55", 
				minWidth : "55",
				styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (item.survey_seq != "" && item.reply_yn == 'O') {
						return "aui-popup";
					}
					return null;
				}
			},
			{
				headerText : "정비지시서번호",
				dataField : "job_report_no",
				visible : false
			},
			{
				headerText : "설문번호",
				dataField : "survey_seq",
				visible : false
			},
			{
				headerText : "장비대장번호",
				dataField : "machine_seq",
				visible : false
			}
		];

		// 실제로 #grid_wrap에 그리드 생성
		auiGridHappyCall = AUIGrid.create("#auiGridHappyCall", columnLayout, gridPros);
		// 그리드 갱신
		AUIGrid.setGridData(auiGridHappyCall, []);

		AUIGrid.bind(auiGridHappyCall, "cellClick", function(event) {
			if(event.dataField == "body_no" ) {
				var params = {
					"s_job_report_no" : event.item.job_report_no
				};

				var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=840, left=0, top=0";
				$M.goNextPage('/serv/serv0101p01', $M.toGetParam(params), {popupStatus : popupOption});
			}

			if(event.dataField == "reply_yn" ) {
				if(event.item.reply_yn == "O"){
					var params = {
						"survey_seq" : event.item.survey_seq,
						"job_report_no" : event.item.job_report_no
					};

					var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=800, height=500, left=0, top=0";
					$M.goNextPage('/serv/serv040404p02', $M.toGetParam(params), {popupStatus : popupOption});
				}
			}
		});	
	}

	// 미수금 Call
	function createAUIGridDealCall() {
		var gridPros = {
			rowIdField : "_$uid",
			showRowNumColumn: true
		};
		
		var columnLayout = [
			{
				headerText: "고객명",
				dataField: "cust_name",
				width : "70", 
				minWidth : "70",
				style: "aui-center aui-popup"
			},
			{
				headerText: "총미수금",
				dataField: "ed_misu_amt",
				style: "aui-right",
				dataType: "numeric",
				width : "80", 
				minWidth : "70",
				formatString: "#,##0"
			},
			{
				headerText: "연락처",
				dataField: "hp_no",
				width : "90", 
				minWidth : "90",
				style: "aui-center"
			},
			{
				headerText: "미수입금예정일",
				dataField: "deposit_plan_dt",
				style: "aui-center",
				dataType: "date",
				width : "65", 
				minWidth : "65",
				formatString: "yy-mm-dd"
			},
			{
				headerText : "고객번호",
				dataField : "cust_no",
				visible : false
			}
		];
		
		// 실제로 #grid_wrap에 그리드 생성
		auiGridDealCall = AUIGrid.create("#auiGridDealCall", columnLayout, gridPros);
		// 그리드 갱신
		AUIGrid.setGridData(auiGridDealCall, []);

		AUIGrid.bind(auiGridDealCall, "cellClick", function(event) {
			if(event.dataField == "cust_name" ) {
				var params = {
					"s_cust_no" : event.item.cust_no,
				};

				openDealLedgerPanel($M.toGetParam(params));
			}
		});	
	}

	// 정기검사 Call
	function createAUIGridRegular() {
		var gridPros = {
			rowIdField : "_$uid",
			showRowNumColumn: true
		};
		
		var columnLayout = [
			{
				headerText : "고객명",
				dataField : "cust_name",
				width : "65", 
				minWidth : "65",
				style : "aui-center"
			},
			{
				headerText : "차대번호",
				dataField : "body_no",
				width : "80", 
				minWidth : "80",
				style : "aui-center aui-popup"
			},
			{
				headerText : "연락처",
				dataField : "hp_no",
				width : "75", 
				minWidth : "75",
				style : "aui-center"
			},
			{
				headerText : "차수",
				dataField : "seq_no",
				width : "35", 
				minWidth : "35",
				style : "aui-center"
			},
			{
				headerText : "검사예정",
				dataField : "deadline_dt",
				style : "aui-center",
				dataType: "date",
				width : "65", 
				minWidth : "65",
				formatString: "yy-mm-dd"
			},
			{
				headerText : "Call 일자",
				dataField : "as_dt",
				style : "aui-center",
				dataType: "date",
				width : "65", 
				minWidth : "65",
				formatString: "yy-mm-dd"
			},
			{
				headerText : "AS번호",
				dataField : "as_no",
				visible : false
			},
			{
				headerText: "장비대장번호",
				dataField: "machine_seq",
				visible: false
			}
		];

		// 실제로 #grid_wrap에 그리드 생성
		auiGridRegular = AUIGrid.create("#auiGridRegular", columnLayout, gridPros);
		// 그리드 갱신
		AUIGrid.setGridData(auiGridRegular, []);

		AUIGrid.bind(auiGridRegular, "cellClick", function(event) {
			if(event.dataField == "body_no" ) {
				var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1300, height=840, left=0, top=0";
				var params = {};
				if (event.item.as_no == "") {
					params.s_machine_seq = event.item.machine_seq;
					$M.goNextPage('/serv/serv0102p13', $M.toGetParam(params), {popupStatus: popupOption});
				} else {
					params.s_as_no = event.item.as_no;
					$M.goNextPage('/serv/serv0102p06', $M.toGetParam(params), {popupStatus: popupOption});
				}
			}
		});
	}

	// Cap Call 그리드
	function createAUIGridCap() {
		var gridPros = {
			rowIdField : "_$uid",
			showRowNumColumn: true
		};
		
		var columnLayout = [
			{
				headerText : "고객명",
				dataField : "cust_name",
				width : "65", 
				minWidth : "65",
				style : "aui-center aui-popup"
			},
			{
				headerText : "차대번호",
				dataField : "body_no",
				width : "80", 
				minWidth : "80",
				style : "aui-center aui-popup"
			},
			{
				headerText : "연락처",
				dataField : "hp_no",
				width : "75", 
				minWidth : "75",
				style : "aui-center"
			},
			{
				headerText : "현재차수",
				dataField : "cap_cnt",
				width : "55", 
				minWidth : "55",
				style : "aui-center"
			},
			{
				headerText : "예정일자",
				dataField : "change_plan_date",
				dataType : "date",
				width : "65", 
				minWidth : "65",
				formatString: "yy-mm-dd"
			},
			{
				headerText : "Call 일자",
				dataField : "reg_dt",
				dataType : "date",
				width : "65", 
				minWidth : "65",
				formatString: "yy-mm-dd"
			},
			{
				headerText : "고객번호",
				dataField : "cust_no",
				visible : false
			},
			{
				headerText : "장비대장번호",
				dataField : "machine_seq",
				visible : false
			}
		];

		// 실제로 #grid_wrap에 그리드 생성
		auiGridCap = AUIGrid.create("#auiGridCap", columnLayout, gridPros);
		// 그리드 갱신
		AUIGrid.setGridData(auiGridCap, []);

		AUIGrid.bind(auiGridCap, "cellClick", function(event) {
			if(event.dataField == "cust_name" ) {
				var param = {
					"cust_no" : event.item.cust_no
				};

				var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=750, left=0, top=0";
				$M.goNextPage('/cust/cust0102p01', $M.toGetParam(param), {popupStatus : poppupOption});
			}

			if(event.dataField == "body_no" ) {
				var params = {
					"s_machine_seq" : event.item.machine_seq
				};

				var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1300, height=840, left=0, top=0";
				$M.goNextPage('/sale/sale0205p01', $M.toGetParam(params), {popupStatus : popupOption});
			}
		});
	}
	
	
	// 조회
	function goSearch() {
		var param = {
			"s_start_dt": $M.getValue("s_start_dt"),
			"s_end_dt": $M.getValue("s_end_dt"),
			"s_center_org_code": $M.getValue("s_center_org_code"),
			"s_treat_yn" : "N",
			"s_page_type" : "T",
			"s_masking_yn" : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N",
			"s_cnt" : cnt
		};

		if(cnt == 1) {
			AUIGrid.setGridData(auiGridDICall, []);
			$("#di_total_cnt").html(0);
			AUIGrid.setGridData(auiGridEndCall, []);
			$("#end_total_cnt").html(0);
			AUIGrid.setGridData(auiGridHappyCall, []);
			$("#happy_total_cnt").html(0);
			AUIGrid.setGridData(auiGridRegular, []);
			$("#regular_total_cnt").html(0);
			AUIGrid.setGridData(auiGridCap, []);
			$("#cap_total_cnt").html(0);
		}

		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: 'GET'},
				function (result) {
					if (result.success) {
						fnDataSetting(result);
						cnt++;
						if(cnt < 6) {
							goSearch();
						} else {
							cnt = 1;
						}
					}
				}
		);
	}

	function fnDataSetting(result) {

		if(cnt == 1) {
			// DI Call
			$("#di_total_cnt").html(result.di_total_cnt);
			AUIGrid.setGridData(auiGridDICall, result.dIList);
			AUIGrid.showAjaxLoader("#auiGridEndCall");
			AUIGrid.showAjaxLoader("#auiGridHappyCall");
			AUIGrid.showAjaxLoader("#auiGridRegular");
			AUIGrid.showAjaxLoader("#auiGridCap");
		}

		if(cnt == 2) {
			// 종료점검 Call
			AUIGrid.removeAjaxLoader("#auiGridEndCall");
			$("#end_total_cnt").html(result.end_total_cnt);
			AUIGrid.setGridData(auiGridEndCall, result.endList);
		}

		if(cnt == 3) {
			// Happy Call
			AUIGrid.removeAjaxLoader("#auiGridHappyCall");
			$("#happy_total_cnt").html(result.happy_total_cnt);
			AUIGrid.setGridData(auiGridHappyCall, result.happyList);
		}

		// 미수금 Call
		// $("#deal_total_cnt").html(result.deal_total_cnt);
		// AUIGrid.setGridData(auiGridDealCall, result.dealList);

		if(cnt == 4) {
			// 정기검사 Call
			AUIGrid.removeAjaxLoader("#auiGridRegular");
			$("#regular_total_cnt").html(result.regular_total_cnt);
			AUIGrid.setGridData(auiGridRegular, result.regularList);
		}

		if(cnt == 5) {
			// 정기검사 Call
			AUIGrid.removeAjaxLoader("#auiGridCap");
			$("#cap_total_cnt").html(result.cap_total_cnt);
			AUIGrid.setGridData(auiGridCap, result.capCallList);
		}
	}
	</script>
</head>
<body style="background : #fff">
<form id="main_form" name="main_form">
<input type="hidden" id="s_start_dt" name="s_start_dt">
<input type="hidden" id="s_end_dt" name="s_end_dt">
<input type="hidden" id="s_service_mem_no" name="s_service_mem_no" value="${inputParam.login_mem_no}">
<div class="layout-box">
<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
				<div class="contents">
<!-- 검색영역 -->		
					<div class="search-wrap mt10">				
						<table class="table">
							<colgroup>
								<col width="55px">
								<col width="120px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th>담당센터</th>
									<td>
										<select class="form-control" id="s_center_org_code" name="s_center_org_code">
											<option value="">- 전체 -</option>
											<c:forEach items="${orgCenterList}" var="item">
												<option value="${item.org_code}" <c:if test="${item.org_code eq orgBean.org_code}">selected="selected"</c:if> >${item.org_name}</option>
											</c:forEach>
										</select>
									</td>
									<td>
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
										&nbsp;&nbsp;&nbsp;
										<c:if test="${page.add.POS_UNMASKING eq 'Y'}">
										<div class="form-check form-check-inline">
											<input  class="form-check-input"  type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" >
											<label  class="form-check-input"  for="s_masking_yn" >마스킹 적용</label>
										</div>
										</c:if>					
									</td>	
								</tr>
							</tbody>
						</table>					
					</div>
<!-- /검색영역 -->
					<div class="row mt10">
						<div class="col-4">
<!-- DI Call -->
							<div class="title-wrap">
								<h4>DI Call</h4>
							</div>
							<div id="auiGridDICall" style="margin-top: 5px; height: 250px;"></div>
							<div class="btn-group mt5">	
								<div class="left">
									총 <strong id="di_total_cnt" class="text-primary">0</strong>건
								</div>
							</div>
<!-- /DI Call -->
						</div>
						<div class="col-4">
<!-- 종료점검 Call -->
							<div class="title-wrap">
								<h4>종료점검 Call</h4>
							</div>
							<div id="auiGridEndCall" style="margin-top: 5px; height: 250px;"></div>
							<div class="btn-group mt5">	
								<div class="left">
									총 <strong id="end_total_cnt" class="text-primary">0</strong>건
								</div>
							</div>
<!-- /종료점검 Call -->
						</div>
						<div class="col-4">
<!-- Happy Call -->
							<div class="title-wrap">
								<h4>Happy Call</h4>
							</div>
							<div id="auiGridHappyCall" style="margin-top: 5px; height: 250px;"></div>
							<div class="btn-group mt5">	
								<div class="left">
									총 <strong id="happy_total_cnt" class="text-primary">0</strong>건
								</div>
							</div>
<!-- /Happy Call -->
						</div>
					</div>
					
					<div class="row mt10">
						<div class="col-4">
<!-- 미수금 Call -->
<%--							<div class="title-wrap">--%>
<%--								<h4>미수금 Call</h4>--%>
<%--							</div>--%>
<%--							<div id="auiGridDealCall" style="margin-top: 5px; height: 250px;"></div>--%>
<%--							<div class="btn-group mt5">	--%>
<%--								<div class="left">--%>
<%--									총 <strong id="deal_total_cnt" class="text-primary">0</strong>건--%>
<%--								</div>--%>
<%--							</div>--%>
							<div class="title-wrap">
								<h4>정기검사 Call</h4>
							</div>
							<div id="auiGridRegular" style="margin-top: 5px; height: 250px;"></div>
							<div class="btn-group mt5">
								<div class="left">
									총 <strong id="regular_total_cnt" class="text-primary">0</strong>건
								</div>
							</div>
<!-- /미수금 Call -->
						</div>
						<div class="col-4">
<%--<!-- 정기검사 Call -->--%>
<%--							<div class="title-wrap">--%>
<%--								<h4>정기검사 Call</h4>--%>
<%--							</div>--%>
<%--							<div id="auiGridRegular" style="margin-top: 5px; height: 250px;"></div>--%>
<%--							<div class="btn-group mt5">	--%>
<%--								<div class="left">--%>
<%--									총 <strong id="regular_total_cnt" class="text-primary">0</strong>건--%>
<%--								</div>--%>
<%--							</div>--%>
<%--<!-- /정기검사 Call -->--%>
						</div>
						<div class="col-4">
<!-- CAP Call -->
							<div class="title-wrap">
								<h4>CAP Call</h4>
							</div>
							<div id="auiGridCap" style="margin-top: 5px; height: 250px;"></div>
							<div class="btn-group mt5">	
								<div class="left">
									총 <strong id="cap_total_cnt" class="text-primary">0</strong>건
								</div>
							</div>
<!-- /CAP Call -->
						</div>
					</div>
				</div>

			</div>		
		</div>
<!-- /contents 전체 영역 -->		
</div>
</form>	
</body>
</html>