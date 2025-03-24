<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 거래현황 > 계좌입출금내역 > null > null
-- 작성자 : 박예진
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var selectRow = "";
		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGrid();
// 			fnInitDate();
			goSearch();
			// 22.11.21 Q&A 15104 입금정보 최신화 버튼 미노출
			$("#_goChangeSave").addClass("dpn");
		});

		function fnDownloadExcel() {
			  // 엑셀 내보내기 속성
			  var exportProps = {
			  };
			  fnExportExcel(auiGrid, "계좌입출금내역", exportProps);
		}

		// 검색 시작일자 세팅 현재날짜의 7일전
// 		function fnInitDate() {
// 			var now = "${inputParam.s_current_dt}";
// 			$M.setValue("s_start_dt", $M.addDates($M.toDate(now), -1));
// 		}

		function fnChangeEndDt() {
			$M.setValue("s_end_dt", $M.getValue("s_start_dt"));
		}

		function goSearch() {
			var param = {
					"s_inout_type_io" : $M.getValue("s_inout_type_io"),
					"s_account_no" : $M.getValue("s_account_no"),
					"s_deal_type_rv" : $M.getValue("s_deal_type_rv"),
					"s_start_dt" : $M.getValue("s_start_dt"),
					"s_cust_name" : $M.getValue("s_cust_name"),
					"s_end_dt" : $M.getValue("s_end_dt"),
					"s_inout_yn" : $M.getValue("s_inout_yn"),
					"s_sort_key" : "ibk_bank_name, acct_no, deal_dt",
					"s_sort_method" : "asc"
			};
			_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
			$M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'get'},
					function(result) {
						if(result.success) {
							AUIGrid.setGridData(auiGrid, result.list);
							$("#total_cnt").html(result.total_cnt);
						};
					}
				);
		}

		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showStateColumn : false,
				// No. 제거
				showRowNumColumn: true,
				showFooter : true,
				footerPosition : "top",
				selectionMode : "singleRow",
				showSelectionBorder : true,
				editable : false
			};
			var columnLayout = [
				{
					dataField : "ibk_iss_acct_his_seq",
					visible : false
				},
				{
					dataField : "ibk_rcv_vacct_reco_seq",
					visible : false
				},
				{
					dataField : "ibk_bank_cd",
					visible : false
				},
				{
					dataField : "inout_type_io",
					visible : false
				},
				{
					dataField : "account_no",
					visible : false
				},
				{
					headerText : "은행명",
					dataField : "ibk_bank_name",
					width : "45",
					minWidth : "45",
					style : "aui-center"
				},
// 				{
// 					headerText : "계좌구분",
// 					dataField : "deal_type_rv",
// 					width : "5%",
// 					style : "aui-center",
// 					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
// 						return item["deal_type_rv"] == "R" ? "통장" : "가상계좌";
// 					}
// 				},
				{
					headerText : "계좌번호",
					dataField : "acct_no",
					width : "155",
					minWidth : "135",
					style : "aui-center aui-popup",
				},
				{
					headerText : "일자",
					dataField : "deal_dt",
					width : "65",
					minWidth : "65",
					dataType : "date",
					formatString : "yy-mm-dd",
					style : "aui-center",
				},
				{
					headerText : "입금자명",
					dataField : "cust_name",
					width : "120",
					minWidth : "120",
					style : "aui-left",
				},
				{
					headerText : "입금",
					dataField : "in_tx_amt",
					width : "90",
					minWidth : "90",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right"
				},
				{
					headerText : "출금",
					dataField : "out_tx_amt",
					width : "90",
					minWidth : "90",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right"
				},
				{
					headerText : "계좌잔액",
					dataField : "balance_amt",
					width : "95",
					minWidth : "95",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right"
				},
				{
					headerText : "입출금정보",
					dataField : "deposit_name",
					width : "120",
					minWidth : "120",
					style : "aui-left"
				},
				{
					headerText : "메모",
					dataField : "erp_memo",
					width : "180",
					minWidth : "100",
					style : "aui-left"
				},
				{
					headerText : "처리액",
					dataField : "erp_amt",
					width : "85",
					minWidth : "85",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right"
				},
				{
					headerText : "처리잔액",
					dataField : "erp_balance_amt",
					width : "85",
					minWidth : "85",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right",
					xlsxTextConversion : true,
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var amt = value;
						return amt == "0" ? "" : $M.setComma(amt);
					}
				},
				{
					headerText : "처리내역",
					dataField : "remark",
					width : "170",
					minWidth : "100",
					style : "aui-left"
				},
				{
					dataField : "aui_status_cd",
					visible : false
				}
			];
			// 푸터레이아웃
			var footerColumnLayout = [
				{
					labelText : "합계",
					positionField : "cust_name",
					style : "aui-center aui-footer",
				},
				{
					dataField : "in_tx_amt",
					positionField : "in_tx_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "out_tx_amt",
					positionField : "out_tx_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				}
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 푸터 객체 세팅
			AUIGrid.setFooter(auiGrid, footerColumnLayout);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();

			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == "acct_no" ) {
					selectRow = event.rowIndex;

					// ibk_iss_acct_his_seq
					// ibk_iss_stockacct_his_seq
					// ibk_rcv_vacct_reco_seq

					// [재호] 23.08.28 : 증권계좌 로직 추가
					// - ibk 입출금 내역
					if(event.item['ibk_iss_acct_his_seq'] !== '') {
						var params = {
							"ibk_iss_acct_his_seq" : event.item["ibk_iss_acct_his_seq"],
							"deal_type_rv" : event.item["deal_type_rv"]
						};
					}
					// - ibk 가상계좌 내역
					else if(event.item['ibk_rcv_vacct_reco_seq'] !== '') {
						var params = {
							"ibk_rcv_vacct_reco_seq" : event.item["ibk_rcv_vacct_reco_seq"],
							"deal_type_rv" : event.item["deal_type_rv"]
						};
					}
					// - ibk 증권계좌
					else if(event.item['ibk_iss_stockacct_his_seq'] !== '') {
						var params = {
							"ibk_iss_stockacct_his_seq" : event.item["ibk_iss_stockacct_his_seq"],
							"deal_type_rv" : event.item["deal_type_rv"]
						};
					}

					// if(event.item["deal_type_rv"] == "R") {
					// 	var params = {
					// 			"ibk_iss_acct_his_seq" : event.item["ibk_iss_acct_his_seq"],
					// 			"deal_type_rv" : event.item["deal_type_rv"]
					// 	};
					// } else if(event.item["deal_type_rv"] == "V") {
					// 	var params = {
					// 			"ibk_rcv_vacct_reco_seq" : event.item["ibk_rcv_vacct_reco_seq"],
					// 			"deal_type_rv" : event.item["deal_type_rv"]
					// 	};
					// }

					var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1100, height=350, left=0, top=0";
					$M.goNextPage('/cust/cust0303p01', $M.toGetParam(params), {popupStatus : popupOption});
				}
			});
		}

		function fnSetMemo(memo){
			AUIGrid.updateRow(auiGrid,{erp_memo : memo},selectRow);
		}

		// 엔터키 이벤트
		function enter(fieldObj) {
			var name = fieldObj.name;
			if (name == "s_cust_name") {
				goSearch();
			}
		}

		// 가상계좌 팝업 오픈
		function goVirtualAccountInfo() {
			var params = {};
			var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=700, height=350, left=0, top=0";
			$M.goNextPage('/cust/cust0303p02', $M.toGetParam(params), {popupStatus : popupOption});
		}

		// 원인불명 고객조회
		function goUnknownCust() {
			var popupOption = "";
			var param = {
					"s_cust_no" : "20160323084759031"
			}
			$M.goNextPage('/cust/cust0106p01', $M.toGetParam(param), {popupStatus : popupOption});
		}

		// 기준정보 재생성
		function goChangeSave() {
			alert("최신 입출금정보를 반영합니다.");
			var param = {
				"s_start_dt" : $M.getValue("s_start_dt"),
				"s_end_dt" : $M.getValue("s_end_dt"),
			};

			$M.goNextPageAjax(this_page + "/syncIbkIssAcctHis", $M.toGetParam(param), {method: "POST"},
					function (result) {
						if (result.success) {
							alert("입금정보 최신화를 완료하였습니다.");
							goSearch();
						}
					}
			);
		}

	</script>
</head>
<body>
<form id="main_form" name="main_form">
<div class="layout-box">
<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
<!-- 메인 타이틀 -->
				<div class="main-title">
					<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
				</div>
<!-- /메인 타이틀 -->
				<div class="contents">
<!-- 검색영역 -->
					<div class="search-wrap">
						<table class="table">
							<colgroup>
								<col width="50px">
								<col width="260px">
								<col width="50px">
								<col width="100px">
								<col width="60px">
								<col width="80px">
								<col width="60px">
								<col width="180px">
								<col width="60px">
								<col width="80px">
								<col width="80px">
								<col width="100px">
<%-- 								<col width="110px"> --%>
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th>처리일자</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="" value="${searchDtMap.s_start_dt}" onchange="javascript:fnChangeEndDt();">
												</div>
											</div>
											<div class="col-auto">~</div>
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="" value="${searchDtMap.s_end_dt}">
												</div>
											</div>
											<jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp">
				                     		<jsp:param name="st_field_name" value="s_start_dt"/>
				                     		<jsp:param name="ed_field_name" value="s_end_dt"/>
				                     		<jsp:param name="click_exec_yn" value="Y"/>
				                     		<jsp:param name="exec_func_name" value="goSearch();"/>
				                     		</jsp:include>
										</div>
									</td>
									<th>입금자명</th>
									<td>
										<input type="text" class="form-control" id="s_cust_name" name="s_cust_name">
									</td>
									<th>계좌구분</th>
									<td>
										<select class="form-control" id="s_deal_type_rv" name="s_deal_type_rv">
											<option value="">- 전체 -</option>
											<option value="R">통장</option>
											<option value="V">가상계좌</option>
										</select>
									</td>
									<th>계좌번호</th>
									<td>
										<select class="form-control" id="s_account_no" name="s_account_no">
											<option value="">- 전체 -</option>
											<c:forEach items="${bankList}" var="item">
											  <option value="${item.acct_no}">${item.bank_name}</option>
											</c:forEach>
										</select>
									</td>
									<th>입출구분</th>
									<td>
										<select class="form-control" id="s_inout_type_io" name="s_inout_type_io">
											<option value="">- 전체 -</option>
											<option value="I">입금</option>
											<option value="O">출금</option>
										</select>
									</td>
									<th>입금처리여부</th>
									<td>
										<select class="form-control" id="s_inout_yn" name="s_inout_yn">
											<option value="">- 전체 -</option>
											<option value="Y" selected="selected">입금완료 제외</option>
<!-- 											<option value="O">출금</option> -->
										</select>
									</td>
									<!-- <td class="pl10">
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="checkbox" id="a">
											<label class="form-check-label" for="a">원인불명고객</label>
										</div>
									</td> -->
									<td>
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
									</td>
								</tr>
							</tbody>
						</table>
					</div>
<!-- /검색영역 -->
<!-- 거래내역 -->
					<div class="title-wrap mt10">
						<h4>
							<span>거래내역</span>
							<span style="color: #ff7f00;" class="ml5">※ 가장 최근 입출금된 내역 일시 : ${lastStandDateTime}</span>
						</h4>
						<div class="left">

						</div>
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
						</div>
					</div>
<!-- /거래내역 -->
					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
					<div class="btn-group mt5">
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">0</strong>건
						</div>
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
					</div>
				</div>
			</div>
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
		</div>
<!-- /contents 전체 영역 -->
</div>
</form>
</body>
</html>
