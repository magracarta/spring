<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 정산 > 대리점월정산 > null > 클레임 비용정산처리
-- 작성자 : 황빛찬
-- 최초 작성일 : 2020-04-08 18:03:57
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGrid();
		});
		
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				// No. 제거
				showRowNumColumn: true,
				editable : false,
				showFooter : true,
				footerPosition : "top",
				enableMovingColumn : false
			};
			var columnLayout = [
				{
					headerText : "작업일자", 
					dataField : "as_dt", 
					width : "10%",
					dataType : "date",  
					formatString : "yyyy-mm-dd",
					style : "aui-center"
				},
				{ 
					headerText : "차대번호", 
					dataField : "body_no", 
					width : "17%",
					style : "aui-center"
				},
				{ 
					headerText : "상품명", 
					dataField : "machine_name", 
					width : "15%",
					style : "aui-center",
				},
				{ 
					headerText : "처리자", 
					dataField : "reg_mem_name", 
					width : "8%",
					style : "aui-center",
				},
				{ 
					headerText : "부품비용", 
					dataField : "part_margin_amt",
					width : "10%",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right",
				},
				{ 
					headerText : "출장비용", 
					dataField : "travel_expense", 
					width : "10%",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right",
				},
				{ 
					headerText : "공임", 
					dataField : "work_total_amt", 
					width : "10%",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right",
				},
				{ 
					headerText : "부가세", 
					dataField : "vat_amt", 
					width : "10%",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right",
				},
				{ 
					headerText : "합계", 
					dataField : "totalamount", 
					width : "10%",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right",
				}
			];
			// 푸터레이아웃
			var footerColumnLayout = [ 
				{
					labelText : "합계",
					positionField : "reg_mem_name",
					style : "aui-center aui-footer",
				}, 
				{
					dataField : "part_margin_amt",
					positionField : "part_margin_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "travel_expense",
					positionField : "travel_expense",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "work_total_amt",
					positionField : "work_total_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "totalamount",
					positionField : "totalamount",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				}
			];
			
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 푸터 객체 세팅
			AUIGrid.setFooter(auiGrid, footerColumnLayout);
			AUIGrid.setGridData(auiGrid, ${list});
			$("#auiGrid").resize();
			$("#total_cnt").html(AUIGrid.getGridData(auiGrid).length);
		}
		
		// 닫기
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
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
<!-- 폼테이블 -->					
			<div>
				<div class="title-wrap">
					<h4>${orgName}<span>&nbsp;클레임처리내역</span></h4>
				</div>
				<div id="auiGrid" style="margin-top: 5px; height: 400px;"></div>
			</div>
<!-- /폼테이블-->					
			<div class="btn-group mt10">
				<div class="left">
					총 <strong id="total_cnt" class="text-primary">0</strong>건
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