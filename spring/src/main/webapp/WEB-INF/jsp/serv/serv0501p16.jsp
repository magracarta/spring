<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 서비스관리 > 서비스업무평가-개인 > null > 브랜드별 정비시간
-- 작성자 : 이강원
-- 최초 작성일 : 2021-09-24 14:23:48
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
		fnExportExcel(auiGrid, "브랜드별 정비시간", "");
	}
	
	//그리드생성
	function createAUIGrid() {
		var gridPros = {
			rowIdField : "_$uid",
			enableCellMerge: true, // 셀병합 사용여부
			showRowNumColumn: true,
			editable : false,
		};
		var columnLayout = [
			{
				dataField : "mem_no",
				visible : false,
			},
			{
				dataField : "maker_cd",
				visible : false,
			},
			{
				headerText : "사원",
				dataField : "mem_name",
				style : "aui-center",
				cellMerge: true,
				cellColMerge: true, // 셀 가로 병합 실행
				cellColSpan: 2, // 셀 가로 병합 대상은 3개로 설정
				width : "120",
				minWidth : "120",
				labelFunction : function(rowIndex, columnIndex, value, headerText, item){
					if(item.mem_no == ""){
						return "합계";	
					}
					return value;
				}
			},
			{
				headerText : "브랜드",
				dataField : "maker_name",
				style : "aui-center",
				width : "120",
				minWidth : "120",
				labelFunction : function(rowIndex, columnIndex, value, headerText, item){
					if(item.maker_cd == ""){
						return "합계";	
					}
					return value;
				}
			},
			{
				headerText : "정비시간",
				dataField : "tot_hour",
				style : "aui-right",
				width : "100",
				minWidth : "100",
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
				<h4>브랜드별 정비시간</h4>
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