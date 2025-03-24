<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 서비스관리 > 서비스업무평가-센터 > 실적분석 > 각 분야 기준 월별 매출/수익집계
-- 작성자 : 손광진
-- 최초 작성일 : 2020-04-08 13:05:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

	var auiGridTop;
	var auiGridBottom;
	$(document).ready(function() {
		// AUIGrid 생성
		createAUIGridTop();		// 월별 매출
		createAUIGridBottom();	// 월별 수익
	});

	// 엑셀다운로드 (월별 매출 집계)
	function fnDownloadExcel() {
		fnExportExcel(auiGridTop, "월별 매출 집계", "");
	}

	// 엑셀다운로드 (월별 수익 집계)
	function fnExcelDownSec() {
		fnExportExcel(auiGridBottom, "월별 수익 집계", "");
	}

	// 닫기
	function fnClose() {
		window.close(); 
	}	
	
	// 작업지시 그리드
	function createAUIGridTop() {
		var gridPros = {
			editable : false,
			rowIdField : "_$uid", 
			showRowNumColumn : false,
			showFooter: true,
			footerPosition : "top"
		};
		
		var columnLayout = [
			{
				headerText : "구분",
				dataField : "amt_month",
				width : "100"
			},
			{
				headerText : "유상 정비 매출",
				dataField : "cost_amt",
				style : "aui-right",
				dataType : "numeric",
				formatString : "#,##0",
				width : "10%",
				labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
					if (value == "0" || value == ""  || value == null) {
						return "";
					} else {
						return $M.setComma(value);
					}
				}
			},
			{
				headerText : "무상 정비 매출",
				dataField : "free_amt",
				style : "aui-right",
				dataType : "numeric",
				formatString : "#,##0",
				width : "10%",
				labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
					if (value == "0" || value == ""  || value == null) {
						return "";
					} else {
						return $M.setComma(value);
					}
				}
			},
			{
				headerText : "부품 판매 매출",
				dataField : "part_amt",
				style : "aui-right",
				dataType : "numeric",
				formatString : "#,##0",
				width : "10%",
				labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
					if (value == "0" || value == ""  || value == null) {
						return "";
					} else {
						return $M.setComma(value);
					}
				}
			},
			{
				headerText : "렌탈 운영 매출",
				dataField : "rental_amt",
				style : "aui-right",
				dataType : "numeric",
				formatString : "#,##0",
				width : "10%",
				labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
					if (value == "0" || value == ""  || value == null) {
						return "";
					} else {
						return $M.setComma(value);
					}
				}
			},
			{
				headerText : "출하지원 20",
				dataField : "out_servcie_amt",
				style : "aui-right",
				dataType : "numeric",
				formatString : "#,##0",
				width : "10%",
				labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
					if (value == "0" || value == ""  || value == null) {
						return "";
					} else {
						return $M.setComma(value);
					}
				}
			},
			{
				headerText : "신차판매 70",
				dataField : "service_account_amt",
				style : "aui-right",
				dataType : "numeric",
				formatString : "#,##0",
				width : "10%",
				labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
					if (value == "0" || value == ""  || value == null) {
						return "";
					} else {
						return $M.setComma(value);
					}
				}
			},
			{
				headerText : "부품부서",
				dataField : "org_part_amt",
				style : "aui-right",
				dataType : "numeric",
				formatString : "#,##0",
				width : "10%",
				labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
					if (value == "0" || value == ""  || value == null) {
						return "";
					} else {
						return $M.setComma(value);
					}
				}
			},
			{
				headerText : "중고손익",
				dataField : "used_amt",
				style : "aui-right",
				dataType : "numeric",
				formatString : "#,##0",
				width : "10%",
				labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
					if (value == "0" || value == ""  || value == null) {
						return "";
					} else {
						return $M.setComma(value);
					}
				}
			},
			{
				headerText : "월별 최종 매출",
				dataField : "tot_amt",
				style : "aui-right",
				dataType : "numeric",
				formatString : "#,##0",
				width : "10%",
				labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
					if (value == "0" || value == ""  || value == null) {
						return "";
					} else {
						return $M.setComma(value);
					}
				}
			},
			{
				headerText : "전년도 월별 최종 매출",
				dataField : "pre_tot_amt",
				style : "aui-right",
				dataType : "numeric",
				formatString : "#,##0",
				width : "10%",
				labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
					if (value == "0" || value == ""  || value == null) {
						return "";
					} else {
						return $M.setComma(value);
					}
				},
				visible : false
			},
			{
				headerText : "과년대비 성장율",
				dataField : "month_per",
				style : "aui-right",
				dataType : "numeric",
				formatString : "#,##0",
				labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
					if (value == "0" || value == ""  || value == null) {
						return "";
					} else {
						return value + "%";
					}
				}
			}
		];

		var footerColumnLayout = [
			{
				labelText : "합계",
				positionField : "amt_month",
				style : "aui-center aui-fotter"
			},
			{
				dataField : "cost_amt",
				positionField : "cost_amt",
				operation : "SUM",
				formatString : "#,##0",
				style : "aui-right aui-footer"
			},
			{
				dataField : "free_amt",
				positionField : "free_amt",
				operation : "SUM",
				formatString : "#,##0",
				style : "aui-right aui-footer"
			},
			{
				dataField : "part_amt",
				positionField : "part_amt",
				operation : "SUM",
				formatString : "#,##0",
				style : "aui-right aui-footer"
			},
			{
				dataField : "rental_amt",
				positionField : "rental_amt",
				operation : "SUM",
				formatString : "#,##0",
				style : "aui-right aui-footer"
			},
			{
				dataField : "out_servcie_amt",
				positionField : "out_servcie_amt",
				operation : "SUM",
				formatString : "#,##0",
				style : "aui-right aui-footer"
			},
			{
				dataField : "service_account_amt",
				positionField : "service_account_amt",
				operation : "SUM",
				formatString : "#,##0",
				style : "aui-right aui-footer"
			},
			{
				dataField : "org_part_amt",
				positionField : "org_part_amt",
				operation : "SUM",
				formatString : "#,##0",
				style : "aui-right aui-footer"
			},
			{
				dataField : "used_amt",
				positionField : "used_amt",
				operation : "SUM",
				formatString : "#,##0",
				style : "aui-right aui-footer"
			},
			{
				dataField : "tot_amt",
				positionField : "tot_amt",
				operation : "SUM",
				formatString : "#,##0",
				style : "aui-right aui-footer"
			},
			{
				dataField : "month_per",
				positionField : "month_per",
				formatString : "#,##0.00",
				postfix : "%",
				style: "aui-right aui-footer",
				expFunction : function(columnValues) {
					var gridData = AUIGrid.getOrgGridData(auiGridTop);
					var totAmt = 0;
					var preTotAmt = 0;
					var monthPer = 0;
					
					for (var i = 0; i < gridData.length; i++) {
						totAmt += gridData[i].tot_amt;
						preTotAmt += gridData[i].pre_tot_amt;
					}

					monthPer = (totAmt - preTotAmt) / preTotAmt * 100;
					
					return monthPer;
				}
			}
		];
		
		// 실제로 #grid_wrap에 그리드 생성
		auiGridTop = AUIGrid.create("#auiGridTop", columnLayout, gridPros);
		// Footer setting
		AUIGrid.setFooter(auiGridTop, footerColumnLayout);
		
		// 그리드 갱신
		AUIGrid.setGridData(auiGridTop, ${topList});
		$("#auiGrid").resize();
	}
	
	// 부품목록 그리드
	function createAUIGridBottom() {
		var gridPros = {
			editable : false,
			rowIdField : "_$uid", 
			showRowNumColumn : false,	
			showFooter: true,
			footerPosition : "top"
		};
		var columnLayout = [
			{
				headerText : "구분",
				dataField : "amt_month",
				width : "100"
			},
			{
				headerText : "유상 정비 수익",
				dataField : "cost_profit_amt",
				style : "aui-right",
				dataType : "numeric",
				formatString : "#,##0",
				width : "10%",
				labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
					if (value == "0" || value == ""  || value == null) {
						return "";
					} else {
						return $M.setComma(value);
					}
				}
			},
			{
				headerText : "무상 정비 수익",
				dataField : "free_profit_amt",
				style : "aui-right",
				dataType : "numeric",
				formatString : "#,##0",
				width : "10%",
				labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
					if (value == "0" || value == ""  || value == null) {
						return "";
					} else {
						return $M.setComma(value);
					}
				}
			},
			{
				headerText : "부품 판매 수익",
				dataField : "part_profit_amt",
				style : "aui-right",
				dataType : "numeric",
				formatString : "#,##0",
				width : "10%",
				labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
					if (value == "0" || value == ""  || value == null) {
						return "";
					} else {
						return $M.setComma(value);
					}
				}
			},
			{
				headerText : "렌탈 운영 수익",
				dataField : "rental_profit_amt",
				style : "aui-right",
				dataType : "numeric",
				formatString : "#,##0",
				width : "10%",
				labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
					if (value == "0" || value == ""  || value == null) {
						return "";
					} else {
						return $M.setComma(value);
					}
				}
			},
			{
				headerText : "출하지원 20",
				dataField : "out_servcie_amt",
				style : "aui-right",
				dataType : "numeric",
				formatString : "#,##0",
				width : "10%",
				labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
					if (value == "0" || value == ""  || value == null) {
						return "";
					} else {
						return $M.setComma(value);
					}
				}
			},
			{
				headerText : "신차판매 70",
				dataField : "service_account_amt",
				style : "aui-right",
				dataType : "numeric",
				formatString : "#,##0",
				width : "10%",
				labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
					if (value == "0" || value == ""  || value == null) {
						return "";
					} else {
						return $M.setComma(value);
					}
				}
			},
			{
				headerText : "부품부서",
				dataField : "org_part_profit_amt",
				style : "aui-right",
				dataType : "numeric",
				formatString : "#,##0",
				width : "10%",
				labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
					if (value == "0" || value == ""  || value == null) {
						return "";
					} else {
						return $M.setComma(value);
					}
				}
			},
			{
				headerText : "중고손익",
				dataField : "used_amt",
				style : "aui-right",
				dataType : "numeric",
				formatString : "#,##0",
				width : "10%",
				labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
					if (value == "0" || value == ""  || value == null) {
						return "";
					} else {
						return $M.setComma(value);
					}
				}
			},
			{
				headerText : "월별 최종 수익",
				dataField : "tot_profit_amt",
				style : "aui-right",
				dataType : "numeric",
				formatString : "#,##0",
				width : "10%",
				labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
					if (value == "0" || value == ""  || value == null) {
						return "";
					} else {
						return $M.setComma(value);
					}
				}
			},
			{
				headerText : "전년도 월별 최종 수익",
				dataField : "pre_tot_profit_amt",
				style : "aui-right",
				dataType : "numeric",
				formatString : "#,##0",
				width : "10%",
				labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
					if (value == "0" || value == ""  || value == null) {
						return "";
					} else {
						return $M.setComma(value);
					}
				},
				visible : false
			},
			{
				headerText : "과년대비 성장율",
				dataField : "month_per",
				style : "aui-right",
				dataType : "numeric",
				formatString : "#,##0",
				labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
					if (value == "0" || value == ""  || value == null) {
						return "";
					} else {
						return value + "%";
					}
				}
			}
		];

		var footerColumnLayout = [
			{
				labelText : "합계",
				positionField : "amt_month",
				style : "aui-center aui-fotter"
			},
			{
				dataField : "cost_profit_amt",
				positionField : "cost_profit_amt",
				operation : "SUM",
				formatString : "#,##0",
				style : "aui-right aui-footer"
			},
			{
				dataField : "free_profit_amt",
				positionField : "free_profit_amt",
				operation : "SUM",
				formatString : "#,##0",
				style : "aui-right aui-footer"
			},
			{
				dataField : "part_profit_amt",
				positionField : "part_profit_amt",
				operation : "SUM",
				formatString : "#,##0",
				style : "aui-right aui-footer"
			},
			{
				dataField : "rental_profit_amt",
				positionField : "rental_profit_amt",
				operation : "SUM",
				formatString : "#,##0",
				style : "aui-right aui-footer"
			},
			{
				dataField : "out_servcie_amt",
				positionField : "out_servcie_amt",
				operation : "SUM",
				formatString : "#,##0",
				style : "aui-right aui-footer"
			},
			{
				dataField : "service_account_amt",
				positionField : "service_account_amt",
				operation : "SUM",
				formatString : "#,##0",
				style : "aui-right aui-footer"
			},
			{
				dataField : "org_part_profit_amt",
				positionField : "org_part_profit_amt",
				operation : "SUM",
				formatString : "#,##0",
				style : "aui-right aui-footer"
			},
			{
				dataField : "used_amt",
				positionField : "used_amt",
				operation : "SUM",
				formatString : "#,##0",
				style : "aui-right aui-footer"
			},
			{
				dataField : "tot_profit_amt",
				positionField : "tot_profit_amt",
				operation : "SUM",
				formatString : "#,##0",
				style : "aui-right aui-footer"
			},
			{
				dataField : "month_per",
				positionField : "month_per",
				formatString : "#,##0.00",
				postfix : "%",
				style: "aui-right aui-footer",
				expFunction : function(columnValues) {
					var gridData = AUIGrid.getOrgGridData(auiGridBottom);
					var totProfitAmt = 0;
					var preTotProfitAmt = 0;
					var monthPer = 0;
					
					for (var i = 0; i < gridData.length; i++) {
						totProfitAmt += gridData[i].tot_profit_amt;
						preTotProfitAmt += gridData[i].pre_tot_profit_amt;
					}

					monthPer = (totProfitAmt - preTotProfitAmt) / preTotProfitAmt * 100;
					
					return monthPer;
				}
			}
		];
		
		// 실제로 #grid_wrap에 그리드 생성
		auiGridBottom = AUIGrid.create("#auiGridBottom", columnLayout, gridPros);
		// Footer setting
		AUIGrid.setFooter(auiGridBottom, footerColumnLayout);
		
		// 그리드 갱신
		AUIGrid.setGridData(auiGridBottom, ${bomList});
		$("#auiGrid").resize();
	}
	
	</script>
</head>
<body class="bg-white class">
	<form id="main_form" name="main_form">
		<!-- 팝업 -->
		<div class="popup-wrap width-100per">
			<!-- 타이틀영역 -->
			<div class="main-title">
				<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp" />
			</div>
			<!-- /타이틀영역 -->
			<div class="content-wrap">
				<!-- 폼테이블 -->
				<div>
					<div class="title-wrap">
						<h4>월별 매출 집계</h4>
						<div class="btn-group">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R" /></jsp:include>
							</div>
						</div>
					</div>
					<div id="auiGridTop" style="margin-top: 5px; height: 345px;"></div>
				</div>
				<!-- /폼테이블-->
				<!-- 폼테이블2 -->
				<div>
					<div class="title-wrap mt10">
						<h4>월별 수익 집계</h4>
						<div class="btn-group">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R" /></jsp:include>
							</div>
						</div>
					</div>
					<div id="auiGridBottom" style="margin-top: 5px; height: 345px;"></div>
				</div>
				<!-- /폼테이블2 -->
				<div class="btn-group mt10">
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R" /></jsp:include>
					</div>
				</div>
			</div>
		</div>
		<!-- /팝업 -->
	</form>
</body>
</html>