<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 부품통계 > 재고회전율 > null > null
-- 작성자 : 손광진
-- 최초 작성일 : 2020-10-23 17:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function() {
			// 그리드 생성
			createAUIGrid();		
		});
		
		// 부품이동처리 목록 조회
		function goSearch() {
			
			var param = {
				s_year  : $M.getValue("s_year"),
			};
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
					};
				}
			);
		}
		
		// 그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				editable : false,
				cellMergeRowSpan:  true,
				enableCellMerge : true,
				showFooter : true,
				footerPosition : "top"
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
				    headerText: "분류",
					children : [
						{
							headerText : "메이커",
							dataField : "maker_name",
							style : "aui-center",
							cellMerge : true,	
						}, 
						{
							headerText : "구분",
							dataField : "maker_sub_gubun",
							style : "aui-center",
						},
					]
				},
				{
				    headerText: "당해년도",
					children : [
						{
							dataField : "month01",
							headerText : "01월",
							style : "aui-right",
							dataType : "numeric",
							formatString : "#,##0",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								return item.maker_sub_gubun == "회전율" ? AUIGrid.formatNumber(value, "#,##0.00") : AUIGrid.formatNumber(value, "#,##0");
							},
							
						}, 
						{
							dataField : "month02",
							headerText : "02월",
							style : "aui-right",
							dataType : "numeric",
							formatString : "#,##0",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								return item.maker_sub_gubun == "회전율" ? AUIGrid.formatNumber(value, "#,##0.00") : AUIGrid.formatNumber(value, "#,##0");
							},
							
						}, 
						{
							dataField : "month03",
							headerText : "03월",
							style : "aui-right",
							dataType : "numeric",
							formatString : "#,##0",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								return item.maker_sub_gubun == "회전율" ? AUIGrid.formatNumber(value, "#,##0.00") : AUIGrid.formatNumber(value, "#,##0");
							},
							
						}, 
						{
							dataField : "month04",
							headerText : "04월",
							style : "aui-right",
							dataType : "numeric",
							formatString : "#,##0",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								return item.maker_sub_gubun == "회전율" ? AUIGrid.formatNumber(value, "#,##0.00") : AUIGrid.formatNumber(value, "#,##0");
							},
							
						}, 
						{
							dataField : "month05",
							headerText : "05월",
							style : "aui-right",
							dataType : "numeric",
							formatString : "#,##0",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								return item.maker_sub_gubun == "회전율" ? AUIGrid.formatNumber(value, "#,##0.00") : AUIGrid.formatNumber(value, "#,##0");
							},
							
						}, 
						{
							dataField : "month06",
							headerText : "06월",
							style : "aui-right",
							dataType : "numeric",
							formatString : "#,##0",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								return item.maker_sub_gubun == "회전율" ? AUIGrid.formatNumber(value, "#,##0.00") : AUIGrid.formatNumber(value, "#,##0");
							},
							
						}, 
						{
							dataField : "month07",
							headerText : "07월",
							style : "aui-right",
							dataType : "numeric",
							formatString : "#,##0",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								return item.maker_sub_gubun == "회전율" ? AUIGrid.formatNumber(value, "#,##0.00") : AUIGrid.formatNumber(value, "#,##0");
							},
						}, 
						{
							dataField : "month08",
							headerText : "08월",
							style : "aui-right",
							dataType : "numeric",
							formatString : "#,##0",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								return item.maker_sub_gubun == "회전율" ? AUIGrid.formatNumber(value, "#,##0.00") : AUIGrid.formatNumber(value, "#,##0");
							},
						}, 
						{
							dataField : "month09",
							headerText : "09월",
							style : "aui-right",
							dataType : "numeric",
							formatString : "#,##0",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								return item.maker_sub_gubun == "회전율" ? AUIGrid.formatNumber(value, "#,##0.00") : AUIGrid.formatNumber(value, "#,##0");
							},
						}, 
						{
							dataField : "month10",
							headerText : "10월",
							style : "aui-right",
							dataType : "numeric",
							formatString : "#,##0",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								return item.maker_sub_gubun == "회전율" ? AUIGrid.formatNumber(value, "#,##0.00") : AUIGrid.formatNumber(value, "#,##0");
							},
						}, 
						{
							dataField : "month11",
							headerText : "11월",
							style : "aui-right",
							dataType : "numeric",
							formatString : "#,##0",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								return item.maker_sub_gubun == "회전율" ? AUIGrid.formatNumber(value, "#,##0.00") : AUIGrid.formatNumber(value, "#,##0");
							},
						}, 
						{
							dataField : "month12",
							headerText : "12월",
							style : "aui-right",
							dataType : "numeric",
							formatString : "#,##0",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								return item.maker_sub_gubun == "회전율" ? AUIGrid.formatNumber(value, "#,##0.00") : AUIGrid.formatNumber(value, "#,##0");
							},
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
					colSpan : 2
				}, 
				{
					dataField : "month01",
					positionField : "month01",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "month02",
					positionField : "month02",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "month03",
					positionField : "month03",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "month04",
					positionField : "month04",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "month05",
					positionField : "month05",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "month06",
					positionField : "month06",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "month07",
					positionField : "month07",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "month08",
					positionField : "month08",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "month09",
					positionField : "month09",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "month10",
					positionField : "month10",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "month11",
					positionField : "month11",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "month12",
					positionField : "month12",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
			];


			// 그리드 출력
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setFooter(auiGrid, footerColumnLayout);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
		}
		
		
		//엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, '재고회전율');
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
						<table class="table table-fixed">
							<colgroup>
								<col width="60px">
								<col width="100px">					
								<col width="">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th>기준년월</th>
									<td>
										<div>
											<select class="form-control width120px" name="s_year" id="s_year">
												<c:forEach var="i" begin="2000" end="${inputParam.s_current_year+5}" step="1">
													<option value="${i}" <c:if test="${i eq inputParam.s_current_year}">selected="selected"</c:if>>${i}년</option>
												</c:forEach>
											</select>
										</div>
									</td>
									<td>
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
									</td>	
									<td class="text-right text-warning"><!-- ※  회전율 = (기준년 해달월의 직전 12개월)출고원가 총합의 12개월 평균값 / 재고 총합의 12개월 평균값 --></td>	
								</tr>										
							</tbody>
						</table>					
					</div>
<!-- /검색영역 -->
<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<h4>조회결과</h4>
						<div class="btn-group">
							<div class="right">
								<button type="button" class="btn btn-default" onclick="javascript:fnDownloadExcel();"><i class="icon-btn-excel inline-btn"></i>엑셀다운로드</button>
							</div>
						</div>
					</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->		
					<div style="margin-top: 5px; height: 555px;" id="auiGrid"></div>
				</div>
			</div>		
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
		</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>