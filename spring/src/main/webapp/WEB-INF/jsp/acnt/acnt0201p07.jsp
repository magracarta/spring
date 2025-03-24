<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 장부 > 자금일보 > null > 예적금 등록
-- 작성자 : 황빛찬
-- 최초 작성일 : 2020-09-08 13:27:21
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	var bankCdJson = JSON.parse('${codeMapJsonObj['BANK']}');
	var auiGrid;
	
	var gridRowIndex;
	// 행번호
	var rowNum = '${rowNum}' + 1;
	
	$(document).ready(function () {
		createAUIGrid();
	});
	
	function fnAdd() {
		var colIndex = AUIGrid.getColumnIndexByDataField(auiGrid, "funds_daily_saving_seq");
		fnSetCellFocus(auiGrid, colIndex, "funds_daily_saving_seq");
		var item = new Object();
		if(fnCheckGridEmpty(auiGrid)) {
	    		item.funds_daily_saving_seq = "0",
// 	    		item.bank_name = "",
	    		item.bank_cd = "",
	    		item.account_no = "",
	    		item.expire_dt = "",
	    		item.join_dt = "",
	    		item.savings_amt = null,
	    		item.row_num = rowNum;
	    		AUIGrid.addRow(auiGrid, item, 'last');
		}		
		
		rowNum++;
	}
	
	// 장비추가내역 그리드 벨리데이션
	function fnCheckGridEmpty() {
		return AUIGrid.validateGridData(auiGrid, ["bank_cd", "account_no", "join_dt", "expire_dt", "savings_amt"], "필수 항목은 반드시 값을 입력해야합니다.");
	}
	
	function goSave() {
		if(fnCheckGridEmpty(auiGrid) == false) {
			return;
		}
		
		var fundsDailySavingSeq = [];
        var bankCd = [];
        var accountNo = [];
        var expireDt = [];
        var joinDt = [];
        var savingsAmt = [];
        var rowNum = [];
        var fundsSavingsCmd = [];
		
		var addRows = AUIGrid.getAddedRowItems(auiGrid);
		var editRows = AUIGrid.getEditedRowItems(auiGrid);
		var removeRows = AUIGrid.getRemovedItems(auiGrid);
		
		var frm = document.main_form;
		frm = $M.toValueForm(document.main_form);
		
		for (var i = 0; i < addRows.length; i++) {
			fundsDailySavingSeq.push(addRows[i].funds_daily_saving_seq);
			bankCd.push(addRows[i].bank_cd);
			accountNo.push(addRows[i].account_no);
			expireDt.push(addRows[i].expire_dt);
			joinDt.push(addRows[i].join_dt);
			savingsAmt.push(addRows[i].savings_amt);
			rowNum.push(addRows[i].row_num);
			fundsSavingsCmd.push("C");
		}

		for (var i = 0; i < editRows.length; i++) {
			fundsDailySavingSeq.push(editRows[i].funds_daily_saving_seq);
			bankCd.push(editRows[i].bank_cd);
			accountNo.push(editRows[i].account_no);
			expireDt.push(editRows[i].expire_dt);
			joinDt.push(editRows[i].join_dt);
			savingsAmt.push(editRows[i].savings_amt);
			rowNum.push(editRows[i].row_num);
			fundsSavingsCmd.push("U");
		}

		for (var i = 0; i < removeRows.length; i++) {
			fundsDailySavingSeq.push(removeRows[i].funds_daily_saving_seq);
			bankCd.push(removeRows[i].bank_cd);
			accountNo.push(removeRows[i].account_no);
			expireDt.push(removeRows[i].expire_dt);
			joinDt.push(removeRows[i].join_dt);
			savingsAmt.push(removeRows[i].savings_amt);
			rowNum.push(removeRows[i].row_num);
			fundsSavingsCmd.push("D");
		}
		
		console.log("addRows : ", addRows);
		console.log("editRows : ", editRows);
		console.log("removeRows : ", removeRows);
		
		var option = {
				isEmpty : true
		};
		
		$M.setValue(frm, "funds_daily_saving_seq_str", $M.getArrStr(fundsDailySavingSeq, option));
		$M.setValue(frm, "bank_cd_str", $M.getArrStr(bankCd, option));
		$M.setValue(frm, "account_no_str", $M.getArrStr(accountNo, option));
		$M.setValue(frm, "expire_dt_str", $M.getArrStr(expireDt, option));
		$M.setValue(frm, "join_dt_str", $M.getArrStr(joinDt, option));
		$M.setValue(frm, "savings_amt_str", $M.getArrStr(savingsAmt, option));
		$M.setValue(frm, "row_num_str", $M.getArrStr(rowNum, option));
		$M.setValue(frm, "funds_savings_cmd_str", $M.getArrStr(fundsSavingsCmd, option));
		
		console.log("frm : ", frm);
		
		$M.goNextPageAjaxSave(this_page +"/save", frm, {method : 'POST'}, 
  			function(result) {
   				if(result.success) {
//    					alert("저장이 완료되었습니다.");
// 					window.opener.location.reload();
					window.opener.goSearch();
   					fnClose();
   				};
   			}
   		);
	}
	
	function createAUIGrid() {
		var gridPros = {
			showRowNumColumn : true,
			editable : true,
			showFooter : true,
			footerPosition : "top",
			enableFilter :true,
			rowIdField : "_$uid",
		};

		var columnLayout = [
			{
				headerText : "행번호",
				dataField : "row_num",
				visible : false
			},
			{
				dataField : "funds_daily_saving_seq",
				visible : false
			},
// 			{
// 				dataField : "bank_cd",
// 				visible : false
// 			},
			{
				headerText : "은행명",
				dataField : "bank_cd",
				style : "aui-center aui-editable",
				editable : true,
				editRenderer : {
					type : "DropDownListRenderer",
					list : bankCdJson,
					keyField : "code_value",
					valueField  : "code_name"
				},
				labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) { 
					var retStr = value;
					for(var j = 0; j < bankCdJson.length; j++) {
						if(bankCdJson[j]["code_value"] == value) {
							retStr = bankCdJson[j]["code_name"];
							break;
						}
					}
					return retStr;
				},
				filter : {
					showIcon : true
				}
			},
			{
				headerText : "계좌번호",
				dataField : "account_no",
				style : "aui-center aui-editable",
				editable : true,
				filter : {
					showIcon : true
				}
			},
			{
				headerText : "가입일자",
				dataField : "join_dt",
				dataType : "date",
				style : "aui-center aui-editable",
				dataInputString : "yyyymmdd",
				formatString : "yyyy-mm-dd",
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
				},
				editable : true
			},
			{
				headerText : "만기일자",
				dataField : "expire_dt",
				dataType : "date",
				style : "aui-center aui-editable",
				dataInputString : "yyyymmdd",
				formatString : "yyyy-mm-dd",
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
				},
				editable : true
			},
			{
				headerText : "금액",
				dataField : "savings_amt",
				dataType : "numeric",
				formatString : "#,##0",
				style : "aui-right aui-editable",
				editRenderer : {
				      type : "InputEditRenderer",
// 				      min : 1,
				      onlyNumeric : true,
				      allowNegative : true,
				      // 에디팅 유효성 검사
				      validator : AUIGrid.commonValidator
				}
			},
			{
				headerText : "삭제",
				dataField : "removeBtn",
				width : "10%",
				renderer : {
					type : "ButtonRenderer",
					onClick : function(event) {
						var isRemoved = AUIGrid.isRemovedById(auiGrid, event.item._$uid);
						if (isRemoved == false) {
							AUIGrid.removeRow(event.pid, event.rowIndex);
						} else {
							AUIGrid.restoreSoftRows(auiGrid, "selectedIndex");
						}
					}
				},
				labelFunction : function(rowIndex, columnIndex, value,
										 headerText, item) {
					return '삭제'
				},
				style : "aui-center",
				editable : true
			}
		];

		// 푸터 설정
		var footerLayout = [
			{
				labelText : "합계",
				positionField : "account_no"
			},
			{
				dataField: "savings_amt",
				positionField: "savings_amt",
				operation: "SUM",
				formatString : "#,##0",
				style: "aui-right aui-footer"
			}
		];

		// 실제로 #grid_wrap에 그리드 생성
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		// 푸터 레이아웃 세팅
		AUIGrid.setFooter(auiGrid, footerLayout);
		// 그리드 갱신
		AUIGrid.setGridData(auiGrid, ${list});
	}
	
	function fnClose() {
		window.close();
	}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
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
				<h4>자금현황 예적금(WON)</h4>
				<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
			</div>
			<div id="auiGrid" style="margin-top: 5px; height: 380px;"></div>
		</div>
		<!-- /폼테이블-->
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