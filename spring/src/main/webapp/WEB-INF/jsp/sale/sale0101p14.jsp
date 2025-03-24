<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 계약관리 > 계약/출하 > null > 출하증명서 발급이력
-- 작성자 : 김태훈
-- 최초 작성일 : 2021-04-09 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
<script type="text/javascript">
<%-- 여기에 스크립트 넣어주세요. --%>

	$(document).ready(function() {
		createAUIGrid();
	});


	function fnClose() {
		window.close();
	}
	
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
				headerText: "발급일",
			    dataField: "print_dt",
			    dataType : "date",  
				width : "70",
				minWidth : "50",
				style : "aui-center",
				formatString : "yy-mm-dd"
			},
			{
				headerText: "기종명",
			    dataField: "machine_type_name",
				width : "80",
				minWidth : "30",
			},
			{
				headerText: "모델명",
			    dataField: "machine_name",
				width : "80",
				minWidth : "30",
			},
			{
				headerText: "엔진번호",
			    dataField: "engine_no_1",
				width : "80",
				minWidth : "30",
			},
			{
				headerText: "년식",
			    dataField: "made_dt",
				width : "80",
				minWidth : "30"
			},
			{
				headerText: "사용유종",
			    dataField: "use_oil",
				width : "80",
				minWidth : "30",
			},
			{
				headerText: "총중량",
				dataField: "total_weight",
				width : "100",
				minWidth : "30",
			},
			{
				headerText: "상용출력",
				dataField: "normal_power",
				width : "80",
				minWidth : "30",
			},
			{
				headerText: "규격",
				dataField: "mch_std",
				width : "80",
				minWidth : "30",
			},
			{
				headerText: "제조번호",
				dataField: "serial_no",
				width : "150",
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

</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form" autocomplete="off">
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
                        	발급이력
                    </span>
                </h4>
			</div>
<!-- 폼테이블 -->					
<!-- /폼테이블 -->
<!-- 그리드 서머리, 컨트롤 영역 -->
			<div id="auiGrid"></div>
			<div class="btn-group mt5">	
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">0</strong>건
				</div>
				<div class="right">
					<button type="button" class="btn btn-info" onclick="javascript:fnClose()">닫기</button>
				</div>
			</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
        </div>
    </div>
<!-- /팝업 -->
</form>
</html>