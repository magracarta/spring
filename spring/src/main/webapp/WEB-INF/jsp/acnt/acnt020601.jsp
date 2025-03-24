<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 장부 > 자산현황 및 재무제표 > 자산현황 > null
-- 작성자 : 황빛찬
-- 최초 작성일 : 2023-10-24 10:43:00
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGridTop;
		var auiGridBot;
		var searchTypeDate;
		$(document).ready(function () {
			createAUIGridTop();
			createAUIGridBot();

			goSearch();
		});

		function createAUIGridTop() {
			var gridPros = {
				rowIdField : "_$uid",
				showFooter : true,
				footerPosition : "top",
				showRowNumColumn: false,
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
					headerText : "구분",
					dataField : "gubun",
					width : "90",
					minWidth : "80",
				},
				{
					headerText : "전월재고",
					children : [
						{
							dataField : "bef_month_stock_cnt",
							headerText : "수량",
							width : "70",
							minWidth : "70",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								return value == 0 ? "" : $M.setComma(value);
							},
							style : "aui-right"
						},
						{
							dataField : "bef_month_stock_amt",
							headerText : "금액",
							width : "130",
							minWidth : "70",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								return value == 0 ? "" : $M.setComma(value);
							},
							style : "aui-right aui-link"
						},
					]
				},
				{
					headerText : "당월입고",
					children : [
						{
							dataField : "curr_month_in_cnt",
							headerText : "수량",
							width : "70",
							minWidth : "70",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								return value == 0 ? "" : $M.setComma(value);
							},
							style : "aui-right"
						},
						{
							dataField : "curr_month_in_amt",
							headerText : "금액",
							width : "130",
							minWidth : "70",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								return value == 0 ? "" : $M.setComma(value);
							},
							style : "aui-right aui-link"
						},
					]
				},
				{
					headerText : "당월판매",
					children : [
						{
							dataField : "curr_month_sale_cnt",
							headerText : "수량",
							width : "70",
							minWidth : "50",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								return value == 0 ? "" : $M.setComma(value);
							},
							style : "aui-right"
						},
						{
							dataField : "curr_month_sale_amt",
							headerText : "금액",
							width : "130",
							minWidth : "70",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								return value == 0 ? "" : $M.setComma(value);
							},
							style : "aui-right aui-link"
						},
					]
				},
				{
					headerText : "송금완료",
					children : [
						{
							dataField : "remit_proc_cnt",
							headerText : "수량",
							width : "70",
							minWidth : "50",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								return value == 0 ? "" : $M.setComma(value);
							},
							style : "aui-right"
						},
						{
							dataField : "remit_proc_amt",
							headerText : "금액",
							width : "130",
							minWidth : "70",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								return value == 0 ? "" : $M.setComma(value);
							},
							style : "aui-right aui-link"
						},
					]
				},
				{
					headerText : "당월재고",
					children : [
						{
							dataField : "curr_month_stock_cnt",
							headerText : "수량",
							width : "70",
							minWidth : "70",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								return value == 0 ? "" : $M.setComma(value);
							},
							style : "aui-right"
						},
						{
							dataField : "curr_month_stock_amt",
							headerText : "금액",
							width : "130",
							minWidth : "70",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								return value == 0 ? "" : $M.setComma(value);
							},
							style : "aui-right aui-link"
						},
					]
				},
			];

			// 푸터레이아웃
			var footerColumnLayout = [
				{
					labelText : "합계",
					positionField : "gubun",
					style : "aui-center aui-footer",
				},
				{
					dataField : "bef_month_stock_cnt",
					positionField : "bef_month_stock_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer"
				},
				{
					dataField : "bef_month_stock_amt",
					positionField : "bef_month_stock_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer"
				},
				{
					dataField : "curr_month_in_cnt",
					positionField : "curr_month_in_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer"
				},
				{
					dataField : "curr_month_in_amt",
					positionField : "curr_month_in_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer"
				},
				{
					dataField : "curr_month_sale_cnt",
					positionField : "curr_month_sale_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer"
				},
				{
					dataField : "curr_month_sale_amt",
					positionField : "curr_month_sale_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer"
				},
				{
					dataField : "remit_proc_cnt",
					positionField : "remit_proc_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer"
				},
				{
					dataField : "remit_proc_amt",
					positionField : "remit_proc_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer"
				},
				{
					dataField : "curr_month_stock_cnt",
					positionField : "curr_month_stock_cnt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer"
				},
				{
					dataField : "curr_month_stock_amt",
					positionField : "curr_month_stock_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer"
				}
			];

			// 실제로 #grid_wrap에 그리드 생성
			auiGridTop = AUIGrid.create("#auiGridTop", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridTop, []);
			AUIGrid.setFooter(auiGridTop, footerColumnLayout);
			$("#auiGridTop").resize();

			// 클릭 시 이벤트
			AUIGrid.bind(auiGridTop, "cellClick", function(event) {

				if (event.value == "" || !event.dataField.endsWith("amt")) {
					return;
				}

				var param = {
					s_year  : $M.getValue("s_year"),
					s_mon 	: $M.getValue("s_mon"),
				};

				// 로우인덱스에 따라 구분
				if (event.rowIndex == 0) {
					param["s_type_1"] = "machine"; // 장비재고
					$("#detail_name").html("장비재고 상세내역");
				} else if (event.rowIndex == 1) {
					param["s_type_1"] = "part"; // 부품재고
					$("#detail_name").html("부품재고 상세내역");
				} else {
					param["s_type_1"] = "used"; // 중고장비재고
					$("#detail_name").html("중고장비재고 상세내역");
				}

				// 전월재고금액
				if(event.dataField == "bef_month_stock_amt") {
					param["s_type"] = "bef_month_stock_amt";
					goSearchDetail(param);
				}

				// 당월입고금액
				if(event.dataField == "curr_month_in_amt") {
					param["s_type"] = "curr_month_in_amt";
					goSearchDetail(param);
				}

				// 당월판매금액
				if(event.dataField == "curr_month_sale_amt") {
					param["s_type"] = "curr_month_sale_amt";
					goSearchDetail(param);
				}

				// 송금완료
				if(event.dataField == "remit_proc_amt") {
					param["s_type"] = "remit_proc_amt";
					goSearchDetail(param);
				}

				// 당월 재고금액
				if(event.dataField == "curr_month_stock_amt") {
					param["s_type"] = "curr_month_stock_amt";
					goSearchDetail(param);
				}

			});
		}

		function createAUIGridBot() {
			var gridPros = {
				rowIdField : "row",
				// No. 제거
				showRowNumColumn: true,
				// 고정칼럼 카운트 지정
				editable : false,
				showFooter : true,
				footerPosition : "top",
				selectionMode : "singleRow",
				showSelectionBorder : true
			};
			var columnLayout = [
				{
					headerText : "고객명",
					dataField : "cust_name",
					width : "170",
					minWidth : "150",
					style : "aui-center"
				},
				{
					dataField : "cust_no",
					visible : false,
				},
				{
					headerText : "전화번호",
					dataField : "hp_no",
					width : "130",
					minWidth : "130",
					style : "aui-center"
				},
				{
					headerText : "더존거래처번호",
					dataField : "account_link_cd",
					width : "110",
					minWidth : "110",
					style : "aui-center",
				},
				{
					headerText : "사업자명",
					dataField : "breg_name",
					width : "190",
					minWidth : "170",
					style : "aui-center",
				},
				{
					headerText : "센터",
					dataField : "org_name",
					width : "100",
					minWidth : "100",
					style : "aui-center",
				},
				{
					headerText : "담당자(미수)",
					dataField : "misu_mem_name",
					width : "80",
					minWidth : "80",
					style : "aui-center",
				},
				{
					headerText : "장비 미수",
					dataField : "machine_misu_amt",
					width : "130",
					minWidth : "110",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if(value == 0) {
							return "";
						}
						return "aui-popup"
					},
				},
				{
					headerText : "부품/정비/렌탈 미수",
					dataField : "repair_misu_amt",
					width : "130",
					minWidth : "120",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if(value == 0) {
							return "";
						}
						return "aui-popup"
					},
				},
// 				{
// 					headerText : "렌탈 미수금",
// 					dataField : "rental_misu_amt",
// 					width : "12%",
// 					dataType : "numeric",
// 					formatString : "#,##0",
// 					style : "aui-right",
// 					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
// 						if(value == 0) {
// 							return "";
// 						}
// 						return "aui-popup"
// 					},
// 				},
				{
					headerText : "총 미수",
					dataField : "tot_misu_amt",
					width : "130",
					minWidth : "110",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right"
				}
			];
			// 푸터레이아웃
			var footerColumnLayout = [
				{
					labelText : "합계",
					positionField : "misu_mem_name",
					style : "aui-center aui-footer",
				},
				{
					dataField : "machine_misu_amt",
					positionField : "machine_misu_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "repair_misu_amt",
					positionField : "repair_misu_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "rental_misu_amt",
					positionField : "rental_misu_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "tot_misu_amt",
					positionField : "tot_misu_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				}
			];

			auiGridBot = AUIGrid.create("#auiGridBot", columnLayout, gridPros);
			// 푸터 객체 세팅
			AUIGrid.setFooter(auiGridBot, footerColumnLayout);
			AUIGrid.setGridData(auiGridBot, []);
			$("#auiGridBot").resize();

			AUIGrid.bind(auiGridBot, "cellClick", function(event) {
				// 고객장비거래원장 팝업
				if(event.value == 0) {
					return;
				};

				if(event.dataField == "machine_misu_amt" ) {
					console.log(event.item.cust_no);
					var params = {
						s_cust_no : event.item.cust_no,
					}

					openCustMachineDealLedgerPanel($M.toGetParam(params));

				} else if(event.dataField == "repair_misu_amt" ) {
					// 고객거래원장 팝업(정비)
					var params = {
						s_cust_no : event.item.cust_no,
// 						s_inout_doc_type_cd : '07',
					}

					openDealLedgerPanel($M.toGetParam(params));
				} else if(event.dataField == "rental_misu_amt" ) {
					// 고객거래원장 팝업(렌탈)
					var params = {
						s_cust_no : event.item.cust_no,
						s_inout_doc_type_cd : '11',
					}

					openDealLedgerPanel($M.toGetParam(params));
				}
			});
		}

		//조회시
		function goSearch() {
			var param = {
				s_year : $M.getValue("s_year"),
				s_mon  : $M.getValue("s_mon"),
				s_search_type  : $M.getValue("s_search_type"),
				s_masking_yn   : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N"
			};

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						console.log(result);
						searchTypeDate = result.searchTypeDate;
						AUIGrid.setGridData(auiGridTop, result.inventoryAssetsList);
						AUIGrid.setGridData(auiGridBot, result.accountReceivableList);

						// 조회 html에 각각 금액 세팅
						var fundsDailyList = result.fundsDailyList;

						var wonFooterAmt = result.krwTotalAmt;
						var jpyFooterAmt = result.jpyTotalAmt;
						var usdFooterAmt = result.usdTotalAmt;
						var otherFooterAmt = result.etcTotalAmt;

						for (var i = 0; i <= 5; i++) {
							$("#fundsType"+ i +"_before_money").html($M.numberFormat(fundsDailyList[i].before_money));
							$("#fundsType"+ i +"_in_amt").html($M.numberFormat(fundsDailyList[i].in_amt));
							$("#fundsType"+ i +"_out_amt").html($M.numberFormat(fundsDailyList[i].out_amt));
							$("#fundsType"+ i +"_after_money").html($M.numberFormat(fundsDailyList[i].after_money));

							// 비고 (예정대비 부족분) 세팅
							var bigoAmt = 0;
							switch (i) {
								case 1 :
									bigoAmt = fundsDailyList[i].after_money - $M.toNum(wonFooterAmt);
									$("#fundsType"+ i +"_bigo").html($M.numberFormat(bigoAmt));
									break;
								case 2 :
									bigoAmt = fundsDailyList[i].after_money - $M.toNum(jpyFooterAmt);
									$("#fundsType"+ i +"_bigo").html($M.numberFormat(parseInt(bigoAmt)));
									break;
								case 3 :
									bigoAmt = fundsDailyList[i].after_money - $M.toNum(usdFooterAmt);
									$("#fundsType"+ i +"_bigo").html($M.numberFormat(bigoAmt.toFixed(2)));
									break;
								case 4 :
									bigoAmt = fundsDailyList[i].after_money - $M.toNum(otherFooterAmt);
									$("#fundsType"+ i +"_bigo").html($M.numberFormat(bigoAmt.toFixed(2)));
									break;
								default :
									$("#fundsType"+ i +"_bigo").html($M.numberFormat(bigoAmt));
									break;
							}
						}
					};
				}
			);
		}

		// 검색조건 라디오 제어
		function fnSearchTypeControl(val) {
			// 조회년월 선택할경우
			if (val == "yyyyMM") {
				$("#s_year").attr("disabled", false);
				$("#s_mon").attr("disabled", false);
			} else {
				$("#s_year").attr("disabled", true);
				$("#s_mon").attr("disabled", true);
			}
		}

		function goDetail(strType) {
			var str = "";
			var fundsTypeCd;
			if(strType == "W") {
				str = "예금잔액(WON)";
				fundsTypeCd = 1;
			} else if(strType == "J") {
				str = "외화예금(JPY)";
				fundsTypeCd = 2;
			} else if(strType == "U") {
				str = "외화예금(USD)";
				fundsTypeCd = 3;
			} else if(strType == "E") {
				str = "외화예금(EUR)";
				fundsTypeCd = 4;
			} else if(strType == "O") {
				str = "예적금(WON)";
				fundsTypeCd = 5;
			}

			var param = {
				"str" : str,
				"str_type" : strType,
				"funds_type_cd" : fundsTypeCd,
				"s_end_dt" : searchTypeDate
			};

			var popupOption = "";
			$M.goNextPage('/acnt/acnt0201p01', $M.toGetParam(param), {popupStatus : popupOption});
		}

		// 예적금 등록상세
		function goFundsDailySavings() {
			var param = {
				"s_end_dt" : searchTypeDate
			}
			var popupOption = "";
			$M.goNextPage('/acnt/acnt0201p07', $M.toGetParam(param), {popupStatus : popupOption});
		}

		// 재고자산 - 장비상세내역 팝업 호출
		function goSearchDetail(param) {
			var popupOption = "";
			$M.goNextPage('/acnt/acnt0206p01', $M.toGetParam(param), {popupStatus : popupOption});
		}
	</script>
</head>
<body style="background : #fff">
<form id="main_form" name="main_form">
	<div class="layout-box">
		<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
				<div class="contents">
					<!-- 검색영역 -->
					<div class="search-wrap" style="margin-top: 10px;">
						<table class="table">
							<colgroup>
								<col width="70px">
								<col width="80px">
								<col width="150px">
							</colgroup>
							<tbody>
							<tr>
								<td>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="search_type_now" name="s_search_type" value="now" checked onchange="javascript:fnSearchTypeControl(this.value)">
										<label class="form-check-label" for="search_type_now">현기준</label>
									</div>
								</td>
								<td>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="search_type_yyyyMM" name="s_search_type" value="yyyyMM" onchange="javascript:fnSearchTypeControl(this.value)">
										<label class="form-check-label" for="search_type_yyyyMM">조회년월</label>
									</div>
								</td>
<%--								<th>조회년월</th>--%>
								<td>
									<div class="form-row inline-pd">
										<div class="col-auto">
											<select class="form-control" id="s_year" name="s_year" disabled>
												<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
													<c:set var="year_option" value="${inputParam.s_current_year - i + 2000}"/>
													<option value="${year_option}" <c:if test="${year_option eq inputParam.s_year}">selected</c:if>>${year_option}년</option>
												</c:forEach>
											</select>
										</div>
										<div class="col-auto">
											<select class="form-control" id="s_mon" name="s_mon" disabled>
												<c:forEach var="i" begin="1" end="12" step="1">
													<option value="<c:if test="${i < 10}">0</c:if><c:out value="${i}" />" <c:if test="${i==s_start_mon}">selected</c:if>>${i}월</option>
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
					<!-- 조회결과 -->
					<div class="title-wrap mt10">
						<h4>재고자산</h4>
					</div>
					<!-- /조회결과 -->
					<div id="auiGridTop" style="margin-top: 5px; height: 200px;"></div>

					<div class="title-wrap mt10">
						<h4>당좌자산</h4>
					</div>
					<!-- 폼테이블 -->
					<table class="table-border mt10">
						<colgroup>
							<col width="">
							<col width="">
							<col width="">
							<col width="">
							<col width="">
							<col width="">
						</colgroup>
						<thead>
						<tr>
							<th style="font-size: 15px;">구분</th>
							<th class="th-gray" style="font-size: 15px;">전일잔고</th>
							<th class="th-gray" style="font-size: 15px;">당일입고</th>
							<th class="th-gray" style="font-size: 15px;">당일출고</th>
							<th class="th-gray" style="font-size: 15px;">금일잔고</th>
							<th class="th-gray" style="font-size: 15px;">비고(예정대비 부족분)</th>
						</tr>
						</thead>
						<tbody>
						<tr>
							<th style="font-size: 15px;">현금</th>
							<td class="text-right" id="fundsType0_before_money" style="font-size: 15px;"></td>
							<td class="text-right" id="fundsType0_in_amt" style="font-size: 15px;"></td>
							<td class="text-right" id="fundsType0_out_amt" style="font-size: 15px;"></td>
							<td class="text-right" id="fundsType0_after_money" style="font-size: 15px;"></td>
							<td class="text-right" id="fundsType0_bigo" style="font-size: 15px;"></td>
						</tr>
						<tr>
							<th class="text-primary">
								<a class="funds_a_link" href="#" onclick="javascript:goDetail('W');" style="font-size: 15px;">예금잔액(WON)</a>
							</th>
							<td class="text-right" id="fundsType1_before_money" style="font-size: 15px;"></td>
							<td class="text-right" id="fundsType1_in_amt" style="font-size: 15px;"></td>
							<td class="text-right" id="fundsType1_out_amt" style="font-size: 15px;"></td>
							<td class="text-right" id="fundsType1_after_money" style="font-size: 15px;"></td>
							<td class="text-right" id="fundsType1_bigo" style="font-size: 15px;"></td>
						</tr>
						<tr>
							<th class="text-primary">
								<a class="funds_a_link" href="#" onclick="javascript:goDetail('J');" style="font-size: 15px;">외화예금(JPY)</a>
							</th>
							<td class="text-right" id="fundsType2_before_money" style="font-size: 15px;"></td>
							<td class="text-right" id="fundsType2_in_amt" style="font-size: 15px;"></td>
							<td class="text-right" id="fundsType2_out_amt" style="font-size: 15px;"></td>
							<td class="text-right" id="fundsType2_after_money" style="font-size: 15px;"></td>
							<td class="text-right" id="fundsType2_bigo" style="font-size: 15px;"></td>
						</tr>
						<tr>
							<th class="text-primary">
								<a class="funds_a_link" href="#" onclick="javascript:goDetail('U');" style="font-size: 15px;">외화예금(USD)</a>
							</th>
							<td class="text-right" id="fundsType3_before_money" style="font-size: 15px;"></td>
							<td class="text-right" id="fundsType3_in_amt" style="font-size: 15px;"></td>
							<td class="text-right" id="fundsType3_out_amt" style="font-size: 15px;"></td>
							<td class="text-right" id="fundsType3_after_money" style="font-size: 15px;"></td>
							<td class="text-right" id="fundsType3_bigo" style="font-size: 15px;"></td>
						</tr>
						<tr>
							<th class="text-primary">
								<a class="funds_a_link" href="#" onclick="javascript:goDetail('E');" style="font-size: 15px;">외화예금(EUR)</a>
							</th>
							<td class="text-right" id="fundsType4_before_money" style="font-size: 15px;"></td>
							<td class="text-right" id="fundsType4_in_amt" style="font-size: 15px;"></td>
							<td class="text-right" id="fundsType4_out_amt" style="font-size: 15px;"></td>
							<td class="text-right" id="fundsType4_after_money" style="font-size: 15px;"></td>
							<td class="text-right" id="fundsType4_bigo" style="font-size: 15px;"></td>
						</tr>
						<tr>
							<th class="text-primary">
								<a class="funds_a_link" href="#" onclick="javascript:goFundsDailySavings();" style="font-size: 15px;">예적금(WON)</a>
							</th>
							<td class="text-right" id="fundsType5_before_money" style="font-size: 15px;"></td>
							<td class="text-right" id="fundsType5_in_amt" style="font-size: 15px;"></td>
							<td class="text-right" id="fundsType5_out_amt" style="font-size: 15px;"></td>
							<td class="text-right" id="fundsType5_after_money" style="font-size: 15px;"></td>
							<td class="text-right" id="fundsType5_bigo" style="font-size: 15px;"></td>
						</tr>
						</tbody>
					</table>
					<!-- /폼테이블 -->

					<div class="title-wrap mt10">
						<h4>매출채권</h4>
						<div class="btn-group">
							<div class="right">
								<c:if test="${page.add.POS_UNMASKING eq 'Y'}">
									<div class="form-check form-check-inline">
										<input  class="form-check-input"  type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" onchange="javascript:goSearch()">
										<label  class="form-check-input"  for="s_masking_yn" >마스킹 적용</label>
									</div>
								</c:if>
							</div>
						</div>
					</div>
					<div id="auiGridBot" style="margin-top: 5px; height: 250px;"></div>
				</div>
			</div>
		</div>
		<!-- /contents 전체 영역 -->
	</div>
</form>
</body>
</html>