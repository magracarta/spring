<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 업무일지 > null > 영업/관리/부품부 업무일지 상세
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2020-04-09 11:51:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>

	<script type="text/javascript">
		var auiGridinner1;
		/* $(document).ready(function() {
			createauiGridinner1();
		}); */

		function createauiGridinner1() {
			var gridPros = {
				showRowNumColumn : true
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
					dataField : "ibk_iss_stockacct_his_seq",
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
					width : "70",
					style : "aui-center"
				},
				{
					headerText : "계좌번호",
					dataField : "acct_no",
					width : "130",
					style : "aui-center aui-popup",
				},
				{
					headerText : "일자",
					dataField : "deal_dt",
					width : "80",
					dataType : "date",
					formatString : "yyyy-mm-dd",
					style : "aui-center",
				},
				{
					headerText : "입금자명",
					dataField : "cust_name",
					width : "120",
					minWidth: "100",
					style : "aui-left",
				},
				{
					headerText : "입금",
					dataField : "in_tx_amt",
					width : "100",
					minWidth: "80",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right"
				},
				{
					headerText : "출금",
					dataField : "out_tx_amt",
					width : "100",
					minWidth : "80",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right"
				},
				{
					headerText : "잔액",
					dataField : "balance_amt",
					width : "100",
					minWidth : "80",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right"
				},
				{
					headerText : "메모",
					dataField : "erp_memo",
					width : "200",
					style : "aui-left"
				},
				{
					headerText : "처리액",
					dataField : "erp_amt",
					width : "70",
					minWidth : "70",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right"
				},
				{
					headerText : "처리잔액",
					dataField : "erp_balance_amt",
					width : "70",
					minWidth : "70",
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
					width : "70",
					minWidth : "70",
					style : "aui-left"
				},
			];

			auiGridinner1 = AUIGrid.create("#auiGridinner1", columnLayout, gridPros);
			// 푸터 객체 세팅
			AUIGrid.setGridData(auiGridinner1, []);
			$("#auiGridinner1").resize();

			AUIGrid.bind(auiGridinner1, "cellClick", function(event) {
				if(event.dataField == "acct_no" ) {
					// [재호] 23.08.28 : 증권계좌 로직 추가
					// - ibk 입출금 내역
					if(event.item['ibk_iss_acct_his_seq'] !== '') {
						var params = {
							"ibk_iss_acct_his_seq" : event.item["ibk_iss_acct_his_seq"],
							"deal_type_rv" : event.item["deal_type_rv"],
							"opener_work_yn" : "Y",
						};
					}
					// - ibk 가상계좌 내역
					else if(event.item['ibk_rcv_vacct_reco_seq'] !== '') {
						var params = {
							"ibk_rcv_vacct_reco_seq" : event.item["ibk_rcv_vacct_reco_seq"],
							"deal_type_rv" : event.item["deal_type_rv"],
							"opener_work_yn" : "Y",
						};
					}
					// - ibk 증권계좌
					else if(event.item['ibk_iss_stockacct_his_seq'] !== '') {
						var params = {
							"ibk_iss_stockacct_his_seq" : event.item["ibk_iss_stockacct_his_seq"],
							"deal_type_rv" : event.item["deal_type_rv"],
							"opener_work_yn" : "Y",
						};
					}

					// if(event.item["deal_type_rv"] == "R") {
					// 	var params = {
					// 			"ibk_iss_acct_his_seq" : event.item["ibk_iss_acct_his_seq"],
					// 			"deal_type_rv" : event.item["deal_type_rv"],
					// 			"opener_work_yn" : "Y"
					// 	};
					// } else if(event.item["deal_type_rv"] == "V") {
					// 	var params = {
					// 			"ibk_rcv_vacct_reco_seq" : event.item["ibk_rcv_vacct_reco_seq"],
					// 			"deal_type_rv" : event.item["deal_type_rv"],
					// 			"opener_work_yn" : "Y"
					// 	};
					// }

					var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1100, height=350, left=0, top=0";
					$M.goNextPage('/cust/cust0303p01', $M.toGetParam(params), {popupStatus : popupOption});
				}
			});
			AUIGrid.showAjaxLoader("#auiGridinner1"); //로딩바 보이기
		}
	</script>


	<div  class="mt10">
		<div id="auiGridinner1" style="margin-top: 5px;"></div>
	</div>

