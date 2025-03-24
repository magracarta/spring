<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 코드관리 > 부품마스터등록/수정 > null > 부품마스터상세
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2020-01-10 17:06:42
------------------------------------------------------------------------------------------------------------------%>
<html>
<head>
<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
<script type="text/javascript">

	// list 의 part_output_price_cd (부품판매단가계산식코드 - 산출구분) 의 name 값
	var partOutputPriceName = "${list.part_output_price_cd}";

	var map = ${map}; // 산출구분 코드를 Key값으로 묶은 List
	var exchangeList = ${exchangeList}; // 통화별 환율
	var priceMakerList = ${priceMakerList}; // 통화별 환율

	var jsonList = ${jsonList};  // json 형태의 원래 정보 - 단가변경체크위해 사용

	// 산출구분의 2번째자리, 3번째자리, 4번째자리 , 화폐단위의 value값
	var dealerCdName = 0;  // 부품판가 딜러할인율 (2번째자리)
	var mngCdName = 0;     // 부품판가 일반관리비 (3번째자리)
	var marginCdName = 0;  // 부품판가 마진율 (4번째자리)
	var fixedErPrice = 0;  // 통화별 결정환율

	var before_deal_cust_name = "${list.deal_cust_name}"; // 매입처명 변경 감지
	var before_deal_cust_name2 = "${list.deal_cust_name2}"; // 매입처명 변경 감지

// 	var changeCnt = 0;

	$(document).ready(function(){
		fnToggle();
		// 산출구분 콤보그리드에 part_output_price_cd 의 가공한 name 값을 세팅
		for (var i in outputPriceCodeData) {
			if (partOutputPriceName == outputPriceCodeData[i].code) {
				$M.setValue("part_output_price_cd", outputPriceCodeData[i].code);
			}
		}

		// 매출정지 - 매출정지사유 textarea 제어
	    if ("${list.part_mng_cd}" == '9') {
	    	$("#sale_stop_reason").prop("disabled");
	    } else {
	    	$("#sale_stop_reason").prop("disabled",true);
	    }

		// 통화별 결정환율 초기값 세팅
		fnSetExchangeRate(true);

		$M.setValue("in_stock_price", jsonList.in_stock_price);
		$M.setValue("cust_price", jsonList.cust_price);
		$M.setValue("mng_agency_price", jsonList.mng_agency_price);

		fnSetPriceCodes();
		// fnMngstopYn();
		
		var chgCycleYn = $M.getValue("origin_chg_cycle_yn");
		if(chgCycleYn != "Y"){
			$("#_goUpdatePartChgCycle").addClass("dpn");
		}
	})

	// 매입처
	function setSearchClientInfo(row) {
		$M.setValue("deal_cust_no", row.cust_no);
		$M.setValue("deal_cust_name", row.cust_name);
		$M.setValue("com_buy_group_cd", row.com_buy_group_cd);

		// 매입처를 선택했을 당시의 매입처명(저장할때 다르면 deal_cust_no 삭제);
		before_deal_cust_name = row.cust_name;
	}
	// 매입처2
	function setSearchClientInfo2(row) {
		$M.setValue("deal_cust_no2", row.cust_no);
		$M.setValue("deal_cust_name2", row.cust_name);

		// 매입처를 선택했을 당시의 매입처명(저장할때 다르면 deal_cust_no2 삭제);
		before_deal_cust_name2 = row.cust_name;
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

	// 수정
	function goModify(){
		if($M.getValue("deal_cust_name2") != "" && $M.getValue("strategy_price") == 0){
			alert("매입처2 등록 시 전략가는 필수입력입니다.");
			$('#strategy_price').next().find('input').focus()
			return;
		}

		if (before_deal_cust_name != $M.getValue("deal_cust_name")) {
			$M.clearValue({field:["deal_cust_no"]});
		}

		if (before_deal_cust_name2 != $M.getValue("deal_cust_name2")) {
			$M.clearValue({field:["deal_cust_no2"]});
		}

		// 주요부품 자동반영 여부
		var majorAutoYn = $("input:checkbox[name='majorAutoYn']").is(":checked");
		if(majorAutoYn) {
			$M.setValue("major_auto_yn", "Y");
		} else {
			$M.setValue("major_auto_yn", "N");
		}

		var frm = document.main_form;

		// validation check
		if($M.validation(document.main_form, {field:["part_no", "part_name", "maker_cd", "part_production_cd", "part_mng_cd", "part_real_check_cd", "list_price", "in_stock_price", "part_margin_cd"]}) == false) {
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

		// 단가내역항목 변경값 체크 (변경사항이 없을 시 -> 저장하지 않음)
		// hidden 으로 flag 값을 넣어주고 서버에서 form안에 flag값을 꺼내어 조건에따라 수정하도록 하는 방법.

// 		var partPriceModifyFlag = $M.getValue("part_price_modify_flag");
// 		console.log(jsonList);
// 		console.log("part_price_modify_flag : " , $M.getValue("part_price_modify_flag"));

		// 기존값
		var originData = {
			"list_price" : jsonList.list_price,  // 기준단가
			"net_price" : jsonList.net_price,	// 발주단가
			"price_remark" : jsonList.price_remark, // 단가변경사유
			"special_price" : jsonList.special_price, // SPECIAL 단가
			"in_stock_price" : jsonList.in_stock_price, // 입고단가
			"cust_price" : jsonList.cust_price,		// 소비자가
			"mng_agency_price" : jsonList.mng_agency_price,  // 관리대리점가
			"mng_agency_price2" : jsonList.mng_agency_price2, // 관리대리점가2
			"vip_price" : jsonList.vip_price, // VIP 판매가
			"strategy_price" : jsonList.strategy_price,  // 전략가
			"maker_exchange_rate" : jsonList.maker_exchange_rate,   // 화폐단위
			"apply_er_rate" : jsonList.apply_er_rate,  // 적용환율
			"cost_apply_rate" : jsonList.cost_apply_rate,  // 원가적용율
			"cost_price" : jsonList.cost_price,		 // 적용원가
			"fob_export_price" : jsonList.fob_export_price,  // FOB수출가
			"vip_sale_price" : jsonList.vip_sale_price,  // 최종 VIP판매가
			"sale_price" : jsonList.sale_price,  // 최종 일반판매가
		};

		// 새로 입력받은 값
		var newData = {
			"list_price" : $M.getValue("list_price"), // 기준단가
			"net_price" : $M.getValue("net_price"),   // 발주단가
			"price_remark" : $M.getValue("price_remark"),  // 단가변경사유
			"special_price" : $M.getValue("special_price"), // SPECIAL 단가
			"in_stock_price" : $M.getValue("in_stock_price"), // 입고단가
			"cust_price" : $M.getValue("cust_price"),		// 소비자가
			"mng_agency_price" : $M.getValue("mng_agency_price"),  // 관리대리점가
			"mng_agency_price2" : $M.getValue("mng_agency_price2"), // 관리대리점가2
			"vip_price" : $M.getValue("vip_price"), // VIP 판매가
			"strategy_price" : $M.getValue("strategy_price"),  // 전략가
			"maker_exchange_rate" : $M.getValue("maker_exchange_rate"),   // 화폐단위
			"apply_er_rate" : $M.getValue("apply_er_rate"),  // 적용환율
			"cost_apply_rate" : $M.getValue("cost_apply_rate"),  // 원가적용율
			"cost_price" : $M.getValue("cost_price"),		 // 적용원가
			"fob_export_price" : $M.getValue("fob_export_price"),  // FOB수출가
			"vip_sale_price" : $M.getValue("vip_sale_price"),  // 최종 VIP판매가
			"sale_price" : $M.getValue("sale_price"),  // 최종 일반판매가
		}

		var cnt = Object.keys(originData).length; // 데이터변경 체크할 변수  cnt가 0이면 수정사항 없음
		for (var item in originData) {
			if (originData[item] == newData[item]) {
				cnt--;
				console.log("데이터변경 X");
			}

			if (cnt == 0) {
				$M.setValue("part_price_modify_flag", true);
			}
		}
		if(jsonList.part_mng_cd != $M.getValue("part_mng_cd") && $M.getValue("part_mng_cd") == "20"){ // 관리구분 충당재고로 변경 시
			$M.setValue("part_mng_cd_modify", "Y");
		}

		// 호환모델 수정 추가
		var machinePlantSeqArr = $(".machine_plant_seq");
		var machineRemoveArr = $(".machine_remove");
		var machinePlantSeq = [];
		var machineRemove = [];
		
		if(machinePlantSeqArr.length > 0) {
			for(var i = 0; i < machinePlantSeqArr.length; i++) {
				machinePlantSeq.push(machinePlantSeqArr[i].value);
			}
		}
		if(machineRemoveArr.length > 0) {
			for(var i = 0; i < machineRemoveArr.length; i++) {
				machineRemove.push(machineRemoveArr[i].value);
			}
		}
		var option = {
			isEmpty : true
		};
		$M.setValue(frm, "machine_plant_seq_str", $M.getArrStr(machinePlantSeq, option));
		$M.setValue(frm, "machine_remove_str", $M.getArrStr(machineRemove, option));
		
		$M.goNextPageAjaxSave(this_page + "/modify", $M.toValueForm(frm) , {method : 'POST'},
			function(result) {
				if(result.success) {
					$M.setValue("part_price_modify_flag", false); // falg 값 false로 설정
// 	    			fnClose();
					location.reload();
					if (window.opener.goSearch) {
						window.opener.goSearch();
					}
				}
			}
		);
	}

	// 단가이력조회 ( 부품단가변경이력 팝업 호출 )
	function goHistory() {
		var param = {
			'part_no' : $M.getValue("part_no"),
			's_sort_key' : "price_date",
			's_sort_method' : "desc"
		};
		$M.goNextPage('/part/part0701p05', $M.toGetParam(param), {popupStatus : getPopupProp});
	}

	// 상세조회 팝업 닫기
	function fnClose() {
		window.close();
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

	// 입출고내역 팝업호출
    function fnInoutPartInfo() {
		var param = {
				'part_no' : $M.getValue("part_no")
		};
  	  	openInoutPartPanel('fnSetInoutPartInfo', $M.toGetParam(param));
    }

	// HOMI관리 팝업호출
	function fnHomiStock() {
		var param = {
				'part_no' : $M.getValue("part_no"),
		};
		var poppupOption = "";
	    $M.goNextPage('/part/part0701p06/', $M.toGetParam(param) , {popupStatus : poppupOption});
	}

	// 산출구분 콤보그리드 onChange
	function fnOutputPriceCdChange() {

		// 콤보그리드 onchagne가 페이지 최초진입시에도 실행되어버려서 추가함. 2021-02-03 김상덕
// 		if (changeCnt == 0) {
// 			changeCnt++;
// 			return false;
// 		}

		// 산출구분이 변경될때마다 계산식에 필요한 정보를 가져오기 위함.
		fnSetPriceCodes();
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
				$M.setValue("maker_exchange_rate", priceMakerList[item].code_v1);
			}
		}

		fnSetExchangeRate(true);
		fnPriceCalc('N');
	}

	// 메이커, 생산구분, 금액 초기화
	function fnClearValue(gubun) {
		if(gubun == "OUTPUT") {
			$M.clearValue({field:["maker_cd", "maker_exchange_rate", "list_price", "net_price"
				, "special_price" , "in_stock_price", "vip_price", "strategy_price", "cust_price", "mng_agency_price"]});
		}
		$M.clearValue({field:["part_production_cd"]});
	}

	// maker onChange 단가내역상세조회 메이커에 따라 화폐단위 변경
	function fnPriceChange() {
		// 메이커, 생산구분, 금액 초기화
// 		fnClearValue("MAKER");

		var partOutputPrice = $M.getValue("part_output_price_cd");
		console.log("메이커 또는 산출구분partOutputPrice : ", partOutputPrice);
		var exchangeStr = $.trim(partOutputPrice).substring(0, 1);
		console.log("메이커 또는 산출구분exchangeStr : ", exchangeStr);

		for(var item in priceMakerList) {
			if(priceMakerList[item].code.includes(exchangeStr)) {
				$M.setValue("maker_exchange_rate", priceMakerList[item].code_v1);
			}
		}
// 		var makerNm = $("#maker_cd option:selected").text();

// 		var str1 = makerNm.lastIndexOf(" ");  // 오른쪽에서 왼쪽으로 검색하여 값을 가져옴니다.
// 		var str2 = $.trim(makerNm.substring(str1, makerNm.length)); // 결정환율을 구하기위한 값
// 		$M.setValue("maker_exchange_rate", str2);

// 		console.log(str2);
// 		console.log("화폐 단위 : ", $M.getValue("maker_exchange_rate"));

		fnSetExchangeRate(true);
		fnPartInfo();
	}

	// 생산구분 클릭 시
	function fnChangeProduction() {
		// 생산구분이 국산 (code값 1) 일때 는 무조건 KRW로 세팅해줌.
		if ($M.getValue("part_production_cd") == '1') {

			fnSetExchangeRate(true);

		} else {
// 			var makerNm = $("#maker_cd option:selected").text();

// 			var str1 = makerNm.lastIndexOf(" ");  // 오른쪽에서 왼쪽으로 검색하여 값을 가져옴니다.
// 			var str2 = $.trim(makerNm.substring(str1, makerNm.length)); // 결정환율을 구하기위한 값
// 			$M.setValue("maker_exchange_rate", str2);

			var partOutputPrice = $M.getValue("part_output_price_cd");
			console.log("생산구분partOutputPrice : ", partOutputPrice);
			var exchangeStr = $.trim(partOutputPrice).substring(0, 1);
			console.log("생산구분exchangeStr : ", exchangeStr);

			for(var item in priceMakerList) {
				if(priceMakerList[item].code.includes(exchangeStr)) {
					$M.setValue("maker_exchange_rate", priceMakerList[item].code_v1);
				}
			}

			fnSetExchangeRate(false);
		}

		console.log("생산구분fixedErPrice : ", fixedErPrice);

		fnPartInfo();
	}

	// 부품기준산출코드 조회
	function fnPartInfo() {

		if($M.getValue("maker_cd") != "" && ($M.getValue("part_production_cd") == "0" || $M.getValue("part_production_cd") == "1")) {
			var param = {
					"part_production_cd" : $M.getValue("part_production_cd"),
					"maker_cd" : $M.getValue("maker_cd")
			}

			$M.goNextPageAjax("/part/part070101/getPartInfo", $M.toGetParam(param), {method : 'GET'},
				function(result) {
					if(result.success) {
						$M.clearValue({field:["part_output_price_cd", "part_country_cd", "part_mng_cd", "part_real_check_cd"]});

						$M.setValue(result);

						dealerCdName = result.part_price_dealer_discount;
						mngCdName = result.part_price_mng_amount;
						marginCdName = result.part_price_margin;

						if($M.getValue("part_production_cd") == "1") {
							fnSetExchangeRate(true);
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

						// 23.02.27 정윤수 관리구분 - 정상부품 : 수요예측 Y, 정상부품X : 수요예측 N, disabled
						if($M.getValue("part_mng_cd") == "1") {
							$("#dem_fore_yn1").prop("checked",true);
							$(".dem_fore").prop("disabled",false);
						}else{
							$("#dem_fore_yn2").prop("checked",true);
							$(".dem_fore").prop("disabled",true);
						}
// 						if ($M.getValue("part_production_cd") == '1') {
// 							$M.setValue("maker_exchange_rate", 'KRW');
// 						}
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
					"part_no" : $M.getValue("part_no"),
					// 23.02.27 정윤수 매입처2 항목 추가
					"list_price2" : $M.getValue("list_price2") == "" ? 0 : $M.getValue("list_price2"),
					"special_price2" : $M.getValue("special_price2"),
					// 추가
					"part_output_price_cd" : $M.getValue("part_output_price_cd"),
					"money_unit_cd" : $M.getValue("maker_exchange_rate"),
					"in_avg_price" : $M.getValue("avg_instock_price"), // 평균매입가
					"part_mng_cd" : $M.getValue("part_mng_cd"), // 관리구분
					"part_margin_cd" : $M.getValue("part_margin_cd"), // 마진율 대체하는 부품구분
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
					"dealer_discount" : dealerCdName,
					"part_no" : $M.getValue("part_no")
			}

			console.log("param : ", param);

			$M.goNextPageAjax(this_page + "/calcFinalAmt", $M.toGetParam(param), {method : 'GET'},
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
		if($M.getValue("vip_sale_price") != "") {
			var param = {
					"vip_price" : $M.getValue("vip_sale_price"),
					"cust_price" : $M.getValue("cust_price"),
					"strategy_price" : $M.getValue("strategy_price")
			}

			$M.goNextPageAjax(this_page + "/calcSalePrice", $M.toGetParam(param), {method : 'GET'},
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
	function fnClientClear() {
			$M.setValue("deal_cust_name2", "");
	}

	// 선택한 산출구분 코드로 '딜러할인율', '일반관리비', '마진율' 구하기
	function fnSetPriceCodes() {
		var outputPriceCode = $M.getValue("part_output_price_cd");  // 산출구분 코드 (B014, N724...)

		var keys = Object.keys(map);
		for (var i in keys) {
			if (keys[i].includes(outputPriceCode)) {
				dealerCdName = map[keys[i]][0].dealer_cd_name;   // 딜러할인율
				mngCdName = map[keys[i]][0].mng_cd_name;         // 일반관리비
				marginCdName = map[keys[i]][0].margin_cd_name;   // 마진율
			}
		}
	}

	/**
	 * 생산구분에 따라 결정환율을 세팅
	 * @param {boolean} isSetExchange 국산일 때, maker_exchange_rate를 KRW로 세팅 여부
	 */
	function fnSetExchangeRate(isSetExchange) {
		// 통화별 결정환율
	    var makerExchangeRate = $M.getValue("maker_exchange_rate");

		// 생산구분이 국산일때 결정환율 1로 세팅
	    if ($M.getValue("part_production_cd") == "1") {
			fixedErPrice = 1;
			if (isSetExchange) {
				$M.setValue("maker_exchange_rate", 'KRW');
			}
		} else if (makerExchangeRate != "") {
			for (var item in exchangeList) {
				if (exchangeList[item].money_unit_cd.includes(makerExchangeRate)) {
					fixedErPrice = exchangeList[item].fixed_er_price; // 결정환율 set
				}
			}
		} else {
// 			fixedErPrice = 0;
			// 21.06.01 이원영 파트장님 요청으로 메이커 기타일 경우 결정환율 1로 세팅.
			fixedErPrice = 1;
		}
	}
	
	// 장비조회 클릭
	function goSearchMachine() {
		var param = {
			"part_comm_yn" : 'Y'
		};
		openSearchModelPanel('fnSetMachineInfo', 'N', $M.toGetParam(param));
	}
	// 호환모델 추가
	function fnSetMachineInfo(data){
		var name = data.machine_name;
		var machinePlantSeq = data.machine_plant_seq;
		var nameArr = $(".machine_name");

		if(nameArr.length > 0) {
			for(var i = 0; i < nameArr.length; i++) {
				if(nameArr[i].textContent == name) {
					alert("동일한 모델이 있습니다.");
					return false;
				}
			}
		}

		var str = '';
		str += '<div class="save-location" id="' + machinePlantSeq + '">';
		str += '<span class="machine_name">' + name +'</span>';
		str += '<input type="hidden" class="machine_plant_seq" value="' + machinePlantSeq + '">';
		str += '<div class="delete">';
		str += '<button type="button" class="btn btn-icon-md text-light" onclick="javascript:fnRemoveStorage(\'' + machinePlantSeq + '\');"><i class="material-iconsclose font-16"></i></button>';
		str += '</div>';
		str += '</div>';

		$("#machine_div").append(str);
	}
	
	// 호환모델 삭제
	function fnRemoveStorage(machinePlantSeq) {
		var str = '';
		str += '<input type="hidden" class="machine_remove" value="' + machinePlantSeq + '">';
		$("#machine_div").append(str);
		
		$("#" + machinePlantSeq).remove();
	}
	
	// 교체주기산출
	function goUpdatePartChgCycle() {
		var originChgCycleYn = $M.getValue("origin_chg_cycle_yn");
		
		if(originChgCycleYn != "Y"){ // 교체주기산출여부 바꾸고 저장 안한경우
			alert("저장 후 다시 시도해주세요.");
			return;
		} 
	
		var param = {
			"part_no" : $M.getValue("part_no")
		}

		$M.goNextPageAjax(this_page + "/updatePartChgCycle", $M.toGetParam(param), {method : 'POST'},
				function(result) {
					if(result.success) {
						location.reload();
					}
				}
		);
	}
</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" name="part_price_modify_flag" value="false">
<input type="hidden" name="part_mng_cd_modify" value="N">
<input type="hidden" name="part_mng_cd_modify" value="N">
<input type="hidden" name="origin_chg_cycle_yn" value="${list.chg_cycle_yn}"/>
	<!-- 팝업 -->
	<div class="popup-wrap width-100per">
		<!-- 타이틀영역 -->
		<div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
		</div>
		<!-- /타이틀영역 -->
		<div class="content-wrap">
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
						<input type="text" id="part_no" name="part_no" class="form-control sale-rb width120px" alt="부품번호" required="required" readonly value="${list.part_no}" >
					</td>
					<th colspan="2" class="text-right essential-item">부품명</th>
					<td colspan="2">
						<input type="text" id="part_name" name="part_name" class="form-control essential-bg" alt="부품명" required="required" value="${list.part_name}">
					</td>
					<th colspan="2" class="text-right">안전재고</th>
					<td colspan="2">
						<input type="text" class="form-control text-right width60px" id="part_safe_stock" name="part_safe_stock" value="${list.part_safe_stock}">
					</td>
					<th colspan="2" class="text-right">안전재고2</th>
					<td>
						<input type="text" class="form-control text-right width60px" id="part_safe_stock2" name="part_safe_stock2" value="${list.part_safe_stock2}">
					</td>
				</tr>
				<tr>
					<th class="text-right">신번호</th>
					<td>
						<input type="text" class="form-control width120px" id="part_new_no" name="part_new_no" value="${list.part_new_no}">
					</td>
					<th colspan="2" class="text-right">신번호 호환성</th>
					<td colspan="2">
						<select id="part_new_exchange_cd" name="part_new_exchange_cd" class="form-control width80px">
							<option value="">- 선택 -</option>
							<c:forEach items="${codeMap['PART_NEW_EXCHANGE']}" var="item">
								<option value="${item.code_value}" ${item.code_value == list.part_new_exchange_cd ? 'selected' : '' }>
										${item.code_name}
								</option>
							</c:forEach>
						</select>
					</td>
					<th colspan="2" class="text-right">현재고</th>
					<td colspan="2">
						<input type="text" class="form-control text-right width60px" id="part_current_stock" name="part_current_stock" value="${list.part_current_stock}" readonly>
					</td>
					<th colspan="2" class="text-right">발주수량/선 주문</th>
					<td>
						<div class="form-row inline-pd">
							<div class="col-auto">
								<input type="text" class="form-control text-right width60px" id="part_order_count" name="part_order_count" value="${list.part_order_count}" readonly/>
							</div>
							<div class="col-auto">
								<input type="text" class="form-control text-right width60px" id="preorder_qty" name="preorder_qty" value="${list.preorder_qty}" readonly/>
							</div>
						</div>
					</td>
				</tr>
				<tr>
					<th class="text-right">구번호</th>
					<td>
						<input type="text" class="form-control width120px" id="part_old_no" name="part_old_no" value="${list.part_old_no}">
					</td>
					<th colspan="2" class="text-right">구번호 호환성</th>
					<td colspan="2">
						<select id="part_old_exchange_cd" name="part_old_exchange_cd" class="form-control width80px">
							<option value="">- 선택 -</option>
							<c:forEach items="${codeMap['PART_OLD_EXCHANGE']}" var="item">
								<option value="${item.code_value}" ${item.code_value == list.part_old_exchange_cd ? 'selected="selected"' : '' }>
										${item.code_name}
								</option>
							</c:forEach>
						</select>
					</td>
					<th colspan="2" class="text-right essential-item">사용여부</th>
					<td colspan="2">
						<div class="form-check form-check-inline">
							<input class="form-check-input" type="radio" id="radio1" name="use_yn" value="Y" ${list.use_yn eq 'Y' ? 'checked' : '' }>
							<label class="form-check-label" for="radio1">사용</label>
						</div>
						<div class="form-check form-check-inline">
							<input class="form-check-input" type="radio" id="radio2" name="use_yn" value="N" ${list.use_yn eq 'N' ? 'checked' : '' }>
							<label class="form-check-label" for="radio2">사용안함</label>
						</div>
					</td>
					<th colspan="2" class="text-right essential-item">생산구분</th>
					<td>
						<select id="part_production_cd" name="part_production_cd" alt="생산구분" class="form-control essential-bg width80px" onChange="javascript:fnChangeProduction();">
							<option value="">- 전체 -</option>
							<c:forEach items="${codeMap['PART_PRODUCTION']}" var="item">
								<option value="${item.code_value}" ${item.code_value == list.part_production_cd ? 'selected' : '' }>
										${item.code_name}</option>
							</c:forEach>
						</select>
					</td>
				</tr>
				<tr>
					<th class="text-right">수요예측번호</th>
					<td>
						<input type="text" class="form-control width120px" id="dem_fore_no" name="dem_fore_no" value="${list.dem_fore_no}">
					</td>
					<th colspan="2" class="text-right essential-item">산출구분</th>
					<td colspan="2">
						<select id="part_output_price_cd" name="part_output_price_cd" alt="산출구분" class="form-control essential-bg width240px" onChange="javascript:fnOutputPriceCdChange();">
							<option value="">- 전체 -</option>
							<c:forEach items="${outputPriceCodeList}" var="item">
								<option value="${item.code}" ${item.code == list.part_output_price_cd ? 'selected' : '' }>
									(${item.code}) ${item.calc_foumular}</option>
							</c:forEach>
						</select>
<!-- 							<div class="form-row inline-pd" style="padding-left : 5px; padding-right : 5px;"> -->
<!-- 								 <input type="text" class="form-control essential-bg"  -->
<!-- 									id="part_output_price_cd"  -->
<!-- 									name="part_output_price_cd"  -->
<!-- 									easyuiname="outputPriceCode" -->
<!-- 									textfield="calc_foumular" -->
<!-- 									multi="N" -->
<!-- 									idfield="code" -->
<!-- 									easyui="combogrid" -->
<!-- 									change="fnOutputPriceCdChange()" -->
<!-- 								 />  -->
<!-- 							</div> -->
					</td>
					<th colspan="2" class="text-right essential-item">메이커</th>
					<td colspan="2">
						<select id="maker_cd" name="maker_cd" alt="메이커" class="form-control essential-bg width120px" onchange="javascript:fnPartInfo();">
							<option value="">- 선택 -</option>
							<c:forEach items="${makerList}" var="item" varStatus="status">
								<option value="${item.code_value}" ${item.code_value == list.maker_cd ? 'selected' : '' }>${item.code_name}</option>
							</c:forEach>
							<%-- 								<c:forEach items="${codeMap['MAKER']}" var="item" varStatus="status"> --%>
							<%-- 									<c:if test="${item.code_v1 eq 'Y' && item.code_v2 eq 'Y'}"> --%>
							<%-- 										<option value="${item.code_value}" ${item.code_value == list.maker_cd ? 'selected' : '' }>${item.code_name} ${item.code_v3}</option> --%>
							<%-- 									</c:if> --%>
							<%-- 								</c:forEach>								 --%>
						</select>
					</td>
					<th colspan="2" class="text-right essential-item">관리구분</th>
					<td>
						<select id="part_mng_cd" name="part_mng_cd" alt="관리구분" class="form-control essential-bg width120px" onchange="javascript:fnMngstopYn();">
							<option value="">- 선택 -</option>
							<c:forEach items="${codeMap['PART_MNG']}" var="item">
								<option value="${item.code_value}" ${item.code_value == list.part_mng_cd ? 'selected' : '' }>
										${item.code_name}</option>
							</c:forEach>
						</select>
					</td>
				</tr>
				<tr>
					<th class="text-right essential-item">부품구분</th>
					<td>
<%--						<select id="part_real_check_cd" name="part_real_check_cd" alt="분류구분" required="required" class="form-control essential-bg width80px">--%>
<%--							<option value="">- 선택 -</option>--%>
<%--							<c:forEach items="${codeMap['PART_REAL_CHECK']}" var="item">--%>
<%--								<option value="${item.code_value}" ${item.code_value == list.part_real_check_cd ? 'selected' : '' }>--%>
<%--										${item.code_name}</option>--%>
<%--							</c:forEach>--%>
<%--						</select>--%>
						<select id="part_margin_cd" name="part_margin_cd" alt="부품구분" required="required" class="form-control essential-bg width80px" onchange="javascript:fnPriceCalc('N');">
							<option value="">- 선택 -</option>
							<c:forEach items="${codeMap['PART_MARGIN']}" var="item">
								<option value="${item.code_value}" ${item.code_value == list.part_margin_cd ? 'selected' : '' }>
										${item.code_value}</option>
							</c:forEach>
						</select>
					</td>
					<th rowspan="4" class="th-skyblue">단가내역상세</th>
					<th class="text-right">
						<span class="v-align-middle">전략가</span>
						<i class="material-iconserror font-16" style="vertical-align: middle;" onmouseover="javascript:show()" onmouseout="javascript:hide()"></i></th>
					<!-- 마우스 오버시 레이어팝업 -->
					<div class="con-info" id="machine_operation" style="max-height: 500px; left: 32.5%; width: 245px; display: none; top:19.5%;">
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
						<input type="text" class="form-control text-right width120px" id="strategy_price" name="strategy_price" value="${list.strategy_price}" format="decimal4" onblur="javascript:fnPriceCalc('Y');">
					</td>
					<th colspan="2" class="text-right essential-item">원산지</th>
					<td colspan="2">
						<select id="part_country_cd" name="part_country_cd" class="form-control essential-bg width80px">
							<option value="">- 선택 -</option>
							<c:forEach items="${codeMap['PART_COUNTRY']}" var="item">
								<option value="${item.code_value}" ${item.code_value == list.part_country_cd ? 'selected' : '' }>
										${item.code_name}</option>
							</c:forEach>
						</select>
					</td>
					<th rowspan="4" class="th-skyblue">수출가격</th>
					<th class=text-right>적용환율</th>
					<td>
						<input type="text" class="form-control text-right width80px" id="apply_er_rate" name="apply_er_rate" format="decimal4" value="${list.apply_er_rate}">
					</td>
				</tr>
				<tr>
					<th class="text-right essential-item">분류구분</th>
					<td>
						<div class="form-row inline-pd" style="padding-left : 5px;">
							<!-- 								<input type="text" id="part_group_cd" name="part_group_cd" class="form-control essential-bg" style="width : 250px"; easyui="combogrid"/> -->
							<input type="text" class="form-control essential-bg" alt="분류구분" required="required" style="width : 300px";
								   id="part_group_cd"
								   name="part_group_cd"
								   easyui="combogrid"
								   easyuiname="partGroupCode"
								   idfield="code"
								   textfield="code_name"
								   multi="N"
								   easyui="combogrid"
								   value="${list.part_group_cd}"
							/>
						</div>
					</td>
					<th class="text-right">일반판매가</th>
					<td class="text-center">KRW</td>
					<td>
						<input type="text" class="form-control text-right width120px" id="cust_price" name="cust_price" value="${list.cust_price}" format="decimal4" onBlur="javascript:fnChangeFinalPrice('Y');">
					</td>
					<th rowspan="3" class="th-skyblue">최종적용가</th>
					<th class="text-right">산출비율</th>
					<td class="text-center text-danger">${vipRate}</td>
					<td></td>
					<th class=text-right>원가적용율</th>
					<td>
						<input type="text" class="form-control text-right width80px" id="cost_apply_rate" name="cost_apply_rate" value="${list.cost_apply_rate}" format="decimal4">
					</td>
				</tr>
				<tr>
					<th class="text-right">최초등록일</th>
					<td>
						<input type="text" class="form-control width120px" id="use_start_dt" name="use_start_dt" value="${list.use_start_dt}" dateFormat="yyyy-MM-dd" readonly>
					</td>
					<%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체 --%>
					<%--<th class="text-right">대리점가</th>--%>
					<th class="text-right">위탁판매점가</th>
					<td class="text-center">KRW</td>
					<td>
						<input type="text" class="form-control text-right width120px" id="mng_agency_price" name="mng_agency_price" value="${list.mng_agency_price}" format="decimal4">
					</td>
					<th class="text-right">VIP판매가</th>
					<td class="text-center">KRW</td>
					<td>
						<input type="text" class="form-control text-right width120px" readonly="readonly" id="vip_sale_price" name="vip_sale_price" value="${list.vip_sale_price}" format="decimal4">
					</td>
					<th class=text-right>적용원가</th>
					<td>
						<input type="text" class="form-control text-right width80px" id="cost_price" name="cost_price" value="${list.cost_price}" datatype="int">
					</td>
				</tr>
				<tr>
					<th class="text-right">매출정지일</th>
					<td>
						<input type="text" class="form-control width120px" id="sale_stop_dt2" name="sale_stop_dt2" value="${list.sale_stop_dt}" dateFormat="yyyy-MM-dd" readonly>
						<input type="hidden" name="sale_stop_dt" value="${inputParam.s_current_dt}">
					</td>
					<th class="text-right">평균매입가</th>
					<td class="text-center">KRW</td>
					<td>
						<input type="text" class="form-control text-right width120px" id="avg_instock_price" name="avg_instock_price" value="${list.avg_instock_price}" format="decimal4" readonly>
					</td>
					<th class="text-right">일반판매가</th>
					<td class="text-center">KRW</td>
					<td>
						<input type="text" class="form-control text-right width120px mt3" readonly="readonly" id="sale_price" name="sale_price" value="${list.sale_price}" format="decimal4">
					</td>
					<th class=text-right>FOB수출가</th>
					<td>
						<input type="text" class="form-control text-right width80px" id="fob_export_price" name="fob_export_price" value="${list.fob_export_price}" format="decimal4">
					</td>
				</tr>
				<tr>
					<th class="text-right">충당금단가</th>
					<td>
						<input type="text" class="form-control text-right width120px" id="provision_price" name="provision_price" value="${list.provision_price}" format="decimal4" readonly/>
					</td>
					<th colspan="2"class="text-right">충당금제외단가</th>
					<td colspan="2">
						<input type="text" class="form-control text-right width120px" id="except_provision_price" name="except_provision_price" value="${list.except_provision_price}" format="decimal4" readonly/>
					</td>
					<th colspan="2" class="text-right">교체주기</th>
					<td colspan="5">
						<div class="form-row inline-pd">
							<div class="col-auto form-check-inline" style="margin-right: 5px;">
								<span style="margin-right: 5px;">수기입력</span>
								<input type="text" class="form-control text-right width70px" id="man_chg_cycle" name="man_chg_cycle" value="${list.man_chg_cycle}" format="decimal4"/>
							</div>
							<div class="col-auto form-check-inline" style="margin-right: 5px;">
								<span style="margin-right: 5px;">자동산출(첫 판매)</span>
								<input type="text" class="form-control text-right width70px" id="auto_first_chg_cycle" name="auto_first_chg_cycle" value="${list.auto_first_chg_cycle}" format="decimal4" readonly/>
							</div>
							<div class="col-auto form-check-inline" style="margin-right: 5px;">
								<span style="margin-right: 5px;">자동산출(평균)</span>
								<input type="text" class="form-control text-right width70px" id="auto_avg_chg_cycle" name="auto_avg_chg_cycle" value="${list.auto_avg_chg_cycle}" format="decimal4" readonly/>
							</div>
							<button type="button" class="btn btn-info mr10" id="_goUpdatePartChgCycle" onclick="javascript:goUpdatePartChgCycle()">교체주기산출</button>
						</div>
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
										<div class="input-group">
											<input type="text" class="form-control border-right-0 essential-bg" id="deal_cust_name" name="deal_cust_name" value="${list.deal_cust_name}" alt="매입처">
											<input type="hidden" id="deal_cust_no" name="deal_cust_no" value="${list.deal_cust_no}">
											<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSearchClientComm();"><i class="material-iconssearch"></i></button>
										</div>
									</div>
								</div>
							</td>
							<th class="text-right">매입처그룹</th>
							<td>
								<input type="text" id="com_buy_group_cd" name="com_buy_group_cd" class="form-control width40px " readonly value="${list.com_buy_group_cd}">
							</td>
							<th class="text-right essential-item">List Price</th>
							<td class="text-center">
								<input type="text" class="form-control essential-bg text-center" value="${list.maker_exchange_rate}" name="maker_exchange_rate" readonly>
							</td>
							<td>
								<input type="text" class="form-control text-right essential-bg width120px" id="list_price" name="list_price" alt="List Price" format="decimal4" value="${list.list_price}" onblur="javascript:fnPriceCalc('N');">
							</td>
							<th class="text-right">최종매입일</th>
							<td>
								<input type="text" class="form-control width120px" id="last_in_dt" name="last_in_dt" value="${list.last_in_dt}" dateFormat="yyyy-MM-dd" readonly>
							</td>
						</tr>
						<tr>
							<th class="text-right">금형관리</th>
							<td>
								<select id="deal_mold_cont_no_yn" name="deal_mold_cont_no_yn" class="form-control width60px">
									<option value="">- 선택 -</option>
									<option value="Y" ${list.deal_mold_cont_no_yn == "Y" ? 'selected' : '' }>Y</option>
									<option value="N" ${list.deal_mold_cont_no_yn == "N" ? 'selected' : '' }>N</option>
								</select>
							</td>
							<th class="text-right">입고품질검사</th>
							<td>
								<select id="deal_ware_qual_ass" name="deal_ware_qual_ass" class="form-control width60px">
									<option value="">- 선택 -</option>
									<c:forEach items="${codeMap['WARE_QUAL']}" var="item">
										<option value="${item.code_value}" ${item.code_value == list.deal_ware_qual_ass ? 'selected' : '' }>
												${item.code_name}</option>
									</c:forEach>
								</select>
							</td>
							<th class="text-right">Net Price</th>
							<td class="text-center">
								<input type="text" class="form-control text-center" value="${list.maker_exchange_rate}" name="maker_exchange_rate" readonly>
							</td>
							<td>
								<input type="text" class="form-control text-right width120px" id="net_price" name="net_price" value="${list.net_price}" format="decimal4">
							</td>
							<th class="text-right">최종매입가</th>
							<td>
								<input type="text" class="form-control text-right width120px" id="part_buy_price" name="part_buy_price" format="decimal4" value="${list.part_buy_price}" readonly >
							</td>
						</tr>
						<tr>
							<th class="text-right">도면보유</th>
							<td>
								<select id="deal_floor_plan_yn" name="deal_floor_plan_yn" class="form-control width60px">
									<option value="">- 선택 -</option>
									<option value="Y" ${list.deal_floor_plan_yn == "Y" ? 'selected' : '' }>Y</option>
									<option value="N" ${list.deal_floor_plan_yn == "N" ? 'selected' : '' }>N</option>
								</select>
							</td>
							<th class="text-right">포장단위</th>
							<td>
								<input type="text" class="form-control width80px" id="part_pack_unit" name="part_pack_unit" value="${list.part_pack_unit}" datatype="int">
							</td>
							<th class="text-right">SPECIAL</th>
							<td class="text-center">
								<input type="text" class="form-control text-center " value="${list.maker_exchange_rate}" name="maker_exchange_rate" readonly>
							</td>
							<td>
								<input type="text" class="form-control text-right width120px" id="special_price" name="special_price" value="${list.special_price}" format="decimal4" onblur="javascript:fnPriceCalc('N');">
							</td>
							<td colspan="2" rowspan="3"></td>
						</tr>
						<tr>
							<th class="text-right">구매리드타임</th>
							<td>
								<input type="text" class="form-control width80px" id="part_pur_day_cnt" name="part_pur_day_cnt" value="${list.part_pur_day_cnt}" datatype="int">
							</td>
							<th class="text-right">발주단위</th>
							<td>
								<input type="text" class="form-control width80px" id="order_unit" name="order_unit" value="${list.order_unit}" datatype="int">
							</td>
							<th class="text-right essential-item">입고단가</th>
							<td class="text-center">
								KRW
							</td>
							<td>
								<input type="text" class="form-control text-right essential-bg width120px" id="in_stock_price" name="in_stock_price" alt="입고단가" value="${list.in_stock_price}" format="decimal4">
							</td>
						</tr>
						<tr>
							<th class="text-right">서비스%</th>
							<td>
								<input type="text" class="form-control width80px" id="service_rate" name="service_rate" value="${list.service_rate}" datatype="int">
							</td>
							<th class="text-right">최소LOT</th>
							<td>
								<input type="text" class="form-control width80px" id="part_lot" name="part_lot" value="${list.part_lot}" datatype="int">
							</td>
							<th class="text-right">VIP판매가</th>
							<td class="text-center">
								KRW
							</td>
							<td>
								<input type="text" class="form-control text-right width120px" id="vip_price" name="vip_price" value="${list.vip_price}" onChange="javascript:goCalcFinalPrice('N');" format="decimal4">
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
										<div class="input-group">
											<input type="text" class="form-control border-right-0" id="deal_cust_name2" name="deal_cust_name2" value="${list.deal_cust_name2}" alt="매입처2">
											<input type="hidden" id="deal_cust_no2" name="deal_cust_no2" value="${list.deal_cust_no2}">
											<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSearchClientComm2();"><i class="material-iconssearch"></i></button>
										</div>
									</div>
									<div class="col-auto">
										<button type="button" class="btn btn-default btn-icon"><i class="material-iconsclose text-default" onclick="javascript:fnClientClear();"></i></button>
									</div>
								</div>
							</td>
							<th class="text-right">매입처그룹</th>
							<td>
								<input type="text" id="com_buy_group_cd2" name="com_buy_group_cd2" class="form-control width40px " readonly value="${list.com_buy_group_cd2}">
							</td>
							<th class="text-right">List Price</th>
							<td class="text-center">
								<input type="text" class="form-control text-center" value="${list.maker_exchange_rate}" name="maker_exchange_rate" readonly>
							</td>
							<td>
								<input type="text" class="form-control text-right width120px" id="list_price2" name="list_price2" alt="List Price2" format="decimal4" value="${list.list_price2}" onblur="javascript:fnPriceCalc('N');">
							</td>
							<th class="text-right">최종매입일</th>
							<td>
								<input type="text" class="form-control width120px" id="last_in_dt2" name="last_in_dt2" value="${list.last_in2_dt}" dateFormat="yyyy-MM-dd" readonly>
							</td>
						</tr>
						<tr>
							<th class="text-right">금형관리</th>
							<td>
								<select id="deal_mold_cont_no2_yn" name="deal_mold_cont_no2_yn" class="form-control width60px">
									<option value="">- 선택 -</option>
									<option value="Y" ${list.deal_mold_cont_no2_yn == "Y" ? 'selected' : '' }>Y</option>
									<option value="N" ${list.deal_mold_cont_no2_yn == "N" ? 'selected' : '' }>N</option>
								</select>
							</td>
							<th class="text-right">입고품질검사</th>
							<td>
								<select id="deal_ware_qual_ass2" name="deal_ware_qual_ass2" class="form-control width60px">
									<option value="">- 선택 -</option>
									<c:forEach items="${codeMap['WARE_QUAL']}" var="item">
										<option value="${item.code_value}" ${item.code_value == list.deal_ware_qual_ass2 ? 'selected' : '' }>
												${item.code_name}</option>
									</c:forEach>
								</select>
							</td>
							<th class="text-right">Net Price</th>
							<td class="text-center">
								<input type="text" class="form-control text-center" value="${list.maker_exchange_rate}" name="maker_exchange_rate" readonly>
							</td>
							<td>
								<input type="text" class="form-control text-right width120px" id="net_price2" name="net_price2" value="${list.net_price2}" format="decimal4">
							</td>
							<th class="text-right">최종매입가</th>
							<td>
								<input type="text" class="form-control text-right width120px" id="part_buy_price2" name="part_buy_price2" format="decimal4" value="${list.part_buy_price2}" readonly >
							</td>
						</tr>
						<tr>
							<th class="text-right">도면보유</th>
							<td>
								<select id="deal_floor_plan2_yn" name="deal_floor_plan2_yn" class="form-control width60px">
									<option value="">- 선택 -</option>
									<option value="Y" ${list.deal_floor_plan2_yn == "Y" ? 'selected' : '' }>Y</option>
									<option value="N" ${list.deal_floor_plan2_yn == "N" ? 'selected' : '' }>N</option>
								</select>
							</td>
							<th class="text-right">포장단위</th>
							<td>
								<input type="text" class="form-control width80px" id="part_pack_unit2" name="part_pack_unit2" value="${list.part_pack_unit2}" datatype="int">
							</td>
							<th class="text-right">SPECIAL</th>
							<td class="text-center">
								<input type="text" class="form-control text-center " value="${list.maker_exchange_rate}" name="maker_exchange_rate" readonly>
							</td>
							<td>
								<input type="text" class="form-control text-right width120px" id="special_price2" name="special_price2" value="${list.special_price2}" format="decimal4" onblur="javascript:fnPriceCalc('N');">
							</td>
							<td colspan="2" rowspan="3"></td>
						</tr>
						<tr>
							<th class="text-right">구매리드타임</th>
							<td>
								<input type="text" class="form-control width80px" id="part_pur_day_cnt2" name="part_pur_day_cnt2" value="${list.part_pur_day_cnt2}" datatype="int">
							</td>
							<th class="text-right">발주단위</th>
							<td>
								<input type="text" class="form-control width80px" id="order_unit2" name="order_unit2" value="${list.order_unit2}" datatype="int">
							</td>
							<th class="text-right">입고단가</th>
							<td class="text-center">
								KRW
							</td>
							<td>
								<input type="text" class="form-control text-right width120px" id="in_stock_price2" name="in_stock_price2" alt="입고단가" value="${list.in_stock_price2}" format="decimal4">
							</td>
						</tr>
						<tr>
							<th class="text-right">서비스%</th>
							<td>
								<input type="text" class="form-control width80px" id="service_rate2" name="service_rate2" value="${list.service_rate2}" datatype="int">
							</td>
							<th class="text-right">최소LOT</th>
							<td>
								<input type="text" class="form-control width80px" id="part_lot2" name="part_lot2" value="${list.part_lot2}" datatype="int">
							</td>
							<th class="text-right">VIP판매가</th>
							<td class="text-center">
								KRW
							</td>
							<td>
								<input type="text" class="form-control text-right width120px" id="vip_price2" name="vip_price2" value="${list.vip_price2}" onChange="javascript:goCalcFinalPrice('N');" format="decimal4">
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
					<textarea class="form-control mt5" style="height: 50px;" id="sale_stop_reason" name="sale_stop_reason" maxlength="100">${list.sale_stop_reason}</textarea>
				</div>

				<div class="col-3">
					<div class="title-wrap mt10">
						<h4>단가변경사유</h4>
					</div>
					<textarea class="form-control mt5" style="height: 50px;" id="price_remark" name="price_remark" maxlength="100">${list.price_remark}</textarea>
				</div>

				<div class="col-3">
					<div class="title-wrap mt10">
						<h4>경고문구팝업</h4>
					</div>
					<textarea class="form-control mt5" style="height: 50px;" id="warning_text" name="warning_text" maxlength="100">${list.warning_text }</textarea>
				</div>

				<div class="col-3">
					<div class="title-wrap mt10">
						<h4>비고</h4>
					</div>
					<textarea class="form-control mt5" style="height: 50px;" id="part_remark" name="part_remark">${list.part_remark}</textarea>
				</div>
			</div>

			<!-- 하단 폼테이블 -->
			<div class="title-wrap mt10">
				<h4>추가설정</h4>
			</div>
			<table class="table-border mt5">
				<colgroup>
					<col width="130px">
					<col width="">
					<col width="130px">
					<col width="">
					<col width="130px">
					<col width="220px">
					<col width="110px">
					<col width="">
				</colgroup>
				<tbody>
				<tr>
					<th class="text-right">수요예측</th>
					<td>
						<div class="form-row inline-pd">
							<div class="col-9">
								<div class="form-check form-check-inline">
									<input class="form-check-input dem_fore" type="radio" id="dem_fore_yn1" name="dem_fore_yn" value="Y" ${list.dem_fore_yn == "Y" ? 'checked' : '' } />
									<label class="form-check-label" for="dem_fore_yn1">YES</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input dem_fore" type="radio" id="dem_fore_yn2" name="dem_fore_yn" value="N" ${list.dem_fore_yn == "N" ? 'checked' : '' } />
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
									<input class="form-check-input" type="radio" id="homi_yn1" name="homi_yn" value="Y" ${list.homi_yn == "Y" ? 'checked' : '' } />
									<label class="form-check-label" for="homi_yn1">YES</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" id="homi_yn2" name="homi_yn" value="N" ${list.homi_yn == "N" ? 'checked' : '' } />
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
									<input class="form-check-input" type="radio" id="out_mng_yn1" name="out_mng_yn" value="Y" ${list.out_mng_yn == "Y" ? 'checked' : '' } />
									<label class="form-check-label" for="out_mng_yn1">YES</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" id="out_mng_yn2" name="out_mng_yn" value="N" ${list.out_mng_yn == "N" ? 'checked' : '' } />
									<label class="form-check-label" for="out_mng_yn2">NO</label>
								</div>
							</div>
						</div>
					</td>
					<th class="text-right">교체주기 산출여부</th>
					<td>
						<div class="form-row inline-pd">
							<div class="col-9">
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" id="chg_cycle_yn1" name="chg_cycle_yn" value="Y" ${list.chg_cycle_yn == "Y" ? 'checked' : '' } />
									<label class="form-check-label" for="chg_cycle_yn1">YES</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" id="chg_cycle_yn2" name="chg_cycle_yn" value="N" ${list.chg_cycle_yn == "N" ? 'checked' : '' } />
									<label class="form-check-label" for="chg_cycle_yn2">NO</label>
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
									<input class="form-check-input" type="radio" id="repair_yn1" name="repair_yn" value="Y" ${list.repair_yn == "Y" ? 'checked' : '' } />
									<label class="form-check-label" for="repair_yn1">YES</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" id="repair_yn2" name="repair_yn" value="N" ${list.repair_yn == "N" ? 'checked' : '' } />
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
									<input class="form-check-input" type="radio" id="avg_exchange_cycle_yn1" name="avg_exchange_cycle_yn" value="Y" ${list.avg_exchange_cycle_yn == "Y" ? 'checked' : '' } />
									<label class="form-check-label" for="avg_exchange_cycle_yn1">YES</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" id="avg_exchange_cycle_yn2" name="avg_exchange_cycle_yn" value="N" ${list.avg_exchange_cycle_yn == "N" ? 'checked' : '' } />
									<label class="form-check-label" for="avg_exchange_cycle_yn2">NO</label>
								</div>
							</div>
						</div>
					</td>
					<th class="text-right">주요부품설정</th>
					<td>
						<div class="form-row inline-pd">
							<div class="col-12">
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" id="major_yn1" name="major_yn" value="Y" ${list.major_yn == "Y" ? 'checked' : '' } />
									<label class="form-check-label" for="major_yn1">YES</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" id="major_yn2" name="major_yn" value="N" ${list.major_yn == "N" ? 'checked' : '' } />
									<label class="form-check-label" for="major_yn2">NO</label>
								</div>
								<div class="form-check form-check-inline">
									<input type="checkbox" id="majorAutoYn" name="majorAutoYn" value="${list.major_auto_yn}" ${list.major_auto_yn == 'Y'? 'checked="checked"' : ''}>
									<label for="majorAutoYn">자동반영여부</label>
									<input type="hidden" id="major_auto_yn" name="major_auto_yn" value="${list.major_auto_yn}">
								</div>
							</div>
						</div>
					</td>
                    <th class="text-right">앱 판매 여부</th>
                    <td>
                        <div class="form-row inline-pd">
                            <div class="col-9">
                                <div class="form-check form-check-inline">
                                    <input class="form-check-input" type="radio" id="app_sale_y" name="app_sale_yn" value="Y" ${list.app_sale_yn == "Y" ? 'checked' : '' } />
                                    <label class="form-check-label" for="app_sale_y">YES</label>
                                </div>
                                <div class="form-check form-check-inline">
                                    <input class="form-check-input" type="radio" id="app_sale_n" name="app_sale_yn" value="N" ${list.app_sale_yn == "N" ? 'checked' : '' } />
                                    <label class="form-check-label" for="app_sale_n">NO</label>
                                </div>
                            </div>
                        </div>
                    </td>
				</tr>
				</tbody>
			</table>
			<!-- /하단 폼테이블 -->
			<!-- /폼테이블 -->
			<!-- 호환모델 -->
			<div class="title-wrap mt10">
				<h4>호환모델</h4>
			</div>
			<div class="save-location-wrap" id="machine_div">
				<c:forEach var="item" items="${partMchlist}">
					<c:if test="${item.machine_name ne ''}">
						<div class="save-location" id="${item.machine_plant_seq}">
							<span class="machine_name">${item.machine_name}</span>
							<div class="delete">
								<button type="button" class="btn btn-icon-md text-light" onclick="javascript:fnRemoveStorage('${item.machine_plant_seq}');"><i class="material-iconsclose font-16"></i></button>
							</div>
						</div>
					</c:if>
				</c:forEach>
			</div>
<%--			<ul class="row-list">--%>
<%--				<c:forEach var="item" items="${partMchlist}">--%>
<%--					<li>${item.machine_name}</li>--%>
<%--				</c:forEach>--%>
<%--			</ul>--%>
			<div class="btn-group mt5">
				<div class="left">
					<button type="button" class="btn btn-primary-gra" onclick="javascript:goHistory();">단가이력조회</button>
					<c:if test="${list.homi_yn == 'Y'}">
						<button type="button" class="btn btn-primary-gra" onclick="javascript:fnHomiStock();">HOMI관리</button>
					</c:if>
					<button type="button" class="btn btn-primary-gra" onclick="javascript:fnInoutPartInfo();">입출고내역</button>
					<button type="button" class="btn btn-primary-gra" onclick="javascript:goSearchMachine();">호환모델</button>
				</div>
			</div>
			<!-- /호환모델 -->
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
