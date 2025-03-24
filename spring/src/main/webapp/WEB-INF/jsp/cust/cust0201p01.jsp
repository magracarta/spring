<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 부품판매 > 수주현황/등록 > null > 수주상세
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
		var isDelivery = false;
		var partStatus = ${partSaleStatus};
		var onlyWarehouseYn = "N";
		var milePercent = 0;
		$(document).ready(function() {
			milePercent = $M.toNum(${milePercent});
			// AUIGrid 생성
			createAUIGrid();
			fnMachineList();
			fnBtn();
			fnInitPage();
		});

		// 3차 추가 - vip 상태 비교후 팝업 노출
		window.onload = function () {
			fnVipComparisonPopup();
		}

		function fnBtn() {
			// 23.05.31 Q&A 17407 확정 버튼 미노출
			$("#_goProcessConfirm").addClass("dpn");
			$("#_goCancelConfirm").addClass("dpn");
			switch(partStatus) {
				case "2" : $("#_goProcessConfirm").addClass("dpn");
						$("#_goDeliveryInfo").prop("disabled", true);
						$("#_goPartList").prop("disabled", true);
						$("#_fnAdd").prop("disabled", true);
						$("#_fnMassInputPart").prop("disabled", true);
						$("#_goSearchSet").prop("disabled", true);
						$("#_goModify").addClass("dpn");
						$("#_goRemove").addClass("dpn");
						$("#_goDoneProcess").addClass("dpn"); // 22.10.26 Q&A 15565 마감버튼 미노출
						$("#_goDetail").prop("disabled", true); // 23.06.12 Q&A 17407 장기/충당재고
						break;
			case "9" : $("#_goProcessConfirm").addClass("dpn");
						$("#_goCancelConfirm").addClass("dpn");
						$("#_goSale").addClass("dpn");
						$("#_goDoneProcess").addClass("dpn");
						$("#_goDeliveryInfo").prop("disabled", true);
						$("#_goPartList").prop("disabled", true);
						$("#_fnAdd").prop("disabled", true);
						$("#_fnMassInputPart").prop("disabled", true);
						$("#_goSearchSet").prop("disabled", true);
						$("#_goModify").addClass("dpn");
						$("#_goRemove").addClass("dpn");
						$("#_goDetail").prop("disabled", true); // 23.06.12 Q&A 17407 장기/충당재고
						break;
				default : $("#_goCancelConfirm").addClass("dpn");
					// 3차 신화면 개발내용. 확정단계 삭제되어 "작성"상태일때 매출처리되도록.
					// $("#_goSale").addClass("dpn"); // 확정이 아닐 시 매출 불가이므로 매출처리 버튼 hide
					$(".confirmAmt").prop("readonly", false);
					$("#_goDeliveryInfo").prop("disabled", false);
					$("#_goPartList").prop("disabled", false);
					$("#_fnAdd").prop("disabled", false);
					$("#_fnMassInputPart").prop("disabled", false);
					$("#_goSearchSet").prop("disabled", false);
					$(".partStatus").prop("disabled", false);
					$("#_goModify").removeClass("dpn");
					$("#_goRemove").removeClass("dpn");
					$("#_goDoneProcess").addClass("dpn"); // 22.10.26 Q&A 15565 마감버튼 미노출
					break;
			}

			if($M.getValue("inout_doc_no") != "") {
				$("#_goReferDetailPopup").removeClass("dpn");
			} else {
				$("#_goReferDetailPopup").addClass("dpn");
			}
		}

		function fnMachineList() {
			// select box 옵션 전체 삭제
			$("#machine_seq option").remove();

			var machineList = ${machineList};
			if(machineList.length > 0) {
				for(item in machineList) {
					// 차대번호의 고객이 보유하고 있는 list 추가
					$("#machine_seq").append(new Option(machineList[item].machine_name, machineList[item].machine_seq));
				}
			}
		}

		function fnInitPage() {
			$("#btnRefer").prop("disabled", true);
			$("#btnOrder").prop("disabled", true);
			var info = ${info}
			var partSaleNoTemp = info.basicInfo.part_sale_no.split("-");
			$M.setValue("part_sale_no_1", partSaleNoTemp[0]);
			$M.setValue("part_sale_no_2", partSaleNoTemp[1]);
			if (info.basicInfo.cust_no != null) {
				isCust = true;
			}
			if (info.basicInfo.part_sale_no != "") {
				isRfq = true;
			}
			$M.setValue("cancel_yn", "N");
			$M.setValue("__s_sale_yn", "Y");

			// VIP판매가 추가 : 고객이 VIP일경우 VIP판매가로 적용.
			$M.setValue("vip_yn", info.basicInfo.vip_yn);
			if (info.basicInfo.vip_yn == 'Y') {
// 				$("#vip_text").html("※ VIP 고객 ※");
				// 단가 헤더 속성값 변경하기
				AUIGrid.setColumnProp(auiGrid, 6, {
					headerText : "단가(VIP)",
					width : 80,
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right",
					headerStyle : "aui-vip-header",
					editable : true,
					editRenderer : {
					    type : "InputEditRenderer",
					    onlyNumeric : true,
					    autoThousandSeparator : true, // 천단위 구분자 삽입 여부 (onlyNumeric=true 인 경우 유효)
					    allowPoint : false // 소수점(.) 입력 가능 설정
					},
		            styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
		                 if(partStatus == "0") {
		                    return "aui-editable";
		                 };
		                 return null;
					}
				});
			} else {
// 				$("#vip_text").html("※ 일반 고객 ※");
				// 단가 헤더 속성값 변경하기
				AUIGrid.setColumnProp(auiGrid, 6, {
					headerText : "단가(일반)",
					width : 80,
					dataType : "numeric",
					formatString : "#,##0",
					headerStyle : "aui-vip-header",
					style : "aui-right",
					editable : true,
					editRenderer : {
					    type : "InputEditRenderer",
					    onlyNumeric : true,
					    autoThousandSeparator : true, // 천단위 구분자 삽입 여부 (onlyNumeric=true 인 경우 유효)
					    allowPoint : false // 소수점(.) 입력 가능 설정
					},
		            styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
		                 if(partStatus == "0") {
		                    return "aui-editable";
		                 };
		                 return null;
					}
				});
			}

			fnSetPartSaleData(info);
		}

		function fnSetPartSaleData(result) {
			 $M.setValue(result.basicInfo);
			 $M.setValue("__s_cust_name", result.basicInfo.cust_name);
			 $M.setValue("__s_cust_no", result.basicInfo.cust_no);
			 $M.setValue("__s_hp_no", result.basicInfo.hp_no);
			 // 22.09.14 문자메세지 참조
			 $M.setValue("__s_part_sale_no", result.basicInfo.part_sale_no);
			 $M.setValue("__s_req_msg_yn", "Y");
		     $M.setValue("__s_menu_seq", ${menu_seq});						//내용참조 메뉴
			 $("#part_sale_status_name").text(result.basicInfo.part_sale_status_name);
			 $("#part_sale_status_cd").text(result.basicInfo.part_sale_status_cd);
			 $("#deal_gubun_name").text("[" + result.basicInfo.deal_gubun_name + "]");
			 $("#deal_gubun_cd").text(result.basicInfo.deal_gubun_cd);
			 if (result.basicInfo.hp_no != null) {
				 $M.setValue("hp_no", result.basicInfo.hp_no);
			 }
			 // 21.09.03 입출금, 수주상태에 따라 수주종류 수정가능여부 추가
			 if(result.basicInfo.dis_yn == "Y") {
				 $("input:radio[name=preorder_yn]").attr("disabled", true);
			 } else {
				 // [정윤수] 23.05.10 Q&A 17407 주문시스템 개선으로 인하여 disabled처리
				 // $("input:radio[name=preorder_yn]").attr("disabled", false);
				 $("input:radio[name=preorder_yn]").attr("disabled", true);
			 }

			 // 21.09.09 대리점일 시 선주문 선택 못하도록 변경
			 if(result.basicInfo.part_sale_type_ca == "A") {
				 $("input:radio[name=part_sale_type_ca]").prop("disabled", true);
				 $("input:radio[name=preorder_yn]").prop("disabled", true);
			 }


			 AUIGrid.setGridData("#auiGrid", result.partList);
			// 부가세 적용
			fnChangeDCAmt();
			fnChangeAmt();
			fnChangeMileAmt();
		}

		// vip 여부 판별 팝업
		function fnVipComparisonPopup() {
			let realVipYn = $('#real_vip_yn').val();
			let vipYn = $('#vip_yn').val();
			let name = $('#cust_name').val();

			let statusCd = $('#part_sale_status_cd').val();

			// 3차 서비스 추가 : VIP 고객이 일반가로 보일 경우 알림
			// 고객이 vip 인 경우 && vip_apply_yn(vip 가격 상태여부)가 N 인경우 && 작성중인 경우
			if(realVipYn == 'Y' && vipYn == 'N' && statusCd == '0') {
				alert(name + " 고객님은 VIP 고객이나 미수로 인하여 현재 단가는 일반가로 보여집니다. 참고바랍니다.");
			}
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
			};
			if(partStatus == "0") {
				gridPros.editable = true;
			} else {
				gridPros.editable = false;
			}
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
					style : "aui-left"
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
				// (Q&A 17407) 3차 신화면 개발로인한 변경. 2023-03-17 김상덕.
				{
					headerText : "가용재고",
					dataField : "able_stock_qty",
					dataType : "numeric",
					formatString : "#,##0",
					width : "5%",
					style : "aui-center aui-popup",
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
					style : "aui-center",
					editable : true,
					editRenderer : {
					      type : "InputEditRenderer",
// 					      onlyNumeric : true, // Input 에서 숫자만 가능케 설정
// 					      min : 1,				// AS-IS에서 반품 처리 시 마이너스 넣음
					      validator : AUIGrid.commonValidator
					},
		            styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
		                 if(partStatus == "0") {
		                    return "aui-editable";
		                 };
		                 return null;
					}
				},
				{
					headerText : "단가",
					dataField : "unit_price",
					width : "8%",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right",
					editable : true,
					editRenderer : {
					    type : "InputEditRenderer",
					    onlyNumeric : true,
					    autoThousandSeparator : true, // 천단위 구분자 삽입 여부 (onlyNumeric=true 인 경우 유효)
					    allowPoint : false // 소수점(.) 입력 가능 설정
					},
		            styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
		                 if(partStatus == "0") {
		                    return "aui-editable";
		                 };
		                 return null;
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
				// [정윤수] 23.05.17 Q&A 17407 단위, 출고일, 미처리량 컬럼 삭제
				// {
				// 	headerText : "출고일",
				// 	dataField : "out_dt",
				// 	width : "8%",
				// 	dataType : "date",
				// 	formatString : "yyyy-mm-dd",
				// 	style : "aui-center",
				// 	editable : false,
				// },
				// {
				// 	headerText : "미처리량",
				// 	dataField : "check_sale_mi_qty",
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
					style : "aui-left",
					editable : true,
		            styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
		                 if(partStatus == "0") {
		                    return "aui-editable";
		                 };
		                 return null;
					}

				},
				{
					dataField : "part_use_yn",
					visible : false
				},
				{
					headerText : "삭제",
					dataField : "removeBtn",
					width : "4%",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
				 			if(partStatus != "0") {
				 				return false;
				 			}
							var isRemoved = AUIGrid.isRemovedById(auiGrid, event.item._$uid);
							if (isRemoved == false) {
								AUIGrid.updateRow(auiGrid, {part_use_yn : "N"}, event.rowIndex);
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
				},
				{
					dataField : "part_return_no",
					visible : false
				},
				{
					dataField : "return_seq_no",
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
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				// 현재고 셀 클릭 시 부품재고상세 팝업 호출
				 if(event.dataField == 'able_stock_qty') {
					var param = {
							"part_no" : event.item["part_no"]
					};
					var popupOption = "";
					$M.goNextPage('/part/part0101p01', $M.toGetParam(param),  {popupStatus : popupOption});
				};
			});

			AUIGrid.bind(auiGrid,"rowStateCellClick",function(event){
				if(event.marker == "removed"){
					if(partStatus != "0") {
		 				return false;
		 			}
					var isRemoved = AUIGrid.isRemovedById(auiGrid, event.item._$uid);
					if (isRemoved == false) {
						AUIGrid.updateRow(auiGrid, {part_use_yn : "N"}, event.rowIndex);
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
				}
			});

			// keyDown 이벤트 바인딩
// 	         AUIGrid.bind(auiGrid, "keyDown",   function(event) {
// 	        	if(partStatus == "0") {
// 		            // 행추가 단축키
// 		            if(event.shiftKey && event.keyCode == 32) {
// 		               fnAddPart();
// 		            }

// 		            if(event.keyCode == 45 || event.keyCode == 32) {
// 		               return false;
// 		            }
// 	        	}
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

		// 행추가
		function fnAddPart() {
			var colIndex = AUIGrid.getColumnIndexByDataField(auiGrid, "part_no");
			fnSetCellFocus(auiGrid, colIndex, "part_no");
			var item = new Object();
    		item.seq_no = "",
    		item.part_no = "",
    		item.part_name = "",
    		item.part_unit = "",
    		item.able_stock_qty = "",
    		item.qty = 1,
    		item.unit_price = "",
    		item.amount = "",
    		item.out_dt = "",
    		item.check_sale_mi_qty = "",
    		item.remark = "",
    		item.storage_name = "",
    		item.removeBtn = "",
    		item.part_use_yn = "Y",
    		item.part_name_change_yn = "N",
    		item.part_mng_cd = "",
    		AUIGrid.addRow(auiGrid, item, 'last');
		}

		// 10행 추가
		function fnAdd() {
			for(var i=0; i<10; i++) {
				var item = new Object();
				item.seq_no = "",
	    		item.part_no = "",
	    		item.part_name = "",
	    		item.part_unit = "",
	    		item.able_stock_qty = "",
	    		item.qty = 1,
	    		item.unit_price = "",
	    		item.amount = "",
	    		item.out_dt = "",
	    		item.sale_mi_qty = "",
	    		item.remark = "",
	    		item.storage_name = "",
	    		item.removeBtn = "",
	    		item.part_use_yn = "Y",
				item.part_name_change_yn = "N",
	    		item.part_mng_cd = "",
	    		AUIGrid.addRow(auiGrid, item, 'last');
			}
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
	    			 's_warning_check' : "Y", // 정비지시서 및 수주에서 부품조회시 alert가 다르게 나오고 리턴받는 list를 다르게 받기위해 생성
// 	    			 's_cust_no' : $M.getValue('cust_no')
	    	};

			openSearchPartPanel('setPartInfo', 'Y', $M.toGetParam(param));
		}

		// 부품조회 창에서 받아온 값
		function setPartInfo(rowArr) {
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
					row.able_stock_qty = rowArr[i].part_able_stock;		// 전체 현재고가 아닌 소속창고의 현재고 => 가용재고로 변경. 2023-03-17 김상덕.
					row.part_use_yn = "Y";

					// VIP판매가 추가 : 고객이 VIP일경우 VIP판매가로 적용.
					if ($M.getValue("vip_yn") == 'Y') {
						row.unit_price = typeof rowArr[i].vip_sale_price == "undefined" ? vipSalePrice : rowArr[i].vip_sale_price;
						row.amount = typeof rowArr[i].vip_sale_vat_price == "undefined" ? vipSaleVatPrice : rowArr[i].vip_sale_vat_price; // vat별도 값 (추후 단가 함수 완료 시 변경)
					} else {
						row.unit_price = typeof rowArr[i].sale_price == "undefined" ? unitPrice : rowArr[i].sale_price;
						row.amount = typeof rowArr[i].sale_price == "undefined" ? unitPrice : rowArr[i].sale_price; // vat별도 값 (추후 단가 함수 완료 시 변경)
					}

					if(rowArr[i].hasOwnProperty("warning_text") && rowArr[i].warning_text != "" && rowArr[i].warning_text != undefined){
						warningText += partNo+" 주의사항 : \n"+rowArr[i].warning_text+"\n\n";
						console.log(warningText);
                    }

					row.part_name_change_yn = rowArr[i].part_name_change_yn;
					row.storage_name = rowArr[i].storage_name;
					row.part_mng_cd = rowArr[i].part_mng_cd;
					AUIGrid.addRow(auiGrid, row, 'last');

					if(rowArr[i].hasOwnProperty("multi_check") && rowArr[i].multi_check == "Y" && warningText != "" && warningText != undefined){
						// 금액, 할인 적용
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
								able_stock_qty : item.part_able_stock,
								qty : 1,
// 								unit_price : item.sale_price,
								unit_price : unitPrice,
								total_amt : event.item.add_qty * item.sale_price,
								part_name_change_yn : item.part_name_change_yn,
								storage_name : item.storage_name,
								part_mng_cd : item.part_mng_cd,
							}, event.rowIndex);

							if(warningText != "" ){
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
			// getColumnValues 삭제된것도 더하는 오류로 주석
			/* var values = AUIGrid.getColumnValues(auiGrid, "amount");
			var valuesQty = AUIGrid.getColumnValues(auiGrid, "qty");
			var totalAmt = sum(values);
			var totalQty = sum(valuesQty); */

			$M.setValue("total_amt", AUIGrid.getNotDeletedColumnValuesSum(auiGrid, "amount"));
			$M.setValue("total_qty", AUIGrid.getNotDeletedColumnValuesSum(auiGrid, "qty"));
		 }

		// 마일리지예상금액 변경 메소드
		function fnChangeMileAmt() {
			var totalAmt = $M.toNum($M.getValue("total_amt"));
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
				var vat = Math.trunc(totalAmt*0.1);
				var calc = {
					sale_amt :  Math.round(totalAmt+vat),
					vat : vat,
					discount_rate : "0"
				}
				$M.setValue(calc);
				return false;
			} else {
				var resultPrice = totalAmt-saveAmt;
				var saveRate = 100 - (resultPrice/totalAmt * 100);
				var vat = Math.round(resultPrice*0.1);
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

		// 고객상세 팝업
		function goCustDetailInfo() {
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
				var poppupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=600, left=0, top=0";
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
		    			isCust = true; isRfq = true;
		    			$("#btnRefer").html("(견)"+result.basicInfo.rfq_no);
		    			AUIGrid.setGridData(auiGrid, result.partList);
		    			console.log(result.machineList)
		    			fnSetData(result);
					}
				}
			);
		}

		function fnSetData(result) {
			var info = result.basicInfo;
			var machineList = result.machineList;
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
					breg_seq : info.breg_seq,
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
					discount_rate : info.discount_rate,
					sale_amt : "0",
					total_amt : "0",
					total_qty : "0",
					// 배송 정보
					receive_name : info.cust_name,
					receive_hp_no : info.hp_no,
					receive_tel_no : info.receive_tel_no,
					invoice_post_no : info.invoice_post_no,
					invoice_addr1 : info.invoice_addr1,
					invoice_addr2 : info.invoice_addr2,
				}
			 $M.setValue(param);

			 if (info.hp_no != null) {
				 $M.setValue("hp_no", info.hp_no);
				 $M.setValue("receive_hp_no", info.hp_no);
			 }

			// 금액, 할인 적용
			fnChangeAmt();
			fnChangeDCAmt();
			fnChangeMileAmt();
		}

		function fnCheckRfq() {
			if (isRfq == true) {
				alert("견적서를 참조한 자료는 부품/고객을 수정할 수 없습니다.");
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
				breg_seq : "",
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
	    	$("#btnChange").children().eq(0).attr('id','btnDeposit');
	    	if($("#btnDeposit").text() == '입금자명변경') {
		    	$("#deposit_name").prop("readonly", false);
		    	$("#deposit_name").off("keydown");
		       	$("#btnDeposit").text("정정");
	    	} else if($("#btnDeposit").text() == '정정') {
	    		if($M.getValue("deposit_name") == "") {
					alert("입금자명을 입력해주세요.");
					$M.getComp("deposit_name").focus();
					return false;
		    	}
		    	var custNo = $M.getValue("cust_no");
		    	var param = {
						deposit_name : $M.getValue("deposit_name")
					}
		    	$M.goNextPageAjax("/cust/cust020101/deposit/"+ custNo, $M.toGetParam(param), {method : 'POST'},
					function(result) {
						console.log(result);
				    	if(result.success) {
				    		$("#btnDeposit").text("입금자명변경");
				    		$("#deposit_name").prop("readonly", true);
						}
					}
				);
	    	}
	    }

	    // 배송정보 팝업
	    function goDeliveryInfo() {
	    	if (isCust == false) {
				alert("고객명을 검색해서 입력해주세요.");
				$("#cust_name").focus();
				return false;
			}
	    	var params = {
	    			cust_no : $M.getValue("cust_no"),
	    			invoice_type_cd : $M.getValue("invoice_type_cd"),
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
	    	};

	    	openDeliveryInfoPanel('setDeliveryInfo', $M.toGetParam(params));
	    }

	    // 배송정보 callback
	    function setDeliveryInfo(data) {
	    	isDelivery = true;
	    	$M.setValue(data);
	    }

	    // 문자발송
		function fnSendSms() {
			var param = {
					  name : $M.getValue("cust_name"),
					  hp_no : $M.getValue("hp_no"),
			}
			openSendSmsPanel($M.toGetParam(param));
		}

		// 문자발송
		function fnSendSms2() {
			  var param = {
			  }
			  	openSendSmsPanel($M.toGetParam(param));
		}

		function fnSendMail() {
			var param = {
	    			 'to' : $M.getValue('email')
	    	  };
	        openSendEmailPanel($M.toGetParam(param));
		}

	    // 매출처리 팝업
	    function goSale() {
			var editData = AUIGrid.getEditedRowItems(auiGrid);

			if(editData.length > 0) {
				alert("변경된 내역이 있습니다.\n수정처리 후 매출처리해주세요.");
				return false;
			}
	    	var param = {
					part_sale_no : $M.getValue("part_sale_no"),
			}
	    	openInoutProcPanel("fnSetInout", $M.toGetParam(param));
	    }

	   function fnSetInout() {
		   location.reload();
	   }

	    // 검증
	    function fnValidation() {
	    	if($M.validation(document.main_form) == false) {
				return false;
			}
			var gridData = AUIGrid.getGridData(auiGrid);
			if(gridData.length <= 0) {
				alert("부품을 추가해주세요.");
				return false;
			}
		}

	    // 수정
		/*
	    function goModify() {
	    	var partSaleNo = $M.getValue("part_sale_no");
	    	if(fnValidation() == false) {
				return false;
			}
	    	var result = confirm("수정 하시겠습니까?");
			if (!result) {
				return false;
	        }
	    	$M.setValue("invoice_type", "SAVE");

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
			var use_yn_arr = [];

			for (var i = 0; i < gridData.length; i++) {
				part_no_arr.push(gridData[i].part_no);
				part_name_arr.push(gridData[i].part_name);
				seq_no_arr.push(gridData[i].seq_no);
				part_unit_arr.push(gridData[i].part_unit);
				stock_qty_arr.push(gridData[i].able_stock_qty);
				qty_arr.push(gridData[i].qty);
				unit_price_arr.push(gridData[i].unit_price);
				amount_arr.push(gridData[i].amount);
				out_dt_arr.push(gridData[i].out_dt);
				sale_mi_qty_arr.push(gridData[i].qty);
				remark_arr.push(gridData[i].remark);
				use_yn_arr.push(gridData[i].part_use_yn);
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
 			$M.setValue(frm, "part_use_yn_str", $M.getArrStr(use_yn_arr, option));

			$M.goNextPageAjax(this_page + "/" + partSaleNo + "/modify", frm, {method : 'POST'},
				function(result) {
					console.log(result);
			    	if(result.success) {
			    		alert("수정이 완료되었습니다.");
			    		location.reload();
					}
				}
			);
	    }
	    */

		// 3차 신화면 확정단계 삭제로 인하여 저장으로 변경
	    // 확정
	    // function goProcessConfirm() {
	    function goModify() {
	    	var partSaleNo = $M.getValue("part_sale_no");
	    	if(fnValidation() == false) {
				return false;
			}
	    	// 21.09.09 재고 부족 부품이 있을 시 해당 수주를 선주문 수주로 변경할지 여부 추가
			var gridData = AUIGrid.getGridData(auiGrid);

			var preValid = false;
			for (var i = 0; i < gridData.length; i++) {
				if (gridData[i].part_use_yn == "Y" && gridData[i].part_no != ""
						&& gridData[i].part_mng_cd != "8" && (gridData[i].able_stock_qty < gridData[i].qty)) {
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
			var use_yn_arr = [];
			var part_return_no_arr = [];
			var return_seq_no_arr = [];

			for (var i = 0; i < gridData.length; i++) {
				part_no_arr.push(gridData[i].part_no);
				part_name_arr.push(gridData[i].part_name);
				seq_no_arr.push(gridData[i].seq_no);
				part_unit_arr.push(gridData[i].part_unit);
				stock_qty_arr.push(gridData[i].able_stock_qty);
				qty_arr.push(gridData[i].qty);
				unit_price_arr.push(gridData[i].unit_price);
				amount_arr.push(gridData[i].amount);
				out_dt_arr.push(gridData[i].out_dt);
				sale_mi_qty_arr.push(gridData[i].qty);
				remark_arr.push(gridData[i].remark);
				use_yn_arr.push(gridData[i].part_use_yn);
				part_return_no_arr.push(gridData[i].part_return_no);
				return_seq_no_arr.push(gridData[i].return_seq_no);
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
 			$M.setValue(frm, "part_use_yn_str", $M.getArrStr(use_yn_arr, option));
			$M.setValue(frm, "part_return_no_str", $M.getArrStr(part_return_no_arr, option));
			$M.setValue(frm, "return_seq_no_str", $M.getArrStr(return_seq_no_arr, option));

 			// var msg = "확정 처리 하시겠습니까?";
 			var msg = "저장하시겠습니까";
 			$M.goNextPageAjaxMsg(msg, this_page + "/" + partSaleNo + "/modify", frm, {method : 'POST'},
				function(result) {
					console.log(result);
			    	if(result.success) {
			    		// alert("확정 처리 되었습니다.");
			    		alert("저장 되었습니다.");
			    		location.reload();
					}
				}
			);
	    }

	    // 확정 취소
	    function goCancelConfirm() {
	    	var partSaleNo = $M.getValue("part_sale_no");
	    	if(fnValidation() == false) {
				return false;
			}
	    	var result = confirm("확정취소를 하시겠습니까?");
			if (!result) {
				return false;
	        }
	    	$M.setValue("invoice_type", "SAVE");
	    	$M.setValue("cancel_yn", "Y");

	    	var frm = document.main_form;
			frm = $M.toValueForm(document.main_form);

			var gridData = AUIGrid.getGridData(auiGrid);

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
			var use_yn_arr = [];

			for (var i = 0; i < gridData.length; i++) {
				part_no_arr.push(gridData[i].part_no);
				part_name_arr.push(gridData[i].part_name);
				seq_no_arr.push(gridData[i].seq_no);
				part_unit_arr.push(gridData[i].part_unit);
				stock_qty_arr.push(gridData[i].able_stock_qty);
				qty_arr.push(gridData[i].qty);
				unit_price_arr.push(gridData[i].unit_price);
				amount_arr.push(gridData[i].amount);
				out_dt_arr.push(gridData[i].out_dt);
				sale_mi_qty_arr.push(gridData[i].qty);
				remark_arr.push(gridData[i].remark);
				use_yn_arr.push(gridData[i].part_use_yn);
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
 			$M.setValue(frm, "part_use_yn_str", $M.getArrStr(use_yn_arr, option));

			$M.goNextPageAjax(this_page + "/" + partSaleNo + "/modify", frm, {method : 'POST'},
				function(result) {
					console.log(result);
			    	if(result.success) {
			    		alert("취소가 완료되었습니다.");
			    		location.reload();
					}
				}
			);
	    }

	    // 마감 처리
	    function goDoneProcess() {
	    	var partSaleNo = $M.getValue("part_sale_no");
	    	if(fnValidation() == false) {
				return false;
			}
	    	var result = confirm("마감처리를 하시면 수정이 불가능합니다.\n그래도 하시겠습니까?");
			if (!result) {
				return false;
	        }
	    	$M.setValue("invoice_type", "DONE");

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
			var use_yn_arr = [];

			for (var i = 0; i < gridData.length; i++) {
				part_no_arr.push(gridData[i].part_no);
				part_name_arr.push(gridData[i].part_name);
				seq_no_arr.push(gridData[i].seq_no);
				part_unit_arr.push(gridData[i].part_unit);
				stock_qty_arr.push(gridData[i].able_stock_qty);
				qty_arr.push(gridData[i].qty);
				unit_price_arr.push(gridData[i].unit_price);
				amount_arr.push(gridData[i].amount);
				out_dt_arr.push(gridData[i].out_dt);
				sale_mi_qty_arr.push(gridData[i].qty);
				remark_arr.push(gridData[i].remark);
				use_yn_arr.push(gridData[i].part_use_yn);
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
 			$M.setValue(frm, "part_use_yn_str", $M.getArrStr(use_yn_arr, option));


			$M.goNextPageAjax(this_page + "/" + partSaleNo + "/modify", frm, {method : 'POST'},
				function(result) {
					console.log(result);
			    	if(result.success) {
			    		alert("마감처리가 완료되었습니다.");
			    		location.reload();
					}
				}
			);
	    }

	    // 삭제
	    function goRemove() {
			var partSaleNo = $M.getValue("part_sale_no");
			var param = {
				"sale_part_sale_no" : $M.getValue("sale_part_sale_no")
			}
			$M.goNextPageAjaxRemove(this_page + "/remove/" + partSaleNo, $M.toGetParam(param), {method : 'POST'},
				function(result) {
					console.log(result);
			    	if(result.success) {
			    		alert("삭제가 완료되었습니다.");
			    		fnClose();
			    		if (opener != null && opener.goSearch) {
							opener.goSearch();
						}
					}
				}
			);
	    }

	    // 매출상세
	    function goReferDetailPopup() {
	    	var param = {
	    			"inout_doc_no" : $M.getValue("inout_doc_no")
			}
			var poppupOption = "";
			$M.goNextPage('/cust/cust0202p01', $M.toGetParam(param), {popupStatus : poppupOption});
	    }

		// 닫기
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

			openSearchLongPartPanel("setPartInfo", "Y", $M.toGetParam(param));
		}

		function goInoutPopup() {
			var popupOption = "";
    		// 입출금전표처리
    		var param = {
    				"cust_no" : $M.getValue("cust_no"),
    				"part_sale_no" : $M.getValue("part_sale_no"),
    				"popup_yn" : "Y"
    		};

			$M.goNextPage('/cust/cust020301', $M.toGetParam(param), {popupStatus : popupOption});
		}

		// 견적서 저장
		function goRfqSave() {
	    	if(fnValidation() == false) {
				return false;
			}

	    	var frm = document.main_form;
			frm = $M.toValueForm(document.main_form);

			var gridData = AUIGrid.getGridData(auiGrid);

			// 견적서
			var part_no_arr = [];
			var part_name_arr = [];
			var qty_arr = [];
			var unit_price_arr = [];
			var remark_arr = [];

			// 수주
			var seq_no_arr = [];
			var part_unit_arr = [];
			var stock_qty_arr = [];
			var amount_arr = [];
			var out_dt_arr = [];
			var sale_mi_qty_arr = [];
			var use_yn_arr = [];

			for (var i = 0; i < gridData.length; i++) {
				part_no_arr.push(gridData[i].part_no);
				part_name_arr.push(gridData[i].part_name);
				qty_arr.push(gridData[i].qty);
				unit_price_arr.push(gridData[i].unit_price);
				remark_arr.push(gridData[i].remark);

				seq_no_arr.push(gridData[i].seq_no);
				part_unit_arr.push(gridData[i].part_unit);
				stock_qty_arr.push(gridData[i].able_stock_qty);
				amount_arr.push(gridData[i].amount);
				out_dt_arr.push(gridData[i].out_dt);
				sale_mi_qty_arr.push(gridData[i].qty);
				use_yn_arr.push(gridData[i].part_use_yn);
			}

			var option = {
					isEmpty : true
			};
 			$M.setValue(frm, "part_no_str", $M.getArrStr(part_no_arr, option));
 			$M.setValue(frm, "part_name_str", $M.getArrStr(part_name_arr, option));
 			$M.setValue(frm, "qty_str", $M.getArrStr(qty_arr, option));
 			$M.setValue(frm, "unit_price_str", $M.getArrStr(unit_price_arr, option));
 			$M.setValue(frm, "remark_str", $M.getArrStr(remark_arr, option));

 			$M.setValue(frm, "seq_no_str", $M.getArrStr(seq_no_arr, option));
 			$M.setValue(frm, "part_unit_str", $M.getArrStr(part_unit_arr, option));
 			$M.setValue(frm, "stock_qty_str", $M.getArrStr(stock_qty_arr, option));
 			$M.setValue(frm, "amount_str", $M.getArrStr(amount_arr, option));
 			$M.setValue(frm, "out_dt_str", $M.getArrStr(out_dt_arr, option));
 			$M.setValue(frm, "sale_mi_qty_str", $M.getArrStr(sale_mi_qty_arr, option));
 			$M.setValue(frm, "part_use_yn_str", $M.getArrStr(use_yn_arr, option));

 			$M.goNextPageAjax(this_page + "/rfqPartSave", frm, {method : 'POST'},
				function(result) {
			    	if(result.success) {
		    			goPartDocPrint(result.rfq_no);
					}
				}
			);
		}

		// 견적서 인쇄
		// 견적서번호 없을 시 견적서 저장 후 인쇄
		// 견적서 번호 있으면 현재 수주 저장 후 일반 인쇄
		function goDocPrint() {
			if($M.getValue("rfq_no") != "") {
		        goRfqSave();
			} else {
				var result = confirm("견적서 저장 후 인쇄가 가능합니다.\n견적서를 저장하시겠습니까?");
				if (!result) {
					return false;
		        } else {
		        	goRfqSave();
		        }
			}
		}

		function goPartDocPrint(rfqNo) {
			var param = {
					rfq_no : rfqNo,
					part_sale_no : $M.getValue("part_sale_no"),
					part_sale_yn : "Y"
			};
			$M.goNextPageAjaxMsg("견적서를 인쇄하시겠습니까?","/rfq/delivery/print", $M.toGetParam(param), {method : 'GET'},
				function(result) {
					openReportPanel('cust/cust0107p02_01.crf','rfq_no=' + rfqNo + '&cust_no=' + $M.getValue("cust_no"));
				}
			);
		}

		// 차주명조회
		function goMachineCust() {
			var popupOption = "";
    		var param = {
    				"s_cust_name" : $M.getValue("cust_name")
    		};

			$M.goNextPage('/comp/comp0309', $M.toGetParam(param), {popupStatus : popupOption});
		}

		// 차대번호
		function setMachineSeqInfo() {

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
					row.stock_qty = list[i].part_able_stock;		// 전체 현재고가 아닌 소속창고의 현재고
					if($M.getValue("vip_yn") == "Y") {
						row.unit_price = list[i].vip_sale_price;
					} else {
						row.unit_price = list[i].sale_price;
					}
					row.amount = list[i].amount
					row.part_name_change_yn = list[i].part_name_change_yn;
					row.storage_name = list[i].storage_name;
					row.part_use_yn = "Y";
					row.part_mng_cd = list[i].part_mng_cd;
					row.remark = typeof list[i].set_name == "undefined" ? list[i].remark : list[i].remark + ' (' + list[i].set_name + ')';

					if(list[i].hasOwnProperty("warning_text") && list[i].warning_text != "" && list[i].warning_text != undefined){
						warningText += partNo+" 주의사항 : \n"+list[i].warning_text+"\n\n";
                    }

					AUIGrid.addRow(auiGrid, row, 'last');
				}

				// 금액, 할인 적용
				fnChangeAmt();
				fnChangeDCAmt();
				fnDiscountInit();
				fnChangeMileAmt();

				if(warningText != ""){
                	window.setTimeout(function(){ alert(warningText) }, 200);
				}
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

	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" name="invoice_type" id="invoice_type" value=""><!-- 저장/확정 구분 -->
<input type="hidden" name="sale_part_sale_no" id="sale_part_sale_no"><!-- 반품대상 수주전표번호 -->
<input type="hidden" name="cust_no" id="cust_no"><!-- 고객번호 -->
<input type="hidden" name="rfq_no" id="rfq_no"><!-- 견적서번호 -->
<input type="hidden" name="ref_key" id="ref_key"><!-- 견적서 참조키 -->
<input type="hidden" name="warehouse_cd" id="warehouse_cd" value="${SecureUser.warehouse_cd != '' ? SecureUser.warehouse_cd : SecureUser.org_code}"><!-- 로그인한 사용자의 조직코드 -->
<input type="hidden" name="org_gubun_cd" id="org_gubun_cd" value="${SecureUser.org_type}"><!-- 로그인한 사용자의 소속 -->
<input type="hidden" name="invoice_type_cd" id="invoice_type_cd" value="05"><!-- 발송구분 -->
<input type="hidden" name="invoice_money_cd" id="invoice_money_cd"><!-- 송장비용방식 -->
<input type="hidden" name="invoice_no" id="invoice_no"><!-- 송장번호 -->
<input type="hidden" name="bill_no" id="bill_no"><!-- 대신화물 송장번호 -->
<input type="hidden" name="invoice_qty" id="invoice_qty">
<input type="hidden" name="receive_tel_no" id="receive_tel_no">
<input type="hidden" name="receive_name" id="receive_name">
<input type="hidden" name="receive_hp_no" id="receive_hp_no">
<input type="hidden" name="invoice_remark" id="invoice_remark">
<input type="hidden" id="part_sale_status_cd" name="part_sale_status_cd">
<input type="hidden" id="deal_gubun_cd" name="deal_gubun_cd">
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
<input type="hidden" name="part_use_yn_str" id="part_use_yn_str">
<input type="hidden" name="cancel_yn" id="cancel_yn">
<input type="hidden" name="real_breg_no" id="real_breg_no">
<input type="hidden" name="breg_seq" id="breg_seq">
<input type="hidden" name="inout_doc_no" id="inout_doc_no">
<input type="hidden" name="vip_yn" id="vip_yn">
<input type="hidden" name="real_vip_yn" id="real_vip_yn">
<!-- <input type="hidden" name="email" id="email"> -->
<!-- 팝업 -->
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
					<h4 class="primary">수주상세</h4>
					<div class="right">
          			 	<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_L"/></jsp:include>
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
							<th class="text-right">수주번호</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-7">
										<input type="text" class="form-control width120px" id="part_sale_no" name="part_sale_no" readonly="readonly">
									</div>
									<div class="col-5">
									<input type="text" class="form-control width120px" id="reg_mem_name" name="reg_mem_name" readonly="readonly">
									</div>
								</div>
							</td>
							<th class="text-right essential-item">수주일자</th>
									<td>
									<div class="form-row inline-pd">
										<div class="col-6">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 width120px calDate partStatus sale-rb" style="width:120px;" disabled="disabled" id="sale_dt" name="sale_dt" dateformat="yyyy-MM-dd" required="required" alt="수주일자" value="">
											</div>
										</div>
										<div class="col-6">
											<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_L"/></jsp:include>
										</div>
										</div>
									</td>
									<th class="text-right">수주구분</th>
									<td>
										<div class="form-check form-check-inline">
											<input class="form-check-input partStatus" type="radio" value="C" id="part_sale_type_c" name="part_sale_type_ca" disabled="disabled">
											<label class="form-check-label" for="part_sale_type_c">고객</label>
										</div>
										<div class="form-check form-check-inline">
											<input class="form-check-input partStatus" type="radio" value="A" id="part_sale_type_a" name="part_sale_type_ca"  disabled="disabled">
											<%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체 --%>
											<%--<label class="form-check-label" for="part_sale_type_a">대리점</label>--%>
											<label class="form-check-label" for="part_sale_type_a">위탁판매점</label>
										</div>
									</td>
							<th class="text-right">수주종류/상태</th>
							<td>
								<div class="form-row inline-pd preorder">
								<div class="col-auto">
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" value="N" id="preorder_n" name="preorder_yn">
										<label class="form-check-label" for="preorder_n">일반</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" value="Y" id="preorder_y" name="preorder_yn">
										<label class="form-check-label" for="preorder_y">선주문</label>
									</div>
								</div>
								<div class="col-auto">/</div>
								<div class="col-auto"><span class="text" id="part_sale_status_name" name="part_sale_status_name"></span>
								<span class="text-danger" id="deal_gubun_name" name="deal_gubun_name"></span></div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">고객명</th>
							<td>
								<div class="form-row inline-pd pr">
									<div class="col-6">
										<input type="text" class="form-control width120px" id="cust_name" name="cust_name" readonly="readonly" alt="고객명">
									</div>
									<jsp:include page="/WEB-INF/jsp/common/commonCustJob.jsp">
		 	                     		<jsp:param name="li_type" value="__cust_dtl#__ledger#__sms_popup#__sms_info#__visit_history#__check_required#__cust_rental_history#__rental_consult_history"/>
			                     	</jsp:include>
								</div>
							</td>
							<th class="text-right">휴대폰</th>
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
								<div class="input-group">
									<input type="text" class="form-control border-right-0 width120px" readonly="readonly" id="breg_rep_name" name="breg_rep_name">
									<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSendSms2();"><i class="material-iconsforum"></i></button>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">배송희망일</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-auto">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 width120px calDate partStatus" disabled="disabled" id="delivery_plan_dt" name="delivery_plan_dt" dateformat="yyyy-MM-dd">
											</div>
									</div>
									<div class="col-auto">
          			 				<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_L"/></jsp:include>
          			 				</div>
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
							<th rowspan="2" class="text-right essential-item">배송지주소</th>
							<td colspan="3" rowspan="2">
								<div class="form-row inline-pd mb7">
									<div class="col-3">
										<select class="form-control partStatus sale-rb" required="required" disabled="disabled" id="invoice_send_cd" name="invoice_send_cd" onChange="javascript:goDeliveryInfo();" alt="배송지 주소">
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
								<input type="text" class="form-control partStatus" disabled="disabled" id="desc_text" name="desc_text">
							</td>
							<th class="text-right">입금자</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-6">
										<input type="text" class="form-control" id="deposit_name" name="deposit_name" readonly="readonly">
									</div>
									<div class="col-5" id="btnChange">
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
								<select class="form-control partStatus" disabled="disabled" id="machine_seq" name="machine_seq">
								</select>
							</td>
							<th class="text-right">불러오기</th>
							<td>
								<button type="button" class="btn btn-primary-gra spacing-sm" onclick="javascript:goReferEstimate();" id="btnRefer">견적서</button>
								<button type="button" class="btn btn-primary-gra spacing-sm" onclick="javascript:goOrder();" id="btnOrder">주문서</button>
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
<!-- /상단 폼테이블 -->
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
										<td class="text-right"><input type="text" class="form-control text-right confirmAmt" readonly="readonly" id="discount_rate" name="discount_rate" value="0" onchange="fnChangeDCRate()" format="decimal"></td>
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
										<td class="text-right"><input type="text" class="form-control text-right confirmAmt" readonly="readonly" id="discount_amt" name="discount_amt" value="0" onchange="fnChangeDCAmt()" format="decimal"></td>
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
<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
					<!-- 버튼 추후 수정 -->
<%-- 						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"> --%>
<%-- 							<jsp:param name="pos" value="BOM_R"/> --%>
<%-- 							<jsp:param name="mem_no" value=""/> --%>
<%-- 							<jsp:param name="show_yn" value="${part_sale_status_cd eq '0' ? 'Y' : 'N'}"/> --%>
<%-- 						</jsp:include> --%>
				</div>
			</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>
