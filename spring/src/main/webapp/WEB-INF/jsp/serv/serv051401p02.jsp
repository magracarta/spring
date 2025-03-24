<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 서비스관리 > 신)서비스업무평가-센터 > 매출현황 > 센터별 실적분석
-- 작성자 : 황빛찬
-- 최초 작성일 : 2023-12-07 10:26:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGrid;
		var auiGridB;
		var dataFieldName = []; // 펼침 항목(create할때 넣음)

		$(document).ready(function () {
			createAUIGridA();
			createAUIGridB();
		});

		// 유상+무상 정비건수 변화추이 팝업
		function goFirstGraphPopup() {
			var params = {
				"s_end_year" : $M.getValue("s_end_year"),
				"s_org_code" : $M.getValue("s_org_code")
			};

			var popupOption = 'scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1000, height=531, left=0, top=0';
			$M.goNextPage('/serv/serv050203p0101', $M.toGetParam(params), {popupStatus : popupOption});
		}

		// 유상 정비순익 변화추이 팝업
		function goSecondGraphPopup() {
			var params = {
				"s_end_year" : $M.getValue("s_end_year"),
				"s_org_code" : $M.getValue("s_org_code")
			};

			var popupOption = 'scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1000, height=531, left=0, top=0';
			$M.goNextPage('/serv/serv050203p0102', $M.toGetParam(params), {popupStatus : popupOption});
		}

		// 최종 순익 변화추이 팝업
		function goThirdGraphPopup() {
			var params = {
				"s_end_year" : $M.getValue("s_end_year"),
				"s_org_code" : $M.getValue("s_org_code")
			};

			var popupOption = 'scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1000, height=531, left=0, top=0';
			$M.goNextPage('/serv/serv050203p0103', $M.toGetParam(params), {popupStatus : popupOption});
		}

		// 렌탙 순익 변화추이
		function goFourthGraphPopup() {
			var params = {
				"s_end_year" : $M.getValue("s_end_year"),
				"s_org_code" : $M.getValue("s_org_code")
			};

			var popupOption = 'scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1000, height=531, left=0, top=0';
			$M.goNextPage('/serv/serv050203p0104', $M.toGetParam(params), {popupStatus : popupOption});
		}

		// 조회
		function goSearch() {
			if ($M.validation(document.main_form) == false) {
				return;
			}
 
 			var sStartYearMon = fnSetYearMon($M.getValue("s_start_year"), $M.getValue("s_start_mon"));
			var sEndYearMon = fnSetYearMon($M.getValue("s_end_year"), $M.getValue("s_end_mon"));

 			var param = {
				"s_start_year_mon" : sStartYearMon,
				"s_end_year_mon" : sEndYearMon,
				"s_org_code" : $M.getValue("s_org_code"),
			};

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: 'GET'},
					function (result) {
						if (result.success) {
							$("#total_cnt").html(result.total_cnt);
							AUIGrid.setGridData(auiGridB, result.LastYearList);
							AUIGrid.setGridData(auiGrid, result.list);
						}
					}
			);
		}

		function fnSetYearMon(year, mon) {
			var yearMon = year + (mon.length == 1 ? "0" + mon : mon);
			
			return yearMon; 
		}

		function createAUIGridA() {
			var gridPros = {
				editable: false,
				// rowIdField 설정
				rowIdField: "_$uid",
				// rowIdField가 unique 임을 보장
				rowIdTrustMode: true,
				showFooter: true,
				footerPosition : "top",
				footerRowCount : 3,
				fixedColumnCount: 1
			};
			var columnLayout = [
				{
					headerText: "년월",
					dataField: "yyyymm",
					dataType: "date",
					formatString: "yyyy-mm",
					width: 80,
					minWidth: 80
				},
				{
					headerText: "서비스업무평가",
					children: [
						{
							headerText: "전체",
							dataField: "as_tot",
							dataType: "numeric",
							formatString: "#,##0",
							style: "aui-right",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value == 0 ? "" : $M.setComma(value);
							},
							styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
								if (value == 0) {
									return "";
								}
								return "aui-popup"
							},
							width: 50,
							minWidth: 50,
							// headerTooltip : { // 헤더 툴팁 표시 일반 스트링
		                    //     show : true,
		                    //     tooltipHtml : '<div style="width:400px;"><p><span style="color:#F29661;">유무상 결정 조건</span></p>' +
		                    //     				'<p>1. 정비일지 : 전표처리한 정비지시서만 대상</p>' +
		                    //     				'<p>- 결재한 일지가 없을 경우 : 무상 - 정비지시서 금액 > 0, 무상 - 금액 0</p>' +
		                    //     				'<p>- 결재된 일지가 있는 경우 : 마지막 결재 정비일지에 따라 유/무상 결정</p>' +
		                    //     				'<p>2. 출하일지 : 무상</p>' +
		                    //     			  '</div>'
		                    // }
						},
						{
							headerText: "전화",
							dataField: "as_call_cnt",
							dataType: "numeric",
							formatString: "#,##0",
							style: "aui-right",
							width: "5%",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value == 0 ? "" : $M.setComma(value);
							},
							styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
								if (value == 0) {
									return "";
								}
								return "aui-popup"
							},
							width: 50,
							minWidth: 50,
							headerStyle : "aui-fold",
						},
						{
							headerText: "유상",
							dataField: "as_cost_repair_cnt",
							dataType: "numeric",
							formatString: "#,##0",
							style: "aui-right",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value == 0 ? "" : $M.setComma(value);
							},
							styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
								if (value == 0) {
									return "";
								}
								return "aui-popup"
							},
							width: 50,
							minWidth: 50,
							headerStyle : "aui-fold",
						},
						{
							headerText: "무상",
							dataField: "as_free_repair_cnt",
							dataType: "numeric",
							formatString: "#,##0",
							style: "aui-right",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value == 0 ? "" : $M.setComma(value);
							},
							styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
								if (value == 0) {
									return "";
								}
								return "aui-popup"
							},
							width: 50,
							minWidth: 50,
							headerStyle : "aui-fold",
						},
						{
							headerText: "유상+무상",
							dataField: "as_repair_tot",
							dataType: "numeric",
							formatString: "#,##0",
							style: "aui-right",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value == 0 ? "" : $M.setComma(value);
							},
							styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
								if (value == 0) {
									return "";
								}
								return "aui-popup"
							},
							width: 70,
							minWidth: 70,
						},
						{
							headerText: "유무상규정H",
							dataField: "sum_standard_hour",
							dataType: "numeric",
							formatString: "#,##0.0####",
							style: "aui-right",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value == 0 ? "" : $M.setComma(value);
							},
							width: 90,
							minWidth: 90,
							headerStyle : "aui-fold",
						},
						{
							headerText: "유무상이동H",
							dataField: "sum_move_hour",
							dataType: "numeric",
							formatString: "#,##0.0####",
							style: "aui-right",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value == 0 ? "" : $M.setComma(value);
							},
							width: 90,
							minWidth: 90,
							headerStyle : "aui-fold",
						},
						{
							headerText: "렌탈H",
							dataField: "rental_job_hour",
							dataType: "numeric",
							formatString: "#,##0.0####",
							style: "aui-right",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value == 0 ? "" : $M.setComma(value);
							},
							width: 70,
							minWidth: 70,
							headerStyle : "aui-fold",
						},
						{
							headerText: "유효활동시간",
							dataField: "tot_valid_hour",
							dataType: "numeric",
							formatString: "#,##0.0####",
							style: "aui-right",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value == 0 ? "" : value;
							},
							width: 180,
							minWidth: 100,
							// headerTooltip : { // 헤더 툴팁 표시 일반 스트링
							// 	show : true,
							// 	tooltipHtml : '<div style="width:200px;"><p><span style="color:#F29661;">유상 이동(H)</span></p>' +
							// 			'<p>서비스업무평가 유상,무상<br>총이동(H) + 총규정(H)<br>+ 렌탈업무시간(H)</p>' +
							// 			'</div>'
							// }
						},
					]
				},
				{
					headerText: "유상정비집계",
					children: [
						{
							headerText: "이동H",
							dataField: "cost_move_hour",
							dataType: "numeric",
							formatString: "#,##0.0####",
							style: "aui-right",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value == 0 ? "" : value;
							},
							styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
								if (value == 0) {
									return "";
								}
								return "aui-popup"
							},
							width: 50,
							minWidth: 50,
							// headerTooltip : { // 헤더 툴팁 표시 일반 스트링
		                    //     show : true,
		                    //     tooltipHtml : '<div style="width:200px;"><p><span style="color:#F29661;">유상 이동(H)</span></p>' +
		                    //     				'<p>서비스업무평가 유상에 이동(H)</p>' +
		                    //     			  '</div>'
		                    // }
						},
						{
							headerText: "정비H",
							dataField: "cost_repair_hour",
							dataType: "numeric",
							formatString: "#,##0.0####",
							style: "aui-right",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value == 0 ? "" : value;
							},
							styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
								if (value == 0) {
									return "";
								}
								return "aui-popup"
							},
							width: 50,
							minWidth: 50,
							headerStyle : "aui-fold",
							// headerTooltip : { // 헤더 툴팁 표시 일반 스트링
		                    //     show : true,
		                    //     tooltipHtml : '<div style="width:200px;"><p><span style="color:#F29661;">유상 정비(H)</span></p>' +
		                    //     				'<p>서비스업무평가 유상에 정비(H)</p>' +
		                    //     			  '</div>'
		                    // }
						},
						{
							headerText: "규정H",
							dataField: "cost_standard_hour",
							dataType: "numeric",
							formatString: "#,##0.0####",
							style: "aui-right",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value == 0 ? "" : value;
							},
							styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
								if (value == 0) {
									return "";
								}
								return "aui-popup"
							},
							width: 50,
							minWidth: 50,
							// headerTooltip : { // 헤더 툴팁 표시 일반 스트링
		                    //     show : true,
		                    //     tooltipHtml : '<div style="width:200px;"><p><span style="color:#F29661;">유상 규정(H)</span></p>' +
		                    //     				'<p>서비스업무평가 유상에 규정(H)</p>' +
		                    //     			  '</div>'
		                    // }
						},
						{
							headerText: "부품비(A)",
							dataField: "cost_part_amt",
							style: "aui-right",
							dataType: "numeric",
							formatString: "#,##0",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value == 0 ? "" : $M.setComma(value);
							},
							styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
								if (value == 0) {
									return "";
								}
								return "aui-popup"
							},
							width: 100,
							minWidth: 50,
							headerStyle : "aui-fold",
							// headerTooltip : { // 헤더 툴팁 표시 일반 스트링
		                    //     show : true,
		                    //     tooltipHtml : '<div style="width:400px;"><p><span style="color:#F29661;">부품비</span></p>' +
		                    //     				'<p>1.정비지시서 유상전표 중 물품대 - (YK01, YK02, YK021, YK임대료)</p>' +
		                    //     			  '</div>'
		                    // }
						},
						{
							headerText: "출장비(B)",
							dataField: "cost_travel_amt",
							dataType: "numeric",
							formatString: "#,##0",
							style: "aui-right",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value == 0 ? "" : $M.setComma(value);
							},
							styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
								if (value == 0) {
									return "";
								}
								return "aui-popup"
							},
							width: 100,
							minWidth: 50,
							headerStyle : "aui-fold",
							// headerTooltip : { // 헤더 툴팁 표시 일반 스트링
		                    //     show : true,
		                    //     tooltipHtml : '<div style="width:250px;"><p><span style="color:#F29661;">출장비</span></p>' +
		                    //     				'<p>1.정비지시서 유상전표 중 YK01</p>' +
		                    //     			  '</div>'
		                    // }
						},
						{
							headerText: "공임(C)",
							dataField: "cost_work_amt",
							dataType: "numeric",
							formatString: "#,##0",
							style: "aui-right",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value == 0 ? "" : $M.setComma(value);
							},
							styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
								if (value == 0) {
									return "";
								}
								return "aui-popup"
							},
							width: 100,
							minWidth: 50,
							headerStyle : "aui-fold",
							// headerTooltip : { // 헤더 툴팁 표시 일반 스트링
		                    //     show : true,
		                    //     tooltipHtml : '<div style="width:250px;"><p><span style="color:#F29661;">공임</span></p>' +
		                    //     				'<p>1.정비지시서 유상전표 중 YK01, YK021</p>' +
		                    //     				'<p>2.수주 전표 중 YK02, YK021</p>' +
		                    //     				'<p>3.모든 전표 중 YK배송료</p>' +
		                    //     			  '</div>'
		                    // }
						}
					]
				},
				{
					headerText: "유상 정비",
					children: [
						{
							headerText: "매출집계(D)",
							dataField: "cost_amt",
							dataType: "numeric",
							formatString: "#,##0",
							style: "aui-right",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value == 0 ? "" : $M.setComma(value);
							},
							width: 130,
							minWidth: 50,
						},
						{
							headerText: "순익(부품15%)(E)",
							dataField: "cost_profit_amt",
							dataType: "numeric",
							formatString: "#,##0",
							style: "aui-right",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value == 0 ? "" : $M.setComma(value);
							},
							width: 130,
							minWidth: 50,
						}
					]
				},
				{
					headerText: "무상정비집계",
					children: [
						{
							headerText: "이동H",
							dataField: "free_move_hour",
							dataType: "numeric",
							formatString: "#,##0.0####",
							style: "aui-right",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value == 0 ? "" : value;
							},
							styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
								if (value == 0) {
									return "";
								}
								return "aui-popup"
							},
							width: 50,
							minWidth: 50,
							// headerTooltip : { // 헤더 툴팁 표시 일반 스트링
		                    //     show : true,
		                    //     tooltipHtml : '<div style="width:200px;"><p><span style="color:#F29661;">무상 이동(H)</span></p>' +
		                    //     				'<p>서비스업무평가 무상에 이동(H)</p>' +
		                    //     			  '</div>'
		                    // }
						},
						{
							headerText: "정비H",
							dataField: "free_repair_hour",
							dataType: "numeric",
							formatString: "#,##0.0####",
							style: "aui-right",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value == 0 ? "" : value;
							},
							styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
								if (value == 0) {
									return "";
								}
								return "aui-popup"
							},
							width: 50,
							minWidth: 50,
							headerStyle : "aui-fold",
							// headerTooltip : { // 헤더 툴팁 표시 일반 스트링
		                    //     show : true,
		                    //     tooltipHtml : '<div style="width:200px;"><p><span style="color:#F29661;">무상 정비(H)</span></p>' +
		                    //     				'<p>서비스업무평가 무상에 정비(H)</p>' +
		                    //     			  '</div>'
		                    // }
						},
						{
							headerText: "규정H",
							dataField: "free_standard_hour",
							dataType: "numeric",
							formatString: "#,##0.0####",
							style: "aui-right",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value == 0 ? "" : value;
							},
							styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
								if (value == 0) {
									return "";
								}
								return "aui-popup"
							},
							width: 50,
							minWidth: 50,
							// headerTooltip : { // 헤더 툴팁 표시 일반 스트링
		                    //     show : true,
		                    //     tooltipHtml : '<div style="width:200px;"><p><span style="color:#F29661;">무상 규정(H)</span></p>' +
		                    //     				'<p>서비스업무평가 무상에 규정(H)</p>' +
		                    //     			  '</div>'
		                    // }
						},
						{
							headerText: "부품비(F)",
							dataField: "m_free_part_amt",
							dataType: "numeric",
							formatString: "#,##0",
							style: "aui-right",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value == 0 ? "" : $M.setComma(value);
							},
							styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
								if (value == 0) {
									return "";
								}
								return "aui-popup"
							},
							width: 130,
							minWidth: 50,
							headerStyle : "aui-fold",
							// headerTooltip : { // 헤더 툴팁 표시 일반 스트링
		                    //     show : true,
		                    //     tooltipHtml : '<div style="width:400px;"><p><span style="color:#F29661;">무상 부품비</span></p>' +
		                    //     				'<p>전표처리한 정비지시서 대상</p>' +
		                    //     				'<p>- 대상부품 : YK01, YK02, YK021, YK임대료 제외</p>' +
		                    //     				'<p>- 판매가가 있으면 수량 X 판매가</p>' +
		                    //     				'<p>- 판매가가 없으면 수량 X 단가</p>' +
		                    //     			  '</div>'
		                    // }
						},
						{
							headerText: "출장비(G)",
							dataField: "free_travel_amt",
							dataType: "numeric",
							formatString: "#,##0",
							style: "aui-right",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value == 0 ? "" : $M.setComma(value);
							},
							styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
								if (value == 0) {
									return "";
								}
								return "aui-popup"
							},
							width: 130,
							minWidth: 50,
							headerStyle : "aui-fold",
							// headerTooltip : { // 헤더 툴팁 표시 일반 스트링
		                    //     show : true,
		                    //     tooltipHtml : '<div style="width:200px;"><p><span style="color:#F29661;">무상 출장비</span></p>' +
		                    //     				'<p>출장거리 있는것 대상</p>' +
		                    //     				'<p>- 2020/12/01 이전 : 거리 X 450원 </p>' +
		                    //     				'<p>- 2020/12/01 이후 : 거리 X 500원 </p>' +
		                    //     			  '</div>'
		                    // }
						},
						{
							headerText: "공임(H)",
							dataField: "free_work_amt",
							dataType: "numeric",
							formatString: "#,##0",
							style: "aui-right",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value == 0 ? "" : $M.setComma(value);
							},
							styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
								if (value == 0) {
									return "";
								}
								return "aui-popup"
							},
							width: 130,
							minWidth: 50,
							headerStyle : "aui-fold",
							// headerTooltip : { // 헤더 툴팁 표시 일반 스트링
		                    //     show : true,
		                    //     tooltipHtml : '<div style="width:300px;"><p><span style="color:#F29661;">무상 공임비</span></p>' +
		                    //     				'<p>정비일지만 대상</p>' +
		                    //     				'<p>- 2020/12/01 이전 : 규정시간 X 35,000원 </p>' +
		                    //     				'<p>- 2020/12/01 이후 : 규정시간 X 60,000원 </p>' +
		                    //     			  '</div>'
		                    // }
						},
						{
							headerText: "지출집계(I)",
							dataField: "free_amt",
							dataType: "numeric",
							formatString: "#,##0",
							style: "aui-right",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value == 0 ? "" : $M.setComma(value);
							},
							width: 130,
							minWidth: 50,
						},
						{
							headerText: "워렌티비용(L)",
							dataField: "warranty_amt",
							dataType: "numeric",
							formatString: "#,##0.0####",
							style: "aui-right aui-link",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value == 0 ? "" : $M.setComma(value);
							},
							width: 130,
							minWidth: 50,
							headerStyle : "aui-fold",
						},
						{
							headerText: "출하정비비용(J)",
							dataField: "out_cost_amt",
							dataType: "numeric",
							formatString: "#,##0",
							width : "100",
							minWidth : "90",
							style: "aui-right",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value == 0 ? "" : $M.setComma(value);
							},
							styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
								if (value == 0) {
									return "";
								}
								return "aui-popup"
							}
						},
						{
							headerText: "서비스비용합계(K)",
							dataField: "free_cost_amt",
							dataType: "numeric",
							formatString: "#,##0",
							width : "100",
							minWidth : "90",
							style: "aui-right",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value == 0 ? "" : $M.setComma(value);
							},
							styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
								if (value == 0) {
									return "";
								}
								return "aui-popup"
							}
						},
						{
							headerText: "무상종합(N)",
							dataField: "free_total_amt",
							dataType: "numeric",
							formatString: "#,##0.0####",
							width : "100",
							minWidth : "90",
							style: "aui-right",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value == 0 ? "" : $M.setComma(value);
							},
						},
					]
				},
				// {
				// 	headerText: "서비스비용(무상정비)",
				// 	children: [
				// 		{
		        //         	headerText: "출하정비비용(J)",
		        //             dataField: "out_cost_amt",
		        //             dataType: "numeric",
		        //             formatString: "#,##0",
		        //             width : "100",
		        //             minWidth : "90",
		        //             style: "aui-right",
		        //             labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
				// 				return value == 0 ? "" : $M.setComma(value);
				// 			},
				// 			styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
				// 				if (value == 0) {
				// 					return "";
				// 				}
				// 				return "aui-popup"
				// 			}
		        //         },
		        //         {
		        //         	headerText: "서비스비용합계(K)",
		        //             dataField: "free_cost_amt",
		        //             dataType: "numeric",
		        //             formatString: "#,##0",
		        //             width : "100",
		        //             minWidth : "90",
		        //             style: "aui-right",
		        //             labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
				// 				return value == 0 ? "" : $M.setComma(value);
				// 			},
				// 			styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
				// 				if (value == 0) {
				// 					return "";
				// 				}
				// 				return "aui-popup"
				// 			}
		        //         },
		        //         {
		        //         	headerText: "서비스비용잔여수익(L)",
		        //             dataField: "service_profit_amt",
		        //             dataType: "numeric",
		        //             formatString: "#,##0",
		        //             width : "120",
		        //             minWidth : "90",
		        //             style: "aui-right",
		        //             labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
				// 				return value == 0 ? "" : $M.setComma(value);
				// 			},
		        //         },
				// 	]
				// },
				// {
				// 	headerText: "무상정비",
				// 	children: [
				// 		{
		        //         	headerText: "매출집계(M)",
		        //             dataField: "free_sale_amt",
		        //             dataType: "numeric",
		        //             formatString: "#,##0",
		        //             width : "100",
		        //             minWidth : "90",
		        //             style: "aui-right",
		        //             labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
				// 				return value == 0 ? "" : $M.setComma(value);
				// 			},
				// 		},
				// 		{
		        //         	headerText: "순익(부품15%)(N)",
		        //             dataField: "free_profit_amt",
		        //             dataType: "numeric",
		        //             formatString: "#,##0",
		        //             width : "100",
		        //             minWidth : "90",
		        //             style: "aui-right",
		        //             labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
				// 				return value == 0 ? "" : $M.setComma(value);
				// 			},
				// 		}
				// 	]
				// },
				{
					headerText: "부품판매(O)",
					dataField: "part_amt",
					dataType: "numeric",
					formatString: "#,##0",
					style: "aui-right",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						return value == 0 ? "" : $M.setComma(value);
					},
					styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
						if (value == 0) {
							return "";
						}
						return "aui-popup"
					},
					width: 130,
					minWidth: 50,
				},
				{
					headerText: "부품판매(15%)(P)",
					dataField: "part_profit_amt",
					dataType: "numeric",
					formatString: "#,##0",
					style: "aui-right",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						return value == 0 ? "" : $M.setComma(value);
					},
					width: 130,
					minWidth: 50,
				},
				{
					headerText: "재정비",
					dataField: "re_as_repair_cnt",
					dataType: "numeric",
					formatString: "#,##0",
					style: "aui-right aui-popup",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						return value == 0 ? "" : $M.setComma(value);
					},
					width: 50,
					minWidth: 50,
				},
				{
					headerText: "중고손익(Q)",
					dataField: "machine_used_profit_amt",
					dataType: "numeric",
					formatString: "#,##0",
					style: "aui-right aui-popup",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						return value == 0 ? "" : $M.setComma(value);
					},
					width: 130,
					minWidth: 50,
				},
				{
					headerText: "렌탈집계",
					children: [
						// {
						// 	headerText: "렌탈업무시간",
						// 	dataField: "rental_job_hour",
						// 	dataType: "numeric",
						// 	formatString: "#,##0.0####",
						// 	style: "aui-right aui-popup",
						// 	labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						// 		return value == 0 ? "" : value;
						// 	},
						// 	width: 100,
						// 	minWidth: 50,
						// },
						{
							headerText: "렌탈료(R)",
							dataField: "rental_rent_amt",
							dataType: "numeric",
							formatString: "#,##0",
							style: "aui-right",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value == 0 ? "" : $M.setComma(value);
							},
							styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
								if (value == 0) {
									return "";
								}
								return "aui-popup"
							},
							width: 130,
							minWidth: 50,
						},
						{
							headerText: "수리비용",
							dataField: "rental_repair_amt",
							dataType: "numeric",
							formatString: "#,##0",
							style: "aui-right",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value == 0 ? "" : $M.setComma(value);
							},
							styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
								if (value == 0) {
									return "";
								}
								return "aui-popup"
							},
							width: 130,
							minWidth: 50,
							headerStyle : "aui-fold",
						},
						{
							headerText: "감가(S)",
							dataField: "reduce_total_amt",
							dataType: "numeric",
							formatString: "#,##0",
							style: "aui-right",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value == 0 ? "" : $M.setComma(value);
							},
							styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
								if (value == 0) {
									return "";
								}
								return "aui-popup"
							},
							width: 130,
							minWidth: 50,
						},
						{
							headerText: "재렌탈(T)",
							dataField: "re_rental",
							dataType: "numeric",
							formatString: "#,##0",
							style: "aui-right",
							labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
								return value == 0 ? "" : $M.setComma(value);
							},
							styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
								if (value == 0) {
									return "";
								}
								return "aui-popup"
							},
							width: 130,
							minWidth: 50,
							headerStyle : "aui-fold",
						}
					]
				},
				{
					headerText: "렌탈순익(U)",
					dataField: "rental_profit_amt",
					dataType: "numeric",
					formatString: "#,##0",
					style: "aui-right",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						return value == 0 ? "" : $M.setComma(value);
					},
					width: 130,
					minWidth: 50,
				},
				// {
				// 	headerText: "출하지원금(V)",
				// 	dataField: "out_servcie_amt",
				// 	dataType: "numeric",
				// 	formatString: "#,##0",
				// 	style: "aui-right",
				// 	labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
				// 		return value == 0 ? "" : $M.setComma(value);
				// 	},
				// 	styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
				// 		if (value == 0) {
				// 			return "";
				// 		}
				// 		return "aui-popup"
				// 	},
				// 	width: 130,
				// 	minWidth: 50,
				// },
				{
					headerText: "신차 판매 정산(W)",
					dataField: "service_account_amt",
					dataType: "numeric",
					formatString: "#,##0",
					style: "aui-right aui-popup",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						return value == 0 ? "" : $M.setComma(value);
					},
					width: 130,
					minWidth: 50,
				},
				{
					headerText: "최종매출",
					dataField: "tot_amt",
					dataType: "numeric",
					formatString: "#,##0",
					style: "aui-right",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						return value == 0 ? "" : $M.setComma(value);
					},
					width: 130,
					minWidth: 50,
					// headerTooltip : { // 헤더 툴팁 표시 일반 스트링
                    //     show : true,
                    //     tooltipHtml : '<div style="width:180px;"><p><span style="color:#F29661;">최종매출</span></p><p>=D+M+O+Q+R+T+V+W</p></div>'
                    // }
				},
				{
					headerText: "최종순익",
					dataField: "tot_profit",
					dataType: "numeric",
					formatString: "#,##0",
					style: "aui-right",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						return value == 0 ? "" : $M.setComma(value);
					},
					width: 130,
					minWidth: 50,
					// headerTooltip : { // 헤더 툴팁 표시 일반 스트링
                    //     show : true,
                    //     tooltipHtml : '<div style="width:180px;"><p><span style="color:#F29661;">최종순익</span></p><p>=E+N+P+Q+U+T+V+W</p></div>'
                    // }
				},
				{
					headerText: "MBO",
					dataField: "temp_mbo_amt",
					dataType: "numeric",
					formatString: "#,##0",
					style: "aui-right",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						return value == 0 ? "" : $M.setComma(value);
					},
					width: 130,
					minWidth: 50,
				},
				{
					headerText: "MBO 달성율",
					dataField: "temp_mbo_amt_2",
					dataType: "numeric",
					formatString: "#,##0",
					style: "aui-right",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						return value == 0 ? "" : $M.setComma(value);
					},
					width: 130,
					minWidth: 50,
				}
			]

			// 푸터레이아웃
			var footerColumnLayout = [];
			footerColumnLayout[0] = [
				{
					labelText: "합계",
					positionField: "yyyymm",
					style: "aui-center aui-footer",
				},
				{
					dataField: "as_tot",
					positionField: "as_tot",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
				},
				{
					dataField: "as_call_cnt",
					positionField: "as_call_cnt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
				},
				{
					dataField: "as_cost_repair_cnt",
					positionField: "as_cost_repair_cnt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
				},
				{
					dataField: "as_free_repair_cnt",
					positionField: "as_free_repair_cnt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
				},
				{
					dataField: "as_repair_tot",
					positionField: "as_repair_tot",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
				},
				{
					dataField: "sum_standard_hour",
					positionField: "sum_standard_hour",
					operation: "SUM",
					formatString: "#,##0.0####",
					style: "aui-right aui-footer",
				},
				{
					dataField: "sum_move_hour",
					positionField: "sum_move_hour",
					operation: "SUM",
					formatString: "#,##0.0####",
					style: "aui-right aui-footer",
				},
				{
					dataField: "rental_job_hour",
					positionField: "rental_job_hour",
					operation: "SUM",
					formatString: "#,##0.0####",
					style: "aui-right aui-footer",
				},
				{
					dataField: "tot_valid_hour",
					positionField: "tot_valid_hour",
					operation: "SUM",
					formatString: "#,##0.0####",
					style: "aui-right aui-footer",
				},
				{
					dataField: "cost_move_hour",
					positionField: "cost_move_hour",
					operation: "SUM",
					formatString: "#,##0.0####",
					style: "aui-right aui-footer",
				},
				{
					dataField: "cost_repair_hour",
					positionField: "cost_repair_hour",
					operation: "SUM",
					formatString: "#,##0.0####",
					style: "aui-right aui-footer",
				},
				{
					dataField: "cost_standard_hour",
					positionField: "cost_standard_hour",
					operation: "SUM",
					formatString: "#,##0.0####",
					style: "aui-right aui-footer",
				},
				{
					dataField: "cost_part_amt",
					positionField: "cost_part_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
				},
				{
					dataField: "cost_travel_amt",
					positionField: "cost_travel_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
				},
				{
					dataField: "cost_work_amt",
					positionField: "cost_work_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
				},
				{
					dataField: "cost_amt",
					positionField: "cost_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
				},
				{
					dataField: "cost_profit_amt",
					positionField: "cost_profit_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
				},
				{
					dataField: "free_move_hour",
					positionField: "free_move_hour",
					operation: "SUM",
					formatString: "#,##0.0####",
					style: "aui-right aui-footer",
				},
				{
					dataField: "free_repair_hour",
					positionField: "free_repair_hour",
					operation: "SUM",
					formatString: "#,##0.0####",
					style: "aui-right aui-footer",
				},
				{
					dataField: "free_standard_hour",
					positionField: "free_standard_hour",
					operation: "SUM",
					formatString: "#,##0.0####",
					style: "aui-right aui-footer",
				},
				{
					dataField: "m_free_part_amt",
					positionField: "m_free_part_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
				},
				{
					dataField: "free_travel_amt",
					positionField: "free_travel_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
				},
				{
					dataField: "free_work_amt",
					positionField: "free_work_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
				},
				{
					dataField: "free_amt",
					positionField: "free_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
				},
				{
					dataField: "warranty_amt",
					positionField: "warranty_amt",
					operation: "SUM",
					formatString: "#,##0.0####",
					style: "aui-right aui-footer",
				},
				{
					dataField: "out_cost_amt",
					positionField: "out_cost_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
				},
				{
					dataField: "free_cost_amt",
					positionField: "free_cost_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
				},
				{
					dataField: "free_total_amt",
					positionField: "free_total_amt",
					operation: "SUM",
					formatString: "#,##0.0####",
					style: "aui-right aui-footer",
				},
				// {
				// 	dataField: "service_profit_amt",
				// 	positionField: "service_profit_amt",
				// 	operation: "SUM",
				// 	formatString: "#,##0",
				// 	style: "aui-right aui-footer",
				// },
				// {
				// 	dataField: "free_sale_amt",
				// 	positionField: "free_sale_amt",
				// 	operation: "SUM",
				// 	formatString: "#,##0",
				// 	style: "aui-right aui-footer",
				// },
				// {
				// 	dataField: "free_profit_amt",
				// 	positionField: "free_profit_amt",
				// 	operation: "SUM",
				// 	formatString: "#,##0",
				// 	style: "aui-right aui-footer",
				// },
				{
					dataField: "part_amt",
					positionField: "part_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
				},
				{
					dataField: "part_profit_amt",
					positionField: "part_profit_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
				},
				{
					dataField: "re_as_repair_cnt",
					positionField: "re_as_repair_cnt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
				},
				{
					dataField: "machine_used_profit_amt",
					positionField: "machine_used_profit_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
				},
				// {
				// 	dataField: "rental_job_hour",
				// 	positionField: "rental_job_hour",
				// 	operation: "SUM",
				// 	formatString: "#,##0.0####",
				// 	style: "aui-right aui-footer",
				// },
				{
					dataField: "rental_rent_amt",
					positionField: "rental_rent_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
				},
				{
					dataField: "rental_repair_amt",
					positionField: "rental_repair_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
				},
				{
					dataField: "reduce_total_amt",
					positionField: "reduce_total_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
				},
				{
					dataField: "rental_profit_amt",
					positionField: "rental_profit_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
				},
				{
					dataField: "re_rental",
					positionField: "re_rental",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
				},
				{
					dataField: "rental_profit_amt",
					positionField: "rental_profit_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
				},
				// {
				// 	dataField: "out_servcie_amt",
				// 	positionField: "out_servcie_amt",
				// 	operation: "SUM",
				// 	formatString: "#,##0",
				// 	style: "aui-right aui-footer",
				// },
				{
					dataField: "service_account_amt",
					positionField: "service_account_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
				},
				{
					dataField: "tot_amt",
					positionField: "tot_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
				},
				{
					dataField: "tot_profit",
					positionField: "tot_profit",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
				},
				{
					dataField: "temp_mbo_amt",
					positionField: "temp_mbo_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
				},
				{
					dataField: "temp_mbo_amt_2",
					positionField: "temp_mbo_amt_2",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
				},
			];

			footerColumnLayout[1] = [
				{
					labelText: "전년도 합계",
					positionField: "yyyymm",
					style: "aui-center aui-footer",
				},
				{
					dataField: "as_tot",
					positionField: "as_tot",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGridB);
						var sum = 0;
						
						for (var i = 0; i < gridData.length; i++) {
							sum += $M.toNum(gridData[i].as_tot);
						}
						
						return sum;
					}
				},
				{
					dataField: "as_call_cnt",
					positionField: "as_call_cnt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGridB);
						var sum = 0;
						
						for (var i = 0; i < gridData.length; i++) {
							sum += $M.toNum(gridData[i].as_call_cnt);
						}
						
						return sum;
					}
				},
				{
					dataField: "as_cost_repair_cnt",
					positionField: "as_cost_repair_cnt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGridB);
						var sum = 0;
						
						for (var i = 0; i < gridData.length; i++) {
							sum += $M.toNum(gridData[i].as_cost_repair_cnt);
						}
						
						return sum;
					}
				},
				{
					dataField: "as_free_repair_cnt",
					positionField: "as_free_repair_cnt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGridB);
						var sum = 0;
						
						for (var i = 0; i < gridData.length; i++) {
							sum += $M.toNum(gridData[i].as_free_repair_cnt);
						}
						
						return sum;
					}
				},
				{
					dataField: "as_repair_tot",
					positionField: "as_repair_tot",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGridB);
						var sum = 0;
						
						for (var i = 0; i < gridData.length; i++) {
							sum += $M.toNum(gridData[i].as_repair_tot);
						}
						
						return sum;
					}
				},
				{
					dataField: "sum_standard_hour",
					positionField: "sum_standard_hour",
					operation: "SUM",
					formatString: "#,##0.0####",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGridB);
						var sum = 0;

						for (var i = 0; i < gridData.length; i++) {
							sum += $M.toNum(gridData[i].sum_standard_hour);
						}

						return sum;
					}
				},
				{
					dataField: "sum_move_hour",
					positionField: "sum_move_hour",
					operation: "SUM",
					formatString: "#,##0.0####",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGridB);
						var sum = 0;

						for (var i = 0; i < gridData.length; i++) {
							sum += $M.toNum(gridData[i].sum_move_hour);
						}

						return sum;
					}
				},
				{
					dataField: "rental_job_hour",
					positionField: "rental_job_hour",
					operation: "SUM",
					formatString: "#,##0.0####",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGridB);
						var sum = 0;

						for (var i = 0; i < gridData.length; i++) {
							sum += $M.toNum(gridData[i].rental_job_hour);
						}

						return sum;
					}
				},
				{
					dataField: "tot_valid_hour",
					positionField: "tot_valid_hour",
					operation: "SUM",
					formatString: "#,##0.0####",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGridB);
						var sum = 0;

						for (var i = 0; i < gridData.length; i++) {
							sum += $M.toNum(gridData[i].tot_valid_hour);
						}

						return sum;
					}
				},
				{
					dataField: "cost_move_hour",
					positionField: "cost_move_hour",
					operation: "SUM",
					formatString: "#,##0.0####",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGridB);
						var sum = 0;
						
						for (var i = 0; i < gridData.length; i++) {
							sum += $M.toNum(gridData[i].cost_move_hour);
						}
						
						return sum;
					}
				},
				{
					dataField: "cost_repair_hour",
					positionField: "cost_repair_hour",
					operation: "SUM",
					formatString: "#,##0.0####",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGridB);
						var sum = 0;
						
						for (var i = 0; i < gridData.length; i++) {
							sum += $M.toNum(gridData[i].cost_repair_hour);
						}
						
						return sum;
					}
				},
				{
					dataField: "cost_standard_hour",
					positionField: "cost_standard_hour",
					operation: "SUM",
					formatString: "#,##0.0####",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGridB);
						var sum = 0;
						
						for (var i = 0; i < gridData.length; i++) {
							sum += $M.toNum(gridData[i].cost_standard_hour);
						}
						
						return sum;
					}
				},
				{
					dataField: "cost_part_amt",
					positionField: "cost_part_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGridB);
						var sum = 0;
						
						for (var i = 0; i < gridData.length; i++) {
							sum += $M.toNum(gridData[i].cost_part_amt);
						}
						
						return sum;
					}
				},
				{
					dataField: "cost_travel_amt",
					positionField: "cost_travel_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGridB);
						var sum = 0;
						
						for (var i = 0; i < gridData.length; i++) {
							sum += $M.toNum(gridData[i].cost_travel_amt);
						}
						
						return sum;
					}
				},
				{
					dataField: "cost_work_amt",
					positionField: "cost_work_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGridB);
						var sum = 0;
						
						for (var i = 0; i < gridData.length; i++) {
							sum += $M.toNum(gridData[i].cost_work_amt);
						}
						
						return sum;
					}
				},
				{
					dataField: "cost_amt",
					positionField: "cost_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGridB);
						var sum = 0;
						
						for (var i = 0; i < gridData.length; i++) {
							sum += $M.toNum(gridData[i].cost_amt);
						}
						
						return sum;
					}
				},
				{
					dataField: "cost_profit_amt",
					positionField: "cost_profit_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGridB);
						var sum = 0;
						
						for (var i = 0; i < gridData.length; i++) {
							sum += $M.toNum(gridData[i].cost_profit_amt);
						}
						
						return sum;
					}
				},
				{
					dataField: "free_move_hour",
					positionField: "free_move_hour",
					operation: "SUM",
					formatString: "#,##0.0####",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGridB);
						var sum = 0;
						
						for (var i = 0; i < gridData.length; i++) {
							sum += $M.toNum(gridData[i].free_move_hour);
						}
						
						return sum;
					}
				},
				{
					dataField: "free_repair_hour",
					positionField: "free_repair_hour",
					operation: "SUM",
					formatString: "#,##0.0####",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGridB);
						var sum = 0;
						
						for (var i = 0; i < gridData.length; i++) {
							sum += $M.toNum(gridData[i].free_repair_hour);
						}
						
						return sum;
					}
				},
				{
					dataField: "free_standard_hour",
					positionField: "free_standard_hour",
					operation: "SUM",
					formatString: "#,##0.0####",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGridB);
						var sum = 0;
						
						for (var i = 0; i < gridData.length; i++) {
							sum += $M.toNum(gridData[i].free_standard_hour);
						}
						
						return sum;
					}
				},
				{
					dataField: "m_free_part_amt",
					positionField: "m_free_part_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGridB);
						var sum = 0;
						
						for (var i = 0; i < gridData.length; i++) {
							sum += $M.toNum(gridData[i].m_free_part_amt);
						}
						
						return sum;
					}
				},
				{
					dataField: "free_travel_amt",
					positionField: "free_travel_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGridB);
						var sum = 0;
						
						for (var i = 0; i < gridData.length; i++) {
							sum += $M.toNum(gridData[i].free_travel_amt);
						}
						
						return sum;
					}
				},
				{
					dataField: "free_work_amt",
					positionField: "free_work_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGridB);
						var sum = 0;
						
						for (var i = 0; i < gridData.length; i++) {
							sum += $M.toNum(gridData[i].free_work_amt);
						}
						
						return sum;
					}
				},
				{
					dataField: "free_amt",
					positionField: "free_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGridB);
						var sum = 0;
						
						for (var i = 0; i < gridData.length; i++) {
							sum += $M.toNum(gridData[i].free_amt);
						}
						
						return sum;
					}
				},
				{
					dataField: "warranty_amt",
					positionField: "warranty_amt",
					operation: "SUM",
					formatString: "#,##0.0####",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGridB);
						var sum = 0;

						for (var i = 0; i < gridData.length; i++) {
							sum += $M.toNum(gridData[i].warranty_amt);
						}

						return sum;
					}
				},
				{
					dataField: "out_cost_amt",
					positionField: "out_cost_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGridB);
						var sum = 0;
						
						for (var i = 0; i < gridData.length; i++) {
							sum += $M.toNum(gridData[i].out_cost_amt);
						}
						
						return sum;
					}
				},
				{
					dataField: "free_cost_amt",
					positionField: "free_cost_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGridB);
						var sum = 0;
						
						for (var i = 0; i < gridData.length; i++) {
							sum += $M.toNum(gridData[i].free_cost_amt);
						}
						
						return sum;
					}
				},
				{
					dataField: "free_total_amt",
					positionField: "free_total_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGridB);
						var sum = 0;

						for (var i = 0; i < gridData.length; i++) {
							sum += $M.toNum(gridData[i].free_total_amt);
						}

						return sum;
					}
				},
				// {
				// 	dataField: "service_profit_amt",
				// 	positionField: "service_profit_amt",
				// 	operation: "SUM",
				// 	formatString: "#,##0",
				// 	style: "aui-right aui-footer",
				// 	expFunction : function(columnValues) {
				// 		var gridData = AUIGrid.getGridData(auiGridB);
				// 		var sum = 0;
				//
				// 		for (var i = 0; i < gridData.length; i++) {
				// 			sum += $M.toNum(gridData[i].service_profit_amt);
				// 		}
				//
				// 		return sum;
				// 	}
				// },
				// {
				// 	dataField: "free_sale_amt",
				// 	positionField: "free_sale_amt",
				// 	operation: "SUM",
				// 	formatString: "#,##0",
				// 	style: "aui-right aui-footer",
				// 	expFunction : function(columnValues) {
				// 		var gridData = AUIGrid.getGridData(auiGridB);
				// 		var sum = 0;
				//
				// 		for (var i = 0; i < gridData.length; i++) {
				// 			sum += $M.toNum(gridData[i].free_sale_amt);
				// 		}
				//
				// 		return sum;
				// 	}
				// },
				// {
				// 	dataField: "free_profit_amt",
				// 	positionField: "free_profit_amt",
				// 	operation: "SUM",
				// 	formatString: "#,##0",
				// 	style: "aui-right aui-footer",
				// 	expFunction : function(columnValues) {
				// 		var gridData = AUIGrid.getGridData(auiGridB);
				// 		var sum = 0;
				//
				// 		for (var i = 0; i < gridData.length; i++) {
				// 			sum += $M.toNum(gridData[i].free_profit_amt);
				// 		}
				//
				// 		return sum;
				// 	}
				// },
				{
					dataField: "part_amt",
					positionField: "part_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGridB);
						var sum = 0;
						
						for (var i = 0; i < gridData.length; i++) {
							sum += $M.toNum(gridData[i].part_amt);
						}
						
						return sum;
					}
				},
				{
					dataField: "part_profit_amt",
					positionField: "part_profit_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGridB);
						var sum = 0;
						
						for (var i = 0; i < gridData.length; i++) {
							sum += $M.toNum(gridData[i].part_profit_amt);
						}
						
						return sum;
					}
				},
				{
					dataField: "re_as_repair_cnt",
					positionField: "re_as_repair_cnt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGridB);
						var sum = 0;
						
						for (var i = 0; i < gridData.length; i++) {
							sum += $M.toNum(gridData[i].re_as_repair_cnt);
						}
						
						return sum;
					}
				},
				{
					dataField: "machine_used_profit_amt",
					positionField: "machine_used_profit_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGridB);
						var sum = 0;
						
						for (var i = 0; i < gridData.length; i++) {
							sum += $M.toNum(gridData[i].machine_used_profit_amt);
						}
						
						return sum;
					}
				},
				// {
				// 	dataField: "rental_job_hour",
				// 	positionField: "rental_job_hour",
				// 	operation: "SUM",
				// 	formatString: "#,##0.0####",
				// 	style: "aui-right aui-footer",
				// 	expFunction : function(columnValues) {
				// 		var gridData = AUIGrid.getGridData(auiGridB);
				// 		var sum = 0;
				//
				// 		for (var i = 0; i < gridData.length; i++) {
				// 			sum += $M.toNum(gridData[i].rental_job_hour);
				// 		}
				//
				// 		return sum;
				// 	}
				// },
				{
					dataField: "rental_rent_amt",
					positionField: "rental_rent_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGridB);
						var sum = 0;
						
						for (var i = 0; i < gridData.length; i++) {
							sum += $M.toNum(gridData[i].rental_rent_amt);
						}
						
						return sum;
					}
				},
				{
					dataField: "rental_repair_amt",
					positionField: "rental_repair_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGridB);
						var sum = 0;

						for (var i = 0; i < gridData.length; i++) {
							sum += $M.toNum(gridData[i].rental_repair_amt);
						}

						return sum;
					}
				},
				{
					dataField: "reduce_total_amt",
					positionField: "reduce_total_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGridB);
						var sum = 0;
						
						for (var i = 0; i < gridData.length; i++) {
							sum += $M.toNum(gridData[i].reduce_total_amt);
						}
						
						return sum;
					}
				},
				{
					dataField: "re_rental",
					positionField: "re_rental",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGridB);
						var sum = 0;
						
						for (var i = 0; i < gridData.length; i++) {
							sum += $M.toNum(gridData[i].re_rental);
						}
						
						return sum;
					}
				},
				{
					dataField: "rental_profit_amt",
					positionField: "rental_profit_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGridB);
						var sum = 0;

						for (var i = 0; i < gridData.length; i++) {
							sum += $M.toNum(gridData[i].rental_profit_amt);
						}

						return sum;
					}
				},
				// {
				// 	dataField: "out_servcie_amt",
				// 	positionField: "out_servcie_amt",
				// 	operation: "SUM",
				// 	formatString: "#,##0",
				// 	style: "aui-right aui-footer",
				// 	expFunction : function(columnValues) {
				// 		var gridData = AUIGrid.getGridData(auiGridB);
				// 		var sum = 0;
				//
				// 		for (var i = 0; i < gridData.length; i++) {
				// 			sum += $M.toNum(gridData[i].out_servcie_amt);
				// 		}
				//
				// 		return sum;
				// 	}
				// },
				{
					dataField: "service_account_amt",
					positionField: "service_account_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGridB);
						var sum = 0;
						
						for (var i = 0; i < gridData.length; i++) {
							sum += $M.toNum(gridData[i].service_account_amt);
						}
						
						return sum;
					}
				},
				{
					dataField: "tot_amt",
					positionField: "tot_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGridB);
						var sum = 0;
						
						for (var i = 0; i < gridData.length; i++) {
							sum += $M.toNum(gridData[i].tot_amt);
						}
						
						return sum;
					}
				},
				{
					dataField: "tot_profit",
					positionField: "tot_profit",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGridB);
						var sum = 0;

						for (var i = 0; i < gridData.length; i++) {
							sum += $M.toNum(gridData[i].tot_profit);
						}

						return sum;
					}
				},
				{
					dataField: "temp_mbo_amt",
					positionField: "temp_mbo_amt",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGridB);
						var sum = 0;
						
						for (var i = 0; i < gridData.length; i++) {
							sum += $M.toNum(gridData[i].temp_mbo_amt);
						}
						
						return sum;
					}
				},
				{
					dataField: "temp_mbo_amt_2",
					positionField: "temp_mbo_amt_2",
					operation: "SUM",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridData = AUIGrid.getGridData(auiGridB);
						var sum = 0;

						for (var i = 0; i < gridData.length; i++) {
							sum += $M.toNum(gridData[i].temp_mbo_amt_2);
						}

						return sum;
					}
				},
			];

			footerColumnLayout[2] = [
				{
					labelText: "증감율",
					positionField: "yyyymm",
					style: "aui-center aui-footer",
				},
				{
					dataField: "as_tot",
					positionField: "as_tot",
					formatString: "#,##0.0#",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridDataA = AUIGrid.getGridData(auiGrid);
						var gridDataB = AUIGrid.getGridData(auiGridB);
						var sumA = 0;
						var sumB = 0;
						var result = 0.0;
						
						for (var i = 0; i < gridDataA.length; i++) {
							sumA += $M.toNum(gridDataA[i].as_tot);
						}
						for(var i=0; i<gridDataB.length; i++) {
							sumB += $M.toNum(gridDataB[i].as_tot);
						}

						result = (sumB == 0 ? 0 : $M.toNum((sumA - sumB) / sumB));
						
						return result;
					}
				},
				{
					dataField: "as_call_cnt",
					positionField: "as_call_cnt",
					formatString: "#,##0.0#",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridDataA = AUIGrid.getGridData(auiGrid);
						var gridDataB = AUIGrid.getGridData(auiGridB);
						var sumA = 0;
						var sumB = 0;
						var result = 0.0;
						
						for (var i = 0; i < gridDataA.length; i++) {
							sumA += $M.toNum(gridDataA[i].as_call_cnt);
						}
						for(var i=0; i<gridDataB.length; i++) {
							sumB += $M.toNum(gridDataB[i].as_call_cnt);
						}

						result = (sumB == 0 ? 0 : $M.toNum((sumA - sumB) / sumB));
						
						return result;
					}
				},
				{
					dataField: "as_cost_repair_cnt",
					positionField: "as_cost_repair_cnt",
					formatString: "#,##0.0#",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridDataA = AUIGrid.getGridData(auiGrid);
						var gridDataB = AUIGrid.getGridData(auiGridB);
						var sumA = 0;
						var sumB = 0;
						var result = 0.0;
						
						for (var i = 0; i < gridDataA.length; i++) {
							sumA += $M.toNum(gridDataA[i].as_cost_repair_cnt);
						}
						for(var i=0; i<gridDataB.length; i++) {
							sumB += $M.toNum(gridDataB[i].as_cost_repair_cnt);
						}

						result = (sumB == 0 ? 0 : $M.toNum((sumA - sumB) / sumB));
						
						return result;
					}
				},
				{
					dataField: "as_free_repair_cnt",
					positionField: "as_free_repair_cnt",
					formatString: "#,##0.0#",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridDataA = AUIGrid.getGridData(auiGrid);
						var gridDataB = AUIGrid.getGridData(auiGridB);
						var sumA = 0;
						var sumB = 0;
						var result = 0.0;
						
						for (var i = 0; i < gridDataA.length; i++) {
							sumA += $M.toNum(gridDataA[i].as_free_repair_cnt);
						}
						for(var i=0; i<gridDataB.length; i++) {
							sumB += $M.toNum(gridDataB[i].as_free_repair_cnt);
						}

						result = (sumB == 0 ? 0 : $M.toNum((sumA - sumB) / sumB));
						
						return result;
					}
				},
				{
					dataField: "as_repair_tot",
					positionField: "as_repair_tot",
					formatString: "#,##0.0#",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridDataA = AUIGrid.getGridData(auiGrid);
						var gridDataB = AUIGrid.getGridData(auiGridB);
						var sumA = 0;
						var sumB = 0;
						var result = 0.0;
						
						for (var i = 0; i < gridDataA.length; i++) {
							sumA += $M.toNum(gridDataA[i].as_repair_tot);
						}
						for(var i=0; i<gridDataB.length; i++) {
							sumB += $M.toNum(gridDataB[i].as_repair_tot);
						}

						result = (sumB == 0 ? 0 : $M.toNum((sumA - sumB) / sumB));
						
						return result;
					}
				},
				{
					dataField: "sum_standard_hour",
					positionField: "sum_standard_hour",
					formatString: "#,##0.0#",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridDataA = AUIGrid.getGridData(auiGrid);
						var gridDataB = AUIGrid.getGridData(auiGridB);
						var sumA = 0;
						var sumB = 0;
						var result = 0.0;

						for (var i = 0; i < gridDataA.length; i++) {
							sumA += $M.toNum(gridDataA[i].sum_standard_hour);
						}
						for(var i=0; i<gridDataB.length; i++) {
							sumB += $M.toNum(gridDataB[i].sum_standard_hour);
						}

						result = (sumB == 0 ? 0 : $M.toNum((sumA - sumB) / sumB));

						return result;
					}
				},
				{
					dataField: "sum_move_hour",
					positionField: "sum_move_hour",
					formatString: "#,##0.0#",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridDataA = AUIGrid.getGridData(auiGrid);
						var gridDataB = AUIGrid.getGridData(auiGridB);
						var sumA = 0;
						var sumB = 0;
						var result = 0.0;

						for (var i = 0; i < gridDataA.length; i++) {
							sumA += $M.toNum(gridDataA[i].sum_move_hour);
						}
						for(var i=0; i<gridDataB.length; i++) {
							sumB += $M.toNum(gridDataB[i].sum_move_hour);
						}

						result = (sumB == 0 ? 0 : $M.toNum((sumA - sumB) / sumB));

						return result;
					}
				},
				{
					dataField: "rental_job_hour",
					positionField: "rental_job_hour",
					formatString: "#,##0.0#",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridDataA = AUIGrid.getGridData(auiGrid);
						var gridDataB = AUIGrid.getGridData(auiGridB);
						var sumA = 0;
						var sumB = 0;
						var result = 0.0;

						for (var i = 0; i < gridDataA.length; i++) {
							sumA += $M.toNum(gridDataA[i].rental_job_hour);
						}
						for(var i=0; i<gridDataB.length; i++) {
							sumB += $M.toNum(gridDataB[i].rental_job_hour);
						}

						result = (sumB == 0 ? 0 : $M.toNum((sumA - sumB) / sumB));

						return result;
					}
				},
				{
					dataField: "tot_valid_hour",
					positionField: "tot_valid_hour",
					formatString: "#,##0.0####",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridDataA = AUIGrid.getGridData(auiGrid);
						var gridDataB = AUIGrid.getGridData(auiGridB);
						var sumA = 0;
						var sumB = 0;
						var result = 0.0;

						for (var i = 0; i < gridDataA.length; i++) {
							sumA += $M.toNum(gridDataA[i].tot_valid_hour);
						}
						for(var i=0; i<gridDataB.length; i++) {
							sumB += $M.toNum(gridDataB[i].tot_valid_hour);
						}

						result = (sumB == 0 ? 0 : $M.toNum((sumA - sumB) / sumB));

						return result.toFixed(2);
					}
				},
				{
					dataField: "cost_move_hour",
					positionField: "cost_move_hour",
					formatString: "#,##0.0####",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridDataA = AUIGrid.getGridData(auiGrid);
						var gridDataB = AUIGrid.getGridData(auiGridB);
						var sumA = 0;
						var sumB = 0;
						var result = 0.0;
						
						for (var i = 0; i < gridDataA.length; i++) {
							sumA += $M.toNum(gridDataA[i].cost_move_hour);
						}
						for(var i=0; i<gridDataB.length; i++) {
							sumB += $M.toNum(gridDataB[i].cost_move_hour);
						}

						result = (sumB == 0 ? 0 : $M.toNum((sumA - sumB) / sumB));
						
						return result.toFixed(2);
					}
				},
				{
					dataField: "cost_repair_hour",
					positionField: "cost_repair_hour",
					formatString: "#,##0.0####",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridDataA = AUIGrid.getGridData(auiGrid);
						var gridDataB = AUIGrid.getGridData(auiGridB);
						var sumA = 0;
						var sumB = 0;
						var result = 0.0;
						
						for (var i = 0; i < gridDataA.length; i++) {
							sumA += $M.toNum(gridDataA[i].cost_repair_hour);
						}
						for(var i=0; i<gridDataB.length; i++) {
							sumB += $M.toNum(gridDataB[i].cost_repair_hour);
						}

						result = (sumB == 0 ? 0 : $M.toNum((sumA - sumB) / sumB));
						
						return result.toFixed(2);
					}
				},
				{
					dataField: "cost_standard_hour",
					positionField: "cost_standard_hour",
					formatString: "#,##0.0####",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridDataA = AUIGrid.getGridData(auiGrid);
						var gridDataB = AUIGrid.getGridData(auiGridB);
						var sumA = 0;
						var sumB = 0;
						var result = 0.0;
						
						for (var i = 0; i < gridDataA.length; i++) {
							sumA += $M.toNum(gridDataA[i].cost_standard_hour);
						}
						for(var i=0; i<gridDataB.length; i++) {
							sumB += $M.toNum(gridDataB[i].cost_standard_hour);
						}

						result = (sumB == 0 ? 0 : $M.toNum((sumA - sumB) / sumB));
						
						return result.toFixed(2);
					}
				},
				{
					dataField: "cost_part_amt",
					positionField: "cost_part_amt",
					formatString: "#,##0.0#",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridDataA = AUIGrid.getGridData(auiGrid);
						var gridDataB = AUIGrid.getGridData(auiGridB);
						var sumA = 0;
						var sumB = 0;
						var result = 0.0;
						
						for (var i = 0; i < gridDataA.length; i++) {
							sumA += $M.toNum(gridDataA[i].cost_part_amt);
						}
						for(var i=0; i<gridDataB.length; i++) {
							sumB += $M.toNum(gridDataB[i].cost_part_amt);
						}

						result = (sumB == 0 ? 0 : $M.toNum((sumA - sumB) / sumB));
						
						return result;
					}
				},
				{
					dataField: "cost_travel_amt",
					positionField: "cost_travel_amt",
					formatString: "#,##0.0#",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridDataA = AUIGrid.getGridData(auiGrid);
						var gridDataB = AUIGrid.getGridData(auiGridB);
						var sumA = 0;
						var sumB = 0;
						var result = 0.0;
						
						for (var i = 0; i < gridDataA.length; i++) {
							sumA += $M.toNum(gridDataA[i].cost_travel_amt);
						}
						for(var i=0; i<gridDataB.length; i++) {
							sumB += $M.toNum(gridDataB[i].cost_travel_amt);
						}

						result = (sumB == 0 ? 0 : $M.toNum((sumA - sumB) / sumB));
						
						return result;
					}
				},
				{
					dataField: "cost_work_amt",
					positionField: "cost_work_amt",
					formatString: "#,##0.0#",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridDataA = AUIGrid.getGridData(auiGrid);
						var gridDataB = AUIGrid.getGridData(auiGridB);
						var sumA = 0;
						var sumB = 0;
						var result = 0.0;
						
						for (var i = 0; i < gridDataA.length; i++) {
							sumA += $M.toNum(gridDataA[i].cost_work_amt);
						}
						for(var i=0; i<gridDataB.length; i++) {
							sumB += $M.toNum(gridDataB[i].cost_work_amt);
						}

						result = (sumB == 0 ? 0 : $M.toNum((sumA - sumB) / sumB));
						
						return result;
					}
				},
				{
					dataField: "cost_amt",
					positionField: "cost_amt",
					formatString: "#,##0.0#",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridDataA = AUIGrid.getGridData(auiGrid);
						var gridDataB = AUIGrid.getGridData(auiGridB);
						var sumA = 0;
						var sumB = 0;
						var result = 0.0;
						
						for (var i = 0; i < gridDataA.length; i++) {
							sumA += $M.toNum(gridDataA[i].cost_amt);
						}
						for(var i=0; i<gridDataB.length; i++) {
							sumB += $M.toNum(gridDataB[i].cost_amt);
						}

						result = (sumB == 0 ? 0 : $M.toNum((sumA - sumB) / sumB));
						
						return result;
					}
				},
				{
					dataField: "cost_profit_amt",
					positionField: "cost_profit_amt",
					formatString: "#,##0.0#",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridDataA = AUIGrid.getGridData(auiGrid);
						var gridDataB = AUIGrid.getGridData(auiGridB);
						var sumA = 0;
						var sumB = 0;
						var result = 0.0;
						
						for (var i = 0; i < gridDataA.length; i++) {
							sumA += $M.toNum(gridDataA[i].cost_profit_amt);
						}
						for(var i=0; i<gridDataB.length; i++) {
							sumB += $M.toNum(gridDataB[i].cost_profit_amt);
						}

						result = (sumB == 0 ? 0 : $M.toNum((sumA - sumB) / sumB));
						
						return result;
					}
				},
				{
					dataField: "free_move_hour",
					positionField: "free_move_hour",
					formatString: "#,##0.0####",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridDataA = AUIGrid.getGridData(auiGrid);
						var gridDataB = AUIGrid.getGridData(auiGridB);
						var sumA = 0;
						var sumB = 0;
						var result = 0.0;
						
						for (var i = 0; i < gridDataA.length; i++) {
							sumA += $M.toNum(gridDataA[i].free_move_hour);
						}
						for(var i=0; i<gridDataB.length; i++) {
							sumB += $M.toNum(gridDataB[i].free_move_hour);
						}

						result = (sumB == 0 ? 0 : $M.toNum((sumA - sumB) / sumB));
						
						return result.toFixed(2);
					}
				},
				{
					dataField: "free_repair_hour",
					positionField: "free_repair_hour",
					formatString: "#,##0.0####",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridDataA = AUIGrid.getGridData(auiGrid);
						var gridDataB = AUIGrid.getGridData(auiGridB);
						var sumA = 0;
						var sumB = 0;
						var result = 0.0;
						
						for (var i = 0; i < gridDataA.length; i++) {
							sumA += $M.toNum(gridDataA[i].free_repair_hour);
						}
						for(var i=0; i<gridDataB.length; i++) {
							sumB += $M.toNum(gridDataB[i].free_repair_hour);
						}

						result = (sumB == 0 ? 0 : $M.toNum((sumA - sumB) / sumB));
						
						return result.toFixed(2);
					}
				},
				{
					dataField: "free_standard_hour",
					positionField: "free_standard_hour",
					formatString: "#,##0.0####",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridDataA = AUIGrid.getGridData(auiGrid);
						var gridDataB = AUIGrid.getGridData(auiGridB);
						var sumA = 0;
						var sumB = 0;
						var result = 0.0;
						
						for (var i = 0; i < gridDataA.length; i++) {
							sumA += $M.toNum(gridDataA[i].free_standard_hour);
						}
						for(var i=0; i<gridDataB.length; i++) {
							sumB += $M.toNum(gridDataB[i].free_standard_hour);
						}

						result = (sumB == 0 ? 0 : $M.toNum((sumA - sumB) / sumB));
						
						return result.toFixed(2);
					}
				},
				{
					dataField: "m_free_part_amt",
					positionField: "m_free_part_amt",
					formatString: "#,##0.0#",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridDataA = AUIGrid.getGridData(auiGrid);
						var gridDataB = AUIGrid.getGridData(auiGridB);
						var sumA = 0;
						var sumB = 0;
						var result = 0.0;
						
						for (var i = 0; i < gridDataA.length; i++) {
							sumA += $M.toNum(gridDataA[i].m_free_part_amt);
						}
						for(var i=0; i<gridDataB.length; i++) {
							sumB += $M.toNum(gridDataB[i].m_free_part_amt);
						}

						result = (sumB == 0 ? 0 : $M.toNum((sumA - sumB) / sumB));
						
						return result;
					}
				},
				{
					dataField: "free_travel_amt",
					positionField: "free_travel_amt",
					formatString: "#,##0.0#",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridDataA = AUIGrid.getGridData(auiGrid);
						var gridDataB = AUIGrid.getGridData(auiGridB);
						var sumA = 0;
						var sumB = 0;
						var result = 0.0;
						
						for (var i = 0; i < gridDataA.length; i++) {
							sumA += $M.toNum(gridDataA[i].free_travel_amt);
						}
						for(var i=0; i<gridDataB.length; i++) {
							sumB += $M.toNum(gridDataB[i].free_travel_amt);
						}

						result = (sumB == 0 ? 0 : $M.toNum((sumA - sumB) / sumB));
						
						return result;
					}
				},
				{
					dataField: "free_work_amt",
					positionField: "free_work_amt",
					formatString: "#,##0.0#",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridDataA = AUIGrid.getGridData(auiGrid);
						var gridDataB = AUIGrid.getGridData(auiGridB);
						var sumA = 0;
						var sumB = 0;
						var result = 0.0;
						
						for (var i = 0; i < gridDataA.length; i++) {
							sumA += $M.toNum(gridDataA[i].free_work_amt);
						}
						for(var i=0; i<gridDataB.length; i++) {
							sumB += $M.toNum(gridDataB[i].free_work_amt);
						}

						result = (sumB == 0 ? 0 : $M.toNum((sumA - sumB) / sumB));
						
						return result;
					}
				},
				{
					dataField: "free_amt",
					positionField: "free_amt",
					formatString: "#,##0.0#",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridDataA = AUIGrid.getGridData(auiGrid);
						var gridDataB = AUIGrid.getGridData(auiGridB);
						var sumA = 0;
						var sumB = 0;
						var result = 0.0;
						
						for (var i = 0; i < gridDataA.length; i++) {
							sumA += $M.toNum(gridDataA[i].free_amt);
						}
						for(var i=0; i<gridDataB.length; i++) {
							sumB += $M.toNum(gridDataB[i].free_amt);
						}

						result = (sumB == 0 ? 0 : $M.toNum((sumA - sumB) / sumB));
						
						return result;
					}
				},
				{
					dataField: "warranty_amt",
					positionField: "warranty_amt",
					formatString: "#,##0.0#",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridDataA = AUIGrid.getGridData(auiGrid);
						var gridDataB = AUIGrid.getGridData(auiGridB);
						var sumA = 0;
						var sumB = 0;
						var result = 0.0;

						for (var i = 0; i < gridDataA.length; i++) {
							sumA += $M.toNum(gridDataA[i].warranty_amt);
						}
						for(var i=0; i<gridDataB.length; i++) {
							sumB += $M.toNum(gridDataB[i].warranty_amt);
						}

						result = (sumB == 0 ? 0 : $M.toNum((sumA - sumB) / sumB));

						return result;
					}
				},
				{
					dataField: "out_cost_amt",
					positionField: "out_cost_amt",
					formatString: "#,##0.0#",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridDataA = AUIGrid.getGridData(auiGrid);
						var gridDataB = AUIGrid.getGridData(auiGridB);
						var sumA = 0;
						var sumB = 0;
						var result = 0.0;
						
						for (var i = 0; i < gridDataA.length; i++) {
							sumA += $M.toNum(gridDataA[i].out_cost_amt);
						}
						for(var i=0; i<gridDataB.length; i++) {
							sumB += $M.toNum(gridDataB[i].out_cost_amt);
						}

						result = (sumB == 0 ? 0 : $M.toNum((sumA - sumB) / sumB));
						
						return result;
					}
				},
				{
					dataField: "free_cost_amt",
					positionField: "free_cost_amt",
					formatString: "#,##0.0#",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridDataA = AUIGrid.getGridData(auiGrid);
						var gridDataB = AUIGrid.getGridData(auiGridB);
						var sumA = 0;
						var sumB = 0;
						var result = 0.0;
						
						for (var i = 0; i < gridDataA.length; i++) {
							sumA += $M.toNum(gridDataA[i].free_cost_amt);
						}
						for(var i=0; i<gridDataB.length; i++) {
							sumB += $M.toNum(gridDataB[i].free_cost_amt);
						}

						result = (sumB == 0 ? 0 : $M.toNum((sumA - sumB) / sumB));
						
						return result;
					}
				},
				{
					dataField: "free_total_amt",
					positionField: "free_total_amt",
					formatString: "#,##0.0#",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridDataA = AUIGrid.getGridData(auiGrid);
						var gridDataB = AUIGrid.getGridData(auiGridB);
						var sumA = 0;
						var sumB = 0;
						var result = 0.0;

						for (var i = 0; i < gridDataA.length; i++) {
							sumA += $M.toNum(gridDataA[i].free_total_amt);
						}
						for(var i=0; i<gridDataB.length; i++) {
							sumB += $M.toNum(gridDataB[i].free_total_amt);
						}

						result = (sumB == 0 ? 0 : $M.toNum((sumA - sumB) / sumB));

						return result;
					}
				},
				// {
				// 	dataField: "service_profit_amt",
				// 	positionField: "service_profit_amt",
				// 	formatString: "#,##0.0#",
				// 	style: "aui-right aui-footer",
				// 	expFunction : function(columnValues) {
				// 		var gridDataA = AUIGrid.getGridData(auiGrid);
				// 		var gridDataB = AUIGrid.getGridData(auiGridB);
				// 		var sumA = 0;
				// 		var sumB = 0;
				// 		var result = 0.0;
				//
				// 		for (var i = 0; i < gridDataA.length; i++) {
				// 			sumA += $M.toNum(gridDataA[i].service_profit_amt);
				// 		}
				// 		for(var i=0; i<gridDataB.length; i++) {
				// 			sumB += $M.toNum(gridDataB[i].service_profit_amt);
				// 		}
				//
				// 		result = (sumB == 0 ? 0 : $M.toNum((sumA - sumB) / sumB));
				//
				// 		return result;
				// 	}
				// },
				// {
				// 	dataField: "free_sale_amt",
				// 	positionField: "free_sale_amt",
				// 	formatString: "#,##0.0#",
				// 	style: "aui-right aui-footer",
				// 	expFunction : function(columnValues) {
				// 		var gridDataA = AUIGrid.getGridData(auiGrid);
				// 		var gridDataB = AUIGrid.getGridData(auiGridB);
				// 		var sumA = 0;
				// 		var sumB = 0;
				// 		var result = 0.0;
				//
				// 		for (var i = 0; i < gridDataA.length; i++) {
				// 			sumA += $M.toNum(gridDataA[i].free_sale_amt);
				// 		}
				// 		for(var i=0; i<gridDataB.length; i++) {
				// 			sumB += $M.toNum(gridDataB[i].free_sale_amt);
				// 		}
				//
				// 		result = (sumB == 0 ? 0 : $M.toNum((sumA - sumB) / sumB));
				//
				// 		return result;
				// 	}
				// },
				// {
				// 	dataField: "free_profit_amt",
				// 	positionField: "free_profit_amt",
				// 	formatString: "#,##0.0#",
				// 	style: "aui-right aui-footer",
				// 	expFunction : function(columnValues) {
				// 		var gridDataA = AUIGrid.getGridData(auiGrid);
				// 		var gridDataB = AUIGrid.getGridData(auiGridB);
				// 		var sumA = 0;
				// 		var sumB = 0;
				// 		var result = 0.0;
				//
				// 		for (var i = 0; i < gridDataA.length; i++) {
				// 			sumA += $M.toNum(gridDataA[i].free_profit_amt);
				// 		}
				// 		for(var i=0; i<gridDataB.length; i++) {
				// 			sumB += $M.toNum(gridDataB[i].free_profit_amt);
				// 		}
				//
				// 		result = (sumB == 0 ? 0 : $M.toNum((sumA - sumB) / sumB));
				//
				// 		return result;
				// 	}
				// },
				{
					dataField: "part_amt",
					positionField: "part_amt",
					formatString: "#,##0.0#",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridDataA = AUIGrid.getGridData(auiGrid);
						var gridDataB = AUIGrid.getGridData(auiGridB);
						var sumA = 0;
						var sumB = 0;
						var result = 0.0;
						
						for (var i = 0; i < gridDataA.length; i++) {
							sumA += $M.toNum(gridDataA[i].part_amt);
						}
						for(var i=0; i<gridDataB.length; i++) {
							sumB += $M.toNum(gridDataB[i].part_amt);
						}

						result = (sumB == 0 ? 0 : $M.toNum((sumA - sumB) / sumB));
						
						return result;
					}
				},
				{
					dataField: "part_profit_amt",
					positionField: "part_profit_amt",
					formatString: "#,##0.0#",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridDataA = AUIGrid.getGridData(auiGrid);
						var gridDataB = AUIGrid.getGridData(auiGridB);
						var sumA = 0;
						var sumB = 0;
						var result = 0.0;
						
						for (var i = 0; i < gridDataA.length; i++) {
							sumA += $M.toNum(gridDataA[i].part_profit_amt);
						}
						for(var i=0; i<gridDataB.length; i++) {
							sumB += $M.toNum(gridDataB[i].part_profit_amt);
						}

						result = (sumB == 0 ? 0 : $M.toNum((sumA - sumB) / sumB));
						
						return result;
					}
				},
				{
					dataField: "re_as_repair_cnt",
					positionField: "re_as_repair_cnt",
					formatString: "#,##0.0#",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridDataA = AUIGrid.getGridData(auiGrid);
						var gridDataB = AUIGrid.getGridData(auiGridB);
						var sumA = 0;
						var sumB = 0;
						var result = 0.0;
						
						for (var i = 0; i < gridDataA.length; i++) {
							sumA += $M.toNum(gridDataA[i].re_as_repair_cnt);
						}
						for(var i=0; i<gridDataB.length; i++) {
							sumB += $M.toNum(gridDataB[i].re_as_repair_cnt);
						}

						result = (sumB == 0 ? 0 : $M.toNum((sumA - sumB) / sumB));
						
						return result;
					}
				},
				{
					dataField: "machine_used_profit_amt",
					positionField: "machine_used_profit_amt",
					formatString: "#,##0.0#",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridDataA = AUIGrid.getGridData(auiGrid);
						var gridDataB = AUIGrid.getGridData(auiGridB);
						var sumA = 0;
						var sumB = 0;
						var result = 0.0;
						
						for (var i = 0; i < gridDataA.length; i++) {
							sumA += $M.toNum(gridDataA[i].machine_used_profit_amt);
						}
						for(var i=0; i<gridDataB.length; i++) {
							sumB += $M.toNum(gridDataB[i].machine_used_profit_amt);
						}

						result = (sumB == 0 ? 0 : $M.toNum((sumA - sumB) / sumB));
						
						return result;
					}
				},
				// {
				// 	dataField: "rental_job_hour",
				// 	positionField: "rental_job_hour",
				// 	formatString: "#,##0.0####",
				// 	style: "aui-right aui-footer",
				// 	expFunction : function(columnValues) {
				// 		var gridDataA = AUIGrid.getGridData(auiGrid);
				// 		var gridDataB = AUIGrid.getGridData(auiGridB);
				// 		var sumA = 0;
				// 		var sumB = 0;
				// 		var result = 0.0;
				//
				// 		for (var i = 0; i < gridDataA.length; i++) {
				// 			sumA += $M.toNum(gridDataA[i].rental_job_hour);
				// 		}
				// 		for(var i=0; i<gridDataB.length; i++) {
				// 			sumB += $M.toNum(gridDataB[i].rental_job_hour);
				// 		}
				//
				// 		result = (sumB == 0 ? 0 : $M.toNum((sumA - sumB) / sumB));
				//
				// 		return result.toFixed(2);
				// 	}
				// },
				{
					dataField: "rental_rent_amt",
					positionField: "rental_rent_amt",
					formatString: "#,##0.0#",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridDataA = AUIGrid.getGridData(auiGrid);
						var gridDataB = AUIGrid.getGridData(auiGridB);
						var sumA = 0;
						var sumB = 0;
						var result = 0.0;
						
						for (var i = 0; i < gridDataA.length; i++) {
							sumA += $M.toNum(gridDataA[i].rental_rent_amt);
						}
						for(var i=0; i<gridDataB.length; i++) {
							sumB += $M.toNum(gridDataB[i].rental_rent_amt);
						}

						result = (sumB == 0 ? 0 : $M.toNum((sumA - sumB) / sumB));
						
						return result;
					}
				},
				{
					dataField: "rental_repair_amt",
					positionField: "rental_repair_amt",
					formatString: "#,##0.0#",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridDataA = AUIGrid.getGridData(auiGrid);
						var gridDataB = AUIGrid.getGridData(auiGridB);
						var sumA = 0;
						var sumB = 0;
						var result = 0.0;

						for (var i = 0; i < gridDataA.length; i++) {
							sumA += $M.toNum(gridDataA[i].rental_repair_amt);
						}
						for(var i=0; i<gridDataB.length; i++) {
							sumB += $M.toNum(gridDataB[i].rental_repair_amt);
						}

						result = (sumB == 0 ? 0 : $M.toNum((sumA - sumB) / sumB));

						return result;
					}
				},
				{
					dataField: "reduce_total_amt",
					positionField: "reduce_total_amt",
					formatString: "#,##0.0#",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridDataA = AUIGrid.getGridData(auiGrid);
						var gridDataB = AUIGrid.getGridData(auiGridB);
						var sumA = 0;
						var sumB = 0;
						var result = 0.0;
						
						for (var i = 0; i < gridDataA.length; i++) {
							sumA += $M.toNum(gridDataA[i].reduce_total_amt);
						}
						for(var i=0; i<gridDataB.length; i++) {
							sumB += $M.toNum(gridDataB[i].reduce_total_amt);
						}

						result = (sumB == 0 ? 0 : $M.toNum((sumA - sumB) / sumB));
						
						return result;
					}
				},
				{
					dataField: "re_rental",
					positionField: "re_rental",
					formatString: "#,##0.0#",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridDataA = AUIGrid.getGridData(auiGrid);
						var gridDataB = AUIGrid.getGridData(auiGridB);
						var sumA = 0;
						var sumB = 0;
						var result = 0.0;
						
						for (var i = 0; i < gridDataA.length; i++) {
							sumA += $M.toNum(gridDataA[i].re_rental);
						}
						for(var i=0; i<gridDataB.length; i++) {
							sumB += $M.toNum(gridDataB[i].re_rental);
						}

						result = (sumB == 0 ? 0 : $M.toNum((sumA - sumB) / sumB));
						
						return result;
					}
				},
				{
					dataField: "rental_profit_amt",
					positionField: "rental_profit_amt",
					formatString: "#,##0.0#",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridDataA = AUIGrid.getGridData(auiGrid);
						var gridDataB = AUIGrid.getGridData(auiGridB);
						var sumA = 0;
						var sumB = 0;
						var result = 0.0;

						for (var i = 0; i < gridDataA.length; i++) {
							sumA += $M.toNum(gridDataA[i].rental_profit_amt);
						}
						for(var i=0; i<gridDataB.length; i++) {
							sumB += $M.toNum(gridDataB[i].rental_profit_amt);
						}

						result = (sumB == 0 ? 0 : $M.toNum((sumA - sumB) / sumB));

						return result;
					}
				},
				// {
				// 	dataField: "out_servcie_amt",
				// 	positionField: "out_servcie_amt",
				// 	formatString: "#,##0.0#",
				// 	style: "aui-right aui-footer",
				// 	expFunction : function(columnValues) {
				// 		var gridDataA = AUIGrid.getGridData(auiGrid);
				// 		var gridDataB = AUIGrid.getGridData(auiGridB);
				// 		var sumA = 0;
				// 		var sumB = 0;
				// 		var result = 0.0;
				//
				// 		for (var i = 0; i < gridDataA.length; i++) {
				// 			sumA += $M.toNum(gridDataA[i].out_servcie_amt);
				// 		}
				// 		for(var i=0; i<gridDataB.length; i++) {
				// 			sumB += $M.toNum(gridDataB[i].out_servcie_amt);
				// 		}
				//
				// 		result = (sumB == 0 ? 0 : $M.toNum((sumA - sumB) / sumB));
				//
				// 		return result;
				// 	}
				// },
				{
					dataField: "service_account_amt",
					positionField: "service_account_amt",
					formatString: "#,##0.0#",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridDataA = AUIGrid.getGridData(auiGrid);
						var gridDataB = AUIGrid.getGridData(auiGridB);
						var sumA = 0;
						var sumB = 0;
						var result = 0.0;
						
						for (var i = 0; i < gridDataA.length; i++) {
							sumA += $M.toNum(gridDataA[i].service_account_amt);
						}
						for(var i=0; i<gridDataB.length; i++) {
							sumB += $M.toNum(gridDataB[i].service_account_amt);
						}

						result = (sumB == 0 ? 0 : $M.toNum((sumA - sumB) / sumB));
						
						return result;
					}
				},
				{
					dataField: "tot_amt",
					positionField: "tot_amt",
					formatString: "#,##0.0#",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridDataA = AUIGrid.getGridData(auiGrid);
						var gridDataB = AUIGrid.getGridData(auiGridB);
						var sumA = 0;
						var sumB = 0;
						var result = 0.0;

						for (var i = 0; i < gridDataA.length; i++) {
							sumA += $M.toNum(gridDataA[i].tot_amt);
						}
						for(var i=0; i<gridDataB.length; i++) {
							sumB += $M.toNum(gridDataB[i].tot_amt);
						}

						result = (sumB == 0 ? 0 : $M.toNum((sumA - sumB) / sumB));

						return result;
					}
				},
				{
					dataField: "tot_profit",
					positionField: "tot_profit",
					formatString: "#,##0.0#",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridDataA = AUIGrid.getGridData(auiGrid);
						var gridDataB = AUIGrid.getGridData(auiGridB);
						var sumA = 0;
						var sumB = 0;
						var result = 0.0;
						
						for (var i = 0; i < gridDataA.length; i++) {
							sumA += $M.toNum(gridDataA[i].tot_profit);
						}
						for(var i=0; i<gridDataB.length; i++) {
							sumB += $M.toNum(gridDataB[i].tot_profit);
						}

						result = (sumB == 0 ? 0 : $M.toNum((sumA - sumB) / sumB));
						
						return result;
					}
				},
				{
					dataField: "temp_mbo_amt",
					positionField: "temp_mbo_amt",
					formatString: "#,##0.0#",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridDataA = AUIGrid.getGridData(auiGrid);
						var gridDataB = AUIGrid.getGridData(auiGridB);
						var sumA = 0;
						var sumB = 0;
						var result = 0.0;
						
						for (var i = 0; i < gridDataA.length; i++) {
							sumA += $M.toNum(gridDataA[i].temp_mbo_amt);
						}
						for(var i=0; i<gridDataB.length; i++) {
							sumB += $M.toNum(gridDataB[i].temp_mbo_amt);
						}

						result = (sumB == 0 ? 0 : $M.toNum((sumA - sumB) / sumB));
						
						return result;
					}
				},
				{
					dataField: "temp_mbo_amt_2",
					positionField: "temp_mbo_amt_2",
					formatString: "#,##0.0#",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var gridDataA = AUIGrid.getGridData(auiGrid);
						var gridDataB = AUIGrid.getGridData(auiGridB);
						var sumA = 0;
						var sumB = 0;
						var result = 0.0;

						for (var i = 0; i < gridDataA.length; i++) {
							sumA += $M.toNum(gridDataA[i].temp_mbo_amt_2);
						}
						for(var i=0; i<gridDataB.length; i++) {
							sumB += $M.toNum(gridDataB[i].temp_mbo_amt_2);
						}

						result = (sumB == 0 ? 0 : $M.toNum((sumA - sumB) / sumB));

						return result;
					}
				},
			];

			// 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setFooter(auiGrid, footerColumnLayout);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();

			// 펼치기 전에 접힐 컬럼 목록
			var auiColList = AUIGrid.getColumnInfoList(auiGrid);
			for (var i = 0; i <auiColList.length; ++i) {
				if (auiColList[i].headerStyle != null && auiColList[i].headerStyle == "aui-fold") {
					dataFieldName.push(auiColList[i].dataField);
				}
			}

			for (var i = 0; i < dataFieldName.length; ++i) {
				var dataField = dataFieldName[i];
				AUIGrid.hideColumnByDataField(auiGrid, dataField);
			}

			$("#auiGrid").resize();

			AUIGrid.bind(auiGrid, "cellClick", function (event) {
				if (event.value == 0) {
					return;
				}

				var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=300, height=200, left=0, top=0";
				var params = {
					"year_mon": event.item.yyyymm,
					"s_org_code": $M.getValue("s_org_code")
				};

				// 서비스업무평가
				if (event.dataField == "as_tot" || event.dataField == "as_call_cnt"
						|| event.dataField == "as_cost_repair_cnt" || event.dataField == "as_free_repair_cnt" || event.dataField == "as_repair_tot") {

					if (event.dataField == "as_call_cnt") {
						params.type = "CALL"; // 전화
					} else if (event.dataField == "as_cost_repair_cnt") {
						params.type = "Y"; // 유상
					} else if (event.dataField == "as_free_repair_cnt") {
						params.type = "N"; // 무상
					} else if (event.dataField == "as_repair_tot") {
						params.type = "REPAIR"; // 유상+무상
					}

					$M.goNextPage('/serv/serv0501p01', $M.toGetParam(params), {popupStatus: popupOption});
				}

				// 유상정비시간평가
				if (event.dataField == "cost_move_hour" || event.dataField == "cost_repair_hour" || event.dataField == "cost_standard_hour") {
					$M.goNextPage('/serv/serv0501p02', $M.toGetParam(params), {popupStatus: popupOption});
				}

				// 유상정비금액
				if(event.dataField == "cost_part_amt" || event.dataField == "cost_travel_amt" || event.dataField == "cost_work_amt") {
					$M.goNextPage('/serv/serv0501p03', $M.toGetParam(params), {popupStatus: popupOption});
				}

				// 무상정비시간평가
				if(event.dataField == "free_move_hour" || event.dataField == "free_repair_hour" || event.dataField == "free_standard_hour") {
					$M.goNextPage('/serv/serv0501p04', $M.toGetParam(params), {popupStatus: popupOption});
				}

				// 무상정비금액
				if(event.dataField == "m_free_part_amt" || event.dataField == "free_travel_amt" || event.dataField == "free_work_amt") {

					/* if (event.dataField == "m_free_part_amt") {
						params.type = "1"; // 부품비
					} else if (event.dataField == "free_travel_amt" || event.dataField == "free_work_amt") {
						params.type = "2"; // 출장비,공임
					} */
					
					// 무상부품, 무상출장, 무상공임 같이 보여줌
					if (event.dataField == "free_travel_amt" || event.dataField == "free_work_amt" || event.dataField == "m_free_part_amt") {
						params.type = "2"; // 출장비,공임
					}

					$M.goNextPage('/serv/serv0501p05', $M.toGetParam(params), {popupStatus: popupOption});
				}
				
				// 서비스비용(무상정비)
				if(event.dataField == "out_cost_amt" || event.dataField == "free_cost_amt") {
					if(event.dataField == "free_cost_amt"){
						params.free_cost_yn = "Y"; // 23.12.07 서비스 비용 이관 기능 추가로 인하여 구분
					}
					$M.goNextPage('/serv/serv0501p15', $M.toGetParam(params), {popupStatus: popupOption});
				}

				// 부품판매 전표
				if(event.dataField == "part_amt") {
					$M.goNextPage('/serv/serv0501p08', $M.toGetParam(params), {popupStatus: popupOption});
				}

				// 렌탈 수리비
				if(event.dataField == "rental_rent_amt" || event.dataField == "rental_repair_amt") {

					if (event.dataField == "rental_rent_amt") {
						params.type = "1"; // 렌탈료
						params.page_type = "center";
					} else if (event.dataField == "rental_repair_amt") {
						params.type = "2"; // 수리비용
					}

					// $M.goNextPage('/serv/serv0501p06', $M.toGetParam(params), {popupStatus: popupOption});
					$M.goNextPage('/serv/serv051401p0202', $M.toGetParam(params), {popupStatus: popupOption});
				}

				// 정비내용평가 & AS전산평가(출하지원금)
				if(event.dataField == "out_servcie_amt") {
					params.s_center_page = "Y";
					params.out_svc_amt = 'Y';
					$M.goNextPage('/serv/serv0501p07', $M.toGetParam(params), {popupStatus: popupOption});
				}

				// 재벙비건수
				if(event.dataField == "re_as_repair_cnt") {
					$M.goNextPage('/serv/serv0501p09', $M.toGetParam(params), {popupStatus: popupOption});
				}

				// 센터간 재렌탈 수익 정산리스트
				if(event.dataField == "re_rental") {
					$M.goNextPage('/serv/serv0501p10', $M.toGetParam(params), {popupStatus: popupOption});
				}

				// 신차 판매 리스트
				if(event.dataField == "service_account_amt") {
					$M.goNextPage('/serv/serv0501p11', $M.toGetParam(params), {popupStatus: popupOption});
				}

				// 감가
				if(event.dataField == "reduce_total_amt") {
					$M.goNextPage('/serv/serv0501p12', $M.toGetParam(params), {popupStatus: popupOption});
				}

				// 중고손익
				if(event.dataField == "machine_used_profit_amt") {
					params = {
						"s_year_mon" : event.item.yyyymm,
						"s_org_code": $M.getValue("s_org_code")
					};
					$M.goNextPage('/serv/serv0501p17', $M.toGetParam(params), {popupStatus: popupOption});
				}

				// 렌탈업무시간
				if(event.dataField == "rental_job_hour") {
					params = {
						"s_year_mon" : event.item.yyyymm,
						"s_org_code": $M.getValue("s_org_code")
					};
					$M.goNextPage('/serv/serv0501p18', $M.toGetParam(params), {popupStatus: popupOption});
				}

				// 워렌티 비용
				if(event.dataField == "warranty_amt") {
					params = {
						"s_year_mon" : event.item.yyyymm,
						"s_org_code": $M.getValue("s_org_code")
					};
					$M.goNextPage('/serv/serv051401p0203', $M.toGetParam(params), {popupStatus: popupOption});
				}
			});
		}

		function createAUIGridB() {
			var gridPros = {
				editable: false,
				// rowIdField 설정
				rowIdField: "_$uid",
				// rowIdField가 unique 임을 보장
				rowIdTrustMode: true,
			};
			var columnLayout = [
				{
					headerText: "년월",
					dataField: "yyyymm",
					dataType: "date",
					formatString: "yyyy-mm",
					width: "5%",
				},
				{
					headerText: "서비스업무평가",
					children: [
						{
							headerText: "전체",
							dataField: "as_tot",
						},
						{
							headerText: "전화",
							dataField: "as_call_cnt",
						},
						{
							headerText: "유상",
							dataField: "as_cost_repair_cnt",
						},
						{
							headerText: "무상",
							dataField: "as_free_repair_cnt",
						},
						{
							headerText: "유상+무상",
							dataField: "as_repair_tot",
						},
						{
							headerText: "유무상규정H",
							dataField: "sum_standard_hour",
						},
						{
							headerText: "유무상이동H",
							dataField: "sum_move_hour",
						},
						{
							headerText: "렌탈H",
							dataField: "rental_job_hour",
						},
						{
							headerText: "유효활동시간",
							dataField: "tot_valid_hour",
						}
					]
				},
				{
					headerText: "유상정비집계",
					children: [
						{
							headerText: "이동H",
							dataField: "cost_move_hour",
						},
						{
							headerText: "정비H",
							dataField: "cost_repair_hour",
						},
						{
							headerText: "규정H",
							dataField: "cost_standard_hour",
						},
						{
							headerText: "부품비",
							dataField: "cost_part_amt",
						},
						{
							headerText: "출장비",
							dataField: "cost_travel_amt",
						},
						{
							headerText: "공임",
							dataField: "cost_work_amt",
						}
					]
				},
				{
					headerText: "유상 정비",
					children: [
						{
							headerText: "매출집계",
							dataField: "cost_amt",
						},
						{
							headerText: "순익(부품15%)",
							dataField: "cost_profit_amt",
						}
					]
				},
				{
					headerText: "무상정비집계",
					children: [
						{
							headerText: "이동H",
							dataField: "free_move_hour",
						},
						{
							headerText: "정비H",
							dataField: "free_repair_hour",
						},
						{
							headerText: "규정H",
							dataField: "free_standard_hour",
						},
						{
							headerText: "부품비",
							dataField: "m_free_part_amt",
						},
						{
							headerText: "출장비",
							dataField: "free_travel_amt",
						},
						{
							headerText: "공임",
							dataField: "free_work_amt",
						},
						{
							headerText: "지출집계",
							dataField: "free_amt",
						},
						{
							headerText: "워렌티비용",
							dataField: "warranty_amt",
						},
						{
							headerText: "출하정비비용",
							dataField: "out_cost_amt"
						},
						{
							headerText: "서비스비용합계",
							dataField: "free_cost_amt"
						},
						{
							headerText: "종합",
							dataField: "free_total_amt"
						},
					]
				},
				{
					headerText: "무상정비",
					children: [
						// {
						// 	headerText: "지출집계",
						// 	dataField: "free_amt",
						// },
						// {
						// 	headerText: "워렌티비용",
						// 	dataField: "warranty_amt",
						// },
						// {
						// 	headerText: "출하정비비용",
						// 	dataField: "out_cost_amt"
						// },
						// {
						// 	headerText: "서비스비용합계",
						// 	dataField: "free_cost_amt"
						// },
						// {
						// 	headerText: "종합",
						// 	dataField: "free_total_amt"
						// },
						// {
						// 	headerText: "서비스잔여수익",
						// 	dataField: "service_profit_amt"
						// },
						// {
						// 	headerText: "매출집계(M)",
						// 	dataField: "free_sale_amt",
						// },
						// {
						// 	headerText: "순익(부품15%)",
						// 	dataField: "free_profit_amt",
						// }
					]
				},
				{
					headerText: "부품판매",
					dataField: "part_amt",
				},
				{
					headerText: "부품판매(15%)",
					dataField: "part_profit_amt",
				},
				{
					headerText: "재정비",
					dataField: "re_as_repair_cnt",
				},
				{
					headerText: "중고손익",
					dataField: "machine_used_profit_amt",
				},
				{
					headerText: "렌탈집계",
					children: [
						{
							headerText: "렌탈료",
							dataField: "rental_rent_amt",
						},
						{
							headerText: "수리비용",
							dataField: "rental_repair_amt",
						},
						{
							headerText: "감가",
							dataField: "reduce_total_amt",
						},
						{
							headerText: "재렌탈",
							dataField: "re_rental",
						}
					]
				},
				{
					headerText: "렌탈순익",
					dataField: "rental_profit_amt",
				},
				// {
				// 	headerText: "출하지원금",
				// 	dataField: "out_servcie_amt",
				// },
				{
					headerText: "신차 판매 정산",
					dataField: "service_account_amt",
				},
				{
					headerText: "최종매출",
					dataField: "tot_amt",
				},
				{
					headerText: "최종순익",
					dataField: "tot_profit",
				},
				{
					headerText: "MBO",
					dataField: "temp_mbo_amt",
				},
				{
					headerText: "MBO 달성율",
					dataField: "temp_mbo_amt_2",
				}
			]

			// 그리드 생성
			auiGridB = AUIGrid.create("#auiGridB", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGridB, []);
			$("#auiGridB").resize();
		}

		//닫기
		function fnClose() {
			window.close();
		}

		//엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "센터별 실적분석", "");
		}

		// 그래프 보기 팝업 호출
		function goGraphPopup() {
			var params = {
				"s_end_year" : $M.getValue("s_end_year"),
				"s_org_code" : $M.getValue("s_org_code")
			};
			var poppupOption = "";
			$M.goNextPage('/serv/serv051401p0201', $M.toGetParam(params), {popupStatus: poppupOption});
		}

		// 펼침
		function fnChangeColumn(event) {
			var data = AUIGrid.getGridData(auiGrid);
			var target = event.target || event.srcElement;
			if(!target)	return;

			var dataField = target.value;
			var checked = target.checked;

			for (var i = 0; i < dataFieldName.length; ++i) {
				var dataField = dataFieldName[i];

				if(checked) {
					AUIGrid.showColumnByDataField(auiGrid, dataField);
				} else {
					AUIGrid.hideColumnByDataField(auiGrid, dataField);
				}
			}

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
	            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
	        </div>
	<!-- /타이틀영역 -->
	        <div class="content-wrap">
	<!-- 검색조건 -->
				<div class="search-wrap mt5">
					<table class="table">
						<colgroup>
							<col width="65px">
							<col width="280px">
							<col width="40px">
							<col width="130px">
							<col width="">
						</colgroup>
						<tbody>
							<tr>
								<th>조회년도</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-auto">
											<select class="form-control" id="s_start_year" name="s_start_year">
												<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
													<c:set var="year_option" value="${inputParam.s_current_year - i + 2000}" />
													<option value="${year_option}" <c:if test="${year_option eq inputParam.s_start_year}">selected</c:if>>${year_option}년</option>
												</c:forEach>
											</select>
										</div>
										<div class="col-auto">
											<select class="form-control" id="s_start_mon" name="s_start_mon">
												<c:forEach var="i" begin="1" end="12" step="1">
													<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i eq inputParam.s_start_mon}">selected</c:if>>${i}월</option>
												</c:forEach>
											</select>
										</div>
										<div class="col-auto">~</div>
										<div class="col-auto">
											<select class="form-control" id="s_end_year" name="s_end_year">
												<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
													<c:set var="year_option" value="${inputParam.s_current_year - i + 2000}" />
													<option value="${year_option}" <c:if test="${year_option eq inputParam.s_end_year}">selected</c:if>>${year_option}년</option>
												</c:forEach>
											</select>
										</div>
										<div class="col-auto">
											<select class="form-control" id="s_end_mon" name="s_end_mon">
												<c:forEach var="i" begin="1" end="12" step="1">
													<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i eq inputParam.s_end_mon}">selected</c:if>>${i}월</option>
												</c:forEach>
											</select>
										</div>
									</div>
								</td>
								<th>센터</th>
								<td>
									<select class="form-control" id="s_org_code" name="s_org_code">
										<option value="">- 전체 -</option>
										<c:forEach var="item" items="${orgList}">
											<option value="${item.org_code}" <c:if test="${i eq SecureUser.org_code}">selected="selected"></c:if>>${item.org_kor_name}</option>
										</c:forEach>
									</select>
								</td>
								<td class=""><button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();" >조회</button></td>
							</tr>
						</tbody>
					</table>
				</div>
	<!-- /검색조건 -->
	<!-- 폼테이블 -->					
				<div>
					<div class="title-wrap mt10">
						<h4>조회결과</h4>
						<div class="btn-group">
							<div class="right">
								<div class="form-check form-check-inline">
									<label for="s_toggle_column" style="color:black;">
										<input type="checkbox" id="s_toggle_column" onclick="javascript:fnChangeColumn(event)">펼침
									</label>
								</div>
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
						<div id="auiGrid" style="margin-top: 5px; height: 460px;"></div>
						<div id="auiGridB" style="margin-top: 5px; height: 460px; display:none;"></div>
				</div>
	<!-- /폼테이블-->					
				<div class="btn-group mt10">
					<div class="left" style="flex: 2">
						부품부 조회 시, 부품판매현황-기간별 년간 메뉴의 최종매출은 C+E, 최종 수익은 A3로 조회합니다. 전체 조회 시, 부품부의 부품판매 실적은 제외합니다. <br>
						수주 또는 정비의 YK배송료 품목은 유상정비로 들어갑니다.<br>
						중고손익은 렌탈판매처리 할 때, 판매센터수익+수익배분금액입니다.
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