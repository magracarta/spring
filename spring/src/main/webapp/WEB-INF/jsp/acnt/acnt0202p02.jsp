<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 장부 > 자금일보관리 > null > 외화
-- 작성자 : 황빛찬
-- 최초 작성일 : 2020-09-01 17:55:01

-- 수정자 : ywm2004 (정재호)
-- 수정일 : 2022-08-04 00:00:00
-- [3차 QNA-14445] 외화 기능 제거됨.
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
	$(document).ready(function() {
		$M.setValue("apply_er_price", ${map.apply_er_price});
		$("#fe_before_money_name").text("${map.money_unit_cd}");
	});
	
	function goModify() {
// 		var moneyUnitCdVal;
// 		switch($M.getValue("funds_type_cd")) {
// 			case "2" :
// 				moneyUnitCdVal = "JPY";
// 				break;
// 			case "3" :
// 				moneyUnitCdVal = "USD";
// 				break;
// 			case "4" :
// 				moneyUnitCdVal = "EUR";
// 				break;
// 		}
// 		$M.setValue("money_unit_cd", moneyUnitCdVal);
		
		if ($M.getValue("fe_in_amt") == "" && $M.getValue("fe_out_amt") == "") {
			alert("입금액, 출금액 중 하나는 필수 입력입니다.");
			return;
		}
		
		var frm = document.main_form;
		
		// 입력폼 벨리데이션
		if($M.validation(frm) == false) {
			return;
		}
		
		if (confirm("수정하시겠습니까?") == false) {
			return false;
		}
		
		frm = $M.toValueForm(frm);
		console.log(frm);
		
		$M.goNextPageAjax(this_page + "/modify", frm , {method : 'POST'},
			function(result) {
	    		if(result.success) {
	    			alert("수정이 완료되었습니다.");
	    			fnClose();
// 					window.opener.location.reload();
	    			opener.goSearch($M.getValue("funds_dt"));
				}
			}
		);
	}

	function goRemove() {
		if (confirm("삭제하시겠습니까?") == false) {
			return false;
		}
		
		var fundsDailyNo = $M.getValue("funds_daily_no");
		console.log(fundsDailyNo);
		
		var param = {
				funds_daily_no : $M.getValue("funds_daily_no")
		}
		
		$M.goNextPageAjax(this_page + "/remove" , $M.toGetParam(param) , {method : 'POST'},
			function(result) {
	    		if(result.success) {
	    			alert("삭제 처리 되었습니다.");
	    			fnClose();
// 	    			window.opener.location.reload();
	    			opener.goSearch($M.getValue("funds_dt"));
				}
			}
		);	
	}

	function fnClose() {
		window.close();
	}

	// 관리번호 팝업 호출
// 	function fnGetDepositCode() {
// 		var fundsTypeCode = $M.getValue("funds_type_cd"); // 처리구분
// 		console.log("fundsTypeCode : ", fundsTypeCode);
		
// 		if (fundsTypeCode == "") {
// 			alert("처리구분을 먼저 선택해 주세요.");
// 			return;
// 		}
		
// // 		var param = {
// // 			s_sort_key : "acnt_code",
// // 			s_sort_method : "asc",
// // 			"parent_js_name" : "fnSetDeposit"
// // 		};
						
// // 		var popupOption = "";
// // 		$M.goNextPage('/acnt/acnt0202p03', $M.toGetParam(param), {popupStatus : popupOption});

// 		// 외화일경우 무조건 '10302' , 예금조회 공통팝업 호출
// 		var acntCodeArr = ["10302"];
// 		var param = {
// 				"s_acnt_code" : $M.getArrStr(acntCodeArr)
// 		}
// 		openDepositInfoPanel('setDepositInfoPanel', $M.toGetParam(param));
// 	}
	
// 	function setDepositInfoPanel(result) {
// 		$M.setValue("deposit_code", result.deposit_code);
// 		$M.setValue("deposit_name", result.deposit_name);
		
// 		var fundsTypeCd = $M.getValue("funds_type_cd");
// 		console.log("fundsTypeCd : ", fundsTypeCd);
		
// 		// 관리번호 변경시 이월금액 조회
// 		var param = {
// 				funds_dt : $M.getValue("funds_dt"),
// 				funds_type_cd : fundsTypeCd,
// 				deposit_code : $M.getValue("deposit_code")
// 			};
			
// 		$M.goNextPageAjax("/acnt/acnt0202p04/search/amt", $M.toGetParam(param), {method : 'get'},
// 			function(result) {
// 				if(result.success) {
// 					beforeMoney = result.map.before_money;
// 					console.log("beforeMoney ?? ", beforeMoney);
// 					$M.setValue("before_money", beforeMoney);
// 					fnChangeAmt();
// 				};
// 			}		
// 		);
// 	}
	
	// 관리번호 팝업에서 받아온 데이터 세팅
// 	function fnSetDeposit(result) {
// 		console.log(result);
// 		$M.setValue("deposit_code", result.deposit_code);
// 		$M.setValue("deposit_name", result.deposit_name);
		
// // 		goSearchBeforeAmt();
		
// 		var param = {
// 				funds_dt : $M.getValue("funds_dt"),
// 				funds_type_cd : $M.getValue("funds_type_cd"),
// 				deposit_code : $M.getValue("deposit_code")
// 			};
			
// 		$M.goNextPageAjax("/acnt/acnt0202p05/search/amt", $M.toGetParam(param), {method : 'get'},
// 			function(result) {
// 				if(result.success) {
// 					console.log(result);
// 					$M.setValue("before_money", result.map.before_amt);
// 					$M.setValue("fe_before_money", result.map.fe_before_amt);
// 					$M.setValue("after_money", result.map.balance_amt);
// 					fnChangeAmt();
// 				};
// 			}		
// 		);	
// 	}
	
	// 환율 구해오기
	function goSearchExchange(val) {
		console.log(val);
		
		$("#fe_before_money_name").text(val);
		
// 		var moneyUnitCdVal;
		if (val != "") {
// 			if (val == "2") {
// 				moneyUnitCdVal = "JPY";	
// 			} else if (val == "3") {
// 				moneyUnitCdVal = "USD";	
// 			} else if (val == "4") {
// 				moneyUnitCdVal = "EUR";	
// 			}
// 			var moneyUnitCd = val;
			var param = {
					money_unit_cd : val,
					funds_dt : $M.getValue("funds_dt")
				};
				
			$M.goNextPageAjax("/acnt/acnt0202p05/search/exchange", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						console.log("result : ", result);
						
						if (result.map != "")  {
							$M.setValue("apply_er_price", result.map.fixed_er_price);
							fnChangeExchange(result.map.fixed_er_price);
						} else {
							$M.setValue("apply_er_price", "");
						}
						
						if (result.amtMap != undefined)  {
							$M.setValue("before_money", Math.round(result.amtMap.before_amt));
							$M.setValue("fe_before_money", result.amtMap.fe_before_amt);
							$M.setValue("after_money", Math.round(result.amtMap.balance_amt));
						} else {
							$M.setValue("before_money", 0);
							$M.setValue("fe_before_money", 0);
							$M.setValue("after_money", 0);
						}
					};
				}		
			);
			
			$M.clearValue({field:["deposit_code", "deposit_name", "before_money", "after_money", "fe_before_money", "fe_in_amt", "fe_out_amt"]});
		} else {
			$M.clearValue({field:["apply_er_price", "deposit_code", "deposit_name", "before_money", "after_money", "fe_before_money", "fe_in_amt", "fe_out_amt", "in_amt", "out_amt"]});
		}
	}
	
	// 입금,출금액 계산
	function fnChangeAmt(val) {
// 		var fundsTypeCode = $M.getValue("funds_type_cd"); // 처리구분
		var moneyUnitCode = $M.getValue("money_unit_cd"); // 처리구분
// 		console.log("fundsTypeCode : ", fundsTypeCode);
		console.log("moneyUnitCode : ", moneyUnitCode);
		
		if (moneyUnitCode == "") {
			alert("처리구분을 먼저 선택해 주세요.");
			$M.clearValue({field:["fe_in_amt", "fe_out_amt", "apply_er_price"]});
			return;
		}
		
// 		var feInAmtVal = val;
		var feInAmt = $M.getValue("fe_in_amt");
		var feOutAmt = $M.getValue("fe_out_amt");
		console.log("feInAmt : ", feInAmt);
		console.log("feOutAmt : ", feOutAmt);
		
		var applyErPrice = $M.getValue("apply_er_price");
		
		var inAmt = feInAmt * applyErPrice; // 입금액(원화)
		var outAmt = feOutAmt * applyErPrice; // 출금액(원화)
		
		console.log("inAmt : ", inAmt);
		console.log("outAmt : ", outAmt);
		
		$M.setValue("in_amt", Math.round(inAmt));
		$M.setValue("out_amt", Math.round(outAmt));
		
		fnSetAfterMoney();
		
	}
	
	// 환율
	function fnChangeExchange(val) {
		$M.setValue("apply_er_price", val);
		fnChangeAmt();
		fnSetAfterMoney();
	}
	
	// 잔액 구하기
	function fnSetAfterMoney() {
		var beforeMoney = Number($M.getValue("before_money")); // 이월액
		var inAmt = Number($M.getValue("in_amt"));  // 입금액
		var outAmt = Number($M.getValue("out_amt"));  // 출금액

		var afterMoney = (beforeMoney + inAmt) - outAmt;
		console.log("afterMoney : ", afterMoney);
		
		$M.setValue("after_money", Math.round(afterMoney));
	}
	
	</script>
</head>
<body class="bg-white">
<!-- 팝업 -->
<form id="main_form" name="main_form">
<input type="hidden" name="funds_daily_no" value="${map.funds_daily_no}">
<!-- <input type="hidden" name="money_unit_cd"> -->
<div class="popup-wrap width-100per">
	<!-- 타이틀영역 -->
	<div class="main-title">
		<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
	</div>
	<!-- /타이틀영역 -->
	<div class="content-wrap">
		<!-- 외화 -->
		<div>
			<div class="title-wrap">
				<h4>외화</h4>
			</div>
			<table class="table-border mt5">
				<colgroup>
					<col width="100px">
					<col width="">
					<col width="100px">
					<col width="">
				</colgroup>
				<tbody>
				<tr>
					<th class="text-right essential-item">처리일자</th>
					<td>
						<div class="input-group">
							<input type="text" class="form-control width80px" id="funds_dt" name="funds_dt" dateFormat="yyyy-MM-dd" value="${map.funds_dt}" alt="자금일자" required="required" readonly>
						</div>
					</td>
					<th class="text-right essential-item">처리구분</th>
					<td>
						<select class="form-control width120px essential-bg" id="money_unit_cd" name="money_unit_cd" required="required" alt="처리구분" onchange="javascript:goSearchExchange(this.value);">
							<option value="">- 선택 -</option>
							<option value="JPY" ${'JPY' eq map.money_unit_cd ? 'selected' : ''}>JPY(엔화)</option>
							<option value="EUR" ${'EUR' eq map.money_unit_cd ? 'selected' : ''} >EUR(유로)</option>
							<option value="USD" ${'USD' eq map.money_unit_cd ? 'selected' : ''} >USD(달러)</option>
							<option value="SGD" ${'SGD' eq map.money_unit_cd ? 'selected' : ''} >SGD(싱가폴)</option>
							<option value="GBP" ${'GBP' eq map.money_unit_cd ? 'selected' : ''} >GBP(파운드)</option>
							<option value="CNY" ${'CNY' eq map.money_unit_cd ? 'selected' : ''} >CNY(위안)</option>							
<%-- 							<c:forEach var="item" items="${codeMap['FUNDS_TYPE']}"> --%>
<%-- 								<c:if test="${item.code_value ne '0'}"> --%>
<%-- 									<option value="${item.code_value}" ${item.code_value == map.money_unit_val ? 'selected' : ''}>${item.code_name}</option> --%>
<%-- 								</c:if> --%>
<%-- 							</c:forEach> --%>
						</select>
					</td>
				</tr>
<!-- 				<tr> -->
<!-- 					<th class="text-right">관리번호</th> -->
<!-- 					<td> -->
<!-- 						<div class="form-row inline-pd"> -->
<!-- 							<div class="col-5"> -->
<!-- 								<div class="input-group"> -->
<%-- 									<input type="text" class="form-control border-right-0" id="deposit_code" name="deposit_code" readonly required="required" alt="관리번호" value="${map.deposit_code}"> --%>
<!-- 									<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnGetDepositCode();"><i class="material-iconssearch"></i></button> -->
<!-- 								</div> -->
<!-- 							</div> -->
<!-- 							<div class="col-7"> -->
<%-- 								<input type="text" class="form-control" id="deposit_name" name="deposit_name" value="${map.deposit_name}" readonly> --%>
<!-- 							</div> -->
<!-- 						</div> -->
<!-- 					</td> -->
<!-- 				</tr> -->
				<tr>
					<th class="text-right">이월(외화)</th>
					<td>
						<div class="form-row inline-pd widthfix">
							<div class="col width160px">
								<input type="text" class="form-control text-right" id="fe_before_money" name="fe_before_money" format="decimal" datatype="int" alt="이월액" readonly value="${map.fe_before_amt}">
							</div>
<!-- 							<div class="col width22px">원</div> -->
							<div class="col width30px" id="fe_before_money_name" name="fe_before_money_name"></div>
						</div>
					</td>
					<th class="text-right">이월(원화)</th>
					<td>
						<div class="form-row inline-pd widthfix">
							<div class="col width160px">
								<input type="text" class="form-control text-right" id="before_money" name="before_money" format="decimal" datatype="int" alt="이월액" readonly value="${map.before_amt}">
							</div>
							<div class="col width22px">원</div>
						</div>
					</td>
				</tr>
				<tr>
					<th class="text-right essential-item">입금</th>
					<td colspan="3">
						<div class="form-row inline-pd widthfix">
							<div class="col width160px">
								<input type="text" class="form-control text-right essential-bg" id="fe_in_amt" name="fe_in_amt" value="${map.fe_in_amt}" format="decimal" alt="외화입금액" onchange="javascript:fnChangeAmt(this.value);">
							</div>
							<div class="col width160px">
								<input type="text" class="form-control essential-bg" placeholder="환율" id="apply_er_price" name="apply_er_price" required="required" format="decimal4" alt="환율" onchange="javascript:fnChangeExchange(this.value);">
							</div>
							<div class="col width16px text-center">
								=
							</div>
							<div class="col width160px">
								<input type="text" class="form-control essential-bg text-right" id="in_amt" name="in_amt" value="${map.in_amt}" datatype="int" format="decimal" alt="입금액" required="required" onchange="javascript:fnSetAfterMoney();">
							</div>
						</div>
					</td>
				</tr>
				<tr>
					<th class="text-right essential-item">출금</th>
					<td colspan="3">
						<div class="form-row inline-pd widthfix">
							<div class="col width160px">
								<input type="text" class="form-control text-right essential-bg" id="fe_out_amt" name="fe_out_amt" value="${map.fe_out_amt}" format="decimal" alt="외화출금액" onchange="javascript:fnChangeAmt(this.value);">
							</div>
							<div class="col width160px">
								<input type="text" class="form-control essential-bg" placeholder="환율" id="apply_er_price" name="apply_er_price" required="required" format="decimal4" alt="환율" onchange="javascript:fnChangeExchange(this.value);">
							</div>
							<div class="col width16px text-center">
								=
							</div>
							<div class="col width160px">
								<input type="text" class="form-control essential-bg text-right" id="out_amt" name="out_amt" value="${map.out_amt}" format="decimal" alt="출금액" required="required" onchange="javascript:fnSetAfterMoney();">
							</div>
						</div>
					</td>
				</tr>
				<tr>
					<th class="text-right">잔액</th>
					<td colspan="3">
						<div class="form-row inline-pd widthfix">
							<div class="col width160px">
								<input type="text" class="form-control text-right" id="after_money" name="after_money" format="decimal" alt="잔액" readonly value="${map.balance_amt}">
							</div>
							<div class="col width22px">원</div>
						</div>
					</td>
				</tr>
				<tr>
					<th class="text-right">비고</th>
					<td colspan="3">
						<textarea class="form-control" style="height: 100px;" id="remark" name="remark">${map.remark}</textarea>
					</td>
				</tr>
				</tbody>
			</table>
		</div>
		<!-- /외화 -->
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