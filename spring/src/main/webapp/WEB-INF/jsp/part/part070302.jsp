<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 코드관리 > 부품CUBE > 부품CUBE등록 > null
-- 작성자 : 박예진
-- 최초 작성일 : 2021-04-09 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		$(document).ready(function() {
			createAUIGrid();
			goSearch();
		});
	
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn: true,
				treeColumnIndex : 1,
				headerHeight : 40,
				// 최초 보여질 때 모두 열린 상태로 출력 여부
				displayTreeOpen : false,
			};
			var columnLayout = [
				{
					headerText : "대상",
					dataField : "",
					children : [
						{
							headerText : "부품번호", 
							dataField : "t_part_no", 
							width : "140",
							minWidth : "140",
							style : "aui-left",
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								if(item["rnk"] == "1") {
									return "aui-popup";
								}
							},
						},
						{
							headerText : "부품명", 
							dataField : "t_part_name", 
							width : "220",
							minWidth : "220",
							style : "aui-left"
						},
						{
							headerText : "수량", 
							dataField : "t_cube_qty",
							dataType : "numeric",
							formatString : "#,##0",
							width : "60",
							minWidth : "60",
							style : "aui-center",
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								var val = value;
								if(item["t_part_no"] == "") {
									val = "";
								}
						    	return $M.setComma(val); 
							}
						},
						{
							headerText : "평균매입가", 
							dataField : "t_in_avg_price",
							dataType : "numeric",
							formatString : "#,##0",
							width : "85",
							minWidth : "85",
							style : "aui-center",
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								var val = value;
								if(item["t_part_no"] == "" || item["cube_depth"] == "1") {
									val = "";
								}
						    	return $M.setComma(val); 
							}
						},
						{
							headerText : "합계", 
							dataField : "t_total_price",
							dataType : "numeric",
							onlyNumeric : true,
							formatString : "#,##0",
							width : "85",
							minWidth : "85", 
							style : "aui-right",
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								var val = value;
								if(item["t_part_no"] == ""|| item["cube_depth"] == "1") {
									val = "";
								}
						    	return $M.setComma(val); 
							}
						},
						{
							headerText : "비고", 
							dataField : "t_cube_remark",
							width : "150",
							minWidth : "150",
							style : "aui-left"
						},
					]
				},
				{
					headerText : "결과",
					dataField : "",
					children : [
						{
							headerText : "부품번호",  
							dataField : "r_part_no", 
							width : "140", 
							minWidth : "140",
							style : "aui-left"
						},
						{
							headerText : "부품명", 
							dataField : "r_part_name", 
							width : "220",
							minWidth : "220",
							style : "aui-left"
						},
						{
							headerText : "수량", 
							dataField : "r_cube_qty",
							dataType : "numeric",
							formatString : "#,##0",
							width : "60",
							minWidth : "60",
							style : "aui-center",
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								var val = value;
								if(item["r_part_no"] == "") {
									val = "";
								}
						    	return $M.setComma(val); 
							}
						},
						{
							headerText : "평균매입가", 
							dataField : "r_in_avg_price",
							dataType : "numeric",
							formatString : "#,##0",
							width : "85",
							minWidth : "85",
							style : "aui-center",
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								var val = value;
								if(item["r_part_no"] == ""|| item["cube_depth"] == "1") {
									val = "";
								}
						    	return $M.setComma(val); 
							}
						},
						{
							headerText : "합계", 
							dataField : "r_total_price",
							dataType : "numeric",
							onlyNumeric : true,
							formatString : "#,##0",
							width : "85",
							minWidth : "85", 
							style : "aui-right",
							labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
								var val = value;
								if(item["r_part_no"] == ""|| item["cube_depth"] == "1") {
									val = "";
								}
						    	return $M.setComma(val); 
							}
						},
						{
							headerText : "비고", 
							dataField : "r_cube_remark",
							width : "150",
							minWidth : "150",
							style : "aui-left"
						},
					]
				},
				{
					headerText : "등록일", 
					dataField : "reg_dt", 
					dataType : "date",  
					formatString : "yy-mm-dd",
					width : "65",
					minWidth : "65",
					style : "aui-center",
				},
				{ 
					headerText : "작성자", 
					dataField : "reg_mem_name",
					width : "60",
					minWidth : "60",
					style : "aui-center"
				},
				{
					headerText : "마감여부", 
					dataField : "end_yn",
					width : "65",
					minWidth : "65",
					style : "aui-center",
				},
				{ 
					headerText : "part_cube_no", 
					dataField : "part_cube_no", 
					visible : false
				},
				{ 
					headerText : "rnk", 
					dataField : "rnk", 
					visible : false
				},
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == "t_part_no") {
					if(event.item["rnk"] == 1) {
						var param = {
								"part_cube_no" : event.item["part_cube_no"]
							};			
						var popupOption = "";
						$M.goNextPage('/part/part0703p02', $M.toGetParam(param),  {popupStatus : popupOption});
					} 
				}
			});	
		}
		
		//조회
		function goSearch() { 
			var param = {
					"s_part_no" : $M.getValue("s_part_no"),
					"s_part_name" : $M.getValue("s_part_name"),
			};
			$M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'get'},
					function(result) {
						if(result.success) {
							AUIGrid.setGridData(auiGrid, result.list);
							$("#total_cnt").html(result.total_cnt);
						};
					}
				);
		} 
	
		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_part_no", "s_part_name"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch();
				};
			});
		}
		
		// 엑셀다운로드
		function fnDownloadExcel() {
			  // 엑셀 내보내기 속성
			  var exportProps = {
			  };
			  fnExportExcel(auiGrid, "부품CUBE", exportProps);
		}
		
		// SET등록
		function goNew() {
			var popupOption = "";
			$M.goNextPage('/part/part070302p01', "",  {popupStatus : popupOption});
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
						<table class="table table-fixed">
							<colgroup>					
								<col width="65px">
								<col width="100px">
								<col width="55px">
								<col width="100px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th>부품번호</th>
									<td>
										<input type="text" class="form-control" id="s_part_no" name="s_part_no">
                                    </td>
                                    <th>부품명</th>
									<td>
										<input type="text" class="form-control" id="s_part_name" name="s_part_name">
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
<!-- /그리드 타이틀, 컨트롤 영역 -->	
					<div class="title-wrap mt10">
						<div class="btn-group">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
							</div>
						</div>
					</div>
					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">	
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">0</strong>건
						</div>			
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
					</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
			</div>		
		</div>
<!-- /contents 전체 영역 -->		
</div>	
</form>
</body>
</html>