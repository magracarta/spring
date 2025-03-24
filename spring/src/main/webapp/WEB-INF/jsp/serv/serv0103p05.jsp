<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 정비 > 정비Tool관리 > null > 공구 수량 차이 발생 사유서
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2020-04-07 19:54:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>
	
	var auiGridTop;
	var auiGridBom;
	
	$(document).ready(function() {
		// AUIGrid 생성
		createAUIGridTop();
		createAUIGridBom();
	});
	
	// 그리드생성
	function createAUIGridTop() {
		var gridPros = {
			rowIdField : "row",
			showRowNumColumn: true,
		};
		var columnLayout = [
			{ 
				headerText : "공구명", 
				dataField : "a", 
				style : "aui-left aui-editable",
				width : "25%"
			},
			{
				headerText : "이전", 
				dataField : "b", 
				style : "aui-center"
			},
			{ 
				headerText : "조사", 
				dataField : "c", 
				style : "aui-center"
			},
			{ 
				headerText : "차이", 
				dataField : "d", 
				style : "aui-center",
			},
			{ 
				headerText : "차이발생사유", 
				dataField : "e", 
				style : "aui-left",
				width : "35%"
			},
		];
		
		var testData = [
			{
				"a" : "½ 미리 복스 12",
				"b" : "7",
				"c" : "17",
				"d" : "10",
				"e" : "공구 손망실",
			},
			{
				"a" : "½ 미리 복스 13",
				"b" : "7",
				"c" : "5",
				"d" : "-2",
				"e" : "분실",
			},
		];
		
		auiGridTop = AUIGrid.create("#auiGridTop", columnLayout, gridPros);
		AUIGrid.setGridData(auiGridTop, testData);
		
		AUIGrid.bind(auiGridTop, "cellClick", function(event) {
			if(event.dataField == "a" ) {
				alert("실사이력 출력");
			}
		});	
		
		$("#auiGridTop").resize();
	}	

	// 센터 실사재고 이력 그리드
	function createAUIGridBom() {
		var gridPros = {
			rowIdField : "row",
			showRowNumColumn: true,
			showFooter : true,
			footerPosition : "top",
		};
		var columnLayout = [
			{ 
				headerText : "공구함", 
				dataField : "a", 
				style : "aui-center",
				width : "25%"
			},
			{
				headerText : "이전수량", 
				dataField : "b", 
				style : "aui-center"
			},
			{ 
				headerText : "실사수량", 
				dataField : "c", 
				style : "aui-center"
			},
			{ 
				headerText : "차이수량", 
				dataField : "d", 
				style : "aui-center",
			},
			{ 
				headerText : "비고", 
				dataField : "e", 
				style : "aui-left",
				width : "35%"
			},
		];
		
		var testData = [
			{
				"a" : "센터설비",
				"b" : "2",
				"c" : "1",
				"d" : "1",
				"e" : "공구 손망실",
			},
			{
				"a" : "특수공구",
				"b" : "1",
				"c" : "1",
				"d" : "1",
				"e" : "",
			},
			{
				"a" : "마스터공구함",
				"b" : "2",
				"c" : "1",
				"d" : "1",
				"e" : "손망실",
			},
		];
		
		// 푸터 설정
		var footerLayout = [
			{
				labelText : "총 조사수량",
				positionField : "a"
			},
			{
				dataField: "b",
				positionField: "b",
				operation: "SUM",
				formatString : "#,##0",
				style: "aui-center aui-footer"
			},
			{
				dataField: "c",
				positionField: "c",
				operation: "SUM",
				formatString : "#,##0",
				style: "aui-center aui-footer"
			},
			{
				dataField: "d",
				positionField: "d",
				operation: "SUM",
				formatString : "#,##0",
				style: "aui-center aui-footer"
			},
		];
		
		auiGridBom = AUIGrid.create("#auiGridBom", columnLayout, gridPros);
		AUIGrid.setFooter(auiGridBom, footerLayout);
		AUIGrid.setGridData(auiGridBom, testData);
		
		$("#auiGridBom").resize();
	}
	
	// 저장
	function goSave() {
		alert("저장");
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
<!-- 폼테이블1 -->			
			<div class="title-wrap">
				<h4>차이 발생 건수 : <span class="text-primary font-16">2</span>건</h4>
			</div>
			<div id="auiGridTop" style="margin-top: 5px; height: 150px;"></div>
			<div class="btn-group mt10">						
				<div class="right">
					<button type="button" class="btn btn-info" onclick="javascript:goSave();">저장</button>
				</div>
			</div>
<!-- /폼테이블1 -->	
<!-- 폼테이블2 -->			
			<div class="title-wrap">
				<h4><span class="text-primary">½미리복스 13</span> 공구함 실사 이력</h4>
			</div>
			<div id="auiGridBom" style="margin-top: 5px; height: 155px;"></div>	
			<div class="btn-group mt10">						
				<div class="right">
					<button type="button" class="btn btn-info" onclick="javascript:fnClose();">닫기</button>
				</div>
			</div>
<!-- /폼테이블2 -->	
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>