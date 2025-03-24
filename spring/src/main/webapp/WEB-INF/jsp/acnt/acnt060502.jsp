<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 인사 > 고과평가관리 > 센터고과평가
-- 작성자 : jsk
-- 최초 작성일 : 2024-06-12 11:18:33
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var auiGrid;

		$(document).ready(function() {
			createAUIGrid();
			goSearch();
		});

		//조회
		function goSearch() {
			var param = {
				"s_year": $M.getValue("s_year"),
				"s_org_code": $M.getValue("s_org_code")
			};
			$M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method: "GET"},
					function (result) {
						if (result.success) {
							$("#total_cnt").html(result.total_cnt);
							AUIGrid.setGridData(auiGrid, result.list);
						}
					}
			);
		}

		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn: true,
				editable : false
			};
			var columnLayout = [
				{
					dataField : "eval_year",
					visible : false
				},
				{
					dataField : "org_code",
					visible : false
				},
				{
					headerText : "부서",
					dataField : "org_name",
					width : "12%",
					minWidth : "70",
					style : "aui-center",
				},
				{
					headerText : "분기별 평가결과(최초)",
					children: [
						{
							headerText : "1/4",
							dataField : "q1_eval_point",
							width : "8%",
							style : "aui-center",
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if (${detail_pos_yn eq 'Y'}) {
									return "aui-popup"
								}
								return null;
							},
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value > 100? 100 : value;
							}
						},
						{
							headerText : "2/4",
							dataField : "q2_eval_point",
							width : "8%",
							style : "aui-center",
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if (${detail_pos_yn eq 'Y'}) {
									return "aui-popup"
								}
								return null;
							},
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value > 100? 100 : value;
							}
						},
						{
							headerText : "3/4",
							dataField : "q3_eval_point",
							width : "8%",
							style : "aui-center",
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if (${detail_pos_yn eq 'Y'}) {
									return "aui-popup"
								}
								return null;
							},
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value > 100? 100 : value;
							}
						},
						{
							headerText : "4/4",
							dataField : "q4_eval_point",
							width : "8%",
							style : "aui-center",
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if (${detail_pos_yn eq 'Y'}) {
									return "aui-popup"
								}
								return null;
							},
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value > 100? 100 : value;
							}
						}
					]
				},
				{
					headerText : "분기별 평가(조정)",
					children: [
						{
							headerText : "1/4",
							dataField : "q1_eval_point_adjust",
							width : "8%",
							style : "aui-center",
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if (${detail_pos_yn eq 'Y'}) {
									return "aui-popup"
								}
								return null;
							}
						},
						{
							headerText : "2/4",
							dataField : "q2_eval_point_adjust",
							width : "8%",
							style : "aui-center",
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if (${detail_pos_yn eq 'Y'}) {
									return "aui-popup"
								}
								return null;
							}
						},
						{
							headerText : "3/4",
							dataField : "q3_eval_point_adjust",
							width : "8%",
							style : "aui-center",
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if (${detail_pos_yn eq 'Y'}) {
									return "aui-popup"
								}
								return null;
							}
						},
						{
							headerText : "4/4",
							dataField : "q4_eval_point_adjust",
							width : "8%",
							style : "aui-center",
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if (${detail_pos_yn eq 'Y'}) {
									return "aui-popup"
								}
								return null;
							}
						},
						{
							headerText : "합계",
							dataField : "eval_point_adjust_sum",
							width : "8%",
							style : "aui-center"
						}
					]
				}
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);

			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField.endsWith("_point")) {
					if (event.value !== "") {
						var params = {
							"eval_year": event.item["eval_year"],
							"eval_org_code": event.item["org_code"],
							"eval_qtr" : event.headerText.charAt(0)
						};
						$M.goNextPage('/acnt/acnt060502p01', $M.toGetParam(params), {popupStatus : ""});
					}
				}
				if(event.dataField.endsWith("_adjust")) {
					if (event.value !== "") {
						var params = {
							"s_year": event.item["eval_year"],
							"s_org_code": event.item["org_code"]
						};
						$M.goNextPage('/acnt/acnt060502p02', $M.toGetParam(params), {popupStatus: ""});
					}
				}
			});

			$("#auiGrid").resize();
		}

		// 평가비율설정 팝업
		function goRatePopup() {
			$M.goNextPage('/acnt/acnt060502p03', "", {popupStatus : ""});
		}

		// 분기별 평가(조정) 팝업
		function goPopupQuarterEval() {
			var params = {
				"s_year": $M.getValue("s_year"),
				"s_org_code": $M.getValue("s_org_code")
			};
			$M.goNextPage('/acnt/acnt060502p02', $M.toGetParam(params), {popupStatus : ""});
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
					<div class="search-wrap mt10">
						<table class="table">
							<colgroup>
								<col width="60px">
								<col width="80px">
								<col width="50px">
								<col width="120px">
								<col width="">
							</colgroup>
							<tbody>
							<tr>
								<th>조회년도</th>
								<td>
									<select class="form-control" id="s_year" name="s_year" required="required" alt="조회년도">
										<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
											<c:set var="year_option" value="${inputParam.s_current_year - i + 2000}"/>
											<option value="${year_option}" <c:if test="${year_option eq inputParam.s_current_year}">selected</c:if>>${year_option}년</option>
										</c:forEach>
									</select>
								</td>
								<th>부서</th>
								<td>
									<select class="form-control" id="s_org_code" name="s_org_code">
										<option value="">- 전체 -</option>
										<c:forEach var="item" items="${org_center_list}">
											<option value="${item.org_code}">${item.org_name}</option>
										</c:forEach>
									</select>
								</td>
								<td>
									<button type="button" class="btn btn-important" style="width: 50px;" onclick="goSearch();">조회</button>
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
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
					<!-- /조회결과 -->
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