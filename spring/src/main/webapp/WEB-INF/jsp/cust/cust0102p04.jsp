<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 고객현황 > 고객조회/등록 > null > 할인쿠폰상세조회 팝업
-- 작성자 : 황빛찬
-- 최초 작성일 : 2021-08-06 10:27:00
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
	var auiGrid;

	$(document).ready(function() {
		createAUIGrid();
	});
	
	// 그리드생성
	function createAUIGrid() {
		var gridPros = {
			rowIdField : "_$uid",
			showRowNumColumn : true,
			enableFilter :true,
			editable : false,
		};
		// AUIGrid 칼럼 설정
		var columnLayout = [
			{
				dataField : "cust_coupon_no",
				visible : false
			},
			{ 
				dataField : "cust_no", 
				visible : false
			},
			{
				headerText: "발행일자",
				dataField: "issue_dt",
				style : "aui-center",
				dataType : "date",  
				dataInputString : "yy-mm-dd",
				formatString : "yy-mm-dd",
				editable : false,
			},
			{ 
				headerText : "전표번호", 
				dataField : "inout_doc_no", 
				style : "aui-center aui-popup",
				labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
					var docNo = value;
					return docNo.substring(4, 16);
				}
			},
// 			{ 
// 				headerText : "고객명", 
// 				dataField : "cust_name", 
// 				width : "95",
// 				minWidth : "90",
// 				style : "aui-center",
// 			},
// 			{ 
// 				headerText : "연락처", 
// 				dataField : "cust_hp_no", 
// 				width : "110",
// 				minWidth : "110",
// 				style : "aui-center"
// 			},
			{ 
				headerText : "쿠폰구분", 
				dataField : "coupon_issue_name", 
				style : "aui-center",
			},
			{ 
				headerText : "쿠폰금액", 
				dataField : "coupon_amt", 
				dataType : "numeric",
				formatString : "#,##0",
				style : "aui-right",
			},
			{ 
				headerText : "쿠폰잔액", 
				dataField : "balance_amt", 
				dataType : "numeric",
				formatString : "#,##0",
				style : "aui-right",
			},
			{ 
				headerText : "소멸예정일", 
				dataField : "expire_plan_dt", 
				dataType : "date",
				formatString : "yy-mm-dd",
				style : "aui-center",
			}
		];
		
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros)
		AUIGrid.setGridData(auiGrid, ${list});
		$("#auiGrid").resize();
		
		AUIGrid.bind(auiGrid, "cellClick", function(event){
			if (event.dataField == "inout_doc_no") {
				var param = {
						cust_coupon_no : event.item.cust_coupon_no
				}
				
				var popupOption = "";
				$M.goNextPage('/cust/cust0305p01', $M.toGetParam(param), {popupStatus : popupOption});
			}
		});
	}	
	
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<div id="auiGrid" style="margin-top: 5px; height: 350px;"></div>
</form>
</body>
</html>