<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 부품판매 > 수주현황/등록 > 수주등록 > null
-- 작성자 : 박예진
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var isCust = false;
		var isRfq = false;
		var isOrder = false;
		var isDelivery = false;
		var onlyWarehouseYn = "N";

		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGrid();
			fnInitPage();

			// 자동기입 - 류성진
			<c:if test="${not empty inputParam.cust_no and inputParam.part_return_yn ne 'Y'}">
			<%--fnSetCustInfo({"cust_no" : "${inputParam.cust_no}"});--%>
			fnSetRfqRefer({
				"cust_no" : "${inputParam.cust_no}",
				"rfq_no" : "${inputParam.rfq_no}",
				"rfq_type_cd" : "${inputParam.rfq_type_cd}",
			})
			</c:if>
		});

		function fnInitPage() {

			$M.setValue("__s_sale_yn", "Y");
			if($M.getValue("s_popup_yn") == "Y") {
				$("#popupBtn").addClass("dpn");
			}

			if("${page.fnc.F00792_002}" == "Y") {
				onlyWarehouseYn = "Y";
			}
			<%--if("${SecureUser.org_type}" == "AGENCY") {--%>
			var partReturnYn = "${partReturnYn}";
			if("${page.fnc.F00792_001}" == "Y" || partReturnYn == "Y") {

				isCust = true;
				var custYn = ${custYn};
				if(custYn == "N") {
					alert("지사장정보가 없습니다. 마케팅담당자에게 문의하세요.");
					$("#main_form :input").prop("disabled", true);
					$("#main_form :button").prop("disabled", true);
					$("#_fnClose").prop("disabled", false);
					$("#_goSave").addClass("dpn");
					$("#_goProcessConfirm").addClass("dpn");
					return false;
				} else if(custYn == "Y") {
	    			var list = ${info};
	    			$M.setValue(list);
	    			var param = {
	    					cust_no : list.cust_no,
							__s_cust_no : list.cust_no,
	    					cust_name : list.cust_name,
	    					hp_no : $M.phoneFormat(list.hp_no),
	    					fax_no : list.fax_no,
	    					breg_seq : list.breg_seq,
	    					breg_name : list.breg_name,
	    					breg_no : list.breg_no,
	    					real_breg_no : list.real_breg_no,
	    					breg_rep_name : list.breg_rep_name,
	    					breg_cor_type : list.breg_cor_type,
	    					breg_cor_part : list.breg_cor_part,
	    					post_no : list.post_no,
	    					addr1 : list.addr1,
	    					addr2 : list.addr2,
	    					receive_name : list.cust_name,
	    					receive_hp_no : $M.phoneFormat(list.hp_no),
	    				}
	    			$M.setValue(param);
	    			$("#part_sale_type_c").prop("checked", false);
	    			$("#part_sale_type_a").prop("checked", true);
					$(".agencyY").prop("disabled", true);
					$("#btnRefer").prop("disabled", true);
					$("#btnFav").prop("disabled", true);
					$("#btnOrder").prop("disabled", true);
					$("input:radio[name=part_sale_type_ca]").prop("disabled", true);
					// 21.09.09 대리점일 시 선주문 선택 못하도록 변경
	    			$("#preorder_y").prop("checked", false);
	    			$("#preorder_n").prop("checked", true);
					$("input:radio[name=preorder_yn]").prop("disabled", true);
	    			// select box 옵션 전체 삭제
	   				$("#machine_seq option").remove();

	  					var machineList = ${machineList};
	  					if(machineList.length > 0) {
		   					for(item in machineList) {
		   						// 고객이 보유하고 있는 장비 list 추가
		   						$("#machine_seq").append(new Option(machineList[item].machine_name, machineList[item].machine_seq));
		   					}
	  					}
	  				goSearchPrivacyAgree();
					goSearchCUstMemo();
				} else if(partReturnYn == "Y") {
					var list = ${info};
					var partList = ${info}.partList;
					$M.setValue(list.basicInfo);
					var param = {
						cust_no : list.basicInfo.cust_no,
						__s_cust_no : list.basicInfo.cust_no,
						cust_name : list.basicInfo.cust_name,
						hp_no : $M.phoneFormat(list.basicInfo.hp_no),
						fax_no : list.basicInfo.fax_no,
						breg_seq : list.basicInfo.breg_seq,
						breg_name : list.basicInfo.breg_name,
						breg_no : list.basicInfo.breg_no,
						real_breg_no : list.basicInfo.real_breg_no,
						breg_rep_name : list.basicInfo.breg_rep_name,
						breg_cor_type : list.basicInfo.breg_cor_type,
						breg_cor_part : list.basicInfo.breg_cor_part,
						post_no : list.basicInfo.post_no,
						addr1 : list.basicInfo.addr1,
						addr2 : list.basicInfo.addr2,
						misu_amt : list.basicInfo.misu_amt,
						max_misu_amt : list.basicInfo.max_misu_amt,
						coupon_balance_amt : list.basicInfo.coupon_balance_amt,
						mile_balance_amt : list.basicInfo.mile_balance_amt,
						// 배송 정보
						receive_name : list.basicInfo.receive_name,
						receive_hp_no : $M.phoneFormat(list.basicInfo.receive_hp_no),
						receive_tel_no : list.basicInfo.receive_tel_no,
						invoice_remark : list.basicInfo.invoice_remark,
						invoice_post_no : list.basicInfo.invoice_post_no,
						invoice_addr1 : list.basicInfo.invoice_addr1,
						invoice_addr2 : list.basicInfo.invoice_addr2,
						invoice_send_cd : list.basicInfo.invoice_send_cd,
						invoice_type_cd : list.basicInfo.invoice_type_cd,
						invoice_money_cd : list.basicInfo.invoice_money_cd,
					}
					$M.setValue(param);
					$M.setValue("sale_part_sale_no", list.basicInfo.part_sale_no);
					// select box 옵션 전체 삭제
					$("#machine_seq option").remove();

					var machineList = ${machineList};
					if(machineList.length > 0) {
						for(item in machineList) {
							// 고객이 보유하고 있는 장비 list 추가
							$("#machine_seq").append(new Option(machineList[item].machine_name, machineList[item].machine_seq));
						}
					}
					for(var i=0; i<partList.length; i++) {
						partList[i].qty = partList[i].qty * -1
						AUIGrid.addRow(auiGrid, partList[i], 'last');
					}
					fnChangeAmt();
					fnChangeDCAmt();
					fnDiscountInit();
					fnChangeMileAmt();
					// goSearchPrivacyAgree();
					// goSearchCUstMemo();
				}
			}
			// [정윤수] 23.05.10 Q&A 17407 주문시스템 개선으로 인하여 disabled처리
			$("input:radio[name=preorder_yn]").attr("disabled", true);
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
								's_warehouse_cd' : $M.getValue("warehouse_cd"),
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
					width : "16%",
					style : "aui-left",
					editable : true
				},
				{
					headerText : "순번",
					dataField : "seq_no",
					visible : false
				},
				// [정윤수] 23.05.17 Q&A 17407 단위, 출고일, 미처리량 컬럼 삭제
				// {
				// 	headerText : "단위",
				// 	dataField : "part_unit",
				// 	width : "5%",
				// 	style : "aui-center",
				// 	editable : false,
				// 	labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
			    //         return value == "" || value == null ? "-" : value;
				// 	},
				// },
				{
					headerText : "가용재고",
					dataField : "stock_qty",
					dataType : "numeric",
					formatString : "#,##0",
					width : "5%",
					style : "aui-center aui-link",
					editable : false,
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
			            return value == "" || value == null ? 0 : $M.setComma(value);
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
// 					      min : 1,				// AS-IS에서 반품 처리 시 마이너스 넣음
					      validator : AUIGrid.commonValidator
					},
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
				// [정윤수] 23.05.17 Q&A 17407 단위, 출고일, 미처리량 컬럼 삭제
				// {
				// 	headerText : "출고일",
				// 	dataField : "out_dt",
				// 	width : "8%",
				// 	dataType : "date",
				// 	formatString : "yyyy-mm-dd",
				// 	style : "aui-center",
				// 	editable : false,
				// 	/* labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
			    //         return value == "" || value == null ? "-" : value;
				// 	}, */
				// },
				// {
				// 	headerText : "미처리량",
				// 	dataField : "sale_mi_qty",
				// 	dataType : "numeric",
				// 	formatString : "#,##0",
				// 	width : "5%",
				// 	style : "aui-center",
				// 	editable : false,
				// 	labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
			    //         return value == "" || value == null ? 0 : $M.setComma(value);
				// 	},
				// },
				{
					headerText : "비고",
					dataField : "remark",
					style : "aui-left aui-editable",
					editable : true
				},
				{
					headerText : "삭제",
					dataField : "removeBtn",
					width : "4%",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							var isRemoved = AUIGrid.isRemovedById(auiGrid, event.item._$uid);
							if (isRemoved == false) {
								AUIGrid.removeRow(event.pid, event.rowIndex);
								AUIGrid.update(auiGrid);
								var qty = event.item.qty;
								var amt = event.item.amount;
								if(event.item["part_no"] != "") {
									minusAmt(qty, amt);
								}
							} else {
								AUIGrid.restoreSoftRows(auiGrid, "selectedIndex");
								AUIGrid.update(auiGrid);
								var qty = event.item.qty;
								var amt = event.item.amount;
								addAmt(qty, amt);

								AUIGrid.updateRow(auiGrid, {part_use_yn : "Y"}, event.rowIndex);
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
					dataField : "part_name_change_yn",
					visible : false
				},
				{
					dataField : "part_mng_cd",
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
					return true;
				} else {
					return false;
				}
			});
			// 에디팅 정상 종료 이벤트 바인딩
			AUIGrid.bind(auiGrid, "cellEditEndBefore", auiCellEditHandler);
			// 에디팅 정상 종료 이벤트 바인딩
			AUIGrid.bind(auiGrid, "cellEditEnd", auiCellEditHandler);
			// 에디팅 취소 이벤트 바인딩
			AUIGrid.bind(auiGrid, "cellEditCancel", auiCellEditHandler);

			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				// 현재고 셀 클릭 시 부품재고상세 팝업 호출
				 if(event.dataField == 'stock_qty') {
					var param = {
							"part_no" : event.item["part_no"]
					};
					var popupOption = "";
					$M.goNextPage('/part/part0101p01', $M.toGetParam(param),  {popupStatus : popupOption});
				};
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

			$("#auiGrid").resize();
		}

		// 행추가
		function fnAddPart() {
			var colIndex = AUIGrid.getColumnIndexByDataField(auiGrid, "part_no");
			fnSetCellFocus(auiGrid, colIndex, "part_no");
			var item = new Object();
    		item.seq_no = "",
    		item.part_no = "",
    		item.part_name = "",
    		item.part_unit = "",
    		item.stock_qty = "",
    		item.qty = 1,
    		item.unit_price = "",
    		item.amount = "",
    		item.out_dt = "",
    		item.sale_mi_qty = "",
    		item.remark = "",
    		item.storage_name = "",
    		item.removeBtn = "",
    		item.part_name_change_yn = "N",
    		item.part_mng_cd = "",
    		AUIGrid.addRow(auiGrid, item, 'last');
		}

		// 10행 추가
		function fnAdd() {
			if ($M.getValue("cust_no") == "") {
				alert("고객 선택 후 진행해 주세요.");
				return false;
			}
			for(var i=0; i<10; i++) {
				var item = new Object();
				item.seq_no = "",
	    		item.part_no = "",
	    		item.part_name = "",
	    		item.part_unit = "",
	    		item.stock_qty = "",
	    		item.qty = 1,
	    		item.unit_price = "",
	    		item.amount = "",
	    		item.out_dt = "",
	    		item.sale_mi_qty = "",
	    		item.remark = "",
	    		item.storage_name = "",
	    		item.removeBtn = "",
	    		item.part_name_change_yn = "N",
	    		item.part_mng_cd = "",

	    		AUIGrid.addRow(auiGrid, item, 'last');
			}
		}

		// 부품조회
		function goPartList() {
			if ($M.getValue("cust_no") == "") {
				alert("고객 선택 후 진행해 주세요.");
				return false;
			}
// 			var items = AUIGrid.getAddedRowItems(auiGrid);
// 			for (var i = 0; i < items.length; i++) {
// 				if (items[i].part_no == "") {
// 					alert("추가된 행을 입력하고 시도해주세요.");
// 					return;
// 				}
// 			}

			if("${page.fnc.F00792_002}" == "Y") {
				onlyWarehouseYn = "Y";
			}

			var param = {
	    			 's_warehouse_cd' : $M.getValue('warehouse_cd'),
	    			 's_only_warehouse_yn' : "N",	// 센터일 때만 Y로 넘김 -> 전체 다 나오게 변경
	    			 's_warning_check' : "Y", // 정비지시서 및 수주에서 부품조회시 alert가 다르게 나오고 리턴받는 list를 다르게 받기위해 생성
// 	    			 's_cust_no' : $M.getValue('cust_no')
	    	};

			openSearchPartPanel('setSearchPartInfo', 'Y', $M.toGetParam(param));
		}
		// 23.06.14 [정윤수] 장기/충당 팝업에서 같이 사용하기위하여 추가
		function setSearchPartInfo(rowArr){
			var longPartYn = "N";
			setPartInfo(rowArr, longPartYn);
		}
		// 부품조회 창에서 받아온 값
		function setPartInfo(rowArr, longPartYn) {
			var params = AUIGrid.getGridData(auiGrid);
			// 부품조회 창에서 받아온 값 중복체크
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
			var vipSaleVatPrice ='';
			var qty = 1;
			var row = new Object();
			var warningText = "";
			if(rowArr != null) {
				for(i=0; i < rowArr.length; i++) {
					row.seq_no = "";
					partNo = typeof rowArr[i].part_no == "undefined" ? partNo : rowArr[i].part_no;
					partName = typeof rowArr[i].part_name == "undefined" ? partName : rowArr[i].part_name;
					row.part_no = partNo;
					row.part_name = partName;
					row.qty = qty;
					row.sale_mi_qty = rowArr[i].sale_mi_qty;
					row.stock_qty = rowArr[i].part_able_stock;		// 전체 현재고가 아닌 소속창고의 현재고

					if ($M.getValue("vip_yn") == 'Y' || longPartYn == 'Y') {
						row.unit_price = typeof rowArr[i].vip_sale_price == "undefined" ? vipSalePrice : rowArr[i].vip_sale_price;
						row.amount = typeof rowArr[i].vip_sale_vat_price == "undefined" ? vipSaleVatPrice : rowArr[i].vip_sale_vat_price; // vat별도 값 (추후 단가 함수 완료 시 변경)
					} else {
						row.unit_price = typeof rowArr[i].sale_price == "undefined" ? unitPrice : rowArr[i].sale_price;
						row.amount = typeof rowArr[i].sale_price == "undefined" ? unitPrice : rowArr[i].sale_price; // vat별도 값 (추후 단가 함수 완료 시 변경)
					}

                    if(rowArr[i].hasOwnProperty("warning_text") && rowArr[i].warning_text != "" && rowArr[i].warning_text != undefined){
						warningText += partNo+" 주의사항 : \n"+rowArr[i].warning_text+"\n\n";
                    }

					row.part_name_change_yn = rowArr[i].part_name_change_yn;
					row.storage_name = rowArr[i].storage_name;
					row.part_mng_cd = rowArr[i].part_mng_cd;
					AUIGrid.addRow(auiGrid, row, 'last');

					if(rowArr[i].hasOwnProperty("multi_check") && rowArr[i].multi_check == "Y" && warningText != "" && warningText != undefined){
						fnChangeAmt();
						fnChangeDCAmt();
						fnDiscountInit();
						fnChangeMileAmt();
                    	return warningText;
                    }
				}
				if(warningText != ""){
                	window.setTimeout(function(){ alert(warningText) }, 200);
				}

				// 금액, 할인 적용
				fnChangeAmt();
				fnChangeDCAmt();
				fnDiscountInit();
				fnChangeMileAmt();
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
						console.log("a");
						if(item === undefined) {
							AUIGrid.updateRow(auiGrid, {part_no : event.oldValue}, event.rowIndex);
						} else {
							// 수정 완료하면, 나머지 필드도 같이 업데이트 함.

							// VIP판매가 추가 : 고객이 VIP일경우 VIP판매가로 적용.
							var unitPrice = 0;
                            var warningText = "";
							if ($M.getValue("vip_yn") == 'Y') {
								unitPrice = item.vip_sale_price;
							} else {
								unitPrice = item.sale_price;
							}

							if(item.hasOwnProperty("warning_text") && item.warning_text != "" && item.warning_text != undefined){
								warningText += event.value+" 주의사항 : \n"+item.warning_text+"\n\n";
		                    }

							AUIGrid.updateRow(auiGrid, {
								part_name : item.part_name,
								stock_qty : item.part_able_stock,
								qty : 1,
// 								unit_price : item.sale_price,
								unit_price : unitPrice,
// 								total_amt : event.item.add_qty * item.sale_price,
								total_amt : event.item.add_qty * unitPrice,
								part_name_change_yn : item.part_name_change_yn,
								storage_name : item.storage_name,
								part_mng_cd : item.part_mng_cd,
							}, event.rowIndex);

							if(warningText != ""){
			                	window.setTimeout(function(){ alert(warningText) }, 200);
                            }
						}
						// 금액, 할인 적용
						fnChangeAmt();
						fnChangeDCAmt();
						fnDiscountInit();
						fnChangeMileAmt();
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
						fnChangeMileAmt();
					}
					if (event.dataField == "unit_price") {
						unitPrice = event.value;
						rowIndex = event.rowIndex;
		 	            AUIGrid.updateRow(auiGrid, { "amount" : unitPrice * event.item.qty}, rowIndex);
		 	       		// 금액, 할인 적용
						fnChangeAmt();
						fnChangeDCAmt();
						fnDiscountInit();
						fnChangeMileAmt();
					}
					break;
				}
			};

		// 엔터키 이벤트
		function enter(fieldObj) {
			var name = fieldObj.name;
			if (name == "cust_name") {
				goCustInfo();
			} if (name == "deposit_name") {
				goChangeDeposit();
			}
		}

		// 금액 변경 메소드
		 function fnChangeAmt() {
			 var values = AUIGrid.getColumnValues(auiGrid, "amount");
			 var valuesQty = AUIGrid.getColumnValues(auiGrid, "qty");
			 var totalAmt = sum(values);
			 var totalQty = sum(valuesQty);
			 $M.setValue("total_amt", totalAmt);
			 $M.setValue("total_qty", totalQty);
		 }

		// 마일리지예상금액 변경 메소드
		function fnChangeMileAmt() {
			var totalAmt = $M.toNum($M.getValue("total_amt"));
			var milePercent =$M.toNum("${milePercent}");
			var expectMileAmt = Math.round(totalAmt * milePercent);
			$M.setValue("expect_mile_amt", expectMileAmt);
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
					sale_amt : Math.round(totalAmt+vat),
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
					sale_amt : Math.round(resultPrice+vat),
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
					sale_amt : Math.round(totalAmt+vat),
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
					sale_amt : Math.round(resultPrice+vat),
					vat : vat,
					discount_amt : savePrice
				}
				$M.setValue(calc);
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

		function goCustInfoClick() {
			if (fnCheckRfq() == false) {
				return false;
			};

			if (fnCheckOrder() == false) {
				return false;
			};

			var param = {
					s_cust_no : $M.getValue("cust_name")
			};
			openSearchCustPanel('fnSetCustInfo', $M.toGetParam(param));
		}

		function goCustInfo() {
			if (fnCheckRfq() == false) {
				return false;
			};
			if (fnCheckOrder() == false) {
				return false;
			};
			if($M.validation(null, {field:['cust_name']}) == false) {
				return;
			}
			var param = {
					s_cust_no : $M.getValue("cust_name"),
					"s_sort_key" : "c.cust_name",
					"s_sort_method" : "desc",
			};
			$M.goNextPageAjax(this_page + "/searchCust", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$("#cust_name").blur();
						var list = result.list;
						console.log(list.length, "----->> length");
						console.log(list, "----->> list");
						switch(list.length) {
							case 0 :
								$M.clearValue({field:["cust_name"]});
								break;
							case 1 :
								var row = list[0];
								console.log(row, "---->> row");
								fnSetCustInfo(row);
								break;
							default :
								openSearchCustPanel('fnSetCustInfo', $M.toGetParam(param));
							break;
						}
					}
				}
			);
		}

		function fnSetCustInfo(row) {
			var custGradeHandCdStr = row.cust_grade_hand_cd_str;
			$M.setValue("cust_grade_hand_cd_str", custGradeHandCdStr);
			if (custGradeHandCdStr.indexOf("03") != -1) {
				alert("거래금지 고객입니다. 확인후 진행해주세요.");
				return false;
			}
			if (custGradeHandCdStr.indexOf("04") != -1) {
				alert("그레이장비 보유 고객입니다. 수주등록 전에 확인 바랍니다.");
			}

			isCust = true;
			$M.goNextPageAjax(this_page + "/custInfo/" + row.cust_no, "", {method : 'GET'},
				function(result) {
		    		if(result.success) {
		    			AUIGrid.clearGridData(auiGrid);
		    			var list = result.list;
						// 3차 서비스 추가 : VIP 고객이 일반가로 보일 경우 알림
						if(list.real_vip_yn == 'Y' && list.vip_yn == 'N') {
							alert(list.cust_name + " 고객님은 VIP 고객이나 미수로 인하여 현재 단가는 일반가로 보여집니다. 참고바랍니다.");
						}
		    			$M.setValue(list);
		    			var param = {
		    					cust_no : list.cust_no,
								__s_cust_no : list.cust_no,
		    					cust_name : list.cust_name,
		    					hp_no : $M.phoneFormat(list.hp_no),
		    					fax_no : list.fax_no,
		    					breg_seq : list.breg_seq,
		    					breg_name : list.breg_name,
		    					breg_no : list.breg_no,
		    					real_breg_no : list.real_breg_no,
		    					breg_rep_name : list.breg_rep_name,
		    					breg_cor_type : list.breg_cor_type,
		    					breg_cor_part : list.breg_cor_part,
		    					post_no : list.post_no,
		    					addr1 : list.addr1,
		    					addr2 : list.addr2,
		    					receive_name : list.cust_name,
		    					receive_hp_no : $M.phoneFormat(list.hp_no),
		    				}
		    			$M.setValue(param);

		    			// select box 옵션 전체 삭제
	    				$("#machine_seq option").remove();

    					var machineList = result.machineList;
    					if(machineList.length > 0) {
	    					for(item in machineList) {
	    						// 고객이 보유하고 있는 장비 list 추가
	    						$("#machine_seq").append(new Option(machineList[item].machine_name, machineList[item].machine_seq));
	    					}
    					}
    					goSearchPrivacyAgree();
						goSearchCUstMemo();

						if (list.vip_yn == "Y") {
							// 단가 헤더 속성값 변경하기
							AUIGrid.setColumnProp(auiGrid, 6, {
								headerText : "단가(VIP)",
								width : 80,
								headerStyle : "aui-vip-header",
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
							});
						} else {
							// 단가 헤더 속성값 변경하기
							AUIGrid.setColumnProp(auiGrid, 6, {
								headerText : "단가(일반)",
								width : 80,
								headerStyle : "aui-vip-header",
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
							});
						}
						// 23.06.09 [정윤수] 이원영파트장님 요청으로 10행 자동 추가 삭제
						// fnAdd();
					}
				}
			);
		}

		// 개인정보동의 팝업
		function goSearchPrivacyAgree() {
			var param = {
				cust_no : $M.getValue("cust_no")
			}
			$M.goNextPageAjax("/comp/comp0306/search", $M.toGetParam(param), {method : 'get'},
				function(result){
					if(result.success) {
						var custInfo = result.custInfo;
						if (custInfo.personal_yn != "Y") {
							if (confirm("개인정보 동의사항을 확인하세요") == true) {
								openPrivacyAgreePanel('fnSetPrivacy', $M.toGetParam(param));
							}
						}
					}
				}
			);
		}

		// 거래시필수확인사항
		function goSearchCUstMemo() {
			var param = {
				cust_no : $M.getValue("cust_no")
			}

			$M.goNextPageAjax("/comp/comp0702/search", $M.toGetParam(param), {method : 'get'},
					function(result){
						if(result.success) {
							var listSize = result.total_cnt;
							if (listSize > 0) {
								openCheckRequiredPanel('fnSetRequired', $M.toGetParam(param));
							}
						}
					}
			);
		}

		// 개인정보 동의 세팅
		function fnSetPrivacy(data) {
		}

		function fnSetRequired(data) {
		}

		// 고객상세 팝업
		function goCustDetailInfo() {
			var custNo = $M.getValue('cust_no');
			if (isCust == false) {
				alert("고객명을 검색해서 입력해주세요.");
				$("#cust_name").focus();
				return false;
			}
			var param = {
					"cust_no" : $M.getValue("cust_no")
			}
			var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=750, left=0, top=0";
			$M.goNextPage('/cust/cust0102p01/', $M.toGetParam(param), {popupStatus : poppupOption});
		}

		// 사업자명세 팝업
		function goBregSpecInfo() {
			if($M.getValue('cust_no') == "") {
				alert("고객을 먼저 조회해주세요.");
				return false;
			}
			var param = {
	    			 's_cust_no' : $M.getValue('cust_no')
	    	  };
	    	  openSearchBregSpecPanel('fnSetBregSpec', $M.toGetParam(param));
		}

	    // 사업자명세
	    function fnSetBregSpec(row) {
	    	 var param = {
	 	        	"breg_name" : row.breg_name,
	 	        	"breg_no" : row.breg_no,
	 	        	"real_breg_no" : row.breg_no,
	 	        	"breg_rep_name" : row.breg_rep_name,
	 	        	"breg_cor_type" : row.breg_cor_type,
	 	        	"breg_cor_part" : row.breg_cor_part,
	 	        	"breg_seq" : row.breg_seq,
	 	        	"post_no" : row.biz_post_no,
	 	        	"addr1" : row.biz_addr1,
	 	        	"addr2" : row.biz_addr2,
	 	        };
	 	        $M.setValue(param);

// 	 	       var bregNo = row.breg_no;
// 		        console.log(bregNo.length);
// 		        console.log(bregNo);
// 		        console.log(row.breg_seq);
// 		        if(bregNo.length == 13) {
// 		        	var params = {
// 		        			"breg_seq" : row.breg_seq
// 		        	}
// 		        	$M.goNextPageAjax("/cust/cust020201/breg", $M.toGetParam(params), {method : 'GET'},
// 	    				function(result) {
// 	    		    		if(result.success) {
// 	    		    			$M.setValue("breg_no", result.info.breg_no);
// 	    					}
// 	    				}
// 	    			);
// 		        }

	    }

	    // 견적서 참조
	    function goReferEstimate() {
	    	var rfqNo = $M.getValue("rfq_no");
			if (rfqNo == "") {
				var param = {
					rfq_type : "PART",
					type_select_yn : "N",
					refer_yn : "Y"
				}
				openRfqReferPanel("fnSetRfqRefer", $M.toGetParam(param));
			} else {
				var param = {
						rfq_no : rfqNo,
						disabled_yn : "Y",
						cust_no : $M.getValue("cust_no")
				}
				var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=600, left=0, top=0";
				$M.goNextPage('/cust/cust0107p02', $M.toGetParam(param), {popupStatus : poppupOption});
			}
	    }

		 // 견적서 참조 결과
		function fnSetRfqRefer(row) {
			fnInit();
			var param = {
					cust_no : row.cust_no
			}
			$M.goNextPageAjax("/rfq/refer/"+row.rfq_type_cd+"/"+row.rfq_no, $M.toGetParam(param), {method : 'GET'},
				function(result) {
		    		if(result.success) {
		    			isCust = true; isRfq = true; isOrder = false;
		    			$("#btnRefer").html("(견)"+result.basicInfo.rfq_no);
		    			AUIGrid.setGridData(auiGrid, result.partList);
		    			AUIGrid.update(auiGrid);
		    			fnSetData(result);
					}
				}
			);
		}

	    // 즐겨찾는 견적서 참조
	    function goReferFav() {
	    	if (isCust == false) {
				alert("고객명을 검색해서 입력해주세요.");
				$("#cust_name").focus();
				return false;
			}
			var params = {
					"parent_js_name" : "fnSetReferFav",
					"sale_yn" : "Y"
			};
			var popupOption = "";
			$M.goNextPage('/cust/cust0107p05', $M.toGetParam(params), {popupStatus : popupOption});
	    }

		 // 즐겨찾는 견적서 참조 결과
		function fnSetReferFav(row) {
			var param = {
					"rfq_part_fav_seq" : row.rfq_part_fav_seq,
					"cust_no" : $M.getValue("cust_no")
			}

			$M.goNextPageAjax(this_page + "/searchReferFav", $M.toGetParam(param), {method : 'GET'},
				function(result) {
		    		if(result.success) {
		    			isCust = true; isRfq = false; isOrder = false;
// 		    			console.log(result);
// 		    			AUIGrid.setGridData(auiGrid, result.partList);
// 		    			AUIGrid.update(auiGrid);

						// 즐겨찾는 견적서 클릭할 때마다 추가 (리셋 안 함)
						var list = result.partList;

						var partNo = '';
						var partName = '';
						var unitPrice = '';
						var rows = new Object();
						if(list != null) {
							for(i=0; i < list.length; i++) {
								rows.seq_no = "";
								partNo = typeof list[i].part_no == "undefined" ? partNo : list[i].part_no;
								partName = typeof list[i].part_name == "undefined" ? partName : list[i].part_name;
								rows.part_no = partNo;
								rows.part_name = partName;
								rows.qty = list[i].qty;
								rows.part_unit = list[i].part_unit;
								rows.sale_mi_qty = list[i].sale_mi_qty;
								rows.stock_qty = list[i].stock_qty;		// 전체 현재고가 아닌 소속창고의 현재고
								rows.unit_price = typeof list[i].unit_price == "undefined" ? unitPrice : list[i].unit_price;
								rows.part_name_change_yn = list[i].part_name_change_yn;
								rows.storage_name = list[i].storage_name;
								rows.part_mng_cd = list[i].part_mng_cd;
								AUIGrid.addRow(auiGrid, rows, 'last');
							}
						}

		    			$M.setValue("discount_rate", row.discount_rate);
		    			// 금액, 할인 적용
						fnChangeAmt();
		    			fnChangeDCRate();
					}
				}
			);
		}

		function fnSetData(result) {
			var info = result.basicInfo;
			var machineList = result.machineList;

			if (info.vip_yn == 'Y') {
				// 단가 헤더 속성값 변경하기
				AUIGrid.setColumnProp(auiGrid, 6, {
					headerText : "단가(VIP)",
					width : 80,
					headerStyle : "aui-vip-header",
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
				});
			} else {
				// 단가 헤더 속성값 변경하기
				AUIGrid.setColumnProp(auiGrid, 6, {
					headerText : "단가(일반)",
					width : 80,
					headerStyle : "aui-vip-header",
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
				});
			}

			// select box 옵션 전체 삭제
			$("#machine_seq option").remove();

			if(machineList.length > 0) {
				for(item in machineList) {
					// 차대번호의 고객이 보유하고 있는 list 추가
					$("#machine_seq").append(new Option(machineList[item].machine_name, machineList[item].machine_seq));
				}
			}

			var param = {
					cust_name : info.cust_name,
					cust_no : info.cust_no,
					breg_name : info.breg_name,
					breg_no : info.breg_no,
					real_breg_no : info.real_breg_no,
					machine_seq : info.machine_seq,
					breg_rep_name : info.breg_rep_name,
					breg_cor_type : info.breg_cor_type,
					breg_cor_part : info.breg_cor_part,
					post_no : info.post_no,
					addr1 : info.addr1,
					addr2 : info.addr2,
					deposit_name : info.deposit_name,
					misu_amt : info.misu_amt,
					rfq_no : info.rfq_no,
					discount_amt : info.discount_amt,
					coupon_balance_amt : info.coupon_balance_amt,
					discount_rate : info.discount_rate,
					sale_amt : "0",
					total_amt : "0",
					total_qty : "0",
					// 배송 정보
					receive_name : info.cust_name,
					receive_hp_no : $M.phoneFormat(info.hp_no),
					receive_tel_no : info.tel_no,
					invoice_post_no : info.post_no,
					invoice_addr1 : info.addr1,
					invoice_addr2 : info.addr2,
					invoice_send_cd : info.invoice_send_cd,
					invoice_type_cd : info.invoice_type_cd,
					invoice_money_cd : info.invoice_money_cd,
					vip_yn : info.vip_yn
				}
			 $M.setValue(param);

			 if (info.hp_no != null) {
				 $M.setValue("hp_no", $M.phoneFormat(info.hp_no));
			 }

			// 금액, 할인 적용
			fnChangeAmt();
			fnChangeDCAmt();
		}

		// 주문서 참조
	    function goReferOrder() {
				var params = {
						"parent_js_name" : "fnSetPartSaleInfo"
				};
				var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1000, height=400, left=0, top=0";
				$M.goNextPage('/cust/cust0202p02', $M.toGetParam(params), {popupStatus : popupOption});
	    }

		// 주문서 참조시 데이터 콜백
		function fnSetPartSaleInfo(data) {

			var param = {
					"search_type" : 'PART_SALE',
					"search_key" : data.part_sale_no
			}
			$M.goNextPageAjax("/cust/cust020201/info", $M.toGetParam(param), {method : 'GET'},
				function(result) {
		    		if(result.success) {
		    			// 초기화
		    			fnInit();
		    			isCust = true; isOrder = true; isReq = false;
		    			console.log(result);
		    			$("#btnRefer").html("견적서");
		    			fnSetCustInfo(result.bean);

		    			for(i = 0; i< result.list.length; i++){
		    				result.list[i]["part_unit"] = result.list[i].unit;
		    				result.list[i]["part_name"] = result.list[i].item_name;
		    			}

		    			AUIGrid.setGridData("#auiGrid", result.list);
		    			// 금액, 할인 적용
		    			fnChangeAmt();
		    			fnChangeDCAmt();
					}
				}
			);
		}


		function fnCheckRfq() {
			if (isRfq == true) {
				alert("견적서를 참조한 자료는 부품/고객을 수정할 수 없습니다.");
				return false;
			}
		}

		function fnCheckOrder() {
			if (isOrder == true) {
				alert("주문서를 참조한 자료는 부품/고객을 수정할 수 없습니다.");
				return false;
			}
		}


		// 초기화
		function fnInit() {

			var param = {
				cust_name : "",
				cust_no : "",
				rfq_no : "",
				hp_no : "",
				machine_seq : "",
				breg_name : "",
				breg_no : "",
				real_breg_no : "",
				breg_rep_name : "",
				breg_cor_type : "",
				breg_cor_part : "",
				post_no : "",
				addr1 : "",
				addr2 : "",
				deposit_name : "",
				misu_amt : "",
				rfq_no : "",
				discount_amt : "0",
				discount_rate : "0",
				sale_amt : "0",
				total_amt : "",
				total_qty : "0",
				invoice_send_cd : "",
				invoice_money_cd : "",
				invoice_no : "",
				invoice_qty : "",
				receive_tel_no : "",
				receive_name : "",
				receive_hp_no : "",
				invoice_remark : "",
				invoice_post_no : "",
				invoice_addr1 : "",
				invoice_addr2 : ""
			}
			$M.clearValue();
			// 선택사항 그리드 초기화
			AUIGrid.setGridData(auiGrid, []);
			$('#part_sale_type_c').prop('checked', true);
			$M.setValue(param);
		}

		// 입금자명 변경
	    function goChangeDeposit() {
	    	if (isCust == false) {
				alert("고객명을 검색해서 입력해주세요.");
				$("#cust_name").focus();
				return false;
			}
	    	var custNo = $M.getValue("cust_no");
	    	if($M.getValue("deposit_name") == "") {
				alert("입금자명을 입력해주세요.");
				$M.getComp("deposit_name").focus();
				return false;
	    	}
	    	var param = {
					deposit_name : $M.getValue("deposit_name")
				}
	    	var msg = "입금자명을 변경하시겠습니까?";
	    	$M.goNextPageAjaxMsg(msg, this_page + "/deposit/" + custNo, $M.toGetParam(param), {method : 'POST'},
					function(result) {
						console.log(result);
				    	if(result.success) {
						}
					}
				);
	    }

	    // 배송정보 팝업
	    function goDeliveryInfo() {
	    	if (isCust == false) {
				alert("고객명을 검색해서 입력해주세요.");
				$M.setValue("invoice_send_cd", "");
				$("#cust_name").focus();
				return false;
			}
	    	var params = {
	    			cust_no : $M.getValue("cust_no"),
	    			invoice_money_cd : $M.getValue("invoice_money_cd"),
	    			invoice_send_cd : $M.getValue("invoice_send_cd"),
	    			receive_name : $M.getValue("receive_name"),
	    			invoice_no : $M.getValue("invoice_no"),
	    			receive_hp_no : $M.getValue("receive_hp_no"),
	    			receive_tel_no : $M.getValue("receive_tel_no"),
	    			qty : $M.getValue("invoice_qty"),
	    			remark : $M.getValue("invoice_remark"),
	    			post_no : $M.getValue("invoice_post_no"),
	    			addr1 : $M.getValue("invoice_addr1"),
	    			addr2 : $M.getValue("invoice_addr2"),
	    			invoice_type_cd : $M.getValue("invoice_type_cd"),

	    	};

	    	openDeliveryInfoPanel('setDeliveryInfo', $M.toGetParam(params));
	    }

	    // 배송정보 callback
	    function setDeliveryInfo(data) {
	    	isDelivery = true;
	    	$M.setValue(data);

	    	// 대신화물일 시 post_no 입력안함
	    	if(data.invoice_send_cd == "5") {
	    		$M.setValue("invoice_post_no", "");
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

		// seq_no 발번
		function fnUpdateSeqNo() {
			var gridData = AUIGrid.getGridData(auiGrid);
			var seqNo = 1;
			for(var i = 0; i < gridData.length; i++) {
				AUIGrid.updateRow(auiGrid, {seq_no : seqNo}, i);
				seqNo++;
			}
			var updateData = AUIGrid.getEditedRowItems(auiGrid);

		}

		function fnValidation() {
			if (isCust == false) {
				alert("고객명을 검색해서 입력해주세요.");
				$("#cust_name").focus();
				return false;
			}
// 			if (isDelivery == false) {
// 				alert("배송정보설정으로 배송지주소를 설정해주십시오.");
// 				goDeliveryInfo();
// 				return false;
// 			}
			if($M.validation(document.main_form) == false) {
				return false;
			}
			var gridData = AUIGrid.getGridData(auiGrid);
			if(gridData.length <= 0) {
				alert("부품을 추가해주세요.");
				return false;
			}
// 			if(fnCheckGridEmpty(auiGrid) == false) {
// 				return false;
// 			}
		}

	    // 저장
		/*
		function goSave() {
			$M.setValue("invoice_type", "SAVE");

			if(fnValidation() == false) {
				return false;
			}
			var frm = document.main_form;
			frm = $M.toValueForm(document.main_form);

			var gridData = AUIGrid.getGridData(auiGrid);

			// 부품 수량이 0인 row가 있으면 confirm창 띄우기 2021-06-28 황빛찬
			var qtyValid = false;
			for (var i = 0; i < gridData.length; i++) {
				if (gridData[i].qty == 0) {
					qtyValid = true;
				}
			}

			if (qtyValid) {
				if (confirm("부품 입력수량이 0인 항목(부품)이 있습니다. \n계속 진행 하시겠습니까 ?") == false) {
					return false;
				}
			}

			var part_no_arr = [];
			var part_name_arr = [];
			var seq_no_arr = [];
			var part_unit_arr = [];
			var stock_qty_arr = [];
			var qty_arr = [];
			var unit_price_arr = [];
			var amount_arr = [];
			var out_dt_arr = [];
			var sale_mi_qty_arr = [];
			var remark_arr = [];

			for (var i = 0; i < gridData.length; i++) {
				part_no_arr.push(gridData[i].part_no);
				part_name_arr.push(gridData[i].part_name);
				seq_no_arr.push(gridData[i].seq_no);
				part_unit_arr.push(gridData[i].part_unit);
				stock_qty_arr.push(gridData[i].stock_qty);
				qty_arr.push(gridData[i].qty);
				unit_price_arr.push(gridData[i].unit_price);
				amount_arr.push(gridData[i].amount);
				out_dt_arr.push(gridData[i].out_dt);
				sale_mi_qty_arr.push(gridData[i].qty);
				remark_arr.push(gridData[i].remark);
			}

			var option = {
					isEmpty : true
			};

 			$M.setValue(frm, "part_no_str", $M.getArrStr(part_no_arr, option));
 			$M.setValue(frm, "part_name_str", $M.getArrStr(part_name_arr, option));
 			$M.setValue(frm, "seq_no_str", $M.getArrStr(seq_no_arr, option));
 			$M.setValue(frm, "part_unit_str", $M.getArrStr(part_unit_arr, option));
 			$M.setValue(frm, "stock_qty_str", $M.getArrStr(stock_qty_arr, option));
 			$M.setValue(frm, "qty_str", $M.getArrStr(qty_arr, option));
 			$M.setValue(frm, "unit_price_str", $M.getArrStr(unit_price_arr, option));
 			$M.setValue(frm, "amount_str", $M.getArrStr(amount_arr, option));
 			$M.setValue(frm, "out_dt_str", $M.getArrStr(out_dt_arr, option));
 			$M.setValue(frm, "sale_mi_qty_str", $M.getArrStr(sale_mi_qty_arr, option));
 			$M.setValue(frm, "remark_str", $M.getArrStr(remark_arr, option));

			$M.goNextPageAjaxSave(this_page + "/save", frm, {method : 'POST'},
				function(result) {
					console.log(result);
			    	if(result.success) {
			    		alert("저장이 완료되었습니다.");
			    		var param = {
								"part_sale_no" : result.part_sale_no,
								"cust_no" : $M.getValue("cust_no")
							};
						$M.goNextPage('/cust/cust0201p01', $M.toGetParam(param));
						// if (window.parent) window.parent.location.reload();
					}
				}
			);

		}
		*/

		// 3차 신화면 확정단계 삭제로 인하여 저장으로 변경
		// 확정
	    // function goProcessConfirm() {
	    function goSave() {
	    	// 21.09.09 재고 부족 부품이 있을 시 해당 수주를 선주문 수주로 변경할지 여부 추가
			var gridData = AUIGrid.getGridData(auiGrid);

			var preValid = false;
			for (var i = 0; i < gridData.length; i++) {
				if (gridData[i].part_no != "" && gridData[i].part_mng_cd != "8"
						&& (gridData[i].stock_qty < gridData[i].qty)) {
					preValid = true;
				}
			}

			var result = "";
			if(preValid && $M.getValue("part_sale_type_ca") != "A" && $M.getValue("preorder_yn") != "Y") {
				// result = confirm("재고 부족인 부품이 있습니다.\n해당 수주를 선주문으로 변경하시겠습니까?");
				// [정윤수] 23.05.09 Q&A 17407 주문시스템 개선으로 인하여 선주문여부 묻지 않고 자동처리
				result = true;
			}
			if (result) {
				if(preValid && $M.getValue("part_sale_type_ca") != "A" && $M.getValue("preorder_yn") != "Y") {
					$M.setValue("preorder_yn", "Y");
				}
	        }

			// $M.setValue("invoice_type", "CONFIRM");
			$M.setValue("invoice_type", "SAVE");
			if(fnValidation() == false) {
				return false;
			}
			var frm = document.main_form;
			frm = $M.toValueForm(document.main_form);

			// 부품 수량이 0인 row가 있으면 confirm창 띄우기 2021-06-28 황빛찬
			var qtyValid = false;
			for (var i = 0; i < gridData.length; i++) {
				if (gridData[i].qty == 0) {
					qtyValid = true;
				}
			}

			if (qtyValid) {
				if (confirm("부품 입력수량이 0인 항목(부품)이 있습니다. \n계속 진행 하시겠습니까 ?") == false) {
					return false;
				}
			}

			var part_no_arr = [];
			var part_name_arr = [];
			var seq_no_arr = [];
			var part_unit_arr = [];
			var stock_qty_arr = [];
			var qty_arr = [];
			var unit_price_arr = [];
			var amount_arr = [];
			var out_dt_arr = [];
			var sale_mi_qty_arr = [];
			var remark_arr = [];

			for (var i = 0; i < gridData.length; i++) {
				part_no_arr.push(gridData[i].part_no);
				part_name_arr.push(gridData[i].part_name);
				seq_no_arr.push(gridData[i].seq_no);
				part_unit_arr.push(gridData[i].part_unit);
				stock_qty_arr.push(gridData[i].stock_qty);
				qty_arr.push(gridData[i].qty);
				unit_price_arr.push(gridData[i].unit_price);
				amount_arr.push(gridData[i].amount);
				out_dt_arr.push(gridData[i].out_dt);
				sale_mi_qty_arr.push(gridData[i].qty);
				remark_arr.push(gridData[i].remark);
			}

			var option = {
					isEmpty : true
			};

 			$M.setValue(frm, "part_no_str", $M.getArrStr(part_no_arr, option));
 			$M.setValue(frm, "part_name_str", $M.getArrStr(part_name_arr, option));
 			$M.setValue(frm, "seq_no_str", $M.getArrStr(seq_no_arr, option));
 			$M.setValue(frm, "part_unit_str", $M.getArrStr(part_unit_arr, option));
 			$M.setValue(frm, "stock_qty_str", $M.getArrStr(stock_qty_arr, option));
 			$M.setValue(frm, "qty_str", $M.getArrStr(qty_arr, option));
 			$M.setValue(frm, "unit_price_str", $M.getArrStr(unit_price_arr, option));
 			$M.setValue(frm, "amount_str", $M.getArrStr(amount_arr, option));
 			$M.setValue(frm, "out_dt_str", $M.getArrStr(out_dt_arr, option));
 			$M.setValue(frm, "sale_mi_qty_str", $M.getArrStr(sale_mi_qty_arr, option));
 			$M.setValue(frm, "remark_str", $M.getArrStr(remark_arr, option));

	    	var msg = "저장하시겠습니까?";
			if ($M.getValue("cust_grade_hand_cd_str").indexOf("04") != -1) {
				msg = "그레이장비 보유 고객입니다. " + msg;
			}
			$M.goNextPageAjaxMsg(msg, this_page + "/save", frm, {method : 'POST'},
				function(result) {
					console.log(result);
			    	if(result.success) {
			    		alert("저장 되었습니다.");
			    		var param = {
								"part_sale_no" : result.part_sale_no,
								"cust_no" : $M.getValue("cust_no"),
								"sale_part_sale_no" : $M.getValue("sale_part_sale_no") // 반품대상 수주전표번호
							};
						$M.goNextPage('/cust/cust0201p01', $M.toGetParam(param));
						// if (window.parent) window.parent.location.reload();
					}
				}
			);
	    }

		// 삭제 시 합계 계산
		function minusAmt(qty, amt) {
			var totalQty = $M.toNum($M.getValue("total_qty"));
			var totalAmt = $M.toNum($M.getValue("total_amt"));
			$M.setValue("total_qty", totalQty-qty);
			$M.setValue("total_amt", totalAmt-amt);
			fnDiscountInit();
			var vat =  $M.toNum(Math.floor($M.getValue("total_amt")*0.1));
			var saleAmt =  vat+$M.toNum($M.getValue("total_amt"));
			$M.setValue("vat", vat);
			$M.setValue("sale_amt", saleAmt);
			fnChangeMileAmt();
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
			$M.setValue("sale_amt", saleAmt);
			fnChangeMileAmt();
		}

	    // 조회 페이지로 이동
	    function fnList() {
	    	$M.goNextPage("/cust/cust0201");
	    }

	    // 입출금전표처리 팝업
	    function goInoutPopup() {
			var popupOption = "";
    		// 입출금전표처리
    		var param = {
    				"cust_no" : $M.getValue("cust_no"),
    				"popup_yn" : "Y"
    		};

			$M.goNextPage('/cust/cust020301', $M.toGetParam(param), {popupStatus : popupOption});
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
	    	console.log("list : ", list);
			var partNo =  "";
			var partName =  "";
			var unitPrice = "";
			var row = new Object();
			var warningText = "";
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
					row.part_mng_cd = list[i].part_mng_cd;
					row.remark = typeof list[i].set_name == "undefined" ? list[i].remark : list[i].remark + ' (' + list[i].set_name + ')';

					if(list[i].hasOwnProperty("warning_text") && list[i].warning_text != "" && list[i].warning_text != undefined){
						warningText += partNo+" 주의사항 : \n"+list[i].warning_text+"\n\n";
                    }

					AUIGrid.addRow(auiGrid, row, 'last');
				}

				if(warningText != ""){
                	window.setTimeout(function(){ alert(warningText) }, 200);
				}

				// 금액, 할인 적용
				fnChangeAmt();
				fnChangeDCAmt();
				fnDiscountInit();
				fnChangeMileAmt();
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

	    function fnClose() {
			window.close();
		}

		/**
		 * 장기/충당재고 팝업
		 */
		function goDetail() {
			if (isCust == false) {
				alert("고객명을 검색해서 입력해주세요.");
				$("#cust_name").focus();
				return false;
			}
			var param = {
				"cust_no" : $M.getValue("cust_no")
			};

			openSearchLongPartPanel("setLongPartInfo", "Y", $M.toGetParam(param));
		}
		// 장기/충당재고 부품정보 세팅
		function setLongPartInfo(rowArr){
			var longPartYn = "Y";
			setPartInfo(rowArr, longPartYn);
		}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" name="invoice_type" id="invoice_type" value=""><!-- 저장/확정 구분 -->
<input type="hidden" name="warehouse_cd" id="warehouse_cd" value="${SecureUser.warehouse_cd != '' ? SecureUser.warehouse_cd : SecureUser.org_code}"><!-- 로그인한 사용자의 조직코드 -->
<input type="hidden" name="org_gubun_cd" id="org_gubun_cd" value="${SecureUser.org_type}"><!-- 로그인한 사용자의 소속 -->
<input type="hidden" name="cust_no" id="cust_no" value=${inputParam.cust_no}><!-- 고객번호 -->
<input type="hidden" name="rfq_no" id="rfq_no" value=${inputParam.rfq_no}><!-- 견적서번호 -->
<input type="hidden" name="invoice_type_cd" id="invoice_type_cd"><!-- 수주 -->
<input type="hidden" name="invoice_money_cd" id="invoice_money_cd"><!-- 송장비용방식 -->
<input type="hidden" name="invoice_no" id="invoice_no"><!-- 송장번호 -->
<input type="hidden" name="bill_no" id="bill_no"><!-- 대신화물송장번호 -->
<input type="hidden" name="sale_part_sale_no" id="sale_part_sale_no"><!-- 반품대상 수주전표번호 -->
<input type="hidden" name="invoice_qty" id="invoice_qty">
<input type="hidden" name="receive_tel_no" id="receive_tel_no">
<input type="hidden" name="receive_name" id="receive_name">
<input type="hidden" name="receive_hp_no" id="receive_hp_no">
<input type="hidden" name="invoice_remark" id="invoice_remark">
<input type="hidden" name="part_no_str" id="part_no_str">
<input type="hidden" name="part_name_str" id="part_name_str">
<input type="hidden" name="seq_no_str" id="seq_no_str">
<input type="hidden" name="part_unit_str" id="part_unit_str">
<input type="hidden" name="stock_qty_str" id="stock_qty_str">
<input type="hidden" name="qty_str" id="qty_str">
<input type="hidden" name="unit_price_str" id="unit_price_str">
<input type="hidden" name="amount_str" id="amount_str">
<input type="hidden" name="out_dt_str" id="invoiout_dt_strce_remark">
<input type="hidden" name="sale_mi_qty_str" id="sale_mi_qty_str">
<input type="hidden" name="remark_str" id="remark_str">
<input type="hidden" name="part_sale_no" id="part_sale_no">
<input type="hidden" name="real_breg_no" id="real_breg_no">
<input type="hidden" name="breg_seq" id="breg_seq">
<input type="hidden" id="s_popup_yn" name="s_popup_yn" value="${inputParam.s_popup_yn}">
<input type="hidden" id="part_return_no" name="part_return_no" value="${inputParam.part_return_no}">
<input type="hidden" name="vip_yn" id="vip_yn">
<input type="hidden" id="cust_grade_hand_cd_str" name="cust_grade_hand_cd_str">
<div class="layout-box">
<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
<!-- 상세페이지 타이틀 -->
				<div class="main-title detail">
					<div class="detail-left">
						<button type="button" class="btn btn-outline-light" id="popupBtn" onclick="javascript:fnList();"><i class="material-iconskeyboard_backspace text-default"></i></button>
						<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
					</div>
				</div>
<!-- /상세페이지 타이틀 -->
				<div class="contents">
<!-- 폼테이블 -->
					<div>
						<table class="table-border">
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
									<th class="text-right">수주번호</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-7">
												<input type="text" class="form-control width120px" id="" name="" readonly="readonly">
											</div>
											<div class="col-5">
											<input type="text" class="form-control width120px" id="reg_mem_name" name="reg_mem_name" readonly="readonly" value="${SecureUser.kor_name}">
											</div>
										</div>
									</td>
									<th class="text-right essential-item">수주일자</th>
									<td>
										<div class="input-group">
											<input type="text" class="form-control border-right-0 width120px calDate rb" style="width:120px;" id="sale_dt" name="sale_dt" dateformat="yyyy-MM-dd" alt="수주일자" required="required" value="${inputParam.s_current_dt}">
										</div>
									</td>
									<th class="text-right essential-item">수주구분</th>
									<td>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" value="C" id="part_sale_type_c" name="part_sale_type_ca" checked="checked">
											<label class="form-check-label" for="part_sale_type_c">고객</label>
										</div>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" value="A" id="part_sale_type_a" name="part_sale_type_ca">
											<%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체 --%>
											<%--<label class="form-check-label" for="part_sale_type_a">대리점</label>--%>
											<label class="form-check-label" for="part_sale_type_a">위탁판매점</label>
										</div>
									</td>
									<th class="text-right essential-item">수주종류/상태</th>
									<td>
										<div class="form-row inline-pd">
										<div class="col-auto">
											<div class="form-check form-check-inline">
												<input class="form-check-input" type="radio" value="N" id="preorder_n" name="preorder_yn" checked="checked">
												<label class="form-check-label" for="preorder_n">일반</label>
											</div>
											<div class="form-check form-check-inline">
												<input class="form-check-input" type="radio" value="Y" id="preorder_y" name="preorder_yn">
												<label class="form-check-label" for="preorder_y">선주문</label>
											</div>
										</div>
										<div class="col-auto">/</div>
										<div class="col-auto">작성중</div>
										</div>
									</td>
								</tr>
								<tr>
									<th class="text-right essential-item">고객명</th>
									<td>
										<div class="input-group">
											<input type="text" class="form-control border-right-0 width120px" id="cust_name" name="cust_name" required="required" alt="고객명" readonly="readonly">
											<button type="button" class="btn btn-icon btn-primary-gra mr3 agencyY" onclick="javascript:goCustInfoClick();"><i class="material-iconssearch"></i></button>
											<jsp:include page="/WEB-INF/jsp/common/commonCustJob.jsp">
												<jsp:param name="li_type" value="__cust_dtl#__ledger#__sms_popup#__sms_info#__visit_history#__check_required#__cust_rental_history#__rental_consult_history"/>
											</jsp:include>
										</div>
									</td>
									<th class="text-right essential-item">휴대폰</th>
									<td>
										<div class="input-group">
											<input type="text" class="form-control border-right-0 width140px" readonly="readonly" format="tel" id="hp_no" name="hp_no">
											<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSendSms();"><i class="material-iconsforum"></i></button>
										</div>
									</td>
									<th class="text-right">업체명</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-6">
												<input type="text" class="form-control width120px" readonly="readonly" id="breg_name" name="breg_name">
											</div>
											<div class="col-6"><button type="button" class="btn btn-primary-gra width60px" onclick="javascript:goCustDetailInfo();">상세</button></div>
										</div>
									</td>
									<th class="text-right">대표자</th>
									<td>
										<input type="text" class="form-control width120px" readonly="readonly" id="breg_rep_name" name="breg_rep_name">
									</td>
								</tr>
								<tr>
									<th class="text-right">배송희망일</th>
									<td>
										<div class="input-group">
											<input type="text" class="form-control border-right-0 width120px calDate" id="delivery_plan_dt" name="delivery_plan_dt" dateformat="yyyy-MM-dd">
										</div>
									</td>
									<th class="text-right">마일리지예상금액</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-10">
												<input type="text" class="form-control text-right" readonly="readonly" id="expect_mile_amt" name="expect_mile_amt" format="decimal">
											</div>
											<div class="col-2">원</div>
										</div>
									</td>
									<th class="text-right">사업자번호</th>
									<td colspan="3">
										<div class="form-row inline-pd">
											<div class="col-3">
												<input type="text" class="form-control width140px" readonly="readonly" id="breg_no" name="breg_no">
											</div>
											<div class="col-3">
												<input type="text" class="form-control width140px" readonly="readonly" id="fax_no" name="fax_no">
											</div>
											<div class="col-6">
												<button type="button" class="btn btn-primary-gra" onclick="javascript:goBregSpecInfo();">사업자명세</button>
											</div>
										</div>
									</td>
								</tr>
								<tr>
									<th rowspan="2" class="text-right">배송지주소</th>
									<td colspan="3" rowspan="2">
										<div class="form-row inline-pd mb7">
											<div class="col-3">
												<select class="form-control essential-bg" required="required" id="invoice_send_cd" name="invoice_send_cd" required="required" onChange="javascript:goDeliveryInfo();">
													<option value="">- 선택 -</option>
													<c:forEach items="${codeMap['INVOICE_SEND']}" var="item">
													<option value="${item.code_value}">${item.code_name}</option>
													</c:forEach>
												</select>
											</div>
											<div class="col-2">
												<input type="text" class="form-control" id="invoice_post_no" name="invoice_post_no" readonly="readonly">
											</div>
											<div class="col-5">
												<input type="text" class="form-control" id="invoice_addr1" name="invoice_addr1" readonly="readonly">
											</div>
											<div class="col-2">
											<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_M"/></jsp:include>
											</div>
										</div>
										<div class="form-row inline-pd">
											<div class="col-12">
												<input type="text" class="form-control" id="invoice_addr2" name="invoice_addr2" readonly="readonly">
											</div>
										</div>
									</td>
									<th class="text-right">업태</th>
									<td>
										<input type="text" class="form-control width120px" readonly="readonly" id="breg_cor_type" name="breg_cor_type">
									</td>
									<th class="text-right">종목</th>
									<td>
										<input type="text" class="form-control" readonly="readonly" id="breg_cor_part" name="breg_cor_part">
									</td>
								</tr>
								<tr>
									<th rowspan="2" class="text-right">주소</th>
									<td colspan="3" rowspan="2">
										<div class="form-row inline-pd mb7">
											<div class="col-4">
												<input type="text" class="form-control" readonly="readonly" id="post_no" name="post_no">
											</div>
											<div class="col-8">
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
									<th class="text-right">최종메모</th>
									<td colspan="3">
										<input type="text" class="form-control" readonly="readonly" id="last_memo" name="last_memo">
									</td>
								</tr>
								<tr>
									<th class="text-right">적요</th>
									<td colspan="3">
										<input type="text" class="form-control" id="desc_text" name="desc_text" maxlength="95">
									</td>
									<th class="text-right">입금자</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-6">
												<input type="text" class="form-control" id="deposit_name" name="deposit_name">
											</div>
											<div class="col-6">
											<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
											</div>
										</div>
									</td>
									<th class="text-right">현미수</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-10">
												<input type="text" class="form-control text-right" readonly="readonly" id="misu_amt" name="misu_amt" format="decimal">
											</div>
											<div class="col-2">원</div>
										</div>
									</td>
								</tr>
								<tr>
									<th class="text-right">보유기종</th>
									<td>
										<select class="form-control" id="machine_seq" name="machine_seq">
										</select>
									</td>
									<th class="text-right">불러오기</th>
									<td>
										<button type="button" class="btn btn-primary-gra spacing-sm" onclick="javascript:goReferEstimate();" id="btnRefer">견적서</button>
										<button type="button" class="btn btn-primary-gra spacing-sm" onclick="javascript:goReferFav();" id="btnFav">즐겨찾는견적서</button>
										<button type="button" class="btn btn-primary-gra spacing-sm" onclick="javascript:goReferOrder();" id="btnOrder">주문서</button>
									</td>
									<th class="text-right">쿠폰잔액</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-10">
												<input type="text" class="form-control text-right" readonly="readonly" id="coupon_balance_amt" name="coupon_balance_amt" format="decimal">
											</div>
											<div class="col-2">원</div>
										</div>
									</td>
									<th class="text-right">매출한도</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-10">
												<input type="text" class="form-control text-right" readonly="readonly" id="max_misu_amt" name="max_misu_amt" format="decimal">
											</div>
											<div class="col-2">원</div>
										</div>
									</td>
								</tr>
							</tbody>
						</table>
					</div>
<!-- /폼테이블 -->
<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
							<h4>부품추가내역</h4>
						<div class="btn-group">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
							</div>
						</div>
					</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->
					<div id="auiGrid" style="margin-top: 5px; height: 300px;"></div>
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
									<col width="40%">
									<col width="60%">
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
									<col width="40%">
									<col width="60%">
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
									<col width="40%">
									<col width="60%">
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
										<th class="text-right th-sum">총 수주금액</th>
										<td class="text-right td-gray"><div data-tip="(금액-할인액)*VAT"><input type="text" class="form-control text-right" readonly="readonly" id="sale_amt" name="sale_amt" value="0" format="decimal"></div></td>
									</tr>
								</tbody>
							</table>
						</div>
					</div>
<!-- /합계그룹 -->
					<div class="btn-group mt10">
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
					</div>

				</div>
			</div>
			<c:if test="${inputParam.s_popup_yn ne 'Y'}">
				<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
			</c:if>
		</div>
<!-- /contents 전체 영역 -->
</div>
</form>
</body>
</html>
