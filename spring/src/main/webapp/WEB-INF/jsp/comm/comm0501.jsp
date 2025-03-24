<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 결재선관리 > 지역별센터관리 > null > null
-- 작성자 : 박예진
-- 최초 작성일 : 2020-03-03 17:33:37
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var centerJson = ${orgCenterListJson}
		var rowIndex;
		var centerMngYn = "";
	
		$(document).ready(function() {
			createAUIGrid();
			goSearch();
			fnInitPage();
		});
		
		function fnInitPage() {
			centerMngYn = $M.getValue("center_mng_yn");
			var hideList = ["service_yn"];
			if(centerMngYn != "Y") {
				AUIGrid.hideColumnByDataField(auiGrid, hideList);
			}
		}
		
		function createAUIGrid() {
			var gridPros = {
				// rowIdField 설정
				rowIdField : "sale_area_code",
				// rowNumber 
				showRowNumColumn: true,
				// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
				wrapSelectionMove : false,
				enableFilter :true,
				enableSorting : false,
				// 최초 보여질 때 모두 열린 상태로 출력 여부
				displayTreeOpen : true,
				treeColumnIndex : 1,
				// 테두리 제거
// 				showSelectionBorder : false,
				// singleRow 선택모드
				selectionMode : "singleRow",
				editable : true
			};
			var myEditRenderer = {
					type : "DropDownListRenderer",
					// showEditorBtnOver : true,
					showEditorBtn : false,
					showEditorBtnOver : false,
					editable : true,
					list : centerJson,
					// historyMode : true, // 히스토리 모드 사용
					keyField : "org_code",
					valueField  : "org_name"
					
			};
			var columnLayout = [
				{ 
					headerText : "org_depth", 
					dataField : "org_depth", 
					visible : false
				},
				{ 
					headerText : "코드", 
					dataField : "sale_area_code", 
					width : "130",
					minWidth : "130",
					style : "aui-center",
					editable : false,
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "지역", 
					dataField : "path_sale_area_name", 
					style : "aui-left",
					width : "150",
					minWidth : "150",
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
					headerText : "구역도", 
					dataField : "area_do", 
					visible : false
				},
				{ 
					headerText : "구역도", 
					dataField : "area_do", 
					visible : false
				},
				{ 
					headerText : "구역도", 
					dataField : "area_do", 
					visible : false
				},
				{ 
					headerText : "구역도", 
					dataField : "area_do", 
					visible : false
				},
				{ 
					headerText : "구역도", 
					dataField : "area_do", 
					visible : false
				},
				{ 
					headerText : "구역시", 
					dataField : "area_si", 
					visible : false
				},
				{ 
					headerText : "구역표시", 
					dataField : "area_disp", 
					visible : false
				},
				{ 
					headerText : "서비스담당 변경", 
					dataField : "service_yn", 
					width : "120",
					minWidth : "120",
					style : "aui-center",
					renderer : {
						type : "CheckBoxEditRenderer",
						editable : true,
						checkValue : "Y",
						unCheckValue : "N",
						// 체크박스 Visible 함수
						visibleFunction : function(rowIndex, columnIndex, value, isChecked, item, dataField) {
							if(item.children == undefined) {
								return true;
							}
							return false;
						}
					},
					filter : {
						showIcon : true
					},
				},
				{ 
					headerText : "관할센터", 
					dataField : "org_name", 
					width : "120",
					minWidth : "120",
					style : "aui-center",
					editable : true,
					editRenderer : {
						type : "ConditionRenderer",
						conditionFunction : function(rowIndex, columnIndex, value, item, dataField) {
								return myEditRenderer;
						}
					},
					labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) { 
						var retStr = value;
						for(var j = 0; j < centerJson.length; j++) {
							if(centerJson[j]["org_code"] == value) {
								retStr = centerJson[j]["org_name"];
								break;
							}
						}
						return retStr;
					},
					filter : {
						showIcon : true
					},
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
		                 if(centerMngYn == "Y") {
		                    return "aui-editable";
		                 };
		                 return null;
					}
				},
				{ 
					headerText : "센터조직코드", 
					dataField : "org_code", 
					visible : false
				},
				{ 
					headerText : "마케팅담당자",
					dataField : "sale_mem_name", 
					width : "110",
					minWidth : "110",
					style : "aui-center",
					editable : false,
					filter : {
						showIcon : true
					},
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
		                 if(centerMngYn == "Y") {
		                    return "aui-popup";
		                 };
		                 return null;
					},
					renderer : {
						type : "TemplateRenderer"
					},
					labelFunction : function (rowIndex, columnIndex, value, headerText, item) {
						var template = value;
						if($M.nvl(value, "") != ""){
							if(centerMngYn == "Y") {
								template = '<div>' + '<a href="javascript:void(0);" style="color:black;" onclick="javascript:fnSaleMemInfo(\'' + item.sale_mem_name + '\',' + item.children + ');">' + value + '</a>' +'<button type="button" class="icon-btn-search" onclick="javascript:fnRemoveSale(\'' + item.org_code + '\');" style="position:relative; left: 5px;"> <i class="textbox-icon icon-clear"> </i></button></div>';
							} else {
								template = value;
							}
						} else {
							if(item.children == undefined) {
								value = "없음";
								if(centerMngYn == "Y") {
									template = '<div>' + '<a href="javascript:void(0);" style="color:black;" onclick="javascript:fnSaleMemInfo(\'' + item.sale_mem_name + '\',' + item.children + ');">' + value + '</a></div>';
								} else {
									template = value;
								}
							}
						}
						return template;
					}
				},
				{ 
					dataField : "sale_mem_no",
					visible : false
				},
				{ 
					headerText : "마케팅담당자 연락처",
					dataField : "sale_mem_hp_no", 
					width : "140",
					minWidth : "140",
					style : "aui-center",
					editable : false,
					filter : {
						showIcon : true
					},
// 					labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) { 
// 						var val = value;
// 						if(item.children == undefined) {
// 							val = value == "" ? "-" : value;
// 						}
// 						return val; 
// 					},
				},
				{ 
					headerText : "서비스담당", 
					dataField : "service_mem_name", 
					width : "110",
					minWidth : "110",
					style : "aui-center",
					editable : false,
					filter : {
						showIcon : true
					},
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
		                 if(centerMngYn == "Y") {
		                    return "aui-popup";
		                 };
		                 return null;
					},
					renderer : {
						type : "TemplateRenderer"
					},
					labelFunction : function (rowIndex, columnIndex, value, headerText, item) {
						var template = value;
						if($M.nvl(value, "") != ""){
							if(centerMngYn == "Y") {
								template = '<div>' + '<a href="javascript:void(0);" style="color:black;" onclick="javascript:fnServiceMemInfo(\'' + item.service_mem_name + '\',' + item.children + ');">' + value + '</a>' +'<button type="button" class="icon-btn-search" onclick="javascript:fnRemoveService(\'' + rowIndex + '\');" style="position:relative; left: 5px;"> <i class="textbox-icon icon-clear"> </i></button></div>';
							} else {
								template = value;
							}
						} else {
							if(item.children == undefined) {
								value = "없음";
								if(centerMngYn == "Y") {
									template = '<div>' + '<a href="javascript:void(0);" style="color:black;" onclick="javascript:fnServiceMemInfo(\'' + item.service_mem_name + '\',' + item.children + ');">' + value + '</a></div>';
								} else {
									template = value;
								}
							}
						}
						return template;
					}
				},
				{ 
					dataField : "service_mem_no",
					visible : false
				},
				{ 
					headerText : "서비스담당자 연락처", 
					dataField : "service_mem_hp_no", 
					width : "140",
					minWidth : "140",
					style : "aui-center",
					editable : false,
					filter : {
						showIcon : true
					},
// 					labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) { 
// 						var val = value;
// 						if(item.children == undefined) {
// 							val = value == "" ? "-" : value;
// 						}
// 						return val; 
// 					},
				},
			]
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				var frm = document.main_form;
				rowIndex = event.rowIndex;
				var item = AUIGrid.getItemByRowIndex(auiGrid, rowIndex);
				// 영업담당자 클릭 시
				if(event.dataField == 'sale_mem_name' && item.children == undefined && centerMngYn == "Y") {
					rowIndex = event.rowIndex;
// 					if(event.item['sale_mem_name'] == "") {
// 						var param = {
// 								's_mem_name' : event.item['sale_mem_name']
// 							};
// 						openSearchMemberPanel('fnSetSaleInfo', $M.toGetParam(param));
// 					}
					$M.setValue(frm, 'org_code', event.item['org_code']);
				// 서비스담당자 클릭 시
				} else if (event.dataField == 'service_mem_name' && item.children == undefined && centerMngYn == "Y") {
					rowIndex = event.rowIndex;
// 					var param = {
// 							's_mem_name' : event.item['service_mem_name']
// 						};
// 					openSearchMemberPanel('fnSetServiceInfo', $M.toGetParam(param));
					$M.setValue(frm, 'org_code', event.item['org_code']);
				}
			}); 
			// 센터 선택 전
			AUIGrid.bind(auiGrid, "cellEditBegin", function(event) {
				rowIndex = event.rowIndex;
				var item = AUIGrid.getItemByRowIndex(auiGrid, rowIndex);
				if(item.children == undefined && centerMngYn == "Y") {
		            return true;
			    }
				return true; // 22.12.09 Q&A 15589 인천, 부산 군,구 단위 추가로 인하여 기존 인천,부산의 관할센터, 담당자 변경을 위하여 수정
				// return false;
			});
			// 센터 선택 후
			AUIGrid.bind(auiGrid, "cellEditEnd", function( event ) {
				if(event.dataField == 'org_name') {
					var value = event.value;
					rowIndex = event.rowIndex;
					AUIGrid.updateRow(auiGrid, { "org_code" : value }, rowIndex);
					$M.setValue("org_code", value);
				}
			});
			$("#auiGrid").resize();
		}
		
		function fnSaleMemInfo(memName, children) {
			if(children == undefined && centerMngYn == "Y") {
				var param = {
						's_mem_name' : memName
					};
				openSearchMemberPanel('fnSetSaleInfo', $M.toGetParam(param));
			}
		}
		
		function fnServiceMemInfo(memName, children) {
			if(children == undefined && centerMngYn == "Y") {
				var param = {
						's_mem_name' : memName
					};
				openSearchMemberPanel('fnSetServiceInfo', $M.toGetParam(param));
			}
		}
		
		function goSearch() {
			var param = {
					s_sort_key : "sale_area_code",
					s_sort_method : "asc"
					
			};
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result){
					if(result.success){
						AUIGrid.setGridData(auiGrid, result.list);
						$("#total_cnt").html(result.total_cnt);
					}
				}
			); 
		}
		
		// 저장
		function goSave() {
			if (fnChangeGridDataCnt(auiGrid) == 0){
				alert(msg.alert.data.noChanged);
				return false;
			};
			var frm = fnChangeGridDataToForm(auiGrid);
			$M.goNextPageAjaxSave(this_page + "/save", frm, {method : 'POST'}, 
				function(result) {
					if(result.success) {
						AUIGrid.removeSoftRows(auiGrid);
						AUIGrid.resetUpdatedItems(auiGrid);
					};
				}
			);
		}
		
		function fnDownloadExcel() {
			  fnExportExcel(auiGrid, "지역별센터관리");
		}
		
		// 서비스 담당자 팝업 직원조회 결과
		function fnSetServiceInfo(data) {
			console.log(data);
			AUIGrid.updateRow(auiGrid, { "service_mem_no" : data.mem_no }, rowIndex);
			AUIGrid.updateRow(auiGrid, { "service_mem_name" : data.mem_name }, rowIndex);
			AUIGrid.updateRow(auiGrid, { "service_mem_hp_no" : data.hp_no_real }, rowIndex);
			
// 			var items = AUIGrid.getItemsByValue(auiGrid, "org_code", $M.getValue("org_code"));
// 			var rowIdField = AUIGrid.getProp(auiGrid, "rowIdField");
// 			var items2update = [];
// 			var item, obj;
// 			for(var i=0, len=items.length; i<len; i++) {
// 			      item = items[i];
// 			      obj = {};
// 			      obj[rowIdField] = item[rowIdField]; // 행 rowIdField 값
// 			      obj["service_mem_no"] = data.mem_no;
// 			      obj["service_mem_name"] = data.mem_name;
// 			      obj["service_mem_hp_no"] = data.hp_no;
// 			      items2update.push(obj);

// 			}
// 			// 일괄 업데이트
// 			AUIGrid.updateRowsById(auiGrid, items2update);
		}
		
		// 영업 담당자 팝업 직원조회 결과
		function fnSetSaleInfo(data) {
			
			var items = AUIGrid.getItemsByValue(auiGrid, "org_code", $M.getValue("org_code"));
			console.log("item", items);
			var rowIdField = AUIGrid.getProp(auiGrid, "rowIdField");
			var items2update = [];
			var item, obj;
			for(var i=0, len=items.length; i<len; i++) {
			      item = items[i];
			      obj = {};
			      obj[rowIdField] = item[rowIdField]; // 행 rowIdField 값
			      obj["sale_mem_name"] = data.mem_name;
			      obj["sale_mem_no"] = data.mem_no;
			      obj["sale_mem_hp_no"] = data.hp_no_real;
			      items2update.push(obj);

			}
			// 일괄 업데이트
			AUIGrid.updateRowsById(auiGrid, items2update);
		}
		
		// 영업 담당자 삭제
		function fnRemoveSale(data) {
			var items = AUIGrid.getItemsByValue(auiGrid, "org_code", data);
			var rowIdField = AUIGrid.getProp(auiGrid, "rowIdField");
			var items2update = [];
			var item, obj;
			for(var i=0, len=items.length; i<len; i++) {
			      item = items[i];
			      obj = {};
			      obj[rowIdField] = item[rowIdField]; // 행 rowIdField 값
			      obj["sale_mem_name"] = "";
			      obj["sale_mem_no"] = "";
			      obj["sale_mem_hp_no"] = "";
			      items2update.push(obj);

			}
			// 일괄 업데이트
			AUIGrid.updateRowsById(auiGrid, items2update);
		}
		
		// 서비스 담당자 삭제
		function fnRemoveService(rowIndex) {
			AUIGrid.updateRow(auiGrid, { "service_mem_no" : "" }, rowIndex);
			AUIGrid.updateRow(auiGrid, { "service_mem_name" : "" }, rowIndex);
			AUIGrid.updateRow(auiGrid, { "service_mem_hp_no" : "" }, rowIndex);
// 			var items = AUIGrid.getItemsByValue(auiGrid, "org_code", data);
// 			var rowIdField = AUIGrid.getProp(auiGrid, "rowIdField");
// 			var items2update = [];
// 			var item, obj;
// 			for(var i=0, len=items.length; i<len; i++) {
// 			      item = items[i];
// 			      obj = {};
// 			      obj[rowIdField] = item[rowIdField]; // 행 rowIdField 값
// 			      obj["service_mem_name"] = "";
// 			      obj["service_mem_no"] = "";
// 			      obj["service_mem_hp_no"] = "";
// 			      items2update.push(obj);

// 			}
// 			// 일괄 업데이트
// 			AUIGrid.updateRowsById(auiGrid, items2update);
		}
		
		// 서비스담당 일괄변경
		function goPopupSaleArea() {
			openSearchMemberPanel('fnSetServiceMultiInfo', "");
		}
		
		function fnSetServiceMultiInfo(data) {
			var items = AUIGrid.getItemsByValue(auiGrid, "service_yn", "Y");
			console.log("items", items);
			var rowIdField = AUIGrid.getProp(auiGrid, "rowIdField");
			var items2update = [];
			var item, obj;
			for(var i=0, len=items.length; i<len; i++) {
			      item = items[i];
			      obj = {};
			      obj[rowIdField] = item[rowIdField]; // 행 rowIdField 값
			      obj["service_mem_no"] = data.mem_no;
			      obj["service_mem_name"] = data.mem_name;
			      obj["service_mem_hp_no"] = data.hp_no_real;
			      obj["service_yn"] = "N";
			      items2update.push(obj);

			}
			// 일괄 업데이트
			AUIGrid.updateRowsById(auiGrid, items2update);
		}
		
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<div class="layout-box">
<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
<!-- 메인 타이틀 -->
				<div class="main-title">
					<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
				</div>
<!-- /메인 타이틀 -->
				<div class="contents">
<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<h4>조회결과</h4>
						<div class="btn-group">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
							</div>
						</div>
					</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->	
					<div id="auiGrid" style="margin-top: 5px; height:555px;"></div>
					<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">	
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">0</strong>건
						</div>				
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
					</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
				</div>						
			</div>	
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>	
		</div>
<!-- /contents 전체 영역 -->	
</div>	
<input type="hidden" id="sale_mem_name" name="sale_mem_name">
<input type="hidden" id="service_mem_name" name="service_mem_name">
<input type="hidden" id="org_code" name="org_code">
<input type="hidden" id="sale_area_code" name="sale_area_code">
<input type="hidden" id="center_mng_yn" name="center_mng_yn" value="${hasAuth}">
</form>
</body>
</html>