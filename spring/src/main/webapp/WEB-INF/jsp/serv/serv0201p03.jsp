<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 장비 입/출고 > 장비입고관리 > null > 옵션품목
-- 작성자 : 최보성
-- 최초 작성일 : 2020-04-07 19:54:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>
	
	var auiGrid;
	
	$(document).ready(function() {
		// AUIGrid 생성
		createAUIGrid();
	});
	
	//그리드생성
	function createAUIGrid() {
		var gridPros = {
			rowIdField : "row",
			showRowNumColumn: true,
		};
		var columnLayout = [
			{ 
				headerText : "부품번호", 
				dataField : "part_no", 
				style : "aui-center",
				width : "20%"
			},
			{
				headerText : "부품명", 
				dataField : "part_name", 
				style : "aui-left",
				width : "40%"
			},
			{ 
				headerText : "단위", 
				dataField : "part_unit", 
				style : "aui-center",
				width : "20%"
			},
			{ 
				headerText : "구성수량", 
				dataField : "qty", 
				style : "aui-center",
				width : "20%"
			},
		];
		
		var testData = [
			{
				"part_no" : "859034590",
				"part_name" : "ASSY",
				"part_unit" : "1",
				"qty" : "",
			},
			{
				"part_no" : "859034590",
				"part_name" : "ASSY",
				"part_unit" : "1",
				"qty" : "",
			},
			{
				"part_no" : "859034590",
				"part_name" : "ASSY",
				"part_unit" : "1",
				"qty" : "",
			},
		];
		
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		//AUIGrid.setGridData(auiGrid, testData);
		AUIGrid.setGridData(auiGrid, ${list});
		
		$("#auiGrid").resize();
	}	
	
	// 닫기
    function fnClose() {
    	window.close();
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
<!-- 폼테이블1 -->					
			<div>
<!-- 옵션품목 셀렉트 -->
				<input type="text" id="option" name="option" value="${opt_kor_name}" class="form-control width140px" readonly>
				<div id="auiGrid" style="margin-top: 5px; height: 300px;"></div>
<!-- 옵션품목 셀렉트 -->
			</div>
<!-- /폼테이블1 -->
			<div class="btn-group mt10">
				<div class="right">
					<button type="button" class="btn btn-info" onclick="javascript:fnClose();">닫기</button>
				</div>
			</div>
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>