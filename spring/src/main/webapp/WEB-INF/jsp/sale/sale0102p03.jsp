<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 계약관리 > 출하명세서-보유장비대비 > null > 송금예정
-- 작성자 : 손광진
-- 최초 작성일 : 2020-09-18 14:23:48
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
			fnExportExcel(auiGrid, "송금예정", "");
		}
		
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
			};
			var columnLayout = [
				{
					dataField : "aui_status_cd",
					visible: false
				},
				{
					headerText : "선적발주번호", 
					dataField : "machine_ship_no", 
					width : "8%", 
					style : "aui-center",
				},
				{
					headerText : "관리번호", 
					dataField : "machine_lc_no", 
					width : "8%", 
					style : "aui-center",
				},
				{ 
					headerText : "PART NO.", 
					dataField : "machine_name", 
					width : "10%", 
					style : "aui-center"
				},
				{ 
					headerText : "Q'ty", 
					dataField : "qty", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "5%", 
					style : "aui-center"
				},
				{ 
					headerText : "송금예정일", 
					dataField : "remit_plan_dt", 
					dataType : "date",  
					width : "7%", 
					style : "aui-center", 
					formatString : "yyyy-mm-dd"
				},		
				{ 
					headerText : "ETD", 
					dataField : "etd", 
					dataType : "date",  
					width : "7%", 
					style : "aui-center",
					formatString : "yyyy-mm-dd"
				},
				{ 
					headerText : "ETA", 
					dataField : "eta", 
					dataType : "date",  
					width : "7%", 
					style : "aui-center",
					formatString : "yyyy-mm-dd"
				},
				{ 
					headerText : "U/Price", 
					dataField : "unit_price", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "9%", 
					style : "aui-right"
				},
				{ 
					headerText : "Amount", 
					dataField : "order_total_amt", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "9%", 
					style : "aui-right"
				},
				{ 
					headerText : "Option", 
					dataField : "opt_kor_name",
					style : "aui-center"
				},
				{ 
					headerText : "발주일자", 
					dataField : "order_dt", 
					dataType : "date",  
					style : "aui-center",
					width : "7%", 
					formatString : "yyyy-mm-dd"
				}
			];
		
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, listJson);
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
					<h4>송금예정목록</h4>
	                <div class="btn-group mt5">
						<div class="right">
							<div class="right text-warning">
                      			※ 사후송금은 녹색으로 표시됩니다.
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