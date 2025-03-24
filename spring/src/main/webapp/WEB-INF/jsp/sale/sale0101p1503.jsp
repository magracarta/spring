<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp" /><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt"%><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%><%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 계약관리 > 계약/출하 > null > 계약품의서 간편등록(스탭3 유무상부품)
-- 작성자 : 김태훈
-- 최초 작성일 : 2021-04-09 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<script type="text/javascript">

	var oppRowIndex = 0;
	var oppType = "";
	var codeMapCostItemArray = JSON.parse('${codeMapJsonObj['COST_ITEM']}');
	
	$(document).ready(function() {
		createAUIGridForPart();
		
		// [행추가, 부품조회] -> 일반가 // [추가품목선별] -> vip가 로 나와서 일단 [행추가, 부품조회] 버튼 제거 요청 이원영파트장님  210609 김상덕 
		$("#_fnAddPaid").addClass("dpn");
		$("#_goPartListPaid").addClass("dpn");

		// 3-4차 기본지급품 - 행추가, 부품조회 버튼 제거
		$("#_fnAddFree").addClass("dpn");
		$("#_goPartListFree").addClass("dpn");
	});
	
	function createAUIGridForPart() {
		
		//그리드 생성 _ 유상
		var gridProsPart = {
			showFooter : true,
			footerPosition : "top",
			fillColumnSizeMode : false,
			rowIdField : "_$uid",
			headerHeight : 20,
			rowHeight : 11, 
			footerHeight : 20,
			// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
			wrapSelectionMove : false,
			showStateColumn : true,
			editable : true
		};
		var columnLayoutPart = [
			{ 
				dataField : "paid_machine_basic_part_seq", 
				visible : false
			},
			{ 
				dataField : "paid_free_yn", 
				visible : false
			},
			{ 
				headerText : "부품번호", 
				dataField : "paid_part_no", 
				width : "20%", 
				style : "aui-center",
				editRenderer : {				
					type : "ConditionRenderer", 
					conditionFunction : function(rowIndex, columnIndex, value, item, dataField) {
						var param = {
								's_search_kind' : 'DEFAULT_PART',
								's_warehouse_cd' : "${SecureUser.org_code}",
								's_only_warehouse_yn' : "N",
								's_not_sale_yn' : "Y",		// 매출정지 제외
				    			's_not_in_yn' : "Y",			// 미수입 제외
				    			's_part_mng_cd_str' : "1#6#8"
						};
						return fnGetPartSearchRenderer("part_no", param, "#auiGridPart");
					},
				}
			},
			{ 
				headerText : "부품명", 
				dataField : "paid_part_name", 
				style : "aui-left",
			},
			{ 
				headerText : "추가", 
				dataField : "paid_add_qty", 
				width : "11%", 
				style : "aui-center",
			},
			{ 
				headerText : "VIP가",
				dataField : "paid_unit_price", 
				width : "15%", 
				dataType : "numeric",
				formatString : "#,##0",
				style : "aui-right",
			},
			{ 
				headerText : "금액", 
				dataField : "paid_total_amt",
				width : "15%", 
				dataType : "numeric",
				formatString : "#,##0",
				style : "aui-right",
				expFunction : function(  rowIndex, columnIndex, item, dataField ) { 
					// 수량 * 단가 계산
					return ( item.paid_add_qty * item.paid_unit_price ); 
				}
			},
			{
				dataField : "paid_machine_name",
				visible : false
			},
			{
				dataField : "paid_part_name_change_yn",
				visible : false
			},
			{ 
				width : "10%", 
				headerText : "삭제", 
				dataField : "removeBtn", 
				renderer : {
					type : "ButtonRenderer",
					onClick : function(event) {
						var isRemoved = AUIGrid.isRemovedById(auiGridPart, event.item._$uid);
						if (isRemoved == false) {
							AUIGrid.removeRow(event.pid, event.rowIndex);
							AUIGrid.update(auiGridPart);
						} else {
							AUIGrid.restoreSoftRows(auiGridPart, "selectedIndex"); 
							AUIGrid.update(auiGridPart);
						};
					},
				},
				labelFunction : function(rowIndex, columnIndex, value,
						headerText, item) {
					return '삭제'
				},
				style : "aui-center",
				editable : false,
			},
			{
				dataField : "_$uid",
				visible : false
			},
		];
		// 푸터레이아웃
		var footerColumnLayoutPart = [ 
			{
				labelText : "합계",
				positionField : "paid_part_no"
			},{
				dataField : "paid_total_amt",
				positionField : "paid_total_amt",
				operation : "SUM",
				formatString : "#,##0",
				style : "aui-right aui-footer",
				expFunction : function(columnValues) {
					var gridData = AUIGrid.getGridData(auiGridPart);
					var rowIdField = AUIGrid.getProp(auiGridPart, "rowIdField");
					var item;
					var sum = 0;
					for(var i=0, len=gridData.length; i<len; i++) {
						item = gridData[i];
						if(!AUIGrid.isRemovedById(auiGridPart, item[rowIdField])) {
							sum += item.paid_total_amt;
						}
					}
					return Math.floor(sum);
				}
			}
		];
		
		auiGridPart = AUIGrid.create("#auiGridPart", columnLayoutPart, gridProsPart);
		AUIGrid.setFooter(auiGridPart, footerColumnLayoutPart);
		AUIGrid.setGridData(auiGridPart, []);
		
		// 추가행 에디팅 진입 허용
		AUIGrid.bind(auiGridPart, "cellEditBegin", function (event) {
			if (event.dataField == "paid_unit_price" || event.dataField == "paid_part_no") {
				<c:if test="${page.fnc.F02050_002 ne 'Y'}">
				return false;
				</c:if>
			}
			if (event.dataField == "paid_part_name") {
				var changeYn = event.item.paid_part_name_change_yn;
				if (changeYn == "Y") {
					return true;	 
				} else {
					return false;
				}
			}
		});
		
		// 유상 에디팅 정상 종료 이벤트 바인딩
		AUIGrid.bind(auiGridPart, "cellEditEndBefore", auiCellEditHandler1);
		// 유상 에디팅 정상 종료 이벤트 바인딩
		AUIGrid.bind(auiGridPart, "cellEditEnd", auiCellEditHandler1);
		// 유상 에디팅 취소 이벤트 바인딩
		AUIGrid.bind(auiGridPart, "cellEditCancel", auiCellEditHandler1);
		
		//그리드 생성 _ 무상
		var gridProsPartFree = {
				showFooter : true,
				footerPosition : "top",
				rowIdField : "_$uid", 
				// rowNumber 
				showRowNumColumn: true,
				// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
				wrapSelectionMove : false,
				showStateColumn : true,
				editable : true,
				height : 200,
				headerHeight : 20,
				rowHeight : 11, 
				footerHeight : 20,
				rowStyleFunction : function(rowIndex, item) {
					if(item.free_add_qty == "0") {
						return "aui-row-free-part-default";
					}
				return "";
				}
		};
		var columnLayoutPartFree = [
			{ 
				dataField : "free_machine_basic_part_seq", 
				visible : false
			},
			{ 
				dataField : "free_free_yn", 
				visible : false
			},
			{ 
				headerText : "부품번호", 
				dataField : "free_part_no", 
				width : "20%", 
				style : "aui-center",
				editRenderer : {				
					type : "ConditionRenderer", 
					conditionFunction : function(rowIndex, columnIndex, value, item, dataField) {
						var param = {
							's_search_kind' : 'DEFAULT_PART',
							's_warehouse_cd' : "${SecureUser.org_code}",
							's_only_warehouse_yn' : "N",
							's_not_sale_yn' : "Y",		// 매출정지 제외
							's_not_in_yn' : "Y",			// 미수입 제외
							's_part_mng_cd_str' : "1#6#8"
						};
						return fnGetPartSearchRenderer("part_no", param, "#auiGridPartFree");
					},
				},
			},
			{ 
				headerText : "부품명", 
				dataField : "free_part_name", 
				style : "aui-left",
				editable : true
			},
			{ 
				headerText : "추가", 
				dataField : "free_add_qty", 
				width : "11%",
				style : "aui-center",
				editable : true,
				editRenderer : {
				type : "InputEditRenderer",
				onlyNumeric : true, // Input 에서 숫자만 가능케 설정
				min : 1,
				validator : AUIGrid.commonValidator
				},
			},
			{ 
				headerText : "기본", 
				dataField : "free_default_qty", 
				width : "11%",
				style : "aui-center",
				editable : false,
			},
			{ 
				headerText : "VIP가",
				dataField : "free_unit_price", 
				width : "10%", 
				dataType : "numeric",
				formatString : "#,##0",
				style : "aui-right",
				editable : true,
				editRenderer : {
				      type : "InputEditRenderer",
				      onlyNumeric : true, // Input 에서 숫자만 가능케 설정
				},
			},
			{ 
				headerText : "금액", 
				dataField : "free_total_amt", 
				width : "12%", 
				dataType : "numeric",
				formatString : "#,##0",
				style : "aui-right",
				editable : true,
				formatString : "#,##0",
				editRenderer : {
				      type : "InputEditRenderer",
				      onlyNumeric : true, // Input 에서 숫자만 가능케 설정
				},
			},
			{ 
				width : "10%", 
				headerText : "삭제", 
				dataField : "removeBtn", 
				renderer : {
					type : "ButtonRenderer",
					onClick : function(event) {
						var isRemoved = AUIGrid.isRemovedById(auiGridPartFree, event.item._$uid);
						if (isRemoved == false) {
							AUIGrid.removeRow(event.pid, event.rowIndex);
							AUIGrid.update(auiGridPartFree);
						} else {
							AUIGrid.restoreSoftRows(auiGridPartFree, "selectedIndex"); 
							AUIGrid.update(auiGridPartFree);
						};
					},
				},
				labelFunction : function(rowIndex, columnIndex, value,
						headerText, item) {
					return '삭제'
				},
				style : "aui-center",
				editable : false,
			},
			{
				dataField : "free_machine_name",
				visible : false
			},
			{
				dataField : "free_part_name_change_yn",
				visible : false
			},
			{
				dataField : "_$uid",
				visible : false
			},
		];
		// 푸터레이아웃
		var footerColumnLayoutPartFree = [ 
			{
				labelText : "합계",
				positionField : "free_part_no"
			},
			{
				dataField : "free_total_amt",
				positionField : "free_total_amt",
				formatString : "#,##0",
				style : "aui-right aui-footer",
				expFunction : function(columnValues) {
					var gridData = AUIGrid.getGridData(auiGridPartFree);
					var rowIdField = AUIGrid.getProp(auiGridPartFree, "rowIdField");
					var item;
					var sum = 0;
					for(var i=0, len=gridData.length; i<len; i++) {
						item = gridData[i];
						if(!AUIGrid.isRemovedById(auiGridPartFree, item[rowIdField])) {
							sum += item.free_total_amt;
						}
					}
					return Math.floor(sum);
				}
			}
		];
		auiGridPartFree = AUIGrid.create("#auiGridPartFree", columnLayoutPartFree, gridProsPartFree);
		AUIGrid.setGridData(auiGridPartFree, []);
		AUIGrid.setFooter(auiGridPartFree, footerColumnLayoutPartFree);
		
		AUIGrid.bind(auiGridPartFree, "cellEditBegin", function (event) {
			if (event.dataField == "free_unit_price" || event.dataField == "free_part_no") {
				<c:if test="${page.fnc.F02050_002 ne 'Y'}">
				return false;
				</c:if>
			}
			if (event.dataField == "free_part_name") {
				console.log(event);
				var changeYn = event.item.free_part_name_change_yn;
				if (changeYn == "Y") {
					return true;	 
				} else {
					return false;
				}
			}
			if (event.dataField == "free_unit_price" || event.dataField == "free_total_amt") {
				return false;
			} else {
				return true;
			}			
		});
		
		// 무상 에디팅 정상 종료 이벤트 바인딩
		AUIGrid.bind(auiGridPartFree, "cellEditEndBefore", auiCellEditHandler2);
		// 무상 에디팅 정상 종료 이벤트 바인딩
		AUIGrid.bind(auiGridPartFree, "cellEditEnd", auiCellEditHandler2);
		// 무상 에디팅 취소 이벤트 바인딩
		AUIGrid.bind(auiGridPartFree, "cellEditCancel", auiCellEditHandler2);
		
//		---------------------------------- 임의비용 ---------------------------------------
		var gridProsMachineDocOppCost = {
				showFooter : true,
				footerPosition : "top",
				rowIdField : "_$uid", 
				// rowNumber 
				showRowNumColumn: true,
				footerHeight : 20,
				// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
				wrapSelectionMove : false,
				showStateColumn : true,
				editable : true,
				height : 200,
	            rowStyleFunction : function(rowIndex, item) {
	                  return "aui-row-free-part-cost"
	            }
			};
			
			var columnLayoutMachineDocOppCost = [
				{ 
					dataField : "cost_item_cd", 
					visible : false
				},
				{ 
					headerText : "임의비용명", 
					dataField : "cost_item_name", 
					width : "20%", 
					style : "aui-center",
					editable : true,
					editRenderer : {				
						type : "ConditionRenderer", 
						conditionFunction : function(rowIndex, columnIndex, value, item, dataField) {
							return myDropEditRenderer;					
						},
					},
					labelFunction : function(rowIndex, columnIndex, value, headerText, item ) { 
						var retStr = value;
						for(var i = 0, len = codeMapCostItemArray.length; i < len; i++) {
							if(codeMapCostItemArray[i]["code_value"] == value) {
								retStr = codeMapCostItemArray[i]["code_name"];
								break;
							}
						}
						return retStr;
					},
				},
				{ 
					headerText : "비고", 
					dataField : "cost_name", 
					style : "aui-left",
					renderer : { // HTML 템플릿 렌더러 사용
						type : "TemplateRenderer"
					},
					// dataField 로 정의된 필드 값이 HTML 이라면 labelFunction 으로 처리할 필요 없음.
					labelFunction : function (rowIndex, columnIndex, value, headerText, item, dataField, cItem ) { // HTML 템플릿 작성
						var template = '';
						if (item.cost_item_cd == "20" || item.cost_item_cd == "21") { // 모니터/서브딜러
							if (value == "") {
								var ret = "";
								if (item.cost_item_cd == "20") {
									ret = "현금 지급할 서브딜러를 돋보기 아이콘을 눌러서 조회하세요.";
								} else {
									ret = "서비스 쿠폰을 지급할 모니터요원을 돋보기 아이콘을 눌러서 조회하세요.";
								}	
								template = '<div style="margin-top:5px;">'+ret+'<button type="button" class="icon-btn-search" onclick="javascript:goSearchCustInfo(\'' + rowIndex + '\',' + item.cost_item_cd+');" style="float: right;"> <i class="material-iconssearch"> </i></button></div>';
							} else {
								template = '<div style="margin-top:5px;">'+value+'<button type="button" class="icon-btn-search" onclick="javascript:goSearchCustInfo(\'' + rowIndex + '\',' + item.cost_item_cd+');" style="float: right;"> <i class="material-iconssearch"> </i></button></div>';
							}	
						} else {
							template += '<div>'+value+'</div>';
						}
						return template; // HTML 템플릿 반환..그대도 innerHTML 속성값으로 처리됨
					}
				},
				{ 
					headerText : "금액", 
					dataField : "amt", 
					width : "13%", 
					style : "aui-right",
					dataType : "numeric",
					editable : true,
					formatString : "#,##0",
					editRenderer : {
					      type : "InputEditRenderer",
					      onlyNumeric : true, // Input 에서 숫자만 가능케 설정
					},
				},
				{
					width : "10%", 
					headerText : "삭제", 
					dataField : "removeBtn", 
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							AUIGrid.removeRow(event.pid, event.rowIndex);
							AUIGrid.update(auiGridOppCost);
						},
					},
					labelFunction : function(rowIndex, columnIndex, value,
							headerText, item) {
						return '삭제'
					},
					style : "aui-center",
					editable : false,
				},
				{
					dataField : "cost_cust_no",
					visible : false
				}
			];
			
			// 푸터레이아웃
			var footerColumnLayoutMachineDocOppCost = [ 
				{
					labelText : "합계",
					positionField : "cost_item_cd"
				},
				{
					dataField : "amt",
					positionField : "amt",
					formatString : "#,##0",
					style : "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGridOppCost);
						var rowIdField = AUIGrid.getProp(auiGridOppCost, "rowIdField");
						var item;
						var sum = 0;
						for(var i=0, len=gridData.length; i<len; i++) {
							item = gridData[i];
							if(!AUIGrid.isRemovedById(auiGridOppCost, item[rowIdField])) {
								sum += item.amt;
							}
						}
						return Math.floor(sum);
					}
				}
			];		
			
			auiGridOppCost = AUIGrid.create("#auiGridOppCost", columnLayoutMachineDocOppCost, gridProsMachineDocOppCost);
			AUIGrid.setGridData(auiGridOppCost, []);
			AUIGrid.setFooter(auiGridOppCost, footerColumnLayoutMachineDocOppCost);
			
			AUIGrid.bind(auiGridOppCost, "cellEditBegin", function (event) {
				if (event.dataField == "cost_name") {
					if (event.item.cost_item_cd == "20" || event.item.cost_item_cd == "21") {
						return false;
					} else {
						return true;
					}
				}
			});
			
			// 에디팅 정상 종료 이벤트 바인딩
			AUIGrid.bind(auiGridOppCost, "cellEditEndBefore", auiCellEditHandler3);
			// 에디팅 정상 종료 이벤트 바인딩
			AUIGrid.bind(auiGridOppCost, "cellEditEnd", auiCellEditHandler3);
			// 에디팅 취소 이벤트 바인딩
			AUIGrid.bind(auiGridOppCost, "cellEditCancel", auiCellEditHandler3);
	}
	
	// 편집 핸들러 (유상)
	function auiCellEditHandler1(event) {
		switch(event.type) {
			case "cellEditEndBefore" :
				if(event.dataField == "paid_part_no") {
					var isUnique = AUIGrid.isUniqueValue(auiGridPart, event.dataField, event.value);	
					if (isUnique == false && event.value != "" && event.oldValue != event.value) {
						setTimeout(function() {
							   AUIGrid.showToastMessage(auiGridPart, event.rowIndex, event.columnIndex, "부품번호가 중복됩니다.");
						}, 1);
						return "";
					} else {
						if (event.value == "") {
							return event.oldValue;
						}
					}
				}
				break;
			case "cellEditEnd" :
				if(event.dataField == "paid_part_no") {
					if (event.value == ""){
						return "";
					}
					// remote renderer 에서 선택한 값
					var item = fnGetPartItem(event.value);
					console.log(item);
					if(item === undefined) {
						AUIGrid.updateRow(auiGridPart, {paid_part_no : event.oldValue}, event.rowIndex);
					} else {
						// 수정 완료하면, 나머지 필드도 같이 업데이트 함.
						AUIGrid.updateRow(auiGridPart, {
							paid_part_name : item.part_name,
							paid_machine_basic_part_seq : null,
							paid_add_qty : 1,
							paid_unit_price : item.sale_price,
							paid_total_amt : item.total_amt,
							paid_part_name_change_yn : item.part_name_change_yn
						}, event.rowIndex);
					}
				}
				break;
			} 
			console.log(event);	
		};
		
		// 편집 핸들러 (무상)
		function auiCellEditHandler2(event) {
			switch(event.type) {
			case "cellEditEndBefore" :
				if(event.dataField == "free_part_no") {
					var isUnique = AUIGrid.isUniqueValue(auiGridPartFree, event.dataField, event.value);	
					if (isUnique == false && event.value != "" && event.oldValue != event.value) {
						setTimeout(function() {
							   AUIGrid.showToastMessage(auiGridPartFree, event.rowIndex, event.columnIndex, "부품번호가 중복됩니다.");
						}, 1);
						return "";
					} else {
						if (event.value == "") {
							return event.oldValue;
						}
					}
				}
				
				break;
				case "cellEditEnd" :
					if(event.dataField == "free_part_no") {
						if (event.value == ""){
							return "";
						}
					// remote renderer 에서 선택한 값
					var item = fnGetPartItem(event.value);
					if(item === undefined) {
						AUIGrid.updateRow(auiGridPartFree, {free_part_no : event.oldValue}, event.rowIndex);
					} else {
						// 수정 완료하면, 나머지 필드도 같이 업데이트 함.
						AUIGrid.updateRow(auiGridPartFree, {
							free_part_name : item.part_name,
							free_machine_basic_part_seq : null,
							free_add_qty : 1,
							free_default_qty : 0,
							free_unit_price : item.sale_price,
							free_total_amt : event.item.free_add_qty * item.sale_price,
							free_part_name_change_yn : item.part_name_change_yn
						}, event.rowIndex);
					}
				}
				
				var addQty;
				var addQtyRowIndex;
				
				// cost_item_yn == 'N' 일 경우 추가수량(add_qty)의 값이 변경될 때 합계금액을 구해야함. 
				if (event.dataField == "free_add_qty") {
					addQty = event.value;
					addQtyRowIndex = event.rowIndex;
					AUIGrid.updateRow(auiGridPartFree, { "free_total_amt" : addQty * event.item.free_unit_price}, addQtyRowIndex);
				}
				
				break;
			} 
		};
		
		// 편집 핸들러 (임의비용)
		function auiCellEditHandler3(event) {
			switch(event.type) {
			case "cellEditEndBefore" :
				if(event.dataField == "cost_item_name") {
					if (event.value == "22") {
						setTimeout(function() {
							AUIGrid.showToastMessage(auiGridOppCost, event.rowIndex, event.columnIndex, "등록대행은 스탭5에서 선택하세요.");
						}, 1);
						return "";
					} else {
						if (event.value == "") {
							return event.oldValue;
						}
					}
				}
			break;
			case "cellEditEnd" :
				if(event.dataField == "cost_item_name") {
					if (event.value == "20" || event.value == "21") { // 모니터/서브딜러
						var amt = 0;
						if (event.value == "20") { // 서브딜러
							amt = $M.toNum("${subDealr_amt}");
						} else if (event.value == "21") { // 모니터
							amt = $M.toNum("${monitor_amt}");
						}
						AUIGrid.updateRow(auiGridOppCost, {"amt" : amt, "cost_name" : "", "cost_cust_no" : ""}, event.rowIndex);
					} else {
						AUIGrid.updateRow(auiGridOppCost, {"amt" : 0, "cost_name" : "", "cost_cust_no" : ""}, event.rowIndex);
					}
					AUIGrid.updateRow(auiGridOppCost, {"cost_item_cd" : event.value}, event.rowIndex);
				}
			}
		}
		
		function fnAddCostItem() {
			var colIndex = AUIGrid.getColumnIndexByDataField(auiGridOppCost, "cost_item_cd");
			fnSetCellFocus(auiGridOppCost, colIndex, "cost_item_cd");
			var item = new Object();
			if(fnCheckGridEmpty3(auiGridOppCost)) {
				item.cost_name = "";
				item.cost_item_cd = "";
				item.cost_item_name = "";
				item.machine_basic_part_seq = null,
				item.amt = "",
				AUIGrid.addRow(auiGridOppCost, item, 'last');
			}
		}
		
		// 임의비용 조건부 에디트렌더러 출력(드랍다운리스트)
		var myDropEditRenderer = {
				showEditorBtnOver : true, // 마우스 오버 시 에디터버턴 보이기
				type : "DropDownListRenderer",
				keyField : 'code_value',
				valueField : 'code_name',
				list : codeMapCostItemArray,
				editable : false,
				required : true,
				multipleMode : false
		};
		
		// 모니터(21)/서브(20) 딜러 조회
		function goSearchCustInfo(rowIndex, type) {
			oppRowIndex = rowIndex;
			oppType = type;
			var param = {};
			if (type == "20") { // 서브
				param["s_cust_sale_type_cd"] = "20";
			} else { // 모니터 (OPP와 코드값 다르므로 주의!)
				param["s_cust_sale_type_cd"] = "10";
			}	
			
			openSearchCustPanel('fnSetOppCustNo', $M.toGetParam(param));
		}
		
		function fnSetOppCustNo(row) {
			var costName = row.real_cust_name+"님 ";
			if (oppType == "20") { // 서브딜러
				costName += "계산서요청 문자 발송"
			} else {
				costName += "서비스 쿠폰 발행"
			}
			var object = {
				cost_cust_no : row.cust_no,
				cost_name : costName
			};
			console.log(object, oppRowIndex);
			AUIGrid.updateRow(auiGridOppCost, object, oppRowIndex);
		}
		
		// 그리드 빈값 체크 - 유상
		function fnCheckGridEmpty1() {
			return AUIGrid.validateGridData(auiGridPart, ["paid_part_no", "paid_part_name", "paid_add_qty", "paid_unit_price", "paid_total_amt"], "필수 항목은 반드시 값을 입력해야합니다.");
		}

		// 그리드 빈값 체크 - 무상
		function fnCheckGridEmpty2() {
			return AUIGrid.validateGridData(auiGridPartFree, ["free_part_no", "free_part_name", "free_add_qty", "free_unit_price", "free_total_amt"], "필수 항목은 반드시 값을 입력해야합니다.");
		}

		// 그리드 빈값 체크 - 임의비용
		function fnCheckGridEmpty3() {
			return AUIGrid.validateGridData(auiGridOppCost, ["cost_item_cd", "cost_name", "amt"], "필수 항목은 반드시 값을 입력해야합니다.");
		}
		
		// 무상 - 행추가
		function fnAdd() {
			var colIndex = AUIGrid.getColumnIndexByDataField(auiGridPartFree, "free_part_no");
			fnSetCellFocus(auiGridPartFree, colIndex, "free_part_no");
			var item = new Object();
			if(fnCheckGridEmpty2(auiGridPartFree)) {
				item.free_cost_item_yn = "N",
				item.free_machine_basic_part_seq = null,
				item.free_part_no = "",
				item.free_part_name = "",
				item.free_add_qty = 1,
				item.free_default_qty = 0,
				item.free_unit_price = "",
				item.free_total_amt = "",
				item.free_cmd = "C",
				AUIGrid.addRow(auiGridPartFree, item, 'last');
			}	
		}
		
		// 유상 - 행추가
		function fnAddPaid() {
			var colIndex = AUIGrid.getColumnIndexByDataField(auiGridPart, "paid_part_no");
			fnSetCellFocus(auiGridPart, colIndex, "paid_part_no");
			var item = new Object();
			if(fnCheckGridEmpty1(auiGridPart)) {
				item.paid_cost_item_yn = "N",
				item.paid_part_no = "",
				item.paid_machine_basic_part_seq = null,
				item.paid_part_name = "",
				item.paid_add_qty = null,
				item.paid_unit_price = "",
				item.paid_total_amt = "",
				item.paid_part_name_change_yn = "N",
				item.paid_cmd = "C",
				AUIGrid.addRow(auiGridPart, item, 'last');
			}
		}
		
		// 유상 - 부품조회
		function goPartListPaid() {
			var items = AUIGrid.getAddedRowItems(auiGridPart);
			for (var i = 0; i < items.length; i++) {
				if (items[i].paid_part_no == "") {
					alert("추가된 행을 입력하고 시도해주세요.");
					return;
				}
			}
			if(fnCheckGridEmpty1(auiGridPart)) {
				openSearchPartPanel('setPartInfo1', 'Y');
			}	
		}
		
		// 유상 - 부품조회 창에서 받아온 값
		function setPartInfo1(rowArr) {
			var params = AUIGrid.getGridData(auiGridPart);
			// 부품조회 창에서 받아온 값 중복체크
			for (var i = 0; i < rowArr.length; i++ ) {
				var rowItems = AUIGrid.getItemsByValue(auiGridPart, "part_no", rowArr[i].part_no);
				if (rowItems.length != 0){
					return "부품번호를 다시 확인하세요.\n"+rowArr[i].part_no+" 이미 입력한 부품번호입니다.";
				}
			}
			
			var partNo ='';
			var partName ='';
			var unitPrice ='';
			var row = new Object();
			if(rowArr != null) {
				for(i=0; i<rowArr.length; i++) {
					partNo = typeof rowArr[i].part_no == "undefined" ? partNo : rowArr[i].part_no;
					partName = typeof rowArr[i].part_name == "undefined" ? partName : rowArr[i].part_name;
					row.paid_part_no = partNo;
					row.paid_machine_basic_part_seq = null;
					row.paid_part_name = partName;
					row.paid_add_qty = 1;
					row.paid_unit_price = typeof rowArr[i].unit_price == "undefined" ? unitPrice : rowArr[i].sale_price;
					row.paid_total_amt = "";
					row.paid_part_name_change_yn = rowArr[i].part_name_change_yn,
					row.paid_cost_item_yn = 'N';
					AUIGrid.addRow(auiGridPart, row, 'last');
				}
			}
		}
		
		function goPartList() {
			var items = AUIGrid.getAddedRowItems(auiGridPartFree);
			for (var i = 0; i < items.length; i++) {
				if (items[i].free_part_no == "") {
					alert("추가된 행을 입력하고 시도해주세요.");
					return;
				}
			}
			if(fnCheckGridEmpty1(auiGridPartFree)) {
				openSearchPartPanel('setPartInfo2', 'Y');
			}	
		}
		
		// 무상 - 부품조회 창에서 받아온 값
		function setPartInfo2(rowArr) {
			var params = AUIGrid.getGridData(auiGridPartFree);
			// 부품조회 창에서 받아온 값 중복체크
			for (var i = 0; i < rowArr.length; i++ ) {
				var rowItems = AUIGrid.getItemsByValue(auiGridPartFree, "free_part_no", rowArr[i].part_no);
				 if (rowItems.length != 0){
//	 				 alert("부품번호를 다시 확인하세요.\n"+rowArr[i].part_no+" 이미 입력한 부품번호입니다.");
					 return "부품번호를 다시 확인하세요.\n"+rowArr[i].part_no+" 이미 입력한 부품번호입니다.";					 
				 }
			}
			
			var partNo ='';
			var partName ='';
			var unitPrice ='';
			var addQty = 1;
			var row = new Object();
			if(rowArr != null) {
				for(i=0; i<rowArr.length; i++) {
					partNo = typeof rowArr[i].part_no == "undefined" ? partNo : rowArr[i].part_no;
					partName = typeof rowArr[i].part_name == "undefined" ? partName : rowArr[i].part_name;
					row.free_part_no = partNo;
					row.free_machine_basic_part_seq = null;
					row.free_part_name = partName;
					row.free_add_qty = addQty;
					row.free_default_qty = 0;
					row.free_unit_price = typeof rowArr[i].unit_price == "undefined" ? unitPrice : rowArr[i].sale_price;
					row.free_total_amt = addQty * rowArr[i].sale_price;
					row.free_part_name_change_yn = rowArr[i].part_name_change_yn;
					row.free_cost_item_yn = 'N';
					AUIGrid.addRow(auiGridPartFree, row, 'last');
				}
			}
		}
		
		// 유상 - 추가품목선별 팝업
		function goAddPartLinkPaidPopup() {
			var items = AUIGrid.getAddedRowItems(auiGridPart);
			for (var i = 0; i < items.length; i++) {
				if (items[i].paid_part_no == "") {
					alert("추가된 행을 입력하고 시도해주세요.");
					return;
				}
			}
			
			var param = {
					machine_plant_seq : $M.getValue("machine_plant_seq"),
		 			"s_sort_key" : "part_no",
		 			"s_sort_method" : "asc"
			};
			
			if(fnCheckGridEmpty1(auiGridPart)) {
				openAddMachinePartItem('fnSetAddMachinePartItem1', $M.toGetParam(param));
			}
		}
		
		// 유상 - 추가품목선별 팝업 데이터 세팅
		function fnSetAddMachinePartItem1(row) {
			// 기존값과 중복체크
			var rowItems = AUIGrid.getItemsByValue(auiGridPart, "paid_part_no", row.part_no);
			if (rowItems.length != 0){
				alert("부품번호를 다시 확인하세요.\n"+row.part_no+" 이미 입력한 부품번호입니다.");
				return false;					 
			}
			
			// 값 추가
			var colIndex = AUIGrid.getColumnIndexByDataField(auiGridPart, "paid_part_no");
			fnSetCellFocus(auiGridPart, colIndex, "paid_part_no");
			var item = new Object();
			if(fnCheckGridEmpty1(auiGridPart)) {
					item.paid_cost_item_yn = "N",
		    		item.paid_part_no = row.part_no,
		    		item.paid_machine_basic_part_seq = null,
		    		item.paid_part_name = row.part_name,
		    		item.paid_add_qty = row.add_qty,
		    		item.paid_unit_price = row.unit_price, // 추가품목선별에서는sale_price가 아니라 unit_price
		    		item.paid_total_amt = row.total_amt,
		    		item.paid_part_name_change_yn = row.part_name_change_yn,
		    		item.paid_cmd = "C",
		    		AUIGrid.addRow(auiGridPart, item, 'last');
			}	
		}
		
		// 무상 - 추가품목선별 팝업
		function goAddPartLinkPopup() {
			var items = AUIGrid.getAddedRowItems(auiGridPartFree);
			for (var i = 0; i < items.length; i++) {
				if (items[i].free_part_no == "") {
					alert("추가된 행을 입력하고 시도해주세요.");
					return;
				}
			}
			
			var param = {
//	 				machine_name : $M.getValue("machine_name"),
					machine_plant_seq : $M.getValue("machine_plant_seq"),
		 			"s_sort_key" : "part_no",
		 			"s_sort_method" : "asc"
			};
			
			if(fnCheckGridEmpty2(auiGridPartFree)) {
				openAddMachinePartItem('fnSetAddMachinePartItem2', $M.toGetParam(param));
			}
		}
		
		// 무상 - 추가품목선별 팝업 데이터 세팅
		function fnSetAddMachinePartItem2(row) {
			console.log(row);
			// 기존값과 중복체크
			var rowItems = AUIGrid.getItemsByValue(auiGridPartFree, "free_part_no", row.part_no);
			if (rowItems.length != 0){
				alert("부품번호를 다시 확인하세요.\n"+row.part_no+" 이미 입력한 부품번호입니다.");
				return false;					 
			}
			
			// 값 추가
			var colIndex = AUIGrid.getColumnIndexByDataField(auiGridPartFree, "free_part_no");
			fnSetCellFocus(auiGridPartFree, colIndex, "free_part_no");
			var item = new Object();
			if(fnCheckGridEmpty2(auiGridPartFree)) {
					item.free_cost_item_yn = "N",
		    		item.free_part_no = row.part_no,
		    		item.free_machine_basic_part_seq = null,
		    		item.free_part_name = row.part_name,
		    		item.free_add_qty = row.add_qty,
		    		item.free_default_qty = 0,
		    		item.free_unit_price = row.unit_price, // 추가품목선별에서는 unit_price
		    		item.free_total_amt = row.add_qty * row.unit_price,
		    		item.free_part_name_change_yn = row.part_name_change_yn,
		    		item.free_cmd = "C",
		    		AUIGrid.addRow(auiGridPartFree, item, 'last');
			}	
		}
		
		// part_no 으로 검색해온 정보 아이템(row) 반환 (엔터 or 마우스 클릭시 호출).
		function fnGetPartItem(part_no) {
			var item;
			$.each(recentPartList, function(index, row) {
				if(row.part_no == part_no) {
					item = row;
					return false; // 중지
				}
			});
	 		return item;
		 };
		 
		// 사업자조회
		function goSearchBregInfo() {
			var param = {};
	     	openSearchBregInfoPanel('fnSetBregInfo', $M.toGetParam(param));
		}
		
		// 사업자조회 결과
	  	function fnSetBregInfo(row) {
	    	var param = {
	    		cost_breg_seq : row.breg_seq,
	    		cost_part_breg_no : row.real_breg_no,
	    		cost_part_breg_rep_name : row.breg_rep_name,
	    		cost_part_breg_name : row.breg_name
	    	}
	    	$M.setValue(param);
	  	}
	
</script>
<div class="step-title">
	<span class="step-num">step03</span> <span class="step-title">유무상부품</span>
</div>
<ul class="step-info">
	<li>유상부품 및 무상부품을 추가 또는 삭제하신 후 계속 진행하시기 바랍니다.</li>
</ul>
<table class="table-border">
	<colgroup>
		<col width="">
		<col width="">
		<col width="">
		<col width="">
	</colgroup>
	<thead>
		<tr>
			<th>고객명</th>
			<th>휴대폰</th>
			<th>모델명</th>
			<th>출하희망일</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td class="text-center cust_name_view"></td>
			<td class="text-center hp_no_view"></td>
			<td class="text-center machine_name_view"></td>
			<td class="text-center receive_plan_dt_view"></td>
		</tr>
	</tbody>
</table>

<!-- 유상부품 -->
<div class="title-wrap mt10">
	<h4>유상부품</h4>
	<div class="btn-group">
		<div class="right dpf">
			<div class="input-group mr5" style="width: 140px;">
				<input type="text" class="form-control border-right-0" id="cost_part_breg_no" name="cost_part_breg_no" format="bregno" placeholder="유상부품 사업자번호 " readonly="readonly" style="background: white" size="20" maxlength="20" alt="유상부품사업자번호">
				<input type="hidden" id="cost_part_breg_seq" name="cost_part_breg_seq" alt="">
				<button type="button" onclick="javascript:goSearchBregInfo();"
					class="btn btn-icon btn-primary-gra btn-width-initial">
					<i class="material-iconssearch"></i>
				</button>
			</div>
			<div class="mr5" style="width: 90px;">
				<input type="text" class="form-control" readonly="readonly" id="cost_part_breg_rep_name" name="cost_part_breg_rep_name" size="20" maxlength="50" alt="유상부품대표자">
			</div>
			<div class="mr5" style="width: 90px;">
				<input type="text" class="form-control" readonly="readonly" id="cost_part_breg_name" name="cost_part_breg_name" size="20" maxlength="100" alt="유상부품상호">
			</div>
			<div class="form-check mr5" style="text-align: center;">
				<input class="form-check-input" type="checkbox" name="cost_taxbill_yn_check" id="cost_taxbill_yn_check" value="Y">
				<label for="cost_taxbill_yn_check">계산서미발행</label>
			</div>	
			<div>
				<button type="button" id="_fnAddPaid" class="btn btn-default" onclick="javascript:fnAddPaid()">
					<i class="material-iconsadd text-default"></i>행추가
				</button>
				<button type="button" class="btn btn-default" onclick="javascript:goAddPartLinkPaidPopup()">
					<i class="material-iconsadd text-default"></i>추가품목선별
				</button>
				<button type="button" id="_goPartListPaid" class="btn btn-default" onclick="javascript:goPartListPaid()">
					<i class="material-iconsbuild text-default"></i>부품조회
				</button>
			</div>
		</div>
	</div>
</div>
<div id="auiGridPart" style="margin-top: 5px; height: 100px;"></div>
<!-- /유상부품 -->
<!-- 무상부품 -->
<div class="title-wrap mt10">
	<h4>무상부품</h4>
	<div class="btn-group">
		<div class="right">
			<button type="button" id="_fnAddFree" class="btn btn-default" onclick="javascript:fnAdd()">
				<i class="material-iconsadd text-default"></i>행추가
			</button>
			<button type="button" class="btn btn-default" onclick="javascript:goAddPartLinkPopup()">
				<i class="material-iconsadd text-default"></i>추가품목선별
			</button>
			<button type="button" id="_goPartListFree" class="btn btn-default" onclick="javascript:goPartList()">
				<i class="material-iconsbuild text-default"></i>부품조회
			</button>
		</div>
	</div>
</div>
<div id="auiGridPartFree" style="margin-top: 5px; height: 200px;"></div>
<!-- /무상부품 -->
<div class="title-wrap mt10">
	<h4>임의비용</h4>
	<div class="btn-group">
		<div class="right">
			<c:if test="${page.fnc.F02050_002 eq 'Y'}">
				<button type="button" class="btn btn-default" onclick="javascript:fnAddCostItem();">
					<i class="material-iconsadd text-default"></i>행추가
				</button>
			</c:if>
		</div>
	</div>
</div>
<div id="auiGridOppCost" style="margin-top: 5px; height: 100px;"></div>
<!-- 그리드 서머리, 컨트롤 영역 -->
<div class="btn-group mt10">
	<div class="right">
		<button type="button" class="btn btn-md btn-info" style="width: 50px;" onclick="javascript:fnCompleteStep(3)">다음</button>
	</div>
</div>
