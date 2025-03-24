<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 자산 > 법인차량관리 > null > 하이패스카드
-- 작성자 : 박준영
-- 최초 작성일 : 2020-04-17 17:14:22
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>
	

	var auiGrid;
	$(document).ready(function() {
		createAUIGrid();
	});
	
	function createAUIGrid() {
		var gridPros = {
				editable : true,
				// rowIdField 설정
				rowIdField : "_$uid", 
				// rowIdField가 unique 임을 보장
				//rowIdTrustMode : true,
				// rowNumber 
				showRowNumColumn : true,
				enableSorting : true,
				showStateColumn : true
		};
		var columnLayout = [
			{
				headerText : "카드코드",
				dataField : "card_code",
				width : "15%",
				style : "aui-center",
				editable : false
			},

			{
				headerText : "카드번호",
				dataField : "card_no",
				width : "25%",
				style : "aui-center",
				editable : false
			},
			{
				headerText : "카드명",
				dataField : "card_name",
				width : "30%",
				style : "aui-center",
				editable : false
			},			
			{
				headerText : "부서",
				dataField : "org_name",
				width : "15%",
				style : "aui-center",
				editable : false
			},
			{
				headerText : "사용자명",
				dataField : "kor_name",
				width : "15%",
				editable : false
			}	
		]
		// 실제로 #grid_wrap 에 그리드 생성
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		AUIGrid.setGridData(auiGrid, hipassCardListJson);	
		$("#auiGrid").resize();
	
		AUIGrid.bind(auiGrid, "cellClick", function(event) {	
			try {
				opener.${inputParam.parent_js_name}(event.item);
				window.close(); 
			} catch(e) {
				alert("호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.");
			}
				
		});	
		
		var cnt = AUIGrid.getGridData(auiGrid).length;
		$("#total_cnt").html(cnt);
	}
		
	function fnClose() {
		window.close(); 
	}	
	
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">

<!-- 팝업 -->
    <div class="popup-wrap width-100per" >
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
<!-- 폼테이블 -->					
			<div>
				<div class="title-wrap">
					<h4>카드목록</h4>
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
					</div>
				</div>
				<div id="auiGrid" style="margin-top: 5px; height: 200px;"></div>
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