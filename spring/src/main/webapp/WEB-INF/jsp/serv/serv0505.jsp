<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 서비스관리 > 워렌티리포트 통합관리 > null > null
-- 작성자 : 성현우
-- 최초 작성일 : 2020-09-22 13:20:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

	var auiGridTop;
	var auiGridBom;
	$(document).ready(function() {
		// AUIGrid 생성
		createAUIGridTop();
		createAUIGridBom();
	});

	// 엔터키 이벤트
	function enter(fieldObj) {
		var field = ["s_as_warranty_no"];
		$.each(field, function() {
			if(fieldObj.name == this) {
				goSearch();
			}
		});
	}

	// 엑셀 다운로드
	function fnDownloadExcel() {
		fnExportExcel(auiGridTop, "워런티리포트 통합관리");
	}

	// 조회
	function goSearch() {
		var frm = document.main_form;
		//validationcheck
		if ($M.validation(frm,
				{field: ["s_start_dt", "s_end_dt"]}) == false) {
			return;
		}

		var params = {
			"s_start_dt": $M.getValue("s_start_dt"),
			"s_end_dt": $M.getValue("s_end_dt"),
			"s_as_warranty_no": $M.getValue("s_as_warranty_no"),
			"s_req_type_fr": $M.getValue("s_req_type_fr"),
			"s_status_cd": $M.getValue("s_status_cd"),
			"s_date_type" : $M.getValue("s_date_type")
		};
		_fnAddSearchDt(params, 's_start_dt', 's_end_dt');
		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(params), {method: 'GET'},
				function (result) {
					if (result.success) {
						AUIGrid.setGridData(auiGridTop, result.list);
						AUIGrid.setGridData(auiGridBom, result.summaryList);
					}
				}
		);
	}

	// 청구처리
	function goChargeProcess() {
		var frm = $M.toValueForm(document.main_form);
		var gridData = AUIGrid.getCheckedRowItemsAll(auiGridTop);
		if (gridData.length < 1) {
			alert("청구처리할 내역을 먼저 선택해주세요.");
			return;
		}

		var as_warranty_no = [];
		for (var i in gridData) {
			if (gridData[i].money_req_dt != "") {
				alert("이미 청구처리한 내용이 존재합니다.");
				return;
			}
			as_warranty_no.push(gridData[i].as_warranty_no);
		}

		var option = {
			isEmpty: true
		};

		$M.setValue(frm, "as_warranty_no_str", $M.getArrStr(as_warranty_no, option));

		var msg = "처리후 수정 및 취소가 불가능합니다.\n처리일자를 확인하시기 바랍니다.\n선택된 자료가 정확합니까?";
		$M.goNextPageAjaxMsg(msg, this_page + "/save/req_dt", frm, {method: 'POST'},
				function (result) {
					if (result.success) {
						alert("청구처리가 완료되었습니다.");
						goSearch();
					}
				}
		);
	}

	// 수납처리
	function goPurchaseProcess() {
		var frm = $M.toValueForm(document.main_form);
		var gridData = AUIGrid.getCheckedRowItemsAll(auiGridTop);
		if (gridData.length < 1) {
			alert("수납처리할 내역을 먼저 선택해주세요.");
			return;
		}

		var as_warranty_no = [];
		var rcv_part_amt = [];
		var rcv_travel_amt = [];
		var rcv_work_amt = [];
		var rcv_kor_part_amt = [];
		var rcv_kor_travel_amt = [];
		var rcv_kor_work_amt = [];
		var apply_er_price = [];
		var result_text = [];
		for (var i in gridData) {
			if (gridData[i].money_rcv_dt != "") {
				alert("이미 수납처리한 내용이 존재합니다.");
				return;
			}

			if(gridData[i].money_req_dt == "") {
				alert("청구처리가 진행 안된 건이 존재합니다.");
				return;
			}

			as_warranty_no.push(gridData[i].as_warranty_no);
			rcv_part_amt.push(gridData[i].rcv_part_amt);
			rcv_travel_amt.push(gridData[i].rcv_travel_amt);
			rcv_work_amt.push(gridData[i].rcv_work_amt);
			rcv_kor_part_amt.push(gridData[i].rcv_kor_part_amt);
			rcv_kor_travel_amt.push(gridData[i].rcv_kor_travel_amt);
			rcv_kor_work_amt.push(gridData[i].rcv_kor_work_amt);
			apply_er_price.push(gridData[i].apply_er_price);
			result_text.push(gridData[i].result_text);
		}

		var option = {
			isEmpty: true
		};

		$M.setValue(frm, "as_warranty_no_str", $M.getArrStr(as_warranty_no, option));
		$M.setValue(frm, "rcv_part_amt_str", $M.getArrStr(rcv_part_amt, option));
		$M.setValue(frm, "rcv_travel_amt_str", $M.getArrStr(rcv_travel_amt, option));
		$M.setValue(frm, "rcv_work_amt_str", $M.getArrStr(rcv_work_amt, option));
		$M.setValue(frm, "rcv_kor_part_amt_str", $M.getArrStr(rcv_kor_part_amt, option));
		$M.setValue(frm, "rcv_kor_travel_amt_str", $M.getArrStr(rcv_kor_travel_amt, option));
		$M.setValue(frm, "rcv_kor_work_amt_str", $M.getArrStr(rcv_kor_work_amt, option));
		$M.setValue(frm, "apply_er_price_str", $M.getArrStr(apply_er_price, option));
		$M.setValue(frm, "result_text_str", $M.getArrStr(result_text, option));

		var msg = "처리후 수정 및 취소가 불가능합니다.\n처리일자를 확인하시기 바랍니다.\n선택된 자료가 정확합니까?";
		$M.goNextPageAjaxMsg(msg, this_page + "/save/rcv_dt", frm, {method: 'POST'},
				function (result) {
					if (result.success) {
						alert("수납처리가 완료되었습니다.");
						goSearch();
					}
				}
		);
	}

	// 그리드생성
	function createAUIGridTop() {
		var gridPros = {
			rowIdField : "_$uid",
			showRowNumColumn: true,
			//체크박스 출력 여부
			showRowCheckColumn : true,
			//전체선택 체크박스 표시 여부
			showRowAllCheckBox : true,
			showStateColumn : false,
			enableFilter :true,
			// fixedColumnCount : 7,
		};
		var columnLayout = [
			{
				headerText : "AS번호",
				dataField : "as_no",
				visible : false
			},
			{
				headerText : "AS타입",
				dataField : "as_type",
				visible : false
			},
			{
				headerText : "정비일자",
				dataField : "as_dt",
				style: "aui-center aui-popup",
				dataType: "date",
				formatString: "yy-mm-dd",
				width : "65",
				minWidth : "65",
			},
			{
				headerText : "관리번호",
				dataField : "warranty_no",
				width : "90",
				minWidth : "90",
				style : "aui-center"
			},
			{
				headerText : "관리번호",
				dataField : "as_warranty_no",
				visible : false
			},
			{
				headerText : "차주명",
				dataField : "cust_name",
				width : "90",
				minWidth : "90",
				style : "aui-center",
			},
			{
				headerText : "메이커",
				dataField : "maker_name",
				width : "80",
				minWidth : "80",
				style : "aui-center",
				filter : {
					showIcon : true
				},
			},
			{
				headerText : "모델명",
				dataField : "machine_name",
				width : "110",
				minWidth : "110",
				style : "aui-center",
			},
			{
				headerText : "차대번호",
				dataField : "body_no",
				width : "150",
				minWidth : "150",
				style : "aui-center",
			},
			{
				headerText : "출하일자",
				dataField : "out_dt",
				style: "aui-center",
				dataType: "date",
				formatString: "yy-mm-dd",
				width : "65",
				minWidth : "65",
			},
			{
				headerText : "적요",
				style : "aui-center",
				children : [
					{
						headerText : "청구내역",
						dataField : "warranty_text",
						style : "aui-left aui-popup",
						width : "230",
						minWidth : "230",
					},
					{
						headerText : "부품비",
						dataField : "rpt_part_amt",
						style : "aui-right",
						dataType : "numeric",
						width : "85",
						minWidth : "85",
						formatString : "#,##0",
						labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
		                    return value == 0 ? "" : $M.setComma(value);
		                }
					},
					{
						headerText : "출장비",
						dataField : "rpt_travel_amt",
						style : "aui-right",
						dataType : "numeric",
						width : "85",
						minWidth : "85",
						formatString : "#,##0",
						labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
		                    return value == 0 ? "" : $M.setComma(value);
		                }
					},
					{
						headerText : "공임",
						dataField : "rpt_work_amt",
						style : "aui-right",
						dataType : "numeric",
						width : "85",
						minWidth : "85",
						formatString : "#,##0",
						labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
		                    return value == 0 ? "" : $M.setComma(value);
		                }
					},
					{
						headerText : "청구일자",
						dataField : "money_req_dt",
						style: "aui-center",
						dataType: "date",
						formatString: "yy-mm-dd",
						width : "65",
						minWidth : "65",
					},
					{
						headerText : "F",
						dataField : "req_type_fr",
						style : "aui-center",
						width : "30",
						minWidth : "30",
					},
				]
			},
			{
				headerText : "수납내역(외화)",
				style : "aui-center",
				children : [
					{
						headerText : "크레임결정내역",
						dataField : "result_text",
						style : "aui-left",
						width : "230",
						minWidth : "230",
					},
					{
						headerText : "부품비",
						dataField : "rcv_part_amt",
						style : "aui-right",
						dataType : "numeric",
						width : "85",
						minWidth : "85",
						formatString : "#,##0",
						labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
		                    return value == 0 ? "" : $M.setComma(value);
		                }
					},
					{
						headerText : "출장비",
						dataField : "rcv_travel_amt",
						style : "aui-right",
						dataType : "numeric",
						width : "85",
						minWidth : "85",
						formatString : "#,##0",
						labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
		                    return value == 0 ? "" : $M.setComma(value);
		                }
					},
					{
						headerText : "공임",
						dataField : "rcv_work_amt",
						style : "aui-right",
						dataType : "numeric",
						width : "85",
						minWidth : "85",
						formatString : "#,##0",
						labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
		                    return value == 0 ? "" : $M.setComma(value);
		                }
					},
					{
						headerText : "수납일자",
						dataField : "money_rcv_dt",
						style: "aui-center",
						dataType: "date",
						formatString: "yy-mm-dd",
						width : "65",
						minWidth : "65",
					},
					{
						headerText : "R",
						dataField : "reclaim_yn",
						style : "aui-center",
						width : "30",
						minWidth : "30",
					},
				]
			},
			{
				headerText : "수납내역(원화)",
				style : "aui-center",
				children : [
					{
						headerText : "환율",
						dataField : "apply_er_price",
						style : "aui-right",
						dataType : "numeric",
						width : "85",
						minWidth : "85",
						formatString : "#,##0",
						labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
		                    return value == 0 ? "" : $M.setComma(value);
		                }
					},
					{
						headerText : "부품비",
						dataField : "rcv_kor_part_amt",
						style : "aui-right",
						dataType : "numeric",
						width : "85",
						minWidth : "85",
						formatString : "#,##0",
						labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
		                    return value == 0 ? "" : $M.setComma(value);
		                }
					},
					{
						headerText : "출장비",
						dataField : "rcv_kor_travel_amt",
						style : "aui-right",
						dataType : "numeric",
						width : "85",
						minWidth : "85",
						formatString : "#,##0",
						labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
		                    return value == 0 ? "" : $M.setComma(value);
		                }
					},
					{
						headerText : "공임",
						dataField : "rcv_kor_work_amt",
						style : "aui-right",
						dataType : "numeric",
						width : "85",
						minWidth : "85",
						formatString : "#,##0",
						labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
		                    return value == 0 ? "" : $M.setComma(value);
		                }
					},
				]
			},
		];

		auiGridTop = AUIGrid.create("#auiGridTop", columnLayout, gridPros);
		AUIGrid.setGridData(auiGridTop, []);

		AUIGrid.bind(auiGridTop, "cellClick", function(event) {
			// 서비스일지 호출
			if(event.dataField == "as_dt" ) {

				var params = {
					"s_as_no" : event.item.as_no
				};

 				if(event.item.as_type == "REPAIR") {
					var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1600, height=800, left=0, top=0";
	 				$M.goNextPage('/serv/serv0102p01', $M.toGetParam(params), {popupStatus : popupOption});
 				} else if(event.item.as_type == "CALL") {
					var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1400, height=800, left=0, top=0";
	 				$M.goNextPage('/serv/serv0102p06', $M.toGetParam(params), {popupStatus : popupOption});

 				}
			}

			// 수납금액조정 호출
			if(event.dataField == "warranty_text") {
				var params = {
					"as_warranty_no" : event.item.as_warranty_no
				};

				var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=600, height=430, left=0, top=0";
				$M.goNextPage('/serv/serv0505p01', $M.toGetParam(params), {popupStatus : popupOption});
			}
		});

		$("#auiGridTop").resize();
	}

	// 집계표 그리드
	function createAUIGridBom() {
		var gridPros = {
			rowIdField : "_$uid",
			showRowNumColumn: false,
			showFooter : true,
			footerPosition : "top"
		};
		
		var columnLayout = [
			{
				headerText : "메이커",
				dataField : "maker_name",
				width : "110",
				minWidth : "110",
				style : "aui-center",
			},
			{
				headerText : "레포트미작성",
				dataField : "n_report_cnt",
				width : "90",
				minWidth : "90",
				style : "aui-center",
				labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                    return value == 0 ? "" : $M.setComma(value);
                }
			},
			{
				headerText : "미청구",
				style : "aui-center",
				children : [
					{
						headerText : "건수",
						dataField : "n_req_cnt",
						width : "90",
						minWidth : "90",
						labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
		                    return value == 0 ? "" : $M.setComma(value);
		                }
					},
					{
						headerText : "금액",
						dataField : "rpt_price_1",
						style : "aui-right",
						dataType : "numeric",
						width : "90",
						minWidth : "90",
						formatString : "#,##0",
						labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
		                    return value == 0 ? "" : $M.setComma(value);
		                }
					},
				]
			},
			{
				headerText : "미수납",
				style : "aui-center",
				children : [
					{
						headerText : "건수",
						dataField : "n_rcv_cnt",
						width : "90",
						minWidth : "90",
						labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
		                    return value == 0 ? "" : $M.setComma(value);
		                }
					},
					{
						headerText : "금액",
						dataField : "rpt_price_2",
						style : "aui-right",
						dataType : "numeric",
						width : "90",
						minWidth : "90",
						formatString : "#,##0",
						labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
		                    return value == 0 ? "" : $M.setComma(value);
		                }
					},
				]
			},
			{
				headerText : "수납",
				style : "aui-center",
				children : [
					{
						headerText : "건수",
						dataField : "y_rcv_cnt",
						width : "90",
						minWidth : "90",
						labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
		                    return value == 0 ? "" : $M.setComma(value);
		                }
					},
					{
						headerText : "금액(외화)",
						dataField : "rcv_price_1",
						style : "aui-right",
						dataType : "numeric",
						width : "90",
						minWidth : "90",
						formatString : "#,##0",
						labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
		                    return value == 0 ? "" : $M.setComma(value);
		                }
					},
					{
						headerText : "금액(원화)",
						dataField : "rcv_price_2",
						style : "aui-right",
						dataType : "numeric",
						width : "90",
						minWidth : "90",
						formatString : "#,##0",
						labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
		                    return value == 0 ? "" : $M.setComma(value);
		                }
					},
				]
			},
		];

		// 푸터레이아웃
		var footerColumnLayout = [
			{
				labelText : "합계",
				positionField : "maker_name",
				style : "aui-center aui-footer",
			},
			{
				dataField : "n_report_cnt",
				positionField : "n_report_cnt",
				operation : "SUM",
				formatString : "#,##0",
				style : "aui-center aui-footer",
			},
			{
				dataField : "n_req_cnt",
				positionField : "n_req_cnt",
				operation : "SUM",
				formatString : "#,##0",
				style : "aui-center aui-footer",
			},
			{
				dataField : "rpt_price_1",
				positionField : "rpt_price_1",
				operation : "SUM",
				formatString : "#,##0",
				style : "aui-right aui-footer",
			},
			{
				dataField : "n_rcv_cnt",
				positionField : "n_rcv_cnt",
				operation : "SUM",
				formatString : "#,##0",
				style : "aui-center aui-footer",
			},
			{
				dataField : "rpt_price_2",
				positionField : "rpt_price_2",
				operation : "SUM",
				formatString : "#,##0",
				style : "aui-right aui-footer",
			},
			{
				dataField : "y_rcv_cnt",
				positionField : "y_rcv_cnt",
				operation : "SUM",
				formatString : "#,##0",
				style : "aui-center aui-footer",
			},
			{
				dataField : "rcv_price_1",
				positionField : "rcv_price_1",
				operation : "SUM",
				formatString : "#,##0",
				style : "aui-right aui-footer",
			},
			{
				dataField : "rcv_price_2",
				positionField : "rcv_price_2",
				operation : "SUM",
				formatString : "#,##0",
				style : "aui-right aui-footer",
			}
		];

		auiGridBom = AUIGrid.create("#auiGridBom", columnLayout, gridPros);
		AUIGrid.setFooter(auiGridBom, footerColumnLayout);
		AUIGrid.setGridData(auiGridBom, []);

		$("#auiGridBom").resize();
	}
	</script>
</head>
<body>
<form id="main_form" name="main_form">
	<div class="layout-box">
		<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
				<!-- 메인 타이틀 -->
				<div class="main-title">
					<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
				</div>
				<!-- /메인 타이틀 -->
				<div class="contents">
					<!-- 검색영역 -->
					<div class="search-wrap">
						<table class="table">
							<colgroup>
								<col width="100px">
								<col width="270px">
								<col width="50px">
								<col width="100px">
								<col width="65px">
								<col width="100px">
								<col width="50px">
								<col width="100px">
								<col width="">
							</colgroup>
							<tbody>
							<tr>
								<td>
									<select class="form-control" id="s_date_type" name="s_date_type">
										<option value="as_dt">정비일자</option>
										<option value="warranty_dt">작성일자</option>
										<option value="money_req_dt">청구일자</option>
										<option value="money_rcv_dt">수납일자</option>
									</select>
								</td>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="요청시작일" value="${searchDtMap.s_start_dt}">
											</div>
										</div>
										<div class="col-auto">~</div>
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="요청종료일" value="${searchDtMap.s_end_dt}">
											</div>
										</div>
										<jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp">
			                     		<jsp:param name="st_field_name" value="s_start_dt"/>
			                     		<jsp:param name="ed_field_name" value="s_end_dt"/>
			                     		<jsp:param name="click_exec_yn" value="Y"/>
			                     		<jsp:param name="exec_func_name" value="goSearch();"/>
			                     		</jsp:include>	
									</div>
								</td>
								<th>관리번호</th>
								<td>
									<input type="text" class="form-control" id="s_as_warranty_no" name="s_as_warranty_no">
								</td>
								<th>자료구분</th>
								<td>
									<select class="form-control" id="s_req_type_fr" name="s_req_type_fr">
										<option value="">- 전체 -</option>
										<option value="R">실제</option>
										<option value="F">임의</option>
									</select>
								</td>
								<th>상태</th>
								<td>
									<select class="form-control" id="s_status_cd" name="s_status_cd">
										<option value="">- 전체 -</option>
										<option value="1">미작성</option>
										<option value="2">미청구</option>
										<option value="3">미수납</option>
										<option value="4">수납</option>
									</select>
								</td>
								<td>
									<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
								</td>
							</tr>
							</tbody>
						</table>
					</div>
					<!-- /검색영역 -->
					<!-- 조회결과 -->
					<div class="title-wrap mt10">
						<h4>조회결과</h4>
						<div class="right">
							<div class="input-group">
								<div class="right dpf">
									<span class="mr5">처리일자</span>
									<div class="input-group mr5" style="width: 100px;">
										<input type="text" class="form-control border-right-0 calDate" id="money_dt" name="money_dt" dateFormat="yyyy-MM-dd" value="${inputParam.s_current_dt}">
									</div>
									<div>
										<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
									</div>
								</div>
							</div>
						</div>
					</div>
					<div id="auiGridTop" style="margin-top: 5px; height: 400px;"></div>
					<!-- /조회결과 -->
					<!-- 집계표 -->
					<div class="title-wrap mt10">
						<h4>집계표</h4>
					</div>
					<div id="auiGridBom" style="margin-top: 5px; height: 200px;"></div>
					<!-- /집계표 -->
				</div>
			</div>
		</div>
		<!-- /contents 전체 영역 -->
	</div>
</form>
</body>
</html>