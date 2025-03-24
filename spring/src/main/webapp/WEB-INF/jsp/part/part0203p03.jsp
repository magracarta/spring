<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 창고이동/부품출하 > 부품발송-출고처리 > null > 입고처리
-- 작성자 : 성현우
-- 최초 작성일 : 2020-10-11 17:45:28
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var dupYn = "N";
		var auiGridTop;
		var auiGridBottom;
		var rowNo = ${partInoutListSize};

		var orgCode = "${info.org_code}";
		var fromWarehouseCd = "${info.from_warehouse_cd}";
		var loginOrgCode = "${SecureUser.org_code}";
		var searchYn = "Y";
		$(document).ready(function () {
			createAUIGridTop();
			createAUIGridBottom();

			fnInit();
		});

		function fnInit() {
			$("#_goSave").addClass("dpn");
			$("#_fnAdd").addClass("dpn"); // 23.05.25 수기입력 할 수 없도록 수정
			fnInitPage();

			if(orgCode != loginOrgCode && orgCode != "9142") {
				alert("처리창고가 맞지 않습니다.\n입고처리를 진행 할 수 없습니다.");

				$("#barcode").prop("readonly", true);
				$("#qty").prop("readonly", true);
				// $("#_fnAdd").prop("disabled", true);
			}
		}

		function fnInitPage() {
			var docNo = $M.getValue("doc_no");
			var hideList = ["trans_out_qty"];
			if(docNo.startsWith("IN") || fromWarehouseCd == "9142") {
				AUIGrid.hideColumnByDataField(auiGridTop, hideList);
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
		function enter(fieldObj) {
			var field = ["barcode"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					fnBarcode($M.getValue("barcode"));
				};
			});
		}

		function fnConfirm() {
			searchYn = "Y";
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

		// 바코드 리더기로 읽은 값 setting
		function fnBarcodeRead(barcode) {
			if(orgCode != loginOrgCode && orgCode != "9142") {
				alert("처리창고가 맞지 않습니다.\n입고처리를 진행 할 수 없습니다.");
				return;
			}

			if(searchYn == "Y") {
				searchYn = "N";
				fnBarcode(barcode);
			}
		}

		function fnBarcode(barcode) {
			barcode = barcode.replace('C', '');
			barcode = barcode.replace('c', '');
			barcode = barcode.replace('ㅊ', '');
			var param = {
				"s_barcode" : barcode,
				"s_doc_barcode_no" : $M.getValue("doc_barcode_no"),
				"s_from_warehouse_cd" : fromWarehouseCd
			};

			$M.goNextPageAjax(this_page + "/part/search", $M.toGetParam(param), {method: "GET"},
					function (result) {
						searchYn = "Y";
						if (result.success) {
							$M.clearValue({field:["barcode"]});
							scanProcess(result);
						}
					}
			);
		}

		function scanProcess(data) {
			var qty = 1;
			var totalQy = data.total_qty; // 접수수량 no_in_qty_2
			var noInQty = data.no_in_qty // 입고가능수량
			var noInQty2 = data.no_in_qty2; // 입고가능수량(입고창고)
			var partNo = data.part_no; // 부품명
			var showInputQtyYn = data.show_qty_input_yn;

			// 특정부품들은 수량 입력 가능
			var msg = "입고 수량을 입력하세요.";
			if(showInputQtyYn == "Y") {
				var writeQty = prompt(msg);
				while (isNaN(writeQty)) {
					writeQty = prompt(msg);
				}

				qty = writeQty;
			}
			if (qty == null || qty == 0){
				return;
			}

			if(fromWarehouseCd != "9142") {
				if (noInQty < qty) {
					alert("입고 가능한 수량을 초과했습니다.");
					return;
				}
			} else {
				if(noInQty2 < qty) {
					alert("입고 가능한 수량을 초과했습니다.");
					return;
				}
			}

			fnSaveProcess(data, qty, "Y");
		}

		function fnHandWriteProcess() {
			var qty = $M.toNum($M.getValue("qty"));
			var noInQty = $M.toNum($M.getValue("no_in_qty"));
			var partNo = $M.getValue("input_part_no"); // 부품명

			// 특정부품들은 수량 입력 가능
			var msg = "입고 수량을 입력하세요.";
			if(noInQty >= 10) {
				var writeQty = prompt(msg);
				while(isNaN(writeQty)) {
					writeQty = prompt(msg);
				}

				qty = writeQty;
			}

			if(noInQty < qty) {
				alert("입고 가능한 수량을 초과했습니다.");
				return;
			}

			fnSaveProcess("", qty, "N");
		}

		function fnSaveProcess(data, qty, scanYn) {
			// 한 번 실행 시 리턴
			if(dupYn == "Y") {
				return false;
			}
			var params = {};
			params.inout_cmd = "C";
			if(scanYn == "Y") {
				params.part_no = data.part_no;
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

			dupYn = "Y";
			$M.goNextPageAjax(this_page + "/save", $M.toGetParam(params), {method: 'POST'},
				function (result) {
					if (result.success) {
						location.reload();
					}
				}
			);
			// 테스트용
// 			setTimeout(function() {
// 				fnSaveProcess(data, qty, scanYn);
// 			}, 500);
		}

		function fnAdd() {
			if($M.getValue("input_part_no") == "") {
				alert("입고처리 할 부품을 먼저 선택해주세요.");
				return;
			}

			fnHandWriteProcess();
		}

		function goRemove() {
			var frm = $M.toValueForm(document.main_form);
			$M.setValue(frm, "inout_dt", $M.getCurrentDate());
			$M.setValue(frm, "inout_cmd", "U");

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
					headerText : "전체",
					dataField: "qty",
					width : "5%",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{
					headerText : "출고",
					dataField : "trans_out_qty",
					width : "5%",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{
					headerText : "입고",
					dataField: "in_qty",
					width : "5%",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{
					headerText : "미입고",
					dataField : "no_in_qty",
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
					headerText : "수기처리여부",
					dataField : "barcode_hand_yn",
					visible : false
				}
			];

			auiGridTop = AUIGrid.create("#auiGridTop", columnLayout, gridPros)
			AUIGrid.setGridData(auiGridTop, ${list});
			$("#auiGridTop").resize();

			AUIGrid.bind(auiGridTop, "cellClick", function (event) {
				if (event.dataField == "part_no") {

					if(event.item.barcode_hand_yn == "N") {
						alert("[" + event.item.part_no + "] 부품은 수기처리가 불가능합니다.");
						return;
					}

					$M.setValue("no_in_qty", event.item.no_in_qty);
					$M.setValue("input_part_no", event.item.part_no);
					$M.setValue("qty", "1");
					$M.setValue("part_name", event.item.part_name);
					$M.setValue("barcode", event.item.barcode);
					$M.setValue("type_code", event.item.type_code);
					$M.setValue("seq_no", event.item.seq_no);
				}
			});
		}

		function createAUIGridBottom() {
			var gridPros = {
				rowIdField: "_$uid",
				showRowNumColumn : false,
			};

			var columnLayout = [
				{
					headerText: "처리일시",
					dataField: "s_reg_date",
					dataType : "date",
					formatString : "yy-mm-dd HH:MM:ss",
				},
				{
					headerText: "처리자",
					dataField: "reg_mem_name",
					width : "5%"
				},
				{
					headerText: "처리자번호",
					dataField: "reg_mem_no",
					visible: false
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
					formatString : "#,##0"
				},
				{
					headerText: "구분",
					dataField: "scan_name"
				},
				{
					headerText : "삭제",
					dataField : "remove",
					width : "9%",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							// 22.10.04 자동입고처리내역 삭제 시 출고처리내역에서만 삭제 가능
							if(event.item.scan_name == "자동입고") {
								alert("자동입고된 내역은 출고처리내역에서 삭제하실 수 있습니다.");
								return;
							}

							if(event.item.reg_mem_no != "${SecureUser.mem_no}") {
								alert("삭제는 처리자만 가능합니다.");
								return;
							}


							$M.setValue("s_part_no", event.item.part_no);
							var isRemoved = AUIGrid.isRemovedById(auiGridBottom, event.item._$uid);
							if (isRemoved == false) {
								AUIGrid.removeRow(event.pid, event.rowIndex);

								if (confirm("삭제 하시겠습니까?") == false) {
									AUIGrid.restoreSoftRows(auiGridBottom, "selectedIndex");
									return false;
								} else {
									goRemove();
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
					headerText: "전표일련번호",
					dataField: "inout_seq_no",
					visible: false
				},
				{
					headerText : "부품이동번호",
					dataField : "part_trans_no",
					visible : false
				},
				{
					headerText : "부품이동연번",
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

	<input type="hidden" id="no_out_qty" name="no_in_qty">
	<input type="hidden" id="total_qty" name="total_qty">
	<input type="hidden" id="type_code" name="type_code">
	<input type="hidden" id="seq_no" name="seq_no">
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
					<div class="dpf">
						<h4 class="pr15">입고처리</h4>
					</div>
					<div class="right text-warning">
						※ 바코드 인식이 안될 경우 바코드인식 버튼을 누른 후 진행해주세요.
					</div>
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
				</div>
				<table class="table-border mt5">
					<colgroup>
						<col width="60px">
						<col width="">
						<col width="50px">
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
							<input type="text" class="form-control width80px" id="cust_name" name="cust_name" readonly="readonly" value="${info.cust_name}">
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
					<div class="dpf">
						<h4 class="pr15">입고처리내역</h4>
					</div>
				</div>
				<table class="table-border mt5">
					<colgroup>
						<col width="80px">
						<col width="">
						<col width="80px">
						<col width="">
						<col width="80px">
						<col width="">
						<col width="50px">
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