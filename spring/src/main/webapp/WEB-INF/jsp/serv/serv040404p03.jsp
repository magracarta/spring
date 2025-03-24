<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 고객관리 > 전화업무 통합관리 > Happy Call > 발송현황
-- 작성자 : 최보성
-- 최초 작성일 : 2020-04-07 19:54:29
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
	
	//그리드생성
	function createAUIGrid() {
		var gridPros = {
			rowIdField : "row",
			showRowNumColumn: true,
		};
		var columnLayout = [
			{ 
				headerText : "발송일", 
				dataField : "sms_send_dt", 
				style : "aui-center",
				dataType : "date",
				formatString : "yyyy-mm-dd",
			},
			{
				headerText : "제목", 
				dataField : "survey_title", 
				style : "aui-left"
			},
			{ 
				headerText : "문항수", 
				dataField : "ques_cnt", 
				style : "aui-center"
			},
			{ 
				headerText : "대상고객", 
				dataField : "cust_cnt", 
				style : "aui-center",
			},
			{ 
				headerText : "발송성공", 
				dataField : "sms_send_y_cnt", 
				style : "aui-center",
			},
			{ 
				headerText : "발송실패", 
				dataField : "sms_send_n_cnt", 
				style : "aui-center",
			},
			{ 
				headerText : "응답수", 
				dataField : "reply_y_cnt", 
				style : "aui-center",
			},
			{ 
				headerText : "응답률", 
				dataField : "reply_rate", 
				style : "aui-center",
			},
		];
		
		
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		AUIGrid.setGridData(auiGrid, ${list});
		
		$("#auiGrid").resize();

		// 만약 칼럼 사이즈들의 총합이 그리드 크기보다 작다면, 나머지 값들을 나눠 가져 그리드 크기에 맞추기
		var colSizeList = AUIGrid.getFitColumnSizeList(auiGrid, true);

		// 구해진 칼럼 사이즈를 적용 시킴.
		AUIGrid.setColumnSizeList(auiGrid, colSizeList);
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
					<h4>발송목록</h4>
				</div>
				<div id="auiGrid" style="margin-top: 5px; height: 300px;"></div>
			</div>
<!-- /폼테이블-->					
			<div class="btn-group mt10">
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">${total_cnt }</strong>건
				</div>	
				<div class="right">
					<button type="button" class="btn btn-info" onclick="javascript:fnClose();">닫기</button>
				</div>
			</div>
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>