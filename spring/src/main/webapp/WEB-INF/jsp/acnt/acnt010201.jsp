<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 비용관리 > 전도금정산서 > null > null
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-04-08 17:55:01
-- 카드사용내역

-- 21.4.6 관리부는 카드사용내역화면 보여달라고 해서 acnt0101소스 가져옴
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	
		<style type="text/css">
	
		/* 커스텀 행 스타일 ( 회계확인 ) */
		.my-row-style1 {
			color:#bbbbbb;
		}
	
		/* 커스텀 행 스타일 (승인취소) */
		.my-row-style2 {
			color:red;
		}
	
		/* 커스텀 행 스타일 법인카드(정상매출) */
		.my-row-style3 {
			color:#31933d;
		}
		
		/* 커스텀 행 스타일 하이패스(정상매출) */
		.my-row-style4 {
			color:black;
		}
			
		/* rownum 칼럼 색상 고정하는 경우 */
		.aui-grid-row-num-column {
		    color: #000000;
		}	
					
	</style>
	
	
	<script type="text/javascript">
	
		var auiGrid;
		
		//세액공제여부
		var taxDudectYnList = [ { "code_name" : "-선택 -","code_value":"" },{"code_value":"Y", "code_name" : "처리"}, {"code_value" :"N", "code_name" :"미처리"}];	
		var gridRowIndex;
		
		$(document).ready(function() {
			<c:if test="${page.fnc.F00672_001 eq 'Y'}">
				createAUIGridFor2000();
			</c:if>
			<c:if test="${page.fnc.F00672_001 ne 'Y'}">
				createAUIGridFor5000();
			</c:if>
			fnInit();
		});
		
		//그리드 스타일을 동적으로 바꾸기
	 	function myCellStyleFunction(rowIndex, columnIndex, value, headerText, item, dataField) {
			
  	        
           	if (item.acnt_confirm_yn == "Y") {
             	return "aui-center";
            } else {
             	return "aui-editable";
            }
        };
        
        //미확인금액 가져오기
		function fnGetUnconfirmAmt(result) {

			var unConfirm = 0;
			var unConfirmCount = 0;
			for(i=0 ; i < result.list.length ; i++){
				unConfirm = unConfirm + result.list[i].unconfirm_amt;
				// 미확인 갯수 추가 (0원이 아닐 경우만)
				if(result.list[i].unconfirm_amt !== 0) {
					unConfirmCount++;
				}
			}

			unConfirm = Math.floor(unConfirm);

			$('#unConfirmAmt').html( $M.setComma(unConfirm) + '원');
			$('#unConfirmCount').html( $M.setComma(unConfirmCount) + '건');

		}

		// 계정관리 목록 팝업호출
		function goAccountListPopup(rowIdx) {
			
			gridRowIndex = rowIdx;
			var param = {};
			param.parent_js_name = "fnSetAccountInfo";
			var poppupOption = "";
			$M.goNextPage("/comp/comp0901", $M.toGetParam(param), {popupStatus : poppupOption});
		}
		
		// 계정과목 결과
		function fnSetAccountInfo(data) {
			console.log(data.acnt_code);
			if($M.nvl(data.acnt_code, "") == "") {
				return;
			}			
		    AUIGrid.updateRow(auiGrid, { "acnt_code" : data.acnt_code }, gridRowIndex);
		    AUIGrid.updateRow(auiGrid, { "acnt_name" : data.acnt_name }, gridRowIndex);
		}
		
		function fnSetImprestCheck(data) {
			var rowIndex = $M.getValue("clickedRowIndex");
			if (data.type == "M") {
				if (data.acnt_dt) {
					AUIGrid.setCellValue(auiGrid, rowIndex, "acnt_dt", data.acnt_dt);	
				}
				if (data.acnt_code) {
					AUIGrid.setCellValue(auiGrid, rowIndex, "acnt_code", data.acnt_code);
					AUIGrid.setCellValue(auiGrid, rowIndex, "acnt_name", data.acnt_name);
				}
				if (data.tax_dudect_yn) {
					AUIGrid.setCellValue(auiGrid, rowIndex, "tax_dudect_yn", data.tax_dudect_yn);
				}
				if (data.remark) {
					AUIGrid.setCellValue(auiGrid, rowIndex, "remark", data.remark);
				}
				if (data.mem_no) {
					AUIGrid.setCellValue(auiGrid, rowIndex, "mem_no", data.mem_no);
					AUIGrid.setCellValue(auiGrid, rowIndex, "mem_name", data.mem_name);
				}
				var rowId = AUIGrid.indexToRowId(auiGrid, rowIndex);
				AUIGrid.addCheckedRowsByIds(auiGrid, rowId);
			} 
		}
		
		function fnInit() {
			if ("${page.fnc.F00672_001}"=="Y") {
				$("#_goConfirmProcess").css("display", "none");
			} else {
				$("#_goAccTrans").css("display", "none");
				$("#_goCancelAccTrans").css("display", "none");
			}
			fnUpdateParentStartDt();
			fnUpdateParentEndDt();
			fnUpdateParentOrgCode();
			fnUpdateParentImprestCd();
			fnUpdateParentExcept();
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
				s_imprest_status_cd : $M.getValue("s_imprest_status_cd"),
				s_except_acnt_confirm : $M.getValue("s_except_acnt_confirm"),
				s_sort_key : "a.card_no, a.approval_date, a.approval_no, a.cancel_yn",
				s_sort_method : "asc"
			};
			_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
			$M.goNextPageAjax("/acnt/acnt0102/cardUse/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$M.setValue("clickedRowIndex", "");
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
						
						fnGetUnconfirmAmt(result);
					};
				}
			);
		}

		function goConfirmProcess() {
			var items = AUIGrid.getCheckedRowItemsAll(auiGrid);
			if (items.length == 0) {
				alert("체크된 데이터가 없습니다.");
				return false
			}
			var param = {
				card_code_str : $M.getArrStr(items, {key : 'card_code'}),
				ibk_ccm_appr_seq_str : $M.getArrStr(items, {key : 'ibk_ccm_appr_seq'})
			}
			var msg = "확정처리하시겠습니까?";
			$M.goNextPageAjaxMsg(msg, "/acnt/acnt0102/cardUse/confirm", $M.toGetParam(param), {method : 'POST'}, 
				function(result) {
					if(result.success) {
						for (var i = 0; i < items.length; ++i) {
							var param = {
								imprest_status_cd : "2",
								imprest_status_name : "발송",
								ibk_ccm_appr_seq : items[i].ibk_ccm_appr_seq,
								card_code : items[i].card_code
							};
							var index = AUIGrid.rowIdToIndex(auiGrid, items[i].ibk_ccm_appr_seq);
							AUIGrid.updateRow(auiGrid, param, index);
						}
						AUIGrid.removeSoftRows(auiGrid);
						AUIGrid.resetUpdatedItems(auiGrid);
					};
				}
			);
		}
		
		//회계전송
		function goAccTrans() {
			var cardCodeArr = [];
			var useMemNoArr = [];
			var acntDtArr = [];
			var acntCodeArr = [];
			var taxDudectYnArr = [];
			var remarkArr = [];
			var ibkCcmApprSeqArr = [];
			
			//회계전송전 선택된 로우가 있는지 확인
			var checkedItems = AUIGrid.getCheckedRowItems(auiGrid);
			var items = AUIGrid.getCheckedRowItemsAll(auiGrid);
			console.log(checkedItems);
			console.log("items : ", items);
			if(checkedItems.length <= 0) {
				alert("선택된 데이터가 없습니다.");
				return;
			} else {
				
				var str = "";
				var rowItem;
				for(var i=0, len = checkedItems.length; i<len; i++) {
					rowItem = checkedItems[i];
					str += "row : " + rowItem.rowIndex + ", id :" + rowItem.item.id + ", name : " + rowItem.item.name  + "\n";
					
					if (rowItem.item.duzon_trans_yn == "Y") {
						alert("이미 회계처리된 데이터가 있습니다.");
						return;
					}
					
					if (rowItem.item.tax_dudect_yn == "Y" && rowItem.item.chain_id == "") {
						alert("사업자번호가 없습니다.");
						return;
					}
					
					// 사용자
					if( rowItem.item.mem_no == "") {
						alert("사용자를 등록해주세요.");		
						AUIGrid.showToastMessage(auiGrid, rowItem.rowIndex, 13, "사용자를 등록해주세요.");
						return;
					}

// 					회계일자
					if( rowItem.item.acnt_dt == "") {
						alert("회계일자를 선택해주세요.");		
						AUIGrid.showToastMessage(auiGrid, rowItem.rowIndex, 15, "회계일자를 선택해주세요.");
						return;
					}
					
// 					계정과목
					if( rowItem.item.acnt_code == "") {
						alert("계정과목을 선택해주세요.");		
						AUIGrid.showToastMessage(auiGrid, rowItem.rowIndex, 17, "계정과목을 선택해주세요.");
						return;
					}
					
// 					세액공제여부
					if( rowItem.item.tax_dudect_yn == "") {
						alert("세액공제여부를 선택해주세요.");		
						AUIGrid.showToastMessage(auiGrid, rowItem.rowIndex, 18, "세액공제여부를 선택해주세요.");
						return;
					}
				}
				var frm = fnCheckedGridDataToForm(auiGrid);
			}
			
			console.log("frm : ", frm);
			
			var msg = "회계전송하시겠습니까?";
			$M.goNextPageAjaxMsg(msg, "/acnt/acnt0101/saveAcntTrans", frm, {method : 'POST'},
				function(result) {
					if(result.success) {
						AUIGrid.resetUpdatedItems(auiGrid);		
						goSearch();
					};
				}
			);				
		}

		// 회계전송
		/* function goAccTrans() {
			// 회계 일자, 계정과목, 전송여부, 거래처 코드 검사 
			var row = "";
			var items = AUIGrid.getCheckedRowItemsAll(auiGrid);
			var gridData = AUIGrid.getGridData(auiGrid);
			
			console.log(items);
			console.log(gridData);
			
			if (items.length == 0) {
				alert("체크된 데이터가 없습니다.");
				return false
			}
			
			for (var i = 0; i < items.length; i++) {
				if(items[i].duzon_trans_yn == "Y") {
					alert("이미 회계처리된 데이터가 있습니다.");
					return false;
				}
				
				if(items[i].acnt_dt == "") {
					for(var j = 0; j < gridData.length; j++) {
						if(items[i].ibk_ccm_appr_seq == gridData[j].ibk_ccm_appr_seq) {
							row = j + 1;
						}
					}
					alert(row + "행의 회계 일자가 없습니다.");
					return false;
				}

				if(items[i].acnt_code == "") {
					for(var j = 0; j < gridData.length; j++) {
						if(items[i].ibk_ccm_appr_seq == gridData[j].ibk_ccm_appr_seq) {
							row = j + 1;
						}
					}
					alert(row + "행의 계정 과목이 없습니다.");
					return false;
				}

				if(items[i].chain_no == "") {
					for(var j = 0; j < gridData.length; j++) {
						if(items[i].ibk_ccm_appr_seq == gridData[j].ibk_ccm_appr_seq) {
							row = j + 1;
						}
					}
					alert(row + "행의 거래처 코드가 없습니다.");
					return false;
				}
			}
			
			var param = {
					ibk_ccm_appr_seq_str : $M.getArrStr(items, {key : 'ibk_ccm_appr_seq'}),
				}
			
			var msg = "회계전송하시겠습니까?";
			$M.goNextPageAjaxMsg(msg, "/acnt/acnt010201/accTrans", $M.toGetParam(param), {method : 'POST'}, 
				function(result) {
					if(result.success) {
						goSearch();
					};
				}
			);
		} */
		
		// 회계전송 취소
		function goCancelAccTrans() {
			var row = "";
			var items = AUIGrid.getCheckedRowItemsAll(auiGrid);
			
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
					ibk_ccm_appr_seq_str : $M.getArrStr(items, {key : 'ibk_ccm_appr_seq'}),
			}
			
			var msg = "회계전송을 취소하시겠습니까?";
			$M.goNextPageAjaxMsg(msg, "/acnt/acnt010201/cancelAccTrans", $M.toGetParam(param), {method : 'POST'}, 
				function(result) {
					if(result.success) {
						goSearch();
					};
				}
			);
		}

		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "카드사용내역", "");
		}
		
		// 관리부용 그리드
		function createAUIGridFor2000() {
			var gridPros = {							
				// 체크박스 표시 설정
				showRowCheckColumn : true,			
				// 전체 체크박스 표시 설정
				showRowAllCheckBox : true,

				// 전체 선택 체크박스가 독립적인 역할을 할지 여부
				independentAllCheckBox : true,
				
				editable : true,
				headerHeight : 40,
				// Row번호 표시 여부
				showRowNumColum : true,
				showFooter : true,
				footerPosition : "top",
				
				// row Styling 함수
				rowStyleFunction : function(rowIndex, item) {
					
					if(item.acnt_confirm_yn == "Y") {
						return "my-row-style1";
					}
					
					if(item.cancel_yn == "Y") {
						return "my-row-style2";
					}						
					else {
						if(item.hipass_yn == "N") {
							return "my-row-style3";
						}
						else {
							return "my-row-style4";
						}
					}
				},

				// 2020-10-19 회계전송 취소기능으로 인하여 주석처리
				// 엑스트라 체크박스 disabled 함수
				// 이 함수는 렌더링 시 빈번히 호출됩니다. 무리한 DOM 작업 하지 마십시오. (성능에 영향을 미침)
				// rowCheckDisabledFunction 이 아래와 같이 간단한 로직이라면, 실제로 rowCheckableFunction 정의가 필요 없습니다.
				// rowCheckDisabledFunction 으로 비활성화된 체크박스는 체크 반응이 일어나지 않습니다.(rowCheckableFunction 불필요)
// 				rowCheckDisabledFunction : function(rowIndex, isChecked, item) {
// 					if(item.acnt_confirm_yn == "Y") {
// 						return false;
// 					}
// 					else {
// 						return true;
// 					}
				
// 				}
				
			};

			var columnLayout = [
				{
					dataField : "duzon_trans_yn",
					visible : false
				},
				{
					dataField : "chain_id",
					visible : false
				},
				{
					headerText : "카드번호",
					dataField : "card_no",
					width : "150",
					minWidth : "30",
					style : "aui-center aui-popup",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
					     return $M.creditCardFormat(value); 
					},
					editable : false
				},
				{
					headerText : "카드코드",
					dataField : "card_code",
					visible : false
				},
				{
					headerText : "하이패스여부",
					dataField : "hipass_yn",
					visible : false,
					editable : false
				},	
				{
					headerText : "ibk카드승인순번",
					dataField : "ibk_ccm_appr_seq",
					visible : false,
					editable : false
				},
				
				{
					headerText : "승인일시",
					dataField : "approval_date",
					width : "130",
					minWidth : "30",
					dataType : "date",
					formatString : "yy-mm-dd HH:MM:ss",
					editable : false
				},
				{
					headerText : "승인번호",
					dataField : "approval_no",
					visible :false,
					editable : false
				},
				{
					headerText : "구분",
					dataField : "card_use_name",
					editable : false,
					visible : false
				},
				{
					headerText : "가맹점명",
					dataField : "chain_nm",
					width : "130",
					minWidth : "30",
					style : "aui-left",
					editable : false
				},				
				{
					headerText : "승인금액",
					dataField : "approval_amt",
					dataType : "numeric",
					width : "80",
					minWidth : "70",
					formatString : "#,##0",
					style : "aui-right",
					editable : false
				},
				{
					headerText : "공급가",
					dataField : "supply_amt",
					dataType : "numeric",
					width : "80",
					minWidth : "70",
					formatString : "#,##0",
					style : "aui-right",
					editable : false
				},
				{
					headerText : "부가세",
					dataField : "vat_amt",
					dataType : "numeric",
					width : "75",
					minWidth : "55",
					formatString : "#,##0",
					style : "aui-right",
					editable : false
				},
				{
					headerText : "회계확인여부",
					dataField : "acnt_confirm_yn",
					visible : false,
					editable : false
				},				
				{
					headerText : "사용자",
					dataField : "mem_name",
					width : "60",
					minWidth : "60",
					style : "aui-center",
					editable : false
				},
				{
					dataField : "mem_no",
					visible : false
				},
				{
					headerText : "회계일자", 
					dataField : "acnt_dt", 
					dataType : "date",   
					width : "65",
					minWidth : "65",
					style : "aui-center",					
					dataInputString : "yyyymmdd",
					formatString : "yy-mm-dd",
					editable : true,
					editRenderer : {
						type : "JQCalendarRenderer", // datepicker 달력 렌더러 사용
						defaultFormat : "yyyymmdd", // 원래 데이터 날짜 포맷과 일치 시키세요. (기본값: "yyyy/mm/dd")
						onlyCalendar : false, // 사용자 입력 불가, 즉 달력으로만 날짜입력 ( 기본값: true )
						maxlength : 8,
						onlyNumeric : true, // 숫자만
						validator : function(oldValue, newValue, rowItem) { // 에디팅 유효성 검사
							return fnCheckDate(oldValue, newValue, rowItem);
						},
						showEditorBtnOver : true
					}
				},
				{
					headerText : "계정과목코드",
					dataField : "acnt_code",
					visible : false
				},
				{
					headerText : "계정과목",
					dataField : "acnt_name",
					width : "150",
					minWidth : "120",
					style : "aui-center",	
					editable : false,
					renderer : {
						type : "TemplateRenderer"
					},
					labelFunction : function (rowIndex, columnIndex, value, headerText, item) {
						var template = "";
						if($M.nvl(item.acnt_confirm_yn, "") == "N"){
							template = '<div>' + value +'<button type="button" class="icon-btn-search" onclick="javascript:goAccountListPopup(' + rowIndex + ');" style="float: right;"> <i class="material-iconssearch"> </i></button></div>';
						} else {
							template = value;
						}
						
						return template;
					}					
				},				
				{
					
					headerText : "세액공제",
					dataField : "tax_dudect_yn",
					width : "60",
					minWidth : "60",
					styleFunction: myCellStyleFunction,
					editRenderer : {
						type : "DropDownListRenderer",
						showEditorBtn : false,
						showEditorBtnOver : false,
						list : taxDudectYnList,
						keyField : "code_value", 
						valueField : "code_name" 				
					},
					labelFunction : function(rowIndex, columnIndex, value){
						for(var i=0; i<taxDudectYnList.length; i++){
							if(value == taxDudectYnList[i].code_value){
								return taxDudectYnList[i].code_name;
							}
						}
						return value;
					}
				},										
				{
					headerText : "취소<br>여부",
					dataField : "cancel_yn",
					width : "45",
					minWidth : "50",
					style : "aui-center",
					editable : false
				},
							
				{
					headerText : "비고",
					dataField : "remark",
					width : "225",
					minWidth : "10",
					style : "aui-left"
				},
				{
					headerText : "상태",
					width : "55",
					minWidth : "30",
					dataField : "imprest_status_name",
					editable : false, // 그리드의 에디팅 사용 안함( 템플릿에서 만든 Select 로 에디팅 처리 하기 위함 )
					renderer : { // HTML 템플릿 렌더러 사용
						type : "TemplateRenderer"
					}, 
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
			];


			// 푸터 설정
			var footerLayout = [
				{
					labelText : "합계",
					positionField : "chain_nm"
				},
				{
					dataField : "approval_calc_amt",
					positionField : "approval_amt",
// 					operation : "SUM",
					formatString : "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGrid);
						var sum = 0;
						
						for (var i = 0; i < gridData.length; i++) {
							sum += gridData[i].approval_amt;
						}
						
						return sum;
					}
				},
				{
					dataField : "supply_calc_amt",
					positionField : "supply_amt",
// 					operation : "SUM",
					formatString : "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGrid);
						var sum = 0;
						
						for (var i = 0; i < gridData.length; i++) {
							sum += gridData[i].supply_amt;
						}
						
						return sum;
					}
				},
				{
					dataField : "vat_calc_amt",
					positionField : "vat_amt",
// 					operation : "SUM",
					formatString : "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGrid);
						var sum = 0;
						
						for (var i = 0; i < gridData.length; i++) {
							sum += gridData[i].vat_amt;
						}
						
						return sum;
					}
				},
			];

			// 실제로 #grid_wrap에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 푸터 레이아웃 세팅
			AUIGrid.setFooter(auiGrid, footerLayout);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, []);
			// AUIGrid.setFixedColumnCount(auiGrid, 11);
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == "card_no") {
					$M.setValue("clickedRowIndex", event.rowIndex);
					param = {						
						"ibk_ccm_appr_seq" : event.item.ibk_ccm_appr_seq,
						"parent_js_name" : "fnSetImprestCheck"
					};	
				
					var poppupOption = "";
					$M.goNextPage('/acnt/acnt0101p01', $M.toGetParam(param), {popupStatus : poppupOption});
				} else if (event.dataField == "imprest_status_name") {
					var nowCd = event.item.imprest_status_cd;
					var param = {
						ibk_ccm_appr_seq : event.item.ibk_ccm_appr_seq,
						card_code : event.item.card_code
					};
					if ("${page.fnc.F00672_001}" == "Y") {
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
					$M.goNextPageAjax("/acnt/acnt0102/cardUse/status", $M.toGetParam(param), {method : 'POST', loader : false}, 
						function(result) {
							if(result.success) {
								/* AUIGrid.addCheckedRowsByValue(auiGrid, "ibk_ccm_appr_seq", event.item.ibk_ccm_appr_seq); */
								AUIGrid.updateRow(auiGrid, param, event.rowIndex);
							};
						}
					);
				}
			});
			
			//회계전송된 건인 경우 에디팅 진입 불가 ( 회계일자 , 계정과목 , 세액공제)
			AUIGrid.bind(auiGrid, "cellEditBegin", function( event ) {			
				
				if(event.item.acnt_confirm_yn == 'Y' ) {
					if(event.dataField == "acnt_dt" || event.dataField == "acnt_name" || event.dataField == "tax_dudect_yn" ) {
						return false; 
					}	
				}
			});
						
			// 전체 체크박스 클릭 이벤트 바인딩
			AUIGrid.bind(auiGrid, "rowAllChkClick", function( event ) {
				
				if(event.checked) {
					// acnt_confirm_yn 의 값들 얻기
					var uniqueValues = AUIGrid.getColumnDistinctValues(event.pid, "acnt_confirm_yn");
					
					//회계전송된 건의 경우 체크하지 않음
					for (var i = 0; i < uniqueValues.length; ++i) {
						if (uniqueValues[i] == "Y") {
							uniqueValues.splice(i,1);
						}
					}
					
					AUIGrid.setCheckedRowsByValue(event.pid, "acnt_confirm_yn", uniqueValues);
				} else {
					AUIGrid.setCheckedRowsByValue(event.pid, "acnt_confirm_yn", []);
				}
			});
		
		}

		// 센터용 그리드
		function createAUIGridFor5000() {
			var gridPros = {
				rowIdField : "ibk_ccm_appr_seq",
				// 체크박스 출력 여부
				showRowCheckColumn : true,
				// 전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
				// Row번호 표시 여부
				showRowNumColum : true,
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
								if (item.mem_name) {
									return "aui-status-pending";
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
					dataField : "chain_no",
					visible : false
				},
				{
					dataField : "acnt_code",
					visible : false
				},
				{
					dataField : "acnt_dt",
					visible : false
				},
				{
					dataField : "tax_dudect_yn",
					visible : false
				},
				{
					headerText : "카드번호",
					dataField : "card_no",
					width : "160",
					minWidth : "30",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
					     return $M.creditCardFormat(value); 
					},
					style : "aui-center aui-popup"
				},
				{
					headerText : "승인일시",
					dataField : "approval_date",
					width : "140",
					minWidth : "30",
					dataType : "date",
					formatString : "yy-mm-dd HH:MM:ss",
				},
				{
					headerText : "구분",
					dataField : "card_use_name",
					width : "4%",
					visible : false
				},
				{
					headerText : "가맹점명",
					dataField : "chain_nm",
					style : "aui-left",
					width : "180",
					minWidth : "30",
				},
				{
					headerText : "승인금액",
					dataField : "approval_amt",
					style : "aui-right",
					width : "80",
					minWidth : "80",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{
					headerText : "공급가",
					dataField : "supply_amt",
					style : "aui-right",
					width : "80",
					minWidth : "80",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{
					headerText : "부가세",
					dataField : "vat_amt",
					style : "aui-right",
					width : "80",
					minWidth : "80",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{
					headerText : "사업자번호",
					dataField : "chain_id",
					width : "100",
					minWidth : "30",
					labelFunction : function(rowIndex, columnIndex, value) {
						return fnGetBregNo(value);
					}
				},
				{
					headerText : "사용자",
					dataField : "mem_name",
					width : "50",
					minWidth : "30",
				},
// 				{
// 					headerText : "사용자",
// 					dataField : "use_mem_name",
// 					width : "5%"
// 				},
				{
					headerText : "비고",
					style : "aui-left",
					dataField : "remark",
					width : "300",
					minWidth : "30",
				},
				{
					headerText : "상태",
					width : "55",
					minWidth : "30",
					dataField : "imprest_status_name",
					editable : false, // 그리드의 에디팅 사용 안함( 템플릿에서 만든 Select 로 에디팅 처리 하기 위함 )
					renderer : { // HTML 템플릿 렌더러 사용
						type : "TemplateRenderer"
					}, 
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
					dataField : "aui_status_cd",
					visible: false
				},
				{
					dataField : "ibk_ccm_appr_seq",
					visible : false
				},
				{
					dataField : "card_code",
					visible: false
				}
			];
			
			// 푸터 설정
			var footerLayout = [
				{
					labelText : "합계",
					positionField : "chain_nm"
				},
				{
					dataField : "approval_calc_amt",
					positionField : "approval_amt",
// 					operation : "SUM",
					formatString : "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGrid);
						var sum = 0;
						
						for (var i = 0; i < gridData.length; i++) {
							sum += gridData[i].approval_amt;
						}
						
						return sum;
					}
				},
				{
					dataField : "supply_calc_amt",
					positionField : "supply_amt",
// 					operation : "SUM",
					formatString : "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGrid);
						var sum = 0;
						
						for (var i = 0; i < gridData.length; i++) {
							sum += gridData[i].supply_amt;
						}
						
						return sum;
					}
				},
				{
					dataField : "vat_calc_amt",
					positionField : "vat_amt",
// 					operation : "SUM",
					formatString : "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGrid);
						var sum = 0;
						
						for (var i = 0; i < gridData.length; i++) {
							sum += gridData[i].vat_amt;
						}
						
						return sum;
					}
				},
			];

			// 실제로 #grid_wrap에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 푸터 레이아웃 세팅
			AUIGrid.setFooter(auiGrid, footerLayout);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == "card_no") {
					$M.setValue("clickedRowIndex", event.rowIndex);
					var param = {
						"ibk_ccm_appr_seq" : event.item.ibk_ccm_appr_seq,
						"parent_js_name" : "fnSetImprestCheck"
					};	
					var poppupOption = "";
					$M.goNextPage('/acnt/acnt0101p01', $M.toGetParam(param), {popupStatus : poppupOption});
				} else if (event.dataField == "imprest_status_name") {
					var nowCd = event.item.imprest_status_cd;
					var param = {
						ibk_ccm_appr_seq : event.item.ibk_ccm_appr_seq,
						card_code : event.item.card_code
					};
					if ("${page.fnc.F00672_001}" == "Y") {
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
					$M.goNextPageAjax("/acnt/acnt0102/cardUse/status", $M.toGetParam(param), {method : 'POST', loader : false}, 
						function(result) {
							if(result.success) {
								/* AUIGrid.addCheckedRowsByValue(auiGrid, "ibk_ccm_appr_seq", event.item.ibk_ccm_appr_seq); */
								AUIGrid.updateRow(auiGrid, param, event.rowIndex);
							};
						}
					);
				}
			});
		}
	</script>
</head>
<body style="background : #fff">
<form id="main_form" name="main_form">
<input type="hidden" name="clickedRowIndex">
	<div class="">
		<!-- contents 전체 영역 -->
		<div class="" style="padding: 0">
			<div class="">
				<!-- 메인 타이틀 -->
				<!-- /메인 타이틀 -->
				<div class="content-wrap" style="margin-top: 5px; padding: 0;">
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
												<input type="text" class="form-control rb border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateFormat="yyyy-MM-dd" value="${searchDtMap.s_start_dt }" alt="조회 시작일" onchange="fnUpdateParentStartDt()">
											</div>
										</div>
										<div class="col-auto text-center">~</div>
										<div class="col width120px">
											<div class="input-group">
												<input type="text" class="form-control rb border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateFormat="yyyy-MM-dd"  value="${searchDtMap.s_end_dt }" alt="조회 종료일" onchange="fnUpdateParentEndDt()">
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
					<div class="title-wrap mt10">
						<h4>조회결과</h4>
						<div class="btn-group">
							<div class="right"><%-- 버튼위치는 pos param 에 따라 나옴 (없으면 기본 상단나옴) T_CODE.CODE_VALUE='BTN_POS' 참고 --%>
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
					<!-- /그리드 타이틀, 컨트롤 영역 -->
					<div id="auiGrid" style="margin-top: 5px; height: 555px; width: 100%"></div>
					<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">0</strong>건
						</div>
						<c:if test="${page.fnc.F00672_001 eq 'Y'}">
							<div class="right">
								미확인 금액 : <span class="text-danger" id="unConfirmAmt" name="unConfirmAmt" format="num" >원</span>
								미확인 건수 : <span class="text-danger" id="unConfirmCount" name="unConfirmCount" format="num" >건</span>
							</div>
						</c:if>
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