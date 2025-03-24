<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > MS관리 > MS관리-지역별 & 시도별 & 센터별 > null > MS리스트
-- 작성자 : 성현우
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		
		$(document).ready(function() {
			createAUIGrid();
			fnInit();
		});

		function fnInit() {
			var totCnt = ${size};
			$("#total_cnt").html(totCnt);
		}
		
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "MS리스트");
		}
		
		function fnClose() {
			window.close(); 
		}
		
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "row_id",
			};
			var columnLayout = [
				{ 
					headerText : "연월", 
					dataField : "ms_mon",
					dataType : "date",  
					formatString : "yyyy-mm",
					width : "10%", 
					style : "aui-center"
				},
				{ 
					headerText : "메이커", 
					dataField : "maker_name",
					width : "10%", 
					style : "aui-center",
				},
				{
					headerText : "메이커코드",
					dataField : "maker_cd",
					visible : false
				},
				{ 
					headerText : "형식",
					dataField : "ms_machine_name",
					width : "10%", 
					style : "aui-center"
				},
				{
					headerText : "중량", 
					dataField : "ms_std_name",
					width : "10%", 
					style : "aui-center"
				},
				{ 
					headerText : "수량", 
					dataField : "qty",
					width : "10%", 
					style : "aui-center"
				},
				{
					headerText : "규격명", 
					dataField : "ms_machine_sub_type_name",
					width : "10%", 
					style : "aui-center",
				},
				{
					headerText : "규격코드",
					dataField : "ms_machine_sub_type_cd",
					visible : false
				},
				{
					headerText : "센터",
					dataField : "center_org_name",
					width : "10%",
					style : "aui-center",
				},
				{
					headerText : "담당자",
					dataField : "sale_mem_name",
					width : "10%",
					style : "aui-center",
				},
				{ 
					headerText : "지역명", 
					dataField : "area_name",
					style : "aui-left",
				}
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, ${msList});
			$("#auiGrid").resize();

			// MS-센터별이 아닐경우 '센터' '담당자' 컬럼 숨김
			if ($.isEmptyObject(${msList}[0].sale_mem_name)) {
				AUIGrid.hideColumnByDataField(auiGrid, "sale_mem_name");
			}
			if ($.isEmptyObject(${msList}[0].center_org_name)) {
				AUIGrid.hideColumnByDataField(auiGrid, "center_org_name");
			}
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
				<h4>${title}</h4>
				<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
			</div>

			<div id="auiGrid" style="margin-top: 5px;"></div>

<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">0</strong>건
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