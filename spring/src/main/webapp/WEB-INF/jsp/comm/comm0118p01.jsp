<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 기준정보 > 로그정보 > null > 로그상세
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-03-13 13:53:27
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
			rowIdField : "_$uid",
			showRowNumColumn : true,
			// 전체 체크박스 표시 설정
			//체크박스 출력 여부
			/* showRowCheckColumn: true,
			//전체선택 체크박스 표시 여부
			showRowAllCheckBox : true, */
		};
		// AUIGrid 칼럼 설정
		var columnLayout = [
			{
				headerText: "페이지명",
			    dataField: "path_menu_name",
				width : "300",
				minWidth : "50",
				style : "aui-left"
			},
			{
				headerText: "생성",
			    dataField: "create_cnt",
				width : "80",
				minWidth : "30",
				labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
					return value == "0" ? "X" : "O";
				},
			},
			{
				headerText: "수정",
			    dataField: "update_cnt",
				width : "80",
				minWidth : "30",
				labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
					return value == "0" ? "X" : "O";
				},
			},
			{
				headerText: "조회",
			    dataField: "read_cnt",
				width : "80",
				minWidth : "30",
				labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
					return value == "0" ? "X" : "O";
				},
			},
			{
				headerText: "삭제",
			    dataField: "delete_cnt",
				width : "80",
				minWidth : "30",
				labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
					return value == "0" ? "X" : "O";
				},
			},
			{
				headerText: "엑셀다운로드",
			    dataField: "excel_down_cnt",
				width : "80",
				minWidth : "30",
				labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
					return value == "0" ? "X" : "O";
				},
			},
			{
				headerText: "다운로드 일시",
				dataField: "last_excel_down_date",
				width : "200",
				minWidth : "30",
			}
		];
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		
		<c:if test="${not empty list}">
			var list = ${list}
			AUIGrid.setGridData(auiGrid, list);
			$("#total_cnt").html(list.length);
		</c:if>
		
		AUIGrid.resize(auiGrid);
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
            <h2>로그상세</h2>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">		
			<div class="title-wrap">
				<h4>
                    <span>
                        ${inputParam.log_st_date } ~ ${inputParam.log_ed_date}
                    </span>
                    <span class="ver-line">
                        ${inputParam.org_name }
                    </span>
                    <span class="ver-line">
                      	${inputParam.kor_name }
                    </span>
                </h4>
			</div>
<!-- 폼테이블 -->					
<!-- /폼테이블 -->
<!-- 그리드 서머리, 컨트롤 영역 -->
			<div id="auiGrid" style="margin-top: 5px; height: 430px;"></div>
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