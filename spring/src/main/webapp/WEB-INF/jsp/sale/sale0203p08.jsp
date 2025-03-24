<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 장비관리 > 장비입고-LC Open 선적 > null > 센터 별 보유장비현황
-- 작성자 : 황빛찬
-- 최초 작성일 : 2021-08-09 17:17:08
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
	var auiGrid;

	$(document).ready(function() {
		createAUIGrid(); // 메인 그리드
	});
	
	function createAUIGrid() {
		var gridPros = {
			rowIdField : "_$uid", 
			// rowNumber 
			showRowNumColumn: true,
			// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
			wrapSelectionMove : false,
			showStateColumn : false,
			editable : true,
			showFooter: true,
			footerPosition : "top",
		};
		var columnLayout = [
			{ 
				headerText : "모델", 
				dataField : "machine_name", 
				width : "200", 
				style : "aui-center",
				editable : false
			},
			{ 
				headerText : "옥천", 
				dataField : "okcheon", 
				width : "100", 
				style : "aui-center",
				dataType : "numeric",
				formatString : "#,##0",
				editable : false
			},
			{ 
				headerText : "평택", 
				dataField : "pyeongtaek", 
				width : "100", 
				style : "aui-center",
				dataType : "numeric",
				formatString : "#,##0",
				editable : false
			},
			{ 
				headerText : "김해", 
				dataField : "gimhae", 
				width : "100", 
				style : "aui-center",
				dataType : "numeric",
				formatString : "#,##0",
				editable : false
			},
			{ 
				headerText : "계", 
				dataField : "total", 
				width : "100", 
				style : "aui-center",
				dataType : "numeric",
				formatString : "#,##0",
				editable : false
			},
		];
		
		// 푸터레이아웃
		var footerColumnLayout = [ 
			{
				labelText : "합계",
				positionField : "machine_name",
			}, 
			{
				dataField: "okcheon",
				positionField: "okcheon",
				operation: "SUM",
				formatString : "#,##0",
				style: "aui-center aui-footer"
			},
			{
				dataField: "pyeongtaek",
				positionField: "pyeongtaek",
				operation: "SUM",
				formatString : "#,##0",
				style: "aui-center aui-footer"
			},
			{
				dataField: "gimhae",
				positionField: "gimhae",
				operation: "SUM",
				formatString : "#,##0",
				style: "aui-center aui-footer"
			},
			{
				dataField: "total",
				positionField: "total",
				operation: "SUM",
				formatString : "#,##0",
				style: "aui-center aui-footer"
			},
		];
		
		// 실제로 #grid_wrap 에 그리드 생성
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		AUIGrid.setFooter(auiGrid, footerColumnLayout);
		// 그리드 갱신
		AUIGrid.setGridData(auiGrid, ${list});
		$("#total_cnt").html(${total_cnt});
	}	
	
	function fnClose() {
		window.close();
	}
	</script>
</head>
<body>
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
<!-- 조회결과 -->
				<div class="title-wrap mt10">
					<h4>센터별보유장비현황</h4>
				</div>
				<div id="auiGrid" style="margin-top: 5px; height: 400px;"></div>
<!-- /조회결과 -->
			</div>		
<!-- /폼테이블 -->
			<div class="btn-group mt10">
				<div class="left">
					총 <strong id="total_cnt" class="text-primary">0</strong>건
				</div>	
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