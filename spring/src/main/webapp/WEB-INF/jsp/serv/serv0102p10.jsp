<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 정비 > 서비스일지 > null > 서비스일지 등록
-- 작성자 : 성현우
-- 최초 작성일 : 2020-07-15 11:12:10
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		// 6.부품내역 Grid
		var auiGridParts;
		// 서비스미결 Grid
		var auiGridAsTodos;

		// 4.정비분류 No
		var i = 1;

		var item = ${resultInfo};
		var pro = ${promotionMap};
		var sessionCehckTime = 1000 * 60 * 5;
		$(document).ready(function() {

			fnToggle();
			fnJobCaseTi();

			// 6. 부품내역
			createAUIGridParts();
			// 서비스미결
			createAUIGridAsTodos();

			fnInit();
		});

		// 참고 탭
		function fnToggle() {
			$('ul.tabs-c li a').click(function() {
				var tab_id = $(this).attr('data-tab');

				$('ul.tabs-c li a').removeClass('active');
				$('.tabs-inner').removeClass('active');

				$(this).addClass('active');
				$("#"+tab_id).addClass('active');
			});
		};

		function fnInit() {
			var cap = item.cap;
			if(cap.indexOf("미적용") != -1) {
				$("#cap_plan_dt").prop("disabled", true);
			}

			fnCalcRepairHour();

			fnSetPromotion();
			fnSetFileInfo();
			
			// 공임배분
			fnSetRepairCowoker(${cowokerListJson});

			setInterval(function () {
				fnSessionCheck();
			}, sessionCehckTime);
		}

		function fnSessionCheck() {
			$M.goNextPageAjax('/session/check', '', {method: 'GET', loader: false},
					function (result) {
						console.log($M.getCurrentDate("yyyyMMddHHmmss"));
					}
			);
		}

		// 부품내역 상세보기
		function goPartDetail() {
			var param = {
				"s_job_report_no" : $M.getValue("job_report_no")
			}
				
			var popupOption = "";
			$M.goNextPage('/serv/serv0102p17', $M.toGetParam(param), {popupStatus : popupOption});
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

		// 서비스일지출력
		function goPrint() {
			alert("서비스일지출력은 저장 후 가능합니다.");
			return;
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

		// 고장부위
		function goBreakPart() {
			var params = {
				"parent_js_name" : "fnSetBreakPartInformation"
			};
			var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=750, height=420, left=0, top=0";
			$M.goNextPage('/serv/serv0102p07', $M.toGetParam(params), {popupStatus : popupOption});
		}

		function fnSetBreakPartInformation(data) {
			// alert(JSON.stringify(data));
			var repairText = $M.getValue("repair_text");
			if($M.getValue("break_part_seq_1") == "") {
				$M.setValue("break_part_name_1", data[0].item.mng_name);
				$M.setValue("break_part_seq_1", data[0].item.break_part_seq);

				repairText += "\n▶ " + data[0].item.mng_name + "\n-현상 :\n-원인 :\n-조치 :\n\n";
				$M.setValue("repair_text", repairText);

				for (var j = 1; j < data.length; j++) {
					fnAdd();
					$M.setValue("break_part_name_" + (j + 1), data[j].item.mng_name);
					$M.setValue("break_part_seq_" + (j + 1), data[j].item.break_part_seq);

					repairText += "▶ " + data[j].item.mng_name + "\n-현상 :\n-원인 :\n-조치 :\n\n";
					$M.setValue("repair_text", repairText);
				}
			} else {
				for (var j = 0; j < data.length; j++) {
					$M.setValue("break_part_name_" + i, data[j].item.mng_name);
					$M.setValue("break_part_seq_" + i, data[j].item.break_part_seq);

					repairText += "▶ " + data[j].item.mng_name + "\n-현상 :\n-원인 :\n-조치 :\n\n";
					$M.setValue("repair_text", repairText);

					if(j != data.length - 1) {
						fnAdd();
					}
				}
			}
		}

		// 정비접수 - 정비종류
		function fnJobCaseTi() {
			var trueFalse = true;
			if($M.getValue("job_case_ti") == "T") {
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

			if(trueFalse == true) {
				// 출장관련 컬럼 초기화
				$M.clearValue({field : ["area_name", "travel_st_ti_h", "travel_st_ti_m", "travel_ed_ti_h", "travel_ed_ti_m", "travel_km", "move_hour"]});
			}
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
			// alert(JSON.stringify(data));

			var repairText = $M.getValue("repair_text");
			if($M.getValue("break_part_seq_1") == "") {
				$M.setValue("break_part_name_1", data[0].item.mng_name);
				$M.setValue("break_part_seq_1", data[0].item.break_part_seq);
				$M.setValue("break_status_cd_1", data[0].item.break_status_cd);
				$M.setValue("break_reason_cd_1", data[0].item.break_reason_cd);
				$M.setValue("remark_1", data[0].item.remark);

				repairText += "▶ " + data[0].item.mng_name + "\n-현상 :\n-원인 :\n-조치 :\n\n";
				$M.setValue("repair_text", repairText);

				for (var j = 1; j < data.length; j++) {
					fnAdd();
					$M.setValue("break_part_name_" + (j + 1), data[j].item.mng_name);
					$M.setValue("break_part_seq_" + (j + 1), data[j].item.break_part_seq);
					$M.setValue("break_status_cd_" + (j + 1), data[j].item.break_status_cd);
					$M.setValue("break_reason_cd_" + (j + 1), data[j].item.break_reason_cd);
					$M.setValue("remark_" + (j + 1), data[j].item.remark);

					repairText += "▶ " + data[j].item.mng_name + "\n-현상 :\n-원인 :\n-조치 :\n\n";
					$M.setValue("repair_text", repairText);
				}
			} else {
				for (var j = 0; j < data.length; j++) {
					fnAdd();
					$M.setValue("break_part_name_" + i, data[j].item.mng_name);
					$M.setValue("break_part_seq_" + i, data[j].item.break_part_seq);
					$M.setValue("break_status_cd_" + i, data[j].item.break_status_cd);
					$M.setValue("break_reason_cd_" + i, data[j].item.break_reason_cd);
					$M.setValue("remark_" + i, data[j].item.remark);

					repairText += "▶ " + data[j].item.mng_name + "\n-현상 :\n-원인 :\n-조치 :\n\n";
					$M.setValue("repair_text", repairText);
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
			str += '				<input type="hidden" id="row_no_' + i + '" name="row_no_' + i + '" value="' + i + '">';
			str += '				<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goBreakPart();" ><i class="material-iconssearch"></i></button>';
			str += '			</div>';
			str += '			<div class="text-right">';
			str += '				<button type="button" class="btn btn-primary-gra ml5" style="width: 50px;" onclick="javascript:fnRemoveRow(\''+ i +'\')">삭제</button>';
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
			str += '	</div>';
			str += '</div>';

			$("#parent_div").append(str);
		}

		// 내용삭제
		function fnRemoveRow(num) {
			var divId = "#child_div_" + num;
			$("div").remove(divId);
		}
		
		// 공임배분 -> 상세페이지에서만 호출 가능.
		function goRepairCowoker() {
			var param = {
				"parent_js_name" : "fnSetRepairCowoker",
				"work_total_amt" : $M.setComma($M.getValue("work_total_amt")),
				"s_job_report_no" : $M.getValue("job_report_no")
			};

			var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=500, height=450, left=0, top=0";
			$M.goNextPage('/serv/serv0102p03', $M.toGetParam(param), {popupStatus : popupOption});
		}

		// 공임배분 Data Setting
		function fnSetRepairCowoker(data) {
			var co_as_no = [];
			var co_mem_no = [];
			var co_work_rate = [];
			var co_work_amt = [];

			for(var i in data) {
				co_as_no.push(data[i].as_no);
				co_mem_no.push(data[i].mem_no);
				co_work_rate.push(data[i].work_rate);
				co_work_amt.push(data[i].work_amt);
			}

			var option = {
				isEmpty : true
			};

			$M.setValue("co_as_no_str", $M.getArrStr(co_as_no, option));
			$M.setValue("co_mem_no_str", $M.getArrStr(co_mem_no, option));
			$M.setValue("co_work_rate_str", $M.getArrStr(co_work_rate, option));
			$M.setValue("co_work_amt_str", $M.getArrStr(co_work_amt, option));

			var cowoker = data.length > 0 ? data[0].mem_name : '';
			var cowokerCnt = data.length - 1;
			if(data.length > 1) {
				cowoker += " 외" + cowokerCnt + "명";
			}

			$M.setValue("cowoker", cowoker);
		}

		// 정비시간 계산
		function fnCalcRepairHour(index) {
			// 정비시작 - 시(분으로 환산)
			var repairStHour = $M.toNum($M.getValue("repair_st_ti_h")) * 60;
			// 정비시작 - 분
			var repairStMin = $M.toNum($M.getValue("repair_st_ti_m"));
			// 정비시작 분으로 환산
			var repairStart = repairStHour + repairStMin;

			// 정비종료 - 시(분으로 환산)
			var repairEdHour = $M.toNum($M.getValue("repair_ed_ti_h")) * 60;
			// 정비종료 - 분
			var repairEdMin = $M.toNum($M.getValue("repair_ed_ti_m"));
			// 정비종료 분으로 환산
			var repairEnd = repairEdHour + repairEdMin;

			// 최종시간 계산 - 시로 환산
			var finalTime = (repairEnd - repairStart) / 60;
			finalTime = finalTime.toFixed(1);

			// 정비시간 Setting
			if(finalTime > 0) {
				$M.setValue("repair_hour", finalTime);
			} else {
				$M.setValue("repair_hour", 0);
			}
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
			var finalTime = ((repairEnd - repairStart) / 60) - $M.toNum($M.getValue("repair_hour"));
			finalTime = finalTime.toFixed(1);

			// 정비시간 Setting
			if(finalTime > 0) {
				$M.setValue("move_hour", finalTime);
			} else {
				$M.setValue("move_hour", 0);
			}
		}

		// 규정시간 계산
		function fnCalcStandardHour() {
			var standardHour = $M.getValue("standard_hour");

			for(var hour in standardHour) {
				console.log(hour);
			}
		}

		// 결재요청
		function goRequestApproval() {
			goSave('requestAppr');
		}

		// 저장
		function goSave(isRequestAppr) {

			var frm = document.main_form;
			//validationcheck
			if($M.validation(frm,
					{field:["job_case_ti", "repair_st_ti_h", "repair_st_ti_m", "job_type_cd", "break_part_name_1"]})==false) {
				return;
			};

			if(isRequestAppr == "requestAppr") {
				if($M.toNum($M.getValue("op_hour")) < 1) {
					alert("가동시간은 필수 입력입니다.");
					return;
				}
			}
			

			var startTiH = $M.toNum($M.getValue("repair_st_ti_h"));
			var startTiM = $M.toNum($M.getValue("repair_st_ti_m"));
			var endTiH = $M.toNum($M.getValue("repair_ed_ti_h"));
			var endTiM = $M.toNum($M.getValue("repair_ed_ti_m"));

			if(startTiH < 1 || startTiH > 23) {
				alert("정비시작 입력 시 시간은 (01 ~ 23)시로 입력 해야합니다.");
				return;
			}

			if(startTiM > 59) {
				alert("정비시작 입력 시 분은 (01 ~ 59)분으로 입력 해야합니다.");
				return;
			}

			if(endTiH < 1 || endTiH > 23) {
				alert("정비종료 입력 시 시간은 (01 ~ 23)시로 입력 해야합니다.");
				return;
			}

			if(endTiM > 59) {
				alert("정비종료 입력 시 분은 (01 ~ 59)분으로 입력 해야합니다.");
				return;
			}

			if((startTiH > endTiH) || (startTiH == endTiH && startTiM > endTiM)) {
				alert("정비시작시간은 정비종료시간보다 늦을 수 없습니다.");
				return;
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
			var travelStTi = $M.getValue("travel_st_ti_h") + $M.getValue("travel_st_ti_m");
			var travelEdTi = $M.getValue("travel_ed_ti_h") + $M.getValue("travel_ed_ti_m");
			var repairStTi = $M.getValue("repair_st_ti_h") + $M.getValue("repair_st_ti_m");
			var repairEdTi = $M.getValue("repair_ed_ti_h") + $M.getValue("repair_ed_ti_m");

			$M.setValue("travel_st_ti", travelStTi);
			$M.setValue("travel_ed_ti", travelEdTi);
			$M.setValue("repair_st_ti", repairStTi);
			$M.setValue("repair_ed_ti", repairEdTi);

			// 4.정비분류 Setting
			var break_part_seq = [];
			var break_status_cd = [];
			var break_reason_cd = [];
			var remark = [];
			var use_yn = [];
			var break_cmd = [];
			var break_row_no = [];

			$('div[id^="child_div"]').each(function () {
				var parent_div = $(this);
				var child_div = parent_div.children();

				break_part_seq.push(child_div.find('[id^="break_part_seq"]').val());
				break_status_cd.push(child_div.find('[id^="break_status_cd"]').val());
				break_reason_cd.push(child_div.find('[id^="break_reason_cd"]').val());
				remark.push(child_div.find('[id^="remark"]').val());
				break_row_no.push(child_div.find('[id^="row_no"]').val());
				use_yn.push("Y");
				break_cmd.push("C");
			});

			frm = $M.toValueForm(document.main_form);

			var option = {
				isEmpty : true
			};

			$M.setValue(frm, "break_part_seq_str", $M.getArrStr(break_part_seq, option));
			$M.setValue(frm, "break_status_cd_str", $M.getArrStr(break_status_cd, option));
			$M.setValue(frm, "break_reason_cd_str", $M.getArrStr(break_reason_cd, option));
			$M.setValue(frm, "remark_str", $M.getArrStr(remark, option));
			$M.setValue(frm, "break_row_no_str", $M.getArrStr(break_row_no, option));
			$M.setValue(frm, "use_yn_str", $M.getArrStr(use_yn, option));
			$M.setValue(frm, "break_cmd_str", $M.getArrStr(break_cmd, option));

			var msg = "";
			if(isRequestAppr != undefined) {
				// 결재요청 Setting
				$M.setValue("save_mode", "save");
				msg = "결재요청 하시겠습니까?\n※확인 시 현재 창에서는 저장만 진행됩니다.";
			} else {
				$M.setValue("save_mode", "save");
				msg = "저장 하시겠습니까?";
			}

			$M.goNextPageAjaxMsg(msg, this_page + "/save", frm, {method : "POST"},
				function(result) {
					if(result.success) {
						$M.setValue("as_no", result.as_no);
						if(isRequestAppr != undefined) {
							fnClose();

							goApproval();
						} else {
							alert("처리가 완료되었습니다.");
							fnClose();

							goAsdetail();
						}
					}
				}
			);
		}

		function goAsdetail() {
			var params = {
				"s_as_no" : $M.getValue("as_no")
			};

			var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=900, left=0, top=0";
			$M.goNextPage('/serv/serv0102p01', $M.toGetParam(params), {popupStatus : popupOption});
		}

		// 결재
		function goApproval() {
			var params = {
				"s_as_no" : $M.getValue("as_no"),
			};

			var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=840, left=0, top=0";
			$M.goNextPage('/serv/serv0102p02', $M.toGetParam(params), {popupStatus : popupOption});
		}

		// 닫기
		function fnClose() {
			window.close();
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
					width : "20%",
					style : "aui-center",
				},
				{
					headerText : "부품명",
					dataField : "part_name",
					width : "20%",
					style : "aui-left",
				},
				{
					headerText : "구분",
					dataField : "normal_yn_name",
					style : "aui-center",
				},
				{
					headerText : "수량",
					dataField : "use_qty",
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{
					headerText : "단가",
					dataField : "unit_price",
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{
					headerText : "금액",
					dataField : "bill_amount",
					style : "aui-right",
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
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<input type="hidden" id="job_report_no" name="job_report_no" value="${result.job_report_no}"/>
	<input type="hidden" id="__s_machine_seq" name="__s_machine_seq" value="${result.machine_seq}"/>
	<input type="hidden" id="__s_cust_no" name="__s_cust_no" value="${result.cust_no}"/>
	<input type="hidden" id="machine_seq" name="machine_seq" value="${result.machine_seq}"/>
	<input type="hidden" id="cust_no" name="cust_no" value="${result.cust_no}"/>
	<input type="hidden" id="travel_st_ti" name="travel_st_ti">
	<input type="hidden" id="travel_ed_ti" name="travel_ed_ti">
	<input type="hidden" id="repair_st_ti" name="repair_st_ti">
	<input type="hidden" id="repair_ed_ti" name="repair_ed_ti">
	<input type="hidden" id="save_mode" name="save_mode">
	<input type="hidden" id="as_repair_type_ro" name="as_repair_type_ro" value="R">
	<input type="hidden" id="as_type" name="as_type" value="REPAIR">
	<input type="hidden" id="__s_reg_type" name="__s_reg_type" value="I">
	<input type="hidden" id="__s_menu_type" name="__s_menu_type" value="S">
	<input type="hidden" id="as_no" name="as_no">
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
										<div class="form-row inline-pd pr">
											<div class="col-6">
												<input type="text" id="body_no" name="body_no" class="form-control essential-bg" readonly="readonly" required="required" alt="차대번호" value="${result.body_no}">
											</div>
											<div class="col-6">
												<jsp:include page="/WEB-INF/jsp/common/commonMachineJob.jsp">
													<jsp:param name="li_machine_type" value="__machine_detail#__repair_history#__as_todo#__campaign#__work_db"/>
												</jsp:include>
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
									<div class="con-info" id="help_operation" style="max-height: 500px; top: 60%; left: 7%; width: 230px; display: none;">
										<ul class="">
											<ol style="color: #666;">&nbsp;※ CAP적용/미적용은 장비대장에서 처리</ol>
										</ul>
									</div>
									<td>
										<div class="form-row inline-pd">
											<div class="col-5">
												<span id="cap">${result.cap}</span>
											</div>
											<div class="col-7 text-right">
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
						<div class="col-6">
							<!-- 2. 고객정보 -->
							<table class="table-border mt5">
								<colgroup>
									<col width="70px">
									<col width="190">
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
												<input type="text" id="di_balance_amt" name="di_balance_amt" class="form-control text-right" readonly="readonly" format="decimal" value="${result.di_balance_amt}">
											</div>
											 /&nbsp;
											<div class="col width100px">
												<input type="text" id="misu_amt" name="misu_amt" class="form-control text-right" readonly="readonly" format="decimal" value="${result.misu_amt}">
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
							<button type="button" class="btn btn-default" onclick="javascript:goMap();"><i class="material-iconsplace text-default"></i>지도보기</button>
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
									<select class="form-control essential-bg" name="job_type_cd" id="job_type_cd" required="required" alt="정비구분">
										<option value="">- 선택 -</option>
										<c:forEach var="list" items="${codeMap['JOB_TYPE']}">
											<option value="${list.code_value}" ${list.code_value == result.job_type_cd ? 'selected="selected"' : ''} >${list.code_name}</option>
										</c:forEach>
									</select>
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
										<input class="form-check-input" type="radio" id="job_case_ti_i" name="job_case_ti" value="I" <c:if test="${result.job_case_ti eq 'I'}">checked="checked"</c:if> required="required" alt="정비종류" onchange="javascript:fnJobCaseTi();">
										<label class="form-check-label" for="job_case_ti_i">입고</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="job_case_ti_t"  name="job_case_ti" value="T" <c:if test="${result.job_case_ti eq 'T'}">checked="checked"</c:if> required="required" alt="정비종류" onchange="javascript:fnJobCaseTi();">
										<label class="form-check-label" for="job_case_ti_t">출장</label>
									</div>
								</td>
								<th class="text-right">재정비</th>
								<td>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="rework_ync_n" name="rework_ync" value="N" <c:if test="${result.rework_ync eq 'N'}">checked="checked"</c:if> required="required" alt="재정비">
										<label class="form-check-label" for="job_case_ti_i">N</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="rework_ync_y"  name="rework_ync" value="Y" <c:if test="${result.rework_ync eq 'Y'}">checked="checked"</c:if> required="required" alt="재정비">
										<label class="form-check-label" for="job_case_ti_t">Y</label>
									</div>
								</td>
								<th class="text-right">정비과실자</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-12">
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
								<th class="text-right">가동시간</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col width60px">
											<input type="text" id="op_hour" name="op_hour" class="form-control text-right" format="decimal" value="${inputParam.op_hour}">
										</div>
										<div class="col width33px">hr</div>
									</div>
								</td>
								<input type="hidden" class="form-control text-right" id="travel_discount_amt" name="travel_discount_amt" datatype="int" alt="출장할인" format="decimal" readonly="readonly" value="${result.travel_discount_amt}">
							</tr>
							<tr>
<%--								<th class="text-right">정비장소</th>--%>
<%--								<td>--%>
<%--									<c:choose>--%>
<%--										<c:when test="${result.job_case_ti eq 'I'}">--%>
<%--											<input type="text" class="form-control" id="org_name" name="org_name" readonly="readonly" value="${result.org_name}">--%>
<%--										</c:when>--%>
<%--										<c:when test="${result.job_case_ti eq 'T'}">--%>
<%--											<input type="text" class="form-control" id="travel_area_name" name="travel_area_name" readonly="readonly" value="${result.travel_area_name}">--%>
<%--										</c:when>--%>
<%--									</c:choose>--%>
<%--								</td>--%>
								<th class="text-right">정비시간합계</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width70px">
											<input type="text" class="form-control text-right" id="tot_repair_hour" name="tot_repair_hour" datatype="int" readonly="readonly">
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
											<input type="text" class="form-control text-right" id="tot_standard_hour" name="tot_standard_hour" readonly="readonly">
										</div>
										<div class="col width33px">hr</div>
									</div>
								</td>
								<th class="text-right">동행정비</th>
								<td colspan="3">
									<div class="form-row inline-pd">
										<div>
											<input type="text" class="form-control widt180px ml5" id="cowoker" name="cowoker" readonly="readonly" value="${cowoker}">
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
											<button type="button" class="btn btn-primary-gra ml15" onclick="javascript:goRepairCowoker();">공임배분</button>
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
									<input type="text" class="form-control width200px" id="area_name" name="area_name" readonly="readonly" value="${result.svc_area_name}">
								</td>

								<th class="text-right">출장출발</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width40px">
											<input type="text" id="travel_st_ti_h" name="travel_st_ti_h" class="form-control text-right" minlength="2" maxlength="2" onchange="javascript:fnCalcTravelHour();">
										</div>
										<div class="col width16px">시</div>
										<div class="col width35px">
											<input type="text" id="travel_st_ti_m" name="travel_st_ti_m" class="form-control text-right" minlength="2" maxlength="2" onchange="javascript:fnCalcTravelHour();">
										</div>
										<div class="col width16px">분</div>
									</div>
								</td>
								<th class="text-right">출장도착</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width40px">
											<input type="text" id="travel_ed_ti_h" name="travel_ed_ti_h" class="form-control text-right" minlength="2" maxlength="2" onchange="javascript:fnCalcTravelHour();">
										</div>
										<div class="col width16px">시</div>
										<div class="col width35px">
											<input type="text" id="travel_ed_ti_m" name="travel_ed_ti_m" class="form-control text-right" minlength="2" maxlength="2" onchange="javascript:fnCalcTravelHour();">
										</div>
										<div class="col width16px">분</div>
									</div>
								</td>
								<th class="text-right">이동시간</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width60px">
											<input type="text" class="form-control text-right" id="move_hour" name="move_hour">
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
								</div>
							</div>
							<!-- /No1. -->
						</div>
						<!-- /4. 정비분류 -->
						<!-- 5. 부품내역 -->
						<div class="title-wrap mt10">
							<div class="left">
								<h4>5. 부품내역</h4>
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
								<h4>6. 서비스 미결</h4>
							</div>
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_M"/></jsp:include>
							</div>
						</div>
						<div id="auiGridAsTodos" style="margin-top: 5px; height: 70px;"></div>
						<!-- /6. 서비스 미결 -->
					</div>
					<div class="col-8">
						<c:forEach var="dayItem" items="${dayList}" varStatus="dayStatus">
						<input type="hidden" id="day_seq_no${status.count}" name="day_seq_no" value="${dayItem.seq_no}" alt="정비순서">
						<ul class="tabs-c">
							<li class="tabs-item">
								<a href="#" class="tabs-link font-12 <c:if test="${inputParam.s_seq_no eq dayStatus.count}">active</c:if>" data-tab="inner${dayStatus.count}">${dayItem.as_dt}</a>
							</li>
						</ul>
						<div class="tabs-inner <c:if test="${inputParam.s_seq_no eq dayStatus.count}">active</c:if>" id="inner${dayStatus.count}">
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
							</colgroup>
							<tbody>
								<tr>
									<th class="text-right">정비시작</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width40px">
												<input type="text" id="repair_st_ti_h${dayStatus.count}" name="repair_st_ti_h" value="${dayItem.repair_st_ti_h}" class="form-control text-right essential-bg" required="required" alt="정비시작 시간" datatype="int" minlength="2" maxlength="2" onchange="javascript:fnCalcRepairHour(${dayStatus.count});">
											</div>
											<div class="col width16px">시</div>
											<div class="col width35px">
												<input type="text" id="repair_st_ti_m${dayStatus.count}" name="repair_st_ti_m" value="${dayItem.repair_st_ti_m}" class="form-control text-right essential-bg" required="required" alt="정비시작 분" datatype="int" minlength="2" maxlength="2" onchange="javascript:fnCalcRepairHour(${dayStatus.count});">
											</div>
											<div class="col width16px">분</div>
										</div>
									</td>
									<th class="text-right">정비종료</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width40px">
												<input type="text" id="repair_ed_ti_h${dayStatus.count}" name="repair_ed_ti_h" value="${dayItem.repair_ed_ti_h}" class="form-control text-right" datatype="int" minlength="2" maxlength="2" onchange="javascript:fnCalcRepairHour(${dayStatus.count});">
											</div>
											<div class="col width16px">시</div>
											<div class="col width35px">
												<input type="text" id="repair_ed_ti_m${dayStatus.count}" name="repair_ed_ti_m" value="${dayItem.repair_ed_ti_m}" class="form-control text-right" datatype="int" minlength="2" maxlength="2" onchange="javascript:fnCalcRepairHour(${dayStatus.count});">
											</div>
											<div class="col width16px">분</div>
										</div>
									</td>
									<th class="text-right">정비시간</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width70px">
												<input type="text" class="form-control text-right" id="repair_hour${dayStatus.count}" name="repair_hour" value="${dayItem.repair_hour}" readonly="readonly" datatype="int">
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
												<input type="text" class="form-control text-right" id="standard_hour${dayStatus.count}" name="standard_hour" value="${dayItem.standard_hour}" onchange="javascript:fnCalcStandardHour();">
											</div>
											<div class="col width33px">hr</div>
										</div>
									</td>
								</tr>
							</tbody>
						</table>
						<!-- 7. 정비내역 -->
						<div class="title-wrap mt10">
							<div class="left">
								<h4>정비내역</h4>
							</div>
						</div>
						<div class="mt5" style="height: 365px;">
							<textarea class="form-control" style="height: 365px;" id="repair_text${dayStatus.count}" name="repair_text" placeholder="정비내역을 입력 할 수 있습니다.">${dayItem.repair_text}</textarea>
						</div>
						</div>
						<!-- /7. 정비내역 -->
						</c:forEach>
						<table class="table-border mt5">
							<colgroup>
								<col width="100px">
								<col width="">
							</colgroup>
							<tbody>
							<tr>
								<th class="text-right essential-item">정비사진</th>
								<td>
									<div class="table-attfile att_file_div" style="width:100%;">
										<div class="table-attfile" style="float:left">
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
						<!-- /탭 -->
						<div class="mt5">
							<textarea class="form-control" id="ref_text" name="ref_text" style="height: 110px;" placeholder="참고사항 관련 메모가 들어갑니다."></textarea>
						</div>
						<!-- /참고사항 탭 -->
						<!-- /8. 기타 -->
					</div>
					<div class="col-8">
						<!-- 결재자의견 -->
						<div class="title-wrap">
							<div class="left">
								<h4>결재자의견</h4>
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
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
					</div>
				</div>
			</div>
		</div>
		<!-- /팝업 -->
</form>
</body>
</html>