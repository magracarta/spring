<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 쪽지함 > null > 쪽지쓰기 > 조직도
-- 작성자 : 이종술
-- 최초 작성일 : 2020-04-09 11:51:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function() {
			createAUIGrid();
		});
	
		//추가
		function fnData() {
			var data = [];
			var itemArr = AUIGrid.getCheckedRowItemsAll(auiGrid); // 체크된 그리드 데이터
			for(var i = 0 ; i < itemArr.length ; i++){
				if(itemArr[i].mem_no != ""){
					data.push(itemArr[i]);
				}
			}
			AUIGrid.setAllCheckedRows(auiGrid, false);
			return data;
		}
		
		//검색
		function fnSearch(str){
			var searchData = [];
			var rowItems = AUIGrid.getOrgGridData(auiGrid);
			
			for(var i = 0 ; i < rowItems.length ; i++){
				if(rowItems[i].name.indexOf(str) > -1){
					searchData.push(rowItems[i]);
				}
				
				if(rowItems[i].hasOwnProperty("children")){
					fnSearchChild(searchData, rowItems[i].children, str);
				}
			}
			
			AUIGrid.search(auiGrid, "name", str);
			
			return searchData;
		}
		
		//트리검색 재귀함수
		function fnSearchChild(searchData, childData, str){
			for(var i = 0 ; i < childData.length ; i++){
				if(childData[i].name.indexOf(str) > -1){
					searchData.push(childData[i]);
				}
				
				if(childData[i].hasOwnProperty("children")){
					fnSearchChild(searchData, childData[i].children, str);
				}
			}
		}
		
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "code",
//  				height : 350,
 				//체크박스 출력 여부
				showRowCheckColumn : true,
				//전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
				// rowNumber
				// showRowNumColumn: true,
				rowCheckDependingTree : true,
				showRowNumColumn: false,
				enableFilter :true,
				displayTreeOpen : true,
				treeColumnIndex : 0,
				// 전체선택 제어 컨트롤
				independentAllCheckBox: true,
			};
			var columnLayout = [
				{
					headerText : "조직",
					dataField : "name",
					style : "aui-center",
					editable : false,
					filter : {
						showIcon : true
					},
				},
				{
					headerText : "직책",
					dataField : "grade_name",
					width : "20%",
					style : "aui-center",
					editable : false,
					filter : {
						showIcon : true
					}
				}
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, ${list});
			AUIGrid.bind(auiGrid, "cellClick", cellClickHandler);
			// [14313] 전체 선택 이벤트 바인딩 커스텀 - 김경빈
			extraAllCheckAtTreeGrid(auiGrid, "YK건기");
		}

		// 셀 클릭으로 엑스트라 체크박스 체크/해제 하기
		function cellClickHandler(event) {
			var item = event.item, rowIdField, rowId;
			rowIdField = AUIGrid.getProp(event.pid, "rowIdField"); // rowIdField 얻기
			rowId = item[rowIdField];
			// 이미 체크 선택되었는지 검사
			if(AUIGrid.isCheckedRowById(event.pid, rowId)) {
				// 엑스트라 체크박스 체크해제 추가
				AUIGrid.addUncheckedRowsByIds(event.pid, rowId);
			} else {
				// 엑스트라 체크박스 체크 추가
				AUIGrid.addCheckedRowsByIds(event.pid, rowId);
			}
		};
	</script>
</head>
<body class="bg-white class">
<form id="main_form" name="main_form">
	<!-- 팝업 -->
	<div class="content width-100per">
		<!-- 타이틀영역 -->
		<div class="main-title">
<%--			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp" />--%>
		</div>
		<!-- /타이틀영역 -->
		<div class="content-wrap">
			<div id="auiGrid" style="margin-top: 5px; height: 300px;"></div>
		</div>
	</div>
	<!-- /팝업 -->
</form>
</body>
</html>