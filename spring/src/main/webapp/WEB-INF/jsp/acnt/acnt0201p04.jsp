<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 장부 > 자금일보 > null > 입금외화등록
-- 작성자 : 황빛찬
-- 최초 작성일 : 2020-09-03 17:55:01
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
	var auiGrid;
	
	var gridRowIndex;
	// 행번호
	var rowNum = '${rowNum}' + 1;
	
	$(document).ready(function () {
		createAUIGrid();
	});
	
// 	function fnSetCustInfo(data) {
// 		console.log("data : ", data);
// 		AUIGrid.updateRow(auiGrid, { "cust_name" : data.cust_name }, gridRowIndex);
// 		AUIGrid.updateRow(auiGrid, { "cust_no" : data.cust_no }, gridRowIndex);
// 	}

	function fnAdd() {
		var colIndex = AUIGrid.getColumnIndexByDataField(auiGrid, "funds_in_plan_no");
		fnSetCellFocus(auiGrid, colIndex, "funds_in_plan_no");
		var item = new Object();
		if(fnCheckGridEmpty(auiGrid)) {
	    		item.funds_in_plan_no = "",
	    		item.reg_mem_name = "",
	    		item.plan_dt = "",
	    		item.plan_amt = null,
	    		item.money_unit_cd = "",
	    		item.cust_name = "",
	    		item.remark = "",
	    		item.row_num = rowNum;
	    		AUIGrid.addRow(auiGrid, item, 'last');
		}		
		
		rowNum++;
	}

	// 장비추가내역 그리드 벨리데이션
	function fnCheckGridEmpty() {
		return AUIGrid.validateGridData(auiGrid, ["plan_dt", "plan_amt", "money_unit_cd", "cust_name", "remark"], "필수 항목은 반드시 값을 입력해야합니다.");
	}
	
	function goSave() {
		if(fnCheckGridEmpty(auiGrid) == false) {
			return;
		}
		
		var fundsInPlanNo = [];
        var planDt = [];
        var planAmt = [];
        var moneyUnitCd = [];
        var custNo = [];
        var custName = [];
        var remark = [];
        var rowNum = [];
        var fundsInPlanCmd = [];
		
		var addRows = AUIGrid.getAddedRowItems(auiGrid);
		var editRows = AUIGrid.getEditedRowItems(auiGrid);
		var removeRows = AUIGrid.getRemovedItems(auiGrid);
		
		var frm = document.main_form;
		frm = $M.toValueForm(document.main_form);
		
		for (var i = 0; i < addRows.length; i++) {
			fundsInPlanNo.push(addRows[i].funds_in_plan_no);
			planDt.push(addRows[i].plan_dt);
			planAmt.push(addRows[i].plan_amt);
			moneyUnitCd.push(addRows[i].money_unit_cd);
// 			custNo.push(addRows[i].cust_no);
			custName.push(addRows[i].cust_name);
			remark.push(addRows[i].remark);
			rowNum.push(addRows[i].row_num);
			fundsInPlanCmd.push("C");
		}

		for (var i = 0; i < editRows.length; i++) {
			fundsInPlanNo.push(editRows[i].funds_in_plan_no);
			planDt.push(editRows[i].plan_dt);
			planAmt.push(editRows[i].plan_amt);
			moneyUnitCd.push(editRows[i].money_unit_cd);
// 			custNo.push(editRows[i].cust_no);
			custName.push(editRows[i].cust_name);
			remark.push(editRows[i].remark);
			rowNum.push(editRows[i].row_num);
			fundsInPlanCmd.push("U");
		}

		for (var i = 0; i < removeRows.length; i++) {
			fundsInPlanNo.push(removeRows[i].funds_in_plan_no);
			planDt.push(removeRows[i].plan_dt);
			planAmt.push(removeRows[i].plan_amt);
			moneyUnitCd.push(removeRows[i].money_unit_cd);
// 			custNo.push(removeRows[i].cust_no);
			custName.push(removeRows[i].cust_name);
			remark.push(removeRows[i].remark);
			rowNum.push(removeRows[i].row_num);
			fundsInPlanCmd.push("D");
		}
		
		console.log("addRows : ", addRows);
		console.log("editRows : ", editRows);
		console.log("removeRows : ", removeRows);
		
		var option = {
				isEmpty : true
		};
		
		$M.setValue(frm, "funds_in_plan_no_str", $M.getArrStr(fundsInPlanNo, option));
		$M.setValue(frm, "plan_dt_str", $M.getArrStr(planDt, option));
		$M.setValue(frm, "plan_amt_str", $M.getArrStr(planAmt, option));
		$M.setValue(frm, "money_unit_cd_str", $M.getArrStr(moneyUnitCd, option));
// 		$M.setValue(frm, "cust_no_str", $M.getArrStr(custNo, option));
		$M.setValue(frm, "cust_name_str", $M.getArrStr(custName, option));
		$M.setValue(frm, "remark_str", $M.getArrStr(remark, option));
		$M.setValue(frm, "row_num_str", $M.getArrStr(rowNum, option));
		$M.setValue(frm, "funds_in_plan_cmd_str", $M.getArrStr(fundsInPlanCmd, option));
		
		console.log("frm : ", frm);
		
		$M.goNextPageAjaxSave(this_page +"/save", frm, {method : 'POST'}, 
  			function(result) {
   				if(result.success) {
   					alert("저장이 완료되었습니다.");
// 					window.opener.location.reload();
					window.opener.goSearch();
   					fnClose();
   				};
   			}
   		);
	}
	
	function fnClose() {
		window.close();
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

		var fixList = [
			{fix_yn : "JPY", fix_name : "JPY"},
			{fix_yn : "USD", fix_name : "USD"},
			{fix_yn : "EUR", fix_name : "EUR"}
		];

		var columnLayout = [
// 			{ 
// 				dataField : "cust_no", 
// 				visible : false
// 			},
			{
				headerText : "행번호",
				dataField : "row_num",
				visible : false
			},
			{
				headerText : "관리번호",
				dataField : "funds_in_plan_no",
				width : "15%",
				editable : false,
				filter : {
					showIcon : true
				}
			},
			{
				headerText : "담당자",
				dataField : "reg_mem_name",
				width : "10%",
				editable : false,
			},
			{
				headerText : "입금일자",
				dataField : "plan_dt",
				dataType : "date",
				width : "10%",
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
				dataField : "plan_amt",
				dataType : "numeric",
				formatString : "#,##0",
				width : "12%",
				style : "aui-right aui-editable",
				editRenderer : {
				      type : "InputEditRenderer",
				      min : 1,
				      onlyNumeric : true,
				      // 에디팅 유효성 검사
				      validator : AUIGrid.commonValidator
				}
			},
			{
				headerText : "구분",
				dataField : "money_unit_cd",
				width : "10%",
				showEditorBtn : false,
				showEditorBtnOver : false,
				editable : true,
				style : "aui-center aui-editable",
				editRenderer : {
					type : "DropDownListRenderer",
					list : fixList,
					keyField : "fix_yn",
					valueField  : "fix_name"
				},
			},
			{
				headerText : "고객명",
				dataField : "cust_name",
				style : "aui-center aui-editable",
				width : "12%",
				editable : true,
			},
			{
				headerText : "비고",
				dataField : "remark",
				style : "aui-left aui-editable"
			},
			{
				headerText : "삭제",
				dataField : "removeBtn",
				width : "8%",
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
				positionField : "plan_dt"
			},
			{
				dataField: "plan_amt",
				positionField: "plan_amt",
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
		
// 		AUIGrid.bind(auiGrid, "cellClick", function (event) {
// 			if (event.dataField == "cust_name") {
// 				// TODO : 고객통합조회 팝업 호출
// 				var param = {
// 						s_cust_no : $M.getValue("cust_name")
// 				};
// 				gridRowIndex = event.rowIndex;
// 				openSearchCustPanel('fnSetCustInfo', $M.toGetParam(param));
// 			}
// 		});
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
				<h4>입금외화등록</h4>
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