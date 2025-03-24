<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 부품조회 > 부품재고조회 > 부품재고상세 > 부품이동 조회
-- 작성자 : 박예진
-- 최초 작성일 : 2021-02-24 16:40:29
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
				headerText : "이동처리번호", 
				dataField : "part_trans_no", 
				width : "130",
				minWidth : "130",
				style : "aui-center aui-popup",
			},
			{ 
				headerText : "처리일자", 
				dataField : "reg_dt", 
				width : "100",
				minWidth : "100",
				dataType : "date",
				formatString : "yyyy-mm-dd",
				style : "aui-center",
			},
			{
				headerText : "From 창고", 
				dataField : "from_warehouse_name", 
				width : "100",
				minWidth : "100",
				style : "aui-center"
			},
			{ 
				headerText : "To 창고", 
				dataField : "to_warehouse_name", 
				width : "100",
				minWidth : "100",
				style : "aui-center"
			},
			{ 
				headerText : "이동수량", 
				dataField : "trans_qty", 
				width : "85",
				minWidth : "85",
				dataType : "numeric",
				formatString : "#,##0",
				style : "aui-center",
			},
			{ 
				headerText : "처리자", 
				dataField : "reg_mem_name", 
				width : "80",
				minWidth : "80",
				style : "aui-center",
			},
			{ 
				headerText : "부품 순번", 
				dataField : "seq_no", 
				width : "65",
				minWidth : "65",
				style : "aui-center",
			},
			{ 
				dataField : "from_warehouse_cd", 
				visible : false
			},
			{ 
				dataField : "to_warehouse_cd", 
				visible : false
			}
		];
		
		
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);

		AUIGrid.setGridData(auiGrid, ${list});
		AUIGrid.bind(auiGrid, "cellClick", function(event) {
			var popupOption = "";
			var param = {
				"part_trans_no" : event.item["part_trans_no"]
			};
			if(event.dataField == 'part_trans_no') {
				$M.goNextPage('/part/part0202p03', $M.toGetParam(param), {popupStatus : popupOption});
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
					<h4>부품이동 목록 (${inputParam.part_no})</h4>
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