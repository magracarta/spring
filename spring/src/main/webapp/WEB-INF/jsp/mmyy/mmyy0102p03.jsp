<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 쪽지함 > null > 선택쪽지함관리
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

		//쪽지함 조회
		function fnGetData(){
			$M.goNextPageAjax(this_page + "/search", null, {method : 'get'},
				function(result) {
					if(result.success) {
						AUIGrid.setGridData(auiGrid, result.list);
					};
				}
			);
		}
		
		function fnClose() {
			window.close();
		}

		//쪽지함 저장
		function goSave() {
			var gridFrm = fnChangeGridDataToForm(auiGrid, "Y");
			
			if(gridFrm.length > 0){
				$M.goNextPageAjaxSave(this_page + "/save", gridFrm, {method : 'post'},
					function(result) {
				    	if(result.success) {
				    		fnGetData();
				    		opener.fnReload();
				    		//opener.location.reload(true);
						}
					}
				);
			}
		}

		//쪽지함 추가
		function fnAdd() {
			var colIndex = AUIGrid.getColumnIndexByDataField(auiGrid, "box_name");
			fnSetCellFocus(auiGrid, colIndex, "box_name");
			
			var item = new Object();
	   		item.paper_box_seq = 0;
	   		item.box_name = "";
	   		
	   		AUIGrid.addRow(auiGrid, item, 'last');
		}

		//쪽지함 삭제
		function fnRemove() {
			var itemArr = AUIGrid.getCheckedRowItemsAll(auiGrid); // 체크된 그리드 데이터
			
			for(var i = 0 ; i < itemArr.length ; i++){
				AUIGrid.removeRowByRowId(auiGrid, itemArr[i]._$uid);
			}
		}

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
					headerText : "쪽지함번호",
					dataField : "paper_box_seq",
					visible : false
				},
				{
					headerText : "쪽지함명",
					dataField : "box_name",
					editable : true
				}
			];

			// 실제로 #grid_wrap에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);

			// 그리드 갱신
			AUIGrid.bind(auiGrid, "cellEditBegin", function( event ) {			
				if(event.item.paper_box_seq != 0 ) {
					return false;
				}
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
						<h4>쪽지함관리</h4>
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