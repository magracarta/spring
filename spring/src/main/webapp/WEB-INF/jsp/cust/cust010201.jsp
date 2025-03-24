<%@ page contentType="text/html;charset=utf-8" language="java"%><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객
-- 작성자 : 강명지
-- 최초 작성일 : 2020-01-20 13:01:58
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
</head>
<!-- script -->
<script type="text/javascript">

	$(document).ready(function() {
		fnInit();
	});

	function fnInit() {
		var mngYn = "${mngYn}";	// 관리부서만 노출
		if(mngYn == "Y") {
			$(".mng-show-yn").removeClass("dpn");
		}

		// 지정(중고)딜러여부 수정 권한자만 활성화
		if(${page.fnc.F00063_001 ne 'Y'}) {
			$(".dealerYn").prop("disabled", true);
		}

		// 주요관리업체여부 수정 권한자만 활성화
		if(${page.fnc.F00063_002 ne 'Y'}) {
			$(".mainMngYn").prop("disabled", true);
		}
	}
	function fnSetBregInfo(data) {
		$M.goNextPageAjax(this_page + "/breg/dupCheck", $M.toGetParam(data), {method : 'get'},
				function(result) {
					if(result.success) {
						var dupInfo = result.dup_info;
						// 사업자번호 중복시 메세지 노출 (저장가능)
						if(dupInfo.rep_dup_cnt > 0) {
							var msg = "\'" + dupInfo.rep_breg_name + "\' 사업자는 이미 " + dupInfo.rep_dup_cust_name + " 고객의 대표사업자로 등록되어있습니다. 마케팅관리에 문의하세요.";
							alert(msg);
						}
						if(dupInfo.dup_cnt > 0) {
							var msg = "\'" + dupInfo.breg_name + "\' 사업자는 이미 " + dupInfo.dup_cust_name + " 고객의 사업자로 등록되어있습니다. 마케팅관리에 문의하세요.";
							alert(msg);
						}
						$M.setValue("breg_no", data.breg_no);
						$M.setValue("breg_rep_name", data.breg_rep_name);
						$M.setValue("breg_name", data.breg_name);
						$M.setValue("breg_seq", data.breg_seq);
					}
				}
		);
	}

	function fnSwitchSMS(param) {
		if(param == 'on') {
			$("#sms_cancel").attr('disabled', true);
			$("#sms_send").attr('disabled', false);
			$M.setValue("sms_send_yn", "N");
		} else {
			$("#sms_cancel").attr('disabled', false);
			$("#sms_send").attr('disabled', true);
			$M.setValue("sms_send_yn", "Y");
		}
	}

	// 목록으로 돌아가기
	function fnList() {
		window.history.back();
	}

	function fnClose() {
		window.close();
	}

	// 직원조회 결과
	function fnSetMemberInfo(data) {
		$M.setValue("misu_mem_name", data.mem_name);
		$M.setValue("misu_mem_no", data.mem_no);
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

	function goSave() {
		fnYnCheck();
		var frm = document.main_form;
		if($M.validation(frm) == false) {
			return;
		}
		if($M.getValue("hpDuplicCheck") == "N") {
			alert("휴대폰 중복체크를 진행해주세요");
			return;
		}
		if($M.getValue("app_cor_auth_yn") == "Y" && $M.getValue("corHpDuplicCheck") == "N") {
			alert("고객앱 법인휴대폰 중복체크를 진행해주세요");
			return false;
		}


		// if($M.getValue("mng_hp_no") != "" && $M.getValue("hpManagerCheck") == "N") {
		// 	alert("휴대폰(정비관리자) 중복체크를 진행해주세요.");
		// 	return;
		// }
		//
		// if($M.getValue("driver_hp_no") != "" && $M.getValue("hpDriverCheck") == "N") {
		// 	alert("휴대폰(장비운영자) 중복체크를 진행해주세요.");
		// 	return;
		// }

		if(fnCheckPrivacy("marketing") == false) {
			return false;
		}
		if(fnCheckPrivacy("personal") == false) {
			return false;
		}
		if(fnCheckPrivacy("three") == false) {
			return false;
		}

		$M.setValue("sales_maker_cd_str", $M.getValue("sales_maker_cd"))
		$M.setValue("cust_maker_cd_str", $M.getValue("cust_maker_cd"))

		$M.goNextPageAjaxSave(this_page+'/save', $M.toValueForm(frm) , {method : 'POST'},
				function(result) {
					if(result.success) {
						if (${inputParam.s_popup_yn eq 'Y'}){
							window.close();
						} else {
							$M.goNextPage("/cust/cust0102");
						}
					}
				}
		);
	}

	function fnCheckPrivacy(param) {
		// if(param == "marketing") {
		// 	var marketingCheckYn = $("input:checkbox[name='marketing_check']").is(":checked");
		// 	var marketingYn = $("input:checkbox[name='marketingYn']").is(":checked");
		// 	if(marketingCheckYn) {
		// 		if(marketingYn == false) {
		// 			alert("마케팅 활용동의를 체크해주세요.");
		// 			return false;
		// 		}
		// 	}
		// }
		var privacyYn = $("input:checkbox[name='"+param+"Yn']").is(":checked");
		if(privacyYn) {
			if($M.getValue(param+"_dt") == "") {
				alert("확인일자를 확인해주세요.");
				return false;
			}
			if($M.getValue(param+"_mem_name") == "") {
				alert("확인자를 확인해주세요.");
				return false;
			}
			if($M.getValue(param+"_collect_cd") == "") {
				alert("수집구분을 선택해주세요.");
				return false;
			}
		} else {
			$M.setValue(param+"_yn", "N");
			$M.setValue(param+"_dt", "");
			$M.setValue(param+"_mem_name", "");
			$M.setValue(param+"_mem_no", '');
			$M.setValue(param+"_collect_cd", "");
		}
	}

	function fnJusoBiz(data) {
		$M.setValue("post_no", data.zipNo);
		$M.setValue("addr1", data.roadAddrPart1);
		$M.setValue("addr2", data.addrDetail);
		$M.setValue("addr_kor1", data.roadAddrPart1);
		$M.setValue("addr_kor2", data.addrDetail);
		$M.setValue("addr_eng1", data.engAddr);
		var str = $M.getValue("addr2");
		var res = '';
		if(str.indexOf("호") > -1 && str.indexOf("동") > -1) {
			res = str.replace("호", "-ho");
			res = res.replace("동", "-dong");
			$M.setValue("addr_eng2", res);
		} else if(str.indexOf("호") > -1) {
			res = str.replace("호", "-ho");
			$M.setValue("addr_eng2", res);
		} else {
			$M.setValue("addr_eng2", str);
		}

		var param = {
			"addr1": $M.getValue("addr1")
		}
		// 고객담당 세팅
		$M.goNextPageAjax(this_page + "/search/saleArea", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						var data = result.info;
						data.center_name = data.center_org_name;
						data.servie_mem_name = data.service_mem_name;
						setSaleAreaInfo(data);
					}
				}
		);
	}

	function fnJusoCurr(data) {
		$M.setValue("curr_post_no", data.zipNo);
		$M.setValue("curr_addr1", data.roadAddrPart1);
		$M.setValue("curr_addr2", data.addrDetail);
	}

	function fnShowEnLocation() {
		var btnValue = document.querySelector('#btnAddrChanger').innerHTML;
		if(btnValue == '영문주소보기') {
			$M.setValue("addr_kor1", $M.getValue("addr_eng1"));
			$M.setValue("addr_kor2", $M.getValue("addr_eng2"));
			document.querySelector('#btnAddrChanger').innerHTML = '한글주소보기';
		} else {
			$M.setValue("addr_kor1", $M.getValue("addr1"));
			$M.setValue("addr_kor2", $M.getValue("addr2"));
			document.querySelector('#btnAddrChanger').innerHTML = '영문주소보기';
		}
	}

	// 관리번호 팝업
	function goControlNoPopup(){
		var param = {
			"cust_no" : ""
		}
		var popupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=400, height=450, left=0, top=0";
		$M.goNextPage('/cust/cust0102p02', $M.toGetParam(param), {popupStatus : popupOption});
	}

	// 준회원 인증 팝업
	function goMemberAuthPopup(execFuncName) {
		if($M.getValue("hpDuplicCheck") != "Y") {
			alert("휴대폰 중복체크 후 다시 시도해주세요.");
			return false;
		}
		var param = {
			hp_no : $M.getValue("hp_no"),
			cust_no : "",
			parent_js_name : execFuncName
		};
		var popupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=600, height=260, left=0, top=0";
		$M.goNextPage('/cust/cust0102p03', $M.toGetParam(param), {popupStatus : popupOption});
	}


	function fnPersonalChange(param) {
		var personalYn = $("input:checkbox[name='"+param+"Yn']").is(":checked");
		if(personalYn) {
			$M.setValue(param+"_yn", "Y");
			$M.setValue(param+"_dt", $M.getCurrentDate());
			$M.setValue(param+"_mem_name", '${SecureUser.user_name }');
			$M.setValue(param+"_mem_no", '${SecureUser.mem_no }');
			$M.setValue(param+"_collect_cd", '1');
		} else {
			$M.setValue(param+"_yn", "N");
			$M.setValue(param+"_dt", "");
			$M.setValue(param+"_mem_name", "");
			$M.setValue(param+"_mem_no", '');
			$M.setValue(param+"_collect_cd", '');
		}
	}

	function fnSelectToggle(param) {
		if(param == "sale") {
			$("#cd_for_sales").toggleClass("dpn");
		} else {
			$("#cd_for_owns").toggleClass("dpn");
		}
	}

	function setHpAssociate(data) {
		$("#memberAuth").attr('disabled', true);
		$M.setValue("hp_no", data);
		$("#hpDuplic").attr('disabled', true);
		$M.setValue("hpDuplicCheck", "Y");
		$M.setValue("auth_check_yn", "Y");

		// 2023-03-10 직원앱 erp적용 jsk
		// $M.setValue("cust_type_cd", "02");
		// $("#custTypeName").html("준회원");
		// $M.setValue("cust_type_name", "준회원");
	}

	// 장비소유자 핸드폰 인증
	function goHpDuplCheck(succsessMsgYn) {
		if($M.validation(null, {field:["hp_no"]}) == false) {
			return false;
		}

		var param = {
			"s_hp_no" : $M.getValue("hp_no"),
			"cust_no" : ""
		};

		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						var response = result.result;

						var check = false;
						var msg = "[휴대폰 번호 중복]\n";

						if(response.all_cnt > 0) {
							// 장비소유자 중복 됨
							if(response.hp_no_dup_cnt > 0) {
								msg += "⁎ 소유자 번호가 중복되면 [고객 등록이 불가능] 합니다.\n\n" +
										"소유자 번호 중복 고객명 : " + response.hp_no_dup_name;
								alert(msg);

								check = false;
							} else {
								msg += "* " + $M.getValue("cust_name") + " 장비소유자님은 다른 회원정보에 장비관리자/장비운영자로 중복등록이 되어있으니 수정하시기 바랍니다.\n\n";

								// 장비관리자 중복 됨
								if(response.mng_hp_no_dup_cnt > 0) {
									msg += "장비관리자 중복 고객명 : " + response.mng_hp_no_dup_name + "\n";
								}

								// 장비운영자 중복 됨
								if(response.driver_hp_no_dup_cnt > 0) {
									msg += "장비운영자 중복 고객명 : " + response.driver_hp_no_dup_name + "\n";
								}

								alert(msg);

								check = false;
							}
						} else {
							if (succsessMsgYn != 'N') {
								alert("사용 가능한 번호입니다.");
							}
							check = true;
						}

						if(check){
							$("#hpDuplic").attr('disabled', true);
							$M.setValue("hpDuplicCheck", "Y");
						}
						return check;
					}
				}
		);
	}

	function fnSendMail() {
		var param = {
			'to' : $M.getValue('email')
		};
		openSendEmailPanel($M.toGetParam(param));
	}

	function setSendSMSInfo(data) {
		alert(data);
	}

	function fnYnCheck() {
		if($M.getValue("cust_type_cd") == '') {
			$M.setValue("cust_type_cd", "01");
			$M.setValue("cust_type_name", "일반회원");
		}
		var ynCheck = ['misu_print', 'tel', 'sms', 'email', 'dm']
		for (i=0; i<ynCheck.length; i++) {
			var check = $("input:checkbox[id='"+ynCheck[i]+"']").is(":checked");
			if(check) {
				$M.setValue(ynCheck[i]+"_yn", "Y");
			} else {
				$M.setValue(ynCheck[i]+"_yn", "N");
			}
		}
	}


	function fnOpenSmsPanel(param) {
		var custName = $M.getValue('cust_name');
		var phone = '';
		if(param == 'sms') {			// 장비소유자
			phone = $M.getValue('hp_no');
		} else if(param == 'manager') {	// 장비관리자
			phone = $M.getValue('mng_hp_no');
		} else if(param == 'admin') {	// 장비운영자
			phone = $M.getValue('driver_hp_no');
		} else if (param == 'cor') {	// 법인폰
			phone = $M.getValue('cor_hp_no');
	  }

		var params = {
			name : custName,
			hp_no : phone
		}
		openSendSmsPanel($M.toGetParam(params));
	}

	// 사업자정보조회 팝업
	function fnSearchBregInfo() {
		var param = {
		};
		openSearchBregInfoPanel('fnSetBregInfo', $M.toGetParam(param));
	}

	// 핸드폰 번호 입력 시
	function fnHpStatus() {
		$("#hpDuplic").prop("disabled", false);
		$("#memberAuth").attr('disabled', false);
		$M.setValue("hpDuplicCheck", "N");
		$M.setValue("auth_check_yn", "N");
	}

	function fnSetAppCorAuth() {
		var authYn = $("input:checkbox[name='appCorAuthYn']").is(":checked");
		if (authYn) {
			$("#cor_hp_no").attr("disabled", false);
			$("#corHpDuplic").attr("disabled", false);
			$M.setValue("cor_hp_no", $M.getValue("hp_no"));
			$M.setValue("app_cor_auth_yn", "Y");
			$M.setValue("corHpDuplicCheck", "N");
			$("#cor_hp_no").focus();
		} else {
			$("#cor_hp_no").attr("disabled", true);
			$("#corHpDuplic").attr("disabled", true);
			$M.setValue("cor_hp_no", "");
			$M.setValue("app_cor_auth_yn", "N");
			$M.setValue("corHpDuplicCheck", "Y");
		}
	}

	function fnCorHpDuplCheck() {
		if($M.getValue("cor_hp_no") != '${result.cor_hp_No}') {
			$("#corHpDuplic").attr("disabled", false);
			$M.setValue("corHpDuplicCheck", "N");
		}
	}

	function goCorHpDuplCheck() {
		if ($M.getValue("cor_hp_no") == '') {
			alert("법인 휴대폰번호를 입력해주세요.");
			return false;
		}
		var param = {
			"cor_hp_no" : $M.getValue("cor_hp_no")
		}
		$M.goNextPageAjax(this_page + "/corHp/dupCheck", $M.toGetParam(param), {method : 'get'},
			function(result) {
				if(result.success) {
					var dupInfo = result.dup_info;
					var check = false;
					var msg = "";

					if(dupInfo.apply_cnt > 0) {
						msg = "'"+ dupInfo.apply_cust_name + "' 앱고객님이 이미 가입한 번호입니다.\n관리자에게 문의해주세요.";
					} else if(dupInfo.auth_cnt > 0) {
						msg = "'"+ dupInfo.auth_cust_name + "' 고객님이 본인인증한 이력이 있는 번호입니다.\n관리자에게 문의해주세요.";
					} else if(dupInfo.dup_cnt > 0) {
						msg = "'"+ dupInfo.dup_cust_name + "' 고객님이 이미 사용중인 법인휴대폰 번호입니다.\n관리자에게 문의해주세요.";
					} else {
						msg = "사용가능한 법인휴대폰 번호입니다.";
						check = true;
					}
					alert(msg);

					if(check){
						$("#corHpDuplic").attr('disabled', true);
						$M.setValue("corHpDuplicCheck", "Y");
					}
				}
			}
		);
	}
</script>
<body>
<!-- /script -->
<!-- content-wrap -->
<form id="main_form" name="main_form">
	<input type="hidden" id="auth_check_yn" name="auth_check_yn">
	<input type="hidden" id="cust_maker_cd_str" name="cust_maker_cd_str">
	<input type="hidden" id="sales_maker_cd_str" name="sales_maker_cd_str">
	<div class="content-wrap">
		<div class="content-box">
			<!-- 상세페이지 타이틀 -->
			<div class="main-title detail">
				<div class="detail-left">
					<c:if test="${inputParam.s_popup_yn ne 'Y'}">
						<button type="button" class="btn btn-outline-light" onclick="fnList()"><i class="material-iconskeyboard_backspace text-default"></i></button>
					</c:if>
					<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
				</div>
			</div>
			<!-- /상세페이지 타이틀 -->
			<div class="contents">
				<!-- 폼테이블 -->
				<div>
					<table class="table-border">
						<colgroup>
							<col width="120px">
							<col width="310px">
							<col width="120px">
							<col width="310px">
							<col width="120px">
							<col width="210px">
							<col width="120px">
							<col width="">
						</colgroup>
						<tbody>
						<tr>
							<th class="text-right essential-item">고객명</th> <!-- 필수항목일때 클래스 essential-item 추가 -->
							<td>
								<input type="text" class="form-control essential-bg" placeholder="반드시 사람이름 입력" maxlength="10" id="cust_name" name="cust_name" required="required" alt="고객명" value="${empty inputParam.cust_name? '' : inputParam.cust_name}"> <!-- 필수항목일때 클래스 essential-bg 추가 -->
							</td>
							<th class="text-right">고객번호</th>
							<td>
								<input type="text" class="form-control" readonly="readonly" id="cust_no" name="cust_no" value="">
							</td>
							<th class="text-right essential-item">고객분류</th> <!-- 필수항목일때 클래스 essential-item 추가 -->
							<td>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" id="cust_class_p" name="cust_class_pc" value="P" alt="고객분류" required="required" checked="checked">
									<label class="form-check-label">개인</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" id="cust_class_c" name="cust_class_pc" value="C" alt="고객분류" required="required">
									<label class="form-check-label">법인</label>
								</div>
							</td>
							<th class="text-right">고객등급(자동)</th>
							<td>
								<div class="form-row inline-pd pr">
									<div class="col-auto">
										<input class="form-control" style="width: 99%;" type="text" id="cust_grade_cd" name="cust_grade_cd" easyui="combogrid"
											   easyuiname="custGradeList" panelwidth="250" idfield="code_value" textfield="code_name" multi="Y"
											   <c:if test="${gradeModifyYn ne 'Y'}">disabled</c:if>/>
									</div>
									<div class="col-auto">
										<input type="checkbox" id="custGradeAutoYn" name="custGradeAutoYn" checked="checked" <c:if test="${gradeModifyYn ne 'Y'}">disabled</c:if>>
										<label for="custGradeAutoYn">등급자동반영</label>
										<input type="hidden" id="cust_grade_auto_yn" name="cust_grade_auto_yn">
									</div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">사업자번호</th>
							<td>
								<div class="input-group">
									<input type="text" class="form-control border-right-0" maxlength="13" minlength="10" id="breg_no" name="breg_no" alt="사업자번호" readonly="readonly">
									<input type="hidden" id="breg_seq" name="breg_seq">
									<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSearchBregInfo();"><i class="material-iconssearch"></i></button>
								</div>
							</td>
							<th class="text-right">업체명</th>
							<td>
								<input type="text" class="form-control" placeholder="업체명" id="breg_name" name="breg_name" readonly="readonly" alt="업체명">
							</td>
							<th class="text-right">회원구분</th> <!-- 필수항목일때 클래스 essential-item 추가 -->
							<td>
								<div class="form-row inline-pd">
									<div class="col-auto" id="custTypeName" name="custTypeName">일반회원</div>
									<input type="hidden" id="cust_type_name" name="cust_type_name" alt="회원구분">
									<input type="hidden" id="cust_type_cd" name="cust_type_cd" >
									<div class="col-auto"><button type="button" class="btn btn-primary-gra btn-cancel" id="memberAuth" name="memberAuth" onclick="javascript:goMemberAuthPopup('setHpAssociate');">본인인증</button></div>
								</div>
							</td>
							<th class="text-right">고객등급(수동)</th>
							<td>
								<input class="form-control" style="width: 99%;" type="text" id="cust_grade_hand_cd" name="cust_grade_hand_cd" easyui="combogrid"
									   easyuiname="custGradeHandList" panelwidth="250" idfield="code_value" textfield="code_name" multi="Y"/>
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">휴대폰(장비소유자)</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-auto">
										<div class="input-group">
											<input type="text" id="hp_no" name="hp_no"  maxlength="11" minlength="10" alt="휴대폰(장비소유자)" onkeyup="fnHpStatus();" class="form-control border-right-0 essential-bg"
												   placeholder="숫자만 입력" format="phone" required="required" value="${empty inputParam.hp_no? '' : inputParam.hp_no}">
											<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnOpenSmsPanel('sms');"><i class="material-iconsforum"></i></button>
										</div>
									</div>
									<div class="col-auto">
										<button type="button" class="btn btn-primary-gra btn-cancel" id="hpDuplic" name="hpDuplic" onclick="javascript:goHpDuplCheck('Y');">중복체크</button>
										<input type="hidden" id="hpDuplicCheck" name="hpDuplicCheck" value="N" required="required"/>
									</div>
								</div>
							</td>
							<th class="text-right">대표자</th>
							<td>
								<input type="text" class="form-control" placeholder="대표자" id="breg_rep_name" name="breg_rep_name" readonly="readonly" alt="대표자">
							</td>
							<th class="text-right">지입사명</th>
							<td>
								<input type="text" class="form-control" id="artic_name" name="artic_name">
							</td>
							<th class="text-right">지입사연락처</th>
							<td>
								<input type="text" class="form-control" placeholder="하이픈(-) 포함" id="artic_tel_no" name="artic_tel_no">
							</td>
						</tr>
						<tr>
							<th class="text-right">휴대폰(장비관리자)</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-7">
										<div class="input-group">
											<input type="text" class="form-control border-right-0" alt="휴대폰(장비관리자)" placeholder="숫자만 입력" id="mng_hp_no" name="mng_hp_no" format="phone">
											<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnOpenSmsPanel('manager');"><i class="material-iconsforum"></i></button>
										</div>
									</div>
									<%--										 	[3차 - 14444] 재협의 후 기능 수정으로 인한 삭제 처리 --%>
									<%--											<div class="col-5">--%>
									<%--												<button type="button" class="btn btn-primary-gra btn-cancel" id="hpManager" name="hpManager" onclick="javascript:goHpDuplCheck('manager');">중복체크</button>--%>
									<%--												<input type="hidden" id="hpManagerCheck" name="hpManagerCheck" value="N" required="required"/>--%>
									<%--											</div>--%>
									<div class="col-5">
										<input type="text" class="form-control ml5" placeholder="간단메모" id="mng_memo" name="mng_memo">
									</div>
								</div>
							</td>
							<th class="text-right">생년월일</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-6">
										<div class="input-group">
											<input type="text" class="form-control border-right-0 calDate" dateFormat="yyyy-MM-dd" id="birth_dt" name="birth_dt" value="${empty inputParam.birth_dt? '' : inputParam.birth_dt}">
										</div>
									</div>
									<div class="col-6">
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" id="solar_cal_y" name="solar_cal_yn"
											<c:if test="${empty inputParam.solar_cal_yn or inputParam.solar_cal_yn eq 'Y'}"> checked</c:if> value="Y" >
											<label class="form-check-label">양력</label>
										</div>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" id="solar_cal_n" name="solar_cal_yn"
											<c:if test="${not empty inputParam.solar_cal_yn and inputParam.solar_cal_yn eq 'N'}" > checked value="N"</c:if>>
											<label class="form-check-label">음력</label>
										</div>
									</div>
								</div>
							</td>
							<th rowspan="4" class="text-right">메모</th>
							<td colspan="3" rowspan="4">
								<textarea class="form-control" style="height: 100px;" id="remark" name="remark">${result.remark}</textarea>
							</td>
						</tr>
						<tr>
							<th class="text-right">휴대폰(장비운영자)</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-7">
										<div class="input-group">
											<input type="text" class="form-control border-right-0" alt="휴대폰(장비운영자)" placeholder="숫자만 입력" id="driver_hp_no" name="driver_hp_no" format="phone">
											<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnOpenSmsPanel('admin');"><i class="material-iconsforum"></i></button>
										</div>
									</div>
									<%--											[3차 - 14444] 재협의 후 기능 수정으로 인한 삭제 처리 --%>
									<%--											<div class="col-5">--%>
									<%--												<button type="button" class="btn btn-primary-gra btn-cancel" id="hpDriver" name="hpDriver" onclick="javascript:goHpDuplCheck('driver');">중복체크</button>--%>
									<%--												<input type="hidden" id="hpDriverCheck" name="hpDriverCheck" value="N" required="required"/>--%>
									<%--
                                                                        </div>--%>
									<div class="col-5">
										<input type="text" class="form-control ml5" placeholder="간단메모" id="driver_memo" name="driver_memo">
									</div>
								</div>
							</td>
							<th class="text-right">이메일</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-10">
										<input type="text" class="form-control" id="email" name="email" format="email" value="${empty inputParam.email? '' : inputParam.email}">
									</div>
									<div class="col-2">
										<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSendMail();"><i class="material-iconsmail"></i></button>
									</div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">전화</th>
							<td>
								<input type="text" class="form-control" placeholder="하이픈(-) 포함" id="tel_no" name="tel_no">
							</td>
							<th class="text-right">팩스</th>
							<td>
								<input type="text" class="form-control" placeholder="하이픈(-) 포함" id="fax_no" name="fax_no">
							</td>
						</tr>
						<tr>
							<th rowspan="3" class="text-right">고객주소</th>
							<td colspan="3" rowspan="3">
								<div class="form-row inline-pd mb7">
									<div class="col-4">
										<input type="text" class="form-control" id="post_no" name="post_no" alt="고객 우편번호" value="${empty inputParam.post_no? '' : inputParam.post_no}" readonly="readonly">
									</div>
									<div class="col-4">
										<button type="button" class="btn btn-primary-gra" onclick="javascript:openSearchAddrPanel('fnJusoBiz');">주소찾기</button>
									</div>
									<div class="col-4 text-right">
										<button type="button" class="btn btn-primary-gra" onclick="javascript:fnShowEnLocation();" id="btnAddrChanger" name="btnAddrChanger">영문주소보기</button>
									</div>
								</div>
								<div class="form-row inline-pd mb7">
									<div class="col-12">
										<input type="text" class="form-control" id="addr_kor1" name="addr_kor1" alt="고객주소" value="${empty inputParam.addr1? '' : inputParam.addr1}" readonly="readonly">
										<input type="hidden" id="addr_eng1" name="addr_eng1">
										<input type="hidden" id="addr1" name="addr1" value="${empty inputParam.addr1? '' : inputParam.addr1}">
									</div>
								</div>
								<div class="form-row inline-pd">
									<div class="col-12">
										<input type="text" class="form-control" id="addr_kor2" name="addr_kor2" alt="고객 상세 주소" value="${empty inputParam.addr2? '' : inputParam.addr2}">
										<input type="hidden" id="addr_eng2" name="addr_eng2">
										<input type="hidden" id="addr2" name="addr2" value="${empty inputParam.addr2? '' : inputParam.addr2}">
									</div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">입금자</th>
							<td>
								<input type="text" class="form-control" placeholder="" id="deposit_name" name="deposit_name" alt="입금자">
							</td>
							<th class="text-right">업종</th>
							<td>
								<select class="form-control" id="biz_type_cd" name="biz_type_cd" alt="업종">
									<option value="">- 선택 -</option>
									<c:forEach var="biz" items="${codeMap['BIZ_TYPE']}">
										<option value="${biz.code_value}">${biz.code_name}</option>
									</c:forEach>
								</select>

							</td>
						</tr>
						<tr>
							<th class="text-right">마케팅대상</th>
							<td colspan="3">
								<input type="text" class="form-control" id="sales_maker_cd" name="sales_maker_cd" alt="" readonly="readonly">
								<!-- 										<div class="form-row inline-pd pr"> -->
								<!-- 											<div class="col-12"> -->
								<!-- 												<input class="form-control" style="width: 99%;"type="text" id="sales_maker_cd" name="sales_maker_cd" easyui="combogrid" -->
								<!-- 													easyuiname="salesMakerCd" panelwidth="500" textfield="code_name" multi="Y" idfield="code_value"/> -->
								<!-- 											</div> -->
								<!-- 										</div> -->
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">고객담당</th>
							<td colspan="3">
								<div class="form-row inline-pd">
									<div class="col-auto essential-item spacing-sm">
										지역
									</div>
									<div class="col-2">
										<div class="input-group" >
											<input type="text" class="form-control border-right-0 essential-bg" id="area_si" name="area_si" required="required" readonly="readonly" alt="고객담당 지역">
											<input type="hidden" id="sale_area_code" name="sale_area_code"/>
											<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchSaleAreaPanel('setSaleAreaInfo');"><i class="material-iconssearch"></i></button>
										</div>
									</div>
									<div class="col-auto essential-item spacing-sm">
										담당센터
									</div>
									<div style="width: 80px;">
										<input type="text" class="form-control essential-bg" id="center_org_name" name="center_org_name" alt="고객 담당 센터" readonly="readonly" required="required">
										<input type="hidden" id="center_org_code" name="center_org_code">
									</div>
									<div class="col-auto essential-item spacing-sm">
										서비스담당
									</div>
									<div style="width: 80px;">
										<input type="text" class="form-control essential-bg" id="service_mem_name" name="service_mem_name" alt="고객 서비스 담당 직원" readonly="readonly" required="required">
										<input type="hidden" id="service_mem_no" name="service_mem_no">
									</div>
									<div class="col-auto spacing-sm">
										미수담당
									</div>
									<div class="col-2">
										<div class="input-group">
											<input type="text" class="form-control border-right-0" id="misu_mem_name" name="misu_mem_name" readonly="readonly" alt="고객 미수 담당 직원">
											<input type="hidden" id="misu_mem_no" name="misu_mem_no">
											<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchMemberPanel('fnSetMemberInfo');"><i class="material-iconssearch"></i></button>
										</div>
									</div>
								</div>
							</td>
							<th class="text-right">보유기종</th>
							<td colspan="3">
								<input type="text" class="form-control" id="cust_maker_cd" name="cust_maker_cd" alt="" readonly="readonly">
								<!-- 										<div class="form-row inline-pd"> -->
								<!-- 											<div class="col-12"> -->
								<!-- 												<input class="form-control" style="width: 99%;"type="text" id="cust_maker_cd" name="cust_maker_cd" easyui="combogrid" -->
								<!-- 														easyuiname="custMakerCd" panelwidth="500" textfield="code_name" multi="Y" idfield="code_value"/> -->
								<!-- 											</div> -->
								<!-- 										</div> -->
							</td>
						</tr>
						<tr>
							<th class="text-right">고객분류2</th>
							<td>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" id="cust_sale_type_cd_00" name="cust_sale_type_cd" value="00" checked="checked" alt="">
									<label class="form-check-label" for="cust_sale_type_cd_00">일반</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" id="cust_sale_type_cd_10" name="cust_sale_type_cd" value="10" alt="">
									<label class="form-check-label" for="cust_sale_type_cd_10">모니터</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" id="cust_sale_type_cd_20" name="cust_sale_type_cd" value="20" alt="">
									<label class="form-check-label" for="cust_sale_type_cd_20">서브딜러</label>
								</div>
							</td>
							<th class="text-right">마케팅구분</th>
							<td>
								<div class="row" style="margin-left:1px;">
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="sale_type_c" name="sale_type_ca" value="C" checked="checked">
										<label class="form-check-label" for="sale_type_c">건설기계</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="sale_type_a" name="sale_type_ca" value="A">
										<label class="form-check-label" for="sale_type_a">농기계</label>
									</div>
								</div>
							</td>
							<th class="text-right">주기장주소</th>
							<td colspan="3">
								<div class="form-row inline-pd">
									<div class="col-auto pdr0">
										<input type="text" class="form-control mw45 width60px" id="curr_post_no" name="curr_post_no" readonly="readonly" alt="고객주소">
									</div>
									<div class="col-auto pdl5">
										<button type="button" class="btn btn-primary-gra" style="width: 100%;" id="addr" readonly="readonly" onclick="javascript:openSearchAddrPanel('fnJusoCurr');">주소찾기</button>
									</div>
									<div class="col-5">
										<input type="text" class="form-control" id="curr_addr1" name="curr_addr1" readonly="readonly">
									</div>
									<div class="col-4">
										<input type="text" class="form-control" id="curr_addr2" name="curr_addr2">
									</div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">지정(중고)딜러여부</th>
							<td>
								<div class="form-check form-check-inline">
									<input class="form-check-input dealerYn" type="radio" id="dealer_y" name="dealer_yn" value="Y" alt="">
									<label class="form-check-label" for="dealer_n">Y</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input dealerYn" type="radio" id="dealer_n" name="dealer_yn" value="N" checked="checked"  alt="">
									<label class="form-check-label" for="dealer_n">N</label>
								</div>
							</td>
							<th class="text-right">주요관리업체</th>
							<td>
								<div class="form-check form-check-inline">
									<input class="form-check-input mainMngYn" type="radio" id="main_mng_y" name="main_mng_yn" value="Y" alt="">
									<label class="form-check-label" for="main_mng_y">Y</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input mainMngYn" type="radio" id="main_mng_n" name="main_mng_yn" value="N" checked="checked" alt="">
									<label class="form-check-label" for="main_mng_n">N</label>
								</div>
							</td>
							<th class="text-right">
								<div class="form-check form-check-inline" style="margin-right: -5px;">
									<label class="form-check-label mr5">고객앱 법인인증</label>
									<input class="form-check-input" type="checkbox" id="appCorAuthYn" name="appCorAuthYn" onchange="javascript:fnSetAppCorAuth();">
									<input type="hidden" id="app_cor_auth_yn" name="app_cor_auth_yn" value="N">
								</div>
							</th>
							<td colspan="3">
								<div class="form-row inline-pd">
									<div class="col-auto">
										<div class="input-group">
											<input type="text" id="cor_hp_no" name="cor_hp_no" class="form-control border-right-0" placeholder="숫자만 입력" format="phone" alt="법인휴대폰" value="" maxlength="11"
												   disabled='disabled' onchange="javascript:fnCorHpDuplCheck();">
											<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnOpenSmsPanel('cor');"><i class="material-iconsforum"></i></button>
										</div>
									</div>
									<div class="col-auto">
										<button type="button" class="btn btn-primary-gra btn-cancel" id="corHpDuplic" name="corHpDuplic" disabled='disabled' onclick="javascript:goCorHpDuplCheck();">중복체크</button>
										<input type="hidden" id="corHpDuplicCheck" name="corHpDuplicCheck" value="Y">
									</div>
								</div>
							</td>
						</tr>
						</tbody>
					</table>
				</div>

				<div>
					<div class="title-wrap mt20">
						<h4>개인정보수집 동의 여부</h4>
						<div class="text-secondary">마케팅 활용 미 동의 시 광고/홍보문자 발송불가!</div>
					</div>
					<table class="table-border mt5">
						<colgroup>
							<col width="160px">
							<col width="">
						</colgroup>
						<tbody>
						<tr>
							<th class="text-right">
								<div class="form-check form-check-inline">
									<label class="form-check-label mr5">개인정보 수집동의</label>
									<input class="form-check-input" type="checkbox" id="personalYn" name="personalYn" onchange="javascript:fnPersonalChange('personal');">
									<input type="hidden" id="personal_yn" name="personal_yn" value="N" alt="개인정보 수집동의">
								</div>
							</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-1 text-right">확인일자</div>
									<div class="col-2">
										<div class="input-group">
											<input type="text" dateFormat="yyyy-MM-dd" class="form-control border-right-0 calDate" id="personal_dt" name="personal_dt" alt="확인일자" readonly="readonly">
										</div>
									</div>
									<div class="col-1 text-right">확인자</div>
									<div class="col-2">
										<input type="text" class="form-control" id="personal_mem_name" name="personal_mem_name" alt="확인 직원" readonly="readonly">
										<input type="hidden" class="form-control" id="personal_mem_no" name="personal_mem_no">
									</div>
									<div class="col-1 text-right">수집구분</div>
									<div class="col-1">
										<select class="form-control" id="personal_collect_cd" name="personal_collect_cd">
											<c:forEach var="personal" items="${codeMap['PERSONAL_COLLECT']}">
												<option value="${personal.code_value}">${personal.code_name}</option>
											</c:forEach>
										</select>
									</div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">
								<div class="form-check form-check-inline">
									<label class="form-check-label mr5">제3자 정보제공동의</label>
									<input class="form-check-input" type="checkbox" id="threeYn" name="threeYn" onchange="javascript:fnPersonalChange('three');" alt="제 3자 정보 제공 동의">
									<input type="hidden" id="three_yn" name="three_yn" value="N">
								</div>
							</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-1 text-right">확인일자</div>
									<div class="col-2">
										<div class="input-group">
											<input type="text" dateFormat="yyyy-MM-dd" class="form-control border-right-0 calDate" id="three_dt" name="three_dt" alt="제 3자 정보 제공 동의 확인 일자" readonly="readonly">
										</div>
									</div>
									<div class="col-1 text-right">확인자</div>
									<div class="col-2">
										<input type="text" class="form-control" id="three_mem_name" name="three_mem_name" readonly="readonly">
										<input type="hidden" class="form-control" id="three_mem_no" name="three_mem_no">
									</div>
									<div class="col-1 text-right">수집구분</div>
									<div class="col-1">
										<select class="form-control" id="three_collect_cd" name="three_collect_cd">
											<c:forEach var="three" items="${codeMap['THREE_COLLECT']}">
												<option value="${three.code_value}">${three.code_name}</option>
											</c:forEach>
										</select>
									</div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">
								<div class="form-check form-check-inline">
									<label class="form-check-label mr5">마케팅 활용동의</label>
									<input class="form-check-input" type="checkbox" id="marketingYn" name="marketingYn" onchange="javscript:fnPersonalChange('marketing')">
									<input type="hidden" id="marketing_yn" name="marketing_yn" value="N">
								</div>
							</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-1 text-right">확인일자</div>
									<div class="col-2">
										<div class="input-group">
											<input type="text" dateFormat="yyyy-MM-dd" class="form-control border-right-0 calDate" id="marketing_dt" name="marketing_dt" readonly="readonly">
										</div>
									</div>
									<div class="col-1 text-right">확인자</div>
									<div class="col-2">
										<input type="text" class="form-control" id="marketing_mem_name" name="marketing_mem_name" readonly="readonly">
										<input type="hidden" class="form-control" id="marketing_mem_no" name="marketing_mem_no">
									</div>
									<div class="col-1 text-right">수집구분</div>
									<div class="col-1">
										<select class="form-control" id="marketing_collect_cd" name="marketing_collect_cd">
											<c:forEach var="marketing" items="${codeMap['MARKETING_COLLECT']}">
												<option value="${marketing.code_value}">${marketing.code_name}</option>
											</c:forEach>
										</select>
									</div>
									<%--											<div class="col-4 text-right">--%>
									<%--												<div class="form-check form-check-inline">--%>
									<%--													<input class="form-check-input" type="checkbox" id="tel" name="marketing_check">--%>
									<%--													<input type="hidden" id="tel_yn" name="tel_yn">--%>
									<%--													<label class="form-check-label" for="tel">전화</label>--%>
									<%--												</div>--%>
									<%--												<div class="form-check form-check-inline">--%>
									<%--													<input class="form-check-input" type="checkbox" id="sms" name="marketing_check">--%>
									<%--													<input type="hidden" id="sms_yn" name="sms_yn">--%>
									<%--													<label class="form-check-label" for="sms">SMS</label>--%>
									<%--												</div>--%>
									<%--												<div class="form-check form-check-inline">--%>
									<%--													<input class="form-check-input" type="checkbox" id="email" name="marketing_check">--%>
									<%--													<input type="hidden" id="email_yn" name="email_yn">--%>
									<%--													<label class="form-check-label" for="email">이메일</label>--%>
									<%--												</div>--%>
									<%--												<div class="form-check form-check-inline">--%>
									<%--													<input class="form-check-input" type="checkbox" id="dm" name="marketing_check">--%>
									<%--													<input type="hidden" id="dm_yn" name="dm_yn">--%>
									<%--													<label class="form-check-label" for="dm">우편발송</label>--%>
									<%--												</div>--%>
									<%--											</div>--%>
								</div>
							</td>
						</tr>
						</tbody>
					</table>
				</div>
				<!-- TODO: 관리부 계정만 보여줌 -->
				<div class="mng-show-yn dpn">
					<div class="title-wrap mt20">
						<h4>추가사항</h4>
					</div>
					<table class="table-border mt5">
						<colgroup>
							<col width="100px">
							<col width="">
							<col width="100px">
							<col width="">
							<col width="100px">
							<col width="">
							<col width="100px">
							<col width="">
							<col width="100px">
							<col width="">
						</colgroup>
						<tbody>
						<tr>
							<th class="text-right">매출한도</th>
							<td>
								<input type="text" class="form-control text-right" id="max_misu_amt" name="max_misu_amt" format="decimal">
							</td>
							<th class="text-right">관리번호</th>
							<td>
								<div class="input-group">
									<input type="text" class="form-control border-right-0" readonly="readonly">
									<button type="button" class="btn btn-icon btn-primary-gra" onclick="goControlNoPopup();"><i class="material-iconssearch"></i></button>
								</div>
							</td>
							<th class="text-right">거래명세서</th>
							<td>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="checkbox" id="misu_print" name="misu_print">
									<input type="hidden" id="misu_print_yn" name="misu_print_yn">
									<label class="form-check-label">미수금 인쇄안함</label>
								</div>
							</td>
							<th class="text-right">업체명인쇄</th>
							<td>
								<c:forEach var="print" items="${codeMap['COM_NAME_PRINT']}">
									<input type="radio" id="com_name_print_cd" name="com_name_print_cd" value="${print.code_value}"<c:if test="${ print.code_value eq '0'}">checked="checked"</c:if>/>${print.code_name}
								</c:forEach>
							</td>
							<th class="text-right">사용여부</th>
							<td>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" id="use_yn" name="use_yn" value="Y" checked="checked">
									<label class="form-check-label">사용</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" id="use_yn" name="use_yn" value="N">
									<label class="form-check-label">사용안함</label>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">단가구분</th>
							<td>
								<select class="form-control" id="unit_price_cd" name="unit_price_cd">
									<c:forEach var="unit" items="${codeMap['UNIT_PRICE']}">
										<option value="${unit.code_value}"<c:if test="${result.unit_price_cd eq unit.code_value }"> selected="selected"</c:if>>${unit.code_name}</option>
									</c:forEach>
								</select>
							</td>
							<th class="text-right">부가구분</th>
							<td>
								<select class="form-control" id="add_ut" name="add_ut">
									<c:forEach var="add" items="${addCombo}">
										<option value="${add.code_value}"<c:if test="${result.add_ut eq add.code_value }"> selected="selected"</c:if>>${add.code_name}</option>
									</c:forEach>
								</select>
							</td>
							<th class="text-right">거래구분</th>
							<td>
								<select class="form-control" id="deal_gubun_cd" name="deal_gubun_cd">
									<c:forEach var="deal" items="${codeMap['DEAL_GUBUN']}">
										<option value="${deal.code_value}"<c:if test="${result.deal_gubun_cd eq deal.code_value }"> selected="selected"</c:if>>${deal.code_name}</option>
									</c:forEach>
								</select>
							</td>
							<th class="text-right">회계거래처 코드</th>
							<td>
								<input type="text" class="form-control" id="account_link_cd" name="account_link_cd">
							</td>
							<th class="text-right">SMS 발송여부</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-6">
										<button type="button" class="btn btn-primary-gra btn-cancel" id="sms_cancel" name="sms_cancel" style="width: 100%;" onclick="javascript:fnSwitchSMS('on');">SMS정지</button>
									</div>
									<div class="col-6">
										<button type="button" class="btn btn-primary-gra btn-cancel" id="sms_send" name="sms_send" style="width: 100%;" onclick="javascript:fnSwitchSMS('off');">정지해제</button>
									</div>
								</div>
							</td>
						</tr>
						</tbody>
					</table>
				</div>
				<!-- /폼테이블 -->
				<!-- 회원구분정책 -->
				<div class="row mg0">
					<div class="col-12 alert alert-secondary mt10">
						<div class="title">
							<i class="material-iconserror font-16"></i>
							<span>회원구분정책</span>
						</div>
						<ul>
							<c:forEach var="code" items="${codeMap['CUST_TYPE']}">
								<li>${code.code_name} : ${code.code_desc}</li>
							</c:forEach>
							<%--								<li>일반회원 : 필수사항 입력 및 전화번호 중복체크 시 이상 없는 고객</li>--%>
							<%--								<li>준회원 : YK건기에서 인증번호를 부여하여 본인확인을 하는 회원</li>--%>
						</ul>
					</div>
				</div>
				<!-- /회원구분정책 -->
				<div class="btn-group mt10">
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
					</div>
				</div>
			</div>
		</div>
		<c:if test="${inputParam.s_popup_yn ne 'Y'}">
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
		</c:if>
	</div>
	<!-- /content-wrap -->
	<input type="hidden" id="sms_send_yn" name="sms_send_yn" value="N">
</form>
</body>
</html>
