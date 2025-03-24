<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 매입관리 > 부품매입관리 > null > 부품매입처리
-- 작성자 : 성현우
-- 최초 작성일 : 2020-09-25 17:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var fileIdx;
		var auiGrid;
		var item = ${resultMap};
		var resultMap = ${resultMap};
		$(document).ready(function() {
			// 그리드 생성
			createAUIGrid();
			fnSetFileInfo();

			fnInit();
		});

		function fnInit() {
			if(resultMap != null) {
				$("#_goSave").addClass("dpn");
				$("#main_form :input").prop("disabled", true);
				$("#main_form :button").prop("disabled", false);
				$("#search_file1").prop("disabled", true);
				$("#search_file2").prop("disabled", true);
				$("#search_file3").prop("disabled", true);
				$("#_goOrderReferPopup").prop("disabled", true);
			} else {
				$("#_fnBacodePrint").prop("disabled", true);
				$("#_goPrint").prop("disabled", true);
			}
		}

		//팝업 닫기
		function fnClose(){
			window.close();
		}

		// 저장
		function goSave() {
			var frm = document.main_form;
			//validationcheck
			if($M.validation(frm,
					{field:["cust_name",  "doc_amt", "total_amt", "vat_amt"]}) == false) {
				return;
			};

			// 정산요청 체크 시 정산요청일 추가 -- 2024.05.27[황다은]
			if($M.getValue("s_pay_req_yn") == 'Y') {
				var date = new Date();
				var year = date.getFullYear();
				var mon = ("0" + (1 + date.getMonth())).slice(-2);
				var day = ("0" + date.getDate()).slice(-2);

				var clientPayReqDt = year+mon+day;

				$M.setValue(frm, "client_pay_req_dt", clientPayReqDt);
			}

			// 메모전표 활용여부
			if($M.isCheckBoxSel("memo_chk")) {
				$M.setValue(frm, "memo_yn", "Y");
			} else {
				$M.setValue(frm, "memo_yn", "N");
			}
			
			var gridData = AUIGrid.getGridData(auiGrid);
			
			// (Q&A 12208) 이태희님 요청으로 매입수량 입력하지 않을 시 저장 안되도록 추가 21.09.07 박예진
			for(var i = 0; i < gridData.length; i++) {
				if(gridData[i].qty == 0 || gridData[i].qty == undefined) {
					alert("수량을 입력 후 진행해주세요.");
					return false;
				}
			}
			var concatCols = [];
			var concatList = [];
			var gridIds = [auiGrid];
			for (var i = 0; i < gridIds.length; ++i) {
				concatList = concatList.concat(AUIGrid.exportToObject(gridIds[i]));
				concatCols = concatCols.concat(fnGetColumns(gridIds[i]));
			}

			frm = $M.toValueForm(document.main_form);
			var gridData = fnGridDataToForm(concatCols, concatList);
			$M.copyForm(gridData, frm);

			$M.goNextPageAjaxSave(this_page + "/save", gridData, {method: "POST"},
					function (result) {
						if (result.success) {
							alert("저장이 완료되었습니다.");
							fnClose();
							window.opener.goSearch();
						}
					}
			);
		}

		// 바코드전용프린터
		function fnBacodePrint() {
			fnGoPrint('02');
		}
		
		// 일반레이저프린터
		function goPrint() {
			fnGoPrint('01');
		}
		
		function fnGoPrint(gubun) {
			var rows = AUIGrid.getGridData(auiGrid);
			
			if (rows.length == 0) {
				alert("최소 1개이상 선택해 주십시오.")
				return false;
			}
			
			var totalRows = [];
			for (var i in rows) {
				for (var j = 0; j < rows[i].qty; j++) {
					totalRows.push(rows[i]);
				}
			}
			
			
			var param = {
				"data" : totalRows
			}
			
			openReportPanel('part/part050301_' + gubun + '.crf', param);
		}

		// 거래원장
		function goLedger() {
			var custNo = $M.getValue("cust_no");
			if(custNo == "") {
				alert("발주처 조회를 먼저 진행해주세요.");
				return;
			}

			var params = {
				"s_cust_no" : custNo
			};

			$M.goNextPage('/part/part0303p01', $M.toGetParam(params), {popupStatus : getPopupProp(1550, 860)});
		}

		// 매입처 조회
		function fnSearchClientComm() {
			var param = {};
			openSearchClientPanel("setSearchClientInfo", "comm", $M.toGetParam(param));
		}

		// 매입처 조회 팝업 클릭 후 리턴
		function setSearchClientInfo(data) {
			$M.setValue("cust_no", data.cust_no); // 발주처 번호
			$M.setValue("cust_name", data.cust_name); // 발주처
			$M.setValue("sale_mem_name", data.charge_name); // 담당자
			$M.setValue("breg_name", data.breg_name); // 업체명
			$M.setValue("cust_hp_no", $M.phoneFormat(data.hp_no)); // 휴대폰
			$M.setValue("breg_rep_name", data.breg_rep_name); // 대표자
			$M.setValue("tel_no", $M.phoneFormat(data.tel_no)); // 전화번호
			$M.setValue("breg_no", data.breg_no); // 사업자번호
			$M.setValue("cust_fax_no", $M.phoneFormat(data.fax_no)); // 팩스
			$M.setValue("breg_cor_type", data.breg_cor_type); // 업태
			$M.setValue("breg_cor_part", data.breg_cor_part); // 종목 (업종)
			$M.setValue("biz_post_no", data.post_no); // 우편번호
			$M.setValue("biz_addr1", data.addr1); // 주소1
			$M.setValue("biz_addr2", data.addr2); // 주소2
		}

		// 발주자료참조
		function goOrderReferPopup() {
			
			var custNo = $M.getValue("cust_no");
			
			if(custNo == "" || custNo == undefined){
				alert("선택된 발주처 정보가 없습니다.");
				return;
			}
			var params = {
					
				"cust_no": $M.getValue("cust_no"),
				"parent_js_name" : "fnSetPartOrder"
			};

			var poppupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=800, height=350, left=0, top=0";
			$M.goNextPage("/part/part0302p02", $M.toGetParam(params), {popupStatus: poppupOption});
		}

		// 22.10.20 15267 매입단가입력팝업
		function goCalcUnitPricePopup() {
			var gridData = AUIGrid.getGridData(auiGrid);
			if(gridData.length == 0) {
				alert("대상부품을 입력 후 진행해주세요.");
				return;
			}
			var params = {
				"parent_js_name" : "fnSetGridData"
			};

			var poppupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=570, height=800, left=0, top=0";
			$M.goNextPage("/part/part0302p06", $M.toGetParam(params), {popupStatus: poppupOption});
		}

		function fnSetGridData(){
			var gridData = AUIGrid.getGridData(auiGrid);
			return gridData;
		}

		function fnUnitPriceApply(data, applyErRate, mngAmt){
			var gridData = AUIGrid.getGridData(auiGrid);
			for(var i=0; i<gridData.length; i++) {
				gridData[i].unit_price = data[i].unit_price;
			}
			AUIGrid.setGridData(auiGrid, gridData);
			for(var i=0; i<gridData.length; i++) {
				if(gridData[i].qty > 0){
					var unitPrice = 0;
					unitPrice = data[i].unit_price * gridData[i].qty;
					AUIGrid.updateRow(auiGrid, {"amt" : unitPrice}, i, true); // 금액 업데이트
				}
			}
			fncCalcDocAmt(); // 물품대, 부가세, 합계금액 업데이트
			$M.setValue("apply_er_rate", applyErRate);
			$M.setValue("mng_amt", mngAmt);
		}

		function fnSetPartOrder(data) {
			// 중복 Data check
			for(var i in data) {
				var partOrderNo = AUIGrid.getItemsByValue(auiGrid, "part_order_no", data[i].part_order_no);
				var partNo = AUIGrid.getItemsByValue(auiGrid, "item_id", data[i].part_no);

				if(partNo.length > 0 && partOrderNo.length > 0) {
					alert("발주번호[" + data[i].part_order_no + "]의 \n부품번호[" + data[i].part_no + "]는 이미 입력하셨습니다.\n다시 확인하세요.");
					return;
				}
			}

			var item = new Object();
			for(var i in data) {

				item.item_id = data[i].part_no; // 부품번호
				item.item_name = data[i].part_name; // 부품명
				item.maker_name = data[i].maker_name; // 기종
				// item.unit = data[i].part_unit; // 단위
				item.money_unit_cd = data[i].money_unit_cd; // 화폐단위
				item.current_all_qty = data[i].current_qty; // 현재고
				item.unit_price = data[i].unit_price; // 매입단가
				item.in_price = data[i].unit_price; // 입고원가
				item.order_unit_price = data[i].unit_price; // 발주단가
				item.amt = 0; // 금액 ( 0으로초기화)
				// item.delivary_dt = data[i].delivary_dt; // 비고
				item.remark = data[i].remark; // 비고
				item.mi_qty = data[i].mi_qty; // 미처리량
				item.origin_mi_qty = data[i].mi_qty; // 미처리량 (원본))
				item.part_order_seq_no = data[i].seq_no; // 번호
				item.part_order_no = data[i].part_order_no; // 발주번호
				item.cust_no = data[i].cust_no; // 고객번호
				item.com_buy_group_cd = data[i].com_buy_group_cd; // 고객번호
				item.part_production_cd = data[i].part_production_cd; // 생산구분

				AUIGrid.addRow(auiGrid, item, 'last');
			}

			$("#total_cnt").html(data.length);
		}

		// 물품대, 합계금액, 부가세 계산
		function fncCalcDocAmt() {
			var gridData = AUIGrid.getGridData(auiGrid);
			var docAmt = 0;

			for(var i in gridData) {
				docAmt += $M.toNum(gridData[i].amt);
			}

			var vatAmt = docAmt * 0.1;
			var totalAmt = docAmt + vatAmt;
			$M.setValue("doc_amt", docAmt);
			$M.setValue("vat_amt", vatAmt.toFixed(2));
			$M.setValue("total_amt", totalAmt.toFixed(2));
		}

		// 파일찾기 팝업
		function goSearchFile(idx) {
			fileIdx = idx;
			var param = {
				upload_type	: 'PART',
				file_type : 'both',
				max_size : 2048
			};
			openFileUploadPanel("setFileInfo", $M.toGetParam(param));
		}

		// 팝업창에서 받아온 값
		function setFileInfo(result) {

			$("#file_name_item_div" + fileIdx).remove();
			showFileNameTd(fileIdx);

			var fileName; // 파일업로드 대상 컬럼 name값
			var str = '';
			str += '<div class="table-attfile-item' + fileIdx + '" id="file_name_item_div' + fileIdx + '">';
			str += '<a href="javascript:fileDownload(' + result.file_seq + ');" style="color: blue;">' + result.file_name + '</a>&nbsp;';

			if (fileIdx == 1) {
				fileName = "invoice_file_seq"
			} else if (fileIdx == 2) {
				fileName = "import_file_seq"
			} else if (fileIdx == 3) {
				fileName = "bl_file_seq"
			}

			str += '<input type="hidden" id="file_seq" name="' + fileName + '" value="' + result.file_seq + '"/>';
			str += '<button type="button" class="btn-default" onclick="javascript:fnRemoveFile(' + fileIdx + ');"><i class="material-iconsclose font-18 text-default"></i></button>';
			str += '</div>';

			$("#file_name_div" + fileIdx).append(str);
		}

		// 파일명 노출
		function showFileNameTd(fileIdx) {
			$("#file_search_td" + fileIdx).addClass("dpn");
			$("#file_name_td" + fileIdx).removeClass("dpn");
		}

		// 파일삭제
		function fnRemoveFile(fileIdx) {
			var result = confirm("파일을 삭제하시겠습니까?");
			if (result) {
				showFileSearchTd(fileIdx);
				$("#file_name_item_div" + fileIdx + " input").val("0");
			} else {
				return false;
			}
		}

		// 파일찾기 버튼 노출
		function showFileSearchTd(fileIdx) {
			$("#file_search_td" + fileIdx).removeClass("dpn");
			$("#file_name_td" + fileIdx).addClass("dpn");
		}

		// 파일정보 노출
		function fnSetFileInfo() {
			if (resultMap != null) {
				
				// 인보이스
				if("" == resultMap.invoice_file_seq || "" == resultMap.invoice_file_name) {
					showFileSearchTd(1);
				} else {
					fileIdx = 1;
					var file_info = {
						"file_seq" : resultMap.invoice_file_seq,
						"file_name" : resultMap.invoice_file_name,
						"fileIdx" : fileIdx
					};

					setFileInfo(file_info);
					showFileNameTd();
				}

				// 수입면장
				if("" == resultMap.import_file_seq || "" == resultMap.import_file_name) {
					showFileSearchTd(2);
				} else {
					fileIdx = 2;
					var file_info = {
						"file_seq" : resultMap.import_file_seq,
						"file_name" : resultMap.import_file_name,
						"fileIdx" : fileIdx
					};

					setFileInfo(file_info);
					showFileNameTd();
				}

				// B/L
				if("" == resultMap.bl_file_seq || "" == resultMap.bl_file_name) {
					showFileSearchTd(3);
				} else {
					fileIdx = 3;
					var file_info = {
						"file_seq" : resultMap.bl_file_seq,
						"file_name" : resultMap.bl_file_name,
						"fileIdx" : fileIdx
					};

					setFileInfo(file_info);
					showFileNameTd();
				}
			}	
		}

		
		// 사업자명세 팝업
		function goBregSpecInfo() {
			if($M.getValue("cust_no") == "") {
				alert("고객을 검색하여 먼저 입력해주세요.");
				return false;
			}
			var param = {
	    			 "s_cust_no" : $M.getValue("cust_no")
	    	  };
	    	  openSearchBregSpecPanel("fnSetBregSpec", $M.toGetParam(param));
		}
		
		// 사업자명세
	    function fnSetBregSpec(row) {
	    	 var param = {
	 	        	"breg_name" : row.breg_name,
	 	        	"breg_no" : row.breg_no,
	 	        	"breg_rep_name" : row.breg_rep_name,
	 	        	"breg_cor_type" : row.breg_cor_type,
	 	        	"breg_cor_part" : row.breg_cor_part,
	 	        	"breg_seq" : row.breg_seq,
	 	        	"biz_post_no" : row.biz_post_no,
	 	        	"biz_addr1" : row.biz_addr1,
	 	        	"biz_addr2" : row.biz_addr2,
	 	        };
	 	        $M.setValue(param);
	    }
		
		
		// 그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn: true,
				editable : true,
				showStateColumn : true,
				//체크박스 출력 여부
				showRowCheckColumn : false,
				//전체선택 체크박스 표시 여부
				showRowAllCheckBox : false,
				// 행 소프트 제거 모드 해제
				softRemoveRowMode : false,
			};

			if(resultMap == null) {
				gridPros.editable = true;
			} else {
				gridPros.editable = false;
			}

			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
				    dataField: "part_no",
					visible : false
				},
				{
				    dataField: "part_name",
				    visible : false
				},
					// 22.10.27 Q&A 15267 생산구분확인
				{
				    dataField: "part_production_cd",
				    visible : false
				},
				{
					headerText: "발주단가",
				    dataField: "order_unit_price",
				    visible : false
				},
				{
				    headerText: "부품번호",
				    dataField: "item_id",
					editable : false,
					width : "13%",
					style : "aui-center"
				},
				{
					headerText : "부품명",
					dataField : "item_name",
					editable : false,
					width: "15%",
					style : "aui-left"
				},
				{
				    headerText: "기종",
				    dataField: "maker_name",
					editable : false,
					width : "8%",
					style : "aui-center"
				},
				{
				    headerText: "현재고",
				    dataField: "current_all_qty",
					editable : false,
					width : "5%",
					style : "aui-center",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{
				    headerText: "수량",
				    dataField: "qty",
					width : "5%",
					style : "aui-center",
					dataType : "numeric",
					formatString : "#,##0",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item) {
						if(resultMap == null) {
							return "aui-editable";
						}
					},
				},
				{
					headerText: "화폐단위",
					dataField: "money_unit_cd",
					editable : false,
					width : "10%",
					style : "aui-center"
				},
				{
				    headerText: "입고원가",
				    dataField: "in_price",
					width : "10%",
					style : "aui-right",
					dataType : "numeric",
					editable : true,
					formatString : "#,##0.00",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item) {
						if(item.order_unit_price != item.in_price){ //
							return "aui-status-reject-or-urgent";
						} else if(resultMap == null) {
							if(item.com_buy_group_cd == "A") {
								return "aui-editable";
							}
						}
					},
				},
				{
				    headerText: "매입단가",
				    dataField: "unit_price",
					width : "10%",
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0",
				},
				{
				    headerText: "금액",
				    dataField: "amt",
					editable : false,
					width : "10%",
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{
				    headerText: "비고",
				    // dataField: "delivary_dt",
				    dataField: "remark",
					editable : false,
					width : "15%",
					style : "aui-left"
				},
				{
				    headerText: "미처리량",
				    dataField: "mi_qty",
					editable : false,
					width : "7%",
					style : "aui-center",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{
				    headerText: "미처리량(원본)",
				    dataField: "origin_mi_qty",
					visible : false
				},
				{
				    headerText: "번호",
				    dataField: "part_order_seq_no",
					editable : false,
					width : "8%",
					style : "aui-center"
				},
				{
				    headerText: "발주번호",
				    dataField: "part_order_no",
					editable : false,
					width : "10%",
					style : "aui-center"
				},
				{
					headerText : "고객번호",
					dataField : "cust_no",
					visible : false
				},
				{
					headerText : "삭제",
					dataField : "removeBtn",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							if(resultMap != null) {
								return false;
							}

							var isRemoved = AUIGrid.isRemovedById(auiGrid, event.item._$uid);
							if (isRemoved == false) {
								AUIGrid.removeRow(event.pid, event.rowIndex);
							} else {
								AUIGrid.restoreSoftRows(auiGrid, "selectedIndex");
							}

							var total = AUIGrid.getGridData(auiGrid).length;
							$("#total_cnt").html(total);
							fncCalcDocAmt();
						}
					},
					labelFunction : function(rowIndex, columnIndex, value,
											 headerText, item) {
						return '삭제'
					},
					style : "aui-center",
					editable : true
				},
				{
					headerText : "매입처그룹코드",
					dataField : "com_buy_group_cd",
					visible : false
				},
				{
					dataField : "barcode",
					visible : false
				}
			];
			

			// 그리드 출력
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);

			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, ${list});

			// 에디팅 시작 이벤트 바인딩
			AUIGrid.bind(auiGrid, "cellEditBegin", function (event) {
				if (event.dataField == "unit_price") {
					// if(event.item.com_buy_group_cd != "A") {
					// 	return false; // false 를 반환하면 수정 불가임.
					// }
					return false;
				}
			});

			// 클릭한 셀 데이터 받음
			// AUIGrid.bind(auiGrid, "cellClick", function(event) {
			// 	if(event.dataField == "unit_price") {
			// 		var params = {
			// 			"s_cust_no" : event.item.cust_no,
			// 			"s_item_id" : event.item.item_id
			// 		};
			//
			// 		var poppupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=600, height=400, left=0, top=0";
			// 		$M.goNextPage("/part/part0302p03", $M.toGetParam(params), {popupStatus : poppupOption});
			// 	}
			// });

			// 수량 입력 시 금액 변경
			AUIGrid.bind(auiGrid, "cellEditEnd", auiGridCellEditHandler);
		}

		function auiGridCellEditHandler(event) {
			var rowIndex = event.rowIndex;
			if(event.dataField == "qty") {
				var item = AUIGrid.getItemByRowIndex(auiGrid, rowIndex);
				var qty = $M.toNum(item.qty);
				var miQty = $M.toNum(item.mi_qty);
				var originMiQty = $M.toNum(item.origin_mi_qty);		//미처리수량(원본)
				
				var unitPrice = $M.toNum(item.unit_price);
				var amt = qty <= originMiQty ? qty * unitPrice : $M.toNum(item.amt);

				if(qty > originMiQty) {
					alert("발주수량보다 입력 수량이 많습니다.\n확인 후 처리하세요.");
					AUIGrid.updateRow(auiGrid, { "qty" : 0 }, rowIndex);
					AUIGrid.updateRow(auiGrid, { "amt" : 0 }, rowIndex);
					AUIGrid.updateRow(auiGrid, { "mi_qty" : originMiQty }, rowIndex);
					
				} else {
					// 미처리량 update
					miQty = originMiQty - qty;
					AUIGrid.updateRow(auiGrid, {"mi_qty" : miQty}, rowIndex, false);
					AUIGrid.updateRow(auiGrid, { "amt" : amt }, rowIndex);
				}
				fncCalcDocAmt();
			}else if(event.dataField == "in_price"){
				var item = AUIGrid.getItemByRowIndex(auiGrid, rowIndex);
				if(item.part_production_cd =="1"){ // 국산부품인 경우 입고원가 변경 시 매입원가도 변경
					var inUnitPrice = $M.toNum(item.in_price);
					var qty = $M.toNum(item.qty);
					var amt = qty * inUnitPrice;

					AUIGrid.updateRow(auiGrid, { "unit_price" : inUnitPrice }, rowIndex);
					AUIGrid.updateRow(auiGrid, { "amt" : amt }, rowIndex);
				}
			}

		}
	</script>
</head>
<body class="bg-white class">
<form id="main_form" name="main_form">
<input type="hidden" id="cust_no" name="cust_no" value="${result.cust_no}">
<input type="hidden" id="memo_yn" name="memo_yn">
<input type="hidden" id="doc_barcode_no" name="doc_barcode_no" value="${result.doc_barcode_no}">
<input type="hidden" id="apply_er_rate" name="apply_er_rate">
<input type="hidden" id="mng_amt" name="mng_amt">
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
					<h4>부품매입처리</h4>
					<div>
						<span class="text-warning pr5">※ 발주서가 마감상태 이거나 일마감이 된 경우 삭제 할 수 없습니다. 마감취소 후 삭제가능</span>
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
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
						<th class="text-right">전표번호</th>
						<td>
							<input type="text" class="form-control width120px" id="inout_doc_no" name="inout_doc_no" readonly="readonly" value="${result.inout_doc_no}">
						</td>
						<th class="text-right">전표일자</th>
						<td>
							<div class="input-group">
								<c:choose>
									<c:when test="${size == 0}">
										<input type="text" class="form-control border-right-0 calDate" id="inout_dt" name="inout_dt" dateformat="yyyy-MM-dd" value="${inputParam.s_current_dt}">
									</c:when>
									<c:when test="${size != 0}">
										<input type="text" class="form-control border-right-0 calDate" id="inout_dt" name="inout_dt" dateformat="yyyy-MM-dd" value="${result.inout_dt}">
									</c:when>
								</c:choose>
							</div>
						</td>
						<th class="text-right">발주처</th>
						<td>
							<div class="input-group">
								<input type="text" class="form-control border-right-0" id="cust_name" name="cust_name" readonly="readonly" value="${result.cust_name}" required="required" alt="발주처">
								<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSearchClientComm();"><i class="material-iconssearch"></i></button>
							</div>
						</td>
						<th class="text-right">담당자</th>
						<td>
							<input type="text" class="form-control" id="sale_mem_name" name="sale_mem_name" readonly="readonly" value="${result.charge_name}">
						</td>
					</tr>
					<tr>
						<th class="text-right">처리창고</th>
						<td>
						<%-- 매입처리시 기본 입고창고로 디폴트. 11.27 수정 --%>
							<input type="text" class="form-control width120px" id="inout_org_name" name="inout_org_name" readonly="readonly" value="입고창고">
							<input type="hidden" class="form-control" id="inout_org_code" name="inout_org_code" readonly="readonly" value="${inoutOrgCode}">
						</td>
						<th class="text-right">담당자</th>
						<td>
							<input type="text" class="form-control" id="reg_mem_no" name="reg_mem_no" readonly="readonly" value="${result.reg_mem_name}">
						</td>
						<th class="text-right">업체명</th>
						<td>
							<input type="text" class="form-control" id="breg_name" name="breg_name" readonly="readonly" value="${result.breg_name}">
						</td>
						<th class="text-right">휴대폰</th>
						<td>
							<input type="text" class="form-control" id="cust_hp_no" name="cust_hp_no" readonly="readonly" format="phone" value="${result.cust_hp_no}">
						</td>
					</tr>
					<tr>
						<th class="text-right essential-item">물품대</th>
						<td>
							<div class="form-row inline-pd">
								<div class="col-10">
									<input type="text" class="form-control text-right essential-bg" id="doc_amt" name="doc_amt" required="required" alt="물품대" format="decimal" value="${result.doc_amt}">
								</div>
								<div class="col-2">원</div>
							</div>
						</td>
						<th class="text-right essential-item">부가세</th>
						<td>
							<div class="form-row inline-pd">
								<div class="col-10">
									<input type="text" class="form-control text-right essential-bg" id="vat_amt" name="vat_amt" required="required" alt="부가세" format="decimal" value="${result.vat_amt}">
								</div>
								<div class="col-2">원</div>
							</div>
						</td>
						<th class="text-right">대표자</th>
						<td>
							<input type="text" class="form-control" id="breg_rep_name" name="breg_rep_name" readonly="readonly" value="${result.breg_rep_name}">
						</td>
						<th class="text-right">전화번호</th>
						<td>
							<input type="text" class="form-control" id="tel_no" name="tel_no" readonly="readonly" value="${result.tel_no}">
						</td>
					</tr>
					<tr>
						<th class="text-right essential-item">합계금액</th>
						<td>
							<div class="form-row inline-pd">
								<div class="col-6">
									<input type="text" class="form-control text-right essential-bg" id="total_amt" name="total_amt" required="required" alt="합계금액" format="decimal" value="${result.total_amt}">
								</div>
								<div class="col-1">원</div>
								<div class="col-5">
									<button type="button" class="btn btn-primary-gra" style="width: 100%;" onclick="javascript:goLedger();">매입거래원장</button>
								</div>
							</div>
						</td>
						<th class="text-right">운송비</th>
						<td>
							<div class="form-row inline-pd">
								<div class="col-10">
									<input type="text" class="form-control text-right" id="invoice_transport_amt" name="invoice_transport_amt" alt="운송비" format="decimal" value="${result.invoice_transport_amt}">
								</div>
								<div class="col-2">원</div>
							</div>
						</td>
						<th class="text-right">사업자No</th>
						<td>			
							<div class="input-group">			
								<input type="text" class="form-control border-right-0" id="breg_no" name="breg_no" readonly="readonly" value="${result.breg_no}">
								<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goBregSpecInfo();"><i class="material-iconssearch"></i></button>
							</div>
						</td>
						<th class="text-right">팩스</th>
						<td>
							<input type="text" class="form-control" id="cust_fax_no" name="cust_fax_no" readonly="readonly" value="${result.cust_fax_no}">
						</td>
					</tr>
					<tr>
						<th class="text-right">인보이스</th>
						<td colspan="3">
							<div id="file_search_td1">
								<button type="button" id="search_file1" class="btn btn-primary-gra" onclick="javascript:goSearchFile(1)">파일찾기</button>
							</div>
							<div id="file_name_td1" class="dpn">
								<div class="table-attfile" id="file_name_div1">
								</div>
							</div>
						</td>
						<th class="text-right">업태</th>
						<td>
							<input type="text" class="form-control" id="breg_cor_type" name="breg_cor_type" readonly="readonly" value="${result.breg_cor_type}">
						</td>
						<th class="text-right">종목</th>
						<td>
							<input type="text" class="form-control" id="breg_cor_part" name="breg_cor_part" readonly="readonly" value="${result.breg_cor_part}">
						</td>
					</tr>
					<tr>
						<th class="text-right">수입면장</th>
						<td id="file_search_td2">
							<button type="button" id="search_file2" class="btn btn-primary-gra" onclick="javascript:goSearchFile(2)">파일찾기</button>
						</td>
						<td id="file_name_td2" class="dpn">
							<div class="table-attfile" id="file_name_div2">
							</div>
						</td>
						<th class="text-right">B/L</th>
						<td id="file_search_td3">
							<button type="button" id="search_file3" class="btn btn-primary-gra" onclick="javascript:goSearchFile(3)">파일찾기</button>
						</td>
						<td id="file_name_td3" class="dpn">
							<div class="table-attfile" id="file_name_div3">
							</div>
						</td>
						<th rowspan="2" class="text-right">주소</th>
						<td colspan="3" rowspan="2">
							<div class="form-row inline-pd mb7">
								<div class="col-4">
									<input type="text" class="form-control" id="biz_post_no" readonly="readonly" name="biz_post_no" value="${result.biz_post_no}">
								</div>
								<div class="col-8">
									<input type="text" class="form-control" id="biz_addr1" readonly="readonly" name="biz_addr1" value="${result.biz_addr1}">
								</div>
							</div>
							<div class="form-row inline-pd">
								<div class="col-12">
									<input type="text" class="form-control" id="biz_addr2" readonly="readonly" name="biz_addr2" value="${result.biz_addr2}">
								</div>
							</div>
						</td>
					</tr>
					<tr>
						<th class="text-right">비고</th>
						<td colspan="3">
							<div class="form-row inline-pd">
								<div class="col-9">
									<input type="text" class="form-control" id="desc_text" name="desc_text" value="${result.desc_text}">
								</div>
								<div class="col-3">
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="checkbox" id="memo_chk" name="memo_chk">
										<label class="form-check-label" for="memo_chk">메모전표활용</label>
									</div>
								</div>
							</div>
						</td>
					</tr>
					</tbody>
				</table>
			</div>
			<!-- /상단 폼테이블 -->
			<!-- 부품목록 -->
			<div>
				<div class="title-wrap mt10">
					<h4>부품목록</h4>
					<div class="right">
						<input type="checkbox" class="right" id="s_pay_req_yn" name="s_pay_req_yn" value="Y" checked="checked">
						<label class="form-check-label" for="s_pay_req_yn" style="width: 55px; font-size: 13px;">정산요청</label>
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
					</div>
				</div>
				<div id="auiGrid" style="margin-top: 5px; height: 300px;"></div>
			</div>
			<!-- /부품목록 -->
			<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">0</strong>건
				</div>
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