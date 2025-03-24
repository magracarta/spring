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
		const originCustName = '${result.cust_name}'; // 처음 조회된 고객 이름
		const originCustHpNo = '${result.hp_no}'; // 처음 조회된 핸드폰 번호

		$(document).ready(function() {
			if($M.getValue("sms_send_yn") == "Y") {
				$("#sms_send").attr('disabled', true);
			} else {
				$("#sms_cancel").attr('disabled', true);
			}
			fnInitPage();
		});

		function fnInitPage() {
// 			$("#_goRemove").hide();
			var haveMch = ${have_mch};
			var consultMch = ${consult_mch};
			var type = ${type_cd};

			if(haveMch != null) {
				$M.setValue("cust_maker_cd", haveMch.have_machine_name);
			}
			if(consultMch != null) {
				$M.setValue("sales_maker_cd", consultMch.consult_machine_name);
			}

			$M.setValue("__s_cust_name", $M.getValue("cust_name"));
			$M.setValue("__s_cust_no", $M.getValue("cust_no"));
			$M.setValue("__s_hp_no", $M.getValue("hp_no"));
			$M.setValue("__s_machine_seq", "${inputParam.machine_seq}");

			var custGradeHandCdStr =  "${result.cust_grade_hand_cd_str}";
			$('#cust_grade_hand_cd').combogrid("setValues", custGradeHandCdStr == ""? "" : custGradeHandCdStr.split("^"));
			var custGradeCdStr =  "${result.cust_grade_cd_str}";
			$('#cust_grade_cd').combogrid("setValues", custGradeCdStr == ""? "" : custGradeCdStr.split("^"));

			var mngYn = "${mngYn}";
			// 이금님사원님 영업대행으로 부서가 영업이 됐으나 관리부이기도 하여 추가. 210811 김상덕
			<%--var loginMemNo = "${inputParam.login_mem_no}";--%>
			// 2023-02-23 김상덕. 3-2차 권한관련인데 누락된부분이라 추가함.
			if(mngYn == "Y") {
				$(".mng-show-yn").removeClass("dpn");
			}

			// 준회원이면 버튼 비활성화
			if(type.auth_check_yn == "Y") {
				$("#memberAuth").prop("disabled", true);
			}

			// 대리점권한일경우 수정 불가
			<%--if("${SecureUser.org_type}" == "AGENCY") {--%>
			if(${page.fnc.F00064_001 eq 'Y'}) {
				$("#_goModify").addClass("dpn");
				$("#removeBregNoBtn").addClass("dpn");
			} else {
				$("#_goModify").removeClass("dpn");
				$("#removeBregNoBtn").removeClass("dpn");
			}

			// 고객분류2 수정 권한자만 활성화
			if("${typeModifyYn}" != "Y") {
				$(".custSaleType").prop("disabled", true);
			}

			// 지정(중고)딜러여부 수정 권한자만 활성화
			if(${page.fnc.F00064_005 ne 'Y'}) {
				$(".dealerYn").prop("disabled", true);
			}

			// 주요관리업체여부 수정 권한자만 활성화
			if(${page.fnc.F00064_006 ne 'Y'}) {
				$(".mainMngYn").prop("disabled", true);
			}
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
			}
		}

		function fnJusoCurr(data) {
			$M.setValue("curr_post_no", data.zipNo);
			$M.setValue("curr_addr1", data.roadAddrPart1);
			$M.setValue("curr_addr2", data.addrDetail);
		}

		function fnPersonalChange(param) {
			var personalYn = $("input:checkbox[name='"+param+"Yn']").is(":checked");
			if(personalYn) {
				$M.setValue(param+"_yn", "Y");
				$M.setValue(param+"_dt", $M.getCurrentDate());
				$M.setValue(param+"_mem_name", '${SecureUser.user_name }');
				$M.setValue(param+"_mem_no", '${SecureUser.mem_no }');

				var collectCd = $M.getValue(param+"_collect_cd");
				if (collectCd == '') {
					$M.setValue(param+"_collect_cd", "1");
				}
			} else {
				$M.setValue(param+"_yn", "N");
				$M.setValue(param+"_dt", "");
				$M.setValue(param+"_mem_name", "");
				$M.setValue(param+"_mem_no", "");
				$M.setValue(param+"_collect_cd", "");
				// if(param == "marketing") {
				// 	$("input:checkbox[name='marketing_check']").prop("checked", false);
				// }
			}
		}

		function fnPersonalCollectChange(param) {
			var personalYn = $("input:checkbox[name='"+param+"Yn']").is(":checked");
			if(personalYn) {
				$M.setValue(param+"_dt", $M.getCurrentDate());
				$M.setValue(param+"_mem_name", '${SecureUser.user_name }');
				$M.setValue(param+"_mem_no", '${SecureUser.mem_no }');
			}
		}

		function fnPersonalDateChange(param) {
			var personalYn = $("input:checkbox[name='"+param+"Yn']").is(":checked");
			if(personalYn) {
				$M.setValue(param+"_mem_name", '${SecureUser.user_name }');
				$M.setValue(param+"_mem_no", '${SecureUser.mem_no }');
			}
		}

		function goModify() {
			var frm = document.main_form;
			if($M.validation(frm) == false) {
	     		return false;
	     	}
			if($M.getValue("hpDuplicCheck") == "N") {
				alert("휴대폰 중복체크를 진행해주세요");
				return false;
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

			fnYnCheck();
// 			$M.setValue("sales_maker_cd_str", $M.getValue("sales_maker_cd"));
// 			$M.setValue("cust_maker_cd_str", $M.getValue("cust_maker_cd"));

			$M.setValue("addr1", $M.getValue("addr_kor1"));
			$M.setValue("addr2", $M.getValue("addr_kor2"));

			if(fnCheckPrivacy("marketing") == false) {
				return false;
			}
			if(fnCheckPrivacy("personal") == false) {
				return false;
			}
			if(fnCheckPrivacy("three") == false) {
				return false;
			}
			// 고객등급 자동반영 여부
			var custGradeAutoYn = $("input:checkbox[name='custGradeAutoYn']").is(":checked");
			if(custGradeAutoYn) {
				$M.setValue("cust_grade_auto_yn", "Y");
			} else {
				$M.setValue("cust_grade_auto_yn", "N");
			}

			// VIP 자동반영 여부
			var custGroupAutoYn = $("input:checkbox[name='vipAutoYn']").is(":checked");
			if(custGroupAutoYn) {
				$M.setValue("vip_auto_yn", "Y");
			} else {
				$M.setValue("vip_auto_yn", "N");
			}

			// vip가격 반영 여부
			var vipYn = $("input:checkbox[name='vipYn']").is(":checked");
			if(vipYn) {
				$M.setValue("vip_yn", "Y");
			} else {
				$M.setValue("vip_yn", "N");
			}

			// 23.05.17 [정윤수] 월결제고객 여부 추가
			var monPayCustYn = $("input:checkbox[name='monPayCustYn']").is(":checked");
			if(monPayCustYn) {
				$M.setValue("mon_pay_cust_yn", "Y");
			} else {
				$M.setValue("mon_pay_cust_yn", "N");
			}

			// 3차 - 14327 : 고객명, 휴대폰 번호 변경시에만 쪽지 전송을 위해 트리거 셋팅
			// if (originCustName != $M.getValue("cust_name") || originCustHpNo != $M.getValue("hp_no")) {
			// 2023-02-23 고객정보 변경 쪽지 전송시 고객명만 체크 - 황빛찬
			if (originCustName != $M.getValue("cust_name")) {
				$M.setHiddenValue(frm, "isSendPaper", true);
			} else {
				$M.setHiddenValue(frm, "isSendPaper", false);
			}

			$M.setHiddenValue(frm, "cust_grade_hand_cd_str", $M.getValue("cust_grade_hand_cd").replaceAll("#", "^"));
			$M.setHiddenValue(frm, "cust_grade_cd_str", $M.getValue("cust_grade_cd").replaceAll("#", "^"));

			$M.goNextPageAjaxModify(this_page + "/modify", $M.toValueForm(frm) , {method : 'POST'},
				function(result) {
		    		if(result.success) {
		    			// 조직관리에서 모니터 서브딜러 수정할때
		    			if ("${inputParam.s_monitor_yn}" == "Y") {
		    				if (window.opener && window.opener.goSearchMonitorSubList()) {
		    					window.opener.goSearchMonitorSubList();
		    				}
		    			}
						// 품의서 등록시 고객상세 주소 없어서 수정할때
						if (window.opener && window.opener.fnSetCustAddr) {
							var addrParam = {
								"cust_no": $M.getValue("cust_no"),
								"post_no": $M.getValue("post_no"),
								"addr1": $M.getValue("addr1"),
								"addr2": $M.getValue("addr2"),
							}
							window.opener.fnSetCustAddr(addrParam);
							window.close();
						}
						location.reload();
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

		function fnSendMail() {
			var param = {
	    			 'to' : $M.getValue('email')
	    	  };
	        openSendEmailPanel($M.toGetParam(param));
		}

		function fnYnCheck() {
			if($M.getValue("cust_type_cd") == '' || $M.getValue("cust_type_cd") == '01') {
				$M.setValue("cust_type_cd", "01");
				$M.setValue("cust_type_name", "일반회원");
			}
			var ynCheck = ['misu_print', 'tel', 'sms', 'email_check', 'dm']
			for (i=0; i<ynCheck.length; i++) {
				var check = $("input:checkbox[id='"+ynCheck[i]+"']").is(":checked");
				if(check) {
					if(ynCheck[i] == "email_check") {
						$M.setValue("email_yn", "Y");
					} else {
						$M.setValue(ynCheck[i]+"_yn", "Y");
					}
				} else {
					if(ynCheck[i] == "email_check") {
						$M.setValue("email_yn", "N");
					} else {
						$M.setValue(ynCheck[i]+"_yn", "N");
					}
				}
			}
		}

		function fnClose() {
			window.close();
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
		function goControlNoPopup() {
			var param = {
					"cust_no" : $M.getValue("cust_no")
			}
			var popupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=500, height=450, left=0, top=0";
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
					cust_no : $M.getValue("cust_no"),
					parent_js_name : execFuncName
			};
			var popupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=600, height=260, left=0, top=0";
			$M.goNextPage('/cust/cust0102p03', $M.toGetParam(param), {popupStatus : popupOption});
		}

		function setHpAssociate(data) {

			$("#memberAuth").prop("disabled", true);
			$("#hpDuplic").attr('disabled', true);
			$M.setValue("hp_no", data);
			$M.setValue("hpDuplicCheck", "Y");
			$M.setValue("auth_check_yn", "Y");

			// 2023-03-10 직원앱 erp적용 jsk
			// $M.setValue("cust_type_cd", "02");
			// $("#custTypeName").text("준회원");
			// $M.setValue("cust_type_name", "준회원");

			// var param = {
			// 		"cust_no" : $M.getValue("cust_no"),
			// 		"cust_type_cd" : $M.getValue("cust_type_cd")
			// }
			//
			// $M.goNextPageAjax(this_page+'/custAuth', $M.toGetParam(param) , {method : 'POST'},
			// 		function(result) {
			//     		if(result.success) {
			// 			}
			// 		}
			// 	);
		}

		function fnHpDuplCheck() {
			if($M.getValue("hp_no") != '${result.hp_no}') {
				$("#memberAuth").attr('disabled', false);
				$("#hpDuplic").attr('disabled', false);
				$M.setValue("hpDuplicCheck", "N");
				$M.setValue("auth_check_yn", "N");
			}
		}

		//핸드폰 인증
		function goHpDuplCheck(succsessMsgYn) {
			var param = {
				"s_hp_no" : $M.getValue("hp_no"),
				"cust_no" : $M.getValue("cust_no"),
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

		function setSendSMSInfo(data) {
			alert(data);
		}

		function fnOpenPanel(param) {
			if(param == 'send') {
	 			openSearchSendSMSPanel('setSendSMSInfo');
	 		} else if(param == 'machine') {
	 			alert("보유기종");
	 		} else if(param == 'confirm') {
	 			openCheckRequiredPanel();
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

		// 사업자명세조회
	    function fnSearchBregSpec() {
			var param = {
				's_cust_no' : $M.getValue('cust_no')
			};
	   		openSearchBregSpecPanel('fnSetNewBregInfo', $M.toGetParam(param));
	    }

		// 사업자명세조회
		function fnSetNewBregInfo(data) {
			data.cust_no = $M.getValue('cust_no');
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
							// 여기에 체크
							$M.setValue("breg_no", data.breg_no);
							$M.setValue("breg_rep_name", data.breg_rep_name);
							$M.setValue("breg_name", data.breg_name);
							$M.setValue("breg_seq", data.breg_seq);
						}
					}
			);
		}

	    // 고객 삭제
		function goRemove() {
			// 전표가 있는 고객일 시
			if($M.getValue("inout_cnt") > 0) {
				custRemove();
				return false;
			}
			var param = {
					"cust_no" : $M.getValue("cust_no")
			}

			$M.goNextPageAjaxRemove(this_page + "/remove", $M.toGetParam(param), {method : 'POST'},
				function(result) {
		    		if(result.success) {
		    			alert("삭제 처리되었습니다.");
		    			fnClose();
					} else {
						location.reload();
					}
				}
			);
		}

		// 전표가 있는 고객일 시
		function custRemove() {
			var param = {
					"cust_no" : $M.getValue("cust_no")
			}

			var msg = "해당 고객은 거래내역이 있습니다.\n고객명을 제외한 나머지 정보를 삭제합니다.\n삭제 처리하시겠습니까?";

			$M.goNextPageAjaxMsg(msg, this_page + "/custRemove", $M.toGetParam(param), {method : 'POST'},
				function(result) {
		    		if(result.success) {
		    			alert("삭제 처리되었습니다.");
		    			fnClose();
					}
				}
			);
		}

		// 사업자번호 삭제
		function fnRemoveBregNo() {
			if ($M.getValue("breg_seq") == "" || $M.getValue("breg_seq") == "0") {
				alert("사업자번호가 없습니다.");
				return false;
			}

			var param = {
				"cust_no" : $M.getValue("cust_no")
			}

			var msg = "사업자번호를 삭제하시겠습니까?";

			$M.goNextPageAjaxMsg(msg, this_page + "/custBregRemove", $M.toGetParam(param), {method : 'POST'},
				function(result) {
		    		if(result.success) {
		    			alert("삭제 처리되었습니다.");
		    			$M.setValue("breg_no", "");
		    			$M.setValue("breg_rep_name", "");
		    			$M.setValue("breg_name", "");
		    			$M.setValue("breg_seq", "0");
					}
				}
			);
		}

		function show() {
			document.getElementById("machine_operation").style.display="block";
		}
		function hide() {
			document.getElementById("machine_operation").style.display="none";
		}

		// 쿠폰상세보기
		function fnCouponPopup() {
			var param = {
				cust_no : $M.getValue("cust_no")
			};

			var popupOption = "";
			$M.goNextPage('/cust/cust0102p99', $M.toGetParam(param), {popupStatus : popupOption});
		}

		// 동의서파일 팝업
		function goFile(fileSeq){
			openFileViewerPanel(fileSeq);
		}

		// 월결제고객체크 시 inputbox에 M추가
		function fnMonPayCheck() {
			var monPayYn = $("input:checkbox[id='monPayCustYn']").is(":checked");
			var gradeCd = $M.getValue("cust_grade_cd");
			var gradeCdArr = $M.getValue("cust_grade_cd").split("#");

			if(monPayYn && gradeCd.indexOf("M") < 0){
				if(gradeCd.substr(-1) == "#"){
					$M.setValue("cust_grade_cd", gradeCd + "M#")
				}else{
					$M.setValue("cust_grade_cd", gradeCd + "#M")
				}
				gradeCdArr = $M.getValue("cust_grade_cd").split("#");
			}else if(monPayYn == false){
				if(gradeCd.indexOf("M") >= 0){
					$M.setValue("cust_grade_cd", gradeCd.replace("M", ""));
					gradeCdArr = $M.getValue("cust_grade_cd").split("#");
					$('#cust_grade_cd').combogrid("setValues", gradeCdArr);
				}
			}
			for(var i = 0; i < gradeCdArr.length; i++) {
				if(gradeCdArr[i] == '')  {
					gradeCdArr.splice(i, 1);
					i--;
				}
			}
			$('#cust_grade_cd').combogrid("setValues", gradeCdArr);
		}

		// 앱 고객정보 상세 화면 이동
		function goAppCustDetail() {
			var param = {
				"app_cust_no" : $M.getValue("app_cust_no")
			}
			var popupOption = "";
			$M.goNextPage('/cust/cust0501p01', $M.toGetParam(param), {popupStatus : popupOption});
		}

		// 충성도 팝업 이동
		function goLoyaltyPopup() {
			var param = {
				"cust_no" : $M.getValue("cust_no")
			}
			var popupOption = "";
			$M.goNextPage('/cust/cust0102p0101', $M.toGetParam(param), {popupStatus : popupOption});
		}

		function fnSetAppCorAuth() {
			var authYn = $("input:checkbox[name='appCorAuthYn']").is(":checked");
			if (authYn && $M.getValue("app_use_yn") == "Y") {
				alert("${result.c_cust_name}(${result.c_web_id})" + " 앱고객님과 이미 매핑된 상태입니다. 매핑해제 후 다시 시도해주세요.");
				return false;
			}
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
                "cust_no" : $M.getValue("cust_no"),
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
<!-- /script -->
<!-- 팝업 -->
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" id="inout_cnt" name="inout_cnt" value="${inout_cnt}">
<input type="hidden" id="cust_group_cd" name="cust_group_cd" value="${result.cust_group_cd}">
<input type="hidden" id="sms_send_yn" name="sms_send_yn" value="${result.sms_send_yn}">
<input type="hidden" id="auth_check_yn" name="auth_check_yn" value="${result.auth_check_yn}">
<!-- <input type="hidden" id="cust_maker_cd_str" name="cust_maker_cd_str"> -->
<!-- <input type="hidden" id="sales_maker_cd_str" name="sales_maker_cd_str"> -->
<div class="popup-wrap width-100per">
	<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
            <!-- <button type="button" class="btn btn-icon"><i class="material-iconsclose"></i></button> -->
        </div>
		<!-- /타이틀영역 -->
        <div class="content-wrap">
			<div>
				<div class="title-wrap">
					<div class="left"><h4 class="primary">고객정보상세</h4></div>
					<div class="right">
<%--						<input type="checkbox" id="vipYn" name="vipYn" value="${result.vip_yn}" ${result.vip_yn == 'Y'? 'checked="checked"' : ''}>--%>
<%--						<label for="vipYn">VIP가격</label>--%>
<%--						<input type="hidden" id="vip_yn" name="vip_yn" value="${result.vip_yn}">	--%>
						<input type="checkbox" id="monPayCustYn" name="monPayCustYn" value="${result.mon_pay_cust_yn}" ${result.mon_pay_cust_yn == 'Y'? 'checked="checked"' : ''} onclick="javascript:fnMonPayCheck();"
							   <c:if test="${gradeModifyYn ne 'Y'}">disabled</c:if>>
						<label for="monPayCustYn">월결제고객여부</label>
						<input type="hidden" id="mon_pay_cust_yn" name="mon_pay_cust_yn" value="${result.mon_pay_cust_yn}">
						<input type="checkbox" id="vipAutoYn" name="vipAutoYn" value="${result.vip_auto_yn}" ${result.vip_auto_yn == 'Y'? 'checked="checked"' : ''}
							   <c:if test="${gradeModifyYn ne 'Y'}">disabled</c:if>>
						<label for="vipAutoYn">VIP자동반영</label>
						<input type="hidden" id="vip_auto_yn" name="vip_auto_yn" value="${result.vip_auto_yn}">
					</div>
				</div>
				<table class="table-border mt5">
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
								<div class="form-row inline-pd pr">
									<div class="col-auto">
										<!-- 고객명 수정가능 권한 mem_no 김태공/최승희/채평석/관리부/이원영/이진동/신정애 + 전산담당 -->
										<!-- 대리점일경우 고객상세 자체 수정불가하도록 수정 (스크립트에서 저장버튼 숨김처리) -->
<%-- 										<c:set var="name_change_mem_no" value="MB00000246#MB00000178#MB00000181#MB00000060#MB00000072#MB00000133#MB00000373#MB00000289#MB00000306#MB00000435#MB00000479#MB00000431#MB00000501"/> --%>
										<input type="text" class="form-control width120px essential-bg" id="cust_name" name="cust_name" value="${result.cust_name}" alt="고객명" required="required">
									</div>
									<%-- (Q&A 16821) 대리점직원은 연관업무 안보이도록.2022-11-18 김상덕. --%>
<%--									<c:if test="${SecureUser.org_type ne 'AGENCY'}">--%>
									<c:if test="${page.fnc.F00064_001 ne 'Y'}">
										<jsp:include page="/WEB-INF/jsp/common/commonCustJob.jsp">
			 	                     		<jsp:param name="li_type" value="__ledger#__sms_popup#__sms_info#__visit_history#__check_required#__have_machine_cust#__cust_rental_history#__rental_consult_history"/>
				                     	</jsp:include>
			                     	</c:if>
								</div>
							</td>
							<th class="text-right">고객번호</th>
							<td>
								<input type="text" class="form-control" readonly="readonly" id="cust_no" name="cust_no" value="${result.cust_no}">
							</td>
							<th class="text-right essential-item">고객분류</th> <!-- 필수항목일때 클래스 essential-item 추가 -->
							<td>
								<div class="form-row inline-pd pr">
								<div class="col-auto">
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" id="cust_class_pc" name="cust_class_pc" value="P" ${result.cust_class_pc == 'P'? 'checked="checked"' : ''}>
									<label class="form-check-label">개인</label>
								</div>
								</div>
								<div class="col-auto">
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" id="cust_class_pc" name="cust_class_pc" value="C" ${result.cust_class_pc == 'C'? 'checked="checked"' : ''}>
									<label class="form-check-label">법인</label>
								</div>
								</div>
								</div>
							</td>
							<th class="text-right">고객등급(자동)</th>
							<td>
								<div class="form-row inline-pd pr">
									<div class="col-auto">
										<input class="form-control" style="width: 99%;" type="text" id="cust_grade_cd" name="cust_grade_cd" easyui="combogrid"
											   easyuiname="custGradeList" panelwidth="250" idfield="code_value" textfield="code_name" multi="Y"
											   <c:if test="${gradeModifyYn ne 'Y'}">disabled</c:if>/>
<%--										<input type="text" class="form-control" id="cust_grade_name_str" name="cust_grade_name_str" value="${result.cust_grade_name_str}" readonly="readonly">--%>
<%--										2023-03-10 직원앱 erp적용 jsk--%>
<%--										<select class="form-control" id="cust_grade_cd" name="cust_grade_cd" checked="checked">--%>
<%--											<option value="T"<c:if test="${result.cust_grade_cd eq 'T' }"> selected="selected"</c:if>>- 선택 -</option>--%>
<%--											<c:forEach var="item" items="${codeMap['CUST_GRADE']}">--%>
<%--												<option value="${item.code_value}"<c:if test="${result.cust_grade_cd eq item.code_value }"> selected="selected"</c:if>>${item.code_name}</option>--%>
<%--											</c:forEach>--%>
<%--										</select>--%>
									</div>
									<div class="col-auto">
										<input type="checkbox" id="custGradeAutoYn" name="custGradeAutoYn" value="${result.cust_grade_auto_yn}" ${result.cust_grade_auto_yn == 'Y' ? 'checked="checked"' : ''} <c:if test="${gradeModifyYn ne 'Y'}">disabled</c:if>>
										<label for="custGradeAutoYn">등급자동반영</label>
										<input type="hidden" id="cust_grade_auto_yn" name="cust_grade_auto_yn" value="${result.cust_grade_auto_yn}">
									</div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">사업자번호</th>
							<td>
								<div class="input-group">
									<input type="text" class="form-control border-right-0" placeholder="사업자번호" id="breg_no" name="breg_no" format="bregno" value="${result.breg_no}" readonly="readonly">
									<input type="hidden" id="breg_seq" name="breg_seq" value="${result.breg_seq}">
									<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSearchBregSpec();"><i class="material-iconssearch"></i></button>
									<button id="removeBregNoBtn" name="removeBregNoBtn" type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnRemoveBregNo();"><i class="material-iconsclose text-default"></i></button>
								</div>
							</td>
							<th class="text-right">업체명</th>
							<td>
								<input type="text" class="form-control" placeholder="업체명" id="breg_name" name="breg_name" value="${result.breg_name}" readonly="readonly">
							</td>
							<th class="text-right">회원구분</th> <!-- 필수항목일때 클래스 essential-item 추가 -->
							<td>
								<div class="form-row inline-pd">
									<div class="col-auto" id="custTypeName" name="custTypeName">${result.cust_type_name}</div>
									<input type="hidden" id="cust_type_name" name="cust_type_name" value="${result.cust_type_name}">
									<input type="hidden" id="cust_type_cd" name="cust_type_cd" value="${result.cust_type_cd}">
									<div class="col-auto"><button type="button" class="btn btn-primary-gra btn-cancel" id="memberAuth" name="memberAuth" onclick="javascript:goMemberAuthPopup('setHpAssociate');">본인인증</button></div>
								</div>
							</td>
							<th class="text-right">고객등급(수동)</th>
							<td>
								<input class="form-control" style="width: 99%;" type="text" id="cust_grade_hand_cd" name="cust_grade_hand_cd" easyui="combogrid"
									   easyuiname="custGradeHandList" panelwidth="250" idfield="code_value" textfield="code_name" multi="Y"/>
							</td>
<%--							2023-03-10 직원앱 erp적용 jsk--%>
<%--							<th class="text-right">관리번호</th>--%>
<%--							<td>--%>
<%--								<div class="input-group">--%>
<%--									<input type="text" class="form-control border-right-0" name="machine_doc_no" value="${result.machine_doc_no}" readonly="readonly">--%>
<%--									<button type="button" class="btn btn-icon btn-primary-gra" onclick="goControlNoPopup();"><i class="material-iconssearch"></i></button>--%>
<%--								</div>--%>
<%--							</td>--%>
						</tr>
						<tr>
							<th class="text-right essential-item">휴대폰(장비소유자)</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-auto">
										<div class="input-group">
											<input type="text" id="hp_no" name="hp_no" class="form-control border-right-0 essential-bg" placeholder="숫자만 입력" format="phone" alt="휴대폰(장비소유자)" value="${result.hp_no}" maxlength="11" onchange="javascript:fnHpDuplCheck();" required="required">
											<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnOpenSmsPanel('sms');"><i class="material-iconsforum"></i></button>
										</div>
									</div>
									<div class="col-auto">
										<button type="button" class="btn btn-primary-gra btn-cancel" id="hpDuplic" name="hpDuplic" <c:if test="${result.hp_no ne '' }">disabled='disabled'</c:if> onclick="javascript:goHpDuplCheck('Y');">중복체크</button>
										<input type="hidden" id="hpDuplicCheck" name="hpDuplicCheck" <c:if test="${result.hp_no ne '' }">value="Y"</c:if>>
									</div>
								</div>
							</td>
							<th class="text-right">대표자</th>
							<td>
								<input type="text" class="form-control" placeholder="대표자" readonly="readonly" id="breg_rep_name" name="breg_rep_name" value="${result.breg_rep_name}">
							</td>
							<th class="text-right">지입사명</th>
							<td>
								<input type="text" class="form-control" id="artic_name" name="artic_name"  value="${result.artic_name}">
							</td>
							<th class="text-right">지입사연락처</th>
							<td>
								<input type="text" class="form-control" placeholder="숫자만 입력" id="artic_tel_no" name="artic_tel_no" value="${result.artic_tel_no}">
							</td>
						</tr>
						<tr>
							<th class="text-right">휴대폰(장비관리자)</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-7">
										<div class="input-group">
											<input type="text" class="form-control border-right-0" alt="휴대폰(장비관리자)" placeholder="숫자만 입력" format="phone" id="mng_hp_no" name="mng_hp_no"  value="${result.mng_hp_no}">
											<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnOpenSmsPanel('manager');"><i class="material-iconsforum"></i></button>
										</div>
									</div>
<%--									[3차 - 14444] 재협의 후 기능 수정으로 인한 삭제 처리 --%>
<%--									<div class="col-5">--%>
<%--										<button type="button" class="btn btn-primary-gra btn-cancel" id="hpManager" name="hpManager" <c:if test="${result.mng_hp_no ne '' }">disabled='disabled'</c:if> onclick="javascript:goHpDuplCheck('manager');">중복체크</button>--%>
<%--										<input type="hidden" id="hpManagerCheck" name="hpManagerCheck" <c:if test="${result.mng_hp_no ne '' }">value="Y"</c:if>>--%>
<%--									</div>--%>
									<div class="col-5">
										<input type="text" class="form-control ml5" placeholder="간단메모" id="mng_memo" name="mng_memo"value="${result.mng_memo}">
									</div>
								</div>
							</td>
							<th class="text-right">생년월일</th>
							<td>
							<div class="form-row inline-pd">
								<div class="col-6">
									<div class="input-group">
										<input type="text" class="form-control border-right-0 calDate" dateFormat="yyyy-MM-dd" id="birth_dt" name="birth_dt" value="${result.birth_dt}">
									</div>
								</div>
								<div class="col-6">
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="solar_cal_yn" name="solar_cal_yn" value="${result.solar_cal_yn}" ${result.solar_cal_yn == 'Y'? 'checked="checked"' : ''}>
										<label class="form-check-label">양력</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="solar_cal_yn" name="solar_cal_yn" value="${result.solar_cal_yn}" ${result.solar_cal_yn == 'N'? 'checked="checked"' : ''}>
										<label class="form-check-label">음력</label>
									</div>
								</div>
								</div>
							</td>
<!-- 							<th class="text-right">양력/음력</th> -->
<!-- 							<td> -->
<!-- 								<div class="form-check form-check-inline"> -->
<%-- 									<input class="form-check-input" type="radio" id="solar_cal_yn" name="solar_cal_yn" value="${result.solar_cal_yn}" ${result.solar_cal_yn == 'Y'? 'checked="checked"' : ''}> --%>
<!-- 									<label class="form-check-label">양력</label> -->
<!-- 								</div> -->
<!-- 								<div class="form-check form-check-inline"> -->
<%-- 									<input class="form-check-input" type="radio" id="solar_cal_yn" name="solar_cal_yn" value="${result.solar_cal_yn}" ${result.solar_cal_yn == 'N'? 'checked="checked"' : ''}> --%>
<!-- 									<label class="form-check-label">음력</label> -->
<!-- 								</div> -->
<!-- 							</td>	 -->
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
											<input type="text" class="form-control border-right-0" alt="휴대폰(장비운영자)" placeholder="숫자만 입력" format="phone" id="driver_hp_no" name="driver_hp_no" value="${result.driver_hp_no}">
											<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnOpenSmsPanel('admin');"><i class="material-iconsforum"></i></button>
										</div>
									</div>
<%--									[3차 - 14444] 재협의 후 기능 수정으로 인한 삭제 처리 --%>
<%--									<div class="col-5">--%>
<%--										<button type="button" class="btn btn-primary-gra btn-cancel" id="hpDriver" name="hpDriver" <c:if test="${result.driver_hp_no ne '' }">disabled='disabled'</c:if> onclick="javascript:goHpDuplCheck('driver');">중복체크</button>--%>
<%--										<input type="hidden" id="hpDriverCheck" name="hpDriverCheck" <c:if test="${result.driver_hp_no ne '' }">value="Y"</c:if>>--%>
<%--									</div>--%>
									<div class="col-5">
										<input type="text" class="form-control ml5" placeholder="간단메모" id="driver_memo" name="driver_memo" value="${result.driver_memo}">
									</div>
								</div>
							</td>
							<th class="text-right">이메일</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-10">
										<input type="text" class="form-control" id="email" name="email" format="email" value="${result.email}">
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
								<input type="text" class="form-control" placeholder="숫자만 입력" id="tel_no" name="tel_no" value="${result.tel_no}">
							</td>
							<th class="text-right">팩스</th>
							<td>
								<input type="text" class="form-control" placeholder="숫자만 입력" id="fax_no" name="fax_no" value="${result.fax_no}">
							</td>
						</tr>
						<tr>
							<th rowspan="3" class="text-right">고객주소</th>
							<td colspan="3" rowspan="3">
								<div class="form-row inline-pd mb7">
									<div class="col-4">
										<input type="text" class="form-control" id="post_no" name="post_no" value="${result.post_no}" readonly="readonly">
									</div>
									<div class="col-4">
										<button type="button" class="btn btn-primary-gra" onclick="javascript:openSearchAddrPanel('fnJusoBiz');">주소찾기</button>
									</div>
									<div class="col-4 text-right">
										<button type="button" class="btn btn-primary-gra" id="btnAddrChanger" name="btnAddrChanger" onclick="javascript:fnShowEnLocation();">영문주소보기</button>
									</div>
								</div>
								<div class="form-row inline-pd mb7">
									<div class="col-12">
										<input type="text" class="form-control" id="addr_kor1" name="addr_kor1" value="${result.addr1}" readonly="readonly">
										<input type="hidden" id="addr_eng1" name="addr_eng1" value="${result.addr_eng1}">
										<input type="hidden" id="addr1" name="addr1" value="${result.addr1}">
									</div>
								</div>
								<div class="form-row inline-pd">
									<div class="col-12">
										<input type="text" class="form-control" id="addr_kor2" name="addr_kor2" value="${result.addr2}">
										<input type="hidden" id="addr_eng2" name="addr_eng2" value="${result.addr_eng2}">
										<input type="hidden" id="addr2" name="addr2" value="${result.addr2}">
									</div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">입금자</th>
							<td>
								<input type="text" class="form-control" placeholder="" id="deposit_name" name="deposit_name" value="${result.deposit_name}">
							</td>
							<th class="text-right">업종</th>
							<td>
								<select class="form-control" id="biz_type_cd" name="biz_type_cd">
									<c:forEach var="item" items="${codeMap['BIZ_TYPE']}">
										<option value="${item.code_value}"<c:if test="${result.biz_type_cd eq item.code_value }"> selected="selected"</c:if>>${item.code_name}</option>
									</c:forEach>
								</select>
							</td>
						</tr>
						<tr>
							<th class="text-right">마케팅대상</th>
							<td colspan="3">
								<input type="text" class="form-control" placeholder="" id="sales_maker_cd" name="sales_maker_cd" value="" readonly="readonly">
							</td>
						</tr>
						<tr>
							<c:choose>
								<c:when test="${'PERSON' eq result.cust_group_cd || 'ITEM' eq result.cust_group_cd}">
									<th class="text-right essential-item">고객담당</th>
									<td colspan="3">
										<div class="form-row inline-pd">
											<div class="col-auto essential-item spacing-sm">
												지역
											</div>
											<div class="col-2">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 essential-bg" id="area_si" name="area_si" value="${result.area_si}"  required="required" readonly="readonly" alt="고객담당 지역">
													<input type="hidden" id="sale_area_code" name="sale_area_code" value="${result.sale_area_code}">
													<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchSaleAreaPanel('setSaleAreaInfo');"><i class="material-iconssearch"></i></button>
												</div>
											</div>
											<div class="col-auto essential-item spacing-sm">
												담당센터
											</div>
											<div class="col-2">
												<input type="text" class="form-control essential-bg" id="center_org_name" name="center_org_name" value="${result.center_org_name}"  required="required" readonly="readonly" alt="고객담당 센터">
												<input type="hidden" id="center_org_code" name="center_org_code">
											</div>
											<div class="col-auto essential-item spacing-sm">
												서비스담당
											</div>
											<div class="col-2">
												<input type="text" class="form-control essential-bg" id="service_mem_name" name="service_mem_name" value="${result.service_mem_name}"  required="required" readonly="readonly" alt="고객담당 서비스 직원">
												<input type="hidden" id="service_mem_no" name="service_mem_no">
											</div>
											<div class="col-auto spacing-sm">
												미수담당
											</div>
											<div class="col-2">
												<div class="input-group">
													<input type="text" class="form-control border-right-0" id="misu_mem_name" name="misu_mem_name" value="${result.misu_mem_name}" readonly="readonly">
													<input type="hidden" id="misu_mem_no" name="misu_mem_no" value="${result.misu_mem_no}">
													<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchMemberPanel('fnSetMemberInfo');"><i class="material-iconssearch"></i></button>
												</div>
											</div>
										</div>
									</td>
								</c:when>
								<c:otherwise>
									<th class="text-right">고객담당</th>
									<td colspan="3">
										<div class="form-row inline-pd">
											<div class="col-auto spacing-sm">
												지역
											</div>
											<div class="col-2">
												<div class="input-group">
													<input type="text" class="form-control border-right-0" id="area_si" name="area_si" value="${result.area_si}" readonly="readonly" alt="고객담당 지역">
													<input type="hidden" id="sale_area_code" name="sale_area_code" value="${result.sale_area_code}">
													<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchSaleAreaPanel('setSaleAreaInfo');"><i class="material-iconssearch"></i></button>
												</div>
											</div>
											<div class="col-auto spacing-sm">
												담당센터
											</div>
											<div class="col-2">
												<input type="text" class="form-control" id="center_org_name" name="center_org_name" value="${result.center_org_name}" readonly="readonly" alt="고객담당 센터">
												<input type="hidden" id="center_org_code" name="center_org_code">
											</div>
											<div class="col-auto spacing-sm">
												서비스담당
											</div>
											<div class="col-2">
												<input type="text" class="form-control" id="service_mem_name" name="service_mem_name" value="${result.service_mem_name}" readonly="readonly" alt="고객담당 서비스 직원">
												<input type="hidden" id="service_mem_no" name="service_mem_no">
											</div>
											<div class="col-auto spacing-sm">
												미수담당
											</div>
											<div class="col-2">
												<div class="input-group">
													<input type="text" class="form-control border-right-0" id="misu_mem_name" name="misu_mem_name" value="${result.misu_mem_name}" readonly="readonly">
													<input type="hidden" id="misu_mem_no" name="misu_mem_no" value="${result.misu_mem_no}">
													<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchMemberPanel('fnSetMemberInfo');"><i class="material-iconssearch"></i></button>
												</div>
											</div>
										</div>
									</td>
								</c:otherwise>
							</c:choose>
							<th class="text-right">보유기종</th>
							<td colspan="3">
								<input type="text" class="form-control" placeholder="" id="cust_maker_cd" name="cust_maker_cd" value="" readonly="readonly">
							</td>
						</tr>
						<tr>
							<th class="text-right">고객분류2</th>
							<td>
								<div class="form-check form-check-inline">
									<input class="form-check-input custSaleType" type="radio" id="cust_sale_type_cd_00" name="cust_sale_type_cd" value="00" ${result.dp_cust_sale_type_cd == '00' ? 'checked="checked"' : ''} ${result.dp_cust_sale_type_cd == '40' ? 'disabled' : ''}>
									<label class="form-check-label" for="cust_sale_type_cd_00">일반</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input custSaleType" type="radio" id="cust_sale_type_cd_10" name="cust_sale_type_cd" value="10" ${result.dp_cust_sale_type_cd == '10'? 'checked="checked"' : ''} ${result.dp_cust_sale_type_cd == '40' ? 'disabled' : ''}>
									<label class="form-check-label" for="cust_sale_type_cd_10">모니터</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input custSaleType" type="radio" id="cust_sale_type_cd_20" name="cust_sale_type_cd" value="20" ${result.dp_cust_sale_type_cd == '20'? 'checked="checked"' : ''} ${result.dp_cust_sale_type_cd == '40' ? 'disabled' : ''}>
									<label class="form-check-label" for="cust_sale_type_cd_20">서브딜러</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input custSaleType" type="radio" id="cust_sale_type_cd_40" name="cust_sale_type_cd" value="${result.cust_sale_type_cd}" ${result.dp_cust_sale_type_cd == '40' ? 'checked="checked"' : ''} disabled="disabled">
									<%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체 --%>
									<%-- <label class="form-check-label" for="cust_sale_type_cd_40">대리점</label>--%>
									<label class="form-check-label" for="cust_sale_type_cd_40">위탁판매점</label>
								</div>
							</td>
							<th class="text-right">앱사용여부</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-auto">
										<c:out value="${result.app_info_str}"></c:out>
									</div>
									<input type="hidden" id="app_use_yn" name="app_use_yn" value="${result.app_use_yn}">
									<c:if test = "${result.app_use_yn eq 'Y'}">
										<div class="col-auto">
											<button type="button" class="btn btn-primary-gra" id="btnGoAppCustDetail" name="btnGoAppCustDetail" onclick="javascript:goAppCustDetail();">앱고객정보 상세</button>
											<input type="hidden" id="app_cust_no" name="app_cust_no" value="${result.app_cust_no}">
										</div>
									</c:if>
								</div>

							</td>
							<th class="text-right">쿠폰잔액</th>
							<td colspan="3">
								<div class="form-row inline-pd">
									<div class="col-2.5">
										<input type="text" class="form-control text-right width120px" id="coupon_amt" name="coupon_amt" readonly="readonly" format="num" value="${result.coupon_amt}">
									</div>
									<div class="col-auto">
										<button type="button" class="btn btn-default" style="width: 80px;" onclick="javascript:fnCouponPopup();">쿠폰상세보기</button>
									</div>
								</div>
							</td>
						</tr>
					<tr>
						<th class="text-right">장비용도</th>
						<td>
							<c:out value="${result.mch_use_str}"></c:out>
						</td>
						<th class="text-right">마케팅구분</th>
						<td>
							<div class="row" style="margin-left:1px;">
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" id="sale_type_c" name="sale_type_ca" value="C" <c:if test="${result.sale_type_ca eq 'C'}">checked="checked"</c:if>>
									<label class="form-check-label" for="sale_type_c">건설기계</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" id="sale_type_a" name="sale_type_ca" value="A" <c:if test="${result.sale_type_ca eq 'A'}">checked="checked"</c:if>>
									<label class="form-check-label" for="sale_type_a">농기계</label>
								</div>
							</div>
						</td>
						<th class="text-right">주기장주소</th>
						<td colspan="3">
							<div class="form-row inline-pd">
								<div class="col-auto pdr0">
									<input type="text" class="form-control mw45 width60px" id="curr_post_no" name="curr_post_no" readonly="readonly" alt="고객주소" value="${result.curr_post_no}">
								</div>
								<div class="col-auto pdl5">
									<button type="button" class="btn btn-primary-gra" style="width: 100%;" id="addr"onclick="javascript:openSearchAddrPanel('fnJusoCurr');">주소찾기</button>
								</div>
								<div class="col-5">
									<input type="text" class="form-control" id="curr_addr1" name="curr_addr1" readonly="readonly" value="${result.curr_addr1}">
								</div>
								<div class="col-4">
									<input type="text" class="form-control" id="curr_addr2" name="curr_addr2" value="${result.curr_addr2}">
								</div>
							</div>
						</td>
					</tr>
					<tr>
						<th class="text-right">지정(중고)딜러여부</th>
						<td>
							<div class="form-check form-check-inline">
								<input class="form-check-input dealerYn" type="radio" id="dealer_y" name="dealer_yn" value="Y" alt="" <c:if test="${result.dealer_yn eq 'Y'}">checked="checked"</c:if>>
								<label class="form-check-label" for="dealer_y">Y</label>
							</div>
							<div class="form-check form-check-inline">
								<input class="form-check-input dealerYn" type="radio" id="dealer_n" name="dealer_yn" value="N" alt="" <c:if test="${result.dealer_yn eq 'N'}">checked="checked"</c:if>>
								<label class="form-check-label" for="dealer_n">N</label>
							</div>
						</td>
						<th class="text-right">주요관리업체</th>
						<td>
							<div class="form-check form-check-inline">
								<input class="form-check-input mainMngYn" type="radio" id="main_mng_y" name="main_mng_yn" value="Y" alt=""
									   <c:if test="${result.main_mng_yn eq 'Y'}">checked="checked"</c:if>
									   <c:if test="${empty result.main_mng_yn}">disabled</c:if>>
								<label class="form-check-label" for="main_mng_y">Y</label>
							</div>
							<div class="form-check form-check-inline">
								<input class="form-check-input mainMngYn" type="radio" id="main_mng_n" name="main_mng_yn" value="N" alt=""
									   <c:if test="${result.main_mng_yn eq 'N'}">checked="checked"</c:if>
									   <c:if test="${empty result.main_mng_yn}">disabled</c:if>>
								<label class="form-check-label" for="main_mng_n">N</label>
							</div>
                        </td>
						<th class="text-right">서비스충성도</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width120px">
									<select class="form-control" id="svc_loyal_cd" name="svc_loyal_cd">
										<option value="">- 선택 -</option>
										<c:forEach var="item" items="${codeMap['SVC_LOYAL']}">
											<option value="${item.code_value}"<c:if test="${item.code_value eq result.svc_loyal_cd}"> selected="selected"</c:if>>${item.code_name}</option>
										</c:forEach>
									</select>
								</div>
								<div class="col-auto">
									<button type="button" class="btn btn-primary-gra" onclick="javascript:goLoyaltyPopup();">충성도보기</button>
								</div>
							</div>
						</td>
						<th class="text-right">
							<div class="form-check form-check-inline" style="margin-right: -5px;">
								<label class="form-check-label mr5">고객앱 법인인증</label>
								<input class="form-check-input" type="checkbox" id="appCorAuthYn" name="appCorAuthYn" onchange="javascript:fnSetAppCorAuth();"
									   value="${result.app_cor_auth_yn}" ${result.app_cor_auth_yn eq 'Y'? 'checked="checked"' : ''}>
								<input type="hidden" id="app_cor_auth_yn" name="app_cor_auth_yn" value="${result.app_cor_auth_yn}">
							</div>
						</th>
						<td>
							<div class="form-row inline-pd">
								<div class="col-auto">
									<div class="input-group">
										<input type="text" id="cor_hp_no" name="cor_hp_no" class="form-control border-right-0" placeholder="숫자만 입력" format="phone" alt="법인휴대폰" value="${result.cor_hp_no}" maxlength="11"
											${result.app_cor_auth_yn eq 'Y'? '' : 'disabled'} onchange="javascript:fnCorHpDuplCheck();">
										<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnOpenSmsPanel('cor');"><i class="material-iconsforum"></i></button>
									</div>
								</div>
								<div class="col-auto">
									<button type="button" class="btn btn-primary-gra btn-cancel" id="corHpDuplic" name="corHpDuplic" <c:if test="${result.app_cor_auth_yn eq 'N' or result.cor_hp_no ne ''}">disabled='disabled'</c:if> onclick="javascript:goCorHpDuplCheck();">중복체크</button>
									<input type="hidden" id="corHpDuplicCheck" name="corHpDuplicCheck" <c:if test="${result.app_cor_auth_yn eq 'N' or result.cor_hp_no ne '' }">value="Y"</c:if>>
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
					<div class="left text-warning ml5" style="width:70%;">
					※ 동의 철회는 마케팅부(신정애, 이미영)에 문의하세요.
					</div>
					<div class="right text-secondary">마케팅 활용 미 동의 시 광고/홍보문자 발송불가!</div>
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
									<input class="form-check-input" type="checkbox" id="personalYn" name="personalYn"
										   onchange="javascript:fnPersonalChange('personal')"; ${result.personal_edit_yn ne 'Y'? 'disabled="true"' : ''}
										   value="${result.personal_yn}" ${result.personal_yn == 'Y'? 'checked="checked"' : ''}>
									<input type="hidden" id="personal_yn" name="personal_yn" value="${result.personal_yn}">
								</div>
							</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-1 text-right">확인일자</div>
									<div class="col-1">
										<div class="input-group">
											<input type="text" class="form-control border-right-0 calDate" id="personal_dt" name="personal_dt" dateFormat="yyyy-MM-dd" value="${result.personal_dt}" readonly="readonly" onchange="fnPersonalDateChange('personal')">
										</div>
									</div>
									<div class="col-1 text-right">확인자</div>
									<div class="col-1">
										<input type="text" class="form-control" id="personal_mem_name" name="personal_mem_name" value="${result.personal_mem_name}"  readonly="readonly">
										<input type="hidden" class="form-control" id="personal_mem_no" name="personal_mem_no" value="${result.personal_mem_no}">
									</div>
									<div class="col-1 text-right">수집구분</div>
									<div class="col-1">
										<select class="form-control" id="personal_collect_cd" name="personal_collect_cd" onchange="fnPersonalCollectChange('personal')">
											<c:forEach var="personal" items="${codeMap['PERSONAL_COLLECT']}">
												<option value="${personal.code_value}"<c:if test="${result.personal_collect_cd eq personal.code_value }"> selected="selected"</c:if>>${personal.code_name}</option>
											</c:forEach>
										</select>
									</div>
									<div class="col-1"></div>
									<c:if test = "${result.privacy_file_seq ne '' and result.privacy_file_seq ne null}">
										<div class="col-4">동의서파일:
											<a style="text-decoration: underline; color: blue;" href="javascript:goFile('${result.privacy_file_seq}')" >${result.privacy_file_name}</a>
											<c:if test="${result.modu_modify_yn eq 'Y'}">(수정중)</c:if>
										</div>
									</c:if>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">
								<div class="form-check form-check-inline">
									<label class="form-check-label mr5">제3자 정보제공동의</label>
									<input class="form-check-input" type="checkbox"id="threeYn" name="threeYn"
										   onchange="javascript:fnPersonalChange('three');" ${result.three_edit_yn ne 'Y'? 'disabled="true"' : ''}
										   value="${result.three_yn}" ${result.three_yn == 'Y'? 'checked="checked"' : ''}>
									<input type="hidden" id="three_yn" name="three_yn" value="${result.three_yn}">
								</div>
							</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-1 text-right">확인일자</div>
									<div class="col-1">
										<div class="input-group">
											<input type="text" class="form-control border-right-0 calDate" id="three_dt" name="three_dt" dateFormat="yyyy-MM-dd" value="${result.three_dt}"  readonly="readonly" onchange="fnPersonalDateChange('three')">
										</div>
									</div>
									<div class="col-1 text-right">확인자</div>
									<div class="col-1">
										<input type="text" class="form-control" id="three_mem_name" name="three_mem_name" value="${result.three_mem_name}"  readonly="readonly">
										<input type="hidden" class="form-control" id="three_mem_no" name="three_mem_no" value="${result.three_mem_no}">
									</div>
									<div class="col-1 text-right">수집구분</div>
									<div class="col-1">
										<select class="form-control" id="three_collect_cd" name="three_collect_cd" onchange="fnPersonalCollectChange('three')">
											<c:forEach var="three" items="${codeMap['THREE_COLLECT']}">
												<option value="${three.code_value}"<c:if test="${result.three_collect_cd eq three.code_value }"> selected="selected"</c:if>>${three.code_name}</option>
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
									<input class="form-check-input" type="checkbox" id="marketingYn" name="marketingYn"
										   value="${result.marketing_yn}" ${result.marketing_edit_yn ne 'Y'? 'disabled="true"' : ''}
										   onchange="javscript:fnPersonalChange('marketing')" ${result.marketing_yn == 'Y'? 'checked="checked"' : ''} >
									<input type="hidden" id="marketing_yn" name="marketing_yn" value="${result.marketing_yn}">
								</div>
							</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-1 text-right">확인일자</div>
									<div class="col-1">
										<div class="input-group">
											<input type="text" class="form-control border-right-0 calDate" id="marketing_dt" name="marketing_dt" dateFormat="yyyy-MM-dd" value="${result.marketing_dt}" readonly="readonly" onchange="fnPersonalDateChange('marketing')">
										</div>
									</div>
									<div class="col-1 text-right">확인자</div>
									<div class="col-1">
										<input type="text" class="form-control" id="marketing_mem_name" name="marketing_mem_name" value="${result.marketing_mem_name}"  readonly="readonly">
										<input type="hidden" class="form-control" id="marketing_mem_no" name="marketing_mem_no" value="${result.marketing_mem_no}">
									</div>
									<div class="col-1 text-right">수집구분</div>
									<div class="col-1">
										<select class="form-control" id="marketing_collect_cd" name="marketing_collect_cd" onchange="fnPersonalCollectChange('marketing')">
											<c:forEach var="marketing" items="${codeMap['MARKETING_COLLECT']}">
												<option value="${marketing.code_value}"<c:if test="${result.marketing_collect_cd eq marketing.code_value }"> selected="selected"</c:if>>${marketing.code_name}</option>
											</c:forEach>
										</select>
									</div>
<%--									<div class="col-1"></div>--%>
<%--									<div class="col-3">--%>
<%--										<div class="form-check form-check-inline">--%>
<%--											<input class="form-check-input" type="checkbox" id="tel" name="marketing_check" ${result.marketing_edit_yn ne 'Y'? 'disabled="true"' : ''}--%>
<%--												   <c:if test="${result.tel_yn eq 'Y'}">value="${result.tel_yn}" ${result.tel_yn == 'Y'? 'checked' : ''}</c:if>>--%>
<%--											<input type="hidden" id="tel_yn" name="tel_yn">--%>
<%--											<label class="form-check-label" for="tel">전화</label>--%>
<%--										</div>--%>
<%--										<div class="form-check form-check-inline">--%>
<%--											<input class="form-check-input" type="checkbox" id="sms" name="marketing_check" ${result.marketing_edit_yn ne 'Y'? 'disabled="true"' : ''}--%>
<%--												   <c:if test="${result.sms_yn eq 'Y'}">value="${result.sms_yn}" ${result.sms_yn == 'Y'? 'checked' : ''}</c:if>>--%>
<%--											<input type="hidden" id="sms_yn" name="sms_yn">--%>
<%--											<label class="form-check-label" for="sms">SMS</label>--%>
<%--										</div>--%>
<%--										<div class="form-check form-check-inline">--%>
<%--											<input class="form-check-input" type="checkbox" id="email_check" name="marketing_check" ${result.marketing_edit_yn ne 'Y'? 'disabled="true"' : ''}--%>
<%--												   <c:if test="${result.email_yn eq 'Y'}">value="${result.email_yn}" ${result.email_yn == 'Y'? 'checked' : ''}</c:if>>--%>
<%--											<input type="hidden" id="email_yn" name="email_yn">--%>
<%--											<label class="form-check-label" for="email_check">이메일</label>--%>
<%--										</div>--%>
<%--										<div class="form-check form-check-inline">--%>
<%--											<input class="form-check-input" type="checkbox" id="dm" name="marketing_check" ${result.marketing_edit_yn ne 'Y'? 'disabled="true"' : ''}--%>
<%--												   <c:if test="${result.dm_yn eq 'Y'}">value="${result.dm_yn}" ${result.dm_yn == 'Y'? 'checked' : ''}</c:if>>--%>
<%--											<input type="hidden" id="dm_yn" name="dm_yn">--%>
<%--											<label class="form-check-label" for="dm">우편발송</label>--%>
<%--										</div>--%>
<%--									</div>--%>
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
								<input type="text" class="form-control text-right" id="max_misu_amt" name="max_misu_amt" value="${result.max_misu_amt}" format="decimal">
							</td>
							<th class="text-right">관리번호</th>
							<td>
								<div class="input-group">
									<input type="text" class="form-control border-right-0" name="machine_doc_no" value="${result.machine_doc_no}" readonly="readonly">
									<button type="button" class="btn btn-icon btn-primary-gra" onclick="goControlNoPopup();"><i class="material-iconssearch"></i></button>
								</div>
							</td>
							<th class="text-right">거래명세서</th>
							<td>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="checkbox" id="misu_print" name="misu_print" value="${result.misu_print_yn}" ${result.misu_print_yn == 'Y'? 'checked="checked"' : ''}>
									<input type="hidden" id="misu_print_yn" name="misu_print_yn">
									<label class="form-check-label">미수금 인쇄안함</label>
								</div>
							</td>
							<th class="text-right">업체명인쇄</th>
							<td>
								<c:forEach var="print" items="${codeMap['COM_NAME_PRINT']}">
									<input type="radio" name="com_name_print_cd" value="${print.code_value}"<c:if test="${result.com_name_print_cd eq print.code_value }"> checked="checked"</c:if>/>${print.code_name}
								</c:forEach>
							</td>
							<th class="text-right">사용여부</th>
							<td>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" name="use_yn" value="Y" <c:if test="${result.use_yn eq 'Y' }"> checked="checked"</c:if>>
									<label class="form-check-label">사용</label>
									<input type="hidden" id="use_yn" name="use_yn">
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" name="use_yn" value="N" <c:if test="${result.use_yn eq 'N' }"> checked="checked"</c:if>>
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
							<th class="text-right">회계거래처코드</th>
							<td>
								<input type="text" class="form-control" id="account_link_cd" name="account_link_cd" value="${result.account_link_cd}">
							</td>
							<th class="text-right">SMS발송여부</th>
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
<%--						<li>일반회원 : 필수사항 입력 및 전화번호 중복체크 시 이상 없는 고객</li>--%>
<%--						<li>준회원 : YK건기에서 인증번호를 부여하여 본인확인을 하는 회원</li>--%>
					</ul>
					<br>
					<div class="title">
						<i class="material-iconserror font-16"></i>
						<span>고객등급정책</span>
					</div>
					<ul>
						<c:forEach var="code" items="${codeMap['CUST_GRADE']}">
							<li>${code.code_name} : ${code.code_desc}</li>
						</c:forEach>
<%--						<li>A : 자사 판매 장비 3대 이상 보유한 고객</li>--%>
<%--						<li>B : 자사 판매 장비 2대 보유한 고객</li>--%>
<%--						<li>C : 자사 판매 장비 1대 보유</li>--%>
<%--						<li>F : 거래 신용 문제로 주의해야 할 악성 고객</li>--%>
<%--						<li>N : New 의 약자로 신차 구매 가능성 있는 신규 안건 등록 고객</li>--%>
<%--						<li>E : Exchange 의 약자로 자사 장비 혹은 타사 장비를 가지고 있지만 장비를 곧 교체할 가능성이 있는 고객</li>--%>
<%--						<li>Z : 타사 장비를 가지고 있는 고객으로 시장 내 관리가 필요한 고객</li>--%>
<%--						<li>R : Rental 의 약자로 렌탈 이용 고객</li>--%>
<%--						<li>T : NEZR을 제외한 고객(기본고객)</li>--%>
<%--						<li>H : 2년간 한번도 매출이 발생하지 않은 고객</li>--%>
<%--						<li>BL : 블랙리스트(진상고객)</li>--%>
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
<!-- /팝업 -->
</form>
</body>
</html>
