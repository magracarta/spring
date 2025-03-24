<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 거래현황 > 계좌입출금내역 > null > 계좌입출금내역
-- 작성자 : 박예진
-- 최초 작성일 : 2020-04-28 09:08:26
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var balanceAmt = 0;

		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGrid();
			fnInit();
		});

		function fnInit() {
			var list = ${list};
			AUIGrid.setGridData("#auiGrid", list);
			$M.setValue("erp_memo", list[0].erp_memo);
			$("#total_cnt").html(list.length);
			var txAmt = $M.toNum(list[0].tx_amt);

			for(var i=0; i < list.length; i++) {
				balanceAmt += $M.toNum(list[i].erp_balance_amt);
			}
			balanceAmt =  $M.toNum(txAmt) - $M.toNum(balanceAmt);

		}

		//그리드생성
		function createAUIGrid() {
			var gridPros = {
					rowIdField : "row_id",
					showStateColumn : false,
					// No. 제거
					showRowNumColumn: true,
					showBranchOnGrouping : false,
					showFooter : true,
					footerPosition : "top",
					editable : false
				};
			var columnLayout = [
				{
					headerText : "처리일자",
					dataField : "deal_dt",
					dataType : "date",
					formatString : "yyyy-mm-dd",
					width : "10%",
					style : "aui-center",
				},
				{
					headerText : "은행명",
					dataField : "ibk_bank_name",
					width : "8%",
					style : "aui-center",
				},
				{
					headerText : "계좌번호",
					dataField : "acct_no",
					style : "aui-center",
				},
				{
					headerText : "입(출)금액",
					dataField : "tx_amt",
					dataType : "numeric",
					formatString : "#,##0",
					width : "9%",
					style : "aui-right",
				},
				<c:if test="${'Y' eq inputParam.imprest_yn}">
				{
					headerText : "적요",
					dataField : "erp_memo",
					style : "aui-left",
					width : "10%",
				},
				</c:if>
				{
					headerText : "전표일자",
					dataField : "inout_dt",
					width : "10%",
					dataType : "date",
					formatString : "yyyy-mm-dd",
					style : "aui-center"
				},
				{
					headerText : "번호",
					dataField : "ref_doc_no",
					width : "12%",
					style : "aui-center aui-popup"
				},
				{
					headerText : "처리액",
					dataField : "inout_amt",
					dataType : "numeric",
					formatString : "#,##0",
					width : "9%",
					style : "aui-right",
				},
				{
					headerText : "고객명",
					dataField : "cust_name",
					width : "8%",
					style : "aui-center",
				},
				{
					headerText : "휴대폰",
					dataField : "cust_hp_no",
					width : "11%",
					style : "aui-center",
				},
				{
					headerText : "등록자",
					dataField : "reg_mem_name",
					width : "8%",
					style : "aui-center",
				},
				{
					dataField : "inout_doc_type_cd",
					visible : false
				},
				{
					dataField : "erp_balance_amt",
					visible : false
				},
				{
					dataField : "machine_deposit_result_seq",
					visible : false
				}
			];

			// 푸터레이아웃
			var footerColumnLayout = [
				{
					labelText : "미처리액",
					positionField : "acct_no",
					style : "aui-center aui-footer"
				},
				{
					dataField : "erp_balance_amt",
					positionField : "tx_amt",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right aui-footer",
					labelFunction : function(value, columnValues, footerValues) {
						return balanceAmt;
		           }
				},
				{
					labelText : "합계",
					positionField : "inout_dt",
					style : "aui-center aui-footer"
				},
				{
					dataField : "inout_amt",
					positionField : "inout_amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				}
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 푸터 객체 세팅
			AUIGrid.setFooter(auiGrid, footerColumnLayout);
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == "ref_doc_no" ) {
					if(event.item["inout_doc_type_cd"] == "00") {
						var param = {
								"inout_doc_no" : event.item["ref_doc_no"]
						};
						var poppupOption = "";
						$M.goNextPage('/cust/cust0203p01', $M.toGetParam(param), {popupStatus : poppupOption});
					} else if (event.item["inout_doc_type_cd"] == "21") {
						var param = {
								"machine_deposit_result_seq" : event.item["machine_deposit_result_seq"]
						};
						var poppupOption = "";
						$M.goNextPage('/cust/cust0301p05', $M.toGetParam(param), {popupStatus : poppupOption});
					}
				}
			});
			$("#auiGrid").resize();
		}

		function goAccountMemo() {
			var param = {
					"deal_type_rv" : "${inputParam.deal_type_rv}",
					"ibk_iss_acct_his_seq" : "${inputParam.ibk_iss_acct_his_seq}",
					"ibk_rcv_vacct_reco_seq" : "${inputParam.ibk_rcv_vacct_reco_seq}",
					"ibk_iss_stockacct_his_seq" : "${inputParam.ibk_iss_stockacct_his_seq}",
					"erp_memo" : $M.getValue("erp_memo"),
			}

			$M.goNextPageAjaxSave(this_page + "/saveErpMemo", $M.toGetParam(param), {method : 'POST'},
					function(result) {
						if(result.success) {
							fnClose();
							// 업무일지에서 접근할 경우 조건 추가.
							if ("${inputParam.opener_work_yn}" == "Y") {
								window.opener.location.reload();
							} else {
								if(opener.fnSetMemo){
									opener.fnSetMemo($M.getValue("erp_memo"));
								}else{
									opener.goSearch();
								}
							}
						};
					}
				);
		}

		function fnClose() {
			window.close();
		}

		// 입출금전표등록 팝업
		function goInoutPopup() {

			var dealTypeRv = "${inputParam.deal_type_rv}"; // 계좌구분(R:실제계좌, V:가상계좌)
			var ibk_iss_acct_his_seq =  "${inputParam.ibk_iss_acct_his_seq}"
			var ibk_rcv_vacct_reco_seq =  "${inputParam.ibk_rcv_vacct_reco_seq}"
			var ibk_iss_stockacct_his_seq =  "${inputParam.ibk_iss_stockacct_his_seq}"


			var param = {
				"popup_yn" 		: "Y",
				"call_page_seq" : $M.getValue("page_seq"),
				"inout_type_io" : $M.getValue("inout_type_io"), // 전표구분(입금, 출금)
				"acc_type_cd" 	: $M.getValue("acc_type_cd"), 	// 계정구분(은행) 고정
				"deal_dt" 		: $M.getValue("deal_dt"), 		// 처리일자
				"deal_type_rv" 	: dealTypeRv,
			};

			// [재호] 23.08.28 : 증권계좌 로직 추가
			// - ibk 입출금 내역
			if(ibk_iss_acct_his_seq) {
				param.ibk_iss_acct_his_seq = ibk_iss_acct_his_seq;
			}
			// - ibk 가상계좌 내역
			else if(ibk_rcv_vacct_reco_seq) {
				param.ibk_rcv_vacct_reco_seq = ibk_rcv_vacct_reco_seq;
			}
			// - ibk 증권계좌 내역
			else if(ibk_iss_stockacct_his_seq) {
				param.ibk_iss_stockacct_his_seq = ibk_iss_stockacct_his_seq;
			}

			<%--if (dealTypeRv == 'R' ) {--%>
			<%--	param.ibk_iss_acct_his_seq 	 = "${inputParam.ibk_iss_acct_his_seq}";--%>
			<%--} else if(dealTypeRv == 'V' ) {--%>
			<%--	param.ibk_rcv_vacct_reco_seq = "${inputParam.ibk_rcv_vacct_reco_seq}";--%>
			<%--}--%>

			var gridData = AUIGrid.getGridData(auiGrid);

			var txAmtTotal 	  = gridData[0].tx_amt;
			var inoutAmtTotal = AUIGrid.getFooterData(auiGrid)[3].value;

			if (txAmtTotal - Math.abs(inoutAmtTotal) <= 0) {
				alert("처리완료된 계좌입출금내역 입니다.");
				return;
			}

			var popupOption = "";
			$M.goNextPage('/cust/cust020301', $M.toGetParam(param), {popupStatus : popupOption});
		}

	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<input type="hidden" id="page_seq" 	    name="page_seq" 	 value="${info.page_seq}">
	<input type="hidden" id="inout_type_io" name="inout_type_io" value="${info.inout_type_io}">
	<input type="hidden" id="acc_type_cd"   name="acc_type_cd" 	 value="${info.acc_type_cd}">
	<input type="hidden" id="inout_dt"   	name="deal_dt" 	 	 value="${info.deal_dt}">
	<input type="hidden" id="total_tx_amt"  name="total_tx_amt"  value="${info.tx_amt}">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
        <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
<!-- 처리내역 -->
			<div>
				<div class="title-wrap">
					<div class="left">
						<h4>처리내역</h4>
					</div>
					<c:if test="${'Y' ne inputParam.imprest_yn }">
						<div class="right dpf">
						<div class="left" style="width:90px;">
							<strong>작성자 :${memo_mem_name}</strong>
						</div>
							<input type="text" id="erp_memo" name="erp_memo" class="form-control mr3" style="width: 580px;" maxlength="70" placeholder="메모입력">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
						</div>
					</c:if>
				</div>
				<div id="auiGrid" style="margin-top: 5px; height: 200px;"></div>
			</div>
<!-- /처리내역 -->
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
