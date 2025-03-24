<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 기준정보 > 부서권한관리 > null > 메뉴일괄적용
-- 작성자 : 이강원
-- 최초 작성일 : 2021-06-28 16:18:14
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGridCenter;
		var auiGridRightTop;
		var auiGridRightBottom;
	
		$(document).ready(function() {
			createCenterAUIGrid();		// 그리드 생성 (메뉴목록)
			createRightTopAUIGrid();	// 그리드 생성 (버튼권한 목록)
			createRightBottomAUIGrid();	// 그리드 생성 (추가설정 목록)

			goSearchMenuList();
		});
		
		var cellRowIndex = 0;	// 버튼권한 설정 후 셀클릭 위치지정
		
		// 그리드생성
		function createCenterAUIGrid() {
			var gridPros = {
				rowIdField : "menu_seq",
				showRowNumColumn : false,
				treeColumnIndex : 0,
				height : 580,
				editable : false,
				fillColumnSizeMode : false,
				enableFilter : true
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
					headerText : "메뉴",
					dataField : "path_menu_name",
					width: "50%",
					style : "aui-left aui-link",
					editable : false,
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var area = value.split(" > ")
						return area[area.length-1];
					},
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "사용여부", 
					dataField : "use_yn", 
					width : "14%",
					style : "aui-center",
					renderer : {
						type : "CheckBoxEditRenderer",
						editable : true,
						checkValue : "Y",
						unCheckValue : "N"
					},
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "전체 버튼 수",
					dataField : "btn_cnt",
					width: "18%",
					style : "aui-center"
				},
				{
					headerText : "전체 추가설정 수",
					dataField : "add_cnt",
					width: "18%",
					style : "aui-center"
				},
				{
					dataField : "depth_1",
					visible : false
				},
				{
					dataField : "depth_2",
					visible : false
				},
				{
					dataField : "depth_3",
					visible : false
				},
				{
					dataField : "depth_4",
					visible : false
				}
			];
			auiGridCenter = AUIGrid.create("#auiGridCenter", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridCenter, []);
			// 그리드 ready 이벤트 바인딩
			AUIGrid.bind(auiGridCenter, "ready", function(event){
				AUIGrid.showItemsOnDepth(auiGridCenter, 3);
			});
 			// 클릭한 셀 데이터 받음
 			AUIGrid.bind(auiGridCenter, "cellClick", function(event) {
 				if(event.dataField == "path_menu_name") {
	 				// treeicon 클릭 or (depth 2이하 and 팝업여부 = N) 이벤트 없음
	 				if(event.treeIcon === true || (event.item.menu_depth < 3 && event.item.pop_yn == "N")) {
	 					return false;
	 				};
	 				cellRowIndex = event.rowIndex;	// 클릭한 로우index 저장
					var param = {
						"menu_seq" 			: event.item["menu_seq"]
					};
					var frm = document.main_form;
	 				$M.setValue(frm, "menu_seq", param.menu_seq);
	 				goSearchDetail(param);
 				}

 				if(event.dataField == "use_yn") {
 					var depth = event.item.menu_depth;
 					var rowItem = AUIGrid.getItemByRowId(auiGridCenter, event.item.menu_seq);
 					var depthNGroup;
 					var items;
 					switch(depth) {
 					case "1" : depthNGroup = rowItem.depth_1;
 							items = AUIGrid.getItemsByValue(auiGridCenter, "depth_1", depthNGroup);
 								break;
 					case "2" : depthNGroup = rowItem.depth_2;
 							items = AUIGrid.getItemsByValue(auiGridCenter, "depth_2", depthNGroup);
 								break;
 					case "3" : depthNGroup = rowItem.depth_3;
 							items = AUIGrid.getItemsByValue(auiGridCenter, "depth_3", depthNGroup);
 								break;
 					case "4" : depthNGroup = rowItem.depth_4;
 							items = AUIGrid.getItemsByValue(auiGridCenter, "depth_4", depthNGroup);
 								break;
 					}
 					var rowIdField = AUIGrid.getProp(auiGridCenter, "rowIdField");
 					var items2update = [];
 					var item, obj;
 					if(event.value == "Y") {
 						for(var i=0, len=items.length; i<len; i++) {
 						      item = items[i];
 						      obj = {};
 						      obj[rowIdField] = item[rowIdField];
 						      obj["use_yn"] = "Y";
 						      items2update.push(obj);
 						}
 					} else {
 						for(var i=0, len=items.length; i<len; i++) {
 						      item = items[i];
 						      obj = {};
 						      obj[rowIdField] = item[rowIdField];
 						      obj["use_yn"] = "N";
 						      items2update.push(obj);
 						}
 					}
 					// 일괄 업데이트
 					AUIGrid.updateRowsById(auiGridCenter, items2update);
 				}

			});
		}

		// 그리드생성(버튼권한)
		function createRightTopAUIGrid() {
			var gridPros = {
				rowIdField: "btn_seq",
				showRowNumColumn: true,
				fillColumnSizeMode: false,
				//전체선택 체크박스 표시 여부
				showRowAllCheckBox: true,
				editable: true,
				height: 270
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
					headerText: "",
					dataField: "btn_chk",
					width: "10%",
					style: "aui-center",
					headerRenderer: { // 헤더 렌더러
						type: "CheckBoxHeaderRenderer",
						dependentMode: true
					},
					renderer: {
						type: "CheckBoxEditRenderer",
						checkValue: "Y", // true, false 인 경우가 기본
						unCheckValue: "N",
						editable: true
					}
				},
				{
					headerText: "버튼",
					dataField: "btn_name",
					width: "90%",
					style: "aui-center",
					editable: false
				},
			];
			auiGridRightTop = AUIGrid.create("#auiGridRightTop", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridRightTop, []);
		}

		// 그리드생성(추가설정)
		function createRightBottomAUIGrid() {
			var gridPros = {
				rowIdField : "menu_add_cd",
				showRowNumColumn : true,
				fillColumnSizeMode : false,
				//전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
				editable : true,
				height : 268
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
					headerText : "",
					dataField : "add_chk",
					width : "10%",
					style : "aui-center",
					headerRenderer : { // 헤더 렌더러
						type : "CheckBoxHeaderRenderer",
						dependentMode : true
					},
					renderer : {
						type : "CheckBoxEditRenderer",
						checkValue : "Y", // true, false 인 경우가 기본
						unCheckValue : "N",
						editable : true
					}
				},
				{
					headerText : "추가설정",
					dataField : "menu_add_name",
					width: "90%",
					style : "aui-center",
					editable : false
				},
			];
			auiGridRightBottom = AUIGrid.create("#auiGridRightBottom", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridRightBottom, []);
		}

		// 메뉴목록 상세보기
		function goSearchMenuList() {
			$M.goNextPageAjax(this_page + "/search", "", {method : 'get'},
				function(result) {
					if(result.success) {
						// 데이터 그리드 세팅
						AUIGrid.setGridData(auiGridCenter, result.list);
						if(cellRowIndex != 0) {
							AUIGrid.setSelectionByIndex("#auiGridCenter", cellRowIndex, 0);
						};
					};
				}	
			);
		}
		
		// 상세보기
		function goSearchDetail(getParam) {
			var param = {
					"menu_seq" : getParam.menu_seq
				};
			$M.goNextPageAjax(this_page + "/" + getParam.menu_seq, $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						// 데이터 그리드 세팅
						AUIGrid.setGridData(auiGridRightTop, result.btnList);
						AUIGrid.setGridData(auiGridRightBottom, result.addList);
					};
				}	
			);
		}

		// 필드값으로 아이템들 얻기
		function getItemsByField(targetGrid, fieldName, rtnFieldName) {
			// 그리드 데이터에서 btn_chk 필드의 값이 Y 인 행 아이템 모두 반환
			var activeItems = AUIGrid.getItemsByValue(targetGrid, fieldName, "Y");
			var ids = [];
			for(var i=0, len=activeItems.length; i<len; i++) {
				ids.push(activeItems[i][rtnFieldName]); // chk여부가 Y인 값만 저장
			};
			return ids;
		}

		// 메뉴저장
		function goSave() {
			var frm = document.main_form;
			frm = $M.toValueForm(frm);

			var changeGridData = AUIGrid.getItemsByValue(auiGridCenter, "use_yn", "Y"); // 변경내역
			if (changeGridData.length == 0) {
				alert("변경된 데이터가 없습니다.");
				return false;
			}
			if($M.getValue("org_code_str") == ""){
				alert("권한을 적용할 부서를 선택하지 않았습니다.");
				return false;
			}

			var menu_seq = [];
			var use_yn = [];
			var menuCheck = "";
			if($("input[name='menu_check']:checked").val() == "Y"){
				menuCheck = "Y";
			}else{
				menuCheck = "N";
			}

			for (var i = 0; i < changeGridData.length; i++) {
				menu_seq.push(changeGridData[i].menu_seq);
				use_yn.push(menuCheck);
			}

			var option = {
				isEmpty : true
			};

			$M.setValue(frm, "upt_menu_seq_str", $M.getArrStr(menu_seq, option));
			$M.setValue(frm, "use_yn_str", $M.getArrStr(use_yn, option));
			$M.setValue(frm, "org_code_str", $M.getValue("org_code_str"));
			$M.goNextPageAjaxSave(this_page + "/menuSave", frm, {method : 'POST'},
					function(result) {
						if(result.success) {
							alert("저장이 완료되었습니다.");
							$M.setValue("save_org_code_str",$M.getValue("org_code_str"));
							goSearchMenuList();
							$("#menu_check1").prop("checked", true);
						}
					}
			);
		}

		// 상세기능저장
		function goSaveDetail() {
			var changeGridData = AUIGrid.getEditedRowItems(auiGridCenter); // 변경내역
	    	if (changeGridData.length != 0) {
    			alert("변경한 메뉴목록을 먼저 저장 후 진행해주세요.");
    			return false;
	    	}
			if (fnChangeGridDataCnt(auiGridRightTop) == 0 && fnChangeGridDataCnt(auiGridRightBottom) == 0){
				alert("저장할 버튼이 없습니다.");
				return false;
			};
			if($M.getValue("org_code_str") == ""){
				alert("버튼권한을 적용할 부서를 선택한 후 진행해주세요.");
				return false;
			}

			var btnCheckData = getItemsByField(auiGridRightTop, "btn_chk", "btn_seq");
			var btnCheck = "";
			if($("input[name='button_check']:checked").val() == "Y"){
				btnCheck = "Y";
			}else{
				btnCheck = "N";
			}

			var menuAddCds = getItemsByField(auiGridRightBottom, "add_chk", "menu_add_cd");
			var addCheck = "";
			if($("input[name='add_check']:checked").val() == "Y"){
				addCheck = "Y";
			}else{
				addCheck = "N";
			}
			
			var param = {
				"org_code_str" : $M.getValue("org_code_str"),
				"menu_seq" : $M.getValue("menu_seq"),
				"btn_seq_str" : $M.getArrStr(btnCheckData),
				"menu_add_cd_str" : $M.getArrStr(menuAddCds),
				"btnCheck" : btnCheck,
				"addCheck" : addCheck
			};
			
			$M.goNextPageAjaxSave(this_page, $M.toGetParam(param), {method : "POST"},
				function(result) {
					if(result.success) {
						alert("저장이 완료되었습니다.");
			    		$M.setValue("save_org_code_str",$M.getValue("org_code_str"));
						goSearchDetail(param);
						$("#button_check1").prop("checked", true);
						$("#add_check1").prop("checked", true);
					};
				}
			);
		}

		//팝업 닫기
		function fnClose() {
			window.close(); 
		}
		
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" id="save_org_code_str" name="save_org_code_str">
<input type="hidden" id="menu_seq" name="menu_seq">
<input type="hidden" id="upt_menu_seq_str" name="upt_menu_seq_str">
<input type="hidden" id="use_yn_str" name="use_yn_str">
<!-- 팝업 전체 영역 -->
<div class="popup-wrap width-100per">
	<!-- 메인 타이틀 -->
	<div class="main-title">
		<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
	</div>
	<!-- /메인 타이틀 -->
	<div class="content-wrap">
		<div class="title-wrap">
			<h4 class="primary">메뉴일괄적용</h4>
		</div>
		
		<!-- /검색조건 -->	
		<div class="row">
			<div class="col-7">
				<div class="title-wrap mt10">
					<h4>메뉴목록</h4>	
					<div class="form-row inline-pd">
						<div>
							<div class="form-check form-check-inline">
								<input class="form-check-input" type="radio" id="menu_check1" name="menu_check" value="Y" checked/>
								<label class="form-check-label" for="menu_check1">추가</label>
							</div>
							<div class="form-check form-check-inline">
								<input class="form-check-input" type="radio" id="menu_check2" name="menu_check" value="N" />
								<label class="form-check-label" for="menu_check2">삭제</label>
							</div>
						</div>	
					</div>
				</div>
				<!-- 그리드 생성 -->
				<div id="auiGridCenter" style="margin-top: 5px;"></div>
				<div class="right mt5" style="text-align: right;">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_L"/></jsp:include>
				</div>						
			</div>
			<div class="col-5">
				<div class="title-wrap mt10">
					<h4>버튼권한 목록</h4>	
					<div class="form-row inline-pd">
						<div>
							<div class="form-check form-check-inline">
								<input class="form-check-input" type="radio" id="button_check1" name="button_check" value="Y" checked/>
								<label class="form-check-label" for="button_check1">추가</label>
							</div>
							<div class="form-check form-check-inline">
								<input class="form-check-input" type="radio" id="button_check2" name="button_check" value="N" />
								<label class="form-check-label" for="button_check2">삭제</label>
							</div>
						</div>	
					</div>	
				</div>
				<!-- 그리드 생성 -->
				<div id="auiGridRightTop" style="margin-top: 5px;"></div>

				<div class="title-wrap mt10">
					<h4>추가설정 목록</h4>
					<div class="form-row inline-pd">
						<div>
							<div class="form-check form-check-inline">
								<input class="form-check-input" type="radio" id="add_check1" name="add_check" value="Y" checked/>
								<label class="form-check-label" for="add_check1">추가</label>
							</div>
							<div class="form-check form-check-inline">
								<input class="form-check-input" type="radio" id="add_check2" name="add_check" value="N" />
								<label class="form-check-label" for="add_check2">삭제</label>
							</div>
						</div>
					</div>
				</div>
				<!-- 그리드 생성 -->
				<div id="auiGridRightBottom" style="margin-top: 5px;"></div>

				<!-- 버튼영역 -->
				<div class="btn-group mt5">
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
					</div>						
				</div>
				<!-- /버튼영역 -->
			</div>
		</div>
		<div>
			<table class="table-border mt10">
				<colgroup>
					<col width="150px">
				</colgroup>
				<tbody>
					<tr>
						<th class="text-right essential-item">적용권한</th>
						<td>
							<input class="form-control" style="width:700px;" type="text" id="org_code_str" name="org_code_str" easyui="combogrid"
							easyuiname="orgList" panelwidth="300" idfield="org_code" textfield="path_org_name" multi="Y"/>
						</td>
					</tr>
				</tbody>
			</table>
		</div>
	</div>
</div>
	<!-- /contents 전체 영역 -->	
</form>
</body>
</html>