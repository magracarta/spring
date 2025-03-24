<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 고품관리 > 고품관리 > null > 제출현황
-- 작성자 : 성현우
-- 최초 작성일 : 2021-04-09 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGrid;
// 		var dateListJson = ${dateListJson};
		$(document).ready(function () {
			// AUIGrid 생성
			createAUIGrid();
			goSearch();
		});

		// 조회
		function goSearch() {
			var frm = document.main_form;
			//validationcheck
			if ($M.validation(frm,
					{field: ["s_year"]}) == false) {
				return;
			}

			frm = $M.toValueForm(document.main_form);

			$M.goNextPageAjax(this_page + "/search", frm, {method: 'GET'},
					function (result) {
						if (result.success) {
							console.log(result.list);
// 							AUIGrid.clearGridData(auiGrid);
// 							AUIGrid.setGridData(auiGrid, result.list);
							
							fnResult(result);
						}
					}
			);
		}
		
		function fnResult(result) {
			var list = result.list;
			
			var columnLayout = [
				{
					headerText: "센터",
					dataField: "code_name",
					width: "70",
					minWidth: "60",
				}
			];
			
			var dateList = result.dateListJson;
			
			var columnObjArr = [];
			
			for(var i=0; i<dateList.length; i++) {
				var headerTextName = dateList[i].mon + "월";
				var dataFieldName = "a_" + dateList[i].year_mon + "_cnt";

				var columnObj = {
					headerText: headerTextName,
					dataField: dataFieldName,
					// addColumn 할때 width 그냥 값으로하면 오류. %로 하거나 해야함.
// 					width: "50",
// 					minWidth: "40",
					style: "aui-center",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						return value == "0" ? "" : "●";
					}
				}
				
// 				var columnObj = {
// 					headerText : headerTextName,
// 					dataField : dataFieldName,
// 				};

				columnObjArr.push(columnObj);
			}
			
			AUIGrid.changeColumnLayout(auiGrid, columnLayout);
			AUIGrid.addColumn(auiGrid, columnObjArr, 1);
			
			AUIGrid.setGridData(auiGrid, result.list);
		}

		// 닫기
		function fnClose() {
			window.close();
		}

		function createAUIGrid() {
			var gridPros = {
				rowIdField: "_$uid",
				showRowNumColumn: false,
			};

			var columnLayout = [
// 				{
// 					headerText: "센터",
// 					dataField: "code_name",
// 					width: "70",
// 					minWidth: "60",
// 				}
				
				// push
			];

// 			for(var i=0; i<dateListJson.length; i++) {
// 				var headerTextName = dateListJson[i].mon + "월";
// 				var dataFieldName = "a_" + dateListJson[i].year_mon + "_cnt";

// 				var centerCntObj = {
// 					headerText: headerTextName,
// 					dataField: dataFieldName,
// 					width: "50",
// 					minWidth: "40",
// 					style: "aui-center",
// 					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
// 						return value == "0" ? "" : "●";
// 					}
// 				}

// 				columnLayout.push(centerCntObj);
// 			}

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
		}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<!-- 팝업 -->
	<div class="popup-wrap width-100per">
		<!-- 타이틀영역 -->
		<div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
		</div>
		<!-- /타이틀영역 -->
		<div class="content-wrap">
			<!-- 검색조건 -->
			<div class="search-wrap mt5">
				<table class="table">
					<colgroup>
						<col width="65px">
						<col width="90px">
						<col width="">
					</colgroup>
					<tbody>
					<tr>
						<th>조회년도</th>
						<td>
							<select class="form-control" id="s_year" name="s_year" alt="조회년도">
								<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
									<c:set var="year_option" value="${inputParam.s_current_year - i + 2000}"/>
									<option value="${year_option}" <c:if test="${year_option eq inputParam.s_year}">selected</c:if>>${year_option}년</option>
								</c:forEach>
							</select>
						</td>
						<td class="">
							<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
						</td>
					</tr>
					</tbody>
				</table>
			</div>
			<!-- /검색조건 -->
			<div id="auiGrid" style="margin-top: 5px; height: 450px;"></div>
			<div class="btn-group mt10">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
		</div>
	</div>
	<!-- /팝업 -->
</form>
</body>
</html>