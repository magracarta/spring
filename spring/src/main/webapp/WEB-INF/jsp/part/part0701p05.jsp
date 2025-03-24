<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 코드관리 > 부품마스터등록/수정 > null > null
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2020-01-10 17:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
	<%-- 여기에 스크립트 넣어주세요. --%>
	var auiGrid;
	
	$(document).ready(function() {
		createAUIGrid();
	});
	
	// 메인그리드
	function createAUIGrid() {
		var gridPros = {
			// rowIdField 설정
			rowIdField : "price_date",
			// rowIdField가 unique 임을 보장
			rowIdTrustMode : true,
			// rowNumber 
			showRowNumColumn : true,
			// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
			wrapSelectionMove : false
		};
		var columnLayout = [ 
			{
				headerText : "부품번호",
				dataField : "part_no",
				style : "aui-center",
				width : "10%",
				editable : false
			}, 
			{
				headerText : "부품명",
				dataField : "part_name",
				style : "aui-left",
				width : "15%",
				editable : false
			}, 
			{
				headerText : "단가변경사유",
				dataField : "price_remark",
				style : "aui-center",
				width : "10%",
				editable : false
			}, 
			{
				headerText : "변경일시",
				dataField : "price_date",
				dataType : "date",
				formatString : "yy-mm-dd HH:MM:ss", 				
				style : "aui-center",
				width : "12%",
				editable : false
			}, 
			{
				headerText : "처리자",
				dataField : "reg_mem_name",
				style : "aui-center",
				editable : false
			}, 
			{
				headerText : "List Price",
				dataField : "list_price",
				style : "aui-right",
				dataType : "numeric",
				formatString : "#,##0",
				width : "10%",
				editable : false
			}, 
			{
				headerText : "Net Price",
				dataField : "net_price",
				style : "aui-right",
				dataType : "numeric",
				formatString : "#,##0",
				width : "10%",
				editable : false
			}, 
			{
				headerText : "입고단가",
				dataField : "in_stock_price",
				style : "aui-right",
				dataType : "numeric",
				formatString : "#,##0",
				width : "10%",
				editable : false
			}, 
			{
				headerText : "VIP 판매가",
				dataField : "vip_price",
				style : "aui-right",
				dataType : "numeric",
				formatString : "#,##0",
				width : "10%",
				editable : false
			}, 
			{
				headerText : "전략가",
				dataField : "strategy_price",
				style : "aui-right",
				dataType : "numeric",
				formatString : "#,##0",
				width : "10%",
				editable : false
			}, 
			{
				headerText : "일반판매가",
				dataField : "cust_price",
				style : "aui-right",
				dataType : "numeric",
				formatString : "#,##0",
				width : "10%",
				editable : false
			}, 
			{
				headerText : "최종 VIP 판매가",
				dataField : "vip_sale_price",
				style : "aui-right",
				dataType : "numeric",
				formatString : "#,##0",
				width : "10%",
				editable : false
			}, 
			{
				headerText : "최종 일반판매가",
				dataField : "sale_price",
				style : "aui-right",
				dataType : "numeric",
				formatString : "#,##0",
				width : "10%",
				editable : false
			}, 
// 			{
// 				headerText : "대리점가",
// 				dataField : "mng_agency_price",
// 				style : "aui-right",
// 				dataType : "numeric",
// 				formatString : "#,##0",
// 				width : "10%",
// 				editable : false
// 			}, 
// 			{
// 				headerText : "대리점가2",
// 				dataField : "mng_agency_price2",
// 				style : "aui-right",
// 				dataType : "numeric",
// 				formatString : "#,##0",
// 				width : "10%",
// 				editable : false
// 			}, 

		];
		// 실제로 #grid_wrap 에 그리드 생성
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		// 그리드 갱신
		AUIGrid.setGridData(auiGrid, ${list});
		$("#auiGrid").resize();
 		$("#total_cnt").html(${total_cnt});
	}
	
	// 팝업 닫기
	function fnClose() {
		window.close();
	}
	</script>
</head>
<body class="bg-white">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
<!-- 폼테이블 -->									
			<div id="auiGrid" style="margin-top: 5px;"></div>
<!-- /폼테이블 -->
			<div class="btn-group mt10">
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">0</strong>건
				</div>	
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
        </div>
    </div>
<!-- /팝업 -->
</body>
</html>
