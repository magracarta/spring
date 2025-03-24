<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 창고이동/부품출하 > 부품이동요청 > null > 부품이동요청상세
-- 작성자 : 손광진
-- 최초 작성일 : 2020-02-25 17:03:22
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		var sendInvoiceChk = false; 	// 배송정보에서 받은 값인지 체크
		var checkHomi = ${homiType};	// 요청타입 HOMI인지 체크
		
		$(document).ready(function() {
			fnInitPage();			// 페이지 초기 세팅
			createLeftAUIGrid();	// 장바구니 grid
			createRightAUIGrid();	// 요청예정목록 grid
		});
		
		
		function fnInitPage() {
			var complete_yn = $M.getValue("mst_complete_yn");
			
			if(complete_yn == "Y") {
				$('#partMoveRightBtn').attr('disabled', true);
				$('#partMoveLeftBtn').attr('disabled', true);
				$('#invoice_send_cd').attr('disabled', true);
				$('input').prop('readonly', true);
				$("#invoice_send_cd").removeClass('essential-bg');
				$("th").removeClass('essential-item');
			};
			
			// homi인 경우 배송정보X
			if($M.getValue("mst_part_trans_req_type_cd") == checkHomi) {
				$('#sendInvocieBtn').attr('disabled', true);
			};
		}
		
		// 그리드생성
		function createLeftAUIGrid() {
			var complete_yn = $M.getValue("mst_complete_yn");
			if(complete_yn == "") {
				alert("부품이동요청의 작성완료여부를 받지 못했습니다.");
				return false;
			}; 
			
			// 작성여부에 따라 그리드데이터 수정 (가능, 불가)
			if(complete_yn == "Y") {
				var gridPros = {
					rowIdField : "part_trans_cart_seq",
					showRowNumColumn : true,
					// 행 소프트 제거 모드 해제
					softRemoveRowMode : false,
					rowIdTrustMode : true,
					editable : false,
					//체크박스 출력 여부
					showRowCheckColumn : true,
					//전체선택 체크박스 표시 여부
					showRowAllCheckBox : true,
				}
			} else if(complete_yn == "N") {
				var gridPros = {
					rowIdField : "part_trans_cart_seq",
					showRowNumColumn : true,
					// 행 소프트 제거 모드 해제
					softRemoveRowMode : false,
					rowIdTrustMode : true,
					editable : true,
					//체크박스 출력 여부
					showRowCheckColumn : true,
					//전체선택 체크박스 표시 여부
					showRowAllCheckBox : true,
					showStateColumn : true,
				}
			};
				
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
				    headerText: "처리일자",
				    dataField: "reg_date",
				    dataType : "date",   
					width : "13%",
					style : "aui-center",
					formatString : "yyyy-mm-dd",
					editable : false 
				},
				{
					headerText : "부품번호",
					dataField : "part_no",
					width: "23%",
					style : "aui-center",
					editable : false 
				},
				{
				    headerText: "부품명",
				    dataField: "part_name",
					width : "30%",
					style : "aui-center",
					editable : false 
				},
				{
				    headerText: "수량",
				    dataField: "qty",
					width : "8%",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-center aui-editable",
					editable : true 
				},
				{
				    headerText: "FROM",
				    dataField: "from_warehouse_name",
					width : "12%",
					style : "aui-center",
					editable : false 
				},
				{
				    headerText: "TO",
				    dataField: "to_warehouse_name",
					width : "12%",
					style : "aui-center",
					editable : false 
				},
				{
				    dataField: "to_warehouse_cd",
				    visible : false,
				},
				{
				    dataField: "from_warehouse_cd",
				    visible : false,
				},
				{
				    headerText: "비고",
				    dataField: "remark",
					width : "30%",
					style : "aui-left aui-editable",
					editable : true
				},
				{
				    headerText: "처리자",
				    dataField: "reg_mem_name",
					width : "10%",
					style : "aui-center",
					editable : false
				},
// 				{
// 				    headerText: "삭제",
// 				    renderer : {
// 						type : "ButtonRenderer",
// 						labelText : "삭제",
// 						onClick : function(event) {
// 							goRemoveCart(event.item.part_trans_cart_seq);
// 						},
// 				    },
// 					style : "aui-left"
// 				},
				{
					headerText: "FROM코드",
				    dataField: "from_warehouse_cd",
					style : "aui-left",
					editable : false,
					visible : false
				},
				{
					headerText: "To코드",
				    dataField: "to_warehouse_cd",
					style : "aui-left",
					editable : false,
					visible : false
				},
				{
					headerText: "FROM현재고",
				    dataField: "current_stock",
					style : "aui-left",
					editable : false,
					visible : false
				},
				{
					headerText: "장바구니No",
				    dataField: "part_trans_cart_seq",
					editable : false,
					visible : false
				}
			];
			auiGridLeft = AUIGrid.create("#auiGridLeft", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridLeft, ${cartList});
			$("#auiGridLeft").resize();
		}
		
		// 그리드생성
		function createRightAUIGrid() {
			var complete_yn = $M.getValue("mst_complete_yn");
			if(complete_yn == "") {
				alert("작성여부 정보를 받지 못했습니다.");
				return false;
			};
			
			// 작성여부에 따라 그리드데이터 수정 (가능, 불가)
			if(complete_yn == "Y") {
				var gridPros = {
					rowIdField : "_$uid",
					editable : false,
				}
			} else if(complete_yn == "N") {
				var gridPros = {
					rowIdField : "part_trans_cart_seq",
					showRowNumColumn : true,
					//체크박스 출력 여부
					showRowCheckColumn : true,
					//전체선택 체크박스 표시 여부
					showRowAllCheckBox : true,
					rowIdTrustMode : true,
					// 행 소프트 제거 모드 해제
					softRemoveRowMode : false,
					showStateColumn : true,
					editable : true
				}
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
					headerText : "부품번호",
					dataField : "part_no",
					width: "23%",
					editable : false,
					style : "aui-center"
				},
				{
				    headerText: "부품명",
				    dataField: "part_name",
					width : "30%",
					editable : false,
					style : "aui-left"
				},
				{
				    headerText: "FROM가용재고",
				    dataField: "current_able_stock",
					width : "15%",
					dataType : "numeric",
					formatString : "#,##0",
					editable : false,
					style : "aui-center"
				},
				{
				    headerText: "수량",
				    dataField: "qty",
					width : "10%",
					dataType : "numeric",
					formatString : "#,##0",
					editable : true,
					style : "aui-center aui-editable"
				},
				{
				    headerText: "미처리량",
				    dataField: "mi_qty",
					width : "10%",
					dataType : "numeric",
					formatString : "#,##0",
					editable : false,
					style : "aui-center"
				},
				{
				    headerText: "비고",
				    dataField: "remark",
					width : "30%",
					style : "aui-left aui-editable"
				},
				{
					headerText: "이동요청서 번호",
				    dataField: "part_trans_req_no",
					style : "aui-left",
					visible : false
				},
				{
					headerText: "일련번호",
				    dataField: "seq_no", 
					style : "aui-left",
					visible : false
				},
				{
					headerText: "장바구니 일련번호",
				    dataField: "part_trans_cart_seq", 
					style : "aui-left",
					visible : false
				}
			];
			auiGridRight = AUIGrid.create("#auiGridRight", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridRight, ${transList});
			
			AUIGrid.bind(auiGridRight, "cellEditEnd", function( event ) {
				if(event.dataField == 'qty') {
					var qty = event.value;
					AUIGrid.updateRow(auiGridRight, {"mi_qty" : qty }, event.rowIndex);

				}
			});

			$("#auiGridRight").resize();
		}
		

		// 부품장바구니 데이터 요청예정목록에 추가
		function fnAddRequest() {
			// 그리드의 체크된 행들 얻기
			var rows = AUIGrid.getCheckedRowItemsAll(auiGridLeft);

			// 선택된 행이 없을 때
			if(rows.length < 1) {
				alert("장바구니에 선택된 행이 없습니다.");
				return;
			};

			// 장바구니에서 여러개 체크 후 요청예정목록에 추가할때 동일한 FROM창고를 체크했는지
			for(var i = 0, len = rows.length; i < len; i++) {
				for(var j = 0, len = rows.length; j < len; ++j) {
					if(rows[i]["from_warehouse"] != rows[j]["from_warehouse"]) {
						alert("동일한 FROM창고를 체크하세요.");
						return;
					};
				};
			};

			// 추가된 그리드목록
			var gridRightList = AUIGrid.getGridData(auiGridRight);
			
			// 장바구니 체크값과 요청예정목록의 from_warehouse_cd값을 비교하여 FROM창고가 동일한지 체크
			for(var i = 0; i < rows.length; i++) {
				for (var j = 0; j < gridRightList.length; j++) {
					if(rows[i]["from_warehouse_cd"] != gridRightList[j]["from_warehouse_cd"]) {
						alert("요청예정목록과 동일한 FROM창고를 체크하세요.");
						return;
					};

					// 2024-09-26 (Q&A:24013) 저장시 중복된 부품이 있는지 체크
					if(rows[i]["part_no"] == gridRightList[j]["part_no"]) {
						alert("동일한 항목이 있습니다. 확인 후 다시 처리해주세요. 부품번호 : " + rows[i]["part_no"]);
						return;
					};
				};
			};
			
			// 미처리량 컬럼
			for(var i=0, len=rows.length; i<len; i++) {
			    rows[i]["mi_qty"] = rows[i]["qty"];
			}
			
			var columns = fnGetColumns(auiGridLeft);
			
			fnGridDataFormCmd(rows, columns, "add");
		}
		
		// 그리드 데이터를 폼으로 변경
		function fnGridDataFormCmd(data, columns, saveMode) {
			
			var frm = $M.createForm();
			
			for(var i = 0, n = data.length; i < n; i++) {
				var row = data[i];
				frm = fnToFormData(frm, columns, row);
			}
			goTransPartGridSave(frm, saveMode);
		}
		

		// 부품이동요청 부품 추가,수정,삭제
		function goTransPartGridSave(gridForm, saveMode) {
			var frm = document.main_form;
			$M.copyForm(gridForm, frm);
			var moveGridMsg = "";
			
			if(saveMode == "add") {
				moveGridMsg = "선택하신 부품을 요청예정목록으로 이동 하시겠습니까?";
			} else if(saveMode == "del") {
				moveGridMsg = "선택하신 부품을 장바구니로 이동 하시겠습니까?";
			};
			
			if(!confirm(moveGridMsg)) {
				return;
			}
			$M.goNextPageAjax(this_page + "/gridSave/" + saveMode, gridForm, { method : "POST"},
				function(result) {
					if(result.success) {
						location.reload();
					}
				}
			);
		}
		
		
		// 장바구니 삭제
// 		function goRemoveCart(seq) {
// 			var cartSeq = seq;	// 받아온 장바구니일련번호
// 			var param = {
// 				"part_trans_cart_seq"	: cartSeq
// 			};

// 			$M.goNextPageAjaxRemove(this_page + "/removeCart", $M.toGetParam(param), { method : "POST"},
// 				function(result) {
// 					if(result.success) {
// 						alert("장바구니 삭제가 완료되었습니다.");
// 						location.reload();
// 					};
// 				}
// 			);
// 		}
		
		// 장바구니 체크 후 삭제 (2021-06-29 황빛찬 / SR 추가요청.)
		function fnCartCheckRemove() {
			var checkData = AUIGrid.getCheckedRowItemsAll(auiGridLeft);
			
			if (checkData.length == 0) {
				alert("선택된 항목이 없습니다.");
				return;
			}
			
			if (confirm("선택된 장바구니 목록을 삭제하시겠습니까?") == false) {
				return false;
			}

			var checkDataArr = [];
			for (var i = 0; i < checkData.length; i++) {
				checkDataArr.push(checkData[i].part_trans_cart_seq);
			}
			
			var param = {
					part_trans_cart_seq_str : $M.getArrStr(checkData, {key : 'part_trans_cart_seq'}),
			}			
			
			$M.goNextPageAjax(this_page + "/removeCart", $M.toGetParam(param), { method : "POST"},
				function(result) {
					if(result.success) {
// 						AUIGrid.removeRowByRowId(auiGridLeft, checkDataArr);
						alert("장바구니 삭제가 완료되었습니다.");
						location.reload();
					};
				}
			);
		}
		
		// 요청예정목록데이터 부품장바구니로 이동
		function fnReturnCart() {
			// 그리드의 체크된 행들 얻기
			var rows = AUIGrid.getCheckedRowItemsAll(auiGridRight);
			console.log("left", rows);
			// 선택된 행이 없을 때
			if(rows.length < 1) {
				alert("요청예정목록에 선택된 행이 없습니다.");
				return;
			};

			var columns = fnGetColumns(auiGridRight);
			
			fnGridDataFormCmd(rows, columns, "del");
		}
		
	
		// 부품이동 요청서 삭제
		function goRemove(seq) {
			
			var complete_yn = $M.getValue("mst_complete_yn");
			
			if(complete_yn == "Y") {
				alert("부품 이동요청서가 작성된 자료는 삭제가 불가능합니다.");
			};
			
			var frm = document.main_form;
			
			var option = {
				isEmpty : true,
			};
			
			var partTransReqNo =  $M.getValue("mst_part_trans_req_no");	// mst부품이동요청 번호
			var rightGridData = AUIGrid.getGridData(auiGridRight);
			
			if(rightGridData.length > 0) {
				
				var part_trans_req_no = [];
				var seq_no = [];
				var part_no = [];
				var part_trans_cart_seq = [];
				var part_trans_qty = [];
				var part_trans_remark = [];
				
				for(var i = 0, n = rightGridData.length; i < n; i++) {
					part_trans_req_no.push(rightGridData[i].part_trans_req_no);
					seq_no.push(rightGridData[i].seq_no);
					part_no.push(rightGridData[i].part_no);
					part_trans_cart_seq.push(rightGridData[i].part_trans_cart_seq);
				}
				
				$M.setValue(frm, "part_trans_req_no_str", $M.getArrStr(part_trans_req_no, option));
				$M.setValue(frm, "seq_no_str", $M.getArrStr(seq_no, option));
				$M.setValue(frm, "part_no_str", $M.getArrStr(part_no, option));
				$M.setValue(frm, "part_trans_cart_seq_str", $M.getArrStr(part_trans_cart_seq, option));
			};

			$M.goNextPageAjaxRemove(this_page + "/remove/" + partTransReqNo, $M.toValueForm(frm), { method : "POST"},
				function(result) {
					if(result.success) {
                        alert("삭제가 완료되었습니다.");
                        fnClose();
                        window.opener.goSearch();
					};
				}
			);
		}

		// 이동요청서 수정(요청서 작성X)
		function goSave() {
			saveTransPart("save");
		}
		
		// 이동요청서 작성완료
		function goTransPart() {
			saveTransPart("trans");
		}
	
		function saveTransPart(str) {
			// 2024-09-26 (Q&A:24013) 저장시 중복된 부품이 있는지 체크
			var gridData = AUIGrid.getGridData(auiGridRight);
			for(var i = 0; i < gridData.length; i++) {
				for(var j = 0; j < i; j++) {
					if(gridData[i].part_no == gridData[j].part_no) {
						alert("동일한 항목이 있습니다. 확인 후 다시 처리해주세요. 부품번호 : " + gridData[i].part_no);
						return;
					}
				}
			}

			var complete_yn = "N";	// 이동요청서 작성여부 
			
			if(str == "trans") {
				complete_yn = "Y"; // 이동요청서 작성완료
			};
			
			var frm = document.main_form;

			var option = {
				isEmpty : true
			};
			
			// 장바구니
			var editRowCart	  = AUIGrid.getEditedRowItems(auiGridLeft);
			
			if(editRowCart.length > 0) {
				var part_trans_cart_seq = [];
				var partNo 				= [];
				var qty 				= [];
				var remark 				= [];
				for(var i = 0, n = editRowCart.length; i < n; i++) {
					part_trans_cart_seq.push(editRowCart[i].part_trans_cart_seq);
					partNo.push(editRowCart[i].part_no);
					qty.push(editRowCart[i].qty);
					remark.push(editRowCart[i].remark);
				}
				
				$M.setValue(frm, "part_trans_cart_seq_str", $M.getArrStr(part_trans_cart_seq, option));
				$M.setValue(frm, "part_no_cart_str", $M.getArrStr(partNo, option));
				$M.setValue(frm, "qty_cart_str", $M.getArrStr(qty, option));
				$M.setValue(frm, "remark_cart_str", $M.getArrStr(remark, option));
			};
			
			
			// 부품이동요청 부품
			var editRowPartTrans = AUIGrid.getEditedRowItems(auiGridRight);
			
			if(editRowPartTrans.length > 0) {
				
				var part_trans_req_no = [];
				var seq_no = [];
				var part_no = [];
				var part_trans_dtl_cart_seq = [];
				var part_trans_qty = [];
				var part_trans_remark = [];
				
				for(var i = 0, n = editRowPartTrans.length; i < n; i++) {
					part_trans_req_no.push(editRowPartTrans[i].part_trans_req_no);
					seq_no.push(editRowPartTrans[i].seq_no);
					part_no.push(editRowPartTrans[i].part_no);
					part_trans_dtl_cart_seq.push(editRowPartTrans[i].part_trans_cart_seq);
					part_trans_qty.push(editRowPartTrans[i].qty);
					part_trans_remark.push(editRowPartTrans[i].remark);
				}
				
				$M.setValue(frm, "part_trans_req_no_str", $M.getArrStr(part_trans_req_no, option));
				$M.setValue(frm, "seq_no_str", $M.getArrStr(seq_no, option));
				$M.setValue(frm, "part_no_str", $M.getArrStr(part_no, option));
				$M.setValue(frm, "part_trans_dtl_cart_seq_str", $M.getArrStr(part_trans_dtl_cart_seq, option));
				$M.setValue(frm, "part_trans_qty_str", $M.getArrStr(part_trans_qty, option));
				$M.setValue(frm, "part_trans_remark_str", $M.getArrStr(part_trans_remark, option));
				
			};
					
			var msg 	  = complete_yn == "Y" ? "이동 요청서를 작성하시겠습니까?" : "저장하시겠습니까?";
			var resultMsg = complete_yn == "Y" ? "정상적으로 이동 요청서를 작성하였습니다" : "저장이 완료되었습니다.";

			$M.goNextPageAjaxMsg(msg, this_page + "/save/" + complete_yn, $M.toValueForm(frm), {method : "POST"},
				function(result) {
		    		if(result.success) {
		    			alert(resultMsg);
		    			fnClose();
		    			window.opener.goSearch();
					};
				}
			); 
		}
		
		function goHomiDtlPopup() {
			var popupOption = "scrollbars=yes, resizable-1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1100, height=580, left=0, top=0";

			var param = {
					"warehouse_cd" : $M.getValue("mst_to_warehouse_cd"),
					"warehouse_name" : $M.getValue("to_warehouse"),
			 		"homi_dt" : $M.getValue("mst_part_trans_req_no").substr(0, 8),
			};
			$M.goNextPage('/part/part0502p01', $M.toGetParam(param), {popupStatus : popupOption});
		}
		
	    // 배송정보 팝업
	    function goSendInvoiceInfo() {
	    	var complete_yn = $M.getValue("mst_complete_yn");
	    	
	    	var params = {
    			to_warehouse_cd     : $M.getValue("mst_to_warehouse_cd"),
    			invoice_type_cd 	: $M.getValue("invoice_type_cd"),
    			invoice_money_cd	: $M.getValue("invoice_money_cd"),
    			invoice_send_cd 	: $M.getValue("invoice_send_cd"),
    			receive_name 		: $M.getValue("receive_name"),
    			invoice_no 			: $M.getValue("invoice_no"),
    			receive_hp_no 		: $M.getValue("receive_hp_no"),
    			receive_tel_no 		: $M.getValue("receive_tel_no"),
    			qty 				: $M.getValue("invoice_qty"),
    			remark 				: $M.getValue("invoice_remark"),
    			post_no 			: $M.getValue("invoice_post_no"),
    			addr1				: $M.getValue("invoice_addr1"),
    			addr2				: $M.getValue("invoice_addr2"),
    			show_yn 			: complete_yn == "Y" ? 'Y' : '',
	    	};
	    	
	    	openDeliveryInfoPanel('setDeliveryInfo', $M.toGetParam(params));
	    }
	    
	    // 배송정보 callback
	    function setDeliveryInfo(data) {
	    	fnNewSendInvoice();
	    	$M.setValue(data);
	    	$M.setValue("invoice_address", data.invoice_addr1 + " " + data.invoice_addr2)
	    	sendInvoiceChk = true;
	    	$M.setValue("sendInvoiceChk", sendInvoiceChk);
	    }
	    
		//갱신
		function fnNewSendInvoice() {
			var param = {
    			invoice_warehouse 		: "",	// 송장창고(to)
    			invoice_no 				: "",	// 송장번호
    			invoice_qty 			: "",	// 수량
    			receive_name 			: "", 	// 성명
    			receive_tel_no 			: "", 	// 전화번호
    			receive_hp_no 			: "",	// 핸드폰번호
    			invoice_remark			: "",	// 비고
    			invoice_money_cd 		: "",	// 송장비용방식 코드
    			invoice_send_cd 		: "0",	// 송장발송구분 코드(방문)
    			invoice_post_no			: "",	// 우편번호
    			invoice_addr1 			: "",	// 주소1
    			invoice_addr2 			: "",	// 주소2
    			invoice_address 		: "",	// 주소
			}
			$M.setValue(param);
		}
	    
		function fnClose() {
			window.close();
		}
		
	</script>
</head>
<body class="bg-white class">
	<form id="main_form" name="main_form">
		<!-- 부품 이동 요청서 완료여부 -->
		<input type="hidden" id="mst_complete_yn" name="mst_complete_yn" value="${transMst.complete_yn}">
		<!-- 부품 이동 요청타입 코드 -->
		<input type="hidden" id="mst_part_trans_req_type_cd" name="mst_part_trans_req_type_cd" value="${transMst.part_trans_req_type_cd}">
		<!-- 배송정보팝업에서 받은건지 check -->
		<input type="hidden" id="sendInvoiceChk" name="sendInvoiceChk" value="">
		
		<!-- 송장발송 -->
		<!-- 기존 송장발송번호 -->
		<input type="hidden" name="send_invoice_seq" id="send_invoice_seq" value="${transMst.send_invoice_seq}">
		<!-- 송장창고(to창고) -->
		<input type="hidden" name="invoice_warehouse" id="invoice_warehouse" value="">
		<!-- 발송구분 -->
		<input type="hidden" name="invoice_type_cd" id="invoice_type_cd" value="99">
		<!-- 송장번호 -->
		<input type="hidden" name="invoice_no" id="invoice_no" value="${transMst.invoice_no}">
		<!-- 수량 -->
		<input type="hidden" name="invoice_qty" id="invoice_qty" 	value="${transMst.invoice_qty}">
		<!-- 성명 -->
		<input type="hidden" name="receive_name" id="receive_name" value="${transMst.receive_name}">
		<!-- 전화번호 -->
		<input type="hidden" name="receive_tel_no" id="receive_tel_no" value="${transMst.receive_tel_no}">
		<!-- 핸드폰번호 -->
		<input type="hidden" name="receive_hp_no" id="receive_hp_no" value="${transMst.receive_hp_no}">
		<!-- 참고 -->	
		<input type="hidden" name="invoice_remark" id="invoice_remark" value="${transMst.invoice_remark}">		
		<!-- 송장비용방식코드 -->					
		<input type="hidden" name="invoice_money_cd" id="invoice_money_cd" value="${transMst.invoice_money_cd}">
		<!-- 우편번호 -->
		<input type="hidden" name="invoice_post_no" id="invoice_post_no" value="${transMst.invoice_post_no}">
		<!-- 주소1 -->
		<input type="hidden" name="invoice_addr1" id="invoice_addr1" value="${transMst.invoice_addr1}">
		<!-- 주소2 -->		
		<input type="hidden" name="invoice_addr2" id="invoice_addr2" value="${transMst.invoice_addr2}">
		<!-- // 송장발송 -->
     
		<!-- 팝업 -->
	    <div class="popup-wrap width-100per">
			<!-- 상세페이지 타이틀 -->
			<div class="main-title">
				<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
			</div>
			<!-- /상세페이지 타이틀 -->
	        <div class="content-wrap">	
				<div class="btn-group mt5" style="margin-bottom: 5px;">
					<div class="right">
					<c:if test="${transMst.part_trans_req_type_cd eq 'Stock 상세'}">
						<button type="button" class="btn btn-primary-gra" onclick="javascript:goHomiDtlPopup();">Stock 상세</button>
					</c:if>
					</div>
				</div>
				<!-- 폼테이블 -->	
				<!-- 상단 폼테이블 -->
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
								<th class="text-right">이동요청서번호</th>
								<td>
									<div class="col">
										<input type="text" class="form-control width120px" id="mst_part_trans_req_no" name="mst_part_trans_req_no" alt="요청서번호" value="${transMst.part_trans_req_no}" readonly="readonly">
									</div>
								</td>
								<th class="text-right">요청자</th>
								<td>
									<input type="text" class="form-control width100px" id="reg_name" name="reg_name" value="${transMst.reg_mem_name}" readonly="readonly">
								</td>
								<th class="text-right">요청처</th>
								<td>
									<input type="text" class="form-control width100px" id="to_warehouse" name="to_warehouse" value="${transMst.to_warehouse_name}" readonly="readonly">
									<input type="hidden" class="form-control width100px" id="mst_to_warehouse_cd" name="mst_to_warehouse_cd" value="${transMst.to_warehouse_cd}" readonly="readonly">
								</td>
								<th class="text-right">From창고</th>
								<td>
									<input type="text" class="form-control width100px" id="from_warehouse" name="from_warehouse" value="${transMst.from_warehouse_name}" readonly="readonly">
								</td>
							</tr>
							<tr>
								<th class="text-right essential-item">발송구분</th>
								<td colspan="3" style="padding-left: 9px;">
									<div class="form-row inline-pd">
										<div class="col-2">
											<select class="form-control width100px essential-bg" id="invoice_send_cd" name="invoice_send_cd" required="required" alt="전송구분">
												<c:forEach items="${codeMap['INVOICE_SEND']}" var="item">
												<option value="${item.code_value}" ${item.code_value == "0" ? 'selected' : '' }>${item.code_name}</option>
												</c:forEach>
											</select>
										</div>
										<div class="col-1.5">
											<button type="button" style="width: 100%;" class="btn btn-primary-gra" id="sendInvocieBtn" onclick="javascript:goSendInvoiceInfo();">배송정보설정</button>
										</div>
										<div class="col-8">
											<input type="text" class="form-control" maxlength="200" id="invoice_address" name="invoice_address" value="${transMst.invoice_address}" readonly="readonly">
										</div>
									</div>
								</td>
								<th class="text-right">비고</th>
								<td colspan="3">
									<input type="text" class="form-control" id="mst_remark" name="mst_remark" value="${transMst.remark}">
								</td>
							</tr>								
						</tbody>
					</table>
				</div>
				<!-- /상단 폼테이블 -->
	
				<!-- 하단 폼테이블 -->		
				<div class="row">
				<!-- 좌측 폼테이블 -->
					<div class="col" style="width: 50%;">
					<!-- 장비추가내역 -->
						<div class="title-wrap mt10">
							<h4>부품장바구니</h4>
							<button type="button" class="btn btn-default" onclick="javascript:fnCartCheckRemove();">체크 후 삭제</button>
						</div>
						<div id="auiGridLeft" style="margin-top: 5px; height: 390px;"></div>
						<!-- /장비추가내역 -->
					</div>
					<!-- /좌측 폼테이블 -->			
					<!-- 이동버튼 -->
					<div class="col btn-switch mt40">
						<button type="button" class="btn btn-default" id="partMoveRightBtn" onclick="javascript:fnAddRequest();"><i class="material-iconsarrow_right text-default"></i></button>
						<button type="button" class="btn btn-default" id="partMoveLeftBtn" onclick="javascript:fnReturnCart();"><i class="material-iconsarrow_left text-default"></i></button>
					</div>
					<!-- /이동버튼 -->						

					<!-- 우측 폼테이블 -->
					<div class="col" style="width: 45%;">
						<!-- 옵션품목 -->
						<div class="title-wrap mt10">
							<h4>요청예정목록</h4>
						</div>
						<div id="auiGridRight" style="margin-top: 5px; height: 390px;"></div>
						<!-- /옵션품목 -->

					</div>
					<!-- /우측 폼테이블 -->
				</div>
				<!-- /하단 폼테이블 -->	
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