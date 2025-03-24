<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 발주/납기관리 > 수요예측 > null > 거래처별 주문상품
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2020-01-10 17:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var auiGrid;

		$(document).ready(function() {
			createAUIGrid();	
		});

		function createAUIGrid() {
			var gridPros = {
					showRowNumColumn : true,
					rowIdField : "row",
			};

			var columnLayout = [
				{
					headerText : "부품번호",
					dataField : "part_no",
					width : "15%",
				},
				{
					headerText : "부품명",
					dataField : "part_name",
					width : "27%",
				},
				{
					headerText : "메이커",
					dataField : "maker_name",
					width : "15%",
				},
				{
					headerText : "수량",
					dataField : "qty",
					width : "10%",
				},
				{
					headerText : "처리일자",
					dataField : "reg_dt",
					dataType : "date",
					width : "15%",
					formatString : "yyyy-mm-dd",
				},
				{
					headerText : "처리자",
					dataField : "sale_name",
					width : "10%",
				},
				{
					headerText : "삭제",
					dataField : "delete_btn",
					width : "8%",
					renderer : {
						type : "ButtonRenderer",
						labelText : "삭제", 
						onClick : function(event) {
							// var isRemoved = AUIGrid.isRemovedById(auiGridSecRight, event.item._$uid);
							// if (isRemoved == false) {
							// 	AUIGrid.removeRow(event.pid, event.rowIndex);
							// 	if(AUIGrid.isAddedById(auiGridSecRight, event.item._$uid)) {
							// 		AUIGrid.removeSoftRows(event.pid, event.rowIndex);
							// 	}
							// } else {
							// 	AUIGrid.restoreSoftRows(auiGridSecRight, "selectedIndex");
							// }
							alert("삭제 버튼");
						},
					},
				}
			];

			var testData = [
				{
					"part_no" : "119305-35151L",
					"part_name" : "FILTER, ENGINE OIL",
					"maker_name" : "안마",
					"qty" : "2",
					"reg_dt" : "20160719",
					"sale_name" : "홍길동"
				}, 
				{
					"part_no" : "119305-35151L",
					"part_name" : "FILTER, ENGINE OIL",
					"maker_name" : "안마",
					"qty" : "2",
					"reg_dt" : "20160719",
					"sale_name" : "홍길동"
				},
				{
					"part_no" : "119305-35151L",
					"part_name" : "FILTER, ENGINE OIL",
					"maker_name" : "안마",
					"qty" : "2",
					"reg_dt" : "20160719",
					"sale_name" : "홍길동"
				},
				{
					"part_no" : "119305-35151L",
					"part_name" : "FILTER, ENGINE OIL",
					"maker_name" : "안마",
					"qty" : "2",
					"reg_dt" : "20160719",
					"sale_name" : "홍길동"
				},
				{
					"part_no" : "119305-35151L",
					"part_name" : "FILTER, ENGINE OIL",
					"maker_name" : "안마",
					"qty" : "2",
					"reg_dt" : "20160719",
					"sale_name" : "홍길동"
				},
				{
					"part_no" : "119305-35151L",
					"part_name" : "FILTER, ENGINE OIL",
					"maker_name" : "안마",
					"qty" : "2",
					"reg_dt" : "20160719",
					"sale_name" : "홍길동"
				},
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, testData);
		}

		function fnClose() {
			window.close();
		}
	</script>
</head>
<body>
	<div class="popup-wrap width-100per">
	<!-- 메인 타이틀 -->
			<div class="main-title">
				<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
			</div>
	<!-- /메인 타이틀 -->
			<div class="content-wrap">
	<!-- 기본 -->					
			<div id="auiGrid" style="margin-top: 5px; height: 300px;"></div>
	<!-- /기본 -->	
	
	<!-- 그리드 서머리, 컨트롤 영역 -->
				<div class="btn-group mt5">
					<div class="left">
						총 <strong class="text-primary">25</strong>건
					</div>						
					<div class="right"><%-- 버튼위치는 pos param 에 따라 나옴 (없으면 기본 상단나옴) T_CODE.CODE_VALUE='BTN_POS' 참고 --%>
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
					</div>
				</div>
			</div>
	</div>
<!-- /contents 전체 영역 -->	
</body>
</html>