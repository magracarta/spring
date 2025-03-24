<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 거래현황 > 일계표 > null > 전표세부내역
-- 작성자 : 박예진
-- 최초 작성일 : 2020-04-28 09:08:26
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGrid();
			fnInit();
		});
		
		function fnInit() {
			var list = ${list};
			console.log(list);
			
			$("#inout_doc_no").text(list.inout_doc_no);
			$("#cust_name").text(list.cust_name + "님");
		}
		
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
					rowIdField : "row_id",
					showStateColumn : false,
					// No. 제거
					showRowNumColumn: true,
					showBranchOnGrouping : false,
					showFooter : true,
					footerPosition : "top",
					editable : false
				};
			var columnLayout = [
				{
					headerText : "상호", 
					dataField : "breg_name", 
					width : "12%",
					style : "aui-center"
				},
				{ 
					headerText : "구분", 
					dataField : "inout_type_name", 
					width : "6%",
					style : "aui-center"
				},
				{ 
					headerText : "작성자", 
					dataField : "mem_name", 
					width : "6%",
					style : "aui-center",
				},
				{ 
					headerText : "부품번호", 
					dataField : "item_id", 
					width : "10%",
					style : "aui-center",
				},
				{ 
					headerText : "품명", 
					dataField : "item_name", 
					style : "aui-left",
				},
				{ 
					headerText : "수량", 
					dataField : "qty", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "6%",
					style : "aui-center",
				},
				{ 
					headerText : "단가", 
					dataField : "unit_price", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "8%",
					style : "aui-right",
				},
				{ 
					headerText : "금액", 
					dataField : "amt", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "8%",
					style : "aui-right",
				},
				{ 
					headerText : "세액", 
					dataField : "vat_amt", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "8%",
					style : "aui-right",
				},
// 				{ 
// 					headerText : "합계금액", 
// 					dataField : "total_amt", 
// 					dataType : "numeric",
// 					formatString : "#,##0",
// 					width : "8%",
// 					style : "aui-right",
// 				},
				{ 
					headerText : "전 재고", 
					dataField : "current_all_qty", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "6%",
					style : "aui-center",
				},
				{
					dataField : "inout_doc_no",
					visible : false
				},
				{
					dataField : "inout_type_cd",
					visible : false
				},
				{
					dataField : "mem_no",
					visible : false
				}
			];
			
			// 푸터레이아웃
			var footerColumnLayout = [ 
				{
					labelText : "합계",
					positionField : "qty",
					style : "aui-center aui-footer",
// 					colSpan : 6
				}, 
				{
					dataField : "unit_price",
					positionField : "unit_price",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "amt",
					positionField : "amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "vat_amt",
					positionField : "vat_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
// 				{
// 					dataField : "total_amt",
// 					positionField : "total_amt",
// 					operation : "SUM",
// 					formatString : "#,##0",
// 					style : "aui-right aui-footer",
// 				}
			];
			
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 푸터 객체 세팅
			AUIGrid.setFooter(auiGrid, footerColumnLayout);
			AUIGrid.setGridData(auiGrid, ${list});
			$("#auiGrid").resize();
		}
	
		function fnDownloadExcel() {
			  // 엑셀 내보내기 속성
			  var exportProps = {
			  };
			  fnExportExcel(auiGrid, "전표세부내역", exportProps);
		}
		
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
					<div class="left">
						<h4>
							<span>
								<span class="text-default bd0 pr5">전표번호 : </span>
								${inputParam.inout_doc_no}
							</span>
							<span class="ver-line">
								<span class="text-default bd0 pr5">고객명 : </span>
								${cust_name}님
							</span>
						</h4>
					</div>
					<div class="right">						
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
					</div>
				</div>						
				<div id="auiGrid" style="margin-top: 5px; height: 300px;"></div>
			</div>		
<!-- /폼테이블 -->
			<div class="btn-group mt10">
				<div class="left">
					총 <strong class="text-primary">${total_cnt}</strong>건
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