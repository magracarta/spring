<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp" /><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt"%><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%><%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 계약관리 > 계약/출하 > null > 계약품의서 간편등록
-- 작성자 : 김태훈
-- 최초 작성일 : 2021-04-09 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
<style type="text/css">
	.step-con {
		width: 100%;
	}
	#btnClear {
		pointer-events: auto !important;
	    opacity: 1 !important;
	    border: none !important;
	    background: transparent !important;
	}
	.enableMove {
		background-color: rgba(16, 113, 189, 75%) !important;
		color: white !important;
	}
</style>
<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp" />
<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>
	
	var stepMovableArr = [1, 0, 0, 0, 0]; // 페이지 이동가능 여부
	
	var isExcust = false; // 기존고객여부
	var isHpCheck = false; // 휴대폰 중복체크 여부
	
	var optList = [];
	var auiIds = ["auiGridOption", "auiGridAttach", "auiGridPart", "auiGridPartFree", "auiGridOppCost"];
	var auiGridOption; // 선택사항
	var auiGridAttach; // 어테치먼트
	var auiGridPart; // 유상부품
	var auiGridPartFree; // 무상부품
	var auiGridOppCost; // 임의비용
	var auiGridBasic; // 기본제공품(hidden)
	
	$(document).ready(function() {
		$("#sar_yn_check").on({
			click: function(e){
				if($("#sar_yn_check").is(":checked") == true){
					$(".sarFileYn").show();
				}else{
					$(".sarFileYn").hide();
				}
			},
		});
		$("#cap_yn_check").on({
			click: function(e){
				if($("#cap_yn_check").is(":checked") == true){
					$(".capFileYn").show();
				}else{
					$(".capFileYn").hide();
				}
			},
		});

		$("#assist_yn_check").on({
			click: function(e){
				if($("#assist_yn_check").is(":checked") == true){
					fnShowYn("assistFileYn");
				}else{
					fnHideYn("assistFileYn");
				}
			},
		});
	});
	
	////////////////////////////////// 스탭1 고객  등록(sale0101p1501) ////////////////////////////////////
	////////////////////////////////// 스탭2 지급품확인(sale0101p1502) ////////////////////////////////////
	////////////////////////////////// 스탭3 유무상부품(sale0101p1503) ////////////////////////////////////
	////////////////////////////////// 스탭4 결제  조건(sale0101p1504) ////////////////////////////////////
	////////////////////////////////// 스탭5 기     타(sale0101p1505) ////////////////////////////////////
	
	////////////////////////////////// 스탭 공통 /////////////////////////////////////////
	
	// 탭 이동
	function fnMoveStep(stepId) {
		if (stepMovableArr[stepId-1] == 1) {
			$('ul.step li a').removeClass('active');
			$("#wrap"+stepId).addClass('active');
			$(".step-con").addClass('dpn');
			$("#step"+stepId).removeClass('dpn');
		} else {
			alert("최초 이동 시, 다음 버튼으로 이동해주세요.");
			return false;
		}
		for (var i =0; i < auiIds.length; ++i) {
			AUIGrid.resize("#"+auiIds[i]);
		}

		// 이동가능한 step은 약같 옅은 남색으로 처리 - 김경빈
		for (var i=1; i<=stepMovableArr.length; i++) {
			if (stepMovableArr[i-1] === 1) {
				if (!$("#wrap" + i).hasClass("active")) {
					$("#wrap" + i).addClass('enableMove');
				} else {
					$("#wrap" + i).removeClass('enableMove');
				}
			}
		}
	}
	
	// 스탭1 고객등록 유효성 검사
	function fnCheckStep1() {
		// 신규등록일경우
		if ($M.getValue("cust_no") == "") {
			// [14466] 주소 필수값 해제
			if($M.validation(null, {field:['cust_name', 'hp_no', 'area_si']}) == false) {
				return false;
			}
			// if($M.validation(null, {field:['cust_name', 'hp_no', 'post_no', 'area_si']}) == false) {
			// 	return false;
			// }
			console.log("핸드폰 중복검사");
			if (!isHpCheck) {
				alert("휴대폰 중복확인을 해주세요.");
				return false;
			}
		}
		if($M.validation(null, {field:['machine_name', 'receive_plan_dt', 'mch_type_cad']}) == false) {
			return false;
		}
	}
	
	// 스탭2 지급품확인 유효성 검사
	function fnCheckStep2() {
		return true;
	}
	
	// 스탭3 유무상부품 유효성 검사
	function fnCheckStep3() {
		if (!fnCheckGridEmpty1()) {
			return false;
		}
		if (!fnCheckGridEmpty2()) {
			return false;
		}
		if (!fnCheckGridEmpty3()) {
			return false;
		}
		var paid = AUIGrid.getGridData(auiGridPart);
		if (paid.length != 0 && $M.getValue("cost_part_breg_no") == "" && $M.getValue("cost_taxbill_yn_check") == "") {
			alert("유상부품 사업자번호를 입력하세요.");
			$("#cost_part_breg_no").focus();
			return false;
		}
		if ($M.getValue("cost_taxbill_yn_check") != "" && $M.getValue("cost_part_breg_no") != "") {
			if (confirm("계산서 미발행 시, 유상부품사업자를 삭제해야합니다.\n계속하시겠습니까?") == true) {
				$M.setValue("cost_part_breg_seq", "");
				$M.setValue("cost_part_breg_no", "");
				$M.setValue("cost_part_breg_rep_name", "");
				$M.setValue("cost_part_breg_name", "");
			} else {
				alert("계산서미발행 체크를 해제하세요.");
				return false;
			}
		}
	}
	
	// 스탭4 결제조건 유효성 검사
	function fnCheckStep4() {
		// 2023-03-17 황빛찬 - 캐피탈 필수선택 해제 (직원앱,ERP 둘다 적용)
		// 결재조건 중 금융을 입력했을 경우 캐피탈 필수 
		// if ($M.toNum($M.getValue("plan_amt_3")) > 0 && $M.getValue("finance_cmp_cd") == "") {
		// 	alert("캐피탈을 선택해주세요.");
		// 	$("#finance_cmp_cd").focus();
		// 	return false;
		// }

		// 결제구분(0:현금, 1:카드, 2:어음, 3:금융, 4:중고, 5:보조, 6:부가세)
		var payArr = ["현금", "카드", "어음", "금융", "중고", "보조", "부가세"]
		// 입금예정일 확인
		for (var i = 0; i < 7; ++i) {
			if($M.toNum($M.getValue("plan_amt_"+i)) > 0 && $M.getValue("plan_dt_"+i) == "") {
				alert(payArr[i]+" 입금예정일이 지정되지 않았습니다.\n"+payArr[i]+" 금액만 입력할 수 없습니다.");
				$("#plan_dt_"+i).focus();
				return false;
			}
			if($M.toNum($M.getValue("plan_amt_"+i)) < 1 && $M.getValue("plan_dt_"+i) != "") {
				alert(payArr[i]+" 금액이 입력되지 않았습니다.\n"+payArr[i]+" 입금예정일만 입력할 수 없습니다.");
				$("#plan_amt_"+i).focus();
				return false;
			}
		}
		if ($M.toNum($M.getValue("balance")) != 0) {
			alert("계약금액과 결재요청하려는 금액이 다릅니다.");
			$("#balance").focus();
			return false;
		} 
	}
	
	// 완료 다음
	function fnCompleteStep(stepId) {
		switch (stepId) {
		// 고객등록
		case 1 :
			if (fnCheckStep1() == false) {
				return false;
			}
			if ($M.getValue("cust_no") == "" && !confirm("신규 고객으로 품의서가 작성됩니다.\n기존 등록된 고객은 취소 후 기존고객을 조회하시기 바랍니다.")) {
				return false;
			}
			$(".cust_name_view").html($M.getValue("cust_name"));
			$(".hp_no_view").html($M.phoneFormat($M.getValue("hp_no")));
			$(".machine_name_view").html($M.getValue("machine_name"));
			$(".receive_plan_dt_view").html($M.dateFormat($M.getValue("receive_plan_dt"), 'yyyy-MM-dd'));

			var param = {
				"trigger" : "register",
			}

			$M.goNextPageAjax("/sale/assignvirtual", $M.toGetParam(param), {method : 'GET'},
					function(result) {
						if(result.success) {
							// 가상계좌 번호 셋팅
							$M.setValue("virtual_account_no", result.virtual_account_no);
							console.log("가상계좌");
							console.log($M.getValue("virtual_account_no"));
						}
					}
			);
			
			break;
		// 지급품 확인
		case 2 : 
			if (fnCheckStep2() == false) {
				return false;
			}
			var optCode = $M.getValue("opt_code");
			var optName = "";
			if (optCode != "") {
				for (var i = 0; i < optList.length; ++i) {
					if (optList[i].opt_code == optCode) {
						optName = optList[i].opt_name;
						break;
					}
				}
				if (confirm("선택하신 옵션품목이 "+optName+"이(가) 맞다면 확인\n변경하시려면 취소를 선택하십시오.") == false) {
					return false;
				}
			}
			break;
		case 3 : 
			if (fnCheckStep3() == false) {
				return false;
			}
			// 유상 그리드 업데이트
			AUIGrid.removeSoftRows(auiGridPart);
			AUIGrid.resetUpdatedItems(auiGridPart);

			// 무상 그리드 업데이트
			AUIGrid.removeSoftRows(auiGridPartFree);
			AUIGrid.resetUpdatedItems(auiGridPartFree);

			// 임의비용 그리드 업데이트
			AUIGrid.removeSoftRows(auiGridOppCost);
			AUIGrid.resetUpdatedItems(auiGridOppCost);
			break;
		case 4 : 
			if (fnCheckStep4() == false) {
				return false;
			}
			break;
		case 5 : 
			break;
		}
		
		stepMovableArr[stepId] = 1;
		fnMoveStep(stepId+1);
	}
	
	// 닫기
	function fnClose() {
		window.close();
	}
	
</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" name="write_price" alt="작성자 전결가"> <!-- 작성자 전결가 -->
<input type="hidden" name="review_price"> <!-- 심사자 전결가 -->
<input type="hidden" name="agree_price"> <!-- 합의자 전결가 -->
<input type="hidden" name="max_dc_price"> <!-- 할인한도 -->
<input type="hidden" name="fee_price"> <!-- 수수료 -->
<input type="hidden" name="cust_no"> <!-- 고객번호 -->
<input type="hidden" name="tel_no">
<input type="hidden" name="fax_no">
<input type="hidden" name="email">

<!-- YN -->
<input type="hidden" name="cap_yn">
<input type="hidden" name="center_di_yn">
<input type="hidden" name="sar_yn">
<input type="hidden" name="assist_yn">
<input type="hidden" name="reg_proxy_yn">

<input type="hidden" name="cost_taxbill_yn">

<input type="hidden" name="total_amt">

<input type="hidden" name="save_mode" value="appr"> <!-- 저장모드 : 결재요청 -->

<input type="hidden" name="machine_plant_seq">

<!-- 지역 -->
<input type="hidden" name="sale_area_code">
<input type="hidden" name="center_org_code">
<input type="hidden" name="sale_area_code">
<input type="hidden" name="service_mem_no">

<div id="auiGridBasic" style="display: none"></div>
	<div class="popup-wrap width-100per">
		<!-- 타이틀영역 -->
		<div class="main-title">
			<h2>품의서 간편등록</h2>
		</div>
		<!-- /타이틀영역 -->
		<div class="content-wrap">
			<div class="step-wrap mt5">
				<ul class="step">
					<li>
						<a href="#" id="wrap1" data-tab="step1" onclick="javascript:fnMoveStep(1)" class="active"> <span class="step-num">step01</span> <span class="step-title">고객등록</span></a>
					</li>
					<li>
						<a href="#" id="wrap2" data-tab="step2" onclick="javascript:fnMoveStep(2)"> <span class="step-num">step02</span> <span class="step-title">지급품확인</span></a>
					</li>
					<li>
						<a href="#" id="wrap3" data-tab="step3" onclick="javascript:fnMoveStep(3)"> <span class="step-num">step03</span> <span class="step-title">유무상부품</span></a>
					</li>
					<li>
						<a href="#" id="wrap4" data-tab="step4" onclick="javascript:fnMoveStep(4)"> <span class="step-num">step04</span> <span class="step-title">결제조건</span></a>
					</li>
					<li>
						<a href="#" id="wrap5" data-tab="step5" onclick="javascript:fnMoveStep(5)"> <span class="step-num">step05</span> <span class="step-title">기타</span></a>
					</li>
				</ul>
				<div class="step-con" id="step1">
					<jsp:include page="/WEB-INF/jsp/sale/sale0101p1501.jsp"/>
				</div>
				<div class="step-con dpn" id="step2">
					<jsp:include page="/WEB-INF/jsp/sale/sale0101p1502.jsp"/>
				</div>
				<div class="step-con dpn" id="step3">
					<jsp:include page="/WEB-INF/jsp/sale/sale0101p1503.jsp"/>
				</div>
				<div class="step-con dpn" id="step4">
					<jsp:include page="/WEB-INF/jsp/sale/sale0101p1504.jsp"/>
				</div>
				<div class="step-con dpn" id="step5">
					<jsp:include page="/WEB-INF/jsp/sale/sale0101p1505.jsp"/>
				</div>
			</div>
		</div>
	</div>
</form>
</body>
</html>