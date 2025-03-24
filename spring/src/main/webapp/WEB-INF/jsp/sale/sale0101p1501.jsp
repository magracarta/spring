<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp" /><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt"%><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%><%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 계약관리 > 계약/출하 > null > 계약품의서 간편등록(스탭1 고객등록)
-- 작성자 : 김태훈
-- 최초 작성일 : 2021-04-09 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<script type="text/javascript">

	// 고객 조회 결과
	function fnSetCustInfo(row) {
		isExcust = true;
		$("#btnClear").removeClass("dpn");
		$M.goNextPageAjax("/sale/custInfo/"+row.cust_no, "", {method : 'GET'},
			function(result) {
	    		if(result.success) {
	    			alert("고객을 변경했습니다.");
	    			console.log(result);
	    			$M.setValue(result);
	    			var phone = {
	    				hp_no : $M.phoneFormat(result.hp_no)
	    			}
	    			$M.setValue(phone);
	    			// processDisabled(['cust_name', 'hp_no', 'addr2', 'btnHpDupl', 'btnAddr', 'btnCharge'], true, null, null);
	    			processDisabled(['cust_name', 'hp_no', 'addr2', 'btnHpDupl', 'btnCharge'], true, null, null);

	    			$(".cust_name_view").html($M.getValue("cust_name"));
	    			$(".hp_no_view").html($M.phoneFormat($M.getValue("hp_no")));
	    			$(".machine_name_view").html($M.getValue("machine_name"));
	    			$(".receive_plan_dt_view").html($M.dateFormat($M.getValue("receive_plan_dt"), 'yyyy-MM-dd'));

					// 'YK렌탈장비'인 경우, step05의 장비계약서 및 개인정보동의서 필수 CSS값 해제 - 김경빈
					if (result.cust_no === "20130603145119670") {
						$('#title_mch_contract1').removeClass("rs");
						$('#title_mch_contract2').removeClass("rs");
						$('#title_per_agree_contract').removeClass("rs");
					} else {
						$('#title_mch_contract1').addClass("rs");
						$('#title_mch_contract2').addClass("rs");
						$('#title_per_agree_contract').addClass("rs");
					}
				}
			}
		);
	}
	
	function fnSetClearCustNo() {
		if (confirm("조회한 고객정보를 초기화하시겠습니까?") == false) {
			return false;
		};
		isExcust = false;
		$("#btnClear").addClass("dpn");
		$M.clearValue({field : ['cust_no', 'cust_name', 'hp_no', 'post_no', 'addr1', 'addr2', 'area_si', 'sale_area_code', 'center_org_code', 'center_org_name', 'service_mem_name', 'service_mem_no']});
		// processDisabled(['cust_name', 'hp_no', 'addr2', 'btnHpDupl', 'btnAddr', 'btnCharge'], false, null, null);
		processDisabled(['cust_name', 'hp_no', 'addr2', 'btnHpDupl', 'btnCharge'], false, null, null);
	}
	
	// 핸드폰번호 바꾸면 중복검사하게끔
	function fnHpCheckFalse() {
		isHpCheck = false;
		$("#btnHpDupl").prop("disabled", false);
	}
	
	// 핸드폰번호 중복체크
	function goHpNoCheck() {
		var hp = $M.getValue("hp_no");
		if(hp == "") {
			alert("핸드폰번호를 입력해주세요"); 
			$("#hp_no").focus();
			return;	
		};
		
		var param = {
			"s_hp_no" : $M.getValue("hp_no"),
			"cust_no" : ""	
		};
		
		$M.goNextPageAjax("/cust/cust010201/search", $M.toGetParam(param), {method : "get"},
			function(result) {
	    		if(result.success) {
	    			console.log(result);
	    			if(result.result.hp_no_dup_cnt > 0) {
	    				alert("핸드폰번호가 중복됩니다. 확인하고 다시 시도해주세요.");
	    				isHpCheck = false;
					} else {
						alert("사용 가능한 번호입니다.");
						isHpCheck = true;
		    			$("#btnHpDupl").prop("disabled", true);
					}
				} 
			}
		);
	}
	
	// 주소찾기
	function fnSetAddr(row) {
	    var param = {
	        post_no: row.zipNo,
	        addr1: row.roadAddr,
	        addr2: row.addrDetail
	    };
	    $M.setValue(param);
	}
	
	// 담당자조회 결과
	function setSaleAreaInfo(data) {
		$M.setValue("area_si", data.area_si);
		$M.setValue("sale_area_code", data.sale_area_code);
		$M.setValue("center_org_name", data.center_name);
		$M.setValue("center_org_code", data.center_org_code);
		$M.setValue("service_mem_name", data.servie_mem_name);
		$M.setValue("service_mem_no", data.service_mem_no);
	}
	
	// 모델조회팝업
	function goModelInfoClick() {
		var param = {
			s_price_present_yn : "Y"
		};
		openSearchModelPanel('fnSetModelInfo', 'N', $M.toGetParam(param));
	}
	
	// 모델조회 결과
	function fnSetModelInfo(row) {
		fnInit();
		$M.setValue("machine_name", row.machine_name);
		$M.goNextPageAjax("/machine/supplement/"+row.machine_plant_seq, "", {method : 'GET'},
			function(result) {
	    		if(result.success) {
	    			if (result.basicInfo) {
	    				fnSetData(result);	
	    				alert("모델을 변경했습니다.");
	    			 } else {
	    				$M.setValue("machine_name", "");
	    				alert("이 모델에 대한 가격정보가 없습니다.\n관리자에게 문의하거나 다른 장비를 선택하세요.");
	    				return false;
	    			 }
				}
			}
		);
	}
	
	// 모델에 해당하는 부가정보 세팅
	function fnSetData(result) {
		 if (result.basicInfo) {
			 $M.setValue(result.basicInfo);
		 } 
		 
		 // 조회 시, 정상판매가(sale_price) = 최종판매금액(sale_amt) default
		 // 부가정보 조작 시, 최종판매금액을 수정함.
		 $M.setValue("sale_amt", result.basicInfo.sale_price);
		 fnChangePrice();
		 
		 // YN
		 fnMakeYn(result.basicInfo);
		 
		 // 선택사항
		 optList = result.optionList;
		 console.log(optList);
		 var optCodeDom = $("#opt_code");
		 optCodeDom.html("");
		 AUIGrid.setGridData("#auiGridOption", []);
		 if (optList) {
			 if (optList.length > 0) {
				 optCodeDom.css("display", "inline-block");
				 var selectedOptCode = result.basicInfo.selected_opt_code;
				 var selectedOptCodeIdx = 0;
				 for (var i = 0; i < optList.length; ++i) {
					 optCodeDom.append("<option value='"+optList[i].opt_code+"'>"+optList[i].opt_name+"</option>");
	   				 if (optList[i].opt_code == selectedOptCode) {
	   					 selectedOptCodeIdx = i;
	   				 }
	   			 }
				 if (selectedOptCode != null) {
					 $M.setValue("opt_code", selectedOptCode);				 
				 } else {
					 $M.setValue("opt_code", optList[0].opt_code);
				 }
				 AUIGrid.setGridData("#auiGridOption", optList[0].list);
			 } else {
				 optCodeDom.css("display", "none");
			 }
		 } else {
			 optCodeDom.css("display", "none");
		 }
		// 어테치먼트
		if (result.attachList) {
			 AUIGrid.setGridData("#auiGridAttach", result.attachList);
		 }
		
		 // 기본지급품내역
		 AUIGrid.setGridData("#auiGridBasic", result.basicInfo.basicItemList);
		 var basicItemListDom = $("#basicItemList");
		 basicItemListDom.css("display", "flex");
		 basicItemListDom.html("");
		 var basicDtlBtnDom = $("#basicDtlBtn");
		 basicDtlBtnDom.css("display", "none");
		 if (result.basicInfo.basicItemList) {
			 for (var i = 0; i < result.basicInfo.basicItemList.length; ++i) {
				 basicItemListDom.append("<span>"+result.basicInfo.basicItemList[i].basic_item_name+"</span>");
			 }
			 if (result.basicInfo.basicItemList.length > 0) {
				 basicDtlBtnDom.css("display", "inline-block");
			 } 
		 } 
		 AUIGrid.setGridData("#auiGridPartFree", result.freeList != null ? result.freeList.sort($M.sortMulti("-free_add_qty")) : []);
		 AUIGrid.setGridData("#auiGridPart", result.paidList != null ? result.paidList : []);
		 AUIGrid.setGridData("#auiGridOppCost", result.oppCostList != null ? result.oppCostList : []);
	}
	
	// YN세팅
	function fnMakeYn(info) {
		fnHideYn("diYn"); fnHideYn("capYn"); fnHideYn("sarYn"); fnHideYn("proxyYn"); fnHideYn("capFileYn"); fnHideYn("sarFileYn");
		var isDiExist = info.center_di_yn_info == "Y" ? fnShowYn("diYn") : fnHideYn("diYn");
		var isCapExist = info.cap_yn_info == "Y" ? fnShowYn("capYn") : fnHideYn("capYn");
		var isSarExist = info.sar_yn_info == "Y" ? fnShowYn("sarYn") : fnHideYn("sarYn");
		fnShowYn("proxyYn");
		var tempArr = [isDiExist, isSarExist, isCapExist];
		var yCnt = tempArr.filter(Boolean).length;
		var yCntDom = $("#yCnt");
		if (yCnt != 3) {
			if (yCnt == 0) {
				yCnt = 1;
			}
			var percent = yCnt*33;
			if (percent < 50) {
				percent = 50;
			}
			yCntDom.css("width", (percent)+"%");
		} else {
			yCntDom.css("width", "100%");
		}
	}
	
	function fnHideYn(type) {
		$("."+type).hide();
		return false;
	}
	
	function fnShowYn(type) {
		$("."+type).show();
		return true;
	}
	
	// 출하희망일 세팅 시, VAT 입금예정일을 출하희망일로 세팅
	function fnSetReceivePlan() {
		$M.setValue("plan_dt_6", $M.getValue("receive_plan_dt"));
	}
	
	// 초기화
	function fnInit() {
		var param = {
			sale_price : "0", 
			part_free_amt : "0",
			discount_amt : "0",
			agency_price : "0",
			part_cost_amt : "0",
			part_free_amt : "0",
			attach_amt : "0",
			total_vat_amt : "0",
			sale_amt : "0",
			balance : "0",
			write_price : "",
			review_price : "",
			agree_price : "",
			max_dc_price : "",
			fee_price : "",
			discount_amt : "",
			pay_complete_yn : "N",
			total_amt : "",
			center_di_yn_check : "",
			center_di_yn : "",
			cap_yn_check : "",
			cap_yn : "",
			sar_yn_check : "",
			sar_yn : "",
			assist_yn : "",
			machine_name_temp : "",
			reg_proxy_yn : "",
			reg_proxy_yn_check : "",
			reg_proxy_amt : ""
		}
		$M.clearValue();
		// 선택사항 그리드 초기화
		AUIGrid.setGridData(auiGridOption, []);
		// 어테치먼트 그리드 초기화
		AUIGrid.setGridData(auiGridAttach, []);
		// 기본제공품 그리드 초기화
		AUIGrid.setGridData(auiGridBasic, []);
		// 유상그리드 초기화
		AUIGrid.setGridData(auiGridPart, []);
		// 무상그리드 초기화
        AUIGrid.setGridData(auiGridPartFree, []);
		$M.setValue(param);
	}
	
	// 업무DB 연결 함수 21-08-06이강원
 	function openWorkDB(){
 		openWorkDBPanel('',$M.getValue("machine_plant_seq"));
 	}
</script>
<div class="step-title">
	<span class="step-num">step01</span> <span class="step-title">고객등록</span>
</div>
<ul class="step-info">
	<li>기존 등록된 고객은 <b style="color: deepskyblue;">기존고객조회</b>를 하신 후 진행하시기 바랍니다.</li>
	<li>신규고객이면 화면 하단의 필수정보를 입력하신 후 &lt;다음&gt;버튼은 클릭하세요!</li>
</ul>
<!-- 폼테이블 -->
<table class="table-border">
	<colgroup>
		<col width="17%">
		<col width="">
		<col width="17%">
		<col width="">
	</colgroup>
	<tbody>
		<tr>
			<th class="text-right rs">고객명</th>
			<td colspan="3">
				<div class="form-row inline-pd">
					<div class="icon-btn-cancel-wrap" style="width : calc(150px - 24px); padding-left: 5px;">
						<input type="text" class="form-control rb" placeholder="고객명" id="cust_name" name="cust_name" alt="고객명">
						<button type="button" class="icon-btn-cancel dpn" style="top: 50%;transform: translateY(-50%); margin-top: -1px;" onclick="fnSetClearCustNo()" id="btnClear"><i class="material-iconsclose font-16 text-default"></i></button>
					</div>
					<div class="col-auto" style="padding-left: 5px;">
						<button type="button" class="btn btn-primary-gra" onclick="javascript:openSearchCustPanel('fnSetCustInfo', 'machineDocYn=Y')">기존고객조회</button>
					</div>
				</div>
			</td>
		</tr>
		<tr>
			<th class="text-right rs">휴대폰</th>
			<td colspan="3">
				<div class="form-row inline-pd">
					<div class="col width110px">
						<input type="text" class="form-control rb" placeholder="-없이 숫자만 입력" id="hp_no" name="hp_no" format="phone" required="required" alt="휴대폰" onchange="javascript:fnHpCheckFalse()">
					</div>
					<div class="col-auto">
						<button type="button" class="btn btn-primary-gra" id="btnHpDupl" onclick="javascript:goHpNoCheck()">중복확인</button>
					</div>
				</div>
			</td>
		</tr>
		<tr>
			<!-- [14466] 주소 필수값 해제 -->
			<th class="text-right">주소</th>
			<td colspan="3">
				<div class="form-row inline-pd mb7 widthfix">
					<div class="col width80px">
						<input type="text" class="form-control" disabled="disabled" id="post_no" name="post_no" alt="주소">
					</div>
					<div class="col-auto">
						<button type="button" class="btn btn-primary-gra" id="btnAddr" onclick="javascript:openSearchAddrPanel('fnSetAddr');">주소찾기</button>
					</div>
				</div>
				<div class="form-row inline-pd mb7 widthfix">
					<div class="col width400px">
						<input type="text" class="form-control" disabled="disabled" id="addr1" name="addr1">
					</div>
				</div>
				<div class="form-row inline-pd widthfix">
					<div class="col width400px">
						<input type="text" class="form-control" id="addr2" name="addr2">
					</div>
				</div>
			</td>
		</tr>
		<tr>
			<th class="text-right rs">고객담당</th>
			<td colspan="3">
				<div class="form-row inline-pd widthfix">
					<div class="col width33px">지역</div>
					<div class="col width100px">
						<div class="input-group widthfix">
							<input type="text" class="form-control border-right-0" readonly="readonly" id="area_si" name="area_si" alt="담당지역">
							<button type="button" class="btn btn-icon btn-primary-gra" id="btnCharge" onclick="javascript:openSearchSaleAreaPanel('setSaleAreaInfo');"><i class="material-iconssearch"></i></button>
						</div>
					</div>

					<div class="col width70px pl15">담당센터</div>
					<div class="col width100px">
						<input type="text" class="form-control" readonly="readonly" id="center_org_name" name="center_org_name">
					</div>
					<div class="col width80px pl15">서비스담당</div>
					<div class="col width100px">
						<input type="text" class="form-control" readonly="readonly" id="service_mem_name" name="service_mem_name">
					</div>
				</div>
			</td>
		</tr>
		<tr>
			<th class="text-right rs">모델명</th>
			<td colspan="3">
				<div class="form-row inline-pd pr">
					<div class="col-auto">
						<div class="input-group widthfix">
							<input type="text" class="form-control border-right-0 width100px" id="machine_name" name="machine_name" alt="모델명" readonly="readonly">
							<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goModelInfoClick();">
								<i class="material-iconssearch"></i>
							</button>
						</div>
					</div>
					<div class="col-auto">
						<c:if test="${page.fnc.F02050_001 eq 'Y'}">
                        	<button type="button" class="btn btn-primary-gra" onclick="javascript:openWorkDB();">업무DB</button>
                        </c:if>
		            </div>
				</div>
			</td>
		</tr>
		<tr>
			<th class="text-right rs">출하희망일</th>
			<td>
				<div class="input-group widthfix">
					<input type="text" class="form-control border-right-0 width100px calDate" id="receive_plan_dt" name="receive_plan_dt" alt="출하희망일" dateformat="yyyy-MM-dd" onchange="fnSetReceivePlan()">
				</div>
			</td>
			<th class="text-right rs">장비계약</th>
			<td>
				<div class="form-check form-check-inline">
					<input class="form-check-input" type="radio" id="mch_type_c" name="mch_type_cad" value="C" alt="장비계약">
					<label for="mch_type_c" class="form-check-label">건설기계</label>
				</div>
				<div class="form-check form-check-inline">
					<input class="form-check-input" type="radio" id="mch_type_a" name="mch_type_cad" value="A" alt="장비계약">
					<label for="mch_type_a" class="form-check-label">농기계</label>
				</div>
			</td>
		</tr>
	</tbody>
</table>
<!-- /폼테이블 -->
<!-- 그리드 서머리, 컨트롤 영역 -->
<div class="btn-group mt10">
	<div class="right">
		<button type="button" class="btn btn-md btn-info" style="width: 50px;" onclick="javascript:fnCompleteStep(1)">다음</button>
	</div>
</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
