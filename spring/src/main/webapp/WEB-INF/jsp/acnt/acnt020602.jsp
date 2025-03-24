<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 장부 > 자산현황 및 재무제표 > 재무상태표 > null
-- 작성자 : 황빛찬
-- 최초 작성일 : 2023-10-24 10:43:00
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGrid;
		var thisHeaderText;
		var beHeaderText;
		$(document).ready(function () {
			thisHeaderText = $M.toNum($M.getValue("s_year").substr(2, 3)) + 2;
			beHeaderText = $M.toNum($M.getValue("s_year").substr(2, 3)) + 1;

			createAUIGrid();
			goSearch();
		});

		// 날짜 Setting
		function fnSetYearMon(year, mon) {
			return year + (mon.length == 1 ? "0" + mon : mon);
		}

		function createAUIGrid() {
			var gridPros = {
				// Row번호 표시 여부
				rowIdField: "_$uid",
				showRowNumColum: true,
				showStateColumn: true,
				editable: false
			};

			var columnLayout = [
				{
					headerText : "과목",
					dataField : "finan_name",
					width : "200",
					minWidth : "100",
				},
				{
					headerText : "제 " + thisHeaderText + " (당)기",
					children : [
						{
							dataField : "this_1_amt",
							headerText : "금액",
							width : "150",
							minWidth : "150",
							dataType: "numeric",
							formatString: "#,##0",
							style : "aui-right",
						},
						{
							dataField : "this_2_amt",
							headerText : "금액",
							width : "150",
							minWidth : "150",
							dataType: "numeric",
							formatString: "#,##0",
							style : "aui-right",
						},
					]
				},
				{
					headerText : "제 " + beHeaderText + " (전)기",
					children : [
						{
							dataField : "be_1_amt",
							headerText : "금액",
							width : "150",
							minWidth : "150",
							dataType: "numeric",
							formatString: "#,##0",
							style : "aui-right",
						},
						{
							dataField : "be_2_amt",
							headerText : "금액",
							width : "150",
							minWidth : "150",
							dataType: "numeric",
							formatString: "#,##0",
							style : "aui-right",
						},
					]
				},
			];

			// 실제로 #grid_wrap에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
		}

		// 조회
		function goSearch(){
			var param = {
				"s_finan_mon" : fnSetYearMon($M.getValue("s_year"), $M.getValue("s_mon"))
			}

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), { method : "GET" }, function(result){
				if(result.success){
					thisHeaderText = $M.toNum($M.getValue("s_year").substr(2, 3)) + 2;
					beHeaderText = $M.toNum($M.getValue("s_year").substr(2, 3)) + 1;

					var changeColumnLayout = [
						{
							headerText : "과목",
							dataField : "finan_name",
							width : "200",
							minWidth : "100",
						},
						{
							headerText : "제 " + thisHeaderText + " (당)기",
							children : [
								{
									dataField : "this_1_amt",
									headerText : "금액",
									width : "150",
									minWidth : "150",
									dataType: "numeric",
									formatString: "#,##0",
									style : "aui-right",
								},
								{
									dataField : "this_2_amt",
									headerText : "금액",
									width : "150",
									minWidth : "150",
									dataType: "numeric",
									formatString: "#,##0",
									style : "aui-right",
								},
							]
						},
						{
							headerText : "제 " + beHeaderText + " (전)기",
							children : [
								{
									dataField : "be_1_amt",
									headerText : "금액",
									width : "150",
									minWidth : "150",
									dataType: "numeric",
									formatString: "#,##0",
									style : "aui-right",
								},
								{
									dataField : "be_2_amt",
									headerText : "금액",
									width : "150",
									minWidth : "150",
									dataType: "numeric",
									formatString: "#,##0",
									style : "aui-right",
								},
							]
						},
					];
					AUIGrid.changeColumnLayout(auiGrid, changeColumnLayout);

					AUIGrid.clearGridData(auiGrid);
					AUIGrid.setGridData(auiGrid,result.list);
				}
			});
		}

		// 엑셀업로드
		function goExcelUpload() {
			var popupOption = "";
			var param = {
				"s_year" : $M.getValue("s_year"),
				"s_mon" : $M.getValue("s_mon")
			};

			$M.goNextPage('/acnt/acnt0206p02', $M.toGetParam(param), {popupStatus : popupOption});
		}

		// 엑셀 다운로드
		function fnDownloadExcel() {
			var exportProps = {
				// 제외항목
			};
			fnExportExcel(auiGrid, "재무상태표", exportProps);
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
					<div class="search-wrap" style="margin-top: 10px;">
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
													<option value="${year_option}" <c:if test="${year_option eq s_start_year}">selected</c:if>>${year_option}년</option>
												</c:forEach>
											</select>
										</div>
										<div class="col-auto">
											<select class="form-control" id="s_mon" name="s_mon">
												<c:forEach var="i" begin="1" end="12" step="1">
													<option value="<c:if test="${i < 10}">0</c:if><c:out value="${i}" />" <c:if test="${i==s_start_mon}">selected</c:if>>${i}월</option>
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
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
					<!-- /조회결과 -->
					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
<%--					<div class="btn-group mt5">--%>
<%--						<div class="left">--%>
<%--							총 <strong class="text-primary" id="total_cnt">0</strong>건--%>
<%--						</div>--%>
<%--					</div>--%>
				</div>
			</div>
		</div>
		<!-- /contents 전체 영역 -->
	</div>
</form>
</body>
</html>