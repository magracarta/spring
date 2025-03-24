<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 장비연관팝업 > 장비연관팝업 > null > 유/무상 부품조회
-- 작성자 : 황빛찬
-- 최초 작성일 : 2020-04-10 14:40:34
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>
	
	var codeMapCostItemArray = JSON.parse('${codeMapJsonObj['COST_ITEM']}');
	var codeMapCostApplyArray = JSON.parse('${codeMapJsonObj['COST_APPLY']}');

	var oppRowIndex = 0;
	var oppType = "";
	
	var auiGridPartPaid; // 유상부품
	var auiGridPartFree; // 기본지급품
	var auiGridMachineDocOppCost; // 임의비용
	var auiGridMachineCostApply; // 원가반영
	var pageType = "${inputParam.page_type}";  // 부모 페이지 타입 (DOC, REQ)
	
	var parentPaidList; // 부모페이지에 넘겨줄 유상부품 List
	var parentFreeList; // 부모페이지에 넘겨줄 기본지급품 List
	var parentOppList; // 부모페이지에 넘겨줄 임의비용 List
	var parentCostList; // 부모페이지에 넘겨줄 원가반영 List
	var visibles = false;
	
	$(document).ready(function() {
		if (opener == null) {
			alert("비정상 접근");
			fnClose();
		}
		// 견적서에서는 임의비용추가 버튼 사용x
		if (pageType == 'RFQ' || pageType == 'OUT' || '${page.fnc.F00572_001}' == 'Y') {
			$(".oppCostArea").css({
				display: "none"
			});
		}
		if (pageType == 'OUT') {
			$("#_fnAddPaid").css("display", "none");
			$("#_goAddPartLinkPaidPopup").css("display", "none");
			$("#_goPartListPaid").css("display", "none");
			$("#auiGrid_part_paid :input").prop("disabled", true);
		}
		createAUIGrid();
		
		// [행추가, 부품조회] -> 일반가 // [추가품목선별] -> vip가 로 나와서 일단 [행추가, 부품조회] 버튼 제거 요청 이원영파트장님  210609 김상덕 
		$("#_fnAddPaid").addClass("dpn");
		$("#_goPartListPaid").addClass("dpn");

		// 3-4차 기본지급품 - 행추가, 부품조회 버튼 제거
		$("#_fnAdd").addClass("dpn");
		$("#_goPartList").addClass("dpn");
	});
	
	// 닫기
	function fnClose() {
		window.close(); 
	}
	
	// 저장
	function goSave() {
		
		// 벨리데이션
		if (fnCheckGridEmpty1() === false){
			alert("필수 항목은 반드시 값을 입력해야합니다.");
			return false;
		}

		if (fnCheckGridEmpty2() === false){
			alert("필수 항목은 반드시 값을 입력해야합니다.");
			return false;
		}

		if (fnCheckGridEmpty3() === false){
			alert("필수 항목은 반드시 값을 입력해야합니다.");
			return false;
		}

		if (fnCheckGridEmpty4() === false){
			alert("필수 항목은 반드시 값을 입력해야합니다.");
			return false;
		}
		
		if (pageType != 'OUT') {
			// 유상 그리드 업데이트
			AUIGrid.removeSoftRows(auiGridPartPaid);
			AUIGrid.resetUpdatedItems(auiGridPartPaid);

			// 무상 그리드 업데이트
			AUIGrid.removeSoftRows(auiGridPartFree);
			AUIGrid.resetUpdatedItems(auiGridPartFree);

			// 임의비용 그리드 업데이트
			AUIGrid.removeSoftRows(auiGridMachineDocOppCost);
			AUIGrid.resetUpdatedItems(auiGridMachineDocOppCost);

			// 원가반영 그리드 업데이트
			AUIGrid.removeSoftRows(auiGridMachineCostApply);
			AUIGrid.resetUpdatedItems(auiGridMachineCostApply);
		} else {
			// 유상 추가된 행 아이템들(배열)
			var padd = AUIGrid.getAddedRowItems(auiGridPartPaid);
			for (var i = 0 ; i < padd.length; ++i) {
				AUIGrid.updateRow(auiGridPartPaid, {"cmd" : "C"}, AUIGrid.rowIdToIndex(auiGridPartPaid, padd[i]._$uid));
			}
			// 유상 수정된 행 아이템들(배열)
			var pedit = AUIGrid.getEditedRowItems(auiGridPartPaid);
			for (var i = 0 ; i < pedit.length; ++i) {
				if (pedit[i].cmd != "C") {
					AUIGrid.updateRow(auiGridPartPaid, {"cmd" : "U"}, AUIGrid.rowIdToIndex(auiGridPartPaid, pedit[i]._$uid));					
				}
			}
			
			// 무상 추가된 행 아이템들(배열)
			var fadd = AUIGrid.getAddedRowItems(auiGridPartFree);
			for (var i = 0 ; i < fadd.length; ++i) {
				AUIGrid.updateRow(auiGridPartFree, {"cmd" : "C"}, AUIGrid.rowIdToIndex(auiGridPartFree, fadd[i]._$uid));
			}
			// 무상 수정된 행 아이템들(배열)
			var fedit = AUIGrid.getEditedRowItems(auiGridPartFree);
			for (var i = 0 ; i < fedit.length; ++i) {
				if (fedit[i].cmd != "C") {
					AUIGrid.updateRow(auiGridPartFree, {"cmd" : "U"}, AUIGrid.rowIdToIndex(auiGridPartFree, fedit[i]._$uid));
				}
			}
		}
		
		// cost_item_yn = 'Y'  --> 임의비용추가로 추가된 row
		// add_qty != 0  --> 추가된 row
		var freeStr = "free_";
		var paidStr = "paid_";
		parentPaidList = [];  // 유상부품 
		parentFreeList = [];  // 기본지급품
		var paidTemp = AUIGrid.getGridData(auiGridPartPaid);  // 유상부품 그리드 데이터
		var freeTemp = AUIGrid.getGridData(auiGridPartFree);  // 기본지급품 그리드 데이터
		parentOppList = AUIGrid.getGridData(auiGridMachineDocOppCost); // 임의비용 그리드 데이터
		parentCostList = AUIGrid.getGridData(auiGridMachineCostApply); // 임의비용 그리드 데이터

		// 유상부품리스트 앞에 faid_ 붙이는 작업
		for (var i = 0; i < paidTemp.length; i++) {
			var obj = new Object();
			for (var prop in paidTemp[i]) {
			    obj[paidStr+prop] = paidTemp[i][prop];
			}
			parentPaidList.push(obj);
		}
		
		// 기본지급품 리스트 앞에 free_ 붙이는 작업
		for (var i = 0; i < freeTemp.length; i++) {
			var obj = new Object();
			if (freeTemp[i].cost_item_yn == 'Y') {
				freeTemp[i].cost_item_remark = freeTemp[i].part_name;
			} else {
				freeTemp[i].cost_item_remark = null;
			}
			
			for (var prop in freeTemp[i]) {
				obj[freeStr+prop] = freeTemp[i][prop];
			}
			
			parentFreeList.push(obj);
		}
		
		console.log("유상부품 : ", parentPaidList);
		console.log("기본지급품 : ", parentFreeList);
		console.log("임의비용 : ", parentOppList);
		console.log("원가반영 : ", parentCostList);

		// 유상, 무상 리스트를 담아 부모페이지로 넘길 객체
		var list = {
				"parentPaidList" : parentPaidList,
				"parentFreeList" : parentFreeList,
				"parentOppList" : parentOppList,
				"parentCostList" : parentCostList,
		}
		
		try{
			opener.${inputParam.parent_js_name}(list);
			window.close();	
		} catch(e) {
			alert('호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.');
		}
	}
	
//		---------------------------------- 유상 ---------------------------------------
	
	function createAUIGrid() {
		//그리드 생성 _ 유상
		var gridProsPartPaid = {
			showFooter : true,
			footerPosition : "top",
			rowIdField : "_$uid",
			height : 200,
			// rowNumber 
			showRowNumColumn: true,
			// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
			wrapSelectionMove : false,
			showStateColumn : true,
			editable : true
		};
		var columnLayoutPartPaid = [
			{
				dataField : "cost_item_yn",
				headerText : "임의비용여부",
				visible:false
			},
			{
				dataField : "machine_plant_seq",
				visible:false
			}, 
			{
				dataField : "machine_name",
				headerText : "장비명",
				visible:false
			}, 
			{
				dataField : "machine_basic_part_seq",
				visible:false
			}, 
			{ 
				headerText : "부품번호", 
				dataField : "part_no", 
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
						return fnGetPartSearchRenderer(dataField, param, "#auiGrid_part_paid");
					},
				}
			},
			{ 
				headerText : "부품명", 
				dataField : "part_name", 
				style : "aui-left"
			},
			{ 
				headerText : "추가수량", 
				dataField : "add_qty", 
				width : "10%", 
				style : "aui-center aui-editable",
				dataType : "numeric",
				editable : true,
				editRenderer : {
				      type : "InputEditRenderer",
				      onlyNumeric : true, // Input 에서 숫자만 가능케 설정
				      min : 1,
				      validator : AUIGrid.commonValidator
				}
			},
			{ 
				// headerText : "단가",
				headerText : "VIP가",
				dataField : "unit_price",
				width : "10%", 
				dataType : "numeric",
				formatString : "#,##0",
// 				style : "aui-center aui-editable",
				// (Q&A 11830) 대리점에선 금액변경 안되도록 수정 211006 김상덕
				style : "aui-right",
				styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if ('Y' == '${page.fnc.F00572_001}') {
		             	return "";
		            } else {
		             	return "aui-editable";
		            }
				},
				editable : true,
				editRenderer : {
				      type : "InputEditRenderer",
				      onlyNumeric : true, // Input 에서 숫자만 가능케 설정
				}
			},
			{ 
				headerText : "금액", 
				dataField : "total_amt", 
				dataType : "numeric",
				onlyNumeric : true,
				formatString : "#,##0",
				width : "13%", 
				style : "aui-right",
				editable : false,
				expFunction : function(  rowIndex, columnIndex, item, dataField ) { 
					// 수량 * 단가 계산
					return ( item.add_qty * item.unit_price ); 
				}
			},
			{ 
				width : "10%", 
				headerText : "삭제", 
				dataField : "removeBtn", 
				renderer : {
					type : "ButtonRenderer",
					onClick : function(event) {
						var isRemoved = AUIGrid.isRemovedById(auiGridPartPaid, event.item._$uid);
						if (isRemoved == false) {
							if (pageType == 'OUT') {
								AUIGrid.updateRow(auiGridPartPaid, {cmd : "D"}, event.rowIndex);	
							}
							AUIGrid.removeRow(event.pid, event.rowIndex);
							AUIGrid.update(auiGridPartPaid);
						} else {
							AUIGrid.restoreSoftRows(auiGridPartPaid, "selectedIndex"); 
							if (pageType == 'OUT') {
								AUIGrid.updateRow(auiGridPartPaid, {cmd : "U"}, event.rowIndex);	
							}
							AUIGrid.update(auiGridPartPaid);
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
				dataField : "cmd",
				visible : visibles
			},
			{
				dataField : "attach_yn",
				visible : visibles
			},
			{
				dataField : "no_out_qty",
				visible : visibles
			},
			{
				dataField : "add_doc_yn",
				visible : visibles
			},
			{
				dataField : "doc_seq_no",
				visible : visibles
			},
			{
				dataField : "_$uid",
				visible : visibles
			},
			{
				dataField : "part_name_change_yn",
				visible : visibles
			}
		];
		
		// 푸터레이아웃
		var footerColumnLayoutPartPaid = [ 
			{
				labelText : "합계",
				positionField : "part_no"
			},
			{
				dataField : "total_amt",
				positionField : "total_amt",
				formatString : "#,##0",
				style : "aui-right aui-footer",
				expFunction : function(columnValues) {
					var gridData = AUIGrid.getGridData(auiGridPartPaid);
					var rowIdField = AUIGrid.getProp(auiGridPartPaid, "rowIdField");
					var item;
					var sum = 0;
					for(var i=0, len=gridData.length; i<len; i++) {
						item = gridData[i];
						if(!AUIGrid.isRemovedById(auiGridPartPaid, item[rowIdField])) {
							sum += item.total_amt;
						}
					}
					return Math.floor(sum);
				}
			}
		];

		auiGridPartPaid = AUIGrid.create("#auiGrid_part_paid", columnLayoutPartPaid, gridProsPartPaid);
		AUIGrid.setGridData(auiGridPartPaid, opener.parentPaidList);
		
		if (pageType == "OUT") {
			var prmArr = [];
			var pArr = AUIGrid.getGridData(auiGridPartPaid);
			for (var i = 0; i <  pArr.length; ++i) {
				if (pArr[i].cmd == "D") {
					console.log(pArr[i].cmd);
					prmArr.push(AUIGrid.rowIdToIndex(auiGridPartPaid, pArr[i]._$uid));
				}
			}
			AUIGrid.removeRow(auiGridPartPaid, prmArr);
		}
		
		AUIGrid.setFooter(auiGridPartPaid, footerColumnLayoutPartPaid);
		
		// 추가행 에디팅 진입 허용
		AUIGrid.bind(auiGridPartPaid, "cellEditBegin", function (event) {
			if (event.dataField == "part_name") {
				var changeYn = event.item.part_name_change_yn;
				if (changeYn == "Y") {
					return true;	 
				} else {
					return false;
				}
			}
			// (Q&A 11830) 대리점에선 금액변경 안되도록 수정 211006 김상덕
			// 대리점은 유상부품 검색안되게 수정함! 21.10.06 김태훈
			if (event.dataField == "unit_price" || event.dataField == "part_no") {
				if ('Y' == '${page.fnc.F00572_001}') {
					return false;
				} else {
					return true;
				}
			}
			
		});
		
		// 에디팅 정상 종료 이벤트 바인딩
		AUIGrid.bind(auiGridPartPaid, "cellEditEndBefore", auiCellEditHandler1);
		// 에디팅 정상 종료 이벤트 바인딩
		AUIGrid.bind(auiGridPartPaid, "cellEditEnd", auiCellEditHandler1);
		// 에디팅 취소 이벤트 바인딩
		AUIGrid.bind(auiGridPartPaid, "cellEditCancel", auiCellEditHandler1);
		
		$("#auiGrid_part_paid").resize();
		
// 		---------------------------------- 무상 ---------------------------------------
		
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
			rowStyleFunction : function(rowIndex, item) {
				if(item.add_qty == "0") {
					return "aui-row-free-part-default";
				}
			return "";
			}
		};
		
		var columnLayoutPartFree = [
			{ 
				dataField : "machine_basic_part_seq", 
				visible : false
			},			
			{
				dataField : "machine_plant_seq",
				visible:false
			}, 
			{
				dataField : "machine_name",
				headerText : "장비명",
				visible:false
			}, 
			{ 
				headerText : "부품번호", 
				dataField : "part_no", 
				width : "20%", 
				style : "aui-center",
				editable : true,
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
						return fnGetPartSearchRenderer(dataField, param, "#auiGrid_part_free");
					},
				},
			},
			{ 
				headerText : "부품명", 
				dataField : "part_name", 
				style : "aui-left",
				editable : true
			},
			{ 
				headerText : "추가수량", 
				dataField : "add_qty", 
				width : "10%", 
				style : "aui-center aui-editable",
				dataType : "numeric",
				editable : true,
				editRenderer : {
				type : "InputEditRenderer",
				onlyNumeric : true, // Input 에서 숫자만 가능케 설정
				min : 1,
				validator : AUIGrid.commonValidator
				},
			},
			{ 
				headerText : "기본수량", 
				dataField : "default_qty", 
				width : "10%", 
				style : "aui-center",
				editable : false,
				editRenderer : {
				      type : "InputEditRenderer",
				      onlyNumeric : true, // Input 에서 숫자만 가능케 설정
				},
			},
			{ 
				// headerText : "단가",
				headerText : "VIP가",
				dataField : "unit_price",
				width : "10%", 
				style : "aui-center",
				dataType : "numeric",
				formatString : "#,##0",
				editable : true,
				editRenderer : {
				      type : "InputEditRenderer",
				      onlyNumeric : true, // Input 에서 숫자만 가능케 설정
				},
			},
			{ 
				headerText : "금액", 
				dataField : "total_amt", 
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
						var isRemoved = AUIGrid.isRemovedById(auiGridPartFree, event.item._$uid);
						if (isRemoved == false) {
							if (pageType == 'OUT') {
								AUIGrid.updateRow(auiGridPartFree, {cmd : "D"}, event.rowIndex);	
							}
							AUIGrid.removeRow(event.pid, event.rowIndex);
							AUIGrid.update(auiGridPartFree);
						} else {
							AUIGrid.restoreSoftRows(auiGridPartFree, "selectedIndex"); 
							if (pageType == 'OUT') {
								AUIGrid.updateRow(auiGridPartFree, {cmd : "U"}, event.rowIndex);	
							}
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
				dataField : "attach_yn",
				visible : visibles
			},
			{
				dataField : "no_out_qty",
				visible : visibles
			},
			{
				dataField : "add_doc_yn",
				visible : visibles
			},
			{
				dataField : "doc_seq_no",
				visible : visibles
			},
			{
				dataField : "cmd",
				visible : visibles
			},
			{
				dataField : "_$uid",
				visible : visibles
			},
			{
				dataField : "part_name_change_yn",
				visible : visibles
			}
		];
		
		// 푸터레이아웃
		var footerColumnLayoutPartFree = [ 
			{
				labelText : "합계",
				positionField : "part_no"
			},
			{
				dataField : "total_amt",
				positionField : "total_amt",
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
							sum += item.total_amt;
						}
					}
					return Math.floor(sum);
				}
			}
		];		
		
		auiGridPartFree = AUIGrid.create("#auiGrid_part_free", columnLayoutPartFree, gridProsPartFree);
		AUIGrid.setGridData(auiGridPartFree, opener.parentFreeList);
		
		if (pageType == "OUT") {
			var frmArr = [];
			var fArr = AUIGrid.getGridData(auiGridPartFree);
			for (var i = 0; i <  fArr.length; ++i) {
				if (fArr[i].cmd == "D") {
					frmArr.push(AUIGrid.rowIdToIndex(auiGridPartFree, fArr[i]._$uid));
				}
			}
			AUIGrid.removeRow(auiGridPartFree, frmArr);
		}
		
		AUIGrid.setFooter(auiGridPartFree, footerColumnLayoutPartFree);
		
		// 추가행 에디팅 진입 허용
		AUIGrid.bind(auiGridPartFree, "cellEditBegin", function (event) {
			if (event.dataField == "part_name") {
				console.log(event);
				var changeYn = event.item.part_name_change_yn;
				if (changeYn == "Y") {
					return true;	 
				} else {
					return false;
				}
			}
			if (event.dataField == "unit_price" || event.dataField == "total_amt") {
				return false;
			} else {
				return true;
			}			
		});
		
		
		// 에디팅 정상 종료 이벤트 바인딩
		AUIGrid.bind(auiGridPartFree, "cellEditEndBefore", auiCellEditHandler2);
		// 에디팅 정상 종료 이벤트 바인딩
		AUIGrid.bind(auiGridPartFree, "cellEditEnd", auiCellEditHandler2);
		// 에디팅 취소 이벤트 바인딩
		AUIGrid.bind(auiGridPartFree, "cellEditCancel", auiCellEditHandler2);
		
		$("#auiGrid_part_free").resize();
		
		
//		---------------------------------- 임의비용 ---------------------------------------
	// 임의비용 그리드 생성
		var gridProsMachineDocOppCost = {
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
            rowStyleFunction : function(rowIndex, item) {
                  return "aui-row-free-part-cost"
            }
		};
		
		var columnLayoutMachineDocOppCost = [
			{ 
				dataField : "cost_item_name", 
				visible : false
			},
			{ 
				headerText : "임의비용명", 
				dataField : "cost_item_cd",
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
							AUIGrid.updateRow(auiGridMachineDocOppCost, {"cost_item_name" : value}, rowIndex);
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
					if (item.cost_item_cd == "20" || item.cost_item_cd == "21" || item.cost_item_cd == "15") { // 모니터/서브딜러/소개비
						if (value == "") {
							var ret = "";
							if (item.cost_item_cd == "20") {
								ret = "현금 지급할 서브딜러를 돋보기 아이콘을 눌러서 조회하세요.";
							} else if (item.cost_item_cd == "21") {
								ret = "마일리지 적립할 모니터요원을 돋보기 아이콘을 눌러서 조회하세요.";
							} else {
								ret = "현금 지급할 고객을 돋보기 아이콘을 눌러서 조회하세요.";
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
						var isRemoved = AUIGrid.isRemovedById(auiGridMachineDocOppCost, event.item._$uid);
						if (isRemoved == false) {
							AUIGrid.removeRow(event.pid, event.rowIndex);
							AUIGrid.update(auiGridMachineDocOppCost);
						} else {
							AUIGrid.restoreSoftRows(auiGridMachineDocOppCost, "selectedIndex"); 
							AUIGrid.update(auiGridMachineDocOppCost);
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
					var gridData = AUIGrid.getGridData(auiGridMachineDocOppCost);
					var rowIdField = AUIGrid.getProp(auiGridMachineDocOppCost, "rowIdField");
					var item;
					var sum = 0;
					for(var i=0, len=gridData.length; i<len; i++) {
						item = gridData[i];
						if(!AUIGrid.isRemovedById(auiGridMachineDocOppCost, item[rowIdField])) {
							sum += item.amt;
						}
					}
					return Math.floor(sum);
				}
			}
		];		
		
		auiGridMachineDocOppCost = AUIGrid.create("#auiGrid_machine_doc_opp_cost", columnLayoutMachineDocOppCost, gridProsMachineDocOppCost);
		AUIGrid.setGridData(auiGridMachineDocOppCost, opener.parentOppCost);
		AUIGrid.setFooter(auiGridMachineDocOppCost, footerColumnLayoutMachineDocOppCost);
		
		AUIGrid.bind(auiGridMachineDocOppCost, "cellEditBegin", function (event) {
			if (event.dataField == "cost_name") {
				if (event.item.cost_item_cd == "20" || event.item.cost_item_cd == "21" || event.item.cost_item_cd == "15") {
					return false;
				} else {
					return true;
				}
			}
		});
		
		// 에디팅 정상 종료 이벤트 바인딩
		AUIGrid.bind(auiGridMachineDocOppCost, "cellEditEndBefore", auiCellEditHandler3);
		// 에디팅 정상 종료 이벤트 바인딩
		AUIGrid.bind(auiGridMachineDocOppCost, "cellEditEnd", auiCellEditHandler3);
		// 에디팅 취소 이벤트 바인딩
		AUIGrid.bind(auiGridMachineDocOppCost, "cellEditCancel", auiCellEditHandler3);
		
		$("#auiGrid_machine_doc_opp_cost").resize();

//		---------------------------------- 원가반영 ---------------------------------------
		var gridProsMachineCostApply = {
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
			rowStyleFunction : function(rowIndex, item) {
				return "aui-row-free-part-cost"
			}
		};

		var columnLayoutMachineCostApply = [
			{
				dataField : "cost_item_cd",
				visible : false
			},
			{
				headerText : "원가반영 명",
				dataField : "cost_apply_cd",
				width : "20%",
				style : "aui-center",
				editable : true,
				editRenderer : {
					type : "ConditionRenderer",
					conditionFunction : function(rowIndex, columnIndex, value, item, dataField) {
						return myDropEditApplyRenderer;
					},
				},
				labelFunction : function(rowIndex, columnIndex, value, headerText, item ) {
					var retStr = value;
					for(var i = 0, len = codeMapCostApplyArray.length; i < len; i++) {
						if(codeMapCostApplyArray[i]["code_value"] == value) {
							retStr = codeMapCostApplyArray[i]["code_name"];
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
					if (item.cost_item_cd == "20" || item.cost_item_cd == "21" || item.cost_item_cd == "15") { // 모니터/서브딜러
						if (value == "") {
							var ret = "";
							if (item.cost_item_cd == "20") {
								ret = "현금 지급할 서브딜러를 돋보기 아이콘을 눌러서 조회하세요.";
							} else if (item.cost_item_cd == "21") {
								ret = "마일리지 적립할 모니터요원을 돋보기 아이콘을 눌러서 조회하세요.";
							} else {
								ret = "현금 지급할 고객을 돋보기 아이콘을 눌러서 조회하세요.";
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
						var isRemoved = AUIGrid.isRemovedById(auiGridMachineCostApply, event.item._$uid);
						if (isRemoved == false) {
							AUIGrid.removeRow(event.pid, event.rowIndex);
							AUIGrid.update(auiGridMachineCostApply);
						} else {
							AUIGrid.restoreSoftRows(auiGridMachineCostApply, "selectedIndex");
							AUIGrid.update(auiGridMachineCostApply);
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
		];

		// 푸터레이아웃
		var footerColumnLayoutMachineCostApply = [
			{
				labelText : "합계",
				positionField : "cost_apply_cd"
			},
			{
				dataField : "amt",
				positionField : "amt",
				formatString : "#,##0",
				style : "aui-right aui-footer",
				expFunction : function(columnValues) {
					var gridData = AUIGrid.getGridData(auiGridMachineCostApply);
					var rowIdField = AUIGrid.getProp(auiGridMachineCostApply, "rowIdField");
					var item;
					var sum = 0;
					for(var i=0, len=gridData.length; i<len; i++) {
						item = gridData[i];
						if(!AUIGrid.isRemovedById(auiGridMachineCostApply, item[rowIdField])) {
							sum += item.amt;
						}
					}
					return Math.floor(sum);
				}
			}
		];

		auiGridMachineCostApply = AUIGrid.create("#auiGrid_machine_cost_apply", columnLayoutMachineCostApply, gridProsMachineCostApply);
		AUIGrid.setGridData(auiGridMachineCostApply, opener.parentCostApply);
		AUIGrid.setFooter(auiGridMachineCostApply, footerColumnLayoutMachineCostApply);
	}

	// 조건부 에디트렌더러 출력(드랍다운리스트)
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

	var myDropEditApplyRenderer = {
		showEditorBtnOver : true, // 마우스 오버 시 에디터버턴 보이기
		type : "DropDownListRenderer",
		keyField : 'code_value',
		valueField : 'code_name',
		list : codeMapCostApplyArray,
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
		} else if (type == "21") { // 모니터 (OPP와 코드값 다르므로 주의!)
			param["s_cust_sale_type_cd"] = "10";
		} else {
			param["s_cust_sale_type_cd"] = "00";
		}
		
		openSearchCustPanel('fnSetOppCustNo', $M.toGetParam(param));
	}
	
	function fnSetOppCustNo(row) {
		var costName = row.real_cust_name+"님 ";
		if (oppType == "20") { // 서브딜러
			costName += "계산서요청 문자 발송"
		} else if (oppType == "21") {
			costName += "서비스 쿠폰 발행"
		} else {
			costName += "계산서요청 문자 발송"
		}
		var object = {
			cost_cust_no : row.cust_no,
			cost_name : costName
		};
		console.log(object, oppRowIndex);
		AUIGrid.updateRow(auiGridMachineDocOppCost, object, oppRowIndex);
	}
			
	// 무상 - 행추가
	function fnAdd() {
		var colIndex = AUIGrid.getColumnIndexByDataField(auiGridPartFree, "part_no");
		fnSetCellFocus(auiGridPartFree, colIndex, "part_no");
		var item = new Object();
		if(fnCheckGridEmpty2(auiGridPartFree)) {
			item.cost_item_yn = "N",
			item.machine_basic_part_seq = null,
			item.part_no = "",
			item.part_name = "",
			item.add_qty = 1,
			item.default_qty = 0,
			item.unit_price = "",
			item.total_amt = "",
			item.cmd = "C",
			AUIGrid.addRow(auiGridPartFree, item, 'last');
		}
	}
	
	// 편집 핸들러 (유상)
	function auiCellEditHandler1(event) {
		switch(event.type) {
			case "cellEditEndBefore" :
				if(event.dataField == "part_no") {
					var isUnique = AUIGrid.isUniqueValue(auiGridPartPaid, event.dataField, event.value);	
					if (isUnique == false && event.value != "" && event.oldValue != event.value) {
						setTimeout(function() {
							   AUIGrid.showToastMessage(auiGridPartPaid, event.rowIndex, event.columnIndex, "부품번호가 중복됩니다.");
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
				if(event.dataField == "part_no") {
					if (event.value == ""){
						return "";
					}
					// remote renderer 에서 선택한 값
					var item = fnGetPartItem(event.value);
					if(item === undefined) {
						AUIGrid.updateRow(auiGridPartPaid, {part_no : event.oldValue}, event.rowIndex);
					} else {
						// 수정 완료하면, 나머지 필드도 같이 업데이트 함.
						AUIGrid.updateRow(auiGridPartPaid, {
							part_name : item.part_name,
							machine_basic_part_seq : null,
							add_qty : 1,
							unit_price : item.sale_price,
							total_amt : item.total_amt,
							part_name_change_yn : item.part_name_change_yn
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
			if(event.dataField == "part_no") {
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
				if(event.dataField == "part_no") {
					if (event.value == ""){
						return "";
					}
					// remote renderer 에서 선택한 값
					var item = fnGetPartItem(event.value);
					if (event.item.cost_item_yn == "Y") {
						AUIGrid.updateRow(auiGridPartFree, { "cost_item_cd" : event.value}, event.rowIndex);
					} else {
						if(item === undefined) {
							AUIGrid.updateRow(auiGridPartFree, {part_no : event.oldValue}, event.rowIndex);
						} else {
							// 수정 완료하면, 나머지 필드도 같이 업데이트 함.
							AUIGrid.updateRow(auiGridPartFree, {
								part_name : item.part_name,
								machine_basic_part_seq : null,
								add_qty : 1,
								default_qty : 0,
								unit_price : item.sale_price,
								total_amt : event.item.add_qty * item.sale_price,
								part_name_change_yn : item.part_name_change_yn
							}, event.rowIndex);
						} 
					}
				}
				
				var addQty;
				var addQtyRowIndex;
				
				// cost_item_yn == 'N' 일 경우 추가수량(add_qty)의 값이 변경될 때 합계금액을 구해야함. 
				if (event.dataField == "add_qty") {
					addQty = event.value;
					addQtyRowIndex = event.rowIndex;
					AUIGrid.updateRow(auiGridPartFree, { "total_amt" : addQty * event.item.unit_price}, addQtyRowIndex);
				}
				
				break;
			} 
		};
		
	function auiCellEditHandler3(event) {
		switch(event.type) {
		case "cellEditEndBefore" :
			if(event.dataField == "cost_item_cd") {
				if (event.value == "22") {
					setTimeout(function() {
						AUIGrid.showToastMessage(auiGridMachineDocOppCost, event.rowIndex, event.columnIndex, "등록대행은 품의서 하단에서 체크하십시오.");
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
			if(event.dataField == "cost_item_cd") {
				if (event.value == "20" || event.value == "21") { // 모니터/서브딜러/소개비
					var amt = 0;
					if (event.value == "20") { // 서브딜러
						amt = $M.toNum("${subDealr_amt}");
					} else if (event.value == "21") { // 모니터
						amt = $M.toNum("${monitor_amt}");
					}
					AUIGrid.updateRow(auiGridMachineDocOppCost, {"amt" : amt, "cost_name" : "", "cost_cust_no" : ""}, event.rowIndex);
				} else {
					AUIGrid.updateRow(auiGridMachineDocOppCost, {"amt" : 0, "cost_name" : "", "cost_cust_no" : ""}, event.rowIndex);
				}	
			}
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
	
	// 그리드 빈값 체크 - 유상
	function fnCheckGridEmpty1() {
		return AUIGrid.validateGridData(auiGridPartPaid, ["part_no", "part_name", "add_qty", "unit_price", "total_amt"], "필수 항목은 반드시 값을 입력해야합니다.");
	}

	// 그리드 빈값 체크 - 무상
	function fnCheckGridEmpty2() {
		return AUIGrid.validateGridData(auiGridPartFree, ["part_no", "part_name", "add_qty", "unit_price", "total_amt"], "필수 항목은 반드시 값을 입력해야합니다.");
	}

	// 그리드 빈값 체크 - 임의비용
	function fnCheckGridEmpty3() {
		return AUIGrid.validateGridData(auiGridMachineDocOppCost, ["cost_item_cd", "cost_name", "amt"], "필수 항목은 반드시 값을 입력해야합니다.");
	}

	// 그리드 빈값 체크 - 원가반영
	function fnCheckGridEmpty4() {
		return AUIGrid.validateGridData(auiGridMachineCostApply, ["cost_apply_cd", "amt", "cost_name"], "필수 항목은 반드시 값을 입력해야합니다.");
	}
	
	// 유상 - 행추가
	function fnAddPaid() {
		var colIndex = AUIGrid.getColumnIndexByDataField(auiGridPartPaid, "part_no");
		fnSetCellFocus(auiGridPartPaid, colIndex, "part_no");
		var item = new Object();
		if(fnCheckGridEmpty1(auiGridPartPaid)) {
			item.cost_item_yn = "N",
			item.part_no = "",
			item.machine_basic_part_seq = null,
			item.part_name = "",
			item.add_qty = null,
			item.unit_price = "",
			item.total_amt = "",
			item.part_name_change_yn = "N",
			item.cmd = "C",
			AUIGrid.addRow(auiGridPartPaid, item, 'last');
		}
	}
	
	// 무상 - 부품조회
	function goPartList() {
		var items = AUIGrid.getAddedRowItems(auiGridPartFree);
		for (var i = 0; i < items.length; i++) {
			if (items[i].part_no == "") {
				alert("추가된 행을 입력하고 시도해주세요.");
				return;
			}
		}
		
		if(fnCheckGridEmpty2(auiGridPartFree)) {
			openSearchPartPanel('setPartInfo2', 'Y');
		}
	}

	// 유상 - 부품조회
	function goPartListPaid() {
		var items = AUIGrid.getAddedRowItems(auiGridPartPaid);
		for (var i = 0; i < items.length; i++) {
			if (items[i].part_no == "") {
				alert("추가된 행을 입력하고 시도해주세요.");
				return;
			}
		}
		if(fnCheckGridEmpty1(auiGridPartFree)) {
			openSearchPartPanel('setPartInfo1', 'Y');
		}	
	}
	
	// 유상 - 부품조회 창에서 받아온 값
	function setPartInfo1(rowArr) {
		var params = AUIGrid.getGridData(auiGridPartPaid);
		// 부품조회 창에서 받아온 값 중복체크
		for (var i = 0; i < rowArr.length; i++ ) {
			var rowItems = AUIGrid.getItemsByValue(auiGridPartPaid, "part_no", rowArr[i].part_no);
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
				row.part_no = partNo;
				row.machine_basic_part_seq = null;
				row.part_name = partName;
				row.add_qty = 1;
				row.unit_price = typeof rowArr[i].unit_price == "undefined" ? unitPrice : rowArr[i].sale_price;
				row.total_amt = "";
				row.part_name_change_yn = rowArr[i].part_name_change_yn,
				row.cost_item_yn = 'N';
				AUIGrid.addRow(auiGridPartPaid, row, 'last');
			}
		}
	}
	
	// 무상 - 부품조회 창에서 받아온 값
	function setPartInfo2(rowArr) {
		var params = AUIGrid.getGridData(auiGridPartFree);
		// 부품조회 창에서 받아온 값 중복체크
		for (var i = 0; i < rowArr.length; i++ ) {
			var rowItems = AUIGrid.getItemsByValue(auiGridPartFree, "part_no", rowArr[i].part_no);
			 if (rowItems.length != 0){
// 				 alert("부품번호를 다시 확인하세요.\n"+rowArr[i].part_no+" 이미 입력한 부품번호입니다.");
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
				row.part_no = partNo;
				row.machine_basic_part_seq = null;
				row.part_name = partName;
				row.add_qty = addQty;
				row.default_qty = 0;
				row.unit_price = typeof rowArr[i].unit_price == "undefined" ? unitPrice : rowArr[i].sale_price;
				row.total_amt = addQty * rowArr[i].sale_price;
				row.part_name_change_yn = rowArr[i].part_name_change_yn;
				row.cost_item_yn = 'N';
				AUIGrid.addRow(auiGridPartFree, row, 'last');
			}
		}
	}
	
	// 유상 - 추가품목선별 팝업
	function goAddPartLinkPaidPopup() {
		var items = AUIGrid.getAddedRowItems(auiGridPartPaid);
		for (var i = 0; i < items.length; i++) {
			if (items[i].part_no == "") {
				alert("추가된 행을 입력하고 시도해주세요.");
				return;
			}
		}
		
		var param = {
// 				machine_name : $M.getValue("machine_name"),
				machine_plant_seq : $M.getValue("machine_plant_seq"),
	 			"s_sort_key" : "part_no",
	 			"s_sort_method" : "asc"
		};
		
		if(fnCheckGridEmpty1(auiGridPartFree)) {
			openAddMachinePartItem('fnSetAddMachinePartItem1', $M.toGetParam(param));
		}
	}
	
	// 유상 - 추가품목선별 팝업 데이터 세팅
	function fnSetAddMachinePartItem1(row) {
		// 기존값과 중복체크
		var rowItems = AUIGrid.getItemsByValue(auiGridPartPaid, "part_no", row.part_no);
		if (rowItems.length != 0){
			alert("부품번호를 다시 확인하세요.\n"+row.part_no+" 이미 입력한 부품번호입니다.");
			return false;					 
		}
		
		// 값 추가
		var colIndex = AUIGrid.getColumnIndexByDataField(auiGridPartPaid, "part_no");
		fnSetCellFocus(auiGridPartPaid, colIndex, "part_no");
		var item = new Object();
		if(fnCheckGridEmpty1(auiGridPartPaid)) {
				item.cost_item_yn = "N",
	    		item.part_no = row.part_no,
	    		item.machine_basic_part_seq = null,
	    		item.part_name = row.part_name,
	    		item.add_qty = row.add_qty,
	    		item.unit_price = row.unit_price, // 추가품목선별에서는sale_price가 아니라 unit_price
	    		item.total_amt = row.total_amt,
	    		item.part_name_change_yn = row.part_name_change_yn,
	    		item.cmd = "C",
	    		AUIGrid.addRow(auiGridPartPaid, item, 'last');
		}	
	}
	
	// 무상 - 추가품목선별 팝업
	function goAddPartLinkPopup() {
		var items = AUIGrid.getAddedRowItems(auiGridPartFree);
		for (var i = 0; i < items.length; i++) {
			if (items[i].part_no == "") {
				alert("추가된 행을 입력하고 시도해주세요.");
				return;
			}
		}
		
		var param = {
// 				machine_name : $M.getValue("machine_name"),
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
		var rowItems = AUIGrid.getItemsByValue(auiGridPartFree, "part_no", row.part_no);
		if (rowItems.length != 0){
			alert("부품번호를 다시 확인하세요.\n"+row.part_no+" 이미 입력한 부품번호입니다.");
			return false;					 
		}
		
		// 값 추가
		var colIndex = AUIGrid.getColumnIndexByDataField(auiGridPartFree, "part_no");
		fnSetCellFocus(auiGridPartFree, colIndex, "part_no");
		var item = new Object();
		if(fnCheckGridEmpty2(auiGridPartFree)) {
				item.cost_item_yn = "N",
	    		item.part_no = row.part_no,
	    		item.machine_basic_part_seq = null,
	    		item.part_name = row.part_name,
	    		item.add_qty = row.add_qty,
	    		item.default_qty = 0,
	    		item.unit_price = row.unit_price, // 추가품목선별에서는 unit_price
	    		item.total_amt = row.add_qty * row.unit_price,
	    		item.part_name_change_yn = row.part_name_change_yn,
	    		item.cmd = "C",
	    		AUIGrid.addRow(auiGridPartFree, item, 'last');
		}	
	}
	
	// 무상 - 임의비용추가
	function fnAddCostItem() {
		var colIndex = AUIGrid.getColumnIndexByDataField(auiGridMachineDocOppCost, "cost_item_cd");
		fnSetCellFocus(auiGridMachineDocOppCost, colIndex, "cost_item_cd");
		var item = new Object();
		if(fnCheckGridEmpty3(auiGridMachineDocOppCost)) {
			item.cost_name = "";
			item.cost_item_name = "";
			item.machine_basic_part_seq = null,
			item.amt = "",
			AUIGrid.addRow(auiGridMachineDocOppCost, item, 'last');
		}
	}

	// 원가 - 행추가
	function fnAddSec() {
		var colIndex = AUIGrid.getColumnIndexByDataField(auiGridMachineCostApply, "cost_apply_cd");
		fnSetCellFocus(auiGridMachineCostApply, colIndex, "cost_apply_cd");
		var item = new Object();
		if(fnCheckGridEmpty4(auiGridMachineCostApply)) {
			item.cost_name = ""; // 비고
			item.cost_item_name = ""; // 합계
			item.cost_apply_cd = "", // 원가반영 명
			item.amt = "", // 가격
			item.cost_item_cd = "99", // 임의비용코드
			AUIGrid.addRow(auiGridMachineCostApply, item, 'last');
		}
	}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" name="machine_name" value="${inputParam.machine_name}">
<input type="hidden" name="machine_plant_seq" value="${inputParam.machine_plant_seq}">
<input type="hidden" name="" value="${org_type}">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
<!-- 폼테이블 -->					
			<div>
				<div class="title-wrap">
					<h4>유상부품</h4>
					<div>
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
					</div>
				</div>
				<div id="auiGrid_part_paid" style="margin-top: 5px; width: 100%"></div>	

				<div class="title-wrap mt10">
					<!-- [14458] 무상 -> 기본지급품으로 변경 -->
					<h4>기본지급품</h4>
					<div>
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
					</div>
				</div>
				<div id="auiGrid_part_free" style="margin-top: 5px; width: 100%"></div>				
			
				<div class="oppCostArea">
					<div class="title-wrap mt10">
						<h4>임의비용</h4>
						<div>
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BASE_R"/></jsp:include>
						</div>
					</div>
					<div id="auiGrid_machine_doc_opp_cost" style="margin-top: 5px; width: 100%"></div>				
				</div>

				<div class="costApplyArea">
					<div class="title-wrap mt10">
						<h4>원가반영</h4>
						<div>
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_M"/></jsp:include>
						</div>
					</div>
					<div id="auiGrid_machine_cost_apply" style="margin-top: 5px; width: 100%"></div>
				</div>
			</div>
<!-- /폼테이블 -->	
<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">						
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>