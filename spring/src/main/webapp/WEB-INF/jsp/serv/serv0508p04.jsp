<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 서비스관리 > Yammar가동현황(SA-R) > null > 분류별 SA-R장비 목록
-- 작성자 : 이강원
-- 최초 작성일 : 2021-09-17 14:23:48
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
	
	//엑셀다운로드
	function fnDownloadExcel() {
		fnExportExcel(auiGrid, "분류별 SA-R장비 목록", "");
	}
	
	//그리드생성
	function createAUIGrid() {
		var gridPros = {
			rowIdField : "_$uid",
			showRowNumColumn: true,
			editable : false,
		};
		var columnLayout = [
			{
				headerText : "고객명",
				dataField : "cust_name",
				style : "aui-center",
				width : "120",
				minWidth : "120",
			},
			{
				headerText : "모델",
				dataField : "machine_name",
				style : "aui-center",
				width : "90",
				minWidth : "90",
			},
			{
				headerText : "차대번호",
				dataField : "body_no",
				style : "aui-center",
				width : "100",
				minWidth : "100",
			},
			{
				headerText : "가동시간(SA-R)",
				dataField : "run_time",
				style : "aui-center",
				width : "90",
				minWidth : "90",
				labelFunction : function(rowIndex, columnIndex, value, headerText, item){
					return value == 0 ? value : $M.setComma(value);
				},
			},
			{
				headerText : "판매일자",
				dataField : "sale_dt",
				dataType : "date",
				formatString : "yy-mm-dd",
				style : "aui-center",
				width : "90",
				minWidth : "90",
			},
			{
				headerText : "담당센터",
				dataField : "center_org_name",
				style : "aui-center",
				width : "90",
				minWidth : "90",
			},
			{
				headerText : "지역",
				dataField : "area_do",
				width : "90",
				minWidth : "90",
			},
		];
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		AUIGrid.setGridData(auiGrid, ${list});
		
		$("#auiGrid").resize();
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
			<div class="title-wrap">		
				<h4>분류 : ${inputParam.gubun_type } 장비목록</h4>
				<div class="btn-group mt5">
					<div class="right">
						<div class="right text-warning">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
                    	</div>
						
					</div>
               	</div>
			</div>	
			<div id="auiGrid" style="margin-top: 5px; height: 300px;"></div>
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
<!-- /상단 폼테이블 -->
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>