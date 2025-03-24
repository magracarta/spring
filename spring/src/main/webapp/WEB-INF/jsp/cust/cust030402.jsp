<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 거래현황 > 임의비용처리-출하 > null > 원가 반영
-- 작성자 : 정재호
-- 최초 작성일 : 2022-10-25 10:00:00
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		$(document).ready(function() {
			createAUIGrid();
		});

		//조회
		function goSearch() {
			console.log("cust030402 goSearch");
			var param = {
				"s_sort_key" : "machine_doc_no",
				"s_sort_method" : "asc",
				"s_cost_proc_yn" : $M.getValue("s_cost_proc_yn"),
				"s_cost_item_cd" : $M.getValue("s_cost_item_cd"),
				"s_start_dt" : $M.getValue("s_start_dt"),
				"s_end_dt" : $M.getValue("s_end_dt"),
				"s_masking_yn" : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N"
			};
			_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
			$M.goNextPageAjax('/cust/cust030401' + '/search', $M.toGetParam(param), {method : 'get'},
					function(result) {
						if(result.success) {
							AUIGrid.setGridData(auiGrid, result.list);
							$("#total_cnt").html(result.total_cnt);
						};
					}
			);
		}

		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "row_id",
				showStateColumn : false,
				// No. 제거
				showRowNumColumn: true,
				editable : false,
				headerHeight : 40,
				rowStyleFunction : function(rowIndex, item) {
					if(item.cost_proc_yn == "Y") {
						// 처리일 때
						return "aui-row-part-sale-end";
					}
					return "";
				}
			};
			var columnLayout = [
				{
					headerText : "관리번호",
					dataField : "machine_doc_no",
					style : "aui-center aui-popup",
					width : "70",
					minWidth : "65",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						var ret = "";
						if (value != null && value != "") {
							ret = value.split("-");
							ret = ret[0]+"-"+ret[1];
							ret = ret.substr(4, ret.length);
						}
						return ret;
					},
				},
				{
					headerText : "출하일자",
					dataField : "out_dt",
					width : "70",
					minWidth : "70",
					style : "aui-center",
					dataType : "date",
					formatString : "yy-mm-dd"
				},
				{
					headerText : "판매자",
					dataField : "reg_mem_name",
					width : "60",
					minWidth : "60",
					style : "aui-center",
				},
				{
					headerText : "장비명",
					dataField : "machine_name",
					width : "100",
					minWidth : "90",
					style : "aui-left",
				},
				{
					headerText : "차대번호",
					dataField : "body_no",
					width : "150",
					minWidth : "150",
					style : "aui-center",
				},
				{
					headerText : "차주명",
					dataField : "cust_name",
					width : "110",
					minWidth : "110",
					style : "aui-center"
				},
				{
					headerText : "연락처",
					dataField : "hp_no",
					width : "110",
					minWidth : "110",
					style : "aui-center"
				},
				{
					headerText : "원가반영 명",
					dataField : "cost_apply_name",
					width : "80",
					minWidth : "70",
					style : "aui-center"
				},
				{
					dataField : "cost_item_cd",
					visible : false
				},
				{
					headerText : "금액",
					dataField : "amt",
					width : "95",
					minWidth : "90",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right"
				},
				{
					headerText : "비고",
					dataField : "cost_name",
					width : "80",
					minWidth : "70",
					style : "aui-center"
				},
				{
					headerText : "처리<br\>구분",
					dataField : "cost_proc_yn",
					width : "45",
					minWidth : "45",
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						return item["cost_proc_yn"] == "Y" ? "처리" : "미결";
					}
				},
				{
					headerText : "처리일자",
					dataField : "cost_proc_dt",
					width : "70",
					minWidth : "70",
					style : "aui-center",
					dataType : "date",
					formatString : "yy-mm-dd"
				},
				{
					headerText : "처리자",
					dataField : "cost_proc_mem_name",
					width : "60",
					minWidth : "60",
					style : "aui-center"
				}
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
			// 관리번호 클릭시 -> 계약 품의서 상세 팝업 호출
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == "machine_doc_no") {
					var params = {
						"machine_doc_no" : event.item["machine_doc_no"]
					};
					var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1300, height=750, left=0, top=0";
					$M.goNextPage('/sale/sale0101p01', $M.toGetParam(params), {popupStatus : popupOption});
				}
			});
		}

		function fnExcelDownload() {
			// 엑셀 내보내기 속성
			var exportProps = {
			};
			fnExportExcel(auiGrid, "임의비용처리-출하_원가반영", exportProps);
		}

		function fnChangeCostProcYn(costProcYn) {
			if(costProcYn == "Y") {
				$("#date_name").text("처리일자");
			} else {
				$("#date_name").text("출하일자");
			}
		}

	</script>
</head>
<body style="background : #fff">
<form id="main_form" name="main_form">
	<div class="layout-box">
		<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
				<div class="contents">
					<!-- 기본 -->
					<div class="search-wrap mt10">
						<table class="table">
							<colgroup>
								<col width="70px">
								<col width="100px">
								<col width="75px">
								<col width="260px">
								<col width="">
							</colgroup>
							<tbody>
							<tr>
								<th>처리구분</th>
								<td>
									<select class="form-control" id="s_cost_proc_yn" name="s_cost_proc_yn" onchange="javascript:fnChangeCostProcYn(this.value);">
										<option value="">- 전체 -</option>
										<option value="Y">처리</option>
										<option value="N" selected="selected">미결</option>
									</select>
								</td>
								<th id="date_name">출하일자</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="" value="${searchDtMap.s_start_dt}">
											</div>
										</div>
										<div class="col-auto">~</div>
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="" value="${searchDtMap.s_end_dt}">
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
								<td class="">
									<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
								</td>
							</tr>
							</tbody>
						</table>
					</div>
					<!-- /기본 -->
					<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<h4>지급처리내역</h4>
						<div class="btn-group">
							<div class="right">
								<c:if test="${page.add.POS_UNMASKING eq 'Y'}">
									<div class="form-check form-check-inline">
										<input  class="form-check-input"  type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" >
										<label  class="form-check-input"  for="s_masking_yn" >마스킹 적용</label>
									</div>
								</c:if>
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
							</div>
						</div>
					</div>
					<!-- /그리드 타이틀, 컨트롤 영역 -->
					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
					<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">0</strong>건
						</div>
					</div>
					<!-- /그리드 서머리, 컨트롤 영역 -->
				</div>
			</div>
		</div>
		<!-- /contents 전체 영역 -->
	</div>
</form>
</body>
</html>