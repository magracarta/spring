<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 부품연관팝업 > 부품연관팝업 > null > 부품일괄이동요청
-- 작성자 : 박예진
-- 최초 작성일 : 2021-02-02 19:53:41
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
	// 선주문 관련 추가 필요. 기획 정해지면 진행
		$(document).ready(function() {
			createAUIGrid();
		});
	
		// 부품이동요청
		function goTransPart() {
			
			// 콤보그리드 유효성 추가
			if($M.getValue("from_warehouse_cd") == ''){
				alert("보내는 창고는 필수입력입니다.");
				$('#from_warehouse_cd').next().find('input').focus()
				return;
			}
			if($M.getValue("from_warehouse_cd") == $M.getValue("to_warehouse_cd")) {
				alert("동일한 창고로는 이동할 수 없습니다.");
				return;
			}

			var gridData = AUIGrid.getGridData(auiGrid);

			var sumQty = 0;
			var cnt = 0;
			
			for(var i=0, len = gridData.length; i < len; i++) {
				sumQty += gridData[i]["req_qty"];
				if(gridData[i].part_use_yn == "Y") {
					cnt++;
				}
			}
			
			if(gridData.length < 1 || sumQty === 0 || cnt === 0) {
				alert("이동요청할 부품이 없습니다.");
				return false;
			}
			
			var frm = document.main_form;
			frm = $M.toValueForm(frm);
			
			var partNo = [];
			var qty	= [];
			var fromWarehouseCd	= [];
			var toWarehouseCd = [];
			var remark 	= [];
			var partName 	= [];

			for(var i = 0, n = gridData.length; i < n; i++) {
				if(gridData[i].part_use_yn == "Y" && gridData[i].req_qty > 0) {
					partNo.push(gridData[i].part_no);
					qty.push(gridData[i].req_qty);
					partName.push(gridData[i].part_name);
					fromWarehouseCd.push($M.getValue("from_warehouse_cd"));
					toWarehouseCd.push($M.getValue("to_warehouse_cd"));
					remark.push(gridData[i].remark);
						
				}
			}
			
			var option = {
				isEmpty : true
			};
			
			$M.setValue(frm, "part_no_str", $M.getArrStr(partNo, option));
			$M.setValue(frm, "req_qty_str", 	$M.getArrStr(qty, option));
			$M.setValue(frm, "part_name_str", 	$M.getArrStr(partName, option));
// 			$M.setValue(frm, "from_warehouse_cd_str", 	$M.getArrStr(fromWarehouseCd, option));
// 			$M.setValue(frm, "to_warehouse_cd_str", 	$M.getArrStr(toWarehouseCd, option));
			$M.setValue(frm, "remark_str", $M.getArrStr(remark, option));
				
			$M.goNextPageAjaxMsg("이동요청서를 작성하시겠습니까?", this_page + "/save", $M.toValueForm(frm), {method : "POST"},
				function(result) {
		    		if(result.success) {
		    			fnClose();
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
				rowIdTrustMode : true
			};
			
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{ 
					headerText : "부품번호", 
					dataField : "part_no", 
					width : "180",
					minWidth : "180",
					style : "aui-center",
					editable : false 
				},
				{
				    headerText: "부품명",
				    dataField: "part_name",
					width : "280",
					minWidth : "280",
					style : "aui-left",
					editable : false 
				},
				{
				    headerText: "미결수량",
				    dataField: "mi_qty",
					width : "60",
					minWidth : "60",
					style : "aui-center",
					dataType : "numeric",
					formatString : "#,##0",
					editable : false
				},
				{
				    headerText: "요청수량",
				    dataField: "req_qty",
					width : "60",
					minWidth : "60",
					style : "aui-center aui-editable",
					dataType : "numeric",
					formatString : "#,##0",
					editable : true,
					editRenderer : {
						type : "InputEditRenderer",
						onlyNumeric : true, // 숫자만
					},
				},
				{
				    headerText: "비고",
				    dataField: "remark",
					width : "370",
					minWidth : "370",
					style : "aui-left aui-editable",
					editable : true
				},
				{
					headerText : "삭제",
					dataField : "removeBtn",
					width : "55",
					minWidth : "55",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							var isRemoved = AUIGrid.isRemovedById(auiGrid, event.item._$uid);
							if (isRemoved == false) {
								AUIGrid.updateRow(auiGrid, {part_use_yn : "N"}, event.rowIndex);
								AUIGrid.removeRow(event.pid, event.rowIndex);
							} else {
								AUIGrid.restoreSoftRows(auiGrid, "selectedIndex"); 
								AUIGrid.updateRow(auiGrid, {part_use_yn : "Y"}, event.rowIndex);
							};
						},
					},
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						return '삭제'
					},
					style : "aui-center",
					editable : false,
				},
				{
				    dataField: "part_use_yn",
				    visible : false
				},
			];
		
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, ${list});

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
		
		
		function fnClose() {
			window.close();
		}
		
</script>
</head>
<body class="bg-white class">
<form id="main_form" name="main_form">
<!-- 송장발송 -->
	<!-- 발송구분 -->
	<input type="hidden" name="invoice_type_cd"   id="invoice_type_cd" 	 value="99">
	<!-- 송장번호 -->
	<input type="hidden" name="invoice_no" 		  id="invoice_no" 		 value="">
	<!-- 수량 -->
	<input type="hidden" name="invoice_qty" 	  id="invoice_qty" 		 value="${inputParam.invoice_qty}">
	<!-- 성명 -->
	<input type="hidden" name="receive_name" 	  id="receive_name" 	 value="${inputParam.receive_name}">
	<!-- 전화번호 -->
	<input type="hidden" name="receive_tel_no" 	  id="receive_tel_no" 	 value="${inputParam.receive_tel_no}">
	<!-- 핸드폰번호 -->
	<input type="hidden" name="receive_hp_no" 	  id="receive_hp_no" 	 value="${inputParam.receive_hp_no}">
	<!-- 참고 -->	
	<input type="hidden" name="invoice_remark"    id="invoice_remark" 	 value="${inputParam.invoice_remark}">		
	<!-- 송장비용방식코드 -->					
	<input type="hidden" name="invoice_money_cd"  id="invoice_money_cd"  value="${inputParam.invoice_money_cd}">
	<!-- 우편번호 -->
	<input type="hidden" name="invoice_post_no"   id="invoice_post_no"   value="${inputParam.invoice_post_no}">
	<!-- 주소1 -->
	<input type="hidden" name="invoice_addr1" 	  id="invoice_addr1"     value="${inputParam.invoice_addr1}">
	<!-- 주소2 -->		
	<input type="hidden" name="invoice_addr2" 	  id="invoice_addr2"     value="${inputParam.invoice_addr2}">

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
						<col width="300px">
						<col width="80px">
						<col width="100px">
						<col width="">
					</colgroup>
					<tbody>
						<tr rowspan="2"> 
							<th class="text-right essential-item">요청일자</th>
							<td colspan="3">
								<div class="input-group">
									<input type="text" class="form-control border-right-0 width120px calDate rb" id="reg_dt" name="reg_dt" dateformat="yyyy-MM-dd" alt="요청일" value="${inputParam.s_current_dt}" required="required">
								</div>
							</td>
							<th class="text-right">요청자</th>
							<td colspan="3">
								<input type="text" class="form-control width100px"   id="mst_reg_name" name="mst_reg_name" readonly="readonly" value="${SecureUser.kor_name}">
								<input type="hidden" class="form-control width100px" id="mst_mem_no"   name="mst_mem_no"   readonly="readonly" value="${SecureUser.mem_no}">
							</td>
						</tr>
						<tr rowspan="2">
							<th class="text-right rs">보내는창고</th>
							<td colspan="3">
								<div class="form-row inline-pd">
								<c:choose>
									<c:when test="${ page.fnc.F01769_001 eq 'Y' }">
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
							<td colspan="3">
								<div class="form-row inline-pd">
										<div class="col-3">
											<input type="text" class="form-control width100px" readonly="readonly" value="${SecureUser.warehouse_cd ne '' ? SecureUser.warehouse_cd : SecureUser.org_code}" id="to_warehouse_cd" name="to_warehouse_cd" required="required" alt="받는 창고">
										</div>
										<div class="col-3">
											<input type="text" class="form-control width100px" readonly="readonly" value="${SecureUser.warehouse_cd eq partOrgCode ? partOrgName : SecureUser.org_name}">
										</div>
										<div class="col-3">
											로 이동 요청
										</div>						
								</div>
							</td>
						</tr>
						<tr rowspan="2">
							<th class="text-right essential-item">발송구분</th>
							<td colspan="3">
								<div class="form-row inline-pd">
									<div class="col-2">
										<select class="form-control width100px essential-bg" id="invoice_send_cd" name="invoice_send_cd" required="required" alt="전송구분">
											<c:forEach items="${codeMap['INVOICE_SEND']}" var="item">
											<option value="${item.code_value}" <c:if test="${item.code_value eq inputParam.invoice_send_cd}">selected</c:if>>${item.code_name}</option>
											</c:forEach>
										</select>
									</div>
									<div class="col-2">
										<button type="button" style="width: 100%;" class="btn btn-primary-gra" onclick="javascript:goDeliveryInfo();">배송정보설정</button>
									</div>
									<div class="col-8">
										<input type="text" class="form-control" maxlength="200" id="invoice_address" name="invoice_address" value="${inputParam.invoice_address}" readonly="readonly">
									</div>
								</div>
							</td>
							<th class="text-right">비고</th>
							<td colspan="3">
								<input type="text" class="form-control" id="mst_remark" name="mst_remark" maxlength="98">
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
								<div class="btn-group">
									<div class="right">
									<div class="text-warning ml5">
										※요청수량이 1개 이상인 것만 이동요청됩니다.
									</div>
<%-- 									<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include> --%>
									</div>
								</div>
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