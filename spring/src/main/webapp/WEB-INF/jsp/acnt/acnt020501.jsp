<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 장부 > 월별손익계산서 > null > null
-- 작성자 : 류성진
-- 최초 작성일 : 2022-08-04 05:24
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGrid;
		var dateInfoMap;
		var numberFormat = "thousand";
		$(document).ready(function () {
			fnInit();
			createAUIGrid();

			goSearch();
		});

		function fnInit() {
			dateInfoMap = ${dateInfoMap};
		}


		// 엑셀업로드
		function goExcelUpload() {
			var popupOption = "";
			var param = {
				s_year : $M.getValue("s_year")
			};

			$M.goNextPage('/acnt/acnt0205p01', $M.toGetParam(param), {popupStatus : popupOption});
		}

		// 엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "당월손익계산서");
		}

		// 날짜 Setting
		function fnSetYearMon(year, mon) {
			return year + (mon.length == 1 ? "0" + mon : mon);
		}

		// 조회
		function goSearch() {
			var param = {
				s_pnl_mon: fnSetYearMon($M.getValue("s_year"), $M.getValue("s_mon"))
			};

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: "get"},
					function (result) {
						if (result.success) {
							dateInfoMap = result.dateInfoMap;

							fnAUIGridInit();
							$("#total_cnt").html(result.total_cnt);
							AUIGrid.setGridData(auiGrid, result.list);
						}
					}
			);
		}

		// 그리드 재생성
		function fnAUIGridInit() {
			destroyGrid();
			createAUIGrid();
		}

		// 그리드 초기화
		function destroyGrid() {
			AUIGrid.destroy("#auiGrid");
			auiGrid = null;
		}

		// 저장
		function goSave() {
			if (fnChangeGridDataCnt(auiGrid) == 0) {
				alert("변경된 데이터가 없습니다.");
				return false;
			}

			var frm = $M.toValueForm(document.main_form);
			var columns = ["pnl_mon", "pnl_item_cd", "remark"];
			var gridFrm = fnChangeGridDataToForm(auiGrid, '', columns);
			$M.copyForm(gridFrm, frm);

			$M.goNextPageAjaxSave(this_page + "/save", gridFrm, {method: "POST"},
					function (result) {
						if (result.success) {
							alert("저장이 완료되었습니다.");
							goSearch();
						}
					}
			);
		}

		// 천 단위
		function fnSetNumberFormatToggle() {
			if (numberFormat == "all") {
				numberFormat = "thousand";
			} else {
				numberFormat = "all"
			}

			AUIGrid.resize(auiGrid);
		}

		function createAUIGrid() {
			var gridPros = {
				// Row번호 표시 여부
				rowIdField: "_$uid",
				showRowNumColum: true,
				showStateColumn: true,
				editable: true,
				rowStyleFunction : function(rowIndex, item) {
					if(item.pnl_item_name.indexOf(".") != -1) {
						return "aui-as-center-row-style";
					} else if(item.pnl_item_name.indexOf("상품매출원가_") != -1) {
						return "aui-as-tot-row-style";
					}
					return "";
				}
			};

			var columnLayout = [
				{
					headerText: "과목",
					dataField: "pnl_item_name",
					width: "160",
					minWidth: "150",
					style: "aui-center",
					editable: false
				},
				{
					headerText: dateInfoMap.s_last_year + "년 " + dateInfoMap.s_last_mon + "월 ~ " + dateInfoMap.s_year + "년 " + dateInfoMap.s_mon + "월",
					children: [
						{
							headerText: dateInfoMap.s_year + "년",
							dataField: "a_tot_pnl_amt",
							width: "110",
							minWidth: "100",
							style: "aui-right",
							editable: false,
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value == 0 || value == null ? "" : (numberFormat == "all" ? $M.setComma(value) : $M.setComma(Math.floor($M.toNum(value)/1000)));
							}
						},
						{
							headerText: dateInfoMap.real_last_year + "년",
							dataField: "b_tot_pnl_amt",
							width: "110",
							minWidth: "100",
							style: "aui-right",
							editable: false,
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value == 0 || value == null ? "" : (numberFormat == "all" ? $M.setComma(value) : $M.setComma(Math.floor($M.toNum(value)/1000)));
							}
						},
						{
							headerText: "증감액",
							dataField: "tot_in_de_amt",
							width: "110",
							minWidth: "100",
							style: "aui-right",
							editable: false,
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value == 0 || value == null ? "" : (numberFormat == "all" ? $M.setComma(value) : $M.setComma(Math.floor($M.toNum(value)/1000)));
							}
						},
						{
							headerText: "전년비(%)",
							dataField: "tot_year_on_year",
							width: "80",
							minWidth: "70",
							style: "aui-right",
							editable: false,
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value == 0 || value == null ? "" : Math.round(value*10)/10;
							}
						},
						{
							headerText: "비중(" + dateInfoMap.s_year.substr(2,4) + ")",
							dataField: "a_gravity",
							width: "60",
							minWidth: "30",
							style: "aui-right",
							editable: false,
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value == 0 || value == null ? "" : $M.setComma(value);
							}
						},
						{
							headerText: "비중(" + dateInfoMap.s_last_year.substr(2,4) + ")",
							dataField: "b_gravity",
							width: "60",
							minWidth: "30",
							style: "aui-right",
							editable: false,
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value == 0 || value == null ? "" : $M.setComma(value);
							}
						},
						{
							headerText: "비중(차)",
							dataField: "c_gravity",
							width: "60",
							minWidth: "50",
							style: "aui-right",
							editable: false,
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value == 0 || value == null ? "" : $M.setComma(value);
							}
						}
					]
				},
				{
					headerText: dateInfoMap.s_mon + "월",
					children: [
						{
							headerText: dateInfoMap.s_year + "년",
							dataField: "a_pnl_amt",
							width: "110",
							minWidth: "100",
							style: "aui-right",
							editable: false,
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value == 0 || value == null ? "" : (numberFormat == "all" ? $M.setComma(value) : $M.setComma(Math.floor($M.toNum(value)/1000)));
							}
						},
						{
							headerText: dateInfoMap.real_last_year + "년",
							dataField: "b_pnl_amt",
							width: "110",
							minWidth: "100",
							style: "aui-right",
							editable: false,
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value == 0 || value == null ? "" : (numberFormat == "all" ? $M.setComma(value) : $M.setComma(Math.floor($M.toNum(value)/1000)));
							}
						},
						{
							headerText: "증감액",
							dataField: "in_de_amt",
							width: "110",
							minWidth: "100",
							style: "aui-right",
							editable: false,
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value == 0 || value == null ? "" : (numberFormat == "all" ? $M.setComma(value) : $M.setComma(Math.floor($M.toNum(value)/1000)));
							}
						},
						{
							headerText: "전년비(%)",
							dataField: "year_on_year",
							width: "80",
							minWidth: "70",
							style: "aui-right",
							editable: false,
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value == 0 || value == null ? "" : $M.setComma(value);
							}
						}
					]
				},
				{
					headerText: "비고",
					dataField: "remark",
					width: "250",
					minWidth: "240",
					style: "aui-left aui-editable"
				},
				{
					headerText: "손익월",
					dataField: "pnl_mon",
					visible: false
				},
				{
					headerText: "손익항목코드",
					dataField: "pnl_item_cd",
					visible: false
				}
			];

			// 실제로 #grid_wrap에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
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
					<!-- 검색영역 -->
					<div class="search-wrap">
						<table class="table">
							<colgroup>
								<col width="60px">
								<col width="130px">
<%--								<col width="20px">--%>
<%--								<col width="130px">--%>
								<col width="">
							</colgroup>
							<tbody>
							<tr>
								<th>조회년월</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-auto">
											<select class="form-control" id="s_year" name="s_year">
												<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
													<c:set var="year_option" value="${inputParam.s_current_year - i + 2000}"/>
													<option value="${year_option}" <c:if test="${year_option eq inputParam.s_year}">selected</c:if>>${year_option}년</option>
												</c:forEach>
											</select>
										</div>
										<div class="col-auto">
											<select class="form-control" id="s_mon" name="s_mon">
												<c:forEach var="i" begin="1" end="12" step="1">
													<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i eq inputParam.s_mon}">selected</c:if>>${i}월</option>
												</c:forEach>
											</select>
										</div>
									</div>
								</td>
<%--								<td>--%>
<%--									<div > ~ </div>--%>
<%--								</td>--%>
<%--								<td>--%>
<%--									<div class="form-row inline-pd">--%>
<%--										<div class="col-auto">--%>
<%--											<select class="form-control" id="e_year" name="e_year">--%>
<%--												<c:forEach var="i" begin="2000" end="${inputParam.e_current_year}" step="1">--%>
<%--													<c:set var="year_option" value="${inputParam.e_current_year - i + 2000}"/>--%>
<%--													<option value="${year_option}" <c:if test="${year_option eq inputParam.e_year}">selected</c:if>>${year_option}년</option>--%>
<%--												</c:forEach>--%>
<%--											</select>--%>
<%--										</div>--%>
<%--										<div class="col-auto">--%>
<%--											<select class="form-control" id="e_mon" name="e_mon">--%>
<%--												<c:forEach var="i" begin="1" end="12" step="1">--%>
<%--													<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i eq inputParam.e_mon}">selected</c:if>>${i}월</option>--%>
<%--												</c:forEach>--%>
<%--											</select>--%>
<%--										</div>--%>
<%--									</div>--%>
<%--								</td>--%>
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
						<div class="btn-group">
							<div class="right">
								<label for="s_toggle_numberFormat" style="color:black;">
									<input type="checkbox" id="s_toggle_numberFormat" checked="checked" onclick="javascript:fnSetNumberFormatToggle(event)"><span>천</span> 단위
								</label>
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
					<!-- /조회결과 -->
					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
					<div class="btn-group mt5">
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">0</strong>건
						</div>
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
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