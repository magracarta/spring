<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 렌탈운영 > 렌탈장비 출고/회수현황 > null > 정산처리
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-05-21 20:04:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		
		var attachStr = [];
		var isLoad = false;
		var preUseAmt;
	
		<%-- 여기에 스크립트 넣어주세요. --%>
		$(document).ready(function() {
			fnChangeUseDt();
		});
		
		function getMachinePrice(rentalMachineNo, useCnt) {
	    	if ($M.toNum($M.getValue("use_day_cnt")) == 0) {
	    		return false;
	    	}
	    	var param = {
	    		rental_machine_no : "${inputParam.rental_machine_no}",
	    		day_cnt : $M.getValue("use_day_cnt")
	    	}
			$M.goNextPageAjax("/rent/rent010101/calc/machine", $M.toGetParam(param), {method : 'GET'},
					function(result) {
			    		if(result.success) {
			    			$M.setValue("use_amt", result.price);
							preUseAmt = result.price;
			    			getAttachPrice();
						}
					}
				);
	    }
		
		function getAttachPrice() {
			if ("${inputParam.rental_attach_str}" != "") {
				var dayArr = [];
				var tempStr = "${inputParam.rental_attach_no_str}";
				var attachStr = tempStr.split("#");
				var useCnt = $M.getValue("use_day_cnt");
				for (var i = 0; i < attachStr.length; ++i) {
					dayArr.push(useCnt);
				}
				var param = {
		    		rental_attach_no_str : "${inputParam.rental_attach_no_str}",
		    		day_cnt_str : $M.getArrStr(dayArr),
		    	}
				$M.goNextPageAjax("/rent/rent010101/calc/attach", $M.toGetParam(param), {method : 'GET'},
						function(result) {
				    		if(result.success) {
				    			var total = 0;
				    			for (var i = 0; i < result.attachPrice.length; ++i) {
				    				total+=result.attachPrice[i];
				    			}
				    			fnCalc(total);
							}
						}
					);
			} else {
				fnCalc(0);
			}
		}

		function fnCalc(attachPrice) {
			var rentAmt = "${inputParam.rental_amt}";
			var mchNouseAmt = $M.toNum($M.getValue("mch_nouse_amt"));
			var useAmt = $M.toNum(preUseAmt)+$M.toNum(attachPrice) + mchNouseAmt;
			var mchDepositAmt = $M.toNum("${inputParam.mch_deposit_amt}");
			// useAmt = $M.toNum(useAmt) + mchNouseAmt;
			<%--var mileYn = ${mile_yn eq 'Y'} ? 'Y' : 'N';--%>
			var returnAmt = rentAmt-useAmt+mchDepositAmt;
			// var mileAmt;
			// if(mileYn == 'Y' && returnAmt > 0) {
			// 	mileAmt = rentAmt * 1.1 * 0.03 * ($M.getValue("rental_day_cnt") - $M.getValue("use_day_cnt")) / $M.getValue("rental_day_cnt");
			// 	returnAmt -= mileAmt;
			// }
			var param = {
				rental_day_cnt : $M.getValue("rental_day_cnt"),
				use_day_cnt : $M.getValue("use_day_cnt"),
				rental_amt : rentAmt,
				use_amt : useAmt,
				// return_amt : returnAmt,
				calc_return_amt : returnAmt,
				mch_deposit_amt : "${inputParam.mch_deposit_amt}"
			}
			$M.setValue(param);

			if (isLoad == false) {
				$M.setValue("return_amt", returnAmt);
			}

			var lastReturnAmt = $M.toNum($M.getValue("return_amt"));
			console.log("lastReturnAmt : ", lastReturnAmt);

			// if (isLoad == false) {
				var amtMsg = "환불금액";
				if(lastReturnAmt < 0) {
					amtMsg = "연체금액";
				}
				var initRemark = "렌탈금액 : "+$M.setComma(rentAmt)+" / 사용금액 : "+$M.setComma(useAmt);
				// if(mileYn == 'Y' && returnAmt > 0) {
				// 	initRemark += " / 적립 마일리지 차감금액 : "+$M.setComma(mileAmt);
				// }
				initRemark += " / "+ amtMsg +" : "+$M.setComma(lastReturnAmt);
				$M.setValue("remark", initRemark);
				isLoad = true;
			// }


		}
		
		function fnChangeUseDt() {
			if ($M.getValue("use_ed_dt") != "") {
				var rentalCnt = $M.getDiff($M.getValue("rental_ed_dt"), $M.getValue("rental_st_dt"));
				$M.setValue("rental_day_cnt", rentalCnt);
				var useCnt = $M.getDiff($M.getValue("use_ed_dt"), $M.getValue("use_st_dt"));
				if (useCnt < 1) {
					alert("사용 종료일이 사용 시작일 이전입니다.\n회수일자에 이상이 없다면 계속 진행해주세요.");
					$M.setValue("use_st_dt", $M.getValue("use_ed_dt"));
					$M.setValue("use_day_cnt", 0);
					$M.setValue("use_amt", 0);
					fnCalc(0);
				} else {
					$M.setValue("use_day_cnt", useCnt);
					getMachinePrice();
				}
			}
		}
		
		function fnClose() {
			window.close();
		}
		
		function goReturnEarly() {
			var frm = document.main_form;
			if($M.validation(frm) == false) {
				return;
			};
			if($M.checkRangeByFieldName('use_st_dt', 'use_ed_dt', true) == false) {
				return;
			};
			var rCnt = $M.toNum($M.getValue("rental_day_cnt"));
			var uCnt = $M.toNum($M.getValue("use_day_cnt"));
			console.log(rCnt, uCnt);
			// if (rCnt <= uCnt) {
			// 	alert("사용기간이 조기회수가 아닙니다.");
			// 	$("#use_ed_dt").focus();
			// 	return false;
			// };
			if ("${inputParam.out_dt}" > $M.getValue("use_ed_dt")) {
				alert("사용종료일이 출고일("+"${inputParam.out_dt}"+") 이전입니다.");
				return false;
			}

			frm = $M.toValueForm(frm);
			var param = {
				rental_machine_no : "${inputParam.rental_machine_no}",
				rental_doc_no : $M.getValue("rental_doc_no"),
				machine_seq : $M.getValue("machine_seq"),
				op_dt : $M.getValue("op_dt"),
				op_hour : $M.getValue("op_hour"),
				rental_st_dt : $M.getValue("rental_st_dt"),
				rental_ed_dt : $M.getValue("rental_ed_dt"),
				rental_amt : $M.getValue("rental_amt"),
				rental_day_cnt : $M.getValue("rental_day_cnt"),
				use_st_dt : $M.getValue("use_st_dt"),
				use_ed_dt : $M.getValue("use_ed_dt"),
				use_day_cnt : $M.getValue("use_day_cnt"),
				use_amt : $M.getValue("use_amt"), 
				return_amt : $M.getValue("return_amt"),
				return_bank_name : $M.getValue("return_bank_name"),
				return_account_no : $M.getValue("return_account_no"),
				return_deposit_name : $M.getValue("return_deposit_name"),
				remark : $M.getValue("remark"),
				return_memo : $M.getValue("return_memo"),
				return_job_hour : $M.getValue("return_job_hour"),
				return_mem_no : $M.getValue("return_mem_no"),
				rental_attach_no_str : "${inputParam.rental_attach_no_str}",
				mch_nouse_amt : $M.getValue("mch_nouse_amt"),
			}
			// if (param.return_amt < 0) {
			// 	alert("환불금액을 다시 확인하십시오.\n환불금액은 0 또는 양수여야합니다.");
			// 	return false;
			// }
			if (confirm("비고, 렌탈금액, 사용금액, 환불(연체)금액을 확인하셨습니까?") == false) {
				return false;
			}
			$M.goNextPageAjaxMsg("정산처리 하시겠습니까?",this_page, frm, {method : 'POST'},
					function(result) {
			    		if(result.success) {
			    			alert("처리가 완료되었습니다. 매출처리 후 거래원장을 다시 확인하세요."
									+"\n문서는 매출처리 시 종결 상태로 자동으로 변경됩니다.");
			    			opener.fnReload();
			    			var param = {
			    				early_return_yn : "Y",
			    				rental_doc_no : $M.getValue("rental_doc_no"),
			    				doc_amt : $M.toNum($M.getValue("return_amt")) * -1
			    			}
			    			openInoutProcPanel("fnSetSaleResult", $M.toGetParam(param));
						}
					}
				);
		}
		
		function fnSetSaleResult() {
			fnClose();
		}
	
	</script>
</head>
<body  class="bg-white" >
<form id="main_form" name="main_form">
<input type="hidden" id="op_hour" name="op_hour" value="${inputParam.op_hour }">
<input type="hidden" id="return_memo" name="return_memo" value="${inputParam.return_memo }">
<input type="hidden" id="return_job_hour" name="return_job_hour" value="${inputParam.return_job_hour }">
<input type="hidden" id="return_mem_no" name="return_mem_no" value="${inputParam.return_mem_no }">
<input type="hidden" id="rental_doc_no" name="rental_doc_no" value="${inputParam.rental_doc_no }">
<input type="hidden" id="machine_seq" name="machine_seq" value="${inputParam.machine_seq}">
<!-- 팝업 -->
	<div  class="popup-wrap width-100per"  >
<!-- 타이틀영역 -->
        <div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">	
			<div class="title-wrap approval-left">
				<h4>정산처리</h4>
			</div>
			<table class="table-border mt5">
				<colgroup>
					<col width="100px">
					<col width="">
				</colgroup>
				<tbody>
					<tr>
						<th class="text-right rs">렌탈계약기간</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width110px">
									<div class="input-group">
										<input type="text" class="form-control border-right-0 calDate" id="rental_st_dt" name="rental_st_dt" dateFormat="yyyy-MM-dd" value="${inputParam.rental_st_dt}" alt="렌탈 시작일" disabled="disabled">
									</div>
								</div>
								<div class="col-auto text-center">~</div>
								<div class="col width110px">
									<div class="input-group">
										<input type="text" class="form-control border-right-0 calDate" id="rental_ed_dt" name="rental_ed_dt" dateFormat="yyyy-MM-dd"  value="${inputParam.rental_ed_dt}" alt="렌탈 종료일" disabled="disabled">
									</div>
								</div>
								<div class="col width50px text-right">
									<input type="text" class="form-control" readonly="readonly" id="rental_day_cnt" name="rental_day_cnt" format="decimal">
								</div>
								<div class="col width16px">
									일
								</div>
							</div>
						</td>
					</tr>
					<tr>
						<th class="text-right rs">사용기간</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width110px">
									<div class="input-group">
										<input type="text" class="form-control border-right-0 calDate" id="use_st_dt" name="use_st_dt" dateFormat="yyyy-MM-dd"  value="${inputParam.use_st_dt}" alt="사용 시작일" disabled="disabled">
									</div>
								</div>
								<div class="col-auto text-center">~</div>
								<div class="col width110px">
									<div class="input-group">
										<input type="text" class="form-control border-right-0 calDate rb" id="use_ed_dt" name="use_ed_dt" dateFormat="yyyy-MM-dd"  value="${inputParam.use_ed_dt}" alt="사용 종료일" onchange="javascript:fnChangeUseDt()" required="required" disabled="disabled">
									</div>
								</div>
								<div class="col width50px text-right">
									<input type="text" class="form-control" readonly="readonly" id="use_day_cnt" name="use_day_cnt" format="decimal">
								</div>
								<div class="col width16px">
									일
								</div>
							</div>
						</td>
					</tr>
					<tr>
						<th class="text-right rs">렌탈금액</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width100px">
									<input type="text" class="form-control text-right" readonly="readonly" id="rental_amt" name="rental_amt" value="${inputParam.rental_amt}" format="decimal">
								</div>
								<div class="col width16px">원</div>
								(총렌탈료-렌탈료조정, 운임비 제외 금액)
							</div>									
						</td>
					</tr>
					<tr>
						<th class="text-right rs">사용금액</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width100px">
									<input type="text" class="form-control text-right" readonly="readonly" id="use_amt" name="use_amt" format="decimal">
								</div>
								<div class="col width16px">원</div>
							</div>									
						</td>
					</tr>
					<tr>
						<th class="text-right rs">정산금액</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width100px">
									<input type="text" class="form-control text-right" id="calc_return_amt" name="calc_return_amt" format="minusNum" readonly="readonly">
								</div>
								<div class="col width16px">원</div>
								(렌탈금액-사용금액+장비보증금, 음수인 경우 연체비용, 양수인 경우 환불비용)
							</div>									
						</td>
					</tr>
					<tr>
						<th class="text-right rs">최종정산금액</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width100px">
									<input type="text" class="form-control text-right" id="return_amt" name="return_amt" format="minusNum" onchange="javascript:fnCalc()">
								</div>
								<div class="col width16px">원</div>
								(정산처리시 해당 금액이 반영됩니다.)
							</div>
						</td>
					</tr>
					<tr>
						<th class="text-right">정산은행</th>
						<td>
							<input type="text" class="form-control width140px" placeholder="은행명" id="return_bank_name" name="return_bank_name" maxlength="10" alt="정산은행명">
						</td>
					</tr>
					<tr>
						<th class="text-right">정산계좌</th>
						<td>
							<input type="text" class="form-control width140px" placeholder="계좌번호" id="return_account_no" name="return_account_no" maxlength="20" alt="정산계좌">
						</td>
					</tr>
					<tr>
						<th class="text-right">예금주명</th>
						<td>
							<input type="text" class="form-control width140px" id="return_deposit_name" name="return_deposit_name" maxlength="10" alt="예금주">						
						</td>
					</tr>
					<tr>
						<th class="text-right">장비보증금</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width100px">
									<input type="text" class="form-control text-right" id="mch_deposit_amt" name="mch_deposit_amt" format="minusNum" readonly="readonly">
								</div>
								<div class="col width16px">원</div>
							</div>
						</td>
					</tr>
					<tr>
						<th class="text-right rs">휴차료</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width100px">
									<input type="text" class="form-control text-right" id="mch_nouse_amt" name="mch_nouse_amt" format="minusNum" onchange="javascript:fnCalc()">
								</div>
								<div class="col width16px">원</div>
								(음수인 경우 고객환불, 양수인 경우에는 고객청구)
							</div>
						</td>
					</tr>
					<tr>
						<th class="text-right">비고</th>
						<td>
							<textarea class="form-control" style="height: 70px;" id="remark" name="remark" maxlength="300"></textarea>
						</td>
					</tr>							
				</tbody>
			</table>
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