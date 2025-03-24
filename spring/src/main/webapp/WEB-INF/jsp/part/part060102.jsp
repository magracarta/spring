<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 부품통계 > 부품판매현황-기간별 > null > null
-- 작성자 : 손광진
-- 최초 작성일 : 2020-09-08 17:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function() {
			// 그리드 생성
			createAUIGrid();	
			goSearch();
		});
		
		function goSearch() {
			var param = {
				s_inout_dt : $M.getValue("s_inout_dt"),
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
		
		//엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "부품판매현황-기간별(년간)", "");
		}
		
		// 그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				editable : false,
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
				    headerText: "항목",
				    dataField: "col",
					width : "280",
					minWidth : "280",
					style : "aui-left"
				},
				{
				    headerText: "12월",
				    dataField: "month_12",
					dataType : "numeric",
					formatString : "#,##0",
					width : "90",
					minWidth : "90",
					style : "aui-right"
				},
				{
				    headerText: "01월",
				    dataField: "month_01",
					dataType : "numeric",
					formatString : "#,##0",
					width : "90",
					minWidth : "90",
					style : "aui-right"
				},
				{
				    headerText: "02월",
				    dataField: "month_02",
					dataType : "numeric",
					formatString : "#,##0",
					width : "90",
					minWidth : "90",
					style : "aui-right"
				},
				{
				    headerText: "03월",
				    dataField: "month_03",
					dataType : "numeric",
					formatString : "#,##0",
					width : "90",
					minWidth : "90",
					style : "aui-right"
				},
				{
				    headerText: "04월",
				    dataField: "month_04",
					dataType : "numeric",
					formatString : "#,##0",
					width : "90",
					minWidth : "90",
					style : "aui-right"
				},
				{
				    headerText: "05월",
				    dataField: "month_05",
					dataType : "numeric",
					formatString : "#,##0",
					width : "90",
					minWidth : "90",
					style : "aui-right"
				},
				{
				    headerText: "06월",
				    dataField: "month_06",
					dataType : "numeric",
					formatString : "#,##0",
					width : "90",
					minWidth : "90",
					style : "aui-right"
				},
				{
				    headerText: "07월",
				    dataField: "month_07",
					dataType : "numeric",
					formatString : "#,##0",
					width : "90",
					minWidth : "90",
					style : "aui-right"
				},
				{
				    headerText: "08월",
				    dataField: "month_08",
					dataType : "numeric",
					formatString : "#,##0",
					width : "90",
					minWidth : "90",
					style : "aui-right"
				},
				{
				    headerText: "09월",
				    dataField: "month_09",
					dataType : "numeric",
					formatString : "#,##0",
					width : "90",
					minWidth : "90",
					style : "aui-right"
				},
				{
				    headerText: "10월",
				    dataField: "month_10",
					dataType : "numeric",
					formatString : "#,##0",
					width : "90",
					minWidth : "90",
					style : "aui-right"
				},
				{
				    headerText: "11월",
				    dataField: "month_11",
					dataType : "numeric",
					formatString : "#,##0",
					width : "90",
					minWidth : "90",
					style : "aui-right"
				},
				{
				    headerText: "합계",
				    dataField: "month_total",
					dataType : "numeric",
					width : "95",
					minWidth : "95",
					formatString : "#,##0",
				    expFunction : function(  rowIndex, columnIndex, item, dataField ) { 
				    	return Number(item.month_12 + item.month_01 + item.month_02 + item.month_03 + item.month_04
				    			 + item.month_05 + item.month_06 + item.month_07 + item.month_08 + item.month_09
				    			 + item.month_10 + item.month_11); 
				    },
					style : "aui-right"
				},
				{
				    headerText: "전년대비누계",
				    dataField: "last_year_total",
					dataType : "numeric",
					width : "95",
					minWidth : "95",
					formatString : "#,##0",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
			            return value == "" || value == null ? "0" : value;
					},
					style : "aui-right"
				},
			];

	
			// 그리드 출력
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
		}
		
		// 기준정보 재생성
        function goChangeSave() {
            var param = {
                "s_start_dt": "${inputParam.s_start_dt}",
                "s_end_dt": "${inputParam.s_end_dt}",
            };
            $M.goNextPageAjax("/part/part0601/change/save", $M.toGetParam(param), {method: "POST"},
                function (result) {
                    if (result.success) {
                        alert("기준정보 재생성을 완료하였습니다.");
                        window.location.reload();
                    }
                }
            );
        }
		
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<div class="layout-box">
<!-- contents 전체 영역 -->
		<div class="content-wrap">
<!-- 검색영역 -->		
					<div class="search-wrap mt10">
						<table class="table">
							<colgroup>
								<col width="70px">
								<col width="80px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>								
									<th>조회기간</th>
									<td>
										<select class="form-control width120px" name="s_inout_dt" id="s_inout_dt">
												<c:forEach var="i" begin="2000" end="${inputParam.s_current_year+5}" step="1">
													<option value="${i}" <c:if test="${i eq inputParam.s_current_year}">selected="selected"</c:if>>${i}년</option>
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
<!-- /검색영역 -->
<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<h4>조회결과</h4>
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
					<div id="auiGrid" style="margin-top: 5px; height: 445px;"></div>
				</div>						
			</div>		
<!-- /contents 전체 영역 -->	
</form>
</body>
</html>