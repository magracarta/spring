<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 렌탈현황 > 렌탈매출현황 > 년도별 센터별 매출현황 > null
-- 작성자 : 손광진
-- 최초 작성일 : 2020-10-12 09:30:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>

		var auiGrid;
		var centerCd = [];
		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGrid();
		});
	
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn: true,
				showFooter : true,
				footerPosition : "top",
			};
			var columnLayout = [
				{ 
					headerText : "년도", 
					dataField : "inout_year", 
					width : "7%", 
					style : "aui-center"
				},
				{
					headerText : "전체",
					dataField : "total_amt",	
					width : "6%", 
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-center aui-popup",
					expFunction : function(  rowIndex, columnIndex, item, dataField ) { // 여기서 실제로 출력할 값을 계산해서 리턴시킴.
						var sum = 0;
						for (var i = 0; i < centerCd.length; ++i) {
							sum+=$M.toNum(item[centerCd[i]]);
						}
						return sum;
					}
				},			
			];
			
	
			// 푸터레이아웃
			var footerColumnLayout = [ 
				{
					labelText : "합계",
					positionField : "inout_year",
					style : "aui-center"
				},
				{
					dataField : "total",
					positionField : "total",
					formatString : "#,##0",
					operation : "SUM",
					style : "aui-center"
				}
			]
			<c:forEach items="${rentCenters}" var="item">
				var obj = {
					headerText : "${item[1]}",
					dataField : "${item[0]}" + "_amt",
					dataType : "numeric",
					formatString : "#,##0",
					width : "6%",
					style : "aui-center aui-popup"
				}
				var sumObj = {
					dataField : "${item[0]}" + "_amt",
					positionField : "${item[0]}" + "_amt",
					formatString : "#,##0",
					operation : "SUM",
					style : "aui-center aui-footer",	
				}
				centerCd.push("${item[0]}" + "_amt");
				columnLayout.push(obj);
				footerColumnLayout.push(sumObj);
			</c:forEach>
			console.log(centerCd);
			
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.setFooter(auiGrid, footerColumnLayout);
			AUIGrid.resize(auiGrid);
			
			AUIGrid.bind(auiGrid, "cellClick", function(event) {

				if(event.value == 0) {
					return;
				};
				var org_code = event.dataField.split("_");
				if (event.dataField.indexOf("_amt") != -1) {
					// 렌탈매출현황 상세 팝업 호출
					
					var params = {
// 						made_year 			: event.dataField != "total_amt" ? event.item.inout_year : "",
						"start_dt" 			: event.item.inout_year + "0101",
						"end_dt" 			: event.item.inout_year + "1231",
						mng_org_code	 	: event.dataField != "total_amt" ? org_code[0] : "",
						"s_sort_key" 		: "t5.inout_dt desc, t1.rental_doc_no",
						"s_sort_method" 	: "asc",
					};
					
					var popupOption = "scrollbars=yes, resizable=yes, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=440, left=0, top=0";
	 				$M.goNextPage('/rent/rent0402p01', $M.toGetParam(params), {popupStatus : popupOption});
				};
			}); 
						
		}
		
	
		function goSearch() {
			
			if($M.checkRangeByFieldName("s_start_year", "s_end_year", true) == false) {				
				return;
			}; 
			
			var param = {
				s_start_year      : $M.getValue("s_start_year"),
				s_end_year   	  : $M.getValue("s_end_year"),
				s_sort_key 		  : "",
				s_sort_method 	  : "",
			};
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						AUIGrid.setGridData(auiGrid, result.list);
					};
				}
			);
		}


		function fnDownloadExcel() {
			var exportProps = {};
			fnExportExcel(auiGrid, "년도별 센터별 매출현황", exportProps);
	    }

		
	
	</script>
</head>
<body  style="background : #fff;"  >
<form id="main_form" name="main_form">
	<div class="layout-box">
		<div class="content-wrap">						
<!-- 검색영역 -->					
			<div class="search-wrap mt10">				
				<table class="table">
					<colgroup>		
						<col width="190px">						
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width80px">
										<select class="form-control width120px" name="s_start_year" id="s_start_year" alt="시작일">
											<c:forEach var="i" begin="2013" end="${inputParam.s_current_year}" step="1">
												<option value="${i}" <c:if test="${i eq inputParam.s_current_year}">selected="selected"</c:if>>${i}년</option>
											</c:forEach>
										</select>
									</div>
									<div class="col width16px text-center">~</div>
									<div class="col width80px">
										<select class="form-control width120px" name="s_end_year" id="s_end_year" alt="종료일">
											<c:forEach var="i" begin="2013" end="${inputParam.s_current_year}" step="1">
												<option value="${i}" <c:if test="${i eq inputParam.s_current_year}">selected="selected"</c:if>>${i}년</option>
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
<!-- 년도별 센터별 매출현황 -->
			<div class="title-wrap mt10">
				<h4>년도별 센터별 매출현황</h4>
				<div class="btn-group">
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
					</div>
				</div>
			</div>
<!-- /년도별 센터별 매출현황 -->
			<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>		
		</div>
	</div>		

</form>	
</body>
</html>