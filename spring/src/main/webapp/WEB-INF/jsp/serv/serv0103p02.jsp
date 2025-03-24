<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 정비 > 정비Tool관리 > null > 공구함신규등록
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2020-04-07 19:54:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>
	
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
				headerText : "공구명", 
				dataField : "a", 
				style : "aui-left",
				width : "40%"
			},
			{
				headerText : "등록자", 
				dataField : "b", 
				style : "aui-center"
			},
			{ 
				headerText : "처리구분", 
				dataField : "c", 
				style : "aui-center",
				dataType : "date",  
				formatString : "yyyy-mm-dd",
			},
			{ 
				headerText : "정렬순서", 
				dataField : "d", 
				style : "aui-center",
			},
			{ 
				headerText : "이미지", 
				dataField : "e", 
				renderer : {
					type : "ButtonRenderer",
					onClick : function(event) {
						alert("검정교서 이미지 등록 팝업")
					},
				},
				labelFunction : function(rowIndex, columnIndex, value,
						headerText, item) {
					return '첨부'
				},
				style : "aui-center",
				editable : false,
			},
			{ 
				headerText : "삭제", 
				dataField : "f", 
				renderer : {
					type : "ButtonRenderer",
					onClick : function(event) {
						alert("삭제");
						/*
						var isRemoved = AUIGrid.isRemovedById(auiGridPartPaid, event.item._$uid);
						if (isRemoved == false) {
							AUIGrid.removeRow(event.pid, event.rowIndex);
							AUIGrid.update(auiGridPartPaid);
						} else {
							AUIGrid.restoreSoftRows(auiGridPartPaid, "selectedIndex"); 
							AUIGrid.update(auiGridPartPaid);
						};
						*/
					},
				},
				labelFunction : function(rowIndex, columnIndex, value,
						headerText, item) {
					return '삭제'
				},
				style : "aui-center",
				editable : false,
			}
		];
		
		var testData = [
			{
				"a" : "½ 미리 복스 10",
				"b" : "장현석",
				"c" : "2020-10-22",
				"d" : "1",
				"e" : "",
				"f" : ""
			},
			{
				"a" : "½ 미리 복스 10",
				"b" : "장현석",
				"c" : "2020-10-22",
				"d" : "1",
				"e" : "",
				"f" : ""
			},
			{
				"a" : "½ 미리 복스 10",
				"b" : "장현석",
				"c" : "2020-10-22",
				"d" : "1",
				"e" : "",
				"f" : ""
			},
		];
		
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		AUIGrid.setGridData(auiGrid, testData);
		
		$("#auiGrid").resize();
	}
	
	// 저장
	function goSave() {
		alert("저장");
	}
	
	// 닫기
    function fnClose() {
    	window.close();
    }
	
	// 조회
	function goSearch() {
		alert("조회");
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
<!-- 검색조건 -->
			<div class="search-wrap mt5">
				<table class="table">
					<colgroup>
						<col width="60px">
						<col width="150px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th>공구명</th>
							<td>
								<input type="text" class="form-control">
							</td>
							<td class=""><button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button></td>
						</tr>
					</tbody>
				</table>
			</div>
<!-- /검색조건 -->
			<div class="title-wrap mt10">
				<h4>조회결과</h4>
			</div>
<!-- 검색결과 -->
			<div id="auiGrid" style="margin-top: 5px; height: 350px;"></div>
			<div class="btn-group mt10">
				<div class="left">
					총 <strong class="text-primary">25</strong>건
				</div>		
				<div class="right">
					<button type="button" class="btn btn-info" onclick="javascript:goSave();">저장</button>
					<button type="button" class="btn btn-info" onclick="javascript:fnClose();">닫기</button>
				</div>
			</div>
<!-- /검색결과 -->
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>