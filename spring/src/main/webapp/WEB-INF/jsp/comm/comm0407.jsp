<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 서비스 > 메이커별 기본지급품 항목관리 > null > null
-- 작성자 : 이강원
-- 최초 작성일 : 2021-08-04 16:40:14
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		
		var auiGridLeft;
		var auiGridRight;
		var itemTypeJson = [{"code_value":"G","code_name":"기본지급품"},{"code_value":"A","code_name":"기본장착"}];
	
		$(document).ready(function() {
			createAUIGridLeft();	// 그리드 생성 (부서권한 목록)
			createAUIGridRight();	// 그리드 생성 (부서권한 목록)
		});
		
		// 메이커 목록 그리드 생성
		function createAUIGridLeft(){
			var gridPros = {
                rowIdField: "_$uid",
                editable: false
            };

            var columnLayout = [
                {
                    dataField: "maker_cd",
                    visible: false
                },
                {
                    dataField: "maker_name",
                    headerText: "메이커",
                    width : "120",
                    style: "aui-center aui-link"
                },
                {
                    dataField: "maker_model_cnt",
                    headerText: "모델수",
                    width : "70",
                    style: "aui-center"
                },
                {
                    dataField: "maker_item_cnt",
                    headerText: "기본지급품 목록수",
                    width : "150",
                    style: "aui-center"
                }
            ];

            auiGridLeft = AUIGrid.create("#auiGridLeft", columnLayout, gridPros);
            AUIGrid.setGridData(auiGridLeft, ${list});

            // 셀 클릭 이벤트
            AUIGrid.bind(auiGridLeft, "cellClick", function(event){
            	if(event.dataField == "maker_name"){
                	search(event.item.maker_cd);
            	}
            });

		}
		
		// 지금품 목록 그리드 생성
		function createAUIGridRight(){
			var gridPros = {
	                rowIdField: "_$uid",
	                showStateColumn: true,
	                editable: true,
	            };

	            var columnLayout = [
	                {
	                    dataField: "maker_cd",
	                    visible: false
	                },
	                {
	                    dataField: "item_code",
	                    visible: false
	                },
	                {
	                    dataField: "cmd",
	                    visible: false
	                },
	                {
	                    dataField: "item_type_ga",
	                    headerText: "구분",
	                    style: "aui-center",
	                    width : "100",
	                    required: true,
	                    editRenderer: {
	                        type: "DropDownListRenderer",
	                        showEditorBtn: false,
	                        showEditorBtnOver: true,
	                        list: itemTypeJson,
	                        keyField: "code_value",
	                        valueField: "code_name"
	                    },
	                    labelFunction : function(rowIndex, columnIndex, value, headerText, item){
	                    	for(var i=0; i<itemTypeJson.length; i++) {
	    						if(value == itemTypeJson[i].code_value){
	    							return itemTypeJson[i].code_name;
	    						}
	    					}
	    					return value;
	                    }
	                },
	                {
	                    dataField: "item_name",
	                    headerText: "항목명",
	                    style: "aui-center",
	                    width : "200",
	                    required: true,
	                },
	                {
	                    dataField: "sort_no",
	                    headerText: "정렬순서",
	                    style: "aui-center",
	                    width : "100",
	                    required: true,
	                    editRenderer: {
	                        type: "InputEditRenderer",
	                        onlyNumeric: true
	                    },
	                },
	                {
	                    dataField: "removeBtn",
	                    headerText: "삭제",
	                    width: "70",
	                    renderer: {
	                        type: "ButtonRenderer",
	                        onClick: function (event) {
	                        	var isRemoved = AUIGrid.isRemovedById(auiGridRight, event.item._$uid);
	                        
								if(isRemoved == false){
									AUIGrid.updateRow(auiGridRight, {cmd: "D"}, event.rowIndex);
	 	                        	AUIGrid.removeRow(event.pid, event.rowIndex);
								}else{
		                            AUIGrid.restoreSoftRows(auiGridRight, "selectedIndex");
									AUIGrid.updateRow(auiGridRight, {cmd: "U"}, event.rowIndex);
								}
	                        }
	                    },
	                    labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
	                        return '삭제'
	                    },
	                    style: "aui-center",
	                    editable: false,
	                }
	            ];

	            auiGridRight = AUIGrid.create("#auiGridRight", columnLayout, gridPros);
	            AUIGrid.setGridData(auiGridRight, []);
	            
	            AUIGrid.bind(auiGridRight, "rowStateCellClick", myGridHandler);
	            
		}
		
		function myGridHandler(event){
			switch(event.type){
				case "rowStateCellClick" :
	            	if(event.marker == "removed"){
	            		var isRemoved = AUIGrid.isRemovedById(auiGridRight, event.item._$uid);
                        
						if(isRemoved == false){
							AUIGrid.updateRow(auiGridRight, {cmd: "D"}, event.rowIndex);
	                        	AUIGrid.removeRow(event.pid, event.rowIndex);
						}else{
                            AUIGrid.restoreSoftRows(auiGridRight, "selectedIndex");
							AUIGrid.updateRow(auiGridRight, {cmd: "U"}, event.rowIndex);
						}
	            	}
			}
		}
		
		// 메이커 지금품 목록 검색
		function search(maker_cd){
			if(fnChangeGridDataCnt(auiGridRight) != 0 && maker_cd != $M.getValue("curr_maker_cd")){
				var check = confirm("저장하지 않은 변경내용이 사라집니다.");
				if(!check){
					return;
				}
			}
			
			var param = {
					"maker_cd" : maker_cd,
			}
			
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'}, function(result){
				if(result.success){
					$M.setValue("curr_maker_cd",maker_cd);
					AUIGrid.setGridData(auiGridRight, result.list);
				}
			});
		}
		
		function goSave(){
			if(fnChangeGridDataCnt(auiGridRight) == 0){
				alert("변경사항이 없습니다.");
				return;
			}
			
			var gridFrm = fnChangeGridDataToForm(auiGridRight);
			
			$M.goNextPageAjaxSave(this_page + "/save", gridFrm, {method : 'post'}, function(result){
				if(result.success){
					AUIGrid.resetUpdatedItems(auiGridRight);
					search($M.getValue("curr_maker_cd"));
				}
			});
		}
		
		function fnAdd(){
			if ($M.getValue("curr_maker_cd") == undefined || $M.getValue("curr_maker_cd") == "") {
                alert("메이커를 선택해주세요.");
                return;
            }
            var item = new Object();
            item.maker_cd = $M.getValue("curr_maker_cd");
            item.item_code = "0";
            item.item_name = "";
            item.item_type_ga = "";
            item.sort_no = "";
            item.cmd = "C";
            AUIGrid.addRow(auiGridRight, item, 'last');
		}
		
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" id="curr_maker_cd" name="curr_maker_cd" value=""/>
	<!-- contents 전체 영역 -->
	<div class="content-wrap" style="height: 850px;">
		<div class="content-box">
			<!-- 메인 타이틀 -->
			<div class="main-title">
				<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
			</div>
			<!-- /메인 타이틀 -->
			<div class="contents">
				<div class="row">
					<div class="col-4">
						<div class="title-wrap mt10">
							<h4>메이커 목록</h4>
						</div>
						<!-- 그리드 생성 -->
						<div id="auiGridLeft" style="margin-top: 5px; height:500px;"></div>
					</div>
					<div class="col-8">
						<div class="title-wrap mt10">
							<h4>지금품 목록</h4>
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>		
						</div>
						<!-- 그리드 생성 -->
						<div id="auiGridRight" style="margin-top: 5px; height:500px;"></div>
						<!-- 버튼영역 -->
						<div class="btn-group mt5">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
							</div>						
						</div>
						<!-- /버튼영역 -->
					</div>
				</div>
			</div>
		</div>
		<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>	
	</div>
	<!-- /contents 전체 영역 -->	
</form>
</body>
</html>