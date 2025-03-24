<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 서비스관리 > 서비스비용설정 > null > 잔여서비스비용 정산이력
-- 작성자 : 김태훈
-- 최초 작성일 : 2021-08-10 13:42:37
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		$(document).ready(function() {
			createAUIGrid();
		});

		//엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "잔여서비스비용 정산이력", "");
		}
		
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showFooter : true,
				footerPosition : "top",
			};
			var columnLayout = [
				{
					headerText : "차대번호", 
					dataField : "body_no", 
					width : "150",
					minWidth : "150",
					style : "aui-center",
				},
				{
					headerText : "출하센터", 
					dataField : "in_org_name", 
					width : "60",
					minWidth : "60",
					style : "aui-center",
				},
				{ 
					headerText : "출하일자", 
					dataField : "out_dt", 
					dataType : "date",  
					style : "aui-center",
					width : "80",
					minWidth : "80",
					formatString : "yy-mm-dd"
				},
				{
					headerText : "서비스비용", 
					dataField : "ba_svc_amt", 
					width : "120",
					minWidth : "120",
					style : "aui-right",
					dataType : "numeric",
				},
				/* {
					headerText : "출하비용배정", 
					dataField : "out_cost_amt1", 
					width : "120",
					minWidth : "120",
					style : "aui-right",
					dataType : "numeric",
				}, */
				{
					headerText : "출하비용", 
					dataField : "out_cost_amt", 
					width : "120",
					minWidth : "120",
					style : "aui-right",
					dataType : "numeric",
				},
				/* {
					headerText : "무상정비비용배정", 
					dataField : "free_cost_amt1", 
					width : "120",
					minWidth : "120",
					style : "aui-right",
					dataType : "numeric",
				}, */
				{
					headerText : "무상정비비용", 
					dataField : "free_cost_amt", 
					width : "120",
					minWidth : "120",
					style : "aui-right",
					dataType : "numeric",
				},
				{
					headerText : "잔액", 
					dataField : "balance", 
					width : "90",
					minWidth : "90",
					style : "aui-right",
					dataType : "numeric",
				},
				{
					headerText : "담당센터", 
					dataField : "center_org_name", 
					width : "90",
					minWidth : "90",
					style : "aui-center",
				},
				{
					headerText : "서비스담당자", 
					dataField : "service_mem_name", 
					width : "90",
					minWidth : "90",
					style : "aui-center",
				},
			];
			
			// 푸터 설정
			var footerLayout = [
				{
					labelText : "합계",
					positionField : "out_dt",
					style : "aui-right"
				},
				{
					dataField : "ba_svc_amt",
					positionField : "ba_svc_amt",
 					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right"
				},
				{
					dataField : "out_cost_amt",
					positionField : "out_cost_amt",
 					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right"
				},
				{
					dataField : "free_cost_amt",
					positionField : "free_cost_amt",
 					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right"
				},
				{
					dataField : "balance",
					positionField : "balance",
 					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right"
				},
			];
		
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, ${list});
			// 푸터 레이아웃 세팅
			AUIGrid.setFooter(auiGrid, footerLayout);
			$("#auiGrid").resize();
		}
		
		// 팝업 닫기
		function fnClose() {
			window.close();
		}
	
	</script>
</head>
<body class="bg-white class">
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
					<h4>${machine_name}</h4>
	                <div class="btn-group mt5">
						<div class="right">
							<div class="right text-warning">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
	                    	</div>
							
						</div>
                	</div>
				</div>
				<div id="auiGrid" style="margin-top: 5px; height: 350px;"></div>				
			</div>
<!-- /폼테이블 -->	
<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">	
				<div class="left">
					총 <strong class="text-primary">${total_cnt}</strong>건
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