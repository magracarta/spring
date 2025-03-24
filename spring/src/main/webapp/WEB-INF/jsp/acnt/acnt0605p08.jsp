<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 인사 > 고과평가관리 > null > 중고 장비 판매 수익
-- 작성자 : 김태훈
-- 최초 작성일 : 2021-04-09 14:09:45
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
				rowIdField : "_$uid",
				showRowNumColumn: true,
				showFooter : true,
				footerPosition : "top",
			};
			var columnLayout = [
				{ 
					headerText : "관리번호", 
					dataField : "rental_machine_no", 
					width : "100", 
					style : "aui-center",
				},
				{ 
					headerText : "모델명", 
					dataField : "machine_name", 
					width : "100", 
					style : "aui-center"
				},
				{
					headerText : "차대번호", 
					dataField : "body_no", 
					width : "100", 
					style : "aui-center"
				},
				{ 
					headerText : "차주명", 
					dataField : "cust_name",  
					width : "100", 
					style : "aui-center"
				},
				{ 
					headerText : "매입일", 
					dataField : "buy_dt", 
					width : "100", 
					style : "aui-center",
				},
				{ 
					headerText : "매입가", 
					dataField : "buy_price",					
					width : "100", 
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{ 
					headerText : "판매가", 
					dataField : "sale_price",					
					width : "100", 
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{ 
					headerText : "손익", 
					dataField : "sale_profit_amt",					
					width : "100", 
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{ 
					headerText : "판매자", 
					dataField : "sale_mem_name",					
					width : "100", 
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{ 
					headerText : "판매일", 
					dataField : "sale_dt", 
					width : "100", 
					style : "aui-center",
				},
			];
			
			// 푸터 설정
			var footerLayout = [
				{
					labelText : "합계",
					positionField : "buy_dt",
					style : "aui-right aui-footer"
				},
				{
					dataField : "buy_price",
					positionField : "buy_price",
 					operation : "SUM",
					formatString : "#,##0",
					style: "aui-right aui-footer",
				},
				{
					dataField : "sale_price",
					positionField : "sale_price",
 					operation : "SUM",
					formatString : "#,##0",
					style: "aui-right aui-footer",
				}
			];
			
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, ${list});
			// 푸터 레이아웃 세팅
			AUIGrid.setFooter(auiGrid, footerLayout);
			$("#total_cnt").html("${total_cnt}");
			$("#auiGrid").resize();
		}
		
		function fnDownloadExcel() {
			var exportProps = {};
			fnExportExcel(auiGrid, "부품판매수익", exportProps);
	    }
		
		// 닫기
	    function fnClose() {
	    	window.close();
	    }
		
	</script>
</head>
<body class="bg-white" >
<form id="main_form" name="main_form">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">				
			<div>
				<!-- <div class="title-wrap">
					<button type="button" class="btn btn-default" onclick="javascript:fnDownloadExcel();" ><i class="icon-btn-excel inline-btn"></i>엑셀다운로드</button>
				</div> -->
				<div  id="auiGrid"  style="margin-top: 5px; height: 300px;"></div>
				<div class="btn-group mt10">
					<div class="left">
						총 <strong class="text-primary" id="total_cnt">0</strong>건
					</div>
					<div class="right">
						<button type="button" class="btn btn-info" onclick="javascript:fnClose();">닫기</button>
					</div>
				</div>
			</div>			
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>