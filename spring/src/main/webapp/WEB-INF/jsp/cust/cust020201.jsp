
<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 부품판매 > 매출처리 > 매출등록 > null
-- 작성자 : 박예진
-- 최초 작성일 : 2020-04-28 09:08:26
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var isDelivery = false;
		var bregCnt = 0;
		
		// var partYn = '${SecureUser.part_org_yn}';
		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGrid();
			$("#_goTransPart").addClass("dpn");
			// authChangeGrid();
		});
		
		// 부품영업부이면 삭제 버튼 노출
//  		function authChangeGrid() {
// 			var hideList = ["remove_btn"];
// 			if(partYn == 'N') {
// 				AUIGrid.hideColumnByDataField(auiGrid, hideList);
// 			}
// 		} 
		
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "row_id",
				// No. 제거
				showRowNumColumn: true,
				editable : false,
				showStateColumn : true,
				showFooter : true,
				footerPosition : "top",
			};
			var columnLayout = [
				{
					headerText : "부품번호", 
					dataField : "item_id", 
					width : "10%",
					style : "aui-center",
					editable : false
				},
				{ 
					headerText : "부품명", 
					dataField : "item_name", 
					width : "24%",
					style : "aui-left",
					editable : false
				},
				{ 
					headerText : "단위", 
					dataField : "unit", 
					width : "6%",
					style : "aui-center",
					editable : false,
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
			            return value == "" || value == null ? "-" : value;
					},
				},
				{ 
					headerText : "현재고", 
					dataField : "stock_qty",  
					dataType : "numeric",
					formatString : "#,##0",
					width : "6%",
					style : "aui-center",
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
					width : "6%",
					editable : false,
					style : "aui-center",
				},
				{ 
					dataField : "old_qty", 
					visible : false
				},
				{ 
					headerText : "단가", 
					dataField : "unit_price", 
					width : "8%", 
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right",
					editable : false
				},
				{ 
					headerText : "금액", 
					dataField : "amt",  
					width : "8%", 
					dataType : "numeric",
					formatString : "#,##0",
					editable : false,
					style : "aui-right",
					expFunction : function(  rowIndex, columnIndex, item, dataField ) { 
						// 수량 * 단가 계산
						return ( item.qty * item.unit_price ); 
					}
				},
				{ 
					headerText : "비고", 
					dataField : "dtl_desc_text", 
					style : "aui-left",
					editable : false
				},
				{ 
					headerText : "미처리량", 
					dataField : "sale_mi_qty", 
					width : "6%",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-center",
					editable : false,
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
			            return value == "" || value == null ? "-" : $M.setComma(value);
					},
				},
// 				{
// 					headerText : "삭제",
// 					dataField : "remove_btn",
// 					width : "6%",
// 					renderer : {
// 						type : "ButtonRenderer",
// 						onClick : function(event) {
// 							var isRemoved = AUIGrid.isRemovedById(auiGrid, event.item.row_id);
// 							if (isRemoved == false) {
// 								AUIGrid.removeRow(event.pid, event.rowIndex);		
// 							} else {
// 								AUIGrid.restoreSoftRows(auiGrid, "selectedIndex"); 
// 							}
// 						}
// 					},
// 					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
// 						return '삭제'
// 					},
// 					style : "aui-center",
// 					editable : false
// 				},
				{
					dataField : "part_no",  
					visible : false
				},
				{
					dataField : "seq_no",  
					visible : false
				},
				{
					dataField : "part_mng_cd",  
					visible : false
				},
			];
			var footerColumnLayout = [ 
				{
					labelText : "합계",
					positionField : "item_id",
					style : "aui-center aui-footer",
					colSpan : 5
				}, 
				{
					dataField : "unit_price",
					positionField : "unit_price",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "amt",
					positionField : "amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setFooter(auiGrid, footerColumnLayout);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
			AUIGrid.bind(auiGrid, "cellEditEnd", function( event ) {
				if(event.dataField == 'qty'){
					var qty = event.value;
					var oldQty = event.item["old_qty"];
					if(qty > oldQty) {
						alert("발주수량보다 큰 수량을 입력할 수 없습니다.\n" + oldQty + "보다 작거나 같은 수량을 입력하십시오.");
						AUIGrid.updateRow(auiGrid, { "qty" : oldQty }, event.rowIndex);
						return false;
					}
				}
			});
			
			// 에디팅 정상 종료 이벤트 바인딩
			AUIGrid.bind(auiGrid, "cellEditEndBefore", auiCellEditHandler);
			// 에디팅 정상 종료 이벤트 바인딩
			AUIGrid.bind(auiGrid, "cellEditEnd", auiCellEditHandler);
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
			};
		}
		
		// 입출금전표처리
		function goInoutPopup() {
			var url = '/cust/cust020301?cust_no=' + $M.getValue("cust_no");
			var title = $("#_goInoutPopup").text();
			parent.goContent(title, url);
		}
		
		// 수주참조
		function goSaleReferPopup() {
			var params = {
					"parent_js_name" : "fnSetPartInfo"
			};
			var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1000, height=400, left=0, top=0";
			$M.goNextPage('/cust/cust0202p02', $M.toGetParam(params), {popupStatus : popupOption});
		}
		
		// 수주참조 시 데이터 콜백
		function fnSetPartInfo(data) {
			fnSearchInoutInfo('PART_SALE', data.part_sale_no);
		}
		
		
		// 정비참조
		function goReportReferPopup() {
			var params = {
					"parent_js_name" : "fnSetReportInfo",
					"s_job_status_cd" : "7"
			};
			var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1000, height=400, left=0, top=0";
			$M.goNextPage('/cust/cust0202p03', $M.toGetParam(params), {popupStatus : popupOption});
		}
		
		// 정비참조 시 데이터 콜백
		function fnSetReportInfo(data) {
			fnSearchInoutInfo('JOB_REPORT', data.job_report_no);
		}
		
		// 렌탈참조
		function goRentalReferPopup() {
			var params = {
					"parent_js_name" : "fnSetRentalInfo"
			};
			var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1000, height=400, left=0, top=0";
			$M.goNextPage('/cust/cust0202p05', $M.toGetParam(params), {popupStatus : popupOption});
		}
		
		// 렌탈참조 시 데이터 콜백
		function fnSetRentalInfo(data) {
			fnSearchInoutInfo('RENTAL', data.rental_doc_no);
		}
		
		// 참조 후 실행
		function fnSearchInoutInfo(searchType, searchKey) {
			var param = {
					"search_type" : searchType,
					"search_key" : searchKey
			}
			$M.goNextPageAjax(this_page + "/info", $M.toGetParam(param), {method : 'GET'},
				function(result) {
		    		if(result.success) {
		    			// 초기화
		    			fnInit();
		    			
		    			$M.setValue(result.bean);
		    			AUIGrid.setGridData("#auiGrid", result.list);
		    			fnSetPage(result.bean);
					}
				}
			);
		}
		
		function fnSetPage(data) {
			// 고객에 매핑된 사업자가 다수인 경우 처리
			$M.setValue("check_breg_no", data.breg_no);
// 			if($M.getValue("check_breg_yn") == "Y") {
// 				var text = data.breg_no + ' ' + '외' + ' ' + data.count_breg_no;
// 				$M.setValue("check_breg_no", text);
// 				$("#check_breg_no").css("color", "red");
// 			} else {
// 				$M.setValue("check_breg_no", data.breg_no);
// 			}
				// 부가구분이 합계면 합산발행만 표시
				// if ($M.getValue("add_ut") == "T") {
				// 	$(".add-u").addClass("dpn");
// 				$("#vat_treat_s").prop("checked", true);
// 				} else {
// 					$(".add-u").removeClass("dpn");
// 				$("#vat_treat_y").prop("checked", true); 	// 세금계산서 디폴트 요청
// 				}

			if (data.required_yn == "Y") {
				alert("거래시 필수사항을 확인하십시오.");
				// 거래시 필수확인사항 조회
				fnCheckRequired();
			}

			if ($M.getValue("inout_doc_type_cd") == "05" || $M.getValue("inout_doc_type_cd") == "07") {
				$("#_goTransPart").removeClass("dpn");
			} else {
				$("#_goTransPart").addClass("dpn");
			}

			// 나중에 지울 것
			// 부품일괄이동요청 버튼 우선 hide
// 			$("#_goTransPart").addClass("dpn");

			// VIP 판매가 관련 추가
			if (data.vip_yn == "Y") {
				// 단가 헤더 속성값 변경하기
				AUIGrid.setColumnProp(auiGrid, 6, {
					headerText: "단가(VIP)",
					width: "8%",
					headerStyle: "aui-vip-header",
					dataType: "numeric",
					formatString: "#,##0",
					style: "aui-right",
					editable: false
				});
			} else {
				// 단가 헤더 속성값 변경하기
				AUIGrid.setColumnProp(auiGrid, 6, {
					headerText: "단가(일반)",
					width: "8%",
					headerStyle: "aui-vip-header",
					dataType: "numeric",
					formatString: "#,##0",
					style: "aui-right",
					editable: false
				});
			}

			//  21.09.09 선주문 전표 표시 추가
			if ($M.getValue("preorder_yn") == "Y") {
				$("#preorder_inout").text("※선주문전표");
			} else {
				$("#preorder_inout").text("");
			}

			// 3차 Q&A 14336 2022-11-08 김상덕
			// 수정계산서는 마이너스 일때만 활성
				if (data.doc_amt < 0) {
					$("#vat_treat_y").prop("disabled", true);
					$("#vat_treat_f").prop("disabled", false);
				} else {
					$("#vat_treat_y").prop("disabled", false);
					$("#vat_treat_f").prop("disabled", true);
				}
		}
		
		 // 거래시필수확인사항
	    function fnCheckRequired() {
			 var param = {
	  	 		"cust_no" : $M.getValue("cust_no")
	  		 };
			 openCheckRequiredPanel('setCheckRequired', $M.toGetParam(param));
	    }
		
		// 사업자변경
		function goBregInfoPopup() {
			fnSearchBregSpec();
		}

		// 사업자명세조회
	    function fnSearchBregSpec() {
	    	if($M.getValue("cust_no") == "") {
	    		alert("매출처리할 건을 참조 후 이용해주세요.");
	    		$(".vat_treat").prop('checked', false);
	    		return false;
	    	}
	    	var param = {
	    			 's_cust_no' : $M.getValue('cust_no')
	    	};
	    	openSearchBregSpecPanel('fnSetBregSpec', $M.toGetParam(param));
	    }
		
		// 사업자명세 정보 call back
	    function fnSetBregSpec(row) {
			if(row.new_yn == "Y") {
				bregCnt++;
			}
	        var param = {
	        	"breg_name" : row.breg_name,
	        	"real_breg_no" : row.real_breg_no,
// 	        	"check_breg_no" : row.breg_no + ' ' + '외' + ' ' + ($M.toNum($M.getValue("count_breg_no")) + $M.toNum(bregCnt)),
	        	"check_breg_no" : row.breg_no,
	        	"breg_no" : row.breg_no,
	        	"breg_rep_name" : row.breg_rep_name,
	        	"breg_cor_type" : row.breg_cor_type,
	        	"breg_cor_part" : row.breg_cor_part,
	        	"breg_seq" : row.breg_seq,
	        	"biz_post_no" : row.biz_post_no,
	        	"biz_addr1" : row.biz_addr1,
	        	"biz_addr2" : row.biz_addr2,
	        	"biz_addr" : row.biz_post_no + ' ' + row.biz_addr1 + ' ' + row.biz_addr2 
	        };

	        $M.setValue(param);
	        
// 	        var bregNo = row.breg_no;
// 	        console.log(bregNo.length);
// 	        if(bregNo.length == 13) {
// 	        	var param = {
// 	        			"breg_seq" : row.breg_seq
// 	        	}
// 	        	$M.goNextPageAjax(this_page + "/breg", $M.toGetParam(param), {method : 'GET'},
//     				function(result) {
//     		    		if(result.success) {
//     		    			$M.setValue("check_breg_no", result.info.breg_no);
//     					}
//     				}
//     			);
// 	        }
	        
	     	
	    }
   		
		// 배송정보 팝업
	    function goDeliveryInfo() {
	    	if ($M.getValue("cust_no") == "") {
				alert("매출처리할 건을 참조 후 이용해주세요.");
				$M.setValue("invoice_send_cd", "");
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
	    			bill_no : $M.getValue("bill_no"), //대신화물 송장번호
	    			
	    	};
	    	
	    	openDeliveryInfoPanel('setDeliveryInfo', $M.toGetParam(params));
	    }
	    
	    // 배송정보 callback
	    function setDeliveryInfo(data) {
	    	$M.setValue(data);
	    	$M.setValue("invoice_addr", data.invoice_post_no + ' ' + data.invoice_addr1 + ' ' + data.invoice_addr2);
	    }
	    
	    // 저장
		function goSave() {
			var frm = document.main_form;
	     	var gridData = AUIGrid.getGridData(auiGrid);
			
			if($M.getValue("inout_org_code") == "") {
				alert("처리센터는 필수입력입니다.");
				return false;
			}
			if ($M.getValue("invoice_send_cd") == "") {
				alert("배송정보설정으로 발송구분을 설정해주십시오.");
				return false;
			}
			if ($M.validation(frm) === false) {
				return;
			}
			;

			/*
			* (Q&A14336) 2022-12-08 김상덕
			* [매출 등록], [매출 상세 수정]
			* 세금계산서(Y), 합산(S), 수정(F) : 사업자번호 있어야함, 미수 상관없음
			* 카드(C), 현금영수증(A) : 사업자번호 유무 상관없음, 미수금 상관없음
			* 무증빙(N) : 사업자번호 유무 상관없음, 과입금만큼만 매출발행 가능
			* */
			var taxArr = ["Y", "S", "F"];
			var checkedVatTreatCd = $M.getValue("vat_treat_cd");
			if (taxArr.includes(checkedVatTreatCd)) {
				if ($M.getValue("breg_no") == "") {
					alert("사업자번호 및 업체명을 확인 후 처리 하세요.");
					return false;
				}
			} else if (checkedVatTreatCd == "N") {
				var calcAmt = 0;
				calcAmt = $M.toNum($M.getValue("total_amt")) + $M.toNum($M.getValue("misu_amt"));
				if (calcAmt > 0) {
					alert("미수금을 확인하십시오.\n미 사업자고객의 경우 입금처리 후 매출처리 하시기 바랍니다.");
					return false;
				}
			}

			frm = $M.toValueForm(document.main_form);

			var seq_no_arr = [];
			var item_id_arr = [];
			var item_name_arr = [];
			var unit_arr = [];
			var stock_qty_arr = [];
			var qty_arr = [];
			var unit_price_arr = [];
			var amt_arr = [];
			var storage_name_arr = [];
			var current_all_qty_arr = [];
			var desc_text_arr = [];

			// 재고없는 부품 제외할지 여부
			var outYn = "N";
			
	     	// 수주일때 선주문이 아닐 시 재고 확인
	     	if($M.getValue("preorder_yn") != "Y" && $M.getValue("inout_doc_type_cd") == "05") {
	     		var qtyCnt = 0;
	     		var qtyName = "";
	            var partNoObj = {};
	     		
	     		for(var i = 0; i < gridData.length; i++) {
		            var partNo = gridData[i].part_no;
		            var qty = $M.toNum(gridData[i].qty);
		            var tempPartNoObj = $.extend({
		            	qty : 0
		            	, over_yn : 'N'
		            }, partNoObj[partNo]);
		            
		            var tempQty = $M.toNum($M.nvl(tempPartNoObj.qty, 0));
		            var tempSumQty = tempQty + qty;
		            var tempOverYn = 'N';
		            
		            // 현재고가 수량보다 작을 시 체크(중복 부품 포함)
		            if ($M.toNum(gridData[i].stock_qty) < tempSumQty) {
		            	tempOverYn = 'Y'
		            }
		            var tempObj = {
						qty : tempSumQty
						, over_yn : tempOverYn
		            }
		            partNoObj[partNo] = tempObj;
	     		}
	     		
	     		for(var i = 0; i < gridData.length; i++) {
	     			var partNo = gridData[i].part_no;
	     			var partObj = partNoObj[partNo];
	     			
	     			if(partObj.over_yn == "Y" && gridData[i].part_mng_cd != "8") {
	     				qtyCnt++;
	     				if(qtyCnt == 1) {
	     					qtyName = gridData[i].item_id;
	     				}
	     			}
	     		}
	     		
	     		if(qtyCnt > 0) {
	     			var msg = "";
					if(qtyCnt == gridData.length) {
						alert("재고 부족으로 처리할 부품이 없습니다.");
						return false;
	     			} else if(qtyCnt == 1) {
	    				msg = confirm(qtyName + "건" + "이 재고 부족으로 매출을 낼 수 없습니다.\n해당 부품을 제외하고 매출을 진행하시겠습니까?");
	     			} else {
	    				msg = confirm(qtyName + " 외 " + $M.toNum(qtyCnt-1) + "건" + "이 재고 부족으로 매출을 낼 수 없습니다.\n해당 부품을 제외하고 매출을 진행하시겠습니까?");
	     			}
	    			if(msg) {
	    				outYn = "Y";
	    			} else {
	    				return false;
	    			}
	     		}
	     	// Q&A 12604. 수주일때만 선주문 판단하도록 수정 210913 김상덕
	     	}
			// [정윤수] 23.05.10 Q&A 17407 주문시스템 개선으로 인하여 선주문 판단안함
			//  else if ($M.getValue("preorder_yn") != "N" && $M.getValue("inout_doc_type_cd") == "05"){
	     	// 	var msg = confirm("선 주문으로 매출 처리하시겠습니까?");
	     	// 	if(!msg) {
	     	// 		return false;
	     	// 	}
	     	// }
	     	
			for (var i = 0; i < gridData.length; i++) {
				if(outYn == "Y") {
					var partNo = gridData[i].part_no;
	     			var partObj = partNoObj[partNo];
					if(partObj.over_yn == "N"|| gridData[i].part_mng_cd == "8") {
						seq_no_arr.push(gridData[i].seq_no);
						item_id_arr.push(gridData[i].item_id);
						item_name_arr.push(gridData[i].item_name);
						unit_arr.push(gridData[i].unit);
						stock_qty_arr.push(gridData[i].stock_qty);
						qty_arr.push(gridData[i].qty);
						unit_price_arr.push(gridData[i].unit_price);
						amt_arr.push(gridData[i].amt);
						storage_name_arr.push(gridData[i].storage_name);
						current_all_qty_arr.push(gridData[i].current_all_qty);
						desc_text_arr.push(gridData[i].dtl_desc_text);
	     			}
				} else {
					seq_no_arr.push(gridData[i].seq_no);
					item_id_arr.push(gridData[i].item_id);
					item_name_arr.push(gridData[i].item_name);
					unit_arr.push(gridData[i].unit);
					stock_qty_arr.push(gridData[i].stock_qty);
					qty_arr.push(gridData[i].qty);
					unit_price_arr.push(gridData[i].unit_price);
					amt_arr.push(gridData[i].amt);
					storage_name_arr.push(gridData[i].storage_name);
					current_all_qty_arr.push(gridData[i].current_all_qty);
					desc_text_arr.push(gridData[i].dtl_desc_text);
				}
			}
			
			// 선주문에 따라 count_remark 세팅도 변경
	     	var gridLength = item_name_arr.length - 1;
	     	
	     	if ( gridLength >= 0 ) {
	     		var partName = item_name_arr[0];
	     		if(gridLength <= 0) {
		     		$M.setValue("count_remark", partName);
		     	} else {
		     		$M.setValue("count_remark", partName + " 외 " + gridLength + "건");
		     	}
	     	}
			
			var option = {
					isEmpty : true
			};

			$M.setValue(frm, "seq_no_str", $M.getArrStr(seq_no_arr, option));
 			$M.setValue(frm, "item_id_str", $M.getArrStr(item_id_arr, option));
 			$M.setValue(frm, "item_name_str", $M.getArrStr(item_name_arr, option));
 			$M.setValue(frm, "unit_str", $M.getArrStr(unit_arr, option));
 			$M.setValue(frm, "stock_qty_str", $M.getArrStr(stock_qty_arr, option));
 			$M.setValue(frm, "qty_str", $M.getArrStr(qty_arr, option));
 			$M.setValue(frm, "unit_price_str", $M.getArrStr(unit_price_arr, option));
 			$M.setValue(frm, "amt_str", $M.getArrStr(amt_arr, option));
 			$M.setValue(frm, "storage_name_str", $M.getArrStr(storage_name_arr, option));
 			$M.setValue(frm, "current_all_qty_str", $M.getArrStr(current_all_qty_arr, option));
 			$M.setValue(frm, "dtl_desc_text_str", $M.getArrStr(desc_text_arr, option));

	     	var msg = "";
	     	
	     	switch($M.getValue("vat_treat_cd")) {
	     	case "Y" : msg = confirm("매출전표 및 세금계산서를 발행하시겠습니까?");
	     			break;
	     	case "N" : msg = confirm("무증빙처리 하시겠습니까?");
	     			break;
	     	// case "R" : msg = confirm("사업자를 추후에 등록하고 매출처리 하시겠습니까?");
	     	// 		break;
	     	case "S" : msg = confirm("합산발행 매출처리 하시겠습니까?");
	     			break;
			case "F" : msg = confirm("수정계산서 매출처리 하시겠습니까?");
					break;
			case "C" : msg = confirm("카드매출처리 하시겠습니까?");
					break;
			case "A" : msg = confirm("현금영수증처리 하시겠습니까?");
					break;
	     	default : alert("세금계산서 처리구분을 반드시 선택하십시오.");
	     			return false;
	     			break;
	     	}
	     	
	     	if(!msg) {
	     		return false;
	     	}
// 	     	$M.setValue("breg_no", $M.getValue("check_breg_no"));

			// 부품 수량이 0인 row가 있으면 confirm창 띄우기 2021-06-28 황빛찬
			var qtyValid = false;
			for (var i = 0; i < qty_arr.length; i++) {
				if (qty_arr[i] == 0) {
					qtyValid = true;	
				}
			}
			
			if (qtyValid) {
				if (confirm("부품 입력수량이 0인 항목(부품)이 있습니다. \n계속 진행 하시겠습니까 ?") == false) {
					return false;
				}
			}
	     	
			$M.goNextPageAjax(this_page + "/save", frm, {method : 'POST', timeout : 60 * 60 * 1000},
				function(result) {
			    	if(result.success) {
			    		fnList();
			    		var popupOption = "";
			    		// 매출처리(수주) 팝업 오픈
			    		var param = {
			    				"inout_doc_no" : result.inout_doc_no 
			    		};
						$M.goNextPage('/cust/cust0202p04', $M.toGetParam(param), {popupStatus : popupOption});
// 						fnAfterInout(result.inout_doc_no);
						$M.setValue("inout_doc_no", result.inout_doc_no);
						goAfterInout(result.inout_doc_no);
					} else {
						if(result.dupYn == "Y") {
							$M.goNextPageAjax("/cust/cust020201/inoutDocCheck", frm, {method : 'POST'},
								function(result) {
							    	if(result.success) {
							    		fnList();
							    		var popupOption = "";
							    		// 매출처리 상세로 페이지 이동
							    		var param = {
							    				"inout_doc_no" : result.inout_doc_no
							    		};
										$M.goNextPage('/cust/cust0202p01', $M.toGetParam(param), {popupStatus : popupOption});
									}
								}
							);
						}
					}
				}
			);
		}
	    
		// 초기화
		function fnInit() {
			bregCnt = 0;
			var param = {
				preorder_yn : "",
				cust_name : "",
				cust_no : "",
				cust_hp_no : "",
				cust_fax_no : "",
				breg_name : "",
				breg_no : "",
				real_breg_no : "",
				breg_seq : "",
				breg_rep_name : "",
				breg_cor_type : "",
				breg_cor_part : "",
				biz_post_no : "",
				biz_addr1 : "",
				biz_addr2 : "",
				biz_addr : "",
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
				invoice_addr2 : "",
				invoice_addr : "",
				count_breg_no : "",
				check_breg_yn : "",
				add_ut : "",
				inout_doc_type_cd : "",
				check_breg_no : "",
				deposit_name : "",
				doc_amt : "0",
				inout_org_code : "",
				discount_amt : "0",
				apply_discount_amt : "0",
				vat_amt : "0",
				total_amt : "0",
				desc_text : "",
				last_memo : "",
				reference_no : "",
				part_sale_no : "",
				job_report_no : "",
				rental_doc_no : "",
				misu_amt : "0",
				max_misu_amt : "0",
				sale_mem_no : "",
				sale_mem_name : "",
				email : "",
				deposit_plan_dt : "",
				
			}
			$M.clearValue();
			// 선택사항 그리드 초기화
			AUIGrid.setGridData(auiGrid, []);
			$(".vat_treat").prop("checked", false);
			$M.setValue(param);
			
		}
	    
		// 입금자명 변경
	    function goChangeDeposit() {
	    	if ($M.getValue("cust_no") == "") {
				alert("매출처리할 건을 참조 후 이용해주세요.");
				return false;
			}
	    	var custNo = $M.getValue("cust_no");
	    	var param = {
					deposit_name : $M.getValue("deposit_name")
				}
	    	$M.goNextPageAjaxSave("/cust/cust020101/deposit/" + custNo, $M.toGetParam(param), {method : 'POST'},
					function(result) {
						console.log(result);
				    	if(result.success) {
						}
					}
				);
	    }
	    
		function fnCalcCoupon() {
			if($M.toNum($M.getValue("coupon_balance_amt")) < $M.toNum($M.getValue("discount_amt"))) {
				alert("쿠폰 잔액보다 더 큰 쿠폰 금액을 사용할 수 없습니다.");
				$M.setValue("discount_amt", 0);
			}

			var applyDiscountAmt = $M.toNum($M.getValue("doc_amt"))-$M.toNum($M.getValue("discount_amt"))-$M.toNum($M.getValue("use_mile_amt"));
			$M.setValue("apply_discount_amt", applyDiscountAmt);
			var vatAmt = $M.toNum($M.getValue("apply_discount_amt"))*0.1;
			$M.setValue("vat_amt", vatAmt);
			var totalAmt = $M.toNum($M.getValue("apply_discount_amt"))+$M.toNum($M.getValue("vat_amt"));
			$M.setValue("total_amt", totalAmt);
		}

		function fnCalcMile() {
			var mileAmt = $M.toNum($M.getValue("mile_balance_amt"));
			if(mileAmt < $M.toNum($M.getValue("use_mile_amt"))) {
				alert("마일리지 잔액보다 더 큰 마일리지 금액을 사용할 수 없습니다.");
				$M.setValue("use_mile_amt", 0);
			}

			var applyDiscountAmt = $M.toNum($M.getValue("doc_amt")) - $M.toNum($M.getValue("discount_amt")) - $M.toNum($M.getValue("use_mile_amt"));
			$M.setValue("apply_discount_amt", applyDiscountAmt);
			var vatAmt = $M.toNum($M.getValue("apply_discount_amt"))*0.1;
			$M.setValue("vat_amt", vatAmt);
			var totalAmt = $M.toNum($M.getValue("apply_discount_amt"))+$M.toNum($M.getValue("vat_amt"));
			$M.setValue("total_amt", totalAmt);
		}
		
		function fnCalcVat() {
			var applyDiscountAmt = $M.toNum($M.getValue("doc_amt"))-$M.toNum($M.getValue("discount_amt"))-$M.toNum($M.getValue("use_mile_amt"));
			$M.setValue("apply_discount_amt", applyDiscountAmt);
			var vatAmt = $M.toNum($M.getValue("vat_amt"));
			$M.setValue("vat_amt", vatAmt);
			var totalAmt = $M.toNum($M.getValue("apply_discount_amt"))+$M.toNum($M.getValue("vat_amt"));
			$M.setValue("total_amt", totalAmt);
		}
		
		function fnList() {
			history.back();
		}
		
		function fnAfterInout(inoutDocNo) {
			
			var param = {
					"inout_doc_no" : inoutDocNo
			}
						
			$M.goNextPageAjax("/cust/cust020201/afterInout", $M.toGetParam(param), {method : 'POST'},
				function(result) {
			    	if(result.success) {
			    		var info = result.info;
			    		
			    		if(info.vat_treat_cd == "Y") {
			    			var data = [
			    				{title : '세금계산서', name : '', type : 'myTitle', suffix : '', width : '100%', title_yn : true},
			    				{title : '발행번호', name : '', type : 'textD', suffix : '', width : '120px', value : ""},
			    				{title : '거래처', name : 'breg_name', type : 'textD', suffix : '', 'width' : '60%', value : info.breg_name},
			    				{title : '대표자명', name : 'breg_rep_name', type : 'textD', suffix : '', 'width' : '60%', value : info.breg_rep_name},
			    				{title : '물품대', name : 'taxbill_amt', type : 'numberD', suffix : '원', 'width' : '40%', value : info.taxbill_amt},
			    				{title : '발급구분', name : 'taxbill_type_cd', type : 'selectbox', 'width' : '80%', required : true},
			    				{title : '수령구분', name : 'taxbill_send_cd', type : 'selectboxD', 'width' : '80%', value : info.taxbill_send_cd, value_name : info.taxbill_send_name},
			    				{title : '인쇄자', name : 'kor_name', type : 'textD', suffix : '', 'width' : '60%', value : "${SecureUser.kor_name}"},
			    				{title : '거래명세서', name : '', type : 'myTitle', suffix : '', width : '100%', title_yn : true},
			    				{title : '전표번호', name : 'print_inout_doc_no', type : 'textD', suffix : '', width : '120px', value : info.inout_doc_no},
			    				{title : '고객명', name : 'print_breg_name', type : 'textD', suffix : '', 'width' : '60%', value : info.breg_name},
			    				{title : '대표자명', name : 'print_breg_rep_name', type : 'textD', suffix : '', 'width' : '60%', value : info.breg_rep_name},
			    				{title : '금액', name : 'doc_amt', type : 'numberD', suffix : '원', 'width' : '60%', value : info.doc_amt},
			    				{title : '인쇄자', name : 'kor_name', type : 'textD', suffix : '', 'width' : '60%', value : "${SecureUser.kor_name}"},
			    				{title : '입금예정처리', name : '', type : 'myTitle', suffix : '', width : '100%', title_yn : true},
			    				{title : '전표번호', name : 'inout_doc_no', type : 'textD', suffix : '', width : '120px', value : info.inout_doc_no},
			    				{title : '미수금', name : 'ed_misu_amt', type : 'numberD', suffix : ' 원', 'width' : '60%', value : info.ed_misu_amt},
			    				{title : '입금예정일', name : 'deposit_plan_dt', type : 'date', suffix : '', 'width' : '60%', required : true},
			    				{title : '처리자', name : '', type : 'textD', suffix : '', 'width' : '60%', value : "${SecureUser.kor_name}"},
			    			];			    			
			    		} else {
			    			var data = [
			    				{title : '거래명세서', name : '', type : 'myTitle', suffix : '', width : '100%', title_yn : true},
			    				{title : '전표번호', name : '', type : 'textD', suffix : '', width : '120px', value : info.inout_doc_no},
			    				{title : '고객명', name : 'print_breg_name', type : 'textD', suffix : '', 'width' : '60%', value : info.breg_name},
			    				{title : '대표자명', name : 'print_breg_rep_name', type : 'textD', suffix : '', 'width' : '60%', value : info.breg_rep_name},
			    				{title : '금액', name : 'doc_amt', type : 'numberD', suffix : '원', 'width' : '60%', value : info.doc_amt},
			    				{title : '인쇄자', name : 'kor_name', type : 'textD', suffix : '', 'width' : '60%', value : "${SecureUser.kor_name}"},
			    				{title : '입금예정처리', name : '', type : 'myTitle', suffix : '', width : '100%', title_yn : true},
			    				{title : '전표번호', name : 'inout_doc_no', type : 'textD', suffix : '', width : '120px', value : info.inout_doc_no},
			    				{title : '미수금', name : 'ed_misu_amt', type : 'numberD', suffix : ' 원', 'width' : '60%', value : info.ed_misu_amt},
			    				{title : '입금예정일', name : 'deposit_plan_dt', type : 'date', suffix : '', 'width' : '60%', required : true},
			    				{title : '처리자', name : '', type : 'textD', suffix : '', 'width' : '60%', value : "${SecureUser.kor_name}"},
			    			]
			    		}
			    		
			    		fnInputDialogInout(data, function(result){
			    			alert("gd");
			    			alert(result);
			    			console.log(result);
			 				return true;
						});
					}
				}
			);
		}
   		  
		function goAfterInout(inoutDocNo) {
			var param = {
					"inout_doc_no" : inoutDocNo
			}
						
			$M.goNextPageAjax("/cust/cust020201/afterInout", $M.toGetParam(param), {method : 'POST'},
				function(result) {
			    	if(result.success) {
			    		var info = result.info;
			    		$M.setValue(info);
						$M.setValue("print_breg_name", info.breg_name);
						$M.setValue("print_breg_rep_name", info.breg_rep_name);
						$M.setValue("print_inout_doc_no", info.inout_doc_no);
						$M.setValue("taxbill_type_cd", "2");	// 청구를 기본값으로
						
						if("${inputParam.early_return_yn}" == "Y") {
							$M.setValue("taxbill_send_cd", "5");
						}
						
						if(info.vat_treat_cd != "Y" && "${inputParam.early_return_yn}" != "Y") {
							$(".vat-treat-y").hide();
							var vwidth = document.getElementById('main_form').clientWidth;
							var vheight = document.getElementById('main_form').clientHeight + 90;  
							window.resizeTo(vwidth,vheight);
						} else {
							$(".vat-treat-y").show();
						}
					}
				}
			);
			$M.goNextPageLayerDiv('open_layer_passFind');
		}
		
		
 		// 저장
		function goChangeSave() {
	     	if($M.getValue("vat_treat_cd") == "Y") {
	     		if($M.getValue("taxbill_type_cd") == "") {
	     			alert("발급구분은 필수입력입니다.");
	     			return false;
	     		}
	     	}
	     	
			if($M.validation(document.main_form) === false) {
	     		return;
	     	};
	     	
			frm = $M.toValueForm(document.main_form);
			
			var msg = "";
			
			if($M.getValue("vat_treat_cd") == "Y") {
				msg = confirm("세금계산서 발행 및 미수금 입금예정일을 처리하시겠습니까?");
			} else {
				msg = confirm("미수금 입금예정일을 처리하시겠습니까?");
			}
			if(!msg) {
				return false;
		    }

			$M.goNextPageAjax("/cust/cust0202p04/save", frm, {method : 'POST'},
				function(result) {
			    	if(result.success) {
			    		fnClose();
			    		alert("정상 처리되었습니다.");
			    		
			    		// 매출처리 팝업으로 저장 시 페이지 닫아줌
			    		if("${inputParam.popup_yn}" != "Y") {
				    		opener.location.reload();
			    		} else {
			    			opener.fnDetail();
			    		}
					}
				}
			);
		}
	
		function fnClose() {
			window.close();
		}
		
		// 거래명세서 출력
        function goDocPrint() {
        	openReportPanel('cust/cust0202p01_01.crf','inout_doc_no=' + $M.getValue("inout_doc_no"));
        }
		
     // 부품일괄이동요청
		function goTransPart() {
			var params = {};
			var popupOption = "";
			switch($M.getValue("inout_doc_type_cd")) {
			case "05" : params = {
							"search_key" : $M.getValue("part_sale_no"),
							"search_type" : "PART_SALE"
						};
				break;
			case "07" : params = {
						"search_key" : $M.getValue("job_report_no"),
						"search_type" : "JOB_REPORT"
						};
				break;
			}
				
			$M.goNextPage('/comp/comp0606', $M.toGetParam(params), {popupStatus : popupOption});
		}
     
		// 처리센터 변경 시 재고 재조회
	    function fnSetPartQty() {
			if($M.getValue("inout_doc_type_cd") == "05") {
				var param = {
						"part_sale_no" : $M.getValue("part_sale_no"),
						"inout_org_code" : $M.getValue("inout_org_code")
				}
                $M.goNextPageAjax("/cust/cust020201/searchPartQty/", $M.toGetParam(param), {method: 'get'},
                    function (result) {
                        console.log(result);
                        if (result.success) {
                            AUIGrid.setGridData("#auiGrid", result.list);
                        }
                    }
                );
            }
        }

        // (Q&A 14336) 처리구분 옆에 ? 추가 2022-12-16 김상덕
        function show1() {
            document.getElementById("show1").style.display = "block";
        }

        function hide1() {
            document.getElementById("show1").style.display = "none";
        }

    </script>

    <style>
        .leftButton {
            margin-right: 170px !important;
        }
    </style>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" name="breg_seq" id="breg_seq"><!-- 부가구분(U개별/T합계) -->
<input type="hidden" name="add_ut" id="add_ut"><!-- 부가구분(U개별/T합계) -->
<input type="hidden" name="count_breg_no" id="count_breg_no"><!-- 사업자번호 외 몇 건 -->
<input type="hidden" name="check_breg_yn" id="check_breg_yn"><!-- 사업자번호 다수 유무 -->
<input type="hidden" name="part_sale_no" id="part_sale_no"><!-- 수주번호 -->
<input type="hidden" name="doc_barcode_no" id="doc_barcode_no"><!-- 바코드번호 -->
<input type="hidden" name="job_report_no" id="job_report_no"><!-- 정비번호 -->
<input type="hidden" name="rental_doc_no" id="rental_doc_no"><!-- 렌탈번호 -->
<input type="hidden" name="cust_no" id="cust_no"><!-- 고객번호 -->
<input type="hidden" name="invoice_type_cd" id="invoice_type_cd"> <!-- 수주(정비) 매출 -->
<input type="hidden" name="invoice_money_cd" id="invoice_money_cd"><!-- 송장비용방식 -->
<input type="hidden" name="invoice_no" id="invoice_no"><!-- 송장번호 -->
<input type="hidden" name="bill_no" id="bill_no"><!-- 대신화물 송장번호 -->
<input type="hidden" name="invoice_qty" id="invoice_qty">
<input type="hidden" name="receive_tel_no" id="receive_tel_no">
<input type="hidden" name="receive_name" id="receive_name">
<input type="hidden" name="receive_hp_no" id="receive_hp_no">
<input type="hidden" name="invoice_remark" id="invoice_remark">
<input type="hidden" name="invoice_post_no" id="invoice_post_no">
<input type="hidden" name="invoice_addr1" id="invoice_addr1">
<input type="hidden" name="invoice_addr2" id="invoice_addr2">
<input type="hidden" name="biz_post_no" id="biz_post_no">
<input type="hidden" name="biz_addr1" id="biz_addr1">
<input type="hidden" name="biz_addr2" id="biz_addr2">
<input type="hidden" name="count_remark" id="count_remark"> <!-- 품명 외 몇 건 -->
<input type="hidden" name="inout_doc_type_cd" id="inout_doc_type_cd" required="required" alt="참조 구분"> <!-- 품의서 구분코드 -->
<input type="hidden" name="item_id_str" id="item_id_str">
<input type="hidden" name="item_name_str" id="item_name_str">
<input type="hidden" name="unit_str" id="unit_str">
<input type="hidden" name="stock_qty_str" id="stock_qty_str">
<input type="hidden" name="qty_str" id="qty_str">
<input type="hidden" name="unit_price_str" id="unit_price_str">
<input type="hidden" name="amt_str" id="amt_str">
<input type="hidden" name="storage_name_str" id="storage_name_str">
<input type="hidden" name="current_all_qty_str" id="current_all_qty_str">
<input type="hidden" name="inout_doc_no" id="inout_doc_no">
<input type="hidden" name="real_breg_no" id="real_breg_no">
<input type="hidden" name="vip_yn" id="vip_yn">
<input type="hidden" name="preorder_yn" id="preorder_yn"> <!-- 수주 선주문 여부 추가 -->

<div class="layout-box">
<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
<!-- 상세페이지 타이틀 -->
				<div class="main-title detail">
					<div class="detail-left">
						<button type="button" class="btn btn-outline-light" onclick="javascript:fnList();"><i class="material-iconskeyboard_backspace text-default"></i></button>
						<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
					</div>
				</div>
<!-- /상세페이지 타이틀 -->
				<div class="contents">
					<div class="row">
<!-- 좌측 폼테이블 -->
						<div class="col-6">
<!-- 전표일자 테이블 -->
							<table class="table-border">
								<colgroup>
									<col width="100px">
									<col width="">
									<col width="100px">
									<col width="">
								</colgroup>
								<tbody>
									<tr>
										<th class="text-right essential-item">전표일자</th>
										<td>
											<div class="input-group">
												<input type="text" class="form-control border-right-0 width120px calDate rb" id="inout_dt" name="inout_dt" dateformat="yyyy-MM-dd" alt="전표일자" required="required" value="${inputParam.s_current_dt}">	
											</div>
										</td>
										<th class="text-right">전표번호</th>
										<td>
											<div class="form-row inline-pd">
												<div class="col-5">
													<input type="text" class="form-control width120px" readonly="readonly">
												</div>
												<div class="col-5">
												<input type="text" class="form-control width120px" id="mem_name" name="mem_name" readonly="readonly" value="${SecureUser.kor_name}">
												</div>
											</div>
										</td>
									</tr>
									<tr>
										<th class="text-right essential-item">처리센터</th>
										<td>
											<div class="input-group width120px">
												<input class="form-control" style="width:99%;" type="text" id="inout_org_code" name="inout_org_code" easyui="combogrid"
												easyuiname="warehouseList" panelwidth="240" idfield="code" textfield="code_name" multi="N" enter="fnSetPartQty();" change="fnSetPartQty();"/>
											</div>
										</td>
										<th class="text-right">물품대</th>
										<td>
											<div class="form-row inline-pd widthfix">
												<div class="col width100px">
													<input type="text" class="form-control text-right" readonly="readonly" id="doc_amt" name="doc_amt" value="0" format="decimal">	
												</div>
												<div class="col width33px">원</div>
											</div>	
										</td>
									</tr>
									<tr>
										<th class="text-right">쿠폰사용</th>
										<td>
											<div class="form-row inline-pd widthfix">
												<div class="col width100px">
													<input type="text" class="form-control text-right" id="discount_amt" name="discount_amt" format="decimal" value="0" onChange="javascript:fnCalcCoupon();">	
												</div>
												<div class="col width33px">원</div>
											</div>	
										</td>
										<th class="text-right">할인적용가</th>
										<td>
											<div class="form-row inline-pd widthfix">
												<div class="col width100px">
													<input type="text" class="form-control text-right" readonly="readonly" id="apply_discount_amt" name="apply_discount_amt" format="decimal" value="0">
												</div>
												<div class="col width33px">원</div>
											</div>	
										</td>
									</tr>
									<tr>
										<th class="text-right">마일리지사용</th>
										<td>
											<div class="form-row inline-pd widthfix">
												<div class="col width100px">
													<input type="text" class="form-control text-right" id="use_mile_amt" name="use_mile_amt" format="decimal" value="0" onchange="javascript:fnCalcMile();">
												</div>
												<div class="col width33px">원</div>
											</div>
										</td>
										<th class="text-right">부가세</th>
										<td>
											<div class="form-row inline-pd widthfix">
												<div class="col width100px">
													<input type="text" class="form-control text-right" id="vat_amt" name="vat_amt" format="decimal" onchange="javascript:fnCalcVat();">
												</div>
												<div class="col width33px">원</div>
											</div>
										</td>
									</tr>
									<tr>
										<th class="text-right">마일리지적립</th>
										<td>
											<div class="form-row inline-pd widthfix">
												<div class="col width100px">
													<input type="text" class="form-control text-right" id="mile_amt" name="mile_amt" format="decimal" readonly="readonly">
												</div>
												<div class="col width33px">원</div>
											</div>
										</td>
										<th class="text-right">합계금액</th>
										<td>
											<div class="form-row inline-pd widthfix">
												<div class="col width100px">
													<input type="text" class="form-control text-right" readonly="readonly" id="total_amt" name="total_amt" value="0" format="decimal">	
												</div>
												<div class="col width33px">원</div>
											</div>	
										</td>
									</tr>
									<tr>
										<th class="text-right">비고</th>
										<td colspan="3">
											<input type="text" class="form-control" id="desc_text" name="desc_text" maxlength="240">
										</td>
									</tr>
									<tr>
										<th class="text-right essential-item">발송구분</th>
										<td colspan="3">
											<div class="form-row inline-pd widthfix mb7">
												<div class="col width160px">
													<select class="form-control essential-bg" required="required" id="invoice_send_cd" name="invoice_send_cd" alt="발송구분" required="required" onChange="javascript:goDeliveryInfo();">
														<option value="">- 선택 -</option>
														<c:forEach items="${codeMap['INVOICE_SEND']}" var="item">
														<option value="${item.code_value}">${item.code_name}</option>
														</c:forEach>
													</select>
												</div>
												<div class="col width60px">
													<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_L"/></jsp:include>
												</div>
											</div>
											<div class="form-row inline-pd">
												<div class="col-12">
													<input type="text" class="form-control" readonly="readonly" id="invoice_addr" name="invoice_addr">
												</div>
											</div>
										</td>
									</tr>
									<tr>
										<th class="text-right">최종메모</th>
										<td colspan="3">
											<textarea class="form-control" readonly="readonly" style="height: 205px;" id="last_memo" name="last_memo"></textarea>
										</td>
									</tr>																			
								</tbody>
							</table>
<!-- /전표일자 테이블 -->
						</div>
<!-- /좌측 폼테이블 -->
<!-- 우측 폼테이블 -->
						<div class="col-6">
<!-- 참조 -->
							<div>
								<div class="title-wrap">
									<h4>참조</h4>
								</div>

								<table class="table-border">
									<colgroup>
										<col width="100px">
										<col width="">
									</colgroup>
									<tbody>
										<tr>
											<th class="text-right">참조번호</th>
											<td>
												<div class="form-row inline-pd widthfix">
													<div class="col-auto">
														<input type="text" class="form-control" readonly="readonly" id="reference_no" name="reference_no">
													</div>
													<div class="col-auto">
														<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
													</div>
													<div class="left">
														<div class="text-warning ml5" style="font-weight:bold;" id="preorder_inout">
														</div>
													</div>
												</div>
											</td>
										</tr>															
									</tbody>
								</table>
							</div>
<!-- /참조 -->	
<!-- 고객정보 -->
							<div>
								<div class="title-wrap mt10">
									<h4>고객정보</h4>
								</div>

								<table class="table-border">
									<colgroup>
										<col width="100px">
										<col width="">
										<col width="100px">
										<col width="">
									</colgroup>
									<tbody>
										<tr>
											<th class="text-right">고객명</th>
											<td>
												<input type="text" class="form-control width100px" id="cust_name" name="cust_name" readonly="readonly" required="required" alt="고객명">
											</td>
											<th class="text-right">현미수금</th>
											<td>
												<div class="form-row inline-pd widthfix">
													<div class="col width100px">
														<input type="text" class="form-control text-right" id="misu_amt" name="misu_amt" readonly="readonly" format="decimal">	
													</div>
													<div class="col width33px">원</div>
												</div>	
											</td>
										</tr>
										<tr>
											<th class="text-right">연락처</th>
											<td>
												<div class="form-row inline-pd">
													<div class="col-6">
														<input type="text" class="form-control" id="cust_hp_no" name="cust_hp_no" readonly="readonly">	
													</div>
													<div class="col-6">
														<input type="text" class="form-control" id="email" id="email" readonly="readonly">	
													</div>
												</div>
											</td>
											<th class="text-right">쿠폰잔액</th>
											<td>
												<div class="form-row inline-pd widthfix">
													<div class="col width100px">
														<input type="text" class="form-control text-right" id="coupon_balance_amt" name="coupon_balance_amt" readonly="readonly" format="decimal">	
													</div>
													<div class="col width33px">원</div>
												</div>	
											</td>
										</tr>
										<tr>
											<th class="text-right">담당자</th>
											<td>
												<input type="text" class="form-control width100px" id="sale_mem_name" name="sale_mem_name" readonly="readonly">
												<input type="hidden" id="sale_mem_no" name="sale_mem_no">
											</td>
											<th class="text-right">누적마일리지</th>
											<td>
												<div class="form-row inline-pd widthfix">
													<div class="col width100px">
														<input type="text" class="form-control text-right" id="mile_balance_amt" name="mile_balance_amt" readonly="readonly" format="decimal">
													</div>
													<div class="col width33px">원</div>
												</div>
											</td>
										</tr>
										<tr>
											<th class="text-right">입금자</th>
											<td >
												<div class=" inline-pd widthfix ">
													<div class="form-row col ">
														<input type="text" class="form-control width100px" id="deposit_name" name="deposit_name">
														<div class="pl5">
															<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_M"/></jsp:include>
														</div>
													</div>
												</div>
											</td>
											<th class="text-right">매출한도</th>
											<td>
												<div class="form-row inline-pd widthfix">
													<div class="col width100px">
														<input type="text" class="form-control text-right" id="max_misu_amt" name="max_misu_amt" readonly="readonly" format="decimal">
													</div>
													<div class="col width33px">원</div>
												</div>
											</td>
										</tr>
										<tr>
											<th class="text-right">입금예정일</th>
											<td>
												<input type="text" class="form-control width120px" style="width:120px;" id="deposit_plan_dt" name="deposit_plan_dt" readonly="readonly" dateformat="yyyy-MM-dd">
											</td>
										</tr>
									</tbody>
								</table>
							</div>
<!-- /고객정보 -->	
<!-- 세금계산서 -->
							<div>
								<div class="title-wrap mt10">
									<h4>세금계산서</h4>
								</div>
								<table class="table-border">
									<colgroup>
										<col width="100px">
										<col width="">
										<col width="100px">
										<col width="">
									</colgroup>
									<tbody>
									<tr>
										<th class="text-right essential-item">처리구분
											<i class="material-iconshelp font-16" style="vertical-align: middle;"
											   onmouseover="javascript:show1()" onmouseout="javascript:hide1()"></i>
										</th>
										<div class="con-info" id="show1"
											 style="display: none; max-height: 150px; left: 7%; width: 500px; top:68%;">
											<ul class="">
												<li>
													<span style="font-weight: bold">세금계산서 발행</span><br>
													세금계산서 : 세금계산서 발행<br>
													합산발행 : 계산서 고객 요청에 따라 일괄 합산발행
												</li>
												<li>
                                                    <span style="font-weight: bold">계산서 미발행</span><br>
                                                    카드매출 : 카드로 결제할 경우 선택, 고객이 계산서를 요청하는 경우에는 해당하지 않음.<br>
                                                    현금영수증 : 고객이 계산서 발행없이 현금영수증 끊고자 할때 체크<br>
                                                    무증빙 : 건별처리와 동일, 아무런 증빙을 원하지 않는 경우 처리.
                                                </li>
                                            </ul>
                                        </div>
                                        <td colspan="3">
                                            <div class="form-check form-check-inline add-u">
                                                <input class="form-check-input vat_treat" type="radio" id="vat_treat_y"
                                                       name="vat_treat_cd" value="Y"
                                                       onclick="javascript:fnSearchBregSpec();">
                                                <label for="vat_treat_y" class="form-check-label">세금계산서</label>
                                            </div>
                                            <div class="form-check form-check-inline add-n vat-S vat">
                                                <input class="form-check-input vat_treat" type="radio" id="vat_treat_s"
													   name="vat_treat_cd" value="S"
													   onclick="javascript:fnSearchBregSpec();">
												<label for="vat_treat_s" class="form-check-label">합산발행</label>
											</div>
											<div class="form-check form-check-inline add-u add-f vat-F vat">
												<input class="form-check-input vat_treat" type="radio" id="vat_treat_f"
													   name="vat_treat_cd" value="F">
												<label for="vat_treat_f" class="form-check-label">수정계산서</label>
											</div>
											<span style="font-size:16px">ㅣ&nbsp;&nbsp;&nbsp;</span>
											<div class="form-check form-check-inline add-u vat-C vat">
												<input class="form-check-input vat_treat" type="radio" id="vat_treat_c"
													   name="vat_treat_cd" value="C">
												<label for="vat_treat_c" class="form-check-label text-info">카드매출</label>
											</div>
											<div class="form-check form-check-inline add-u vat-H vat">
												<input class="form-check-input vat_treat" type="radio" id="vat_treat_a"
													   name="vat_treat_cd" value="A">
												<label for="vat_treat_a"
													   class="form-check-label text-info">현금영수증</label>
											</div>
											<div class="form-check form-check-inline add-u vat-N vat">
												<input class="form-check-input vat_treat" type="radio" id="vat_treat_n"
													   name="vat_treat_cd" value="N">
												<label for="vat_treat_n" class="form-check-label text-info">무증빙</label>
											</div>
<%--												<div class="form-check form-check-inline add-u">--%>
<%--													<input class="form-check-input vat_treat" type="radio" id="vat_treat_r" name="vat_treat_cd" value="R">--%>
<%--													<label for="vat_treat_r" class="form-check-label">발행보류(사업자 無)</label>--%>
<%--												</div>--%>

											</td>
										</tr>
										<tr>
											<th class="text-right">사업자No</th>
											<td colspan="3">
												<div class="form-row inline-pd widthfix">
													<div class="col width160px">
														<input type="hidden" class="form-control" id="breg_no" name="breg_no">	
														<input type="text" class="form-control" id="check_breg_no" name="check_breg_no" readonly="readonly">	
													</div>
													<div class="col width80px">
														<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
													</div>
													<div class="col width70px text-right">
														부가세포함
													</div>
													<div class="col width60px">
														<input type="text" class="form-control" readonly="readonly" id="taxbill_dt" name="taxbill_no">
													</div>
													<div class="col width10px">
														-
													</div>
													<div class="col width60px">
														<input type="text" class="form-control" readonly="readonly" id="taxbill_no" name="taxbill_no">	
													</div>
													<div class="col width10px">
														-
													</div>
													<div class="col width60px">
														<input type="text" class="form-control" readonly="readonly" id="taxbill_control_no" name="taxbill_control_no">	
													</div>
												</div>	
											</td>
										</tr>
										<tr>
											<th class="text-right">업체명</th>
											<td>
												<input type="text" class="form-control" readonly="readonly" id="breg_name" name="breg_name">
											</td>
											<th class="text-right">대표자</th>
											<td>
												<input type="text" class="form-control width100px" readonly="readonly" id="breg_rep_name" name="breg_rep_name">
											</td>
										</tr>
										<tr>
											<th class="text-right">업태</th>
											<td>
												<input type="text" class="form-control" readonly="readonly" id="breg_cor_type" name="breg_cor_type">
											</td>
											<th class="text-right">종목</th>
											<td>
												<input type="text" class="form-control" readonly="readonly" id="breg_cor_part" name="breg_cor_part">
											</td>
										</tr>
										<tr>
											<th class="text-right">주소</th>
											<td colspan="3">
												<input type="text" class="form-control" readonly="readonly" id="biz_addr" name="biz_addr">
											</td>
										</tr>														
									</tbody>
								</table>
							</div>
<!-- /세금계산서 -->		
						</div>
<!-- /우측 폼테이블 -->	
					</div>
<!-- 하단 폼테이블 -->				
					<div>
						<div class="title-wrap mt10">
							<h4>부품목록</h4>
						</div>
						<div id="auiGrid" style="margin-top: 5px; height: 150px;"></div>
					</div>
<!-- /하단 폼테이블 -->	
					<div class="btn-group mt10">
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
<!-- 							<butten type="butten" onclick="fnAfterInout('IN20201109-023');">test</butten> -->
<!-- 							<butten type="butten" class="btn btn-info" onclick="javascript:goAfterInout('IN20201109-023');">test</butten> -->
						</div>
					</div>
				</div>						
			</div>		
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
		</div>
<!-- /contents 전체 영역 -->	
</div>
</form>	
</body>
</html>