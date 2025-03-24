<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 거래현황 > 장비입금관리 > null > 입금계정구분
-- 작성자 : 박예진
-- 최초 작성일 : 2020-04-28 09:08:26
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function() {
			fnChangeDepositForm();
		});
		
		function fnClose() {
			window.close();
		}
		
// 		function goBankInfo() {
// 			var param = {
// 					"parent_js_name" : "fnSetBankInfo",
// 					"amt" : "${inputParam.amt}",
// 					"inout_type_io" : $M.getValue("inout_type_io"),
// 					"view" : "${inputParam.view}"
// 			};
// 			var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1300, height=450, left=0, top=0";
// 			$M.goNextPage('/cust/cust0301p03', $M.toGetParam(param), {popupStatus : popupOption});
// 		}
		
		// 계정구분에 따라 form 디자인 변경
		function fnChangeDepositForm() {
			switch("${inputParam.acc_type_cd}") {
			case "2" : $(".deposit_billin").removeClass("dpn");
						$(".deposit_cash").addClass("dpn");
						$(".deposit_card").addClass("dpn");
						$(".deposit_replace").addClass("dpn");
						$(".deposit_bank").addClass("dpn");
					    var vwidth = document.getElementById('main_form').clientWidth;
						var vheight = document.getElementById('main_form').clientHeight + 90;  
						window.resizeTo(vwidth,vheight);
						if(${checkYn} == "Y") {
							$M.reloadComboData("bill_no", []);
						}
						break;
// 			case "3" : $(".deposit_bank").removeClass("dpn");
// 						$(".deposit_cash").addClass("dpn");
// 						$(".deposit_card").addClass("dpn");
// 						$(".deposit_replace").addClass("dpn");
// 						$(".deposit_billin").addClass("dpn");
// 						break;
			case "4" : $(".deposit_card").removeClass("dpn");
						$(".deposit_cash").addClass("dpn");
						$(".deposit_bank").addClass("dpn");
						$(".deposit_replace").addClass("dpn");
						$(".deposit_billin").addClass("dpn");
						var vwidth = document.getElementById('main_form').clientWidth;
						var vheight = document.getElementById('main_form').clientHeight + 200;  
						window.resizeTo(vwidth,vheight);
						break;
			case "5" : $(".deposit_replace").removeClass("dpn");
						$(".deposit_cash").addClass("dpn");
						$(".deposit_bank").addClass("dpn");
						$(".deposit_card").addClass("dpn");
						$(".deposit_billin").addClass("dpn");
						var vwidth = document.getElementById('main_form').clientWidth;
						var vheight = document.getElementById('main_form').clientHeight + 200;  
						window.resizeTo(vwidth,vheight);
						break;
			}
		}
		
		function fnBillinChange() {
			var param = {
				"bill_no" : $M.getValue("bill_no")
			};
			$M.goNextPageAjax("/cust/cust0301p02/billin", $M.toGetParam(param), {method : 'GET'},
				function(result) {
					if(result.success) {
						$M.setValue(result.billinDetail);
					};
				}
			);
		}
		
		// 은행조회 callback
// 		function fnSetBankInfo(data) {
// 			console.log(data);
// 			$M.setValue("bank_name", data.ibk_bank_name);
// 			$M.setValue("ibk_bank_cd", data.ibk_bank_cd);
// 			$M.setValue("account_no", data.account_no);
// 			$M.setValue("acct_no", data.acct_no);
// 			$M.setValue("acct_txday", data.deal_dt);
// 			$M.setValue("acct_txday_seq", data.acct_txday_seq);
// 			if(data.in_tx_amt == "") {
// 				$M.setValue("tx_amt", data.out_tx_amt);
// 			} else {
// 				$M.setValue("tx_amt", data.in_tx_amt);
// 			}
// 			$M.setValue("jeokyo", data.deposit_name);
// 			$M.setValue("site_no", data.site_no);
// 			$M.setValue("ibk_iss_acct_his_seq", data.ibk_iss_acct_his_seq);
// 			$M.setValue("ibk_rcv_vacct_reco_seq", data.ibk_rcv_vacct_reco_seq);
// 			$M.setValue("inout_type_io", data.inout_type_io);
// 		}
		
		// 카드사 조회
		function fnCardChange() {
			var cardCmpJson = JSON.parse('${codeMapJsonObj["CARD_CMP"]}');
			for(var item in cardCmpJson) {
				if(cardCmpJson[item].code_value == $M.getValue("card_cmp_cd")) {
					$M.setValue("card_cmp_name", cardCmpJson[item].code_name);
				}
			}
		}
		
		// 대체계정명 조회
		function fnReplaceChange() {
// 			var inReplaceAcntJson = JSON.parse('${codeMapJsonObj["IN_REPLACE_ACNT"]}');
			var inReplaceAcntJson = ${replaceListJson};
			for(var item in inReplaceAcntJson) {
				if(inReplaceAcntJson[item].code_value == $M.getValue("in_replace_acnt_cd")) {
					$M.setValue("in_replace_acnt_name", inReplaceAcntJson[item].code_name);
				}
			}
		}
		
		// 대체고객 셋팅
		function setReplaceCustInfo(data) {
			$M.setValue("replace_cust_name", data.real_cust_name);
			$M.setValue("replace_cust_no", data.cust_no);
		}
		
		// 데이터 callback
		function goApply() {
			var param = {
					"acc_type_cd" : $M.getValue("acc_type_cd"),
					"bill_no" : $M.getValue("bill_no"),
					"billin_no" : $M.getValue("billin_no"),
					"bank_name" : $M.getValue("bank_name"),
					"acct_txday_seq" : $M.getValue("acct_txday_seq"),
					"ibk_bank_cd" : $M.getValue("ibk_bank_cd"),
					"card_cmp_cd" : $M.getValue("card_cmp_cd"),
					"card_cmp_name" : $M.getValue("card_cmp_name"),
					"in_replace_acnt_cd" : $M.getValue("in_replace_acnt_cd"),
					"in_replace_acnt_name" : $M.getValue("in_replace_acnt_name"),
					"replace_cust_name" : $M.getValue("replace_cust_name"),
					"replace_cust_no" : $M.getValue("replace_cust_no"),
					"end_dt" : $M.getValue("end_dt"),
					"acct_no" : $M.getValue("acct_no"),
					"account_no" : $M.getValue("account_no"),
					"ibk_iss_acct_his_seq" : $M.getValue("ibk_iss_acct_his_seq"),
					"ibk_rcv_vacct_reco_seq" : $M.getValue("ibk_rcv_vacct_reco_seq"),
					"inout_type_io" : $M.getValue("inout_type_io"),
					"approval_no" : $M.getValue("approval_no"),
					"corp_cust_name" : $M.getValue("corp_cust_name"),
					"acct_txday" : $M.getValue("acct_txday"),
					"tx_amt" : $M.getValue("tx_amt"),
					"out_tx_amt" : $M.getValue("out_tx_amt"),
					"jeokyo" : $M.getValue("jeokyo"),
					"site_no" : $M.getValue("site_no"),
			};
			
			opener.${inputParam.parent_js_name}(param);
			fnClose();
		}
	
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" id="card_cmp_name" name="card_cmp_name">
<input type="hidden" id="in_replace_acnt_name" name="in_replace_acnt_name">
<input type="hidden" id="site_no" name="site_no">
<input type="hidden" id="billin_no" name="billin_no">
<input type="hidden" id="ibk_iss_acct_his_seq" name="ibk_iss_acct_his_seq">
<input type="hidden" id="acct_txday_seq" name="acct_txday_seq">
<input type="hidden" id="ibk_rcv_vacct_reco_seq" name="ibk_rcv_vacct_reco_seq">
<input type="hidden" id="inout_type_io" name="inout_type_io" value="${inputParam.inout_type_io}">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
<!-- 폼테이블1 -->					
			<div>				
				<table class="table-border mt5">
					<colgroup>
						<col width="80px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
						<th class="text-right">계정구분</th>
						<td>
							<select class="form-control" id="acc_type_cd" name="acc_type_cd" readonly="readonly" disabled="disabled">
								<c:forEach var="item" items="${codeMap['ACC_TYPE']}">
									<c:if test="${item.code_value ne '2'}"><option value="${item.code_value}" ${item.code_value == inputParam.acc_type_cd ? 'selected' : ''}></c:if>${item.code_name}</option>
								</c:forEach>
							</select>
						</td>
						</tr>
						<tr>
							<th class="text-right deposit_billin dpn">어음번호</th>
							<td class="deposit_billin dpn">
								<input class="form-control" style="width:99%;" type="text" id="bill_no" name="bill_no" easyui="combogrid"
										easyuiname="billinList" panelwidth="240" idfield="bill_no" textfield="corp_cust_name" multi="N" change="fnBillinChange()"/>
							</td>
							<th class="text-right deposit_bank dpn">은행명</th>							
							<td class="deposit_bank dpn">
								<input type="text" class="form-control" readonly="readonly" id="bank_name" name="bank_name">
								<input type="hidden" class="form-control" readonly="readonly" id="ibk_bank_cd" name="ibk_bank_cd">
							</td>
							<th class="text-right deposit_card dpn">카드사</th>
							<td class="deposit_card dpn">
								<input class="form-control" style="width:99%;" type="text" id="card_cmp_cd" name="card_cmp_cd" easyui="combogrid"
										easyuiname="cardList" panelwidth="240" idfield="code_value" textfield="code_name" multi="N" change="fnCardChange()"/>
							</td>
							<th class="text-right deposit_replace dpn">대체계정</th>
							<td class="deposit_replace dpn">
								<input class="form-control" style="width:99%;" type="text" id="in_replace_acnt_cd" name="in_replace_acnt_cd" easyui="combogrid"
										easyuiname="replaceList" panelwidth="240" idfield="code_value" textfield="code_name" multi="N" change="fnReplaceChange()"/>
							</td>
						</tr>
						<tr>
							<th class="text-right deposit_billin dpn">만기일자</th>
							<td class="deposit_billin dpn">
								<input type="text" class="form-control" style="width: 80px;" readonly="readonly" id="end_dt" name="end_dt" dateFormat="yyyy-MM-dd">
							</td>
							<th class="text-right deposit_bank dpn">계좌번호</th>
							<td class="deposit_bank dpn">
								<div class="input-group">
									<input type="text" class="form-control border-right-0" readonly="readonly" id="account_no" name="account_no">
									<input type="hidden" class="form-control border-right-0" readonly="readonly" id="acct_no" name="acct_no">
									<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goBankInfo();"><i class="material-iconssearch"></i></button>							
								</div>
							</td>
							<th class="text-right deposit_card dpn">승인번호</th>
							<td class="deposit_card dpn">
								<input type="text" class="form-control" id="approval_no" name="approval_no">
							</td>
							<th class="text-right deposit_replace dpn">대체고객명</th>
							<td class="deposit_replace dpn">
								<div class="input-group">
									<input type="text" class="form-control" readonly="readonly" id="replace_cust_name" name="replace_cust_name">
									<input type="hidden" class="form-control" readonly="readonly" id="replace_cust_no" name="replace_cust_no">
									<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchCustPanel('setReplaceCustInfo');"><i class="material-iconssearch"></i></button>							
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right deposit_billin dpn">발행처</th>
							<td class="deposit_billin dpn">
								<input type="text" class="form-control" readonly="readonly" id="corp_cust_name" name="corp_cust_name">
							</td>
							<th class="text-right deposit_bank dpn">입금일자</th>
							<td class="deposit_bank dpn">
								<input type="text" class="form-control" readonly="readonly" id="acct_txday" name="acct_txday" dateFormat="yyyy-MM-dd" style="width: 80px;">
							</td>
						</tr>
						<tr>
							<th class="text-right deposit_bank dpn">입금액</th>
							<td class="deposit_bank dpn">
								<div class="form-row inline-pd">
									<div class="col-10">
										<input type="text" class="form-control text-right" readonly="readonly" id="tx_amt" name="tx_amt" format="decimal">
										<input type="hidden" class="form-control text-right" readonly="readonly" id="out_tx_amt" name="out_tx_amt">
									</div>
									<div class="col-2">원</div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right deposit_bank dpn">입금자</th>
							<td class="deposit_bank dpn">
								<input type="text" class="form-control" readonly="readonly" id="jeokyo" name="jeokyo">
							</td>
						</tr>
					</tbody>
				</table>
			</div>
<!-- /폼테이블1 -->
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