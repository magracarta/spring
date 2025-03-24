<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 부품판매 > 매출처리 > 부품발송상세
-- 작성자 : 정윤수
-- 최초 작성일 : 2023-05-02 11:29:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

	var auiGridTop;
	var auiGridBottom;
	var centerJson = ${orgCenterListJson}
	centerJson.unshift({org_code : "6000", org_name : "부품영업부"});
	$(document).ready(function() {
		createAUIGridTop();
		createAUIGridBottom();
		if("${page.fnc.F04783_001}" != "Y"){
			$("#_goSave").addClass("dpn");
		}
	});
	

	// 닫기
    function fnClose() {
    	window.close();
    }
	
	// 체크 후 발송센터추가
	function fnAddCheck(){
		var items = AUIGrid.getCheckedRowItemsAll(auiGridTop);
		if(items.length < 1){
			alert("체크된 항목이 없습니다.")
			return false;
		}
		for(var i = 0; i < items.length; i++) {
			if(items[i].no_out_qty == 0){
				alert("발송이 완료된 부품은 추가하실 수 없습니다.");
				return false;
			}
		}
		for(var i = 0; i < items.length; i++) {
			var selItem = items[i];
			var parentRowId = selItem._$uid; // 체크행의 자식으로 행 추가

			var row = new Object();
			row.inout_doc_no = selItem.inout_doc_no;
			row.send_invoice_seq = 0;
			row.part_no = selItem.part_no;
			row.part_name = selItem.part_name;
			row.org_code = "";
			row.origin_org_code = "0000";
			row.assign_qty = 0;
			row.scan_qty = 0;
			row.no_out_qty = 0;
			row.send_date = "";
			row.seq_depth = "2";
			row.warehouse_cd = "";            
			row.seq_no = 1;            
			// 행 위치 시킬 곳
			var rowPos = "last";

			// parameter
			// item : 삽입하고자 하는 아이템 Object 또는 배열(배열인 경우 다수가 삽입됨)
			// rowId : 삽입되는 행의 부모 rowId 값
			// rowPos : first : 상단, last : 하단, selectionUp : 선택된 곳 위, selectionDown : 선택된 곳 아래
			AUIGrid.addTreeRow(auiGridTop, row, parentRowId, rowPos);
		}
		AUIGrid.setAllCheckedRows(auiGridTop, false);
	}
	
	// 발주요청
	function goOrderPart(data) {
		// 23.11.02 정윤수 발송목록 저장 후 발주요청하도록 추가 (trunk에만 작업함 머지할때 넣어야함)
		if(data.item.origin_org_code == "0000"){
			alert("변경한 발송목록을 먼저 저장 후 진행해주세요.")
			return false;
		}
		var msg = "발주요청 하시겠습니까?";
		var param = {
			// 발주요청 data
			"part_no" : data.item.part_no,
			"order_qty" : data.item.no_out_qty, // 미발송수량만큼 요청
			"in_qty" : data.item.current_stock, // 입고수량 = 현재고
			// 23.05.31 발주요청센터는 매출처리센터로 고정 
			"order_org_code" : data.item.inout_org_code, // 발주요청센터
			"req_warehouse_cd" : data.item.inout_org_code, //요청창고
			"preorder_inout_doc_no" : data.item.inout_doc_no, // 선주문전표
			// 발주요청 이후 발송센터 정보 삭제하기 위한 data
			"inout_doc_no" : data.item.inout_doc_no, // 전표번호
			"send_invoice_seq" : data.item.send_invoice_seq, // 송장번호
			"org_code" : data.item.org_code, // 발송센터
			"part_no" : data.item.part_no, // 부품번호
			"warehouse_cd" : data.item.org_code,
			"seq_no" : data.item.seq_no,

		}
		$M.goNextPageAjaxMsg(msg, this_page + "/saveOrder", $M.toGetParam(param), { method : "POST"},
				function(result) {
					if(result.success) {
						alert("발주 요청 처리되었습니다.");
						location.reload();
					}
				}
		);
	}

	// 부품출고처리상세 페이지 팝업 호출 2024.06.19[황다은]
	function goPartoutDetail(barcodeNo, warehouseCd, sendInvoiceSeq, custNo) {
		if(barcodeNo == "undefined") {
			alert("저장 후 다시 시도해주세요.");
			return null;
		}
		var params = {
			"doc_barcode_no" : barcodeNo,
			"send_out_dept_code" : warehouseCd,
			"send_invoice_seq" : sendInvoiceSeq,
			"cust_no" : custNo,		// 해당 고객이 미수금액있는지 확인
			"inout_doc_no" : "${inputParam.inout_doc_no}",
			"opener" : 4783
		}
		var popupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=480, left=0, top=0";
		$M.goNextPage('/part/part0203p01', $M.toGetParam(params), {popupStatus : popupOption});
	}
	
	// 저장
	function goSave() {
		if (fnChangeGridDataCnt(auiGridTop) == 0) {
			alert("변경된 데이터가 없습니다.");
			return false;
		}
		var gridData = AUIGrid.getGridData(auiGridTop); // 변경내역
		for(var i in gridData){
			if(gridData[i].org_code == "" && gridData[i].seq_depth != "1"){
				alert("센터를 선택해주세요.")
				return false;
			}
			if(gridData[i].assign_qty == 0){
				alert("수량을 입력하세요.")
				return false;
			}
		}
		var frm = $M.toValueForm(document.main_form);
		var gridFrm = fnChangeGridDataToForm(auiGridTop, false);
		$M.copyForm(gridFrm, frm);
		// console.log(gridFrm);
		$M.goNextPageAjaxSave(this_page +"/save", gridFrm, {method: "POST"},
				function (result) {
					if (result.success) {
						location.reload();
					}
				}
		);
	}
	
	// 부품발송상세 그리드 생성
	function createAUIGridTop() {
		var gridPros = {
			editable : true,
			rowIdField : "_$uid",
			// 체크박스 표시 설정
			showRowCheckColumn : true,
			// 전체 체크박스 표시 설정
			showRowAllCheckBox : false,
			showRowNumColumn : false,
			showStateColumn : true,
			treeColumnIndex : 2,
			displayTreeOpen : true, // 전체펼침
			rowStyleFunction : function(rowIndex, item) {
				if(item.seq_depth == "1" || (item.no_out_qty == 0 && item.assign_qty != 0)) {
					return "aui-grid-row-depth3-style";
				}
				return "";
			},
			// 부모 row만 체크박스 노출
			independentAllCheckBox : true, 
			rowCheckVisibleFunction : function(rowIndex, isChecked, item) {
				if(item.seq_depth == '1') {
					return true;
				}
				else {
					return false;
				}
			},
		};
		
		var columnLayout = [
			{
				dataField: "inout_doc_no",
				visible: false,
			},
			{
				dataField: "send_invoice_seq",
				visible: false,
			},
			{ 
				headerText : "부품번호", 
				dataField : "part_no",
				style : "aui-center",
				// width : "120",
				editable : false,
				labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
					if (item["seq_depth"] == "2") {
						return "";
					}
					return value;
				}
			},
			{
				headerText : "부품명",
				dataField : "part_name",
				style : "aui-center",
				editable : false,
				renderer: {
					type: "TemplateRenderer",
				},
				labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
					if (item.seq_depth == "2") {	// [자동화추가개발]_황다은. [부품출고-상세]팝업호출
						return '<button type="button" class="aui-grid-button-renderer aui-grid-button-percent-width" style="width: 90px" onclick="javascript:goPartoutDetail(\'' + item.doc_barcode_no + '\',\'' + item.org_code + '\',\'' + item.send_invoice_seq + '\',\'' + item.cust_no +  '\');">출고처리상세</button>';
					}
					return value;
				},
			},
			{
				headerText : "순번",
				dataField : "seq_no",
				visible: false,
			},
			{
				headerText : "발송센터", 
				dataField : "org_name",
				style : "aui-center",
				width : "80",
				editRenderer : {
					type: "DropDownListRenderer",
					showEditorBtn : true,
					showEditorBtnOver : true,
					list: centerJson,
					keyField: "org_code",
					valueField: "org_name",
				},
				labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) {
					var retStr = value;
					for(var j = 0; j < centerJson.length; j++) {
						if(centerJson[j]["org_code"] == value) {
							retStr = centerJson[j]["org_name"];
							break;
						}
					}
					return retStr;
				},
				styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (item.preorder_order_req_qty <= "0") {
						return "aui-editable";
					};
				},
			},
			{
				headerText : "org_code",
				dataField: "org_code",
				visible: false,
			},
			{
				headerText : "origin_org_code",
				dataField: "origin_org_code",
				visible: false,
			},
			{
				headerText : "warehouse_cd",
				dataField: "warehouse_cd",
				visible: false,
			},
			{ 
				headerText : "수량", 
				dataField : "assign_qty",
				dataType : "numeric",
				formatString : "#,##0",
				style : "aui-center",
				width : "60",
				editRenderer : {
					type : "InputEditRenderer",
					onlyNumeric : true,
				},
				styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if (item.seq_depth == "1") {
						return "aui-popup"
					} else if(item.preorder_order_req_qty <= "0"){
						return "aui-editable";
					};
				},
			},
			{ 
				dataField : "scan_qty",
				visible : false,
			},
			{ 
				dataField : "current_stock",
				visible : false,
			},
			{ 
				headerText : "미발송", 
				dataField : "no_out_qty",
				dataType : "numeric",
				formatString : "#,##0",
				style : "aui-center",
				width : "60",
				editable : false,
				expFunction : function(  rowIndex, columnIndex, item, dataField ) {
					// 할당수량 - 스캔수량
					return (item.assign_qty - item.scan_qty);
				},
			},
			{ 
				headerText : "발주요청", 
				dataField : "part_preorder_btn",
				style : "aui-center",
				width : "70",
				renderer : {
					type : "ButtonRenderer",
					onClick : function(event) {
						goOrderPart(event);
					},
					visibleFunction: function (rowIndex, columnIndex, value, item, dataField) {
						// 부품행은 발주요청 버튼 노출안함
						if (item.seq_depth == "1" || item.no_out_qty == 0 || "${page.fnc.F04783_001}" != "Y" || item.preorder_order_req_qty > "0") {
							return false;
						}
						return true;
					}
				},
				labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
					return '발주요청'
				},
				style : "aui-center",
				editable : false,
			},
			{
				dataField: "inout_org_code",
				visible : false,
			},
			{ 
				headerText : "발송일자", 
				dataField : "send_date",
				style : "aui-center",
				width : "100",
				dataType : "date",
				formatString : "yyyy-mm-dd",
				editable : false,
				labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
					if(item.no_out_qty == 0 && value != ""){
						return $M.dateFormat(value, "yyyy-MM-dd");
					} else {
						return "";
					}
				},
			},
			{
				headerText : "삭제",
				dataField : "removeBtn",
				width : "60",
				renderer : {
					type : "ButtonRenderer",
					onClick : function(event) {
						if(event.item.seq_depth != "2") {
							alert("센터만 삭제할 수 있습니다.");
							return false;
						}
						if(event.item.assign_qty != 0 && event.item.no_out_qty == 0){
							alert("발송이 완료된 센터은 삭제하실 수 없습니다.");
							return false;
						}
						var isRemoved = AUIGrid.isRemovedById(auiGridTop, event.item._$uid);
						if (isRemoved == false) {
							AUIGrid.updateRow(auiGridTop, {cmd : "D"}, event.rowIndex);
							AUIGrid.removeRow(event.pid, event.rowIndex);
						} else {
							AUIGrid.restoreEditedRows(auiGridTop, "selectedIndex") // 수정된 값 초기화
							AUIGrid.restoreSoftRows(auiGridTop, "selectedIndex") // 삭제 취소
						}
						AUIGrid.update(auiGridTop);
					},
					visibleFunction: function (rowIndex, columnIndex, value, item, dataField) {
						// 부품행은 버튼 노출안함
						if (item.seq_depth == "1" || (item.assign_qty != 0 && item.no_out_qty == 0) || "${page.fnc.F04783_001}" != "Y" || item.preorder_order_req_qty > "0") {
							return false;
						}
						return true;
					}
				},
				labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
					return '삭제'
				},
				style : "aui-center",
				editable : false,
			},
			{
				dataField : "seq_depth",
				visible : false
			},
			{
				dataField : "preorder_order_req_qty",
				visible : false
			},
			{
				dataField : "doc_barcode_no",
				visible : false
			},
			{
				dataField : "cust_no",
				visible : false
			},
			{
				dataField : "cmd",
				visible : false
			},
			
		];
		auiGridTop = AUIGrid.create("#auiGridTop", columnLayout, gridPros);
		AUIGrid.setGridData(auiGridTop, ${list});

		// 부품재고상세팝업 호출
		AUIGrid.bind(auiGridTop, "cellClick", function(event) {
			var popupOption = "";
			var param = {
				"part_no" : event.item["part_no"]
			};
			if(event.dataField == "assign_qty" && event.item.seq_depth == "1") {
				$M.goNextPage('/part/part0101p01', $M.toGetParam(param), {popupStatus : popupOption});
			};
		});
		
		AUIGrid.bind(auiGridTop, "cellEditBegin", function( event ) {
			if (event.item.seq_depth == "1" || (event.item.assign_qty != 0 && event.item.no_out_qty == 0)  || event.item.preorder_order_req_qty > "0") {
				return false;
			}
		});
		
		// 센터 선택 후
		AUIGrid.bind(auiGridTop, "cellEditEnd", function( event ) { 
			var items = AUIGrid.getItemsByValue(auiGridTop, "part_no", event.item.part_no);
			if(event.dataField == 'org_name') {
				var value = event.value;
				var modifyYn = true;
				// 23.11.10 [20644] seq_no 추가로 인하여 동일한 센터 추가 가능하도록 주석처리
				for(var i in items) {
					var item = items[i];
					if(item.org_code == value){
						AUIGrid.restoreEditedCells(auiGridTop, "selectedIndex");
						modifyYn = false;
						alert("동일한 센터가 존재합니다."); 
						return false;
					}
				}
				if(modifyYn){
					rowIndex = event.rowIndex;
					AUIGrid.updateRow(auiGridTop, { "org_code" : value, "warehouse_cd" : value}, rowIndex);
				}
			} else if(event.dataField == 'assign_qty'){
				var param = {
					"s_inout_doc_no" : event.item.inout_doc_no,
					"s_part_no" : event.item.part_no	
				};
				
				$M.goNextPageAjax(this_page + "/searchPartAssign", $M.toGetParam(param), { method : "GET"},
						function(result) {
							if(result.success) {
								var saleQty = 0; // 수주수량
								var totalQty = 0; // 전체 할당수량
								var partYn = "N"; // 부품부 할당여부
								for(var i in items) {
									var item = items[i];
									if(item.org_code == "6000"){
										partYn = "Y";
									}
									if(item.seq_depth == "1"){
										saleQty = Number(item.assign_qty);
									} else {
										totalQty += Number(item.assign_qty);
									}
								}
								// 수주수량보다 부품발송상세 할당 수량 + 부품부 할당수량이 더 큰 경우 알림
								if((partYn == "N" && saleQty < totalQty + result.assign_qty) || (partYn == "Y" && saleQty < totalQty)){
									AUIGrid.restoreEditedCells(auiGridTop, "selectedIndex");
									alert("전체 수량을 초과하였습니다. 다시 입력하시기 바랍니다.");
									return false
								}
							}
						}
				);
				
			}
		});
		$("#auiGridTop").resize();
	}

	// 미발송내역 그리드 생성
	function createAUIGridBottom() {
		var gridPros = {
			rowIdField : "_$uid",
			showRowNumColumn : false,
		};

		var columnLayout = [
			{
				headerText : "부품번호",
				dataField : "part_no",
				style : "aui-center",
				width : "120",
			},
			{
				headerText : "부품명", 
				dataField : "part_name",
				style : "aui-center",
			},
			{ 
				headerText : "발송센터", 
				dataField : "org_name",
				style : "aui-center",
				width : "100",
			},
			{
				dataField: "org_code",
				visible : false,
			},
			{ 
				headerText : "미발송", 
				dataField : "no_out_qty",
				dataType : "numeric",
				formatString : "#,##0",
				style : "aui-right",
				width : "60",
			},
			{ 
				headerText : "발주요청", 
				dataField : "preorder_order_req_qty",
				dataType : "numeric",
				formatString : "#,##0",
				style : "aui-right",
				width : "60",
			},
			{
				headerText : "발주중", 
				dataField : "order_qty",
				dataType : "numeric",
				formatString : "#,##0",
				style : "aui-right",
				width : "60",
			},
			{
				headerText : "입고예정일", 
				dataField : "in_plan_dt",
				style : "aui-right",
				width : "110",
				dataType : "date",
				formatString : "yyyy-mm-dd"
			},
		];
		
		auiGridBottom = AUIGrid.create("#auiGridBottom", columnLayout, gridPros);
		AUIGrid.setGridData(auiGridBottom, ${noOutList});
		$("#auiGridBottom").resize();

	}

	</script>
</head>
<body>
<form id="main_form" name="main_form">
	<input type="hidden" name="cust_no" id="cust_no" value="${sendInvoiceInfo.cust_no}">
	<input type="hidden" name="part_sale_no" id="part_sale_no" value="${sendInvoiceInfo.part_sale_no}">
	<input type="hidden" name="invoice_no" id="invoice_no" value="${sendInvoiceInfo.invoice_no}">
	<input type="hidden" name="post_no" id="post_no" value="${sendInvoiceInfo.post_no}">
	<input type="hidden" name="addr1" id="addr1" value="${sendInvoiceInfo.addr1}">
	<input type="hidden" name="addr2" id="addr2" value="${sendInvoiceInfo.addr2}">
	<input type="hidden" name="receive_name" id="receive_name" value="${sendInvoiceInfo.receive_name}">
	<input type="hidden" name="receive_tel_no" id="receive_tel_no" value="${sendInvoiceInfo.receive_tel_no}">
	<input type="hidden" name="receive_hp_no" id="receive_hp_no" value="${sendInvoiceInfo.receive_hp_no}">
	<input type="hidden" name="remark" id="remark" value="${sendInvoiceInfo.remark}">
	<input type="hidden" name="delivery_fee" id="delivery_fee" value="${sendInvoiceInfo.delivery_fee}">
	<input type="hidden" name="invoice_send_cd" id="invoice_send_cd" value="${sendInvoiceInfo.invoice_send_cd}">
	<input type="hidden" name="invoice_money_cd" id="invoice_money_cd" value="${sendInvoiceInfo.invoice_money_cd}">
	<div class="popup-wrap width-100per">
		<!-- 타이틀영역 -->
		<div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
		</div>
		<!-- /타이틀영역 -->
		<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="contents">
				<!-- 상단 - 부품발송상세 -->
				<div class="title-wrap mt5">
					<div class="form-check form-check-inline">
						<h4>부품발송상세</h4>
					</div>
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
					</div>
				</div>
				<div id="auiGridTop" style="margin-top: 5px; height: 350px;"></div>
				<!-- /상단 - 부품발송상세 -->
				<div class="btn-group mt5">
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
					</div>
				</div>
				<!-- 하단 - 미발송내역 -->
				<div class="title-wrap mt10">
					<h4>미발송내역</h4>
				</div>
				<div id="auiGridBottom" style="margin-top: 5px; height: 288px;"></div>
				<div class="btn-group mt10">
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
					</div>
				</div>
				<!-- /하단 - 미발송내역 -->
			</div>
		</div>
	</div>
	<!-- /contents 전체 영역 -->
</form>
</body>
</html>