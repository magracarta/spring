<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 정비 > 정비Tool관리 > null > 센터 공구 실사 재고관리
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
			showFooter : true,
			footerPosition : "top",
		};
		var columnLayout = [
			{ 
				headerText : "공구함", 
				dataField : "a", 
				style : "aui-center",
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
				width : "30%"
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
		
		auiGridTop = AUIGrid.create("#auiGridTop", columnLayout, gridPros);
		AUIGrid.setFooter(auiGridTop, footerLayout);
		AUIGrid.setGridData(auiGridTop, testData);
		
		$("#auiGridTop").resize();
	}	

	// 센터 실사재고 이력 그리드
	function createAUIGridBom() {
		var gridPros = {
			rowIdField : "row",
			showRowNumColumn: true,
		};
		var columnLayout = [
			{ 
				headerText : "조사일", 
				dataField : "a", 
				style : "aui-center",
				dataType : "date",  
				formatString : "yyyy-mm-dd",
				width : "15%"
			},
			{
				headerText : "조사자", 
				dataField : "b", 
				style : "aui-center",
				width : "15%"
			},
			{ 
				headerText : "공구함", 
				dataField : "c", 
				style : "aui-center",
					width : "10%"
			},
			{ 
				headerText : "이전수량", 
				dataField : "d", 
				style : "aui-center",
				width : "10%"
			},
			{ 
				headerText : "실사수량", 
				dataField : "e", 
				style : "aui-center",
				width : "10%"

			},
			{
				headerText : "차이수량", 
				dataField : "f", 
				style : "aui-center",
				width : "10%"
			},
			{
				headerText : "비고", 
				dataField : "g", 
				style : "aui-left",
				width : "30%"
			},
		];
		
		var testData = [
			{
				"a" : "2019-10-22",
				"b" : "장현석",
				"c" : "센터설비",
				"d" : "2",
				"e" : "2",
				"f" : "1",
				"g" : "공구 손망실",
			},
			{
				"a" : "2019-10-22",
				"b" : "장현석",
				"c" : "센터설비",
				"d" : "2",
				"e" : "2",
				"f" : "1",
				"g" : "공구 손망실",
			},
		];
		
		auiGridBom = AUIGrid.create("#auiGridBom", columnLayout, gridPros);
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
<!-- 폼테이블 -->					
			<div>
				<table class="table-border mt5">
					<colgroup>
						<col width="120px">
						<col width="">
						<col width="120px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right">재고조사일자</th>
							<td>2020-10-22</td>
							<th class="text-right">공구명</th>
							<td>2020-10-22</td>						
						</tr>									
					</tbody>
				</table>
			</div>
<!-- /폼테이블 -->	
<!-- 의견추가내역 -->
			<div class="mt5">	
				<div id="auiGridTop" style="margin-top: 5px; height: 150px;"></div>
			</div>	
			<div class="btn-group mt10">						
				<div class="right">
					<button type="button" class="btn btn-info" onclick="javascript:goSave();">저장</button>
				</div>
			</div>
<!-- /의견추가내역 -->
<!-- 센터 실사재고 이력 -->
			<div class="title-wrap">
				<h4>센터 실사재고 이력</h4>
			</div>				
			<div id="auiGridBom" style="margin-top: 5px; height: 155px;"></div>	
<!-- /센터 실사재고 이력 -->
<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt10">						
				<div class="right">
					<button type="button" class="btn btn-info" onclick="javascript:fnClose();">닫기</button>
				</div>
			</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>