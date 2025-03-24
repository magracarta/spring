<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 정비 > 서비스일지 > 전화상담일지 신규등록 > null
-- 작성자 : 성현우
-- 최초 작성일 : 2020-07-23 19:54:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

	var auiGridAsTodos;
	var item;
	var sessionCehckTime = 1000 * 60 * 5;
	$(document).ready(function() {
		// AUIGrid 생성
		createAUIGrid();

		fnInit();
	});

	function fnInit() {
		var machineSeq = "${inputParam.s_machine_seq}";
		var asCallTypeCd = "${inputParam.as_call_type_cd}";

		if(asCallTypeCd != "") {
			$("#as_call_type_cd").prop("disabled", true);
			$M.setValue("as_call_type_cd", asCallTypeCd);
			fnChangeCallType(asCallTypeCd);
		}

		if(machineSeq != "") {
			fnSetInformation(machineSeq);
		}
		setInterval(function () {
			fnSessionCheck();
		}, sessionCehckTime);
	}

	// session 유지를 위한 함수
	function fnSessionCheck() {
		$M.goNextPageAjax('/session/check', '', {method: 'GET', loader: false},
				function (result) {
					console.log($M.getCurrentDate("yyyyMMddHHmmss"));
				}
		);
	}

	// CAP이력 팝업
	function goCapLog() {
		var machineSeq = $M.getValue("__s_machine_seq");
		if(machineSeq == "") {
			alert("차대번호 조회를 먼저 진행해주세요.");
			return;
		}

		var params = {
			"s_machine_seq" : machineSeq
		};
		var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=750, height=360, left=0, top=0";
		$M.goNextPage('/serv/serv0101p14', $M.toGetParam(params), {popupStatus : popupOption});
	}

	// 사업자변경
	function goChangeBreg() {
    	if ($M.getValue("cust_no") == "") {
			alert("고객정보가 없습니다.");
			return false;
		}
		var params = {
			's_cust_no' : $M.getValue("cust_no")
		};
		openSearchBregSpecPanel('fnSetBregInfo', $M.toGetParam(params));
	}

	// 사업자정보 Setting
	function fnSetBregInfo(data) {
		$M.setValue("breg_no", data.breg_no);
		$M.setValue("breg_rep_name", data.breg_rep_name);
		$M.setValue("breg_name", data.breg_name);
		$M.setValue("breg_seq", data.breg_seq);
	}

	// 쿠폰사용이력
	function goCouponHistory() {
		var machineSeq = $M.getValue("__s_machine_seq");
		if(machineSeq == "") {
			alert("차대번호 조회를 먼저 진행해주세요.");
			return;
		}

		var params = {
			"s_machine_seq" : machineSeq
		};
		var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=750, height=420, left=0, top=0";
		$M.goNextPage('/serv/serv0101p02', $M.toGetParam(params), {popupStatus : popupOption});
	}

	// 문자발송
	function fnSms(type) {
		alert("저장 후 발송 가능합니다.");
		return ;
	}

	// 차대번호, 차주명 조회
	function fnSetInformation(data) {

		var param = {};
		if(typeof data == "object") {
			param.s_machine_seq = data.machine_seq
		} else if(typeof data == "string") {
			param.s_machine_seq = data;
		}

		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'GET'},
				function (result) {
					if(result.success) {
						dataSetting(result);
					}
				}
		);
	}

	// 장비, 고객 정보 Setting
	function dataSetting(result) {
		item = result.custBean;
		// 장비관련
		$M.setValue(result.machineBean);
		$M.setValue("__s_machine_seq", result.machineBean.machine_seq);


		$("#cap").html(result.machineBean.cap);
		if(result.machineBean.cap == "미적용") {
			$("#plan_dt").prop("disabled", true);
		}

		// 고객정보
		$M.setValue(result.custBean);
		$M.setValue("__s_cust_no", result.custBean.cust_no);

		// 프로모션
		$("#pro_period").html(result.custBean.pro_period);
		$("#pro_content").html(result.custBean.pro_content);
		fnSetFileInfo();

		// DI, 종료 여부
		$M.setValue("di_yn", result.diYn);
		$M.setValue("end_yn", result.endYn);

		// 서비스미결
		AUIGrid.setGridData(auiGridAsTodos, result.asTodoList);
	}

	// 첨부파일관련 함수
	function fnSetFileInfo() {
		if("" != item.pro_file_seq || "" != item.pro_file_name) {
			var file_info = {
				"file_seq" : item.pro_file_seq,
				"file_name" : item.pro_file_name,
				"fileIdx" : 1
			};

			setFileInfo(file_info);
			showFileNameTd();
		}
	}

	// 첨부파일관련 함수
	function setFileInfo(result) {
		var fileIdx = result.fileIdx;
		$("#file_name_item_div" + fileIdx).remove();
		showFileNameTd(fileIdx);

		var fileName; // 파일업로드 대상 컬럼 name값
		var str = '';
		str += '<div class="table-attfile-item' + fileIdx + '" id="file_name_item_div' + fileIdx + '">';
		str += '<a href="javascript:fileDownload(' + result.file_seq + ');" style="color: blue;">' + result.file_name + '</a>&nbsp;';

		if (fileIdx == 1) {
			fileName = "pro_file_seq"
		}

		str += '<input type="hidden" id="file_seq" name="' + fileName + '" value="' + result.file_seq + '"/>';
		str += '<button type="button" class="btn-default" onclick="javascript:fnRemoveFile(' + fileIdx + ');"><i class="material-iconsclose font-18 text-default"></i></button>';
		str += '</div>';

		$("#file_name_div" + fileIdx).append(str);
	}

	// 첨부파일관련 함수
	function showFileNameTd(fileIdx) {
		$("#file_search_td" + fileIdx).addClass("dpn");
		$("#file_name_td" + fileIdx).removeClass("dpn");
	}

	// 결재요청
	function goRequestApproval() {
		goSave('requestAppr');
	}

	// 저장
	function goSave(isRequestAppr) {
		var frm = document.main_form;
		// validationcheck
		if($M.validation(frm,
				{field:["body_no", "cust_name", "as_dt",
						"as_call_result_cd", "as_call_type_cd", "as_call_hour"]})==false) {
			return;
		};

		// 사업자확인 CheckBox 확인
		if(!$M.isCheckBoxSel("breg_confirm_yn")) {
			alert("사업자확인을 먼저 진행해주세요.");
			$M.getComp("breg_confirm_yn").focus();
			return;
		}

		var endYn = $M.getValue("end_yn");
		var diYn = $M.getValue("di_yn");
		var asCallTypeCd = $M.getValue("as_call_type_cd");

		if(diYn == "Y" && asCallTypeCd == "1") {
			alert("DI Call은 한 번만 가능합니다.\n상담구분을 다시 선택해주세요.");
			return;
		}

		if(endYn == "Y" && asCallTypeCd == "3") {
			alert("종료 Call은 한 번만 가능합니다.\n상담구분을 다시 선택해주세요.");
			return;
		}

		var msg = "";
		if(isRequestAppr != undefined) {
			// 결재요청 Setting
			$M.setValue("save_mode", "save");
			msg = "결재요청 하시겠습니까?\n※확인 시 현재 창에서는 저장만 진행됩니다.";
		} else {
			$M.setValue("save_mode", "save");
			msg = "저장 하시겠습니까?";
		}

		console.log($M.toValueForm(frm));

		$M.goNextPageAjaxMsg(msg, this_page + "/save", $M.toValueForm(frm), {method : "POST"},
			function(result) {
				if(result.success) {
					$M.setValue("as_no", result.as_no);
					if(isRequestAppr != undefined) {
						fnClose();

						goApproval();
					} else {
						alert("처리가 완료되었습니다.");
						fnClose();

						__goAsCallDetail();
					}
				}
			}
		);
	}

	function __goAsCallDetail() {
		var params = {
			"s_as_no" : $M.getValue("as_no")
		};

		var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=900, left=0, top=0";
		$M.goNextPage('/serv/serv0102p06', $M.toGetParam(params), {popupStatus : popupOption});
	}

	// 결재
	function goApproval() {
		var params = {
			"s_as_no" : $M.getValue("as_no")
		};

		var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=700, height=470, left=0, top=0";
		$M.goNextPage('/serv/serv0102p09', $M.toGetParam(params), {popupStatus : popupOption});
	}

	// 전화상담내역
	function goCallHistory() {
		var machineSeq = $M.getValue("machine_seq");
		if(machineSeq == "") {
			alert("차대번호 조회를 먼저 진행해주세요.");
			return;
		}

		var params = {
			"s_machine_seq" : machineSeq
		};

		var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=500, left=0, top=0";
		$M.goNextPage('/serv/serv0102p08', $M.toGetParam(params), {popupStatus : popupOption});
	}

	// 문자발송이력
	function goSmsHistory() {
		var params = {
			"receiver_name" : $M.getValue("cust_name"),
			"phone_no" : $M.getValue("hp_no")
		};

		openSearchSendSMSPanel('setSendSMSInfo', $M.toGetParam(params));
	}

	// Warranty Report
	function goWarrantyReport() {
		alert("저장 후 진행가능합니다.");
	}

	// 닫기
	function fnClose() {
		window.close();
	}

	//그리드생성
	function createAUIGrid() {
		var gridPros = {
			showStateColumn : false,
			showRowNumColumn : true,
			editable : false
		};

		var columnLayout = [
			{
				headerText : "예정일자",
				dataField : "plan_dt",
				style : "aui-center",
				width : "20%",
				dataType : "date",
				formatString : "yy-mm-dd",
			},
			{
				headerText : "미결사항",
				dataField : "todo_text",
				style : "aui-left aui-popup",
				width : "40%",
			},
			{
				headerText : "처리사항",
				dataField : "proc_text",
				style : "aui-left",
				width : "40%",
			},
			{
				headerText : "AS미결번호",
				dataField : "as_todo_seq",
				visible : false
			},
			{
				headerText : "장비대장번호",
				dataField : "machine_seq",
				visible : false
			}
		];

		auiGridAsTodos = AUIGrid.create("#auiGridAsTodos", columnLayout, gridPros);
		AUIGrid.setGridData(auiGridAsTodos, []);
		
		$("#auiGridAsTodos").resize();

		// 상세팝업
        AUIGrid.bind(auiGridAsTodos, "cellClick", function (event) {
            if (event.dataField == "todo_text") {
                var params = {
                    "s_as_todo_seq": event.item.as_todo_seq
                };
                
                var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=600, height=300, left=0, top=0";
				$M.goNextPage('/serv/serv0101p17', $M.toGetParam(params), {popupStatus : popupOption});
            }
        });
	}
	
	// CAP CALL 팝업 오픈
	function goCapPopup() {
		var bodyNo = $M.getValue("body_no");
		if(bodyNo == "") {
			alert("차대번호 조회를 먼저 진행해주세요.");
			return;
		}

		var param = {
			"s_body_no" : $M.getValue("body_no"),
			"s_plan_dt" : $M.getValue("plan_dt")
		};

		var popupOption = "";
           $M.goNextPage('/serv/serv040407', $M.toGetParam(param), {popupStatus : popupOption});
	}

	// 상담구분에 따라 상담문자발송 버튼 노출 (DI, 종료 아닌 경우만 show)
	function fnChangeCallType(val) {
		if (val == "1" || val == "3") {
			$("#_fnSms").addClass("dpn");
		} else {
			$("#_fnSms").removeClass("dpn");
		}
	}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<input type="hidden" id="job_report_no" name="job_report_no" value="${result.job_report_no}"/>
	<input type="hidden" id="job_seq_no" name="job_seq_no" value="${inputParam.s_seq_no}"/>
	<input type="hidden" id="__s_machine_seq" name="__s_machine_seq" value="${result.machine_seq}"/>
	<input type="hidden" id="__s_cust_no" name="__s_cust_no" value="${result.cust_no}"/>
	<input type="hidden" id="machine_seq" name="machine_seq" value="${result.machine_seq}"/>
	<input type="hidden" id="cust_no" name="cust_no" value="${result.cust_no}"/>
	<input type="hidden" id="save_mode" name="save_mode">
	<input type="hidden" id="call_type_cd_str" name="call_type_cd_str">
	<input type="hidden" id="as_type" name="as_type" value="CALL">
	<input type="hidden" id="__s_reg_type" name="__s_reg_type" value="I">
	<input type="hidden" id="__s_menu_type" name="__s_menu_type" value="S">
	<input type="hidden" id="di_yn" name="di_yn">
	<input type="hidden" id="end_yn" name="end_yn">
	<input type="hidden" id="as_no" name="as_no">
	<input type="hidden" id="sar_error_no" name="sar_error_no" value="${inputParam.sar_error_no }"/>
	<!-- 팝업 -->
	<div class="popup-wrap width-100per">
		<!-- 타이틀영역 -->
		<div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
		</div>
		<!-- /타이틀영역 -->
		<div class="content-wrap">
			<!-- 상단 폼테이블 -->
			<div>
				<!-- 1. 장비정보 -->
				<div class="title-wrap">
					<div class="left approval-left">
						<div></div>
						<span class="condition-item">상태 : 작성중</span>
					</div>
					<!-- 결재영역 -->
					<div class="p10" style="margin-left: 10px;">
						<jsp:include page="/WEB-INF/jsp/common/apprHeader.jsp"></jsp:include>
					</div>
					<!-- /결재영역 -->
				</div>
				<div class="title-wrap mt-10" style="float:left;">
					<h4>1. 장비정보 </h4>
					<div class="left text-warning">
							${sar_error_msg }
					</div>
				</div>
				<table class="table-border mt5">
					<colgroup>
						<col width="110px">
						<col width="300px">
						<col width="110px">
						<col width="">
						<col width="110px">
						<col width="">
						<col width="110px">
						<col width="">
					</colgroup>
					<tbody>
					<tr>
						<th class="text-right essential-item">차대번호</th>
						<td>
							<div class="form-row inline-pd pr">
								<div class="col-8">
									<div class="input-group">
										<input type="text" id="body_no" name="body_no" class="form-control border-right-0 essential-bg" readonly="readonly" required="required" alt="차대번호">
										<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchDeviceHisPanel('fnSetInformation');" ><i class="material-iconssearch"></i></button>
									</div>
								</div>
								<div class="col-4">
									<jsp:include page="/WEB-INF/jsp/common/commonMachineJob.jsp">
										<jsp:param name="li_machine_type" value="__machine_detail#__repair_history#__as_todo#__campaign#__work_db"/>
									</jsp:include>
								</div>
							</div>
						</td>
						<th class="text-right">장비모델</th>
						<td>
							<div class="input-group">
								<input type="text" id="machine_name" name="machine_name" class="form-control width180px mr10" readonly="readonly">
								<input type="text" id="mch_type_name" name="mch_type_name" class="form-control width80px" readonly="readonly">
							</div>
						</td>
						<th class="text-right">출하일자</th>
						<td>
							<div class="input-group width120px">
								<input type="text" class="form-control border-right-0 calDate" id="out_dt" name="out_dt" dateFormat="yyyy-MM-dd" disabled="disabled">
							</div>
						</td>
						<th class="text-right">최근정비 가동시간</th>
						<td>
							<div class="form-row inline-pd">
								<div class="col width70px">
									<input type="text" id="op_hour" name="op_hour" class="form-control text-right" >
								</div>
								<div class="col width33px">
									hr
								</div>
							</div>
						</td>
					</tr>
					<tr>
						<th class="text-right">CAP</th>
						<td>
							<div class="form-row inline-pd">
								<div class="col-5">
									<span id="cap">${result.cap}</span>
								</div>
								<div class="col-7 text-right">
									<button type="button" class="btn btn-primary-gra" onclick="javascript:goCapLog();">CAP이력</button>
									<button type="button" class="btn btn-primary-gra" onclick="javascript:goCapPopup();">CAP팝업</button>
								</div>
							</div>
						</td>
						<th class="text-right">CAP회차</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width33px">
									현재
								</div>
								<div class="col width40px">
									<input type="text" id="cap_cnt" name="cap_cnt" class="form-control text-center" readonly="readonly">
								</div>
								<div class="col width16px">
									차,
								</div>
								<div class="col width33px pl5">
									다음
								</div>
								<div class="col width40px">
									<input type="text" id="next_cap_cnt" name="next_cap_cnt" class="form-control text-center" readonly="readonly">
								</div>
								<div class="col width16px">
									차
								</div>
							</div>
						</td>
						<th class="text-right">CAP예정일자</th>
						<td>
							<div class="input-group width120px">
								<input type="text" class="form-control border-right-0 calDate" id="plan_dt" name="plan_dt" dateFormat="yyyy-MM-dd" disabled="disabled">
							</div>
						</td>
						<th class="text-right">최근 정비일자</th>
						<td>
							<div class="input-group width120px">
								<input type="text" class="form-control border-right-0 calDate" id="job_ed_dt" name="job_ed_dt" dateFormat="yyyy-MM-dd" disabled="disabled">
							</div>
						</td>
					</tr>
					</tbody>
				</table>
				<div class="btn-group mt5">
					<div class="right text-warning">
						※ CAP적용/미적용은 장비대장에서 처리
					</div>
				</div>
				<!-- /1. 장비정보 -->
				<!-- 2. 고객정보 -->
				<div class="title-wrap">
					<h4>2. 고객정보</h4>
				</div>
				<table class="table-border mt5">
					<colgroup>
						<col width="70px">
						<col width="">
						<col width="70px">
						<col width="">
						<col width="70px">
						<col width="">
						<col width="70px">
						<col width="">
						<col width="70px">
						<col width="">
						<col width="70px">
						<col width="">
					</colgroup>
					<tbody>
					<tr>
						<th class="text-right essential-item">고객명</th>
						<td>
							<div class="form-row inline-pd pr">
								<div class="col-6">
									<div class="input-group">
										<input type="text" id="cust_name" name="cust_name" class="form-control essential-bg" readonly="readonly" required="required" alt="고객명">
									</div>
								</div>
								<div class="col-6">
									<jsp:include page="/WEB-INF/jsp/common/commonCustJob.jsp">
										<jsp:param name="li_type" value="__cust_dtl#__ledger#__visit_history"/>
									</jsp:include>
								</div>
							</div>
						</td>
						<th class="text-right">휴대폰</th>
						<td>
							<div class="input-group width140px">
								<input type="text" id="hp_no" name="hp_no" class="form-control border-right-0" format="phone" readonly="readonly">
								<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSms('cust');" ><i class="material-iconsforum"></i></button>
							</div>
						</td>
						<th class="text-right">업체명</th>
						<td>
							<input type="text" id="breg_name" name="breg_name" class="form-control" readonly="readonly">
						</td>
						<th class="text-right">연락처</th>
						<td>
							<input type="text" id="tel_no" name="tel_no" class="form-control width120px" readonly="readonly">
						</td>
						<th class="text-right">팩스</th>
						<td>
							<input type="text" id="fax_no" name="fax_no" class="form-control width120px" readonly="readonly">
						</td>
						<th class="text-right">DI쿠폰잔액</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width100px">
									<input type="text" id="di_balance_amt" name="di_balance_amt" class="form-control text-right" format="decimal" readonly="readonly">
								</div>
								<div class="col width16px">원</div>
							</div>
						</td>
					</tr>
					<tr>
						<th class="text-right">프로모션</th>
						<td colspan="">
							<span id="pro_content"></span>
						</td>
						<th class="text-right">주소</th>
						<td colspan="3">
							<div class="form-row inline-pd">
								<div class="col-6">
									<input type="text" id="addr1" name="addr1" class="form-control" readonly="readonly">
								</div>
								<div class="col-6">
									<input type="text" id="addr2" name="addr2" class="form-control" readonly="readonly">
								</div>
							</div>
						</td>
						<th class="text-right">사업자</th>
						<td colspan="3">
							<div class="form-row inline-pd widthfix">
								<div class="col-6">
									<input type="text" id="breg_no" name="breg_no" class="form-control" readonly="readonly">
								</div>
								<div class="col width100px pl5">
									<div class="form-check form-check-inline">
										<input id="breg_confirm_yn" name="breg_confirm_yn" class="form-check-input" type="checkbox" value="Y">
										<label class="form-check-label" for="breg_confirm_yn" style="color: red">사업자확인</label>
									</div>
								</div>
								<div class="col" style="width: calc(50% - 100px);">
									<button type="button" class="btn btn-primary-gra" onclick="javascript:goChangeBreg();" >변경</button>
								</div>
							</div>
						</td>
						<th class="text-right">미수</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width100px">
									<input type="text" id="misu_amt" name="misu_amt" class="form-control text-right" format="decimal" readonly="readonly">
								</div>
								<div class="col width16px">원</div>
							</div>
						</td>
					</tr>
					</tbody>
				</table>
				<!-- /2. 고객정보 -->
			</div>
			<!-- /상단 폼테이블 -->

			<!-- 중간 폼테이블 -->
			<div class="row mt10">
				<!-- 중간좌측 폼테이블 -->
				<div class="col-5">
					<!-- 3. 상담정보 -->
					<div class="title-wrap">
						<div class="left">
							<h4>3. 상담정보</h4>
						</div>
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_L"/></jsp:include>
						</div>
					</div>
					<table class="table-border mt5">
						<colgroup>
							<col width="100px">
							<col width="">
							<col width="100px">
							<col width="">
						</colgroup>
						<tbody>
						<tr>
							<th class="text-right">상담일자</th>
							<td>
								<div class="input-group width120px">
									<input type="text" class="form-control border-right-0 calDate" id="as_dt" name="as_dt" dateFormat="yyyy-MM-dd" disabled="disabled" required="required" alt="상담일자" value="${inputParam.s_current_dt}">
								</div>
							</td>
							<th class="text-right essential-item">상담구분</th>
							<td>
								<select class="form-control width100px essential-bg" name="as_call_type_cd" id="as_call_type_cd" required="required" alt="상담구분" onchange="javascript:fnChangeCallType(this.value);">
									<option value="">- 선택 -</option>
									<c:forEach var="list" items="${codeMap['AS_CALL_TYPE']}">
										<option value="${list.code_value}">${list.code_name}</option>
									</c:forEach>
								</select>
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">통화구분</th>
							<td>
								<select class="form-control width100px essential-bg" name="as_call_result_cd" id="as_call_result_cd" required="required" alt="통화구분">
									<option value="">- 선택 -</option>
									<c:forEach var="list" items="${codeMap['AS_CALL_RESULT']}">
										<option value="${list.code_value}">${list.code_name}</option>
									</c:forEach>
								</select>
							</td>
							<th class="text-right essential-item">통화시간</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col width60px">
										<input type="text" class="form-control text-right essential-bg" id="as_call_hour" name="as_call_hour" required="required" alt="통화시간" format="decimal">
									</div>
									<div class="col width33px">
										hr
									</div>
								</div>
							</td>
						</tr>
						</tbody>
					</table>
					<!-- /3. 상담정보 -->
					<!-- 4. 서비스미결 -->
					<div class="title-wrap mt10">
						<h4>4. 서비스미결</h4>
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_M"/></jsp:include>
					</div>
					<div id="auiGridAsTodos" style="margin-top: 5px; height: 110px;" ></div>
					<!-- /4. 서비스미결 -->
					<!-- 5. 결재자의견 -->
					<div class="title-wrap mt10">
						<div class="left">
							<h4>5. 결재자의견</h4>
						</div>
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
						</div>
					</div>
					<table class="table mt5">
						<colgroup>
							<col width="40px">
							<col width="">
							<col width="60px">
							<col width="">
						</colgroup>
						<thead>
						<tr>
							<td colspan="5">
								<div class="fixed-table-container" style="width: 100%; height: 110px;"> <!-- height값 인라인 스타일로 주면 타이틀 영역이 고정됨  -->
									<div class="fixed-table-wrapper">
										<table class="table-border doc-table md-table">
											<colgroup>
												<col width="40px">
												<col width="140px">
												<col width="55px">
												<col width="">
											</colgroup>
											<thead>
											<!-- 퍼블리싱 파일의 important 속성 때문에 dev에 선언한 클래스가 안되서 인라인 CSS로함 -->
											<tr><th class="th" style="font-size: 12px !important">구분</th>
												<th class="th" style="font-size: 12px !important">결재일시</th>
												<th class="th" style="font-size: 12px !important">담당자</th>
												<th class="th" style="font-size: 12px !important">특이사항</th>
											</tr></thead>
											<tbody>
											<c:forEach var="list" items="${apprMemoList}">
												<tr>
													<td class="td" style="text-align: center; font-size: 12px !important">${list.appr_status_name }</td>
													<td class="td" style="font-size: 12px !important">${list.proc_date }</td>
													<td class="td" style="text-align: center; font-size: 12px !important">${list.appr_mem_name }</td>
													<td class="td" style="font-size: 12px !important">${list.memo }</td>
												</tr>
											</c:forEach>
											</tbody>
										</table>
									</div>
								</div>
							</td>
						</tr>
						</tbody>
					</table>
					<!-- /5. 결재자의견 -->
				</div>
				<!-- /중간좌측 폼테이블 -->
				<!-- 중간우측 폼테이블 -->
				<div class="col-7">
					<!-- 6. 상담내용 -->
					<div class="title-wrap">
						<h4>6. 상담내용</h4>
					</div>
					<div class="mt5" style="height: 375px;">
						<textarea class="form-control" style="height: 100%;" id="as_call_text" name="as_call_text" placeholder="상담내용작성이 가능합니다."></textarea>
					</div>
					<!-- /6. 상담내용 -->
				</div>
				<!-- /중간우측 폼테이블 -->
			</div>
			<!-- /중간 폼테이블 -->
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