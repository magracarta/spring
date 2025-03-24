<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 서비스관리 > 서비스비용설정 > null > 변경이력
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
			fnExportExcel(auiGrid, "변경이력", "");
		}
		
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
			};
			var columnLayout = [
				{ 
					headerText : "결정일자", 
					dataField : "svc_dt", 
					dataType : "date",  
					style : "aui-center",
					width : "80",
					minWidth : "80",
					formatString : "yy-mm-dd"
				},
				{
					headerText : "최저판매가", 
					dataField : "min_sale_price", 
					width : "90",
					minWidth : "90",
					style : "aui-right",
					dataType : "numeric",
				},
				{
					headerText : "서비스비용설정(%)", 
					dataField : "ba_svc_rate", 
					width : "120",
					minWidth : "120",
					style : "aui-right",
					dataType : "numeric",
				},
				{
					headerText : "서비스비용", 
					dataField : "ba_svc_amt", 
					width : "120",
					minWidth : "120",
					style : "aui-right",
					dataType : "numeric",
				},
				{
					headerText : "출하비용설정(%)", 
					dataField : "out_cost_rate", 
					width : "120",
					minWidth : "120",
					style : "aui-right",
					dataType : "numeric",
				},
				{
					headerText : "출하비용", 
					dataField : "out_cost_amt", 
					width : "120",
					minWidth : "120",
					style : "aui-right",
					dataType : "numeric",
				},
				{
					headerText : "무상비용설정(%)", 
					dataField : "free_cost_rate", 
					width : "120",
					minWidth : "120",
					style : "aui-right",
					dataType : "numeric",
				},
				{
					headerText : "무상비용", 
					dataField : "free_cost_amt", 
					width : "90",
					minWidth : "90",
					style : "aui-right",
					dataType : "numeric",
				},
				{
					headerText : "정산이력건수", 
					dataField : "svc_his_cnt", 
					width : "90",
					minWidth : "90",
					style : "aui-center aui-popup",
					dataType : "numeric",
				},
				{
					headerText : "비고", 
					dataField : "remark", 
					width : "250",
					minWidth : "250",
					style : "aui-left",
				},
				{
					dataField : "svc_cost_seq",
					visible : false
				}
			];
		
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, ${list});
			
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == "svc_his_cnt" ) {
	 				var params = {
	 					"machine_plant_seq" : "${inputParam.machine_plant_seq}",
	 					"svc_cost_seq" : event.item.svc_cost_seq
					};
	 				var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=800, left=0, top=0";
	 				$M.goNextPage('/serv/serv0512p02', $M.toGetParam(params), {popupStatus : popupOption});
				}
			});	
			
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