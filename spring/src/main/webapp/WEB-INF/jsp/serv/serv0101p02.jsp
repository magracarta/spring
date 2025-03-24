<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 정비 > 정비지시서 > null > 쿠폰사용이력
-- 작성자 : 성현우
-- 최초 작성일 : 2020-07-02 19:54:29
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
	
	function goSearch() {
		var machineSeq = '${inputParam.s_machine_seq}';
		var params = {
			"s_machine_seq" : machineSeq
		};

		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(params), {method : 'GET'},
				function (result) {
					if(result.success) {
						AUIGrid.setGridData(auiGrid, result.list);
					}
				}
		);
	}
	
	//그리드생성
	function createAUIGrid() {
		var gridPros = {
			rowIdField : "row",
			showRowNumColumn: true,
			height : 550,
		};
		var columnLayout = [
			{ 
				headerText : "쿠폰세부항목", 
				dataField : "coupon_type_name",
				style : "aui-left"
			},
			{
				headerText : "사용일자", 
				dataField : "apply_date",
				dataType : "date",  
				formatString : "yyyy-mm-dd",
				style : "aui-center"
			},
			{ 
				headerText : "유효기간", 
				dataField : "use_ed_dt",
				dataType : "date",  
				formatString : "yyyy-mm-dd",
				style : "aui-center"
			},
			{ 
				headerText : "정비담당자", 
				dataField : "apply_mem_name",
				style : "aui-center",
			},
		];

		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		AUIGrid.setGridData(auiGrid, []);
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
			<div id="auiGrid" style="margin-top: 5px; height: 300px; "></div>
			<div class="btn-group mt10">
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