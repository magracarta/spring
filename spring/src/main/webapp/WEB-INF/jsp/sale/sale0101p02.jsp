<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 계약관리 > 계약/출하 > null > 기본지급품
-- 작성자 : 김태훈
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		
		$(document).ready(function() {
			createAUIGrid();
		});
		
		function fnClose() {
			window.close(); 
		}
		
		function goPartPrint() {
			openReportPanel('sale/sale0101p02_01.crf','machine_plant_seq=${inputParam.machine_plant_seq}');
		}
		
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				fillColumnSizeMode : false,
				rowHeight	: 80
			};
			var columnLayout = [
				{ 
					headerText : "품명", 
					dataField : "item_name",   
					width : "70", 
					style : "aui-center",
				},
				{ 
					headerText : "수량", 
					dataField : "qty",
					width : "50", 
					style : "aui-center"
				},
				{
					headerText : "비고", 
					dataField : "remark", 
					width : "350", 
					style : "aui-left"
				},
				{ 
					headerText : "사진", 
					prefix : "/file/",
					dataField : "file_seq", 
					style : "aui-center",
					renderer : {
						type : "ImageRenderer",
						altField : null, 
					}
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, ${list});
			// AUIGrid.setFixedColumnCount(auiGrid, 6);
			$("#auiGrid").resize();
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
					<h4 class="primary">기본지급품목록</h4>
					<div>
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>		
					</div>
				</div>
				<div id="auiGrid" style="margin-top: 5px; height: 350px"></div>		
			</div>
<!-- /폼테이블 -->	
<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">						
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