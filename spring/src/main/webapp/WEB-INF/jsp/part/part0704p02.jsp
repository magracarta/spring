<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 코드관리 > 부품판가산출지표 > null > 기준산출코드 History 상세
-- 작성자 : 황빛찬
-- 최초 작성일 : 2020-01-10 17:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
	var auiGrid;

	$(document).ready(function() {
		createAUIGridCalcCode(); // 기준산출코드 그리드
// 		createAUIGridCalcCodeSample(); // 기준산출코드 그리드 (Sample)
// 		createAUIGridCalcCodeRatio(); // 기준산출코드 그리드 (비율)
	});
	
	// 기준산출코드 그리드생성 
	function createAUIGridCalcCode() {
		var gridPros = {
			rowIdField : "_$uid", 
			// rowNumber 
			showRowNumColumn: true,
			// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
			wrapSelectionMove : false,
			showStateColumn : true,
			editable : false,
			enableCellMerge : true
		};
		
		var columnLayout = [
			{ 
				headerText : "메이커", 
				dataField : "code_name", 
				width : "70", 
				style : "aui-center",
// 				editable : false,
				cellMerge : true,
			},
			{
				dataField : "row_num",
				visible : false
			},
			{
				dataField : "maker_cd",
				visible : false
			},
			{
				dataField : "part_price_log_seq",
				visible : false
			},
			{
				dataField : "part_price_maker_cd",
				visible : false
			},
			{
				dataField : "part_production_cd",
				visible : false
			},
			{
				headerText : "생산구분", 
				dataField : "part_production_name", 
				width : "55", 
				style : "aui-center",
				editable : false,
			},
			{ 
				headerText : "기준산출코드", 
				dataField : "part_output_price_cd",
				width : "80", 
				style : "aui-center",
// 				editable : true,
// 				editRenderer : {
// 					type : "DropDownListRenderer",
// 					list : outputPriceCodeList,
// 					keyField : "code",
// 					valueField  : "code"
// 				},
			},
			{
				headerText : "실사구분", 
				dataField : "part_real_check", 
				width : "55", 
				style : "aui-center",
// 				editable : true,
// 				editRenderer : {
// 					type : "DropDownListRenderer",
// 					list : partRealCheckArray,
// 					keyField : "code_value",
// 					valueField  : "code_name"
// 				},
// 				labelFunction : function(rowIndex, columnIndex, value){
// 					for(var i=0; i<partRealCheckArray.length; i++){
// 						if(value == partRealCheckArray[i].code_value){
// 							return partRealCheckArray[i].code_name;
// 						}
// 					}
// 					return value;
// 				},
			},
			{ 
				headerText : "원산지", 
				dataField : "part_country",
				width : "50", 
				style : "aui-center",
// 				editable : true,
// 				editRenderer : {
// 					type : "DropDownListRenderer",
// 					list : partCountryArray,
// 					keyField : "code_value",
// 					valueField  : "code_name"
// 				},
// 				labelFunction : function(rowIndex, columnIndex, value){
// 					for(var i=0; i<partCountryArray.length; i++){
// 						if(value == partCountryArray[i].code_value){
// 							return partCountryArray[i].code_name;
// 						}
// 					}
// 					return value;
// 				},
			},
			{ 
				headerText : "관리구분", 
				dataField : "part_mng_name",
				width : "65",
				style : "aui-center",
				editable : false,
			},
			{ 
				headerText : "기준환율", 
				dataField : "basic_er_price",  
				width : "65", 
				dataType : "numeric",
				formatString : "#,##0.000",
				style : "aui-right",
				editable : false,
				labelFunction : function(rowIndex, columnIndex, value){
					if (value == "0") {
						return "";
					} else {
						return value;
					}
				},
			},
			{ 
				headerText : "결정환율", 
				dataField : "fixed_er_price",  
				width : "65", 
				dataType : "numeric",
				formatString : "#,##0.000",
				style : "aui-right",
				editable : false,
				labelFunction : function(rowIndex, columnIndex, value){
					if (value == "0") {
						return "";
					} else {
						return value;
					}
				},
			},
			{ 
				headerText : "관리비", 
				dataField : "part_price_mng_amount",  
				width : "55", 
				dataType : "numeric",
				formatString : "#,##0",
				style : "aui-right",
				editable : false,
				labelFunction : function(rowIndex, columnIndex, value){
					if (value == "0") {
						return "";
					} else {
						return value;
					}
				},
			},
			{ 
				headerText : "마진", 
				dataField : "part_price_margin",  
				width : "55", 
				dataType : "numeric",
				formatString : "#,##0.000",
				style : "aui-right",
				editable : false,
				labelFunction : function(rowIndex, columnIndex, value){
					if (value == "0") {
						return "";
					} else {
						return value;
					}
				},
			},
			{ 
				headerText : "기본 판가 수식", 
				dataField : "part_output_price_name",  
				width : "160", 
				style : "aui-left",
				editable : false,
			},	
			{ 
				headerText : "Net Price", 
				dataField : "net_price",  
				width : "70", 
				dataType : "numeric",
				headerStyle : 'aui-fold',
				formatString : "#,##0",
				style : "aui-right",
// 				editable : true,
				labelFunction : function(rowIndex, columnIndex, value){
					if (value == "0") {
						return "";
					} else {
						return $M.setComma(value);
					}
				},
			},
			{ 
				headerText : "A : 판매가", 
				dataField : "vip_price",  
				width : "70", 
				dataType : "numeric",
				headerStyle : 'aui-fold',
				formatString : "#,##0",
				style : "aui-right",
				editable : false,
				labelFunction : function(rowIndex, columnIndex, value){
					if (value == "0") {
						return "";
					} else {
						return $M.setComma(value);
					}
				},
			},
			{ 
				headerText : "마진", 
				dataField : "vip_margin_price",  
				width : "55", 
				dataType : "numeric",
				headerStyle : 'aui-fold',
				formatString : "#,##0",
				style : "aui-right",
				editable : false,
				labelFunction : function(rowIndex, columnIndex, value){
					if (value == "0") {
						return "";
					} else {
						return $M.setComma(value);
					}
				},
			},
			{ 
				headerText : "B : 일반판매가", 
				dataField : "sale_price",  
				width : "95", 
				dataType : "numeric",
				formatString : "#,##0",
				style : "aui-right",
				editable : false,
				labelFunction : function(rowIndex, columnIndex, value){
					if (value == "0") {
						return "";
					} else {
						return $M.setComma(value);
					}
				},
			},
			{ 
				headerText : "마진", 
				dataField : "sale_margin_price",  
				width : "60", 
				dataType : "numeric",
				formatString : "#,##0",
				style : "aui-right",
				editable : false,
				labelFunction : function(rowIndex, columnIndex, value){
					if (value == "0") {
						return "";
					} else {
						return $M.setComma(value);
					}
				},
			},
			{ 
				headerText : "%", 
				dataField : "margin_rate",  
				width : "45", 
				dataType : "numeric",
//					postfix: "%",
				formatString : "#,##0",
				style : "aui-right",
				editable : false,
				labelFunction : function(rowIndex, columnIndex, value){
					if (value == "0") {
						return "";
					} else {
						return value + "%";
					}
				},
			},
			{ 
				headerText : "A-B", 
				dataField : "cal_price",  
				width : "75", 
				dataType : "numeric",
				formatString : "#,##0",
				style : "aui-right",
				editable : false,
				labelFunction : function(rowIndex, columnIndex, value){
					if (value == "0") {
						return "";
					} else {
						return $M.setComma(value);
					}
				},
			},
		];

		auiGridCalcCode = AUIGrid.create("#auiGridCalcCode", columnLayout, gridPros);
		AUIGrid.setGridData(auiGridCalcCode, ${list});
	}
	
	// 닫기 
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
<!-- 상단 폼테이블 -->					
			<div>
				<div class="title-wrap">
					<h4 class="primary">변경일시 ${vipRate.reg_date}</h4>
				</div>
			</div>
				<div class="row">
					<div class="col-12">
						<div class="title-wrap mt10">
							<h4>기준산출코드</h4>
							<div class="btn-group">
								<div class="right">
									비율
									<input type="text" id="part_price_vip_rate" name="part_price_vip_rate" style="width : 70px" value="${vipRate.part_price_vip_rate}" disabled>
								</div>
							</div>							
						</div>
						<div id="auiGridCalcCode" style="margin-bottom: 5px; margin-top: 5px; height: 350px;"></div>
					</div>
				</div>			
<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">						
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