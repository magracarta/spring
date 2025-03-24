<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 서비스관리 > 신)서비스업무평가-센터 > 매출현황 > null
-- 작성자 : 황빛찬
-- 최초 작성일 : 2023-12-01 15:48:00
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>

	<style type="text/css">

		/* 커스텀 행 스타일 ( 세로선 ) */
		.my-column-style {
			border-right: 1px solid #000000 !important;
		}

		/* 커스텀 행 스타일 ( 세로선 ) */
		.my-column-style_2 {
			border-right: 1px solid #000000 !important;
			text-align: right;
		}

	</style>

	<script type="text/javascript">

		var auiGrid;
		var auiGridB;
		var numberFormat = "thousand";
		var monCnt = 0;

		// 지출(천원)
		var footerOutAmt = 0; // 1년간 지출
		var footerAvgAmt = 0; // 과1년 월 평균 지출
		var footerYearAmt = 0; // 평균지출누계

		// 월매출(천원)
		var footerTotAmt = 0; // 매출누계
		var footerCostAmt = 0; // 유상정비매출
		var footerFreeAmt = 0; // 무상정비지출
		var footerWarrantyAmt = 0; // 워렌티비용
		var footerFreeOutSumAmt = 0; // 출하+서비스비용
		var footerPartAmt = 0; // 부품판매매출
		var footerRentalRentAmt = 0; // 렌탈매출
		var footerServiceAccountAmt_1 = 0; // 신차판매
		var footerMachineUsedProfitAmt_1 = 0; // 중고손익

		// 월수익(천원)
		var footerTotProfitAmt = 0; // 수익누계
		var footerCostProfitAmt = 0; // 유상정비수익
		var footerFreeTotalAmt = 0; // 무상종합
		var footerPartProfitAmt = 0; // 부품판매수익
		var footerRentalProfitAmt = 0; // 렌탈수익
		var footerServiceAccountAmt_2 = 0; // 신차판매
		var footerMachineUsedProfitAmt_2 = 0; // 중고손익

		var footerProfitTotalAmt = 0; // 수익율 > 순수이익
		var footerProfitTotalAmtPersentage = 0; // 수익율 > 이익율
		var footerPreProfitTotalMargin = 0; // 전월

		var footerMboSaleAmt = 0; // MBO 매출
		var footerMboSaleAmtPersentage = 0; // MBO 매출 달성률
		var footerMboProfitAmt = 0; // MBO 수익
		var footerMboProfitAmtPersentage = 0; // MBO 수익 달성률

		// 작년대비 푸터
		var year_amt_pre_diff_persentage = 0; // 평균지출누계 전년대비
		var tot_amt_diff = 0; // 매출누계 전년대비
		var cost_amt_diff = 0; // 유상정비매출 전년대비
		var free_amt_diff = 0; // 무상정비지출 전년대비
		var free_warranty_amt_diff = 0; // 워렌티비용 전년대비
		var free_out_amt_diff = 0; // 출하+서비스비용 전년대비
		var part_amt_diff = 0; // 부품 판매 매출 전년대비
		var rental_rent_amt_diff = 0; // 렌탈매출 전년대비
		var service_account_amt_diff = 0; // 신차판매 전년대비
		var machine_used_profit_amt_diff = 0; // 중고손익 전년대비

		var tot_profit_amt_diff = 0; // 수익누계 전년대비
		var cost_profit_amt_diff = 0; // 유상정비수익 전년대비
		var free_total_amt_diff = 0; // 무상종합 전년대비
		var part_profit_amt_diff = 0; // 부품판매수익 전년대비
		var rental_profit_amt_diff = 0; // 렌탈수익 전년대비
		var service_account_amt_diff = 0; // 신차판매 전년대비
		var machine_used_profit_amt_diff = 0; // 중고손익 전년대비

		$(document).ready(function () {
			createAUIGrid();
			createAUIGridB();

			fnInit();
		});

		function fnInit() {
			fnUpdateParentStartYear();
			fnUpdateParentStartMon();
			fnUpdateParentEndYear();
			fnUpdateParentEndMon();

			goSearch();
		}

		function fnUpdateParentStartYear() {
			var value = $M.getValue("s_start_year");
			$('#s_start_year', window.parent.document).val(value);
		}

		function fnUpdateParentStartMon() {
			var value = $M.getValue("s_start_mon");
			$('#s_start_mon', window.parent.document).val(value);
		}

		function fnUpdateParentEndYear() {
			var value = $M.getValue("s_end_year");
			$('#s_end_year', window.parent.document).val(value);
		}

		function fnUpdateParentEndMon() {
			var value = $M.getValue("s_end_mon");
			$('#s_end_mon', window.parent.document).val(value);
		}

		function createAUIGrid() {
			var gridPros = {
				rowIdField: "_$uid",
				showFooter: true,
				footerPosition : "top",
				footerRowCount : 2,
				headerHeight : 60,
				showRowNumColumn: false,
				editable: false,
				fixedColumnCount: 1
			};

			var columnLayout = [
				{
					headerText: "센터",
					dataField: "org_name",
					width : "80",
					minwidth : "90",
					style : "my-column-style",
					headerStyle : "my-column-style",
				},
				{
					headerText: "센터코드",
					dataField: "org_code",
					visible: false
				},
				{
					headerText: "지출(천원)",
					headerStyle : "my-column-style",
					children: [
						{
							headerText: "1년간지출",
							dataField: "out_amt",
							dataType: "numeric",
							formatString: "#,##0",
							width : "90",
							minWidth : "40",
							style: "aui-right",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								if (value == "0" || value == "0.0" || value == ""  || value == null) {
									return "";
								} else {
									if (numberFormat == "all") {
										return $M.setComma(value);
									} else {
										return $M.setComma(Math.floor($M.toNum(value)/1000));
									}
								}
							}
						},
						{
							headerText: "과1년<br>월평균<br>지출",
							dataField: "avg_amt",
							dataType: "numeric",
							formatString: "#,##0",
							width : "90",
							minWidth : "40",
							style: "aui-right",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								if (value == "0" || value == "0.0" || value == ""  || value == null) {
									return "";
								} else {
									if (numberFormat == "all") {
										return $M.setComma(value);
									} else {
										return $M.setComma(Math.floor($M.toNum(value)/1000));
									}
								}
							}
						},
						{
							headerText: "평균지출<br>누계",
							dataField: "year_amt",
							dataType: "numeric",
							formatString: "#,##0",
							width : "90",
							minWidth : "40",
							style: "aui-right",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								if (value == "0" || value == "0.0" || value == ""  || value == null) {
									return "";
								} else {
									if (numberFormat == "all") {
										return $M.setComma(value);
									} else {
										return $M.setComma(Math.floor($M.toNum(value)/1000));
									}
								}
							}
						},
						{
							headerText: "전년대비",
							dataField: "pre_year_amt_persentage",
							dataType: "numeric",
							formatString: "#,##0",
							width : "90",
							minWidth : "40",
							headerStyle : "my-column-style",
							// style: "aui-center",
							style : "my-column-style",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								if (value == "0" || value == ""  || value == null || isNaN(value)) {
									return "";
								} else {
									return value + "%";
								}
							}
						},
					]
				},
				{
					headerText: "월매출(천원)",
					headerStyle : "my-column-style",
					children: [
						{
							headerText: "매출누계",
							dataField: "tot_amt",
							dataType: "numeric",
							formatString: "#,##0",
							width : "90",
							minWidth : "40",
							style: "aui-right",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								if (value == "0" || value == "0.0" || value == ""  || value == null) {
									return "";
								} else {
									if (numberFormat == "all") {
										return $M.setComma(value);
									} else {
										return $M.setComma(Math.floor($M.toNum(value)/1000));
									}
								}
							}
						},
						{
							headerText: "전년대비",
							dataField: "pre_tot_amt_persentage",
							dataType: "numeric",
							formatString: "#,##0",
							width : "90",
							minWidth : "40",
							style: "aui-center",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								if (value == "0" || value == ""  || value == null || isNaN(value)) {
									return "";
								} else {
									return value + "%";
								}
							}
						},
						{
							headerText: "유상정비<br>매출",
							dataField: "cost_amt",
							dataType: "numeric",
							formatString: "#,##0",
							width : "90",
							minWidth : "40",
							style: "aui-right",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								if (value == "0" || value == "0.0" || value == ""  || value == null) {
									return "";
								} else {
									if (numberFormat == "all") {
										return $M.setComma(value);
									} else {
										return $M.setComma(Math.floor($M.toNum(value)/1000));
									}
								}
							}
						},
						{
							headerText: "무상정비<br>지출",
							dataField: "free_amt",
							dataType: "numeric",
							formatString: "#,##0",
							width : "90",
							minWidth : "40",
							style: "aui-right",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								if (value == "0" || value == "0.0" || value == ""  || value == null) {
									return "";
								} else {
									if (numberFormat == "all") {
										return $M.setComma(value);
									} else {
										return $M.setComma(Math.floor($M.toNum(value)/1000));
									}
								}
							}
						},
						{
							headerText: "워렌티비용",
							dataField: "warranty_amt",
							dataType: "numeric",
							formatString: "#,##0",
							width : "90",
							minWidth : "40",
							style: "aui-right",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								if (value == "0" || value == "0.0" || value == ""  || value == null) {
									return "";
								} else {
									if (numberFormat == "all") {
										return $M.setComma(value);
									} else {
										return $M.setComma(Math.floor($M.toNum(value)/1000));
									}
								}
							}
						},
						{
							headerText: "출하+서비스<br>비용",
							dataField: "free_out_sum_amt",
							dataType: "numeric",
							formatString: "#,##0",
							width : "90",
							minWidth : "40",
							style: "aui-right",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								if (value == "0" || value == "0.0" || value == ""  || value == null) {
									return "";
								} else {
									if (numberFormat == "all") {
										return $M.setComma(value);
									} else {
										return $M.setComma(Math.floor($M.toNum(value)/1000));
									}
								}
							}
						},
						{
							headerText: "부품판매<br>매출",
							dataField: "part_amt",
							dataType: "numeric",
							formatString: "#,##0",
							width : "90",
							minWidth : "40",
							style: "aui-right",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								if (value == "0" || value == "0.0" || value == ""  || value == null) {
									return "";
								} else {
									if (numberFormat == "all") {
										return $M.setComma(value);
									} else {
										return $M.setComma(Math.floor($M.toNum(value)/1000));
									}
								}
							}
						},
						{
							headerText: "렌탈매출",
							dataField: "rental_rent_amt",
							dataType: "numeric",
							formatString: "#,##0",
							width : "90",
							minWidth : "40",
							style: "aui-right",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								if (value == "0" || value == "0.0" || value == ""  || value == null) {
									return "";
								} else {
									if (numberFormat == "all") {
										return $M.setComma(value);
									} else {
										return $M.setComma(Math.floor($M.toNum(value)/1000));
									}
								}
							}
						},
						{
							headerText: "신차판매",
							dataField: "service_account_amt_1",
							dataType: "numeric",
							formatString: "#,##0",
							width : "90",
							minWidth : "40",
							style: "aui-right",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								if (value == "0" || value == "0.0" || value == ""  || value == null) {
									return "";
								} else {
									if (numberFormat == "all") {
										return $M.setComma(value);
									} else {
										return $M.setComma(Math.floor($M.toNum(value)/1000));
									}
								}
							}
						},
						{
							headerText: "중고손익",
							dataField: "machine_used_profit_amt_1",
							dataType: "numeric",
							formatString: "#,##0",
							width : "90",
							minWidth : "40",
							headerStyle : "my-column-style",
							// style: "aui-right",
							style : "my-column-style",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								if (value == "0" || value == "0.0" || value == ""  || value == null) {
									return "";
								} else {
									if (numberFormat == "all") {
										return $M.setComma(value);
									} else {
										return $M.setComma(Math.floor($M.toNum(value)/1000));
									}
								}
							}
						},
					]
				},
				{
					headerText: "월수익(천원)",
					headerStyle : "my-column-style",
					children: [
						{
							headerText: "수익누계",
							dataField: "tot_profit",
							dataType: "numeric",
							formatString: "#,##0",
							width : "90",
							minWidth : "40",
							style: "aui-right",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								if (value == "0" || value == "0.0" || value == ""  || value == null) {
									return "";
								} else {
									if (numberFormat == "all") {
										return $M.setComma(value);
									} else {
										return $M.setComma(Math.floor($M.toNum(value)/1000));
									}
								}
							}
						},
						{
							headerText: "전년대비",
							dataField: "pre_tot_profit_persentage",
							dataType: "numeric",
							formatString: "#,##0",
							width : "90",
							minWidth : "40",
							style: "aui-center",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								if (value == "0" || value == ""  || value == null || isNaN(value)) {
									return "";
								} else {
									return value + "%";
								}
							}
						},
						{
							headerText: "유상정비<br>수익",
							dataField: "cost_profit_amt",
							dataType: "numeric",
							formatString: "#,##0",
							width : "90",
							minWidth : "40",
							style: "aui-right",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								if (value == "0" || value == "0.0" || value == ""  || value == null) {
									return "";
								} else {
									if (numberFormat == "all") {
										return $M.setComma(value);
									} else {
										return $M.setComma(Math.floor($M.toNum(value)/1000));
									}
								}
							}
						},
						{
							headerText: "무상종합",
							dataField: "free_total_amt",
							dataType: "numeric",
							formatString: "#,##0",
							width : "90",
							minWidth : "40",
							style: "aui-right",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								if (value == "0" || value == "0.0" || value == ""  || value == null) {
									return "";
								} else {
									if (numberFormat == "all") {
										return $M.setComma(value);
									} else {
										return $M.setComma(Math.floor($M.toNum(value)/1000));
									}
								}
							}
						},
						{
							headerText: "부품판매<br>수익",
							dataField: "part_profit_amt",
							dataType: "numeric",
							formatString: "#,##0",
							width : "90",
							minWidth : "40",
							style: "aui-right",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								if (value == "0" || value == "0.0" || value == ""  || value == null) {
									return "";
								} else {
									if (numberFormat == "all") {
										return $M.setComma(value);
									} else {
										return $M.setComma(Math.floor($M.toNum(value)/1000));
									}
								}
							}
						},
						{
							headerText: "렌탈수익",
							dataField: "rental_profit_amt",
							dataType: "numeric",
							formatString: "#,##0",
							width : "90",
							minWidth : "40",
							style: "aui-right",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								if (value == "0" || value == "0.0" || value == ""  || value == null) {
									return "";
								} else {
									if (numberFormat == "all") {
										return $M.setComma(value);
									} else {
										return $M.setComma(Math.floor($M.toNum(value)/1000));
									}
								}
							}
						},
						{
							headerText: "신차판매",
							dataField: "service_account_amt_2",
							dataType: "numeric",
							formatString: "#,##0",
							width : "90",
							minWidth : "40",
							style: "aui-right",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								if (value == "0" || value == "0.0" || value == ""  || value == null) {
									return "";
								} else {
									if (numberFormat == "all") {
										return $M.setComma(value);
									} else {
										return $M.setComma(Math.floor($M.toNum(value)/1000));
									}
								}
							}
						},
						{
							headerText: "중고손익",
							dataField: "machine_used_profit_amt_2",
							dataType: "numeric",
							formatString: "#,##0",
							width : "90",
							minWidth : "40",
							headerStyle : "my-column-style",
							// style: "aui-right",
							style : "my-column-style",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								if (value == "0" || value == "0.0" || value == ""  || value == null) {
									return "";
								} else {
									if (numberFormat == "all") {
										return $M.setComma(value);
									} else {
										return $M.setComma(Math.floor($M.toNum(value)/1000));
									}
								}
							}
						},
					]
				},
				{
					headerText: "수익율",
					headerStyle : "my-column-style",
					children: [
						{
							headerText: "순수이익",
							dataField: "profit_total_amt",
							dataType: "numeric",
							formatString: "#,##0",
							width : "90",
							minWidth : "40",
							style: "aui-right",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								if (value == "0" || value == "0.0" || value == ""  || value == null) {
									return "";
								} else {
									if (numberFormat == "all") {
										return $M.setComma(value);
									} else {
										return $M.setComma(Math.floor($M.toNum(value)/1000));
									}
								}
							}
						},
						{
							headerText: "이익율",
							dataField: "profit_total_margin",
							dataType: "numeric",
							formatString: "#,##0",
							width : "90",
							minWidth : "40",
							headerStyle : "my-column-style",
							// style: "aui-center",
							style : "my-column-style",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								if (value == "0" || value == ""  || value == null || isNaN(value)) {
									return "";
								} else {
									return value + "%";
								}
							}
						},
					]
				},
				{
					headerText: "전월",
					dataField: "pre_profit_total_margin",
					dataType: "numeric",
					formatString: "#,##0",
					width : "60",
					minWidth : "40",
					style: "aui-center",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						if (value == "0" || value == ""  || value == null || isNaN(value)) {
							return "";
						} else {
							return value + "%";
						}
					}
				},
				{
					headerText: "증감",
					dataField: "pre_profit_diff",
					dataType: "numeric",
					formatString: "#,##0",
					width : "60",
					minWidth : "40",
					headerStyle : "my-column-style",
					// style: "aui-center",
					style : "my-column-style",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						if (value == "0" || value == ""  || value == null || isNaN(value)) {
							return "";
						} else {
							return value + "%";
						}
					}
				},
				{
					headerText: "2023 MBO 매출(천원)",
					headerStyle : "my-column-style",
					children: [
						{
							headerText: "매출누계",
							dataField: "mbo_sale_amt",
							dataType: "numeric",
							formatString: "#,##0",
							width : "150",
							minWidth : "40",
							// headerStyle : "my-column-style",
							style: "aui-right",
							// style : "my-column-style",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								if (value == "0" || value == "0.0" || value == ""  || value == null) {
									return "";
								} else {
									if (numberFormat == "all") {
										return $M.setComma(value);
									} else {
										return $M.setComma(Math.floor($M.toNum(value)/1000));
									}
								}
							}
						},
						{
							headerText: "달성률",
							dataField: "mbo_sale_amt_persentage",
							dataType: "numeric",
							formatString: "#,##0",
							width : "90",
							minWidth : "40",
							headerStyle : "my-column-style",
							style: "my-column-style",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								if (value == "0" || value == ""  || value == null || isNaN(value)) {
									return "";
								} else {
									return value + "%";
								}
							}
						},
					]
				},
				{
					headerText: "2023 MBO 수익(천원)",
					children: [
						{
							headerText: "수익누계",
							dataField: "mbo_profit_amt",
							dataType: "numeric",
							formatString: "#,##0",
							width : "150",
							minWidth : "40",
							style: "aui-right",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								if (value == "0" || value == "0.0" || value == ""  || value == null) {
									return "";
								} else {
									if (numberFormat == "all") {
										return $M.setComma(value);
									} else {
										return $M.setComma(Math.floor($M.toNum(value)/1000));
									}
								}
							}
						},
						{
							headerText: "달성률",
							dataField: "mbo_profit_amt_persentage",
							dataType: "numeric",
							formatString: "#,##0",
							width : "90",
							minWidth : "40",
							// headerStyle : "my-column-style",
							style: "aui-right",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								if (value == "0" || value == ""  || value == null || isNaN(value)) {
									return "";
								} else {
									return value + "%";
								}
							}
						},
					]
				}
			];

			// 푸터레이아웃
			var footerColumnLayout = [];
			footerColumnLayout[0] = [
				{
					labelText: "합계",
					positionField: "org_name",
					// style: "aui-center aui-footer",
					style : "my-column-style",
					headerStyle : "my-column-style",
				},
				{
					dataField: "out_amt",
					positionField: "out_amt",
					operation: "SUM",
					formatString: "#,##0",
					rowSpan : 2, // 셀 세로 2개 병합
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var value = footerOutAmt;

						if (value == "0" || value == "0.0" || value == ""  || value == null) {
							return "";
						} else {
							if (numberFormat == "all") {
								value =  $M.setComma(value);
							} else {
								value =  $M.setComma(Math.floor($M.toNum(value)/1000));
							}
						}

						return $M.toNum(value);
					}
				},
				{
					dataField: "avg_amt",
					positionField: "avg_amt",
					operation: "SUM",
					rowSpan : 2, // 셀 세로 2개 병합
					formatString: "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var value = footerAvgAmt;

						if (value == "0" || value == "0.0" || value == ""  || value == null) {
							return "";
						} else {
							if (numberFormat == "all") {
								value =  $M.setComma(value);
							} else {
								value =  $M.setComma(Math.floor($M.toNum(value)/1000));
							}
						}

						return $M.toNum(value);
					}
				},
				// 평균지출 누계
				{
					dataField: "year_amt",
					positionField: "year_amt",
					operation: "SUM",
					formatString: "#,##0",
					colSpan: 2,
					// style: "aui-right aui-footer",
					style : "my-column-style_2",
					headerStyle : "my-column-style_2",
					expFunction : function(columnValues) {
						var value = footerYearAmt;

						if (value == "0" || value == "0.0" || value == ""  || value == null) {
							return "";
						} else {
							if (numberFormat == "all") {
								value =  $M.setComma(value);
							} else {
								value =  $M.setComma(Math.floor($M.toNum(value)/1000));
							}
						}

						return $M.toNum(value);
					}
				},
				// 전년대비
				// {
				// 	dataField: "",
				// 	positionField: "",
				// 	operation: "SUM",
				// 	formatString: "#,##0",
				// 	// style: "aui-right aui-footer",
				// 	style : "my-column-style",
				// 	headerStyle : "my-column-style",
				// },
				// 매출 누계
				{
					dataField: "tot_amt",
					positionField: "tot_amt",
					operation: "SUM",
					colSpan: 2,
					formatString: "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGrid);
						var value = footerTotAmt;
						var value1 = 0;

						for (var i = 0; i < gridData.length; i++) {
							if (gridData[i].org_code == '6000') {
								value1 += $M.toNum(gridData[i].tot_amt);
							}
						}

						value = value + value1

						if (value == "0" || value == "0.0" || value == ""  || value == null) {
							return "";
						} else {
							if (numberFormat == "all") {
								value =  $M.setComma(value);
							} else {
								value =  $M.setComma(Math.floor($M.toNum(value)/1000));
							}
						}

						return $M.toNum(value);
					}
				},
				// 전년대비
				// {
				// 	dataField: "",
				// 	positionField: "",
				// 	operation: "SUM",
				// 	formatString: "#,##0.0####",
				// 	style: "aui-right aui-footer",
				// },
				{
					dataField: "cost_amt",
					positionField: "cost_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var value = footerCostAmt;

						if (value == "0" || value == "0.0" || value == ""  || value == null) {
							return "";
						} else {
							if (numberFormat == "all") {
								value =  $M.setComma(value);
							} else {
								value =  $M.setComma(Math.floor($M.toNum(value)/1000));
							}
						}

						return $M.toNum(value);
					}
				},
				{
					dataField: "free_amt",
					positionField: "free_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var value = footerFreeAmt;

						if (value == "0" || value == "0.0" || value == ""  || value == null) {
							return "";
						} else {
							if (numberFormat == "all") {
								value =  $M.setComma(value);
							} else {
								value =  $M.setComma(Math.floor($M.toNum(value)/1000));
							}
						}

						return $M.toNum(value);
					}
				},
				// 워렌티비용
				{
					dataField: "warranty_amt",
					positionField: "warranty_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var value = footerWarrantyAmt;

						if (value == "0" || value == "0.0" || value == ""  || value == null) {
							return "";
						} else {
							if (numberFormat == "all") {
								value =  $M.setComma(value);
							} else {
								value =  $M.setComma(Math.floor($M.toNum(value)/1000));
							}
						}

						return $M.toNum(value);
					}
				},
				{
					dataField: "free_out_sum_amt",
					positionField: "free_out_sum_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var value = footerFreeOutSumAmt;

						if (value == "0" || value == "0.0" || value == ""  || value == null) {
							return "";
						} else {
							if (numberFormat == "all") {
								value =  $M.setComma(value);
							} else {
								value =  $M.setComma(Math.floor($M.toNum(value)/1000));
							}
						}

						return $M.toNum(value);
					}
				},
				{
					dataField: "part_amt",
					positionField: "part_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var value = footerPartAmt;

						if (value == "0" || value == "0.0" || value == ""  || value == null) {
							return "";
						} else {
							if (numberFormat == "all") {
								value =  $M.setComma(value);
							} else {
								value =  $M.setComma(Math.floor($M.toNum(value)/1000));
							}
						}

						return $M.toNum(value);
					}
				},
				{
					dataField: "rental_rent_amt",
					positionField: "rental_rent_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var value = footerRentalRentAmt;

						if (value == "0" || value == "0.0" || value == ""  || value == null) {
							return "";
						} else {
							if (numberFormat == "all") {
								value =  $M.setComma(value);
							} else {
								value =  $M.setComma(Math.floor($M.toNum(value)/1000));
							}
						}

						return $M.toNum(value);
					}
				},
				{
					dataField: "service_account_amt_1",
					positionField: "service_account_amt_1",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var value = footerServiceAccountAmt_1;

						if (value == "0" || value == "0.0" || value == ""  || value == null) {
							return "";
						} else {
							if (numberFormat == "all") {
								value =  $M.setComma(value);
							} else {
								value =  $M.setComma(Math.floor($M.toNum(value)/1000));
							}
						}

						return $M.toNum(value);
					}
				},
				{
					dataField: "machine_used_profit_amt_1",
					positionField: "machine_used_profit_amt_1",
					operation: "SUM",
					formatString: "#,##0",
					// style: "aui-right aui-footer",
					style : "my-column-style_2",
					headerStyle : "my-column-style_2",
					expFunction : function(columnValues) {
						var value = footerMachineUsedProfitAmt_1;

						if (value == "0" || value == "0.0" || value == ""  || value == null) {
							return "";
						} else {
							if (numberFormat == "all") {
								value =  $M.setComma(value);
							} else {
								value =  $M.setComma(Math.floor($M.toNum(value)/1000));
							}
						}

						return $M.toNum(value);
					}
				},
				// 수익 누계
				{
					dataField: "tot_profit",
					positionField: "tot_profit",
					operation: "SUM",
					colSpan: 2,
					formatString: "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGrid);
						var value = footerTotProfitAmt;
						var value1 = 0;

						for (var i = 0; i < gridData.length; i++) {
							if (gridData[i].org_code == '6000') {
								value1 += $M.toNum(gridData[i].tot_profit);
							}
						}

						value = value + value1;

						if (value == "0" || value == "0.0" || value == ""  || value == null) {
							return "";
						} else {
							if (numberFormat == "all") {
								value =  $M.setComma(value);
							} else {
								value =  $M.setComma(Math.floor($M.toNum(value)/1000));
							}
						}

						return $M.toNum(value);
					}
				},
				// 전년대비
				// {
				// 	dataField: "",
				// 	positionField: "pre_year_amt_persentage",
				// 	operation: "SUM",
				// 	formatString: "#,##0.0####",
				// 	// style: "aui-right aui-footer",
				// 	style : "my-column-style",
				// 	headerStyle : "my-column-style",
				// },
				{
					dataField: "cost_profit_amt",
					positionField: "cost_profit_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var value = footerCostProfitAmt;

						if (value == "0" || value == "0.0" || value == ""  || value == null) {
							return "";
						} else {
							if (numberFormat == "all") {
								value =  $M.setComma(value);
							} else {
								value =  $M.setComma(Math.floor($M.toNum(value)/1000));
							}
						}

						return $M.toNum(value);
					}
				},
				// 무상 종합
				{
					dataField: "free_total_amt",
					positionField: "free_total_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var value = footerFreeTotalAmt;

						if (value == "0" || value == "0.0" || value == ""  || value == null) {
							return "";
						} else {
							if (numberFormat == "all") {
								value =  $M.setComma(value);
							} else {
								value =  $M.setComma(Math.floor($M.toNum(value)/1000));
							}
						}

						return $M.toNum(value);
					}
				},
				{
					dataField: "part_profit_amt",
					positionField: "part_profit_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var value = footerPartProfitAmt;

						if (value == "0" || value == "0.0" || value == ""  || value == null) {
							return "";
						} else {
							if (numberFormat == "all") {
								value =  $M.setComma(value);
							} else {
								value =  $M.setComma(Math.floor($M.toNum(value)/1000));
							}
						}

						return $M.toNum(value);
					}
				},
				{
					dataField: "rental_profit_amt",
					positionField: "rental_profit_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var value = footerRentalProfitAmt;

						if (value == "0" || value == "0.0" || value == ""  || value == null) {
							return "";
						} else {
							if (numberFormat == "all") {
								value =  $M.setComma(value);
							} else {
								value =  $M.setComma(Math.floor($M.toNum(value)/1000));
							}
						}

						return $M.toNum(value);
					}
				},
				{
					dataField: "service_account_amt_2",
					positionField: "service_account_amt_2",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var value = footerServiceAccountAmt_2;

						if (value == "0" || value == "0.0" || value == ""  || value == null) {
							return "";
						} else {
							if (numberFormat == "all") {
								value =  $M.setComma(value);
							} else {
								value =  $M.setComma(Math.floor($M.toNum(value)/1000));
							}
						}

						return $M.toNum(value);
					}
				},
				{
					dataField: "machine_used_profit_amt_2",
					positionField: "machine_used_profit_amt_2",
					operation: "SUM",
					formatString: "#,##0",
					// style: "aui-right aui-footer",
					style : "my-column-style_2",
					headerStyle : "my-column-style_2",
					expFunction : function(columnValues) {
						var value = footerMachineUsedProfitAmt_2;

						if (value == "0" || value == "0.0" || value == ""  || value == null) {
							return "";
						} else {
							if (numberFormat == "all") {
								value =  $M.setComma(value);
							} else {
								value =  $M.setComma(Math.floor($M.toNum(value)/1000));
							}
						}

						return $M.toNum(value);
					}
				},
				// 순수 이익
				{
					dataField: "profit_total_amt",
					positionField: "profit_total_amt",
					operation: "SUM",
					rowSpan : 2, // 셀 세로 2개 병합
					formatString: "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var value = footerProfitTotalAmt;

						if (value == "0" || value == "0.0" || value == ""  || value == null) {
							return "";
						} else {
							if (numberFormat == "all") {
								value =  $M.setComma(value);
							} else {
								value =  $M.setComma(Math.floor($M.toNum(value)/1000));
							}
						}

						return $M.toNum(value);
					}
				},
				// 이익율
				{
					dataField: "profit_total_margin",
					positionField: "profit_total_margin",
					// operation: "SUM",
					formatString: "#,##0",
					rowSpan : 2, // 셀 세로 2개 병합
					postfix: "%",
					// style: "aui-right aui-footer",
					style : "my-column-style",
					headerStyle : "my-column-style",
					expFunction : function(columnValues) {
						var value = footerProfitTotalAmtPersentage;
						return value;
					}
				},
				// 전월
				{
					dataField: "pre_profit_total_margin",
					positionField: "pre_profit_total_margin",
					rowSpan : 2, // 셀 세로 2개 병합
					operation: "SUM",
					postfix: "%",
					formatString: "#,##0",
					style: "aui-center aui-footer",
					expFunction : function(columnValues) {
						return footerPreProfitTotalMargin;
					}
				},
				// 증감
				{
					dataField: "pre_profit_diff",
					positionField: "pre_profit_diff",
					operation: "SUM",
					rowSpan : 2, // 셀 세로 2개 병합
					postfix: "%",
					formatString: "#,##0",
					// style: "aui-right aui-footer",
					style : "my-column-style",
					headerStyle : "my-column-style",
					expFunction : function(columnValues) {
						return footerPreProfitTotalMargin - footerProfitTotalAmtPersentage;
					}
				},
				// MBO 매출
				{
					dataField: "mbo_sale_amt",
					positionField: "mbo_sale_amt",
					operation: "SUM",
					rowSpan : 2, // 셀 세로 2개 병합
					formatString: "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var value = footerMboSaleAmt;

						if (value == "0" || value == "0.0" || value == ""  || value == null) {
							return "";
						} else {
							if (numberFormat == "all") {
								value =  $M.setComma(value);
							} else {
								value =  $M.setComma(Math.floor($M.toNum(value)/1000));
							}
						}

						return $M.toNum(value);
					}
				},
				{
					dataField: "mbo_sale_amt_persentage",
					positionField: "mbo_sale_amt_persentage",
					// operation: "SUM",
					formatString: "#,##0",
					rowSpan : 2, // 셀 세로 2개 병합
					postfix: "%",
					// style: "aui-right aui-footer",
					style : "my-column-style",
					headerStyle : "my-column-style",
					expFunction : function(columnValues) {
						var value = footerMboSaleAmtPersentage;
						return value;
					}
				},
				// MBO 수익
				{
					dataField: "mbo_profit_amt",
					positionField: "mbo_profit_amt",
					operation: "SUM",
					rowSpan : 2, // 셀 세로 2개 병합
					formatString: "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var value = footerMboProfitAmt;

						if (value == "0" || value == "0.0" || value == ""  || value == null) {
							return "";
						} else {
							if (numberFormat == "all") {
								value =  $M.setComma(value);
							} else {
								value =  $M.setComma(Math.floor($M.toNum(value)/1000));
							}
						}

						return $M.toNum(value);
					}
				},
				{
					dataField: "mbo_profit_amt_persentage",
					positionField: "mbo_profit_amt_persentage",
					// operation: "SUM",
					formatString: "#,##0",
					rowSpan : 2, // 셀 세로 2개 병합
					postfix: "%",
					// style: "aui-right aui-footer",
					style : "my-column-style",
					headerStyle : "my-column-style",
					expFunction : function(columnValues) {
						var value = footerMboProfitAmtPersentage;
						return value;
					}
				},
			];

			// 작년대비
			footerColumnLayout[1] = [
				{
					labelText: "작년대비",
					positionField: "org_name",
					// style: "aui-center aui-footer",
					style : "my-column-style",
					headerStyle : "my-column-style",
				},
				// {
				// 	dataField: "out_amt",
				// 	positionField: "out_amt",
				// 	operation: "SUM",
				// 	formatString: "#,##0",
				// 	style: "aui-right aui-footer",
				// },
				// {
				// 	dataField: "avg_amt",
				// 	positionField: "avg_amt",
				// 	operation: "SUM",
				// 	formatString: "#,##0",
				// 	style: "aui-right aui-footer",
				// },
				// 평균지출 누계
				{
					dataField: "pre_tot_amt_persentage",
					positionField: "year_amt",
					operation: "SUM",
					formatString: "#,##0",
					colSpan: 2,
					style : "my-column-style_2",
					// style: "aui-right aui-footer",
					headerStyle : "my-column-style_2",
					postfix: "%",
					expFunction : function(columnValues) {
						return year_amt_pre_diff_persentage;
					}
				},
				// 전년대비
				// {
				// 	dataField: "",
				// 	positionField: "",
				// 	operation: "SUM",
				// 	formatString: "#,##0",
				// 	// style: "aui-right aui-footer",
				// 	style : "my-column-style",
				// 	headerStyle : "my-column-style",
				// },
				// 매출 누계
				{
					dataField: "tot_amt",
					positionField: "tot_amt",
					operation: "SUM",
					colSpan: 2,
					formatString: "#,##0",
					style: "aui-right aui-footer",
					postfix: "%",
					expFunction : function(columnValues) {
						return tot_amt_diff;
					}
				},
				// 전년대비
				// {
				// 	dataField: "",
				// 	positionField: "",
				// 	operation: "SUM",
				// 	formatString: "#,##0.0####",
				// 	style: "aui-right aui-footer",
				// },
				{
					dataField: "cost_amt",
					positionField: "cost_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					postfix: "%",
					expFunction : function(columnValues) {
						return cost_amt_diff;
					}
				},
				{
					dataField: "free_amt",
					positionField: "free_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					postfix: "%",
					expFunction : function(columnValues) {
						return free_amt_diff;
					}
				},
				// 워렌티비용
				{
					dataField: "warranty_amt",
					positionField: "warranty_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					postfix: "%",
					expFunction : function(columnValues) {
						return free_warranty_amt_diff;
					}
				},
				{
					dataField: "free_out_sum_amt",
					positionField: "free_out_sum_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					postfix: "%",
					expFunction : function(columnValues) {
						return free_out_amt_diff;
					}
				},
				{
					dataField: "part_amt",
					positionField: "part_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					postfix: "%",
					expFunction : function(columnValues) {
						return part_amt_diff;
					}
				},
				{
					dataField: "rental_rent_amt",
					positionField: "rental_rent_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					postfix: "%",
					expFunction : function(columnValues) {
						return rental_rent_amt_diff;
					}
				},
				{
					dataField: "service_account_amt_1",
					positionField: "service_account_amt_1",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					postfix: "%",
					expFunction : function(columnValues) {
						return service_account_amt_diff;
					}
				},
				{
					dataField: "machine_used_profit_amt_1",
					positionField: "machine_used_profit_amt_1",
					operation: "SUM",
					formatString: "#,##0",
					// style: "aui-right aui-footer",
					style : "my-column-style_2",
					headerStyle : "my-column-style_2",
					postfix: "%",
					expFunction : function(columnValues) {
						return machine_used_profit_amt_diff;
					}
				},
				// 수익 누계
				{
					dataField: "tot_profit",
					positionField: "tot_profit",
					operation: "SUM",
					colSpan: 2,
					formatString: "#,##0",
					style: "aui-right aui-footer",
					postfix: "%",
					expFunction : function(columnValues) {
						return tot_profit_amt_diff;
					}
				},
				// 전년대비
				// {
				// 	dataField: "",
				// 	positionField: "pre_year_amt_persentage",
				// 	operation: "SUM",
				// 	formatString: "#,##0.0####",
				// 	// style: "aui-right aui-footer",
				// 	style : "my-column-style",
				// 	headerStyle : "my-column-style",
				// },
				{
					dataField: "cost_profit_amt",
					positionField: "cost_profit_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					postfix: "%",
					expFunction : function(columnValues) {
						return cost_profit_amt_diff;
					}
				},
				// 무상 종합
				{
					dataField: "free_total_amt",
					positionField: "free_total_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					postfix: "%",
					expFunction : function(columnValues) {
						return free_total_amt_diff;
					}
				},
				{
					dataField: "part_profit_amt",
					positionField: "part_profit_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					postfix: "%",
					expFunction : function(columnValues) {
						return part_profit_amt_diff;
					}
				},
				{
					dataField: "rental_profit_amt",
					positionField: "rental_profit_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					postfix: "%",
					expFunction : function(columnValues) {
						return rental_profit_amt_diff;
					}
				},
				{
					dataField: "service_account_amt_2",
					positionField: "service_account_amt_2",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					postfix: "%",
					expFunction : function(columnValues) {
						return service_account_amt_diff;
					}
				},
				{
					dataField: "machine_used_profit_amt_2",
					positionField: "machine_used_profit_amt_2",
					operation: "SUM",
					formatString: "#,##0",
					// style: "aui-right aui-footer",
					style : "my-column-style_2",
					headerStyle : "my-column-style_2",
					postfix: "%",
					expFunction : function(columnValues) {
						return machine_used_profit_amt_diff;
					}
				},
				// 순수 이익
				// {
				// 	dataField: "",
				// 	positionField: "",
				// 	operation: "SUM",
				// 	formatString: "#,##0",
				// 	style: "aui-right aui-footer",
				// },
				// 이익율
				// {
				// 	dataField: "",
				// 	positionField: "",
				// 	operation: "SUM",
				// 	formatString: "#,##0",
				// 	// style: "aui-right aui-footer",
				// 	style : "my-column-style",
				// 	headerStyle : "my-column-style",
				// },
				// 전월
				// {
				// 	dataField: "",
				// 	positionField: "",
				// 	operation: "SUM",
				// 	formatString: "#,##0",
				// 	style: "aui-right aui-footer",
				// },
				// // 증감
				// {
				// 	dataField: "",
				// 	positionField: "",
				// 	operation: "SUM",
				// 	formatString: "#,##0",
				// 	// style: "aui-right aui-footer",
				// 	style : "my-column-style",
				// 	headerStyle : "my-column-style",
				// },
				// MBO 매출
				// {
				// 	dataField: "mob_tot_amt",
				// 	positionField: "mob_tot_amt",
				// 	operation: "SUM",
				// 	formatString: "#,##0",
				// 	// style: "aui-right aui-footer",
				// 	style : "my-column-style_2",
				// 	headerStyle : "my-column-style_2",
				// },
				// // MBO 수익
				// {
				// 	dataField: "mbo_profit_amt",
				// 	positionField: "mbo_profit_amt",
				// 	operation: "SUM",
				// 	formatString: "#,##0",
				// 	style: "aui-right aui-footer",
				// },
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setFooter(auiGrid, footerColumnLayout);
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.resize(auiGrid);
		}


		// 매출현황 목록 조회
		function goSearch() {
			if ($M.validation(document.main_form) == false) {
				return;
			}

			var sStartYearMon = $M.getValue("s_start_year");
			var sStartMon = $M.getValue("s_start_mon")
			var sEndYearMon = $M.getValue("s_end_year");
			var sEndMon = $M.getValue("s_end_mon");

			if(sStartMon.length == 1) {
				sStartMon = "0" + sStartMon;
			}

			if(sEndMon.length == 1) {
				sEndMon = "0" + sEndMon;
			}

			sStartYearMon += sStartMon;
			sEndYearMon += sEndMon;

			if(sStartYearMon > sEndYearMon) {
				alert("시작년도가 종료년도보다 클 수 없습니다.");
				return;
			}

			var param = {
				"s_start_year_mon" : sStartYearMon,
				"s_end_year_mon" : sEndYearMon
			};

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: 'get'},
					function (result) {
						if (result.success) {
							console.log("result : ", result);

							monCnt = result.mon_cnt;

							var footerDataMap = result.footerDataMap;
							footerOutAmt = footerDataMap.sum_out_amt;
							footerAvgAmt = footerDataMap.sum_avg_amt;
							footerYearAmt = footerDataMap.sum_year_amt;
							footerTotAmt = footerDataMap.sum_tot_amt;
							footerCostAmt = footerDataMap.sum_cost_amt;
							footerFreeAmt = footerDataMap.sum_free_amt;
							footerWarrantyAmt = footerDataMap.tot_sum_warranty_amt;
							footerFreeOutSumAmt = footerDataMap.sum_free_out_sum_amt;
							footerPartAmt = footerDataMap.sum_part_amt;
							footerRentalRentAmt = footerDataMap.sum_rental_rent_amt;
							footerServiceAccountAmt_1 = footerDataMap.sum_service_account_amt_1;
							footerMachineUsedProfitAmt_1 = footerDataMap.sum_machine_used_profit_amt_1;
							footerTotProfitAmt = footerDataMap.sum_tot_profit_amt;
							footerCostProfitAmt = footerDataMap.sum_cost_profit_amt;
							footerFreeTotalAmt = footerDataMap.sum_free_total_amt;
							footerPartProfitAmt = footerDataMap.sum_part_profit_amt;
							footerRentalProfitAmt = footerDataMap.sum_rental_profit_amt;
							footerServiceAccountAmt_2 = footerDataMap.sum_service_account_amt_2;
							footerMachineUsedProfitAmt_2 = footerDataMap.sum_machine_used_profit_amt_2;
							footerProfitTotalAmt = footerDataMap.sum_profit_total_amt; // 수익율 > 순수이익
							footerProfitTotalAmtPersentage = footerDataMap.sum_profit_total_amt_persentage; // 수익율 > 이익율
							footerPreProfitTotalMargin = footerDataMap.sum_pre_profit_total_margin // 전월

							footerMboSaleAmt = footerDataMap.tot_mbo_sale_amt // MBO 매출누계
							footerMboSaleAmtPersentage = footerDataMap.mbo_sale_amt_persentage // MBO 매출 달성률
							footerMboProfitAmt = footerDataMap.tot_mbo_profit_amt // MBO 수익누계
							footerMboProfitAmtPersentage = footerDataMap.mbo_profit_amt_persentage // MBO 수익 달성률

							// 작년대비
							year_amt_pre_diff_persentage = footerDataMap.year_amt_pre_diff_persentage // 평균지출누계 전년대비
							tot_amt_diff = footerDataMap.tot_amt_diff // 매출누계 전년대비
							cost_amt_diff = footerDataMap.cost_amt_diff // 유상정비매출 전년대비
							free_amt_diff = footerDataMap.free_amt_diff // 무상정비지출 전년대비
							free_warranty_amt_diff = footerDataMap.free_warranty_amt_diff // 워렌티비용 전년대비
							free_out_amt_diff = footerDataMap.free_out_amt_diff // 출하+서비스비용 전년대비
							part_amt_diff = footerDataMap.part_amt_diff // 부품 판매 매출 전년대비
							rental_rent_amt_diff = footerDataMap.rental_rent_amt_diff // 렌탈매출 전년대비
							service_account_amt_diff = footerDataMap.service_account_amt_diff // 신차판매 전년대비
							machine_used_profit_amt_diff = footerDataMap.machine_used_profit_amt_diff // 중고손익 전년대비
							tot_profit_amt_diff = footerDataMap.tot_profit_amt_diff // 수익누계 전년대비
							cost_profit_amt_diff = footerDataMap.cost_profit_amt_diff // 유상정비수익 전년대비
							free_total_amt_diff = footerDataMap.free_total_amt_diff // 무상종합 전년대비
							part_profit_amt_diff = footerDataMap.part_profit_amt_diff // 부품판매수익 전년대비
							rental_profit_amt_diff = footerDataMap.rental_profit_amt_diff // 렌탈수익 전년대비
							service_account_amt_diff = footerDataMap.service_account_amt_diff // 신차판매 전년대비
							machine_used_profit_amt_diff = footerDataMap.machine_used_profit_amt_diff // 중고손익 전년대비

							AUIGrid.setGridData(auiGridB, result.LastYearList);
							AUIGrid.setGridData(auiGrid, result.list);
						}
					}
			);
		}

		//엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, '신)서비스업무평가-센터-매출현황');
		}

		// 기준정보 재생성
		function goChangeSave() {
			var s_year = $M.getValue("s_start_year");
			var s_mon = $M.lpad($M.getValue("s_start_mon"), 2, '0');

			var param = {
				"s_year_mon": s_year + s_mon,
			};

			var msg = '일지 작성월 : ' + s_year + '/' + s_mon + ' ~ 당월 까지 정보를 재성성 합니다.\n실행하시겠습니까?';
			$M.goNextPageAjaxMsg(msg, "/serv/serv0501/change/save", $M.toGetParam(param), {method: "POST", timeout : 60 * 60 * 1000},
					function (result) {
						if (result.success) {
							alert("기준정보 재생성을 완료하였습니다.");
							window.location.reload();
						}
					}
			);
		}

		function fnSetNumberFormatToggle() {
			if (numberFormat == "all") {
				numberFormat = "thousand";
			} else {
				numberFormat = "all";
			}
			AUIGrid.resize(auiGrid);
			goSearch();
		}

		// MBO 등록 팝업
		function goAddMbo() {
			var param = {};
			var poppupOption = "";
			$M.goNextPage('/serv/serv051401p01', $M.toGetParam(param), {popupStatus: poppupOption});
		}

		function createAUIGridB() {
			var gridPros = {
				rowIdField: "_$uid",
				showFooter: false,
				showRowNumColumn: false,
				editable: false,
			};

			var columnLayout = [
				{
					headerText: "센터",
					dataField: "org_name",
				},
				{
					headerText: "센터코드",
					dataField: "org_code",
				},
				{
					headerText: "지출(천원)",
					children: [
						{
							headerText: "1년간지출",
							dataField: "out_amt",
						},
						{
							headerText: "과1년<br>월평균<br>지출",
							dataField: "avg_amt",
						},
						{
							headerText: "평균지출<br>누계",
							dataField: "year_amt",
						},
						{
							headerText: "전년대비",
							dataField: "pre_year_amt_persentage",
						},
					]
				},
				{
					headerText: "월매출(천원)",
					children: [
						{
							headerText: "매출누계",
							dataField: "tot_amt",
						},
						{
							headerText: "전년대비",
							dataField: "pre_tot_amt_persentage",
						},
						{
							headerText: "유상정비<br>매출",
							dataField: "cost_amt",
						},
						{
							headerText: "무상정비<br>지출",
							dataField: "free_amt",
						},
						{
							headerText: "워렌티비용",
							dataField: "warranty_amt",
						},
						{
							headerText: "출하+서비스<br>비용",
							dataField: "free_out_sum_amt",
						},
						{
							headerText: "부품판매<br>매출",
							dataField: "part_amt",
						},
						{
							headerText: "렌탈매출",
							dataField: "rental_rent_amt",
						},
						{
							headerText: "신차판매",
							dataField: "service_account_amt_1",
						},
						{
							headerText: "중고손익",
							dataField: "machine_used_profit_amt_1",
						},
					]
				},
				{
					headerText: "월수익(천원)",
					children: [
						{
							headerText: "수익누계",
							dataField: "tot_profit",
						},
						{
							headerText: "전년대비",
							dataField: "pre_tot_profit_persentage",
						},
						{
							headerText: "유상정비<br>수익",
							dataField: "cost_profit_amt",
						},
						{
							headerText: "무상종합",
							dataField: "free_total_amt",
						},
						{
							headerText: "부품판매<br>수익",
							dataField: "part_profit_amt",
						},
						{
							headerText: "렌탈수익",
							dataField: "rental_profit_amt",
						},
						{
							headerText: "신차판매",
							dataField: "service_account_amt_2",
						},
						{
							headerText: "중고손익",
							dataField: "machine_used_profit_amt_2",
						},
					]
				},
				{
					headerText: "수익율",
					children: [
						{
							headerText: "순수이익",
							dataField: "profit_total_amt",
						},
						{
							headerText: "이익율",
							dataField: "profit_total_margin",
						},
					]
				},
				{
					headerText: "전월",
					dataField: "pre_profit_total_margin",
				},
				{
					headerText: "증감",
					dataField: "pre_profit_diff",
				},
				{
					headerText: "2023 MBO 매출(천원)",
					children: [
						{
							headerText: "매출누계",
							dataField: "",
						},
					]
				},
				{
					headerText: "2023 MBO 수익(천원)",
					children: [
						{
							headerText: "수익누계",
							dataField: "",
						},
					]
				}
			];
			auiGridB = AUIGrid.create("#auiGridB", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridB, []);
			AUIGrid.resize(auiGridB);
		}

		// 센터별 실적분석 팝업
		function goCenterProfitPopup() {
			var poppupOption = "";
			$M.goNextPage('/serv/serv051401p02', "", {popupStatus: poppupOption});
		}

		// 분야별 집계 팝업
		// function goTotalFieldPopup() {
		// 	var poppupOption = "";
		// 	var param = {
		// 		"s_year": $M.getValue("s_end_mon") == '12' ? $M.toNum($M.getValue("s_end_year")) + 1 : $M.getValue("s_end_year"),
		// 	}
		// 	$M.goNextPage('/serv/serv050203p02', $M.toGetParam(param), {popupStatus: poppupOption});
		// }

		function goTotalFieldPopup() {
			var poppupOption = "";

			var sStartYearMon = fnSetYearMon($M.getValue("s_start_year"), $M.getValue("s_start_mon"));
			var sEndYearMon = fnSetYearMon($M.getValue("s_end_year"), $M.getValue("s_end_mon"));

			var param = {
				// "s_year": $M.getValue("s_end_mon") == '12' ? $M.toNum($M.getValue("s_end_year")) + 1 : $M.getValue("s_end_year"),
				"s_start_year_mon" : sStartYearMon,
				"s_end_year_mon" : sEndYearMon
			}
			$M.goNextPage('/serv/serv051401p03', $M.toGetParam(param), {popupStatus: poppupOption});
		}

		function fnSetYearMon(year, mon) {
			var yearMon = year + (mon.length == 1 ? "0" + mon : mon);

			return yearMon;
		}
	</script>
</head>
<body style="background : #fff">
<form id="main_form" name="main_form">
<input type="hidden" id="mon_cnt" name="mon_cnt" value="${mon_cnt}">
	<div class="layout-box">
		<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="">
				<div class="">
					<!-- 검색영역 -->
					<div class="search-wrap mt10">
						<table class="table">
							<colgroup>
								<col width="50px">
								<col width="270px">
								<col width="*">
							</colgroup>
							<tbody>
							<tr>
								<th>조회년도</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-auto">
											<select class="form-control" id="s_start_year" name="s_start_year" onchange="fnUpdateParentStartYear()">
												<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
													<c:set var="year_option" value="${inputParam.s_current_year - i + 2000}" />
													<option value="${year_option}" <c:if test="${year_option eq inputParam.s_start_year}">selected</c:if>>${year_option}년</option>
												</c:forEach>
											</select>
										</div>
										<div class="col-auto">
											<select class="form-control" id="s_start_mon" name="s_start_mon" onchange="fnUpdateParentStartMon()">
												<c:forEach var="i" begin="1" end="12" step="1">
													<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i eq inputParam.s_start_mon}">selected</c:if>>${i}월</option>
												</c:forEach>
											</select>
										</div>
										<div class="col-auto">~</div>
										<div class="col-auto">
											<select class="form-control" id="s_end_year" name="s_end_year" onchange="fnUpdateParentEndYear()">
												<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
													<c:set var="year_option" value="${inputParam.s_current_year - i + 2000}" />
													<option value="${year_option}" <c:if test="${year_option eq inputParam.s_end_year}">selected</c:if>>${year_option}년</option>
												</c:forEach>
											</select>
										</div>
										<div class="col-auto">
											<select class="form-control" id="s_end_mon" name="s_end_mon" onchange="fnUpdateParentEndMon()">
												<c:forEach var="i" begin="1" end="12" step="1">
													<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i eq inputParam.s_end_mon}">selected</c:if>>${i}월</option>
												</c:forEach>
											</select>
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
					<!-- /검색영역 -->
					<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<h4>조회결과</h4>
						<div class="btn-group">
							<div class="left" style="margin-left:50px;">
								<span style="color: #ff7f00;">※ 기준일시 : ${lastStandDateTime}</span>
							</div>
							<div class="right">
								<label for="s_toggle_numberFormat" style="color:black;">
									<input type="checkbox" id="s_toggle_numberFormat" checked="checked" onclick="javascript:fnSetNumberFormatToggle(event)"><span>천</span> 단위
								</label>
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
					<!-- /그리드 타이틀, 컨트롤 영역 -->
					<div id="auiGrid" style="margin-top: 5px; height: 650px;"></div>
					<div id="auiGridB" style="margin-top: 5px; height: 460px; display:none;"></div>
					<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
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