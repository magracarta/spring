<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 장부 > 자금일보관리 > null > 관리번호
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2020-04-08 18:03:57
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	var auiGrid;
	$(document).ready(function () {
		createAUIGrid();
	});

	function fnClose() {
		window.close();
	}

	function createAUIGrid() {
		var gridPros = {
			// Row번호 표시 여부
			showRowNumColum : true
		};

		var columnLayout = [
			{
				headerText : "관리번호",
				dataField : "deposit_code",
				style : "aui-center",
				width : "15%"
			},
			{
				headerText : "은행명",
				dataField : "deposit_name",
				style : "aui-left",
				width : "30%"
			},
			{
				headerText : "계좌번호",
				dataField : "account_no",
				style : "aui-center"
			},
			{
				headerText : "예금구분",
				dataField : "use_not_text",
				style : "aui-left",
				width : "20%"
			}
		];

		// 실제로 #grid_wrap에 그리드 생성
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		// 그리드 갱신
		AUIGrid.setGridData(auiGrid, ${list});
		
		AUIGrid.bind(auiGrid, "cellClick", function(event) {
			// Row행 클릭 시 반영
			try{
				opener.${inputParam.parent_js_name}(event.item);
				window.close();	
			} catch(e) {
				alert('호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.');
			}
		});	
	}
	</script>
</head>
<body>
<!-- 팝업 -->
<div class="popup-wrap width-100per">
	<!-- 타이틀영역 -->
	<div class="main-title">
		<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
	</div>
	<!-- /타이틀영역 -->
	<div class="content-wrap">
		<!-- 원화 + 외화예금 -->
		<div>
			<div class="title-wrap">
				<h4>관리번호</h4>
			</div>
			<div id="auiGrid" style="margin-top: 5px; height: 300px;"></div>
		</div>
		<!-- /원화 + 외화예금 -->
		<div class="btn-group mt10">
			<div class="right">
				<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
			</div>
		</div>
	</div>
</div>
<!-- /팝업 -->
</body>
</html>