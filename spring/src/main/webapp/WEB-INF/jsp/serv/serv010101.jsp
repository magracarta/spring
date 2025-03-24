<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 정비 > 정비지시서 > 정비지시서 등록 > null
-- 작성자 : 성현우
-- 최초 작성일 : 2020-06-05 19:54:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript" src="/static/js/qrcode.min.js"></script>
	<script type="text/javascript">

		// 상담과 정검/정비
		var auiGridReportOrder;
		// 부품목록
		var auiGridReportPart;
		// 정비작업
		var auiGridReportWork;
		// SA-R 에러메시지
		var sarErrorNo;


		// 상담과 정검/정비 - 구분 dropbox
		var jobOrderTypeJson = JSON.parse('${codeMapJsonObj['JOB_ORDER_TYPE']}');

		// 5. 부품목록 -> 순정 dropbox (part_production_cd)
		var partProductionCdJson = JSON.parse('${codeMapJsonObj['PART_PRODUCTION']}');

		var rowNum = 0;
		// 부품목록 금액 합계
		var planPartTotalAmt = 0;
		// 상담과 점검/정비 금액 합계
		var planWorkTotalAmt = 0;
		var workTotalAmt = 0;

		var item;
		var pro;
		var sessionCehckTime = 1000 * 60 * 5;
    
    var currentJobTypeCd2 = '';
      
		$(document).ready(function() {
			// 4. 상담과 점검/정비 Grid
			createAUIGridReportOrder();
			// 5. 부품내역 Grid
			createAUIGridReportPart();
			// 6. 정비작업 Grid
			createAUIGridReportWork();

			// 정비종류 (입고, 출장)
			fnJobCaseTi();

			fnInit();

			// 자동기입 - 류성진
			<c:if test="${not empty rfqRepair}">
			fnSetInformation({ machine_seq : "${rfqRepair.machine_seq}",cust_no : "${rfqRepair.cust_no}"}, 'Y');
			// AUIGrid.setGridData(auiGridReportPart, );
			// fnSetInputPart

			</c:if>
			$M.setValue(${custBean});
			<c:if test="${not empty selfAssignBean}">
				var selfAssignBean = ${selfAssignBean};
				if(selfAssignBean.assign_mem_no != ""){
					$M.setValue("assign_mem_name", selfAssignBean.assign_mem_name);
					$M.setValue("assign_mem_no", selfAssignBean.assign_mem_no);
					$M.setValue("assign_date", $M.dateFormat(new Date(selfAssignBean.assign_date),"yyyy-MM-dd HH:mm:ss"));
				}
				$M.setValue("eng_mem_name", selfAssignBean.assign_mem_name);
				$M.setValue("eng_mem_no", selfAssignBean.assign_mem_no);
				if(selfAssignBean.machine_seq != ""){
					fnSetInformation({ machine_seq : selfAssignBean.machine_seq,cust_no : selfAssignBean.cust_no}, 'N');
				}
				$M.setValue("c_job_request_seq", selfAssignBean.c_job_request_seq);
			</c:if>
      // 정비구분2 (초기,종료) 클릭 이벤트 (같은 거 클릭 시 해제 시키기 위함)
      // - 기존엔 없던 기능 이여서 우선 주석 처리, 추후 필요 시 해제
      // $("input[name='job_type2_cd']").click(function() {
      //   var jobTypeCd2 = $("input[name='job_type2_cd']:checked").val();
      //   if(currentJobTypeCd2 != jobTypeCd2) {
      //     currentJobTypeCd2 = jobTypeCd2;
      //   } else {
      //     $("input[name='job_type2_cd']").prop("checked", false);
      //   }
      // });
		});

		function fnInit() {
			$("#_fnJobReportPrint").prop("disabled", true);
			$("#_goJobReportDocPrint").prop("disabled", true);
			$("#_goDocPrint").prop("disabled", true);
			$("#_fnTaxBillPrint").prop("disabled", true);
			$("#_goCheckPartPrint").prop("disabled", true);
			$("#_goPopupPart").prop("disabled", true);
			$("#_goOutRequestForm").prop("disabled", true);
			$("#_goNoteSend").prop("disabled", true);
			$("#_goAssign").prop("disabled", true);

			setInterval(function () {
				fnSessionCheck();
			}, sessionCehckTime);

			sarErrorNo = "${inputParam.sar_error_no}";
			if(sarErrorNo != ""){
				var machineData = {
					"machine_seq": "${inputParam.machine_seq}",
					"cust_no": "${inputParam.cust_no}"
				};
				fnSetInformation(machineData, 'N');
			}

			// 정비예약시간 자동설정
			var nowT = $M.getCurrentDate("HH");
			var nowM = $M.toNum($M.getCurrentDate("mm"));
			<c:if test="${empty selfAssignBean}">
			if(nowM <= 30) {
				$M.setValue("reserve_repair_ti", nowT + "30");
				$M.setValue("reserve_repair_ed_ti", nowT + "30");
			} else {
				$M.setValue("reserve_repair_ti", $M.lpad($M.toNum(nowT)+1, 2, "0") + "00");
				$M.setValue("reserve_repair_ed_ti", $M.lpad($M.toNum(nowT)+1, 2, "0") + "00");
			}
			</c:if>
	}

	function fnSessionCheck() {
	$M.goNextPageAjax('/session/check', '', {method: 'GET', loader: false},
					function (result) {
						console.log($M.getCurrentDate("yyyyMMddHHmmss"));
					}
			);
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

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'GET'},
				function (result) {
					if(result.success) {
						dataSetting(result, initYn);
					}
				}
			);
		}

		// 장비, 고객 정보 Setting
		function dataSetting(result, initYn) {
			item = result.custBean;
			pro = result.promotionList;
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
				alert("해당 차대번호(" + result.machineBean.body_no + ")로\n[" + jobReposrtNo + "]정비지시서가\n미완료 상태입니다.\n해당 정비지시서로 이동합니다.");

				var param = {
					"s_job_report_no" : jobReposrtNo,
					"s_self_assign_no" : $M.getValue("self_assign_no")
				};
				var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=800, height=300, left=0, top=0";
				$M.goNextPage('/serv/serv0101p01', $M.toGetParam(param), {popupStatus : popupOption});
				fnClose();
				return;
			}

			if(item.cust_no == "20130603145119670") {
				$("#rental_cust_btn").attr("disabled", false);
			} else {
				$("#rental_cust_btn").attr("disabled", true);
			}
			// 렌탈수리청구고객 초기화
			if(initYn == "N") {
				$M.setValue("rental_cust_no", "");
				$M.setValue("rental_cust_name", "");
			}
			// 예약문자발송 메시지 초기화
			$("#reserve_confirm_msg").html("");

			// SA-R 장비일 시 운행정보 버튼 노출
			if(result.machineBean.sar_yn == "Y") {
				$("#sar_oper_btn").css("display", "inline-block");
			} else {
				$("#sar_oper_btn").css("display", "none");
			}

			// VIP판매가 추가 : 고객이 VIP일경우 VIP판매가로 적용.
			$M.setValue("vip_yn", item.vip_yn);
			if (item.vip_yn == 'Y') {
				// 단가 헤더 속성값 변경하기
				AUIGrid.setColumnProp(auiGridReportPart, 6, {
					headerText : "단가(VIP)",
					width : 75,
                    style : "aui-right aui-editable",
                    dataType : "numeric",
                    formatString : "#,##0",
					headerStyle : "aui-vip-header",
				});
			} else {
				// 단가 헤더 속성값 변경하기
				AUIGrid.setColumnProp(auiGridReportPart, 6, {
					headerText : "단가(일반)",
					width : 75,
                    style : "aui-right aui-editable",
                    dataType : "numeric",
                    formatString : "#,##0",
					headerStyle : "aui-vip-header",
				});
			}

			// 장비관련
			$M.setValue(result.machineBean);
			$M.setValue("__s_machine_seq", result.machineBean.machine_seq);

			$("#cap").html(result.machineBean.cap);
      $M.setValue("job_type_cd", "");
			if(result.machineBean.cap == "적용") {
				$M.setValue("cap_check_yn", "N");
				fnCheckCap();
			} else {
				$("#cap_log").prop("disabled", true);
				$M.setValue("cap_cnt", "0");
				$M.setValue("next_cap_cnt", "1");
			}

			$("#qr_image > img").remove();
			// qr코드 그리기
			if (result.machineBean.qr_no != "") {
				new QRCode(document.getElementById("qr_image"), {
					text: result.machineBean.qr_no,
					width: 30,
					height: 30,
				});
				$("#qr_image > img").css({"margin":"auto"});
			} else {
				$("#qr_image").html("QR미등록");
			}

			// 고객정보
			$M.setValue(result.custBean);
			$M.setValue("__s_cust_no", result.custBean.cust_no);

			// 프로모션
			// $("#pro_period").html(result.custBean.pro_period);
			// $("#pro_content").html(result.custBean.pro_content);
			fnSetPromotion();
			fnSetFileInfo();

			setTimeout(function () {
				checkPopUp(result);
			}, 1000);
		}

		function fnSetPromotion() {
			for(var i=0; i<pro.length; i++) {
				var innerHtml = "";

				innerHtml += '<tr>';
				innerHtml += '	<th class="text-right">프로모션기간</th>';
				innerHtml += '	<td>';
				innerHtml += '		<span id="pro_period_' + i + '"></span>';
				innerHtml += '	</td>';
				innerHtml += '	<th class="text-right">프로모션첨부</th>';
				innerHtml += '	<td id="file_search_td' + i + '">';
				innerHtml += '	</td>';
				innerHtml += '	<td id="file_name_td' + i + '" class="dpn" colspan="3">';
				innerHtml += '		<div class="table-attfile" id="file_name_div' + i + '">';
				innerHtml += '		</div>';
				innerHtml += '	</td>';
				innerHtml += '</tr>';
				innerHtml += '<tr>';
				innerHtml += '	<th class="text-right">프로모션내용</th>';
				innerHtml += '	<td colspan="5">';
				innerHtml += '		<span id="pro_content_' + i + '"></span>';
				innerHtml += '	</td>';
				innerHtml += '</tr>';

				$('#cust_info > tbody:last').append(innerHtml);

				$("#pro_period_" + i).html(pro[i].term);
				$("#pro_content_" + i).html(pro[i].content);
			}
		}

		function fnCheckCap() {
			var params = {
				"parent_js_name" : "fnSetCapInfo"
			};

			var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=500, left=0, top=0";
			$M.goNextPage('/serv/serv0101p13', $M.toGetParam(params), {popupStatus : popupOption});
		}

		function fnSetCapInfo(data) {
			$M.setValue("cap_use_yn", data.cap_use_yn);
			$M.setValue("cap_check_yn", "Y");

			if($M.getValue("cap_use_yn") == "N") {
				$("#cap").html("미적용 [CAP적용]");
				$M.setValue("cap_cnt", "0");
				$M.setValue("next_cap_cnt", "1");
				$M.setValue("job_type_cd", data.job_type_cd);
				$M.setValue("job_type2_cd", data.job_type2_cd);
			} else {
				$("#cap_plan_dt").prop("disabled", false);
				// TODO : cap 적용 시 정비구분 CAP으로 설정되도록 추가
				$M.setValue("job_type_cd", "5")
			}
		}

		// 첨부파일관련 함수
		function fnSetFileInfo() {
			// if("" != item.pro_file_seq || "" != item.pro_file_name) {
			for(var i=0; i<pro.length; i++) {
				if ("" != pro[i].file_seq || "" != pro[i].file_seq) {
					var file_info = {
						"file_seq": pro[i].file_seq,
						"file_name": pro[i].file_name,
						"fileIdx": i
					};

					setProFileInfo(file_info);
					showFileNameTd();
				}
			}
		}

		// 첨부파일관련 함수
		function setProFileInfo(result) {
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

		// 장비, 고객 검색 시 확인사항 팝업
		function checkPopUp(result) {
			// 24.03.08 부모창에서 confirm를 사용할 수 없어 먼저 체크하도록 순서 변경
			// 거래시필수확인사항 존재여부
			if (result.custMemo.cust_memo_use_yn == "Y") {
				setTimeout(function () {
					if (confirm("거래시 필수사항을 확인하십시오.") == true) {
						fnCheckRequired();
					}
				}, 200);
			} else if (result.jobOffer.job_offer_yn == "Y"){
				// 정비추천 존재여부
				setTimeout(function () {
					if (confirm("정비추천을 확인하십시오.") == true) {
						fnCheckRequired();
					}
				}, 200);
			}
			
			// 미결사항 존재여부
			if (result.asTodo.as_todo_use_yn == "Y") {
				setTimeout(function () {
					goAsTodo();
				// }, 200);
				}, 600);
			}

			// 리콜 존재여부
			if (result.campaign.campaign_use_yn == "Y") {
				setTimeout(function () {
					goCampaign();
				// }, 600);
				}, 900);
			}

			// 개인정보동의 존재여부
			if (result.privacy.privacy_use_yn == "Y") {
				setTimeout(function () {
					goSearchPrivacyAgree();
				// }, 900);
				}, 1200);
			}

			// 거래시필수확인사항 존재여부
			// if (result.custMemo.cust_memo_use_yn == "Y") {
			// 	setTimeout(function () {
			// 		if (confirm("거래시 필수사항을 확인하십시오.") == true) {
			// 			fnCheckRequired();
			// 		}
			// 	}, 1200);
			// } else if (result.jobOffer.job_offer_yn == "Y"){
			// 	// 정비추천 존재여부
			// 	setTimeout(function () {
			// 		if (confirm("정비추천을 확인하십시오.") == true) {
			// 			fnCheckRequired();
			// 		}
			// 	}, 1200);
			// }
		}

		// 개인정보동의 팝업
		function goSearchPrivacyAgree() {
			var param = {
				"cust_no" : $M.getValue("cust_no")
			};

			$M.goNextPageAjax("/comp/comp0306/search", $M.toGetParam(param), {method : 'get'},
					function(result){
						if(result.success) {
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

		// 거래시필수확인사항
		function fnCheckRequired() {
			var param = {
				"cust_no" : $M.getValue("cust_no"),
				"machine_seq" : $M.getValue("machine_seq"),
			};

			openCheckRequiredPanel('setCheckRequired', $M.toGetParam(param));
		}

		function setCheckRequired() {
		}

		// 문자발송
		function fnSendSms(type) {
			var name;
			var hpNo;

			if(type == "cust") {
				name = $M.getValue("cust_name");
				hpNo = $M.getValue("hp_no");
			} else if(type == "sale") {
				name = $M.getValue("sale_mem_name");
				hpNo = $M.getValue("sale_mem_hp_no");
			} else if(type == "serv") {
				name = $M.getValue("service_mem_name");
				hpNo = $M.getValue("service_mem_hp_no");
			} else if(type == "mng") {
				name = "";
				hpNo = $M.getValue("mng_hp_no");
			} else if(type == "mng") {
				name = "";
				hpNo = $M.getValue("driver_hp_no");
			}

			var param = {
				"name" : name,
				"hp_no" : hpNo
			};
			openSendSmsPanel($M.toGetParam(param));
		}

		// 정비작업-행추가
		function fnAdd() {
			// 배정 후 추가가 가능하도록 변경되어 알람 후 막기
			alert("배정처리 후 추가가 가능합니다.");
			return;

			var bodyNo = $M.getValue("body_no");
			if(bodyNo == '') {
				alert("차대번호 조회를 먼저 진행해주세요.");
				return;
			}

			workDt = $M.getCurrentDate();

			// 작업일자 중복 체크
			const idx = AUIGrid.getGridData(auiGridReportWork).findIndex(data => data.work_dt === $M.getCurrentDate())
			if(idx !== -1) {
				alert("정비작업은 하루에 한 번만 가능합니다.");
				return;
			}

			if(fnCheckGridEmpty()) {
				var item = new Object();
				item.work_dt = workDt;
				item.start_ti = "";
				item.v_start_ti = "";
				item.end_ti = "";
				item.v_end_ti = "";
				item.edit = "Y";
				AUIGrid.addRow(auiGridReportWork, item, 'last');
			};
		}

		// 그리드 빈값 체크
		function fnCheckGridEmpty() {
			return AUIGrid.validateGridData(auiGridReportWork, ["work_dt", "v_start_ti", "v_end_ti"], "필수 항목은 반드시 값을 입력해야합니다.");
		}

		// 출장정보 - 출장비(최종)
		function fnTravelYnf() {
			var travelYnfNChk = $("input:radio[id='travel_ynf_n']").is(":checked");

			if(travelYnfNChk) {
				$("#travel_expense").prop("readonly", false);
				$("#travel_discount_amt").prop("readonly", false);
			} else {
				$("#travel_expense").prop("readonly", false);
				$("#travel_discount_amt").prop("readonly", true);
			}
		}

		// 정비접수 - 정비종류
		function fnJobCaseTi() {
			var jobCaseTChk = $M.getValue("job_case_ti");

			if(jobCaseTChk == 'T') {
				$("#svc_travel_expense").prop("disabled", false);
				$("#distance_min").prop("readonly", false);
				$("#distance_max").prop("readonly", false);
				$("#travel_expense_min").prop("readonly", false);
				$("#travel_expense_max").prop("readonly", false);
				$("#travel_area_name").prop("readonly", false);
				$("#travel_km").prop("readonly", false);
				$("#travel_ynf_y").prop("disabled", false);
				$("#travel_ynf_n").prop("disabled", false);
				$("#travel_ynf_f").prop("disabled", false);

				$("#travel_hour").prop("readonly", false);
				$M.setValue("travel_hour_price", $M.getValue("svc_travel_expense_hour"));

				fnTravelYnf();
			} else {
				$("#svc_travel_expense").prop("disabled", true);
				$M.setValue("svc_travel_expense", "");
				$("#distance_min").prop("readonly", true);
				$M.setValue("distance_min", "");
				$("#distance_max").prop("readonly", true);
				$M.setValue("distance_max", "");
				$("#travel_expense_min").prop("readonly", true);
				$M.setValue("travel_expense_min", "");
				$("#travel_expense_max").prop("readonly", true);
				$M.setValue("travel_expense_max", "");
				$("#travel_area_name").prop("readonly", true);
				$M.setValue("travel_area_name", "");
				$("#travel_km").prop("readonly", true);
				$M.setValue("travel_km", "");
				$("#travel_expense").prop("readonly", true);
				$("#travel_discount_amt").prop("readonly", true);
				$("#travel_final_expense").prop("readonly", true);
				$("#travel_ynf_y").prop("disabled", true);
				$("#travel_ynf_n").prop("disabled", true);
				$("#travel_ynf_f").prop("disabled", true);

				$("#travel_hour").prop("readonly", true);
				$M.setValue("travel_hour", "");
				$M.setValue("travel_hour_price", "");
				$M.setValue("tot_travel_hour_price", "");
			}
		}

		// 네이버 지도 호출
		function goMap() {
			var params = [{}];
			var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=800, left=0, top=0";
			$M.goNextPage('https://map.naver.com', $M.toGetParam(params), {popupStatus : popupOption});
		}

		// 접수구분 - 사전 (사전예약문자발송여부 팝업)
		// function goReservationText() {
		//
		// 	$M.setValue("in_dt", "");
		// 	$("#in_dt").prop("disabled", false);
		//
		// 	var params = [{}];
		// 	var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=800, height=300, left=0, top=0";
		// 	$M.goNextPage('/serv/serv0101p05', $M.toGetParam(params), {popupStatus : popupOption});
		// }

		// 접수구분 -> 입고일자 Setting
		function goTypeRt() {
			if($M.getValue("receipt_type_rt") == "R") {
				$M.setValue("in_dt", "");
				$("#in_dt").prop("disabled", false);
			} else if($M.getValue("receipt_type_rt") == "T") {
				$M.setValue("in_dt", $M.getCurrentDate());
				$("#in_dt").prop("disabled", true);
			} else if($M.getValue("receipt_type_rt") == "A") {
				$("#in_dt").prop("disabled", false);
			}
		}

		function fnSetSvcInfo() {
			var svcTravel = $M.getValue("svc_travel_expense");
			var svcTravelArr = svcTravel.split("#");

			$M.setValue("svc_travel_expense_seq", svcTravelArr[0]);
			$M.setValue("distance_min", svcTravelArr[1]);
			$M.setValue("distance_max", svcTravelArr[2]);
			$M.setValue("travel_expense_min", svcTravelArr[3]);
			$M.setValue("travel_expense_max", svcTravelArr[4]);

			fnChangePrice();
		}

		// 출장비용 계산
		function fnChangeTravelPrice() {
			// 출장비용 - 비용
			var travelExpense = $M.toNum($M.getValue("travel_expense"));
			// 출장비용 - 할인
			var travelDiscountAmt = $M.toNum($M.getValue("travel_discount_amt"));
			// 출장비용 - 최종
			var travelFinalExpense = travelExpense - travelDiscountAmt;
			// $M.setValue("travel_final_expense", $M.setComma(travelFinalExpense));
			$M.setValue("travel_final_expense", travelFinalExpense);

			fnChangePrice();
		}

		function fnCalcPlanTravelPrice() {
			var travelHour = $M.toNum($M.getValue("travel_hour"));
			var travelHourPrice = $M.toNum($M.getValue("travel_hour_price"));
			// tot_travel_hour_price
			var totTravelHourPrice = travelHour * travelHourPrice;

			totTravelHourPrice = Math.floor(totTravelHourPrice);
			$M.setValue("tot_travel_hour_price", totTravelHourPrice);

			fnChangePrice();
		}

		// 비용 계산
		function fnChangePrice() {
			// 출장비(예상)
			var planTravelExpense = $M.toNum($M.getValue("tot_travel_hour_price"));
			// 부품(예상)
			planPartTotalAmt = $M.toNum($M.getValue("plan_part_total_amt"));
			// 공임(예상)
			planWorkTotalAmt = $M.toNum($M.getValue("plan_work_total_amt"));

			// 합계(예상)
			var planTotalAmt = planTravelExpense + planPartTotalAmt + planWorkTotalAmt;
			// VAT포함 총금액(예상)
			var planTotalVatAmt = Math.floor(planTotalAmt * 1.1); // 총금액(VAT포함) ㅣ 합계 + VAT

			$M.setValue("plan_travel_expense", $M.setComma(planTravelExpense));
			$M.setValue("plan_part_total_amt", $M.setComma(planPartTotalAmt));
			$M.setValue("plan_work_total_amt", $M.setComma(planWorkTotalAmt));

			$M.setValue("plan_total_amt", $M.setComma(planTotalAmt));
			$M.setValue("plan_total_vat_amt", $M.setComma(planTotalVatAmt));

			// 출장비(최종)
			var finalTravelExpense = $M.toNum($M.getValue("travel_final_expense"));
			// 부품(최종)
			var partTotalAmt = $M.toNum($M.getValue("pwrt_total_amt"));
			// 공임(최종)
			workTotalAmt = $M.toNum($M.getValue("work_total_amt"));

			// 합계(최종)
			var finalTotalAmt = finalTravelExpense + partTotalAmt + workTotalAmt;
			// VAT포함 총금액(최종)
			var finalTotalVatAmt = Math.floor(finalTotalAmt * 1.1); // 총금액(VAT포함) ㅣ 합계 + VAT

			$M.setValue("final_travel_expense", $M.setComma(finalTravelExpense));
			$M.setValue("part_total_amt", $M.setComma(partTotalAmt));
			$M.setValue("work_total_amt", $M.setComma(workTotalAmt));

			$M.setValue("total_amt", $M.setComma(finalTotalAmt));
			$M.setValue("final_total_vat_amt", $M.setComma(finalTotalVatAmt));

			// 23/06/29 추후 다시 자동계산 넣을 예정
			// if($M.getValue("plan_total_amt") == 0 && $M.getValue("total_amt") == 0) {
			// 	$M.setValue("cost_yn", "N");
			// } else {
			// 	$M.setValue("cost_yn", "Y");
			// }
		}

		// 작업지시 그리드
			function createAUIGridReportOrder() {
			var gridPros = {
				// 행 구별 필드명 지정
				rowIdField : "_$uid",
				editable : true,
				showStateColumn : true,
				// treeColumnIndex : 0,
				// displayTreeOpen : true,
				// 체크박스 출력 여부
				showRowCheckColumn : false,
				// 전체선택 체크박스 표시 여부
				showRowAllCheckBox : false,
			};

			var columnLayout = [
				{
					headerText : "점검 및 정비 지시",
					dataField : "order_text",
					width : "60%",
					style : "aui-left",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if(item.bookmark_type_jr == 'R' && (item.sort_no != 0 || item.up_job_report_order_seq != 0)) {
							return "";
						}
						return "aui-editable"
					},
				},
				{
					headerText : "예상비용",
					dataField : "plan_work_amt",
					width : "10%",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right aui-editable",
          editRenderer: {
            type: "InputEditRenderer",
            onlyNumeric: true,
          },
				},
				{
					headerText : "발생비용",
					dataField : "work_amt",
					width : "10%",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right aui-editable",
          editRenderer: {
            type: "InputEditRenderer",
            onlyNumeric: true,
          },
				},
				{
					headerText : "시간",
					dataField : "work_hour",
					width : "10%",
					dataType : "numeric",
					style : "aui-right aui-editable",
          editRenderer: {
            type: "InputEditRenderer",
            onlyNumeric : true,
            allowPoint : true,  // 소수점( . ) 도 허용할지 여부
          },
					labelFunction : (rowIndex, columnIndex, value, headerText, item) => {
            if(item.bookmark_type_jr == 'R' && item.sort_no != "0") {
              return "";
            }

            if(value == "0") {
              return "0";
            }

            return value;
          },
				},
				{
					headerText : "지시번호",
					dataField : "job_report_order_seq",
					visible : false
				},
				{
					headerText : "상위지시번호",
					dataField : "up_job_report_order_seq",
					visible : false
				},
				{
					headerText : "순서",
					dataField : "row_num",
					visible : false
				},
				{
					headerText : "AS미결번호",
					dataField : "as_todo_seq",
					visible : false
				},
				{
					headerText : "예정일자",
					dataField : "as_plan_dt",
					visible : false
				},
				{
					headerText : "할당직원",
					dataField : "as_assign_mem_no",
					visible : false
				},
				{
					headerText : "작업여부",
					dataField : "work_yn",
					visible : false
				},
				{
					headerText : "작업분류",
					dataField : "job_order_type_cd",
					visible : false
				},
				{
					headerText : "작업분류",
					dataField : "break_part_seq",
					visible : false
				},
				{
					headerText : "작업구분",
					dataField : "bookmark_type_jr",
					visible : false
				},
				{
					headerText : "정렬순서",
					dataField : "sort_no",
					visible : false
				},
				{
					headerText : "삭제",
					width : "10%",
					dataField : "removeBtn",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							var isRemoved = AUIGrid.isRemovedById(auiGridReportOrder, event.item._$uid);

							// if(event.item.children != undefined){
							// 	var children = event.item.children;
							// 	for(var i=0;i<children.length;i++){
							// 		var planWorkAmt = $M.toNum(children[i].plan_work_amt);
							// 		planWorkTotalAmt -= planWorkAmt;
							//
							// 		var workAmt = $M.toNum(children[i].work_amt);
							// 		workTotalAmt -= workAmt;
							// 	}
							// }else{
								// 공임 예상금액 Setting
								var planWorkAmt = $M.toNum(event.item.plan_work_amt);
								planWorkTotalAmt -= planWorkAmt;

								// 공임 최종금액 Setting
								var workAmt = $M.toNum(event.item.work_amt);
								workTotalAmt -= workAmt;
							// }

							$M.setValue("plan_work_total_amt", planWorkTotalAmt);
							$M.setValue("work_total_amt", workTotalAmt);


							if (isRemoved == false) {
								AUIGrid.removeRow(event.pid, event.rowIndex);
								AUIGrid.update(auiGridReportOrder);
							} else {
								AUIGrid.restoreSoftRows(auiGridReportOrder, "selectedIndex");
								AUIGrid.update(auiGridReportOrder);
							}
							fnCalcOrderWorkHour();
							fnChangePrice();
						}
					},
					labelFunction : function(rowIndex, columnIndex, value,
											 headerText, item) {
						return '삭제'
					},
					style : "aui-center",
					editable : false
				}
			];

			// 실제로 #grid_wrap에 그리드 생성
			auiGridReportOrder = AUIGrid.create("#auiGridReportOrder", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGridReportOrder, ${rfqRepairOrder});

			// 수량 변경 시 가격 변경
			AUIGrid.bind(auiGridReportOrder, "cellEditEnd", auiCellEditHandler);
			AUIGrid.bind(auiGridReportOrder, "cellEditBegin", auiCellEditHandler);

			// keyDown 이벤트 바인딩
			AUIGrid.bind(auiGridReportOrder, "keyDown",	function(event) {
				// 상담과 점검/정비 행추가 단축키
				if(event.shiftKey && event.keyCode == 32) {
					fnAddPaidKeyDown();
				}

				if(event.keyCode == 45 || event.keyCode == 32) {
					return false;
				}

				return true;
			});

			AUIGrid.bind(auiGridReportOrder,"rowStateCellClick",function(event){
				// 공임 예상금액 Setting
				var planWorkAmt = $M.toNum(event.item.plan_work_amt);
				planWorkTotalAmt -= planWorkAmt;

				// 공임 최종금액 Setting
				var workAmt = $M.toNum(event.item.work_amt);
				workTotalAmt -= workAmt;
				// }

				$M.setValue("plan_work_total_amt", planWorkTotalAmt);
				$M.setValue("work_total_amt", workTotalAmt);

				fnCalcOrderWorkHour();
				fnChangePrice();
				// }
			});


			setTimeout(function() {
				fnCalcOrderPlanWorkAmt();
				fnCalcOrderWorkAmt();
				fnCalcOrderWorkHour();
				fnChangePrice();
			}, 100);
			// AUIGrid.bind(auiGridReportOrder, "addRowFinish", function(event) {
			// 	var rowCount = AUIGrid.getRowCount(event.pid);
			// 	AUIGrid.setSelectionByIndex(auiGridReportOrder, rowCount, 1);
			// });
		}

		// 부품목록 그리드
		function createAUIGridReportPart() {
			var gridPros = {
				// 행 구별 필드명 지정
				rowIdField : "_$uid",
				editable : true,
				showStateColumn : true,
				// displayTreeOpen : true,
				// 체크박스 출력 여부
				showRowCheckColumn : true,
				// 전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
				// // fixedColumnCount : 2,
			};

			// 순정여부
			var fixList = [
				{fix_yn: "Y", fix_name: "순정"},
				{fix_yn: "N", fix_name: "비품"}
			];

			// 고품여부
			var oldPartYn = [
				{old_part_yn: "Y", old_part_name: "Y"},
				{old_part_yn: "N", old_part_name: "N"}
			];

			var columnLayout = [
				{
					headerText : "부품번호",
					dataField : "part_no",
					width : "15%",
					editRenderer : {
						type : "ConditionRenderer",
						conditionFunction : function(rowIndex, columnIndex, value, item, dataField) {

							var param = {
								s_search_kind : 'DEFAULT_PART',
								's_warehouse_cd' : $M.getValue("org_code"),
								's_only_warehouse_yn' : "N",	// 센터일 때만 Y로 넘김 -> 전체 다 나오게 변경
								's_not_sale_yn' : "Y",		// 매출정지 제외
								's_not_in_yn' : "Y",			// 미수입 제외
								's_part_mng_cd' : ""
							};
							return fnGetPartSearchRenderer(dataField, param, "#auiGridReportPart");
						},
					},
				},
				{
					headerText : "부품명",
					width : "20%",
					dataField : "part_name",
					style : "aui-left",
					editable : true
				},
				{
					headerText : "삭제",
					dataField : "removeBtn",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							var isRemoved = AUIGrid.isRemovedById(auiGridReportPart, event.item._$uid);
							var amount = $M.toNum(event.item.amount);
							planPartTotalAmt = planPartTotalAmt - amount;
							$M.setValue("plan_part_total_amt", planPartTotalAmt);
							if (isRemoved == false) {
								AUIGrid.removeRow(event.pid, event.rowIndex);
								AUIGrid.update(auiGridReportPart);
							} else {
								AUIGrid.restoreSoftRows(auiGridReportPart, "selectedIndex");
								AUIGrid.update(auiGridReportPart);
							};
							fnChangePrice();
						},
					},
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						return '삭제'
					},
					style : "aui-center",
					editable : false,
				},
				// {
				// 	headerText : "순정",
				// 	dataField : "normal_yn",
				// 	width : "10%",
				// 	editable : true,
				// 	style: "aui-editable",
				// 	editRenderer : {
				// 		type : "DropDownListRenderer",
				// 		list : fixList,
				// 		keyField : "fix_yn",
				// 		valueField  : "fix_name"
				// 	},
				// 	labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) {
				// 		var retStr = value;
				// 		for(var j = 0; j < fixList.length; j++) {
				// 			console.log(fixList[j]["fix_yn"] )
				// 			if(fixList[j]["fix_yn"] == value) {
				// 				retStr = fixList[j]["fix_name"];
				// 				break;
				// 			} else if(value === null) {
				// 				retStr = "- 선택 -";
				// 				break;
				// 			}
				// 		}
				// 		return retStr;
				// 	}
				// },
				{
					headerText : "수량",
					dataField : "qty",
					style : "aui-center aui-editable"
				},
				{
					headerText: "가용재고(센터)",
					dataField: "part_able_stock",
					style: "aui-center aui-link",
					dataType: "numeric",
					formatString: "#,##0",
					width : "100",
					editable: false,
				},
				{
					headerText : "단가",
					dataField : "unit_price",
					style : "aui-right aui-editable",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{
					headerText : "금액",
					dataField : "amount",
					style : "aui-right aui-editable",
					dataType : "numeric",
					formatString : "#,##0",
				},
				{
					headerText : "출고",
					dataField : "out_qty",
					style : "aui-center",
					editable : false
				},
				{
					headerText : "사용",
					dataField : "use_qty",
					style : "aui-center aui-editable"
				},
				{
					headerText : "반품",
					dataField : "return_qty",
					style : "aui-center",
					editable : false
				},
				{
					headerText: "고품",
					dataField: "old_part_yn",
					width: "10%",
					editable: true,
					style: "aui-editable",
					editRenderer: {
						type: "DropDownListRenderer",
						list: oldPartYn,
						keyField: "old_part_yn",
						valueField: "old_part_name"
					},
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						var retStr = value;
						for (var j = 0; j < oldPartYn.length; j++) {
							if (oldPartYn[j]["old_part_yn"] == value) {
								retStr = oldPartYn[j]["old_part_name"];
								break;
							} else if (value === null) {
								retStr = "- 선택 -";
								break;
							}
						}
						return retStr;
					}
				},
				{
					headerText: "고품고장부위",
					dataField: "old_part_trouble",
					style: "aui-left aui-editable",
					editable: true,
					width: "20%"
				},
				{
					headerText : "청구금액",
					dataField : "bill_amount",
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0",
					editable : false
				},
				{
					headerText : "이동요청",
					dataField : "transBtn",
					width : "70",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							var param = {
								"part_no" : event.item.part_no

							};
							openTransPartPanel('setMovePartInfo', $M.toGetParam(param));
						},
					},
					labelFunction : function(rowIndex, columnIndex, value,
							headerText, item) {
						return '이동요청'
					},
					style : "aui-center",
					editable : false,
				},
				{
					dataField : "part_name_change_yn",
					visible : false
				}
			];

			// 실제로 #grid_wrap에 그리드 생성
			auiGridReportPart = AUIGrid.create("#auiGridReportPart", columnLayout, gridPros);
			// 그리드 갱신
			// AUIGrid.setGridData(auiGridReportPart, ${rfqRepairParts});

			// 추가행 에디팅 진입 허용
			AUIGrid.bind(auiGridReportPart, "cellEditBegin", function (event) {
				if (event.dataField == "part_no") {
					if (AUIGrid.isAddedById(event.pid, event.item._$uid)) {
						return true;
					} else {
						return false;
					}
				}
				if (event.dataField == "part_name") {
					var changeYn = event.item.part_name_change_yn;
					if (changeYn == "Y") {
						return true;
					} else {
						return false;
					}
				}
			});

			// keyDown 이벤트 바인딩
			AUIGrid.bind(auiGridReportPart, "keyDown",	function(event) {

				// 부품목록 행추가
				if(event.shiftKey && event.keyCode == 32) {
					fnAddCostItem();
				}

				// 부품목록 삭제
				if(event.ctrlKey && event.keyCode == 32) {
					fnRemovePart();
				}

				if(event.keyCode == 45 || event.keyCode == 32) {
					return false;
				}

				return true;
			});

			AUIGrid.bind(auiGridReportPart, "addRowFinish", function(event) {
				var rowCount = AUIGrid.getRowCount(event.pid);
				AUIGrid.setSelectionByIndex(auiGridReportPart, rowCount, 0);
			});

			AUIGrid.bind(auiGridReportPart, "cellEditBegin", function (event) {
				if (event.item.old_part_yn == "N") {
					if (event.dataField == "old_part_trouble") {
						return false;
					}
				}
			});

			// 수량 변경 시 가격 변경
			AUIGrid.bind(auiGridReportPart, "cellEditEnd", auiCellEditHandler);

			AUIGrid.bind(auiGridReportPart, "rowStateCellClick",function(event){
				if(event.marker == "added-edited" || event.marker == "added"){
					var tempAmount = event.item.amount * event.item.qty;
					planPartTotalAmt = planPartTotalAmt - tempAmount;
					$M.setValue("plan_part_total_amt", planPartTotalAmt);
					fnChangePrice();
				}
			});

			AUIGrid.bind(auiGridReportPart, "cellClick", function (event) {
				if(event.dataField == "part_able_stock") {
					var param = {
						"part_no" : event.item.part_no,
					};

					$M.goNextPage("/part/part0101p01", $M.toGetParam(param), {popupStatus : ""});
				}
			});

			var parts = null;
			<c:if test="${not empty rfqRepairParts}">
				parts = ${rfqRepairParts};
			</c:if>
			if ( !parts ) return;

			var part = {
				part_no : '',
				part_name : '',
				unit_price : 0,
				normal_yn : "Y",
				qty : 0,
				sale_price : 0,
				amount : 0,
				out_qty : 0,
				return_qty : 0,
				bill_amount : 0,
				old_part_yn : "N",
				seq_no : 0,
				use_yn : 'Y',
				part_name_change_yn : "N",
			};

			for (var i in parts) {
				parts[i].normal_yn = parts[i].part_production_cd =='0' ? 'Y' : 'N';
				parts[i].amount = parts[i].qty * parts[i].unit_price;
				console.log($.extend(part, parts[i]))
				AUIGrid.addRow(auiGridReportPart, $.extend(part, parts[i]), 'last');
				fnCalcPartPrice();

			}

		}

		// 삭제
		function fnRemovePart() {
			var data = AUIGrid.getSelectedItems(auiGridReportPart);

			var isRemoved = AUIGrid.isRemovedById(auiGridReportPart, data[0].rowIdValue);
			var amount = $M.toNum(data[0].item.amount);
			planPartTotalAmt = planPartTotalAmt - amount;
			$M.setValue("plan_part_total_amt", planPartTotalAmt);
			if (isRemoved == false) {
				AUIGrid.removeRow(auiGridReportPart, data[0].rowIndex);
				AUIGrid.update(auiGridReportPart);
			} else {
				AUIGrid.restoreSoftRows(auiGridReportPart, "selectedIndex");
				AUIGrid.update(auiGridReportPart);
			};

			// 5. 부품목록 -> 금액 합계 계산
			fnChangePrice();
		}

		function auiCellEditHandler(event) {
			switch (event.type) {
				case "cellEditBegin" :
					var checkArr = ["plan_work_amt", "work_amt", "work_hour"];
					if(checkArr.indexOf(event.dataField) > -1 && event.item.bookmark_type_jr == 'R' && event.item.sort_no != "0") {
						return false;
					}
					break;
				case "cellEditEnd" :
					if (event.dataField == "qty" || event.dataField == "unit_price") {
						// var qty = $M.toNum(event.item.qty);
						// var unitPrice = $M.toNum(event.item.unit_price);
						// var beforeAmount = $M.toNum(event.item.amount);
						// var amount = qty * unitPrice;
						// planPartTotalAmt = planPartTotalAmt + (amount - beforeAmount);
						// AUIGrid.updateRow(auiGridReportPart, {"amount" : amount}, event.rowIndex);
						// $M.setValue("plan_part_total_amt", planPartTotalAmt);
						var qty = $M.toNum(event.item.qty);
						var unitPrice = $M.toNum(event.item.unit_price);
						var amount = qty * unitPrice;
						AUIGrid.updateRow(auiGridReportPart, {"amount": amount}, event.rowIndex);

						// 5. 부품목록 -> 금액 합계 계산
						fnCalcPartPrice();
					} else if (event.dataField == "plan_work_amt") {
						var gridData = AUIGrid.getGridData(auiGridReportOrder);
						var planWorkAmt = 0;
						for (var i in gridData) {
							planWorkAmt += $M.toNum(gridData[i].plan_work_amt);
						}
						$M.setValue("plan_work_total_amt", planWorkAmt);
					} else if (event.dataField == "work_amt") {
						var gridData = AUIGrid.getGridData(auiGridReportOrder);
						var workAmt = 0;
						for (var i in gridData) {
							workAmt += $M.toNum(gridData[i].work_amt);
						}
						$M.setValue("work_total_amt", workAmt);
					} else if (event.dataField == "work_hour") {
						fnCalcOrderWorkHour();
					} else if (event.dataField == "use_qty") {
						// var item = AUIGrid.getItemByRowIndex(auiGridReportPart, event.rowIndex);
						// var outQty = $M.toNum(item.out_qty); // 출고수량
						// var returnQty = $M.toNum(item.return_qty); // 반품수량
						// var useQty = $M.toNum(item.use_qty); // 사용수량
						//
						// var scanQty = (outQty - returnQty);
						//
						// if(scanQty < useQty) {
						// 	alert("사용수량은 출고수량에서 반품수량을 뺀 값보다 클 수 없습니다.");
						// 	var changeData = {
						// 		"use_qty" : 0
						// 	};
						//
						// 	AUIGrid.updateRow(auiGridReportPart, changeData, event.rowIndex, false);
						// }
						var item = AUIGrid.getItemByRowIndex(auiGridReportPart, event.rowIndex);
						var outQty = $M.toNum(item.out_qty); // 출고수량
						var returnQty = $M.toNum(item.return_qty); // 반품수량
						var useQty = $M.toNum(item.use_qty); // 사용수량
						var amount = $M.toNum(item.amount); // 금액
						var billAmount = 0;

						var scanQty = (outQty - returnQty);

						if (scanQty < useQty) {
							alert("사용수량은 출고수량에서 반품수량을 뺀 값보다 클 수 없습니다.");
							var changeData = {
								"use_qty": 0
							};

							AUIGrid.updateRow(auiGridReportPart, changeData, event.rowIndex, false);
						} else {
							billAmount = useQty * amount;
							var changeData = {
								"bill_amount": billAmount
							};

							AUIGrid.updateRow(auiGridReportPart, changeData, event.rowIndex, false);

							var gridData = AUIGrid.getGridData(auiGridReportPart);
							var partTotalAmt = 0;
							for (var i in gridData) {
								partTotalAmt += $M.toNum(gridData[i].bill_amount);
							}

							$M.setValue("part_total_amt", partTotalAmt);
							fnCalcPartPrice();
						}
					} else if(event.dataField == "amount") {
						var item = AUIGrid.getItemByRowIndex(auiGridReportPart, event.rowIndex);
						var amount = $M.toNum(item.amount); // 금액
						var useQty = $M.toNum(item.use_qty); // 사용수량
						var billAmount = 0;

						billAmount = useQty * amount;
						var changeData = {
							"bill_amount" : billAmount
						};

						AUIGrid.updateRow(auiGridReportPart, changeData, event.rowIndex, false);

						var gridData = AUIGrid.getGridData(auiGridReportPart);
						var partTotalAmt = 0;
						for(var i in gridData) {
							partTotalAmt += $M.toNum(gridData[i].bill_amount);
						}

						$M.setValue("part_total_amt", partTotalAmt);
						fnCalcPartPrice();
					} else if (event.dataField == "old_part_yn") {
						if(event.item.old_part_yn == "N") {
							AUIGrid.updateRow(auiGridReportPart, {"old_part_trouble": ""}, event.rowIndex);
						}
					}else if(event.dataField == "part_no") {
						// remote renderer 에서 선택한 값
						var item = fnGetPartItem(event.value);
						if(item === undefined) {
							AUIGrid.updateRow(auiGridReportPart, {part_no : event.oldValue}, event.rowIndex);
						} else {
							// 수정 완료하면, 나머지 필드도 같이 업데이트 함.

							// VIP판매가 추가 : 고객이 VIP일경우 VIP판매가로 적용.
							var unitPrice = 0;
                            var warningText = "";
							if ($M.getValue("vip_yn") == 'Y') {
								unitPrice = item.vip_sale_price;
							} else {
								unitPrice = item.sale_price;
							}

							if(item.hasOwnProperty("warning_text") && item.warning_text != "" && item.warning_text != undefined){
								warningText += event.value+" 주의사항 : \n"+item.warning_text+"\n\n";
		                    }

							AUIGrid.updateRow(auiGridReportPart, {
								part_name : item.part_name,
								qty : 1,
// 								unit_price : item.sale_price,
								unit_price : unitPrice,
// 								amount : 1 * $M.toNum(item.sale_price),
								amount : 1 * unitPrice,
								part_able_stock : item.part_able_stock,
								use_qty : 0,
								part_name_change_yn : item.part_name_change_yn,
							}, event.rowIndex);

							if(warningText != ""){
			                	window.setTimeout(function(){ alert(warningText) }, 200);
                            }
						}
						fnCalcPartPrice();
					}

					fnChangePrice();
					break;
			}
		}

		// part_no 으로 검색해온 정보 아이템(row) 반환 (엔터 or 마우스 클릭시 호출).
		function fnGetPartItem(part_no) {
			var item;
			$.each(recentPartList, function(index, row) {
				if(row.part_no == part_no) {
					item = row;
					return false; // 중지
				}
			});
			return item;
		};

		// 정비작업 그리드
		function createAUIGridReportWork() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn : false
			};

			var columnLayout = [
				{
					headerText : "정비일자",
					dataField : "work_dt",
					width : "20%",
					dataType : "date",
					formatString : "yyyy-mm-dd"
				},
				{
					headerText : "정비시작",
					width : "20%",
					dataField : "v_start_ti",
					dataType : "date",
					formatString : "HH:MM"
				},
				{
					headerText : "DB정비시작",
					dataField : "start_ti",
					visible : false
				},
				{
					headerText : "정비종료",
					width : "20%",
					dataField : "v_end_ti",
					dataType : "date",
					formatString : "HH:MM"
				},
				{
					headerText : "DB정비종료",
					dataField : "end_ti",
					visible : false
				},
				{
					headerText : "편집",
					dataField : "edit",
					renderer : { // HTML 템플릿 렌더러 사용
						type : "TemplateRenderer"
					},
					// dataField 로 정의된 필드 값이 HTML 이라면 labelFunction 으로 처리할 필요 없음.
					labelFunction : function (rowIndex, columnIndex, value, headerText, item ) { // HTML 템플릿 작성
						var startTi = $M.nvl(item.start_ti, 'N');
						var endTi = $M.nvl(item.end_ti, 'N');

						var template = '<div class="my_div">';

						template += '<button class="btn btn-outline-default" style="width: 30%" onclick="javascript:goStartTi(' + rowIndex + ',\'' + startTi + '\');">시작</button>';
						template += '<button class="btn btn-outline-default" style="width: 30%" onclick="javascript:goEndTi(' + rowIndex + ',\'' + startTi + '\',\'' + endTi + '\');">종료</button>';
						template += '<button class="btn btn-outline-default" style="width: 30%" onclick="javascript:goServiceLog(' + rowIndex + ',\'' + endTi + '\');">일지</button>';
						template += '</div>';
						return template;
					}
				}
			];

			// 실제로 #grid_wrap에 그리드 생성
			auiGridReportWork = AUIGrid.create("#auiGridReportWork", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGridReportWork, []);
		}

		// CAP이력 팝업
		function goCapLog() {
			var machineSeq = $M.getValue("machine_seq");
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
			var machineSeq = $M.getValue("machine_seq");
			if(machineSeq == "") {
				alert("차대번호 조회를 먼저 진행해주세요.");
				return;
			}

			var params = {
				"s_machine_seq" : $M.getValue("machine_seq")
			};
			var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=750, height=420, left=0, top=0";
			$M.goNextPage('/serv/serv0101p02', $M.toGetParam(params), {popupStatus : popupOption});
		}

		// 비용반영
		function goApplyAmt() {
			var data = AUIGrid.getGridData(auiGridReportOrder);

			var workAmt = 0;
			workTotalAmt = $M.toNum($M.getValue("work_total_amt"));

			for(var i in data) {
				var changData = {
					"work_yn" : "Y"
				};

				AUIGrid.updateRow(auiGridReportOrder, changData, data[i].rowIndex);

				workAmt = data[i].item.work_amt;
				workTotalAmt += workAmt;
			}

			// 비용반영 처리 한 Data는 unCheck
			$M.setValue("work_total_amt", workTotalAmt);
			fnChangePrice();
		}

		// 자주쓰는 작업
		function goBookmark() {
			var param = {
				"parent_js_name" : "fnSetJobReportOrder"
			};

			var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1400, height=650, left=0, top=0";
			$M.goNextPage('/serv/serv0101p11', $M.toGetParam(param), {popupStatus : popupOption});
		}

		// 4. 상담과 점검/정비 -> 정비불러오기 팝업
		function goBookmarkRepair() {
			if($M.getValue("machine_plant_seq") == "") {
				alert("차대번호 조회를 먼저 진행해주세요.");
				return;
			}
			var param = {
				"s_machine_plant_seq" : $M.getValue("machine_plant_seq")
			};
			param.parent_js_name = "fnSetJobReportOrder";
			var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1400, height=650, left=0, top=0";
			$M.goNextPage('/serv/serv0101p18', $M.toGetParam(param), {popupStatus : popupOption});
		}

		// 자주쓰는작업 data Setting
		function fnSetJobReportOrder(data) {
			var item = new Object();
			var parentRowId = null;
			var planWorkAmt = 0;
			// planWorkTotalAmt = $M.toNum($M.getValue("plan_work_total_amt"));
			for(var i=0; i < data.length; i++) {
				// 7. 비용 - 공임(예상) 계산
				planWorkAmt = $M.toNum(data[i].item.plan_work_amt);
				// planWorkTotalAmt += planWorkAmt;

				item.job_order_type_cd = data[i].item.job_order_type_cd;
				item.order_text = data[i].item.order_text;
				item.plan_work_amt = planWorkAmt;
				item.work_amt = 0;
				item.work_hour = data[i].item.work_hour;
				item.job_report_order_seq = data[i].item.job_order_bookmark_seq;
				item.up_job_report_order_seq = data[i].item.up_job_order_bookmark_seq;
				if(data[i].item.up_job_order_bookmark_seq != 0) {
					item.sort_no = "1";
				} else {
					item.sort_no = "0";
				}
				item.bookmark_type_jr = data[i].item.bookmark_type_jr;
				item.break_part_seq = data[i].item.break_part_seq;
				item.row_num = rowNum;
				item.apply_yn = "N";
				item.work_yn = "Y";
				// if(data[i].item._$depth == 1) {
					AUIGrid.addRow(auiGridReportOrder, item, 'last');

				// 	var selectedItems = AUIGrid.getSelectedItems(auiGridReportOrder);
				// 	var selItem = selectedItems[0].item;
				// 	parentRowId = selItem._$uid;
				// } else {
				// 	item.parentRowId = parentRowId;
				// 	AUIGrid.addTreeRow(auiGridReportOrder, item, parentRowId, 'first');
				// }
				rowNum++;
			}

			// 7. 비용 - 공임(예상) Setting
			// $M.setValue("plan_work_total_amt", planWorkTotalAmt);
			fnCalcOrderPlanWorkAmt();
			fnCalcOrderWorkAmt();
			fnCalcOrderWorkHour();
			fnChangePrice();
		}

		function fnCalcOrderPlanWorkAmt() {
			var data = AUIGrid.getGridData(auiGridReportOrder);

			var planWorkTotalAmt = 0;
			for(var i in data) {
				if(data[i].order_cmd != "D") {
					planWorkTotalAmt += $M.toNum(data[i].plan_work_amt);
				}
			}

			// 7. 비용 -> 공임(예상)
			$M.setValue("plan_work_total_amt", planWorkTotalAmt);

			// 7.비용 -> 합계, 총금액(VAT포함) 계산
			fnChangePrice();
		}
		function fnCalcOrderWorkAmt() {
			var data = AUIGrid.getGridData(auiGridReportOrder);
			// work_total_amt
			var workTotalAmt = 0;
			for(var i in data) {
				if(data[i].order_cmd != "D") {
					workTotalAmt += $M.toNum(data[i].work_amt);
				}
			}

			// 7. 비용 -> 공임(최종)
			$M.setValue("work_total_amt", workTotalAmt);

			// 7.비용 -> 합계, 총금액(VAT포함) 계산
			fnChangePrice();
		}

		function fnCalcOrderWorkHour() {
			var data = AUIGrid.getGridData(auiGridReportOrder);

			var workTotalHour = 0;
			for(var i in data) {
				if(data[i].order_cmd != "D") {
					workTotalHour += $M.toNum(data[i].work_hour);
				}
			}

			// 7. 비용 -> 공임(최종)
			$M.setValue("except_repair_hour", workTotalHour.toFixed(1));
		}

		// 미결 사항 추가.
		function fnSetJobOrder(data) {
			var item = new Object();
			var parentRowId = null;

			for(var i=0; i < data.length; i++) {
				item.job_order_type_cd = "CONSULT";
				item.order_text = data[i].order_text;
				item.as_plan_dt = data[i].plan_dt;
				item.as_assign_mem_no = data[i].assign_mem_no;
				item.plan_work_amt = 0;
				item.work_amt = 0;
				item.work_hour = 0;
				item.job_report_order_seq = data[i].job_report_order_seq;
				item.up_job_report_order_seq = 0;
				item.as_todo_seq = data[i].as_todo_seq;
				item.bookmark_type_jr = "J";
				item.work_yn = "Y";
				item.sort_no = "0";
				item.row_num = rowNum;

				// if(data[i]._$depth == 1) {
					AUIGrid.addRow(auiGridReportOrder, item, 'last');

				// 	var selectedItems = AUIGrid.getSelectedItems(auiGridReportOrder);
				// 	var selItem = selectedItems[0].item;
				// 	parentRowId = selItem._$uid;
				// } else {
				// 	item.parentRowId = parentRowId;
				// 	AUIGrid.addTreeRow(auiGridReportOrder, item, parentRowId, 'first');
				// }
				rowNum++;
			}
		}

		// 상담과 점검/정비 - 행추가
		function fnAddPaid() {
			for(var i=0; i<10; i++) {
				var item = new Object();
				item.job_order_type_cd = "REPAIR";
				item.order_text = "";
				item.plan_work_amt = "";
				item.work_amt = "";
				item.work_hour = "";
				item.up_job_report_order_seq = 0;
				item.row_num = rowNum;
				item.bookmark_type_jr = "J";
				item.work_yn = "Y";
				item.sort_no = "0";

				rowNum++;
				AUIGrid.addRow(auiGridReportOrder, item, 'last');
			}
		}

		// 단축키 사용 시
		function fnAddPaidKeyDown() {
			var item = new Object();
			item.job_order_type_cd = "REPAIR";
			item.order_text = "";
			item.plan_work_amt = "";
			item.work_amt = "";
			item.work_hour = "";
			item.up_job_report_order_seq = 0;
			item.row_num = rowNum;
			item.bookmark_type_jr = "J";
			item.work_yn = "Y";
			item.sort_no = "0";

			rowNum++;
			AUIGrid.addRow(auiGridReportOrder, item, 'selectionDown');
		}

		// 상담과 점검/정비 필수 항목 체크
		function fnCheckOrderGridEmpty() {
			return AUIGrid.validateGridData(auiGridReportOrder, ["order_text", "plan_work_amt", "work_amt", "work_hour"], "필수 항목은 반드시 값을 입력해야합니다.");
		}

		// 견적서출력
		function goDocPrint() {
			alert("저장 후 진행 가능합니다.");
			return;
		}

		// 거래명세표출력
		function fnTaxBillPrint() {
			alert("저장 후 진행 가능합니다.");
			return;
		}

		// 정비지시서출력
		function fnJobReportPrint() {
			alert("저장 후 진행 가능합니다.");
			return;
		}

		// 체크부품출력
		function goCheckPartPrint() {
			alert("저장 후 진행 가능합니다.");
			return;
		}

		// 부품분출요청서
		function goOutRequestForm() {
			alert("저장 후 진행 가능합니다.");
			return;
		}

		// 부품분출요청 쪽지발송
		function goNoteSend() {
			alert("저장 후 진행 가능합니다.");
			return;
		}

		// 정비지시서 부품출고(반품)처리 팝업
		function goPopupPart() {
			alert("담당기사 배정처리 후 부품출고처리가 가능합니다.");
			return;
		}

		// 센터 Setting
		function setOrgMapCenterPanel(data) {
			$M.setValue("org_code", data.org_code);
			$M.setValue("org_name", data.org_name);
		}

		// 배정직원 Setting
		function setMemberOrgMapPanel(data) {
			$M.setValue("assign_mem_name", data.mem_name);
			$M.setValue("assign_mem_no", data.mem_no);
			$M.setValue("eng_mem_no", data.mem_no);
		}

		// 배정처리
		function goAssign() {
			alert("저장 후 처리가능합니다.");
		}

		// 부품 행추가
		function fnAddCostItem() {
			if($M.getValue("machine_seq") == "") {
				alert("차대번호 조회를 먼저 진행해주세요.");
				return;
			}

			var colIndex = AUIGrid.getColumnIndexByDataField(auiGridReportPart, "part_no");

			var item = new Object();
			var partNo ='';
			var partName ='';
			var qty = 1;
			var salePrice = 0;
			var amount = 0;
			var unitPrice = 0;

			partNo = '';
			partName = '';
			salePrice = 0;
			unitPrice = 0;
			amount = qty * unitPrice;

			item.part_no = partNo;
			item.part_name = partName;
			item.unit_price = unitPrice;
			item.normal_yn = "Y";
			item.qty = qty;
			item.sale_price = salePrice;
			item.amount = amount;
			item.out_qty = 0;
			item.return_qty = 0;
			item.bill_amount = 0;
			item.old_part_yn = "N";
			item.seq_no = 0;
			item.use_yn = 'Y';
			item.part_name_change_yn = "N";

			AUIGrid.addRow(auiGridReportPart, item, 'last');
		}

		//부품조회 창 열기
		function goPartList() {
			var items = AUIGrid.getAddedRowItems(auiGridReportPart);
			if($M.getValue("machine_seq") == "") {
				alert("차대번호 조회를 먼저 진행해주세요.");
				return;
			}

			var param = {
				's_warehouse_cd' : $M.getValue('org_code'),
				's_only_warehouse_yn' : "N",	// 센터일 때만 Y로 넘김 -> 전체 다 나오게 변경
                's_warning_check' : "Y", // 정비지시서 및 수주에서 부품조회시 alert가 다르게 나오고 리턴받는 list를 다르게 받기위해 생성
			};

			if(fnCheckGridEmptyPart(auiGridReportPart)) {
				openSearchPartPanel('setPartInfo', 'Y', $M.toGetParam(param));
			}
		}

		// 부품 Data Setting
		function setPartInfo(rowArr) {
			var partNo ='';
			var partName ='';
			var qty = 1;
			var salePrice = 0;
			var amount = 0;
			var unitPrice = 0;
			var vipSalePrice = 0;
			var row = new Object();
			var warningText = "";
			if(rowArr != null) {
				for(i=0; i<rowArr.length; i++) {
					partNo = typeof rowArr[i].part_no == "undefined" ? partNo : rowArr[i].part_no;
					partName = typeof rowArr[i].part_name == "undefined" ? partName : rowArr[i].part_name;

					// VIP판매가 추가 : 고객이 VIP일경우 VIP판매가로 적용.
					if ($M.getValue("vip_yn") == 'Y') {
	                    salePrice = typeof rowArr[i].vip_sale_price == "undefined" ? vipSalePrice	: rowArr[i].vip_sale_price;
					} else {
						salePrice = typeof rowArr[i].sale_price == "undefined" ? salePrice	: rowArr[i].sale_price;
					}

					unitPrice = typeof rowArr[i].unit_price == "undefined" ? unitPrice : rowArr[i].unit_price;
					amount = qty * salePrice;
					row.part_no = partNo;
					row.part_name = partName;
					row.unit_price = salePrice;
					row.normal_yn = "Y";
					row.qty = qty;
					row.part_able_stock = rowArr[i].part_able_stock;
					row.sale_price = salePrice;
					row.amount = amount;
					row.out_qty = 0;
					row.use_qty = 0;
					row.return_qty = 0;
					row.bill_amount = 0;
					row.old_part_yn = "N";
					row.seq_no = 0;
					row.use_yn = 'Y';
					row.part_name_change_yn = rowArr[i].part_name_change_yn;

                    if(rowArr[i].hasOwnProperty("warning_text") && rowArr[i].warning_text != "" && rowArr[i].warning_text != undefined){
						warningText += partNo+" 주의사항 : \n"+rowArr[i].warning_text+"\n\n";
                    }

					AUIGrid.addRow(auiGridReportPart, row, 'last');

					if(rowArr[i].hasOwnProperty("multi_check") && rowArr[i].multi_check == "Y" && warningText != "" && warningText != undefined){
                        fnCalcPartPrice();
                    	return warningText;
                    }
				}

				if(warningText != ""){
                	window.setTimeout(function(){ alert(warningText) }, 200);
				}
			}

			// 5. 부품목록 -> 금액 합계 계산
			fnCalcPartPrice();
		}

	    // SET조회 창 열기
	    function goSearchSet() {
			if($M.getValue("machine_seq") == "") {
				alert("차대번호 조회를 먼저 진행해주세요.");
				return;
			}

			var popupOption = "";
			var param = {
    				"cust_no" : $M.getValue("cust_no"),
					"warehouse_cd" : $M.getValue('org_code'),
    				"parent_js_name" : "fnSetInputPart"
    		};

			$M.goNextPage('/part/part0703p03', $M.toGetParam(param), {popupStatus : popupOption});
	    }

	    // 부품대량입력 팝업
	    function fnMassInputPart() {
			if($M.getValue("machine_seq") == "") {
				alert("차대번호 조회를 먼저 진행해주세요.");
				return;
			}

			var popupOption = "";
			var param = {
    				"cust_no" : $M.getValue("cust_no"),
    				"parent_js_name" : "fnSetInputPart"
    		};

			$M.goNextPage('/cust/cust0201p06', $M.toGetParam(param), {popupStatus : popupOption});

	    }

		// 부품대량입력, SET조회 데이터 세팅
	    function fnSetInputPart(rowArr) {
			console.log(rowArr)
			var partNo ='';
			var partName ='';
			var qty = 1;
			var salePrice = 0;
			var amount = 0;
			var unitPrice = 0;
			var vipSalePrice = 0;
			var row = new Object();
			var warningText = "";
			if(rowArr != null) {
				for(i=0; i < rowArr.length; i++) {
					qty = rowArr[i].qty;
					partNo = typeof rowArr[i].part_no == "undefined" ? partNo : rowArr[i].part_no;
					partName = typeof rowArr[i].part_name == "undefined" ? partName : rowArr[i].part_name;

					// VIP판매가 추가 : 고객이 VIP일경우 VIP판매가로 적용.
					if ($M.getValue("vip_yn") == 'Y') {
	                    salePrice = typeof rowArr[i].vip_sale_price == "undefined" ? vipSalePrice	: rowArr[i].vip_sale_price;
					} else {
						salePrice = typeof rowArr[i].sale_price == "undefined" ? salePrice	: rowArr[i].sale_price;
					}

					unitPrice = typeof rowArr[i].unit_price == "undefined" ? unitPrice : rowArr[i].unit_price;
					amount = qty * salePrice;
					row.part_no = partNo;
					row.part_name = partName;
					row.unit_price = salePrice;
					row.normal_yn = "Y";
					row.qty = qty;
					row.part_able_stock = rowArr[i].part_able_stock;
					row.sale_price = salePrice;
					row.amount = amount;
					row.out_qty = 0;
					row.use_qty = 0;
					row.return_qty = 0;
					row.bill_amount = 0;
					row.old_part_yn = "N";
					row.seq_no = 0;
					row.use_yn = 'Y';
					row.part_name_change_yn = rowArr[i].part_name_change_yn;

					if(rowArr[i].hasOwnProperty("warning_text") && rowArr[i].warning_text != "" && rowArr[i].warning_text != undefined){
						warningText += partNo+" 주의사항 : \n"+rowArr[i].warning_text+"\n\n";
                    }

					AUIGrid.addRow(auiGridReportPart, row, 'last');
				}
				if(warningText != ""){
                	window.setTimeout(function(){ alert(warningText) }, 200);
				}
			}
			// 5. 부품목록 -> 금액 합계 계산
			fnCalcPartPrice();
	    }

		function fnCalcPartPrice() {
			var data = AUIGrid.getGridData(auiGridReportPart);
			// plan_part_total_amt
			var planPartTotalAmt = 0;
			for(var i in data) {
				planPartTotalAmt += $M.toNum(data[i].amount);
			}

			// 7. 비용 -> 부품(예상)
			$M.setValue("plan_part_total_amt", planPartTotalAmt);

			// 7.비용 -> 합계, 총금액(VAT포함) 계산
			fnChangePrice();
		}

		// 그리드 빈값 체크
		function fnCheckGridEmptyPart() {
			return AUIGrid.validateGridData(auiGridReportPart, ["part_no", "part_name", "unit_price"], "필수 항목은 반드시 값을 입력해야합니다.");
		}

		// 체크부품삭제
		function fnRemove() {
			var gridData = AUIGrid.getCheckedRowItemsAll(auiGridReportPart);

			if (gridData.length == 0) {
				alert("삭제할 부품을 체크해주세요.");
				return;
			}

			for(var i=0; i<gridData.length; i++) {
				var isRemoved = AUIGrid.isRemovedById(auiGridReportPart, gridData[i]._$uid);
				var rowIndex = AUIGrid.getRowIndexesByValue(auiGridReportPart, "_$uid", gridData[i]._$uid);
				var amount = $M.toNum(gridData[i].amount);
				planPartTotalAmt = planPartTotalAmt - amount;
				$M.setValue("plan_part_total_amt", planPartTotalAmt);
				if (isRemoved == false) {
					AUIGrid.removeRow(auiGridReportPart, rowIndex);
					AUIGrid.update(auiGridReportPart);
				} else {
					AUIGrid.restoreSoftRows(auiGridReportPart, "selectedIndex");
					AUIGrid.update(auiGridReportPart);
				};
			}

			fnChangePrice();
		}

		// 저장
		function goSave() {
			var frm = document.main_form;
			//validationcheck
			if($M.validation(frm,
					{field:["body_no", "cust_name", "receipt_type_rt",
							"job_case_ti", "job_type_cd", "org_name"]})==false) {
				return;
			};

			// 상버자확인이 사라져서 무조건 Y로 세팅
			$M.setValue("breg_confirm_yn","Y");
			// 사업자확인 CheckBox 확인
			// if(!$M.isCheckBoxSel("breg_confirm_yn")) {
			// 	alert("사업자확인을 먼저 진행해주세요.");
			// 	$M.getComp("breg_confirm_yn").focus();
			// 	return;
			// }

			if($M.getValue("receipt_type_rt") == "R" && $M.getValue("in_dt") == "") {
				alert("접수구분 사전을 선택했을 경우\n입고일자는 필수입니다.");
				$M.getComp("in_dt").focus();
				return;
			}

			// 접수구분 당일로 선택했을 시 정비예약시간
			if($M.getValue("receipt_type_rt") == "T") {
				var reserveDt = $M.toNum($M.getValue("reserve_repair_ti"));
				var nowTi = $M.toNum($M.getCurrentDate("HHmm"));
				if(reserveDt < nowTi) {
					alert("접수구분 당일을 선택했을 경우\n정비예약시간은 현재시간보다 이후로 설정해야합니다.");
					return;
				}
			}

			if($M.toNum($M.getValue("reserve_repair_ti")) > $M.toNum($M.getValue("reserve_repair_ed_ti"))){
				alert("정비예약종료시간은 시작시간 이후로 설정해야합니다.");
				return;
			}

			$M.setValue("reserve_repair_st_ti",$M.getValue("reserve_repair_ti"));

			// cap정비 시 예정일자 입력여부 확인
			if ($M.getValue("cap_use_yn") == "Y") {
				if ($M.getValue("cap_plan_dt") == "") {
					alert("CAP예정일자를 입력해주세요.");
					return;
				}
			}

			if($M.getValue("op_hour") != "") {
				if($M.toNum($M.getValue("prev_op_hour")) > $M.toNum($M.getValue("op_hour"))) {
					alert("가동 시간 입력 오류\n(가동시간은 " + $M.toNum($M.getValue("prev_op_hour")) + " 보다 커야합니다.)");
					return;
				}
			}

			var fileArr = [];
			var jobFileArr = [];
			$("[name=att_file_seqR]").each(function () {
				fileArr.push($(this).val());
			});
			$("[name=att_file_seqJ]").each(function () {
				jobFileArr.push($(this).val());
			});

			// if(fileArr.length < 4) {
			// 	alert("정비사진은 최소 4장이 필요합니다.");
			// 	return false;
			// }

			var picTypeArr = [];
			var fileSeqArr = [];
			fileArr.forEach(function(item) {
				fileSeqArr.push(item);
				picTypeArr.push("R");
			});
			jobFileArr.forEach(function(item) {
				fileSeqArr.push(item);
				picTypeArr.push("J");
			});

			$M.setValue("file_seq_no_str", $M.getArrStr(fileSeqArr));
			$M.setValue("pic_type_str", $M.getArrStr(picTypeArr));

			// 접수구분 -> 사전인 경우 -> 사전예약문자발송여부 확인
			// 22-09-23 사전예약문자발송 로직에 배정처리 추가로 인해
			// 등록시에는 배정처리가 불가능하므로 주석처리
			// if($M.getValue("reserve_sms_send_target_yn") == "N"
			// 		&& $M.getValue("reserve_n") == "N" && $M.getValue("receipt_type_rt") == "R") {
			// 	goReservationText();
			// }

			$M.setValue("visit_dt", $M.getValue("in_dt"));
			if($M.getValue("eng_mem_no") != ""){
				$M.setValue("job_status_cd", '5');
			}else {
				$M.setValue("job_status_cd", '0');
			}
			$M.setValue("job_st_dt", $M.getCurrentDate("yyyyMMdd"));
			frm = $M.toValueForm(document.main_form);

			var concatCols = [];
			var concatList = [];
			var order = [];

			// 상담과 점검/정비 행추가시 10개씩 추가 됨. (작성 된 행만 추출)
			var tempList = AUIGrid.exportToObject(auiGridReportOrder);
			for (var i = 0; i < tempList.length; i++) {
				var obj = new Object();
				for (var prop in tempList[i]) {
					obj[prop] = tempList[i][prop];
				}
				if (obj['order_text'] != "") {
					order.push(obj);
				}
			}

			AUIGrid.setGridData(auiGridReportOrder, order);
			var gridIds = [auiGridReportPart, auiGridReportWork, auiGridReportOrder];
			for (var i = 0; i < gridIds.length; ++i) {
				concatList = concatList.concat(AUIGrid.exportToObject(gridIds[i]));
				concatCols = concatCols.concat(fnGetColumns(gridIds[i]));
			}

			var gridFrm = fnGridDataToForm(concatCols, concatList);
			$M.copyForm(gridFrm, frm);

			var msg = "저장하시겠습니까?";
			if ($M.getValue("cust_grade_hand_cd_str").indexOf("04") != -1) {
				msg = "그레이장비 보유 고객입니다. " + msg;
			}
			$M.goNextPageAjaxMsg(msg, this_page + "/save", gridFrm, {method: 'POST'},
					function (result) {
						if (result.success) {
							$M.setValue("s_job_report_no", result.job_report_no);
							alert("저장이 완료되었습니다.");
							window.opener.location.reload();
							window.opener.top.location.reload();
							fnClose();
							goJobReportDetail();
						}
					}
			);
		}

		function goJobReportDetail() {
			var params = {
				"s_job_report_no" : $M.getValue("s_job_report_no"),
				"s_self_assign_no" : $M.getValue("self_assign_no")
			};

			var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=300, height=200, left=0, top=0";
			$M.goNextPage('/serv/serv0101p01', $M.toGetParam(params), {popupStatus : popupOption});
		}

		// 접수구분 - 사전 (사전예약문자발송여부 팝업)
		function goReservationText() {
			var params = {
				"parent_js_name" : "fnSetReservationYn",
				"s_in_dt" : $M.dateFormat($M.getValue("in_dt"), "yyyy년 MM월 dd일"),
				"s_cust_name" : $M.getValue("cust_name")
			};

			var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=800, height=300, left=0, top=0";
			$M.goNextPage('/serv/serv0101p05', $M.toGetParam(params), {popupStatus : popupOption});
		}

		function fnSetReservationYn(data) {
			$M.setValue("reserve_sms_send_target_yn", data.reserve_sms_send_target_yn);
			$M.setValue("reserve_n", data.reserve_n);
			setTimeout(goSave, 100);
		}

		// 닫기
		function fnList() {
			history.back();
		}

		function fnClose() {
			window.close();
		}

		// 정비작업 - 시작
		function goStartTi(rowIndex, startTi) {
			if(startTi != 'N') {
				alert("정비시작 시작은 변경이 불가능합니다.");
				return;
			}

			if($M.getValue("reg_id") != $M.getValue("eng_mem_no")){
				alert("배정직원만 정비시작이 가능합니다.");
				return;
			}

			if(confirm("현장의 여건과 작업환경이 올바르고 안전한 정비에 적합하지 않는다 판단되는 경우, 작업자는 정비를 거부하고, 환경을 적극적으로 개선할 의무가 있습니다")){
				$M.setValue("job_mem_no", $M.getValue("reg_id"));
				$M.setValue("job_confirm_date", $M.getCurrentDate("yyyyMMddHHmmss"));
				AUIGrid.setCellValue(auiGridReportWork, rowIndex, "edit", 'N');
				AUIGrid.setCellValue(auiGridReportWork, rowIndex, "start_ti", $M.getCurrentDate("HHmm"));
				AUIGrid.setCellValue(auiGridReportWork, rowIndex, "v_start_ti", $M.getCurrentDate("HH:mm"));
			}

		}

		// 정비작업 - 종료
		function goEndTi(rowIndex, startTi, endTi) {
			if(startTi == 'N') {
				alert("정비시작 먼저 진행해주세요.");
				return;
			}

			if('${SecureUser.mem_no}' != $M.getValue("eng_mem_no")){
				alert("배정직원만 정비종료가 가능합니다.");
				return;
			}

			if(endTi != 'N') {
				alert("정비종료 시간은 변경이 불가능합니다.");
				return;
			}

			AUIGrid.setCellValue(auiGridReportWork, rowIndex, "end_ti", $M.getCurrentDate("HHmm"));
			AUIGrid.setCellValue(auiGridReportWork, rowIndex, "v_end_ti", $M.getCurrentDate("HH:mm"));

			// 6. 정비일시 -> 시간 계산
			fnCalcTime();
		}

		// 6. 정비일시 -> 시간 계산
		function fnCalcTime() {
			var data = AUIGrid.getGridData(auiGridReportWork);

			var total = 0;
			for(var i in data) {
				var startTime = data[i].v_start_ti;
				var endTime = data[i].v_end_ti;
				var lapsetime = 0;

				var stTime = getTime(startTime.split(":")[0], startTime.split(":")[1]);
				var edTime = getTime(endTime.split(":")[0], endTime.split(":")[1]);
				if(edTime.getTime() < stTime.getTime()) {
					edTime.setDate(edTime.getDate() + 1);
				}

				try {
					lapsetime = (Math.floor(((edTime.getTime() - stTime.getTime()) / 1000 / 60 / 60) * 10) / 10) ;
					total += lapsetime;
				} catch(Exception) {
				}
			}

			$M.setValue("work_ti", $M.toNum(total));
		}

		function getTime(hour, min) {
			var date = new Date();

			if("" == hour) {
				hour = 0;
			}

			if("" == min) {
				min = 0;
			}

			return new Date(date.getFullYear(), date.getMonth(), date.getDay(), $M.toNum(hour), $M.toNum(min));
		}

		// 정비작업 - 서비스일지
		function goServiceLog(rowIndex, endTi) {
			alert("저장 후 처리가능합니다.");
		}

		function show(id) {
			document.getElementById(id).style.display="block";
		}
		function hide(id) {
			document.getElementById(id).style.display="none";
		}

		// 예약문자발송
		function goSendSmsReserve() {
			alert("예약확정은 저장 후 가능합니다.");
			return;
			if($M.getValue("machine_seq") == "") {
				alert("차대번호 조회를 먼저 진행해주세요.");
				return;
			}

			if($M.getValue("in_dt") == "") {
				alert("입고일자를 선택해주세요.");
				return;
			}

			//메세지참조기능 사용시 사용메뉴seq,파라미터도 세팅
			var param = {
				'name' 		 : $M.getValue("cust_name"),
				'org_name' 	: $M.getValue("org_name"),
				'in_dt' 	: $M.getValue("in_dt"),
				'reserve_repair_ti' : $M.getValue("reserve_repair_ti"),
				'hp_no' 	: $M.getValue("hp_no"),
				'req_msg_yn'  : "Y",
				'parent_js_name'  : "fnReserveMsgComplete",
				'menu_seq'	 : ${menu_seq},
			}

			openSendSmsPanel($M.toGetParam(param));
		}

		function fnReserveMsgComplete() {
			$("#reserve_confirm_msg").html("발송완료");
			$M.setValue("reserve_sms_send_yn", "Y");
		}

		function fnChangeInDt() {
			$("#reserve_confirm_msg").html("");
			$M.setValue("reserve_sms_send_yn", "N");
		}

		function fnSetRentalCust(data) {
			$M.setValue("rental_cust_no", data.cust_no);
			$M.setValue("rental_cust_name", data.cust_name);
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

			var uploadType = "upload_type=SERV&total_max_count=0";
			if(type == 'R') {
				uploadType += "&file_type=both";
			} else {
				uploadType += "&file_type=img";
			}

			openFileUploadMultiPanel('setFileInfo'+type, uploadType+fileParam);
		}

		function setFileInfoR(result) {
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
			str += '<button type="button" class="btn-default check-dis" onclick="javascript:fnRemoveFile(' + fileSeq + ')"><i class="material-iconsclose font-18 text-default"></i></button>';

			str += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
			str += '</div>';
			$('.att_file_div'+type).append(str);
		}

		// 첨부파일 삭제
		function fnRemoveFile(fileSeq) {
			if (confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.")) {
				$(".att_file_" + fileSeq).remove();
			} else {
				return false;
			}
		}

		// SA-R 운행정보 팝업
		function goSarOperationMap(type) {
			if($M.getValue("machine_seq") == "") {
				alert("차대번호 조회를 먼저 진행해주세요.");
				return;
			}

			var popupOption = "";
			var params = {
				s_type : type,
				machine_seq : $M.getValue("machine_seq")
			}
			$M.goNextPage('/sale/sale0205p04', $M.toGetParam(params), {popupStatus: popupOption});
		}

		/**
		 * 장기/충당재고 팝업
		 */
		function goLongPart() {
			if($M.getValue("machine_seq") == "") {
				alert("차대번호 조회를 먼저 진행해주세요.");
				return;
			}

			var param = {
				"machine_seq" : $M.getValue("machine_seq"),
				"org_code" : $M.getValue("org_code"),
			};

			openSearchLongPartPanel("setPartInfo", "Y", $M.toGetParam(param));
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
    
    // 정비구분 클릭 이벤트
    function onChangeJobTypeCd() {
      var bodyNo = $M.getValue("body_no");
      if(bodyNo == '') {
        alert("차대번호 조회를 먼저 진행해주세요.");
        $("input[name='job_type_cd']").prop("checked", false);
        return;
      }
      
      // 22866 자동화건 - cap 로직 체크 추가
      if($M.getValue('job_type_cd') == "5" && $M.getValue('cap_yn') === 'N') {
        alert("장비대장에서 CAP적용 후 해당 화면을 새로고침하여 다시 진행해주세요.");
        $M.setValue("job_type_cd", "4");
        return;
      }
      
      if($M.getValue('job_type_cd') == '6') {
        // 미결사항 팝업 열기
        var params = {
          "machine_seq" : $M.getValue('machine_seq'),
          "cust_no" : $M.getValue('cust_no'),
          "no_reload" : 'Y',
          "is_next_trip_dt_set" : 'Y',
        };
        var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=600, height=300, left=0, top=0";
        $M.goNextPage('/serv/serv0101p08', $M.toGetParam(params), {popupStatus : popupOption});
      }
    }
	function selectMachineSeq(){
		var param = {
			"s_cust_name" : $M.getValue("cust_name"),
			"s_hp_no" : $M.getValue("hp_no"),
		};
		openSearchDeviceHisPanel('fnSetInformation',$M.toGetParam(param));
	}
	</script>
</head>
<body>
<%--
			var machine_seq = $M.getValue("machine_seq"); var cust_no = $M.getValue("cust_no");--%>
<form id="main_form" name="main_form">
<input type="hidden" name="reg_id" id="reg_id" value="${SecureUser.mem_no}">
<input type="hidden" name="org_code" id="org_code" value="${SecureUser.org_code}">
<input type="hidden" name="svc_travel_expense_seq" id="svc_travel_expense_seq">
<input type="hidden" name="machine_seq" id="machine_seq" value="${inputParam.machine_seq}">
<input type="hidden" name="cust_no" id="cust_no" value="${inputParam.cust_no}">
<input type="hidden" name="s_cust_no" id="s_cust_no">
<input type="hidden" name="assign_mem_no" id="assign_mem_no">
<input type="hidden" name="assign_date" id="assign_date">
<input type="hidden" name="eng_mem_no" id="eng_mem_no">
<input type="hidden" name="consult_dt" id="consult_dt" value="${inputParam.s_current_dt}">
<input type="hidden" name="visit_dt" id="visit_dt">
<input type="hidden" name="service_mem_hp_no" id="service_mem_hp_no">
<input type="hidden" name="sale_mem_hp_no" id="sale_mem_hp_no">
<input type="hidden" name="reserve_sms_send_target_yn" id="reserve_sms_send_target_yn" value="N">
<input type="hidden" name="reserve_sms_send_yn" id="reserve_sms_send_yn" value="N">
<input type="hidden" name="reserve_sms_send_date" id="reserve_sms_send_date">
<input type="hidden" name="reserve_n" id="reserve_n" value="N">
<input type="hidden" id="__s_reg_type" name="__s_reg_type" value="I">
<input type="hidden" id="__s_menu_type" name="__s_menu_type" value="J">
<input type="hidden" id="job_dt" name="job_dt" value="${inputParam.s_current_dt}">
<input type="hidden" id="cap_use_yn" name="cap_use_yn">
<input type="hidden" id="cap_check_yn" name="cap_check_yn" value="Y">
<input type="hidden" id="job_st_dt" name="job_st_dt">
<input type="hidden" id="page_type" name="page_type" value="JOB_REPORT">
<input type="hidden" id="svc_travel_expense_hour" name="svc_travel_expense_hour" value="${bean.code_v1}">
<input type="hidden" id="s_job_report_no" name="s_job_report_no">
<input type="hidden" id="sar_error_no" name="sar_error_no" value="${inputParam.sar_error_no}">
<input type="hidden" id="cust_grade_hand_cd_str" name="cust_grade_hand_cd_str">
<input type="hidden" id="self_assign_no" name="self_assign_no" value="${inputParam.s_self_assign_no}">
<input type="hidden" id="reserve_repair_st_ti" name="reserve_repair_st_ti" value="">
<input type="hidden" id="c_job_request_seq" name="c_job_request_seq" value="">

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
							<span class="condition-item mr5">상태 : 작성중</span>
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
								<col width="60px">
								<col width="190px">
								<col width="60px">
								<col width="190px">
								<col width="60px">
								<col width="150px">
							</colgroup>
							<tbody>
							<tr>
								<th class="text-right essential-item">차대번호</th>
								<td>
									<div class="form-row inline-pd pr">
										<div class="col-8">
											<div class="input-group">
												<input type="text" id="body_no" name="body_no" class="form-control border-right-0 essential-bg" value="${rfqRepair.machine_name}" readonly="readonly" required="required" alt="차대번호">
												<button type="button" class="btn btn-icon btn-primary-gra" disabled onclick="javascript:selectMachineSeq();" ><i class="material-iconssearch"></i></button>
											</div>
										</div>
										<div class="col-4">
											<jsp:include page="/WEB-INF/jsp/common/commonMachineJob.jsp">
												<jsp:param name="li_machine_type" value="__machine_detail#__repair_history#__as_todo#__campaign#__work_db"/>
											</jsp:include>
										</div>
									</div>
								</td>
								<th class="text-right">엔진모델1</th>
								<td>
									<input type="text" id="engine_model_1" name="engine_model_1" class="form-control" readonly="readonly" value="${rfqRepair.engine_model_1}">
								</td>
								<th class="text-right">CAP<i class="material-iconserror font-16" style="vertical-align: middle;" onmouseover="javascript:show('help_operation')" onmouseout="javascript:hide('help_operation')"></i></th>
								<div class="con-info" id="help_operation" style="max-height: 500px; top: 30%; left: 70%; width: 230px; display: none;">
									<ul class="">
										<ol style="color: #666;">&nbsp;※ CAP적용/미적용은 장비대장에서 처리</ol>
									</ul>
								</div>
								<td>
									<div class="form-row inline-pd">
										<div class="col-7">
											<span id="cap"></span>
										</div>
										<div class="col-5 text-right">
											<button type="button" class="btn btn-primary-gra" id="cap_log" onclick="javascript:goCapLog();">CAP이력</button>
										</div>
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right">장비모델</th>
								<td>
									<input type="text" class="form-control" readonly="readonly" id="maker_name" name="maker_name" value="${rfqRepair.maker_name}">
								</td>
								<th class="text-right">엔진번호1</th>
								<td>
									<input type="text" class="form-control" id="engine_no_1" name="engine_no_1" readonly="readonly" value="${rfqRepair.engine_no_1}">
								</td>
								<th class="text-right">CAP회차</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width33px">
											현재
										</div>
										<div class="col width22px">
											<input type="text" id="cap_cnt" name="cap_cnt" class="form-control" readonly="readonly">
										</div>
										<div class="col width16px">
											차,
										</div>
										<div class="col width33px pl5">
											다음
										</div>
										<div class="col width22px">
											<input type="text" id="next_cap_cnt" name="next_cap_cnt" class="form-control" readonly="readonly">
										</div>
										<div class="col width16px">
											차
										</div>
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right">출하일자</th>
								<td>
									<input type="text" id="out_dt" name="out_dt" class="form-control width120px" readonly="readonly" dateformat="yyyy-MM-dd">
								</td>
								<th class="text-right">가동시간</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width70px">
											<input type="text" id="op_hour" name="op_hour" class="form-control text-right">
										</div>
										<div class="col width33px">
											hr
										</div>
									</div>
								</td>
								<th class="text-right">CAP예정일자</th>
								<td>
									<div class="input-group width120px">
										<input type="text" class="form-control border-right-0 calDate" id="cap_plan_dt" name="cap_plan_dt" dateFormat="yyyy-MM-dd" disabled="disabled">
									</div>
								</td>
							</tr>
							</tbody>
						</table>
					</div>
					<!-- /1. 장비정보 -->
					<!-- 2. 고객정보 -->
					<div class="col-6">
						<table id="cust_info" class="table-border mt5">
							<colgroup>
								<col width="80px">
								<col width="190px">
								<col width="120px">
								<col width="170px">
								<col width="120px">
								<col width="180px">
							</colgroup>
							<tbody id="tbody">
							<tr>
								<th class="text-right essential-item">차주명</th>
								<td>
									<div class="form-row inline-pd pr">
										<div class="col-6">
											<div class="input-group">
												<input type="text" id="cust_name" name="cust_name" class="form-control essential-bg" readonly="readonly" required="required" alt="차주명">
											</div>
										</div>
										<div class="col-3">
											<jsp:include page="/WEB-INF/jsp/common/commonCustJob.jsp">
												<jsp:param name="li_type" value="__cust_dtl#__ledger#__visit_history#__as_call#__check_required"/>
											</jsp:include>
										</div>
									</div>
								</td>
								<th class="text-right">업체명</th>
								<td>
									<input type="text" id="breg_name" name="breg_name" class="form-control" readonly="readonly">
								</td>
								<th class="text-right">대표자</th>
								<td>
									<input type="text" id="breg_rep_name" name="breg_rep_name" class="form-control width120px" readonly="readonly">
								</td>
							</tr>
							<tr>
								<th class="text-right">휴대폰</th>
								<td>
									<div class="input-group width140px">
										<input type="text" id="hp_no" name="hp_no" class="form-control border-right-0" format="phone" readonly="readonly">
										<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSendSms('cust');"><i class="material-iconsforum"></i></button>
									</div>
								</td>
								<th class="text-right">휴대폰(장비관리자)</th>
								<td>
									<div class="input-group width120px">
										<input type="text" id="mng_hp_no" name="mng_hp_no" class="form-control border-right-0" readonly="readonly">
										<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSendSms('mng');"><i class="material-iconsforum"></i></button>
									</div>
								</td>
								<th class="text-right">휴대폰(장비운영자)</th>
								<td>
									<div class="input-group width120px">
										<input type="text" id="driver_hp_no" name="driver_hp_no" class="form-control border-right-0" readonly="readonly">
										<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSendSms('driver');"><i class="material-iconsforum"></i></button>
									</div>
								</td>
							</tr>
							<tr>
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
								<th class="text-right">쿠폰잔액/미수</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width80px">
											<input type="text" id="di_balance_amt" name="di_balance_amt" class="form-control text-right" format="decimal" readonly="readonly">
										</div>&nbsp;/&nbsp;
										<div class="col width80px">
											<input type="text" style="color:red" id="misu_amt" name="misu_amt" class="form-control text-right" format="decimal" readonly="readonly">
										</div>
									</div>
								</td>
							</tr>
							</tbody>
						</table>
					</div>
					<!-- /2. 고객정보 -->
				</div>
				<!-- /상단 폼테이블 -->
				<div class="row mt10">
					<div class="col-6">
						<div class="title-wrap">
							<div class="left">
								<h4>정비접수</h4>
							</div>
						</div>
						<!-- 3. 정비접수 -->
						<table class="table-border mt5">
							<colgroup>
								<col width="60px">
								<col width="190px">
								<col width="60px">
								<col width="190px">
								<col width="60px">
								<col width="150px">
							</colgroup>
							<tbody>
							<tr>
								<th class="text-right essential-item">센터</th>
								<td>
									<div class="input-group">
										<input type="text" id="org_name" name="org_name" class="form-control border-right-0 width100px essential-bg" readonly="readonly" required="required" alt="센터" value="${SecureUser.org_name}">
										<button type="button" class="btn btn-icon btn-primary-gra" disabled onclick="javascript:openOrgMapCenterPanel('setOrgMapCenterPanel');"><i class="material-iconssearch"></i></button>
									</div>
								</td>
								<th class="text-right">접수번호</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col-auto">
											<input type="text" id="job_report_no" name="job_report_no" class="form-control width120px" readonly="readonly" value="${inputParam.s_current_dt}">
										</div>
									</div>
								</td>
								<th class="text-right">입고일자</th>
								<td>
									<div class="input-group width120px">
										<input type="text" class="form-control border-right-0 calDate" id="in_dt" name="in_dt" dateFormat="yyyy-MM-dd" value="${rfqRepair.in_dt}" onchange="javascript:fnChangeInDt()">
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right">접수자</th>
								<td>
									<input type="text" class="form-control width120px" name="reg_mem_name" id="reg_mem_name" readonly="readonly" value="${SecureUser.user_name}">
								</td>
								<th class="text-right essential-item">접수구분</th>
								<td>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="receipt_type_rt_r" name="receipt_type_rt" value="R" onclick="javascript:goTypeRt();" required="required" alt="접수구분">
										<label class="form-check-label" for="receipt_type_rt_r">사전</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="receipt_type_rt_t"  name="receipt_type_rt" value="T" onclick="javascript:goTypeRt();" required="required" alt="접수구분">
										<label class="form-check-label" for="receipt_type_rt_t">당일</label>
									</div>
                  <div class="form-check form-check-inline">
                    <input class="form-check-input" type="radio" id="receipt_type_rt_a"  name="receipt_type_rt" value="A" onclick="javascript:goTypeRt();" required="required" alt="접수구분" disabled>
                    <label class="form-check-label" for="receipt_type_rt_a">APP</label>
                  </div>
								</td>
								<th class="text-right essential-item">정비종류</th>
								<td>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="job_case_ti_i" name="job_case_ti" value="I" onclick="javascript:fnJobCaseTi()" <c:if test="${rfqRepair.job_case_ti eq 'I'}">checked="checked"</c:if> required="required" alt="정비종류">
										<label class="form-check-label" for="job_case_ti_i">입고</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="job_case_ti_t"  name="job_case_ti" value="T" onclick="javascript:fnJobCaseTi()" <c:if test="${rfqRepair.job_case_ti eq 'T'}">checked="checked"</c:if> required="required" alt="정비종류">
										<label class="form-check-label" for="job_case_ti_t">출장</label>
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right">배정</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-auto">
											<div class="input-group">
												<input type="text" id="eng_mem_name" name="eng_mem_name" class="form-control border-right-0 width100px" readonly="readonly">
												<button type="button" class="btn btn-icon btn-primary-gra" disabled="disabled" onclick="javascript:openMemberOrgPanel('setMemberOrgMapPanel', 'N');"><i class="material-iconssearch"></i></button>
											</div>
										</div>
									</div>
								</td>
								<th class="text-right essential-item">정비구분</th>
								<td colspan="3">
									<c:forEach items="${codeMap['JOB_TYPE']}" var="item">
										<div class="form-check form-check-inline v-align-middle">
											<input type="radio" id="${item.code_value}" name="job_type_cd" class="form-check-input" value="${item.code_value}" required="required" alt="정비구분" onchange="javascript:onChangeJobTypeCd();">
											<label class="form-check-label" for="${item.code_value}">${item.code_name}</label>
										</div>
									</c:forEach>
                  <span class="form-check form-check-inline v-align-middle">ㅣ</span>
                  <c:forEach items="${codeMap['JOB_TYPE2']}" var="item">
                    <div class="form-check form-check-inline v-align-middle">
                      <input type="radio" id="${item.code_value}" name="job_type2_cd" class="form-check-input" value="${item.code_value}" required="required" alt="정비구분2">
                      <label class="form-check-label" for="${item.code_value}">${item.code_name}</label>
                    </div>
                  </c:forEach>
								</td>
                <%-- 자동화 개발건 - 제거 --%>
<%--								<th class="text-right">유/무상</th>--%>
<%--								<td>--%>
<%--									<div class="form-check form-check-inline">--%>
<%--										<input class="form-check-input" type="radio" id="cost_yn_y" name="cost_yn" value="Y" <c:if test="${rfqRepair.cost_yn eq 'Y'}">checked="checked"</c:if> alt="유/무상">--%>
<%--										<label class="form-check-label" for="cost_yn_y">유상</label>--%>
<%--									</div>--%>
<%--									<div class="form-check form-check-inline">--%>
<%--										<input class="form-check-input" type="radio" id="cost_yn_n"  name="cost_yn" value="N" <c:if test="${rfqRepair.cost_yn eq 'N'}">checked="checked"</c:if> alt="유/무상">--%>
<%--										<label class="form-check-label" for="cost_yn_n">무상</label>--%>
<%--									</div>--%>
<%--								</td>--%>
							</tr>
							</tbody>
						</table>
						<!-- /3. 정비접수 -->
					</div>
					<div class="col-6">
						<div class="title-wrap">
							<div class="left">
								<h4>접수상세</h4>
							</div>
							<div calss="btn-group">
								<button type="button" id="sar_oper_btn" style="display : none;" class="btn btn-primary-gra" onclick="javascript:goSarOperationMap('OPERATION');">SA-R 운행정보</button>
								<button type="button" class="btn btn-default" onclick="javascript:goMap();"><i class="material-iconsplace text-default"></i>지도보기</button>
							</div>
						</div>
						<!-- 4. 접수상세 -->
						<table class="table-border mt5">
							<colgroup>
								<col width="75px">
								<col width="250px">
								<col width="90px">
								<col width="180px">
								<col width="95px">
								<col width="150px">
							</colgroup>
							<tbody>
							<tr>
								<th class="text-right">정비예약시간</th>
								<td>
									<div class="form-row">
										<div class="col-4">
											<select class="form-control" id="reserve_repair_ti" name="reserve_repair_ti" onchange="javascript:fnChangeInDt()">
<%--													<option value="0830" <c:if test="${rfqRepair.reserve_repair_ti eq '0830'}">selected="selected"</c:if>>08:30</option>--%>
												<c:forEach var="hr" varStatus="i" begin="6" end="23" step="1">
													<c:forEach var="min" varStatus="j" begin="0" end="1">
													<option value="<c:if test="${hr < 10}">0</c:if><c:out value="${hr}"/><c:out value="${min eq 0 ? '00' : '30'}"/>"
<%--															<c:if test="${fn:substring(rfqRepair.reserve_repair_ti,0,2) eq (hr < 10 ? '0' + hr : hr) and fn:substring(rfqRepair.reserve_repair_ti,2,4) eq (min eq 0 ? '00' : '30')}">selected="selected"</c:if>>--%>
															<c:if test="${fn:substring(selfAssign.reserve_repair_st_ti,0,2) eq (hr < 10 ? '0' + hr : hr) and fn:substring(selfAssign.reserve_repair_st_ti,2,4) eq (min eq 0 ? '00' : '30')}">selected="selected"</c:if>>
														<c:if test="${hr < 10}">0</c:if><c:out value="${hr}"/>:<c:out value="${min eq 0 ? '00' : '30'}"/>
													</option>
													</c:forEach>
												</c:forEach>
<%--													<option value="1800" <c:if test="${rfqRepair.reserve_repair_ti eq '1800'}">selected="selected"</c:if>>18:00</option>--%>
											</select>
										</div>
										~
										<div class="col-4">
											<select class="form-control" id="reserve_repair_ed_ti" name="reserve_repair_ed_ti" onchange="javascript:fnChangeInDt()">
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
										<div class="col-4">
											<button type="button" class="btn btn-default" onclick="javascript:goSendSmsReserve();" disabled>예약확정</button>
										</div>
										<div class="col-4" id="reserve_confirm_msg">
										</div>
									</div>
								</td>
								<th class="text-right">예상규정시간</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" id="except_repair_hour" name="except_repair_hour" class="form-control text-right" readonly="readonly" value="${rfqRepair.except_repair_hour}">
										</div>
										<div class="col width33px">hr</div>
									</div>
								</td>
								<th class="text-right">렌탈수리청구고객</th>
								<td>
									<div class="form-row inline-pd pr">
										<div class="col-9">
											<div class="input-group">
												<input type="text" id="rental_cust_name" name="rental_cust_name" class="form-control border-right-0" readonly="readonly" alt="렌탈고객" value="${rfqRepair.rental_cust_name}">
												<input type="hidden" id="rental_cust_no" name="rental_cust_no" value="${rfqRepair.rental_cust_no}">
												<button type="button" id="rental_cust_btn" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchCustPanel('fnSetRentalCust');" disabled><i class="material-iconssearch"></i></button>
											</div>
										</div>
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right">출장지역</th>
								<td>
									<select id="svc_travel_expense" name="svc_travel_expense" class="form-control" disabled="disabled" onchange="javascript:fnSetSvcInfo();">
										<option value="">- 출장지역선택- </option>
										<c:forEach var="list" items="${list}">
											<option value="${list.svc_travel_info}" <c:if test="${list.svc_travel_info.split(\"#\")[0] == rfqRepair.svc_travel_expense_seq}">selected="selected"</c:if> >${list.area_name}</option>
										</c:forEach>
									</select>
								</td>
								<th class="text-right">출장위치</th>
								<td>
									<input type="text" id="travel_area_name" name="travel_area_name" class="form-control" value="${rfqRepair.travel_area_name}">
								</td>
								<th class="text-right">출장거리</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" id="travel_km" name="travel_km" class="form-control text-right" readonly="readonly" value="${rfqRepair.travel_km}">
										</div>
										<div class="col width33px">km</div>
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right">출장비참조</th>
								<td colspan="3">
									<div class="form-row inline-pd widthfix">
										<div class="col-auto">
											거리
										</div>
										<div class="col-auto">
											<input type="text" id="distance_min" name="distance_min" class="form-control text-right width35px" placeholder="From" datatype="int" format="decimal" value="${rfqRepair.distance_min}">
										</div>
										<div class="col-auto">
											km
										</div>
										<div class="col-auto">
											<input type="text" id="distance_max" name="distance_max" class="form-control text-right width35px" placeholder="To" datatype="int" format="decimal" value="${rfqRepair.distance_max}">
										</div>
										<div class="col width30px">
											km,
										</div>
										<div class="col-auto">
											이동시간
										</div>
										<div class="col-auto">
											<input type="text" id="travel_hour" name="travel_hour" class="form-control text-right width40px" format="decimal"  onchange="javascript:fnCalcPlanTravelPrice();">
										</div>
										<div class="col-auto">
											hr,
										</div>
										<div class="col-auto">
											시간당 금액
										</div>
										<div class="col-auto">
											<input type="text" id="travel_hour_price" name="travel_hour_price" class="form-control text-right width60px" format="decimal" readonly="readonly">
										</div>
										<div class="col-auto">
											원,
										</div>
										<div class="col-auto">
											총 금액
										</div>
										<div class="col-auto">
											<input type="text" id="tot_travel_hour_price" name="tot_travel_hour_price" class="form-control text-right width70px" format="decimal" readonly="readonly">
										</div>
										<div class="col-auto">
											원
										</div>
									</div>
								</td>
								<th class="text-right">출장비용</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" id="travel_expense" name="travel_expense" class="form-control text-right" datatype="int" format="decimal" onchange="javascript:fnChangeTravelPrice();" value="${rfqRepair.travel_expense}">
										</div>
										<div class="col width16px mr5">원</div>
										<input type="hidden" id="travel_discount_amt" name="travel_discount_amt" class="form-control text-right" datatype="int" format="decimal" onchange="javascript:fnChangeTravelPrice();" value="${rfqRepair.travel_discount_amt}">
										<input type="hidden" id="travel_final_expense" name="travel_final_expense" class="form-control text-right" datatype="int" format="decimal" value="${rfqRepair.travel_final_expense}">
									</div>
								</td>
							</tr>
							</tbody>
						</table>
						<!-- /4. 접수상세 -->
					</div>
				</div>
			</div>
			<!-- 하단 폼테이블 -->
			<div class="row mt10">
				<!-- 하단좌측 폼테이블 -->
				<div class="col-6">
					<!-- 4. 작업지시 -->
					<div class="title-wrap">
						<div class="left">
							<h4>상담과 점검/정비</h4>
							<i class="material-iconserror font-16" style="vertical-align: middle;" onmouseover="javascript:show('help_order')" onmouseout="javascript:hide('help_order')"></i>
							<div class="con-info" id="help_order" style="max-height: 500px; top: 3%; left: 10%; width: 300px; display: none;">
								<ul class="">
									<ol style="color: #666;">&nbsp;※ 상담과 점검/정비 단축키 : Shift + Space</ol>
								</ul>
							</div>
						</div>
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_M"/></jsp:include>
						</div>
					</div>
					<div id="auiGridReportOrder" style="margin-top: 5px; height: 620px;"></div>
					<!-- /4. 작업지시 -->
					<!-- 8. 메모 -->
					<div class="title-wrap mt10">
						<h4>메모</h4>
					</div>
					<textarea class="form-control" id="job_text" name="job_text" style="margin-top: 5px; height: 160px;" maxlength="2000"></textarea>
					<!-- /8. 메모 -->
				</div>
				<!-- /하단좌측 폼테이블 -->
				<!-- 하단우측 폼테이블 -->
				<div class="col-6">
					<!-- 5. 부품목록 -->
					<div class="title-wrap">
						<div class="left">
							<h4>부품목록</h4>
							<i class="material-iconserror font-16" style="vertical-align: middle;" onmouseover="javascript:show('help_part')" onmouseout="javascript:hide('help_part')"></i>
							<div class="con-info" id="help_part" style="max-height: 500px; top: 3%; left: 5%; width: 400px; display: none;">
								<ul class="">
									<ol style="color: #666;">&nbsp;※ 부품 단축키 : Shift + Space || ※ 삭제 단축키 : Ctrl + Space</ol>
								</ul>
							</div>
						</div>
						<div>
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_L"/></jsp:include>
						</div>
					</div>
					<div id="auiGridReportPart" style="margin-top: 5px; height: 400px;"></div>
					<!-- /5. 부품목록 -->
					<!-- 6. 정비작업 -->
					<div class="title-wrap mt10">
						<div class="left">
							<h4>정비작업</h4>
						</div>
						<div calss="btn-group">
							<div class="right dpf">
								<span class="mr3">정비시간</span>
								<input type="text" id="work_ti" name="work_ti" class="form-control text-right width60px mr3" readonly="readonly">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
							</div>
						</div>
					</div>
					<div id="auiGridReportWork" style="margin-top: 5px; height: 130px;"></div>
					<!-- /6. 정비작업 -->
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
										<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:fnAddFile('R');">파일찾기</button>
									</div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">정비지시서</th>
							<td>
								<div class="table-attfile att_file_divJ" style="width:100%;">
									<div class="table-attfile" style="float:left">
										<button type="button" class="btn btn-primary-gra mr5" onclick="javascript:fnShowFile('J');">파일 이미지보기</button>
										<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:fnAddFile('J');">파일찾기</button>
									</div>
								</div>
							</td>
						</tr>
						</tbody>
					</table>
					<!-- 7. 비용 -->
					<div class="title-wrap mt10">
						<h4>비용</h4>
					</div>
					<table class="table-border doc-table mt5">
						<colgroup>
							<col width="10%">
							<col width="18%">
							<col width="18%">
							<col width="18%">
							<col width="18%">
							<col width="18%">
						</colgroup>
						<thead>
						<tr>
							<th class="title-bg">구분</th>
							<th class="title-bg">출장비</th>
							<th class="title-bg">공임</th>
							<th class="title-bg">부품</th>
							<th class="title-bg">합계</th>
							<th class="title-bg">총금액<br>(VAT포함)</th>
						</tr>
						</thead>
						<tbody>
						<tr>
							<th>예상</th>
							<td>
								<input type="text" class="form-control text-right" id="plan_travel_expense" name="plan_travel_expense" format="decimal" readonly="readonly">
							</td>
							<td>
								<input type="text" class="form-control text-right" id="plan_work_total_amt" name="plan_work_total_amt" format="decimal" readonly="readonly">
							</td>
							<td>
								<input type="text" class="form-control text-right" id="plan_part_total_amt" name="plan_part_total_amt" format="decimal" readonly="readonly">
							</td>
							<td>
								<input type="text" class="form-control text-right" id="plan_total_amt" name="plan_total_amt" format="decimal" readonly="readonly">
							</td>
							<td>
								<input type="text" class="form-control text-right" id="plan_total_vat_amt" name="plan_total_vat_amt" format="decimal" readonly="readonly">
							</td>
						</tr>
						<tr>
							<th>최종</th>
							<td>
								<input type="text" class="form-control text-right" id="final_travel_expense" name="final_travel_expense" format="decimal" readonly="readonly">
							</td>
							<td>
								<input type="text" class="form-control text-right" id="work_total_amt" name="work_total_amt" format="decimal" readonly="readonly">
							</td>
							<td>
								<input type="text" class="form-control text-right" id="part_total_amt" name="part_total_amt" format="decimal" readonly="readonly">
							</td>
							<td>
								<input type="text" class="form-control text-right" id="total_amt" name="total_amt" format="decimal" readonly="readonly">
							</td>
							<td>
								<input type="text" class="form-control text-right" id="final_total_vat_amt" name="final_total_vat_amt" format="decimal" readonly="readonly">
							</td>
						</tr>
						</tbody>
					</table>
					<!-- /7. 비용 -->
				</div>
				<!-- /하단우측 폼테이블 -->
			</div>
			<!-- 하단 폼테이블 -->
			<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt10">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
				<!-- /그리드 서머리, 컨트롤 영역 -->
		</div>
		<!-- /contents 전체 영역 -->
	</div>
</form>
</body>
</html>
