<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 쪽지함 > null > 발송그룹설정
-- 작성자 : 이종술
-- 최초 작성일 : 2020-04-09 11:51:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	var auiGridLeft;
	var auiGridRight;
	$(document).ready(function() {
		createAUIGridLeft();
		createAUIGridRight();
		
		fnGetData();
	});

	//쪽지발송그룹 조회
	function fnGetData(){
		$M.goNextPageAjax(this_page + "/group/search", null, {method : 'get'},
			function(result) {
				if(result.success) {
					AUIGrid.clearGridData(auiGridLeft);
					AUIGrid.setGridData(auiGridLeft, result.list);
					$("#group_cnt").html(AUIGrid.getRowCount(auiGridLeft));
					$("#btnArea").hide();
				};
			}
		);
	} 
	
	//쪽지발송그룹 구성원 조회
	function fnGetUserData(){
		var rows = AUIGrid.getSelectedItems(auiGridLeft);
		
		if(rows.length == 0 || rows[0].item.paper_group_seq == 0) return;
		
		$M.setValue("paper_group_seq", rows[0].item.paper_group_seq);
		
		var param = {
			s_paper_group_seq : $M.getValue("paper_group_seq")
		};
		
		$M.goNextPageAjax(this_page + "/user/search", $M.toGetParam(param), {method : 'get'},
			function(result) {
				if(result.success) {
					AUIGrid.setGridData(auiGridRight, result.list);
					
					var selectIdx = AUIGrid.getSelectedIndex(auiGridLeft);
					
					AUIGrid.setCellValue(auiGridLeft, selectIdx[0], "count", AUIGrid.getRowCount(auiGridRight));
		    		$("#user_cnt").html(AUIGrid.getRowCount(auiGridRight));
					$("#btnArea").show();
				};
			}
		);
	}
	
	//쪽지발송그룹 추가
	function fnAdd() {
		/* var addRows = AUIGrid.getAddedRowItems(auiGridLeft);
		var editRows = AUIGrid.getEditedRowItems(auiGridLeft)
		if((addRows.length + editRows.length) > 0){
			alert("발송그룹이 편집중입니다");
			return;
		} */
		
		var colIndex = AUIGrid.getColumnIndexByDataField(auiGridLeft, "group_name");
		fnSetCellFocus(auiGridLeft, colIndex, "group_name");
		
		var item = new Object();
   		item.paper_group_seq = 0;
   		item.group_name = "";
   		item.count = 0;
   		
   		AUIGrid.addRow(auiGridLeft, item, 'last');
	}

	//쪽지발송그룹 삭제
	function fnRemove() {
		var gridFrm = fnCheckedGridDataToForm(auiGridLeft);
		
		if(gridFrm.length > 0){
			
			$M.goNextPageAjaxRemove(this_page + "/group/delete", gridFrm, {method : 'post'},
				function(result) {
			    	if(result.success) {
			    		fnGetData();
					}
				}
			);
		}
	}

	//쪽지발송 구성원 삭제
	function fnRemoveUser(){
		var itemArr = AUIGrid.getCheckedRowItemsAll(auiGridRight); // 체크된 그리드 데이터
		
		for(var i = 0 ; i < itemArr.length ; i++){
			AUIGrid.removeRowByRowId(auiGridRight, itemArr[i]._$uid);
		}
	}
	
	//쪽지발송 저장
	function fnSave(event) {
		var item = event.item;
		
		$M.goNextPageAjax(this_page + "/group/save", $M.toGetParam(item), {method : 'post'},
			function(result) {
				if(result.success) {
					fnGetData();
					opener.location.reload(true);
				};
			}
		);
	}
	
	//쪽지발송구성원저장
	function goSave() {
		var gridFrm = fnChangeGridDataToForm(auiGridRight);
		
		if(gridFrm.length > 0){
			$M.goNextPageAjaxSave(this_page + "/user/save", gridFrm, {method : 'post'},
				function(result) {
			    	if(result.success) {
			    		fnGetUserData();
					}
				}
			);
		}
	}

	function fnClose() {
		window.close();
	}

	// 기본 조직도 조회
	function setMemberOrgMapPanel(result) {
		console.log(JSON.stringify(result));
		var data = []
		for(var i = 0 ; i < result.length ; i++){
			console.log(AUIGrid.isUniqueValue(auiGridRight, "mem_no", result[i].mem_no));
			if(result[i].mem_no != "" && AUIGrid.isUniqueValue(auiGridRight, "mem_no", result[i].mem_no)){
				result[i].paper_group_seq =  $M.getValue("paper_group_seq");
				data.push(result[i]);
			}
		}
		
		AUIGrid.addRow(auiGridRight, data, "last");
	}

	function createAUIGridLeft() {
		var gridPros = {
			rowIdField : "_$uid",
			editable : true,
			// 체크박스 출력 여부
			showRowCheckColumn : true,
			// 전체선택 체크박스 표시 여부
			showRowAllCheckBox : true
			//showStateColumn : true
		};

		var columnLayout = [
			{
				headerText : "일련번호",
				dataField : "paper_group_seq",
				visible : false
			},
			{
				headerText : "그룹명",
				dataField : "group_name",
				style : "aui-left aui-editable",
				editable : true
			},
			{
				headerText : "인원수",
				dataField : "count",
				style : "aui-popup",
				editable : false
			}
		];

		auiGridLeft = AUIGrid.create("#auiGridLeft", columnLayout, gridPros);
		AUIGrid.bind(auiGridLeft, "cellDoubleClick", fnGetUserData);
		AUIGrid.bind(auiGridLeft, "cellEditEnd", fnSave);
	}

	function createAUIGridRight() {
		var gridPros = {
			rowIdField : "_$uid",
			// 체크박스 출력 여부
			showRowCheckColumn : true,
			// 전체선택 체크박스 표시 여부
			showRowAllCheckBox : true
		};

		var columnLayout = [
			{
				headerText : "부서명",
				dataField : "org_name",
			},
			{
				headerText : "사원명",
				dataField : "name",
			},
			{
				headerText : "발송그룹",
				dataField : "paper_group_seq",
				visible : false
			},
			{
				headerText : "직원번호",
				dataField : "mem_no",
				visible : false
			},
			{
				headerText : "등록일",
				dataField : "reg_date"
			}
		];

		auiGridRight = AUIGrid.create("#auiGridRight", columnLayout, gridPros);
	}
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" id="paper_group_seq" name="paper_group_seq"/>
<div class="popup-wrap width-100per">
	<!-- 메인 타이틀 -->
	<div class="main-title">
		<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
	</div>
	<!-- /메인 타이틀 -->
<!-- contents 전체 영역 -->
	<div class="content-wrap">
		<div class="row">
			<div class="col-6">
				<!-- 그룹 -->
				<div>
					<div class="title-wrap">
						<div class="left">
							<h4>그룹</h4>
						</div>
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
						</div>
					</div>
					<div id="auiGridLeft" style="margin-top: 5px; height: 500px;"></div>
					<div class="btn-group mt10">
						<div class="left">
							총 <strong id="group_cnt"  class="text-primary">0</strong>그룹
						</div>
					</div>
				</div>
				<!-- /그룹 -->
			</div>
			<div class="col btn-switch">
				<div class="btn btn-default" onclick="fnGetUserData();"><i class="material-iconsarrow_right text-default"></i></div>
			</div>
			<div class="col" style="width: calc(50% - 60px);">
				<!-- 그룹구성원 -->
				<div>
					<div class="title-wrap">
						<div class="left">
							<h4>그룹구성원</h4>
						</div>
						<div class="right" id="btnArea" style="display:hidden;">
							<button type="button" class="btn btn-default" onclick="javascript:openMemberOrgPanel('setMemberOrgMapPanel', 'Y');"><i class="material-iconsadd text-default"></i> 구성원추가</button>
							<button type="button" class="btn btn-default" onclick="javascript:fnRemoveUser();"><i class="material-iconsclose text-default"></i> 삭제</button>
						</div>
					</div>
					<div id="auiGridRight" style="margin-top: 5px; height: 500px;"></div>
					<div class="btn-group mt10">
						<div class="left">
							총 <strong id="user_cnt" class="text-primary">0</strong>명
						</div>
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
					</div>
				</div>
				<!-- /그룹구성원 -->
			</div>
		</div>
	</div>
</div>
<!-- /contents 전체 영역 -->	
</form>
</body>
</html>