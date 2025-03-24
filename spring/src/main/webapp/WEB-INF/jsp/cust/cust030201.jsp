<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 거래현황 > 일계표 > null > null
-- 작성자 : 박예진
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGrid();
			fnInit();
			goSearch();
		});

		function fnInit() {
			<%--if(${checkYn} == "Y" && "${SecureUser.org_type}" == "BASE") {--%>
			if(${checkYn} == "Y" && ${page.fnc.F00674_001 eq 'Y'}) {
				$M.reloadComboData("s_org_code", []);
			}

			// 로그인한 사용자가 관리부서이면 처리구분 검색조건 노출
			if("${managementYn}" == "Y" || ${page.fnc.F00674_002 eq 'Y'}) {
				$(".management-yn").removeClass("dpn");
				$("#_goAccTrans").addClass("dpn");
				$("#_goCancelAccTrans").addClass("dpn");
			// 처리구분이 '회계'가 아닐 시 회계전송 관련 버튼 hide
			} else {
				$(".management-yn").addClass("dpn");
				$("#_goAccTrans").addClass("dpn");
				$("#_goCancelAccTrans").addClass("dpn");
			}
		}

		// 처리구분에 따른 디자인 변경
		function fnTransBtn() {
			if($M.getValue("trans_yn") == "T") {
				$("#_goAccTrans").removeClass("dpn");
				$("#_goCancelAccTrans").removeClass("dpn");
			} else {
				$("#_goAccTrans").addClass("dpn");
				$("#_goCancelAccTrans").addClass("dpn");
			}
		}

		function fnChangeEndDt() {
			$M.setValue("s_end_dt", $M.getValue("s_start_dt"));
			$M.setValue("s_org_code_arr", $M.getValue("s_org_code"));
// 			if("${SecureUser.org_type}" == "BASE") {
// 				$('#s_org_code').combogrid("setValues", "");
// 			}
// 			goSearchRequirement();
			goSearch();
		}

		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "inout_doc_no",
				showStateColumn : false,
				// No. 제거
				showRowNumColumn: true,
			    displayTreeOpen : true,
				enableCellMerge : false,
				showBranchOnGrouping : false,
				selectionMode : "singleRow",
				// 고정칼럼 카운트 지정
				// fixedColumnCount : 5,
				showFooter : true,
				footerPosition : "top",
				// 체크박스 출력 여부
				showRowCheckColumn : true,
				// 전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
				showSelectionBorder : true
				// 이 함수는 사용자가 체크박스를 클릭 할 때 1번 호출됩니다.
// 				rowCheckableFunction : function(rowIndex, isChecked, item) {
// 					if($M.getValue("trans_yn") == "T" && item.end_yn == "Y" && item.account_link_cd == "") {
// 						alert(rowIndex + 1 + "행의 회계거래처코드가 없습니다.");
// 						return false;
// 					}
// 					return true;
// 				},
			};
			var columnLayout = [
				{
					headerText : "소속부서",
					dataField : "org_name",
					width : "70",
					minWidth : "60",
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var orgName = value;
						return orgName.replace("센터", "");
					}
				},
				{
					headerText : "전표",
					dataField : "inout_doc_no",
					width : "85",
					minWidth : "90",
					style : "aui-center aui-popup",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var docNo = value;
						return docNo.substring(4, 16);
					}
				},
				{
					headerText : "고객명",
					dataField : "cust_name",
					width : "130",
					minWidth : "140",
					style : "aui-center aui-popup",
				},
				{
					headerText : "상호",
					dataField : "breg_name",
					width : "135",
					minWidth : "130",
					style : "aui-center",
				},
				{
					headerText : "전표구분",
					dataField : "inout_type_name",
					width : "90",
					minWidth : "60",
					style : "aui-center",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if(item["inout_type_cd"] == "01" || item["inout_type_cd"] == "02" || item["inout_type_cd"] == "04" || item["inout_type_cd"] == "06") {
							return "aui-popup";
						} else {
							return "aui-center";
						}
					},
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var inoutName = value;
						if(item["inout_type_cd"] == "04") {
							switch(item["inout_doc_type_cd"]) {
							case "05" :
								if(item["preorder_yn"] == "Y") {
									inoutName = "매출(선주문)";
								} else {
									inoutName = "매출(수주)";
								}
								break;
							case "07" : inoutName = "매출(정비)"; break;
							case "08" : inoutName = "매출(출하)"; break;
							case "11" : inoutName = "매출(렌탈)"; break;
							case "12" : inoutName = "매출(중고)"; break;
							case "13" : inoutName = "매출(렌탈장비)"; break;
							}
						}
						return inoutName;
					}
				},
				{
					headerText : "출고일자",
					dataField : "send_date",
					width: "90",
					dataType : "date",
					dataInputString : "yyyymmdd",
					formatString : "yy-mm-dd",
					style : "aui-center"
				},
				{
					headerText : "계정",
					dataField : "acc_type_name",
					width : "45",
					minWidth : "40",
					style : "aui-center"
				},
				{
					headerText : "내용",
					dataField : "dis_desc_text",
					width : "270",
					minWidth : "120",
					style : "aui-left"
				},
				{
					headerText : "물품대",
					dataField : "doc_amt",
					dataType : "numeric",
					formatString : "#,##0",
					width : "95",
					minWidth : "85",
					style : "aui-right",
					xlsxTextConversion : true,
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var amt = value;
						return amt == "0" ? "" : $M.setComma(amt);
					}
				},
				{
					headerText : "세액",
					dataField : "vat_amt",
					dataType : "numeric",
					formatString : "#,##0",
					width : "95",
					minWidth : "85",
					style : "aui-right",
					xlsxTextConversion : true,
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var amt = value;
						return amt == "0" ? "" : $M.setComma(amt);
					}
				},
				{
					headerText : "합계",
					dataField : "total_amt",
					dataType : "numeric",
					formatString : "#,##0",
					width : "95",
					minWidth : "85",
					style : "aui-right",
					xlsxTextConversion : true,
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var amt = value;
						return amt == "0" ? "" : $M.setComma(amt);
					}
				},
// 				{
// 					headerText : "입(출)금액",
// 					dataField : "inout_amt",
// 					dataType : "numeric",
// 					formatString : "#,##0",
// 					width : "5%",
// 					style : "aui-right"
// 				},
				{
					headerText : "처리",
					dataField : "tax_yn",
					width : "80",
					minWidth : "70",
					style : "aui-center"
				},
				{
					headerText : "전표연결",
					dataField : "in_inout_doc_no",
					width : "85",
					minWidth : "80",
					style : "aui-center aui-popup",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var docNo = value;
						return docNo.substring(4, 16);
					}
				},
				{
					headerText : "요청",
					dataField : "vat_treat_cd",
					style : "aui-center",
					width : "70",
					minWidth : "40",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var vatTreatName = "";
						if(value == "Y") {
							vatTreatName = "세금";
						} else if (value == "R") {
							vatTreatName = "보류";
						} else if (value == "S") {
							vatTreatName = "합산";
						} else if (value == "F" && item.taxbill_send_cd == "5") {
							vatTreatName = "수정";
						} else if (value == "C") {
							vatTreatName = "카드매출";
						} else if (value == "A") {
							vatTreatName = "현금영수증";
						} else if (value == "N") {
							vatTreatName = "무증빙";
						}
						return vatTreatName;
					}
				},
				{
					headerText : "영수청구",
					dataField : "taxbill_type_name",
					style : "aui-center aui-popup",
					width : "95",
					minWidth : "85",
				},
				{
					headerText : "작성자",
					dataField : "mem_name",
					width : "55",
					minWidth : "50",
					style : "aui-center"
				},
				{
					headerText : "현미수금",
					dataField : "ed_misu_amt",
					dataType : "numeric",
					formatString : "#,##0",
					width : "95",
					minWidth : "85",
					style : "aui-right",
					xlsxTextConversion : true,
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var amt = value;
						return amt == "0" ? "" : $M.setComma(amt);
					}
				},
				{
					headerText : "마감확인",
					dataField : "end_date",
					dataType : "date",
					// 최승희대리님 요청으로 마감확인 시간표시 - 210531 김상덕
					formatString : "yy-mm-dd HH:MM:ss",
					width : "115",
					minWidth : "70",
					style : "aui-center"
				},
				{
					headerText : "회계전송",
					dataField : "duzon_trans_date",
					dataType : "date",
					width : "80",
					minWidth : "70",
					formatString : "yy-mm-dd",
					style : "aui-center"
				},
				{
					dataField : "inout_org_code",
					visible : false
				},
				{
					dataField : "org_code",
					visible : false
				},
				{
					dataField : "inout_dt",
					visible : false
				},
				{
					dataField : "inout_type_cd",
					visible : false
				},
				{
					dataField : "inout_doc_type_cd",
					visible : false
				},
				{
					dataField : "acc_type_cd",
					visible : false
				},
				{
					dataField : "mem_no",
					visible : false
				},
				{
					dataField : "end_yn",
					visible : false
				},
				{
					dataField : "duzon_trans_yn",
					visible : false
				},
				{
					dataField : "account_link_cd",
					visible : false,
				},
				{
					dataField : "cust_no",
					visible : false
				},
				{
					dataField : "aui_status_cd",
					visible : false
				},
				{
					dataField : "taxbill_send_cd",
					visible : false
				},
				{
					dataField : "agency_pay_yn",
					visible : false
				},
				{
					dataField : "preorder_yn",
					visible : false
				},
				{
					dataField : "taxbill_no",
					visible : false
				},
				{
					dataField : "temp_yn",
					visible : false
				}
			];
			// 푸터레이아웃
			var footerColumnLayout = [
				{
					labelText : "합계",
					positionField : "dis_desc_text",
					style : "aui-center aui-footer",
				},
				{
					dataField : "doc_amt",
					positionField : "doc_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "vat_amt",
					positionField : "vat_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "total_amt",
					positionField : "total_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 푸터 객체 세팅
			AUIGrid.setFooter(auiGrid, footerColumnLayout);
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				var popupOption = "";
				if(event.dataField == "inout_type_name" ) {
					var param = {
						"inout_doc_no" : event.item["inout_doc_no"]
					};
					if(event.item["inout_type_cd"] == "04") {
						// 매출처리 팝업 (매출처리상세?)
						param.temp_yn = event.item["temp_yn"];
						$M.goNextPage('/cust/cust0202p01', $M.toGetParam(param), {popupStatus : popupOption});

					} else if(event.item["inout_type_cd"] == "06") {
						// 매입처리팝업
						$M.goNextPage('/part/part0302p01', $M.toGetParam(param), {popupStatus : popupOption});

					} else if(event.item["inout_type_cd"] == "01" || event.item["inout_type_cd"] == "02") {
						$M.goNextPage('/cust/cust0203p01', $M.toGetParam(param), {popupStatus : popupOption});

					}
				}
				if(event.dataField == "inout_doc_no" ) {
					// 전표세부내역
					var param = {
							"inout_doc_no" : event.item["inout_doc_no"]
					};
					$M.goNextPage('/cust/cust0302p01', $M.toGetParam(param), {popupStatus : popupOption});

				}

				if(event.dataField == "cust_name" ) {
					// 거래원장상세
					var params = {
							"s_cust_no" : event.item["cust_no"],
							"s_start_dt" : $M.getValue("s_start_dt"),
							"s_end_dt" : $M.getValue("s_end_dt"),
							"s_ledger_yn" : "Y"
					};
					openDealLedgerPanel($M.toGetParam(params));

				}

				if(event.dataField == "taxbill_type_name" ) {
					// 매출 세금계산서 관리
					var params = {
						"taxbill_no" : event.item["taxbill_no"],
					};
					var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=800, height=750, left=0, top=0";
					$M.goNextPage('/acnt/acnt0301p02', $M.toGetParam(params), {popupStatus : popupOption});
				}

				if(event.dataField == "in_inout_doc_no" && event.item.in_inout_doc_no != "") {
					// 연결전표
					var param = {
						"inout_doc_no" : event.item["in_inout_doc_no"]
					};
					$M.goNextPage('/cust/cust0203p01', $M.toGetParam(param), {popupStatus : popupOption});

				}
			});
			// 체크박스 클린 이벤트 바인딩
			AUIGrid.bind(auiGrid, "rowCheckClick", function(event) {
				console.log("event : ", event);

				// 회계거래처코드 체크
				if(event.checked == true && $M.getValue("trans_yn") == "T" && event.item["end_yn"] == "Y" && event.item["account_link_cd"] == "") {
					alert(event.rowIndex + 1 + "행의 회계거래처코드가 없습니다.");
					// row 데이터 업데이트
					AUIGrid.addUncheckedRowsByIds(auiGrid, event.item["inout_doc_no"]);
					return false;
				}

				// 대리점월정산 체크
				if(event.checked == true && $M.getValue("trans_yn") == "T" && event.item["agency_pay_yn"] == "Y") {
					// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
					// alert(event.rowIndex + 1 + "행은 대리점월정산 건입니다.");
					alert(event.rowIndex + 1 + "행은 위탁판매점 월정산 건입니다.");
					// row 데이터 업데이트
					AUIGrid.addUncheckedRowsByIds(auiGrid, event.item["inout_doc_no"]);
					return false;
				}
				return true;

			});

			// 전체 체크박스 클릭 이벤트 바인딩
			AUIGrid.bind(auiGrid, "rowAllChkClick", function(event) {
				if(event.checked == true && $M.getValue("trans_yn") == "T") {
					var row = "";
					var agencyRow = "";
					var arr = new Array();
					var agencyArr = new Array();
					var items = AUIGrid.getCheckedRowItemsAll(auiGrid);
					var gridData = AUIGrid.getGridData(auiGrid);

					for (var i = 0; i < items.length; i++) {
						// 회계거래처코드 체크
						if(items[i].account_link_cd == "" && items[i].end_yn == "Y") {
							for(var j = 0; j < gridData.length; j++) {
								if(items[i].inout_doc_no == gridData[j].inout_doc_no) {
									row = j + 1;
									arr.push(row);
								}
							}
							// row 데이터 업데이트
							AUIGrid.addUncheckedRowsByIds(auiGrid, items[i].inout_doc_no);
						}

						// 대리점월정산 체크
						if (items[i].agency_pay_yn == "Y") {
							for(var k = 0; k < gridData.length; k++) {
								if(items[i].inout_doc_no == gridData[k].inout_doc_no) {
									agencyRow = k + 1;
									agencyArr.push(agencyRow);
								}
							}
							// row 데이터 업데이트
							AUIGrid.addUncheckedRowsByIds(auiGrid, items[i].inout_doc_no);
						}
					}
					if(arr != "") {
						alert(arr + "행의 회계거래처코드가 없습니다.");
						return false;
					}

					if(agencyArr != "") {
						// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
						// alert(agencyArr + "행은 대리점월정산 건입니다.");
						alert(agencyArr + "행은 위탁판매점 월정산 건입니다.");
						return false;
					}
				}
			});
			$("#auiGrid").resize();
		}


		function goDone() {
			var items = AUIGrid.getCheckedRowItemsAll(auiGrid);
			if (items.length == 0) {
				alert("체크된 데이터가 없습니다.");
				return false
			}
			console.log(items);
			for (var i = 0; i < items.length; i++) {
				if(items[i].end_yn == "Y") {
					alert("마감처리된 전표가 있습니다.\n확인 후 다시 처리해주십시오.");
					return false;
				}
			}
			var param = {
				inout_doc_no_str : $M.getArrStr(items, {key : 'inout_doc_no'}),
				cust_no_str : $M.getArrStr(items, {key : 'cust_no'}),
			}
			var msg = "마감처리 하시겠습니까?";
			$M.goNextPageAjaxMsg(msg, "/cust/cust030201/endConfirm", $M.toGetParam(param), {method : 'POST'},
				function(result) {
					if(result.success) {
						goSearch();
					};
				}
			);
		}

		function goCancelDone() {
			var items = AUIGrid.getCheckedRowItemsAll(auiGrid);
			if (items.length == 0) {
				alert("체크된 데이터가 없습니다.");
				return false
			}

			for (var i = 0; i < items.length; i++) {
				if(items[i].duzon_trans_yn == "Y") {
					alert("회계처리된 자료는 마감취소가 불가합니다.");
					return false;
				}
				if(items[i].end_yn == "N") {
					alert("마감처리가 되지 않은 전표가 있습니다.\n확인 후 다시 처리해주십시오.");
					return false;
				}
			}

			var param = {
				inout_doc_no_str : $M.getArrStr(items, {key : 'inout_doc_no'}),
				inout_dt_str : $M.getArrStr(items, {key : 'inout_dt'}),
				org_code_str : $M.getArrStr(items, {key : 'org_code'}),
				cust_no_str : $M.getArrStr(items, {key : 'cust_no'})
			}
			var msg = "마감확인건을 취소하시겠습니까?";
			$M.goNextPageAjaxMsg(msg, "/cust/cust030201/endCancel", $M.toGetParam(param), {method : 'POST'},
				function(result) {
					if(result.success) {
						goSearch();
					};
				}
			);
		}

		function goAccTrans() {
			// account_link_cd가 있어야 회계전송 가능
			// row행의 회계거래처코드가 없습니다.
			var row = "";
			var items = AUIGrid.getCheckedRowItemsAll(auiGrid);
			var gridData = AUIGrid.getGridData(auiGrid);

			if (items.length == 0) {
				alert("체크된 데이터가 없습니다.");
				return false
			}

			for (var i = 0; i < items.length; i++) {
				if(items[i].end_yn != "Y") {
					alert("마감처리된 건만 회계처리가 가능합니다.");
					return false;
				}
				if(items[i].duzon_trans_yn == "Y") {
					alert("회계처리된 데이터가 있습니다.");
					return false;
				}
				if(items[i].account_link_cd == "") {
					for(var j = 0; j < gridData.length; j++) {
						if(items[i].inout_doc_no == gridData[j].inout_doc_no) {
							row = j + 1;
						}
					}
					alert(row + "행의 회계거래처코드가 없습니다.");
					return false;
				}

                // 2022-11-24 (SR: 14336) 매출전표일경우 조건 추가. (카드매출,현금영수증 추가)
                if(items[i].inout_type_cd == "04") {
					if((items[i].vat_treat_cd == "N" || items[i].vat_treat_cd == "A" || items[i].vat_treat_cd == "C") == false) {
						alert("매출전표일 경우 회계전송은 카드매출/현금영수증/무증빙 건만 처리할 수 있습니다.");
						return false;
					}
                } else if(items[i].inout_type_cd != "01" && items[i].inout_type_cd != "02" && items[i].inout_type_cd != "21") {
                	alert(items[i].inout_type_name + "전표는 회계전송이 불가능합니다.");
                	return false;
                }
			}

			var param = {
					inout_doc_no_str : $M.getArrStr(items, {key : 'inout_doc_no'}),
				}

			var msg = "회계전송하시겠습니까?";
			$M.goNextPageAjaxMsg(msg, "/cust/cust030201/accTrans", $M.toGetParam(param), {method : 'POST'},
				function(result) {
					if(result.success) {
						goSearch();
					};
				}
			);

		}

		function goCancelAccTrans() {
			var row = "";
			var items = AUIGrid.getCheckedRowItemsAll(auiGrid);

			if (items.length == 0) {
				alert("체크된 데이터가 없습니다.");
				return false
			}

			for (var i = 0; i < items.length; i++) {
				if(items[i].duzon_trans_yn != "Y") {
					alert("회계처리된 건만 취소가 가능합니다.");
					return false;
				}
			}

			var param = {
					inout_doc_no_str : $M.getArrStr(items, {key : 'inout_doc_no'}),
				}

			var msg = "회계전송을 취소하시겠습니까?";
			$M.goNextPageAjaxMsg(msg, "/cust/cust030201/cancelAccTrans", $M.toGetParam(param), {method : 'POST'},
				function(result) {
					if(result.success) {
						goSearch();
					};
				}
			);
		}

		// 검색조건 조회
		function goSearchRequirement() {
			$M.setValue("s_org_code_str", $M.getValue("s_org_code"));
			var param = {
					"s_search_type" : "Y",
					"s_start_dt" : $M.getValue("s_start_dt"),
					"s_start_year" : $M.getValue("s_start_dt").substring(0, 4) + "1231",
					"s_org_code_str" : $M.getValue("s_org_code"),
					"s_end_dt" : $M.getValue("s_end_dt")
			};
			$M.goNextPageAjax(this_page + '/searchDay', $M.toGetParam(param), {method : 'get'},
					function(result) {
						if(result.success) {

							// select box 옵션 전체 삭제
		    				$("#s_inout_org_code option").remove();

	    					var inoutOrgList = result.inoutOrgList;
	    					$("#s_inout_org_code").append(new Option("- 전체 -", ""));
	    					if(inoutOrgList.length > 0) {
	    						for (var i = 0; i <inoutOrgList.length; i++) {
	    							$("#s_inout_org_code").append(new Option(inoutOrgList[i].code_name, inoutOrgList[i].code_value));
	    						}
	    					}

							// select box 옵션 전체 삭제
		    				$("#s_mem_no option").remove();

		    				$("#s_mem_no").append(new Option("- 전체 -", ""));
	    					var memNoList = result.memNoList;
	    					if(memNoList.length > 0) {
	    						for (var i = 0; i <memNoList.length; i++) {
	    							$("#s_mem_no").append(new Option(memNoList[i].kor_name, memNoList[i].mem_no));
	    						}
	    					}

							<%--if("${SecureUser.org_type}" == "BASE") {--%>
							if(${page.fnc.F00674_001 eq 'Y'}) {
								$M.reloadComboData("s_org_code", result.orgList);
							}

							<%--if("${SecureUser.org_type}" == "BASE") {--%>
							if(${page.fnc.F00674_001 eq 'Y'}) {
								var orgCodeArr = $M.getValue("s_org_code_str").split("#");
								$('#s_org_code').combogrid("setValues", orgCodeArr);
							}

						};
					}
				);
		}

		//조회
		function goSearch() {
			$M.setValue("s_org_code_arr", $M.getValue("s_org_code"));
			var param = {
					"s_sort_key" : "inout_doc_no",
					"s_sort_method" : "desc",
					"s_search_type" : "Y",
					"s_org_code_str" : $M.getValue("s_org_code"),
					"s_acc_type_cd_str" : $M.getValue("s_acc_type_cd"),
					"s_inout_org_code" : $M.getValue("s_inout_org_code"),
					"s_mem_no" : $M.getValue("s_mem_no"),
					"s_agency_yn" : $M.getValue("s_agency_yn"),
					"s_inout_type_cd" : $M.getValue("s_inout_type_cd"),
					"s_end_yn" : $M.getValue("s_end_yn"),
					"s_vat_treat_cd" : $M.getValue("s_vat_treat_cd"),
					"s_start_dt" : $M.getValue("s_start_dt"),
					"s_start_year" : $M.getValue("s_start_dt").substring(0, 4) + "1231",
					"s_end_dt" : $M.getValue("s_end_dt"),
					"s_sale_inout_doc_yn" : $M.getValue("s_sale_inout_doc_yn"),
					"s_card_cmp_cd_str" : $M.getValue("s_card_cmp_cd"),
			};
			_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
			$M.setValue("s_org_code_str", $M.getValue("s_org_code"));
			$M.setValue("s_acc_type_cd_str", $M.getValue("s_acc_type_cd"));
			$M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'get'},
					function(result) {
						if(result.success) {

							if(result.list.length == 0) {
								alert("검색된 결과가 없습니다.");
							}

							AUIGrid.setGridData(auiGrid, result.list);
							$("#total_cnt").html(result.total_cnt);
							<%--if("${SecureUser.org_type}" == "BASE") {--%>
							if(${page.fnc.F00674_001 eq 'Y'}) {
								$M.reloadComboData("s_org_code", result.orgList);
							}

							// select box 옵션 전체 삭제
		    				$("#s_inout_org_code option").remove();

	    					var inoutOrgList = result.inoutOrgList;
	    					$("#s_inout_org_code").append(new Option("- 전체 -", ""));
	    					if(inoutOrgList.length > 0) {
	    						for (var i = 0; i <inoutOrgList.length; i++) {
	    							$("#s_inout_org_code").append(new Option(inoutOrgList[i].code_name, inoutOrgList[i].code_value));
	    						}
	    					}

							// select box 옵션 전체 삭제
		    				$("#s_mem_no option").remove();

		    				$("#s_mem_no").append(new Option("- 전체 -", ""));
	    					var memNoList = result.memNoList;
	    					if(memNoList.length > 0) {
	    						for (var i = 0; i <memNoList.length; i++) {
	    							$("#s_mem_no").append(new Option(memNoList[i].kor_name, memNoList[i].mem_no));
	    						}
	    					}

	    					<%--if("${SecureUser.org_type}" == "BASE") {--%>
	    					if(${page.fnc.F00674_001 eq 'Y'}) {
								var orgCodeArr = $M.getValue("s_org_code_str").split("#");
								$('#s_org_code').combogrid("setValues", orgCodeArr);
							}
							var accTypeArr = $M.getValue("s_acc_type_cd_str").split("#");
							$('#s_acc_type_cd').combogrid("setValues", accTypeArr);
						};
					}
				);
		}

		function fnDownloadExcel() {
			  // 엑셀 내보내기 속성
			  var exportProps = {
			  };
			  fnExportExcel(auiGrid, "일계표-명세", exportProps);
		}


	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" id="s_org_code_str" name="s_org_code_str">
<input type="hidden" id="s_acc_type_cd_str" name="s_acc_type_cd_str">
<div class="layout-box">
<!-- contents 전체 영역 -->
		<div class="content-wrap">
<!-- 검색영역 -->
					<div class="search-wrap mt10">
						<table class="table">
							<colgroup>
								<col width="55px">
								<col width="125px">
								<col width="55px">
								<col width="105px">
								<col width="75px">
<%--								<c:if test="${SecureUser.org_type ne 'BASE'}">--%>
								<c:if test="${page.fnc.F00674_001 ne 'Y'}">
									<col width="120px">
								</c:if>
<%--								<c:if test="${SecureUser.org_type eq 'BASE'}">--%>
								<c:if test="${page.fnc.F00674_001 eq 'Y'}">
									<col width="200px">
								</c:if>
								<col width="60px">
								<col width="80px">
								<col width="60px">
								<col width="80px">
								<col width="60px">
								<col width="110px">
								<col class="management-yn" width="60px">
								<col class="management-yn" width="65px">
								<col width="100px">
                <col width="100px">
							</colgroup>
							<tbody>
								<tr>
									<th>전표일자</th>
									<td colspan="3">
										<div class="form-row inline-pd widthfix">
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" value="${searchDtMap.s_start_dt}" onChange="javascript:fnChangeEndDt();">
												</div>
											</div>
											<div class="col-auto text-center">~</div>
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" value="${searchDtMap.s_end_dt}">
												</div>
											</div>
											<jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp">
				                     		<jsp:param name="st_field_name" value="s_start_dt"/>
				                     		<jsp:param name="ed_field_name" value="s_end_dt"/>
				                     		<jsp:param name="click_exec_yn" value="Y"/>
				                     		<jsp:param name="exec_func_name" value="goSearch();"/>
				                     		</jsp:include>
										</div>
									</td>
									<th>소속부서</th>
									<td colspan="3">
										<!-- 센터일 경우, 소속 센터만 조회가능하므로 셀렉트박스로 안함. -->
<%--										<c:if test="${SecureUser.org_type ne 'BASE'}">--%>
										<c:if test="${page.fnc.F00674_001 ne 'Y'}">
											<input type="text" class="form-control" value="${SecureUser.org_name}" readonly="readonly" style="width:120px;">
											<input type="hidden" value="${SecureUser.org_code}" id="s_org_code" name="s_org_code" readonly="readonly">
										</c:if>
										<!-- 본사의 경우, 전체 센터목록 선택가능 -->
<%--										<c:if test="${SecureUser.org_type eq 'BASE'}">--%>
										<c:if test="${page.fnc.F00674_001 eq 'Y'}">
											<input class="form-control" style="width: 99%;" type="text" id="s_org_code" name="s_org_code" easyui="combogrid"
											   easyuiname="orgList" panelwidth="300" idfield="code_value" textfield="code_name" multi="Y"/>
										</c:if>
									</td>
									<th>계정구분</th>
									<td colspan="3">
										<input class="form-control" style="width: 300px;" type="text" id="s_acc_type_cd" name="s_acc_type_cd" easyui="combogrid"
										   easyuiname="accTypeList" panelwidth="300" idfield="code_value" textfield="code_name" multi="Y"/>
									</td>
                  <th>카드사</th>
                  <td colspan="3">
                    <input class="form-control" style="width: 200px;"   type="text" id="s_card_cmp_cd" name="s_card_cmp_cd" easyui="combogrid"
                           easyuiname="cardCmpTypeList" panelwidth="200" idfield="code_value" textfield="code_name" multi="Y"/>
                  </td>
								</tr>
								<tr>
									<th>처리센터</th>
									<td>
										<select class="form-control" id="s_inout_org_code" name="s_inout_org_code">
											<option value="">- 전체 -</option>
											<c:forEach items="${inoutOrgList}" var="item">
											<option value="${item.code_value}">${item.code_name}</option>
											</c:forEach>
										</select>
									</td>
									<th>담당자</th>
									<td>
										<select class="form-control" id="s_mem_no" name="s_mem_no">
											<option value="">- 전체 -</option>
											<c:forEach items="${memNoList}" var="item">
											<option value="${item.mem_no}">${item.kor_name}</option>
											</c:forEach>
										</select>
									</td>
									<%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체 --%>
									<%--<th>일반/대리점</th>--%>
									<th>일반/위탁판매점</th>
									<td>
										<select class="form-control" id="s_agency_yn" name="s_agency_yn">
											<option value="">- 전체 -</option>
											<option value="N">일반</option>
											<%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체 --%>
											<%--<option value="Y">대리점</option>--%>
											<option value="Y">위탁판매점</option>
										</select>
									</td>
									<th>전표구분</th>
									<td>
										<select class="form-control" id="s_inout_type_cd" name="s_inout_type_cd">
											<option value="">- 전체 -</option>
											<c:forEach items="${codeMap['INOUT_TYPE']}" var="item">
											<c:if test="${item.code_value ne '14' && item.code_value ne '15' && item.code_value ne '16' && item.code_value ne '17'}"><option value="${item.code_value}">${item.code_name}</c:if></option>
											</c:forEach>
											<option value="0405">매출(수주)</option>
											<option value="0407">매출(정비)</option>
											<option value="0408">매출(출하)</option>
											<option value="0411">매출(렌탈)</option>
											<option value="0412">매출(중고)</option>
											<option value="0413">매출(렌탈장비)</option>
											<option value="00">매출(선주문)</option>
										</select>
									</td>
									<th>마감구분</th>
									<td>
										<select class="form-control" id="s_end_yn" name="s_end_yn">
											<option value="">- 전체 -</option>
											<option value="Y">마감확인</option>
											<option value="N">미확인</option>
										</select>
									</td>
									<th>요청구분</th>
									<td>
										<select class="form-control" id="s_vat_treat_cd" name="s_vat_treat_cd">
											<option value="">- 전체 -</option>
											<option value="Y">세금계산서</option>
<%--											<option value="R">보류(추후발행)</option>--%>
											<option value="S">합산발행</option>
											<option value="F">수정세금계산서</option>
											<option value="C">카드매출</option>
											<option value="A">현금영수증</option>
											<option value="N">무증빙</option>
										</select>
									</td>
									<th class="management-yn">처리구분</th>
									<td class="management-yn">
										<select class="form-control" id="trans_yn" name="trans_yn" onChange="javascript:fnTransBtn();">
											<option value="E">마감</option>
											<option value="T">회계</option>
										</select>
									</td>
									<th></th>
									<td>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="checkbox" name="s_sale_inout_doc_yn" id="s_sale_inout_doc_yn" value="Y">
											<label for="s_sale_inout_doc_yn" class="form-check-label">전표 미 연결</label>
										</div>
									</td>
									<td>
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
									</td>
								</tr>
							</tbody>
						</table>
					</div>
<!-- /검색영역 -->
<!-- 조회결과 -->
					<div class="title-wrap mt10">
						<div class="left">
							<h4>조회결과</h4>
						</div>
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
					</div>
<!-- /조회결과 -->
					<div id="auiGrid" style="margin-top: 5px; height: 555px; width:100%;"></div>
					<div class="btn-group mt5">
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">0</strong>건
						</div>
					</div>
			</div>
		</div>
<!-- /contents 전체 영역 -->
</form>
</body>
</html>
