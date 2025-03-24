<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 고객현황 > 견적서관리 > null > 수주견적서상세
-- 작성자 : 박예진
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var auiGrid;
		var isCust = false;
		var maxNo;
		var onlyWarehouseYn = "N";
		
		$(document).ready(function() {
			createAUIGrid();
			fnMachineList();
			fnInitPage();
		});

		function fnMachineList() {
			// select box 옵션 전체 삭제
			$("#machine_seq option").remove();

			var machineList = ${machineList};
			if(machineList.length > 0) {
				for(item in machineList) {
					// 차대번호의 고객이 보유하고 있는 list 추가
					$("#machine_seq").append(new Option(machineList[item].machine_name, machineList[item].machine_seq));
				}
				fnMachineListChange();
			}
		}
		
		// 선택된 차대번호 정보 select
		function fnMachineListChange() {
			var machineSeq = $M.getValue("machine_seq");
			$M.goNextPageAjax('/cust/cust010702/machineInfo/' + machineSeq, "", {method : 'GET'},
					function(result) {
			    		if(result.success) {
			    			$M.setValue(result);
			    			console.log(result);
						}
					}
				);
		}
		
		function fnInitPage() {
			if ("${inputParam.disabled_yn}" == "Y") {
				$("#main_form").prop("disabled", true);
				$("#main_form :input").prop("disabled", true);
				$("#machine_seq").prop("disabled", true);
				$("#main_form :button[onclick='javascript:goNew();']").prop("disabled", false);// 류성진 - 수주등록 버튼 추가
				$("#main_form :button[onclick='javascript:fnClose();']").prop("disabled", false);
				$("#main_form :button[onclick='javascript:goBookmarkRfq();']").prop("disabled", false);
				$("#cust_job_btn").prop("disabled", false);
			}
			var info = ${info}
			var rfqNoTemp = info.basicInfo.rfq_no.split("-");
			
			console.log("info : ", info);
			
			// VIP판매가 추가 : 고객이 VIP일경우 VIP판매가로 적용.
			$M.setValue("vip_yn", info.basicInfo.vip_yn);
			if (info.basicInfo.vip_yn == 'Y') {
				// 단가 헤더 속성값 변경하기
				AUIGrid.setColumnProp(auiGrid, 6, {
					headerText : "단가(VIP)",
					headerStyle : "aui-vip-header",
					width : "8%",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right aui-editable",
					editable : true,
					editRenderer : {
							type : "InputEditRenderer",
							onlyNumeric : true,
							autoThousandSeparator : true, // 천단위 구분자 삽입 여부 (onlyNumeric=true 인 경우 유효)
							allowPoint : false // 소수점(.) 입력 가능 설정
						},
						styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if("${inputParam.disabled_yn}" == "Y") {
						return "aui-row-highlight-complete";
					} else {
						return "";
					}
				}
			});
		} else {
			// 단가 헤더 속성값 변경하기
			AUIGrid.setColumnProp(auiGrid, 6, {
				headerText : "단가(일반)",
				headerStyle : "aui-vip-header",
				width : "8%",
				dataType : "numeric",
				formatString : "#,##0",
					style : "aui-right aui-editable",
					editable : true,
					editRenderer : {
					    type : "InputEditRenderer",
					    onlyNumeric : true,
					    autoThousandSeparator : true, // 천단위 구분자 삽입 여부 (onlyNumeric=true 인 경우 유효)
					    allowPoint : false // 소수점(.) 입력 가능 설정
					},
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if("${inputParam.disabled_yn}" == "Y") {  
							return "aui-row-highlight-complete";
						} else {
							return "";
						}
					}
				});
			}
			
			$M.setValue("rfq_no_1", rfqNoTemp[0]);
			$M.setValue("rfq_no_2", rfqNoTemp[1]);
			if (info.basicInfo.cust_no != null) {
				isCust = true;
			}
			if (info.basicInfo.rfq_no != "") {
				isRfq = true;
			}
			fnSetData(info);
		}

		// 수주등록 버튼 추가
		function goNew() {
			var popupOption = "";
			var param = {
				cust_no : $M.getValue("cust_no"),
				rfq_type_cd : $M.getValue("rfq_type_cd"),
				rfq_no : $M.getValue("rfq_no"),
				"s_popup_yn" : "Y",
			}
			$M.goNextPage('/cust/cust020101', $M.toGetParam(param),  {popupStatus : popupOption});
		}
		
		function fnSetData(result) {
			 $M.setValue(result.basicInfo);
			 $M.setValue("__s_cust_name", result.basicInfo.cust_name);
			 $M.setValue("__s_cust_no", result.basicInfo.cust_no);
			 $M.setValue("__s_hp_no", result.basicInfo.hp_no);
			 maxNo = result.basicInfo.max_no;
			 if (result.basicInfo.hp_no != null) {
				 $M.setValue("hp_no", $M.phoneFormat(result.basicInfo.hp_no));	
			 }
			 if(result.basicInfo.part_sale_no != "") {
				$("#part_sale_rfq").text("※수주상세(" + result.basicInfo.part_sale_no + ")에서 저장된 견적서입니다.");

				$("#main_form").prop("disabled", true);
				$("#main_form :input").prop("disabled", true);
				$("#machine_seq").prop("disabled", true);
				$("#_fnClose").prop("disabled", false);
			 	$("#_goNew").prop("disabled", false);
				$("#_goBookmarkRfq").prop("disabled", false);
				$("#_goMailSend").prop("disabled", false);
				$("#_goDocPrint").prop("disabled", false);
				$("#cust_job_btn").prop("disabled", false);
			 }
			 AUIGrid.setGridData("#auiGrid", result.partList);
			// 부가세 적용
			fnChangeDCAmt();
			fnChangeAmt();
		}
		
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid", 
				// rowNumber 
				showRowNumColumn: true,
				// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
				wrapSelectionMove : false,
				showStateColumn : true,
				editable : true,
			};
			var columnLayout = [
				{
					headerText : "순번", 
					dataField : "seq_no", 
					visible : false
				},
				{ 
					headerText : "부품번호", 
					dataField : "part_no", 
					width : "12%", 
					style : "aui-center",
					editable : true,
					editRenderer : {				
						type : "ConditionRenderer", 
						conditionFunction : function(rowIndex, columnIndex, value, item, dataField) {
							var param = {
								s_search_kind : 'DEFAULT_PART',
								's_warehouse_cd' : $M.getValue('warehouse_cd'),
								's_only_warehouse_yn' : "N",	// 센터일 때만 Y로 넘김 -> 전체 다 나오게 변경
				    			's_not_sale_yn' : "Y",		// 매출정지 제외
				    			's_not_in_yn' : "Y",			// 미수입 제외
				    			's_part_mng_cd' : ""
							};
							return fnGetPartSearchRenderer(dataField, param);
						},
					},
				},
				{
					headerText : "부품명", 
					dataField : "part_name", 
					width : "23%", 
					style : "aui-left",
					editable : true
				},
				{ 
					headerText : "단위", 
					dataField : "part_unit",
					width : "5%", 
					style : "aui-center",
					editable : false,
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
			            return value == "" || value == null ? "-" : value;
					},
				},
				{
					headerText : "현재고", 
					dataField : "current_qty", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "5%", 
					style : "aui-center",
					editable : false,
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
			            return value == "" || value == null ? "-" : $M.setComma(value);
					},
				},
				{ 
					headerText : "수량", 
					dataField : "qty",
					dataType : "numeric",
					formatString : "#,##0",
					width : "5%", 
					style : "aui-center aui-editable",
					editable : true,
					editRenderer : {
					      type : "InputEditRenderer",
// 					      onlyNumeric : true, // Input 에서 숫자만 가능케 설정
// 					      min : 1,				// AS-IS에서 부품 반품처리를 수량 마이너스로 처리하기 때문에 일단 주석
					      validator : AUIGrid.commonValidator
					},
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if("${inputParam.disabled_yn}" == "Y") {  
							return "aui-row-highlight-complete";
						} else {
							return "";
						}
					}
				},
				{ 
					headerText : "단가", 
					dataField : "unit_price",
					width : "8%",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right aui-editable",
					editable : true,
					editRenderer : {
					    type : "InputEditRenderer",
					    onlyNumeric : true,
					    autoThousandSeparator : true, // 천단위 구분자 삽입 여부 (onlyNumeric=true 인 경우 유효)
					    allowPoint : false // 소수점(.) 입력 가능 설정
					},
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if("${inputParam.disabled_yn}" == "Y") {  
							return "aui-row-highlight-complete";
						} else {
							return "";
						}
					}
				},
				{ 
					headerText : "금액", 
					dataField : "amount",  
					width : "8%", 
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right",
					editable : false,
					expFunction : function(  rowIndex, columnIndex, item, dataField ) { 
						// 수량 * 단가 계산
						return ( item.qty * item.unit_price ); 
					}
				},
				{ 
					headerText : "저장위치", 
					dataField : "storage_name",  
					style : "aui-center",
					width : "10%",
					editable : false
				},	
				{ 
					headerText : "출고일", 
					dataField : "out_dt",  
					width : "8%", 
					formatString : "yyyy-mm-dd",
					style : "aui-center",
					editable : false,
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
			            return value == "" || value == null ? "-" : $M.dateFormat(value, 'yyyy-mm-dd');
					},
				},
				{ 
					headerText : "미처리량", 
					dataField : "misu_qty",  
					dataType : "numeric",
					formatString : "#,##0",
					width : "5%", 
					style : "aui-center",
					editable : false,
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
			            return value == "" || value == null ? "-" : $M.setComma(value);
					},
				},
				{ 
					headerText : "비고", 
					dataField : "remark",  
					style : "aui-left aui-editable",
					editable : true,
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if("${inputParam.disabled_yn}" == "Y") {  
							return "aui-row-highlight-complete";
						} else {
							return "";
						}
					}
				},	
				{ 
					headerText : "삭제", 
					dataField : "removeBtn", 
					width : "4%",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							var isRemoved = AUIGrid.isRemovedById(auiGrid, event.item._$uid);
							if("${inputParam.disabled_yn}" != "Y") {
								if (isRemoved == false) {
									AUIGrid.updateRow(auiGrid, { "part_use_yn" : "N" }, event.rowIndex);
									AUIGrid.removeRow(event.pid, event.rowIndex);
									AUIGrid.update(auiGrid);
									var qty = event.item.qty;
									var amt = event.item.amount;
									minusAmt(qty, amt);
								} else {
									AUIGrid.updateRow(auiGrid, { "part_use_yn" : "Y" }, event.rowIndex);
									AUIGrid.restoreSoftRows(auiGrid, "selectedIndex"); 
									AUIGrid.update(auiGrid);
									var qty = event.item.qty;
									var amt = event.item.amount;
									addAmt(qty, amt);
								};
							}
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
					dataField : "part_use_yn",  
					visible : false
				},
				{
					dataField : "part_name_change_yn",
					visible : false
				}
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			// 추가행 에디팅 진입 허용
			AUIGrid.bind(auiGrid, "cellEditBegin", function (event) {
				if (event.dataField == "part_name") {
					var changeYn = event.item.part_name_change_yn;
					if (changeYn == "Y") {
						return true;	 
					} else {
						return false;
					}
				}
				if (event.dataField == "part_no") {
					if (AUIGrid.isAddedById(event.pid, event.item._$uid)) {
						return true;
					} else {
						return false;
					}
				}
	 			if (event.dataField == "qty" || event.dataField == "unit_price" || event.dataField == "remark") {
	 				if("${inputParam.disabled_yn}" != "Y") {
						return true;
	 				} else {
						return false;
	 				}
				} else {
					return false;
				}	
			});
			
			AUIGrid.bind(auiGrid,"rowStateCellClick",function(event){
				if(event.marker == "removed"){
					var isRemoved = AUIGrid.isRemovedById(auiGrid, event.item._$uid);
					if("${inputParam.disabled_yn}" != "Y") {
						if (isRemoved == false) {
							AUIGrid.updateRow(auiGrid, { "part_use_yn" : "N" }, event.rowIndex);
							AUIGrid.removeRow(event.pid, event.rowIndex);
							AUIGrid.update(auiGrid);
							var qty = event.item.qty;
							var amt = event.item.amount;
							minusAmt(qty, amt);
						} else {
							AUIGrid.updateRow(auiGrid, { "part_use_yn" : "Y" }, event.rowIndex);
							AUIGrid.restoreSoftRows(auiGrid, "selectedIndex"); 
							AUIGrid.update(auiGrid);
							var qty = event.item.qty;
							var amt = event.item.amount;
							addAmt(qty, amt);
						};
					}
				}
			});
			
			// keyDown 이벤트 바인딩
// 	         AUIGrid.bind(auiGrid, "keyDown",   function(event) {
// 	            // 행추가 단축키
// 	            if(event.shiftKey && event.keyCode == 32) {
// 	               fnAddPart();
// 	            }

// 	            if(event.keyCode == 45 || event.keyCode == 32) {
// 	               return false;
// 	            }

// 	            return true;
// 	         });
			
			// 에디팅 정상 종료 이벤트 바인딩
			AUIGrid.bind(auiGrid, "cellEditEndBefore", auiCellEditHandler);
			// 에디팅 정상 종료 이벤트 바인딩
			AUIGrid.bind(auiGrid, "cellEditEnd", auiCellEditHandler);
			// 에디팅 취소 이벤트 바인딩
			AUIGrid.bind(auiGrid, "cellEditCancel", auiCellEditHandler);
			
			$("#auiGrid").resize();
		}
		
		// 10행추가 
		function fnAdd() {
			for(var i=0; i<10; i++) {
				var item = new Object();
				item.seq_no = maxNo + 1,
	    		item.part_no = "",
	    		item.part_name = "",
	    		item.part_unit = "",
	    		item.current_qty = "",
	    		item.qty = 1,
	    		item.unit_price = "",
	    		item.storage_name = "",
	    		item.amount = "",
	    		item.out_dt = "",
	    		item.misu_qty = "",
	    		item.remark = "",
	    		item.removeBtn = "",
	    		item.part_use_yn = "Y",
	    		item.part_name_change_yn = "N",
	    		AUIGrid.addRow(auiGrid, item, 'last');
	    		maxNo++;
			}	
		}
		
		// 행추가 
		function fnAddPart() {
			var colIndex = AUIGrid.getColumnIndexByDataField(auiGrid, "part_no");
			fnSetCellFocus(auiGrid, colIndex, "part_no");
			var item = new Object();
			item.seq_no = maxNo + 1,
    		item.part_no = "",
    		item.part_name = "",
    		item.part_unit = "",
    		item.current_qty = "",
    		item.qty = 1,
    		item.unit_price = "",
    		item.storage_name = "",
    		item.amount = "",
    		item.out_dt = "",
    		item.misu_qty = "",
    		item.remark = "",
    		item.removeBtn = "",
    		item.part_use_yn = "Y",
    		item.part_name_change_yn = "N",
    		AUIGrid.addRow(auiGrid, item, 'last');
    		maxNo++;
		}

		
		// 부품조회
		function goPartList() {
// 			var items = AUIGrid.getAddedRowItems(auiGrid);
// 			for (var i = 0; i < items.length; i++) {
// 				if (items[i].part_no == "") {
// 					alert("추가된 행을 입력하고 시도해주세요.");
// 					return;
// 				}
// 			}
			if($M.getValue("org_gubun_cd") == "CENTER") {
				onlyWarehouseYn = "Y";
			}
			
			var param = {
	    			 's_warehouse_cd' : $M.getValue('warehouse_cd'),
	    			 's_only_warehouse_yn' : "N",	// 센터일 때만 Y로 넘김 -> 전체 다 나오게 변경
// 	    			 's_cust_no' : $M.getValue('cust_no')
	    	};
			
			openSearchPartPanel('setPartInfo', 'Y', $M.toGetParam(param));
		}
		
		// 부품조회 창에서 받아온 값
		function setPartInfo(rowArr) {
// 			var params = AUIGrid.getGridData(auiGrid);
// 			// 부품조회 창에서 받아온 값 중복체크
// 			for (var i = 0; i < rowArr.length; i++ ) {
// 				var rowItems = AUIGrid.getItemsByValue(auiGrid, "part_no", rowArr[i].part_no);
// 				 if (rowItems.length != 0){
// // 					 alert("부품번호를 다시 확인하세요.\n"+rowArr[i].part_no+" 이미 입력한 부품번호입니다.");
// 					 return "부품번호를 다시 확인하세요.\n"+rowArr[i].part_no+" 이미 입력한 부품번호입니다.";					 
// 				 }
// 			}
			
			var partNo ='';
			var partName ='';
			var unitPrice ='';
			var vipSalePrice ='';
			var qty = 1;
			var row = new Object();
			if(rowArr != null) {
				for(i=0; i < rowArr.length; i++) {
					row.seq_no = maxNo + 1;
					partNo = typeof rowArr[i].part_no == "undefined" ? partNo : rowArr[i].part_no;
					partName = typeof rowArr[i].part_name == "undefined" ? partName : rowArr[i].part_name;
					row.part_no = partNo;
					row.part_name = partName;
					row.current_qty = rowArr[i].part_warehouse_current;
					row.qty = qty;
					
					if ($M.getValue("vip_yn") == 'Y') {
						row.unit_price = typeof rowArr[i].vip_sale_price == "undefined" ? vipSalePrice : rowArr[i].vip_sale_price;
					} else {
						row.unit_price = typeof rowArr[i].sale_price == "undefined" ? unitPrice : rowArr[i].sale_price;
					}
					
					row.part_name_change_yn = rowArr[i].part_name_change_yn;
					row.storage_name = rowArr[i].storage_name;
					AUIGrid.addRow(auiGrid, row, 'last');
					maxNo++;
				}
				// 금액, 할인 적용
				fnChangeAmt();
				fnChangeDCAmt();
				fnDiscountInit();
			}
		}
		
		
		// 편집 핸들러
		function auiCellEditHandler(event) {
			switch(event.type) {
			case "cellEditEndBefore" :
				if(event.dataField == "part_no") {
// 					var isUnique = AUIGrid.isUniqueValue(auiGrid, event.dataField, event.value);	
// 					if (isUnique == false && event.value != "") {
// 						setTimeout(function() {
// 							   AUIGrid.showToastMessage(auiGrid, event.rowIndex, event.columnIndex, "부품번호가 중복됩니다.");
// 						}, 1);
// 						return "";
// 					} else {
					if (event.value == "") {
						return event.oldValue;							
					}
// 					}
				}
				
				break;
				case "cellEditEnd" :
					if(event.dataField == "part_no") {
						if (event.value == ""){
							return "";
						}
						// remote renderer 에서 선택한 값
						var item = fnGetPartItem(event.value);
						console.log(item);
						if(item === undefined) {
							AUIGrid.updateRow(auiGrid, {part_no : event.oldValue}, event.rowIndex);
						} else {
							// 수정 완료하면, 나머지 필드도 같이 업데이트 함.
							
							// VIP판매가 추가 : 고객이 VIP일경우 VIP판매가로 적용.
							var unitPrice = 0;
							if ($M.getValue("vip_yn") == 'Y') {
								unitPrice = item.vip_sale_price;
							} else {
								unitPrice = item.sale_price;
							}
							
							AUIGrid.updateRow(auiGrid, {
								part_name : item.part_name,
								current_qty : item.part_warehouse_current,
								qty : 1,
// 								unit_price : item.sale_price,
								unit_price : unitPrice,
// 								amount : event.item.add_qty * item.sale_price,
								amount : event.item.add_qty * unitPrice,
								part_name_change_yn : item.part_name_change_yn,
								storage_name : item.storage_name,
							}, event.rowIndex);
						} 
						// 금액, 할인 적용
						fnChangeAmt();
						fnChangeDCAmt();
						fnDiscountInit();
				    }
					
					// 수량, 단가 입력 시 금액 계산
					var qty;
					var unitPrice;
					var rowIndex;
					if (event.dataField == "qty") {
						qty = event.value;
						rowIndex = event.rowIndex;
		 	            AUIGrid.updateRow(auiGrid, { "amount" : qty * event.item.unit_price}, rowIndex);
		 	       		// 금액, 할인 적용
						fnChangeAmt();
						fnChangeDCAmt();
						fnDiscountInit();
					}
					if (event.dataField == "unit_price") {
						unitPrice = event.value;
						rowIndex = event.rowIndex;
		 	            AUIGrid.updateRow(auiGrid, { "amount" : unitPrice * event.item.qty}, rowIndex);
		 	       		// 금액, 할인 적용
						fnChangeAmt();
						fnChangeDCAmt();
						fnDiscountInit();
					}
					break;
				} 
			};
			
		// 장비정보 초기화
		function fnInit() {
			var param = {
				discount_rate : "",
				discount_amt : "",
				machine_seq : "",
				engine_model_1 : "",
				engine_model_2 : "",
				opt_model_1 : "",
				opt_model_2 : "",
				maker_name : "",
				maker_cd : "",
				engine_no_1 : "",
				engine_no_2 : "",
				opt_no_1 : "",
				opt_no_2 : "",
				body_no : "",
				
			}
			$M.clearValue();
			$M.setValue(param);
		}
		
		// 삭제 시 합계 계산
		function minusAmt(qty, amt) {
			var totalQty = $M.toNum($M.getValue("total_qty"));
			var totalAmt = $M.toNum($M.getValue("total_amt"));
			$M.setValue("total_qty", totalQty-qty);
			$M.setValue("total_amt", totalAmt-amt);
			fnDiscountInit();
			var vat =  $M.toNum(Math.floor($M.getValue("total_amt")*0.1));
			var rfqAmt =  vat+$M.toNum($M.getValue("total_amt"));
			$M.setValue("vat", vat);
			$M.setValue("rfq_amt", rfqAmt);
		}
		
		// 삭제 취소시 합계 계산
		function addAmt(qty, amt) {
			var totalQty = $M.toNum($M.getValue("total_qty"));
			var totalAmt = $M.toNum($M.getValue("total_amt"));
			$M.setValue("total_qty", totalQty+qty);
			$M.setValue("total_amt", totalAmt+amt);
			fnDiscountInit();
			var vat =  $M.toNum(Math.floor($M.getValue("total_amt")*0.1));
			var saleAmt =  vat+$M.toNum($M.getValue("total_amt"));
			$M.setValue("vat", vat);
			$M.setValue("rfq_amt", rfqAmt);
		}
		
		
		// 할인 초기화
		function fnDiscountInit() {
			var param = {
				discount_rate : "",
				discount_amt : ""
				
			}
			$M.clearValue();
			$M.setValue(param);
		}
		
		// 단가 컬럼 sum
		function sum(array) {
		  var result = 0.0;

		  for (var i = 0; i < array.length; i++)
		    result += array[i];

		  return result;
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
		 
		// 금액 변경 메소드
		 function fnChangeAmt() {
			 var values = AUIGrid.getColumnValues(auiGrid, "amount");
			 var valuesQty = AUIGrid.getColumnValues(auiGrid, "qty");
			 var totalAmt = sum(values);
			 var totalQty = sum(valuesQty);
			 $M.setValue("total_amt", totalAmt);
			 $M.setValue("total_qty", totalQty);
		 }
			
		// 그리드 빈값 체크
// 		function fnCheckGridEmpty() {
// 			return AUIGrid.validateGridData(auiGrid, ["part_no", "part_name", "qty", "unit_price"], "필수 항목은 반드시 값을 입력해야합니다.");
// 		}
		
		// 기본 조직도 조회
		function fnSetOrgMapPanel(row) {
			$M.setValue("rfq_org_name", row.org_name);
			$M.setValue("rfq_org_code", row.org_code);
			$M.goNextPageAjax("/rfq/office/"+row.org_code, "", {method : 'GET'},
				function(result) {
		    		if(result.success) {
		    			 var office = {
	    					 office_post_no : result.post_no,
	    					 office_addr1 : result.addr1,
	    					 office_addr2 : result.addr2,
							 office_fax_no : result.fax_no
		    			 }
		    			 $M.setValue(office);

						fnPhoneSetting(result); // 전화번호 셋팅

					}
				}
			);
	// 		console.log(JSON.stringify(result));
		}

		// 견적사업장 전화번호 셋팅
		function fnPhoneSetting(result) {
			// 옵션 초기화
			$("#office_tel_no").children('option').remove();

			// 전화번호 배열 받기
			var originPhoneArr = [result.tel_no, result.service_tel_no, result.part_tel_no];
			var copyPhoneArr = [result.tel_no + " (전화 번호)", result.service_tel_no + " (서비스 담당자 번호)", result.part_tel_no + " (부품/렌탈 담당자 번호)"];

			// 배열 크기만큼 option 생성
			for (var i = 0; i < originPhoneArr.length; i++) {
				if (originPhoneArr[i] != '') { // 배열에 번호가 있다면
					console.log(originPhoneArr[i]);
					$("#office_tel_no").append('<option value="' + originPhoneArr[i] + '">' + copyPhoneArr[i] + '</option');
				}
			}
		}
		
		// 부가세는 할인액을 반영한 금액의 10%
		// 최종금액은 할인액을 반영한 금액에서 부가세를 더함
		// 할인액 변경
		function fnChangeDCAmt() {
			var totalAmt = $M.toNum($M.getValue("total_amt"));
			var saveAmt = $M.toNum($M.getValue("discount_amt"));
// 			if (saveAmt > totalAmt) {
// 				alert("할인액은 최종판매가("+$M.setComma(totalAmt)+")를 초과할 수 없습니다.");
// 				$M.setValue("discount_amt", totalAmt);
// 				fnChangeDCAmt();
// 				return false;
// 			}
			if (totalAmt == 0 || saveAmt == 0) {
				var vat = Math.floor(totalAmt*0.1);
				var calc = {
					rfq_amt :  Math.round(totalAmt+vat),
					vat : vat,
					discount_rate : "0"
				}
				$M.setValue(calc);
				return false;
			} else {
				var resultPrice = totalAmt-saveAmt;
				var saveRate = 100 - (resultPrice/totalAmt * 100);
				var vat = Math.floor(resultPrice*0.1);
				var calc = {
					rfq_amt : Math.round(resultPrice+vat),
					vat : vat,
					discount_rate : saveRate
				}
				$M.setValue(calc);
			}
		}
		
		// 부가세는 할인액을 반영한 금액의 10%
		// 최종금액은 할인액을 반영한 금액에서 부가세를 더함
		// 할인율 변경
		function fnChangeDCRate() {
			var totalAmt = $M.toNum($M.getValue("total_amt"));
			var rate = $M.toNum($M.getValue("discount_rate"));
			if (rate > 100) {
				alert("할인율은 최대 100입니다.");
				$M.setValue("discount_rate", "100");
				fnChangeDCRate();
				return false;
			}
			if (totalAmt == 0 || rate == 0) {
				var vat = Math.floor(totalAmt*0.1);
				var calc = {
					rfq_amt : Math.round(totalAmt+vat),
					vat : vat,
					discount_amt : "0"
				}
				$M.setValue(calc);
				return false;
			} else {
				var savePrice = totalAmt*rate/100;
				var resultPrice = totalAmt-savePrice;
				var vat = Math.floor(resultPrice*0.1);
				var calc = {
					rfq_amt : Math.round(resultPrice+vat),
					vat : vat,
					discount_amt : savePrice
				}
				$M.setValue(calc);
			}
		}
		   
		function goMailSend() {
			var param = {
					email : $M.getValue("email"),
					rfq_no : $M.getValue("rfq_no")
			};
			console.log(param);
			if(param.email == "") {
				alert("이메일을 입력해주세요.");
				return;
			}
			$M.goNextPageAjaxMsg("견적서를 메일로 전송하시겠습니까?\n전송 후 견적서 수정 시, 차수가 변경됩니다.","/rfq/delivery/mail", $M.toGetParam(param), {method : 'GET'},
				function(result) {
					openReportPanel('cust/cust0107p02_01.crf','rfq_no=' + $M.getValue("rfq_no") + '&cust_no=' + $M.getValue("cust_no"));
					var param = {
		    			 "to" : $M.getValue('email'),
		    			 "subject" : "[YK건기] "+$M.getValue("cust_name")+"님 "+$M.getValue("machine_name")+" 수주 견적서",
		    			 "body" : $M.getValue("cust_name")+"님 "+$M.getValue("machine_name")+" 수주견적서입니다.<br>"+"견적 상세내용은 첨부파일을 참고하세요."
		    	  	};
		        	openSendEmailPanel($M.toGetParam(param));
				}
			);
		}
		
		function goDocPrint() {
			var param = {
					rfq_no : $M.getValue("rfq_no")
			};
			$M.goNextPageAjaxMsg("견적서를 인쇄하시겠습니까?\n인쇄 후 견적서 수정 시, 차수가 변경됩니다.","/rfq/delivery/print", $M.toGetParam(param), {method : 'GET'},
				function(result) {
				openReportPanel('cust/cust0107p02_01.crf','rfq_no=' + $M.getValue("rfq_no") + '&cust_no=' + $M.getValue("cust_no"));
				}
			);
		}
		
		// seq_no 수정 
		function fnUpdateSeqNo() {
			var gridData = AUIGrid.getGridData(auiGrid);
			var seqNo = 1;
			for(var i = 0; i < gridData.length; i++) {
				AUIGrid.updateRow(auiGrid, {seq_no : seqNo}, i);
				seqNo++;
			}
			var updateData = AUIGrid.getEditedRowItems(auiGrid);
			
		}
		// 수정
		function goModify() {
			fnUpdateSeqNo();
			if (isCust == false) {
				alert("고객명을 검색해서 입력해주세요.");
				$("#cust_name").focus();
				return false;
			}
// 			if(fnCheckGridEmpty(auiGrid) == false) {
// 				return;
// 			}
			if($M.validation(document.main_form) == false) {
				return;
			}
// 			var tempEmail = $M.getValue("email");
// 			if (!$M.emailCheck(tempEmail)) {
// 				$("#email").focus();
// 				alert("올바른 이메일을 입력하세요");
// 				return false;
// 			}
			
			var frm = $M.toValueForm(document.main_form);
			
			var gridArr = AUIGrid.getGridData(auiGrid);
			
			// 부품 수량이 0인 row가 있으면 confirm창 띄우기 2021-06-28 황빛찬
			var qtyValid = false;
			for (var i = 0; i < gridArr.length; i++) {
				if (gridArr[i].qty == 0) {
					qtyValid = true;	
				}
			}
			
			if (qtyValid) {
				if (confirm("부품 입력수량이 0인 항목(부품)이 있습니다. \n계속 진행 하시겠습니까 ?") == false) {
					return false;
				}
			}
			
			var rfqNoArr = [];
			var seqNoArr = [];
			var partNoArr = [];
			var qtyArr = [];
			var unitPriceArr = [];
			var remarkArr = [];
			var partNameArr = [];
			
			for(var i = 0, n = gridArr.length; i < n; i++) {
				if(gridArr[i].part_use_yn != "N") {
					rfqNoArr.push(gridArr[i].rfq_no);
					seqNoArr.push(gridArr[i].seq_no);
					partNoArr.push(gridArr[i].part_no);
					qtyArr.push(gridArr[i].qty);
					unitPriceArr.push(gridArr[i].unit_price);
					remarkArr.push(gridArr[i].remark);
					partNameArr.push(gridArr[i].part_name);
				}
			}
			
			if(rfqNoArr.length <= 0) {
				alert("부품을 추가해주세요.");
				return false;
			}
			
			var option = {
				isEmpty : true
			};

			$M.setValue(frm, "rfq_no_str", $M.getArrStr(rfqNoArr, option));
			$M.setValue(frm, "seq_no_str", $M.getArrStr(seqNoArr, option));
			$M.setValue(frm, "part_no_str", $M.getArrStr(partNoArr, option));
			$M.setValue(frm, "qty_str", $M.getArrStr(qtyArr, option));
			$M.setValue(frm, "unit_price_str", $M.getArrStr(unitPriceArr, option));
			$M.setValue(frm, "remark_str", $M.getArrStr(remarkArr, option));
			$M.setValue(frm, "part_name_str", $M.getArrStr(partNameArr, option));

			var rfqNo = $M.getValue("rfq_no");
			$M.goNextPageAjaxModify(this_page+"/"+rfqNo+"/modify", frm, {method : 'POST'},
				function(result) {
			    	if(result.success) {
			    		alert("수정에 성공했습니다.");
			    		if (result.newRfqNo != null) {
			    			var param = {
									rfq_no : result.newRfqNo,
									cust_no : $M.getValue("cust_no")
							}
			    			var poppupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1300, height=1100, left=0, top=0";
							$M.goNextPage('/cust/cust0107p02', $M.toGetParam(param), {popupStatus : poppupOption});
			    		} else {
			    			location.reload();
			    		}
					}
				}
			);
		}
		
		//삭제
		function goRemove() {
			var rfqNo = $M.getValue("rfq_no");
			$M.goNextPageAjaxRemove(this_page+"/"+rfqNo+"/remove", '', {method : 'POST'},
				function(result) {
			    	if(result.success) {
			    		// 여기서 뒤로가기
			    		alert("삭제에 성공했습니다.");
			    		fnClose();
			    		if (opener != null && opener.goSearch) {
			    			opener.goSearch();
			    		}
					}
				}
			);
		}
		
		// 엔터키 이벤트
		function enter(fieldObj) {
			var name = fieldObj.name;
			if (name == "rfq_org_name") {
				openOrgMapPanel('fnSetOrgMapPanel');
			} else if (name == "cust_name") {
				goCustInfo();
			}
		} 
		
		 // 문자발송
		function fnSendSms() {
			var param = {
					  name : $M.getValue("cust_name"),
					  hp_no : $M.getValue("hp_no")
			  }
			openSendSmsPanel($M.toGetParam(param));
		}
		 
		function fnSendMail() {
			var param = {
	    			 'to' : $M.getValue('email')
	    	  };
	        openSendEmailPanel($M.toGetParam(param));
		}
		
		// 즐겨찾는 견적등록
		// 버튼 클릭 시 저장 후 팝업 조회
		function goBookmarkRfq() {
			var gridData = AUIGrid.getGridData(auiGrid);
			
			var param = {
					"rfq_no" : $M.getValue("rfq_no"),
			}
			
			$M.goNextPageAjaxSave(this_page + "/saveFav", $M.toGetParam(param), {method : 'POST'},
				function(result) {
			    	if(result.success) {
			    		var params = {
								"parent_js_name" : "fnSetRfqPart"
			    		}
						var poppupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1100, height=600, left=0, top=0";
						$M.goNextPage('/cust/cust0107p05', $M.toGetParam(params), {popupStatus : poppupOption});
					}
				}
			);
		}
		
		function fnSetRfqPart() {
			
		}
		
		
		 // 부품대량입력 팝업
	    function fnMassInputPart() {
	    	if (isCust == false) {
				alert("고객명을 검색해서 입력해주세요.");
				$("#cust_name").focus();
				return false;
			}
	    	
			var popupOption = "";
			var param = {
   				"cust_no" : $M.getValue("cust_no"),
   				"parent_js_name" : "fnSetInputPart"
   		};
   		
			$M.goNextPage('/cust/cust0201p06', $M.toGetParam(param), {popupStatus : popupOption});
	    	
	    }
		 
	    // 부품대량입력, SET조회 데이터 세팅
	    function fnSetInputPart(list) {
			var partNo =  "";
			var partName =  "";
			var unitPrice = "";
			var row = new Object();
			
			if(list != null) {
				for(i=0; i < list.length; i++) {
					row.seq_no = "";
					partNo = typeof list[i].part_no == "undefined" ? partNo : list[i].part_no;
					partName = typeof list[i].part_name == "undefined" ? partName : list[i].part_name;
					row.part_no = partNo;
					row.part_name = partName;
					row.qty = list[i].qty;
					row.sale_mi_qty = list[i].sale_mi_qty;
					row.stock_qty = list[i].stock_qty;		// 전체 현재고가 아닌 소속창고의 현재고
					if($M.getValue("vip_yn") == "Y") {
						row.unit_price = list[i].vip_sale_price;
					} else {
						row.unit_price = list[i].sale_price;
					}
					row.amount = list[i].amount
					row.part_name_change_yn = list[i].part_name_change_yn;
					row.storage_name = list[i].storage_name;
					row.remark = typeof list[i].set_name == "undefined" ? list[i].remark : list[i].remark + ' (' + list[i].set_name + ')';
					AUIGrid.addRow(auiGrid, row, 'last');
				}
				// 금액, 할인 적용
				fnChangeAmt();
				fnChangeDCAmt();
				fnDiscountInit();
			}
	    }
	    
	    // SET조회
	    function goSearchSet() {
	    	if (isCust == false) {
				alert("고객명을 검색해서 입력해주세요.");
				$("#cust_name").focus();
				return false;
			}
	    	
			var popupOption = "";
			var param = {
    				"cust_no" : $M.getValue("cust_no"),
    				"parent_js_name" : "fnSetInputPart"
    		};
    		
			$M.goNextPage('/part/part0703p03', $M.toGetParam(param), {popupStatus : popupOption});
	    }
	    
	    //닫기
		function fnClose() {
			window.close(); 
		}	
		
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" name="breg_seq"> <!-- 사업자일련번호 -->
<input type="hidden" name="cust_no"> <!-- 고객번호 -->
<input type="hidden" name="rfq_org_code"> <!-- 견적발행조직코드 -->
<input type="hidden" name="rfq_mem_no"><!-- 견적담당자 -->
<input type="hidden" name="rfq_no"><!-- 견적서번호 -->
<input type="hidden" name="rfq_no_str">
<input type="hidden" name="seq_no_str">
<input type="hidden" name="part_no_str">
<input type="hidden" name="qty_str">
<input type="hidden" name="unit_price_str">
<input type="hidden" name="remark_str">
<input type="hidden" name="real_breg_no" id="real_breg_no">
<input type="hidden" name="warehouse_cd" id="warehouse_cd" value="${SecureUser.warehouse_cd != '' ? SecureUser.warehouse_cd : SecureUser.org_code}"><!-- 로그인한 사용자의 조직코드 -->
<input type="hidden" name="org_gubun_cd" id="org_gubun_cd" value="${SecureUser.org_type}"><!-- 로그인한 사용자의 소속 -->
<input type="hidden" name="vip_yn" id="vip_yn">
<div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
<!-- 상단 폼테이블 -->					
			<div>
				<div class="title-wrap">
				<h4>수주견적서상세</h4>
				<div class="btn-group">
					<div class="left">
						<div class="text-warning ml5" id="part_sale_rfq">
						
						</div>
					</div>
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>		
					</div>
					</div>
				</div>
				<table class="table-border mt5">
					<colgroup>
						<col width="100px">
						<col width="">
						<col width="100px">
						<col width="">
						<col width="100px">
						<col width="">
						<col width="100px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right">견적번호</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-6">
										<input type="text" class="form-control" readonly="readonly" id="rfq_no" name="rfq_no">
									</div>
								</div>
							</td>
							<th class="text-right rs">견적일자</th>
							<td>
								<div class="input-group">
									<input type="text" class="form-control border-right-0 width120px calDate rb" required="required" id="rfq_dt" name="rfq_dt" dateFormat="yyyy-MM-dd" value="" onchange="javascript:fnSetExpireDt()">
								</div>
							</td>	
							<th class="text-right">업체명</th>
							<td>
								<input type="text" class="form-control width120px" readonly="readonly" id="breg_name" name="breg_name">
							</td>	
							<th class="text-right">대표자</th>
							<td>
								<input type="text" class="form-control width120px" readonly="readonly" id="breg_rep_name" name="breg_rep_name">
							</td>									
						</tr>
						<tr>
							<th class="text-right rs">고객명</th>
							<td>
									<div class="form-row inline-pd pr">
										<div class="col-6">
											<input type="text" class="form-control width120px rb" id="cust_name" name="cust_name" required="required" alt="고객명" disabled="disabled">
										</div>
									<jsp:include page="/WEB-INF/jsp/common/commonCustJob.jsp">
		 	                     		<jsp:param name="li_type" value="__ledger#__sms_popup#__sms_info#__visit_history#__check_required#__cust_rental_history#__rental_consult_history"/>
			                     	</jsp:include>
									</div>
								</td>		
							<th class="text-right rs">휴대폰</th>
							<td>
								<div class="input-group">
									<input type="text" class="form-control border-right-0 width140px" id="hp_no" name="hp_no" format="phone" readonly="readonly" required="required" alt="휴대폰">
									<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSendSms();" ><i class="material-iconsforum"></i></button>
								</div>
							</td>	
							<th class="text-right">사업자번호</th>
							<td>
								<input type="text" class="form-control width120px" readonly="readonly" id="breg_no" name="breg_no">
							</td>	
							<th class="text-right">현미수</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width120px">
										<input type="text" class="form-control text-right width120px" readonly="readonly" id="misu_amt" name="misu_amt" format="decimal">
									</div>
									<div class="col-1">원</div>
								</div>
								
							</td>									
						</tr>
						<tr>
							<th class="text-right">전화</th>
							<td>
								<input type="text" class="form-control width140px" readonly="readonly" id="tel_no" name="tel_no">
							</td>	
							<th class="text-right">팩스</th>
							<td>
								<input type="text" class="form-control width140px" readonly="readonly" id="fax_no" name="fax_no">
							</td>	
							<th class="text-right" rowspan="2">주소</th>
							<td colspan="3" rowspan="2">
								<div class="form-row inline-pd mb7">
									<div class="width100px" style="padding-left: 5px; padding-right: 5px">
										<input type="text" class="form-control" readonly="readonly" id="post_no" name="post_no">
									</div>
									<div class="col" style="width: calc(100% - 100px)">
										<input type="text" class="form-control" readonly="readonly" id="addr1" name="addr1">
									</div>
								</div>
								<div class="form-row inline-pd">
									<div class="col-12">
										<input type="text" class="form-control" readonly="readonly" id="addr2" name="addr2">
									</div>		
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">이메일</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-6">
										<input type="text" class="form-control" id="email" name="email">
									</div>
									<div class="col-6">
										<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSendMail();"><i class="material-iconsmail"></i></button>	
									</div>									
								</div>
							</td>	
							<th class="text-right rs">유효기간</th>
							<td>
								<div class="input-group">
									<input type="text" class="form-control border-right-0 width120px calDate rb" id="expire_dt" name="expire_dt" required="required" alt="유효기간" dateFormat="yyyy-MM-dd">
								</div>
							</td>
						</tr>										
					</tbody>
				</table>
			</div>
<!-- 장비정보 -->
					<div>
						<div class="title-wrap mt10">
							<h4>장비정보</h4>
						</div>
						<table class="table-border mt5">
							<colgroup>
								<col width="100px">
								<col width="">
								<col width="100px">
								<col width="">
								<col width="100px">
								<col width="">
								<col width="100px">
								<col width="">
								<col width="100px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th class="text-right">차대번호</th>
									<td>
										<select class="form-control" id="machine_seq" name="machine_seq" onchange="fnMachineListChange()">
										<!-- <option value="">- 선택 -</option> -->
										</select>
									</td>
									<th class="text-right">엔진모델1</th>
									<td>
										<input type="text" class="form-control" id="engine_model_1" name="engine_model_1" readonly="readonly">
									</td>
									<th class="text-right">엔진모델2</th>
									<td>
										<input type="text" class="form-control" id="engine_model_2" name="engine_model_2" readonly="readonly">
									</td>
									<th class="text-right">옵션모델1</th>
									<td>
										<input type="text" class="form-control" id="opt_model_1" name="opt_model_1" readonly="readonly">
									</td>	
									<th class="text-right">옵션모델2</th>
									<td>
										<input type="text" class="form-control" id="opt_model_2" name="opt_model_2" readonly="readonly">
									</td>								
								</tr>
								<tr>
									<th class="text-right">장비모델</th>
									<td>
										<input type="text" class="form-control" readonly="readonly" id="maker_name" name="maker_name">
										<input type="hidden" id="maker_cd" name="maker_cd">
										<input type="hidden" id="body_no" name="body_no">
									</td>
									<th class="text-right">엔진번호1</th>
									<td>
										<input type="text" class="form-control" id="engine_no_1" name="engine_no_1" readonly="readonly">
									</td>
									<th class="text-right">엔진번호2</th>
									<td>
										<input type="text" class="form-control" id="engine_no_2" name="engine_no_2" readonly="readonly">
									</td>
									<th class="text-right">옵션번호1</th>
									<td>
										<input type="text" class="form-control" id="opt_no_1" name="opt_no_1" readonly="readonly">
									</td>	
									<th class="text-right">옵션번호2</th>
									<td>
										<input type="text" class="form-control" id="opt_no_2" name="opt_no_2" readonly="readonly">
									</td>								
								</tr>
							</tbody>
						</table>						
					</div>
			<!-- /장비정보 -->	
				<div>
				<div class="title-wrap mt10">
					<h4>견적사업장</h4>
				</div>
				<table class="table-border mt5">
					<colgroup>
						<col width="100px">
						<col width="">
						<col width="100px">
						<col width="">
						<col width="100px">
						<col width="">
						<col width="100px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right rs">부서</th>
							<td>
								<div class="input-group">
									<input type="text" class="form-control width120px border-right-0" id="rfq_org_name" name="rfq_org_name" readonly="readonly">
									<input type="hidden" id="rfq_org_code" name="rfq_org_code">
									<button type="button" class="btn btn-icon btn-primary-gra width120px" onclick="javascript:openOrgMapPanel('fnSetOrgMapPanel');"><i class="material-iconssearch"></i></button>						
								</div>
							</td>
							<th class="text-right rs">견적자</th>
							<td>
								<input type="text" class="form-control width120px" readonly="readonly" id="rfq_mem_name" name="rfq_mem_name">
								<input type="hidden" id="rfq_mem_no" name="rfq_mem_no">
							</td>
							<th class="text-right">전화</th>
							<td>
								<select class="form-control width280px" id="office_tel_no" name="office_tel_no">
									<c:forEach var="item" items="${origin_office_phone}" varStatus="status">
										<c:if test="${save_office_tel_no eq ''}">
											<option value="" selected></option>
										</c:if>
										<c:if test="${save_office_tel_no eq item}">
											<option value="${item}" selected>${copy_office_phone[status.index]}</option>
										</c:if>
										<c:if test="${save_office_tel_no ne item}">
											<option value="${item}">${copy_office_phone[status.index]}</option>
										</c:if>
									</c:forEach>
								</select>
							</td>
							<th class="text-right">팩스</th>
							<td>
								<input type="text" class="form-control width140px" readonly="readonly" id="office_fax_no" name="office_fax_no">
							</td>								
						</tr>
						<tr>
							<th class="text-right">주소</th>
							<td colspan="3">
								<div class="form-row inline-pd mb7">
									<div class="width100px" style="padding-left: 5px; padding-right:5px;">
										<input type="text" class="form-control" readonly="readonly" id="office_post_no" name="office_post_no" value="${office_addr.post_no}">
									</div>
									<div class="col" style="width: calc(100% - 110px)">
										<input type="text" class="form-control" readonly="readonly" id="office_addr1" name="office_addr1" value="${office_addr.addr1}">
									</div>
								</div>
								<div class="form-row inline-pd">
									<div class="col">
										<input type="text" class="form-control" readonly="readonly" id="office_addr2" name="office_addr2" value="${office_addr.addr2}">
									</div>		
								</div>
							</td>	
							<th class="text-right">특이사항</th>
							<td colspan="3">
								<textarea class="form-control" style="height: 97px; resize: none;" id="memo" name="memo">${rfq_default_memo}</textarea>
							</td>
						</tr>
					</tbody>
				</table>						
			</div>
<!-- /상단 폼테이블 -->	
<!-- 그리드 타이틀, 컨트롤 영역 -->
			<div class="title-wrap mt10">
				<h4>부품추가</h4>
<!-- 				<div class="left text-warning ml5" style="width:500px;"> -->
<!-- 					(※ 부품 추가 단축키 : Shift + Space) -->
<!-- 				</div> -->
				<div class="btn-group">
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
					</div>
				</div>
			</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->
			<div id="auiGrid" style="height:300px; margin-top: 5px;"></div>
<!-- 합계그룹 -->
		<div class="row inline-pd mt10">
			<div class="col-2">
				<table class="table-border">
					<colgroup>
						<col width="50%">
						<col width="50%">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right th-sum">수량</th>
							<td class="text-right td-gray"><input type="text" class="form-control text-right" readonly="readonly" id="total_qty" name="total_qty" value="0" format="decimal"></td>
						</tr>
					</tbody>
				</table>
			</div>
			<div class="col-2">
				<table class="table-border">
					<colgroup>
						<col width="50%">
						<col width="50%">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right th-sum">금액</th>
							<td class="text-right td-gray"><input type="text" class="form-control text-right" readonly="readonly" id="total_amt" name="total_amt" value="0" format="decimal"></td>
						</tr>
					</tbody>
				</table>
			</div>
			<div class="col-2">
				<table class="table-border">
					<colgroup>
						<col width="50%">
						<col width="50%">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right th-sum">할인율(%)</th>
							<td class="text-right"><input type="text" class="form-control text-right" id="discount_rate" name="discount_rate" value="0" onchange="fnChangeDCRate()" format="decimal"></td>
						</tr>
					</tbody>
				</table>
			</div>
			<div class="col-2">
				<table class="table-border">
					<colgroup>
						<col width="50%">
						<col width="50%">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right th-sum">할인액</th>
							<td class="text-right"><input type="text" class="form-control text-right" id="discount_amt" name="discount_amt" value="0" onchange="fnChangeDCAmt()" format="decimal"></td>
						</tr>
					</tbody>
				</table>
			</div>
			<div class="col-2">
				<table class="table-border">
					<colgroup>
						<col width="50%">
						<col width="50%">
					</colgroup>
					<tbody>  
						<tr>
							<th class="text-right th-sum">부가세</th>
							<td class="text-right td-gray"><input type="text" class="form-control text-right" readonly="readonly" id="vat" name="vat" value="0" format="decimal"></td>
						</tr>
					</tbody>
				</table>
			</div>
			<div class="col-2">
				<table class="table-border">
					<colgroup>
						<col width="50%">
						<col width="50%">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right th-sum">총견적금액</th>
							<td class="text-right td-gray"><div data-tip="(금액-할인액)*VAT"><input type="text" class="form-control text-right" readonly="readonly" id="rfq_amt" name="rfq_amt" value="0" format="decimal"></div></td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>
<!-- /합계그룹 -->
<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">						
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
						<jsp:param name="pos" value="BOM_R"/>
						<jsp:param name="mem_no" value="${rfq_mem_no}"/>
					</jsp:include>
				</div>
			</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
        </div>
    </div>
<!-- /팝업 -->	
	
</form>
</body>
</html>