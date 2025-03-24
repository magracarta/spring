<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 창고이동/부품출하 > 부품발송-출고처리 > null > 출고처리
-- 작성자 : 성현우
-- 최초 작성일 : 2020-10-13 17:45:28
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
		$(document).ready(function () {
			createAUIGridTop();
			createAUIGridBottom();

			fnInit();
		});

		function fnInit() {
			$("#_goSave").addClass("dpn");

			if(orgCode != "" && orgCode != loginOrgCode) {
				alert("처리창고가 맞지 않습니다.\n출고처리를 진행 할 수 없습니다.");

				$("#barcode").prop("readonly", true);
				$("#qty").prop("readonly", true);
				$("#_fnAdd").prop("disabled", true);
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

		// 바코드 리더기로 읽은 값 setting
		function fnBarcodeRead(barcode) {
			if(orgCode != loginOrgCode) {
				alert("처리창고가 맞지 않습니다.\n출고처리를 진행 할 수 없습니다.");
				return;
			}

			fnBarcode(barcode);
		}

		function fnBarcode(barcode) {
			var partBarcode = barcode;
			if(barcode.startsWith("C")) {
				partBarcode = $M.toNum(barcode.substr(2));
			}

			var param = {
				"s_barcode" : partBarcode,
				"s_machine_out_doc_seq" : $M.getValue("machine_out_doc_seq")
			};

			$M.goNextPageAjax(this_page + "/part/search", $M.toGetParam(param), {method: "GET"},
					function (result) {
						if (result.success) {
							$M.clearValue({field:["barcode"]});
							scanProcess(result);
						}
					}
			);
		}

		function scanProcess(data) {
			var qty = 1;
			var noOutQty = data.no_out_qty; // 출고가능수량
			var partNo = data.part_no; // 부품명
			var showInputQtyYn = data.show_qty_input_yn;

			var msg = "출고 수량을 입력하세요.";
			// 특정부품들은 수량 입력 가능
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

		function fnHandWriteProcess() {
			var qty = $M.toNum($M.getValue("qty"));
			var noOutQty = $M.toNum($M.getValue("no_out_qty"));

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

		// 바코드 최종
		function fnSaveProcess(data, qty, scanYn) {
			var params = {
				"inout_cmd" : "C",
				"machine_out_doc_seq" : $M.getValue("machine_out_doc_seq")
			};

			if(scanYn == "Y") {
				params.part_no = data.part_no;
				params.part_name = data.part_name;
				params.barcode = data.barcode;
				params.qty = qty;
				params.scan_yn = scanYn;
				params.inout_dt = $M.getCurrentDate();
				params.out_seq_no = data.out_seq_no;

			} else if(scanYn == "N") {
				params.part_no = $M.getValue("input_part_no");
				params.part_name = $M.getValue("part_name");
				params.barcode = $M.getValue("part_barcode");
				params.qty = qty;
				params.scan_yn = scanYn;
				params.inout_dt = $M.getCurrentDate();
				params.out_seq_no = $M.getValue("out_seq_no");
			}

			$M.goNextPageAjax(this_page + "/save", $M.toGetParam(params), {method: 'POST'},
					function (result) {
						if (result.success) {
							<c:if test="${not empty inputParam.parent_js_name}"> 
								if (opener != null && opener.${inputParam.parent_js_name} != null) {
									params["no_out_operation"] = "-"; // 미출고 수량 마이너스
									opener.${inputParam.parent_js_name}(params);
									location.reload();
								}
							</c:if>
							<c:if test="${empty inputParam.parent_js_name}">
								location.reload();
							</c:if>
						}
					}
			);
		}

		function fnAdd() {
			if($M.getValue("input_part_no") == "") {
				alert("출고처리 할 부품을 먼저 선택해주세요.");
				return;
			}

			fnHandWriteProcess();
		}
		
		function goRemove(event) {
			var params = {
				inout_dt : $M.getCurrentDate(),
				inout_cmd : "U", 
				use_yn : "N",
				part_inout_seq : event.item.part_inout_seq,
				out_seq_no : event.item.out_seq_no,
				qty : event.item.part_qty
			}
			$M.goNextPageAjax(this_page + "/save", $M.toGetParam(params), {method: 'POST'},
					function (result) {
						if (result.success) {
							<c:if test="${not empty inputParam.parent_js_name}"> 
								if (opener != null && opener.${inputParam.parent_js_name} != null) {
									params["no_out_operation"] = "+"; // 미출고 수량 더함
									opener.${inputParam.parent_js_name}(params);
									location.reload();
								}
							</c:if>
							<c:if test="${empty inputParam.parent_js_name}">
								location.reload();
							</c:if>
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
					headerText : "접수수량",
					dataField: "qty",
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
					headerText : "미출고",
					dataField : "no_out_qty",
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
					headerText: "부품바코드",
					dataField: "barcode",
					visible: false
				},
				{
					headerText: "장비품의서번호",
					dataField: "machine_doc_no",
					visible: false
				},
				{
					headerText: "장비출하의뢰번호",
					dataField: "machine_out_doc_seq",
					visible: false
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

					$M.setValue("no_out_qty", event.item.no_out_qty);
					$M.setValue("input_part_no", event.item.part_no);
					$M.setValue("qty", "1");
					$M.setValue("part_name", event.item.part_name);
					$M.setValue("part_barcode", event.item.barcode);
					$M.setValue("out_seq_no", event.item.seq_no);
				}
			});
		}

		function createAUIGridBottom() {
			var gridPros = {
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
					headerText : "처리자번호",
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

							// if(event.item.scan_yn == "Y" && event.item.check != "N") {
							// 	alert("바코드로 입력된 데이터는 삭제가 불가능합니다.");
							// 	return;
							// }

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
									goRemove(event);
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
					headerText : "장비출하의뢰번호",
					dataField : "machine_out_doc_seq",
					visible : false
				},
				{
					headerText : "장비출하의뢰번호",
					dataField : "out_seq_no",
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
<input type="hidden" id="login_mem_no" name="login_mem_no" value="${info.login_mem_no}">
<input type="hidden" id="login_mem_name" name="login_mem_name" value="${info.login_mem_name}">
<input type="hidden" id="scan_qty" name="scan_qty">
<input type="hidden" id="report_qty" name="report_qty"> <!-- 접수 수량 -->
<input type="hidden" id="part_barcode" name="part_barcode">
<input type="hidden" id="out_seq_no" name="out_seq_no">
<input type="hidden" id="no_out_qty" name="no_out_qty">
<input type="hidden" id="machine_out_doc_seq" name="machine_out_doc_seq" value="${info.machine_out_doc_seq}">
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
						<h4 class="pr15">출고처리</h4>
					</div>
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
						<th class="text-right">출하의뢰서번호</th>
						<td>
							<input type="text" class="form-control width120px" id="machine_doc_no" name="machine_doc_no" readonly="readonly" value="${info.machine_doc_no}">
						</td>
						<th class="text-right">고객명</th>
						<td>
							<input type="text" class="form-control width80px" id="cust_name" name="cust_name" readonly="readonly" value="${not empty info.cust_name ? info.cust_name : orgNameMap[info.display_org_code]}">
						</td>
						<th class="text-right">바코드</th>
						<td>
							<input type="text" class="form-control" id="barcode" name="barcode">
						</td>
					</tr>
					</tbody>
				</table>
				<div id="auiGridTop" style="margin-top: 5px; height: 460px;"></div>
			</div>
			<!-- /폼테이블 -->
			<!-- 폼테이블 -->
			<div>
				<div class="title-wrap">
					<div class="dpf">
						<h4 class="pr15">처리내역</h4>
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
				<div id="auiGridBottom" style="margin-top: 5px; height: 300px;"></div>
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