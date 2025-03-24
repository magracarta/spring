<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 창고이동/부품출하 > 부품이동요청 > 부품이동요청등록 > null
-- 작성자 : 손광진
-- 최초 작성일 : 2020-02-25 16:01:33
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		$(document).ready(function() {
			createLeftAUIGrid();
			createRightAUIGrid();
			
			// fromwarehouse 콤보그리드 목록 클릭 시 장바구니 조회 
			$(document).on("click", ".datagrid-row", function() {
				fromWarehouseCheck();
			});
			
			// fromwarehouse 콤보그리드 x버튼 클릭 시 장바구니 조회 
			$(document).on("click", ".icon-clear", function() {
				fromWarehouseCheck();
			});

			// fromwarehouse 콤보그리드 focusout 시 장바구니 조회
			$("#_easyui_textbox_input1").focusout(function() {
				fromWarehouseCheck();
			});
			
			// fromwarehouse 콤보그리드 focusin 시 code_name 리셋
			$("#_easyui_textbox_input1").focusin(function() {
	    		$('#mst_from_warehouse_cd').combogrid("setText", "");
			});

		});
		
		// 부품 장바구니 조회
		function goSearch() {
			
			if($M.validation(document.main_form, {field:["mst_to_warehouse_cd"]}) == false) {
				return;
			}
			
			var param = {
				s_to_warehouse_cd 	: $M.getValue("mst_to_warehouse_cd"),
				s_from_warehouse_cd : $M.getValue("mst_from_warehouse_cd"),
				s_sort_key : "a.part_trans_cart_seq",
				s_sort_method : "desc"
			};
			
			$M.goNextPageAjax(this_page + "/search" , $M.toGetParam(param), {method : "get"},
				function(result) {
					if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGridLeft, result.list);
						AUIGrid.setGridData(auiGridRight, []);	// 요청예정목록 초기화
					};
				}
			);
		}
		
		// fromwarehouse 값이 기존값과 다르면 부품장바구니 조회
		function fromWarehouseCheck() {
			var mst_from_cd_new 	= $M.getValue("mst_from_warehouse_cd");		// mst_from_warehouse_cd 최신값		
			var mst_from_cd_check   = $M.getValue("mst_from_cd_last");			// 마지막에 클릭 한 mst_from_warehouse_cd

			if(mst_from_cd_check !=  mst_from_cd_new) {
				$M.setValue("mst_from_cd_last", mst_from_cd_new);
				goSearch();
			};			
		}
		
		//갱신
		function fnNewSendInvoice() {
			var param = {
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
		
		
		// 그리드생성
		function createLeftAUIGrid() {
			var gridPros = {
				rowIdField : "part_trans_cart_seq",
				showRowNumColumn : true,
				//체크박스 출력 여부
				showRowCheckColumn : true,
				//전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
				showStateColumn : true,
				editable : true,
				// 행 소프트 제거 모드 해제
				softRemoveRowMode : false,
				rowIdTrustMode : true
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
				    headerText: "처리일자",
				    dataField: "reg_date",
				    dataType : "date",   
					width : "15%",
					style : "aui-center",
					formatString : "yyyy-mm-dd",
					editable : false 
				},
				{
					headerText : "부품번호",
					dataField : "part_no",
					width: "20%",
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
				    dataField: "req_qty",
					width : "5%",
					style : "aui-center aui-editable",
					dataType : "numeric",
					formatString : "#,##0",
					editable : true,
				},
				{
				    headerText: "FROM",
				    dataField: "from_warehouse_name",
					width : "10%",
					style : "aui-center",
					editable : false 
				},
				{
				    headerText: "To",
				    dataField: "to_warehouse_name",
					width : "10%",
					style : "aui-center",
					editable : false 
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
					width : "8%",
					style : "aui-center",
					editable : false
				},
// 				{
// 				    headerText: "삭제",
// 				    renderer : {
// 						type : "ButtonRenderer",
// 						labelText : "삭제",
// 						onClick : function(event) {
// 							goCartDelete(event.item.part_trans_cart_seq);
// 						},
// 				    },
// 				    editable : false,
// 					style : "aui-left"
// 				},
				{
				    headerText: "처리_NO",
				    dataField: "reg_id",
					width : "8%",
					style : "aui-center",
					editable : false,
					visible : false
				},
				{
					headerText: "FROM코드",
				    dataField: "from_warehouse_cd",
					style : "aui-left",
					editable : false,
					visible : false
				},
				{
					headerText: "TO코드",
				    dataField: "to_warehouse_cd",
					style : "aui-left",
					editable : false,
					visible : false
				},
				{
					headerText: "FROM현재고",
				    dataField: "current_stock",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-left",
					editable : false,
					visible : false
				}
			];
			auiGridLeft = AUIGrid.create("#auiGridLeft", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridLeft, listJson);
			// 클릭한 셀 데이터 받음
 			AUIGrid.bind(auiGridLeft, "cellClick", function(event) {
 				AUIGrid.bind(auiGridLeft, "cellClick", cellClickHandler);
			});
		}
		
		// 그리드생성
		function createRightAUIGrid() {
			var gridPros = {
				rowIdField : "part_trans_cart_seq",
				showRowNumColumn : true,
				//체크박스 출력 여부
				showRowCheckColumn : true,
				//전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
				rowIdTrustMode : true,
				editable : true
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
					headerText : "부품번호",
					dataField : "part_no",
					width: "20%",
					style : "aui-center",
					editable : false,
				},
				{
				    headerText: "부품명",
				    dataField: "part_name",
					width : "30%",
					style : "aui-center",
					editable : false,
				},
				{
				    headerText: "비고",
				    dataField: "remark",
					width : "30%",
					style : "aui-left aui-editable",
					editable : true,
				},
				{
				    headerText: "FROM현재고",
				    dataField: "current_stock",
					width : "13%",
					style : "aui-center",
					dataType : "numeric",
					formatString : "#,##0",
					editable : false,		
				},
				{
				    headerText: "수량",
				    dataField: "req_qty",
				    width : "5%",
					style : "aui-center aui-editable",
					dataType : "numeric",
					formatString : "#,##0",
					editable : true,
				},
				{
				    headerText: "미처리량",
				    dataField: "mi_qty",
				    width : "10%",
					style : "aui-center",
					dataType : "numeric",
					formatString : "#,##0",
					editable : false,
				},
				{
					headerText: "FROM코드",
				    dataField: "from_warehouse_cd",
					style : "aui-left",
					visible : false,
					editable : false,
				},
				{
					headerText: "TO코드",
				    dataField: "to_warehouse_cd",
					style : "aui-left",
					visible : false,
					editable : false,
				},
				{
					headerText: "장바구니 일련번호",
				    dataField: "part_trans_cart_seq",
					style : "aui-left",
					visible : false,
					editable : false,
				},
				{
					headerText: "장바구니 요청개수",
				    dataField: "cart_req_qty",
					style : "aui-center",
					dataType : "numeric",
					formatString : "#,##0",
					visible : false,
					editable : false,
				},
				{
					headerText: "장바구니 비고",
				    dataField: "cart_remark",
					style : "aui-center",
					visible : false,
					editable : false,
				},
			];
			auiGridRight = AUIGrid.create("#auiGridRight", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridRight, []);
			// 클릭한 셀 데이터 받음
 			AUIGrid.bind(auiGridRight, "cellClick", function(event) {
 				AUIGrid.bind(auiGridRight, "cellClick", cellClickHandler);
			});
		}
		
		// 부품장바구니 데이터 요청예정목록으로 이동
		function fnAddRequest() {
			// 그리드의 체크된 행들 얻기
			var rows = AUIGrid.getCheckedRowItemsAll(auiGridLeft);
			console.log("right", rows);
			
			// 선택된 행이 없을 때
			if(rows.length < 1) {
				alert("장바구니에 선택된 행이 없습니다.");
				return;
			};
			
			if($M.nvl($M.getValue("mst_from_warehouse_cd"),"") === "") {
				alert("FROM창고를 선택해주세요.");
				$(".combo-arrow").click();
				$("#_easyui_textbox_input1").clear;
				return;
			} 	

			// 미처리량 컬럼 세팅 장바구니 수량 = 미처리량
			for(var i=0, len=rows.length; i<len; i++) {
			    rows[i]["mi_qty"] = rows[i]["req_qty"];
			}
			
			// 기존 장바구니 요청수량 
			for(var i=0, len=rows.length; i<len; i++) {
			    rows[i]["cart_req_qty"] = rows[i]["req_qty"];
			}

			// 기존 장바구니 비고
			for(var i=0, len=rows.length; i<len; i++) {
			    rows[i]["cart_remark"] = rows[i]["remark"];
			}
			
			// 얻은 행을 요청예정목록 그리드에 추가하기
			AUIGrid.addRow(auiGridRight, rows, "last");

			// 삭제하면  "이동" 이고, 삭제하지 않으면 "복사" 를 구현할 수 있음.
			AUIGrid.removeCheckedRows(auiGridLeft);
		}
		
		// 장바구니  (2021-06-29 SR처리. 일괄삭제요청) 
// 		function goCartDelete(seq) {
// 			var cartSeq = seq;	// 받아온 장바구니일련번호
// 			var param = {
// 				"part_trans_cart_seq"	: cartSeq
// 			};
// 			$M.goNextPageAjaxRemove(this_page + "/remove", $M.toGetParam(param), { method : "POST"},
// 				function(result) {
// 					if(result.success) {
// 						AUIGrid.clearGridData(auiGridLeft);
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
			
			$M.goNextPageAjax(this_page + "/remove", $M.toGetParam(param), { method : "POST"},
				function(result) {
					if(result.success) {
						AUIGrid.removeRowByRowId(auiGridLeft, checkDataArr);
						alert("장바구니 삭제가 완료되었습니다.");
					};
				}
			);
		}
		
		// 요청예정목록데이터 부품장바구니로 이동
		function fnReturnCart() {
			// 그리드의 체크된 행들 얻기
			var rows = AUIGrid.getCheckedRowItemsAll(auiGridRight);
			// 선택된 행이 없을 때
			if(rows.length < 1) {
				alert("요청예정목록에 선택된 행이 없습니다.");
				return;
			};
			
			// 기존 장바구니 요청개수
			for(var i=0, len=rows.length; i<len; i++) {
			    rows[i]["req_qty"] = rows[i]["cart_req_qty"];
			}
			
			// 기존 장바구니 비고
			for(var i=0, len=rows.length; i<len; i++) {
			    rows[i]["remark"] = rows[i]["cart_remark"];
			}
			
			// 얻은 행을 부품장바구니목록에 추가
			AUIGrid.addRow(auiGridLeft, rows, "last");
			// 삭제하면  "이동" 이고, 삭제하지 않으면 "복사" 를 구현할 수 있음.
			AUIGrid.removeCheckedRows(auiGridRight);
		}
		
		// 이동요청서 내용저장(요청서등록X)
		function goSave() {
			if (confirm("해당주문서는 [저장]만 됩니다. 이동처리를 진행하시려면\n[이동요청]을 해주시기 바랍니다.") == false) {
				return false;
			}else{
				saveTransPart("save");
			}
		}
		
		// 이동요청서 등록
		function goTransPart() {
			saveTransPart("trans");
		}

		// 이동요청서 등록 or 이동요청서 내용저장
		function saveTransPart(str) {
			
			var fromWarehouseCd =  $M.nvl($M.getValue("mst_from_warehouse_cd"), "");
			var toWarehouseCd 	=  $M.nvl($M.getValue("mst_to_warehouse_cd"), "");
			
			if(fromWarehouseCd === "") {
				alert("FROM창고를 선택해주세요.");
				return;
			}; 	

			if(fromWarehouseCd == toWarehouseCd) {
				alert("from창고와 to창고는 같을 수 없습니다.");
				return;
			};

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
			
			var rowCount 	= AUIGrid.getRowCount(auiGridRight);
			var complete_yn = "N";	// 이동요청서 작성여부 N : 대기, Y : 완료
			
			if(rowCount == 0) {
				alert("요청예정목록에 값이 없습니다.");
				return false;
			};
			
			var transItems = AUIGrid.getGridData(auiGridRight);
			
			// 요청서목록 요청수량 체크
			for(var i=0, len=transItems.length; i<len; i++) {
			    if(transItems[i]["req_qty"] <= 0) {
			    	alert("요청예정목록 요청 수량을 확인해 주세요.");
			    	return;
			    };
			};
			
			var frm = document.main_form;
			frm = $M.toValueForm(frm);
			var gridForm = fnChangeGridDataToForm(auiGridRight);
			
			var msg = "저장하시겠습니까?"; 
			
			if(str == "trans") {
				complete_yn = "Y"; // 이동요청서 작성
				msg = "이동요청서를 작성 하시겠습니까?";
			};

			// grid form 안에 frm 카피
			$M.copyForm(gridForm, frm);

			$M.goNextPageAjaxMsg(msg, this_page + "/save/" + complete_yn, gridForm, {method : "POST"},
				function(result) {
		    		if(result.success) {
		    			history.back();
					};
				}
			);
		}
		
		// 셀 클릭으로 엑스트라 체크박스 체크/해제 하기
		function cellClickHandler(event) {
			
			if(event.pid == "#auiGridLeft") {
				if(event.columnIndex == 3 || event.columnIndex == 6 || event.columnIndex == 8 ) {
					return;
				};
			} else if(event.pid == "#auiGridRight") {
				if(event.columnIndex == 2 || event.columnIndex == 4 ) {
					return;
				};
			};
			
			var item = event.item, rowIdField, rowId;
			rowIdField = AUIGrid.getProp(event.pid, "rowIdField"); // rowIdField 얻기
			rowId = item[rowIdField];
			// 이미 체크 선택되었는지 검사
			if(AUIGrid.isCheckedRowById(event.pid, rowId)) {
				// 엑스트라 체크박스 체크해제 추가
				AUIGrid.addUncheckedRowsByIds(event.pid, rowId);
			} else {
				// 엑스트라 체크박스 체크 추가
				AUIGrid.addCheckedRowsByIds(event.pid, rowId);
			}
		};
		
		
	    // 배송정보 팝업
	    function goDeliveryInfo() {

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
	    	};
	    	
	    	openDeliveryInfoPanel('setDeliveryInfo', $M.toGetParam(params));
	    }
	    
	    // 배송정보 callback
	    function setDeliveryInfo(data) {
	    	fnNewSendInvoice();
	    	$M.setValue(data);
			$M.setValue("invoice_address", data.invoice_addr1 + " " + data.invoice_addr2)
	    }
		
		
		function fnList() {
			history.back(); 
		}	
		
	</script>
</head>
<body>
	<form id="main_form" name="main_form">
		<!-- 부품이동요청타입(장바구니) -->
		<input type="hidden" class="form-control" id="part_trans_req_type_cd" name="part_trans_req_type_cd" value="CART">
		<!-- 입력받은 from창고 콤보그리드 -->
		<input type="hidden" class="form-control" id="mst_from_cd_last" name="mst_from_cd_last" value="">
		
	<!-- 송장발송 -->
		<!-- 발송구분 -->
		<input type="hidden" name="invoice_type_cd"   id="invoice_type_cd" 	 value="99">
		<!-- 송장번호 -->
		<input type="hidden" name="invoice_no" 		  id="invoice_no" 		 value="">
		<!-- 수량 -->
		<input type="hidden" name="invoice_qty" 	  id="invoice_qty" 		 value="">
		<!-- 성명 -->
		<input type="hidden" name="receive_name" 	  id="receive_name" 	 value="${sendInvoice.receive_name}">
		<!-- 전화번호 -->
		<input type="hidden" name="receive_tel_no" 	  id="receive_tel_no" 	 value="${sendInvoice.receive_tel_no}">
		<!-- 핸드폰번호 -->
		<input type="hidden" name="receive_hp_no" 	  id="receive_hp_no" 	 value="${sendInvoice.receive_hp_no}">
		<!-- 참고 -->	
		<input type="hidden" name="invoice_remark"    id="invoice_remark" 	 value="">		
		<!-- 송장비용방식코드 -->					
		<input type="hidden" name="invoice_money_cd"  id="invoice_money_cd"  value="">
		<!-- 우편번호 -->
		<input type="hidden" name="invoice_post_no"   id="invoice_post_no"   value="${sendInvoice.invoice_post_no}">
		<!-- 주소1 -->
		<input type="hidden" name="invoice_addr1" 	  id="invoice_addr1"     value="${sendInvoice.invoice_addr1}">
		<!-- 주소2 -->		
		<input type="hidden" name="invoice_addr2" 	  id="invoice_addr2"     value="${sendInvoice.invoice_addr2}">
	<!-- // 송장발송 -->
		
		<div class="layout-box">
			<!-- contents 전체 영역 -->
			<div class="content-wrap">
				<div class="content-box">
					<!-- 상세페이지 타이틀 -->
					<div class="main-title detail">
						<div class="detail-left">
							<button type="button" class="btn btn-outline-light" onclick="javascript:history.back();"><i class="material-iconskeyboard_backspace text-default"></i></button>
							<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
						</div>
					</div>
					<!-- /상세페이지 타이틀 -->
					<div class="contents">
					<!-- 폼테이블 -->	
						<!-- 상단 폼테이블 -->	
						<div>
							<table class="table-border">
								<colgroup>
									<col width="70px">
									<col width="">
									<col width="70px">
									<col width="">
									<col width="70px">
									<col width="">
									<col width="70px">
									<col width="">
								</colgroup>
								<tbody>
									<tr>
										<th class="text-right essential-item">요청일자</th>
										<td>
											<div class="input-group">
												<input type="text" class="form-control border-right-0 width120px calDate rb" id="reg_dt" name="reg_dt" dateformat="yyyy-MM-dd" alt="요청일" value="${inputParam.s_current_dt}" required="required">
											</div>
										</td>
										<th class="text-right">요청자</th>
										<td>
											<div class="col">
												<input type="text" class="form-control width100px"   id="mst_reg_name" name="mst_reg_name" readonly="readonly" value="${userInfo.kor_name}">
												<input type="hidden" class="form-control width100px" id="mst_mem_no"   name="mst_mem_no"   readonly="readonly" value="${userInfo.mem_no}">
											</div>
										</td>
										<th class="text-right">To창고</th>
										<td>
											<div class="col">
												<input type="text" class="form-control width100px" id="mst_to_warehouse_name" name="mst_to_warehouse_name" readonly="readonly" value="${SecureUser.warehouse_name}">
												<input type="hidden" class="form-control width100px" id="mst_to_warehouse_cd" name="mst_to_warehouse_cd" readonly="readonly" value="${SecureUser.warehouse_cd}" alt="To창고">
											</div>
										</td>
					
										<!-- 콤보그리드 -->
										<th class="text-right essential-item">From창고</th>	
										<td>
											<!-- 로그인 계정이 본사인 경우, 창고목록 콤보그리드 선택가능 -->
											<!-- 로그인 계정이 본사가 아닌 경우 해당부서코드 Set -->
											<c:choose>
												<c:when test="${page.fnc.F00424_001 eq 'Y'}">
													<input type="text" style="width : 200px";
														value=""
														id="mst_from_warehouse_cd" 
														name="mst_from_warehouse_cd"
														alt="From창고" 
														idfield="code_value"
														easyui="combogrid"
														enter="fromWarehouseCheck()"
														header="Y"
														easyuiname="warehouseList" 
														panelwidth="200"
														maxheight="155"
														textfield="code_name"
														multi="N"/>
												</c:when>
												<c:when test="${page.fnc.F00424_002 eq 'Y'}">
													<div class="col width100px">
														<input type="text" class="form-control" value="${partOrgName}" readonly="readonly">
														<input type="hidden" value="${partOrgCode}" id="mst_from_warehouse_cd" name="mst_from_warehouse_cd" readonly="readonly">
													</div> 
												</c:when>
												<c:when test="${page.fnc.F00424_003 eq 'Y'}">
													<input type="text" style="width : 200px";
														value=""
														id="mst_from_warehouse_cd" 
														name="mst_from_warehouse_cd"
														alt="From창고" 
														idfield="code_value"
														easyui="combogrid"
														enter="fromWarehouseCheck()"
														header="Y"
														easyuiname="warehouseList" 
														panelwidth="200"
														maxheight="155"
														textfield="code_name"
														multi="N"/>
												</c:when>
											</c:choose>
										</td>
											
									</tr>
									<tr>
										<th class="text-right essential-item">발송구분</th>
										<td colspan="3" style="padding-left: 9px;">
											<div class="form-row inline-pd">
												<div class="col-1.5">
													<select class="form-control width100px essential-bg" id="invoice_send_cd" name="invoice_send_cd" required="required" alt="전송구분">
														<c:forEach items="${codeMap['INVOICE_SEND']}" var="item">
														<option value="${item.code_value}">${item.code_name}</option>
														</c:forEach>
													</select>
												</div>
												<div class="col-1.5">
													<button type="button" style="width: 100%;" class="btn btn-primary-gra" onclick="javascript:goDeliveryInfo();">배송정보설정</button>
												</div>
												<div class="col-8">
													<input type="text" class="form-control" maxlength="200" id="invoice_address" name="invoice_address" value="${sendInvoice.invoice_address}" readonly="readonly">
												</div>
											</div>
										</td>
										<th class="text-right">비고</th>
										<td colspan="3">
											<input type="text" class="form-control" id="mst_remark" name="mst_remark" maxlength="200">
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
								<div id="auiGridLeft" style="margin-top: 5px; height: 520px;"></div>
								<!-- /장비추가내역 -->
							</div>
							<!-- /좌측 폼테이블 -->
							<!-- 이동버튼 -->
							<div class="col btn-switch mt40">
								<button type="button" class="btn btn-default" onclick="javascript:fnAddRequest();"><i class="material-iconsarrow_right text-default"></i></button>
								<button type="button" class="btn btn-default" onclick="javascript:fnReturnCart();"><i class="material-iconsarrow_left text-default"></i></button>
							</div>
							<!-- /이동버튼 -->						
	
							<!-- 우측 폼테이블 -->
							<div class="col" style="width: 45%;">
								<!-- 옵션품목 -->
								<div class="title-wrap mt10">
									<h4>요청예정목록</h4>
								</div>
								<div id="auiGridRight" style="margin-top: 5px; height: 520px;"></div>
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
				<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>		
			</div>
			<!-- /contents 전체 영역 -->	
		</div>	
	</form>
</body>
</html>