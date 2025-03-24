<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 부품조회 > 부품재고조회 > 부품재고상세 > 선주문전표 조회
-- 작성자 : 박예진
-- 최초 작성일 : 2021-09-02 20:00:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

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
		};
		
		var columnLayout = [
			{ 
				headerText : "선주문전표번호", 
				dataField : "inout_doc_no", 
				width : "130",
				minWidth : "130",
				style : "aui-center aui-popup",
			},
			{ 
				headerText : "전표일자", 
				dataField : "inout_dt", 
				width : "110",
				minWidth : "110",
				dataType : "date",
				formatString : "yyyy-mm-dd",
				style : "aui-center",
			},
			{
				headerText : "처리센터", 
				dataField : "inout_org_name", 
				width : "120",
				minWidth : "120",
				style : "aui-center"
			},
			{ 
				headerText : "선주문수량", 
				dataField : "qty", 
				dataType : "numeric",
				formatString : "#,##0",
				width : "80",
				minWidth : "80",
				style : "aui-center",
			},
			{ 
				headerText : "미 처리수량", 
				dataField : "preorder_qty", 
				dataType : "numeric",
				formatString : "#,##0",
				width : "80",
				minWidth : "80",
				style : "aui-center",
			},
			{
				headerText : "배송상태", 
				dataField : "preorder_status", 
				width : "130",
				minWidth : "130",
				style : "aui-center"
			}
		];
		
		
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);

		AUIGrid.setGridData(auiGrid, ${list});
		AUIGrid.bind(auiGrid, "cellClick", function(event) {
			if(event.dataField == 'inout_doc_no') {
				var popupOption = "";
				var param = {
					"inout_doc_no" : event.item["inout_doc_no"]
				};
				$M.goNextPage('/part/part0204p01', $M.toGetParam(param), {popupStatus : popupOption});
			};
		});
		
		$("#auiGrid").resize();

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
					<h4>선주문전표 목록 (${inputParam.part_no})</h4>
				</div>
				<div id="auiGrid" style="margin-top: 5px; height: 300px;"></div>
			</div>
<!-- /폼테이블-->					
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