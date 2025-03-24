<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 창고이동/부품출하 > 부품이동요청 > null > 이전발송지
-- 작성자 : 손광진
-- 최초 작성일 : 2020-02-26 14:53:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function() {
			createAUIGrid();
		});
			
		// 그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "part_trans_req_no",
				showRowNumColumn : true,
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
				    headerText: "전표날짜",
				    dataField: "reg_date",
					width : "15%",
					style : "aui-left"
				},
				{
					headerText : "전표번호",
					dataField : "part_no",
					width: "15%",
					style : "aui-center"
				},
				{
				    headerText: "주소",
				    dataField: "part_name",
					width : "35%",
					style : "aui-left"
				},
				{
				    headerText: "고객명",
				    dataField: "current_stock",
					width : "10%",
					style : "aui-left"
				},
				{
				    headerText: "휴대폰",
				    dataField: "req_qty",
					width : "15%",
					style : "aui-left"
				},
				{
				    headerText: "참고",
				    dataField: "",
					style : "aui-left"
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			// 클릭한 셀 데이터 받음
 			AUIGrid.bind(auiGrid, "cellClick", function(event) {
			});
		}
		
		//팝업 닫기
		function fnClose() {
			window.close(); 
		}
	</script>
</head>
<body class="bg-white class">
	<form id="main_form" name="main_form">
		<!-- 팝업 -->
	    <div class="popup-wrap width-100per">
			<!-- 타이틀영역 -->
	        <div class="main-title">
	        	<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp" />
	        </div>
			<!-- /타이틀영역 -->
	        <div class="content-wrap">				
				<div id="auiGrid" style="margin-top: 5px; height: 200px;"></div>
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