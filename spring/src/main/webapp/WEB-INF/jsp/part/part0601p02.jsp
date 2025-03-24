<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 부품통계 > 부품판매현황-기간별 > null > 집계상세조회
-- 작성자 : 손광진
-- 최초 작성일 : 2020-09-10 11:33:42
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


		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "집계상세조회", "");
		}
				
		function goPrint() {
			alert("인쇄");
		}
		
				
		// 그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn: true,
				showFooter : true,
				footerPosition : "top"
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
				    headerText: "전표정보",
					children : [
						{
							dataField : "inout_dt",
							headerText : "전표일자",
							width : "5%",
							style : "aui-center",
							
						}, 
						{
							dataField : "inout_doc_no",
							headerText : "번호",
							width : "8%",
							style : "aui-center",
						},
						{
							dataField : "breg_name",
							headerText : "거래처",
							width : "7%",
							style : "aui-center",
						},
						{
							dataField : "cust_name",
							headerText : "고객",
							style : "aui-center",
						},
					]
				},
				{
				    headerText: "기간매입",
				    dataField: "in_amt",
					dataType : "numeric",
					width : "7%",
					formatString : "#,##0",
					style : "aui-right"
				},
				{
				    headerText: "부품부판매",
					children : [
						{
							dataField : "part_amt",
							headerText : "매출",
							dataType : "numeric",
							width : "7%",
							formatString : "#,##0",
							style : "aui-right",
						}, 
						{
							dataField : "part_origin_amt",
							headerText : "원가",
							dataType : "numeric",
							width : "7%",
							formatString : "#,##0",
							style : "aui-right",
						},
						{
							dataField : "part_profit_amt",
							headerText : "이익",
							dataType : "numeric",
							width : "7%",
							formatString : "#,##0",
							style : "aui-right",
						},
						{
							dataField : "part_profit_rate",
							headerText : "%",
							style : "aui-right",
						},
					]
				},
				{
				    headerText: "서비스판매",
					children : [
						{
							dataField : "svc_amt",
							headerText : "매출",
							dataType : "numeric",
							width : "7%",
							formatString : "#,##0",
							style : "aui-right",
						}, 
						{
							dataField : "svc_origin_amt",
							headerText : "원가",
							dataType : "numeric",
							width : "7%",
							formatString : "#,##0",
							style : "aui-right",
						},
						{
							dataField : "svc_profit_amt",
							headerText : "이익",
							dataType : "numeric",
							width : "7%",
							formatString : "#,##0",
							style : "aui-right",
						},
						{
							dataField : "scv_profit_rate",
							headerText : "%",
							style : "aui-right",
						},
					]
				},
				{
				    headerText: "마케팅판매",
					children : [
						{
							dataField : "sale_amt",
							headerText : "매출",
							dataType : "numeric",
							formatString : "#,##0",
							style : "aui-right",
						}, 
						{
							dataField : "sale_origin_amt",
							headerText : "원가",
							dataType : "numeric",
							formatString : "#,##0",
							style : "aui-right",
						},
						{
							dataField : "sale_profit_amt",
							headerText : "이익",
							dataType : "numeric",
							formatString : "#,##0",
							style : "aui-right",
						},
						{
							dataField : "sale_profit_rate",
							headerText : "%",
							style : "aui-right",
						},
					]
				},
				{
				    headerText: "계",
					children : [
						{
							dataField : "org_amt_sum",
							headerText : "매출",
							dataType : "numeric",
							width : "7%",
							formatString : "#,##0",
							style : "aui-right",
						}, 
						{
							dataField : "org_origin_amt_sum",
							headerText : "원가",
							dataType : "numeric",
							width : "7%",
							formatString : "#,##0",
							style : "aui-right",
						},
						{
							dataField : "org_profit_amt_sum",
							headerText : "이익",
							dataType : "numeric",
							width : "7%",
							formatString : "#,##0",
							style : "aui-right",
						},
						{
							dataField : "org_profit_rate_sum",
							headerText : "%",
							style : "aui-right",
						},
					]
				},
				{
					headerText : "서비스",
					dataField : "svc_free_origin_amt",
					width : "7%",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right"
				},
				{
				    headerText: "기본출하",
				    dataField: "mch_out_origin_amt",
					width : "7%",
				    dataType : "numeric",
				    formatString : "#,##0",
					style : "aui-right"
				},
				{
				    headerText: "총원가",
				    dataField: "tot_origin_amt",
					width : "7%",
				    dataType : "numeric",
				    formatString : "#,##0",
					style : "aui-right"
				},
			];
			
			// 푸터레이아웃
			var footerColumnLayout = [ 
				{
					labelText : "합계",
					positionField : "cust_name",
					style : "aui-center aui-footer",
				}, 
				{
					dataField : "in_amt",
					positionField : "in_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "part_amt",
					positionField : "part_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "part_origin_amt",
					positionField : "part_origin_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "part_profit_amt",
					positionField : "part_profit_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "part_profit_rate",
					positionField : "part_profit_rate",
					labelFunction : function(value, columnValues, footerValues) {
						var amtSum = footerValues[2];
						var originAmtSum = footerValues[3];
						
						var profitRateSum = Math.round((Number(amtSum) - Number(originAmtSum) ) / Number(amtSum) * Number(100));
						
						return isNaN(profitRateSum) ? 0 : profitRateSum;
					},
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "svc_amt",
					positionField : "svc_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "svc_origin_amt",
					positionField : "svc_origin_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "svc_profit_amt",
					positionField : "svc_profit_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "scv_profit_rate",
					positionField : "scv_profit_rate",
					// operation : "SUM",
					labelFunction : function(value, columnValues, footerValues) {
						var amtSum = footerValues[6];
						var originAmtSum = footerValues[7];
						
						var profitRateSum = Math.round((Number(amtSum) - Number(originAmtSum) ) / Number(amtSum) * Number(100));
						
						return isNaN(profitRateSum) ? 0 : profitRateSum;
					},
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "sale_amt",
					positionField : "sale_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "sale_origin_amt",
					positionField : "sale_origin_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "sale_profit_amt",
					positionField : "sale_profit_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "sale_profit_rate",
					positionField : "sale_profit_rate",
					// operation : "SUM",
					labelFunction : function(value, columnValues, footerValues) {
						var amtSum = footerValues[10];
						var originAmtSum = footerValues[11];
						
						var profitRateSum = Math.round((Number(amtSum) - Number(originAmtSum) ) / Number(amtSum) * Number(100));
						
						return isNaN(profitRateSum) ? 0 : profitRateSum;
					},
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "org_amt_sum",
					positionField : "org_amt_sum",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "org_origin_amt_sum",
					positionField : "org_origin_amt_sum",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "org_profit_amt_sum",
					positionField : "org_profit_amt_sum",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "org_profit_rate_sum",
					positionField : "org_profit_rate_sum",
					labelFunction : function(value, columnValues, footerValues) {
						var amtSum = footerValues[14];
						var originAmtSum = footerValues[15];
						
						var profitRateSum = Math.round((Number(amtSum) - Number(originAmtSum) ) / Number(amtSum) * Number(100));
						
						return isNaN(profitRateSum) ? 0 : profitRateSum;
					},
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "svc_free_origin_amt",
					positionField : "svc_free_origin_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "mch_out_origin_amt",
					positionField : "mch_out_origin_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "tot_origin_amt",
					positionField : "tot_origin_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
			];

	
			// 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, listJson);
			
			AUIGrid.setFooter(auiGrid, footerColumnLayout);
			// AUIGrid.setFixedColumnCount(auiGrid, 4);
			$("#auiGrid").resize();
		}
		
		
		//팝업 닫기
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
            <!--  <h2>집계상세조회</h2>  -->
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
<!-- 폼테이블 -->					
			<div>
				<div class="title-wrap">
					<div class="left">
						<h4>
							<span>
								<span class="text-default bd0 pr5">부품번호 : </span>
								${inputParam.part_no}
							</span>
							<span class="ver-line">
								<span class="text-default bd0 pr5">부품명 : </span>
								${inputParam.part_name}
							</span>
						</h4>
					</div>
					<div class="right">						
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
					</div>
				</div>						
				<div style="margin-top: 5px; height: 430px;" id="auiGrid"></div>
			</div>		
<!-- /폼테이블 -->
			<div class="btn-group mt10">
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">${total_cnt}</strong>건
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