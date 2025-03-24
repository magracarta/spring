<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 부품통계 > 재고 서머리
-- 작성자 : 김상덕
-- 최초 작성일 : 2023-03-14 16:11:00
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
			rowIdField : "part_no",
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
				width: "150",
				minWidth: "150",
				style: "aui-center aui-popup",
			}, 
			{
				headerText : "부품명",
				dataField : "part_name",
				width: "200",
				minWidth: "200",
				style: "aui-center",
			}, 
			{
				headerText : "메이커",
				dataField : "maker_name",
				width: "150",
				minWidth: "150",
				style: "aui-center",
			}, 
			{
				headerText : "매입처",
				dataField : "deal_cust_name",
				width: "150",
				minWidth: "150",
				style: "aui-center",
			}, 
			{
				headerText : "관리구분",
				dataField : "part_mng_name",
				width: "100",
				minWidth: "100",
				style: "aui-center",
			}, 
			{
				headerText : "기간재고",
				dataField : "ragne_stock",
				width: "100",
				minWidth: "100",
				style: "aui-center",
			}, 
			{
				headerText : "현재고",
				dataField : "current_stock",
				width: "100",
				minWidth: "100",
				style: "aui-center",
			}, 
			{
				headerText : "평균매입가",
				dataField : "avg_price",
				style : "aui-right",
				dataType : "numeric",
				formatString : "#,##0",
				width: "100",
				minWidth: "100",
			}, 
			// {
			// 	headerText : "재고금액",
			// 	dataField : "out_amt",
			// 	style : "aui-right",
			// 	dataType : "numeric",
			// 	formatString : "#,##0",
			// 	width: "200",
			// 	minWidth: "200",
			// },
			{
				headerText : "재고금액",
				dataField : "stock_price",
				style : "aui-right",
				dataType : "numeric",
				formatString : "#,##0",
				width: "200",
				minWidth: "200",
			}
		];
		// 실제로 #grid_wrap 에 그리드 생성
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		// 그리드 갱신
		AUIGrid.setGridData(auiGrid, ${list});
		$("#auiGrid").resize();
 		$("#total_cnt").html(${total_cnt});
		AUIGrid.bind(auiGrid, "cellClick", function(event) {
			if(event.dataField == "part_no") {
				var param = {
					part_no 			: event.item.part_no,
					start_year_mon  	: "${inputParam.s_mon}",
					end_year_mon 	  	: "${inputParam.s_mon}"
				};
				var popupOption = "";
				$M.goNextPage('/part/part0606p01', $M.toGetParam(param), {popupStatus : popupOption});
			}
		});
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
