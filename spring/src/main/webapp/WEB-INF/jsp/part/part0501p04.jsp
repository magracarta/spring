<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 재고관리 > 센터별부품관리 > null > 재고실사이력
-- 작성자 : 박준영
-- 최초 작성일 : 2020-09-16 17:46:42
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
		
		// 그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn: true,
				editable : false,
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
				    headerText: "조사일자",
				    dataField: "stock_dt",
					style : "aui-center",
					dataType : "date",
		            formatString : "yyyy-mm-dd",
				},
				{
					headerText : "조사자",
					dataField : "reg_mem_name",
					style : "aui-center"
				},
				{
				    headerText: "적정재고",
				    dataField: "safe_stock",
					style : "aui-center"
				},
				{
				    headerText: "실사재고",
				    dataField: "check_stock",
					style : "aui-center"
				},
				{
				    headerText: "차이수량",
				    dataField: "diff_cnt",
					style : "aui-center"
				},
				{
				    headerText: "비고",
				    dataField: "remark",
				    width: "40%",
					style : "aui-left"
				},
			];

			// 그리드 출력
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, ${checkStockHislist});
			
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
<!-- 폼테이블 -->					
			<div>
				<div class="title-wrap">
					<h4>${inputParam.part_no} (${inputParam.part_name})</h4>
				</div>
				<div id="auiGrid" style="margin-top: 5px; height: 250px;"></div>
			</div>
<!-- /폼테이블 -->	
<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">	
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">${total_cnt}</strong>건
				</div>					
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