<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 렌탈현황 > 렌탈장비 수요분석 > 고객별 > 고객 조회기간 내 렌탈이력
-- 작성자 : 정윤수
-- 최초 작성일 : 2024-01-23 10:36:21
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var rowIndex;
	
		$(document).ready(function() {
			createAUIGrid();
			goSearch();
			
		});
		function createAUIGrid() {
			var gridPros = {
				// rowIdField 설정
				rowIdField : "_$uid",
				// rowNumber 
				showRowNumColumn: true,
				editable : false,
				showFooter : true,
				footerPosition : "top",
			};
			var columnLayout = [
				{ 
					headerText : "전표일자", 
					dataField : "inout_dt", 
					width : "80", 
					style : "aui-center",
					dataType : "date",
					formatString : "yyyy-mm-dd",
				},			
				{ 
					headerText : "전표번호", 
					dataField : "rental_doc_no", 
					width : "110", 
					style : "aui-center aui-popup",
				},
				{ 
					headerText : "고객명", 
					dataField : "cust_name",
					width : "70",
					style : "aui-center",
				},
				{ 
					headerText : "휴대폰", 
					dataField : "hp_no",
					width : "110",
					style : "aui-center",
				},				
				
				{ 
					headerText : "업체명", 
					dataField : "breg_name", 
					width : "130", 
					style : "aui-center",
				},
				{ 
					headerText : "업종",
					dataField : "mch_use_name",
					width : "60",
				},
				{
					dataField: "mch_use_cd",
					visible: false
				},
				{
					dataField: "breg_type_cd",
					visible: false
				},
				{ 
					headerText : "업체유형", 
					dataField : "breg_type_name", 
					width : "60", 
					style : "aui-center",
				},
				{
					dataField: "breg_type_cd",
					visible: false
				},
				{
					headerText : "자사장비보유",
					dataField : "machine_yn",
					width : "80",
					style : "aui-center",
				},
				{
					headerText : "렌탈모델",
					dataField : "machine_name",
					width : "120",
					style : "aui-center",
				},
				{
					headerText : "렌탈차대번호",
					dataField : "body_no",
					width : "150",
					style : "aui-center",
				},
				{
					headerText : "접수자",
					dataField : "receipt_mem_name",
					width : "50",
					style : "aui-center",
				},
				{
					dataField : "receipt_mem_no",
					visible : false
				},
				{
					headerText : "렌탈시작",
					dataField : "rental_st_dt",
					dataType : "date",
					formatString : "yyyy-mm-dd",
					width : "80",
					style : "aui-center",
				},
				{ 
					headerText : "렌탈종료", 
					dataField : "rental_ed_dt",
					dataType : "date",
					formatString : "yyyy-mm-dd",
					width : "80", 
					style : "aui-center",
				},
				{ 
					headerText : "렌탈기간(일)", 
					dataField : "day_cnt",
					dataType : "numeric",
					formatString : "#,##0",
					width : "80", 
					style : "aui-center",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						if(value == ""){
							return "";
						}else {
							return AUIGrid.formatNumber(value, "#,##0") + "(일)";
						}
					},
				},
				{ 
					headerText : "렌탈금액", 
					dataField : "rental_amt", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "100", 
					style : "aui-right",
				},
				{ 
					headerText : "출고 시 가동시간", 
					dataField : "out_op_hour", 
					width : "100", 
					style : "aui-right",
					dataType : "numeric",
					formatString: "#,###",
				},
				{ 
					headerText : "회수 시 가동시간", 
					dataField : "return_op_hour",
					width : "100",
					style : "aui-right",
					dataType : "numeric",
					formatString: "#,###",
				},
				{
					dataField : "report_sort",
					visible : false
				},
			]

			// 푸터 설정
			var footerLayout = [
				{
					labelText : "합계",
					positionField : "inout_dt"
				},
				{
					dataField: "rental_amt",
					positionField: "rental_amt",
					operation: "SUM",
					formatString : "#,##0",
					style: "aui-right aui-footer"
				},
				{
					dataField: "day_cnt",
					positionField: "day_cnt",
					operation: "SUM",
					formatString : "#,##0",
					style: "aui-center aui-footer",
					labelFunction : function(value, columnValues, footerValues) {
						if(value == ""){
							return "";
						}else {
							return AUIGrid.formatNumber(value, "#,##0") + "(일)";
						}
					},
				},
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 푸터 레이아웃 세팅
			AUIGrid.setFooter(auiGrid, footerLayout);
			AUIGrid.setGridData(auiGrid, []);
			
			AUIGrid.bind(auiGrid, "cellClick", function(event){
				if(event.dataField == "rental_doc_no") {
					var params = {
						rental_doc_no : event.item.rental_doc_no
					}
					var popupOption = "";
					$M.goNextPage('/rent/rent0102p01', $M.toGetParam(params), {popupStatus : popupOption});
				}
			});
			$("#auiGrid").resize();
		}
		
		// 셀 클릭으로 엑스트라 체크박스 체크/해제 하기
		function cellClickHandler(event) {
			
			if(event.dataField == "stock_dt") {		
				
				if(event.item.stock_dt != "") {					
					var param = {
	 						warehouse_cd 	: event.item.warehouse_cd,
	 						part_no 	: event.item.part_no
	 	
	 					};
					var poppupOption = "";
					
					$M.goNextPage("/part/part0501p04", $M.toGetParam(param), {popupStatus : poppupOption});		
				}					
			}			
		};

		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "고객 조회기간 내 렌탈이력");
		}
		
		function goSearch() {
				var param = {
					"s_year" : $M.getValue("s_year"),
					"s_cust_no" : $M.getValue("s_cust_no"),
					"s_mch_use_cd" : $M.getValue("s_mch_use_cd"),
				}

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'GET'},
					function(result) {
						if (result.success) {
							AUIGrid.setGridData(auiGrid, result.list);
							$("#total_cnt").html(result.total_cnt);
						}
					}
			);
		}
		
		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_cust_name", "s_breg_name", "s_hp_no"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch();
				};
			});
		}
		
		// 닫기
		function fnClose() {
			window.close();
		}
		
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<input type="hidden" name="s_cust_no" id="s_cust_no" value="${inputParam.s_cust_no}">
	<input type="hidden" name="s_year" id="s_year" value="${inputParam.s_year}">
	<input type="hidden" name="s_mch_use_cd" id="s_mch_use_cd" value="${inputParam.s_mch_use_cd}">
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
				<div class="title-wrap mt10">
					<h4>조회결과</h4>
					<div class="btn-group">
						<div class="right">
							<c:if test="${page.add.POS_UNMASKING eq 'Y'}">
								<div class="form-check form-check-inline">
									<input  class="form-check-input"  type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" >
									<label  class="form-check-input"  for="s_masking_yn" >마스킹 적용</label>
								</div>
							</c:if>
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
						</div>
					</div>
				</div>
				<div id="auiGrid" style="margin-top: 5px; height: 350px;"></div>
			</div>		
<!-- /폼테이블 -->
			<div class="btn-group mt10">
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">0</strong>건
				</div>	
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