<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 창고이동/부품출하 > 부품발송-출고처리 > null > 출고처리
-- 작성자 : 성현우
-- 최초 작성일 : 2020-10-11 17:45:28
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	var auiGridTop;
	var auiGridBottom;
	var rowNo = ${partInoutListSize};

	var orgCode = "${info.org_code}";
	var loginOrgCode = "${SecureUser.org_code}";
	var searchYn = "Y";
	$(document).ready(function () {
		createAUIGridTop();
		createAUIGridBottom();
		// 2024.06.20[자동화추가개발]_황다은. [부품발송상세]에서 호출할 때 조건 체크
		var isAuthPopup = "${popup_yn}"
		var hasSendInvoiceSeq = "${hasSendSeq}"

		if(isAuthPopup != "") {
			if(isAuthPopup == 'false' || hasSendInvoiceSeq == "") {
				var msg = "";
				msg = hasSendInvoiceSeq == "" ? "해당 송장번호가 존재하지 않습니다." : "미수금을 확인하십시오."
				alert(msg);
				window.close();
				return null;
			}
		}

		fnInit();
	});

	function fnInit() {
		$("#_goSave").addClass("dpn");
		$("#_fnAdd").addClass("dpn"); // 23.05.25 수기입력 할 수 없도록 수정
		if(orgCode != loginOrgCode) {
			alert("처리창고가 맞지 않습니다.\n출고처리를 진행 할 수 없습니다.");
			
			$("#_goComplete").addClass("dpn");
			$("#barcode").prop("readonly", true);
			$("#qty").prop("readonly", true);
			// $("#_fnAdd").prop("disabled", true);
		}
	}

	$(document).scannerDetection({
		timeBeforeScanTest: 200, // wait for the next character for upto 200ms
		startChar: [120], // Prefix character for the cabled scanner (OPL6845R)
		endChar: [13], // be sure the scan is complete if key 13 (enter) is detected
		avgTimeByChar: 40, // it's not a barcode if a character takes longer than 40ms
		minLength: 3,
		onComplete: function (barcode, qty) {
			try {
				if (fnBarcodeRead) {
					fnBarcodeRead(barcode);
				}
				return false;
			} catch (e) {
				console.log(e);
				return false;
			}

		}
	});

	// 엔터키 이벤트
	// [재호] : 중복 스캔 요청 가능성 때문에 주석 처리
	function enter(fieldObj) {
		// var field = ["barcode"];
		// $.each(field, function() {
		// 	if(fieldObj.name == this) {
		// 		if (searchYn == "Y") {
		// 			searchYn = "N";
		// 			fnBarcode($M.getValue("barcode"));
		// 		} else {
		// 			alert("요청 작업을 처리중입니다.");
		// 		}
		// 	};
		// });
	}

	function fnConfirm() {
		// searchYn = "Y"; // 23.07.27 정윤수 부품 바코드 리딩 시 두번씩 찍히는 경우가 있어 수정함
		location.reload();
	}
	
	// 발송완료처리 (수주전표의 배송상태 배송중으로 변경)
	function goComplete() {
		var param = {
			"part_sale_no": "${partSaleNo}",
            "cust_no" : $M.getValue("cust_no")
		}
			
		$M.goNextPageAjax(this_page + "/complete", $M.toGetParam(param), {method: 'POST'},
				function (result) {
					if (result.success) {
						location.reload();
					}
				}
		);
	}

	// 바코드 리더기로 읽은 값 setting
	function fnBarcodeRead(barcode) {
		if(orgCode != loginOrgCode) {
			alert("처리창고가 맞지 않습니다.\n출고처리를 진행 할 수 없습니다.");
			return;
		}
		if (searchYn == "Y") {
			searchYn = "N";
			fnBarcode(barcode);
		} else {
			alert("요청 작업을 처리중입니다.");
            location.reload();
		 }
	}

	function fnBarcode(barcode) {
// 		var partBarcode = barcode;
// 		if (barcode.startsWith("C") || barcode.startsWith("c") || barcode.startsWith("ㅊ")) {
		barcode = barcode.replace('C', '');
		barcode = barcode.replace('c', '');
		barcode = barcode.replace('ㅊ', '');
// 		}
		var param = {
			"s_barcode": barcode,
			"s_doc_barcode_no": $M.getValue("doc_barcode_no"),
			"send_invoice_seq": "${sendInvoiceSeq}",
		};
		
		$M.goNextPageAjax(this_page + "/part/search", $M.toGetParam(param), {method: "GET"},
				function (result) {
					// searchYn = "Y"; // 23.07.06 [정윤수] 바코드를 짧은시간에 연속적으로 리딩하면 문제가 발생하는 거 같아 연속적으로 리딩 시 alert 호출하도록 수정함
					if (result.success) {
						$M.clearValue({field: ["barcode"]});
						scanProcess(result);
					}
				}
		);
	}

	function scanProcess(data) {
		var qty = 1;
		var noOutQty = data.no_out_qty // 출고가능수량
		var partNo = data.part_no; // 부품명
		var showInputQtyYn = data.show_qty_input_yn;

		// 특정부품들은 수량 입력 가능
		var msg = "출고 수량을 입력하세요.";
		if(showInputQtyYn == "Y") {
			var writeQty = prompt(msg);
			while(isNaN(writeQty)) {
				writeQty = prompt(msg);
			}

			qty = writeQty;
		}
		if (qty == null || qty == 0){
			return;
		}

		if(noOutQty < qty) {
			alert("출고 가능한 수량을 초과했습니다.");
			return;
		}

		fnSaveProcess(data, qty, "Y");
	}

	// 수기
	function fnHandWriteProcess() {
		var qty = $M.toNum($M.getValue("qty"));
		var noOutQty = $M.toNum($M.getValue("no_out_qty"));
		var partNo = $M.getValue("input_part_no"); // 부품명

		// 특정부품들은 수량 입력 가능
		var msg = "출고 수량을 입력하세요.";
		if(noOutQty >= 10) {
			var writeQty = prompt(msg);
			while(isNaN(writeQty)) {
				writeQty = prompt(msg);
			}

			qty = writeQty;
		}

		if(noOutQty < qty) {
			alert("출고 가능한 수량을 초과했습니다.");
			return;
		}

		fnSaveProcess("", qty, "N");
	}

	// 부품추가.
	function fnSaveProcess(data, qty, scanYn) {
		var params = {};
		params.inout_cmd = "C";
		params.preorder_yn = $M.getValue("preorder_yn"); // 선주문여부 22.10.05 자동입고처리를 위해서 추가
		params.doc_barcode_type_cd = $M.getValue("doc_barcode_type_cd"); // 문서 바코드 타입
		params.to_warehouse_cd = $M.getValue("to_warehouse_cd"); // 받는창고
		params.out_qty = $M.getValue("out_qty");
		params.report_qty = $M.getValue("report_qty");
		params.assign_seq_no = data.assign_seq_no;
		if(scanYn == "Y") {
			params.part_no = data.part_no;
			params.in_qty = data.trans_in_qty; // 입고수량 22.10.05 자동입고처리를 위해서 추가
			params.part_name = data.part_name;
			params.barcode = data.barcode;
			params.qty = qty;
			params.scan_yn = scanYn;
			params.doc_barcode_no = $M.getValue("doc_barcode_no");
			params.inout_dt = $M.getCurrentDate();
			if (data.type_code == "I") {
				params.inout_doc_no = data.inout_doc_no;
				params.inout_seq_no = data.inout_seq_no;
			} else if (data.type_code == "T") {
				params.part_trans_no = data.part_trans_no;
				params.trans_seq_no = data.trans_seq_no;
			}
		} else if(scanYn == "N") {
			params.part_no = $M.getValue("input_part_no");
			params.in_qty = $M.getValue("in_qty"); // 입고수량 22.10.05 자동입고처리를 위해서 추가
			params.part_name = $M.getValue("part_name");
			params.barcode = $M.getValue("barcode");
			params.qty = qty;
			params.scan_yn = scanYn;
			params.doc_barcode_no = $M.getValue("doc_barcode_no");
			params.inout_dt = $M.getCurrentDate();

			if ($M.getValue("type_code") == "I") {
				params.inout_doc_no = $M.getValue("doc_no");
				params.inout_seq_no = $M.getValue("seq_no");
			} else if ($M.getValue("type_code") == "T") {
				params.part_trans_no = $M.getValue("doc_no");
				params.trans_seq_no = $M.getValue("seq_no");
			}
		}

		var gridData = AUIGrid.getGridData(auiGridTop);
		var noOutQty = 0;
		// no_out_qty
		for(var i=0; i<gridData.length; i++) {
			noOutQty += $M.toNum(gridData[i].no_out_qty);
		}
		noOutQty -= qty;

		params.no_out_qty = noOutQty;
		params.send_invoice_seq = gridData[0].send_invoice_seq;

		$M.goNextPageAjax(this_page + "/save", $M.toGetParam(params), {method: 'POST'},
				function (result) {
					if (result.success) {
						location.reload();
					}
				}
		);
	}

	// 부품추가.
	function fnAdd() {
		if($M.getValue("input_part_no") == "") {
			alert("출고처리 할 부품을 먼저 선택해주세요.");
			return;
		}
		fnHandWriteProcess();
	}

	// 전표조회
	function goSearchInout() {
		var param = {};
		// doc_barcode_type_cd
		var docBarcodeTypeCd = $M.getValue("doc_barcode_type_cd");
		var poppupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=480, left=0, top=0";
		if(docBarcodeTypeCd == "INOUT_DOC") {
			param.inout_doc_no = $M.getValue("doc_no");
			$M.goNextPage("/cust/cust0202p01", $M.toGetParam(param), {popupStatus : poppupOption});
		} else if(docBarcodeTypeCd == "PART_TRANS") {
			// part_trans_no=PT20201018-0001&searchMode=TRANS
			param.part_trans_no = $M.getValue("doc_no");
			param.searchMode = "TRANS";
			$M.goNextPage("/part/part0202p03", $M.toGetParam(param), {popupStatus : poppupOption});
		}
	}

	// 삭제
	function goRemove() {
		var frm = $M.toValueForm(document.main_form);
		$M.setValue(frm, "inout_dt", $M.getCurrentDate());
		$M.setValue(frm, "inout_cmd", "U");
		$M.setValue(frm, "send_invoice_seq", "${sendInvoiceSeq}");

		var gridData = fnChangeGridDataToForm(auiGridBottom, "N");
		$M.copyForm(gridData, frm);

		$M.goNextPageAjax(this_page + "/save", gridData, {method: 'POST'},
				function (result) {
					if (result.success) {
						location.reload();
					}
				}
		);
	}

	// 닫기
	function fnClose() {
		window.close();
	}

	function createAUIGridTop() {
		var gridPros = {
			rowIdField: "_$uid",
			showRowNumColumn: false
		};

		var columnLayout = [
			{
				headerText : "전표번호",
				dataField : "seq_no",
				width : "5%"
			},
			{
				headerText : "부품번호",
				dataField : "part_no",
				style : "aui-center aui-popup"
			},
			{
				headerText : "부품명",
				dataField : "part_name",
				style : "aui-left"
			},
			{
				headerText : "단위",
				dataField : "part_unit",
				width : "5%"
			},
			{
				headerText : "포장",
				dataField : "part_pack_unit",
				width : "5%"
			},
			{
				headerText : "전표",
				dataField: "qty",
				width : "5%",
				dataType : "numeric",
				formatString : "#,##0"
			},
			{
				headerText : "미출고",
				dataField : "no_out_qty",
				width : "5%",
				dataType : "numeric",
				formatString : "#,##0"
			},
			{
				headerText : "출고",
				dataField: "out_qty",
				width : "5%",
				dataType : "numeric",
				formatString : "#,##0"
			},
			{
				headerText : "저장위치",
				dataField : "storage_name"
			},
			{
				headerText : "현재고",
				dataField: "current_qty",
				width : "5%",
				dataType : "numeric",
				formatString : "#,##0"
			},
			{
				headerText: "입고수량",
				dataField: "trans_in_qty",
				visible: false
			},
			{
				headerText: "전표바코드",
				dataField: "doc_barcode_no",
				visible: false
			},
			{
				headerText: "부품바코드",
				dataField: "barcode",
				visible: false
			},
			{
				headerText: "전표번호",
				dataField: "inout_doc_no",
				visible: false
			},
			{
				headerText : "부품이동번호",
				dataField : "part_trans_no",
				visible : false
			},
			{
				headerText: "고객번호",
				dataField: "cust_no",
				visible: false
			},
			{
				headerText : "스캔",
				dataField : "scan_qty",
				visible : false
			},
			{
				headerText : "HOMI여부",
				dataField : "homi_yn",
				visible : false
			},
			{
				headerText : "타입여부",
				dataField : "type_code",
				visible : false
			},
			{
				headerText : "송장발송번호",
				dataField : "send_invoice_seq",
				visible : false
			},
			{
				headerText : "수기처리여부",
				dataField : "barcode_hand_yn",
				visible : false
			},
			{
				headerText : "할당순번",
				dataField : "assign_seq_no",
				visible : false
			}
		];

		auiGridTop = AUIGrid.create("#auiGridTop", columnLayout, gridPros)
		AUIGrid.setGridData(auiGridTop, ${list});
		$("#auiGridTop").resize();

		AUIGrid.bind(auiGridTop, "cellClick", function (event) {
			if (event.dataField == "part_no") {

				// if(event.item.homi_yn == "N" && event.item.barcode_hand_yn == "N") {
				// 	alert("수기처리는 HOMI품목 \n또는 [" + event.item.part_no + "] 품목만 가능합니다.");
				// 	return;
				// }
				if(event.item.barcode_hand_yn == "N") {
					alert("[" + event.item.part_no + "] 부품은 수기처리가 불가능합니다.");
					return;
				}

				$M.setValue("no_out_qty", event.item.no_out_qty);
				$M.setValue("out_qty", event.item.out_qty);
				$M.setValue("input_part_no", event.item.part_no);
				$M.setValue("qty", "1");
				$M.setValue("part_name", event.item.part_name);
				$M.setValue("barcode", event.item.barcode);
				$M.setValue("type_code", event.item.type_code);
				$M.setValue("seq_no", event.item.seq_no);
				$M.setValue("report_qty", event.item.qty);
				$M.setValue("in_qty", event.item.trans_in_qty);
				// $M.setValue("assign_seq_no", event.item.assign_seq_no);
			}
		});
	}

	function createAUIGridBottom() {
		var gridPros = {
			rowIdField: "_$uid",
			showRowNumColumn: false
		};

		var columnLayout = [
			{
				headerText: "처리일시",
				dataField: "s_reg_date",
				dataType : "date",
				width : "20%",
				formatString : "yy-mm-dd HH:MM:ss",
			},
			{
				headerText: "처리자",
				dataField: "reg_mem_name",
				width : "5%"
			},
			{
				headerText: "처리자",
				dataField : "reg_mem_no",
				visible : false
			},
			{
				headerText : "부품번호",
				dataField : "part_no",
				style : "aui-center"
			},
			{
				headerText : "부품명",
				dataField : "part_name",
				style : "aui-left"
			},
			{
				headerText: "수량",
				dataField: "part_qty",
				dataType : "numeric",
				width : "5%",
				formatString : "#,##0"
			},
			{
				headerText: "구분",
				dataField: "scan_name",
				width : "6%"
			},
			{
				headerText : "삭제",
				dataField : "remove",
				width : "9%",
				renderer : {
					type : "ButtonRenderer",
					onClick : function(event) {

						if(event.item.reg_mem_no != "${SecureUser.mem_no}") {
							alert("삭제는 처리자만 가능합니다.");
							return;
						}

						$M.setValue("s_part_no", event.item.part_no);
						var isRemoved = AUIGrid.isRemovedById(auiGridBottom, event.item._$uid);
						if (isRemoved == false) {
							AUIGrid.removeRow(event.pid, event.rowIndex);
							// fnCalcNoOutQty();
							if("Y" == $M.getValue("preorder_yn")){
								if (confirm("자동입고된 내역이 있을 경우 함께 삭제됩니다.\n삭제 하시겠습니까?") == false) {
									AUIGrid.restoreSoftRows(auiGridBottom, "selectedIndex");
									return false;
								} else {
									goRemove();
								}
 							} else {
								if (confirm("삭제 하시겠습니까?") == false) {
									AUIGrid.restoreSoftRows(auiGridBottom, "selectedIndex");
									return false;
								} else {
									goRemove();
								}
							}
						} else {
							AUIGrid.restoreSoftRows(auiGridBottom, "selectedIndex");
						}
					},
					visibleFunction : function(rowIndex, columnIndex, value, item, dataField ) {
						// 삭제버튼은 행 추가시에만 보이게 함

					}
				},
				labelFunction : function(rowIndex, columnIndex, value,
										 headerText, item) {
					return '삭제'
				},
				style : "aui-center",
				editable : false
			},
			{
				headerText : "스캔여부",
				dataField : "scan_yn",
				visible : false
			},
			{
				headerText : "바코드",
				dataField : "part_in_barcode",
				visible : false
			},
			{
				headerText : "전표번호",
				dataField : "inout_doc_no",
				visible : false
			},
			{
				headerText : "부품이동번호",
				dataField : "inout_seq_no",
				visible : false
			},
			{
				headerText : "부품이동번호",
				dataField : "part_trans_no",
				visible : false
			},
			{
				headerText : "이동일련번호",
				dataField : "trans_seq_no",
				visible : false
			},
			{
				headerText : "전표바코드",
				dataField : "doc_barcode_no",
				visible : false
			},
			{
				headerText : "행번호",
				dataField : "row_no",
				visible : false
			},
			{
				headerText : "사용여부",
				dataField : "use_yn",
				visible : false
			},
			{
				headerText : "저장여부",
				dataField : "check",
				visible : false
			},
			{
				headerText : "전표바코드타입",
				dataField : "doc_barcode_type_cd",
				visible : false
			},
			{
				headerText : "입출고번호",
				dataField : "part_inout_seq",
				visible : false
			}
		];

		auiGridBottom = AUIGrid.create("#auiGridBottom", columnLayout, gridPros)
		AUIGrid.setGridData(auiGridBottom, ${partInoutList});
		$("#auiGridBottom").resize();
	}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<input type="hidden" id="cust_no" name="cust_no" value="${info.cust_no}">
	<input type="hidden" id="doc_barcode_no" name="doc_barcode_no" value="${info.doc_barcode_no}">
	<input type="hidden" id="login_mem_no" name="login_mem_no" value="${info.login_mem_no}">
	<input type="hidden" id="login_mem_name" name="login_mem_name" value="${info.login_mem_name}">
	<input type="hidden" id="doc_barcode_type_cd" name="doc_barcode_type_cd" value="${info.doc_barcode_type_cd}">
	<input type="hidden" id="preorder_yn" name="preorder_yn" value="${info.preorder_yn}"> <!-- 선주문여부 -->
	<input type="hidden" id="to_warehouse_cd" name="to_warehouse_cd" value="${info.to_warehouse_cd}"> <!-- 받는창고 -->
	<input type="hidden" id="in_qty" name="in_qty">
	<input type="hidden" id="out_qty" name="out_qty">
	<input type="hidden" id="scan_qty" name="scan_qty">
	<input type="hidden" id="report_qty" name="report_qty"> <!-- 접수 수량 -->
	<input type="hidden" id="part_barcode" name="part_barcode">
	<input type="hidden" id="no_out_qty" name="no_out_qty">
	<input type="hidden" id="no_in_qty" name="no_in_qty">
	<input type="hidden" id="type_code" name="type_code">
	<input type="hidden" id="seq_no" name="seq_no">
	<input type="hidden" id="assign_seq_no" name="assign_seq_no">
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
				<div class="title-wrap">
					<h4>출고처리(매출)</h4>
					<div class="right text-warning">
						※ 바코드 인식이 안될 경우 바코드인식 버튼을 누른 후 진행해주세요.
					</div>
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
				</div>
				<table class="table-border mt5">
					<colgroup>
						<col width="80px">
						<col width="">
						<col width="80px">
						<col width="">
						<col width="80px">
						<col width="">
					</colgroup>
					<tbody>
					<tr>
						<th class="text-right">전표번호</th>
						<td>
							<div class="form-row inline-pd">
								<div class="col-auto">
									<input type="text" class="form-control width120px" id="doc_no" name="doc_no" readonly="readonly" value="${info.doc_no}">
								</div>
								<div class="col-auto">
									<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_L"/></jsp:include>
								</div>
							</div>
						</td>
						<th class="text-right">고객명</th>
						<td>
							<input type="text" class="form-control width120px" id="cust_name" name="cust_name" readonly="readonly" value="${info.cust_name}">
						</td>
						<th class="text-right">바코드</th>
						<td>
							<input type="text" class="form-control" id="barcode" name="barcode">
						</td>
					</tr>
					</tbody>
				</table>
				<div id="auiGridTop" style="margin-top: 5px; height: 150px;"></div>
			</div>
			<!-- /폼테이블 -->
			<!-- 폼테이블 -->
			<div>
				<div class="title-wrap mt10">
					<h4>출고처리내역</h4>
				</div>
				<table class="table-border mt5">
					<colgroup>
						<col width="80px">
						<col width="">
						<col width="80px">
						<col width="">
						<col width="80px">
						<col width="">
						<col width="80px">
						<col width="">
					</colgroup>
					<tbody>
					<tr>
						<th class="text-right">품번</th>
						<td>
							<input type="text" class="form-control" readonly="readonly" id="input_part_no" name="input_part_no">
						</td>
						<th class="text-right">품명</th>
						<td>
							<input type="text" class="form-control" readonly="readonly" id="part_name" name="part_name">
						</td>
						<th class="text-right">수량</th>
						<td colspan="3">
							<div class="btn-group">
								<input type="text" class="form-control text-right width80px mr10" id="qty" name="qty" datatype="int" min="1">
								<div class="left mr5">
									<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
								</div>
							</div>
						</td>
					</tr>
					</tbody>
				</table>
				<div id="auiGridBottom" style="margin-top: 5px; height: 150px;"></div>
			</div>
			<!-- /폼테이블 -->
			<div class="btn-group mt10">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
		</div>
	</div>
	<!-- /팝업 -->
</form>
</body>
</html>