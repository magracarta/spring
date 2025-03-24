<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 인사 > 고과평가관리 > null > 부품 판매 수익
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
					headerText : "수주일", 
					dataField : "sale_dt", 
					width : "100", 
					style : "aui-center",
					dataType : "date",   
					formatString : "yy-mm-dd"
				},
				{ 
					headerText : "관리번호", 
					dataField : "part_sale_no", 
					width : "100", 
					style : "aui-center"
				},
				{
					headerText : "고객명", 
					dataField : "cust_name", 
					width : "100", 
					style : "aui-center"
				},
				{ 
					headerText : "품번", 
					dataField : "part_no",  
					width : "100", 
					style : "aui-center"
				},
				{ 
					headerText : "품명", 
					dataField : "part_name",  
					width : "100", 
					style : "aui-center"
				},
				{ 
					headerText : "수량", 
					dataField : "qty", 
					width : "100", 
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{ 
					headerText : "금액", 
					dataField : "total_amt",					
					width : "100", 
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{ 
					headerText : "금액(부가세포함)", 
					dataField : "total_amt_vat",					
					width : "100", 
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{ 
					headerText : "금액(x0.15)", 
					dataField : "sale_amt",					
					width : "100", 
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0"
				}
			];
			
			// 푸터 설정
			var footerLayout = [
				{
					labelText : "합계",
					positionField : "part_name",
					style : "aui-right aui-footer"
				},
				{
					dataField : "qty",
					positionField : "qty",
 					operation : "SUM",
					formatString : "#,##0",
					style: "aui-right aui-footer",
				},
				{
					dataField : "total_amt",
					positionField : "total_amt",
 					operation : "SUM",
					formatString : "#,##0",
					style: "aui-right aui-footer",
				},
				{
					dataField : "total_amt_vat",
					positionField : "total_amt_vat",
 					operation : "SUM",
					formatString : "#,##0",
					style: "aui-right aui-footer",
				},
				{
					dataField : "sale_amt",
					positionField : "sale_amt",
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