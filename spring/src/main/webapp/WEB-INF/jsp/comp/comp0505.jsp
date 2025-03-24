<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 계약관리 > 계약/출하 > null > 추가품목선별
-- 작성자 : 황빛찬
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
	var auiGrid;
	var list = ${list}  // 서버에서넘겨준 추가품목선별 리스트
	
	$(document).ready(function() {
		createAUIGrid();
		if (list.length == 0) {
			alert("조회된 결과가 없습니다.");
			fnClose();
		}
	});
		
	function fnClose() {
		window.close(); 
	}
		
	//그리드생성
	function createAUIGrid() {
		var gridPros = {
			rowIdField : "_$uid",
			height : 250,
		};
		
		var columnLayout = [
			{ 
				headerText : "부품번호", 
				dataField : "part_no", 
				width : "20%", 
				style : "aui-left"
			},
			{ 
				headerText : "부품명", 
				dataField : "part_name",
				width : "40%", 
				style : "aui-left"
			},
			{
				headerText : "단위", 
				dataField : "unit", 
				width : "6%", 
				style : "aui-center"
			},
			{
				headerText : "수량", 
				dataField : "add_qty", 
				width : "10%", 
				style : "aui-center"
			},
			{
				headerText : "단가", 
				dataField : "unit_price", 
				dataType : "numeric",
				formatString : "#,##0",
				width : "10%", 
				style : "aui-right"
			},
			{
				headerText : "금액", 
				dataField : "part_amt",
				dataType : "numeric",
				formatString : "#,##0",
				style : "aui-right"
			},
			{
				dataField : "part_name_change_yn",
				visible : false
			}
		];
			
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		AUIGrid.setGridData(auiGrid, ${list});
		AUIGrid.bind(auiGrid, "cellClick", function(event){
			try{
				opener.${inputParam.parent_js_name}(event.item);
				window.close();	
			} catch(e) {
				alert('호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.');
			}
		});
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
<!-- 폼테이블 -->					
			<div>
				<div class="title-wrap">
					<h4>추가품목선별목록</h4>
				</div>
				<div id="auiGrid" style="margin-top: 5px;"></div>		
			</div>
<!-- /폼테이블 -->	
<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">						
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>