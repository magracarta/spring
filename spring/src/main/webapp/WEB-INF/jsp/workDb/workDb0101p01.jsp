<%@ page contentType="text/html;charset=utf-8" language="java" %>
<jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통팝업 > 업무DB > 업무DB팝업 > null > 이동
-- 작성자 : 박예진
-- 최초 작성일 : 2021-03-29 11:00:00
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">
	
		$(document).ready(function() {
			createAUIGrid();
		});
			
		function createAUIGrid() {
			var gridPros = {
				// rowIdField 설정
				rowIdField : "sale_area_code",
				// rowNumber 
				showRowNumColumn: false,
				// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
				wrapSelectionMove : false,
				enableFilter :true,
				enableSorting : false,
				// 최초 보여질 때 모두 열린 상태로 출력 여부
				displayTreeOpen : false,
				// singleRow 선택모드
				selectionMode : "singleRow",
			};
			
			var columnLayout = [
				{
					headerText : "이동 Depth", 
					dataField : "path_sale_area_name", 
					width : "100%", 
					style : "aui-left",
					editable : false,
					filter : {
						showIcon : true
					},
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var area = value.split(" > ")
						return area[area.length-1];
					}
				},
			]
// 			var treeList = ${list};
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
// 			AUIGrid.setGridData(auiGrid, treeList);
			AUIGrid.bind(auiGrid, "cellClick", function(event){
// 				var openByRowId = AUIGrid.isItemOpenByRowId(event.pid, event.rowIdValue);
// 			     if((event.treeIcon == false && openByRowId == true) || openByRowId == undefined) {
// 			    	 try{
// 							opener.${inputParam.parent_js_name}(event.item);
// 							window.close();	
// 						} catch(e) {
// 							alert('호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.');
// 						};
// 			     }
				 });
			$("#auiGrid").resize();
		}
		
		//팝업 끄기
		function fnClose() {
			window.close(); 
		}
		
		
    </script> 
</head>

<body class="bg-white class">
	<form id="main_form" name="main_form">
		<!-- 팝업 -->
		<div class="popup-wrap width-100per">
			<!-- 타이틀영역 -->
			<div class="main-title">
				<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
			</div>
			<!-- /타이틀영역 -->
			<div class="content-wrap">
				<div id="auiGrid" style="margin-top: 5px; height: 410px;"></div>
				
				<div class="btn-group mt5">					
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