<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 렌탈비용 > 렌탈기준정보-어테치먼트 > null > 렌탈기본장착어테치 관리
-- 작성자 : 김상덕
-- 최초 작성일 : 2020-05-21 20:04:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var ynList = [{"code_value": "Y", "code_name" : "Y"}, {"code_value": "N", "code_name" : "N"}]

		$(document).ready(function() {
			createAUIGrid();
		});

		function createAUIGrid(){
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn: true,
				editable : true,
			};
			var columnLayout = [
				{
					headerText : "모델명",
					dataField : "machine_name",
					styleFunction : myStyleFunction,
					width: 180,
					required : true,
					editRenderer : {
						type : "ConditionRenderer", // 조건에 따라 editRenderer 사용하기. conditionFunction 정의 필수
						conditionFunction : function(rowIndex, columnIndex, value, item, dataField) {
							if(item.edit_yn == "N") {
								return {};
							}

							var param = {
								s_sale_yn : 'Y'
							};
							return fnGetMachineSearchRenderer(dataField, param);
						},
					}
				},
				{
					dataField : "part_no",
					headerText : "부품번호",
					styleFunction : myStyleFunction,
					width: 180,
					required : true,
					editRenderer : {
						type : "ConditionRenderer", // 조건에 따라 editRenderer 사용하기. conditionFunction 정의 필수
						conditionFunction : function(rowIndex, columnIndex, value, item, dataField) {
							if(item.edit_yn == "N") {
								return {};
							}

							var param = {
								s_search_kind       : 'DEFAULT'
							};
							return fnGetPartSearchRenderer(dataField, param);
						},
					},
				},
				{
					headerText : "어테치먼트명",
					dataField : "attach_name",
					width: 180,
					required : true,
					styleFunction : myStyleFunction,
					editable : true,
				},
				{
					headerText : "수량",
					dataField : "qty",
					width: 100,
					required : true,
					styleFunction : myStyleFunction,
					editable : true,
				},
				{
					headerText : "자동렌탈어테치등록여부",
					dataField : "auto_rental_attach_yn",
					width: 150,
					required : true,
					styleFunction : myStyleFunction,
					editRenderer : {
						type : "DropDownListRenderer",
						showEditorBtn : false,
						showEditorBtnOver : false,
						list : ynList,
						keyField : "code_value",
						valueField : "code_value"
					},
					editable : true,
				},
				{
					headerText : "자동렌탈여부",
					dataField : "auto_rental_yn",
					width: 100,
					required : true,
					styleFunction : myStyleFunction,
					editRenderer : {
						type : "DropDownListRenderer",
						showEditorBtn : false,
						showEditorBtnOver : false,
						list : ynList,
						keyField : "code_value",
						valueField : "code_value"
					},
					editable : true,
				},
				{
					headerText : "삭제",
					dataField : "removeBtn",
					width : "50",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							if(event.item.modify_yn == 'N'){
								alert("공지가 등록된 발령은 삭제할 수 없습니다.");
								return;
							}
							var isRemoved = AUIGrid.isRemovedById(auiGrid, event.item._$uid);
							if(isRemoved == false){
								AUIGrid.updateRow(auiGrid,{"cmd":"D"},event.rowIndex);
								AUIGrid.removeRow(event.pid,event.rowIndex);
							}else{
								AUIGrid.restoreSoftRows(auiGrid,"selectedIndex");
								AUIGrid.updateRow(auiGrid,{"cmd":""},event.rowIndex);
							}
						},
					},
					labelFunction : function(rowIndex, columnIndex, value,headerText, item) {
						return "삭제";
					},
					style : "aui-center",
					editable : false,
				},
				{
					dataField : "rental_part_seq",
					visible : false,
				},
				{
					dataField : "machine_plant_seq",
					visible : false,
				},
				{
					dataField : "use_yn",
					visible : false,
				},
				{
					dataField : "edit_yn",
					visible : false,
				},
				{
					dataField : "cmd",
					visible : false,
				},
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, ${list});

			AUIGrid.bind(auiGrid,"cellEditBegin",function(event){
				if(event.item.edit_yn == 'N' && (event.dataField == "part_no" || event.dataField == "machine_name")){
					return false;
				}
			});


			AUIGrid.bind(auiGrid, "cellEditEnd", function(event) {
				console.log(event.item);
				if(event.dataField == "part_no" || event.dataField == "machine_name") {
					if(event.dataField == "machine_name") {
						var machineItem = fnGetMachineItem(event.value);
						if(typeof machineItem === "undefined") {
							return;
						}

						event.item.machine_plant_seq = machineItem.machine_plant_seq;

						AUIGrid.updateRow(auiGrid, {
							machine_plant_seq : machineItem.machine_plant_seq
						}, event.rowIndex);
					}
					var list = AUIGrid.getGridData(auiGrid);
					for(var i = 0; i < list.length; i++) {
						if(i == event.rowIndex) continue;
						var m = list[i];
						if(m.part_no == event.item.part_no && m.machine_plant_seq == event.item.machine_plant_seq && m.part_no != "" && m.machine_plant_seq != "0") {
							alert("동일한 부품과 모델이 존재합니다.");
							var updateMap;
							if(event.dataField == "part_no") {
								updateMap = {
									"part_no" : ""
								}
							} else if(event.dataField == "machine_name") {
								updateMap = {
									"machine_name" : "",
									"machine_plant_seq" : ""
								};
							}
							AUIGrid.updateRow(auiGrid, updateMap, event.rowIndex);
							return false;
						}
					}
				}
			});
		}

		// 행 추가
		function fnAdd() {
			// 그리드 빈값 체크
			var item = new Object();
			item.rental_part_seq = "0";
			item.part_no = "";
			item.machine_plant_seq = "";
			item.machine_name = "";
			item.attach_name = "어테치이름필요";
			item.qty = "1";
			item.auto_rental_attach_yn = "N";
			item.auto_rental_yn = "N";
			item.use_yn = "Y";
			item.edit_yn = "Y";
			AUIGrid.addRow(auiGrid, item, "last");
		}

		function myStyleFunction(rowIndex, columnIndex, value, headerText, item, dataField) {
			if(item.edit_yn == 'N' && (dataField == "part_no" || dataField == "부품번호" || dataField == "machine_name") || dataField == "모델명") {
				return "aui-center";
			}

			return "aui-editable";
		}

		// machine_name 으로 검색해온 정보 아이템 반환.
		function fnGetMachineItem(machine_name) {
			var item;
			$.each(recentMachineList, function(n, v) {
				if(v.machine_name == machine_name) {
					item = v;
					return false;
				}
			});
			return item;
		};
	
	    function goSave() {
			if (fnChangeGridDataCnt(auiGrid) == 0){
				alert("변경된 데이터가 없습니다.");
				return false;
			};

			if(!AUIGrid.validation(auiGrid)) {
				return false;
			}

			var frm = fnChangeGridDataToForm(auiGrid,'N');

			$M.goNextPageAjaxSave(this_page + '/save', frm , {method : 'POST'},
				function(result) {
					if(result.success) {
						alert("저장이 완료되었습니다.");
						location.reload();
					}
				}
			);
	    }

	    function fnClose() {
	    	window.close();
	    }
	</script>
</head>
<body   class="bg-white"  >
<form id="main_form" name="main_form">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">	
			<div class="title-wrap">
				<h4>기본장착 어테치먼트 관리</h4>
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
				</div>
			</div>
			<!-- 그리드 서머리, 컨트롤 영역 -->
			<div id="auiGrid" style="margin-top: 5px; height: 500px;"></div>
			<!-- /그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>