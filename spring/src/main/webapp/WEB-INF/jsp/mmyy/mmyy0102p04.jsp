<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 쪽지함 > null > 자주쓰는문구
-- 작성자 : 이종술
-- 최초 작성일 : 2020-04-09 11:51:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var auiGrid;
		$(document).ready(function () {
			createAUIGrid();
			fnGetData();
		});
		
		//자주쓰는문구 조회
		function fnGetData(){
			$M.goNextPageAjax(this_page + "/search", null, {method : 'get'},
				function(result) {
					if(result.success) {
						AUIGrid.setGridData(auiGrid, result.list);
					};
				}
			);
		}
		
		//팝업 닫기
		function fnClose() {
			window.close();
		}

		//자주쓰는문구 저장
		function goSave() {
			var gridFrm = fnChangeGridDataToForm(auiGrid, "Y");
			
			if(gridFrm.length > 0){
				$M.goNextPageAjaxSave(this_page + "/save", gridFrm, {method : 'post'},
					function(result) {
				    	if(result.success) {
				    		fnGetData();
						}
					}
				);
			}
		}

		//자주쓰는문구 추가
		function fnAdd() {
			var colIndex = AUIGrid.getColumnIndexByDataField(auiGrid, "paper_contents");
			fnSetCellFocus(auiGrid, colIndex, "paper_contents");
			
			var item = new Object();
	   		item.paper_bookmark_seq = 0;
	   		item.paper_contents = "";
	   		item.use_yn = "Y";
	   		
	   		AUIGrid.addRow(auiGrid, item, 'last');
		}

		//자주쓰는문구 삭제
		function fnRemove() {
			var itemArr = AUIGrid.getCheckedRowItemsAll(auiGrid); // 체크된 그리드 데이터
			
			for(var i = 0 ; i < itemArr.length ; i++){
				AUIGrid.removeRowByRowId(auiGrid, itemArr[i]._$uid);
			}
		}
		
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				editable : true,
				// 체크박스 출력 여부
				showRowCheckColumn : true,
				// 전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
				// Row번호 표시 여부
				showRowNumColum : true
			};

			var columnLayout = [
				{
					headerText : "쪽지번호",
					dataField : "paper_bookmark_seq",
					visible : false
				},
				{
					headerText : "문구내용",
					dataField : "paper_contents",
					style : "aui-left",
					editable : true
				},
				{
					headerText : "사용여부",
					dataField : "use_yn",
					visible : false
				}
			];

			// 실제로 #grid_wrap에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			
			AUIGrid.bind(auiGrid, "cellEditBegin", function( event ) {			
				if(event.item.paper_bookmark_seq != 0 ) {
					return false;
				}
			});
			
			AUIGrid.bind(auiGrid, "cellDoubleClick", function( event ) {
				window.opener.setPaperContents(event.item.paper_contents);
				fnClose();
			});
		}
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<div class="popup-wrap width-100per">
	<div class="main-title">
		<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
	</div>
<!-- contents 전체 영역 -->
	<div class="content-wrap">
		<div>
			<div class="title-wrap">
				<div class="left">
					<h4>문구목록</h4>
				</div>
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
				</div>
			</div>
			<div id="auiGrid" style="margin-top: 5px; height: 300px;"></div>
			<div class="btn-group mt10">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
		</div>
	</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>