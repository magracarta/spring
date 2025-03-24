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
				s_year : $M.getValue("s_year"),
				e_year : $M.getValue("e_year")
			};

			$M.goNextPage('/acnt/acnt0205p01', $M.toGetParam(param), {popupStatus : popupOption});
		}

		// 엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "월별손익계산서");
		}

		// 날짜 Setting
		function fnSetYearMon(year, mon) {
			return year + (mon.length == 1 ? "0" + mon : mon);
		}

		// 조회
		function goSearch() {
			var param = {
				s_pnl_mon: fnSetYearMon($M.getValue("s_year"), $M.getValue("s_mon")),
				e_pnl_mon: fnSetYearMon($M.getValue("e_year"), $M.getValue("e_mon"))
			};
			var regex = /a_(\d{2})(\d{2})(\d{2})_sum/;

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: "get"},
					function (result) {
						if (result.success) {
							dateInfoMap = result.dateInfoMap;

							// fnAUIGridInit();
							var dates = Object.values(result.list);
							if ( !dates.length) {
								alert("조회된 항목이 없습니다!");
							}
							destroyGrid();
							var cols = [];
							for ( var k in dates[0] ) {
								var tmp = regex.exec(k);
								if ( tmp != null){
									cols.push([tmp[1], tmp[2], tmp[3]]);// 날짜 컬럼
								}
							}

							createAUIGrid(cols);
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

		// 천 단위
		function fnSetNumberFormatToggle() {
			if (numberFormat == "all") {
				numberFormat = "thousand";
			} else {
				numberFormat = "all"
			}

			AUIGrid.resize(auiGrid);
		}

		function createAUIGrid( cols ) {
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
					headerText: "합계",
					dataField: "a_sum",
					width: "120",
					minWidth: "130",
					style: "aui-center",
					editable: false,
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						return value == 0 || value == null ? "" : (numberFormat == "all" ? $M.setComma(value) : $M.setComma(Math.floor($M.toNum(value)/1000)));
					}
				},
			];

			for ( var i in cols){
				var name = cols[i];
				columnLayout.push({
					headerText: name[1] + "-" + name[2],
					dataField: "a_" + name.join("") + "_sum",
					editable: false,
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						return value == 0 || value == null ? "" : (numberFormat == "all" ? $M.setComma(value) : $M.setComma(Math.floor($M.toNum(value)/1000)));
					}
				});
			}
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
								<col width="20px">
								<col width="130px">
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
													<option value="${year_option}" <c:if test="${year_option eq inputParam.s_year - 1}">selected</c:if>>${year_option}년</option>
												</c:forEach>
											</select>
										</div>
										<div class="col-auto">
											<select class="form-control" id="s_mon" name="s_mon">
												<c:forEach var="i" begin="1" end="12" step="1">
													<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i eq inputParam.s_mon + 1}">selected</c:if>>${i}월</option>
												</c:forEach>
											</select>
										</div>
									</div>
								</td>
								<td>
									<div > ~ </div>
								</td>
								<td>
									<%-- 시작월년 동일하게 셋팅 --%>
									<div class="form-row inline-pd">
										<div class="col-auto">
											<select class="form-control" id="e_year" name="e_year">
												<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
													<c:set var="year_option" value="${inputParam.s_current_year - i + 2000}"/>
													<option value="${year_option}" <c:if test="${year_option eq inputParam.s_year}">selected</c:if>>${year_option}년</option>
												</c:forEach>
											</select>
										</div>
										<div class="col-auto">
											<select class="form-control" id="e_mon" name="e_mon">
												<c:forEach var="i" begin="1" end="12" step="1">
													<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i eq inputParam.s_mon}">selected</c:if>>${i}월</option>
												</c:forEach>
											</select>
										</div>
									</div>
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
<%--						<div class="left">--%>
<%--							총 <strong class="text-primary" id="total_cnt">0</strong>건--%>
<%--						</div>--%>
<%--						<div class="right">--%>
<%--							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>--%>
<%--						</div>--%>
					</div>
				</div>
			</div>
		</div>
		<!-- /contents 전체 영역 -->
	</div>
</form>
</body>
</html>