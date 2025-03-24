<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 비용관리 > 카드사용내역관리 > null > null
-- 작성자 : 박준영
-- 최초 작성일 : 2020-05-19 15:15:01
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
	
	
		//세액공제여부
		var taxDudectYnList = [ { "code_name" : "-선택 -","code_value":"" },{"code_value":"Y", "code_name" : "처리"}, {"code_value" :"N", "code_name" :"미처리"}];	
	
		var gridRowIndex;
		var auiGrid;
		$(document).ready(function() {
			
			createAUIGrid();
			fnInitDate();
			goSearchCard(); //카드선택리스트 가져오기
		});
		
		// 카드사용내역상세 acnt0101p01 저장 시 체크
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


		function createAUIGrid() {
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
		
		function goSearch() {

			if($('#s_card_no option').length < 1){
				alert('선택할 값이 없습니다.');
				return;
			}
			
			if($M.checkRangeByFieldName("s_start_dt", "s_end_dt", true) == false) {				
				return;
			}; 
						
			var param = {
				s_start_dt : $M.getValue("s_start_dt"),
				s_end_dt : $M.getValue("s_end_dt"),
				s_hipass_yn : $M.getValue("s_hipass_yn"),
				s_card_no : $M.getValue("s_card_no"),
				s_sort_key : "approval_date",
				s_sort_method : "asc"
			};
			_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
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
		
		//그리드 스타일을 동적으로 바꾸기
	 	function myCellStyleFunction(rowIndex, columnIndex, value, headerText, item, dataField) {
			
  	        
           	if (item.acnt_confirm_yn == "Y") {
             	return "aui-center";
            } else {
             	return "aui-editable";
            }
    
        };
		
		
		// 검색 시작일자 세팅 현재날짜의 20일전
		function fnInitDate() {
			var now = "${inputParam.s_current_dt}";
			$M.setValue("s_start_dt", $M.addDates($M.toDate(now), -20));
			$("#s_hipass_yn").val("N").prop("selected", true);
		}
		
		
		//카드선택리스트 가져오기 ( default : 전체)
		function  goSearchCard() {			
			var param = {
					s_hipass_yn : $M.getValue("s_hipass_yn")
			};			
			$M.goNextPageAjax(this_page+"/searchcard", $M.toGetParam(param), {method : 'get'},
				function(result) {
				
					$("select#s_card_no option").remove();	
		    		if(result.success) {		
	    			
		    			//관리부는 카드 전체내역 조회
		    			// 이금님사원님. 영업부 업무대행으로 영업부서이긴 하나 관리부 업무도 필요하여 추가.. 210813 김상덕 210813 김상덕
		    			<%--if( '${SecureUser.org_code}' == '2000' || '${inputParam.login_mem_no}' == 'MB00000181' ){--%>
		    			if("${page.fnc.F00643_001}" == "Y"){
		    				$('#s_card_no').append('<option value="" >- 전체 -</option>');
		    			}
	    			
						//사용자별 카드선택 리스트 적용
		    			for(i = 0; i< result.list.length; i++){       		    				
			    			var optVal = result.list[i].card_no;
			    			var optText = $M.creditCardFormat(result.list[i].card_no) + '  ' + result.list[i].card_user_name;
			    			$('#s_card_no').append('<option value="'+ optVal +'">'+ optText +'</option>');			    			
		                }	
						
						goSearch();
		    		}					
				}
			);	
		}
		
		//미확인금액 가져오기
		function fnGetUnconfirmAmt(result){
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
					
// 					cardCodeArr.push(rowItem.item.card_code);
// 					useMemNoArr.push(rowItem.item.mem_no);
// 					acntDtArr.push(rowItem.item.acnt_dt);
// 					acntCodeArr.push(rowItem.item.acnt_code);
// 					taxDudectYnArr.push(rowItem.item.tax_dudect_yn);
// 					// remark : # --> "" 으로 변경  (# 삭제)
// 					remarkArr.push(rowItem.item.remark.replace(/#/gi,""));
// // 					remarkArr.push(rowItem.item.remark);
// 					ibkCcmApprSeqArr.push(rowItem.item.ibk_ccm_appr_seq);
				}
				
				var frm = fnCheckedGridDataToForm(auiGrid);
				
			}
			
			console.log("frm : ", frm);
// 			var option = {
// 					isEmpty : true
// 			};
			
// 			var param = {
// 					card_code_str : $M.getArrStr(cardCodeArr, option),
// 					use_mem_no_str : $M.getArrStr(useMemNoArr, option),
// 					acnt_dt_str : $M.getArrStr(acntDtArr, option),
// 					acnt_code_str : $M.getArrStr(acntCodeArr, option),
// 					tax_dudect_yn_str : $M.getArrStr(taxDudectYnArr, option),
// 					remark_str : $M.getArrStr(remarkArr, option),
// 					ibk_ccm_appr_seq_str : $M.getArrStr(ibkCcmApprSeqArr, option),
// 			}
			
// 			frm = fnCheckedGridDataToForm(auiGrid);		
			// 회계전송 정보
// 			$M.setValue(frm, "ibk_ccm_appr_seq_str", $M.getArrStr(items, {key : 'ibk_ccm_appr_seq'}));
			
// 			console.log("param : ", param);
			
			var msg = "회계전송하시겠습니까?";
			$M.goNextPageAjaxMsg(msg, this_page + "/saveAcntTrans", frm, {method : 'POST'},
				function(result) {
					if(result.success) {
						AUIGrid.removeSoftRows(auiGrid);
						AUIGrid.resetUpdatedItems(auiGrid);		
						$("#total_cnt").html(AUIGrid.getGridData(auiGrid).length);	
						goSearch();
					};
				}
			);				
		}
		
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
			$M.goNextPageAjaxMsg(msg, this_page + "/cancelAccTrans", $M.toGetParam(param), {method : 'POST'}, 
				function(result) {
					if(result.success) {
						goSearch();
					};
				}
			);
		}

		
		function fnDownloadExcel() {
			  // 엑셀 내보내기 속성
			  var exportProps = {
			         // 제외항목
			         //exceptColumnFields : ["removeBtn"]
			  };
			  fnExportExcel(auiGrid, "법인카드사용이력", exportProps);
		}
				
	</script>
	
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" name="clickedRowIndex">
	<div class="layout-box">
		<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
				<!-- 메인 타이틀 -->
				<div class="main-title">
					<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
				</div>
				<!-- /메인 타이틀 -->
				<div class="contents">
					<!-- 기본 -->
					<div class="search-wrap">
						<table class="table">
							<colgroup>
								<col width="60px">
								<col width="260px">
								<col width="70px">
								<col width="320px">
								<col width="">
							</colgroup>
							<tbody>
							<tr>
								<th>사용기간</th>
								<td>							
									<div class="form-row inline-pd">
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="조회 시작일" value="${searchDtMap.s_start_dt}">
											</div>
										</div>
										<div class="col-auto">~</div>
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="조회 완료일" value="${searchDtMap.s_end_dt}">
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
								<th>카드구분</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-4">
											<select class="form-control" id="s_hipass_yn" name="s_hipass_yn" onchange="javascript:goSearchCard();" >
												<option value="" >- 전체 -</option>
												<option value="N" >법인카드 </option>
												<option value="Y" >하이패스</option>
											</select>
										</div>
										<div class="col-8">
											<select class="form-control" id="s_card_no" name="s_card_no" ></select>
										</div>
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
					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
					<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">
						<div class="left">
							총 <strong class="text-primary" id="total_cnt"  >0</strong>건
						</div>
						<div class="right">
							미확인 금액 : <span class="text-danger" id="unConfirmAmt" name="unConfirmAmt" format="num" >원</span>
							미확인 건수 : <span class="text-danger" id="unConfirmCount" name="unConfirmCount" format="num" >건</span>
						</div>
					</div>
					<!-- /그리드 서머리, 컨트롤 영역 -->
				</div>
			</div>
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>	
		</div>
		<!-- /contents 전체 영역 -->
	</div>
</form>
</body>
</html>