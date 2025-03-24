<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 업무접수현황 > 업무접수현황 상세 > null
-- 작성자 : 박동훈
-- 최초 작성일 : 2024-12-06 12:54:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript" src="/static/js/qrcode.min.js"></script>
</head>
<script type="text/javascript">
	$(document).ready(function() {

		$(".serviceType").hide();
		$(".rentalType").hide();

		$("input[name='self_assign_type_cd']").change(function(){
			if($('input[name=self_assign_type_cd]:checked').val() == ("01") ) {
				$(".serviceType").show();
				$(".rentalType").hide();
				$("#reserve_repair_st_ti").prop("disabled",false);
				$("#reserve_repair_ed_ti").prop("disabled",false);
				$("#in_dt").prop("disabled",false);
				if($M.getValue('reserve_repair_st_ti') == '' && $M.getValue('reserve_repair_ed_ti') == ''){
					setRepairTime();
				}
				$("#selectMachineBtn").prop("disabled",false);
				var selfAssignBean = ${selfAssignBean};
				$M.setValue("__s_machine_seq",selfAssignBean.machine_seq);
				$M.setValue("machine_seq",selfAssignBean.machine_seq);
				$M.setValue("body_no",selfAssignBean.body_no);
				$M.setValue("machine_name",selfAssignBean.machine_name);
				$("#btnRentalMachineInfo").addClass("dpn");
			} else {
				$(".rentalType").show();
				$(".serviceType").hide();
				$("#reserve_repair_st_ti").prop("disabled",true);
				$("#reserve_repair_ed_ti").prop("disabled",true);
				$M.setValue("reserve_repair_st_ti",null);
				$M.setValue("reserve_repair_ed_ti",null);
				$("#in_dt").prop("disabled",true);
				$M.setValue("in_dt",null);
				$("#selectMachineBtn").prop("disabled",true);
				$M.setValue("__s_machine_seq",null);
				$M.setValue("machine_seq",null);
				$M.setValue("body_no",null);
				$M.setValue("machine_name",null);
				$("#btnRentalMachineInfo").removeClass("dpn");
			}
			$("#self_assign_type_cd_3").prop("disabled",true);
			$("#self_assign_type_cd_4").prop("disabled",true);
		});
		fnInit();
	});

	function setRepairTime(){
		var nowT = $M.getCurrentDate("HH");
		var nowM = $M.toNum($M.getCurrentDate("mm"));

		if(nowM <= 30) {
			$M.setValue("reserve_repair_st_ti", nowT + "30");
			$M.setValue("reserve_repair_ed_ti", nowT + "30");
		} else {
			$M.setValue("reserve_repair_st_ti", $M.lpad($M.toNum(nowT)+1, 2, "0") + "00");
			$M.setValue("reserve_repair_ed_ti", $M.lpad($M.toNum(nowT)+1, 2, "0") + "00");
		}
	}

	//렌탈가능장비 리스트 팝업 호출
	function goRentReg() {
		if($M.getValue("assign_mem_no") == ""){ alert("배정자를 먼저 선택해주세요."); return false;}
		var popupOption = "";
		var params = {
			"s_popup_yn": "Y",
			"s_self_assign_no" : $M.getValue("self_assign_no"),
			"s_machine_seq" : $M.getValue("machine_seq"),
			"s_cust_no" : $M.getValue("cust_no")
		};

		$M.goNextPage('/mmyy/mmyy0114p03', $M.toGetParam(params), {popupStatus: popupOption});
	}

	//장비지시서 등록페이지 호출
	function goServReg() {
		if($M.getValue("assign_mem_no") == ""){ alert("배정자를 먼저 선택해주세요."); return false;}
		var popupOption = "";
		var params = {
			"s_popup_yn": "Y",
			"s_self_assign_no" : $M.getValue("self_assign_no"),
			"s_cust_no" : $M.getValue("cust_no")
		};

		$M.goNextPage('/serv/serv010101', $M.toGetParam(params), {popupStatus: popupOption});
	}
	//장비지시서 등록페이지 뷰페이지 호출
	function goServView(jobReportNo) {

		var params = {
			"s_popup_yn": "Y",
			"s_job_report_no": jobReportNo,
			"s_self_assign_no" : $M.getValue("self_assign_no")
		};
		var popupOption = "";
		$M.goNextPage('/serv/serv0101p01', $M.toGetParam(params), {popupStatus: popupOption});
	}

	function goServAsView(jobReportNo , asNo) {

		var params = {
			"s_popup_yn": "Y",
			"s_as_no": asNo,
			"s_job_report_no" : jobReportNo,
		};
		var popupOption = "";
		$M.goNextPage('/serv/serv0102p01', $M.toGetParam(params), {popupStatus: popupOption});
	}

	function goRentView(rentalDocNo,rentalStatusCd,extendYn){
		var assign_same_yn = "Y";
		if($M.getValue("assign_mem_no") != "${SecureUser.mem_no}"){ assign_same_yn = "N";}
		if (rentalDocNo != "") {
			var params = {
				"s_popup_yn": "Y",
				"rental_doc_no": rentalDocNo,
				"assign_same_yn" : assign_same_yn,
				"s_self_assign_no" : $M.getValue("self_assign_no")
			};
			var popupOption = "scrollbars=no, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=730, left=0, top=0";
			if("01,02,03".indexOf(rentalStatusCd) > -1 ){
				$M.goNextPage('/rent/rent0101p01', $M.toGetParam(params), {popupStatus: popupOption});
			}else {
				if (extendYn == "Y") {
					$M.goNextPage('/rent/rent0102p02', $M.toGetParam(params), {popupStatus : popupOption});
				} else {
					$M.goNextPage('/rent/rent0102p01', $M.toGetParam(params), {popupStatus : popupOption});
				}
			}
		}
	}

	//차대번호 조회
	function selectMachineSeq(){
		var param = {
			"s_cust_name" : $M.getValue("cust_name"),
			"s_hp_no" : $M.getValue("hp_no"),
		};
		openSearchDeviceHisPanel('fnSetInformation',$M.toGetParam(param));
	}

	function fnSetInformation(data) {
		fnSetInformation(data, 'N');
	}

	// 차대번호, 차주명 조회
	function fnSetInformation(data, initYn) {

		var custNo = data.cust_no;
		if(custNo == "" || custNo == null) {
// 				alert("고객이 등록되어 있지 않은 장비입니다.\n고객을 먼저 등록해주세요.");
// 				return;
			custNo = "20060727140532287";
		}

		var param = {
			"s_machine_seq" : data.machine_seq,
			"s_cust_no" : custNo
		};

		$M.goNextPageAjax("/serv/serv010101/search", $M.toGetParam(param), {method : 'GET'},
				function (result) {
					if(result.success) {
						dataSetting(result, initYn);
					}
				}
		);
	}

	// 장비, 고객 정보 Setting
	function dataSetting(result, initYn) {
		var item = result.custBean;
		var jobReposrtNo = result.machineBean.before_job_report_no;
		var custGradeHandCdStr = item.cust_grade_hand_cd_str;

		$M.setValue("cust_grade_hand_cd_str", custGradeHandCdStr);
		if (custGradeHandCdStr.indexOf("03") != -1) {
			alert("거래금지 고객입니다. 확인후 진행해주세요.");
			return false;
		}
		if (custGradeHandCdStr.indexOf("04") != -1) {
			alert("그레이장비 보유 고객입니다. 정비전에 확인 바랍니다.");
		}
		// 21.08.03 (SR:12096) 미수금이있거나, 외상매출금지고객에 문구 알림 추가. - 황빛찬
		// 21.08.04 (SR:12145) YK렌탈장비는 알림 제외 추가 - 황빛찬
		if (item.cust_no != "20130603145119670" && (item.deal_gubun_cd == "9" || item.misu_amt > 0)) {
			alert("외상매출금지(미수고객)입니다. 정비전에 확인 바랍니다.");
		}

		if(jobReposrtNo != "") {
			alert("해당 차대번호(" + result.machineBean.body_no + ")로\n[" + jobReposrtNo + "]정비지시서가\n미완료 상태입니다. \n해당 정비지시서를 먼저 완료해주세요.");
			return false;
		}

		// 장비관련
		$M.setValue(result.machineBean);
		$M.setValue("__s_machine_seq", result.machineBean.machine_seq);

		// 고객정보
		$M.setValue(result.custBean);

		goSave();
	}

	// 고객조회 결과 - 견적서 관리에서 등록할 경우 정보를 불러옴
	function fnSetCustInfo(row) {
		$M.goNextPageAjax("/rent/custInfo/"+row.cust_no, "", {method : 'GET'},
				function(result) {
					if(result.success) {
						var custGradeHandCdStr = result.cust_grade_hand_cd_str;
						$M.setValue("cust_grade_hand_cd_str", custGradeHandCdStr);
						if (custGradeHandCdStr.indexOf("03") != -1) {
							alert("거래금지 고객입니다. 확인후 진행해주세요.");
							return false;
						}
						if (custGradeHandCdStr.indexOf("04") != -1) {
							alert("그레이장비 보유 고객입니다. 렌탈신청 전에 확인 바랍니다.");
						}

						var param = {
							hp_no : $M.phoneFormat(result.hp_no),
							cust_no : result.cust_no,
							cust_name : result.cust_name,
							body_no : '',
							machine_seq : '',
							machine_name : '',
							__s_machine_seq : '',
						}
						$M.setValue(param);

						//고객 선택시 차대번호 셋팅
						if(row.machine_seq != "" && $M.getValue("self_assign_type_cd") == "01"){
							fnSetInformation(row,'N');
						}
						goSearchPrivacyAgree();
					}
				}
		);
	}

	// 개인정보동의 팝업
	function goSearchPrivacyAgree() {
		var param = {
			cust_no: $M.getValue("cust_no")
		}
		$M.goNextPageAjax("/comp/comp0306/search", $M.toGetParam(param), {method: 'get'},
				function (result) {
					if (result.success) {
						var custInfo = result.custInfo;
						if (custInfo.personal_yn != "Y") {
							if (confirm("개인정보 동의사항을 확인하세요") == true) {
								openPrivacyAgreePanel('fnSetPrivacy', $M.toGetParam(param));
							}
						}
					}
				}
		);
	}


	// 배정취소
	function fnAssignCancel(){

		if($M.getValue("assign_mem_no") == ""){ alert("배정자를 먼저 선택해주세요."); return false;}
		if($M.getValue("assign_mem_no") != "${SecureUser.mem_no}"){ alert("배정자만 배정 취소할 수 있습니다."); return false;}

		var msg = "배정 취소 하시겠습니까?";
		var params = {
			"s_self_assign_no" : $M.getValue("self_assign_no"),
			"s_job_report_no" : $M.getValue("job_report_no")
		}
		$M.goNextPageAjaxMsg(msg, this_page + "/assignCancel", $M.toGetParam(params), {method: 'POST'},
				function (result) {
					if (result.success) {
						alert("배정 취소 되었습니다.");
						location.reload();
					}
				}
		);
	}

	//삭제
	function goRemove(){
		var params = {
			"self_assign_no" : $M.getValue("self_assign_no")
		}
		var msg = "삭제하시겠습니까?";
		$M.goNextPageAjaxMsg(msg, this_page + "/remove",  $M.toGetParam(params), {method: 'POST'},
				function (result) {
					if (result.success) {
						alert("삭제 되었습니다.");
						window.close();
					}
				}
		);
	}
	// 저장
	function goSave() {
		var frm = document.main_form;
		//validationcheck
		if($M.validation(frm, {field:["self_assign_no", "cust_no", "org_code", "consult_text"]})==false) {return false;};

		if($M.getValue("self_assign_type_cd") == ""){ alert("접수 분류를 선택해주세요."); return false;}

		if("${selfAssign.assign_mem_no}" != ""){

			if("${selfAssign.assign_mem_no}" != "${SecureUser.mem_no}" && "${page.fnc.F06045_001}" != "Y"){ alert("배정자, 업무관리자, 정비관리자만 저장 할 수 있습니다."); return false;}
		}
		frm = $M.toValueForm(document.main_form);
		var msg = "저장하시겠습니까?";
		$M.goNextPageAjaxMsg(msg, this_page + "/modify", frm, {method: 'POST'},
				function (result) {
					if (result.success) {
						alert("저장이 완료되었습니다.");
						location.reload();
					}
				}
		);
	}
	function fnClose() {
		window.close();
	}

    function goComplete(){
		$("#_goComplete").removeAttr("onclick");
		$("#_goComplete").attr("onclick", "goCompleteConfirm()");
		$("#confirmTextTr").show();
		alert("처리 결과를 작성 한 후 완결 처리를 눌러주세요.");
		$("#confirm_text").focus;
	}

	function goCompleteConfirm(){
		if($M.getValue("confirm_text").replaceAll(" ","") == "" ){alert("처리 결과를 작성 한 후 완결 처리를 눌러주세요."); return false;}
		$M.setValue("self_assign_proc_date", $M.getCurrentDate("yyyy-MM-dd HH:mm:ss"));
		$M.setValue("job_confirm_yn", "Y");
		var frm = document.main_form;
		frm = $M.toValueForm(document.main_form);
		var msg = "완결 처리 하시겠습니까?";
		$M.goNextPageAjaxMsg(msg, this_page + "/modify", frm, {method: 'POST'},
				function (result) {
					if (result.success) {
						alert("저장이 완료되었습니다.");
						location.reload();
					}
				}
		);
	}

	// 배정직원 Setting
	function setMemberOrgMapPanel(data) {
		var assignMemNo = data.mem_no;
		$M.setValue("assign_mem_no", assignMemNo);
		$M.setValue("assign_date", $M.getCurrentDate("yyyy-MM-dd HH:mm:ss"))
	}

	// 초기 셋팅
	function fnInit() {
		var selfAssignBean = ${selfAssignBean};
		$M.setValue("reg_dt", $M.dateFormat(new Date(selfAssignBean.reg_date), "yyyy년 MM월 dd일 / HH:mm"));

		if (selfAssignBean.self_assign_type_cd == '01') {
			$("#self_assign_type_cd_1").click();
		} else if (selfAssignBean.self_assign_type_cd == '02') {
			$("#self_assign_type_cd_2").click();
		} else if (selfAssignBean.self_assign_type_cd == '03') {
			$("#self_assign_type_cd_3").click();
		} else if (selfAssignBean.self_assign_type_cd == '04') {
			$("#self_assign_type_cd_4").click();
		}
		$M.setValue("assign_mem_no", selfAssignBean.assign_mem_no);
		$M.setValue("___mem_name", selfAssignBean.assign_mem_name);
		$M.setValue("__s_machine_seq", selfAssignBean.machine_seq);

		if ($M.getValue("assign_mem_no") != "") {
			$M.setValue("selfAssignStatus", "배정완료");
			$("#goPick").prop("disabled", true);
		} else {
			$("#_fnAssignCancel").hide();
		}

		$M.setValue("consult_text", selfAssignBean.consult_text);
		if(selfAssignBean.job_confirm_yn == "Y"){
			$M.setValue("confirm_text", selfAssignBean.confirm_text);
			$("#confirm_text").prop("disabled",true);
			$("#confirmTextTr").show();
		}
		if (selfAssignBean.self_assign_proc_date != "" && selfAssignBean.self_assign_proc_date != undefined) {
			fncProcDisabled();
			$M.setValue("complete_dt", $M.dateFormat(new Date(selfAssignBean.self_assign_proc_date), "yyyy년 MM월 dd일 / HH:mm"));
		}
		if (selfAssignBean.job_report_no != "") {
			fncDisabled();
			$(".serviceType").show();
			$("#servBtn1").removeAttr("onclick");
			$("#servBtn1").attr("onclick", "goServView('" + selfAssignBean.job_report_no + "')");
			$("#servBtn1").text(selfAssignBean.job_report_no);
			$M.setValue("job_report_no", selfAssignBean.job_report_no);
		}
		if (selfAssignBean.as_no != "" && selfAssignBean.as_count > 0) {
			fncDisabled();
			$(".serviceType").show();
			$("#servBtn2").removeAttr("onclick");
			$("#servBtn2").attr("onclick", "goServAsView('" + selfAssignBean.job_report_no + "','" + selfAssignBean.as_no + "')");
			$("#servBtn2").text(selfAssignBean.as_no);
		} else {
			$("#servBtn2").hide();
		}
		if (selfAssignBean.rental_doc_no != "") {
			fncDisabled();
			$(".rentalType").show();
			$("#rentBtn1").removeAttr("onclick");
			$("#rentBtn1").attr("onclick", "goRentView('" + selfAssignBean.rental_doc_no + "','" + selfAssignBean.rental_status_cd + "','" + selfAssignBean.extend_yn + "')");
			$("#rentBtn1").text(selfAssignBean.rental_doc_no);
		}

		<c:forEach var="custFile" items="${custFileList}">
			fnPrintFile('${custFile.file_seq}', '${custFile.file_name}', 'C');
		</c:forEach>
	}

	function fncDisabled() {
		$("#in_dt").prop("disabled", true);
		$("#_goSearchCust").prop("disabled", true);
		$("#selectMachineBtn").prop("disabled", true);
		$("input[name='self_assign_type_cd']").prop("disabled",true);
		$("#_goRemove").hide();
		$("#_fnAssignCancel").hide();
		$("#_goComplete").hide();
	}

	function fncProcDisabled(){
		fncDisabled();
		$("#consult_text").prop("disabled",true);
		$("#reserve_repair_st_ti").prop("disabled",true);
		$("#reserve_repair_ed_ti").prop("disabled",true);
		$("button[name='__mem_search_btn']").prop("disabled",true);
		$("#_goSave").hide();
		$(".serviceType").hide();
		$(".rentalType").hide();
		$M.setValue("selfAssignStatus","처리완료" );
		$("#goPick").prop("disabled", true);
	}

	function fnShowFile(type) {
		var fileArr = [];
		$("[name=att_file_seq"+type+"]").each(function () {
			fileArr.push($(this).val());
		});
		if(type == 'C' && fileArr.length == 0) {
			alert("고객신청 시 업로드된 파일이 없습니다.");
			return;
		}
		if(fileArr.length == 0 && '${result.repair_complete_yn}' == 'Y') {
			alert("서비스 일지가 완결되어 업로드 불가합니다.");
			return;
		} else if (fileArr.length == 0) {
			alert("파일추가 후 다시 시도해주세요.");
			return;
		}
		var param = {
			"file_seq_str" : $M.getArrStr(fileArr),
		}
		openFileImagePanel($M.toGetParam(param));
	}

	// 배정직원 Setting
	function fnPick() {
		if($M.getValue("assign_mem_no") != ""){
			alert("배정자가 있습니다. 배정 이관 또는 배정 취소 후에 찜 하실 수 있습니다.");
			return false;
		}else {
			if($M.getValue("self_assign_org_code") != "${SecureUser.org_code}"){
				alert("타 센터 업무는 찜 하실 수 없습니다.");
				return false;
			}

			$M.setValue("assign_mem_no", "${SecureUser.mem_no}");
			$M.setValue("assign_name", "${SecureUser.user_name}");
			$M.setValue("assign_date", $M.getCurrentDate("yyyy-MM-dd HH:mm:ss"));

			var msg = "찜 하시겠습니까?";
			var params = {
				"s_self_assign_no": $M.getValue("self_assign_no"),
				"assign_date" : $M.getValue("assign_date"),
				"s_job_report_no" : $M.getValue("job_report_no")
			};
			var popupOption = "";
			$M.goNextPageAjaxMsg(msg,'/mmyy/mmyy0114/assignUpdate', $M.toGetParam(params), {popupStatus: popupOption},
					function (result) {
						isLoading = false;
						if (result.success) {
							window.location.reload();
						}
					});
		}
	}

	// 첨부파일 출력 (멀티)
	function fnPrintFile(fileSeq, fileName, type) {
		var str = '';
		str += '<div class="table-attfile-item att_file_' + fileSeq + ' fileDiv'+ type +'"style="float:left; display:block;">';
		str += '<a href="javascript:fileDownload(' + fileSeq + ');" style="color: blue; vertical-align: middle;">' + fileName + '</a>&nbsp;';
		str += '<input type="hidden" name="att_file_seq'+ type +'" value="' + fileSeq + '"/>';
		<%--if(${result.repair_complete_yn ne 'Y'} && type != "C") {--%>
		<%--	str += '<button type="button" class="btn-default check-dis" onclick="javascript:fnRemoveFile(' + fileSeq + ')"><i class="material-iconsclose font-18 text-default"></i></button>';--%>
		<%--}--%>

		str += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
		str += '</div>';
		$('.att_file_div'+type).append(str);
	}

	// 첨부파일 삭제
	// function fnRemoveFile(fileSeq) {
	// 	if (confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.")) {
	// 		$(".att_file_" + fileSeq).remove();
	// 		removeFileArr.push(fileSeq);
	// 	} else {
	// 		return false;
	// 	}
	// }

	// 3-5차 렌탈가능장비조회 팝업 호출 (ERP > 렌탈 > 렌탈신청현황 조회 메뉴 팝업으로 호출)
	function fnRentalMachineList() {
		if ($M.getValue("self_assign_type_cd") != '01') {
			$M.goNextPage('/rent/rent0101', $M.toGetParam({}), {popupStatus : ""});
		} else {
			alert("렌탈건만 확인 가능합니다.");
		}
	}

</script>
<body>
<form id="main_form" name="main_form">
<input type="hidden" name="upt_id" id="upt_id" value="${SecureUser.mem_no}">
<input type="hidden" name="org_code" id="org_code" value="${SecureUser.org_code}">
<input type="hidden" name="self_assign_org_code" id="self_assign_org_code" value="${selfAssign.self_assign_org_code}">
<input type="hidden" name="assign_mem_no" id="assign_mem_no">
<input type="hidden" name="assign_date" id="assign_date">
<input type="hidden" name="complete_date" id="complete_date">
<input type="hidden" id="page_type" name="page_type" value="JOB_REPORT">
<input type="hidden" id="s_job_report_no" name="s_job_report_no">
<input type="hidden" id="job_report_no" name="job_report_no">
<input type="hidden" id="s_as_no" name="s_as_no">
<input type="hidden" id="machine_seq" name="machine_seq">
<input type="hidden" id="self_assign_proc_date" name="self_assig_proc_date">
<input type="hidden" id="job_confirm_yn" name="job_confirm_yn" value="N">
<input type="hidden" id="cust_grade_hand_cd_str" name="cust_grade_hand_cd_str"> <%--거래 금지 고객--%>
<input type="hidden" id="c_rental_request_seq" name="c_rental_request_seq" value="${selfAssign.c_rental_request_seq}">
<input type="hidden" id="c_job_request_seq" name="c_job_request_seq" value="${selfAssign.c_job_request_seq}">

	<div class="popup-wrap width-100per">
		<!-- 상세페이지 타이틀 -->
		<div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
		</div>
		<!-- /상세페이지 타이틀 -->
		<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div>
				<div class="title-wrap">
					<div class="left text-warning">
						${sar_error_msg }
					</div>
					<div class="right half-print">
						<div class="form-row inline-pd pr">
							<div class="col-auto" id="qr_image" name="qr_image">
								<input type="hidden" id="qr_no" name="qr_no">
							</div>
							<%--<span class="condition-item mr5">상태 : 작성중</span>--%>
							<div class="col-auto">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
				</div>
				<div class="row mt10">
					<!-- 1. 장비정보 -->
					<div class="col-6">
						<table class="table-border mt5">
							<colgroup>
								<col width="100px">
								<col width="200px">
								<col width="100px">
								<col width="260px">
								<col width="100px">
								<col width="200px">
							</colgroup>
							<tbody>
							<tr>
								<th class="text-right">접수번호</th>
								<td>
									<input type="text" id="self_assign_no" name="self_assign_no" class="form-control" readonly="readonly" value="${selfAssign.self_assign_no}">
								</td>
								<th class="text-right">접수일시</th>
								<td>
									<input type="text" id="reg_dt" name="reg_dt" class="form-control" readonly="readonly">
								</td>
								<th class="text-right">접수센터</th>
								<td>
									<input type="text" id="org_name" name="org_name" class="form-control" readonly="readonly" required="required" alt="센터" value="${selfAssign.self_assign_org_name}">
								</td>
							</tr>
							<tr>
								<th class="text-right">접수구분</th>
								<td>
									<input type="text" class="form-control" name="self_assign_gubun_name" id="self_assign_gubun_name" readonly="readonly" value="${selfAssign.self_assign_gubun_name}">
								</td>
								<th class="text-right essential-item">접수분류</th>
								<td>
									<div class="form-check form-check-inline v-align-middle" style="margin: unset">
										<input class="form-check-input" type="radio" id="self_assign_type_cd_1" name="self_assign_type_cd" value="01"  >
										<label for="self_assign_type_cd_1" class="form-check-label">정비</label>
									</div>
									<div class="form-check form-check-inline v-align-middle" style="margin: unset">
										<input class="form-check-input" type="radio" id="self_assign_type_cd_2" name="self_assign_type_cd" value="02"  >
										<label  for="self_assign_type_cd_2"  class="form-check-label">렌탈계약</label>
									</div>
									<div class="form-check form-check-inline v-align-middle" style="margin: unset">
										<input class="form-check-input" type="radio" id="self_assign_type_cd_3" name="self_assign_type_cd" value="03" >
										<label  for="self_assign_type_cd_3"  class="form-check-label">렌탈출고</label>
									</div>
									<div class="form-check form-check-inline v-align-middle" style="margin: unset">
										<input class="form-check-input" type="radio" id="self_assign_type_cd_4" name="self_assign_type_cd" value="04" >
										<label  for="self_assign_type_cd_4"  class="form-check-label">렌탈회수</label>
									</div>
								</td>
								<th class="text-right">정비구분</th>
								<td>
									<input type="text" class="form-control" name="job_type_name" id="job_type_name" readonly="readonly" value="${selfAssign.job_type_name}">
								</td>
							</tr>
							<tr>
								<th class="text-right">접수자</th>
								<td>
									<input type="text" class="form-control" name="reg_name" id="reg_name" readonly="readonly" value="${selfAssign.reg_mem_name}">
								</td>
								<th class="text-right rs essential-item">고객명</th>
								<td>
									<div class="row">
										<div class="col-auto">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 width100px" id="cust_name" name="cust_name" readonly="readonly" required="required" alt="고객명" value="${selfAssign.cust_name}">
												<input type="hidden" id="cust_no" name="cust_no" value="${selfAssign.cust_no}" alt="고객명">
												<button type="button" class="btn btn-icon btn-primary-gra"  onclick="javascript:openSearchCustPanel('fnSetCustInfo');" id="_goSearchCust" name="_goSearchCust"><i class="material-iconssearch" ></i></button>
												&nbsp;&nbsp;<button type="button" class="btn btn-primary-gra" id="btnRentalMachineInfo" name="btnRentalMachineInfo" onclick="javascript:fnRentalMachineList();">렌탈가능장비</button>
											</div>
										</div>
									</div>
								</td>
								<th class="text-right">연락처</th>
								<td>
									<input type="text" class="form-control" readonly="readonly" id="hp_no" name="hp_no" value="${selfAssign.cust_hp_no}" format="tel">
								</td>
							</tr>
							<tr>
								<th class="text-right">배정자</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-7">
											<input type="text" class="form-control" id="assign_name" name="assign_name" value="${selfAssign.assign_mem_name}" readonly="readonly">
										</div>
										<div class="col-3 text-right">
											<button type="button" class="btn btn-primary-gra" id="goPick" onclick="fnPick()">찜하기</button>
										</div>
									</div>
								</td>
								<th class="text-right">차대번호</th>
								<td>
									<div class="form-row inline-pd pr">
										<div class="col-8">
											<div class="input-group">
												<input type="text" id="body_no" name="body_no" class="form-control border-right-0 essential-bg" value="${selfAssign.body_no}" readonly="readonly" required="required" alt="차대번호">
												<button type="button" class="btn btn-icon btn-primary-gra" id="selectMachineBtn" onclick="javascript:selectMachineSeq();" ><i class="material-iconssearch"></i></button>
											</div>
										</div>
										<div class="col-4">
											<jsp:include page="/WEB-INF/jsp/common/commonMachineJob.jsp">
												<jsp:param name="li_machine_type" value="__machine_detail#__repair_history#__as_todo#__campaign#__work_db"/>
											</jsp:include>
										</div>
									</div>
								</td>
								<th class="text-right">모델명</th>
								<td>
									<input type="text" class="form-control" id="machine_name" name="machine_name" value="${selfAssign.machine_name}" readonly="readonly">
								</td>
							</tr>
							<tr>
								<th class="text-right">배정 이관</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-auto">
											<jsp:include page="/WEB-INF/jsp/common/searchMem.jsp">
												<jsp:param name="required_field" value=""/>
												<jsp:param name="s_org_code" value=""/>
												<jsp:param name="s_work_status_cd" value=""/>
												<jsp:param name="readonly_field" value=""/>
												<jsp:param name="execFuncName" value="setMemberOrgMapPanel"/>
											</jsp:include>
										</div>
									</div>
								</td>
								<th class="text-right">입고일자</th>
								<td>
									<div class="input-group width160px">
										<input type="text" class="form-control border-right-0 calDate" id="in_dt" name="in_dt" dateFormat="yyyy-MM-dd" value="${selfAssign.in_dt}">
									</div>
								</td>
								<th class="text-right">정비예약시간</th>
								<td>
									<div class="form-row">
										<div class="col-5">
											<select class="form-control" id="reserve_repair_st_ti" name="reserve_repair_st_ti">
												<c:forEach var="hr" varStatus="i" begin="6" end="23" step="1">
													<c:forEach var="min" varStatus="j" begin="0" end="1">
														<option value="<c:if test="${hr < 10}">0</c:if><c:out value="${hr}"/><c:out value="${min eq 0 ? '00' : '30'}"/>"
																<c:if test="${fn:substring(selfAssign.reserve_repair_st_ti,0,2) eq (hr < 10 ? '0' + hr : hr) and fn:substring(selfAssign.reserve_repair_st_ti,2,4) eq (min eq 0 ? '00' : '30')}">selected="selected"</c:if>>
															<c:if test="${hr < 10}">0</c:if><c:out value="${hr}"/>:<c:out value="${min eq 0 ? '00' : '30'}"/>
														</option>
													</c:forEach>
												</c:forEach>
											</select>
										</div>
										~
										<div class="col-5">
											<select class="form-control" id="reserve_repair_ed_ti" name="reserve_repair_ed_ti">
												<c:forEach var="hr" varStatus="i" begin="6" end="23" step="1">
													<c:forEach var="min" varStatus="j" begin="0" end="1">
														<option value="<c:if test="${hr < 10}">0</c:if><c:out value="${hr}"/><c:out value="${min eq 0 ? '00' : '30'}"/>"
																<c:if test="${fn:substring(selfAssign.reserve_repair_ed_ti,0,2) eq (hr < 10 ? '0' + hr : hr) and fn:substring(selfAssign.reserve_repair_ed_ti,2,4) eq (min eq 0 ? '00' : '30')}">selected="selected"</c:if>>
															<c:if test="${hr < 10}">0</c:if><c:out value="${hr}"/>:<c:out value="${min eq 0 ? '00' : '30'}"/>
														</option>
													</c:forEach>
												</c:forEach>
											</select>
										</div>
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right">상태</th>
								<td colspan="5">
									<input type="text" class="form-control" readonly="readonly" id="selfAssignStatus" name="selfAssignStatus" placeholder="미 배정">
								</td>
							</tr>
							<tr>
								<th class="text-right essential-item">접수 내용</th>
								<td colspan="5">
									<textarea class="form-control" style="height: 100px;" id="consult_text" name="consult_text" alt="접수내용"></textarea>
								</td>
							</tr>
							<c:if test="${!empty selfAssign.c_job_request_seq}">
								<tr>
									<th class="text-right">고객희망시간</th>
									<td>
										<input type="text" class="form-control" alt="고객희망시간" value="${selfAssign.request_date}" disabled>
									</td>
									<th class="text-right">고장증상</th>
									<td>
										<input type="text" class="form-control" alt="고장증상" value="${selfAssign.c_mch_break_name}" disabled>
									</td>
									<th class="text-right" rowspan="2">고장내용</th>
									<td rowspan="2">
										<textarea class="form-control" style="height: 75px;" disabled>${selfAssign.request_text}</textarea>
									</td>
								</tr>
								<tr>
									<th class="text-right">출장요청지역</th>
									<td>
										<input type="text" class="form-control" alt="출장요청지역" value="${selfAssign.cust_travel_area}" disabled>
									</td>
									<th class="text-right">고장사진</th>
									<td>
										<div class="table-attfile att_file_divC" style="width:100%;">
											<div class="table-attfile" style="float:left">
												<button type="button" class="btn btn-primary-gra mr5" onclick="javascript:fnShowFile('C');">파일 이미지보기</button>
											</div>
										</div>
									</td>
								</tr>
							</c:if>
							<tr>
								<th class="text-right">처리 일시</th>
								<td>
									<input type="text" id="complete_dt" name="complete_dt" class="form-control" readonly="readonly">
								</td>
								<th class="text-right">지시서(계약서)</th>
								<td>
									<div class="table-attfile" style="width:100%;">
										<div class="table-attfile serviceType" style="float:left">
											<button type="button" class="btn btn-primary-gra mr5" id="servBtn1" onclick="javascript:goServReg();">정비지시서작성</button>
										</div>
										<div class="table-attfile rentalType" style="float:left">
											<button type="button" class="btn btn-primary-gra mr5" id="rentBtn1" onclick="javascript:goRentReg();">렌탈계약서작성</button>
										</div>
									</div>
								</td>
								<th class="text-right">서비스 일지</th>
								<td>
									<div class="table-attfile" style="width:100%;">
										<div class="table-attfile serviceType" style="float:left">
											<button type="button" class="btn btn-primary-gra mr5" id="servBtn2" onclick="javascript:;">서비스일지작성</button>
										</div>
									</div>
								</td>
							</tr>
							<tr style="display: none;" id="confirmTextTr">
								<th class="text-right">처리 결과</th>
								<td colspan="5">
									<textarea class="form-control" style="height: 100px;" id="confirm_text" name="confirm_text" alt="접수내용"></textarea>
								</td>
							</tr>
							</tbody>
						</table>
					</div>
					<!-- /1. 장비정보 -->
				<!-- /상단 폼테이블 -->
			</div>
			<!-- 하단 폼테이블 -->
			<div class="btn-group mt10">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
		</div>
		<!-- /contents 전체 영역 -->
	</div>
</form>
</body>
</html>
