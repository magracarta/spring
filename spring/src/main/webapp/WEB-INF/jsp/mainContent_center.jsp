<%@ page contentType="text/html;charset=utf-8" language="java"%><%@ include file="/WEB-INF/jsp/common/commonForAll.jsp" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<!DOCTYPE html>
<script type="text/javascript">
	var auiGridMidLeft;
	var auiGridMidRight;

	$(document).ready(function() {
		// AUIGrid 생성
		createAUIGridMidLeft();
		createAUIGridMidRight();
	});

	// 업무내용 집계표 그리드
	function createAUIGridMidLeft() {
		var gridPros = {
			showRowNumColumn: false,
			// fixedColumnCount: 4,
			enableCellMerge: true,
		};

		var columnLayout = [
			{
				headerText: "사원",
				dataField: "reg_mem_name",
				width : "100",
				style: "aui-center",
				colSpan : 2,
				cellMerge : true
			},
			{
				dataField: "col_div_name",
				width : "47",
				style: "aui-center",
			},
			{
				headerText : "근무일수",
				dataField: "work_total",
				dataType: "numeric",
				formatString: "#,##0",
				width : "85",
				style: "aui-right",
				labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
					if(item["col_div_name"] == "건수"){
						value = item["work_total_cnt"];
					}else {
						value = item["work_total_hour"];
					}
					value = AUIGrid.formatNumber(value, "#,##0");
					return value == 0 ? "0" : value;
				},
				styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
					return "";
				}
			},
			{
				headerText : "배정",
				dataField: "assign_total",
				dataType: "numeric",
				formatString: "#,##0",
				width : "75",
				style: "aui-right",
				labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
					if(item["col_div_name"] == "건수"){
						value = item["assign_total_cnt"];
					}else {
						value = item["assign_total_hour"];
					}
					value = AUIGrid.formatNumber(value, "#,##0");
					return value == 0 ? "0" : value;
				},
				styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
					return "";
				}
			},
			{
				headerText : "처리",
				dataField: "complete_total",
				dataType: "numeric",
				formatString: "#,##0",
				width : "75",
				style: "aui-right",
				labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
					if(item["col_div_name"] == "건수"){
						value = item["complete_total_cnt"];
					}else {
						value = item["complete_total_hour"];
					}
					value = AUIGrid.formatNumber(value, "#,##0");
					return value == 0 ? "0" : value;
				},
				styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
					return "";
				}
			},
			{
				headerText : "정비",
				dataField: "job_report_total",
				dataType: "numeric",
				formatString: "#,##0",
				width : "75",
				style: "aui-right",
				labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
					if(item["col_div_name"] == "건수"){
						value = item["job_report_total_cnt"];
					}else {
						value = item["job_report_total_hour"];
					}
					value = AUIGrid.formatNumber(value, "#,##0");
					return value == 0 ? "0" : value;
				},
				styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
					return "";
				}
			},
			{
				headerText : "On Time",
				dataField: "on_time_total",
				dataType: "numeric",
				formatString: "#,##0",
				width : "85",
				style: "aui-right",
				labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
					if(item["col_div_name"] == "건수"){
						value = item["on_time_total_cnt"];
					}else {
						value = item["on_time_total_hour"];
					}
					value = AUIGrid.formatNumber(value, "#,##0");
					return value == 0 ? "0" : value;
				},
				styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
					return "";
				}
			},
			{
				headerText : "상담",
				dataField: "consult",
				dataType: "numeric",
				formatString: "#,##0",
				width : "75",
				style: "aui-right",
				labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
					if(item["col_div_name"] == "건수"){
						value = item["consult_cnt"];
					}else {
						value = item["consult_hour"];
					}
					value = AUIGrid.formatNumber(value, "#,##0");
					return value == 0 ? "0" : value;
				},
				styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
					return "";
				}
			},
			{
				headerText : "렌탈계약",
				dataField: "rental_contract_total",
				dataType: "numeric",
				formatString: "#,##0",
				width : "85",
				style: "aui-right",
				labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
					if(item["col_div_name"] == "건수"){
						value = item["rental_contract_total_cnt"];
					}else {
						value = item["rental_contract_total_hour"];
					}
					value = AUIGrid.formatNumber(value, "#,##0");
					return value == 0 ? "0" : value;
				},
				styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
					return "";
				}
			},
			{
				headerText : "렌탈점검",
				dataField: "rental_job",
				dataType: "numeric",
				formatString: "#,##0",
				width : "85",
				style: "aui-right",
				labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
					if(item["col_div_name"] == "건수"){
						value = item["rental_job_cnt"];
					}else {
						value = item["rental_job_hour"];
					}
					value = AUIGrid.formatNumber(value, "#,##0");
					return value == 0 ? "0" : value;
				},
				styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
					return "";
				}
			},
			{
				headerText : "기타",
				dataField: "etc_total",
				dataType: "numeric",
				formatString: "#,##0",
				width : "75",
				style: "aui-right",
				labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
					if(item["col_div_name"] == "건수"){
						value = item["etc_total_cnt"];
					}else {
						value = item["etc_total_hour"];
					}
					value = AUIGrid.formatNumber(value, "#,##0");
					return value == 0 ? "0" : value;
				},
				styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
					return "";
				}
			}
		];

// 실제로 #grid_wrap에 그리드 생성
		auiGridMidLeft = AUIGrid.create("#auiGridMidLeft", columnLayout, gridPros);
		// 그리드 갱신
		AUIGrid.setGridData(auiGridMidLeft, ${arrList});
	}

	// 전체랭킹 그리드
	function createAUIGridMidRight() {
		var gridPros = {
			showRowNumColumn : true,
			rowIdField : "_$uid",
			editable : false,
		};

		var columnLayout = [
			{
				headerText : "순위",
				dataField : "rank",
				width : "20%",
				style : "aui-center",
				editable : false,
			},
			{
				headerText : "부서",
				dataField : "org_name",
				width : "40%",
				style : "aui-center",
				editable : false,
			},
			{
				headerText : "사원",
				dataField : "mem_name",
				width : "40%",
				style : "aui-center",
				editable : false,
			},
		];

		// 실제로 #grid_wrap에 그리드 생성
		auiGridMidRight = AUIGrid.create("#auiGridMidRight", columnLayout, gridPros);
		// 그리드 갱신
		AUIGrid.setGridData(auiGridMidRight, ${rankList});
	}

	// 업무내용 집계표 전체보기 버튼
	function fnWorkContentAllBtn() {
		// [서비스 > 서비스업무평가-개인] 메뉴 팝업으로 호출
		var params = {};
		var popupOption = "";
		$M.goNextPage('/serv/serv0513', $M.toGetParam(params), {popupStatus: popupOption});

	}

	// 전체 랭킹 전체보기 버튼
	function fnTotalRankAllBtn() {
		// [개인별 랭킹] 팝업 호출
		var sStartYearMon = "${s_start_dt}"
		var sEndYearMon = "${s_end_dt}";

		var params = {
			"s_start_year_mon" : sStartYearMon.substring(0,6),
			"s_end_year_mon" : sEndYearMon.substring(0,6),
			"s_inout_yn" : $M.getValue("s_inout_yn")
		};
		var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=440, left=0, top=0";
		$M.goNextPage('/serv/serv0501p13', $M.toGetParam(params), {popupStatus: popupOption});
	}

	function fnSetOrgCode(){
		var params = {
			"s_center_code" : $M.getValue("s_center_code")
		};
		$M.goNextPage(this_page, $M.toGetParam(params), {method : 'get'});
	}

</script>
<div class="row">
	<div class="col-8">
		<div class="title-wrap mt10">
			<h4>당해년도
				<select style="height: 25px;" name="s_center_code" id="s_center_code" onchange="fnSetOrgCode();">
					<option value="">- 전체 -</option>
					<c:forEach var="list" items="${codeMap['WAREHOUSE']}">
						<c:if test="${list.code_value ne '5010' and list.code_value ne '6000' and list.code_v2 eq 'Y'}">
							<option value="${list.code_value}" <c:if test="${list.code_value eq s_center_code}">selected</c:if> >${list.code_name}</option>
						</c:if>
					</c:forEach>

				</select>
				업무내용 집계표</h4>
			<button type="button" class="btn btn-default" onclick="javascript:fnWorkContentAllBtn()"><i class="material-iconskeyboard_arrow_right text-default"></i>전체보기</button>
		</div>
		<div id="auiGridMidLeft" style="margin-top: 5px; height: 250px;"></div>
	</div>
	<div class="col-4">
		<div class="title-wrap mt10">
			<h4>전체 랭킹</h4>
			<button type="button" class="btn btn-default" onclick="javascript:fnTotalRankAllBtn()"><i class="material-iconskeyboard_arrow_right text-default"></i>전체보기</button>
		</div>
		<div id="auiGridMidRight" style="margin-top: 5px; height: 250px;"></div>
	</div>
</div>
