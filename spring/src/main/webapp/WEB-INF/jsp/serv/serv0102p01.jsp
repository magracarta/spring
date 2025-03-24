<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 정비 > 서비스일지 > null > 서비스일지 상세
-- 작성자 : 성현우
-- 최초 작성일 : 2020-07-20 19:54:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	var auiGridRightTop;
	var auiGridLeftBom;
	var auiGridAsTodos;
	// 4.정비분류 No
	var i = '${breakPartSize eq 0 ? 1 : breakPartSize}';

	var lastWorkIndex = '${lastWorkIndex}';

	var originFileList = [];
	var removeFileArr = [];

	var item = ${resultInfo};
	var pro = ${promotionMap};
	var sessionCehckTime = 1000 * 60 * 5;
	var maxByte = 4000;
	$(document).ready(function() {
		fnToggle();
		fnInit();

		// AUIGrid 생성
		createAUIGridParts();
		createAUIGridAsTodos();
	});

	function fnInit() {
		var apprProcStatusCd = "${result.appr_proc_status_cd}";

		var apprJobSeq = '${result.appr_job_seq}';

		var memNo = '${SecureUser.mem_no}';

		if(apprJobSeq == '' || apprJobSeq == 0) {
			$("#_goApprCancel").addClass("dpn");
			$("#_goApproval").addClass("dpn");
		}

		// 작성중인 경우 일자별 등록자는 수정만 가능
		if(apprProcStatusCd == '01' && memNo != '${result.eng_mem_no}' && 'Y' == '${editYn}') {
			$("#_goApprCancel").addClass("dpn");
			$("#_goRequestApproval").addClass("dpn");
			$("#_goApproval").addClass("dpn");
			$("#_goRemove").addClass("dpn");
			$("#goModify2").removeClass("dpn");
		}

		if("${page.fnc.F00667_001}" == "Y") {
			// 서비스관리 계정이 경우 삭제가능하도록 수정
			$("#goRemove2").removeClass("dpn");
		}
    
    // 자동화개발건 - 정비구분 이름 설정
    // - 정비구분2가 있으면 (정비구분1 + " / " + 정비구분2) 로 설정
    if(item.job_type2_name) {
      $M.setValue('job_type_total_name', item.job_type_name + " / " + item.job_type2_name);
    } else {
      $M.setValue('job_type_total_name', item.job_type_name);
    }

		// 최초등록이 아닌 경우 현재 결재인원이 아닌 경우 disable
		if(apprProcStatusCd != '01') {
			$("#_goRemove").addClass("dpn");
			$("#_goChangeBreg").prop("disabled", true);
			$("#job_type_cd").prop("disabled", true);
			$("#_goBookmark").prop("disabled", true);
			$("#_fnAdd").prop("disabled", true);
			$("#_goRepairCowoker").prop("disabled", true);
			$("#travel_area_name").prop("readonly", true);
			if('${apprBean.appr_mem_no}' != memNo) {
				$("[id^=repair_st_ti_h]").prop("readonly", true);
				$("[id^=repair_st_ti_m]").prop("readonly", true);
				$("[id^=repair_ed_ti_h]").prop("readonly", true);
				$("[id^=repair_ed_ti_m]").prop("readonly", true);
				$("[id^=standard_hour]").prop("readonly", true);
				$("input[name='rework_ync']").prop("disabled", true);
				$('button[name="miss_mem_btn"]').prop("disabled", true);
			}
			$("#travel_st_ti_h").prop("readonly", true);
			$("#travel_st_ti_m").prop("readonly", true);
			$("#travel_ed_ti_h").prop("readonly", true);
			$("#travel_ed_ti_m").prop("readonly", true);
			$("#travel_km").prop("readonly", true);
			$("#move_hour").prop("readonly", true);
			$("#ref_text").prop("readonly", true);
			$("[id^=repair_text]").prop("readonly", true);
			$("#op_hour").prop("readonly", true);
			$('input[name="job_case_ti"]').prop("disabled", true);
			$('button[name="_fnRemoveRow"]').prop("disabled", true);
			$('button[name="_goBreakPart"]').prop("disabled", true);
		}

		var cap = item.cap;
		if(cap.indexOf("미적용") != -1) {
			$("#cap_plan_dt").prop("disabled", true);
		}

		fnJobCaseTi();

		fnSetPromotion();
		fnSetFileInfo();

		// 공임배분
		fnSetRepairCowoker(${cowokerListJson});

		// 파일세팅
		<c:forEach var="file" items="${fileList}">
		var temp = {
			file_seq : '${file.file_seq}',
			seq_no : '${file.seq_no}',
			pic_type : '${file.pic_type}',
		}
		originFileList.push(temp);
		fnPrintFile('${file.file_seq}', '${file.file_name}', 'R');
		</c:forEach>
		<c:forEach var="jobFile" items="${jobFileList}">
		var temp = {
			file_seq : '${jobFile.file_seq}',
			seq_no : '${jobFile.seq_no}',
			pic_type : '${file.pic_type}',
		}
		originFileList.push(temp);
		fnPrintFile('${jobFile.file_seq}', '${jobFile.file_name}', 'J');
		</c:forEach>

		var textItems = $("textarea[name*=repair_text]");
		for(var k = 0; k < textItems.length; k++) {
			var textItem = textItems[k];
			fnChkByte(textItem, k + 1);
		}

		setInterval(function () {
			fnSessionCheck();
		}, sessionCehckTime);

	}

	// 정비내역 - 크게보기 추가
	function goLarge(seqNo) {
		var param = {
			"as_no" : $M.getValue("as_no"),
			"seq_no" : seqNo,
		}

		var popupOption = "";
		$M.goNextPage('/serv/serv0102p15', $M.toGetParam(param), {popupStatus : popupOption});
	}

	function goPartDetail() {
		var param = {
			"s_job_report_no" : $M.getValue("job_report_no")
		}

		var popupOption = "";
		$M.goNextPage('/serv/serv0102p17', $M.toGetParam(param), {popupStatus : popupOption});
	}

	function fnSessionCheck() {
		$M.goNextPageAjax('/session/check', '', {method: 'GET', loader: false},
				function (result) {
					console.log($M.getCurrentDate("yyyyMMddHHmmss"));
				}
		);
	}

	function fnSetPromotion() {
		for(var i=0; i<pro.length; i++) {
			var innerHtml = "";

			innerHtml += '<tr>';
			innerHtml += '	<th class="text-right">프로모션기간</th>';
			innerHtml += '	<td colspan="3">';
			innerHtml += '		<span id="pro_period_' + i + '"></span>';
			innerHtml += '	</td>';
			innerHtml += '	<th class="text-right">프로모션내용</th>';
			innerHtml += '	<td colspan="3">';
			innerHtml += '		<span id="pro_content_' + i + '"></span>';
			innerHtml += '	</td>';
			innerHtml += '	<th class="text-right">프로모션첨부</th>';
			innerHtml += '	<td id="file_search_td' + i + '">';
			innerHtml += '	</td>';
			innerHtml += '	<td id="file_name_td' + i + '" class="dpn">';
			innerHtml += '		<div class="table-attfile" id="file_name_div' + i + '">';
			innerHtml += '		</div>';
			innerHtml += '	</td>';
			innerHtml += '</tr>';

			$('#cust_info > tbody:last').append(innerHtml);

			$("#pro_period_" + i).html(pro[i].term);
			$("#pro_content_" + i).html(pro[i].content);
		}
	}

	function fnSetJobOrder(data) {
		AUIGrid.setGridData(auiGridAsTodos, data);
	}

	function fnSetFileInfo() {
		// if("" != item.pro_file_seq || "" != item.pro_file_name) {
		for(var i=0; i<pro.length; i++) {
			if ("" != pro[i].file_seq || "" != pro[i].file_seq) {
				var file_info = {
					"file_seq": pro[i].file_seq,
					"file_name": pro[i].file_name,
					"fileIdx": i
				};

				setFileInfo(file_info);
				showFileNameTd();
			}
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
		str += '</div>';

		$("#file_name_div" + fileIdx).append(str);
	}

	// 첨부파일관련 함수
	function showFileNameTd(fileIdx) {
		$("#file_search_td" + fileIdx).addClass("dpn");
		$("#file_name_td" + fileIdx).removeClass("dpn");
	}

	// 규정시간 계산
	function fnCalcStandardHour() {
		var totStandardHour =  0;
		$("[id^=standard_hour]").each(function() {
			totStandardHour += Number($(this).val());
		});

		$M.setValue("total_standard_hour", Math.round(totStandardHour * 10) / 10.0);
	}

	// 정비시간 계산
	function fnCalcRepairHour(index) {

		// 정비시작 - 시(분으로 환산)
		var repairStHour = $M.toNum($M.getValue("repair_st_ti_h"+index)) * 60;
		// 정비시작 - 분
		var repairStMin = $M.toNum($M.getValue("repair_st_ti_m"+index));
		// 정비시작 분으로 환산
		var repairStart = repairStHour + repairStMin;

		// 정비종료 - 시(분으로 환산)
		var repairEdHour = $M.toNum($M.getValue("repair_ed_ti_h"+index)) * 60;
		// 정비종료 - 분
		var repairEdMin = $M.toNum($M.getValue("repair_ed_ti_m"+index));
		// 정비종료 분으로 환산
		var repairEnd = repairEdHour + repairEdMin;

		// 최종시간 계산 - 시로 환산
		var finalTime = (repairEnd - repairStart) / 60;
		finalTime = finalTime.toFixed(1);

		// 정비시간 Setting
		if(finalTime > 0) {
			$M.setValue("repair_hour"+index, finalTime);
		} else {
			$M.setValue("repair_hour"+index, 0);
		}

		var totRepairdHour =  0;
		$("[id^=repair_hour]").each(function() {
			totRepairdHour += Number($(this).val());
		});

		$M.setValue("total_repair_hour", Math.round(totRepairdHour * 10) / 10.0);
	}

	// 이동시간 계산
	function fnCalcTravelHour() {

		// 정비시작 - 시(분으로 환산)
		var repairStHour = $M.toNum($M.getValue("travel_st_ti_h")) * 60;
		// 정비시작 - 분
		var repairStMin = $M.toNum($M.getValue("travel_st_ti_m"));
		// 정비시작 분으로 환산
		var repairStart = repairStHour + repairStMin;

		// 정비종료 - 시(분으로 환산)
		var repairEdHour = $M.toNum($M.getValue("travel_ed_ti_h")) * 60;
		// 정비종료 - 분
		var repairEdMin = $M.toNum($M.getValue("travel_ed_ti_m"));
		// 정비종료 분으로 환산
		var repairEnd = repairEdHour + repairEdMin;

		// 최종시간 계산 - 시로 환산 (출장 도착시간 - 출장 출발시간 - 정비시간)
		var finalTime = ((repairEnd - repairStart) / 60);
		finalTime = finalTime.toFixed(1);

		// 정비시간 Setting
		// 23.06.13 연속정비로 인한 이동시간 자동계산 삭제
		// if(finalTime > 0) {
		// 	$M.setValue("move_hour", finalTime);
		// } else {
		// 	$M.setValue("move_hour", 0);
		// }
	}

	// 정비접수 - 정비종류
	function fnJobCaseTi() {
		var trueFalse = true;
		if($M.getValue("job_case_ti") == "T" && '${result.appr_proc_status_cd}' == '01') {
			trueFalse = false;
		}

		// 출장출발 - 시
		$("#travel_st_ti_h").prop("readonly", trueFalse);
		// 출장출발 - 분
		$("#travel_st_ti_m").prop("readonly", trueFalse);
		// 출장도착 - 시
		$("#travel_ed_ti_h").prop("readonly", trueFalse);
		// 출장도착 - 분
		$("#travel_ed_ti_m").prop("readonly", trueFalse);
		// 출장거리
		$("#travel_km").prop("readonly", trueFalse);
		// 이동시간
		$("#move_hour").prop("readonly", trueFalse);

		if(trueFalse == true && '${result.appr_proc_status_cd}' == '01') {
			// 출장관련 컬럼 초기화
			$M.clearValue({field : ["travel_area_name", "travel_st_ti_h", "travel_st_ti_m", "travel_ed_ti_h", "travel_ed_ti_m", "travel_km", "move_hour"]});
		}
	}

	// 참고 탭
	function fnToggle() {
		$('ul.tabs-c li a').click(function() {
			var tab_id = $(this).attr('data-tab');

			var selectIndex = tab_id.substring(5);

			$('ul.tabs-c li a').removeClass('active');
			$('.tabs-inner').removeClass('active');

			$(this).addClass('active');
			$("#"+tab_id).addClass('active');
		});
	};

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

	// 사업자변경
	function goChangeBreg() {
		var params = {
			"s_breg_no" : $M.getValue("breg_no")
		};

		openSearchBregInfoPanel('fnSetBregInfo', $M.toGetParam(params));
	}

	// 사업자정보 Setting
	function fnSetBregInfo(data) {
		$M.setValue("breg_no", data.breg_no);
		$M.setValue("breg_rep_name", data.breg_rep_name);
		$M.setValue("breg_name", data.breg_name);
		$M.setValue("breg_seq", data.breg_seq);
	}

	// Warranty Report
	function goWarrantyReport() {
		var params = {
			"s_as_no" : $M.getValue("as_no"),
			"s_machine_seq" : $M.getValue("machine_seq")
		};

		var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=440, left=0, top=0";
		$M.goNextPage('/serv/serv0102p04', $M.toGetParam(params), {popupStatus : popupOption});
	}

	// 결정사항조회
	function goAsRepairAppr() {
		var params = {
			"s_as_no" : $M.getValue("as_no"),
			"read_type" : "R"
		};

		var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=840, left=0, top=0";
		$M.goNextPage('/serv/serv0102p02', $M.toGetParam(params), {popupStatus : popupOption});
	}

	// 3.정비접수 -> 정비지시서 호출
	function goJobReport() {
		var param = {
			"s_job_report_no" : $M.getValue("job_report_no")
		};

		var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=840, left=0, top=0";
		$M.goNextPage('/serv/serv0101p01', $M.toGetParam(param), {popupStatus : popupOption});
	}

	// 네이버 지도 호출
	function goMap() {
		var params = [{}];
		var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=750, height=420, left=0, top=0";
		$M.goNextPage('https://map.naver.com', $M.toGetParam(params), {popupStatus : popupOption});
	}

	// 고장부위
	function goBreakPart() {
		var params = {
			"parent_js_name" : "fnSetBreakPartInformation"
		};
		var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=750, height=420, left=0, top=0";
		$M.goNextPage('/serv/serv0102p07', $M.toGetParam(params), {popupStatus : popupOption});
	}

	function fnSetBreakPartInformation(data) {
		var repairText = $M.getValue("repair_text"+lastWorkIndex);
		if($M.getValue("break_part_seq_1") == "") {
			$M.setValue("break_part_name_1", data[0].item.mng_name);
			$M.setValue("break_part_seq_1", data[0].item.break_part_seq);

			repairText = "▶ " + data[0].item.mng_name + "\n-현상 :\n-원인 :\n-조치 :\n\n" + repairText;
			$M.setValue("repair_text"+lastWorkIndex, repairText);

			for (var j = 1; j < data.length; j++) {
				fnAdd();
				$M.setValue("break_part_name_" + (j + 1), data[j].item.mng_name);
				$M.setValue("break_part_seq_" + (j + 1), data[j].item.break_part_seq);

				repairText = "▶ " + data[j].item.mng_name + "\n-현상 :\n-원인 :\n-조치 :\n\n" + repairText;
				$M.setValue("repair_text"+lastWorkIndex, repairText);
			}
		} else {
			for (var j = 0; j < data.length; j++) {
				$M.setValue("break_part_name_" + i, data[j].item.mng_name);
				$M.setValue("break_part_seq_" + i, data[j].item.break_part_seq);

				repairText = "▶ " + data[j].item.mng_name + "\n-현상 :\n-원인 :\n-조치 :\n\n" + repairText;
				$M.setValue("repair_text"+lastWorkIndex, repairText);

				if(j != data.length - 1) {
					fnAdd();
				}
			}
		}
	}

	// 자주쓰는정비내용 팝업
	function goBookmark() {
		var param = {
			"parent_js_name" : "fnSetBreakPart"
		};

		var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1400, height=650, left=0, top=0";
		$M.goNextPage('/serv/serv0102p05', $M.toGetParam(param), {popupStatus : popupOption});
	}

	// 자주쓰는정비내용 Setting
	function fnSetBreakPart(data) {

		var repairText = $M.getValue("repair_text"+lastWorkIndex);
		if($M.getValue("break_part_seq_1") == "") {
			$M.setValue("break_part_name_1", data[0].item.mng_name);
			$M.setValue("break_part_seq_1", data[0].item.break_part_seq);
			$M.setValue("break_status_cd_1", data[0].item.break_status_cd);
			$M.setValue("break_reason_cd_1", data[0].item.break_reason_cd);
			$M.setValue("remark_1", data[0].item.remark);
			$M.setValue("use_yn_1", "Y");

			repairText += "▶ " + data[0].item.mng_name + "\n-현상 :\n-원인 :\n-조치 :\n\n";
			$M.setValue("repair_text"+lastWorkIndex, repairText);

			for (var j = 1; j < data.length; j++) {
				fnAdd();
				$M.setValue("break_part_name_" + (j + 1), data[j].item.mng_name);
				$M.setValue("break_part_seq_" + (j + 1), data[j].item.break_part_seq);
				$M.setValue("break_status_cd_" + (j + 1), data[j].item.break_status_cd);
				$M.setValue("break_reason_cd_" + (j + 1), data[j].item.break_reason_cd);
				$M.setValue("remark_" + (j + 1), data[j].item.remark);
				$M.setValue("use_yn_" + (j + 1), "Y");

				repairText += "▶ " + data[j].item.mng_name + "\n-현상 :\n-원인 :\n-조치 :\n\n";
				$M.setValue("repair_text"+lastWorkIndex, repairText);
			}
		} else {
			for (var j = 0; j < data.length; j++) {
				fnAdd();
				$M.setValue("break_part_name_" + i, data[j].item.mng_name);
				$M.setValue("break_part_seq_" + i, data[j].item.break_part_seq);
				$M.setValue("break_status_cd_" + i, data[j].item.break_status_cd);
				$M.setValue("break_reason_cd_" + i, data[j].item.break_reason_cd);
				$M.setValue("remark_" + i, data[j].item.remark);
				$M.setValue("use_yn_" + i, "Y");

				repairText += "▶ " + data[j].item.mng_name + "\n-현상 :\n-원인 :\n-조치 :\n\n";
				$M.setValue("repair_text"+lastWorkIndex, repairText);
			}
		}
	}

	// 내용추가
	function fnAdd() {
		var beforeBreakPartSeq = $M.getValue("break_part_seq_" + i);
		if(beforeBreakPartSeq == "") {
			alert("고장부위를 먼저 선택해주세요.");
			return;
		}

		i++;

		var str = "";
		str += '<div class="maintenance-item mt10" id="child_div_' + i + '">';
		str += '	<div class="header">No.' + i + '</div>';
		str += '	<div class="body">';
		str += '		<div class="select-section">';
		str += '			<div class="input-group">';
		str += '				<input type="text" id="break_part_name_' + i + '" name="break_part_name_' + i + '" class="form-control border-right-0" readonly="readonly" placeholder="고장부위선택">';
		str += '				<input type="hidden" id="break_part_seq_' + i + '" name="break_part_seq_' + i + '" >';
		str += '				<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goBreakPart();" ><i class="material-iconssearch"></i></button>';
		str += '			</div>';
		str += '			<div class="text-right">';
		str += '				<button type="button" id="_fnRemoveRow" name="_fnRemoveRow" class="btn btn-primary-gra ml5" style="width: 50px;" onclick="javascript:fnRemoveRow(\''+ i +'\')">삭제</button>';
		str += '			</div>';
		str += '		</div>';
		str += '		<div class="select-section mt3">';
		str += '			<select class="form-control" id="break_status_cd_' + i + '" name="break_status_cd_' + i + '">';
		str += '				<option value="">- 고장현상선택 -</option>';
		str += '				<c:forEach items="${codeMap['BREAK_STATUS']}" var="item">';
		str += '					<c:if test="${item.show_yn eq 'Y' && item.use_yn eq 'Y'}">';
		str += '						<option value="${item.code_value}">${item.code_name}</option>';
		str += '					</c:if>';
		str += '				</c:forEach>';
		str += '			</select>';
		str += '			<select class="form-control" id="break_reason_cd_' + i + '" name="break_reason_cd_' + i + '">';
		str += '				<option value="">- 고장원인선택 -</option>';
		str += '				<c:forEach items="${codeMap['BREAK_REASON']}" var="item">';
		str += '					<c:if test="${item.show_yn eq 'Y' && item.use_yn eq 'Y'}">';
		str += '						<option value="${item.code_value}">${item.code_name}</option>';
		str += '					</c:if>';
		str += '				</c:forEach>';
		str += '			</select>';
		str += '		</div>';
		str += '		<input type="text" class="form-control mt5" id="remark_' + i + '" name="remark_' + i + '" placeholder="특이사항">';
		str += '		<input type="hidden" class="form-control mt5" id="use_yn_' + i + '" name="use_yn_' + i + '" value="Y">';
		str += '		<input type="hidden" class="form-control mt5" id="reg_date_' + i + '" name="reg_date_' + i + '" value="">';
		str += '		<input type="hidden" class="form-control mt5" id="row_no_' + i + '" name="row_no_' + i + '" value="'+ i +'">';
		str += '	</div>';
		str += '</div>';

		$("#parent_div").append(str);
	}

	// 새로 추가 한 내용삭제
	function fnRemoveRow(num) {
		var divId = "#child_div_" + num;
		$("div").remove(divId);
	}

	// 기존내용 삭제
	function fnUpdateUseYnRow(num) {
		var divId = "#child_div_" + num;
		var useYn = "use_yn_" + num;

		$M.setValue(useYn, "N");

		$(divId).hide();
	}

	// 공임배분
	function goRepairCowoker() {
		var param = {
			"parent_js_name" : "fnSetRepairCowoker",
			"work_total_amt" : $M.setComma($M.getValue("work_total_amt")),
			"s_as_no" : $M.getValue("as_no"),
			"s_job_report_no" : $M.getValue("job_report_no")
		};

		if($M.getValue("cowoker") != "") {
			param.s_type = "D";
		}

		var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=500, height=450, left=0, top=0";
		$M.goNextPage('/serv/serv0102p03', $M.toGetParam(param), {popupStatus : popupOption});
	}

	// 공임배분 Data Setting
	function fnSetRepairCowoker(data) {
		var frm = document.main_form;

		var co_as_no = [];
		var co_mem_no = [];
		var co_work_rate = [];
		var co_work_amt = [];
		var co_cmd = [];

		for(var i in data) {
			co_as_no.push($M.getValue("as_no"));
			co_mem_no.push(data[i].mem_no);
			co_work_rate.push(data[i].work_rate);
			co_work_amt.push(data[i].work_amt);
			co_cmd.push("Y");
		}

		var option = {
			isEmpty : true
		};

		$M.setValue(frm, "co_as_no_str", $M.getArrStr(co_as_no, option));
		$M.setValue(frm, "co_mem_no_str", $M.getArrStr(co_mem_no, option));
		$M.setValue(frm, "co_work_rate_str", $M.getArrStr(co_work_rate, option));
		$M.setValue(frm, "co_work_amt_str", $M.getArrStr(co_work_amt, option));
		$M.setValue(frm, "co_cmd_str", $M.getArrStr(co_cmd, option));

		var cowoker = data.length > 0 ? data[0].mem_name : '';
		var cowokerCnt = data.length - 1;
		if(data.length > 1) {
			cowoker += " 외" + cowokerCnt + "명";
		}

		$M.setValue("cowoker", cowoker);
		$M.setValue("co_type", "S");
	}

	// 문자발송
	function fnSendSms() {
		var param = {
			'name' : $M.getValue('cust_name'),
			'hp_no' : $M.getValue('hp_no')
		}
		openSendSmsPanel($M.toGetParam(param));
	}

	// 상신취소
	function goApprCancel() {
		var param = {
			appr_job_seq : "${apprBean.appr_job_seq}",
			seq_no : "${apprBean.seq_no}",
			appr_cancel_yn : "Y"
		};
		openApprPanel("goApprovalResultCancel", $M.toGetParam(param));
	}

	function goApprovalResultCancel(result) {
		$M.goNextPageAjax('/session/check', '', {method : 'GET'},
				function(result) {
			    	if(result.success) {
			    		alert("결재취소가 완료됐습니다.");
			    		location.reload();
					}
				}
			);
	}

	// 결재요청
	function goRequestApproval() {
		goModify('requestAppr');
	}

	// 결재
	function goApprovalResult(data) {
		// var params = {
		// 	"s_as_no" : $M.getValue("as_no"),
		// };
		//
		// var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=840, left=0, top=0";
		// $M.goNextPage('/serv/serv0102p02', $M.toGetParam(params), {popupStatus : popupOption});

		goModify('appr');
	}

	function goApproval() {
		var param = {
			appr_job_seq : "${apprBean.appr_job_seq}",
			seq_no : "${apprBean.seq_no}",
			writer_appr_yn : $M.getValue("v_yn") == "Y" ?  "N" : "",
			appr_reject_only : "${apprBean.appr_reject_only}",
		};
		$M.setValue("save_mode", "approval"); // 승인
		openApprPanel("goApprovalResult", $M.toGetParam(param));
	}

	// 수정
	function goModify(isRequestAppr) {


		$M.setValue("write_yn", "Y");
		var frm = document.main_form;
		//validationcheck
		if($M.validation(frm,
				{field:["job_case_ti", "repair_st_ti_h", "repair_st_ti_m", "job_type_cd"]})==false) {
			return;
		};

		if($M.toNum($M.getValue("op_hour")) < 1) {
			alert("가동시간은 필수 입력입니다.");
			return;
		}

		if($M.toNum($M.getValue("prev_op_hour")) > $M.toNum($M.getValue("op_hour"))) {
			alert("가동 시간 입력 오류\n(가동시간은 " + $M.toNum($M.getValue("prev_op_hour")) + " 보다 커야합니다.)");
			return;
		}

		var fileArr = [];
		var jobFileArr = [];

		$("[name=att_file_seqR]").each(function () {
			fileArr.push($(this).val());
		});

		$("[name=att_file_seqJ]").each(function () {
			jobFileArr.push($(this).val());
		});

		var fileSeqNoArr = [];
		var fileSeqArr = [];
		var fileCmdArr = [];
		var fileUseYnArr = [];
		var filePicTypeArr = [];

		fileArr.forEach(item => {
			var check = false;
			originFileList.forEach(oriFile => {
				if(oriFile.file_seq == item) {
					check = true;
				}
			});
			if(!check) {
				fileSeqNoArr.push('0');
				fileSeqArr.push(item);
				fileCmdArr.push('C');
				fileUseYnArr.push('Y');
				filePicTypeArr.push('R');
			}
		});

		jobFileArr.forEach(item => {
			var check = false;
			originFileList.forEach(oriFile => {
				if(oriFile.file_seq == item) {
					check = true;
				}
			});
			if(!check) {
				fileSeqNoArr.push('0');
				fileSeqArr.push(item);
				fileCmdArr.push('C');
				fileUseYnArr.push('Y');
				filePicTypeArr.push('J');
			}
		});

		removeFileArr.forEach(item => {
			originFileList.forEach(oriFile => {
				if(oriFile.file_seq == item) {
					fileSeqNoArr.push(oriFile.seq_no);
					fileSeqArr.push(item);
					fileCmdArr.push('U');
					fileUseYnArr.push('N');
					filePicTypeArr.push(oriFile.pic_type);
				}
			})
		});

		$M.setValue(frm, "file_seq_no_str", $M.getArrStr(fileSeqNoArr));
		$M.setValue(frm, "file_file_seq_str", $M.getArrStr(fileSeqArr));
		$M.setValue(frm, "file_cmd_str", $M.getArrStr(fileCmdArr));
		$M.setValue(frm, "file_use_yn_str", $M.getArrStr(fileUseYnArr));
		$M.setValue(frm, "file_pic_type_str", $M.getArrStr(filePicTypeArr));


		// 4.정비분류 Setting
		var day_seq_no = [];
		var repair_st_ti = [];
		var repair_ed_ti = [];
		var repair_hour = [];
		var standard_hour = [];
		var repair_text = [];

		var dayItem = ${dayListJson};

		for(var dayCount = 1; dayCount < dayItem.length + 1; dayCount++) {
			var startTiH = $M.toNum($('#repair_st_ti_h'+dayCount).val());
			var startTiM = $M.toNum($('#repair_st_ti_m'+dayCount).val());
			var endTiH = $M.toNum($('#repair_ed_ti_h'+dayCount).val());
			var endTiM = $M.toNum($('#repair_ed_ti_m'+dayCount).val());

			if(startTiH < 1 || startTiH > 23) {
				alert("정비시작 입력 시 시간은 (01 ~ 23)시로 입력 해야합니다.");
				focusDay(dayCount, 'repair_st_ti_h');
				return;
			}

			if(startTiM > 59) {
				alert("정비시작 입력 시 분은 (01 ~ 59)분으로 입력 해야합니다.");
				focusDay(dayCount, 'repair_st_ti_m');
				return;
			}

			if(endTiH < 1 || endTiH > 23) {
				alert("정비종료 입력 시 시간은 (01 ~ 23)시로 입력 해야합니다.");
				focusDay(dayCount, 'repair_ed_ti_h');
				return;
			}

			if(endTiM > 59) {
				alert("정비종료 입력 시 분은 (01 ~ 59)분으로 입력 해야합니다.");
				focusDay(dayCount, 'repair_ed_ti_m');
				return;
			}

			if((startTiH > endTiH) || (startTiH == endTiH && startTiM > endTiM)) {
				alert("정비시작시간은 정비종료시간보다 늦을 수 없습니다.");
				focusDay(dayCount, 'repair_ed_ti_h');
				return;
			}

			var repairStTi = $M.lpad($M.getValue("repair_st_ti_h"+dayCount), 2, '0') + $M.lpad($M.getValue("repair_st_ti_m"+dayCount), 2, '0');
			var repairEdTi = $M.lpad($M.getValue("repair_ed_ti_h"+dayCount), 2, '0') + $M.lpad($M.getValue("repair_ed_ti_m"+dayCount), 2, '0');

			repair_st_ti.push(repairStTi);
			repair_ed_ti.push(repairEdTi);
			repair_hour.push($('#repair_hour'+dayCount).val())
			standard_hour.push($('#standard_hour'+dayCount).val())
			// #으로 내용이 적힐 시 서버에서 안들어가는 문제
			repair_text.push($('#repair_text'+dayCount).val().replaceAll("#", "!!@@!!"))
			day_seq_no.push($('#day_seq_no'+dayCount).val())
		}

		var travelStartTiH = $M.toNum($M.getValue("travel_st_ti_h"));
		var travelStartTiM = $M.toNum($M.getValue("travel_st_ti_m"));
		var travelEndTiH = $M.toNum($M.getValue("travel_ed_ti_h"));
		var travelEndTiM = $M.toNum($M.getValue("travel_ed_ti_m"));

		if($M.getValue("job_case_ti") == "T") {
			if (travelStartTiH < 1 || travelStartTiH > 23) {
				alert("출장시작 입력 시 시간은 (01 ~ 23)시로 입력 해야합니다.");
				return;
			}

			if (travelStartTiM > 59) {
				alert("출장시작 입력 시 분은 (01 ~ 59)분으로 입력 해야합니다.");
				return;
			}

			if (travelEndTiH < 1 || travelEndTiH > 23) {
				alert("출장종료 입력 시 시간은 (01 ~ 23)시로 입력 해야합니다.");
				return;
			}

			if (travelEndTiM > 59) {
				alert("출장종료 입력 시 분은 (01 ~ 59)분으로 입력 해야합니다.");
				return;
			}

			if ((travelStartTiH > travelEndTiH) || (travelStartTiH == travelEndTiH && travelStartTiM > travelEndTiM)) {
				alert("출장시작시간은 출장종료시간보다 늦을 수 없습니다.");
				return;
			}
		}

		// 3.정비정보 Setting
		var travelStTi = $M.lpad($M.getValue("travel_st_ti_h"), 2, '0') + $M.lpad($M.getValue("travel_st_ti_m"), 2, '0');
		var travelEdTi = $M.lpad($M.getValue("travel_ed_ti_h"), 2, '0') + $M.lpad($M.getValue("travel_ed_ti_m"), 2, '0');

		$M.setValue("travel_st_ti", travelStTi);
		$M.setValue("travel_ed_ti", travelEdTi);

		// 4.정비분류 Setting
		var break_part_seq = [];
		var break_status_cd = [];
		var break_reason_cd = [];
		var remark = [];
		var use_yn = [];
		var break_seq_no = [];
		var break_row_no = [];
		var break_cmd = [];

		$('div[id^="child_div"]').each(function () {
			var parent_div = $(this);
			var child_div = parent_div.children();

			break_part_seq.push(child_div.find('[id^="break_part_seq"]').val());
			break_status_cd.push(child_div.find('[id^="break_status_cd"]').val());
			break_reason_cd.push(child_div.find('[id^="break_reason_cd"]').val());
			remark.push(child_div.find('[id^="remark"]').val());
			use_yn.push(child_div.find('[id^="use_yn"]').val());
			break_seq_no.push(child_div.find('[id^="seq_no"]').val());
			break_row_no.push(child_div.find('[id^="row_no"]').val());

			if(child_div.find('[id^="reg_date"]').val() == "") {
				break_cmd.push("C");
			} else {
				break_cmd.push("U");
			}
		});

		frm = $M.toValueForm(document.main_form);

		// 9.17 채평석 상무님이 무조건 무상으로 나오게 하지말고 비용있으면 유상으로 나오게 하라고 함.
		// if ($M.getValue("work_total_amt") + $M.getValue("travel_final_expense") + $M.getValue("part_total_amt") == 0) {
		// 	$M.setHiddenValue(frm, "cost_yn", "N");
		// } else {
		// 	$M.setHiddenValue(frm, "cost_yn", "Y");
		// }

		var option = {
			isEmpty : true
		};

		// 일자별 정비내용
		$M.setValue(frm, "day_seq_no_str", $M.getArrStr(day_seq_no, option));
		$M.setValue(frm, "repair_st_ti_str", $M.getArrStr(repair_st_ti, option));
		$M.setValue(frm, "repair_ed_ti_str", $M.getArrStr(repair_ed_ti, option));
		$M.setValue(frm, "repair_hour_str", $M.getArrStr(repair_hour, option));
		$M.setValue(frm, "standard_hour_str", $M.getArrStr(standard_hour, option));
		$M.setValue(frm, "repair_text_str", $M.getArrStr(repair_text, option));

		// 정비분류
		$M.setValue(frm, "break_part_seq_str", $M.getArrStr(break_part_seq, option));
		$M.setValue(frm, "break_status_cd_str", $M.getArrStr(break_status_cd, option));
		$M.setValue(frm, "break_reason_cd_str", $M.getArrStr(break_reason_cd, option));
		$M.setValue(frm, "remark_str", $M.getArrStr(remark, option));
		$M.setValue(frm, "use_yn_str", $M.getArrStr(use_yn, option));
		$M.setValue(frm, "break_seq_no_str", $M.getArrStr(break_seq_no, option));
		$M.setValue(frm, "break_row_no_str", $M.getArrStr(break_row_no, option));
		$M.setValue(frm, "break_cmd_str", $M.getArrStr(break_cmd, option));

		if($M.getValue("co_type") == "B") {
			// 동행인 (공임배분)
			var co_as_no = [];
			var co_mem_no = [];
			var co_work_rate = [];
			var co_work_amt = [];
			var co_cmd = [];

			$('div[id^="cowoker_div_"]').each(function () {
				var parent_div = $(this);
				var child_div = parent_div.children();

				co_as_no.push(child_div.find('[id^="co_as_no"]').val());
				co_mem_no.push(child_div.find('[id^="co_mem_no"]').val());
				co_work_rate.push(child_div.find('[id^="co_work_rate"]').val());
				co_work_amt.push($M.toNum(child_div.find('[id^="co_work_amt"]').val()));
				co_cmd.push("C");
			});

			$M.setValue(frm, "co_as_no_str", $M.getArrStr(co_as_no, option));
			$M.setValue(frm, "co_mem_no_str", $M.getArrStr(co_mem_no, option));
			$M.setValue(frm, "co_work_rate_str", $M.getArrStr(co_work_rate, option));
			$M.setValue(frm, "co_work_amt_str", $M.getArrStr(co_work_amt, option));
			$M.setValue(frm, "co_cmd_str", $M.getArrStr(co_cmd, option));
		}

		var msg = "";
		if(isRequestAppr != undefined) {
			if(isRequestAppr == "appr") {
			// 결재 Setting
				$M.setValue("save_mode", "approval");
			} else {
			// 결재요청 Setting
				$M.setValue("save_mode", "appr");
				msg = "결재요청 하시겠습니까?";
			}
		} else {
			$M.setValue("save_mode", "modify");
			msg = "수정 하시겠습니까?";
		}

		if(msg != "" && confirm(msg) == false) {
			return;
		}

		$M.goNextPageAjax(this_page + "/modify", frm, {method : "POST"},
			function(result) {
				if(result.success) {
					if(isRequestAppr == "appr") {
						location.reload();
					} else {
						alert("처리가 완료되었습니다.");
						location.reload();
					}
				}
			}
		);
	}

	// 서비스일지출력
	function fnPrint() {
		openReportPanel('serv/serv0102p01_01.crf','s_as_no=' + $M.getValue("as_no"));
	}

	// 삭제
	function goRemove() {
		var frm = $M.toValueForm(document.main_form);

		$M.goNextPageAjaxRemove(this_page + "/remove", frm, {method: "POST"},
				function (result) {
					if (result.success) {
						alert("삭제가 완료되었습니다.");
						fnClose();
						try {
							window.opener.goSearch();
						} catch (e) {
						}
					}
				}
		);
	}

	// 일자별로 삭제요청 들어올거 같아서 미리 생성
	function goRemoveDay(index) {
		var dayList = ${dayListJson};

		if(dayList.length == 1) {
			alert("마지막 정비일자는 삭제할 수 없습니다.\n삭제를 원하는 경우 전체 정비일지를 삭제해주세요.");
			return;
		}

		var param = {
			"as_no" : $M.getValue("as_no"),
			"seq_no" : $M.getValue("day_seq_no"+index),
		}

		$M.goNextPageAjaxRemove(this_page + "/remove/day", frm, {method: "POST"},
				function (result) {
					if (result.success) {
						alert("삭제가 완료되었습니다.");
						location.reload();
						try {
							window.opener.goSearch();
						} catch (e) {
						}
					}
				}
		);
	}

	// 닫기
	function fnClose() {
		window.close();

		// refresh를 원할경우
		if($M.getValue("s_refresh_page_yn") == "Y") {
			window.opener.goSearch();
		}
	}

	// 6.부품내역 그리드
	function createAUIGridParts() {
		var gridPros = {
			// 행 구별 필드명 지정
			rowIdField : "_$uid",
			// 수정 여부
			editable : false,
			// RowNumber
			showRowNumColumn : true,
			// fixedColumnCount : 2,
		};

		var columnLayout = [
			{
				headerText : "부품번호",
				dataField : "part_no",
				style : "aui-center",
			},
			{
				headerText : "부품명",
				dataField : "part_name",
				style : "aui-left",
			},
			{
				headerText : "구분코드",
				dataField : "normal_yn",
				visible : false
			},
			{
				headerText : "수량",
				dataField : "use_qty",
				style : "aui-center",
				dataType : "numeric",
				formatString : "#,##0"
			},
			{
				headerText : "단가",
				dataField : "unit_price",
				style : "aui-center",
				dataType : "numeric",
				formatString : "#,##0"
			},
			{
				headerText : "금액",
				dataField : "bill_amount",
				style : "aui-center",
				dataType : "numeric",
				formatString : "#,##0"
			}
		];


		// 실제로 #grid_wrap에 그리드 생성
		auiGridParts = AUIGrid.create("#auiGridParts", columnLayout, gridPros);
		// 그리드 갱신
		AUIGrid.setGridData(auiGridParts, ${partList});
	}

	// 서비스미결 그리드
	function createAUIGridAsTodos() {
		var gridPros = {
			showRowNumColumn : false,
		};

		var columnLayout = [
			{
				headerText : "예정일자",
				dataField : "plan_dt",
				style : "aui-center",
				width : "20%",
				dataType : "date",
				formatString : "yyyy-mm-dd",
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

		// 실제로 #grid_wrap에 그리드 생성
		auiGridAsTodos = AUIGrid.create("#auiGridAsTodos", columnLayout, gridPros);
		// 그리드 갱신
		AUIGrid.setGridData(auiGridAsTodos, ${asTodoList});

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

	function show(id) {
		document.getElementById(id).style.display="block";
	}
	function hide(id) {
		document.getElementById(id).style.display="none";
	}

	function fnSetMissMem(data) {
		$M.setValue("miss_mem_name", data.mem_name);
		$M.setValue("miss_mem_no", data.mem_no);
	}

	// 작업지시서
	function goJobReportSign() {
		if($M.getValue("modusign_file_seq") == "") {
			alert("고객서명이 완료되지 않았습니다.\n고객서명 완료 후 다시 시도해주세요.");
			return;
		}

		openFileViewerPanel($M.getValue("modusign_file_seq"));
	}

	function fnPreview(fileSeq) {
		var params = {
			file_seq : fileSeq
		};
		var popupOption = "";
		$M.goNextPage('/comp/comp0709', $M.toGetParam(params), {popupStatus : popupOption});
	}

	function focusDay(index, itemId) {
		$('ul.tabs-c li a').removeClass('active');
		$('.tabs-inner').removeClass('active');

		$('ul.tabs-c li a').each(function() {
			var tab_id = $(this).attr('data-tab');

			if(tab_id.substring(5) == index) {
				$(this).addClass('active');
				$("#"+tab_id).addClass('active');
			}
		});

		$('#'+itemId+index).focus();
	}

	// 파일추가
	function fnAddFile(type){
		var fileSeqArr = [];
		var fileSeqStr = "";
		$("[name=att_file_seq"+type+"]").each(function() {
			fileSeqArr.push($(this).val());
		});

		fileSeqStr = $M.getArrStr(fileSeqArr);

		var fileParam = "";
		if("" != fileSeqStr) {
			fileParam = '&file_seq_str='+fileSeqStr;
		}

		openFileUploadMultiPanel('setFileInfo'+type, 'upload_type=SERV&file_type=both&total_max_count=0'+fileParam);
	}

	function setFileInfoR(result){
		setFileInfo(result, 'R');
	}

	function setFileInfoJ(result) {
		setFileInfo(result, 'J');
	}

	// 파일세팅
	function setFileInfo(result, type) {
		$(".fileDiv"+type).remove(); // 파일영역 초기화

		var fileList = result.fileList;  // 공통 파일업로드(다중) 에서 넘어온 file list
		for (var i = 0; i < fileList.length; i++) {
			fnPrintFile(fileList[i].file_seq, fileList[i].file_name, type);
		}
	}

	// 첨부파일 출력 (멀티)
	function fnPrintFile(fileSeq, fileName, type) {
		var str = '';
		str += '<div class="table-attfile-item att_file_' + fileSeq + ' fileDiv'+ type +'"style="float:left; display:block;">';
		str += '<a href="javascript:fileDownload(' + fileSeq + ');" style="color: blue; vertical-align: middle;">' + fileName + '</a>&nbsp;';
		str += '<input type="hidden" name="att_file_seq'+ type +'" value="' + fileSeq + '"/>';
		if(${result.repair_complete_yn ne 'Y'}) {
			str += '<button type="button" class="btn-default check-dis" onclick="javascript:fnRemoveFile(' + fileSeq + ')"><i class="material-iconsclose font-18 text-default"></i></button>';
		}

		str += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
		str += '</div>';
		$('.att_file_div'+type).append(str);
	}

	// 첨부파일 삭제
	function fnRemoveFile(fileSeq) {
		if (confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.")) {
			$(".att_file_" + fileSeq).remove();
			removeFileArr.push(fileSeq);
		} else {
			return false;
		}
	}

	function fnShowFile(type) {
		var fileArr = [];

		$("[name=att_file_seq"+type+"]").each(function () {
			fileArr.push($(this).val());
		});

		if(fileArr.length == 0) {
			alert("파일추가 후 다시 시도해주세요.");
			return;
		}

		var param = {
			"file_seq_str" : $M.getArrStr(fileArr),
		}
		openFileImagePanel($M.toGetParam(param));
	}

	// 첨부서류 일괄다운로드
	function fnFileAllDownload() {
		var fileSeqArr = [];
		$("[name*=att_file_seq]").each(function () {
			fileSeqArr.push($(this).val());
		});

		var zipFileName = $M.getValue("cust_name")+ "," + $M.getValue("machine_name") + ","
				+ $M.getValue("body_no") + "," + $M.dateFormat($M.getValue("in_dt"), 'yyyy-MM-dd');

		var paramObj = {
			'file_seq_str' : $M.getArrStr(fileSeqArr),
			'zip_file_name' : zipFileName,
		}

		fileDownloadZip(paramObj);
	}

	// 글자수 체크
	function fnChkByte(obj, index) {
		var str = obj.value;
		var str_len = str.length;
		var rbyte = 0;
		var rlen = 0;
		var pass_len = 0;
		var one_char = "";
		for (var i = 0; i < str_len; i++) {
			one_char = str.charAt(i);
			if (escape(one_char).length > 4) {
				rbyte += 2; //한글2Byte
			} else {
				rbyte++; //영문 등 나머지 1Byte
			};
			if (rbyte <= maxByte) {
				rlen = i + 1; //return할 문자열 갯수
				pass_len = rbyte;
			};
		}

		if(rbyte > maxByte) {
			alert("최대 글자수를 초과하였습니다.");
			$M.setValue("repair_text"+index, $M.getValue("repair_text"+index).substring(0, rlen));
			rbyte = pass_len;
		}
		$('#repair_text_cnt' + index).html('글자수 : ' + rbyte + ' / ' + maxByte);
	}

	// 업무DB 오픈
	function openWorkDB(){
		var machinePlantSeq = $M.getValue("machine_plant_seq");
		var machineSeq = $M.getValue("machine_seq");
		if(machineSeq == ''){
			alert("장비번호가 없습니다.");
			return;
		}

		openWorkDBPanel(machineSeq, machinePlantSeq);
	}

	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<input type="hidden" id="job_report_no" name="job_report_no" value="${result.job_report_no}">
	<input type="hidden" id="as_no" name="as_no" value="${result.as_no}">
	<input type="hidden" id="in_dt" name="in_dt" value="${result.in_dt}">
	<input type="hidden" id="total_as_dt" name="total_as_dt" value="${result.as_dt}">
	<input type="hidden" id="machine_seq" name="machine_seq" value="${result.machine_seq}">
	<input type="hidden" id="__s_machine_seq" name="__s_machine_seq" value="${result.machine_seq}">
	<input type="hidden" id="machine_plant_seq" name="machine_plant_seq" value="${result.machine_plant_seq}">
	<input type="hidden" id="cust_no" name="cust_no" value="${result.cust_no}">
	<input type="hidden" id="__s_cust_no" name="__s_cust_no" value="${result.cust_no}">
	<input type="hidden" id="travel_st_ti" name="travel_st_ti" value="${result.travel_st_ti}">
	<input type="hidden" id="travel_ed_ti" name="travel_ed_ti" value="${result.travel_ed_ti}">
	<input type="hidden" id="save_mode" name="save_mode">
	<input type="hidden" id="as_repair_type_ro" name="as_repair_type_ro" value="${result.as_repair_type_ro}">
	<input type="hidden" id="as_type" name="as_type">
	<input type="hidden" id="co_type" name="co_type" value="B">
	<input type="hidden" id="appr_job_seq" name="appr_job_seq" value="${result.appr_job_seq}">
	<input type="hidden" id="prev_op_hour" name="prev_op_hour" value="${prev_op_hour}">
	<input type="hidden" id="modusign_file_seq" name="modusign_file_seq" value="${result.modusign_file_seq}">
	<input type="hidden" id="__s_reg_type" name="__s_reg_type" value="D">
	<input type="hidden" id="__s_menu_type" name="__s_menu_type" value="S">
	<input type="hidden" id="s_refresh_page_yn" name="s_refresh_page_yn" value="${inputParam.s_refresh_page_yn}">
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
					<div class="title-wrap">
						<div class="left approval-left">
							<div></div>
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
						</div>
						<!-- 결재영역 -->
						<div class="pl10">
							<jsp:include page="/WEB-INF/jsp/common/apprHeader.jsp"></jsp:include>
						</div>
						<!-- /결재영역 -->
					</div>
					<div class="row mt10">
						<!-- 1. 장비정보 -->
						<div class="col-6">
							<table class="table-border mt5">
								<colgroup>
									<col width="80px">
									<col width="">
									<col width="80px">
									<col width="">
									<col width="80px">
									<col width="">
								</colgroup>
								<tbody>
								<tr>
									<th class="text-right essential-item">차대번호</th>
									<td>
										<input type="text" id="body_no" name="body_no" class="form-control essential-bg" readonly="readonly" required="required" alt="차대번호" value="${result.body_no}">
										<div class="d-flex mt5">
											<div class="mr5">
												<jsp:include page="/WEB-INF/jsp/common/commonMachineJob.jsp">
													<jsp:param name="li_machine_type" value="__machine_detail#__repair_history#__as_todo#__campaign"/>
												</jsp:include>
											</div>
											<div>
												<button type="button" class="btn btn-primary-gra" onclick="javascript:openWorkDB();">업무DB</button>
											</div>
										</div>
									</td>
									<th class="text-right">장비모델</th>
									<td>
										<input type="text" id="machine_name" name="machine_name" class="form-control width120px" readonly="readonly" value="${result.machine_name}">
									</td>
									<th class="text-right">출하일자</th>
									<td>
										<div class="input-group width120px">
											<input type="text" class="form-control border-right-0 calDate" id="out_dt" name="out_dt" dateFormat="yyyy-MM-dd" value="${result.out_dt}" disabled="disabled">
										</div>
									</td>
								</tr>
								<tr>
									<th class="text-right">CAP<i class="material-iconserror font-16" style="vertical-align: middle;" onmouseover="javascript:show('help_operation')" onmouseout="javascript:hide('help_operation')"></i></th>
									<div class="con-info" id="help_operation" style="max-height: 500px; top: 90%; left: 7%; width: 230px; display: none;">
										<ul class="">
											<ol style="color: #666;">&nbsp;※ CAP적용/미적용은 장비대장에서 처리</ol>
										</ul>
									</div>
									<td>
										<div class="form-row inline-pd">
											<div class="col-6">
												<span id="cap">${result.cap}</span>
											</div>
											<div class="col-6 text-right">
												<button type="button" class="btn btn-primary-gra" onclick="javascript:goCapLog();">CAP이력</button>
											</div>
										</div>
									</td>
									<th class="text-right">CAP회차</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width33px">현재</div>
											<div class="col width40px">
												<input type="text" id="cap_cnt" name="cap_cnt" class="form-control text-center" readonly="readonly" value="${result.cap_cnt}">
											</div>
											<div class="col width16px">차,</div>
											<div class="col width33px pl5">다음</div>
											<div class="col width40px">
												<input type="text" id="next_cap_cnt" name="next_cap_cnt" class="form-control text-center" readonly="readonly" value="${result.next_cap_cnt}">
											</div>
											<div class="col width16px">차</div>
										</div>
									</td>
									<th class="text-right">CAP예정일자</th>
									<td>
										<div class="input-group width120px">
											<input type="text" class="form-control border-right-0 calDate" id="cap_plan_dt" name="cap_plan_dt" dateFormat="yyyy-MM-dd" value="${result.cap_plan_dt}">
										</div>
									</td>
								</tr>
								</tbody>
							</table>
						</div>
						<!-- /1. 장비정보 -->
						<!-- 2. 고객정보 -->
						<div class="col-6">
							<table class="table-border mt5">
								<colgroup>
									<col width="70px">
									<col width="190px">
									<col width="70px">
									<col width="190">
									<col width="90px">
									<col width="">
								</colgroup>
								<tbody>
								<tr>
									<th class="text-right essential-item">고객명</th>
									<td>
										<div class="form-row inline-pd pr">
											<div class="col-6">
												<input type="text" id="cust_name" name="cust_name" class="form-control essential-bg" readonly="readonly" required="required" alt="차주명" value="${result.cust_name}">
											</div>
											<div class="col-6">
												<jsp:include page="/WEB-INF/jsp/common/commonCustJob.jsp">
													<jsp:param name="li_type" value="__cust_dtl#__ledger#__visit_history#__as_call"/>
												</jsp:include>
											</div>
										</div>
									</td>
									<th class="text-right">휴대폰</th>
									<td>
										<div class="input-group width140px">
											<input type="text" id="hp_no" name="hp_no" class="form-control border-right-0" format="phone" readonly="readonly" value="${result.hp_no}">
											<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSendSms();" ><i class="material-iconsforum"></i></button>
										</div>
									</td>
									<th class="text-right">업체명</th>
									<td>
										<input type="text" id="breg_name" name="breg_name" class="form-control" readonly="readonly" value="${result.breg_name}">
									</td>
								</tr>
								<tr>
									<th class="text-right">주소</th>
									<td colspan="3">
										<div class="form-row inline-pd">
											<div class="col-6">
												<input type="text" id="addr1" name="addr1" class="form-control" readonly="readonly" value="${result.addr1}">
											</div>
											<div class="col-6">
												<input type="text" id="addr2" name="addr2" class="form-control" readonly="readonly" value="${result.addr2}">
											</div>
										</div>
									</td>
									<th class="text-right">쿠폰잔액/미수</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width100px">
												<input type="text" id="misu_amt" name="misu_amt" class="form-control text-right" readonly="readonly" format="decimal" value="${result.misu_amt}">
											</div>
											/&nbsp;
											<div class="col width100px">
												<input type="text" id="di_balance_amt" name="di_balance_amt" class="form-control text-right" readonly="readonly" format="decimal" value="${result.di_balance_amt}">
											</div>
										</div>
									</td>
								</tr>
								</tbody>
							</table>
						</div>
						<!-- /2. 고객정보 -->
					</div>

					<!-- 3. 정비접수 -->
					<div class="title-wrap mt10">
						<div class="left">
							<h4 class="mr5">정비접수</h4>
							<a href="#" class="btn-link" onclick="javascript:goJobReport();">(${result.job_report_no} 정비지시서)</a>
						</div>
						<div class="right">
							<span class="mr5 text-warning">총액(VAT별도)</span>
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
<%--							<button type="button" class="btn btn-default" onclick="javascript:goMap();"><i class="material-iconsplace text-default"></i>지도보기</button>--%>
						</div>
					</div>
					<table class="table-border mt5">
						<colgroup>
							<col width="85px">
							<col width="">
							<col width="85px">
							<col width="">
							<col width="85px">
							<col width="">
							<col width="110px">
							<col width="">
							<col width="85px">
							<col width="">
							<col width="85px">
							<col width="">
						</colgroup>
						<tbody>
							<tr>
								<th class="text-right essential-item">정비구분</th>
								<td>
                  <%-- 자동화 개발건 - 정비구분2 추가되면서 input 으로 변경 --%>
<%--									<select class="form-control" name="job_type_cd" id="job_type_cd" required="required" disabled alt="정비구분">--%>
<%--										<option value="">- 선택 -</option>--%>
<%--										<c:forEach var="list" items="${codeMap['JOB_TYPE']}">--%>
<%--											<option value="${list.code_value}" ${list.code_value == result.job_type_cd ? 'selected="selected"' : ''} >${list.code_name}</option>--%>
<%--										</c:forEach>--%>
<%--									</select>--%>
                    <input type="text" id="job_type_total_name" name="job_type_total_name" class="form-control" readonly="readonly"/>
								</td>
								<th class="text-right">유무상구분</th>
								<td>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="cost_yn_y" name="cost_yn" value="Y" <c:if test="${result.cost_yn eq 'Y'}">checked="checked"</c:if> required="required" alt="유무상구분">
										<label class="form-check-label" for="cost_yn_y">유상</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="cost_yn_n"  name="cost_yn" value="N" <c:if test="${result.cost_yn eq 'N'}">checked="checked"</c:if> required="required" alt="유무상구분">
										<label class="form-check-label" for="cost_yn_n">무상</label>
									</div>
								</td>
								<th class="text-right">정비종류</th>
								<td>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="job_case_ti_i" name="job_case_ti" value="I" <c:if test="${result.job_case_ti eq 'I'}">checked="checked"</c:if> required="required" alt="정비종류" disabled onchange="javascript:fnJobCaseTi();">
										<label class="form-check-label" for="job_case_ti_i">입고</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="job_case_ti_t"  name="job_case_ti" value="T" <c:if test="${result.job_case_ti eq 'T'}">checked="checked"</c:if> required="required" alt="정비종류" disabled onchange="javascript:fnJobCaseTi();">
										<label class="form-check-label" for="job_case_ti_t">출장</label>
									</div>
								</td>
								<th class="text-right">재정비</th>
								<td>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="rework_ync_n" name="rework_ync" value="N" <c:if test="${result.rework_ync eq 'N'}">checked="checked"</c:if> required="required" alt="재정비">
										<label class="form-check-label" for="rework_ync_n">N</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="rework_ync_y"  name="rework_ync" value="Y" <c:if test="${result.rework_ync eq 'Y'}">checked="checked"</c:if> required="required" alt="재정비">
										<label class="form-check-label" for="rework_ync_y">Y</label>
									</div>
								</td>
								<th class="text-right">정비과실자</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-12">
											<div class="input-group width100px">
												<input type="text" id="miss_mem_name" name="miss_mem_name" class="form-control border-right-0" readonly="readonly" alt="정비과실자" value="${result.miss_mem_name}">
												<input type="hidden" id="miss_mem_no" name="miss_mem_no" value="${result.miss_mem_no}">
												<button type="button" id="miss_mem_no_btn" name="miss_mem_btn" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchMemberPanel('fnSetMissMem', 's_org_code=5000&s_repair_yn=Y');"><i class="material-iconssearch"></i></button>
											</div>
										</div>
									</div>
								</td>
								<th class="text-right">가동시간</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col width60px">
											<input type="text" id="op_hour" name="op_hour" class="form-control text-right" format="decimal" value="${result.op_hour}">
										</div>
										<div class="col width33px">hr</div>
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right">정비시간합계</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width70px">
											<input type="text" class="form-control text-right" id="total_repair_hour" name="total_repair_hour" datatype="int" readonly="readonly" value="${result.total_repair_hour}">
										</div>
										<div class="col width33px">
											hr
										</div>
									</div>
								</td>
								<th class="text-right">규정시간합계</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width70px">
											<input type="text" class="form-control text-right" id="total_standard_hour" name="total_standard_hour" readonly="readonly" value="${result.total_standard_hour}">
										</div>
										<div class="col width33px">hr</div>
									</div>
								</td>
								<th class="text-right">동행정비</th>
								<td colspan="3">
									<div class="form-row inline-pd">
										<div class="col-5">
											<input type="text" class="form-control width300px" id="cowoker" name="cowoker" readonly="readonly" value="${cowoker}">
											<c:forEach var="item" items="${cowokerList}" varStatus="status">
												<div id="cowoker_div_${item.row_num}">
													<div>
														<input type="hidden" id="co_as_no_${item.row_num}" name="co_as_no_${item.row_num}" value="${item.as_no}">
														<input type="hidden" id="co_mem_no_${item.row_num}" name="co_mem_no_${item.row_num}" value="${item.mem_no}">
														<input type="hidden" id="co_work_rate_${item.row_num}" name="co_work_rate_${item.row_num}" value="${item.work_rate}">
														<input type="hidden" id="co_work_amt_${item.row_num}" name="co_work_amt_${item.row_num}" value="${item.work_amt}">
													</div>
												</div>
											</c:forEach>
										</div>
										<div>
											<button type="button" id="_goRepairCowoker" class="btn btn-primary-gra ml5" onclick="javascript:goRepairCowoker();">공임배분</button>
										</div>
									</div>
								</td>
								<th class="text-right">공임비용</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control text-right" id="work_total_amt" name="work_total_amt" datatype="int" format="decimal" readonly="readonly" value="${result.work_total_amt}">
										</div>
										<div class="col width16px">원</div>
									</div>
								</td>
								<th class="text-right">부품비용</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control text-right" id="part_total_amt" name="part_total_amt" datatype="int" format="decimal" readonly="readonly" value="${result.part_total_amt}">
										</div>
										<div class="col width16px">원</div>
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right">출장위치</th>
								<td>
									<input type="text" class="form-control width200px" id="travel_area_name" name="travel_area_name" readonly="readonly" value="${result.travel_area_name}">
								</td>
								<th class="text-right">출장출발</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width40px">
											<input type="text" id="travel_st_ti_h" name="travel_st_ti_h" class="form-control text-right" minlength="2" maxlength="2" onchange="javascript:fnCalcTravelHour();" value="${result.travel_st_ti_h}">
										</div>
										<div class="col width16px">시</div>
										<div class="col width35px">
											<input type="text" id="travel_st_ti_m" name="travel_st_ti_m" class="form-control text-right" minlength="2" maxlength="2" onchange="javascript:fnCalcTravelHour();" value="${result.travel_st_ti_m}">
										</div>
										<div class="col width16px">분</div>
									</div>
								</td>
								<th class="text-right">출장완료</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width40px">
											<input type="text" id="travel_ed_ti_h" name="travel_ed_ti_h" class="form-control text-right" minlength="2" maxlength="2" onchange="javascript:fnCalcTravelHour();" value="${result.travel_ed_ti_h}">
										</div>
										<div class="col width16px">시</div>
										<div class="col width35px">
											<input type="text" id="travel_ed_ti_m" name="travel_ed_ti_m" class="form-control text-right" minlength="2" maxlength="2" onchange="javascript:fnCalcTravelHour();" value="${result.travel_ed_ti_m}">
										</div>
										<div class="col width16px">분</div>
									</div>
								</td>
								<th class="text-right">이동시간</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width60px">
											<input type="text" class="form-control text-right" id="move_hour" name="move_hour" value="${result.move_hour}">
										</div>
										<div class="col width33px">hr</div>
										<input type="hidden" class="form-control text-right" id="travel_km" name="travel_km" value="${result.travel_km}">
									</div>
								</td>
								<th class="text-right">출장비용</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control text-right" id="travel_final_expense" name="travel_final_expense" datatype="int" format="decimal" readonly="readonly" value="${result.travel_final_expense}">
										</div>
										<div class="col width16px">원</div>
									</div>
								</td>
								<th class="text-right">비용합계</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control text-right" id="total_amt" name="total_amt" datatype="int" format="decimal" readonly="readonly" value="${result.total_amt}">
										</div>
										<div class="col width16px">원</div>
									</div>
								</td>
								<input type="hidden" class="form-control text-right" id="travel_discount_amt" name="travel_discount_amt" datatype="int" format="decimal" readonly="readonly" value="${result.travel_discount_amt}">
							</tr>
						</tbody>
					</table>
					<!-- 3. 정비접수 -->
				</div>
				<!-- /상단 폼테이블 -->
				<!-- 중간 폼테이블 -->
				<div class="row mt10">
					<div class="col-4">
						<!-- 4. 정비분류 -->
						<div class="title-wrap">
							<div class="left">
								<h4>정비분류</h4>
							</div>
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_L"/></jsp:include>
							</div>
						</div>
						<div class="mt5" id="parent_div">
						<c:choose>
							<c:when test="${breakPartSize ne 0}">
								<c:forEach var="breakParts" items="${breakParts}" varStatus="status">
								<!-- No1. -->
									<div class="maintenance-item" id="child_div_${breakParts.seq_no}">
										<div class="header">No.${breakParts.row_num}</div>
										<div class="body">
											<div class="input-group">
												<input type="text" id="break_part_name_${breakParts.seq_no}" name="break_part_name_${breakParts.seq_no}" class="form-control border-right-0" readonly="readonly" placeholder="고장부위선택" value="${breakParts.mng_name}">
												<input type="hidden" id="break_part_seq_${breakParts.seq_no}" name="break_part_seq_${breakParts.seq_no}" value="${breakParts.break_part_seq}">
												<button type="button" id="_goBreakPart" name="_goBreakPart" class="btn btn-icon btn-primary-gra" onclick="javascript:goBreakPart();" ><i class="material-iconssearch"></i></button>
												<c:if test="${breakParts.seq_no ne 1}">
													<div class="text-right">
														<button type="button" id="_fnRemoveRow" name="_fnRemoveRow" class="btn btn-primary-gra ml5" style="width: 50px;" onclick="javascript:fnUpdateUseYnRow(${breakParts.seq_no})">삭제</button>
													</div>
												</c:if>
											</div>
											<div class="select-section mt3">
												<select class="form-control" id="break_status_cd_${breakParts.seq_no}" name="break_status_cd_${breakParts.seq_no}">
													<option value="">- 고장현상선택 -</option>
													<c:forEach items="${codeMap['BREAK_STATUS']}" var="item">
														<c:if test="${item.show_yn eq 'Y' && item.use_yn eq 'Y'}">
															<option value="${item.code_value}" <c:if test="${item.code_value == breakParts.break_status_cd}">selected="selected"</c:if> >${item.code_name}</option>
														</c:if>
													</c:forEach>
												</select>
												<select class="form-control" id="break_reason_cd_${breakParts.seq_no}" name="break_reason_cd_${breakParts.seq_no}">
													<option value="">- 고장원인선택 -</option>
													<c:forEach items="${codeMap['BREAK_REASON']}" var="item">
														<c:if test="${item.show_yn eq 'Y' && item.use_yn eq 'Y'}">
															<option value="${item.code_value}" <c:if test="${item.code_value == breakParts.break_reason_cd}">selected="selected"</c:if> >${item.code_name}</option>
														</c:if>
													</c:forEach>
												</select>
											</div>
											<input type="text" class="form-control mt5" id="remark_${breakParts.seq_no}" name="remark_${breakParts.seq_no}" placeholder="특이사항" value="${breakParts.remark}">
											<input type="hidden" id="use_yn_${breakParts.seq_no}" name="use_yn_${breakParts.seq_no}" value="${breakParts.use_yn}">
											<input type="hidden" id="reg_date_${breakParts.seq_no}" name="reg_date_${breakParts.seq_no}" value="${breakParts.reg_date}">
											<input type="hidden" id="seq_no_${breakParts.seq_no}" name="seq_no_${breakParts.seq_no}" value="${breakParts.seq_no}">
											<input type="hidden" id="row_no_${breakParts.seq_no}" name="row_no_${breakParts.seq_no}" value="${breakParts.seq_no}">
										</div>
									</div>
								</c:forEach>
							</c:when>
							<c:otherwise>
									<!-- No1. -->
									<div class="maintenance-item" id="child_div_1">
										<div class="header">No.1</div>
										<div class="body">
											<div class="input-group">
												<input type="text" id="break_part_name_1" name="break_part_name_1" class="form-control border-right-0" readonly="readonly" placeholder="고장부위선택" required="required" alt="고장부위선택">
												<input type="hidden" id="break_part_seq_1" name="break_part_seq_1">
												<input type="hidden" id="row_no_1" name="row_no_1" value="0">
												<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goBreakPart();" ><i class="material-iconssearch"></i></button>
											</div>
											<div class="select-section mt3">
												<select class="form-control" id="break_status_cd_1" name="break_status_cd_1" required="required" alt="고장현상">
													<option value="">- 고장현상선택 -</option>
													<c:forEach items="${codeMap['BREAK_STATUS']}" var="item">
														<c:if test="${item.show_yn eq 'Y' && item.use_yn eq 'Y'}">
															<option value="${item.code_value}">${item.code_name}</option>
														</c:if>
													</c:forEach>
												</select>
												<select class="form-control" id="break_reason_cd_1" name="break_reason_cd_1" required="required" alt="고장부위">
													<option value="">- 고장원인선택 -</option>
													<c:forEach items="${codeMap['BREAK_REASON']}" var="item">
														<c:if test="${item.show_yn eq 'Y' && item.use_yn eq 'Y'}">
															<option value="${item.code_value}">${item.code_name}</option>
														</c:if>
													</c:forEach>
												</select>
											</div>
											<input type="text" class="form-control mt5" id="remark_1" name="remark_1" placeholder="특이사항">
											<input type="hidden" id="reg_date_1" name="reg_date_1" value="">
										</div>
									</div>
									<!-- /No1. -->
							</c:otherwise>
						</c:choose>
						<!-- /No1. -->
						</div>
						<!-- /4. 정비분류 -->
						<!-- 5. 부품내역 -->
						<div class="title-wrap mt10">
							<div class="left">
								<h4>부품내역</h4>
							</div>
							<div class="right">
								<button type="button" class="btn btn-default" onclick="javascript:goPartDetail()">상세보기</button>
							</div>
						</div>
						<div id="auiGridParts" style="margin-top: 5px; height: 120px;"></div>
						<!-- /5. 부품내역 -->
						<!-- 6. 서비스 미결 -->
						<div class="title-wrap mt10">
							<div class="left">
								<h4>서비스 미결</h4>
							</div>
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_M"/></jsp:include>
							</div>
						</div>
						<div id="auiGridAsTodos" style="margin-top: 5px; height: 70px;"></div>
						<!-- /6. 서비스 미결 -->
					</div>
					<div class="col-8">
						<!-- 7. 정비내역 -->
						<ul class="tabs-c">
						<c:forEach var="dayItem" items="${dayList}" varStatus="dayStatus">
							<li class="tabs-item">
								<a href="#" class="tabs-link font-12 <c:if test="${(inputParam.s_seq_no eq dayStatus.count) or (empty inputParam.s_seq_no and dayStatus.count eq 1)}">active</c:if>" data-tab="inner${dayStatus.count}">${dayItem.as_dt}</a>
							</li>
						</c:forEach>
						</ul>
						<c:forEach var="dayItem" items="${dayList}" varStatus="dayStatus">
						<input type="hidden" id="day_seq_no${dayStatus.count}" name="day_seq_no${dayStatus.count}" value="${dayItem.seq_no}" alt="정비순서">
						<div class="tabs-inner <c:if test="${(inputParam.s_seq_no eq dayStatus.count) or (empty inputParam.s_seq_no and dayStatus.count eq 1)}">active</c:if>" id="inner${dayStatus.count}">
							<table class="table-border mt10">
								<colgroup>
									<col width="85px">
									<col width="">
									<col width="85px">
									<col width="">
									<col width="85px">
									<col width="">
									<col width="85px">
									<col width="">
									<col width="85px">
									<col width="">
								</colgroup>
								<tbody>
								<tr>
									<th class="text-right essential-item">정비시작</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width40px">
												<input type="text" id="repair_st_ti_h${dayStatus.count}" name="repair_st_ti_h${dayStatus.count}" value="${dayItem.repair_st_ti_h}" class="form-control text-right essential-bg" required="required" alt="정비시작 시간" datatype="int" minlength="2" maxlength="2" onchange="javascript:fnCalcRepairHour('${dayStatus.count}');">
											</div>
											<div class="col width16px">시</div>
											<div class="col width35px">
												<input type="text" id="repair_st_ti_m${dayStatus.count}" name="repair_st_ti_m${dayStatus.count}" value="${dayItem.repair_st_ti_m}" class="form-control text-right essential-bg" required="required" alt="정비시작 분" datatype="int" minlength="2" maxlength="2" onchange="javascript:fnCalcRepairHour('${dayStatus.count}');">
											</div>
											<div class="col width16px">분</div>
										</div>
									</td>
									<th class="text-right">정비종료</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width40px">
												<input type="text" id="repair_ed_ti_h${dayStatus.count}" name="repair_ed_ti_h${dayStatus.count}" value="${dayItem.repair_ed_ti_h}" class="form-control text-right" datatype="int" minlength="2" maxlength="2" onchange="javascript:fnCalcRepairHour('${dayStatus.count}');">
											</div>
											<div class="col width16px">시</div>
											<div class="col width35px">
												<input type="text" id="repair_ed_ti_m${dayStatus.count}" name="repair_ed_ti_m${dayStatus.count}" value="${dayItem.repair_ed_ti_m}" class="form-control text-right" datatype="int" minlength="2" maxlength="2" onchange="javascript:fnCalcRepairHour('${dayStatus.count}');">
											</div>
											<div class="col width16px">분</div>
										</div>
									</td>
									<th class="text-right">정비시간</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width70px">
												<input type="text" class="form-control text-right" id="repair_hour${dayStatus.count}" name="repair_hour${dayStatus.count}" datatype="int" readonly="readonly" value="${dayItem.repair_hour}">
											</div>
											<div class="col width33px">
												hr
											</div>
										</div>
									</td>
									<th class="text-right">규정시간</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width70px">
												<input type="text" class="form-control text-right" id="standard_hour${dayStatus.count}" name="standard_hour${dayStatus.count}" value="${dayItem.standard_hour}" onchange="javascript:fnCalcStandardHour();">
											</div>
											<div class="col width33px">hr</div>
										</div>
									</td>
									<th class="text-right">작성자</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width100px">
												<input type="text" class="form-control text-left" id="reg_mem_name${dayStatus.count}" name="reg_mem_name${dayStatus.count}" value="${dayItem.reg_mem_name}" readonly>
											</div>
										</div>
									</td>
								</tr>
								</tbody>
							</table>
							<div class="title-wrap mt10">
								<div class="left">
									<h4>정비내역</h4>
									<span class="ml5" id="repair_text_cnt${dayStatus.count}" style="font-weight: bold; color : red;">
									</span>
								</div>
								<div class="right">
									<button type="button" class="btn btn-info material-iconsadd" onclick="javascript:goLarge('${dayStatus.count}')">크게보기</button>
								</div>
							</div>
							<div class="mt5" style="height: 365px;">
								<textarea class="form-control" style="height: 365px;" id="repair_text${dayStatus.count}" name="repair_text${dayStatus.count}" placeholder="정비내역을 입력 할 수 있습니다." onkeyUp="javascript:fnChkByte(this,'${dayStatus.count}')" >${dayItem.repair_text}</textarea>
							</div>
						</div>
						</c:forEach>
						<!-- /7. 정비내역 -->
						<div class="title-wrap mt5">
							<div class="left">
								<h4>정비사진</h4>
							</div>
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_M"/></jsp:include>
							</div>
						</div>
						<table class="table-border mt5">
							<colgroup>
								<col width="100px">
								<col width="">
							</colgroup>
							<tbody>
							<tr>
								<th class="text-right">정비사진</th>
								<td>
									<div class="table-attfile att_file_divR" style="width:100%;">
										<div class="table-attfile" style="float:left">
											<button type="button" class="btn btn-primary-gra mr5" onclick="javascript:fnShowFile('R');">파일 이미지보기</button>
											<c:if test="${result.repair_complete_yn ne 'Y'}">
												<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:fnAddFile('R');">파일찾기</button>
											</c:if>
										</div>
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right">종이정비지시서</th>
								<td>
									<div class="table-attfile att_file_divJ" style="width:100%;">
										<div class="table-attfile" style="float:left">
											<button type="button" class="btn btn-primary-gra mr5" onclick="javascript:fnShowFile('J');">파일 이미지보기</button>
											<c:if test="${result.repair_complete_yn ne 'Y'}">
												<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:fnAddFile('J');">파일찾기</button>
											</c:if>
										</div>
									</div>
								</td>
							</tr>
							</tbody>
						</table>
					</div>
				</div>
				<!-- /중간 폼테이블 -->
				<!-- 하단 폼테이블 -->
				<div class="row mt10">
					<div class="col-4">
						<!-- 8. 기타 -->
						<div class="title-wrap">
							<div class="left">
								<h4>참고사항</h4>
							</div>
						</div>
						<div class="mt5">
							<textarea class="form-control" id="ref_text" name="ref_text" style="height: 110px;" placeholder="참고사항 관련 메모가 들어갑니다.">${result.ref_text}</textarea>
						</div>
					</div>
					<div class="col-8">
						<!-- 결재자의견 -->
						<div class="title-wrap">
							<div class="left">
								<h4>결재자의견</h4>
							</div>
							<div class="right">
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
						<!-- /결재자의견 -->
					</div>
				</div>
				<!-- /하단 폼테이블 -->
				<div class="btn-group mt10">
					<div class="right">
						<button type="button" id="goModify2" class="btn btn-info dpn" onclick="javascript:goModify();">수정</button>
						<button type="button" id="goRemove2" class="btn btn-info dpn" onclick="javascript:goRemove();">삭제</button>
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/><jsp:param name="appr_yn" value="${(empty result.appr_job_seq or result.appr_job_seq eq 0) ? 'N' : 'Y'}"/></jsp:include>
					</div>
				</div>
			</div>
		</div>
		<!-- /팝업 -->
</form>
</body>
</html>
