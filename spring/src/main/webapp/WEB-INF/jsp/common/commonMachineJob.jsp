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
<jsp:param name="__s_machine_doc_no" value="2020-0106-01"/> ==> 필수 파라미터 (장비관련)
<jsp:param name="li_type" value="__check_required#__sms_info"/>		==> 필요 list 파라미터
--%>
<c:set var="liMachineType" value="${param.li_machine_type}"/>

<script>
	$(document).ready(function() {
        var liObj = {
            '__body_no' : '<li onclick="javascript:goCustMakerMachine();">차대번호</li>',
            '__machine_detail' : '<li onclick="javascript:goMachineDetail();">장비대장</li>',
            '__repair_history' : '<li onclick="javascript:goRepairHistory();">수리내역</li>',
            '__machine_ledger' : '<li onclick="javascript:goMachineLedger();">장비원장</li>',
            '__as_todo' : '<li onclick="javascript:goAsTodo();">미결사항</li>',
            '__campaign' : '<li onclick="javascript:goCampaign();">리콜확인</li>',
            '__rental' : '<li onclick="javascript:goRental();">운영이력조회</li>',
            '__machine_doc_detail' : '<li onclick="javascript:goMachineDocDetail();">품의서조회</li>',
            '__check_required' : '<li onclick="javascript:goCheckRequired();">거래시 필수확인사항</li>',
            '__change_cust_history' : '<li onclick="javascript:__goChangeCustHistory();">장비차주변경이력</li>',
            '__change_cust' : '<li onclick="javascript:__goChangeCust();">장비차주변경</li>',
            '__repair_amt' : '<li onclick="javascript:goRepairAmt();">수리금액</li>',
            '__work_db' : '<li onclick="javascript:goWorkDB();">업무DB</li>',
        };

        var liMachineTypeArr = "${liMachineType}".split("#");
        var createHtml = "";

        createHtml += '	<button type="button" class="btn btn-primary-gra" id="">연관업무<i class="material-iconsexpand_more text-primary"></i></button>';
        createHtml += '	<div class="con-info dropdown-content drop-dev common-machine-job">';
        createHtml += '		<ul id="" class="">';
        for(var i in liMachineTypeArr) {
            createHtml += liObj[liMachineTypeArr[i]];
        }
        createHtml += '		</ul>';
        createHtml += '	</div>';
        $("#__machine_job_type").append(createHtml);
	});

	// 전화상담일지
    function goAsCallDetail() {
        var params = [{}];
        var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=840, left=0, top=0";
        $M.goNextPage('/serv/serv0102p06', $M.toGetParam(params), {popupStatus : popupOption});
    }

	// 장비대장
    function goMachineDetail() {
        var machineSeq = $M.getValue("__s_machine_seq");
        if(machineSeq == '') {
            alert("차대번호 조회를 먼저 진행해주세요.");
            return;
        }

        // 보낼 데이터
        var params = {
            "s_machine_seq" : machineSeq
        };
        var popupOption = "scrollbars=no, resizable-1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1700, height=800, left=0, top=0";
        $M.goNextPage('/sale/sale0205p01', $M.toGetParam(params), {popupStatus : popupOption});
    }
	
    // 수리내역
    function goRepairHistory() {
        // 보낼 데이터
        var machineSeq = $M.getValue("__s_machine_seq");
        var params = {
            "s_machine_seq" : machineSeq
        };

        var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1400, height=920, left=0, top=0";
        $M.goNextPage('/comp/comp0506', $M.toGetParam(params), {popupStatus : popupOption});
    }
	
    // 수리금액
    function goRepairAmt() {
        var params = {
            "s_body_no" : $M.getValue("__s_body_no"),
            "s_job_yn" : "Y",
    		"parent_js_name" : "fnSetReportInfo",
    		"s_job_status_cd" : ""
        };

		var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1000, height=400, left=0, top=0";
		$M.goNextPage('/cust/cust0202p03', $M.toGetParam(params), {popupStatus : popupOption});
    }
    
    // 장비원장
    function goMachineLedger() {
        alert("장비원장");
    }
    
    // 미결사항
    function goAsTodo() {

        var regType = $M.getValue("__s_reg_type");
        var menuType = $M.getValue("__s_menu_type");
        if(regType == "I" && menuType == "S") {
            alert("저장 후 조회 가능합니다.");
            return;
        }

        var machineSeq = $M.getValue("__s_machine_seq");
        if(machineSeq == '') {
            alert("차대번호 조회를 먼저 진행해주세요.");
            return;
        }

        var params = {
            "__s_machine_seq" : machineSeq,
            "__s_as_no" : $M.getValue("as_no"),
            "__page_type" : $M.nvl($M.getValue("page_type"), "N"),
            "parent_js_name" : "fnSetJobOrder"
        };
        var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=450, left=0, top=0";
        $M.goNextPage('/serv/serv0101p07', $M.toGetParam(params), {popupStatus : popupOption});
    }
    
    // 리콜확인
    function goCampaign() {
        var machineSeq = $M.getValue("__s_machine_seq");
        if(machineSeq == '') {
            alert("차대번호 조회를 먼저 진행해주세요.");
            return;
        }

        var params = {
            "__s_machine_seq" : machineSeq,
        };
        var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=500, left=0, top=0";
        $M.goNextPage('/serv/serv0101p06', $M.toGetParam(params), {popupStatus : popupOption});
    }


	
	// 보유기종 팝업
	function goCustMakerMachine() {
		var custNo = $M.getValue("__s_cust_no");
		var param = {
				"cust_no" : custNo
			};
		var poppupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1100, height=520, left=0, top=0";
		$M.goNextPage('/comp/comp0503', $M.toGetParam(param), {popupStatus : poppupOption});
	}

	// 운영이력 팝업
	function goRental() {
		var machineSeq = $M.getValue("__s_machine_seq");
		var param = {
				"machine_seq" : machineSeq
			};
		var poppupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1100, height=420, left=0, top=0";
		$M.goNextPage('/rent/rent0201p04', $M.toGetParam(param), {popupStatus : poppupOption});
	}

	// 품의서 팝업
	function goMachineDocDetail() {
		var machineDocNo = $M.getValue("__s_machine_doc_no");
		var param = {
				"machine_doc_no" : machineDocNo
			};
		var poppupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1400, height=920, left=0, top=0";
		$M.goNextPage('/sale/sale0101p01', $M.toGetParam(param), {popupStatus : poppupOption});
	}

	// 출하이력조회
    function goSaleList() {
        var poppupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=930, left=0, top=0";
        $M.goNextPage('/sale/sale0101p09', '', {popupStatus : poppupOption});
    }

    // 거래시필수확인사항
    function goCheckRequired() {
        var custNo = $M.getValue("__s_cust_no");
        if(custNo == "") {
            alert("고객조회를 먼저 진행해주세요.");
            return;
        }

        var param = {
            "cust_no" : custNo
        };

        openCheckRequiredPanel('setCheckRequired', $M.toGetParam(param));
    }

    // 장비차주변경이력 조회
    function __goChangeCustHistory() {
        var popupOption = "";
        var params = {
            "s_popup_yn" : "Y",
            "body_no" : $M.getValue("body_no")
        };

        $M.goNextPage('/cust/cust0103', $M.toGetParam(params), {popupStatus : popupOption});
    }

    // 장비차주변경
    function __goChangeCust() {
        var orgType = $M.getValue("org_type");
//         var jobCd = $M.getValue("job_cd");
        // (Q&A 16324) 직책 -> 직급으로 변경. 2022-09-23 김상덕.
        var gradeCd = $M.getValue("grade_cd");
        var jobAuthCdArray = "${SecureUser.job_auth_cd_array}";
        // 최승희 대리님 문의. 직급, 직책 수습사원인데 센터매니저로 인해 추가. 210705 김상덕
        var isJobAuthCenterAcnt = jobAuthCdArray.indexOf("CENTER_ACNT") != -1;

        // 본사, 기사, 주임, 매니저, 직장만 권한 부여
        if(orgType != "BASE" && (gradeCd != "03" && gradeCd != "05" && gradeCd != "08" && gradeCd != "09") && !isJobAuthCenterAcnt) {
            alert("차주변경 권한이 없습니다.");
            return;
        }

        var machineSeq = $M.getValue("machine_seq");
        if(machineSeq == '') {
            alert("장비 조회를 먼저 진행해주세요.");
            return;
        }

        var pageType = $M.getValue("__page_type");
        if(pageType == "J" && $M.getValue("job_status_cd") == "9") {
            alert("완료된 정비지시서에서 차주변경은 불가능합니다.");
            return;
		}

        var popupOption = "";
        var params = {
			"s_machine_seq" : $M.getValue("machine_seq"),
			"job_report_no" : $M.getValue("job_report_no"),
			"page_type" : $M.getValue("__page_type"),
			"parent_js_name" : "fnSetMachineCust"
		};
		
        $M.goNextPage('/cust/cust0103p01', $M.toGetParam(params), {popupStatus : popupOption});
    }
    
    // 업무DB 오픈
    function goWorkDB(){
    	var machineSeq = $M.getValue("machine_seq");
    	if(machineSeq == ''){
    		alert("장비 조회를 먼저 진행해주세요.");
    		return;
    	}
    	
    	openWorkDBPanel(machineSeq);
    }
</script>

<input type="hidden" id="__s_cust_no" name="__s_cust_no" />
<input type="hidden" id="__s_machine_doc_no" name="__s_machine_doc_no" />
<input type="hidden" id="__s_machine_seq" name="__s_machine_seq" />
<input type="hidden" id="__s_body_no" name="__s_body_no" />
<div id="__machine_job_type" class="dropdown"></div>