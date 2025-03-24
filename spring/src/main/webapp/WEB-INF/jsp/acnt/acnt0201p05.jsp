<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 장부 > 자금일보 > null > 지출예정금액등록
-- 작성자 : 황빛찬
-- 최초 작성일 : 2020-04-08 17:55:01
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var fundsMoneyUnitJson = JSON.parse('${codeMapJsonObj['FUNDS_MONEY_UNIT']}');
	
		var auiGrid;
		var gridRowIndex;
		
		// 행번호
		var rowNum = '${rowNum}' + 1;
		
		$(document).ready(function () {
			createAUIGrid();
		});

		function fnAdd() {
			var colIndex = AUIGrid.getColumnIndexByDataField(auiGrid, "funds_out_plan_no");
			fnSetCellFocus(auiGrid, colIndex, "funds_out_plan_no");
			var item = new Object();
			if(fnCheckGridEmpty(auiGrid)) {
		    		item.funds_out_plan_no = "",
		    		item.plan_dt = "",
		    		item.plan_amt = null,
		    		item.funds_money_unit_cd = "",
		    		item.deposit_code = "",
		    		item.deposit_name = "",
		    		item.acnt_code = "",
		    		item.acnt_name = "",
		    		item.remark = "",
		    		item.row_num = rowNum;
		    		AUIGrid.addRow(auiGrid, item, 'last');
			}		
			
			rowNum++;
		}
		
		// 장비추가내역 그리드 벨리데이션
		function fnCheckGridEmpty() {
			return AUIGrid.validateGridData(auiGrid, ["plan_dt", "plan_amt", "funds_money_unit_cd", "deposit_name", "acnt_name", "remark"], "필수 항목은 반드시 값을 입력해야합니다.");
		}

		// 저장
		function goSave() {
			if(fnCheckGridEmpty(auiGrid) == false) {
				return;
			}
			
			var fundsOutPlanNo = [];
	        var planDt = [];
	        var planAmt = [];
	        var fundsMoneyUnitCd = [];
	        var depositCode = [];
	        var acntCode = [];
	        var remark = [];
	        var rowNum = [];
	        var fundsOutPlanCmd = [];
			
			var addRows = AUIGrid.getAddedRowItems(auiGrid);
			var editRows = AUIGrid.getEditedRowItems(auiGrid);
			var removeRows = AUIGrid.getRemovedItems(auiGrid);
			
			var frm = document.main_form;
			frm = $M.toValueForm(document.main_form);
			
			for (var i = 0; i < addRows.length; i++) {
				fundsOutPlanNo.push(addRows[i].funds_out_plan_no);
				planDt.push(addRows[i].plan_dt);
				planAmt.push(addRows[i].plan_amt);
				fundsMoneyUnitCd.push(addRows[i].funds_money_unit_cd);
				depositCode.push(addRows[i].deposit_code);
				acntCode.push(addRows[i].acnt_code);
				remark.push(addRows[i].remark);
				rowNum.push(addRows[i].row_num);
				fundsOutPlanCmd.push("C");
			}

			for (var i = 0; i < editRows.length; i++) {
				fundsOutPlanNo.push(editRows[i].funds_out_plan_no);
				planDt.push(editRows[i].plan_dt);
				planAmt.push(editRows[i].plan_amt);
				fundsMoneyUnitCd.push(editRows[i].funds_money_unit_cd);
				depositCode.push(editRows[i].deposit_code);
				acntCode.push(editRows[i].acnt_code);
				remark.push(editRows[i].remark);
				rowNum.push(editRows[i].row_num);
				fundsOutPlanCmd.push("U");
			}

			for (var i = 0; i < removeRows.length; i++) {
				fundsOutPlanNo.push(removeRows[i].funds_out_plan_no);
				planDt.push(removeRows[i].plan_dt);
				planAmt.push(removeRows[i].plan_amt);
				fundsMoneyUnitCd.push(removeRows[i].funds_money_unit_cd);
				depositCode.push(removeRows[i].deposit_code);
				acntCode.push(removeRows[i].acnt_code);
				remark.push(removeRows[i].remark);
				rowNum.push(removeRows[i].row_num);
				fundsOutPlanCmd.push("D");
			}
			
			console.log("addRows : ", addRows);
			console.log("editRows : ", editRows);
			console.log("removeRows : ", removeRows);
			
			var option = {
					isEmpty : true
			};
			
			$M.setValue(frm, "funds_out_plan_no_str", $M.getArrStr(fundsOutPlanNo, option));
			$M.setValue(frm, "plan_dt_str", $M.getArrStr(planDt, option));
			$M.setValue(frm, "plan_amt_str", $M.getArrStr(planAmt, option));
			$M.setValue(frm, "funds_money_unit_cd_str", $M.getArrStr(fundsMoneyUnitCd, option));
			$M.setValue(frm, "deposit_code_str", $M.getArrStr(depositCode, option));
			$M.setValue(frm, "acnt_code_str", $M.getArrStr(acntCode, option));
			$M.setValue(frm, "remark_str", $M.getArrStr(remark, option));
			$M.setValue(frm, "row_num_str", $M.getArrStr(rowNum, option));
			$M.setValue(frm, "funds_out_plan_cmd_str", $M.getArrStr(fundsOutPlanCmd, option));
			
			console.log("frm : ", frm);
			
			$M.goNextPageAjaxSave(this_page +"/save", frm, {method : 'POST'}, 
	  			function(result) {
	   				if(result.success) {
	   					alert("저장이 완료되었습니다.");
// 						window.opener.location.reload();
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
				enableFilter :true,
				showFooter : true,
				footerPosition : "top",
			};

			var fixList = [
				{fix_yn : "JPY", fix_name : "JPY"},
				{fix_yn : "USD", fix_name : "USD"},
				{fix_yn : "EUR", fix_name : "EUR"}
			];

			var columnLayout = [
				{ 
					dataField : "deposit_code", 
					visible : false
				},
				{ 
					dataField : "acnt_code", 
					visible : false
				},
				{
					headerText : "행번호",
					dataField : "row_num",
					visible : false
				},
				{
					headerText : "관리번호",
					dataField : "funds_out_plan_no",
					visible : false
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
					editable : true,
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "금액",
					dataField : "plan_amt",
					dataType : "numeric",
					width : "12%",
					formatString : "#,##0.00",
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
					dataField : "funds_money_unit_cd",
					showEditorBtn : false,
					showEditorBtnOver : false,
					editable : true,
					width : "7%",
					style : "aui-center aui-editable",
					editRenderer : {
						type : "DropDownListRenderer",
						list : fundsMoneyUnitJson,
						keyField : "code_value",
						valueField  : "code_name"
					},
				},
				{
					headerText : "거래처",
					dataField : "deposit_name",
					style : "aui-center aui-editable",
					width : "17%",
					editable : false,
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "계정코드",
					dataField : "acnt_name",
					style : "aui-center aui-editable",
					width : "11%",
					editable : false,
					filter : {
						showIcon : true
					}
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
					formatString : "#,##0.00",
					style: "aui-right aui-footer"
				}
			];

			// 실제로 #grid_wrap에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 푸터 레이아웃 세팅
			AUIGrid.setFooter(auiGrid, footerLayout);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, ${list});
			
			AUIGrid.bind(auiGrid, "cellClick", function (event) {
				if (event.dataField == "deposit_name") {
					// 예금조회 팝업 호출
					var acntCodeArr = ["10301", "10302"];
					var param = {
							"s_funds_daily_yn" : "Y"
// 							"s_acnt_code" : $M.getArrStr(acntCodeArr)
// 							"s_acnt_code" : acntCodeArr
					};
					gridRowIndex = event.rowIndex;
					openDepositInfoPanel('setDepositInfoPanel', $M.toGetParam(param));
				}

				if (event.dataField == "acnt_name") {
					// 계정조회 팝업 호출
					var param = {
							
					};
					gridRowIndex = event.rowIndex;
					openAccountInfoPanel('setAccountInfoPanel', $M.toGetParam(param));
				}
			});
		}
		
		// 예금조회 결과
		function setDepositInfoPanel(result) {
			console.log("예금조회 : ", result);
			AUIGrid.updateRow(auiGrid, { "deposit_code" : result.deposit_code }, gridRowIndex);
			AUIGrid.updateRow(auiGrid, { "deposit_name" : result.deposit_name }, gridRowIndex);
				
		}
		
		// 계정조회 결과
		function setAccountInfoPanel(result) {
			console.log("계정조회 : ", result);
			AUIGrid.updateRow(auiGrid, { "acnt_code" : result.acnt_code }, gridRowIndex);
			AUIGrid.updateRow(auiGrid, { "acnt_name" : result.acnt_name_print }, gridRowIndex);
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