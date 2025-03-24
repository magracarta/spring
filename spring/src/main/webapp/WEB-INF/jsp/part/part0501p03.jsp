<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 재고관리 > 센터별부품관리 > null > 저장위치변경이력
-- 작성자 : 박준영
-- 최초 작성일 : 2020-09-16 18:10:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		
		$(document).ready(function() {
			createAUIGrid();
		});
		
		function createAUIGrid() {
			var gridPros = {
				// rowIdField 설정
				rowIdField : "_$uid",
				// rowNumber 
				showRowNumColumn: true,
				// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
				wrapSelectionMove : false,
				// 테두리 제거
				showSelectionBorder : false,
				editable : true,
			};
			var columnLayout = [
				{ 
					headerText : "변경일자", 
					dataField : "change_dt", 
					dataType : "date",
					formatString : "yy-mm-dd", 
					width : "15%", 
					style : "aui-center",
					editable : false
				},
				{ 
					headerText : "변경자", 
					dataField : "reg_mem_name", 
					width : "11%", 
					style : "aui-center",
					editable : false
				},
				{ 
					headerText : "변경 전", 
					dataField : "before_value", 
					width : "37%", 
					style : "aui-center",
					editable : false
				},
				{ 
					headerText : "변경 후", 
					dataField : "after_value", 
					style : "aui-center",
					editable : false
				}
			];

			// 그리드 출력
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, ${partStorageChengeHislist});
			
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
					<h4>${inputParam.part_no} (${inputParam.part_name})</h4>
				</div>
				<div id="auiGrid" style="margin-top: 5px; height: 260px;"></div>
			</div>
<!-- /폼테이블 -->	
<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">	
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">${total_cnt}</strong>건
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