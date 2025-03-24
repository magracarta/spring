<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 코드관리 > 출하시 지급품 관리 > null > 장착옵션명관리
-- 작성자 : 강명지
-- 최초 작성일 : 2020-01-10 17:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		var machinePlantSeq;
	
		$(document).ready(function() {
			createAUIGrid();
			machinePlantSeq = '${inputParam.machine_plant_seq}';
			machineName = '${machine_name}';
// 			$('#hidMchNm').text(machineName);
			codeLength = parseInt('${codeLength}');
		});
		
		function isValid() {
			return AUIGrid.validateGridData(auiGrid, "opt_kor_name", "항목에 값을 입력해주세요.");
		}
		
		function goSave() {
			var validation = isValid();
			if(!validation) {
				return;	
			}
			var removedItems = AUIGrid.getRemovedItems(auiGrid);
			if(removedItems.length > 0) {
				var rowItem='';
				var idx='';
				for(i=0; i<removedItems.length; i++) {
					rowItem = removedItems[i];
					idx = AUIGrid.getRowIndexesByValue(auiGrid, "_$uid", rowItem._$uid);
					AUIGrid.restoreSoftRows(auiGrid, idx); 
					AUIGrid.updateRow(auiGrid, {
						use_yn : "N"
					}, idx
					);
				}
			}
			var frm = fnChangeGridDataToForm(auiGrid);
			if(fnGetUpdatedItemsCnt(auiGrid) == 0) {
				alert(msg.alert.data.noChanged);
				return;
			}
			$M.goNextPageAjaxSave(this_page + "/" + machinePlantSeq + "/save", frm, {method : 'POST'}, 
				function(result) {
					if(result.success) {
						try{
							AUIGrid.setFilterByValues(auiGrid, "use_yn", "Y");
							var param = {
									aui : AUIGrid.getGridData(auiGrid),
									list : result.list
							};
							opener.${inputParam.parent_js_name}(param);
							alert("저장되었습니다.");
							window.close();	
						} catch(e) {
							alert('호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.');
						}
					};
				}
			); 
		}
		
		function goRemove() {
			$M.goNextPageAjaxRemove(this_page +"/" + machinePlantSeq + "/remove", '', { method:"POST" },
				function(result) {
					if(result.success){
						try{
							opener.${inputParam.parent_js_name}(result);
							alert("삭제되었습니다.");
							window.close();	
						} catch(e) {
							alert('호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.');
						}	
					}
			});
		}
		
		function fnAdd() {
			var items = AUIGrid.getAddedRowItems(auiGrid);
			if(items.length > 0) {
				alert("추가된 행을 저장하고 계속해주세요.");
			} else {
			var row = new Object();
				row.machine_plant_seq = machinePlantSeq;
// 				row.machine_name = machineName;
				row.opt_code = codeLength + 1;
				row.opt_kor_name = '';
				row.opt_eng_name = '';
				row.use_yn = 'Y';
				row.delete_btn = '삭제';
				AUIGrid.addRow(auiGrid, row, 'last');
				console.log(row.opt_code);
			}
		}
		
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				height : 200,
				editable : true,
				enableFilter:true,
				showStateColumn : true,
			};
			var columnLayout = [
				{
					dataField : "machine_plant_seq", 
					visible : false
				},
// 				{
// 					dataField : "machine_name", 
// 					visible : false
// 				},
				{
					dataField : "opt_code", 
					visible : false
				},
				{ 
					headerText : "선택옵션명", 
					dataField : "opt_kor_name", 
					width : "30%", 
					style : "aui-center",
				},
				{ 
					headerText : "발주옵션명(영문)", 
					dataField : "opt_eng_name",
					width : "50%", 
					style : "aui-center"
				},
				{
					headerText : "삭제", 
					dataField : "delete_btn", 
					style : "aui-center",
					renderer : {
						type : "ButtonRenderer",
						labelText : "삭제", 
						onClick : function(event) {
							var isRemoved = AUIGrid.isRemovedById(auiGrid, event.item._$uid);
							if (isRemoved == false) {
								AUIGrid.removeRow(event.pid, event.rowIndex);
								if(AUIGrid.isAddedById(auiGrid, event.item._$uid)) {
									AUIGrid.removeSoftRows(event.pid, event.rowIndex);
								}
							} else {
								AUIGrid.restoreSoftRows(auiGrid, "selectedIndex"); 
							}
						},
					},
					editable : false,
				},
				{
					headerText : "엥?", 
					dataField : "use_yn",
					visible : false
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, ${list});
			$("#auiGrid").resize();
			//AUIGrid.hideColumnByDataField(auiGrid, "use_yn");
			AUIGrid.setFilterByValues(auiGrid, "use_yn", "Y");
		}
	
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <!--  <div class="main-title" id="title">
        </div> -->
<!-- /타이틀영역 -->
        <div class="content-wrap">
<!-- 폼테이블 -->					
			<div>
				<div class="title-wrap half-print">
					<div class="doc-info" style="flex: 1;">
						<h4>장착옵션명관리</h4>		
					</div>
<!-- 					<h4 class="primary" name="hidMchNm" id="hidMchNm"> -->
<!-- 					</h4> -->
					<div class="right">
						<button type="button" class="btn btn-default" onclick="javascript:fnAdd();"><i class="material-iconsadd text-default"></i> 행추가</button>
					</div>
				</div>
				<div id="auiGrid" style="margin-top: 5px;"></div>		
			</div>
<!-- /폼테이블 -->	
<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">						
				<div class="right">
					<button type="button" class="btn btn-info" style="width: 50px;" onclick="javascript:goSave();">저장</button>
					<button type="button" class="btn btn-info" style="width: 50px;" onclick="javascript:goRemove();">삭제</button>
				</div>
			</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>