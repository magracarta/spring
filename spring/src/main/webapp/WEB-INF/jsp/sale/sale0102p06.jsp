<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 계약관리 > 출하명세서-보유장비대비 > null > 지정출고 품의서
-- 작성자 : 김태훈
-- 최초 작성일 : 2021-09-03 14:23:48
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
			fnExportExcel(auiGrid, "지정출고 품의서", "");
		}
		
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				height : 565,
				//툴팁 출력 지정
				showTooltip : true,
				//툴팁 마우스 오버 후 100ms 이후 출력시킴. 
				tooltipSensitivity : 100,
			};
			var columnLayout = [
				{ 
					headerText : "관리번호", 
					dataField : "machine_doc_no", 
					width : "90",
					minWidth : "80",
					style : "aui-popup",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
		                  var ret = "";
		                  if (value != null && value != "") {
		                     ret = value.split("-");
		                     ret = ret[0]+"-"+ret[1];
		                     ret = ret.substr(4, ret.length);
		                  }
		                   return ret; 
		               },
				},
				{ 
					headerText : "품의일", 
					dataField : "doc_dt", 
					dataType : "date",
					width : "80",
					minWidth : "80",
					style : "aui-center",
					formatString : "yy-mm-dd",
				},
				{ 
					headerText : "담당자", 
					dataField : "doc_mem_name",
					width : "60",
					minWidth : "60",
					style : "aui-center",
					tooltip : {
						tooltipFunction : fnShowAuigridTooltip
					},
				},
				{ 
					headerText : "고객명", 
					dataField : "cust_name", 
					width : "70",
					minWidth : "60",
					style : "aui-center",
				},
				{ 
					headerText : "차대번호", 
					dataField : "body_no", 
					width : "150",
					minWidth : "90",
					style : "aui-center",
				},
				{
					dataField : "doc_mem_no",
					visible : false
				},
				{
					dataField : "out_org_code",
					visible : false
				},
				{ 
					dataField : "s_mem_no", 
					visible : false
				},
			];

			auiGrid = AUIGrid.create("#auiGrid", initColumnLayout(columnLayout), gridPros);
			AUIGrid.setGridData(auiGrid, listJson);
			AUIGrid.bind(auiGrid, "cellClick", function(event){
				if(event.dataField == "machine_doc_no") {
					var popupOption = "";
					var params = {
						machine_doc_no : event.item.machine_doc_no,
					};
					$M.goNextPage('/sale/sale0101p01', $M.toGetParam(params), {popupStatus : popupOption});					
				};
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
            <button type="button" class="btn btn-icon"></button>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
<!-- 폼테이블 -->					
			<div>
				<div class="title-wrap">
					<h4>${inputParam.machine_name} 지정출고</h4>
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