<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 장부 > 자금일보 > null > 자금현황 예금잔액
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2020-04-08 17:55:01
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	var auiGrid;
	$(document).ready(function () {
		createAUIGrid();
		console.log("val : ", $M.getValue("funds_type_cd"));
	});

	function fnClose() {
		window.close();
	}

	function createAUIGrid() {
		var gridPros = {
			showRowNumColumn : true,
			enableFilter :true,
			showFooter : true,
			footerPosition : "top",
		};

		var columnLayout = [
			{
				headerText : "계정과목",
				dataField : "acnt_name",
				style : "aui-center",
				width : "11%"
			},
			{
				headerText : "관리번호",
				dataField : "deposit_code",
				style : "aui-center aui-popup",
				width : "8%",
				filter : {
					showIcon : true
				}
			},
			{
				headerText : "관리명",
				dataField : "deposit_name",
				style : "aui-left",
				filter : {
					showIcon : true
				}
			},
			{
				headerText : "이월",
				dataField : "before_amt",
// 				dataType : "numeric",
// 				formatString : "#,##0.00",
				style : "aui-right",
				labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
					console.log(value);
					console.log("item : ", item);
					return $M.getValue("funds_type_cd") == "1" ? AUIGrid.formatNumber(value, "#,##0") : AUIGrid.formatNumber(value, "#,##0.00");  
				},
			},
			{
				headerText : "입금",
				dataField : "in_amt",
// 				dataType : "numeric",
// 				formatString : "#,##0.00",
				style : "aui-right",
				labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
					console.log(value);
					console.log("item : ", item);
					return $M.getValue("funds_type_cd") == "1" ? AUIGrid.formatNumber(value, "#,##0") : AUIGrid.formatNumber(value, "#,##0.00");  
				},
			},
			{
				headerText : "출금",
				dataField : "out_amt",
// 				dataType : "numeric",
// 				formatString : "#,##0.00",
				style : "aui-right",
				labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
					console.log(value);
					console.log("item : ", item);
					return $M.getValue("funds_type_cd") == "1" ? AUIGrid.formatNumber(value, "#,##0") : AUIGrid.formatNumber(value, "#,##0.00");  
				},
			},
			{
				headerText : "잔액",
				dataField : "balance_amt",
// 				dataType : "numeric",
// 				formatString : "#,##0.00",
				style : "aui-right",
				labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
					console.log(value);
					console.log("item : ", item);
					return $M.getValue("funds_type_cd") == "1" ? AUIGrid.formatNumber(value, "#,##0") : AUIGrid.formatNumber(value, "#,##0.00");  
				},
			}
		];

		// 푸터 설정
		var footerLayout = [
			{
				labelText : "합계",
				positionField : "deposit_name"
			},
			{
				dataField: "before_amt",
				positionField: "before_amt",
				operation: "SUM",
				formatString : "#,##0.00",
				style: "aui-right aui-footer",
			},
			{
				dataField: "in_amt",
				positionField: "in_amt",
				operation: "SUM",
				formatString : "#,##0.00",
				style: "aui-right aui-footer"
			},
			{
				dataField: "out_amt",
				positionField: "out_amt",
				operation: "SUM",
				formatString : "#,##0.00",
				style: "aui-right aui-footer"
			},
			{
				dataField: "balance_amt",
				positionField: "balance_amt",
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
		$("#auiGrid").resize();

		AUIGrid.bind(auiGrid, "cellClick", function(event) {
			if(event.dataField == "deposit_code") {

				if($M.getValue("str_type") == "W") {
// 					var acctNo = event.item.account_no;
					var acctNo = event.item.account_no.replace('-', '');
// // 					console.log(acctNo);
// 					var param = {
// 							acct_no : event.item.account_no
// 					}
// 					var poppupOption = "";
// 					$M.goNextPage('/acnt/acnt0201p03', $M.toGetParam(param), {popupStatus : poppupOption});
					
					var param = {
							"parent_js_name" : "fnSetBankInfo",
							"funds_show_yn" : "Y",
							"s_account_no" : acctNo
					};
// 					var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1300, height=450, left=0, top=0";
					var popupOption = "";
					$M.goNextPage('/cust/cust0301p03', $M.toGetParam(param), {popupStatus : popupOption});
				} else {
// 					var poppupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=950, height=350, left=0, top=0";
					var param = {
							funds_type_cd : event.item.funds_type_cd,
							deposit_code : event.item.deposit_code,
							s_end_dt : $M.getValue("s_end_dt")
					}
					var poppupOption = "";
					$M.goNextPage('/acnt/acnt0201p02', $M.toGetParam(param), {popupStatus : poppupOption});
				}
			}
		});
	}
	</script>
</head>
<body>
<input type="hidden" name="num" value="${inputParam.str}">
<input type="hidden" name="str_type" value="${inputParam.str_type}">
<input type="hidden" name="funds_type_cd" value="${inputParam.funds_type_cd}">
<input type="hidden" name="s_end_dt" value="${s_end_dt}">
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
				<h4>자금현황<span class="text-primary pl10">${inputParam.str}</span></h4>
			</div>
			<div id="auiGrid" style="margin-top: 5px; height: 350px;"></div>
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

</body>
</html>