<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 매입관리 > 부품매입관리 > null > 기매출단가조회
-- 작성자 : 성현우
-- 최초 작성일 : 2020-09-28 17:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function() {
			createAUIGrid();
		});

		//팝업 닫기
		function fnClose(){
			window.close(); 
		}
		
		function createAUIGrid() {
			//그리드 생성 _ 선택사항
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn: true,
				editable : false
			};

			var columnLayout = [
				{ 
					headerText : "전표번호", 
					dataField : "inout_doc_no",
					width: "20%",
					style : "aui-center"
				},
				{ 
					headerText : "구분", 
					dataField : "inout_type_name",
					width: "15%",
					style : "aui-center",
				},
				{ 
					headerText : "수량", 
					dataField : "qty",
					width: "15%",
					style : "aui-center",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{ 
					headerText : "단가", 
					dataField : "unit_price",
					width: "20%",
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{ 
					headerText : "금액", 
					dataField : "amt",
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0"
				},
			];
			
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
		}
	</script>
</head>
<body class="bg-white class">
<form id="main_form" name="main_form">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">					
			<div id="auiGrid" style="margin-top: 5px; height: 300px;"></div>
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