<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 장부 > 자금일보관리 > null > 원화 + 외화예금 등록
-- 작성자 : 황빛찬
-- 최초 작성일 : 2020-09-01 17:55:01
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
	var calcAmt;
	
	$(document).ready(function() {
		
	});
	
	function goSave() {
		var moneyUnitCdVal;
		switch($M.getValue("funds_type_cd")) {
			case "0" : 
				moneyUnitCdVal = "KRW";
				break;
			case "1" :
				moneyUnitCdVal = "KRW";
				break;
			case "2" :
				moneyUnitCdVal = "JPY";
				break;
			case "3" :
				moneyUnitCdVal = "USD";
				break;
			case "4" :
				moneyUnitCdVal = "EUR";
				break;
		}
		$M.setValue("money_unit_cd", moneyUnitCdVal);
		console.log("moneyUnitCdVal : ", moneyUnitCdVal);

		var frm = document.main_form;
		
		// 입력폼 벨리데이션
		if($M.validation(frm) == false) {
			return;
		}
		
		if ($M.getValue("in_amt") == "" && $M.getValue("out_amt") == "") {
			alert("입금액, 출금액 중 하나는 필수 입력입니다.");
			return;
		}
		
		// 처리구분이 외화일경우 관리번호는 필수입력.
		if ($M.getValue("funds_type_cd") != "0") {
			if ($M.getValue("deposit_code") == "") {
				alert("관리번호를 선택해 주세요.");
				return;
			}
		}
		
		if (confirm("저장하시겠습니까?") == false) {
			return false;
		}
		
		frm = $M.toValueForm(frm);
		console.log(frm);
		
		$M.goNextPageAjax(this_page + "/save", frm , {method : 'POST'},
			function(result) {
	    		if(result.success) {
	    			alert("저장이 완료되었습니다.");
	    			fnClose();
// 					window.opener.location.reload();
					opener.goSearch($M.getValue("funds_dt"));
				}
			}
		);
	}

	function fnClose() {
		window.close();
	}
	
	// 관리번호 팝업 호출
	function fnGetDepositCode() {
		var fundsTypeCode = $M.getValue("funds_type_cd"); // 처리구분
		console.log("fundsTypeCode : ", fundsTypeCode);
		
		if (fundsTypeCode == "") {
			alert("처리구분을 먼저 선택해 주세요.");
			return;
		}
		
		if (fundsTypeCode == 0) {
			alert("현금일 경우 관리번호를 선택 할 수 없습니다.");
			return;
		}
		
// 		var param = {
// 			s_sort_key : "acnt_code",
// 			s_sort_method : "asc",
// 			"parent_js_name" : "fnSetDeposit"
// 		};
						
// 		var popupOption = "";
// 		$M.goNextPage('/acnt/acnt0202p03', $M.toGetParam(param), {popupStatus : popupOption});

		// 외화일경우 무조건 '10302' , 예금조회 공통팝업 호출
		var acntCodeArr = ["10302"];
		var param = {
				"s_acnt_code" : $M.getArrStr(acntCodeArr)
		}
		openDepositInfoPanel('setDepositInfoPanel', $M.toGetParam(param));
	}
	
	function setDepositInfoPanel(result) {
		$M.setValue("deposit_code", result.deposit_code);
		$M.setValue("deposit_name", result.deposit_name);
		
		var fundsTypeCd = $M.getValue("funds_type_cd");
		console.log("fundsTypeCd : ", fundsTypeCd);
		
		// 관리번호 변경시 이월금액 조회
		var param = {
				funds_dt : $M.getValue("funds_dt"),
				funds_type_cd : fundsTypeCd,
				deposit_code : $M.getValue("deposit_code")
			};
			
		$M.goNextPageAjax("/acnt/acnt0202p04/search/amt", $M.toGetParam(param), {method : 'get'},
			function(result) {
				if(result.success) {
					beforeMoney = result.map.before_money;
					console.log("beforeMoney ?? ", beforeMoney);
					$M.setValue("before_money", beforeMoney);
					goSearchAfterAmt(fundsTypeCd);
				};
			}		
		);
	}
	
	// 관리번호 팝업에서 받아온 데이터 세팅
// 	function fnSetDeposit(result) {
// 		console.log(result);
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
			
// 		$M.goNextPageAjax(this_page + "/search/amt", $M.toGetParam(param), {method : 'get'},
// 			function(result) {
// 				if(result.success) {
// 					beforeMoney = result.map.before_money;
// 					console.log("beforeMoney ?? ", beforeMoney);
// 					$M.setValue("before_money", beforeMoney);
// 					goSearchAfterAmt();
// 				};
// 			}		
// 		);
// 	}
	
	// 처리구분이 현금일경우 이월금액 조회
	function goSearchBeforeAmt(val) {
		if (val == "0") {
			var param = {
					funds_dt : $M.getValue("funds_dt"),
					funds_type_cd : val,
					money_unit_cd : "KRW"
				};
				
			$M.goNextPageAjax(this_page + "/search/amt", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						beforeMoney = result.map.before_money;
						console.log("beforeMoney ?? ", beforeMoney);
						$M.setValue("before_money", beforeMoney);
						goSearchAfterAmt(val);
					};
				}		
			);	
			
			$M.clearValue({field:["deposit_code", "deposit_name", "in_amt", "out_amt"]});
		} else {
			$M.clearValue({field:["before_money", "in_amt", "out_amt", "after_money", "deposit_code", "deposit_name"]});
		}		
	}

	// 처리일자가 변경될경우 이월금 다시 조회
	function goSearchBeforeAmt2() {
		var fundsTypeCdVal = $M.getValue("funds_type_cd")
		if (fundsTypeCdVal == "0") {
			var param = {
					funds_dt : $M.getValue("funds_dt"),
					funds_type_cd : fundsTypeCdVal,
					money_unit_cd : "KRW"
				};
				
			$M.goNextPageAjax(this_page + "/search/amt", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						console.log(result);
						console.log("beforeMoney ?? ", result.map.before_money);
						$M.setValue("before_money", result.map.before_money);
						goSearchAfterAmt(fundsTypeCdVal);
					};
				}		
			);	
		} else {
			var param = {
					funds_dt : $M.getValue("funds_dt"),
					funds_type_cd : fundsTypeCdVal,
					deposit_code : $M.getValue("deposit_code")
				};
				
			$M.goNextPageAjax(this_page + "/search/amt", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						console.log(result);
						$M.setValue("before_money", result.map.before_money);
						goSearchAfterAmt(fundsTypeCdVal);
					};
				}		
			);	
		}		
	}
	
	// 잔액 세팅
	function goSearchAfterAmt(val) {
		var moneyUnitCd = "KRW";
		if (val != "0") {
			moneyUnitCd = "";
		}
		
		var param = {
				funds_dt : $M.getValue("funds_dt"),
				funds_type_cd : $M.getValue("funds_type_cd"),
				deposit_code : $M.getValue("deposit_code"),
				money_unit_cd : moneyUnitCd
			};
			
		$M.goNextPageAjax("/acnt/acnt0202p01/search/amt", $M.toGetParam(param), {method : 'get'},
			function(result) {
				if(result.success) {
					console.log("result : ", result);
					$M.setValue("after_money", result.map.after_money);
					
					calcAmt = result.map.after_money;
				};
			}		
		);	
	}
	
	// 잔액 구하기
	function fnSetAfterMoney() {
		if ($M.getValue("funds_type_cd") == "") {
			alert("처리구분을 먼저 선택해 주세요.");
			return;
		} else {
			if ($M.getValue("funds_type_cd") != "0") {
				if ($M.getValue("deposit_code") == "") {
					alert("관리번호를 먼저 선택해 주세요.");
					$M.clearValue({field:["in_amt", "out_amt"]});
					return;
				}
			}
		}
		
		var beforeMoney = Number($M.getValue("before_money")); // 이월액
		var inAmt = Number($M.getValue("in_amt"));  // 입금액
		var outAmt = Number($M.getValue("out_amt"));  // 출금액
		
// 		var afterMoney = (beforeMoney + inAmt) - outAmt;
		var afterMoney = calcAmt + inAmt - outAmt;
		console.log("afterMoney : ", afterMoney);
		
		$M.setValue("after_money", afterMoney);
	}
	
	</script>
</head>
<body class="bg-white">
<!-- 팝업 -->
<form id="main_form" name="main_form">
<input type="hidden" name="funds_daily_no">
<input type="hidden" name="money_unit_cd">
<div class="popup-wrap width-100per">
	<!-- 타이틀영역 -->
	<div class="main-title">
		<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
	</div>
	<!-- /타이틀영역 -->
	<div class="content-wrap">
		<!-- 원화 + 외화예금 -->
		<div>
			<div class="title-wrap">
				<h4>원화 + 외화예금</h4>
			</div>
			<table class="table-border mt5">
				<colgroup>
					<col width="100px">
					<col width="">
				</colgroup>
				<tbody>

				<tr>
					<th class="text-right essential-item">처리일자</th>
					<td>
						<div class="input-group">
							<input type="text" class="form-control border-right-0 calDate" id="funds_dt" name="funds_dt" dateFormat="yyyy-MM-dd" value="${inputParam.s_end_dt}" alt="자금일자" onchange="javascript:goSearchBeforeAmt2();" required="required">
						</div>
					</td>
				</tr>
				<tr>
					<th class="text-right essential-item">처리구분</th>
					<td>
						<select class="form-control width120px essential-bg" id="funds_type_cd" name="funds_type_cd" required="required" alt="처리구분" onchange="javascript:goSearchBeforeAmt(this.value);">
							<option value="">- 선택 -</option>
							<c:forEach var="item" items="${codeMap['FUNDS_TYPE']}">
								<option value="${item.code_value}">${item.code_name}</option>
							</c:forEach>
						</select>
					</td>
				</tr>
				<tr>
					<th class="text-right">관리번호</th>
					<td>
						<div class="form-row inline-pd">
							<div class="col-4">
								<div class="input-group">
									<input type="text" class="form-control border-right-0" id="deposit_code" name="deposit_code" readonly alt="관리번호">
									<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnGetDepositCode();"><i class="material-iconssearch"></i></button>
								</div>
							</div>
							<div class="col-7">
								<input type="text" class="form-control" id="deposit_name" name="deposit_name" readonly>
							</div>
						</div>
					</td>
				</tr>
				<tr>
					<th class="text-right">이월</th>
					<td>
						<div class="form-row inline-pd widthfix">
							<div class="col width160px">
								<input type="text" class="form-control text-right" id="before_money" name="before_money" format="decimal" alt="이월액" readonly>
							</div>
							<div class="col width22px">원</div>
						</div>
					</td>
				</tr>
				<tr>
					<th class="text-right essential-item">입금</th>
					<td>
						<div class="form-row inline-pd widthfix">
							<div class="col width160px">
								<input type="text" class="form-control text-right essential-bg" id="in_amt" name="in_amt" format="decimal" alt="입금액" onchange="javascript:fnSetAfterMoney();">
							</div>
							<div class="col width22px">원</div>
						</div>
					</td>
				</tr>
				<tr>
					<th class="text-right essential-item">출금</th>
					<td>
						<div class="form-row inline-pd widthfix">
							<div class="col width160px">
								<input type="text" class="form-control text-right essential-bg" id="out_amt" name="out_amt" format="decimal" alt="출금액" onchange="javascript:fnSetAfterMoney();">
							</div>
							<div class="col width22px">원</div>
						</div>
					</td>
				</tr>
				<tr>
					<th class="text-right">잔액</th>
					<td>
						<div class="form-row inline-pd widthfix">
							<div class="col width160px">
								<input type="text" class="form-control text-right" id="after_money" name="after_money" format="decimal" alt="잔액" readonly>
							</div>
							<div class="col width22px">원</div>
						</div>
					</td>
				</tr>
				<tr>
					<th class="text-right">비고</th>
					<td>
						<textarea class="form-control" style="height: 100px;" id="remark" name="remark"></textarea>
					</td>
				</tr>

				</tbody>
			</table>

		</div>
		<!-- /원화 + 외화예금 -->
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