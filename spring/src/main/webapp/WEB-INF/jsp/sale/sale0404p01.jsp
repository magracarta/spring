<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 판매관리 > 영업직원개인별실적 > null > 실적분석
-- 작성자 : 손광진
-- 최초 작성일 : 2019-09-25 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function() {
			fnSetValue();
		});
		
		
		function goSave() {

			var param = {
				machine_doc_no 		: $M.getValue("machine_doc_no"),
				profit_loss_amt 	: $M.getValue("profit_loss_amt"),
				base_assist_amt 	: $M.getValue("base_assist_amt"),
				mon_ms_reward_amt 	: $M.getValue("mon_ms_reward_amt"),
				year_ms_reward_amt 	: $M.getValue("year_ms_reward_amt"),
				svc_deduct_amt 		: $M.getValue("svc_deduct_amt"),
				etc_adjust_amt 		: $M.getValue("etc_adjust_amt"),
			};
			
 			$M.goNextPageAjaxSave(this_page + '/save', $M.toGetParam(param), {method : 'POST'},
				function(result) {
					if(result.success) {
						fnClose();
		    			window.opener.goSearch();
					}
				}
			);
		}
		
		function fnClose() {
			window.close();
		}
		
		
		
		function fnSetValue() {
			
			// 손익  = 실판매금액 - 손익기준가
			var incomeAmt = $M.toNum($M.nvl($M.getValue("sale_money"), 0)) - $M.toNum($M.nvl($M.getValue("profit_loss_amt"), 0));
			$M.setValue("income_amt", incomeAmt);
			
			// 손익계 = 손익 + 본사지원 + 기타조정 + 월 MS보상 + 년 MS보상 + 서비스공제
			var income_amt_total = $M.toNum($M.nvl($M.getValue("income_amt"), 0)) + $M.toNum($M.nvl($M.getValue("base_assist_amt"), 0))
								 + $M.toNum($M.nvl($M.getValue("etc_adjust_amt"), 0)) + $M.toNum($M.nvl($M.getValue("mon_ms_reward_amt"), 0))
								 + $M.toNum($M.nvl($M.getValue("year_ms_reward_amt"), 0)) + $M.toNum($M.nvl($M.getValue("svc_deduct_amt"), 0));
			$M.setValue("income_amt_total", income_amt_total);
			 	     
			// 손익율 = 손익계 / 손익기준가
			var income_per = fixNumberScale($M.toNum($M.nvl($M.getValue("income_amt_total"), 0)) / $M.toNum($M.nvl($M.getValue("profit_loss_amt"), 0)) * 100);
			$M.setValue("income_per", isFinite(income_per) == true ? income_per : 0);
		}
		
		function fixNumberScale(number, scale) {
			var ex = Math.pow(10, 2);
			return Math.round(number * ex) / ex;
		}

	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<input type="hidden" name="machine_doc_no" id="machine_doc_no" value="${memSaleInfo.machine_doc_no}">

<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
<!--             <h2>실질분석</h2> -->
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
<!--             <button type="button" class="btn btn-icon"><i class="material-iconsclose"></i></button> -->
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
<!-- 폼테이블 -->					
			<div>
				<div class="title-wrap">
					<h4><strong>${memSaleInfo.cust_name}</strong>님 조회결과</h4>
				</div>
				<table class="table-border mt5">
					<colgroup>
						<col width="90px">
						<col width="">
						<col width="90px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right">관리번호</th>
							<td>${memSaleInfo.machine_doc_no}</td>
							<th class="text-right">출하일자</th>
							<td>${memSaleInfo.out_dt}</td>						
						</tr>	
						<tr>
							<th class="text-right">고객명</th>
							<td>${memSaleInfo.cust_name}</td>
							<th class="text-right">모델명</th>
							<td>${memSaleInfo.machine_name}</td>						
						</tr>
					</tbody>
				</table>
			</div>		
<!-- /폼테이블 -->
<!-- 실판매금액 -->					
			<div>
				<table class="table-border doc-table mt10">
					<colgroup>
						<col width="90px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right">실판매금액</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-1 text-center"></div>
									<div class="col-9">
										<input type="text" class="form-control text-right" id="sale_money" name="sale_money" format="decimal" value="${memSaleInfo.sale_money}" readonly="readonly">
									</div>
									<div class="col-auto">원</div>
								</div>
							</td>					
						</tr>	
						<tr>
							<th class="text-right">손익기준가</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-1 text-center">-</div>
									<div class="col-9">
										<input type="text" class="form-control text-right" id="profit_loss_amt" name="profit_loss_amt" format="decimal" value="${memSaleInfo.income_ref_amt}" onkeyup="javascript:fnSetValue();">		
									</div>
									<div class="col-auto">원</div>
								</div>
							</td>					
						</tr>
						<tr>
							<th class="text-right">손익</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-1 text-center">=</div>
									<div class="col-9"> 
										<input type="text" class="form-control text-right" id="income_amt" name="income_amt" format="decimal" value="${memSaleInfo.income_amt}" readonly="readonly">
									</div>
									<div class="col-auto">원</div>
								</div>
							</td>					
						</tr>
						<tr>
							<th class="text-right">본사지원</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-1 text-center">+</div>
									<div class="col-9">
										<input type="text" class="form-control text-right" id="base_assist_amt" name="base_assist_amt" format="decimal" value="${memSaleInfo.base_support_amt}" onkeyup="javascript:fnSetValue();">
									</div>
									<div class="col-auto">원</div>
								</div>
							</td>					
						</tr>
						<tr>
							<th class="text-right">기타조정</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-1 text-center">+</div>
									<div class="col-9">
										<input type="text" class="form-control text-right" id="etc_adjust_amt" name="etc_adjust_amt" format="decimal" value="${memSaleInfo.etc_adjust_amt}" onkeyup="javascript:fnSetValue();">
									</div>
									<div class="col-auto">원</div>
								</div>
							</td>					
						</tr>
						<tr>
							<th class="text-right">월MS보상</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-1 text-center">+</div>
									<div class="col-9">
										<input type="text" class="form-control text-right" id="mon_ms_reward_amt" name="mon_ms_reward_amt" format="decimal" value="${memSaleInfo.mm_ms_amt}" onkeyup="javascript:fnSetValue();">
									</div>
									<div class="col-auto">원</div>
								</div>
							</td>					
						</tr>
						<tr>
							<th class="text-right">년MS보상</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-1 text-center">+</div>
									<div class="col-9">
										<input type="text" class="form-control text-right" id="year_ms_reward_amt" name="year_ms_reward_amt" format="decimal" value="${memSaleInfo.yyyy_ms_amt}" onkeyup="javascript:fnSetValue();">
									</div>
									<div class="col-auto">원</div>
								</div>
							</td>					
						</tr>
						<tr>
							<th class="text-right">서비스공제</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-1 text-center">+</div>
									<div class="col-9"> 
										<input type="text" class="form-control text-right" id="svc_deduct_amt" name="svc_deduct_amt" format="decimal" value="${memSaleInfo.service_ded_amt}" onkeyup="javascript:fnSetValue();">
									</div>
									<div class="col-auto">원</div>
								</div>
							</td>					
						</tr>	
						<tr>
							<th class="text-right">손익계</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-1 text-center">=</div>
									<div class="col-9">
										<input type="text" class="form-control text-right" readonly id="income_amt_total" name="income_amt_total" format="decimal" value="${memSaleInfo.income_amt_total}" readonly="readonly">
									</div>
									<div class="col-auto">원</div>
								</div>
							</td>					
						</tr>		
						<tr>
							<th class="text-right">손익율</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-6 spacing-sm">손익계 / 손익기준가 X 100 =</div>
									<div class="col-4">
										<input type="text" class="form-control text-right" id="income_per" name="income_per" format="decimal" value="${memSaleInfo.income_per}" readonly="readonly">
									</div>
									<div class="col-auto">%</div>
								</div>
							</td>					
						</tr>
					</tbody>
				</table>
			</div>		
<!-- /실판매금액 -->
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