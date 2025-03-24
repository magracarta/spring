<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 서비스관리 > 서비스업무평가-센터 > MBO > null
-- 작성자 : 손광진
-- 최초 작성일 : 2020-04-08 11:43:29
-- [재호] Deprecated : serv050204 로 이관, 기존 정보는 남겨두기 위해 삭제 처리는 따로 안함
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGrid;
		var centerCd = [];
		$(document).ready(function () {
			createAUIGrid();
		});
		
		function goAdd() {
			var param = {};
			var poppupOption = "";
			$M.goNextPage('/serv/serv050202p02', $M.toGetParam(param), {popupStatus: poppupOption});
		}

		// 집계표 목록 조회
		function goSearch() {
			if ($M.validation(document.main_form) == false) {
				return;
			}

			var param = {
				s_year: $M.getValue("s_year"),
			};

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: 'get'},
					function (result) {
						if (result.success) {
							if (typeof result.list != "undefined") {
								AUIGrid.setGridData(auiGrid, result.list);

								$("#total_sales").text($M.setComma(result.total_sales));
								$("#total_profits").text($M.setComma(result.total_profits));
								$("#total_expenditure").text($M.setComma(result.total_expenditure));
								$("#last_net_profits").text($M.setComma(result.last_net_profits));
								$("#net_rate_of_return").text($M.setComma(result.net_rate_of_return));
							} else {
								alert("조회된 결과가 없습니다.");
								AUIGrid.clearGridData(auiGrid);
							}
						}
					}
			);
		}

		//엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, '서비스업무평가-센터-MBO');
		}

		// 기준정보 재생성
		function goChangeSave() {
			var param = {};
			$M.goNextPageAjax("/serv/serv0502/change/save", $M.toGetParam(param), {method: "POST"},
					function (result) {
						if (result.success) {
							alert("기준정보 재생성을 완료하였습니다.");
							window.location.reload();
						}
					}
			);
		}

		function goCenterAvgAmtPopup() {
			var param = {
				"s_year": $M.getValue("s_year"),
			}

			var poppupOption = "";
			$M.goNextPage('/serv/serv050202p01', $M.toGetParam(param), {popupStatus: poppupOption});
		}

		function createAUIGrid() {
			var gridPros = {
				editable: false,
				// rowIdField 설정
				rowIdField: "_$uid",
				showRowNumColumn: false,
				rowStyleFunction: function (rowIndex, item) {
					if (item.mbo_desc.indexOf("누계") != -1 || item.mbo_desc.indexOf("증감치") != -1
							|| item.mbo_desc.indexOf("수익율") != -1) {
						return "aui-grid-selection-row-satuday-bg"
					} else if (item.mbo_desc.indexOf("최종 순익") != -1 || item.mbo_desc.indexOf("순익율") != -1) {
						return "aui-grid-selection-row-sunday-bg"
					}

					return "";
				}
			};

			var columnLayout = [
				{
					headerText: "집계내역",
					dataField: "mbo_desc",
					width: "15%",
				},
				{
					headerText: "합계",
					dataField: "total",
					dataType: "numeric",
					formatString: "#,##0",
					style: "aui-right",
					width: "10%",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						return value == "0" ? "" : $M.setComma(value);
					}
				}
			];

			<c:forEach items="${centerList}" var="item">
			var amtDataField = "s_" + "${item[0]}" + "_mbo_amt";
			var perDataField = "s_" + "${item[0]}" + "_mbo_per";
			var obj = [
				{
					headerText: "${item[1]}",
					dataField: amtDataField,
					dataType: "numeric",
					formatString: "#,##0",
					width: "6%",
					style: "aui-right",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						return value == "0" ? "" : $M.setComma(value);
					}
				},
				{
					headerText: "실적지표",
					dataField: perDataField,
					dataType: "numeric",
					postfix: "%",
					formatString: "#,##0",
					width: "6%",
					style: "aui-center",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						var valueStr = "";
						if (value == "0" || value == "" || typeof value == "undefined") {
							valueStr = "";
						} else {
							valueStr = $M.setComma(value) + "%";
						}

						return valueStr;
					}
				}
			];

			centerCd.push(amtDataField);
			columnLayout = columnLayout.concat(obj);
			</c:forEach>

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
			<div class="">
				<div class="">
					<!-- 검색영역 -->
					<div class="search-wrap mt10">
						<table class="table">
							<colgroup>
								<col width="70px">
								<col width="90px">
								<col width="">
							</colgroup>
							<tbody>
							<tr>
								<th>조회년도</th>
								<td>
									<select class="form-control width120px" name="s_year" id="s_year">
										<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
											<option value="${i}" <c:if test="${i eq inputParam.s_current_year}">selected="selected"</c:if>>${i}년</option>
										</c:forEach>
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
					<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<h4>실적집계표</h4>
						<div class="btn-group">
							<div class="left" style="margin-left:50px;">
								<span style="color: #ff7f00;">※ 기준일시 : ${lastStandDateTime}</span>
							</div>
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
					<!-- /그리드 타이틀, 컨트롤 영역 -->
					<div id="auiGrid" style="margin-top: 5px; height: 490px; width:100%;"></div>

					<!-- 합계그룹 -->
					<div class="row inline-pd mt10">
						<div class="col" style="width: 20%;">
							<table class="table-border">
								<colgroup>
									<col width="40%">
									<col width="60%">
								</colgroup>
								<tbody>
								<tr>
									<th class="text-right th-sum">매출 총계</th>
									<td class="text-right td-gray">
										<span id="total_sales"></span>
									</td>
								</tr>
								</tbody>
							</table>
						</div>
						<div class="col" style="width: 20%;">
							<table class="table-border">
								<colgroup>
									<col width="40%">
									<col width="60%">
								</colgroup>
								<tbody>
								<tr>
									<th class="text-right th-sum">수익 총계</th>
									<td class="text-right td-gray">
										<span id="total_profits"></span>
									</td>
								</tr>
								</tbody>
							</table>
						</div>
						<div class="col" style="width: 20%;">
							<table class="table-border">
								<colgroup>
									<col width="40%">
									<col width="60%">
								</colgroup>
								<tbody>
								<tr>
									<th class="text-right th-sum">지출 총계</th>
									<td class="text-right td-gray">
										<span id="total_expenditure"></span>
									</td>
								</tr>
								</tbody>
							</table>
						</div>
						<div class="col" style="width: 20%;">
							<table class="table-border">
								<colgroup>
									<col width="40%">
									<col width="60%">
								</colgroup>
								<tbody>
								<tr>
									<th class="text-right th-sum">최종 순익</th>
									<td class="text-right">
										<span id="last_net_profits"></span>
									</td>
								</tr>
								</tbody>
							</table>
						</div>
						<div class="col" style="width: 20%;">
							<table class="table-border">
								<colgroup>
									<col width="40%">
									<col width="60%">
								</colgroup>
								<tbody>
								<tr>
									<th class="text-right th-sum">순익율</th>
									<td class="text-right">
										<span id="net_rate_of_return"></span>%
									</td>
								</tr>
								</tbody>
							</table>
						</div>
					</div>
					<!-- /합계그룹 -->

					<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
								<jsp:param name="pos" value="BOM_R"/>
							</jsp:include>
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