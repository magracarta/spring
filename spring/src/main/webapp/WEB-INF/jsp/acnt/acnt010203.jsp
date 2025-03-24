<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 비용관리 > 전도금정산서 > null > null
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-04-08 17:55:01
-- 금전출납부
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		var auiGridLeft;
		var auiGridRight;
		
		$(document).ready(function() {
			createAUIGridLeft();
			createAUIGridRight();
			fnInit();
		});

		// 닫을때 체크박스 체크 및 회계일자, 계정구분, 사용자 입력
		function fnSetImprestCheck(data) {
			var rowIndex = $M.getValue("clickedRowIndex");
			if (data.type == "M") {
				if (data.acnt_dt) {
					AUIGrid.setCellValue(auiGridLeft, rowIndex, "acnt_dt", data.acnt_dt);	
				}
				if (data.acnt_code) {
					AUIGrid.setCellValue(auiGridLeft, rowIndex, "acnt_code", data.acnt_code);
					AUIGrid.setCellValue(auiGridLeft, rowIndex, "acnt_name", data.acnt_name);
				}
				if (data.remark) {
					AUIGrid.setCellValue(auiGridLeft, rowIndex, "remark", data.remark);	
				}
				if (data.used_mem_no) {
					AUIGrid.setCellValue(auiGridLeft, rowIndex, "used_mem_no", data.used_mem_no);
				}
				var rowId = AUIGrid.indexToRowId(auiGridLeft, rowIndex);
				AUIGrid.addCheckedRowsByIds(auiGridLeft, rowId);
			} else if (data.type == "D") {
				AUIGrid.removeRow(auiGridLeft, rowIndex);
				AUIGrid.removeSoftRows(auiGridLeft);
			} else if (data.type == "C") {
				console.log(data);
				goSearch();
			}
		}
		
		function fnInit() {
			var now = "${inputParam.s_current_dt}";
			$M.setValue("s_start_dt", $M.addDates($M.toDate(now), -7));
			if ("${page.fnc.F00676_001}" == "Y") {
				$("#_goConfirmProcess").css("display", "none");
			} else {
				$("#_goAccTrans").css("display", "none");
				$("#_goCancelAccTrans").css("display", "none");
			}
		}
		
		function fnUpdateParentDtAnGoSearch() {
			var value = $M.getValue("s_start_dt");
		    $('#s_start_dt', window.parent.document).val(value);
		    var value = $M.getValue("s_end_dt");
			$('#s_end_dt', window.parent.document).val(value);
			if ($M.getValue("s_org_code") != "") {
				goSearch();
			}
		}
		
		function fnUpdateParentStartDt() {
			var value = $M.getValue("s_start_dt");
		    $('#s_start_dt', window.parent.document).val(value);
		}
		
		function fnUpdateParentEndDt() {
			var value = $M.getValue("s_end_dt");
			$('#s_end_dt', window.parent.document).val(value);
		}
		
		function fnUpdateParentOrgCode() {
			var value = $M.getValue("s_org_code");
			$('#s_org_code', window.parent.document).val(value);
		}
		
		function fnUpdateParentImprestCd() {
			var value = $M.getValue("s_imprest_status_cd");
			$('#s_imprest_status_cd', window.parent.document).val(value);
		}
		
		function fnUpdateParentExcept() {
			$('#s_except_acnt_confirm', window.parent.document).prop('checked', $("#s_except_acnt_confirm").prop("checked"));
		}

		function goSearch() {
			if ($M.validation(document.main_form) == false) {
				return;
			};
			if($M.checkRangeByFieldName('s_start_dt', 's_end_dt', true) == false) {				
				return;
			}; 
			var param = {
				s_start_dt : $M.getValue("s_start_dt"),
				s_end_dt : $M.getValue("s_end_dt"),
				s_org_code : $M.getValue("s_org_code"),
				s_except_acnt_confirm : $M.getValue("s_except_acnt_confirm"),
				s_imprest_status_cd : $M.getValue("s_imprest_status_cd")
			};
			_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
			console.log(param);
			$M.goNextPageAjax("/acnt/acnt0102/account/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						$M.setValue("clickedRowIndex", "");
						if (result.transList.length == 0) {
							AUIGrid.setGridData(auiGridRight, []);
						} else {
							var list = result.transList;
							/* var tot = 0;
							// 잔액계산 = 전월말 + 입금 - 출금
							for (var i = 0; i < list.length; ++i) {
								if (tot == 0) {
									tot = $M.toNum(list[i].balance_amt);
								}
								var ip = $M.toNum(list[i].in_tx_amt);
								var cl = $M.toNum(list[i].out_tx_amt);
								
								tot = tot + ip - cl;
								list[i].balance_amt = tot;
							} */
							AUIGrid.setGridData(auiGridRight, list);
						}
						
						if (result.list.length == 0) {
							// alert("검색된 결과가 없습니다.");
							AUIGrid.setGridData(auiGridLeft, []);	
						} else {
							var list = result.list;
							var tot = 0;
							// 잔액계산 = 전월말 + 입금 - 출금
							for (var i = 0; i < list.length; ++i) {
								if (tot == 0) {
									tot = $M.toNum(list[i].balance);
								}
								var ip = $M.toNum(list[i].deposit);
								var cl = $M.toNum(list[i].withdrawal);
								
								tot = tot + ip - cl;
								list[i].balance = tot;
							}
							AUIGrid.setGridData(auiGridLeft, list);
						}
						
					};
				}
			);
		}

		function goConfirmProcess() {
			var items = AUIGrid.getCheckedRowItemsAll(auiGridLeft);
			if (items.length == 0) {
				alert("체크된 데이터가 없습니다.");
				return false
			}
			var param = {
				s_start_dt : $M.getValue("s_start_dt"),
				s_end_dt : $M.getValue("s_end_dt"),
				datacase_str : $M.getArrStr(items, {key : 'datacase'}),
				inout_doc_no_str : $M.getArrStr(items, {key :'inout_doc_no'})
			};
			var msg = "확정처리하시겠습니까?";
			$M.goNextPageAjaxMsg(msg, "/acnt/acnt0102/account/confirm", $M.toGetParam(param), {method : 'POST'}, 
				function(result) {
					if(result.success) {
						console.log(items);
						for (var i = 0; i < items.length; ++i) {
							var param = {
								imprest_status_cd : "2",
								imprest_status_name : "발송",
								inout_doc_no : items[i].inout_doc_no
							};
							var index = AUIGrid.rowIdToIndex(auiGridLeft, items[i].inout_doc_no);
							console.log(param, index);
							AUIGrid.updateRow(auiGridLeft, param, index);
						}
						AUIGrid.resize(auiGridLeft);
						/* AUIGrid.removeSoftRows(auiGridLeft);
						AUIGrid.resetUpdatedItems(auiGridLeft); */
					};
				}
			);
		}

		// 회계전송
		function goAccTrans() {
			// 회계일자, 계정과목 체크
			var row = "";
			var items = AUIGrid.getCheckedRowItemsAll(auiGridLeft);
			var gridData = AUIGrid.getGridData(auiGridLeft);
			
			console.log(items);
			
			if (items.length == 0) {
				alert("체크된 데이터가 없습니다.");
				return false
			}
			
			for (var i = 0; i < items.length; i++) {
				if(items[i].duzon_trans_yn == "Y") {
					alert("이미 회계처리된 데이터가 있습니다.");
					return false;
				}
// 				if(items[i].account_link_cd == "") {
// 					for(var j = 0; j < gridData.length; j++) {
// 						if(items[i].inout_doc_no == gridData[j].inout_doc_no) {
// 							row = j + 1;
// 						}
// 					}
// 					alert(row + "행의 회계거래처코드가 없습니다.");
// 					return false;
// 				}

				if(items[i].acnt_dt == "") {
					for(var j = 0; j < gridData.length; j++) {
						if(items[i].inout_doc_no == gridData[j].inout_doc_no) {
							row = j + 1;
						}
					}
					alert(row + "행의 회계 일자가 없습니다.");
					return false;
				}

				if(items[i].acnt_code == "") {
					for(var j = 0; j < gridData.length; j++) {
						if(items[i].inout_doc_no == gridData[j].inout_doc_no) {
							row = j + 1;
						}
					}
					alert(row + "행의 계정 과목이 없습니다.");
					return false;
				}
				
				if(items[i].used_mem_no == "" && items[i].datacase == "2") {
					for(var j = 0; j < gridData.length; j++) {
						if(items[i].inout_doc_no == gridData[j].inout_doc_no) {
							row = j + 1;
						}
					}
					alert(row + "행의 사용자가 없습니다.");
					return false;
				}
			}
			
			var param = {
					imprest_doc_no_str : $M.getArrStr(items, {key : 'inout_doc_no'}),
				}
			
			var msg = "회계전송하시겠습니까?";
			$M.goNextPageAjaxMsg(msg, "/acnt/acnt010203/accTrans", $M.toGetParam(param), {method : 'POST'}, 
				function(result) {
					if(result.success) {
						goSearch();
					};
				}
			);
		}
		
		// 회계전송 취소
		function goCancelAccTrans() {
			var row = "";
			var items = AUIGrid.getCheckedRowItemsAll(auiGridLeft);
			
			if (items.length == 0) {
				alert("체크된 데이터가 없습니다.");
				return false
			}
			
			for (var i = 0; i < items.length; i++) {
				if(items[i].duzon_trans_yn == "N") {
					alert("회계처리된 건만 취소가 가능합니다.");
					return false;
				}
			}

			var param = {
					imprest_doc_no_str : $M.getArrStr(items, {key : 'inout_doc_no'}),
			}
			
			var msg = "회계전송을 취소하시겠습니까?";
			$M.goNextPageAjaxMsg(msg, "/acnt/acnt010203/cancelAccTrans", $M.toGetParam(param), {method : 'POST'}, 
				function(result) {
					if(result.success) {
						goSearch();
					};
				}
			);
		}

		function fnDownloadExcel() {
			fnExportExcel(auiGridRight, "전도금통장거래내역", "");
		}

		function fnExcelDownSec() {
			fnExportExcel(auiGridLeft, "금전출납부", "");
		}

		function goAdd() {
			if ($M.getValue("s_org_code") == "") {
				alert("부서를 선택해주세요");
				$("#s_org_code").focus();
				return false;
			}
			/* if (AUIGrid.getCheckedRowItems(auiGridLeft).length > 0) {
				if (confirm("목록을 다시 조회합니다. 계속 진행하시겠습니까?") == false) {
					return false;
				}
			}  */
			var param = {
				"s_org_code" : $M.getValue("s_org_code"),
				"parent_js_name" : "fnSetImprestCheck"
			};
			var poppupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=600, height=600, left=0, top=0";
			$M.goNextPage('/acnt/acnt0102p01', $M.toGetParam(param), {popupStatus : poppupOption});
		}

		function createAUIGridLeft() {
			var gridPros = {
				// 체크박스 출력 여부
				rowIdField : "inout_doc_no",
				showRowCheckColumn : true,
				// 전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
				// Row번호 표시 여부
				showRowNumColum : true,
				editable : true,
				showFooter : true,
				footerPosition : "top",
				rowStyleFunction : function(rowIndex, item) {
					if (item.aui_status_cd !== "") {
						if(item.aui_status_cd == "D") { // 기본
							return "aui-status-default";
						} else if(item.aui_status_cd == "P") { // 진행예정
							return "aui-status-pending";
						} else if(item.aui_status_cd == "G") { // 진행중
							return "aui-status-ongoing";
						} else if(item.aui_status_cd == "R") { // 반려
							return "aui-status-reject-or-urgent";
						} else if(item.aui_status_cd == "C") { // 완료
							return "aui-status-complete";
						}
					}
					if (item.duzon_trans_yn == "N") {
						if (item.acnt_code) {
							if (item.acnt_dt) {
								if (item.datacase != "2") {
									return "aui-status-pending";
								} else {
									if (item.used_mem_no) {
										return "aui-status-pending";
									}
								}
							}
						}
					}
				}
			};

			var columnLayout = [
				{
					dataField : "duzon_trans_yn",
					visible : false
				},
				{
					dataField : "account_link_cd",
					visible : false
				},
				{
					headerText : "전표번호",
					dataField : "inout_doc_no",
					width : "140",
					minWidth : "135",
					editable : false,
					style : "aui-center aui-popup"
				},
				{
					headerText : "등록일",
					dataField : "inout_dt",
					dataType : "date",
					width : "80",
					minWidth : "80",
					dataInputString : "yyyymmdd",
					formatString : "yy-mm-dd",
					editable : false,
					style : "aui-center",
				},
				{
					headerText : "적요",
					editable : false,
					style : "aui-left",
					width : "300",
					minWidth : "150",
					dataField : "remark",
				},
				{
					headerText : "입금",
					dataField : "deposit",
					editable : false,
					dataType : "numeric",
					style : "aui-right",
					formatString : "#,##0",
					width : "80",
					minWidth : "70",
				},
				{
					headerText : "출금",
					dataField : "withdrawal",
					editable : false,
					dataType : "numeric",
					style : "aui-right",
					formatString : "#,##0",
					width : "80",
					minWidth : "70",
				},
				{
					headerText : "잔액",
					dataField : "balance",
					editable : false,
					dataType : "numeric",
					width : "80",
					minWidth : "70",
					style : "aui-right",
					formatString : "#,##0"
				},
				<c:if test="${page.fnc.F00676_001 eq 'Y'}">
				{
					headerText : "회계일자",
					dataField : "acnt_dt",
					editable : true,
					dataType : "date",
					width : "80",
					minWidth : "80",
					style : "aui-center aui-editable",
					dataInputString : "yyyymmdd",
					formatString : "yyyy-mm-dd",
					editRenderer : {
						type : "JQCalendarRenderer", // datepicker 달력 렌더러 사용
						defaultFormat : "yyyymmdd", // 원래 데이터 날짜 포맷과 일치 시키세요. (기본값: "yyyy/mm/dd")
						onlyCalendar : true, // 사용자 입력 불가, 즉 달력으로만 날짜입력 ( 기본값: true )
						maxlength : 8,
						onlyNumeric : true, // 숫자만
						showEditorBtn : false,
						showEditorBtnOver : true
					},
					editable : true
				},
				{
					dataField : "acnt_name",
					headerText : "계정과목",
					width : "100",
					minWidth : "90",
					style : "aui-center aui-editable",
					labelFunction : function (rowIndex, columnIndex, value, headerText, item ) { // HTML 템플릿 작성
						return value != null && value != "" ? value.replace(/\s/g,'') : "";
					},
					editable : false
				},
				{
					dataField : "acnt_code",
					visible : false
				},
				{
					dataField : "used_mem_no",
					visible : false
				},
				</c:if>
				{
					headerText : "상태",
					dataField : "imprest_status_name",
					editable : false, // 그리드의 에디팅 사용 안함( 템플릿에서 만든 Select 로 에디팅 처리 하기 위함 )
					renderer : { // HTML 템플릿 렌더러 사용
						type : "TemplateRenderer"
					}, 
					width : "50",
					minWidth : "50",
					// dataField 로 정의된 필드 값이 HTML 이라면 labelFunction 으로 처리할 필요 없음.
					labelFunction : function (rowIndex, columnIndex, value, headerText, item ) { // HTML 템플릿 작성
						var template = '<div>';
						if (value != "" && value != undefined) {
							template+= "<button class='btn btn-default'>"+value+"</button>";
						}
						template += '</div>';
						return template;
					}
				},
				{
					dataField : "imprest_status_cd",
					visible : false
				},
				{
					dataField : "datacase",
					visible : false
				},
				{
					dataField : "aui_status_cd",
					visible : false
				}
			];
			// 푸터 설정
			var footerLayout = [
				{
					labelText : "합계",
					style : "aui-center",
					positionField : "remark"
				},
				{
					dataField: "deposit",
					positionField: "deposit",
					operation: "SUM",
					formatString : "#,##0",
					style: "aui-right aui-footer"
				},
				{
					dataField: "withdrawal",
					positionField: "withdrawal",
					operation: "SUM",
					formatString : "#,##0",
					style: "aui-right aui-footer"
				},
				{
					dataField: "balance",
					positionField: "balance",
					operation: "SUM",
					formatString : "#,##0",
					style: "aui-right aui-footer"
				}
			];

			// 실제로 #grid_wrap에 그리드 생성
			auiGridLeft = AUIGrid.create("#auiGridLeft", columnLayout, gridPros);
			// 푸터 레이아웃 세팅
			AUIGrid.setFooter(auiGridLeft, footerLayout);
			// AUIGrid.setFixedColumnCount(auiGridLeft, 1);
			// 그리드 갱신
			AUIGrid.setGridData(auiGridLeft, []);
			AUIGrid.bind(auiGridLeft, "cellEditBegin", function(event) {
			   if(event.item.inout_doc_no == "." || event.item.confirm_yn == "Y") return false; // false 반환. 기본 행위인 편집 불가
			   if((event.item.datacase != "2" && event.dataField == "acnt_name") 
				|| event.item.datacase != "2" && event.dataField == "acnt_dt"
				) return false;
			   if (event.dataField == "acnt_dt") {
				   if (event.item.duzon_trans_yn == "Y") {
					   alert("회계전송 취소 후 처리하십시오.");
					   return false;
				   }
			   }
			});
			AUIGrid.bind(auiGridLeft, "cellEditEndBefore", function(event) {
				if(event.dataField == "acnt_dt") {
					/* if (event.value < $M.dateFormat($M.addDates(new Date(), 0), 'yyyyMMdd')) {
						setTimeout(function() {
							   AUIGrid.showToastMessage(auiGridLeft, event.rowIndex, event.columnIndex, "회계일자는 오늘 이전으로 할 수 없습니다.");
						}, 1);
						if (event.oldValue == null) {
							return "";
						} else {
							return event.oldValue;
						}
					} */
				}
			});
			AUIGrid.bind(auiGridLeft, "cellEditEnd", function(event) {
				if(event.dataField == "acnt_dt") {
					if (event.value != "") {
						var param = {
							imprest_doc_no : event.item.inout_doc_no,
							acnt_dt : event.value
						}
						$M.goNextPageAjax('/acnt/acnt0102/acntDt/acnt', $M.toGetParam(param), {method : 'POST', loader : false}, 
							function(result) {
								if(result.success) {
									/* AUIGrid.addCheckedRowsByValue(auiGrid, "inout_doc_no", event.item.inout_doc_no); */
									AUIGrid.updateRow(auiGridLeft, param, event.rowIndex);
								};
							}
						);
					}
				}
				console.log(event);
			});
			AUIGrid.bind(auiGridLeft, "cellClick", function(event) {
				$M.setValue("clickedRowIndex", event.rowIndex);
				if(event.item.inout_doc_no == ".") {
					return false;
				}
				if(event.dataField == "inout_doc_no") {
					if (event.item.datacase == "1") {
						var param = {
							inout_doc_no : event.value,
							parent_js_name : "fnSetImprestCheck"
						}
						var poppupOption = "scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=600, height=600, left=0, top=0";
						$M.goNextPage('/cust/cust0203p01', $M.toGetParam(param), {popupStatus : poppupOption});
					} else {
						var param = {
							imprest_doc_no : event.value,
							parent_js_name : "fnSetImprestCheck"
						}
						var poppupOption = "scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=600, height=600, left=0, top=0";
						$M.goNextPage('/acnt/acnt0102p01', $M.toGetParam(param), {popupStatus : poppupOption});	
					}
				} else if (event.dataField == "imprest_status_name") {
					var nowCd = event.item.imprest_status_cd;
					var param = {
						datacase : event.item.datacase
					};
					if (event.item.datacase == "1") {
						param['inout_doc_no'] = event.item.inout_doc_no;
					} else {
						param['imprest_doc_no'] = event.item.inout_doc_no;
					}
					if ("${page.fnc.F00676_001}" == "Y") {
						if (nowCd == "3") {
							param['imprest_status_cd'] = "2";
							param['imprest_status_name'] = "발송";
						} else {
							param['imprest_status_cd'] = "3";
							param['imprest_status_name'] = "수신";
						}
					} else {
						// 관리부가 아니면 수신과 발송 상태로 되있는건 변경 불가, 오직 확인과 미확인만
						if (nowCd == "1") {
							param['imprest_status_cd'] = "0";
							param['imprest_status_name'] = "미확인";
						} else if (nowCd == "0") {
							param['imprest_status_cd'] = "1";
							param['imprest_status_name'] = "확인";
						} else {
							return false;
						}
					}
					$M.goNextPageAjax("/acnt/acnt0102/account/status", $M.toGetParam(param), {method : 'POST', loader : false}, 
						function(result) {
							if(result.success) {
								/* AUIGrid.addCheckedRowsByValue(auiGrid, "inout_doc_no", event.item.inout_doc_no); */
								AUIGrid.updateRow(auiGridLeft, param, event.rowIndex);
							};
						}
					);
				}
				
				if(event.dataField == "acnt_name" && event.item.datacase == "2") {
					if (event.item.duzon_trans_yn == "Y") {
					   alert("회계전송 취소 후 처리하십시오.");
					   return false;
				    }
					var param = {
						s_search_type : "IMPREST"
					}
					openAccountInfoPanel('fnSetAcntCode', $M.toGetParam(param));
				}
			});
		}
		
		function fnSetAcntCode(row) {
			var rowIndex = $M.getValue("clickedRowIndex");
			var data = AUIGrid.getItemByRowIndex(auiGridLeft, rowIndex);
			var param = {
				imprest_doc_no : AUIGrid.getItemByRowIndex(auiGridLeft, rowIndex).inout_doc_no,
				acnt_code : row.acnt_code
			}
			$M.goNextPageAjax('/acnt/acnt0102/acntCode/acnt', $M.toGetParam(param), {method : 'POST', loader : false}, 
				function(result) {
					if(result.success) {
						AUIGrid.setCellValue(auiGridLeft, rowIndex, "acnt_code", row.acnt_code);
						AUIGrid.setCellValue(auiGridLeft, rowIndex, "acnt_name", row.acnt_name_print);
					};
				}
			);
			
		}
		
		function createAUIGridRight() {
			var gridPros = {
				// Row번호 표시 여부
				showRowNumColum : true,
				showFooter : true,
				footerPosition : "top",
			};

			var columnLayout = [
				{
					headerText : "거래일자",
					dataField : "deal_dt",
					dataInputString : "yyyymmdd",
					formatString : "yyyy-mm-dd",
					dataType : "date",
					width : "80",
					minWidth : "80",
					style : "aui-center aui-popup"
				},
				{
					headerText : "적요",
					style : "aui-left",
					width : "200",
					minWidth : "200",
					dataField : "remark" // asis에서 erp_remark인데, tobe view erp_remark에 안나오고, remark에 나와서 수정
				},
				{
					headerText : "입금",
					dataField : "in_tx_amt",
					dataType : "numeric",
					style : "aui-right",
					width : "150",
					minWidth : "150",
					formatString : "#,##0"
				},
				{
					headerText : "출금",
					dataField : "out_tx_amt",
					dataType : "numeric",
					style : "aui-right",
					width : "150",
					minWidth : "150",
					formatString : "#,##0"
				},
				{
					headerText : "잔액",
					dataField : "balance_amt",
					dataType : "numeric",
					style : "aui-right",
					width : "150",
					minWidth : "150",
					formatString : "#,##0"
				},
				{
					dataField : "ibk_iss_acct_his_seq",
					visible : false
				},
				{
					dataField : "deal_type_rv",
					visible : false
				},
				{
					dataField : "account_no",
					visible: false
				}
			];

			// 푸터 설정
			var footerLayout = [
				{
					labelText : "합계",
					positionField : "remark",
					style : "aui-right"
				},
				{
					dataField: "in_tx_amt",
					positionField: "in_tx_amt",
					operation: "SUM",
					formatString : "#,##0",
					style: "aui-right aui-footer"
				},
				{
					dataField: "out_tx_amt",
					positionField: "out_tx_amt",
					operation: "SUM",
					formatString : "#,##0",
					style: "aui-right aui-footer"
				},
				{
					dataField: "balance_amt",
					positionField: "balance_amt",
					operation: "SUM",
					formatString : "#,##0",
					style: "aui-right aui-footer"
				}
			];

			// 실제로 #grid_wrap에 그리드 생성
			auiGridRight = AUIGrid.create("#auiGridRight", columnLayout, gridPros);
			// 푸터 레이아웃 세팅
			AUIGrid.setFooter(auiGridRight, footerLayout);
			// 그리드 갱신
			AUIGrid.setGridData(auiGridRight, []);
			AUIGrid.bind(auiGridRight, "cellClick", function(event) {
				if(event.dataField == "deal_dt") {
					var params = {
							"ibk_iss_acct_his_seq" : event.item["ibk_iss_acct_his_seq"],
							"deal_type_rv" : event.item["deal_type_rv"],
							"account_no" : event.item["account_no"],
							"imprest_yn" : "Y"
					};
					var popupOption = "";
					$M.goNextPage('/cust/cust0303p01', $M.toGetParam(params), {popupStatus : popupOption});
				}
			});
		}
	</script>
</head>
<body style="background : #fff">
<input type="hidden" id="clickedRowIndex" name="clickedRowIndex">
<form id="main_form" name="main_form">
	<div class="">
		<!-- contents 전체 영역 -->
		<div class="" style="padding: 0">
			<div class="">
				<!-- 메인 타이틀 -->
				<!-- /메인 타이틀 -->
				<div class="content-wrap" style="margin-top: 5px; padding: 0">
					<!-- 기본 -->
					<div class="search-wrap">
						<table class="table">
							<colgroup>
								<col width="60px">
								<col width="260px">
								<col width="50px">
								<col width="100px">
								<col width="50px">
								<col width="100px">
								<col width="110px">
								<col width="">
							</colgroup>
							<tbody>
							<tr>
								<th class="rs">처리일자</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width110px">
											<div class="input-group">
												<input type="text" class="form-control rb border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateFormat="yyyy-MM-dd" value="" alt="조회 시작일" onchange="fnUpdateParentStartDt()">
											</div>
										</div>
										<div class="col-auto text-center">~</div>
										<div class="col width120px">
											<div class="input-group">
												<input type="text" class="form-control rb border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateFormat="yyyy-MM-dd"  value="${inputParam.s_end_dt}" alt="조회 완료일" onchange="fnUpdateParentEndDt()">
											</div>
										</div>
										<jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp">
				                     		<jsp:param name="st_field_name" value="s_start_dt"/>
				                     		<jsp:param name="ed_field_name" value="s_end_dt"/>
				                     		<jsp:param name="click_exec_yn" value="Y"/>
				                     		<jsp:param name="exec_func_name" value="fnUpdateParentDtAnGoSearch();"/>
				                     	</jsp:include>
									</div>
								</td>
								<th class="rs">부서</th>
								<td>
									<select class="form-control rb" id="s_org_code" name="s_org_code" required="required" alt="부서" onchange="fnUpdateParentOrgCode()">
										<c:choose>
											<c:when test="${deptList.size() > 1 }">
												<option value="">- 선택 -</option>
											</c:when>
											<c:otherwise></c:otherwise>
										</c:choose>
										<c:forEach var="item" items="${deptList}">
											<option value="${item.org_code }">${item.org_name }</option>
										</c:forEach>
									</select>
								</td>
								<th>상태</th>
								<td>
									<select class="form-control" id="s_imprest_status_cd" name="s_imprest_status_cd" onchange="fnUpdateParentImprestCd()">
										<option value="">- 전체 -</option>
										<c:forEach var="item" items="${codeMap['IMPREST_STATUS']}">
											<option value="${item.code_value }">${item.code_name }</option>
										</c:forEach>
										
										<!-- ASIS.. 확인은 미확인, 발송은 확인.. 등 한단계씩 밀림 -->
										<!-- <option value="0">확인(√)</option>
										<option value="1">발송(△)</option>
										<option value="2">수신(○)</option>
										<option value="3">완결</option>
										<option value="4">전체</option> -->
									</select>
								</td>
								<td class="pl10">
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="checkbox" id="s_except_acnt_confirm" name="s_except_acnt_confirm" value="Y" onchange="fnUpdateParentExcept()">
										<label class="form-check-label" for="s_except_acnt_confirm">완결건 제외</label>
									</div>
								</td>
								<td>
									<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
								</td>
							</tr>
							</tbody>
						</table>
					</div>
					<!-- /기본 -->
					<!-- 그리드 타이틀, 컨트롤 영역 -->
						<div class="col-12" style="padding: 0">
							<!-- 금전출납부 -->
							<div class="title-wrap mt10">
								<h4>금전출납부</h4>
								<div class="btn-group">
									<div class="right">
										<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
										<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_M"/></jsp:include>
									</div>
								</div>
							</div>
							<div id="auiGridLeft" style="margin-top: 5px; height: 405px;"></div>
							<!-- /금전출납부 -->
						</div>
						<div class="col-12 mt5" style="padding: 0">
							<!-- 전도금통장거래내역 -->
							<div class="left">
								총 <strong class="text-primary" id="total_cnt">0</strong>건
							</div>
							<div class="title-wrap mt10">
								<h4>전도금통장거래내역</h4>
								<div class="btn-group">
									<div class="right">
										<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
									</div>
								</div>
							</div>
							<div id="auiGridRight" style="margin-top: 5px; height: 140px;  width: 100%"></div>
							<!-- /전도금통장거래내역 -->
						</div>
						<div class="btn-group mt5">
							<div class="right">
								<%-- <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include> --%>
							</div>
						</div>
					<!-- /그리드 서머리, 컨트롤 영역 -->
				</div>
			</div>
		</div>
		<!-- /contents 전체 영역 -->
	</div>
</form>
</body>
</html>