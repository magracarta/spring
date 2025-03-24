<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 코드관리 > 부품마스터등록/수정 > 부품마스터등록 > null
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2020-01-10 17:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	var map = ${map}; // 산출구분 코드를 Key값으로 묶은 List
	var exchangeList = ${exchangeList}; // 통화별 환율
	var priceMakerList = ${priceMakerList}; // 통화별 환율

	// 산출구분의 2번째자리, 3번째자리, 4번째자리 , 화폐단위의 value값
	var dealerCdName = 0;  // 부품판가 딜러할인율 (2번째자리)
	var mngCdName = 0;     // 부품판가 일반관리비 (3번째자리)
	var marginCdName = 0;  // 부품판가 마진율 (4번째자리)
	var fixedErPrice = 0;  // 통화별 결정환율

	var before_deal_cust_name = ""; // 매입처명 변경 감지
	var before_deal_cust_name2 = ""; // 매입처명 변경 감지
	$(document).ready(function(){
		fnToggle();
		$M.setValue("list_price2", 0);
	});

	// 저장
	function goSave() {
		var frm = document.main_form;

		// validation check
		if($M.validation(document.main_form, {field:["part_no", "part_name", "maker_cd", "part_production_cd", "part_mng_cd", "part_real_check_cd", "list_price", "in_stock_price", "part_country_cd", "deal_cust_name"]}) == false) {
			return;
		};

		// 콤보그리드 벨리데이션 따로 추가 - 포커스와 alt 동작이 안되어서 따로 추가함.
		if ($M.getValue("part_output_price_cd") == "") {
			alert("산출구분은 필수입력입니다.");
			$('#part_output_price_cd').next().find('input').focus()
			return;
		}

		if ($M.getValue("part_group_cd") == "") {

			alert("분류구분은 필수입력입니다.");
			$('#part_group_cd').next().find('input').focus()
			return;
		}

		if (before_deal_cust_name != $M.getValue("deal_cust_name")) {
			console.log("매입처1를 선택했지만, 이후 수기로 수정했음 -> deal_cust_no 삭제");
			$M.clearValue({field:["deal_cust_no"]});
		}

		if (before_deal_cust_name2 != $M.getValue("deal_cust_name2")) {
			console.log("매입처1를 선택했지만, 이후 수기로 수정했음 -> deal_cust_no 삭제");
			$M.clearValue({field:["deal_cust_no2"]});
		}
		if($M.getValue("deal_cust_name2") != "" && $M.getValue("strategy_price") == 0){
			alert("매입처2 등록 시 전략가는 필수입력입니다.");
			$('#strategy_price').focus()
			return;
		}

		$M.goNextPageAjaxSave(this_page + "/save", $M.toValueForm(frm), {method : 'POST'},
			function(result) {
				if(result.success) {
					$M.goNextPage("/part/part0701");
				}
			}
		);
	}

	//매입처1 선택
	function setSearchClientInfo(row) {
		$M.setValue("deal_cust_no",row.cust_no);
		$M.setValue("deal_cust_name",row.cust_name);
		$M.setValue("com_buy_group_cd",row.com_buy_group_cd);

		// 매입처를 선택했을 당시의 매입처명(저장할때 다르면 deal_cust_no 삭제);
		before_deal_cust_name = row.cust_name;
	}

	//매입처2 선택
	function setSearchClientInfo2(row) {
		$M.setValue("deal_cust_no2",row.cust_no);
		$M.setValue("deal_cust_name2",row.cust_name);

		// 매입처를 선택했을 당시의 매입처명(저장할때 다르면 deal_cust_no2 삭제);
		before_deal_cust_name2 = row.cust_name;
	}

	// 목록
	function fnList() {
		history.back();
	}

	// 매입처조회
	function fnSearchClientComm() {
		var param = {
				s_com_buy_group_cd : "A",
				s_part_search_yn : "Y"
		};
		openSearchClientPanel('setSearchClientInfo', 'comm', $M.toGetParam(param));
	}

	// 매입처2조회
	function fnSearchClientComm2() {
		var param = {
				s_com_buy_group_cd : "A",
				s_part_search_yn : "Y"
		};
		openSearchClientPanel('setSearchClientInfo2', 'comm', $M.toGetParam(param));
	}

	// 관리구분 - 매출정지 : 매출정지사유 활성화
	function fnMngstopYn(){
		if($M.getValue("part_mng_cd") == "9"){
			$("#sale_stop_reason").prop("disabled",false);
			$("#sale_stop_reason").focus();  // 매출정지사유 활성화
			$M.setValue("sale_stop_reason","장기재고/충당재고 : 모든 재고 판매로 매출정지");
		}else{
			$M.setValue("sale_stop_reason","");
			$("#sale_stop_reason").prop("disabled",true);
		}
		// 23.02.27 정윤수 관리구분 - 정상부품 : 수요예측 Y, 정상부품X : 수요예측 N, disabled
		if($M.getValue("part_mng_cd") == "1") {
			$("#dem_fore_yn1").prop("checked",true);
			$(".dem_fore").prop("disabled",false);
		}else{
			$("#dem_fore_yn2").prop("checked",true);
			$(".dem_fore").prop("disabled",true);
		}
	}

	// 산출구분 콤보그리드 onChange
	function fnOutputPriceCdChange() {
		// 산출구분이 변경될때마다 계산식에 필요한 정보를 가져오기 위함.
		// 딜러 할인율, 일반 관리비, 마진율, 결정환율 구하기
		var outputPriceCode = $M.getValue("part_output_price_cd");  // 산출구분 코드 (B014, N724...)

		// 선택한 산출구분 코드의 dealer_cd_name, mng_cd_name, margin_cd_name 데이터를 가져온다.
		var keys = Object.keys(map);
		for (var item in keys) {
			if (keys[item].includes(outputPriceCode)) {
				dealerCdName = map[keys[item]][0].dealer_cd_name;   // 딜러할인율
				mngCdName = map[keys[item]][0].mng_cd_name;         // 일반관리비
				marginCdName = map[keys[item]][0].margin_cd_name;   // 마진율
			}
		}

		fnOutPutPriceExchange();

		// 메이커, 생산구분, 금액 초기화
// 		fnClearValue("OUTPUT");
	}

	function fnOutPutPriceExchange() {
		var outputPriceCode = $M.getValue("part_output_price_cd");
		console.log("산출구분partOutputPrice : ", outputPriceCode);
		var exchangeStr = $.trim(outputPriceCode).substring(0, 1);
		console.log("산출구분exchangeStr : ", exchangeStr);

		for(var item in priceMakerList) {
			if(priceMakerList[item].code.includes(exchangeStr)) {
				$M.setValue("money_unit_cd", priceMakerList[item].code_v1);
			}
		}

		var moneyUnitCd = $M.getValue("money_unit_cd");
		// 생산구분이 국산일때 결정환율 1로 세팅
	    if($M.getValue("part_production_cd") == "1") {
			fixedErPrice = 1;
		} else if(moneyUnitCd != "") {
			for (var item in exchangeList) {
				if (exchangeList[item].money_unit_cd.includes(moneyUnitCd)) {
					fixedErPrice = exchangeList[item].fixed_er_price;   // 결정환율 set
				}
			}
		} else {
			fixedErPrice = 1;
		}

		fnPriceCalc('N');
	}

	// 메이커, 생산구분, 금액 초기화
	function fnClearValue(gubun) {
		if(gubun == "OUTPUT") {
			$M.clearValue({field:["maker_cd", "money_unit_cd", "list_price", "net_price"
				, "special_price" , "in_stock_price", "vip_price", "strategy_price", "cust_price", "mng_agency_price"]});
		}
// 		$M.clearValue({field:["part_production_cd"]});
	}

	// maker onChange 단가내역상세조회 메이커에 따라 화폐단위 변경
	function fnPriceChange() {
		// 메이커, 생산구분, 금액 초기화
// 		fnClearValue("MAKER");

// 		var makerNm = $("#maker_cd option:selected").text();

// 		var str1 = makerNm.lastIndexOf(" ");  // 오른쪽에서 왼쪽으로 검색하여 값을 가져옴니다.
// 		var str2 = $.trim(makerNm.substring(str1, makerNm.length)); // 결정환율을 구하기위한 값
// 		$M.setValue("money_unit_cd", str2);

// 		console.log(str2);
// 		console.log("화폐 단위 : ", $M.getValue("money_unit_cd"));

		var partOutputPrice = $M.getValue("part_output_price_cd");
		console.log("메이커 또는 산출구분partOutputPrice : ", partOutputPrice);
		var exchangeStr = $.trim(partOutputPrice).substring(0, 1);
		console.log("메이커 또는 산출구분exchangeStr : ", exchangeStr);

		for(var item in priceMakerList) {
			if(priceMakerList[item].code.includes(exchangeStr)) {
				$M.setValue("money_unit_cd", priceMakerList[item].code_v1);
			}
		}

		var makerExchangeRate = $M.getValue("money_unit_cd");
		// 생산구분이 국산일때 결정환율 1로 세팅
		if($M.getValue("part_production_cd") == "1") {
			fixedErPrice = 1;
		} if(makerExchangeRate != "") {
			for (var item in exchangeList) {
				if (exchangeList[item].money_unit_cd.includes(makerExchangeRate)) {
					fixedErPrice = exchangeList[item].fixed_er_price;   // 결정환율 set
				}
			}
		} else {
// 			fixedErPrice = 0;
			// 21.06.01 이원영 파트장님 요청으로 메이커 기타일 경우 결정환율 1로 세팅.
			fixedErPrice = 1;

		}
		fnPartInfo();
	}

	// 생산구분 클릭 시
	function fnChangeProduction() {
		// 생산구분이 국산 (code값 1) 일때 는 무조건 KRW로 세팅해줌.
		if ($M.getValue("part_production_cd") == '1') {
			$M.setValue("money_unit_cd", 'KRW');

			var makerExchangeRate = $M.getValue("money_unit_cd");
			// 생산구분이 국산일때 결정환율 1로 세팅
		    if($M.getValue("part_production_cd") == "1") {
				fixedErPrice = 1;
			} else if(makerExchangeRate != "") {
				for (var item in exchangeList) {
					if (exchangeList[item].money_unit_cd.includes(makerExchangeRate)) {
						fixedErPrice = exchangeList[item].fixed_er_price;   // 결정환율 set
					}
				}
			} else {
				fixedErPrice = 1;

			}
		} else {
// 			var makerNm = $("#maker_cd option:selected").text();

// 			var str1 = makerNm.lastIndexOf(" ");  // 오른쪽에서 왼쪽으로 검색하여 값을 가져옴니다.
// 			var str2 = $.trim(makerNm.substring(str1, makerNm.length)); // 결정환율을 구하기위한 값
// 			$M.setValue("money_unit_cd", str2);
			var partOutputPrice = $M.getValue("part_output_price_cd");
			console.log("생산구분partOutputPrice : ", partOutputPrice);
			var exchangeStr = $.trim(partOutputPrice).substring(0, 1);
			console.log("생산구분exchangeStr : ", exchangeStr);

			for(var item in priceMakerList) {
				if(priceMakerList[item].code.includes(exchangeStr)) {
					$M.setValue("money_unit_cd", priceMakerList[item].code_v1);
				}
			}
			var makerExchangeRate = $M.getValue("money_unit_cd");
			// 생산구분이 국산일때 결정환율 1로 세팅
		    if($M.getValue("part_production_cd") == "1") {
				fixedErPrice = 1;
			} else if(makerExchangeRate != "") {
				for (var item in exchangeList) {
					if (exchangeList[item].money_unit_cd.includes(makerExchangeRate)) {
						fixedErPrice = exchangeList[item].fixed_er_price;   // 결정환율 set
					}
				}
			} else {
				fixedErPrice = 1;

			}
		}

		fnPartInfo();
	}

	// 부품기준산출코드 조회
	function fnPartInfo() {

		if($M.getValue("maker_cd") != "" && ($M.getValue("part_production_cd") == "0" || $M.getValue("part_production_cd") == "1")) {
			var param = {
					"part_production_cd" : $M.getValue("part_production_cd"),
					"maker_cd" : $M.getValue("maker_cd")
			}

			$M.goNextPageAjax(this_page + "/getPartInfo", $M.toGetParam(param), {method : 'GET'},
				function(result) {
					if(result.success) {
						$M.clearValue({field:["part_output_price_cd", "part_country_cd", "part_mng_cd", "part_real_check_cd"]});

						$M.setValue(result);

						dealerCdName = result.part_price_dealer_discount;
						mngCdName = result.part_price_mng_amount;
						marginCdName = result.part_price_margin;

						if($M.getValue("part_production_cd") == "1") {
							fixedErPrice = 1;
							$M.setValue("maker_exchange_rate", 'KRW');

							if($M.getValue("part_output_price_cd") != "") {
								fnPriceCalc('N');
							}
						} else {
							if(result.fixed_er_price != undefined) {
								fixedErPrice = result.fixed_er_price;
							}

							if($M.getValue("part_output_price_cd") != "") {
								fnPriceCalc('N');
							}
						}

						if (result.fixed_er_price != undefined) {
							fixedErPrice = result.fixed_er_price;
						}

						if($M.getValue("part_output_price_cd") != "") {
							fnPriceCalc('N');
						}
						if($M.getValue("part_mng_cd") != "9") {
							$M.setValue("sale_stop_reason","");
							$("#sale_stop_reason").prop("disabled",true);
						}
						// 23.02.27 정윤수 관리구분 - 정상부품 : 수요예측 Y, 정상부품X : 수요예측 N, disabled
						if($M.getValue("part_mng_cd") == "1") {
							$("#dem_fore_yn1").prop("checked",true);
							$(".dem_fore").prop("disabled",false);
						}else{
							$("#dem_fore_yn2").prop("checked",true);
							$(".dem_fore").prop("disabled",true);
						}
					}
				}
			);
		}
	}


	// 단가 계산 로직
	function fnPriceCalc(defaultYn) {
		if($M.getValue("maker_cd") != "" && $M.getValue("part_output_price_cd") != "" && ($M.getValue("list_price") != "" || $M.getValue("special_price") != "" || $M.getValue("strategy_price") != "")) {
			var param = {
					"list_price" : $M.getValue("list_price"),
					"special_price" : $M.getValue("special_price"),
					"strategy_price" : $M.getValue("strategy_price"),
					"dealer_discount" : dealerCdName,
					"mng_amount" : mngCdName,
					"margin" : marginCdName,
					"fixed_er_price" : fixedErPrice,
					// 23.02.27 정윤수 매입처2 항목 추가
					"list_price2" : $M.getValue("list_price2") == "" ? 0 : $M.getValue("list_price2"),
					"special_price2" : $M.getValue("special_price2"),
					// 추가
					"part_output_price_cd" : $M.getValue("part_output_price_cd"),
					"money_unit_cd" : $M.getValue("maker_exchange_rate"),
					"part_mng_cd" : $M.getValue("part_mng_cd"),
					"part_margin_cd" : $M.getValue("part_margin_cd"),
			}

			console.log("param : ", param);

			$M.goNextPageAjax(this_page + "/calcAmt", $M.toGetParam(param), {method : 'GET'},
				function(result) {
					if(result.success) {
						$M.setValue(result);
						fnSetPriceAuto(defaultYn);
					}
				}
			);
		}
	}

	// 부품번호 중복체크
	function fnPartNoDuplCheck() {
		$M.setValue("part_no", $M.getValue("part_no").trim()); // 23.06.27 부품마스터 등록 시 공백이 들어간 경우가 발생하여 추가

		if ($M.getValue("part_no") != "") {
			$M.goNextPageAjax(this_page + "/duplicate/check/" + $M.getValue("part_no"), "", {method : 'GET'},
				function(result) {
		    		if(result.success) {
// 		    			$M.setValue("part_no", $M.getValue("part_no").toUpperCase());
		    		} else {
		    			return;
		    		}
				}
			);
		}
	}

	function show() {
		document.getElementById("machine_operation").style.display="block";
	}
	function hide() {
		document.getElementById("machine_operation").style.display="none";
	}

	// 최종 판매가 계산
	function goCalcFinalPrice(defaultYn) {
		if($M.getValue("maker_cd") != "" && $M.getValue("part_output_price_cd") != "" && $M.getValue("vip_price") != "") {
			var param = {
					"vip_price" : $M.getValue("vip_price"),
					"strategy_price" : $M.getValue("strategy_price"),
					"dealer_discount" : dealerCdName
			}

			$M.goNextPageAjax("/part/part0701p01/calcFinalAmt", $M.toGetParam(param), {method : 'GET'},
				function(result) {
					if(result.success) {
						$M.setValue(result);
						fnSetPriceAuto(defaultYn);
					}
				}
			);
		}
	}

	// 일반판매가 입력 시 최종 일반판매가에 적용
	function fnChangeFinalPrice(defaultYn) {
		if($M.getValue("vip_price") != "") {
			var param = {
					"vip_price" : $M.getValue("vip_sale_price"),
					"cust_price" : $M.getValue("cust_price"),
					"strategy_price" : $M.getValue("strategy_price")
			}
			$M.goNextPageAjax("/part/part0701p01/calcSalePrice", $M.toGetParam(param), {method : 'GET'},
				function(result) {
					if(result.success) {
						$M.setValue(result);
						fnSetPriceAuto(defaultYn);
					}
				}
			);
		}
	}

	// 가격 세팅
	function fnSetPriceAuto(defaultYn) {
		if(defaultYn == "Y") {
			// 전략가가 있을 때
			if($M.getValue("strategy_price") != "" && $M.getValue("strategy_price") != 0) {
				$M.setValue("vip_sale_price", $M.getValue("strategy_price"));
				$M.setValue("sale_price", $M.getValue("cust_price"));
			// 전략가가 없을 때
			} else {
				$M.setValue("vip_sale_price", $M.getValue("vip_price"));
				$M.setValue("sale_price", $M.getValue("cust_price"));
			}
		}

	}

	// 매입처 탭 이동
	function fnToggle() {
		$('ul.tabs-c li a').click(function () {
			var tab_id = $(this).attr('data-tab');

			$('ul.tabs-c li a').removeClass('active');
			$('.tabs-inner').removeClass('active');

			$(this).addClass('active');
			$("#" + tab_id).addClass('active');
		});
	}
	// 매입처 초기화
	function fnClientClear(client) {
		if(client == 1){
			$M.setValue("deal_cust_name", "");
		}else{
			$M.setValue("deal_cust_name2", "");
		}
	}
	</script>
</head>
<body>
<form id="main_form" name="main_form">
	<div class="layout-box">
	<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
	<!-- 상세페이지 타이틀 -->
				<div class="main-title detail">
					<div class="detail-left">
						<button type="button" class="btn btn-outline-light" onclick="javascript:fnList();"><i class="material-iconskeyboard_backspace text-default"></i></button>
						<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
					</div>
				</div>
	<!-- /상세페이지 타이틀 -->
				<div class="contents">
	<!-- 상단 폼테이블 -->
					<div class="title-wrap">
						<h4 class="primary">부품마스터 상세</h4>
					</div>
					<table class="table-border table-fixed mt5">
						<colgroup>
							<col width="120px">
							<col width="">
							<col width="25px">
							<col width="95px">
							<col width="52px">
							<col width="">
							<col width="25px">
							<col width="95px">
							<col width="52px">
							<col width="">
							<col width="25px">
							<col width="95px">
							<col width="">
						</colgroup>
						<tbody>
						<tr>
							<th class="text-right essential-item">부품번호</th>
							<td>
								<input type="text" class="form-control essential-bg  width120px" id="part_no" name="part_no" alt="부품번호" required="required" onblur="javascript:fnPartNoDuplCheck();"/>
							</td>
							<th colspan="2" class="text-right essential-item">부품명</th>
							<td colspan="2">
								<input type="text" class="form-control essential-bg  width200px" id="part_name" name="part_name" alt="부품명" required="required" />
							</td>
							<th colspan="2" class="text-right">안전재고</th>
							<td colspan="2">
								<input type="text" class="form-control text-right  width120px" id="part_safe_stock" name="part_safe_stock"    datatype="int" />
							</td>
							<th colspan="2" class="text-right">안전재고2</th>
							<td>
								<input type="text" class="form-control text-right  width120px" id="part_safe_stock2" name="part_safe_stock2"  datatype="int"/>
							</td>
						</tr>
						<tr>
							<th class="text-right">신번호</th>
							<td>
								<input type="text" class="form-control  width120px" id="part_new_no" name="part_new_no" />
							</td>
							<th colspan="2" class="text-right">신번호 호환성</th>
							<td colspan="2">
								<select id="part_new_exchange_cd" name="part_new_exchange_cd" class="form-control  width80px ">
									<option value="">- 선택 -</option>
									<c:forEach items="${codeMap['PART_NEW_EXCHANGE']}" var="item">
										<option value="${item.code_value}">${item.code_name}</option>
									</c:forEach>
								</select>
							</td>
							<th colspan="2" class="text-right">현재고</th>
							<td colspan="2">
								<input type="text" class="form-control text-right  width60px" id="part_current_stock" name="part_current_stock"  datatype="int" readonly/>
							</td>
							<th colspan="2" class="text-right">발주수량/선 주문</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-auto"><input type="text" class="form-control text-right  width60px" readonly="readonly"  datatype="int" ></div>
									<div class="col-auto"><input type="text" class="form-control text-right  width60px" readonly="readonly"  datatype="int" ></div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">구번호</th>
							<td>
								<input type="text" class="form-control  width120px" id="part_old_no" name="part_old_no" />
							</td>
							<th colspan="2" class="text-right">구번호 호환성</th>
							<td colspan="2">
								<select id="part_old_exchange_cd" name="part_old_exchange_cd" class="form-control  width80px  ">
									<option value="">- 선택 -</option>
									<c:forEach items="${codeMap['PART_OLD_EXCHANGE']}" var="item">
										<option value="${item.code_value}">${item.code_name}</option>
									</c:forEach>
								</select>
							</td>
							<th colspan="2" class="text-right essential-item">사용여부</th>
							<td colspan="2">
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" id="radio1" name="use_yn" value="Y" checked="checked">
									<label class="form-check-label" for="radio1">사용</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" id="radio2" name="use_yn" value="N">
									<label class="form-check-label" for="radio2">사용안함</label>
								</div>
							</td>
							<th colspan="2" class="text-right essential-item">생산구분</th>
							<td>
								<select id="part_production_cd" name="part_production_cd" alt="생산구분" class="form-control essential-bg  width80px " onChange="javascript:fnChangeProduction();">
									<option value="">- 선택 -</option>
									<c:forEach items="${codeMap['PART_PRODUCTION']}" var="item">
										<option value="${item.code_value}">${item.code_name}</option>
									</c:forEach>
								</select>
							</td>
						</tr>
						<tr>
							<th class="text-right">수요예측번호</th>
							<td>
								<input type="text" class="form-control  width120px" id="dem_fore_no" name="dem_fore_no" />
							</td>
							<th colspan="2" class="text-right essential-item">산출구분</th>
							<td colspan="2">
								<select id="part_output_price_cd" name="part_output_price_cd" alt="산출구분" class="form-control essential-bg  width240px " onChange="javascript:fnOutputPriceCdChange();">
									<option value="">- 선택 -</option>
									<c:forEach items="${outputPriceCodeList}" var="item">
										<option value="${item.code}">(${item.code}) ${item.calc_foumular}</option>
									</c:forEach>
								</select>
							</td>
							<th colspan="2" class="text-right essential-item">메이커</th>
							<td colspan="2">
								<select id="maker_cd" name="maker_cd" alt="메이커" class="form-control essential-bg width140px" onChange="javascript:fnPartInfo();">
									<option value="">- 선택 -</option>
									<c:forEach items="${makerList}" var="item" varStatus="status">
										<option value="${item.code_value}">${item.code_name}</option>
									</c:forEach>
								</select>
							</td>
							<th colspan="2" class="text-right essential-item">관리구분</th>
							<td>
								<select id="part_mng_cd" name="part_mng_cd" alt="관리구분" class="form-control essential-bg  width140px "   onchange="javascript:fnMngstopYn();"  >
									<option value="">- 선택 -</option>
									<c:forEach items="${codeMap['PART_MNG']}" var="item">
										<option value="${item.code_value}">${item.code_name}</option>
									</c:forEach>
								</select>
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">부품구분</th>
							<td>
<%--								<select id="part_real_check_cd" name="part_real_check_cd" alt="실사구분" class="form-control essential-bg  width80px ">--%>
<%--									<option value="">- 선택 -</option>--%>
<%--									<c:forEach items="${codeMap['PART_REAL_CHECK']}" var="item">--%>
<%--										<option value="${item.code_value}">${item.code_name}</option>--%>
<%--									</c:forEach>--%>
<%--								</select>--%>
								<select id="part_margin_cd" name="part_margin_cd" alt="부품구분" class="form-control essential-bg  width80px" onchange="javascript:fnPriceCalc('N');" >
									<option value="">- 선택 -</option>
									<c:forEach items="${codeMap['PART_MARGIN']}" var="item">
										<option value="${item.code_value}">${item.code_value}</option>
									</c:forEach>
								</select>
							</td>
							<th rowspan="4" class="th-skyblue">단가내역상세</th>
							<th class="text-right">
								<span class="v-align-middle">전략가</span>
								<i class="material-iconserror font-16" style="vertical-align: middle;" onmouseover="javascript:show()" onmouseout="javascript:hide()"></i></th>
							<!-- 마우스 오버시 레이어팝업 -->
							<div class="con-info" id="machine_operation" style="max-height: 500px; left: 30.5%; width: 245px; display: none; top:19%;">
								<ul class="">
									<ol style="color: #666;">&nbsp;전략가 존재 시,</ol>
									<ol style="color: #666;">&nbsp;고객의 VIP적용 유무에 따라 아래와 같이 적용</ol>
									<li>VIP판매가 = 전략가</li>
									<li>일반판매가 = VIP판매가 * 산출비율</li>
								</ul>
							</div>
							<!-- /마우스 오버시 레이어팝업 -->
							</th>
							<td class="text-center">KRW</td>
							<td>
								<input type="text" class="form-control text-right width120px" id="strategy_price" name="strategy_price" format="decimal4" onblur="javascript:fnPriceCalc('Y');"/>
							</td>
							<th colspan="2" class="text-right essential-item">원산지</th>
							<td colspan="2">
								<select id="part_country_cd" name="part_country_cd" class="form-control essential-bg width80px " alt="원산지">
									<option value="">- 선택 -</option>
									<c:forEach items="${codeMap['PART_COUNTRY']}" var="item">
										<option value="${item.code_value}">${item.code_name}</option>
									</c:forEach>
								</select>
							</td>
							<th rowspan="4" class="th-skyblue">수출가격</th>
							<th class=text-right>적용환율</th>
							<td>
								<input type="text" class="form-control text-right  width120px" id="apply_er_rate" name="apply_er_rate" format="decimal4" datatype="int" />
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">분류구분</th>
							<td>
								<div class="form-row inline-pd " style="padding-left : 5px;">
									<input type="text" class="form-control essential-bg" alt="분류구분" required="required" style="width : 300px"
										   id="part_group_cd"
										   name="part_group_cd"
										   easyui="combogrid"
										   easyuiname="partGroupCode"
										   idfield=code
										   textfield="code_name"
										   multi="N"
									/>
								</div>
							</td>
							<th class="text-right">일반판매가</th>
							<td class="text-center">KRW</td>
							<td>
								<input type="text" class="form-control text-right width120px" id="cust_price" name="cust_price" format="decimal4" onChange="javascript:fnChangeFinalPrice('Y');"/>
							</td>
							<th rowspan="3" class="th-skyblue">최종적용가</th>
							<th class="text-right">산출비율</th>
							<td class="text-center text-danger">
								${vipRate}
							</td>
							<td></td>
							<th class=text-right>원가적용율</th>
							<td>
								<input type="text" class="form-control text-right  width120px" id="cost_apply_rate" name="cost_apply_rate" format="decimal4"/>
							</td>
						</tr>
						<tr>
							<th class="text-right">최초등록일</th>
							<td>
								<input type="text" class="form-control width120px" readonly>
							</td>
							<%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체 --%>
							<%--<th class="text-right">대리점가</th>--%>
							<th class="text-right">위탁판매점가</th>
							<td class="text-center">KRW</td>
							<td>
								<input type="text" class="form-control text-right width120px" id="mng_agency_price" name="mng_agency_price" format="decimal4" />
							</td>
							<th class="text-right">VIP판매가</th>
							<td class="text-center">KRW</td>
							<td>
								<input type="text" class="form-control text-right width120px" readonly="readonly" id="vip_sale_price" name="vip_sale_price" value="${list.vip_sale_price}" format="decimal4">
							</td>
							<th class=text-right>적용원가</th>
							<td>
								<input type="text" class="form-control text-right  width120px" id="cost_price" name="cost_price" format="decimal4"/>
							</td>
						</tr>
						<tr>
							<th class="text-right">매출정지일</th>
							<td>
								<input type="text" class="form-control width120px " id="sale_stop_dt" name="sale_stop_dt" readonly>
							</td>
							<th class="text-right">평균매입가</th>
							<td class="text-center">KRW</td>
							<td>
								<input type="text" class="form-control text-right width120px" id="avg_instock_price" name="avg_instock_price" format="decimal4" readonly/>
							</td>
							<th class="text-right">일반판매가</th>
							<td class="text-center">KRW</td>
							<td>
								<input type="text" class="form-control text-right width120px mt3" readonly="readonly" id="sale_price" name="sale_price" value="${list.sale_price}" format="decimal4">
							</td>
							<th class=text-right>FOB수출가</th>
							<td>
								<input type="text" class="form-control text-right  width120px" id="fob_export_price" name="fob_export_price" format="decimal4"/>
							</td>
						</tr>
						<tr>
							<th class="text-right">충당금단가</th>
							<td>
								<input type="text" class="form-control text-right width120px" id="provision_price" name="provision_price" format="decimal4" readonly/>
							</td>
							<th colspan="2"class="text-right">충당금제외단가</th>
							<td colspan="9">
								<input type="text" class="form-control text-right width120px" id="except_provision_price" name="except_provision_price" format="decimal4" readonly/>
							</td>
						</tr>
						</tbody>
					</table>
					<!-- 탭 -->
					<ul class="tabs-c mt30">
						<li class="tabs-item">
							<a href="#" class="tabs-link font-12  active" data-tab="inner1">매입처1</a>
						</li>
						<li class="tabs-item">
							<a href="#" class="tabs-link font-12" data-tab="inner2">매입처2</a>
						</li>
					</ul>
					<!-- /탭 -->
					<!-- 매입처1 -->
					<div class="tabs-inner active" id="inner1">
						<div class="tabs-inner-line">
							<table class="table-border table-fixed mt5">
								<colgroup>
									<col width="120px">
									<col width="">
									<col width="120px">
									<col width="">
									<col width="120px">
									<col width="55px">
									<col width="">
									<col width="120px">
									<col width="">
								</colgroup>
								<tbody>
								<tr>
									<th class="text-right essential-item">매입처</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-10">
												<div class="input-group width180px">
													<input type="text" class="form-control border-right-0 essential-bg" id="deal_cust_name" name="deal_cust_name" alt="매입처">
													<input type="hidden" id="deal_cust_no" name="deal_cust_no">
													<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSearchClientComm();"><i class="material-iconssearch"></i></button>
													<button type="button" class="btn btn-default btn-icon" onclick="javascript:fnClientClear(1);"><i class="material-iconsclose text-default" ></i></button>
												</div>
											</div>
										</div>
									</td>
									<th class="text-right">매입처그룹</th>
									<td>
										<input type="text" id="com_buy_group_cd" name="com_buy_group_cd" class="form-control width40px " readonly >
									</td>
									<th class="text-right essential-item">List Price</th>
									<td class="text-center">
										<input type="text" class="form-control text-center width120px" name="money_unit_cd" readonly/>
									</td>
									<td>
										<input type="text" class="form-control text-right essential-bg  width120px" id="list_price" name="list_price" alt="List Price" format="decimal4" onblur="javascript:fnPriceCalc('N');" />
									</td>
									<th class="text-right">최종매입일</th>
									<td>
										<input type="text" class="form-control width120px" readonly>
									</td>
								</tr>
								<tr>
									<th class="text-right">금형관리</th>
									<td>
										<select id="deal_mold_cont_no_yn" name="deal_mold_cont_no_yn" class="form-control width140px ">
											<option value="">- 선택 -</option>
											<option value="Y">Y</option>
											<option value="N">N</option>
										</select>
									</td>
									<th class="text-right">입고품질검사</th>
									<td>
										<select id="deal_ware_qual_ass" name="deal_ware_qual_ass" class="form-control width140px ">
											<option value="">- 선택 -</option>
											<c:forEach items="${codeMap['WARE_QUAL']}" var="item">
												<option value="${item.code_value}">${item.code_name}</option>
											</c:forEach>
										</select>
									</td>
									<th class="text-right">Net Price</th>
									<td class="text-center">
										<input type="text" class="form-control text-center  width120px" name="money_unit_cd" readonly/>
									</td>
									<td>
										<input type="text" class="form-control text-right width120px" id="net_price" name="net_price" value="${list.net_price}" format="decimal4">
									</td>
									<th class="text-right">최종매입가</th>
									<td>
										<input type="text" class="form-control width120px" readonly>
									</td>
								</tr>
								<tr>
									<th class="text-right">도면보유</th>
									<td>
										<select id="deal_floor_plan_yn" name="deal_floor_plan_yn" class="form-control width140px ">
											<option value="">- 선택 -</option>
											<option value="Y">Y</option>
											<option value="N">N</option>
										</select>
									</td>
									<th class="text-right">포장단위</th>
									<td>
										<input type="text" class="form-control  width120px" id="part_pack_unit" name="part_pack_unit" datatype="int" />
									</td>
									<th class="text-right">SPECIAL</th>
									<td class="text-center">
										<input type="text" class="form-control text-center  width120px" name="money_unit_cd" readonly/>
									</td>
									<td>
										<input type="text" class="form-control text-right  width120px" id="special_price" name="special_price" format="decimal4" onblur="javascript:fnPriceCalc('N');" />
									</td>
									<td colspan="2" rowspan="3"></td>
								</tr>
								<tr>
									<th class="text-right">구매리드타임</th>
									<td>
										<input type="text" class="form-control  width120px" id="part_pur_day_cnt" name="part_pur_day_cnt" datatype="int"/>
									</td>
									<th class="text-right">발주단위</th>
									<td>
										<input type="text" class="form-control  width120px" id="order_unit" name="order_unit" datatype="int"/>
									</td>
									<th class="text-right essential-item">입고단가</th>
									<td class="text-center">
										KRW
									</td>
									<td>
										<input type="text" class="form-control text-right essential-bg  width120px" id="in_stock_price" name="in_stock_price" format="decimal4" alt="입고단가"/>
									</td>
								</tr>
								<tr>
									<th class="text-right">서비스%</th>
									<td>
										<input type="text" class="form-control  width120px" id="service_rate" name="service_rate" datatype="int"/>
									</td>
									<th class="text-right">최소LOT</th>
									<td>
										<input type="text" class="form-control  width120px" id="part_lot" name="part_lot" datatype="int"/>
									</td>
									<th class="text-right">VIP판매가</th>
									<td class="text-center">
										KRW
									</td>
									<td>
										<input type="text" class="form-control text-right width120px" id="vip_price" name="vip_price" onChange="javascript:goCalcFinalPrice('N');" format="decimal4" />
									</td>
								</tr>
								</tbody>
							</table>
						</div>
					</div>
					<!-- /매입처 -->

					<!-- 매입처2 -->
					<div class="tabs-inner" id="inner2">
						<div class="tabs-inner-line">
							<table class="table-border table-fixed mt5">
								<colgroup>
									<col width="120px">
									<col width="">
									<col width="120px">
									<col width="">
									<col width="120px">
									<col width="55px">
									<col width="">
									<col width="120px">
									<col width="">
								</colgroup>
								<tbody>
								<tr>
									<th class="text-right">매입처</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-10">
												<div class="input-group width180px">
													<input type="text" class="form-control border-right-0" id="deal_cust_name2" name="deal_cust_name2" alt="매입처2">
													<input type="hidden" id="deal_cust_no2" name="deal_cust_no2">
													<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSearchClientComm2();"><i class="material-iconssearch"></i></button>
													<button type="button" class="btn btn-default btn-icon" onclick="javascript:fnClientClear(2);"><i class="material-iconsclose text-default"></i></button>
												</div>
											</div>
										</div>
									</td>
									<th class="text-right">매입처그룹</th>
									<td>
										<input type="text" id="com_buy_group_cd2" name="com_buy_group_cd2" class="form-control width40px " readonly >
									</td>
									<th class="text-right ">List Price</th>
									<td class="text-center">
										<input type="text" class="form-control text-center width120px" name="money_unit_cd" readonly/>
									</td>
									<td>
										<input type="text" class="form-control text-right  width120px" id="list_price2" name="list_price2" alt="List Price2" format="decimal4" value="0" onblur="javascript:fnPriceCalc('N');" />
									</td>
									<th class="text-right">최종매입일</th>
									<td>
										<input type="text" class="form-control width120px" readonly>
									</td>
								</tr>
								<tr>
									<th class="text-right">금형관리</th>
									<td>
										<select id="deal_mold_cont_no2_yn" name="deal_mold_cont_no2_yn" class="form-control width140px ">
											<option value="">- 선택 -</option>
											<option value="Y">Y</option>
											<option value="N">N</option>
										</select>
									</td>
									<th class="text-right">입고품질검사</th>
									<td>
										<select id="deal_ware_qual_ass2" name="deal_ware_qual_ass2" class="form-control width140px ">
											<option value="">- 선택 -</option>
											<c:forEach items="${codeMap['WARE_QUAL']}" var="item">
												<option value="${item.code_value}">${item.code_name}</option>
											</c:forEach>
										</select>
									</td>
									<th class="text-right">Net Price</th>
									<td class="text-center">
										<input type="text" class="form-control text-center  width120px" name="money_unit_cd" readonly/>
									</td>
									<td>
										<input type="text" class="form-control text-right  width120px" id="net_price2" name="net_price2" format="decimal4"/>
									</td>
									<th class="text-right">최종매입가</th>
									<td>
										<input type="text" class="form-control width120px" readonly>
									</td>
								</tr>
								<tr>
									<th class="text-right">도면보유</th>
									<td>
										<select id="deal_floor_plan2_yn" name="deal_floor_plan2_yn" class="form-control width140px ">
											<option value="">- 선택 -</option>
											<option value="Y">Y</option>
											<option value="N">N</option>
										</select>
									</td>
									<th class="text-right">포장단위</th>
									<td>
										<input type="text" class="form-control  width120px" id="part_pack_unit2" name="part_pack_unit2" datatype="int" />
									</td>
									<th class="text-right">SPECIAL</th>
									<td class="text-center">
										<input type="text" class="form-control text-center  width120px" name="money_unit_cd" readonly/>
									</td>
									<td>
										<input type="text" class="form-control text-right  width120px" id="special_price2" name="special_price2" format="decimal4" onblur="javascript:fnPriceCalc('N');" />
									</td>
									<td colspan="2" rowspan="3"></td>
								</tr>
								<tr>
									<th class="text-right">구매리드타임</th>
									<td>
										<input type="text" class="form-control  width120px" id="part_pur_day_cnt2" name="part_pur_day_cnt2" datatype="int"/>
									</td>
									<th class="text-right">발주단위</th>
									<td>
										<input type="text" class="form-control  width120px" id="order_unit2" name="order_unit2" datatype="int"/>
									</td>
									<th class="text-right">입고단가</th>
									<td class="text-center">
										KRW
									</td>
									<td>
										<input type="text" class="form-control text-right width120px" id="in_stock_price2" name="in_stock_price2" format="decimal4" alt="입고단가"/>
									</td>
								</tr>
								<tr>
									<th class="text-right">서비스%</th>
									<td>
										<input type="text" class="form-control  width120px" id="service_rate2" name="service_rate2" datatype="int"/>
									</td>
									<th class="text-right">최소LOT</th>
									<td>
										<input type="text" class="form-control  width120px" id="part_lot2" name="part_lot2" datatype="int"/>
									</td>
									<th class="text-right">VIP판매가</th>
									<td class="text-center">
										KRW
									</td>
									<td>
										<input type="text" class="form-control text-right width120px" id="vip_price2" name="vip_price2" onChange="javascript:goCalcFinalPrice('N');" format="decimal4" />
									</td>
								</tr>
								</tbody>
							</table>
						</div>
					</div>
					<!-- /매입처2 -->
					<!-- /상단 폼테이블 -->
					<div class="row">
						<div class="col-3">
							<div class="title-wrap mt10">
								<h4>매출정지사유</h4>
							</div>
							<textarea class="form-control" style="height: 45px;" id="sale_stop_reason" name="sale_stop_reason" maxlength="100"></textarea>
						</div>

						<div class="col-3">
							<div class="title-wrap mt10">
								<h4>단가변경사유</h4>
							</div>
							<textarea class="form-control" style="height: 45px;" id="price_remark" name="price_remark" maxlength="100"></textarea>
						</div>

						<div class="col-3">
							<div class="title-wrap mt10">
								<h4>경고문구팝업</h4>
							</div>
							<textarea class="form-control" style="height: 45px;" id="warning_text" name="warning_text" maxlength="100"></textarea>
						</div>

						<div class="col-3">
							<div class="title-wrap mt10">
								<h4>비고</h4>
							</div>
							<textarea class="form-control" style="height: 45px;" id="part_remark" name="part_remark"></textarea>
						</div>
					</div>
					<!-- 하단 폼테이블 -->
					<div class="title-wrap mt10">
						<h4>추가설정</h4>
					</div>
					<table class="table-border mt5">
						<colgroup>
							<col width="150px">
							<col width="">
							<col width="150px">
							<col width="">
							<col width="150px">
							<col width="">
							<col width="150px">
							<col width="">
						</colgroup>
						<tbody>
						<tr>
							<th class="text-right">수요예측</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-9">
										<div class="form-check form-check-inline">
											<input class="form-check-input dem_fore" type="radio" id="dem_fore_yn1" name="dem_fore_yn" value="Y">
											<label class="form-check-label" for="dem_fore_yn1">YES</label>
										</div>
										<div class="form-check form-check-inline">
											<input class="form-check-input dem_fore" type="radio" id="dem_fore_yn2" name="dem_fore_yn" value="N" checked="checked">
											<label class="form-check-label" for="dem_fore_yn2">NO</label>
										</div>
									</div>
								</div>
							</td>
							<th class="text-right">HOMI관리품지정</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-9">
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" id="homi_yn1" name="homi_yn" value="Y">
											<label class="form-check-label" for="homi_yn1">YES</label>
										</div>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" id="homi_yn2" name="homi_yn" value="N" checked="checked" >
											<label class="form-check-label" for="homi_yn2">NO</label>
										</div>
									</div>
								</div>
							</td>
							<th class="text-right">출하관리품지정</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-9">
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" id="out_mng_yn1" name="out_mng_yn" value="Y">
											<label class="form-check-label" for="out_mng_yn1">YES</label>
										</div>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" id="out_mng_yn2" name="out_mng_yn" value="N" checked="checked" >
											<label class="form-check-label" for="out_mng_yn2">NO</label>
										</div>
									</div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">정비지시서제외</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-9">
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" id="repair_yn1" name="repair_yn" value="Y">
											<label class="form-check-label" for="repair_yn1">YES</label>
										</div>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" id="repair_yn2" name="repair_yn" value="N" checked="checked">
											<label class="form-check-label" for="repair_yn2">NO</label>
										</div>
									</div>
								</div>
							</td>
							<th class="text-right">평균교환주기대상여부</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-9">
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" id="avg_exchange_cycle_yn1" name="avg_exchange_cycle_yn" value="Y">
											<label class="form-check-label" for="avg_exchange_cycle_yn1">YES</label>
										</div>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" id="avg_exchange_cycle_yn2" name="avg_exchange_cycle_yn" value="N" checked="checked">
											<label class="form-check-label" for="avg_exchange_cycle_yn2">NO</label>
										</div>
									</div>
								</div>
							</td>
							<th class="text-right">주요부품설정</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-9">
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" id="major_yn1" name="major_yn" value="Y">
											<label class="form-check-label" for="major_yn1">YES</label>
										</div>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" id="major_yn2" name="major_yn" value="N" checked="checked">
											<label class="form-check-label" for="major_yn2">NO</label>
										</div>
									</div>
								</div>
							</td>
							<th class="text-right">앱 판매 여부</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-9">
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" id="app_sale_y" name="app_sale_yn" value="Y">
											<label class="form-check-label" for="app_sale_y">YES</label>
										</div>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" id="app_sale_n" name="app_sale_yn" value="N" checked="checked">
											<label class="form-check-label" for="app_sale_n">NO</label>
										</div>
									</div>
								</div>
							</td>
						</tr>
						</tbody>
					</table>
					<!-- /하단 폼테이블 -->
					<div class="btn-group mt10">
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
