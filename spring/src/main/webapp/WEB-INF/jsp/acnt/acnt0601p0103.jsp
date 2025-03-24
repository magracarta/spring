<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 기준정보 > 정보수정 > 인사고과정보 > 실적평가
-- 작성자 : 성현우
-- 최초 작성일 : 2020-06-01 10:03:57
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<style>
		.pointer {
			text-decoration: underline;
		}
	</style>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		/**
		 * 저장 가능 여부
		 * @type {boolean}
		 */
		var canModify = "Y" === "${can_modify_yn}";


		$(document).ready(function () {
			if ("${alert_msg}") {
				alert("${alert_msg}");
			}

			fnSetModify();
			fnCalcTotalProfitAmt();
			['', 'c_', 'p_'].forEach(prefix => fnCalcTimeRate(prefix));
			fnSetStat();

			// Q&A 12133 매니저가 평가시 노출X  210827 김상덕
			if ('${page.fnc.F02081_002}' == "Y") {
				$(".currentYearDiv").remove(); // 당년지출 계
			}
		});

		// 수정 가능 여부에 따른 세팅
		function fnSetModify() {
			if (canModify) {
				$("#_goSave").removeClass("dpn"); // 임시저장 버튼 Show
				$("#_goProcessConfirm").removeClass("dpn"); // 작성완료 버튼 Show
			} else {
				$("#_goSave").addClass("dpn"); // 임시저장 버튼 Hide
				$("#_goProcessConfirm").addClass("dpn"); // 작성완료 버튼 Hide
			}

			// 차년목표 readonly 처리 여부
			$("#call_cnt").prop("readonly", !canModify); // 전화건수
			$("#cost_cnt").prop("readonly", !canModify); // 유상건수
			$("#free_cnt").prop("readonly", !canModify); // 무상건수
			$("#repair_cnt").prop("readonly", !canModify); // 정비건수
			$("#rework_cnt").prop("readonly", !canModify); // 재정비건수
			$("#valid_active_hour").prop("readonly", !canModify); // 유효활동시간
			$("#work_hour").prop("readonly", !canModify); // 근무시간

			$("#new_mch_sale_profit_amt").prop("readonly", !canModify); // 신차판매수익
			$("#part_sale_profit_amt").prop("readonly", !canModify); // 부품 판매 순익
			$("#old_mch_sale_profit_amt").prop("readonly", !canModify); // 중고판매수익

			$("#cost_move_hour").prop("readonly", !canModify); // 유상이동H
			$("#cost_repair_hour").prop("readonly", !canModify); // 유상정비H
			$("#cost_repair_std_hour").prop("readonly", !canModify); // 유상규정H
			$("#cost_part_amt").prop("readonly", !canModify); // 유상부품
			$("#cost_travel_amt").prop("readonly", !canModify); // 유상출장
			$("#cost_work_amt").prop("readonly", !canModify); // 유상공임

			$("#free_move_hour").prop("readonly", !canModify); // 무상이동H
			$("#free_repair_hour").prop("readonly", !canModify); // 무상정비H
			$("#free_repair_std_hour").prop("readonly", !canModify); // 무상규정H
			$("#free_part_amt").prop("readonly", !canModify); // 무상부품
			$("#free_out_amt").prop("readonly", !canModify); // 무상지출총계
			$("#free_svc_amt").prop("readonly", !canModify); // 무상서비스비용

			$("#rental_hour").prop("readonly", !canModify); // 렌탈시간
			$("#rental_amt").prop("readonly", !canModify); // 렌탈료
			$("#rental_mch_reduce_amt").prop("readonly", !canModify); // 렌탈감가
		}

		// 조회
		function goSearch() {
			var memNo = $M.getValue("mem_no");
			var typeCd = 0;
			var url = this_page + "/" + memNo + "/" + typeCd;

			var params = {
				"s_mem_no": memNo,
				"s_mbo_year": $M.getValue("s_mbo_year"),
			};

			$M.goNextPage(url, $M.toGetParam(params), {method: "GET"});
		}

		// 작성완료
		function goProcessConfirm() {
			goSave(true);
		}

		/**
		 * 저장
		 * @param {boolean} isProcessConfirm 작성완료 여부 false 이면 임시저장
		 */
		function goSave(isProcessConfirm) {
			if (!canModify) return false;

			var msg = "";
			// 작성완료
			if (isProcessConfirm) {
				if ($M.validation(document.main_form) == false) {
					return;
				}
				msg = "작성완료 처리를 하시겠습니까?";
			} else {
				msg = "저장 하시겠습니까?";
			}

			if (!confirm(msg)) return false;

			$M.setValue("write_end_yn", isProcessConfirm ? "Y" : "N");
			var frm = $M.toValueForm(document.main_form);

			$M.goNextPageAjax(this_page + "/save", $M.toValueForm(frm), {method: 'POST'},
					function (result) {
						if (result.success) {
							window.location.reload();
						}
					}
			);
		}

		// 닫기
		function fnClose() {
			top.window.close();
		}

		// 당년 본인 지출계 세팅
		function fnSetStat() {
			// (Q&A 13199) 수익률, 성장률 211129 김상덕
			// 당년지출 합계
			var currentAmt = $M.toNum("${memSalary.total_amt}");
			// 과년 총 업무수익
			var pastProfitAmt = $M.toNum("${pastYear.total_profit_amt}");
			// 당년 총 업무수익
			var currentProfitAmt = $M.toNum("${currentYear.total_profit_amt}");
			// 차년 총 목표수익
			var nextProfitAmt = $M.toNum($M.getValue("total_profit_amt"));

			// 지출 대비 순익률
			$M.setValue("profit_rate", currentProfitAmt / currentAmt * 100 );
			// 과년도 대비 당년도 성장률
			$M.setValue("now_grow_rate", (currentProfitAmt - pastProfitAmt) / pastProfitAmt * 100);
			// 당년도 대비 차년도 목표 성장률
			$M.setValue("next_grow_rate", (nextProfitAmt - currentProfitAmt) / currentProfitAmt * 100);
		}

		// 차년목표 업무량집계 '전체' 자동계산
		function fnCalcTotalCnt() {
			// 전화 건수
			var callCnt = $M.toNum($M.getValue("call_cnt"));
			// 유상 건수
			var costCnt = $M.toNum($M.getValue("cost_cnt"));
			// 무상 건수
			var freeCnt = $M.toNum($M.getValue("free_cnt"));
			// 정비 건수 (유상 + 무상)
			var repairCnt = costCnt + freeCnt;
			// 전체 건수 (전화 + 유상 + 무상)
			var totalCnt = callCnt + repairCnt;

			// 전체 건수 Setting
			$M.setValue("total_cnt", totalCnt);
		}

		// 차년목표 유상정비순익 자동계산<br>(부품비용 * 15% + 출장비 + 공임비)
		function fnCalcCostProfitAmt() {
			// 유상정비수익합계
			var costWorkProfitAmt = 0;
			// 유상부품비용
			var costPartAmt = $M.toNum($M.getValue("cost_part_amt"));
			// 유상출장비용
			var costTravelAmt = $M.toNum($M.getValue("cost_travel_amt"));
			// 유상정비공임
			var costWorkAmt = $M.toNum($M.getValue("cost_work_amt"));

			costWorkProfitAmt = Math.round(costPartAmt * (15 / 100)) + costTravelAmt + costWorkAmt;
			// 유상정비수익합계 Setting
			$M.setValue("cost_work_profit_amt", costWorkProfitAmt);

			// 차년 총 목표수익
			fnCalcTotalProfitAmt();
		}

		// 차년목표 무상정비매출 자동 계산<br>(부품비(F)+지출총계(J0)+서비스비용(J1+J2+J3))
		function fnCalcFreeSalesAmt() {
			// 무상 부품비
			var freePartAmt = $M.toNum($M.getValue("free_part_amt"));
			// 지출총계
			var freeOutAmt = $M.toNum($M.getValue("free_out_amt"));
			// 서비스비용
			var freeServiceAmt = $M.toNum($M.getValue("free_svc_amt"));

			$M.setValue("free_repair_sale_amt", freePartAmt + freeOutAmt + freeServiceAmt);

			fnCalcTotalProfitAmt();
		}

		// 차년목표 렌탈순익 자동계산<br>(렌탈비용 - 렌탈장비감가)
		function fnCalcRentalProfitAmt() {
			// 렌탈순익
			var rentalProfitAmt = 0;
			// 렌탈비용
			var rentalAmt = $M.toNum($M.getValue("rental_amt"));
			// 렌탈장비감가
			var rentalMchReduceAmt = $M.toNum($M.getValue("rental_mch_reduce_amt"));

			rentalProfitAmt = rentalAmt - rentalMchReduceAmt;
			// 렌탈업무수익합계 Setting
			$M.setValue("rental_profit_amt", rentalProfitAmt);

			// 차년 총 목표수익
			fnCalcTotalProfitAmt();
		}

		/**
		 * 차년 총 목표수익 자동계산<br>
		 * (유상정비 수익 + 무상정비매출 + 부품판매 순익 + 중고 판매 순익 + 렌탈 수익 + 신차판매 수익)
		 */
		function fnCalcTotalProfitAmt() {
			// 차년 총 목표 수익
			var totalProfitAmt = 0;
			// 유상정비 순익
			var costWorkProfitAmt = $M.toNum($M.getValue("cost_work_profit_amt"));
			// 무상정비매출
			var freeSaleAmt = $M.toNum($M.getValue("free_repair_sale_amt"));
			// 렌탈 순익
			var rentalProfitAmt = $M.toNum($M.getValue("rental_profit_amt"));

			// 신차판매 순익
			var newMchSaleProfitAmt = $M.toNum($M.getValue("new_mch_sale_profit_amt"));
			// 부품판매 순익
			var partSaleProfitAmt = $M.toNum($M.getValue("part_sale_profit_amt"));
			// 중고장비판매 수익
			var oldMchSaleProfitAmt = $M.toNum($M.getValue("old_mch_sale_profit_amt"));

			totalProfitAmt = costWorkProfitAmt + freeSaleAmt + partSaleProfitAmt + oldMchSaleProfitAmt + rentalProfitAmt + newMchSaleProfitAmt;
			// 차년 총 목표수익 Setting
			$M.setValue("total_profit_amt", totalProfitAmt);
		}

		/**
		 * 업무량 집계 비율 자동계산
		 * @param prefix 과년: 'p_' / 당년: 'c_' / 차년목표 : ''
		 */
		function fnCalcTimeRate(prefix) {
			var validHour = $M.toNum($M.getValue(String(prefix).concat("valid_active_hour"))); // 유효활동시간
			var workHour = $M.toNum($M.getValue(String(prefix).concat("work_hour"))); // 근무시간
			var timeRate = validHour / workHour;

			// 비율 = 유효활동시간 / 근무시간
			if (!isNaN(timeRate) && timeRate !== Infinity) {
				$M.setValue(String(prefix).concat("time_rate"), Math.round(timeRate * 100) + "%");
			}
		}


		// ######## 팝업 호출 함수 START ########

        /**
         * 메이커별 건수 팝업 호출<br>
         * '전화', '유상', '무상', '전체' 클릭 시 호출
         * @param yearType P : 과년 / C : 당년
         * @param colName column name
         */
        function goPopupMakerCnt(yearType, colName) {
            var startDt = yearType == "P" ? $M.removeHyphenFormat('${dateMap.past_start_dt}') : $M.removeHyphenFormat('${dateMap.current_start_dt}');
			var endDt = yearType == "P" ? $M.removeHyphenFormat('${dateMap.past_end_dt}') : $M.removeHyphenFormat('${dateMap.current_end_dt}');

			var param = {
				"s_mem_no": $M.getValue("mem_no"),
				"s_start_dt" : startDt,
				"s_end_dt" : endDt,
                "col_name" : colName,
			};
            $M.goNextPage("/acnt/acnt0605p05", $M.toGetParam(param), {popupStatus: ""});
        }

        /**
         * 메이커별 정비시간 팝업 호출<br>
         * '이동H', '정비H', '규정H' 클릭 시 호출
         * @param yearType P : 과년 / C : 당년
         * @param colName column name
         */
        function goPopupMakerRepairHour(yearType, colName) {
            var startDt = yearType == "P" ? $M.removeHyphenFormat('${dateMap.past_start_dt}') : $M.removeHyphenFormat('${dateMap.current_start_dt}');
			var endDt = yearType == "P" ? $M.removeHyphenFormat('${dateMap.past_end_dt}') : $M.removeHyphenFormat('${dateMap.current_end_dt}');

            var param = {
				"s_mem_no": $M.getValue("mem_no"),
				"s_start_dt" : startDt,
				"s_end_dt" : endDt,
				"col_name" : colName,
                "s_amt_yn" : "N", // 메이커별 비용 여부
			};

            $M.goNextPage("/acnt/acnt0605p04", $M.toGetParam(param), {popupStatus: ""});
        }

        /**
         * 메이커별 비용 팝업 호출<br>
         * '부품', '출장', '공임', '지출총계', '서비스비용'
         * @param yearType P : 과년 / C : 당년
         * @param colName column name
         */
        function goPopupMakerCost(yearType, colName) {
            var startDt = yearType == "P" ? $M.removeHyphenFormat('${dateMap.past_start_dt}') : $M.removeHyphenFormat('${dateMap.current_start_dt}');
			var endDt = yearType == "P" ? $M.removeHyphenFormat('${dateMap.past_end_dt}') : $M.removeHyphenFormat('${dateMap.current_end_dt}');

            var param = {
				"s_mem_no": $M.getValue("mem_no"),
				"s_start_dt" : startDt,
				"s_end_dt" : endDt,
				"col_name" : colName,
				"s_amt_yn" : "Y", // 메이커별 비용 여부
			};
			$M.goNextPage("/acnt/acnt0605p04", $M.toGetParam(param), {popupStatus: ""});
        }

		/**
		 * 메이커별 정비시간 팝업 호출 - 당년
		 * @param paid P : 유상 / F : 무상
         * @deprecated
		 */
		function goRepairHourPopup(paid) {
			var startDt = $M.removeHyphenFormat('${dateMap.current_start_dt}');
			var endDt = $M.removeHyphenFormat('${dateMap.current_end_dt}');

			var param = {
				"s_mem_no": $M.getValue("mem_no"),
				"s_start_dt" : startDt,
				"s_end_dt" : endDt,
				"s_type": "M", // M 개인 , O 센터
				"s_cost_yn" : paid == "P" ? "Y" : "N"
			};

			$M.goNextPage("/acnt/acnt0605p04", $M.toGetParam(param), {popupStatus: ""});
		}
		
		// 메이커별 전화시간
		// function goCallHourPopup(st, ed) {
		// 	var param = {
		// 		"s_mem_no": $M.getValue("mem_no"),
		// 		"s_start_dt" : $M.removeHyphenFormat(st),
		// 		"s_end_dt" : $M.removeHyphenFormat(ed),
		// 		"s_type": "M", // M 개인 , O 센터
		// 	};
		// 	var popupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=400, height=400, left=0, top=0";
		// 	$M.goNextPage("/acnt/acnt0605p05", $M.toGetParam(param), {popupStatus: popupOption});
		// }
		
		<%--/**--%>
		<%-- * 메이커별 건수--%>
		<%-- * @param yearType P : 과년 / C : 당년--%>
		<%-- * @param colName t_job_as 테이블에서 조회할 컬럼명--%>
		<%-- */--%>
		<%--function goMakerCnt(yearType, colName) {--%>
		<%--	var startDt = "";--%>
		<%--	var endDt = "";--%>
		<%--	if (yearType == "P") {--%>
		<%--		startDt = $M.removeHyphenFormat('${dateMap.past_start_dt}');--%>
		<%--		endDt = $M.removeHyphenFormat('${dateMap.past_end_dt}');--%>
		<%--	} else {--%>
		<%--		startDt = $M.removeHyphenFormat('${dateMap.current_start_dt}');--%>
		<%--		endDt = $M.removeHyphenFormat('${dateMap.current_end_dt}');--%>
		<%--	}--%>
		<%--	var param = {--%>
		<%--		"s_mem_no": $M.getValue("mem_no"),--%>
		<%--		"s_start_dt" : startDt,--%>
		<%--		"s_end_dt" : endDt,--%>
		<%--		"s_type": "M", // M 개인 , O 센터--%>
		<%--		"col_name" : colName--%>
		<%--	};--%>
		<%--	var popupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=400, height=400, left=0, top=0";--%>
		<%--	$M.goNextPage("/acnt/acnt0605p05", $M.toGetParam(param), {popupStatus: popupOption});--%>
		<%--}--%>

		/**
		 * 메이커별 정비시간 팝업 호출
		 * @param yearType P : 과년 / C : 당년
		 * @param colName v_nas_repair 컬럼명
		 * @param costYn 결재유상여부 (if colName = appr_repair_hour)
         * @deprecated
		 */
		function goRepairHourMaker(yearType, colName, costYn) {
			var startDt = "";
			var endDt = "";
			if (yearType == "P") {
				startDt = $M.removeHyphenFormat('${dateMap.past_start_dt}');
				endDt = $M.removeHyphenFormat('${dateMap.past_end_dt}');
			} else {
				startDt = $M.removeHyphenFormat('${dateMap.current_start_dt}');
				endDt = $M.removeHyphenFormat('${dateMap.current_end_dt}');
			}
			var param = {
				"s_mem_no": $M.getValue("mem_no"),
				"s_start_dt" : startDt,
				"s_end_dt" : endDt,
				"s_type": "M", // M 개인 , O 센터
				"col_name" : colName,
				"s_cost_yn" : costYn,
			};
			$M.goNextPage("/acnt/acnt0605p04", $M.toGetParam(param), {popupStatus: ""});
		}
		
		/**
		 * 메이커별 비용 팝업 호출
		 * @param yearType P : 과년 / C : 당년
		 * @param colName cost_ : t_job_cost_amt / free_ : t_job_free_amt
         * @deprecated
		 */
		function goAmtMaker(yearType, colName) {
			var startDt = "";
			var endDt = "";
			if (yearType == "P") {
				startDt = $M.removeHyphenFormat('${dateMap.past_start_dt}');
				endDt = $M.removeHyphenFormat('${dateMap.past_end_dt}');
			} else {
				startDt = $M.removeHyphenFormat('${dateMap.current_start_dt}');
				endDt = $M.removeHyphenFormat('${dateMap.current_end_dt}');
			}
			var param = {
				"s_mem_no": $M.getValue("mem_no"),
				"s_start_dt" : startDt,
				"s_end_dt" : endDt,
				"col_name" : colName,
				"s_type": "M", // M 개인 , O 센터
				"s_amt_yn" : "Y", // 메이커별 비용 팝업 여부
			};
			$M.goNextPage("/acnt/acnt0605p04", $M.toGetParam(param), {popupStatus: ""});
		}
		
        /**
         * 신차판매수익 팝업 호출
         * @param yearType P : 과년 / C : 당년
         */
		function goMachineSalePopup(yearType) {
            var startDt = yearType == "P" ? $M.removeHyphenFormat('${dateMap.past_start_dt}') : $M.removeHyphenFormat('${dateMap.current_start_dt}');
			var endDt = yearType == "P" ? $M.removeHyphenFormat('${dateMap.past_end_dt}') : $M.removeHyphenFormat('${dateMap.current_end_dt}');
			var param = {
				"s_mem_no": $M.getValue("mem_no"),
				"s_start_dt" : startDt,
				"s_end_dt" : endDt,
				"s_type": "M", // M 개인 , O 센터
			};
			$M.goNextPage("/acnt/acnt0605p06", $M.toGetParam(param), {popupStatus: ""});
		}

        /**
         * 부품 판매 순익 팝업
         * @param yearType P : 과년 / C : 당년
         */
		function goPartSalePopup(yearType) {
            var startDt = yearType == "P" ? $M.removeHyphenFormat('${dateMap.past_start_dt}') : $M.removeHyphenFormat('${dateMap.current_start_dt}');
			var endDt = yearType == "P" ? $M.removeHyphenFormat('${dateMap.past_end_dt}') : $M.removeHyphenFormat('${dateMap.current_end_dt}');
			var param = {
				"s_mem_no": $M.getValue("mem_no"),
				"s_start_dt" : startDt,
				"s_end_dt" : endDt,
				"s_type": "M", // M 개인 , O 센터
			};
			$M.goNextPage("/acnt/acnt0605p07", $M.toGetParam(param), {popupStatus: ""});
		}

        /**
         * 중고장비판매수익 팝업 호출
         * @param yearType P : 과년 / C : 당년
         */
		function goUseSalePopup(yearType) {
            var startDt = yearType == "P" ? $M.removeHyphenFormat('${dateMap.past_start_dt}') : $M.removeHyphenFormat('${dateMap.current_start_dt}');
			var endDt = yearType == "P" ? $M.removeHyphenFormat('${dateMap.past_end_dt}') : $M.removeHyphenFormat('${dateMap.current_end_dt}');
			var param = {
				"s_mem_no": $M.getValue("mem_no"),
				"s_start_dt" : startDt,
				"s_end_dt" : endDt,
				"s_type": "M", // M 개인 , O 센터
			};
			$M.goNextPage("/acnt/acnt0605p08", $M.toGetParam(param), {popupStatus: ""});
		}
        // ######## 팝업 호출 함수 END ########
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<input type="hidden" id="mem_no" name="mem_no" value="${memInfo.mem_no}"/>
	<input type="hidden" id="org_code" name="org_code" value="${memInfo.org_code}"/>
	<input type="hidden" id="grade_cd" name="grade_cd" value="${memInfo.grade_cd}"/>
	<input type="hidden" id="mbo_st_mon" name="mbo_st_mon" value="${dateMap.mbo_st_mon}"/>
	<input type="hidden" id="mbo_ed_mon" name="mbo_ed_mon" value="${dateMap.mbo_ed_mon}"/>
	<input type="hidden" id="write_end_yn" name="write_end_yn" value="${memSvcMbo.write_end_yn}"/>
	<!-- 팝업 -->
	<div class="popup-wrap width-100per">
        <!-- 탭내용 -->
        <div class="tabs-inner-line">
            <div class="boxing bd0 pd0 vertical-line mt5">
                <div class="tabs-search-wrap">
                    <table class="table table-fixed">
                        <colgroup>
                            <col width="60px">
                            <col width="80px">
                            <col width="">
                        </colgroup>
                        <tbody>
                        <tr>
                            <th>조회년도</th>
                            <td>
                                <select class="form-control" id="s_mbo_year" name="s_mbo_year" required="required" alt="조회년도">
                                    <c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
                                        <c:set var="year_option" value="${inputParam.s_current_year - i + 2000}"/>
                                        <option value="${year_option}" <c:if test="${year_option eq inputParam.s_next_mbo_year-1}">selected</c:if>>${year_option}년</option>
                                    </c:forEach>
                                </select>
                            </td>
                            <td>
                                <button type="button" class="btn btn-important" style="width: 50px;" onclick="goSearch();">조회</button>
                            </td>
                        </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        <!-- /탭내용 -->
        <!-- 과년실적 -->
        <div class="title-wrap mt10">
            <div class="left">
                <h4>과년실적 (${dateMap.past_start_dt} ~ ${dateMap.past_end_dt})</h4>
            </div>
        </div>
        <div class="row">
            <div class="col-5">
                <table class="table-border mt5 link">
                    <colgroup>
                        <col width="110px">
                        <col width="60px">
                        <col width="60px">
                        <col width="60px">
                        <col width="60px">
                        <col width="60px">
                    </colgroup>
                    <tbody>
                    <tr>
                        <th class="title-bg" rowspan="4">업무량집계(건)</th>
                        <th class="td-gray">전화</th>
                        <th class="td-gray">유상</th>
                        <th class="td-gray">무상</th>
                        <th class="title-bg" colspan="2">전체</th>
                    </tr>
                    <tr>
                        <td class="text-center td-link">
                            <input type="text" class="form-control text-center pointer"
                                   id="p_call_cnt" name="p_call_cnt"
                                   format="decimal" readonly="readonly" alt="과년실적 전화"
                                   onclick="goPopupMakerCnt('P', 'as_call_cnt')"
                                   value="${pastYear.as_call_cnt}"
<%--                                   onclick="goMakerCnt('P', 'as_call_cnt')"--%>
<%--                                   value="${pastYear.b_call_cnt}"--%>
                            >
                        </td>
                        <td class="text-center td-link">
                            <input type="text" class="form-control text-center pointer"
                                   id="p_cost_cnt" name="p_cost_cnt"
                                   format="decimal" readonly="readonly" alt="과년실적 유상"
                                   onclick="goPopupMakerCnt('P', 'as_cost_repair_cnt')"
                                   value="${pastYear.as_cost_repair_cnt}"
<%--                                   onclick="goMakerCnt('P', 'as_cost_repair_cnt')"--%>
<%--                                   value="${pastYear.b_cost_cnt}"--%>
                            >
                        </td>
                        <td class="text-center td-link">
                            <input type="text" class="form-control text-center pointer"
                                   id="p_free_cnt" name="p_free_cnt"
                                   format="decimal" readonly="readonly" alt="과년실적 무상"
                                   onclick="goPopupMakerCnt('P', 'as_free_repair_cnt')"
                                   value="${pastYear.as_free_repair_cnt}"
<%--                                   onclick="goMakerCnt('P', 'as_free_repair_cnt')"--%>
<%--                                   value="${pastYear.b_free_cnt}"--%>
                            >
                        </td>
                        <td class="text-center td-link" colspan="2">
                            <input type="text" class="form-control text-center pointer" id="p_total_cnt" name="p_total_cnt"
                                   format="decimal" readonly="readonly" alt="과년실적 전체"
                                   value="${pastYear.as_tot}"
                                   onclick="goPopupMakerCnt('P', 'as_tot')"
<%--                                   onclick="goMakerCnt('P', 'as_call_cnt + as_cost_repair_cnt + as_free_repair_cnt')"--%>
<%--                                   value="${pastYear.b_total_cnt}"--%>
                            >
                        </td>
                    </tr>
                    <tr>
                        <th class="td-gray">정비</th>
                        <th class="td-gray">재정비</th>
                        <th class="td-gray">유효활동시간</th>
                        <th class="td-gray">근무시간<br>(편성표)</th>
                        <th class="td-gray">비율</th>
                    </tr>
                    <tr>
                        <td class="text-center">
                            <input type="text" class="form-control text-center" id="p_repair_cnt" name="p_repair_cnt"
                                   format="decimal" readonly="readonly" alt="과년실적 정비"
                                   value="${pastYear.tot_job_hour}"
<%--                                   value="${pastYear.b_repair_cnt}"--%>
                            >
<%--								<input onclick="javascript:goMakerCnt('P', 'as_cost_repair_cnt + as_free_repair_cnt')" type="text" class="form-control text-center pointer" id="p_repair_cnt" style="text-decoration:underline;" name="p_repair_cnt" format="decimal" readonly="readonly" alt="정비" value="${pastYear.b_repair_cnt}">--%>
                        </td>
                        <td class="text-center">
                            <input type="text" class="form-control text-center" id="p_rework_cnt" name="p_rework_cnt"
                                   format="decimal" readonly="readonly" alt="과년실적 재정비"
                                   value="${pastYear.re_as_repair_cnt}"
<%--                                   value="${pastYear.b_rework_cnt}"--%>
                            >
<%--								<input onclick="javascript:goMakerCnt('P', 're_as_repair_cnt')" type="text" class="form-control text-center pointer border-n" style="text-decoration:underline;" id="p_rework_cnt" name="p_rework_cnt" format="decimal" readonly="readonly" alt="재정비" value="${pastYear.b_rework_cnt}">--%>
                        </td>
                        <td class="text-center">
                            <input type="text" class="form-control text-center"
                                   id="p_valid_active_hour" name="p_valid_active_hour"
                                   format="decimal" readonly="readonly" alt="과년 유효활동시간"
                                   onchange="fnCalcTimeRate('p_')"
                                   value="${pastYear.tot_valid_hour}"
<%--                                   value="${pastYear.b_valid_active_hour}"--%>
                            >
                        </td>
                        <td class="text-center">
                            <input type="text" class="form-control text-center"
                                   id="p_work_hour" name="p_work_hour"
                                   format="decimal" readonly="readonly" alt="과년 근무시간"
                                   onchange="fnCalcTimeRate('p_')"
                                   value="${pastYear.work_hour}"
                            >
                        </td>
                        <td title="유효활동시간 / 근무시간">
                            <input type="text" class="form-control text-center"
                                   id="p_time_rate" name="p_time_rate"
                                   format="decimal" readonly="readonly" alt="과년 비율"
                            >
                        </td>
                    </tr>
                    <tr>
                        <th class="title-bg">신차 판매 순익(V)</th>
                        <c:set var="hasValue" value="${pastYear.new_machine_profit > 0 || pastYear.new_machine_profit < 0}" />
                        <td <c:if test="${hasValue}">class="td-link"</c:if> colspan="5">
                            <input type="text" class="form-control text-left <c:if test="${hasValue}">pointer</c:if>"
                                   id="p_new_mch_sale_profit_amt" name="p_new_mch_sale_profit_amt"
                                   format="decimal" readonly="readonly" alt="과년실적 신차판매수익"
                                   <c:if test="${hasValue}">onclick="goMachineSalePopup('P')"</c:if>
                                   value="${pastYear.new_machine_profit}"
<%--                                   value="${pastYear.a_new_mch_sale_profit_amt}"--%>
                            >
                        </td>
                    </tr>
                    <tr>
                        <th class="title-bg">부품 판매 순익(M)</th>
                        <c:set var="hasPastPSPAVal" value="${pastYear.part_profit_amt > 0 || pastYear.part_profit_amt < 0}" />
                        <td <c:if test="${hasPastPSPAVal}">class="td-link"</c:if> colspan="5">
                            <input type="text" class="form-control text-left <c:if test="${hasPastPSPAVal}">pointer</c:if>"
                                   id="p_part_sale_profit_amt" name="p_part_sale_profit_amt"
                                   format="decimal" readonly="readonly" alt="과년실적 부품 판매 순익"
                                   <c:if test="${hasPastPSPAVal}">onclick="goPartSalePopup('P')"</c:if>
                                   value="${pastYear.part_profit_amt}"
<%--                                   value="${pastYear.a_part_sale_profit_amt}"--%>
                            />
                        </td>
                    </tr>
                    <tr>
                        <th class="title-bg">중고 판매 순익(Q)</th>
                        <c:set var="hasValue" value="${pastYear.machine_used_profit_amt > 0 || pastYear.machine_used_profit_amt < 0}" />
                        <td <c:if test="${hasValue}">class="td-link"</c:if> colspan="5">
                            <input type="text" class="form-control text-left <c:if test="${hasValue}">pointer</c:if>"
                                   id="p_old_mch_sale_profit_amt" name="p_old_mch_sale_profit_amt"
                                   format="decimal" readonly="readonly" alt="중고장비판매수익"
                                   <c:if test="${hasValue}">onclick="goUseSalePopup('P')"</c:if>
                                   value="${pastYear.machine_used_profit_amt}"
<%--                                   value="${pastYear.a_old_mch_sale_profit_amt}"--%>
                            >
                        </td>
                    </tr>
                    </tbody>
                </table>
            </div>
            <div class="col-7">
                <table class="table-border mt5 link">
                    <colgroup>
                        <col width="60px">
                        <col width="50px">
                        <col width="50px">
                        <col width="50px">
                        <col width="60px">
                        <col width="60px">
                        <col width="60px">
                        <col width="70px">
                    </colgroup>
                    <tbody>
                    <tr>
                        <th class="title-bg" rowspan="2">유상정비</th>
                        <th class="td-gray">이동H</th>
                        <th class="td-gray">정비H</th>
                        <th class="td-gray">규정H</th>
                        <th class="td-gray">부품(A)</th>
                        <th class="td-gray">출장(B)</th>
                        <th class="td-gray">공임(C)</th>
                        <th class="title-bg">유상정비순익(E)</th>
                    </tr>
                    <tr>
                        <td class="td-link">
                            <input type="text" class="form-control text-center pointer"
                                   id="p_cost_move_hour" name="p_cost_move_hour"
                                   format="decimal" readonly="readonly" alt="과년실적 유상(이동H)"
                                   onclick="goPopupMakerRepairHour('P', 'cost_move_hour')"
                                   value="${pastYear.cost_move_hour}" >
<%--                                   value="${pastYear.b_cost_move_hour}" >--%>
<%--                                   onclick="goRepairHourMaker('P', 'cost_move_hour')"--%>
                        </td>
                        <td class="td-link">
                            <input type="text" class="form-control text-center pointer"
                                   id="p_cost_repair_hour" name="p_cost_repair_hour"
                                   format="decimal" readonly="readonly" alt="과년실적 유상(정비H)"
                                   onclick="goPopupMakerRepairHour('P', 'cost_repair_hour')"
                                   value="${pastYear.cost_repair_hour}"
<%--                                   onclick="goRepairHourMaker('P', 'appr_repair_hour', 'Y')"--%>
<%--                                   value="${pastYear.b_cost_repair_hour}" --%>
                            >
                        </td>
                        <td class="td-link">
                            <input type="text" class="form-control text-center pointer"
                                   id="p_cost_repair_std_hour" name="p_cost_repair_std_hour"
                                   format="decimal" readonly="readonly" alt="과년실적 유상(규정H)"
                                   onclick="goPopupMakerRepairHour('P', 'cost_standard_hour')"
                                   value="${pastYear.cost_standard_hour}"
<%--                                   onclick="goRepairHourMaker('P', 'cost_standard_hour')"--%>
<%--                                   value="${pastYear.b_cost_repair_std_hour}" --%>
                            >
                        </td>
                        <td class="td-link">
                            <input type="text" class="form-control text-right pointer"
                                   id="p_cost_part_amt" name="p_cost_part_amt"
                                   format="decimal" readonly="readonly" alt="과년실적 유상 부품"
                                   value="${pastYear.cost_part_amt}"
                                   onclick="goPopupMakerCost('P', 'cost_part_amt')"
<%--                                   onclick="goAmtMaker('P', 'cost_part_amt')"--%>
<%--                                   value="${pastYear.b_cost_part_amt}" --%>
                            >
                        </td>
                        <td class="td-link">
                            <input type="text" class="form-control text-right pointer"
                                   id="p_cost_travel_amt" name="p_cost_travel_amt"
                                   format="decimal" readonly="readonly" alt="과년실적 유상 출장"
                                   onclick="goPopupMakerCost('P', 'cost_travel_amt')"
                                   value="${pastYear.cost_travel_amt}"
<%--                                   onclick="goAmtMaker('P', 'cost_travel_amt')"--%>
<%--                                   value="${pastYear.b_cost_travel_amt}" --%>
                            >
                        </td>
                        <td class="td-link">
                            <input type="text" class="form-control text-right pointer"
                                   id="p_cost_work_amt" name="p_cost_work_amt"
                                   format="decimal" readonly="readonly" alt="과년실적 유상 공임"
                                   onclick="goPopupMakerCost('P', 'cost_work_amt')"
                                   value="${pastYear.cost_work_amt}"
<%--                                   onclick="goAmtMaker('P', 'cost_work_amt')" --%>
<%--                                   value="${pastYear.b_cost_work_amt}" --%>
                            >
                        </td>
                        <td>
                            <input type="text" class="form-control text-right"
                                   id="p_cost_work_profit_amt" name="p_cost_work_profit_amt"
                                   format="decimal" readonly="readonly" alt="유상정비순익"
                                   value="${pastYear.cost_profit_amt}"
<%--                                   value="${pastYear.a_cost_work_profit_amt}" --%>
                            >
                        </td>
                    </tr>
                    <tr>
                        <th class="title-bg" rowspan="2">무상정비</th>
                        <th class="td-gray">이동H</th>
                        <th class="td-gray">정비H</th>
                        <th class="td-gray">규정H</th>
                        <th class="td-gray">부품(F)</th>
                        <th class="td-gray">지출총계(J0)</th>
                        <th class="td-gray">서비스비용<br>(J1+J2+J3)</th>
                        <th class="title-bg">무상정비매출(W)</th>
                    </tr>
                    <tr>
                        <td class="text-right td-link">
                            <input type="text" class="form-control text-center pointer"
                                   id="p_free_move_hour" name="p_free_move_hour"
                                   format="decimal" readonly="readonly" alt="과년실적 무상(이동H)"
                                   onclick="goPopupMakerRepairHour('P', 'free_move_hour')"
                                   value="${pastYear.free_move_hour}"
<%--                                   onclick="goRepairHourMaker('P', 'free_move_hour')"--%>
<%--                                   value="${pastYear.b_free_move_hour}"--%>
                            >
                        </td>
                        <td class="text-right td-link">
<%-- 								<input type="text" class="form-control text-center pointer" id="p_free_repair_hour" name="p_free_repair_hour" format="decimal" readonly="readonly" alt="무상(정비H)" value="${pastYear.b_free_repair_hour}" onclick="javascript:goRepairHourPopup('${dateMap.past_start_dt}', '${dateMap.past_end_dt}', 'F')" style="text-decoration: underline;"> --%>
                            <input type="text" class="form-control text-center pointer"
                                   id="p_free_repair_hour" name="p_free_repair_hour"
                                   format="decimal" readonly="readonly" alt="과년실적 무상(정비H)"
                                   onclick="goPopupMakerRepairHour('P', 'free_repair_hour')"
                                   value="${pastYear.free_repair_hour}"
<%--                                   onclick="goRepairHourMaker('P', 'appr_repair_hour', 'N')"--%>
<%--                                   value="${pastYear.b_free_repair_hour}"--%>
                            >
                        </td>
                        <td class="text-right td-link">
                            <input type="text" class="form-control text-center pointer"
                                   id="p_free_repair_std_hour" name="p_free_repair_std_hour"
                                   format="decimal" readonly="readonly" alt="과년실적 무상(규정H)"
                                   onclick="goPopupMakerRepairHour('P', 'free_standard_hour')"
                                   value="${pastYear.free_standard_hour}"
<%--                                   onclick="goRepairHourMaker('P', 'free_standard_hour')"--%>
<%--                                   value="${pastYear.b_free_repair_std_hour}"--%>
                            >
                        </td>
                        <td class="text-right td-link">
                            <input type="text" class="form-control text-right pointer"
                                   id="p_free_part_amt" name="p_free_part_amt"
                                   format="decimal" readonly="readonly" alt="과년실적 무상 부품"
                                   onclick="goPopupMakerCost('P', 'm_free_part_amt')"
                                   value="${pastYear.m_free_part_amt}"
<%--                                   onclick="goAmtMaker('P', 'free_part_amt')"--%>
<%--                                   value="${pastYear.b_free_part_amt}"--%>
                            />
                        </td>
                        <td class="text-right td-link">
                            <input type="text" class="form-control text-right pointer"
                                   id="p_free_amt" name="p_free_amt"
                                   format="decimal" readonly="readonly" alt="과년실적 무상 지출총계"
                                   onclick="goPopupMakerCost('P', 'free_amt')"
                                   value="${pastYear.free_amt}"
<%--                                   onclick="goAmtMaker('P', 'free_travel_amt + free_work_amt')"--%>
<%--                                   value="${pastYear.b_free_out_amt}" --%>
                            />
                        </td>
                        <td class="text-right td-link">
                            <input type="text" class="form-control text-right pointer"
                                   id="p_free_svc_amt" name="p_free_svc_amt"
                                   format="decimal" readonly="readonly" alt="과년실적 무상 서비스비용"
                                   onclick="goPopupMakerCost('P', 'free_svc_amt')"
                                   value="${pastYear.free_svc_amt}"
<%--                                   onclick="goAmtMaker('P', 'warranty_amt + out_cost_amt + free_cost_amt')"--%>
<%--                                   value="${pastYear.b_free_svc_amt}" --%>
                            />
                        </td>
                        <td>
                            <input type="text" class="form-control text-right"
                                   id="p_free_sale_amt" name="p_free_sale_amt"
                                   format="decimal" readonly="readonly" alt="과년실적 무상정비매출"
                                   value="${pastYear.free_sale_amt}"
<%--                                   value="${pastYear.a_free_sale_amt}"--%>
                            >
                        </td>
                    </tr>
                    <tr>
                        <th class="title-bg" rowspan="2">렌탈업무</th>
                        <th class="td-gray">렌탈시간</th>
                        <th class="td-gray"></th>
                        <th class="td-gray"></th>
                        <th class="td-gray">렌탈료(R)</th>
                        <th class="td-gray">렌탈감가(S)</th>
                        <th class="td-gray"></th>
                        <th class="title-bg">렌탈순익(U)</th>
                    </tr>
                    <tr>
                        <td>
                            <input type="text" class="form-control text-center"
                                   id="p_rental_job_hour" name="p_rental_job_hour"
                                   format="decimal" readonly="readonly" alt="과년실적 렌탈시간"
                                   value="${pastYear.rental_job_hour}"
<%--                                   value="${pastYear.b_rental_job_hour}"--%>
                            >
                        </td>
                        <td></td>
                        <td></td>
                        <td>
                            <input type="text" class="form-control text-right"
                                   id="p_rental_amt" name="p_rental_amt"
                                   format="decimal" readonly="readonly" alt="렌탈료"
                                   value="${pastYear.rental_rent_amt}"
<%--                                   value="${pastYear.b_rental_amt}"--%>
                            >
                        </td>
                        <td>
                            <input type="text" class="form-control text-right"
                                   id="p_rental_mch_reduce_amt" name="p_rental_mch_reduce_amt"
                                   format="decimal" readonly="readonly" alt="렌탈감가"
                                   value="${pastYear.reduce_total_amt}"
<%--                                   value="${pastYear.b_rental_mch_reduce_amt}"--%>
                            >
                        </td>
                        <td></td>
                        <td>
                            <input type="text" class="form-control text-right"
                                   id="p_rental_profit_amt" name="p_rental_profit_amt"
                                   format="decimal" readonly="readonly" alt="렌탈순익"
                                   value="${pastYear.rental_profit_amt}"
<%--                                   value="${pastYear.a_rental_profit_amt}"--%>
                            >
                        </td>
                    </tr>
                    <tr>
                        <th class="title-bg" colspan="7">과년 총 업무수익</th>
                        <td>
                            <input type="text" class="form-control text-right text-strong"
                                   id="p_total_profit_amt" name="p_total_profit_amt"
                                   format="decimal" readonly="readonly" alt="과년 총 업무수익"
                                   value="${pastYear.total_profit_amt}"
<%--                                   value="${pastYear.a_total_profit_amt}"--%>
                            >
                        </td>
                    </tr>
                    </tbody>
                </table>
            </div>
        </div>
        <!-- /과년실적 -->
        <!-- 당년실적 -->
        <div class="title-wrap mt10">
            <div class="left">
                <h4>당년실적 (${dateMap.current_start_dt} ~ ${dateMap.current_end_dt})</h4>
            </div>
        </div>
        <div class="row">
            <div class="col-5">
                <table class="table-border mt5 link">
                    <colgroup>
                        <col width="110px">
                        <col width="60px">
                        <col width="60px">
                        <col width="60px">
                        <col width="60px">
                        <col width="60px">
                    </colgroup>
                    <tbody>
                    <tr>
                        <th class="title-bg" rowspan="4">업무량집계(건)</th>
                        <th class="td-gray">전화</th>
                        <th class="td-gray">유상</th>
                        <th class="td-gray">무상</th>
                        <th class="title-bg" colspan="2">전체</th>
                    </tr>
                    <tr>
                        <td class="td-link">
                            <input type="text" class="form-control text-center pointer"
                                   id="c_call_cnt" name="c_call_cnt"
                                   format="decimal" readonly="readonly" alt="당년실적 전화"
                                   onclick="goPopupMakerCnt('C', 'as_call_cnt')"
                                   value="${currentYear.as_call_cnt}"
<%--                                   onclick="goMakerCnt('C', 'as_call_cnt')"--%>
<%--                                   value="${currentYear.b_call_cnt}" --%>
                            >
                        </td>
                        <td class="td-link">
                            <input type="text" class="form-control text-center pointer"
                                   id="c_as_cost_repair_cnt" name="c_as_cost_repair_cnt"
                                   format="decimal" readonly="readonly" alt="당년실적 유상"
                                   onclick="goPopupMakerCnt('C', 'as_cost_repair_cnt')"
                                   value="${currentYear.as_cost_repair_cnt}"
<%--                                   value="${currentYear.b_cost_cnt}" --%>
<%--                                   onclick="goMakerCnt('C', 'as_cost_repair_cnt')"--%>
                            >
                        </td>
                        <td class="td-link">
                            <input type="text" class="form-control text-center pointer"
                                   id="c_as_free_repair_cnt" name="c_as_free_repair_cnt"
                                   format="decimal" readonly="readonly" alt="당년실적 무상"
                                   onclick="goPopupMakerCnt('C', 'as_free_repair_cnt')"
                                   value="${currentYear.as_free_repair_cnt}"
<%--                                   onclick="goMakerCnt('C', 'as_free_repair_cnt')"--%>
<%--                                   value="${currentYear.b_free_cnt}"--%>
                            >
                        </td>
                        <td class="td-link" colspan="2" title="전화 + 유상 + 무상">
                            <input type="text" class="form-control text-center pointer"
                                   id="c_as_tot" name="c_as_tot"
                                   format="decimal" readonly="readonly" alt="당년실적 전체"
                                   onclick="goPopupMakerCnt('P', 'as_tot')"
                                   value="${currentYear.as_tot}"
<%--                                   onclick="goMakerCnt('C', 'as_call_cnt+as_cost_repair_cnt+as_free_repair_cnt')"--%>
<%--                                   value="${currentYear.b_total_cnt}"--%>
                            >
                        </td>
                    </tr>
                    <tr>
                        <th class="td-gray">정비</th>
                        <th class="td-gray">재정비</th>
                        <th class="td-gray">유효활동시간</th>
                        <th class="td-gray">근무시간<br>(편성표)</th>
                        <th class="td-gray">비율</th>
                    </tr>
                    <tr>
                        <td>
                            <input type="text" class="form-control text-center"
                                   id="c_tot_job_hour" name="c_tot_job_hour"
                                   format="decimal" readonly="readonly" alt="당년실적 정비"
                                   value="${currentYear.tot_job_hour}"
<%--                                   value="${currentYear.b_repair_cnt}"--%>
                            >
<%--								<input onclick="javascript:goMakerCnt('C', 'as_cost_repair_cnt + as_free_repair_cnt')" type="text" class="form-control text-center pointer" style="text-decoration:underline;" id="b_repair_cnt" name="b_repair_cnt" format="decimal" readonly="readonly" alt="정비" value="${currentYear.b_repair_cnt}">--%>
                        </td>
                        <td>
                            <input type="text" class="form-control text-center"
                                   id="c_re_as_repair_cnt" name="c_re_as_repair_cnt"
                                   format="decimal" readonly="readonly" alt="당년실적 재정비"
                                   value="${currentYear.re_as_repair_cnt}"
<%--                                   value="${currentYear.b_rework_cnt}"--%>
                            >
<%--								<input onclick="javascript:goMakerCnt('C', 're_as_repair_cnt')" type="text" class="form-control text-center pointer" style="text-decoration:underline;" id="b_rework_cnt" name="b_rework_cnt" format="decimal" readonly="readonly" alt="재정비" value="${currentYear.b_rework_cnt}">--%>
                        </td>
                        <td>
                            <input type="text" class="form-control text-center"
                                   id="c_valid_active_hour" name="c_valid_active_hour"
                                   format="decimal" readonly="readonly" alt="당년실적 유효활동시간"
                                   onchange="fnCalcTimeRate('c_')"
                                   value="${currentYear.tot_valid_hour}">
<%--                                   value="${currentYear.b_valid_active_hour}">--%>
                        </td>
                        <td>
                            <input type="text" class="form-control text-center"
                                   id="c_work_hour" name="c_work_hour"
                                   format="decimal" readonly="readonly" alt="당년실적 근무시간"
                                   onchange="fnCalcTimeRate('c_')"
                                   value="${currentYear.work_hour}">
                        </td>
                        <td title="유효활동시간 / 근무시간">
                            <input type="text" class="form-control text-center"
                                   id="c_time_rate" name="c_time_rate"
                                   format="decimal" readonly="readonly" alt="당년실적 비율" >
                        </td>
                    </tr>
                    <tr>
                        <th class="title-bg">신차 판매 순익(V)</th>
                        <c:set var="hasValue" value="${currentYear.new_machine_profit > 0 || currentYear.new_machine_profit < 0}" />
                        <td <c:if test="${hasValue}">class="td-link"</c:if> colspan="5">
                            <input type="text" class="form-control text-left <c:if test="${hasValue}">pointer</c:if>"
                                   id="c_new_mch_sale_profit_amt" name="c_new_mch_sale_profit_amt"
                                   format="decimal" readonly="readonly" alt="당년실적 신차판매수익"
                                   value="${currentYear.new_machine_profit}"
                                   <c:if test="${hasValue}">onclick="goMachineSalePopup('C')"</c:if>
                            />
                        </td>
                    </tr>
                    <tr>
                        <th class="title-bg">부품 판매 순익(M)</th>
                        <c:set var="hasValue" value="${currentYear.part_profit_amt > 0 || currentYear.part_profit_amt < 0}" />
                        <td <c:if test="${hasValue}">class="td-link"</c:if> colspan="5">
                            <input type="text" class="form-control text-left <c:if test="${hasValue}">pointer</c:if>"
                                   id="c_part_sale_profit_amt" name="c_part_sale_profit_amt"
                                   format="decimal" readonly="readonly" alt="당년실적 부품 판매 순익"
                                   value="${currentYear.part_profit_amt}"
                                   <c:if test="${hasValue}">onclick="goPartSalePopup('C')"</c:if>
                            />
                        </td>
                    </tr>
                    <tr>
                        <th class="title-bg">중고 판매 순익(Q)</th>
                        <c:set var="hasValue" value="${currentYear.machine_used_profit_amt > 0 || currentYear.machine_used_profit_amt < 0}" />
                        <td <c:if test="${hasValue}">class="td-link"</c:if> colspan="5">
                            <input type="text" class="form-control text-left <c:if test="${hasValue}">pointer</c:if>"
                                   id="c_machine_used_profit_amt" name="c_machine_used_profit_amt"
                                   format="decimal" readonly="readonly" alt="당년실적 중고장비판매수익"
                                   value="${currentYear.machine_used_profit_amt}"
                                   <c:if test="${hasValue}">onclick="goUseSalePopup('C')"</c:if>
                            />
                        </td>
                    </tr>
                    </tbody>
                </table>
            </div>
            <div class="col-7">
                <table class="table-border mt5 link">
                    <colgroup>
                        <col width="60px">
                        <col width="50px">
                        <col width="50px">
                        <col width="50px">
                        <col width="60px">
                        <col width="60px">
                        <col width="60px">
                        <col width="70px">
                    </colgroup>
                    <tbody>
                    <tr>
                        <th class="title-bg" rowspan="2">유상정비</th>
                        <th class="td-gray">이동H</th>
                        <th class="td-gray">정비H</th>
                        <th class="td-gray">규정H</th>
                        <th class="td-gray">부품(A)</th>
                        <th class="td-gray">출장(B)</th>
                        <th class="td-gray">공임(C)</th>
                        <th class="title-bg">유상정비순익(E)</th>
                    </tr>
                    <tr>
                        <td class="td-link">
                            <input type="text" class="form-control text-center pointer"
                                   id="c_cost_move_hour" name="c_cost_move_hour"
                                   format="decimal" readonly="readonly" alt="당년실적 유상(이동H)"
                                   onclick="goPopupMakerRepairHour('C', 'cost_move_hour')"
                                   value="${currentYear.cost_move_hour}"
<%--                                   value="${currentYear.b_cost_move_hour}"--%>
<%--                                   onclick="goRepairHourMaker('C', 'cost_move_hour')"--%>
                            >
                        </td>
                        <td class="td-link">
                            <input type="text" class="form-control text-center pointer"
                                   id="c_cost_repair_hour" name="c_cost_repair_hour"
                                   format="decimal" readonly="readonly" alt="당년실적 유상(정비H)"
                                   onclick="goPopupMakerRepairHour('C', 'cost_repair_hour')"
                                   value="${currentYear.cost_repair_hour}"
<%--                                   value="${currentYear.b_cost_repair_hour}"--%>
<%--                                   onclick="goRepairHourPopup('P')" --%>
                            />
                        </td>
                        <td class="td-link">
                            <input type="text" class="form-control text-center pointer"
                                   id="c_cost_standard_hour" name="c_cost_standard_hour"
                                   format="decimal" readonly="readonly" alt="당년실적 유상(규정H)"
                                   onclick="goPopupMakerRepairHour('C', 'cost_standard_hour')"
                                   value="${currentYear.cost_standard_hour}"
<%--                                   value="${currentYear.b_cost_repair_std_hour}"--%>
                            />
                        </td>
                        <td class="td-link">
                            <input type="text" class="form-control text-right pointer"
                                   id="c_cost_part_amt" name="c_cost_part_amt"
                                   format="decimal" readonly="readonly" alt="당년실적 유상 부품"
                                   onclick="goPopupMakerCost('C', 'cost_part_amt')"
                                   value="${currentYear.cost_part_amt}"
<%--                                   value="${currentYear.b_cost_part_amt}"--%>
                            />
                        </td>
                        <td class="td-link">
                            <input type="text" class="form-control text-right pointer"
                                   id="c_cost_travel_amt" name="c_cost_travel_amt"
                                   format="decimal" readonly="readonly" alt="당년실적 유상 출장"
                                   onclick="goPopupMakerCost('C', 'cost_travel_amt')"
                                   value="${currentYear.cost_travel_amt}"
<%--                                   value="${currentYear.b_cost_travel_amt}"--%>
                            />
                        </td>
                        <td class="td-link">
                            <input type="text" class="form-control text-right pointer"
                                   id="c_cost_work_amt" name="c_cost_work_amt"
                                   format="decimal" readonly="readonly" alt="당년실적 유상 공임"
                                   onclick="goPopupMakerCost('C', 'cost_work_amt')"
                                   value="${currentYear.cost_work_amt}"
<%--                                   value="${currentYear.b_cost_work_amt}"--%>
                            />
                        </td>
                        <td>
                            <input type="text" class="form-control text-right"
                                   id="c_cost_profit_amt" name="c_cost_profit_amt"
                                   format="decimal" readonly="readonly" alt="당년실적 유상정비순익"
                                   value="${currentYear.cost_profit_amt}"
                            />
                        </td>
                    </tr>
                    <tr>
                        <th class="title-bg" rowspan="2">무상정비</th>
                        <th class="td-gray">이동H</th>
                        <th class="td-gray">정비H</th>
                        <th class="td-gray">규정H</th>
                        <th class="td-gray">부품(F)</th>
                        <th class="td-gray">지출총계(J0)</th>
                        <th class="td-gray">서비스비용<br>(J1+J2+J3)</th>
                        <th class="title-bg">무상정비매출(W)</th>
                    </tr>
                    <tr>
                        <td class="td-link">
                            <input type="text" class="form-control text-center pointer"
                                   id="c_free_move_hour" name="c_free_move_hour"
                                   format="decimal" readonly="readonly" alt="당년실적 무상(이동H)"
                                   onclick="goPopupMakerRepairHour('C', 'free_move_hour')"
                                   value="${currentYear.free_move_hour}"
<%--                                   value="${currentYear.b_free_move_hour}"--%>
<%--                                   onclick="goRepairHourPopup('F')"--%>
                            >
                        </td>
                        <td class="td-link">
                            <input type="text" class="form-control text-center pointer"
                                   id="c_free_repair_hour" name="c_free_repair_hour"
                                   format="decimal" readonly="readonly" alt="당년실적 무상(정비H)"
                                   onclick="goPopupMakerRepairHour('C', 'free_repair_hour')"
                                   value="${currentYear.free_repair_hour}"
<%--                                   value="${currentYear.b_free_repair_hour}"--%>
<%--                                   onclick="goRepairHourPopup('F')"--%>
                            />
                        </td>
                        <td class="td-link">
                            <input type="text" class="form-control text-center pointer"
                                   id="c_free_standard_hour" name="c_free_standard_hour"
                                   format="decimal" readonly="readonly" alt="당년실적 무상(규정H)"
                                   value="${currentYear.free_standard_hour}"
                                   onclick="goPopupMakerRepairHour('C', 'free_standard_hour')"
<%--                                   value="${currentYear.b_free_repair_std_hour}"--%>
<%--                                   onclick="goRepairHourPopup('F')"--%>
                            />
                        </td>
                        <td class="td-link">
                            <input type="text" class="form-control text-right pointer"
                                   id="c_free_part_amt" name="c_free_part_amt"
                                   format="decimal" readonly="readonly" alt="당년실적 무상 부품"
                                   onclick="goPopupMakerCost('C', 'm_free_part_amt')"
                                   value="${pastYear.m_free_part_amt}"
<%--                                   onclick="goAmtMaker('C', 'free_part_amt')"--%>
<%--                                   value="${currentYear.free_part_amt}"--%>
                            />
                        </td>
                        <td class="td-link">
                            <input type="text" class="form-control text-right pointer"
                                   id="c_free_out_amt" name="c_free_out_amt"
                                   format="decimal" readonly="readonly" alt="당년실적 무상 지출총계"
                                   onclick="goPopupMakerCost('C', 'free_amt')"
                                   value="${currentYear.free_amt}"
<%--                                   onclick="goAmtMaker('C', 'free_travel_amt + free_work_amt')"--%>
<%--                                   value="${currentYear.free_out_amt}"--%>
                            />
                        </td>
                        <td class="td-link">
                            <input type="text" class="form-control text-right pointer"
                                   id="c_free_svc_amt" name="c_free_svc_amt"
                                   format="decimal" readonly="readonly" alt="당년실적 무상 서비스비용"
                                   onclick="goPopupMakerCost('C', 'free_svc_amt')"
                                   value="${currentYear.free_svc_amt}"
<%--                                   onclick="goAmtMaker('C', 'warranty_amt + out_cost_amt + free_cost_amt')"--%>
<%--                                   value="${currentYear.free_svc_amt}"--%>
                            />
                        </td>
                        <td>
                            <input type="text" class="form-control text-right"
                                   id="c_free_sale_amt" name="c_free_sale_amt"
                                   format="decimal" readonly="readonly" alt="당년실적 무상정비매출"
                                   value="${currentYear.free_sale_amt}" />
                        </td>
                    </tr>
                    <tr>
                        <th class="title-bg" rowspan="2">렌탈업무</th>
                        <th class="td-gray">렌탈시간</th>
                        <th class="td-gray"></th>
                        <th class="td-gray"></th>
                        <th class="td-gray">렌탈료(R)</th>
                        <th class="td-gray">렌탈감가(S)</th>
                        <th class="td-gray"></th>
                        <th class="title-bg">렌탈순익(U)</th>
                    </tr>
                    <tr>
                        <td>
                            <input type="text" class="form-control text-center"
                                   id="c_rental_job_hour" name="c_rental_job_hour"
                                   format="decimal" readonly="readonly" alt="당년 렌탈시간"
                                   value="${currentYear.rental_job_hour}"
                            />
                        </td>
                        <td></td>
                        <td></td>
                        <td>
                            <input type="text" class="form-control text-right"
                                   id="c_rental_rent_amt" name="c_rental_rent_amt"
                                   format="decimal" readonly="readonly" alt="당년 렌탈료"
                                   value="${currentYear.rental_rent_amt}"
<%--                                   value="${currentYear.b_rental_amt}"--%>
                            />
                        </td>
                        <td>
                            <input type="text" class="form-control text-right"
                                   id="c_reduce_total_amt" name="c_reduce_total_amt"
                                   format="decimal" readonly="readonly" alt="당년 렌탈감가"
                                   value="${currentYear.reduce_total_amt}"
<%--                                   value="${currentYear.b_rental_mch_reduce_amt}"--%>
                            />
                        </td>
                        <td></td>
                        <td>
                            <input type="text" class="form-control text-right"
                                   id="c_rental_profit_amt" name="c_rental_profit_amt"
                                   format="decimal" readonly="readonly" alt="당년 렌탈순익"
                                   value="${currentYear.rental_profit_amt}">
                        </td>
                    </tr>
                    <tr>
                        <th class="title-bg" colspan="7">당년 총 업무수익</th>
                        <td>
                            <input type="text" class="form-control text-right text-strong"
                                   id="c_total_profit_amt" name="c_total_profit_amt"
                                   format="decimal" readonly="readonly" alt="당년 총 업무수익"
                                   value="${currentYear.total_profit_amt}">
                        </td>
                    </tr>
                    </tbody>
                </table>
            </div>
        </div>
        <!-- /당년실적 -->
        <!-- 차년목표 -->
        <div class="title-wrap mt10">
            <div class="left">
                <h4>차년목표 (${dateMap.next_start_dt} ~ ${dateMap.next_end_dt})</h4>
            </div>
        </div>
        <div class="row">
            <div class="col-5">
                <table class="table-border mt5 link">
                    <colgroup>
                        <col width="110px">
                        <col width="60px">
                        <col width="60px">
                        <col width="60px">
                        <col width="60px">
                        <col width="60px">
                    </colgroup>
                    <tbody>
                    <tr>
                        <th class="title-bg" rowspan="4">업무량집계(건)</th>
                        <th class="td-gray">전화</th>
                        <th class="td-gray">유상</th>
                        <th class="td-gray">무상</th>
                        <th class="title-bg" colspan="2">전체</th>
                    </tr>
                    <tr>
                        <td>
                            <input type="text" class="form-control text-center" id="call_cnt" name="call_cnt" format="decimal"
                                   alt="차년 전화" required="required" onchange="fnCalcTotalCnt();" value="${memSvcMbo.call_cnt}">
                        </td>
                        <td>
                            <input type="text" class="form-control text-center" id="cost_cnt" name="cost_cnt" format="decimal"
                                   alt="차년 유상" required="required" onchange="fnCalcTotalCnt();" value="${memSvcMbo.cost_cnt}">
                        </td>
                        <td>
                            <input type="text" class="form-control text-center" id="free_cnt" name="free_cnt" format="decimal"
                                   alt="차년 무상" required="required" onchange="fnCalcTotalCnt();" value="${memSvcMbo.free_cnt}">
                        </td>
                        <td colspan="2" title="전체=전화+유상+무상">
                            <input type="text" class="form-control text-center" id="total_cnt" name="total_cnt"
                                   format="decimal" readonly="readonly" alt="차년 전체" value="${memSvcMbo.total_cnt}">
                        </td>
                    </tr>
                    <tr>
                        <th class="td-gray">정비</th>
                        <th class="td-gray">재정비</th>
                        <th class="td-gray">유효활동시간</th>
                        <th class="td-gray">근무시간<br>(편성표)</th>
                        <th class="td-gray">비율</th>
                    </tr>
                    <tr>
                        <td title="정비=유상+무상">
                            <input type="text" class="form-control text-center" id="repair_cnt" name="repair_cnt"
                                   format="decimal" alt="차년목표 정비" required="required"
                                   value="${memSvcMbo.repair_cnt}">
                        </td>
                        <td>
                            <input type="text" class="form-control text-center"
                                   id="rework_cnt" name="rework_cnt" format="decimal" alt="차년목표 재정비" required="required" value="${memSvcMbo.rework_cnt}">
                        </td>
                        <td>
                            <input type="text" class="form-control text-center"
                                   id="valid_active_hour" name="valid_active_hour"
                                   format="decimal" alt="차년목표 유효활동시간" required="required"
                                   value="${memSvcMbo.valid_active_hour}"
                                   onchange="fnCalcTimeRate('')" />
                        </td>
                        <td>
                            <input type="text" class="form-control text-center"
                                   id="work_hour" name="work_hour"
                                   format="decimal" alt="차년목표 근무시간" required="required"
                                   value="${memSvcMbo.work_hour}"
                                   onchange="fnCalcTimeRate('')" />
                        </td>
                        <td title="비율=유효활동시간/근무시간">
                            <input type="text" class="form-control text-center"
                                   id="time_rate" name="time_rate" format="decimal" alt="차년목표 비율" readonly="readonly" />
                        </td>
                    </tr>
                    <tr>
                        <th class="title-bg">신차 판매 순익(V)</th>
                        <td colspan="5">
                            <input type="text" class="form-control text-left" id="new_mch_sale_profit_amt" name="new_mch_sale_profit_amt"
                                   format="decimal" alt="차년목표 신차 판매 순익" value="${memSvcMbo.new_mch_sale_profit_amt}">
                        </td>
                    </tr>
                    <tr>
                        <th class="title-bg">부품 판매 순익(M)</th>
                        <td colspan="5">
                            <input type="text" class="form-control text-left" id="part_sale_profit_amt" name="part_sale_profit_amt"
                                   format="decimal" alt="차년목표 부품 판매 순익" value="${memSvcMbo.part_sale_profit_amt}">
                        </td>
                    </tr>
                    <tr>
                        <th class="title-bg">중고 판매 순익(Q)</th>
                        <td colspan="5">
                            <input type="text" class="form-control text-left" id="old_mch_sale_profit_amt" name="old_mch_sale_profit_amt"
                                   format="decimal" alt="차년목표 중고장비 판매 수익" value="${memSvcMbo.old_mch_sale_profit_amt}">
                        </td>
                    </tr>
                    </tbody>
                </table>
            </div>
            <div class="col-7">
                <table class="table-border mt5 link">
                    <colgroup>
                        <col width="60px">
                        <col width="50px">
                        <col width="50px">
                        <col width="50px">
                        <col width="60px">
                        <col width="60px">
                        <col width="60px">
                        <col width="70px">
                    </colgroup>
                    <tbody>
                    <tr>
                        <th class="title-bg" rowspan="2">유상정비</th>
                        <th class="td-gray">이동H</th>
                        <th class="td-gray">정비H</th>
                        <th class="td-gray">규정H</th>
                        <th class="td-gray">부품(A)</th>
                        <th class="td-gray">출장(B)</th>
                        <th class="td-gray">공임(C)</th>
                        <th class="title-bg">유상정비순익(E)</th>
                    </tr>
                    <tr>
                        <td>
                            <input type="text" class="form-control text-center" id="cost_move_hour" name="cost_move_hour"
                                   format="decimal" alt="차년목표 유상(이동H)" value="${memSvcMbo.cost_move_hour}">
                        </td>
                        <td>
                            <input type="text" class="form-control text-center" id="cost_repair_hour" name="cost_repair_hour"
                                   format="decimal" alt="차년목표 유상(정비H)" value="${memSvcMbo.cost_repair_hour}">
                        </td>
                        <td>
                            <input type="text" class="form-control text-center" id="cost_repair_std_hour" name="cost_repair_std_hour"
                                   format="decimal" alt="차년목표 유상(규정H)" value="${memSvcMbo.cost_repair_std_hour}">
                        </td>
                        <td>
                            <input type="text" class="form-control text-right" id="cost_part_amt" name="cost_part_amt"
                                   format="decimal" alt="차년목표 유상(부품비용)" onchange="fnCalcCostProfitAmt();" value="${memSvcMbo.cost_part_amt}">
                        </td>
                        <td>
                            <input type="text" class="form-control text-right" id="cost_travel_amt" name="cost_travel_amt"
                                   format="decimal" alt="차년목표 유상(출장비용)" onchange="fnCalcCostProfitAmt();" value="${memSvcMbo.cost_travel_amt}">
                        </td>
                        <td>
                            <input type="text" class="form-control text-right" id="cost_work_amt" name="cost_work_amt"
                                   format="decimal" alt="차년목표 유상(공임비용)" onchange="fnCalcCostProfitAmt();" value="${memSvcMbo.cost_work_amt}">
                        </td>
                        <td>
                            <input type="text" class="form-control text-right" id="cost_work_profit_amt" name="cost_work_profit_amt"
                                   format="decimal" readonly="readonly" alt="차년목표 유상정비순익" title="부품(A)*15%+출장비(B)+공임비(C)"
                                   value="${memSvcMbo.cost_work_profit_amt}">
                        </td>
                    </tr>
                    <tr>
                        <th class="title-bg" rowspan="2">무상정비</th>
                        <th class="td-gray">이동H</th>
                        <th class="td-gray">정비H</th>
                        <th class="td-gray">규정H</th>
                        <th class="td-gray">부품(F)</th>
                        <th class="td-gray">지출총계(J0)</th>
                        <th class="td-gray">서비스비용<br>(J1+J2+J3)</th>
                        <th class="title-bg">무상정비매출(W)</th>
                    </tr>
                    <tr>
                        <td>
                            <input type="text" class="form-control text-center" id="free_move_hour" name="free_move_hour"
                                   format="decimal" alt="차년목표 무상(이동H)" value="${memSvcMbo.free_move_hour}">
                        </td>
                        <td>
                            <input type="text" class="form-control text-center" id="free_repair_hour" name="free_repair_hour"
                                   format="decimal" alt="차년목표 무상(정비H)" value="${memSvcMbo.free_repair_hour}">
                        </td>
                        <td>
                            <input type="text" class="form-control text-center" id="free_repair_std_hour" name="free_repair_std_hour"
                                   format="decimal" alt="차년목표 무상(규정H)" value="${memSvcMbo.free_repair_std_hour}">
                        </td>
                        <td>
                            <input type="text" class="form-control text-right" id="free_part_amt" name="free_part_amt"
                                   format="decimal" alt="차년목표 무상부품"
                                   onchange="fnCalcFreeSalesAmt();" value="${memSvcMbo.free_part_amt}">
                        </td>
                        <td>
                            <input type="text" class="form-control text-right" id="free_out_amt" name="free_out_amt"
                                   format="decimal" alt="차년목표 무상지출총계" title="지출총계=출장비+공임"
                                   onchange="fnCalcFreeSalesAmt();" value="${memSvcMbo.free_out_amt}">
                        </td>
                        <td>
                            <input type="text" class="form-control text-right" id="free_svc_amt" name="free_svc_amt"
                                   format="decimal" alt="차년목표 무상서비스비용"
                                   onchange="fnCalcFreeSalesAmt();" value="${memSvcMbo.free_svc_amt}">
                        </td>
                        <td>
                            <input type="text" class="form-control text-right" id="free_repair_sale_amt" name="free_repair_sale_amt"
                                   format="decimal" readonly="readonly" alt="무상정비매출" title="부품비(F)+지출총계(J0)+서비스비용(J1+J2+J3)"
                                   value="${memSvcMbo.free_repair_sale_amt}">
                        </td>
                    </tr>
                    <tr>
                        <th class="title-bg" rowspan="2">렌탈업무</th>
                        <th class="td-gray">렌탈시간</th>
                        <th class="td-gray"></th>
                        <th class="td-gray"></th>
                        <th class="td-gray">렌탈료(R)</th>
                        <th class="td-gray">렌탈감가(S)</th>
                        <th class="td-gray"></th>
                        <th class="title-bg">렌탈순익(U)</th>
                    </tr>
                    <tr>
                        <td class="text-right">
                            <input type="text" class="form-control text-center" id="rental_hour" name="rental_hour"
                                   format="decimal" alt="차년목표 렌탈시간" value="${memSvcMbo.rental_hour}">
                        </td>
                        <td class="text-right"></td>
                        <td class="text-right"></td>
                        <td>
                            <input type="text" class="form-control text-right" id="rental_amt" name="rental_amt"
                                   format="decimal" alt="차년목표 렌탈비용"
                                   onchange="fnCalcRentalProfitAmt();" value="${memSvcMbo.rental_amt}">
                        </td>
                        <td>
                            <input type="text" class="form-control text-right" id="rental_mch_reduce_amt" name="rental_mch_reduce_amt"
                                   format="decimal" alt="차년목표 렌탈장비감가"
                                   onchange="fnCalcRentalProfitAmt();" value="${memSvcMbo.rental_mch_reduce_amt}">
                        </td>
                        <td class="text-right"></td>
                        <td>
                            <!-- 렌탈비용 - 렌탈장비감가 -->
                            <input type="text" class="form-control text-right" id="rental_profit_amt" name="rental_profit_amt"
                                   format="decimal" readonly="readonly" alt="차년목표 렌탈순익" title="렌탈료(R)-렌탈감가(S)"
                                   value="${memSvcMbo.rental_profit_amt}">
                        </td>
                    </tr>
                    <tr>
                        <th class="title-bg" colspan="7">차년 총 목표수익</th>
                        <td>
                            <input type="text" class="form-control text-right text-strong" id="total_profit_amt" name="total_profit_amt"
                                   format="decimal" readonly="readonly" alt="차년 총 목표수익">
                        </td>
                    </tr>
                    </tbody>
                </table>
            </div>
        </div>
        <!-- /차년목표 -->
        <!-- 당년지출 계 -->
        <div class="title-wrap mt10 currentYearDiv">
            <div class="left">
                <h4>당년 본인 지출계 (${dateMap.current_start_dt} ~ ${dateMap.current_end_dt})</h4>
            </div>
        </div>
        <div class="row currentYearDiv">
            <div class="col-5">
                <table class="table-border mt5">
                    <colgroup>
                        <col width="25%">
                        <col width="25%">
                        <col width="25%">
                        <col width="25%">
                    </colgroup>
                    <thead>
                    <tr>
                        <th class="title-bg">인건비계</th>
                        <th class="title-bg">센터경비계</th>
                        <th class="title-bg">공통비계</th>
                        <th class="title-bg">합계</th>
                    </tr>
                    </thead>
                    <tbody>
                    <tr>
                        <td class="text-right">
                            <input type="text" class="form-control text-right" id="total_salary_amt" name="total_salary_amt" format="decimal" readonly="readonly" alt="인건비계" value="${memSalary.total_salary_amt}">
                        </td>
                        <td class="text-right">
                            <input type="text" class="form-control text-right" id="center_out_amt" name="center_out_amt" format="decimal" readonly="readonly" alt="센터정비계" value="${memSalary.center_out_amt}">
                        </td>
                        <td class="text-right">
                            <input type="text" class="form-control text-right" id="comm_amt" name="comm_amt" format="decimal" readonly="readonly" alt="공통비계" value="${memSalary.comm_amt}">
                        </td>
                        <td class="text-right">
                            <input type="text" class="form-control text-right" id="total_amt" name="total_amt" format="decimal" readonly="readonly" alt="합계" value="${memSalary.total_amt}">
                        </td>
                    </tr>
                    </tbody>
                </table>
            </div>
            <div class="col-7">
                <table class="table-border mt5">
                    <colgroup>
                        <col width="33%">
                        <col width="33%">
                        <col width="34%">
                    </colgroup>
                    <thead>
                    <tr>
                        <th class="title-bg">지출 대비 순익률 (%)</th>
                        <th class="title-bg">과년도 대비 당년도 성장률 (%)</th>
                        <th class="title-bg">당년도 대비 차년도 목표 성장률 (%)</th>
                    </tr>
                    </thead>
                    <tbody>
                    <tr>
                        <td class="text-right">
                            <input type="text" class="form-control text-center" id="profit_rate" name="profit_rate" format="decimal" readonly="readonly" alt="지출 대비 순익률" value="">
                        </td>
                        <td class="text-right">
                            <input type="text" class="form-control text-center" id="now_grow_rate" name="now_grow_rate" format="decimal" readonly="readonly" alt="과년도 대비 당년도 성장률" value="">
                        </td>
                        <td class="text-right">
                            <input type="text" class="form-control text-center" id="next_grow_rate" name="next_grow_rate" format="decimal" readonly="readonly" alt="당년도 대비 차년도 목표 성장률" value="">
                        </td>
                    </tr>
                    </tbody>
                </table>
            </div>
        </div>
        <!-- /당년지출 계 -->
        <div class="btn-group mt10">
            <div class="right">
                <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
            </div>
        </div>
	</div>
	<!-- /팝업 -->
</form>
</body>
</html>