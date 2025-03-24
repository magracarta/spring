<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 코드관리 > 부품CUBE > null > 부품CUBE상세
-- 작성자 : 박예진
-- 최초 작성일 : 2021-04-09 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		$(document).ready(function() {
			createAUIGridLeft();
			createAUIGridRight();
			fnInit();
		});
		
		// 마감여부에 따라 버튼 상태 변경
		function fnInit() {
			if($M.getValue("end_yn") == "Y") {
				$("#_goApply").addClass("dpn");
				$("#_goCancelConfirm").removeClass("dpn");
				$("#_goModify").addClass("dpn");
				$("#_goRemove").addClass("dpn");
				$("#_goPartList").prop("disabled", true);
				$("#_fnAdd").prop("disabled", true);
				$("#_goPartListPaid").prop("disabled", true);
				$("#_fnAddPaid").prop("disabled", true);
			} else {
				$("#_goApply").removeClass("dpn");
				$("#_goCancelConfirm").addClass("dpn");
				$("#_goModify").removeClass("dpn");
				$("#_goRemove").removeClass("dpn");
				$("#_goPartList").prop("disabled", false);
				$("#_fnAdd").prop("disabled", false);
				$("#_goPartListPaid").prop("disabled", false);
				$("#_fnAddPaid").prop("disabled", false);
			}
		}
		
		//그리드생성
		function createAUIGridLeft() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn: true,
				editable : true,
			};
			
			if($M.getValue("end_yn") == "Y") {
				gridPros.editable = false;
			}
			
			var columnLayout = [
				{ 
					headerText : "부품번호", 
					dataField : "part_no", 
					width : "140", 
					minWidth : "140", 
					style : "aui-center",
					editable : true,
					editRenderer : {				
						type : "ConditionRenderer", 
						conditionFunction : function(rowIndex, columnIndex, value, item, dataField) {
							var param = {
								s_search_kind : 'DEFAULT_PART',
								's_warehouse_cd' : "${part_warehouce_cd}",		// 부품부로 조회
								's_only_warehouse_yn' : "N",	// 센터일 때만 Y로 넘김 -> 전체 다 나오게 변경
				    			's_not_sale_yn' : "Y",		// 매출정지 제외
				    			's_not_in_yn' : "Y",			// 미수입 제외
				    			's_part_mng_cd' : ""
							};
							return fnGetPartSearchRenderer(dataField, param, "#auiGridLeft");
						},
					},
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if($M.getValue("end_yn") == "Y") {
							return "aui-center";
						} else {
							return "aui-editable";
						}
					},
				},
				{
					headerText : "부품명", 
					dataField : "part_name", 
					width : "160",
					minWidth : "160",
					style : "aui-left"
				},
				{ 
					headerText : "현재고", 
					dataField : "current_stock",
					dataType : "numeric",
					formatString : "#,##0",
					width : "55",
					minWidth : "55",
					style : "aui-center",
					editable : false,
				},
				{ 
					headerText : "수량", 
					dataField : "cube_qty",
					dataType : "numeric",
					formatString : "#,##0",
					width : "55",
					minWidth : "55",
					style : "aui-center",
					editRenderer : {
					      type : "InputEditRenderer",
						      onlyNumeric : true, // Input 에서 숫자만 가능케 설정
						      min : 1,				// AS-IS에서 반품 처리 시 마이너스 넣음
	//					      validator : AUIGrid.commonValidator
						  validator : function(oldValue, newValue, item) {
							  var isValid = false;
							  if(newValue != '' && (newValue <= item.current_stock)) {
								  isValid = true;
							  }
							return { "validate" : isValid, "message"  : "수량은 현재고보다 적어나 같아야합니다."};
						  }
					},
					editable : true,
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if($M.getValue("end_yn") == "Y") {
							return "aui-center";
						} else {
							return "aui-editable";
						}
					},
				},
				{
					headerText : "매입가", 
					dataField : "in_avg_price",
					dataType : "numeric",
					formatString : "#,##0",
					width : "85",
					minWidth : "85",
					style : "aui-center",
// 					editRenderer : {
// 					      type : "InputEditRenderer",
// 					      onlyNumeric : true, // Input 에서 숫자만 가능케 설정
// 					      min : 1,				// AS-IS에서 반품 처리 시 마이너스 넣음
// 					      validator : AUIGrid.commonValidator
// 					},
					editable : false,
// 					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
// 						if($M.getValue("end_yn") == "Y") {
// 							return "aui-center";
// 						} else {
// 							return "aui-editable";
// 						}
// 					},
				},
				{
					headerText : "합계", 
					dataField : "total_in_avg_price",
					dataType : "numeric",
					onlyNumeric : true,
					formatString : "#,##0",
					width : "85",
					minWidth : "85", 
					style : "aui-right",
					editable : false,
				},
				{
					headerText : "단가", 
					dataField : "unit_price",
					visible : false
				},
				{
					headerText : "큐브타입", 
					dataField : "cube_type_tr",
					visible : false
				},
				{
					headerText : "비고", 
					dataField : "cube_remark",
					width : "115",
					minWidth : "115",
					style : "aui-left",
					editable : true,
				},
				{ 
					headerText : "삭제", 
					dataField : "removeBtn", 
					width : "55",
					minWidth : "55",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							var isRemoved = AUIGrid.isRemovedById(auiGridLeft, event.item._$uid);
							if (isRemoved == false) {
								AUIGrid.updateRow(auiGridLeft, {cmd : "D"}, event.rowIndex);
								AUIGrid.removeRow(event.pid, event.rowIndex);
								// 결과부품 매입가 반영
								//fnChangeApplyAvgAmt();
								// 금액 적용
								fnChangeDivideAvgAmt();
							} else {
								AUIGrid.restoreSoftRows(auiGridLeft, "selectedIndex"); 
								AUIGrid.updateRow(auiGridLeft, {cmd : "U"}, event.rowIndex);
								// 결과부품 매입가 반영
								//fnChangeApplyAvgAmt();
								// 금액 적용
								fnChangeDivideAvgAmt();
							};
						},
						visibleFunction : function(rowIndex, columnIndex, value, item, dataField) {
							if ($M.getValue("end_yn") == 'N') {
								return true;
							};
							return false;
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
					visible : false
				},
				{
					dataField : "part_cube_no",
					visible : false
				}
			];
			auiGridLeft = AUIGrid.create("#auiGridLeft", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridLeft, ${mergeList});
			// 에디팅 정상 종료 이벤트 바인딩
			AUIGrid.bind(auiGridLeft, "cellEditEndBefore", auiCellEditHandlerLeft);
			// 에디팅 정상 종료 이벤트 바인딩
			AUIGrid.bind(auiGridLeft, "cellEditEnd", auiCellEditHandlerLeft);
			// 에디팅 취소 이벤트 바인딩
			AUIGrid.bind(auiGridLeft, "cellEditCancel", auiCellEditHandlerLeft);
			
			$("#auiGridLeft").resize();
		}
	
		//그리드생성
		function createAUIGridRight() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn: true,
				editable : true,
			};
			
			if($M.getValue("end_yn") == "Y") {
				gridPros.editable = false;
			}
			
			var columnLayout = [
				{ 
					headerText : "부품번호", 
					dataField : "part_no", 
					width : "140", 
					minWidth : "140", 
					style : "aui-center",
					editable : true,
					editRenderer : {				
						type : "ConditionRenderer", 
						conditionFunction : function(rowIndex, columnIndex, value, item, dataField) {
							var param = {
								s_search_kind : 'DEFAULT_PART',
								's_warehouse_cd' : "${part_warehouce_cd}",		// 부품부로 조회
								's_only_warehouse_yn' : "N",	// 센터일 때만 Y로 넘김 -> 전체 다 나오게 변경
				    			's_not_sale_yn' : "Y",		// 매출정지 제외
				    			's_not_in_yn' : "Y",			// 미수입 제외
				    			's_part_mng_cd' : ""
							};
							return fnGetPartSearchRenderer(dataField, param, "#auiGridRight");
						},
					},
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if($M.getValue("end_yn") == "Y") {
							return "aui-center";
						} else {
							return "aui-editable";
						}
					},
				},
				{
					headerText : "부품명", 
					dataField : "part_name", 
					width : "160",
					minWidth : "160",
					style : "aui-left",
				},
				{ 
					headerText : "현재고", 
					dataField : "current_stock",
					dataType : "numeric",
					formatString : "#,##0",
					width : "55",
					minWidth : "55",
					style : "aui-center",
					editable : false,
				},
				{ 
					headerText : "수량", 
					dataField : "cube_qty",
					dataType : "numeric",
					formatString : "#,##0",
					width : "55",
					minWidth : "55",
					style : "aui-center",
					editRenderer : {
					      type : "InputEditRenderer",
					      onlyNumeric : true, // Input 에서 숫자만 가능케 설정
					      min : 1,				// AS-IS에서 반품 처리 시 마이너스 넣음
					      validator : AUIGrid.commonValidator
					},
					editable : true,
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if($M.getValue("end_yn") == "Y") {
							return "aui-center";
						} else {
							return "aui-editable";
						}
					},
				},
				{
					headerText : "매입가", 
					dataField : "in_avg_price",
					dataType : "numeric",
					formatString : "#,##0",
					width : "85",
					minWidth : "85",
					style : "aui-center",
					editRenderer : {
					      type : "InputEditRenderer",
					      onlyNumeric : true, // Input 에서 숫자만 가능케 설정
					      min : 1,				// AS-IS에서 반품 처리 시 마이너스 넣음
					      validator : AUIGrid.commonValidator
					},
					editable : true,
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if($M.getValue("end_yn") == "Y") {
							return "aui-center";
						} else {
							return "aui-editable";
						}
					},
				},
				{
					headerText : "합계", 
					dataField : "total_in_avg_price",
					dataType : "numeric",
					onlyNumeric : true,
					formatString : "#,##0",
					width : "85",
					minWidth : "85", 
					style : "aui-right",
					editable : false,
				},
				{
					headerText : "단가", 
					dataField : "unit_price",
					visible : false
				},
				{
					headerText : "큐브타입", 
					dataField : "cube_type_tr",
					visible : false
				},
				{
					headerText : "비고", 
					dataField : "cube_remark",
					width : "115",
					minWidth : "115",
					style : "aui-left",
					editable : true,
				},
				{ 
					headerText : "삭제", 
					dataField : "removeBtn", 
					width : "55",
					minWidth : "55",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							var isRemoved = AUIGrid.isRemovedById(auiGridRight, event.item._$uid);
							if (isRemoved == false) {
								AUIGrid.updateRow(auiGridRight, {cmd : "D"}, event.rowIndex);
								AUIGrid.removeRow(event.pid, event.rowIndex);
								// 결과부품 매입가 반영
								//fnChangeApplyAvgAmt();
								// 금액 적용
								fnChangeDivideAvgAmt();
							} else {
								AUIGrid.restoreSoftRows(auiGridRight, "selectedIndex"); 
								AUIGrid.updateRow(auiGridRight, {cmd : "U"}, event.rowIndex);
								// 결과부품 매입가 반영
								//fnChangeApplyAvgAmt();
								// 금액 적용
								fnChangeDivideAvgAmt();
							};
						},
						visibleFunction : function(rowIndex, columnIndex, value, item, dataField) {
							if ($M.getValue("end_yn") == 'N') {
								return true;
							};
							return false;
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
					visible : false
				},
				{
					dataField : "part_cube_no",
					visible : false
				}
			];
			auiGridRight = AUIGrid.create("#auiGridRight", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridRight, ${divideList});
			// 에디팅 정상 종료 이벤트 바인딩
			AUIGrid.bind(auiGridRight, "cellEditEndBefore", auiCellEditHandlerRight);
			// 에디팅 정상 종료 이벤트 바인딩
			AUIGrid.bind(auiGridRight, "cellEditEnd", auiCellEditHandlerRight);
			// 에디팅 취소 이벤트 바인딩
			AUIGrid.bind(auiGridRight, "cellEditCancel", auiCellEditHandlerRight);
			
			$("#auiGridRight").resize();
		}
		
		// 좌측 그리드 행추가 
		function fnAdd() {
			var colIndex = AUIGrid.getColumnIndexByDataField(auiGridLeft, "part_no");
			fnSetCellFocus(auiGridLeft, colIndex, "part_no");
			var item = new Object();
			if(fnCheckLeftGridEmpty()) {
	    		item.part_no = "",
	    		item.part_name = "",
	    		item.current_stock = "",
	    		item.cube_qty = 1,
	    		item.cube_type_tr = "T",
	    		item.in_avg_price = "",
	    		item.total_in_avg_price = "",
	    		item.cube_remark = "",
	    		item.unit_price = "",
	    		item.removeBtn = "",
		   		AUIGrid.addRow(auiGridLeft, item, 'last');
			}
		}
		
		// 우측 그리드 행추가 
		function fnAddPaid() {
			var gridData = AUIGrid.getGridData(auiGridLeft);
			if(gridData.length == 0) {
				alert("대상부품을 입력 후 진행해주세요.");
				return false;
			}
			var cnt = 0;
			for(var i = 0; i < gridData.length; i++) {
				if(gridData[i].part_no != "") {
					cnt++;
				}
			}
			
			if(cnt == 0) {
				alert("대상부품을 입력 후 진행해주세요.");
				return false;
			}
			var colIndex = AUIGrid.getColumnIndexByDataField(auiGridRight, "part_no");
			fnSetCellFocus(auiGridRight, colIndex, "part_no");
			var item = new Object();
			if(fnCheckRightGridEmpty()) {
	    		item.part_no = "",
	    		item.part_name = "",
	    		item.current_stock = "",
	    		item.cube_qty = 1,
	    		item.cube_type_tr = "R",
	    		item.in_avg_price = "",
	    		item.total_in_avg_price = "",
	    		item.cube_remark = "",
	    		item.unit_price = "",
	    		item.removeBtn = "",
	    		AUIGrid.addRow(auiGridRight, item, 'last');
			}
		}
		
		// 결과부품 적용 시 대상부품의 금액을 결과부품에 반영
		 function fnChangeApplyAvgAmt() {
			var leftGridData = AUIGrid.getGridData(auiGridLeft);
			var leftTotalPrice = 0;
			if(leftGridData.length != 0) {
				for(var i = 0; i < leftGridData.length; i++) {
					if(leftGridData[i].cmd != "D") {
						leftTotalPrice += leftGridData[i].cube_qty * leftGridData[i].in_avg_price;
					}
				}
			}
			
			// 결과부품 갯수에 따라 개당 매입가 구함(21.06.22 고객사 시연 시 이원영파트장님의 요청으로 반올림)
			var rightGridData = AUIGrid.getGridData(auiGridRight);
			if(rightGridData.length != 0) {
				var rightQty = 0;
				for(var i = 0; i < rightGridData.length; i++){
					if(rightGridData[i].cmd != "D" && rightGridData[i].part_no != ""){
						rightQty += AUIGrid.getCellValue(auiGridRight,i,"cube_qty");
					}
				}
				var calcPrice = Math.round(leftTotalPrice / rightQty);
				for(var i = 0; i < rightGridData.length; i++) {
					if(rightGridData[i].cmd != "D" && rightGridData[i].part_no != "") {
						AUIGrid.updateRow(auiGridRight, {"in_avg_price" : calcPrice}, i);
						AUIGrid.updateRow(auiGridRight, {"total_in_avg_price" : rightGridData[i].cube_qty * calcPrice}, i);
					}
				}
			}
		 }
		
		// 좌측 그리드 필수 항목 체크
		function fnCheckLeftGridEmpty() {
			//return AUIGrid.validateGridData(auiGridLeft, ["part_no", "part_name", "cube_qty", "in_avg_price"], "필수 항목은 반드시 값을 입력해야합니다.");
			return true;
		}
		
		// 우측 그리드 필수 항목 체크
		function fnCheckRightGridEmpty() {
			//return AUIGrid.validateGridData(auiGridRight, ["part_no", "part_name", "cube_qty", "in_avg_price"], "필수 항목은 반드시 값을 입력해야합니다.");
			return true;
		}
		
		// 대상부품 그리드 부품조회
		function goPartList() {
			var param = {
	    			 's_warehouse_cd' : "${part_warehouce_cd}",		// 재고 부품부 재고로 조회
	    			 's_only_warehouse_yn' : "N",	// 센터일 때만 Y로 넘김 -> 전체 다 나오게 변경
	    	};
			
	
			if(fnCheckLeftGridEmpty()) {
				openSearchPartPanel('setPartInfoLeft', 'Y', $M.toGetParam(param));
			}
			
		}
		
		// 결과부품 그리드 부품조회
		function goPartListPaid() {
			var gridData = AUIGrid.getGridData(auiGridLeft);
			if(gridData.length == 0) {
				alert("대상부품을 입력 후 진행해주세요.");
				return false;
			}
			var cnt = 0;
			for(var i = 0; i < gridData.length; i++) {
				if(gridData[i].part_no != "") {
					cnt++;
				}
			}
			
			if(cnt == 0) {
				alert("대상부품을 입력 후 진행해주세요.");
				return false;
			}
			
			var param = {
	    			 's_warehouse_cd' : "${part_warehouce_cd}",		// 재고 부품부 재고로 조회
	    			 's_only_warehouse_yn' : "N",	// 센터일 때만 Y로 넘김 -> 전체 다 나오게 변경
	    	};
			
			if(fnCheckRightGridEmpty()) {
				openSearchPartPanel('setPartInfoRight', 'Y', $M.toGetParam(param));
			}
		}
		
		// 대상부품 그리드 부품조회 창에서 받아온 값
		function setPartInfoLeft(rowArr) {
			var params = AUIGrid.getGridData(auiGridLeft);
			// 부품조회 창에서 받아온 값 중복체크
			for (var i = 0; i < rowArr.length; i++ ) {
				var rowItems = AUIGrid.getItemsByValue(auiGridLeft, "part_no", rowArr[i].part_no);
				if (rowItems.length != 0){
					return "부품번호를 다시 확인하세요.\n" + rowArr[i].part_no + " 이미 입력한 부품번호입니다.";
				}
			}
			
			var partNo ='';
			var partName ='';
			var partAvgPrice ='';
			var unitPrice ='';
			var qty = 1;
			var row = new Object();
			if(rowArr != null) {
				for(i=0; i < rowArr.length; i++) {
					partNo = typeof rowArr[i].part_no == "undefined" ? partNo : rowArr[i].part_no;
					partName = typeof rowArr[i].part_name == "undefined" ? partName : rowArr[i].part_name;
					row.part_no = partNo;
					row.part_name = partName;
					row.current_stock = rowArr[i].part_warehouse_current;
					row.cube_qty = qty;
					row.cube_type_tr = "T";
					row.in_avg_price = typeof rowArr[i].part_avg_price == "undefined" ? partAvgPrice : rowArr[i].part_avg_price;
					row.total_in_avg_price = typeof rowArr[i].part_avg_price == "undefined" ? partAvgPrice : rowArr[i].part_avg_price;
					row.unit_price = typeof rowArr[i].vip_sale_price == "undefined" ? unitPrice : rowArr[i].vip_sale_price;
					AUIGrid.addRow(auiGridLeft, row, 'last');
				}
			}
			// 결과부품 매입가 반영
			//fnChangeApplyAvgAmt();
			// 금액 적용
			fnChangeDivideAvgAmt();
		}
		
		// 결과부품 그리드 부품조회 창에서 받아온 값
		function setPartInfoRight(rowArr) {
			var params = AUIGrid.getGridData(auiGridRight);
			// 부품조회 창에서 받아온 값 중복체크
			for (var i = 0; i < rowArr.length; i++ ) {
				var rowItems = AUIGrid.getItemsByValue(auiGridRight, "part_no", rowArr[i].part_no);
				if (rowItems.length != 0){
					return "부품번호를 다시 확인하세요.\n" + rowArr[i].part_no + " 이미 입력한 부품번호입니다.";
				}
			}
			
			var partNo ='';
			var partName ='';
			var partAvgPrice ='';
			var unitPrice ='';
			var qty = 1;
			var row = new Object();
			if(rowArr != null) {
				for(i=0; i < rowArr.length; i++) {
					partNo = typeof rowArr[i].part_no == "undefined" ? partNo : rowArr[i].part_no;
					partName = typeof rowArr[i].part_name == "undefined" ? partName : rowArr[i].part_name;
					row.part_no = partNo;
					row.part_name = partName;
					row.current_stock = rowArr[i].part_warehouse_current;
					row.cube_qty = qty;
					row.cube_type_tr = "R";
					row.in_avg_price = typeof rowArr[i].part_avg_price == "undefined" ? partAvgPrice : rowArr[i].part_avg_price;
					row.total_in_avg_price = typeof rowArr[i].part_avg_price == "undefined" ? partAvgPrice : rowArr[i].part_avg_price;
					row.unit_price = typeof rowArr[i].vip_sale_price == "undefined" ? unitPrice : rowArr[i].vip_sale_price;
					AUIGrid.addRow(auiGridRight, row, 'last');
				}
			}
			// 결과부품 매입가 반영
			//fnChangeApplyAvgAmt();
			// 금액 적용
			fnChangeDivideAvgAmt();
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
		
		// 대상부품 그리드 편집 핸들러
		function auiCellEditHandlerLeft(event) {
			switch(event.type) {
				case "cellEditEndBefore" :
					if(event.dataField == "part_no") {
					var isUnique = AUIGrid.isUniqueValue(auiGridLeft, event.dataField, event.value);
					var isUniqueRight = AUIGrid.isUniqueValue(auiGridRight, "part_no", event.value);
	 				if (isUnique == false && event.value != "") {
						setTimeout(function() {
							AUIGrid.showToastMessage(auiGridLeft, event.rowIndex, event.columnIndex, "부품번호가 중복됩니다.");
						}, 1);
						return "";
					} else if(isUniqueRight == false && event.value != "") {
						setTimeout(function() {
							AUIGrid.showToastMessage(auiGridLeft, event.rowIndex, event.columnIndex, "결과부품의 부품번호와 중복됩니다.");
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
						AUIGrid.updateRow(auiGridLeft, {part_no : event.oldValue}, event.rowIndex);
					} else {
						// 수정 완료하면, 나머지 필드도 같이 업데이트 함.
						AUIGrid.updateRow(auiGridLeft, {
							part_name : item.part_name,
							current_stock : item.part_warehouse_current == "" ? 0 : item.part_warehouse_current,			// 부품부 재고
							qty : 1,
							unit_price : item.vip_sale_price,
							in_avg_price : item.part_avg_price,
							total_in_avg_price : item.part_avg_price,
						}, event.rowIndex);
					} 
					// 결과부품 매입가 반영
					//fnChangeApplyAvgAmt();
					// 금액 적용
					fnChangeDivideAvgAmt();
			    }
				
				// 수량, 단가 입력 시 금액 계산
				var qty;
				var inAvgPrice;
				var rowIndex;
				if (event.dataField == "cube_qty") {
					qty = event.value;
					rowIndex = event.rowIndex;
					inAvgPrice = event.item.in_avg_price;
	 	            AUIGrid.updateRow(auiGridLeft, { "total_in_avg_price" : qty * inAvgPrice}, rowIndex);

	 				// 결과부품 매입가 반영
	 				//fnChangeApplyAvgAmt();
	 				// 금액 적용
	 				fnChangeDivideAvgAmt();
				}
				if (event.dataField == "in_avg_price") {
					qty = event.item.cube_qty;
					rowIndex = event.rowIndex;
					inAvgPrice = event.value;
	 	            AUIGrid.updateRow(auiGridLeft, { "total_in_avg_price" : qty * inAvgPrice}, rowIndex);

	 				// 결과부품 매입가 반영
	 				fnChangeApplyAvgAmt();
	 				// 금액 적용
	 				fnChangeDivideAvgAmt();
				}
				break;
			} 
		};
		
		// 결과부품 그리드 편집 핸들러
		function auiCellEditHandlerRight(event) {
			switch(event.type) {
				case "cellEditEndBefore" :
					if(event.dataField == "part_no") {
					var isUnique = AUIGrid.isUniqueValue(auiGridRight, event.dataField, event.value);
					var isUniqueLeft = AUIGrid.isUniqueValue(auiGridLeft, "part_no", event.value);
					if (event.value != "" && isUnique == false) {
						setTimeout(function() {
							AUIGrid.showToastMessage(auiGridRight, event.rowIndex, event.columnIndex, "부품번호가 중복됩니다.");
						}, 1);
						return "";
					} else if (event.value != "" && isUniqueLeft == false) {
						setTimeout(function() {
							AUIGrid.showToastMessage(auiGridRight, event.rowIndex, event.columnIndex, "대상부품의 부품번호와 중복됩니다.");
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
						AUIGrid.updateRow(auiGridRight, {part_no : event.oldValue}, event.rowIndex);
					} else {
						// 수정 완료하면, 나머지 필드도 같이 업데이트 함.
						AUIGrid.updateRow(auiGridRight, {
							part_name : item.part_name,
							current_stock : item.part_warehouse_current == "" ? 0 : item.part_warehouse_current,			// 부품부 재고
							qty : 1,
							in_avg_price : item.part_avg_price,
							unit_price : item.vip_sale_price,
							total_in_avg_price : item.part_avg_price,
						}, event.rowIndex);
					}
					// 결과부품 매입가 반영
					//fnChangeApplyAvgAmt();
	 	            // 잔여 평균매입가 금액 적용
	 	            fnChangeDivideAvgAmt();
			    }
				
				// 수량, 단가 입력 시 금액 계산
				var qty;
				var inAvgPrice;
				var rowIndex;
				if (event.dataField == "cube_qty") {
					qty = event.value;
					rowIndex = event.rowIndex;
					inAvgPrice = event.item.in_avg_price;
	 	            AUIGrid.updateRow(auiGridRight, { "total_in_avg_price" : qty * inAvgPrice}, rowIndex);
	 	        	// 결과부품 매입가 반영
					//fnChangeApplyAvgAmt();
	 	            // 잔여 평균매입가 금액 적용
	 	            fnChangeDivideAvgAmt();
				}
				if (event.dataField == "in_avg_price") {
					qty = event.item.cube_qty;
					rowIndex = event.rowIndex;
					inAvgPrice = event.value;
	 	            AUIGrid.updateRow(auiGridRight, { "total_in_avg_price" : qty * inAvgPrice}, rowIndex);
	 	        	// 결과부품 매입가 반영
					//fnChangeApplyAvgAmt();
	 	            // 잔여 평균매입가 금액 적용
	 	            fnChangeDivideAvgAmt();
				}
				break;
			} 
		};
	
		// 결과부품 잔여 평균매입가 총 합 계산
		 function fnChangeDivideAvgAmt() {
			var mergeAvgAmt = AUIGrid.getNotDeletedColumnValuesSum(auiGridLeft, "total_in_avg_price");
			var divideAvgAmt = AUIGrid.getNotDeletedColumnValuesSum(auiGridRight, "total_in_avg_price");
			
			var totalAmt = $M.toNum(mergeAvgAmt) - $M.toNum(divideAvgAmt);
			
			$M.setValue("total_avg_price", totalAmt);
		 }
		
		// 수정
		function goModify(doneYn) {
			if(fnCheckLeftGridEmpty(auiGridLeft) === false) {
				return false;
			}
			if(fnCheckRightGridEmpty(auiGridRight) === false) {
				return false;
			}
			if(fnValidation() === false) {
				return false;
			}
	
			$M.setValue("done_yn", doneYn == "Y" ? "Y" : "N");
	
			var frm = document.main_form;
			frm = $M.toValueForm(frm);
			
			var concatCols = [];
			var concatList = [];
			var gridIds = [auiGridLeft, auiGridRight];
			
			for (var i = 0; i < gridIds.length; ++i) {
				concatList = concatList.concat(AUIGrid.exportToObject(gridIds[i]));
				concatCols = concatCols.concat(fnGetColumns(gridIds[i]));
			}
			var gridForm = fnGridDataToForm(concatCols, concatList);
	
			
			// grid form 안에 frm 카피
			$M.copyForm(gridForm, frm);
			
			var msg = "";
			
			if(doneYn == "Y") {
				msg = "마감처리 시 재고가 반영됩니다. 마감 처리하시겠습니까?";
			} else {
				msg = "수정하시겠습니까?";
			}
			
			$M.goNextPageAjaxMsg(msg, this_page + "/modify", gridForm, {method : "POST"},
				function(result) {
		    		if(result.success) {
		    			opener.goSearch();
						location.reload();
					}
				}
			);
			
		}
		
		// 삭제
		function goRemove() {
			var param = {
					"part_cube_no" : "${inputParam.part_cube_no}"
			}
			
			$M.goNextPageAjaxRemove(this_page + "/remove", $M.toGetParam(param), {method : "POST"},
				function(result) {
		    		if(result.success) {
		    			opener.goSearch();
		    			fnClose();
					}
				}
			);
		}
		
		// 마감
		function goApply() {
			goModify("Y");
		}
		
		// 마감 취소
		function goCancelConfirm() {
			
			var param = {
					"part_cube_no" : "${inputParam.part_cube_no}",
// 					"part_trans_no" : "${partTransNo}"
			}
			
			var msg = "마감 취소하시겠습니까?";
			
			$M.goNextPageAjaxMsg(msg, this_page + "/cancelDone", $M.toGetParam(param), {method : "POST"},
				function(result) {
		    		if(result.success) {
						location.reload();
					}
				}
			);
		}
		
		// 체크
		function fnValidation() {
			var leftAllGridData = AUIGrid.getGridData(auiGridLeft);
			var rightAllGridData = AUIGrid.getGridData(auiGridRight);
			
			var leftGridData = [];
			var rightGridData = [];

			for(var i=0; i<leftAllGridData.length; i++){
				if(leftAllGridData[i].part_no != ""){
					leftGridData.push(leftAllGridData[i]);
				}
			}
			for(var i=0; i<rightAllGridData.length; i++){
				if(rightAllGridData[i].part_no != ""){
					rightGridData.push(rightAllGridData[i]);
				}
			}
			var leftCnt = 0;
			var rightCnt = 0;
			
			for(var i = 0; i < leftGridData.length; i++) {
				if(leftGridData[i].cmd != "D") {
					leftCnt++;
				}
				if(leftGridData[i].current_stock < leftGridData[i].cube_qty) {
					alert("대상부품의 수량은 현재고보다 적어나 같아야합니다.");
					return false;
				}
				if(leftGridData[i].cmd != "D" && (leftGridData[i].cube_qty == undefined || leftGridData[i].cube_qty == 0)) {
					alert("대상부품의 수량은 0보다 커야합니다.");
					return false;
				}
				for(var j = 0; j < rightGridData.length; j++) {
					if(leftGridData[i].part_no == rightGridData[j].part_no) {
						alert("대상부품과 결과부품에 동일한 부품이 있습니다. 부품번호 : " + leftGridData[i].part_no);
						return false;
					}
				}
			}

			if(leftCnt == 0) {
				alert("대상 부품이 없습니다.");
				return false;
			};
			
			for(var j = 0; j < rightGridData.length; j++) {
				if(rightGridData[j].cmd != "D") {
					rightCnt++;
				}
				if(rightGridData[j].cmd != "D" && (rightGridData[j].cube_qty == undefined || rightGridData[j].cube_qty == 0)) {
					alert("결과부품의 수량은 0보다 커야합니다.");
					return false;
				}
			}

			if(rightCnt == 0) {
				alert("결과 부품이 없습니다.");
				return false;
			};
			
			if(leftCnt != 1 && rightCnt != 1) {
				alert("대상부품과 결과부품 중 하나는 꼭 1개여야 합니다.");
				return false;
			}

            var totalPrice = $M.toNum($M.getValue("total_avg_price"));
            var rightQty = AUIGrid.getNotDeletedColumnValuesSum(auiGridRight, "cube_qty");

			if(totalPrice > rightQty || totalPrice < $M.toNum("-"+rightQty)) {
				alert("대상부품 매입가의 합과 결과부품의 평균매입가의 합이 기준과 맞지 않습니다.");
				return false;
			}
            // 22.09.21 매입가를 수정할 수 있도록 변경하여 잔여 평균매입가가 0일 경우에만 진행
            // if(totalPrice != 0) {
			// 	alert("대상부품 매입가의 합과 결과부품의 평균매입가의 합이 기준과 맞지 않습니다.");
			// 	return false;
			// }
		}
	
		// 닫기
		function fnClose() {
			window.close();
		}
		
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" id="total_avg_price" name="total_avg_price" value="${avgAmt}">
<input type="hidden" id="end_yn" name="end_yn" value="${endYn}">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
           <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">	
            <div class="row">
                <div class="col-6">
<!-- MERGE 부품 -->
                    <div class="title-wrap">
                        <h4>대상 부품</h4>
                        <div class="btn-group">
                            <div class="right">
                            	<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_L"/></jsp:include>
                            </div>
                        </div>
                    </div>
				<div id="auiGridLeft" style="margin-top: 5px; height: 300px;"></div>
<!-- /MERGE 부품 --> 
                </div>
                <div class="col-6">
<!-- DIVIDE 부품 -->
                    <div class="title-wrap">
                        <h4>결과 부품</h4>
                        <div class="btn-group">
                            <div class="right">
                            	<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
                            </div>
                        </div>
                    </div>
				<div id="auiGridRight" style="margin-top: 5px; height: 300px;"></div>
<!-- /DIVIDE 부품 --> 
                </div>
            </div>
<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt10">						
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