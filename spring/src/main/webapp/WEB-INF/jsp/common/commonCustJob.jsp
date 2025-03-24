<%@ page pageEncoding="UTF-8"%><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><c:set var="btnList" value="${btnAuthMap[param.pos] }"/>
<%--
고객번호 필드 : s_cust_no   
	### param 설명 ###
<jsp:param name="required_field" value="s_cust_no"/>	==> 필수체크 할 필드 (value에 해당하는 name을 찾아서 required 속성 추가)
(팝업포함 검색조건)
<jsp:param name="execFuncName" value="fnMyExecFuncName"/>	==> 응답받을 function명
<jsp:param name="focusInFuncName" value="myFocusInFunc"/>	==> 포커스 인 됐을때 실행할 function명
<jsp:param name="__s_cust_no" value="20130603145119670"/> ==> 필수 파라미터 (고객관련)
<jsp:param name="__s_body_no" value="4CR2-20627"/> ==> 필수 파라미터 (장비관련)
<jsp:param name="__s_machine_seq" value="42973"/> ==> 필수 파라미터 (장비관련)
<jsp:param name="jobType" value="C"/>				==> 타입 구분할 필수 파라미터(고객:C, 부품:P, 장비:B)
<jsp:param name="__s_cust_name" value="장현석"/>			==> 문자발송 시 보낼 파라미터goTaxBill
<jsp:param name="__s_hp_no" value="01066003545"/>		==> 문자발송 시 보낼 파라미터
<jsp:param name="li_type" value="__check_required#__sms_info"/>		==> 필요 list 파라미터
--%>
<c:set var="liType" value="${param.li_type}"/>

<script>
	$(document).ready(function() {
        var liObj = {
            '__ledger' : '<li onclick="javascript:goLedger();">거래원장</li>',
            '__sms_popup' : '<li onclick="javascript:goSmsPopup();">문자발송</li>',
            '__sms_info' : '<li onclick="javascript:goSendSmsInfo();">문자발송내역</li>',
            '__visit_history' : '<li onclick="javascript:goVisitHistory();">방문일지</li>',
            '__check_required' : '<li onclick="javascript:goCheckRequired();">거래시 필수확인사항(정비추천)</li>',
            '__cust_dtl' : '<li onclick="javascript:goCustomerDetail();">고객대장</li>',
            '__as_call_dtl' : '<li onclick="javascript:goAsCallDetail();">전화상담일지</li>',
            '__as_call' : '<li onclick="javascript:goAsCall();">전화상담작성</li>',
            '__deal_specification_popup' : '<li onclick="javascript:goDealSpecification();">거래명세서</li>',
            '__tax_bill' : '<li onclick="javascript:goTaxBill();">세금계산서</li>',
            '__deposit' : '<li onclick="javascript:goDepositStatus();">입금현황</li>',
            '__refused' : '<li onclick="javascript:goRefused();">반려자료</li>',
            '__ars' : '<li onclick="javascript:goArsRequest();">ARS결제요청</li>',
            '__part_sale' : '<li onclick="javascript:goPartSale();">수주등록</li>',
            '__job_report' : '<li onclick="javascript:__goJobReport();">정비지시서</li>',
            '__have_machine_cust' : '<li onclick="javascript:goHaveMachineCust();">보유기종</li>',
            '__as' : '<li onclick="javascript:goAs();">수리내역</li>',
            '__machine_doc' : '<li onclick="javascript:goMachineDoc();">계약품의서</li>',
            '__ars_request' : '<li onclick="javascript:goArsRequest();">ARS결제</li>',
            '__cust_rental_history' : '<li onclick="goCustRentalHistory()">고객렌탈이력</li>',
            '__rental_consult_history' : '<li onclick="goRentalConsultHistory()">렌탈상담이력(방문일지)</li>',
        };

        var liTypeArr = "${liType}".split("#");
        var createHtml = "";

        createHtml += '	<button type="button" class="btn btn-primary-gra" id="">연관업무<i class="material-iconsexpand_more text-primary"></i></button>';
        createHtml += '	<div class="con-info dropdown-content drop-dev common-cust-job">';
        createHtml += '		<ul id="" class="">';
        for(var i in liTypeArr) {
            createHtml += liObj[liTypeArr[i]];
        }
        createHtml += '		</ul>';
        createHtml += '	</div>';
        $("#__cust_job_type").append(createHtml);
	});
	
	function goMachineDoc() {
		var machineDocNo = $M.getValue("__s_machine_doc_no");
		var params = {
			"machine_doc_no" : machineDocNo
		};
		var popupOption = "";
        $M.goNextPage('/sale/sale0101p01', $M.toGetParam(params), {popupStatus : popupOption});
	}
	
	// 수리내역
    function goAs() {
  	
        // 보낼 데이터
//         var custNo = $M.getValue("__s_cust_no");
//         var params = {
//             "s_cust_no" : custNo
//         };
        
     // 보낼 데이터
        var machineSeq = $M.getValue("__s_machine_seq");
        var params = {
            "s_machine_seq" : machineSeq,
            "s_cust_no" : $M.getValue("__s_cust_no")
        };
        
        var popupOption = "";
        $M.goNextPage('/comp/comp0506', $M.toGetParam(params), {popupStatus : popupOption});
    }
	
	function goRefused() {
	    var param = {
			"machine_doc_no" : $M.getValue("__s_machine_doc_no")
		}
	    alert("반려자료");
	    /* var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=750, left=0, top=0";
		$M.goNextPage('/cust/cust0102p01/', $M.toGetParam(param), {popupStatus : poppupOption}); */
	}

	// 입금현황
	function goDepositStatus() {
	    var param = {
			"machine_doc_no" : $M.getValue("__s_machine_doc_no")
		}
	    var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1100, height=750, left=0, top=0";
		$M.goNextPage('/cust/cust0301p01', $M.toGetParam(param), {popupStatus : popupOption});
	}
	
	// 거래명세서
	function goDealSpecification() {
		alert("거래명세서");
	}
	
	function _goTaxBill() {
		alert("세금계산서");	
	}
	
	// 전화상담일지 상세
    function goAsCallDetail() {
        var params = [{}];
        var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=840, left=0, top=0";
        $M.goNextPage('/serv/serv0102p06', $M.toGetParam(params), {popupStatus : popupOption});
    }

    // 전화상담일지 등록
    function goAsCall() {
        var params = {};

        var machineSeq = $M.getValue("__s_machine_seq");
        if(machineSeq != "") {
            params.s_machine_seq = machineSeq;
        }

        var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=840, left=0, top=0";
        $M.goNextPage('/serv/serv0102p13', $M.toGetParam(params), {popupStatus : popupOption});
    }

	// 고객대장
	function goCustomerDetail() {
	    var custNo = $M.getValue("__s_cust_no");
	    var saleYn = $M.getValue("__s_sale_yn");
	    if(custNo == '' && saleYn == "Y") {
	        alert("고객명을 검색해서 입력해주세요.");
	        return false;
        } else if (custNo == '' && saleYn == ""){
	        alert("차주명을 조회를 먼저 진행해주세요.");
	        return false;
        	
        }
	    var param = {
				"cust_no" : custNo
		}
		var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=750, left=0, top=0";
		$M.goNextPage('/cust/cust0102p01/', $M.toGetParam(param), {popupStatus : poppupOption});
    }

	// ARS결제 팝업
	function goArsRequest() { 
		var custNo = $M.getValue("__s_cust_no");
        if(custNo == '') {
            alert("고객 조회를 먼저 진행해주세요.");
            return;
        }

		var param = {
				"s_cust_no" : custNo
			};
		
		openSearchArsRequest($M.toGetParam(param));
	}
	// 거래원장 팝업
	function goLedger() { 
		var custNo = $M.getValue("__s_cust_no");
        if(custNo == '') {
            alert("고객 조회를 먼저 진행해주세요.");
            return;
        }

		var param = {
				"s_cust_no" : custNo
			};
		
		openDealLedgerPanel($M.toGetParam(param));
	}
	
	// 문자발송 팝업
	function goSmsPopup() {
		var custName = $M.getValue("__s_cust_name");
		var hpNo = $M.getValue("__s_hp_no");
		var reqMsgYn = $M.getValue("__s_req_msg_yn");
		var menuSeq  = $M.getValue("__s_menu_seq");
		var menuParam = $M.getValue("__s_menu_param");
        var misuYn = $M.getValue("__s_misu_yn");
        var custNo = $M.getValue("__s_cust_no");
        var partSaleNo = $M.getValue("__s_part_sale_no");

		//메세지참조기능 사용시 사용메뉴seq,파라미터도 세팅		
		if(reqMsgYn == "Y"){
			var param = {
					   'name' 		 : custName, 
					   'hp_no' 		 : hpNo,
					   'req_msg_yn'  : reqMsgYn,
					   'menu_seq'	 : menuSeq,
					   'menu_param'  : menuParam,
                       'cust_no'     : custNo,
                       'part_sale_no' : partSaleNo
			   }
		}
		else {
			var param = {
					   'name' : custName, 
					   'hp_no' : hpNo
			   }
		}

        if(misuYn == "Y") {
            param.misu_yn = "Y";
            param.cust_no = custNo;
        }

		openSendSmsPanel($M.toGetParam(param));
	}
	
	// 문자발송내역조회 팝업
	function goSendSmsInfo() {
		var param = {
			phone_no : $M.getValue("__s_hp_no"),
			receiver_name : $M.getValue("__s_cust_name"),
		}
		openSearchSendSMSPanel('setSendSMSInfo', $M.toGetParam(param));
	}
	
	// 문자 발송 조회 결과값 callback
// 	function setSendSMSInfo(data) {
// 		alert("문자발송조회");
// 	}
	
	// 방문일지 팝업
	function goVisitHistory() {
		var custNo = $M.getValue("__s_cust_no");
        if(custNo == '') {
            alert("고객 조회를 먼저 진행해주세요.");
            return;
        }

		var param = {
				"cust_no" : custNo
			};
		var poppupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1100, height=520, left=0, top=0";
		$M.goNextPage('/serv/serv0101p04', $M.toGetParam(param), {popupStatus : poppupOption});
	}
	
	 // 거래시필수확인사항
    function goCheckRequired() {
        var custNo = $M.getValue("__s_cust_no");
        if(custNo == "") {
            alert("고객 조회를 먼저 진행해주세요.");
            return;
        }

        var param = {
            "cust_no" : custNo
        };

		 openCheckRequiredPanel('setCheckRequired', $M.toGetParam(param));
    }

    // ARS결제요청
	function goArsRequest() {
	    var custNo = $M.getValue("__s_cust_no");
	    if(custNo == "") {
	        alert("고객조회를 먼저 진행해주세요.");
	        return;
        }

        var param = {
            "cust_no" : custNo
        };

        var poppupOption = "scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=375, height=340, left=0, top=0";
        $M.goNextPage('/comp/comp0703', $M.toGetParam(param), {popupStatus : poppupOption});
    }

    // 수주등록
    function goPartSale() {
        var popupOption = "";
        var params = {
            "s_popup_yn" : "Y"
        };

        $M.goNextPage('/cust/cust020101', $M.toGetParam(params), {popupStatus : popupOption});
    }

    // 정비지시서 등록
    function __goJobReport() {
        var popupOption = "";
        var params = {
            "s_popup_yn" : "Y"
        };

        $M.goNextPage('/serv/serv010101', $M.toGetParam(params), {popupStatus : popupOption});
    }

    // 보유기종 팝업
	  function goHaveMachineCust() {
		  var param = {
			  "cust_no"  	: $M.getValue("__s_cust_no")
		  }
		  openHaveMachineCustPanel($M.toGetParam(param));
	  }
    
	// 거래시 필수확인사항 조회 결과값 callback
// 	function setCheckRequired(data) {
// 		alert("거래시 필수확인사항 결과값");
// 	}

    // 고객렌탈이력 팝업
    function goCustRentalHistory() {
        const param = {
            "s_cust_no" : $M.getValue("__s_cust_no")
        }
        openCustRentalHistoryPanel($M.toGetParam(param));
    }

    // 렌탈상담이력(방문일지) 팝업
    function goRentalConsultHistory() {
        const param = {
            "s_cust_no" : $M.getValue("__s_cust_no")
        }
        openRentalConsultHistoryPanel($M.toGetParam(param));
    }

</script>

<input type="hidden" id="__s_cust_no" name="__s_cust_no" />
<input type="hidden" id="__s_cust_name" name="__s_cust_name" />
<input type="hidden" id="__s_hp_no" name="__s_hp_no" />
<input type="hidden" id="__s_req_msg_yn" name="__s_req_msg_yn" />
<input type="hidden" id="__s_menu_seq" name="__s_menu_seq" />
<input type="hidden" id="__s_menu_param" name="__s_menu_param" />
<input type="hidden" id="__s_sale_yn" name="__s_sale_yn" />


<div id="__cust_job_type" class="dropdown"></div>