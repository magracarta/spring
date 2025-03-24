<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 장부 > 자금일보 > null > 미오픈 발주 상세
-- 작성자 : 황빛찬
-- 최초 작성일 : 2020-09-08 13:27:21
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
	var auiGrid;
	
	$(document).ready(function () {
		createAUIGrid();
	});

	function createAUIGrid() {
		var gridPros = {
			// Row번호 표시 여부
			showRowNumColum : true,
			showFooter : true,
			footerPosition : "top",
		};
		
		var columnLayout = [
			{
				dataField : "money_unit_cd",
				visible : false
			},
			{
				headerText : "발주번호",
				dataField : "machine_order_no",
				style : "aui-center aui-popup",
				width : "12%"
			},
			{
				headerText : "모델",
				dataField : "machine_name",
				style : "aui-center",
			},
			{
				headerText : "발주내역",
				dataField : "",
				children : [
					{
						headerText : "수량",
						dataField : "qty",
						dataType : "numeric",
						formatString : "#,##0",
						style : "aui-center",
						width : "7%"
					},
					{
						headerText : "단가",
						dataField : "unit_price",
						dataType : "numeric",
						formatString : "#,##0",
						style : "aui-right"
					},
					{
						headerText : "금액",
						dataField : "amount",
						dataType : "numeric",
						formatString : "#,##0",
						style : "aui-right"
					}
				]
			},
			{
				headerText : "미오픈",
				dataField : "",
				children : [
					{
						headerText : "수량",
						dataField : "not_lc_qty",
						dataType : "numeric",
						formatString : "#,##0",
						style : "aui-center",
						width : "7%"
					},
					{
						headerText : "금액",
						dataField : "not_lc_amount",
						dataType : "numeric",
						formatString : "#,##0",
						style : "aui-right"
					},
				]
			}
		];
		
		// 푸터 설정
		var footerLayout = [
			{
				labelText : "합계",
				positionField : "machine_order_no"
			},
			{
				dataField: "amount",
				positionField: "amount",
				operation: "SUM",
				formatString : "#,##0",
				style: "aui-right aui-footer"
			},
			{
				dataField: "not_lc_amount",
				positionField: "not_lc_amount",
				operation: "SUM",
				formatString : "#,##0",
				style: "aui-right aui-footer"
			},
		];
		
		// 실제로 #grid_wrap에 그리드 생성
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		// 푸터 레이아웃 세팅
		AUIGrid.setFooter(auiGrid, footerLayout);
		// 그리드 갱신
		AUIGrid.setGridData(auiGrid, ${list});
		// 장비생산발주 상세 팝업 호출
		AUIGrid.bind(auiGrid, "cellClick", function(event) {
			if(event.dataField == "machine_order_no") {
				var param = {
						machine_order_no : event.item.machine_order_no
				};
			
				var popupOption = "";
				$M.goNextPage('/sale/sale0201p01', $M.toGetParam(param), {popupStatus : popupOption});
			}
		});
	}
	
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
				<h4>미오픈발주</h4>
			</div>
			<div id="auiGrid" style="margin-top: 5px; height: 350px;"></div>
		</div>
		<!-- /폼테이블-->
		<div class="btn-group mt10">
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