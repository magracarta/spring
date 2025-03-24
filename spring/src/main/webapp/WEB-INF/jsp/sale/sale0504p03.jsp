<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > MS관리 > MS리스트관리 > null > 지역
-- 작성자 : 성현우
-- 최초 작성일 : 2020-08-03 14:23:48
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
				rowIdField : "row",
				// rowNumber 
				showRowNumColumn: false,
				// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
// 				wrapSelectionMove : false,
				enableFilter : true,
			};
			var columnLayout = [
				{ 
					headerText : "코드", 
					dataField : "sale_area_code",
// 					width : "8%", 
					style : "aui-center"
				},
				{ 
					headerText : "지역", 
					dataField : "area_do",
					style : "aui-center"
				},
				{ 
					headerText : "세부지역", 
					dataField : "area_si",
					style : "aui-center"
				},
				{ 
					headerText : "지역명", 
					dataField : "area_disp",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				}
			];

			// 실제로 #grid_wrap 에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, ${saleAreaList});
			$("#auiGrid").resize();

			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				var openByRowId = AUIGrid.isItemOpenByRowId(event.pid, event.rowIdValue);
				if((event.treeIcon == false && openByRowId == true) || openByRowId == undefined) {
					try {
						opener.${inputParam.parent_js_name}(event.item);
						window.close();
					} catch(e) {
						alert('호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.');
					};
				}
			});
		}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
<!--             <h2>지역</h2> -->
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
<!--             <button type="button" class="btn btn-icon"><i class="material-iconsclose"></i></button> -->
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">	
			<div class="title-wrap">			
				<h4 class="primary">지역구분목록</h4>				
			</div>
			<div style="margin-top: 5px; height: 300px;" id="auiGrid"></div>
<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">						
				<div class="right">
					<button type="button" class="btn btn-info" style="width: 50px;" onclick="javascript:window.close();">닫기</button>
				</div>
			</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
        </div>
    </div>
<!-- /팝업 -->

</form>
</body>
</html>