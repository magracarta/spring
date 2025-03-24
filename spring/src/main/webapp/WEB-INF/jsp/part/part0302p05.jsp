<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 매입관리 > 부품매입관리 > null > 부품매입처리 상세
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
			
			var sCurrentMon = "${inputParam.s_current_mon}"; // 당월
			var inoutDtMon = resultMap.inout_dt.substr(0, 6); // 전표날짜
			
			// 마감된 자료 (발주마감,전표마감,당월이 아닌 경우)
			if(resultMap.part_order_status_cd == "9" || resultMap.end_yn == "Y" || (sCurrentMon != inoutDtMon)) {
				$("#_goSave").addClass("dpn");
				$("#_goRemove").addClass("dpn");
				$M.getValue("proc_status") != "02" ? $("#main_form :input").not("#file_seq, #out_case_dt, #client_pay_plan_dt").prop("disabled", true) : $("#main_form :input").not("#file_seq").prop("disabled", true);	// 파일삭제버튼은 활성화 -2024.05.29[황다은]
				$("#main_form :button").prop("disabled", false);
				$("#preorder_inout_doc_no").prop("disabled", false);
				// $("#search_file1").prop("disabled", true);	// 황다은.자동화개발_매입처자동화 - 파일은 마감 후에도 수정가능
				// $("#search_file2").prop("disabled", true);
				// $("#search_file3").prop("disabled", true);
				$("#_goOrderReferPopup").prop("disabled", true);
			}
			// 처리상태가 "저장"이면 <정산요청>버튼 노출, "요청"이면 <정산요청취소>버튼 노출, "완료"일 경우 둘다 노출 X - 2024.05.24[황다은]
			if(resultMap.proc_status == "00") {
				$("#_goPayReqCancel").addClass("dpn");
			} else if (resultMap.proc_status == "01") {
				$("#_goPayRequest").addClass("dpn");
			} else {
				$("#_goPayReqCancel").addClass("dpn");
				$("#_goPayRequest").addClass("dpn");
				$("#btn_plan_dt_save").addClass("dpn");
				$("#out_case_dt").prop("disabled", true)
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

			// 메모전표 활용여부
			if($M.isCheckBoxSel("memo_chk")) {
				$M.setValue(frm, "memo_yn", "Y");
			} else {
				$M.setValue(frm, "memo_yn", "N");
			}

			var concatCols = [];
			var concatList = [];
			var gridIds = [auiGrid];
			for (var i = 0; i < gridIds.length; ++i) {
				concatList = concatList.concat(AUIGrid.exportToObject(gridIds[i]));
				concatCols = concatCols.concat(fnGetColumns(gridIds[i]));
			}

			frm = $M.toValueForm(document.main_form);
			var gridData;
			if($M.getValue("part_yn") == "Y") {
				gridData = fnChangeGridDataToForm(auiGrid, "N");
			} else {
				gridData = fnGridDataToForm(concatCols, concatList);
			}
			$M.copyForm(gridData, frm);

			$M.goNextPageAjaxSave(this_page + "/save", gridData, {method: "POST"},
					function (result) {
						if (result.success) {
							alert("저장이 완료되었습니다.");
							window.location.reload();
						}
					}
			);
		}

		// 전표 삭제
		function goRemove() {
			var concatCols = [];
			var concatList = [];
			var gridIds = [auiGrid];
			for (var i = 0; i < gridIds.length; ++i) {
				concatList = concatList.concat(AUIGrid.exportToObject(gridIds[i]));
				concatCols = concatCols.concat(fnGetColumns(gridIds[i]));
			}

			frm = $M.toValueForm(document.main_form);
			var gridData;
			if($M.getValue("part_yn") == "Y") {
				gridData = fnChangeGridDataToForm(auiGrid, "N");
			} else {
				gridData = fnGridDataToForm(concatCols, concatList);
			}
			$M.copyForm(gridData, frm);

			$M.goNextPageAjaxRemove(this_page + "/remove", gridData, {method: "POST"},
					function (result) {
						if (result.success) {
							alert("삭제가 완료되었습니다.");
							if($M.getValue("part_yn") != "Y") {
								fnClose();
								window.opener.goSearch();
							} else {
								window.location.reload();
								fncCalcDocAmt();
							}
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
		
		// QR전용프린터
		function fnPrintQr() {
			goQrSave();
			setTimeout(function() {
				fnGoPrint('04');
			}, 300);
		}
		
		// QR레이저프린터
		function fnQrPrint() {
			goQrSave();
			setTimeout(function() {
				fnGoPrint('03');
			}, 300);
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
				item.unit = data[i].part_unit; // 단위
				item.current_all_qty = data[i].current_qty; // 현재고
				item.unit_price = data[i].unit_price; // 단가
				item.amt = 0; // 금액 ( 0으로초기화)
				item.delivary_dt = data[i].delivary_dt; // 비고
				item.mi_qty = data[i].mi_qty; // 미처리량
				item.origin_mi_qty = data[i].mi_qty; // 미처리량 (원본))
				item.part_order_seq_no = data[i].seq_no; // 번호
				item.part_order_no = data[i].part_order_no; // 발주번호
				item.cust_no = data[i].cust_no; // 고객번호
				item.com_buy_group_cd = data[i].com_buy_group_cd; // 고객번호

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

		// 인보이스, 수입면장, B/L은 후에 수정가능요청(자동화개발)-[황다은]
		function handlerFileSaveClick(idx){
			var params = {};
			switch(idx) {
				case 1 :
					params = {
						"invoice_file_seq": $M.getValue("invoice_file_seq")
					};
					break;
				case 2 :
					params = {
						"import_file_seq": $M.getValue("import_file_seq")
					};
					break;
				case 3 :
					params = {
						"bl_file_seq": $M.getValue("bl_file_seq")
					};
					break;
			}
			// pklist(공통부분) 넣기
			params.inout_doc_no = $M.getValue("inout_doc_no");
			params.cust_no = $M.getValue("cust_no");
			params.file_gubun = idx;

			var msg = idx == 1 ? "인보이스 파일을 저장하시겠습니까?" : (idx == 2 ? "수입면장 파일을 저장하시겠습니까?" : "B/L 파일을 저장하시겠습니까?");
			$M.goNextPageAjaxMsg(msg, this_page + "/fileSave", $M.toGetParam(params), {method: "POST"},
					function (result) {
						if (result.success) {
							alert("파일이 저장되었습니다.");
							window.location.reload();
						}
					}
			);

		}

		// 정산예정일 저장
		function fnPayPlanDtSave() {
			var param = {
				"inout_doc_no" : $M.getValue("inout_doc_no"),
				"cust_no" : $M.getValue("cust_no"),
				"client_pay_plan_dt" : $M.getValue("out_case_dt")
			}

			$M.goNextPageAjaxSave(this_page + "/planDtSave", $M.toGetParam(param), {method: "POST"},
					function (result) {
						if (result.success) {
							alert("정산 예정일이 성공적으로 변경이 되었습니다.");
							window.location.reload();
							if("${inputParam.call_page_seq}" == 5743) {
								// window.close();
								window.opener.goSearch();
							}
						}
					}
			);
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
				showRowAllCheckBox : false
			};

// 			if(resultMap == null) {
// 				gridPros.editable = true;
// 			} else {
// 				gridPros.editable = false;
// 			}

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
				/*{
				    headerText: "단위",
				    dataField: "unit",
					editable : false,
					width : "5%",
					style : "aui-center"
				},*/
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
					style : "aui-center aui-editable",
					dataType : "numeric",
					formatString : "#,##0",
// 					styleFunction :  function(rowIndex, columnIndex, value, headerText, item) {
// 						if(resultMap == null) {
// 							return "aui-editable";
// 						}
// 					},
				},
				{
				    dataField: "qty_copy",
				    visible : false
				},
				{
					headerText: "화폐단위",
					dataField: "money_unit_cd",
					editable : false,
					width : "5%",
					style : "aui-center"
				},
				{
					headerText: "입고원가",
					dataField: "in_price",
					width : "10%",
					style : "aui-right",
					dataType : "numeric",
					editable : false,
					formatString : "#,##0.00",
				},
				{
				    // headerText: "단가",
				    headerText: "매입단가",
				    dataField: "unit_price",
					width : "10%",
					style : "aui-right",
					dataType : "numeric",
					editable : false,
					formatString : "#,##0",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item) {
				    	if(resultMap == null) {
							if(item.com_buy_group_cd == "A") {
								return "aui-editable";
							}
						}
					},
				},
				{
				    headerText: "금액",
				    dataField: "amt",
					editable : false,
					width : "10%",
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0.00"
				},
				// {
				//     headerText: "비고",
				//     dataField: "delivary_dt",
				// 	editable : false,
				// 	width : "15%",
				// 	style : "aui-left"
				// },
				{
				    headerText: "비고",
				    dataField: "remark", // 22.10.23 계약납기일이 아닌 발주 시 작성한 내용출력되도록 변경
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
				// {
				// 	headerText : "삭제",
				// 	dataField : "removeBtn",
				// 	renderer : {
				// 		type : "ButtonRenderer",
				// 		onClick : function(event) {
				//
				// 			if($M.getValue("part_order_status_cd") == "9") {
				// 				alert("마감된 자료는 삭제할 수 없습니다.");
				// 				return;
				// 			}
				//
				// 			var isRemoved = AUIGrid.isRemovedById(auiGrid, event.item._$uid);
				// 			if (isRemoved == false) {
				// 				AUIGrid.removeRow(event.pid, event.rowIndex);
				// 			} else {
				// 				AUIGrid.restoreSoftRows(auiGrid, "selectedIndex");
				// 			}
				//
				// 			$M.setValue("part_yn", "Y");
				// 			goRemove();
				// 			// var total = AUIGrid.getGridData(auiGrid).length;
				// 			// $("#total_cnt").html(total);
				// 			// fncCalcDocAmt();
				// 		}
				// 	},
				// 	labelFunction : function(rowIndex, columnIndex, value,
				// 							 headerText, item) {
				// 		return '삭제'
				// 	},
				// 	style : "aui-center",
				// 	editable : true
				// },
				{
					headerText : "매입처그룹코드",
					dataField : "com_buy_group_cd",
					visible : false
				},
				{
					dataField : "barcode",
					visible : false
				},
				{
					headerText: "전표번호",
					dataField: "inout_doc_no",
					visible: false
				},
				{
					headerText: "순번",
					dataField: "inout_doc_seq_no",
					visible: false
				},
				{
					headerText: "매입처번호",
					dataField: "deal_cust_no",
					visible: false
				},
				{
					headerText: "매입일자",
					dataField: "stock_dt",
					visible: false
				},
				{
					headerText: "부품QR",
					dataField: "part_qr_no",
					visible: false
				}
			];
			

			// 그리드 출력
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);

			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, ${list});

			// 에디팅 시작 이벤트 바인딩
			AUIGrid.bind(auiGrid, "cellEditBegin", function (event) {
				if (event.dataField == "unit_price") {
					if(event.item.com_buy_group_cd != "A") {
						return false; // false 를 반환하면 수정 불가임.
					}
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
			if(event.dataField == "qty" || event.dataField == "unit_price") {
				var item = AUIGrid.getItemByRowIndex(auiGrid, rowIndex);
				var qty = $M.toNum(item.qty);
				var qty_copy = $M.toNum(item.qty_copy);
				var miQty = $M.toNum(item.mi_qty);
				var originMiQty = $M.toNum(item.origin_mi_qty);		//미처리수량(원본)
				
				var unitPrice = $M.toNum(item.unit_price);
				var amt = qty <= originMiQty ? qty * unitPrice : $M.toNum(item.amt);

				if (qty > qty_copy) {
					alert("기존수량 " + qty_copy + "개 보다 적게 입력해주세요.");
					AUIGrid.updateRow(auiGrid, { "qty" : qty_copy }, rowIndex);
					return false;
				}
				
				
// 				if(qty > originMiQty) {
// 					alert("발주수량보다 입력 수량이 많습니다.\n확인 후 처리하세요.");
// 					AUIGrid.updateRow(auiGrid, { "qty" : 0 }, rowIndex);
// 					AUIGrid.updateRow(auiGrid, { "amt" : 0 }, rowIndex);
// 					AUIGrid.updateRow(auiGrid, { "mi_qty" : originMiQty }, rowIndex);
					
// 				} else {
// 					// 미처리량 update
// 					miQty = originMiQty - qty;
// 					AUIGrid.updateRow(auiGrid, {"mi_qty" : miQty}, rowIndex, false);
// 					AUIGrid.updateRow(auiGrid, { "amt" : amt }, rowIndex);
// 				}
// 				fncCalcDocAmt();
			}
		}
		
		// 선주문 상세 오픈
		function goReferDetailPopup() {
			
			if($M.getValue("preorder_inout_doc_no") == "") {
				alert("선택된 선주문 전표번호가 없습니다.");
				return false;
			}
			var params = {
				"inout_doc_no" : $M.getValue("preorder_inout_doc_no")
			};
			
			var poppupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=600, height=400, left=0, top=0";
			$M.goNextPage("/part/part0204p01", $M.toGetParam(params), {popupStatus : poppupOption});
		}

		// QR코드 저장
		function goQrSave() {
			var frm = $M.toValueForm(document.main_form);
			var concatCols = [];
			var concatList = [];
			var gridIds = [auiGrid];
			for (var i = 0; i < gridIds.length; ++i) {
				concatList = concatList.concat(AUIGrid.exportToObject(gridIds[i]));
				concatCols = concatCols.concat(fnGetColumns(gridIds[i]));
			}

			var gridForm = fnGridDataToForm(concatCols, concatList);
			$M.copyForm(gridForm, frm);

			$M.goNextPageAjax("/part/part050301/qrSave", gridForm, {method: "POST"},
					function (result) {
						if (result.success) {
							var partQrJson = JSON.parse(result.partQrCodeMap);
							var gridData = AUIGrid.getGridData(auiGrid);
							for(var i = 0; i < gridData.length; i++) {
								AUIGrid.updateRow(auiGrid, { "part_qr_no" : partQrJson[gridData[i].part_no] }, i);
							}
						}
					}
			);
		}

		// 정산요청기능 추가(자동화개발)
		function goPayRequest() {
			goPayReqAndCancel("req");
		}

		// 정산삭제요청기능 추가(자동화개발)
		function goPayReqCancel() {
			goPayReqAndCancel("cancel")
		}

		function goPayReqAndCancel(gubun) {
			var date = new Date();
			var year = date.getFullYear();
			var mon = ("0" + (1 + date.getMonth())).slice(-2);
			var day = ("0" + date.getDate()).slice(-2);

			var clientPayReqDt = year+mon+day;
			var params = {
				"inout_doc_no" : $M.getValue("inout_doc_no"),
				"client_pay_req_dt" : gubun == "req" ? clientPayReqDt : null,
				"cust_no" : $M.getValue("cust_no"),
				"client_pay_plan_dt" : $M.getValue("out_case_dt")
			};

			var msg = gubun == "req" ? "정산요청하시겠습니까?" : "정산요청을 취소하시겠습니까?";
			$M.goNextPageAjaxMsg(msg, this_page + "/requestPayAndCancel", $M.toGetParam(params), {method: "POST"},
					function (result) {
						if (result.success) {
							alert(gubun == "req" ? "정산요청이 되었습니다." : "정산요청이 취소되었습니다.");
							window.location.reload();
							if("${inputParam.call_page_seq}" == 5743) {
								window.opener.goSearch();
							}
						}
					});
		}
	</script>
</head>
<body class="bg-white class">
<form id="main_form" name="main_form">
<input type="hidden" id="cust_no" name="cust_no" value="${result.cust_no}">
<input type="hidden" id="memo_yn" name="memo_yn">
<input type="hidden" id="doc_barcode_no" name="doc_barcode_no" value="${result.doc_barcode_no}">
<input type="hidden" id="part_order_status_cd" name="part_order_status_cd" value="${result.part_order_status_cd}">
<input type="hidden" id="end_yn" name="end_yn" value="${result.end_yn}">
<input type="hidden" id="part_yn" name="part_yn">
<input type="hidden" id="proc_status" name="proc_status" value="${result.proc_status}">
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
							<div class="input-group">
								<input type="text" class="form-control width120px" id="inout_doc_no" name="inout_doc_no" readonly="readonly" value="${result.inout_doc_no}">
								<c:if test="${result.part_order_status_cd eq '9'}">
									<span class="aui-color-red ml5">[마감완료]</span>
								</c:if>
							</div>
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
							<div class="form-row inline-pd" style="padding-left:6px">
								<div id="file_search_td1">
									<button type="button" id="search_file1" class="btn btn-primary-gra" onclick="javascript:goSearchFile(1)">파일찾기</button>
								</div>
								<div id="file_name_td1" class="dpn">
									<div class="table-attfile" id="file_name_div1">
									</div>
								</div>
								<div>
									<button type="button" id="btn_invoice_save" class="btn btn-primary-gra ml5" onclick="javascript:handlerFileSaveClick(1);">저장</button>
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
							<td>
								<div class="form-row inline-pd" style="padding-left:6px">
									<div id="file_search_td2">
										<button type="button" id="search_file2" class="btn btn-primary-gra" onclick="javascript:goSearchFile(2)">파일찾기</button>
									</div>
									<div id="file_name_td2" class="dpn">
										<div class="table-attfile" id="file_name_div2"></div>
									</div>
									<div>
										<button type="button" id="btn_import_save" class="btn btn-primary-gra ml5" onclick="javascript:handlerFileSaveClick(2);">저장</button>
									</div>
								</div>
							</td>
						<th class="text-right">B/L</th>
							<td>
								<div class="form-row inline-pd" style="padding-left:6px">
									<div id="file_search_td3">
										<button type="button" id="search_file3" class="btn btn-primary-gra" onclick="javascript:goSearchFile(3)">파일찾기</button>
									</div>
									<div id="file_name_td3" class="dpn">
										<div class="table-attfile" id="file_name_div3">
										</div>
									</div>
									<div>
										<button type="button" id="btn_bl_save" class="btn btn-primary-gra ml5" onclick="javascript:handlerFileSaveClick(3);">저장</button>
									</div>
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
					<tr>
						<th class="text-right">선주문현황 </th>
						<td colspan="3">
							<div class="form-row inline-pd">
								<div class="col-auto">
									<select class="form-control" required="required" id="preorder_inout_doc_no" name="preorder_inout_doc_no">
										<option value="">- 선택 -</option>
										<c:forEach items="${preOrderList}" var="item">
											<option value="${item}">${item}</option>
										</c:forEach>
									</select>
								</div>
								<div class="col-auto">
									<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp" ><jsp:param name="pos" value="MID_L"/></jsp:include>
								</div>
							</div>
						</td>
						<th class="text-right">정산예정일</th>
						<td colspan="3">
							<div class="form-row inline-pd">
								<div class="input-group">
									<c:choose>
										<c:when test="${result.client_pay_plan_dt == ''}">
											<input type="text" style="margin-left: 6px;" class="form-control border-right-0 calDate" id="out_case_dt" name="out_case_dt" dateformat="yyyy-MM-dd" value="${result.out_case_dt}">
										</c:when>
										<c:when test="${result.client_pay_plan_dt != ''}">
											<input type="text" style="margin-left: 6px;" class="form-control border-right-0 calDate" id="out_case_dt" name="out_case_dt" dateformat="yyyy-MM-dd" value="${result.client_pay_plan_dt}">
										</c:when>
									</c:choose>
									<div>
										<button type="button" class="btn btn-primary-gra ml5" id="btn_plan_dt_save" onclick="javascript:fnPayPlanDtSave();">저장</button>
									</div>
								</div>
<%--								<div class="col-2">--%>
<%--									<input type="text" class="form-control" dateformat="yyyy-MM-dd" id="out_case_dt" name="out_case_dt" value="${result.out_case_dt}">--%>
<%--								</div>--%>

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
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp" ><jsp:param name="pos" value="MID_R"/></jsp:include>
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