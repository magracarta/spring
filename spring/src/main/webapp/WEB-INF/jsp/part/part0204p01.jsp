<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 창고이동/부품출하 > 선 주문 미 출하현황 > null > 선 주문 미 출하현황상세
-- 작성자 : 박예진
-- 최초 작성일 : 2021-07-21 15:30:33
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		$(document).ready(function() {
			createAUIGrid();
		});
	
		// 발주요청 체크
		function goOrderPart() {
			var frm = document.main_form;
	     	var gridData = AUIGrid.getGridData(auiGrid);

			if($M.getValue("to_warehouse_cd") == ""){
				alert("받는 창고(사업부)를 다시 확인해주세요.");
				return false;
			}
			
			if($M.validation(frm, {field:["request_remark"]}) == false) {
				return false;
			}
			
			var part_no_arr = [];
			var part_name_arr = [];
			var req_qty_arr = [];
			var in_qty_arr = [];
			var memo_arr = [];
			var preorder_inout_doc_no_arr = [];
			
			for(var i = 0; i < gridData.length; i++) {
				if(gridData[i].part_mng_cd != "8"){ // 22.10.19 비부품인 경우 발주요청X
					// 처리수량이 0이 아니면서 남은 발주요청수량보다 같거나 작은 것
					console.log("gridData[i].req_qty : ", gridData[i].req_qty);
					console.log("gridData[i].order_req_qty : ", gridData[i].order_req_qty);
					if(gridData[i].req_qty > 0) {
						if(gridData[i].req_qty <= gridData[i].order_req_qty) {
								part_no_arr.push(gridData[i].part_no);
								part_name_arr.push(gridData[i].part_name);
								req_qty_arr.push(gridData[i].req_qty);
								in_qty_arr.push(gridData[i].current_stock);	// 입고수량에 현재고 세팅
								memo_arr.push($M.getValue("request_remark"));
								preorder_inout_doc_no_arr.push($M.getValue("preorder_inout_doc_no"));
						} else {
							alert("남은 발주요청수량보다 낮은 처리수량을 입력해주세요.");
							return false;
						}
					}
				}
			}
			var partLength = $M.nvl(part_no_arr, 0);
			if(partLength <= 0) {
				alert("처리할 수량이 없습니다.\n처리수량 입력 후 다시 시도해주세요.");
				return false;
			}
			
			// 받는 창고를 사업부로 세팅
			$M.setValue("order_org_code", $M.getValue("to_warehouse_cd"));

			frm = $M.toValueForm(frm);
	     	
	     	var option = {
					isEmpty : true
			};
			
			$M.setValue(frm, "part_no_str", $M.getArrStr(part_no_arr, option));
			$M.setValue(frm, "part_name_str", $M.getArrStr(part_name_arr, option));
			$M.setValue(frm, "order_qty_str", $M.getArrStr(req_qty_arr, option));
			$M.setValue(frm, "in_qty_str", $M.getArrStr(in_qty_arr, option));
			$M.setValue(frm, "memo_str", $M.getArrStr(memo_arr, option));
			$M.setValue(frm, "preorder_inout_doc_no_str", $M.getArrStr(preorder_inout_doc_no_arr, option));
			
			// 이미 발주중인 발주요청인지 조회
			$M.goNextPageAjax(this_page + "/checkOrder", frm, { method : "GET", loader : false},
				function(result) {
					if(result.success) {
						// 발주요청된 자료일 경우 정말로 등록할것인지 다시 확인함
						if (result.msg) {
							if (confirm(result.msg + "\n부품은 이미 발주요청에 등록되어 있습니다.\n계속 진행하시겠습니까?") == false) {
								return false;
							} else {
								goOrderSave(frm);
							}	
						} else {
							// 발주요청된 자료가 아니면 그냥 저장
							goOrderSave(frm);
						}
					} 
				}
			);
		}
		
		// 발주요청 저장
		function goOrderSave(frm) {
			var msg = "발주 요청하시겠습니까?";
			
			$M.goNextPageAjaxMsg(msg, this_page + "/saveOrder", frm, { method : "POST"},
				function(result) {
					if(result.success) {
						alert("발주 요청 처리되었습니다.");
						location.reload();
					} 
				}
			);
		}
		
		// 부품이동요청 (선주문직발송)
		function goTransPart() {
			var frm = document.main_form;
	     	var gridData = AUIGrid.getGridData(auiGrid);
	     	
			// 콤보그리드 유효성 추가
			if($M.getValue("from_warehouse_cd") == ""){
				alert("보내는 창고는 필수입력입니다.");
				$('#from_warehouse_cd').next().find('input').focus()
				return false;
			}
			// 21.11.01 선주문에서 동일센터 이동처리 기능 추가됐다고 고객사에게 알릴 시
			// 126행~129행 주석 처리하면 됩니다. (아래 4행)
 			if($M.getValue("from_warehouse_cd") == $M.getValue("to_warehouse_cd")) {
 				alert("동일한 창고로는 이동할 수 없습니다.");
 				return false;
			}
			if($M.validation(frm, {field:["trans_reg_dt", "invoice_send_cd", "from_warehouse_cd", "from_warehouse_cd", "request_remark"]}) == false) {
				return false;
			}
			
			var part_no_arr = [];
			var part_name_arr = [];
			var req_qty_arr = [];
			var dtl_remark_arr = [];
			var preorder_inout_doc_no_arr = [];
			
			for(var i = 0; i < gridData.length; i++) {
				// 처리수량이 0이 아닌 것만
				if(gridData[i].req_qty > 0) {
					part_no_arr.push(gridData[i].part_no);
					part_name_arr.push(gridData[i].part_name);
					req_qty_arr.push(gridData[i].req_qty);
// 					dtl_remark_arr.push(gridData[i].remark);
					var remark = gridData[i].remark == "" ? $M.getValue("request_remark") : gridData[i].remark;
					dtl_remark_arr.push(remark);	//해당 비고 없으면 선주문 비고 들어가도록 변경
					preorder_inout_doc_no_arr.push($M.getValue("preorder_inout_doc_no"));
				}
			}
			
			var partLength = $M.nvl(part_no_arr, 0);
			if(partLength <= 0) {
				alert("처리할 수량이 없습니다.\n처리수량 입력 후 다시 시도해주세요.");
				return false;
			}
			
			frm = $M.toValueForm(frm);
	     	
	     	var option = {
					isEmpty : true
			};
			
			$M.setValue(frm, "part_no_str", $M.getArrStr(part_no_arr, option));
			$M.setValue(frm, "part_name_str", $M.getArrStr(part_name_arr, option));
			$M.setValue(frm, "req_qty_str", $M.getArrStr(req_qty_arr, option));
			$M.setValue(frm, "dtl_remark_str", $M.getArrStr(dtl_remark_arr, option));
			$M.setValue(frm, "preorder_inout_doc_no_str", $M.getArrStr(preorder_inout_doc_no_arr, option));

			$M.goNextPageAjaxMsg("이동요청서를 작성하시겠습니까?", this_page + "/saveTrans", frm, {method : "POST"},
				function(result) {
		    		if(result.success) {
		    			location.reload();
					};
				}
			); 
		}

		// 그리드생성
		function createAUIGrid() {
			var	gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn : true,
				showStateColumn : false,
				editable : true,
				// 행 소프트 제거 모드 해제
				softRemoveRowMode : true,
				rowIdTrustMode : true,
				rowStyleFunction :  function(rowIndex, item) { // 22.10.29 15267 비부품인 경우 회색
						if(item.part_mng_cd == "8") { // 비부품
							return "aui-status-complete";
					}
				}
			};
			
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{ 
					headerText : "부품번호", 
					dataField : "part_no", 
					width : "170",
					minWidth : "170",
					style : "aui-center",
					editable : false 
				},
				{
				    headerText: "부품명",
				    dataField: "part_name",
					width : "255",
					minWidth : "255",
					style : "aui-left",
					editable : false 
				},
				{
				    headerText: "현재고",
				    dataField: "current_stock",
					width : "70",
					minWidth : "70",
					style : "aui-center aui-popup",
					dataType : "numeric",
					formatString : "#,##0",
					editable : false
				},
				{
				    headerText: "가용재고",
				    dataField: "current_able_stock",
					width : "70",
					minWidth : "70",
					style : "aui-center",
					dataType : "numeric",
					formatString : "#,##0",
					editable : false
				},
				{
				    headerText: "선주문수량",
				    dataField: "preorder_qty",
					width : "70",
					minWidth : "70",
					style : "aui-center",
					dataType : "numeric",
					formatString : "#,##0",
					editable : false
				},
				{
				    headerText: "처리수량",
				    dataField: "req_qty",
					width : "70",
					minWidth : "70",
					style : "aui-center",
					dataType : "numeric",
					formatString : "#,##0",
					editable : true,
					editRenderer : {
						type : "InputEditRenderer",
						onlyNumeric : true, // 숫자만
						// 에디팅 유효성 검사
					    validator : function(oldValue, newValue, item) {
							var isValid = false;
							// 리턴값은 Object 이며 validate 의 값이 true 라면 패스, false 라면 message 를 띄움
							if(newValue <= item.mi_qty) {
								isValid = true;
							}
							return { "validate" : isValid, "message"  : "처리수량은 미 처리수량보다 높을 수 없습니다." };
						}
					},
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
		                 if(item.mi_qty == "0" || item.part_mng_cd == "8") {
				                 return null;
			                 };
		                    return "aui-editable";
						}
				},
				{
				    headerText: "미 이동처리수량",
				    dataField: "mi_qty",
					width : "100",
					minWidth : "100",
					style : "aui-center",
					dataType : "numeric",
					formatString : "#,##0",
					editable : false
				},
				{
				    headerText: "발주요청/승인수량",
				    dataField: "order_qty",
					width : "110",
					minWidth : "110",
					style : "aui-center",
					dataType : "numeric",
					formatString : "#,##0",
					editable : false
				},
				{
				    headerText: "비고",
				    dataField: "remark",
					width : "200",
					minWidth : "200",
					style : "aui-left",
					editable : false 
				},
				{
					dataField : "stock_qty",
					visible : false
				},
				{
					dataField : "stock_able_qty",
					visible : false
				},
				{
					headerText : "남은 발주요청수량", 
					dataField : "order_req_qty",
					visible : false
				},
				{
					dataField : "seq_no",
					visible : false
				},
				{
					dataField : "part_mng_cd",
					visible : false
				}

			];
		
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, ${list});
			AUIGrid.bind(auiGrid, "cellEditBegin", function (event) {
				if (event.dataField == "req_qty") {
					if(event.item["mi_qty"] == 0 || event.item["part_mng_cd"] == "8") {
						return false;
					} else {
						return true;
					}
				}
			});
			
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				// 현재고 셀 클릭 시 부품재고상세 팝업 호출
				 if(event.dataField == 'current_stock') {
					var param = {
							"part_no" : event.item["part_no"]
					};			
					var popupOption = "";
					$M.goNextPage('/part/part0101p01', $M.toGetParam(param),  {popupStatus : popupOption});
				};
			});
			
			$("#auiGrid").resize();
		}
		
		 // 배송정보 팝업
	    function goDeliveryInfo() {
	    	var params = {
    			to_warehouse_cd     : $M.getValue("to_warehouse_cd"),
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
	    
	   // 발송구분 갱신
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
		
	    // 수정
		function goModify() {
			var frm = document.main_form;
			
			if($M.validation(frm) === false) {
	     		return;
	     	};
	     	
			$M.goNextPageAjaxModify(this_page + "/modify", $M.toValueForm(frm), {method : 'POST'},
				function(result) {
			    	if(result.success) {
			    		location.reload();
					}
				}
			);
		}
	  
		// 매출상세
	    function goReferDetailPopup() {
	    	var param = {
	    			"inout_doc_no" : $M.getValue("preorder_inout_doc_no")
			}
			var poppupOption = "";
			$M.goNextPage('/cust/cust0202p01', $M.toGetParam(param), {popupStatus : poppupOption});
	    }
		
	    // 닫기
		function fnClose() {
			window.close();
		}
		
</script>
</head>
<body class="bg-white class">
<form id="main_form" name="main_form">
<!-- 송장발송 -->
	<!-- 송장발송번호 -->
	<input type="hidden" name="send_invoice_seq"   id="send_invoice_seq" 	 value="${map.send_invoice_seq}">
	<!-- 발송구분 -->
	<input type="hidden" name="invoice_type_cd"   id="invoice_type_cd" 	 value="${map.invoice_type_cd}">
	<!-- 송장번호 -->
	<input type="hidden" name="invoice_no" 		  id="invoice_no" 		 value="${map.invoice_no}">
	<!-- 수량 -->
	<input type="hidden" name="invoice_qty" 	  id="invoice_qty" 		 value="${map.invoice_qty}">
	<!-- 성명 -->
	<input type="hidden" name="receive_name" 	  id="receive_name" 	 value="${map.receive_name}">
	<!-- 전화번호 -->
	<input type="hidden" name="receive_tel_no" 	  id="receive_tel_no" 	 value="${map.receive_tel_no}">
	<!-- 핸드폰번호 -->
	<input type="hidden" name="receive_hp_no" 	  id="receive_hp_no" 	 value="${map.receive_hp_no}">
	<!-- 참고 -->	
	<input type="hidden" name="invoice_remark"    id="invoice_remark" 	 value="${map.invoice_remark}">		
	<!-- 송장비용방식코드 -->					
	<input type="hidden" name="invoice_money_cd"  id="invoice_money_cd"  value="${map.invoice_money_cd}">
	<!-- 우편번호 -->
	<input type="hidden" name="invoice_post_no"   id="invoice_post_no"   value="${map.invoice_post_no}">
	<!-- 주소1 -->
	<input type="hidden" name="invoice_addr1" 	  id="invoice_addr1"     value="${map.invoice_addr1}">
	<!-- 주소2 -->		
	<input type="hidden" name="invoice_addr2" 	  id="invoice_addr2"     value="${map.invoice_addr2}">
	<input type="hidden" id="cust_no" name="cust_no" value="${map.cust_no}">
	

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
				<table class="table-border">
					<colgroup>
						<col width="100px">
						<col width="100px">
						<col width="100px">
						<col width="100px">
						<col width="100px">
						<col width="100px">
						<col width="100px">
						<col width="100px">
						<col width="">
					</colgroup>
					<tbody>
						<tr> 
							<th class="text-right">전표일자</th>
							<td colspan="2">
								<div class="form-row inline-pd">
									<div class="col-auto">
										<div class="input-group">
											<input type="text" class="form-control border-right-0 width120px calDate sale-rb" style="width:120px;" disabled="disabled" id="inout_dt" name="inout_dt" dateformat="yyyy-MM-dd" alt="전표일자" value="${map.inout_dt}">	
										</div>
									</div>
									<div class="col-auto">
										<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_L"/></jsp:include>
									</div>
								</div>
							
							</td>
							<th class="text-right">전표번호</th>
							<td colspan="2">
								<input type="text" class="form-control width120px" id="preorder_inout_doc_no" name="preorder_inout_doc_no" readonly="readonly" value="${map.inout_doc_no}">
							</td>
							<th class="text-right">고객명</th>
							<td colspan="2">
								<input type="text" class="form-control width120px" id="cust_name" name="cust_name" readonly="readonly" value="${map.cust_name}">
							</td>
							<th class="text-right">센터</th>
							<td colspan="2">
								<input type="text" class="form-control width120px" id="inout_org_code" name="inout_org_code" readonly="readonly" value="${map.inout_org_name}">
							</td>
						</tr>
						<tr>
							<th class="text-right">금액</th>
							<td colspan="2">
								<div class="form-row inline-pd">
									<div class="col-auto">
										<input type="text" class="form-control width120px text-right" id="doc_amt" name="doc_amt" readonly="readonly" value="${map.doc_amt}" format="decimal">	
									</div>
									<div class="col-auto">원</div>
								</div>
							</td>
							<th class="text-right">부가세포함</th>
							<td colspan="2">
								<div class="form-row inline-pd">
									<div class="col-auto">
										<input type="text" class="form-control width120px text-right" id="total_amt" name="total_amt" readonly="readonly" value="${map.total_amt}" format="decimal">	
									</div>
									<div class="col-auto">원</div>
								</div>
							</td>
							<th class="text-right">입금여부</th>
							<td colspan="2">
								<input type="text" class="form-control width120px" id="acct_yn" name="acct_yn" readonly="readonly" value="${map.acct_yn}">
							</td>
							<th class="text-right">작성자</th>
							<td colspan="2">
								<input type="text" class="form-control width120px" id="mem_name" name="mem_name" readonly="readonly" value="${map.mem_name}">
							</td>
						</tr>
						<tr>
							<th class="text-right">배송상태</th>
							<td colspan="2">
								<input type="text" class="form-control width120px" id="delivery_yin" name="delivery_yin" readonly="readonly" value="${map.delivery_yin}">	
							</td>
							<th class="text-right">마감여부</th>
							<td colspan="2">
								<input type="text" class="form-control width120px" id="doc_end_yn" name="doc_end_yn" readonly="readonly" value="${map.end_yn}">	
							</td>
							<th class="text-right">입금일</th>
							<td colspan="2">
								<input type="text" class="form-control width120px sale-rb" id="acct_dt" name="acct_dt" readonly="readonly" dateformat="yyyy-MM-dd" value="${map.acct_dt}">	
							</td>
							<th class="text-right">전표비고</th>
							<td colspan="2">
								<input type="text" class="form-control" id="remark" name="remark" readonly="readonly" value="${map.remark}">
							</td>
						</tr>
						<tr>
							<th class="text-right rs">보내는창고</th>
							<td colspan="5">
								<div class="form-row inline-pd">
								<c:choose>
									<c:when test="${ page.fnc.F03104_001 eq 'Y' }">
										<div class="col-6">
											<input type="text" class="form-control border-right-0" style="width:100%;" alt="보내는 창고" required="required"
												id="from_warehouse_cd"
												name="from_warehouse_cd" 
												idfield="code_value"
												textfield="code_name"
												easyui="combogrid"
												header="Y"
												easyuiname="fromWarehouseList" 
												panelwidth="180"
												maxheight="155"
												multi="N"/>
										</div>
										</c:when>
										<c:otherwise>
											<div class="col-3">
												<input type="text" class="form-control width100px" value="${SecureUser.part_org_code}" id="from_warehouse_cd" name="from_warehouse_cd" readonly="readonly" required="required" alt="보내는 창고"> 
											</div>
											<div class="col-3">
												<input type="text" class="form-control width100px" value="${SecureUser.part_org_name}" readonly="readonly">
											</div>
										</c:otherwise>
										</c:choose>
									<div class="col-2">
											에서
									</div>	
								</div>		
							</td>
							<th class="text-right rs">받는창고</th>
							<td colspan="5">
								<div class="form-row inline-pd">
										<div class="col-3">
											<input type="text" class="form-control width100px" readonly="readonly" value="${map.inout_org_code}" id="to_warehouse_cd" name="to_warehouse_cd" required="required" alt="받는 창고">
										</div>
										<div class="col-3">
											<input type="text" class="form-control width100px" readonly="readonly" value="${map.inout_org_name}">
										</div>
										<div class="col-3">
											로 이동 요청
										</div>						
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">발송구분</th>
							<td colspan="5">
								<div class="form-row inline-pd">
									<div class="col-2">
										<select class="form-control width100px essential-bg" id="invoice_send_cd" name="invoice_send_cd" required="required" alt="발송구분">
											<c:forEach items="${codeMap['INVOICE_SEND']}" var="item">
											<option value="${item.code_value}" <c:if test="${item.code_value eq map.invoice_send_cd}">selected</c:if>>${item.code_name}</option>
											</c:forEach>
										</select>
									</div>
									<div class="col-2">
										<button type="button" style="width: 100%;" class="btn btn-primary-gra" onclick="javascript:goDeliveryInfo();">배송정보설정</button>
									</div>
									<div class="col-8">
										<input type="text" class="form-control" maxlength="200" id="invoice_address" name="invoice_address" value="${map.invoice_address}" readonly="readonly">
									</div>
								</div>
							</td>
							<th class="text-right essential-item">이동요청일자</th>
							<td colspan="2">
								<div class="input-group">
									<input type="text" class="form-control border-right-0 width120px calDate sale-rb" style="width:120px;" id="reg_dt" name="reg_dt" dateformat="yyyy-MM-dd" alt="이동요청일자" value="${inputParam.s_current_dt}">	
								</div>
							</td>
							<th class="text-right essential-item">이동/발주 비고</th>
							<td colspan="2">
								<input type="text" class="form-control sale-rb" id="request_remark" name="request_remark" maxlength="98" required="required" alt="비고">
							</td>
						</tr>		
					</tbody>
				</table>
			</div>
<!-- /폼테이블 -->	

				<!-- 하단 폼테이블 -->		
				<div class="row">					
					<div class="col" style="width: 100%;">
						<div class="title-wrap mt5">
							<h4>처리예정목록</h4>
						</div>
						<div id="auiGrid" style="margin-top: 5px; height: 350px;width:100%;"></div>
					</div>
				</div>
				<!-- /하단 폼테이블 -->	
				<!-- /이동요청서 상세 -->
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