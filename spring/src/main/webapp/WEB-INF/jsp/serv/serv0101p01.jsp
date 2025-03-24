<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 정비 > 정비지시서 > null > 정비지시서 상세
-- 작성자 : 성현우
-- 최초 작성일 : 2020-06-11 19:54:29
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

        // 4. 상담과 점검/정비 -> 구분
        var jobOrderTypeJson = JSON.parse('${codeMapJsonObj['JOB_ORDER_TYPE']}');

        // 5. 부품목록 -> 순정 (part_production_cd)
        var partProductionCdJson = JSON.parse('${codeMapJsonObj['PART_PRODUCTION']}');

        // 4. 상담과 점검/정비에서 사용
        var rowNum = '${rowNum}';

        // 6. 정비작업 -> 정비일자
        var workDt;

        var maxSeqNo = '${maxSeqNo}'

        var item = ${resultInfo};
        var pro = ${promotionMap};
        var happyCallInfo = ${happyCallMap};
        var sessionCehckTime = 1000 * 60 * 5;

        var originFileList = [];
        var removeFileArr = [];

        var workRowIndex;

        $(document).ready(function() {
            // 4. 상담과 점검/정비 Grid
            createAUIGridReportOrder();
            // 5. 부품내역 Grid
            createAUIGridReportPart();
            // 6. 정비작업 Grid
            createAUIGridReportWork();

            // 초기 Setting
            fnInit();
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

			// 21.08.03 (SR:12096) 미수금이있거나, 외상매출금지고객에 문구 알림 추가. - 황빛찬
			// 21.08.04 (SR:12145) YK렌탈장비는 알림 제외 추가 - 황빛찬
			if (item.cust_no != "20130603145119670" && (item.deal_gubun_cd == "9" || item.misu_amt > 0)) {
				alert("외상매출금지(미수고객)입니다. 정비전에 확인 바랍니다.");
			}

            //자율배정업무 배정자 동기화
            if(${selfAssignBean} != "" && ${selfAssignBean} != null) {
                var selfAssignBean = ${selfAssignBean};
                $M.setValue("self_assign_no",selfAssignBean.self_assign_no);
                if(selfAssignBean.assign_mem_no != "" && ($M.getValue("job_status_cd") == "0" || $M.getValue("job_status_cd") == "10")) {
                    $M.setValue("assign_date", selfAssignBean.assign_date);
                    $M.setValue("eng_mem_name", selfAssignBean.assign_mem_name);
                    $M.setValue("eng_mem_no", selfAssignBean.assign_mem_no);
                    var assignMemNo = "${SecureUser.mem_no }"; // 접수자도 기사 (작업지시서 작성을 기사가 함)
                    $M.setValue("assign_mem_no", assignMemNo);
                    $M.setValue("assign_change_yn", "Y");
                    $M.setValue("job_status_cd", "5");

                    setTimeout(function() {
                        goSave()
                    }, 100);
                }

                $("button[name='__mem_search_btn']").prop("disabled", true);
                $("#s_web_id").prop("disabled", true);

            }

            $("#in_dt,#reserve_repair_ti,#reserve_repair_ed_ti").change(function() {
                if($M.getValue("job_status_cd") == "5" || $M.getValue("job_status_cd") == "11"){
                    $("#_goSendSmsReserve").prop("disabled",false);
                }
            });
        });

        // 초기 Setting
        function fnInit() {
            rowNum = $M.toNum(rowNum) + 1;

            // 파일세팅
            <c:forEach var="file" items="${fileList}">
                var temp = {
                    file_seq : '${file.file_seq}',
                    seq_no : '${file.seq_no}',
                    pic_type : '${file.pic_type}',
                }
                originFileList.push(temp);
                <%--fnPrintFile('${file.file_seq}', `${file.file_name}`, 'R');--%>
                fnPrintFile('${file.file_seq}', '${file.file_name}', 'R');
            </c:forEach>
            <c:forEach var="jobFile" items="${jobFileList}">
                var temp = {
                    file_seq : '${jobFile.file_seq}',
                    seq_no : '${jobFile.seq_no}',
                    pic_type : '${jobFile.pic_type}',
                }
                originFileList.push(temp);
                fnPrintFile('${jobFile.file_seq}', '${jobFile.file_name}', 'J');
            </c:forEach>

            <c:forEach var="custFile" items="${custFileList}">
                fnPrintFile('${custFile.file_seq}', '${custFile.file_name}', 'C');
            </c:forEach>

            <c:if test="${not empty result.file_seq_before and result.file_seq_before ne '0' and result.file_seq_before ne ''}">
                var fileSeqBefore = '${result.file_seq_before}'
                $('.att_file_divM').append('<button type="button" class="btn btn-outline-primary mr5" onclick="javascript:fileDownload(' + fileSeqBefore + ')">1차 서명완료</button>');
            </c:if>
            <c:if test="${result.modu_modify_yn_before eq 'Y'}">
                $('.att_file_divM').append('(수정중)');
            </c:if>

            <c:if test="${not empty result.file_seq_after and result.file_seq_after ne '0' and result.file_seq_after ne ''}">
                var fileSeqAfter = '${result.file_seq_after}'
                $('.att_file_divM').append('<button type="button" class="btn btn-outline-primary mr5" onclick="javascript:fileDownload(' + fileSeqAfter + ')">2차 서명완료</button>');
            </c:if>
            <c:if test="${result.modu_modify_yn_after eq 'Y'}">
                $('.att_file_divM').append('(수정중)');
            </c:if>

            var jobStatusCd = "${result.job_status_cd}";
            if(jobStatusCd == "7" || jobStatusCd == "9") {
                $("#main_form :input").prop("disabled", true);
                $("#main_form :button").prop("disabled", false);

                $("#_goEngProcess").prop("disabled", true);
                $("#_goChangeBreg").prop("disabled", true);
                $("#in_dt").prop("disabled", true);
            }

            // if(jobStatusCd != "5" && jobStatusCd != "11") {
            if(jobStatusCd != "5") {
                $("#_goSendSmsReserve").prop("disabled", true);
            }

            var ableStausCdArr = ["1", "5", "10", "11"];

            if(!ableStausCdArr.includes(jobStatusCd)) {
                $("#reserve_repair_ti").prop("disabled", true);
                $("#reserve_repair_ed_ti").prop("disabled", true);
            }

            if(${result.repair_complete_yn ne 'Y'}) {
                $("input[name='att_file_seqR']").prop("disabled", false);
                $("input[name='att_file_seqJ']").prop("disabled", false);
            }

            var cap = "${result.j_cap_cnt}";
            if(cap == 0) {
                $M.setValue("cap_use_yn", "N");
                $M.setValue("cap_check_yn", "Y");
            } else {
                $M.setValue("cap_use_yn", "Y");
            }

            if(cap == 0) {
                if("${result.cap}" == "적용") {
                    $("#cap").html("미적용 [CAP적용]");
                } else {
                    $("#cap").html("미적용");
                }
                $M.setValue("cap_cnt", "0");
                $M.setValue("next_cap_cnt", "1");
                $M.setValue("cap_plan_dt", "");
            } else {
                $("#cap_plan_dt").prop("disabled", false);
            }

            // SA-R 장비일 시 운행정보 버튼 노출
            if('${result.sar_yn}' == 'Y') {
                $("#sar_oper_btn").css("display", "inline-block");
            } else {
                $("#sar_oper_btn").css("display", "none");
            }

            var engMemName = '${result.eng_mem_name}';
            var webId = '${result.web_id}';

            $M.setValue("s_web_id", webId);
            $M.setValue("___mem_name", engMemName);

            // qr코드 그리기
            if (${not empty result.qr_no}) {
                new QRCode(document.getElementById("qr_image"), {
                    text: '${result.qr_no}',
                    width: 30,
                    height: 30,
                });
                $("#qr_image > img").css({"margin":"auto"});
            } else {
                $("#qr_image").html("QR미등록");
            }
            
            // 보유 쿠폰 노출 조건
            if('${page.fnc.F00564_003}' === 'Y' && ${couponListSize > 0}) {
                $("#_goCustCoupon").css("display", "inline-block");
            } else {
                $("#_goCustCoupon").css("display", "none");
            }
            
            // 접수구분 APP 일 경우 변경 불가능 처리
          if(${result.receipt_type_rt eq 'A'}) {
            $("#receipt_type_rt_r").prop("disabled", true);
            $("#receipt_type_rt_t").prop("disabled", true);
          } else {
            $("#receipt_type_rt_a").prop("disabled", true);
          }

            // 정비종류 (입고, 출장)
            fnJobCaseTi();
            // 6. 정비일시 -> 시간 계산
            fnCalcTime();
            // 출장지역 선택 및 출장비(예상) 계산
            fnSetSvcInfo('init');
            // 출장비용(최종) 계산
            fnChangeTravelPrice('init');

            fnSetPromotion();
            fnSetFileInfo();

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

        function fnCalcPlanTravelPrice() {
            var travelHour = $M.toNum($M.getValue("travel_hour"));
            var travelHourPrice = $M.toNum($M.getValue("travel_hour_price"));
            // tot_travel_hour_price
            var totTravelHourPrice = travelHour * travelHourPrice;

            totTravelHourPrice = Math.floor(totTravelHourPrice);
            $M.setValue("tot_travel_hour_price", totTravelHourPrice);

            fnChangetTravelExpense();
            fnChangePrice();
        }

        function fnSetPromotion() {
            for(var i=0; i<pro.length; i++) {
                var innerHtml = "";

                innerHtml += '<tr>';
                innerHtml += '	<th class="text-right">프로모션기간</th>';
                innerHtml += '	<td>';
                innerHtml += '		<span id="pro_period_' + i + '"></span>';
                innerHtml += '      <button class="btn btn-primary-gra" onclick="javascript:fnApplyPromotion(' + i + ');">적용</button>';
                innerHtml += '	</td>';
                innerHtml += '	<th class="text-right">프로모션첨부</th>';
                innerHtml += '	<td id="file_search_td' + i + '">';
                innerHtml += '	</td>';
                innerHtml += '	<td id="file_name_td' + i + '" class="dpn" colspan="3">';
                innerHtml += '		<div class="table-attfile" id="file_name_div' + i + '">';
                innerHtml += '		</div>';
                innerHtml += '	</td>';
                innerHtml += '<input type="hidden" id="apply_condition_ao_' + i + '" name="apply_condition_ao_' + i + '">';
                innerHtml += '<input type="hidden" id="condition_aio_' + i + '" name="condition_aio_' + i + '">';
                innerHtml += '<input type="hidden" id="condition_ard_' + i + '" name="condition_ard_' + i + '">';
                innerHtml += '<input type="hidden" id="condition_acs_' + i + '" name="condition_acs_' + i + '">';
                innerHtml += '<input type="hidden" id="benefit_type_md_' + i + '" name="benefit_type_md_' + i + '">';
                innerHtml += '<input type="hidden" id="benefit_amt_' + i + '" name="benefit_amt_' + i + '">';
                innerHtml += '<input type="hidden" id="type_wares_yn_' + i + '" name="type_wares_yn_' + i + '">';
                innerHtml += '<input type="hidden" id="type_wares_dc_rate_' + i + '" name="type_wares_dc_rate_' + i + '">';
                innerHtml += '<input type="hidden" id="type_trip_yn_' + i + '" name="type_trip_yn_' + i + '">';
                innerHtml += '<input type="hidden" id="type_trip_dc_rate_' + i + '" name="type_trip_dc_rate_' + i + '">';
                innerHtml += '<input type="hidden" id="type_part_yn_' + i + '" name="type_part_yn_' + i + '">';
                innerHtml += '<input type="hidden" id="type_part_dc_rate_' + i + '" name="type_part_dc_rate_' + i + '">';
                innerHtml += '<input type="hidden" id="part_output_price_yn_' + i + '" name="part_output_price_yn_' + i + '">';
                innerHtml += '<input type="hidden" id="part_exclude_yn_' + i + '" name="part_exclude_yn_' + i + '">';
                innerHtml += '<input type="hidden" id="ex_part_no_' + i + '" name="ex_part_no_' + i + '">';
                innerHtml += '<input type="hidden" id="pro_seq_' + i + '" name="pro_seq_' + i + '">';
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

                $M.setValue("apply_condition_ao_" + i, pro[i].apply_condition_ao);
                $M.setValue("condition_aio_" + i, pro[i].condition_aio);
                $M.setValue("condition_ard_" + i, pro[i].condition_ard);
                $M.setValue("condition_acs_" + i, pro[i].condition_acs);
                $M.setValue("benefit_type_md_" + i, pro[i].benefit_type_md);
                $M.setValue("benefit_amt_" + i, pro[i].benefit_amt);
                $M.setValue("type_wares_yn_" + i, pro[i].type_wares_yn);
                $M.setValue("type_wares_dc_rate_" + i, pro[i].type_wares_dc_rate);
                $M.setValue("type_trip_yn_" + i, pro[i].type_trip_yn);
                $M.setValue("type_trip_dc_rate_" + i, pro[i].type_trip_dc_rate);
                $M.setValue("type_part_yn_" + i, pro[i].type_part_yn);
                $M.setValue("type_part_dc_rate_" + i, pro[i].type_part_dc_rate);
                $M.setValue("part_output_price_yn_" + i, pro[i].part_output_price_yn);
                $M.setValue("part_exclude_yn_" + i, pro[i].part_exclude_yn);
                $M.setValue("ex_part_no_" + i, pro[i].ex_part_no);
                $M.setValue("pro_seq_" + i, pro[i].pro_seq);
            }
        }

        function fnApplyPromotion(index) {
            var applyConditionAo = $M.getValue("apply_condition_ao_" + index);
            var conditionAio = $M.getValue("condition_aio_" + index);
            var conditionArd = $M.getValue("condition_ard_" + index);
            var conditionAcs = $M.getValue("condition_acs_" + index);
            var jobCaseTi = $M.getValue("job_case_ti");
            var receiptTypeRt = $M.getValue("receipt_type_rt");
            var jobTypeCd = $M.getValue("job_type_cd");

            // 입고,출장 체크
            var aioYn = true;
            var ardYn = true;
            var acsYn = true;
            if(applyConditionAo == "A") {
                if (conditionAio != "A" && (conditionAio != jobCaseTi)) {
                    aioYn = false;
                }
                // 예약(사전), 당일 체크
                if (conditionArd != "A" && (conditionArd != receiptTypeRt)) {
                    ardYn = false;
                }
                // 정비 종류 체크
                if (conditionAcs != "A") {
                    if (conditionAcs == "C" && cap == "미적용") {
                        acsYn = false;
                    }

                    if (conditionAcs == "S" && (jobTypeCd != "2" || jobTypeCd != "3")) {
                        acsYn = false;
                    }
                }

                if(!(aioYn && ardYn & acsYn)) {
                    alert("적용대상이 아닙니다.");
                    return;
                }
            } else {
                if (conditionAio != "A" && (conditionAio != jobCaseTi)) {
                    aioYn = false;
                }
                // 예약(사전), 당일 체크
                if (conditionArd != "A" && (conditionArd != receiptTypeRt)) {
                    ardYn = false;
                }
                // 정비 종류 체크
                if (conditionAcs != "A") {
                    if (conditionAcs == "C" && cap == "미적용") {
                        acsYn = false;
                    }

                    if (conditionAcs == "S" && (jobTypeCd != "2" || jobTypeCd != "3")) {
                        acsYn = false;
                    }
                }

                if(!(aioYn || ardYn || acsYn)) {
                    alert("적용대상이 아닙니다.");
                    return;
                }
            }

            var frm = document.main_form;
            $M.setValue("s_pro_seq", $M.getValue("pro_seq_" + index));
            $M.setValue("s_job_report_no", $M.getValue("job_report_no"));
            frm = $M.toValueForm(frm);

            var concatCols = [];
            var concatList = [];

            var gridIds = [auiGridReportPart, auiGridReportOrder];
            for (var i = 0; i < gridIds.length; ++i) {
                concatList = concatList.concat(AUIGrid.exportToObject(gridIds[i]));
                concatCols = concatCols.concat(fnGetColumns(gridIds[i]));
            }

            var gridFrm = fnGridDataToForm(concatCols, concatList);
            $M.copyForm(gridFrm, frm);

            $M.goNextPageAjax(this_page + "/promotion/apply", gridFrm, {method : "POST"},
                function(result) {
                    if(result.success) {
                        if(result.total_amt == null) {
                            $M.setValue("work_total_amt", result.work_total_amt);
                            $M.setValue("final_travel_expense", result.travel_final_expense);
                            $M.setValue("part_total_amt", result.part_total_amt);
                            fnChangePrice();
                        } else {
                            $M.setValue("total_amt", result.total_amt);
                            $M.setValue("final_total_vat_amt", Math.floor(result.total_amt * 1.1));
                        }
                    };
                }
            );
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
                $("#cap").html("미적용");
                $M.setValue("cap_cnt", "0");
                $M.setValue("next_cap_cnt", "1");
            } else {
                $("#plan_dt").prop("disabled", false);
            }
            $M.setValue("plan_dt", "");
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

        // 해피콜
        function goDetail() {
            var params = {
                "job_report_no" : happyCallInfo.job_report_no,
                "survey_seq" : happyCallInfo.survey_seq
            };
            var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1400, height=650, left=0, top=0";

            // 미발송이면 -> serv040404p04.jsp
            if(happyCallInfo.sms_send_seq == "") {
                params.send_yn = "N";
                $M.goNextPage('/serv/serv040404p04', $M.toGetParam(params), {popupStatus : popupOption});
            } else {
                // 발송이면 -> serv040404p02.jsp
                $M.goNextPage('/serv/serv040404p02', $M.toGetParam(params), {popupStatus : popupOption});
            }
        }

// -> 4. 상담과 점검/정비 관련 시작
        // 4. 상담과 점검/정비 -> 예상비용 합계 계산
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

        // 4. 상담과 점검/정비 -> 발생비용 합계 계산
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

        // 4. 상담과 점검/정비 -> 자주쓰는작업 팝업
        function goBookmark() {
            var param = {};
            param.parent_js_name = "fnSetJobReportOrder";
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

        // 4. 상담과 점검/정비 -> 자주쓰는작업 팝업 Data Setting
        function fnSetJobReportOrder(data) {
            var item = new Object();
            var parentRowId = null;
            for(var i=0; i < data.length; i++) {
                item.job_order_type_cd = data[i].item.job_order_type_cd;
                item.order_text = data[i].item.order_text;
                item.plan_work_amt = data[i].item.plan_work_amt;
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
                item.work_yn = "Y";

                // 부모행일 경우
                // if(data[i].item._$depth == 1) {
                    AUIGrid.addRow(auiGridReportOrder, item, 'last');

                //     var selectedItems = AUIGrid.getSelectedItems(auiGridReportOrder);
                //     var selItem = selectedItems[0].item;
                //     parentRowId = selItem._$uid;
                // } else {
                //     // 자식일 경우
                //     item.parentRowId = parentRowId;
                //     AUIGrid.addTreeRow(auiGridReportOrder, item, parentRowId, 'first');
                // }
                rowNum++;
            }

            // 4. 상담과 점검/정비 -> 예상비용 합계 계산
            fnCalcOrderPlanWorkAmt();
            // 4. 상담과 점검/정비 -> 최종비용 합계 계산
            fnCalcOrderWorkAmt();
            fnCalcOrderWorkHour();
        }

        // 4. 상담과 점검/정비 -> 미결 사항 추가.
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
                item.sort_no = "0";
                item.row_num = rowNum;
                item.apply_yn = "N";

                // if(data[i]._$depth == 1) {
                    AUIGrid.addRow(auiGridReportOrder, item, 'last');

                //     var selectedItems = AUIGrid.getSelectedItems(auiGridReportOrder);
                //     var selItem = selectedItems[0].item;
                //     parentRowId = selItem._$uid;
                // } else {
                //     item.parentRowId = parentRowId;
                //     AUIGrid.addTreeRow(auiGridReportOrder, item, parentRowId, 'first');
                // }
                rowNum++;
            }

            // 4. 상담과 점검/정비 -> 예상비용 합계 계산
            fnCalcOrderPlanWorkAmt();
        }

        // 4. 상담과 점검/정비 -> 비용반영
        function goApplyAmt() {
            var data = AUIGrid.getCheckedRowItems(auiGridReportOrder);
            if(data.length == 0) {
                alert("비용반영 처리 할 내용을 먼저 체크해 주세요.");
                return;
            }

            for(var i in data) {
                // 비용반영 처리 한 Data의 apply_yn cell값을 Y로 변경
                var changData = {
                    "apply_yn" : "Y",
                    "work_yn" : "Y"
                };

                AUIGrid.updateRow(auiGridReportOrder, changData, data[i].rowIndex);
            }

            // 비용반영 처리 한 Data는 unCheck
            AUIGrid.addUncheckedRowsByValue(auiGridReportOrder, "apply_yn", "Y");
            // 4. 상담과 점검/정비 -> 발생비용 합계 계산
            fnCalcOrderWorkAmt();
        }

        // 4. 상담과 점검/정비 -> 행추가
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
                item.work_yn = "N";
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

        // 4.상담과 점검/정비 -> 필수 항목 체크
        function fnCheckOrderGridEmpty() {
            return AUIGrid.validateGridData(auiGridReportOrder, ["order_text", "plan_work_amt", "work_amt", "work_hour"], "필수 항목은 반드시 값을 입력해야합니다.");
        }

        // 예상비용 or 발생비용 변경 시 -> 7. 비용 공임 부분 적용
        function auiOrderCellEditHandler(event) {
            switch(event.type) {
                case "cellEditEnd" :
                    if(event.dataField == "plan_work_amt") {
                        fnCalcOrderPlanWorkAmt();
                    } else if(event.dataField == "work_amt") {
                        fnCalcOrderWorkAmt();
                    } else if (event.dataField == "work_hour") {
                        fnCalcOrderWorkHour();
                    }
                    break;
                case "cellEditBegin" :
                    var checkArr = ["plan_work_amt", "work_amt", "work_hour"]
                    if(checkArr.indexOf(event.dataField) > -1 && event.item.bookmark_type_jr == 'R' && (event.item.sort_no != "0" || event.item.up_job_report_order_seq != "0")) {
                        return false;
                    }

                    // 서비스쿠폰 일 경우 점검 이름 변경 X
                    console.log(event);
                    if(event.dataField == "order_text" && event.item.cust_svc_coupon_no) {
                        return false;
                    }
                    break;
            }
        }
// -> 4. 상담과 점검/정비 관련 종료
// -> 5. 부품목록 관련 시작
        // 5. 부품목록 -> 금액 합계 계산
        function fnCalcPartPrice() {
            var data = AUIGrid.getGridData(auiGridReportPart);
            // plan_part_total_amt
            var planPartTotalAmt = 0;
            var partTotalAmt = 0;
            for(var i in data) {
                if(data[i].part_cmd != "D") {
                    planPartTotalAmt += $M.toNum(data[i].amount);
                    partTotalAmt += $M.toNum(data[i].bill_amount);
                }
            }

            // 7. 비용 -> 부품(예상)
            $M.setValue("plan_part_total_amt", planPartTotalAmt);
            $M.setValue("part_total_amt", partTotalAmt);

            // 7.비용 -> 합계, 총금액(VAT포함) 계산
            fnChangePrice();
        }

        // 수량 or 단가 변경 시 -> 7.비용 부품(예상)부분 적용
        function auiCellEditHandler(event) {
            switch(event.type) {
                case "cellEditEnd" :
                    if(event.dataField == "qty" || event.dataField == "unit_price") {
                    	var qty = $M.toNum(event.item.qty);
                        var unitPrice = $M.toNum(event.item.unit_price);
                        var amount = qty * unitPrice;
                        AUIGrid.updateRow(auiGridReportPart, {"amount" : amount}, event.rowIndex);

                        var use_qty = $M.toNum(event.item.use_qty);
                        var bill_amount = use_qty * unitPrice;
                        AUIGrid.updateRow(auiGridReportPart, {"bill_amount" : bill_amount}, event.rowIndex);

                        // 5. 부품목록 -> 금액 합계 계산
                        fnCalcPartPrice();
                    } else if(event.dataField == "plan_work_amt") {
                        var gridData = AUIGrid.getGridData(auiGridReportOrder);
                        var planWorkAmt = 0;
                        for(var i in gridData) {
                            planWorkAmt += $M.toNum(gridData[i].plan_work_amt);
                        }
                        $M.setValue("plan_work_total_amt", planWorkAmt);
                    } else if(event.dataField == "work_amt") {
                        var gridData = AUIGrid.getGridData(auiGridReportOrder);
                        var workAmt = 0;
                        for(var i in gridData) {
                            if(gridData[i].apply_yn == "Y") {
                                workAmt += $M.toNum(gridData[i].work_amt);
                            }
                        }
                        $M.setValue("work_total_amt", workAmt);
                    }  else if (event.dataField == "work_hour") {
                        fnCalcOrderWorkHour();
                    } else if(event.dataField == "use_qty") {
                        var item = AUIGrid.getItemByRowIndex(auiGridReportPart, event.rowIndex);
                        var outQty = $M.toNum(item.out_qty); // 출고수량
                        var returnQty = $M.toNum(item.return_qty); // 반품수량
                        var useQty = $M.toNum(item.use_qty); // 사용수량
                        var amount = $M.toNum(item.amount); // 금액
                        var unitPrice = $M.toNum(item.unit_price); // 단가
                        var billAmount = 0;

                        var scanQty = (outQty - returnQty);

                        if(scanQty < useQty) {
                            alert("사용수량은 출고수량에서 반품수량을 뺀 값보다 클 수 없습니다.");
                            var changeData = {
                                "use_qty" : 0,
                                "bill_amount" : 0
                            };

                            AUIGrid.updateRow(auiGridReportPart, changeData, event.rowIndex, false);
                            fnCalcPartPrice();
                        } else {
                            billAmount = useQty * unitPrice;
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
                    } else if(event.dataField == "part_no") {
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
//                                 unit_price : item.sale_price,
                                unit_price : unitPrice,
//                                 amount : 1 * $M.toNum(item.sale_price),
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

        //부품조회 창 열기
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

        function goPartList() {
            var items = AUIGrid.getAddedRowItems(auiGridReportPart);
            for(var i in items) {
                if(items[i].part_no == "") {
                    alert("추가된 행을 입력하고 시도해주세요.");
                    return;
                }
            }

            var param = {
                's_warehouse_cd' : $M.getValue("org_code"),
                's_only_warehouse_yn' : "N",	// 센터일 때만 Y로 넘김 -> 전체 다 나오게 변경
                's_warning_check' : "Y", // 정비지시서 및 수주에서 부품조회시 alert가 다르게 나오고 리턴받는 list를 다르게 받기위해 생성
            };

            if(fnCheckGridEmptyPart(auiGridReportPart)) {
                openSearchPartPanel('setPartInfo', 'Y', $M.toGetParam(param));
            }
        }

        // 부품 Data Setting
        function setPartInfo(rowArr) {
            // 부품조회 창에서 받아온 값 중복체크
//             for(var i in rowArr) {
//                 var rowItems = AUIGrid.getItemsByValue(auiGridReportPart, "part_no", rowArr[i].part_no);
//                 if(rowItems.length != 0) {
//                     alert("부품번호를 다시 확인하세요.\n" + rowArr[i].part_no + " 이미 입력한 부품번호입니다.");
//                     return false;
//                 }
//             }

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

        // 그리드 빈값 체크
        function fnCheckGridEmptyPart() {
            return AUIGrid.validateGridData(auiGridReportPart, ["part_no", "part_name", "unit_price"], "필수 항목은 반드시 값을 입력해야합니다.");
        }

        // 정비지시서 부품출고(반품)처리 팝업
        function goPopupPart() {
            if($M.getValue("assign_mem_no") == "") {
                alert("기사 배정을 먼저 진행해주세요.");
                return;
            }

            // [13648] 부품출고처리 버튼 클릭 시, 해당 정비지시서의 ‘정비부품 입/출고처리’ 팝업 호출  - 김경빈
            var partListSize = ${partListSize};
            if(partListSize == 0) {
                alert("부품이 추가 되어 있어야 합니다.");
                return;
            }

            var params = {
                "doc_barcode_no" : '${result.doc_barcode_no}'
            };

            $M.goNextPage('/part/part0203p02', $M.toGetParam(params), {popupStatus : ""});
            // $M.goNextPage('/serv/serv0101p09', $M.toGetParam(params), {popupStatus : ""});
        }

        // 체크부품삭제
        function fnRemove() {
            var checkItems = AUIGrid.getCheckedRowItems(auiGridReportPart);

            if (checkItems.length == 0) {
                alert("삭제할 부품을 체크해주세요.");
                return;
            }

            var partNoArr = [];
            var seqNoArr = [];

            for(var i = checkItems.length -1; i >= 0; i--) {
                var item = checkItems[i].item;
                if(item.job_report_no == undefined || item.job_report_no == null || item.job_report_no == "") {
                    AUIGrid.removeRow(auiGridReportPart, checkItems[i].rowIndex);
                } else {
                    partNoArr.push(item.part_no);
                    seqNoArr.push(item.seq_no);
                }
            }

            // var gridData = fnCheckedGridDataToForm(auiGridReportPart);
            if(partNoArr.length > 0) {
                var param = {
                    job_report_no : $M.getValue("job_report_no"),
                    part_no_str : partNoArr.join("#"),
                    seq_no_str : seqNoArr.join("#"),
                    cmd : 'U',
                }

                $M.goNextPageAjaxMsg("선택한 부품들을 삭제하시겠습니까?", this_page + "/remove/part", $M.toGetParam(param), {method: "POST", loader: false},
                    function (result) {
                        if (result.success) {
                            AUIGrid.setGridData(auiGridReportPart, result.list);
                            fnCalcPartPrice();
                        }
                    }
                );
            } else {
                fnCalcPartPrice();
            }
        }

        // 부품분출요청서
        function goOutRequestForm() {
        	openReportPanel('serv/serv0101p01_05.crf','s_job_report_no=' + $M.getValue("job_report_no"));
        }

        // 부품분출요청 쪽지발송
        function goNoteSend() {
            var params = {
                "ref_key" : $M.getValue("job_report_no")
            };

            var msg = "부품분출요청 쪽지를 발송하시겠습니까?";
            // 서비스일지 조회
            $M.goNextPageAjaxMsg(msg, this_page + "/save/paperSend", $M.toGetParam(params), {method: 'POST'},
                function (result) {
                    if (result.success) {
                        alert("부품분출요청 쪽지를 발송하였습니다.");
                    }
                }
            );
        }
// -> 5. 부품목록 관련 종료
// -> 6. 정비작업 관련 시작
        // 정비작업 - 시작
        function goStartTi(rowIndex, startTi) {
            var jobCaseT = false;
            // 정비종류 '출장'인 경우 출장위치 필수체크
            if ($M.getValue("job_case_ti") == "T") {
                if ($M.getValue("travel_area_name") == "") {
                    alert("정비종류가 출장인 경우 출장위치는 필수입력입니다.");
                    $("#travel_area_name").focus();
                    return;
                }
                jobCaseT = true;
            }

            if(startTi != 'N') {
                alert("정비시작 시작은 변경이 불가능합니다.");
            } else {
                if("${SecureUser.mem_no}" != $M.getValue("eng_mem_no")){
                    alert("배정직원만 정비시작이 가능합니다.");
                    return;
                }

                // Q&A 19500 Re14. 정비시작은 예약확정 단계에서만 가능하도록 변경
                if($M.getValue("job_status_cd") != "11"){
                    alert("예약확정 상태에서만 정비시작이 가능합니다.\n예약확정 후 다시 시도해주세요.");
                    return;
                }

                if($M.getValue("job_mem_no") == ""){
                    if(confirm("현장의 여건과 작업환경이 올바르고 안전한 정비에 적합하지 않는다 판단되는 경우, 작업자는 정비를 거부하고, 환경을 적극적으로 개선할 의무가 있습니다")){
                        $M.setValue("job_mem_no", "${SecureUser.mem_no}");
                        $M.setValue("job_confirm_date", $M.getCurrentDate("yyyyMMddHHmmss"));
                    } else {
                        return;
                    }
                }

                AUIGrid.setCellValue(auiGridReportWork, rowIndex, "edit", 'N');
                AUIGrid.setCellValue(auiGridReportWork, rowIndex, "start_ti", $M.getCurrentDate('HHmm'));
                AUIGrid.setCellValue(auiGridReportWork, rowIndex, "v_start_ti", $M.getCurrentDate('HH:mm'));
            }

            // 정비종류 '출장'인 경우 문자전송 팝업 호출 (종료 전까지)
            var endYn = AUIGrid.getCellValue(auiGridReportWork, rowIndex, "end_ti") != ''? 'Y' : 'N';
            if (jobCaseT && endYn == 'N') {
                workRowIndex = rowIndex;
                goSave('SMS');
            }
        }

        // 정비작업 - 문자전송(출장)
        function goSmsSendTravel() {
            var rowIndex = workRowIndex;
            var params = {
                "row_index" : rowIndex,
                "job_report_no" : $M.getValue("job_report_no"),
                "as_no" : $M.getValue("as_no"),
                "seq_no" : AUIGrid.getCellValue(auiGridReportWork, rowIndex, "seq_no"),
                "eng_mem_no" : $M.getValue("eng_mem_no"),
                "travel_area_name" : $M.getValue("travel_area_name"),
                "hp_no" : $M.getValue("hp_no"),
                "start_ti" : $M.getCurrentDate('HHmm'),
                "cust_name" : $M.getValue("cust_name"),
                "parent_js_name" : "fnSetSmsSendSeq"
            }
            $M.goNextPage('/serv/serv0101p0101', $M.toGetParam(params), {popupStatus : ""});
        }

        // 발송한 문자 seq 세팅
        function fnSetSmsSendSeq(rowIndex, smsSendSeq) {
            var seqNo = AUIGrid.getCellValue(auiGridReportWork, rowIndex, "seq_no");
            AUIGrid.setCellValue(auiGridReportWork, rowIndex, "sms_send_seq", smsSendSeq);
        }

        // 정비작업 - 종료
        function goEndTi(rowIndex, startTi, endTi) {
            if(startTi == 'N') {
                alert("정비시작 먼저 진행해주세요.");
                return;
            }

            if(endTi != 'N') {
                alert("정비종료 시간은 변경이 불가능합니다.");
                return;
            }

            AUIGrid.setCellValue(auiGridReportWork, rowIndex, "end_ti", $M.getCurrentDate('HHmm'));
            AUIGrid.setCellValue(auiGridReportWork, rowIndex, "v_end_ti", $M.getCurrentDate('HH:mm'));

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
        // Q&A 17898 : endTi -> seqNo 로 변경
        function goServiceLog(rowIndex, seqNo) {
            // [재호] [3차&A 15595] 미작성 상태 추가
            // - 정비 시작 시간만 있으면 일지 작성 가능하게 변경
            // if(endTi == 'N') {
            //     alert("서비스 종료를 먼저 진행해주세요.");
            //     return;
            // }

            var saveYn = AUIGrid.getCellValue(auiGridReportWork, rowIndex, "save_yn");
            if(saveYn == "N") {
                alert("저장 후 일지를 작성할 수 있습니다.");
                return;
            }

            // AUIGrid.updateRow(auiGridReportWork, { "seq_no" : rowIndex }, rowIndex);
            // var seqNo = AUIGrid.getCellValue(auiGridReportWork, rowIndex, "seq_no");
            var workDt = AUIGrid.getCellValue(auiGridReportWork, rowIndex, "work_dt");

            var params = {
                "s_job_report_no" : $M.getValue("job_report_no"),
                "s_seq_no" : seqNo,
            };

            // 서비스일지 조회
            $M.goNextPageAjax(this_page + "/search", $M.toGetParam(params), {method : "GET"},
                function(result) {
                    if(result.success) {
                        var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=900, left=0, top=0";
                        // if(typeof result.asRepairMap == "object" || typeof result.asRepairMap != "undefined") {
                        params.s_as_no = result.asRepairMap.as_no;
                        $M.goNextPage('/serv/serv0102p01', $M.toGetParam(params), {popupStatus : popupOption});
                    }
                }
            );
        }

        // 정비작업-행추가
        function fnAdd() {
            if($M.getValue("eng_mem_no") == "") {
                alert("배정처리 후 추가가 가능합니다.");
                return;
            }

            if($M.getValue("eng_mem_no") != "${SecureUser.mem_no}") {
                alert("배정직원만 정비작업을 추가할 수 있습니다.");
                return;
            }

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

            var param = {
                "job_report_no" : $M.getValue("job_report_no"),
            };

            // 서비스일지 결재 여부 조회
            $M.goNextPageAjax(this_page + "/work/check", $M.toGetParam(param), {method : "GET"},
                function(result) {
                    if(result.success) {
                        fnReportWorkAdd();
                    }
                }
            );
        }

        function fnReportWorkAdd() {
            if(fnCheckGridEmpty()) {
                var item = new Object();
                item.work_dt = workDt;
                item.start_ti = "";
                item.v_start_ti = "";
                item.end_ti = "";
                item.v_end_ti = "";
                item.edit = "Y";
                item.seq_no = 0;
                item.save_yn = "N";
                item.write_yn = "N";

                AUIGrid.addRow(auiGridReportWork, item, 'last');
            };
        }

        // 그리드 빈값 체크
        function fnCheckGridEmpty() {
            return AUIGrid.validateGridData(auiGridReportWork, ["work_dt", "v_start_ti", "v_end_ti"], "필수 항목은 반드시 값을 입력해야합니다.");
        }
// -> 6. 정비작업 관련 종료
// -> 3. 정비접수 관련 시작
        // 네이버 지도 호출
        function goMap() {
            var params = [{}];
            var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=750, height=420, left=0, top=0";
            $M.goNextPage('https://map.naver.com', $M.toGetParam(params), {popupStatus : popupOption});
        }

        // 출장지역 선택 및 출장비(예상) 계산
        function fnSetSvcInfo(init) {
            var svcTravel = $M.getValue("svc_travel_expense");
            var svcTravelArr = svcTravel.split("#");

            // 출장지역 일련번호
            $M.setValue("svc_travel_expense_seq", svcTravelArr[0]);
            // 거리_최소
            $M.setValue("distance_min", svcTravelArr[1]);
            // 거리_최대
            $M.setValue("distance_max", svcTravelArr[2]);
            // 출장비_최소
            $M.setValue("travel_expense_min", svcTravelArr[3]);
            // 출장비_최대
            $M.setValue("travel_expense_max", svcTravelArr[4]);

            // 출장비(예상)
            fnChangetTravelExpense(init);
        }

        // 7.비용 -> 출장비(예상)
        function fnChangetTravelExpense(init) {
            // 7. 비용 -> 출장비(예상)
            $M.setValue("plan_travel_expense", $M.getValue("tot_travel_hour_price"));

            // 7.비용 -> 합계, 총금액(VAT포함)
            fnChangePrice(init);
        }

        // 출장비용(최종) 계산
        function fnChangeTravelPrice(init) {
            // 출장비용 - 비용
            var travelExpense = $M.toNum($M.getValue("travel_expense"));
            // 출장비용 - 할인
            var travelDiscountAmt = $M.toNum($M.getValue("travel_discount_amt"));
            // 출장비용 - 최종
            var travelFinalExpense = travelExpense - travelDiscountAmt;

            // 출장비용 -> 최종
            $M.setValue("travel_final_expense", travelFinalExpense);
            // 7. 비용 -> 출장비(최종)
            $M.setValue("final_travel_expense", travelFinalExpense);

            // 7.비용 -> 합계, 총금액(VAT포함) 계산
            fnChangePrice(init);
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
                $("#in_dt").prop("disabled", true);

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
                $("#in_dt").prop("disabled", false);
                $("#in_dt").prop("readonly", false);

                $M.setValue("travel_expense", "0");
                $M.setValue("travel_discount_amt", "0");
                $M.setValue("travel_final_expense", "0");

                $("#travel_hour").prop("readonly", true);
                $M.setValue("travel_hour", "");
                $M.setValue("travel_hour_price", "");
                $M.setValue("tot_travel_hour_price", "");
            }
        }

        // 배정직원검색
        function goSearchEngMemInfo() {
            var param = {
                "s_mem_name" : $M.getValue("eng_mem_name")
            };

            openSearchMemberPanel('setMemberOrgMapPanel', $M.toGetParam(param));
        }

        // 배정직원 Setting
        function setMemberOrgMapPanel(data) {
            var assignMemNo = "${SecureUser.mem_no }";
            $M.setValue("assign_mem_no", assignMemNo);
            // 상태가 접수, 고객신청일 경우에만 배정직원 변경 시 배정상태로 변경
            if($M.getValue("job_status_cd") == "0" || $M.getValue("job_status_cd") == "10") {
                $M.setValue("job_status_cd", "5");
            }
            $M.setValue("assign_date", $M.getCurrentDate("yyyy-MM-dd HH:mm:ss"));
            $M.setValue("eng_mem_name", data.mem_name);
            $M.setValue("eng_mem_no", data.mem_no);

            goEngProcess();
        }

        // 배정처리
        function goEngProcess() {
            var assignMemNo = "${SecureUser.mem_no }";
            $M.setValue("assign_mem_no", assignMemNo);
            $M.setValue("assign_change_yn", "Y");

            if($M.getValue("eng_mem_name") == "") {
                alert("배정처리 직원을 먼저 선택해주세요.");
                return;
            }

            // var params = {
            //     "job_status_cd" : $M.getValue("job_status_cd"),
            //     "eng_mem_no" : $M.getValue("eng_mem_no"),
            //     "assign_mem_no" : assignMemNo,
            //     "job_report_no" : $M.getValue("job_report_no")
            // };
            //
            // var msg = "배정처리 전 저장하지 않은 정보가 있으면 먼저 저장을 해주세요.\n배정처리를 진행하시겠습니까?";
            //
            // $M.goNextPageAjaxMsg(msg, this_page + "/assign/update", $M.toGetParam(params), {method : 'POST'},
            //     function(result) {
            //         if(result.success) {
            //             alert("배정처리가 완료되었습니다.");
            //         }
            //     }
            // );

            setTimeout(function() {
                goSave()
            }, 100);
        }

        // 센터 Setting
        function setOrgMapCenterPanel(data) {
            $M.setValue("org_code", data.org_code);
            $M.setValue("org_name", data.org_name);
        }
// -> 3. 정비접수 관련 종료

        // 정비완료 -- 추후 보완(서비스일지, 콜등 관련 기능 개발 완료 시)
        function goProcessConfirm() {
            // if($("[name=att_file_seqR]").length < 4) {
            //     alert("정비사진은 최소 4장이 필요합니다.");
            //     return false;
            // }
            if("${result.job_status_cd}" != "11") {
                alert("예약확정 후 정비완료가 가능합니다.");
                return;
            }

            if($M.getValue("check_text") == "") {
                alert("점검리스트를 먼저 작성해주세요.");
                return;
            }
            $M.setValue("job_status_type", "R");

            if ($M.getValue("cap_use_yn") == "Y" && $M.getValue("job_status_type") != "D") {
                if ($M.getValue("cap_plan_dt") == "") {
                    alert("CAP예정일자를 입력해주세요.");
                    return;
                }
            }

            // 정비작업 확인
            var workData = AUIGrid.getGridData(auiGridReportWork);
            if(workData.length == 0) {
                alert("정비시작/종료 시간을 확인해주세요.");
                return;
            }

            for(var i=0; i<workData.length; i++) {
                if(workData[i].start_ti == "" || workData[i].end_ti == "") {
                    alert("정비시작/종료 시간을 확인해주세요.");
                    return;
                }
            }

            if($M.getValue("job_mem_no") == "" || $M.getValue("job_confirm_date") == "") {
                alert("작업안전확인 버튼을 클릭하여 내용확인 후 다시 시도해주세요.");
                return;
            }

            var fileArr = [];

            $("[name=att_file_seqJ]").each(function () {
                fileArr.push($(this).val());
            });

            <%--if(${result.cust_no ne '20130603145119670'}) {--%>
            <%--    if($M.getValue("file_seq_before") == "" && $M.getValue("file_seq_after") == "" && fileArr.length == 0) {--%>
            <%--        alert("고객싸인 서명완료 또는 종이계약서 업로드 후 다시 시도해주세요.");--%>
            <%--        return;--%>
            <%--    }--%>
            <%--}--%>

            // 정비만족도 삭제
            $M.setValue("job_status_cd", "7");
            $M.setValue("complete_mem_no", "${SecureUser.mem_no}");
            $M.setValue("complete_date", $M.getCurrentDate("yyyyMMddHHmmss"));
            $M.setValue("job_ed_dt", $M.getCurrentDate("yyyyMMdd"));
            goSave();

            // var params = {
            //     "parent_js_name" : "fnSetCustPoint"
            // };
            //
            // var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=700, height=300, left=0, top=0";
            // $M.goNextPage('/serv/serv0101p03', $M.toGetParam(params), {popupStatus : popupOption});
        }

        // 정비완료취소
        function goOutCancel() {
            $M.setValue("job_status_cd", "11");
            $M.setValue("out_cancel", "Y");
            //
            // var params = {
            //     "job_status_cd" : $M.getValue("job_status_cd"),
            //     "s_job_report_no" : $M.getValue("job_report_no")
            // };
            //
            // var msg = "정비완료 취소 처리를 하시겠습니까?";
            //
            // $M.goNextPageAjaxMsg(msg, this_page + "/assign/update", $M.toGetParam(params), {method : 'POST'},
            //     function(result) {
            //         if(result.success) {
            //             alert("정비완료 취소처리가 완료 되었습니다.");
            //             location.reload();
            //         }
            //     }
            // );

            $M.setValue("job_status_type", "D");
            goSave();
        }

        // 정산서작성
        function goSale() {
            // 2차서명 완료 or 종이정비지시서 사진 등록했는지 체크 후 정산서 작성 가능
            var param = {
                "job_report_no" : $M.getValue("job_report_no"),
                "cust_no" : $M.getValue("cust_no")
            }

            $M.goNextPageAjax(this_page + "/sale/file/check", $M.toGetParam(param), {method : 'GET'},
                function(result) {
                    if(result.success) {
                        // 매출처리 등록
                        var params = {
                            "job_report_no" : $M.getValue("job_report_no")
                            , "parent_js_name" : "fnReload"
                        };

                        var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=700, height=300, left=0, top=0";
                        $M.goNextPage('/cust/cust0202p06', $M.toGetParam(params), {popupStatus : popupOption});
                    }
                }
            );
        }

        function fnReload() {
        	location.reload();
        }

        function fnSetCustPoint(data) {
            $M.setValue("cust_point", data);
            $M.setValue("job_status_cd", "7");
            $M.setValue("complete_mem_no", "${SecureUser.mem_no}");
            $M.setValue("job_ed_dt", $M.getCurrentDate("yyyyMMdd"));
            setTimeout(goSave, 100);
        }

        // 완료보류 -- 추후 보완(서비스일지, 콜등 관련 기능 개발 완료 시)
        function goCancelConfirm() {
            $M.setValue("job_status_cd", "8");
            goSave();
        }

        // 완료보류취소
        function goHoldCancel() {
            $M.setValue("job_status_cd", "5");
            goSave();
        }

        // 예약확정 -- 추후 보완(서비스일지, 콜등 관련 기능 개발 완료 시)
        function goConfirmResv() {
            alert("예약 확정");
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
            $M.setValue("reserve_sms_show_yn", data.reserve_n == "Y" ? "N" : "Y");
            setTimeout(goSave, 100);
        }


        // 7.비용 -> 합계, 총금액(VAT포함) 계산
        function fnChangePrice(init) {

            // 7.비용 -> 출장비(예상)
            var planTravelExpense = $M.toNum($M.getValue("tot_travel_hour_price"));
            // 7.비용 -> 공임(예상)
            var planWorkTotalAmt = $M.toNum($M.getValue("plan_work_total_amt"));
            // 7.비용 -> 부품(예상)
            var planPartTotalAmt = $M.toNum($M.getValue("plan_part_total_amt"));
            // 7.비용 -> 합계(예상)
            var planTotalAmt = planTravelExpense + planWorkTotalAmt + planPartTotalAmt;
            // 7.비용 -> 총금액(VAT포함) -> 합계 + VAT
            var planTotalVatAmt = Math.floor(planTotalAmt * 1.1);

            $M.setValue("plan_total_amt", planTotalAmt);
            $M.setValue("plan_total_vat_amt", planTotalVatAmt);

            // 7.비용 -> 출장비(최종)
            var finalTravelExpense = $M.toNum($M.getValue("final_travel_expense"));
            // 7.비용 -> 공임(최종)
            var workTotalAmt = $M.toNum($M.getValue("work_total_amt"));
            // 7.비용 -> 부품(최종)
            var partTotalAmt = $M.toNum($M.getValue("part_total_amt"));
            // 7.비용 -> 합계(최종)
            var totalAmt = init != undefined ? $M.getValue("total_amt") : finalTravelExpense + workTotalAmt + partTotalAmt;
            // 7.비용 -> 총금액(VAT포함) -> 합계  + VAT
            var finalTotalVatAmt = Math.floor(totalAmt * 1.1);

            $M.setValue("total_amt", totalAmt);
            $M.setValue("final_total_vat_amt", finalTotalVatAmt);

            // 23/06/29 추후 다시 자동계산 넣을 예정
            // if($M.getValue("plan_total_amt") == 0 && $M.getValue("total_amt") == 0) {
            //     $M.setValue("cost_yn", "N");
            // } else {
            //     $M.setValue("cost_yn", "Y");
            // }
        }

		// 장비차주변경 정보
		function fnSetMachineCust(data) {
			$M.setValue("cust_no", data.cust_no);
			setTimeout(goCustInfoSearch, 100);
		}


		// 고객정보 조회
		function goCustInfoSearch() {
			var param = {
	        	"s_cust_no" : $M.getValue("cust_no")
			};

			$M.goNextPageAjax(this_page + "/cust/search", $M.toGetParam(param), {method: 'GET', loader : false},
				function (result) {
					if (result.success) {
						$M.setValue(result.custInfo);
						$M.setValue("__s_cust_no", result.custInfo.cust_no);
					}
			});
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
            };

            var columnLayout = [
                {
                    headerText : "점검 및 정비 지시",
                    dataField : "order_text",
                    width : "60%",
                    style : "aui-left",
                    styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
                        if((item.bookmark_type_jr == 'R' && (item.sort_no != 0 || item.up_job_report_order_seq != 0))) {
                            return "";
                        }

                        // 서비스쿠폰 행 일 경우 수정 불가 스타일
                        if(item.cust_svc_coupon_no) {
                            return ""
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
                      if(item.bookmark_type_jr == 'R' && (item.sort_no != "0" || item.up_job_report_order_seq != "0")) {
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
                    headerText : "cmd",
                    dataField : "order_cmd",
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
                    headerText : "구분",
                    dataField : "job_order_type_cd",
                    visible : false
                },
                {
                    headerText : "정렬순서",
                    dataField : "sort_no",
                    visible : false
                },
                {
                    headerText : "고객서비스쿠폰번호",
                    dataField : "cust_svc_coupon_no",
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
                            if (isRemoved == false) {
                                // if(event.item.job_depth == "1" && event.item.children != undefined){
                                // 	var children = event.item.children;
                                // 	for(var i=0;i<children.length;++i){
                                // 		AUIGrid.updateRow(auiGridReportOrder, { "order_cmd" : "D" }, (event.rowIndex+i+1));
                                //         AUIGrid.removeRow(event.pid, (event.rowIndex+i+1));
                                // 	}
                                // 	AUIGrid.updateRow(auiGridReportOrder, { "order_cmd" : "D" }, event.rowIndex);
                                //     AUIGrid.removeRow(event.pid, event.rowIndex);
                                // }else{
                                	AUIGrid.updateRow(auiGridReportOrder, { "order_cmd" : "D" }, event.rowIndex);
                                    AUIGrid.removeRow(event.pid, event.rowIndex);
                                // }
                            } else {
                            	// if(event.item.job_depth == "1" && event.item.children != undefined){
                                //     AUIGrid.restoreSoftRows(auiGridReportOrder, "selectedIndex");
                                //     AUIGrid.updateRow(auiGridReportOrder, { "order_cmd" : "" }, event.rowIndex);
                            	// 	var children = event.item.children;
                                // 	for(var i=0;i<children.length;++i){
                                //         AUIGrid.restoreSoftRows(auiGridReportOrder, event.rowIndex+i+1);
                                // 		AUIGrid.updateRow(auiGridReportOrder, { "order_cmd" : "" }, event.rowIndex+i+1);
                                // 	}
                                // }else{
                                    AUIGrid.restoreSoftRows(auiGridReportOrder, "selectedIndex");
                                    AUIGrid.updateRow(auiGridReportOrder, { "order_cmd" : "" }, event.rowIndex);
                                // }
                            }
                            AUIGrid.update(auiGridReportOrder);

                            fnCalcOrderPlanWorkAmt();
                            fnCalcOrderWorkAmt();
                            fnCalcOrderWorkHour();
                        },
                    },
                    labelFunction : function(rowIndex, columnIndex, value,
                                             headerText, item) {
                        return '삭제'
                    },
                    style : "aui-center",
                    editable : false,
                }
            ];

            // 실제로 #grid_wrap에 그리드 생성
            auiGridReportOrder = AUIGrid.create("#auiGridReportOrder", columnLayout, gridPros);
            // 그리드 갱신
            AUIGrid.setGridData(auiGridReportOrder, ${originalList});

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
				// aui tree 구조가 가끔 랜덤으로 에러 발생해서 주석처리
				// if(event.marker == "removed"){
                   	// if(event.item.job_depth == "1"){
                    //     AUIGrid.restoreSoftRows(auiGridReportOrder, event.rowIndex);
                    //     AUIGrid.updateRow(auiGridReportOrder, { "order_cmd" : "" }, event.rowIndex);
                	// 	var children = event.item.children;
                    // 	for(var i=0;i<children.length;++i){
                    //         AUIGrid.restoreSoftRows(auiGridReportOrder, event.rowIndex+i+1);
                    // 		AUIGrid.updateRow(auiGridReportOrder, { "order_cmd" : "" }, event.rowIndex+i+1);
                    // 	}
                    // }else{

                        AUIGrid.restoreSoftRows(auiGridReportOrder, event.rowIndex);
                        AUIGrid.updateRow(auiGridReportOrder, { "order_cmd" : "" }, event.rowIndex);
                    // }
                    // AUIGrid.update(auiGridReportOrder);

                    fnCalcOrderPlanWorkAmt();
                    fnCalcOrderWorkAmt();
                    fnCalcOrderWorkHour();
				// }
			});

            // 예상비용 or 발생비용 변경 시 -> 7. 비용 공임 부분 적용
            AUIGrid.bind(auiGridReportOrder, "cellEditEnd", auiOrderCellEditHandler);

            AUIGrid.bind(auiGridReportOrder, "cellEditBegin", auiOrderCellEditHandler);
        }

        // 부품목록 그리드
        function createAUIGridReportPart() {
            var gridPros = {
                // 행 구별 필드명 지정
                rowIdField: "_$uid",
                editable: true,
                showStateColumn: true,
                displayTreeOpen: true,
                // 체크박스 출력 여부
                showRowCheckColumn: true,
                // 전체선택 체크박스 표시 여부
                showRowAllCheckBox: true,
                // 전체 선택 체크박스가 독립적인 역할을 할지 여부
                independentAllCheckBox: true,
                rowCheckDisabledFunction: function (rowIndex, isChecked, item) {
                    // 로그인한 사용자가 결재 권한이 없는 경우 체크박스 disabeld 처리
                    if ($M.getValue("job_status_cd") >= "7") {
                        return false; // false 반환하면 보이지 않게 처리됨
                    }

                    if (item.use_qty > 0) {
                        return false;
                    }

                    return true;
                }
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
                    headerText: "부품번호",
                    dataField: "part_no",
                    width: "15%",
                    editRenderer: {
                        type: "ConditionRenderer",
                        conditionFunction: function (rowIndex, columnIndex, value, item, dataField) {
                            var param = {
                                s_search_kind: 'DEFAULT_PART',
                                's_warehouse_cd': $M.getValue("org_code"),
                                's_only_warehouse_yn': "N",	// 센터일 때만 Y로 넘김 -> 전체 다 나오게 변경
                                's_not_sale_yn': "Y",		// 매출정지 제외
                                's_not_in_yn': "Y",			// 미수입 제외
                                's_part_mng_cd': ""
                            };
                            return fnGetPartSearchRenderer(dataField, param, "#auiGridReportPart");
                        },
                    },
                },
                {
                    headerText: "부품명",
                    dataField: "part_name",
                    width: "20%",
                    style: "aui-left",
                    editable: true
                },
                {
                    headerText: "삭제",
                    dataField: "removeBtn",
                    renderer: {
                        type: "ButtonRenderer",
                        onClick: function (event) {

                            var jobStatusCd = $M.getValue("job_status_cd");
                            if (jobStatusCd ==  "7" || jobStatusCd == "9") {
                                alert("부품 삭제는 [고객신청, 접수, 배정, 예약확정] 상태에서만 가능합니다.");
                                return;
                            }

                            var useQty = event.item.use_qty;
                            if (useQty > 0) {
                                alert("이미 사용 된 부품은 삭제가 불가능합니다.");
                                return;
                            }

                            var outQty = event.item.out_qty;
                            var returnQty = event.item.return_qty;

                            if (outQty > 0 || returnQty > 0) {
                                alert("출고 또는 반품 처리 된 부품은 삭제가 불가능합니다.");
                                return;
                            }

                            if (confirm("해당 부품을 삭제하시겠습니까?") == false) {
                                return;
                            }

                            // var isRemoved = AUIGrid.isRemovedById(auiGridReportPart, event.item._$uid);
                            // if (isRemoved == false) {
                            //     AUIGrid.updateRow(auiGridReportPart, {"part_cmd": "D"}, event.rowIndex);
                            //     AUIGrid.removeRow(event.pid, event.rowIndex);
                            //     AUIGrid.update(auiGridReportPart);
                            // } else {
                            //     AUIGrid.restoreSoftRows(auiGridReportPart, "selectedIndex");
                            //     AUIGrid.updateRow(auiGridReportPart, {"part_cmd": ""}, event.rowIndex);
                            //     AUIGrid.update(auiGridReportPart);
                            // }

                            if(event.item.job_report_no == undefined || event.item.job_report_no == null || event.item.job_report_no == "") {
                                AUIGrid.removeRow(auiGridReportPart, event.rowIndex);
                            } else {
                                __fnRemovePart(event.item);
                            }
                        },
                    },
                    labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                        return '삭제'
                    },
                    style: "aui-center",
                    editable: false,
                },
                // {
                //     headerText: "순정",
                //     dataField: "normal_yn",
                //     width: "10%",
                //     editable: true,
                //     style: "aui-editable",
                //     editRenderer: {
                //         type: "DropDownListRenderer",
                //         list: fixList,
                //         keyField: "fix_yn",
                //         valueField: "fix_name"
                //     },
                //     labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                //         var retStr = value;
                //         for (var j = 0; j < fixList.length; j++) {
                //             if (fixList[j]["fix_yn"] == value) {
                //                 retStr = fixList[j]["fix_name"];
                //                 break;
                //             } else if (value === null) {
                //                 retStr = "- 선택 -";
                //                 break;
                //             }
                //         }
                //         return retStr;
                //     }
                // },
                {
                    headerText: "수량",
                    dataField: "qty",
                    style: "aui-center aui-editable"
                },
                {
                    headerText: "가용재고(센터)",
                    dataField: "part_able_stock",
                    style: "aui-center aui-link",
                    dataType: "numeric",
                    formatString: "#,##0",
                    editable: false,
                },
                {
                    headerText: "단가",
                    dataField: "unit_price",
                    style: "aui-right aui-editable",
                    dataType: "numeric",
                    formatString: "#,##0"
                },
                {
                    headerText: "금액",
                    dataField: "amount",
                    style: "aui-right aui-editable",
                    dataType: "numeric",
                    formatString: "#,##0"
                },
                {
                    headerText: "출고",
                    dataField: "out_qty",
                    style: "aui-center",
                    editable: false
                },
                {
                    headerText: "사용",
                    dataField: "use_qty",
                    style: "aui-center aui-editable"
                },
                {
                    headerText: "반품",
                    dataField: "return_qty",
                    style: "aui-center",
                    editable: false
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
                    headerText: "청구금액",
                    dataField: "bill_amount",
                    style: "aui-right",
                    dataType: "numeric",
                    formatString: "#,##0",
                    editable: false
                },
                {
                    headerText: "이동요청",
                    dataField: "transBtn",
                    width: "70",
                    renderer: {
                        type: "ButtonRenderer",
                        onClick: function (event) {
                            var param = {
                                "part_no": event.item.part_no

                            };
                            openTransPartPanel('setMovePartInfo', $M.toGetParam(param));
                        },
                    },
                    labelFunction: function (rowIndex, columnIndex, value,
                                             headerText, item) {
                        return '이동요청'
                    },
                    style: "aui-center",
                    editable: false,
                },
                {
                    headerText: "정비지시서번호",
                    dataField: "job_report_no",
                    visible: false
                },
                {
                    headerText: "순번",
                    dataField: "seq_no",
                    visible: false
                },
                {
                    headerText: "사용여부",
                    dataField: "use_yn",
                    visible: false
                },
                {
                    headerText: "cmd",
                    dataField: "part_cmd",
                    visible: false
                },
                {
                    dataField: "part_name_change_yn",
                    visible: false
                },
                {
                    headerText: "스캔수량",
                    dataField: "scan_qty",
                    visible: false
                },
                {
                    headerText: "전표바코드",
                    dataField: "doc_barcode_no",
                    visible: false
                }
            ];

            // 실제로 #grid_wrap에 그리드 생성
            auiGridReportPart = AUIGrid.create("#auiGridReportPart", columnLayout, gridPros);
            // 그리드 갱신
            AUIGrid.setGridData(auiGridReportPart, ${partList});

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
            AUIGrid.bind(auiGridReportPart, "keyDown", function (event) {
                // 부품목록 행추가
                if (event.shiftKey && event.keyCode == 32) {
                    fnAddCostItem();
                }

                // 부품목록 삭제
                if (event.ctrlKey && event.keyCode == 32) {
                    fnRemovePart();
                }

                if (event.keyCode == 45 || event.keyCode == 32) {
                    return false;
                }

                return true;
            });

            AUIGrid.bind(auiGridReportPart, "addRowFinish", function (event) {
                var rowCount = AUIGrid.getRowCount(event.pid);
                AUIGrid.setSelectionByIndex(auiGridReportPart, rowCount, 0);
            });

            AUIGrid.bind(auiGridReportPart, "cellEditBegin", function (event) {
                if (event.item.old_part_yn == 'N') {
                    if (event.dataField == "old_part_trouble") {
                        return false;
                    }
                }
            });

            // 전체 체크박스 클릭 이벤트 바인딩
            AUIGrid.bind(auiGridReportPart, "rowAllChkClick", function (event) {
                if (event.checked) {
                    var uniqueValues = AUIGrid.getGridData(auiGridReportPart);
                    var list = [];
                    for (var i = 0; i < uniqueValues.length; ++i) {
                        if (uniqueValues[i].use_qty == 0) {
                            list.push(uniqueValues[i].use_qty);
                        }
                    }
                    AUIGrid.setCheckedRowsByValue(event.pid, "use_qty", list);
                } else {
                    AUIGrid.setCheckedRowsByValue(event.pid, "use_qty", []);
                }
            });

            // 수량 or 단가 변경 시 가격 변경
            AUIGrid.bind(auiGridReportPart, "cellEditEnd", auiCellEditHandler);

            AUIGrid.bind(auiGridReportPart, "cellClick", function (event) {
                if(event.dataField == "part_able_stock") {
                    var param = {
                        "part_no" : event.item.part_no,
                    };

                    $M.goNextPage("/part/part0101p01", $M.toGetParam(param), {popupStatus : ""});
                }
            });

            // 만약 칼럼 사이즈들의 총합이 그리드 크기보다 작다면, 나머지 값들을 나눠 가져 그리드 크기에 맞추기
            var colSizeList = AUIGrid.getFitColumnSizeList(auiGridReportPart, true);

            // 구해진 칼럼 사이즈를 적용 시킴.
            AUIGrid.setColumnSizeList(auiGridReportPart, colSizeList);
        }

        // 삭제
        function fnRemovePart() {
            var data = AUIGrid.getSelectedItems(auiGridReportPart);

            var item = data[0];

            if(item.job_report_no == undefined || item.job_report_no == null || item.job_report_no == "") {
                AUIGrid.removeRow(auiGridReportPart, data[0].rowIndex);
                fnCalcPartPrice();
            } else {
                __fnRemovePart(item);
            }

            // var isRemoved = AUIGrid.isRemovedById(auiGridReportPart, data[0].rowIdValue);
            // if (isRemoved == false) {
            //     AUIGrid.updateRow(auiGridReportPart, { "part_cmd" : "D" }, data[0].rowIndex);
            //     AUIGrid.removeRow(auiGridReportPart, data[0].rowIndex);
            //     AUIGrid.update(auiGridReportPart);
            // } else {
            //     AUIGrid.restoreSoftRows(auiGridReportPart, "selectedIndex");
            //     AUIGrid.updateRow(auiGridReportPart, { "part_cmd" : "" }, data[0].rowIndex);
            //     AUIGrid.update(auiGridReportPart);
            // };
        }

        // 부품삭제
        function __fnRemovePart(data) {

            // var gridData = fnChangeGridDataToForm(auiGridReportPart, "N");

            var param = {
                job_report_no : $M.getValue("job_report_no"),
                part_no : data.part_no,
                seq_no : data.seq_no,
                cmd : 'U',
            }


            $M.goNextPageAjax(this_page + "/remove/part", $M.toGetParam(param), {method: "POST", loader: false},
                function (result) {
                    if (result.success) {
                        AUIGrid.setGridData(auiGridReportPart, result.list);
                        fnCalcPartPrice();
                    }
                }
            );
        }

        // 정비작업 그리드
        function createAUIGridReportWork() {
            var gridPros = {
                showRowNumColumn : false,
                rowIdField : "_$uid",
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
                        template += '<button class="btn btn-outline-default" style="width: 30%" onclick="javascript:goServiceLog(' + rowIndex + ',\'' + item.seq_no + '\');">일지</button>';
                        template += '</div>';
                        return template;
                    }
                },
                {
                    headerText : "순번",
                    dataField : "seq_no",
                    visible : false
                },
                {
                    headerText : "저장여부",
                    dataField : "save_yn",
                    visible : false
                },
                {
                    headerText : "작성여부",
                    dataField : "write_yn",
                    visible : false
                },
                {
                    headerText : "SMS전송일련번호",
                    dataField : "sms_send_seq",
                    visible : false
                }
            ];

            // 실제로 #grid_wrap에 그리드 생성
            auiGridReportWork = AUIGrid.create("#auiGridReportWork", columnLayout, gridPros);
            // 그리드 갱신
            AUIGrid.setGridData(auiGridReportWork, ${workList});
        }

        // 부품견적서 출력
        function goDocPrint() {
        	openReportPanel('serv/serv0101p01_02.crf','s_job_report_no=' + $M.getValue("job_report_no"));
        }

        // 정비견적서 출력
        function goJobReportDocPrint() {
        	openReportPanel('serv/serv0101p01_06.crf','s_job_report_no=' + $M.getValue("job_report_no"));
        }

        // 거래명세표 출력
        function fnTaxBillPrint() {
        	openReportPanel('serv/serv0101p01_04.crf','s_job_report_no=' + $M.getValue("job_report_no"));
        }

        // 정비지시서 출력
        function fnJobReportPrint() {
        	// openReportPanel('serv/serv0101p01_01_v33.crf','s_job_report_no=' + $M.getValue("job_report_no"));
        	openReportPanel('serv/serv0101p01_01_230622.crf','s_job_report_no=' + $M.getValue("job_report_no")); // 23.07.03 정비지시서 모두싸인 양식으로 변경

            <%--if(${(empty result.file_seq_before or result.file_seq_before eq '0') and (empty result.file_seq_after or result.file_seq_after eq '0')}) {--%>
            <%--    alert("모두싸인 문서 서명이 완료되지 않았습니다.\n완료 후 다시 확인해주세요.");--%>
            <%--    return;--%>
            <%--} else {--%>
            <%--    if(${empty result.file_seq_after or result.file_seq_after eq '0'}) {--%>
            <%--        openFileViewerPanel('${result.file_seq_before}');--%>
            <%--    } else {--%>
            <%--        openFileViewerPanel('${result.file_seq_after}');--%>
            <%--    }--%>
            <%--}--%>
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
            $M.setValue("breg_no", $M.bregNoFormat(data.breg_no));
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

        // 거래명세서 팝업
        function goTaxBill() {
            var params = {
                "inout_doc_no" : $M.getValue("inout_doc_no")
            };

            var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=750, height=420, left=0, top=0";
            $M.goNextPage('/cust/cust0202p01', $M.toGetParam(params), {popupStatus : popupOption});
        }

        // 점검리스트 왼쇄
        function goPrintCheckList() {
        	openReportPanel('serv/serv0101p16_01.crf','s_job_report_no=' + $M.getValue("job_report_no"));
        }

        // 점검리스트 팝업
        function goCheckList() {
            var params = {
                "s_job_report_no" : $M.getValue("job_report_no"),
                "parent_js_name" : "fnSetChkList"
            };

            var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1300, height=800, left=0, top=0";
            $M.goNextPage('/serv/serv0101p16', $M.toGetParam(params), {popupStatus : popupOption});
        }

        // 서비스 점검 리스트 정보 Setting
        function fnSetChkList(data) {
            $M.setValue("svc_chk_list_cd_str", data.svc_chk_list_cd_str);
            $M.setValue("check_text", data.check_text);
            setTimeout(goSaveCheckList, 100);
        }

        // 점검 리스트 저장.
        function goSaveCheckList() {
            var frm = document.main_form;
            //validationcheck
            if($M.validation(frm,
                {field:[]})==false) {
                return;
            };

            frm = $M.toValueForm(document.main_form);

            $M.goNextPageAjax(this_page + "/save/checkList", frm, {method : 'POST'},
                function (result) {
                    if(result.success) {
                        alert("서비스점검리스트 저장이 완료되었습니다.");
                    }
                }
            );
        }

        // 저장
        function goSave(mode) {
            var frm = document.main_form;
            //validationcheck
            if($M.validation(frm,
                {field:[]})==false) {
                return;
            };

            // 사업자확인 CheckBox 확인
            // 사업자확인 사라져서 무조건 Y로 세팅
            $M.setValue("breg_confirm_yn", "Y");
            // if(!$M.isCheckBoxSel("breg_confirm_yn")) {
            //     alert("사업자확인을 먼저 진행해주세요.");
            //     return;
            // }

         	// 정비종류 -> 출장인 경우 -> 이동시간 체크
            var jobCaseTi = $M.getValue("job_case_ti");
            var travelHour = $M.toNum($M.getValue("travel_hour"));
            var jobStatusCd = $M.getValue("job_status_cd");

            // 23.06.12 고객사 회의결과 조건 삭제하는걸로 변경
            // if(jobStatusCd == "7" || jobStatusCd == "9") {
            // 	if(jobCaseTi == "T" && travelHour <= 0) {
            //         alert("이동시간은 필수입니다.");
            //         $M.getComp("travel_hour").focus();
            //         return;
    		// 	}
			// }


            if($M.getValue("receipt_type_rt") == "R" && $M.getValue("in_dt") == "") {
                alert("접수구분 사전을 선택했을 경우\n입고일자는 필수입니다.");
                $M.getComp("in_dt").focus();
                return;
            }

            // 접수구분 당일로 선택했을 시 정비예약시간
            // if($M.getValue("receipt_type_rt") == "T") {
            //     var reserveDt = $M.toNum($M.getValue("reserve_repair_ti"));
            //     var nowTi = $M.toNum($M.getCurrentDate("HHmm"));
            //     var inDt = $M.toNum($M.getValue("in_dt"));
            //     var nowDt = $M.toNum($M.getCurrentDate("yyyyMMdd"));
            //     if(inDt == nowDt && reserveDt < nowTi) {
            //         alert("접수구분 당일을 선택했을 경우\n정비예약시간은 현재시간보다 이후로 설정해야합니다.");
            //         return;
            //     }
            // }

            // 접수구분 -> 사전인 경우 -> 사전예약문자발송여부 확인
            // 예약문자발송이 생겨서 삭제
            // if(
            //     // $M.getValue("reserve_sms_send_target_yn") == "N &&
            //     $M.getValue("reserve_sms_show_yn") == "Y" && $M.getValue("receipt_type_rt") == "R"
            //     && $M.getValue("eng_mem_no") != "") {
            //     goReservationText();
            // }


            if ($M.getValue("cap_use_yn") == "Y" && $M.getValue("job_status_type") != "D") {
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

            if ($M.getValue("job_status_cd") == "5" || $M.getValue("job_status_cd") == "11") {
                var param = {
                    "board_mem_no": $M.getValue("eng_mem_no"),
                    "board_dt": $M.getValue("in_dt"),
                    "work_st_ti": $M.getValue("reserve_repair_ti"),
                    "day_board_seq": $M.getValue("day_board_seq"),
                    "report_yn": "Y"
                }

                $M.goNextPageAjax("/mmyy/mmyy0113p01/check/time", $M.toGetParam(param), {method : 'GET'},
                    function(result) {
                        if(result.success) {
                            var msg = "";
                            if (result.mem_work_yn == "N") {
                                msg = "배정자 근무 외 시간입니다.\n";
                            }
                            if (result.dup_yn == "Y") {
                                msg = "해당 시간에 이미 지정된 작업이 설정되어 있습니다.\n";
                            }

                            if (mode == 'SMS') {
                                fnSave(fileArr, jobFileArr, mode);
                            } else {
                                if(mode == undefined) {
                                    msg += "저장하시겠습니까?";
                                } else {
                                    msg += "예약확정 하시겠습니까?"
                                }

                                if (confirm(msg) == false) {
                                    return false;
                                }
                                fnSave(fileArr, jobFileArr, mode);
                            }
                        }
                    }
                );
            } else {
                var msg = "저장하시겠습니까?";
                if (mode == 'SMS') {
                    fnSave(fileArr, jobFileArr, mode);
                } else {
                    if(mode != undefined) {
                        msg = "예약확정 하시겠습니까?"
                    }
                    if(confirm(msg)){
                        fnSave(fileArr, jobFileArr, mode);
                    }
                }
            }
        }

        function fnSave(fileArr, jobFileArr, mode) {
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

            $M.setValue("file_seq_no_str", $M.getArrStr(fileSeqNoArr));
            $M.setValue("file_file_seq_str", $M.getArrStr(fileSeqArr));
            $M.setValue("file_cmd_str", $M.getArrStr(fileCmdArr));
            $M.setValue("file_use_yn_str", $M.getArrStr(fileUseYnArr));
            $M.setValue("file_pic_type_str", $M.getArrStr(filePicTypeArr));

            frm = $M.toValueForm(document.main_form);

            var option = {
                isEmpty : true
            };


            // 추가된 행 아이템들(부품)
            var addedRowParts = AUIGrid.getAddedRowItems("#auiGridReportPart");
            // 수정된 행 아이템들(부품)
            var editedRowParts = AUIGrid.getEditedRowItems("#auiGridReportPart");
            // 삭제된 행 아이템들(부품)
            var removedRowParts = AUIGrid.getRemovedItems("#auiGridReportPart");

            var part_seq_no = [];
            var part_no = [];
            var qty = [];
            var unit_price = [];
            var part_production_cd = [];
            var use_qty = [];
            var scan_qty = [];
            var part_use_yn = [];
            var part_cmd = [];
            var part_name = [];
            var old_part_yn = [];
            var old_part_trouble = [];

            for(var i=0, n=addedRowParts.length; i<n; i++) {
                part_seq_no.push(addedRowParts[i].seq_no);
                part_no.push(addedRowParts[i].part_no);
                qty.push(addedRowParts[i].qty);
                unit_price.push(addedRowParts[i].unit_price);
                part_production_cd.push(addedRowParts[i].part_production_cd);
                use_qty.push(addedRowParts[i].use_qty);
                scan_qty.push(addedRowParts[i].scan_qty);
                part_name.push(addedRowParts[i].part_name);
                old_part_yn.push(addedRowParts[i].old_part_yn);
                old_part_trouble.push(addedRowParts[i].old_part_trouble);
                part_use_yn.push("Y");
                part_cmd.push("C");
            }

            for(var i=0, n=editedRowParts.length; i<n; i++) {
                part_seq_no.push(editedRowParts[i].seq_no);
                part_no.push(editedRowParts[i].part_no);
                qty.push(editedRowParts[i].qty);
                unit_price.push(editedRowParts[i].unit_price);
                part_production_cd.push(editedRowParts[i].part_production_cd);
                use_qty.push(editedRowParts[i].use_qty);
                scan_qty.push(editedRowParts[i].scan_qty);
                part_name.push(editedRowParts[i].part_name);
                old_part_yn.push(editedRowParts[i].old_part_yn);
                old_part_trouble.push(editedRowParts[i].old_part_trouble);
                part_use_yn.push("Y");
                part_cmd.push("U");
            }

            for(var i=0, n=removedRowParts.length; i<n; i++) {
                part_seq_no.push(removedRowParts[i].seq_no);
                part_no.push(removedRowParts[i].part_no);
                qty.push(removedRowParts[i].qty);
                unit_price.push(removedRowParts[i].unit_price);
                part_production_cd.push(removedRowParts[i].part_production_cd);
                use_qty.push(removedRowParts[i].use_qty);
                scan_qty.push(removedRowParts[i].scan_qty);
                part_name.push(removedRowParts[i].part_name);
                old_part_yn.push(removedRowParts[i].old_part_yn);
                old_part_trouble.push(removedRowParts[i].old_part_trouble);
                part_use_yn.push("N");
                part_cmd.push("U");
            }

            $M.setValue(frm, "part_seq_no_str", $M.getArrStr(part_seq_no, option));
            $M.setValue(frm, "part_no_str", $M.getArrStr(part_no, option));
            $M.setValue(frm, "qty_str", $M.getArrStr(qty, option));
            $M.setValue(frm, "unit_price_str", $M.getArrStr(unit_price, option));
            $M.setValue(frm, "part_production_cd_str", $M.getArrStr(part_production_cd, option));
            $M.setValue(frm, "use_qty_str", $M.getArrStr(use_qty, option));
            $M.setValue(frm, "scan_qty_str", $M.getArrStr(scan_qty, option));
            $M.setValue(frm, "part_cmd_str", $M.getArrStr(part_cmd, option));
            $M.setValue(frm, "part_use_yn_str", $M.getArrStr(part_use_yn, option));
            $M.setValue(frm, "part_name_str", $M.getArrStr(part_name, option));
            $M.setValue(frm, "old_part_yn_str", $M.getArrStr(old_part_yn, option));
            $M.setValue(frm, "old_part_trouble_str", $M.getArrStr(old_part_trouble, option));

            // 추가된 행 아이템들(상담과 점점/정비)
            var addedRowOrders = AUIGrid.getAddedRowItems("#auiGridReportOrder");
            // 수정된 행 아이템들(상담과 점점/정비)
            var editedRowOrders = AUIGrid.getEditedRowItems("#auiGridReportOrder");
            // 삭제된 행 아이템들(상담과 점점/정비)
            var removedRowOrders = AUIGrid.getRemovedItems("#auiGridReportOrder");

            var job_report_order_seq = [];
            var up_job_report_order_seq = [];
            var as_todo_seq = [];
            var order_text = [];
            var sort_no = [];
            var plan_work_amt = [];
            var work_amt = [];
            var work_hour = [];
            var work_yn = [];
            var job_order_type_cd = [];

            var as_plan_dt = [];
            var as_assign_mem_no = [];

            var row_num = [];
            var bookmark_type_jr = [];
            var break_part_seq = [];
            var order_use_yn = [];
            var order_cmd = [];

            var cust_svc_coupon_no = [];

            for(var i=0, n=addedRowOrders.length; i<n; i++) {
                if(addedRowOrders[i].order_text != "") {
                    job_report_order_seq.push(addedRowOrders[i].job_report_order_seq);
                    up_job_report_order_seq.push(addedRowOrders[i].up_job_report_order_seq);
                    as_todo_seq.push(addedRowOrders[i].as_todo_seq);
                    order_text.push(addedRowOrders[i].order_text);
                    sort_no.push(addedRowOrders[i].sort_no);
                    plan_work_amt.push(addedRowOrders[i].plan_work_amt);
                    work_amt.push(addedRowOrders[i].work_amt);
                    work_hour.push(addedRowOrders[i].work_hour);
                    work_yn.push(addedRowOrders[i].work_yn);
                    job_order_type_cd.push(addedRowOrders[i].job_order_type_cd);
                    as_plan_dt.push(addedRowOrders[i].as_plan_dt);
                    as_assign_mem_no.push(addedRowOrders[i].as_assign_mem_no);
                    row_num.push(addedRowOrders[i].row_num);
                    bookmark_type_jr.push(addedRowOrders[i].bookmark_type_jr);
                    break_part_seq.push(addedRowOrders[i].break_part_seq);
                    order_use_yn.push("Y");
                    order_cmd.push("C");
                    cust_svc_coupon_no.push(addedRowOrders[i].cust_svc_coupon_no);
                }
            }

            for(var i=0, n=editedRowOrders.length; i<n; i++) {
                job_report_order_seq.push(editedRowOrders[i].job_report_order_seq);
                up_job_report_order_seq.push(editedRowOrders[i].up_job_report_order_seq);
                as_todo_seq.push(editedRowOrders[i].as_todo_seq);
                order_text.push(editedRowOrders[i].order_text);
                sort_no.push(editedRowOrders[i].sort_no);
                plan_work_amt.push(editedRowOrders[i].plan_work_amt);
                work_amt.push(editedRowOrders[i].work_amt);
                work_hour.push(editedRowOrders[i].work_hour);
                work_yn.push(editedRowOrders[i].work_yn);
                job_order_type_cd.push(editedRowOrders[i].job_order_type_cd);
                as_plan_dt.push(editedRowOrders[i].as_plan_dt);
                as_assign_mem_no.push(editedRowOrders[i].as_assign_mem_no);
                row_num.push(editedRowOrders[i].row_num);
                row_num.push(editedRowOrders[i].bookmark_type_jr);
                bookmark_type_jr.push(editedRowOrders[i].bookmark_type_jr);
                break_part_seq.push(editedRowOrders[i].break_part_seq);
                order_use_yn.push("Y");
                order_cmd.push("U");
                cust_svc_coupon_no.push(editedRowOrders[i].cust_svc_coupon_no);
            }

            for(var i=0, n=removedRowOrders.length; i<n; i++) {
                job_report_order_seq.push(removedRowOrders[i].job_report_order_seq);
                up_job_report_order_seq.push(removedRowOrders[i].up_job_report_order_seq);
                as_todo_seq.push(removedRowOrders[i].as_todo_seq);
                order_text.push(removedRowOrders[i].order_text);
                sort_no.push(removedRowOrders[i].sort_no);
                plan_work_amt.push(removedRowOrders[i].plan_work_amt);
                work_amt.push(removedRowOrders[i].work_amt);
                work_hour.push(removedRowOrders[i].work_hour);
                work_yn.push(removedRowOrders[i].work_yn);
                job_order_type_cd.push(removedRowOrders[i].job_order_type_cd);
                as_plan_dt.push(removedRowOrders[i].as_plan_dt);
                as_assign_mem_no.push(removedRowOrders[i].as_assign_mem_no);
                row_num.push(removedRowOrders[i].row_num);
                bookmark_type_jr.push(removedRowOrders[i].bookmark_type_jr);
                break_part_seq.push(removedRowOrders[i].break_part_seq);
                order_use_yn.push("N");
                order_cmd.push("U");
                cust_svc_coupon_no.push(removedRowOrders[i].cust_svc_coupon_no);
            }

            $M.setValue(frm, "job_report_order_seq_str", $M.getArrStr(job_report_order_seq, option));
            $M.setValue(frm, "up_job_report_order_seq_str", $M.getArrStr(up_job_report_order_seq, option));
            $M.setValue(frm, "as_todo_seq_str", $M.getArrStr(as_todo_seq, option));
            $M.setValue(frm, "order_text_str", $M.getArrStr(order_text, option));
            $M.setValue(frm, "sort_no_str", $M.getArrStr(sort_no, option));
            $M.setValue(frm, "plan_work_amt_str", $M.getArrStr(plan_work_amt, option));
            $M.setValue(frm, "work_amt_str", $M.getArrStr(work_amt, option));
            $M.setValue(frm, "work_hour_str", $M.getArrStr(work_hour, option));
            $M.setValue(frm, "work_yn_str", $M.getArrStr(work_yn, option));
            $M.setValue(frm, "job_order_type_cd_str", $M.getArrStr(job_order_type_cd, option));
            $M.setValue(frm, "as_plan_dt_str", $M.getArrStr(as_plan_dt, option));
            $M.setValue(frm, "as_assign_mem_no_str", $M.getArrStr(as_assign_mem_no, option));
            $M.setValue(frm, "row_num_str", $M.getArrStr(row_num, option));
            $M.setValue(frm, "bookmark_type_jr_str", $M.getArrStr(bookmark_type_jr, option));
            $M.setValue(frm, "break_part_seq_str", $M.getArrStr(break_part_seq, option));
            $M.setValue(frm, "order_use_yn_str", $M.getArrStr(order_use_yn, option));
            $M.setValue(frm, "order_cmd_str", $M.getArrStr(order_cmd, option));
            $M.setValue(frm, "cust_svc_coupon_no_str", $M.getArrStr(cust_svc_coupon_no, option));

            // 추가된 행 아이템들(정비 일시)
            var addedRowWorks = AUIGrid.getAddedRowItems("#auiGridReportWork");
            // 수정된 행 아이템들(정비 일시)
            var editedRowWorks = AUIGrid.getEditedRowItems("#auiGridReportWork");

            var work_dt = [];
            var start_ti = [];
            var end_ti = [];
            var edit = [];
            var work_cmd = [];
            var work_seq_no = [];
            var write_yn = [];
            var sms_send_seq = [];

            for(var i=0, n=addedRowWorks.length; i<n; i++) {
                work_dt.push(addedRowWorks[i].work_dt);
                start_ti.push(addedRowWorks[i].start_ti);
                end_ti.push(addedRowWorks[i].end_ti);
                edit.push(addedRowWorks[i].edit);
                work_seq_no.push(addedRowWorks[i].seq_no);
                write_yn.push(addedRowWorks[i].write_yn);
                sms_send_seq.push(addedRowWorks[i].sms_send_seq);
                work_cmd.push("C");
            }

            for(var i=0, n=editedRowWorks.length; i<n; i++) {
                work_dt.push(editedRowWorks[i].work_dt);
                start_ti.push(editedRowWorks[i].start_ti);
                end_ti.push(editedRowWorks[i].end_ti);
                edit.push(editedRowWorks[i].edit);
                work_seq_no.push(editedRowWorks[i].seq_no);
                write_yn.push(editedRowWorks[i].write_yn);
                sms_send_seq.push(editedRowWorks[i].sms_send_seq);
                work_cmd.push("U");
            }

            $M.setValue(frm, "work_dt_str", $M.getArrStr(work_dt, option));
            $M.setValue(frm, "start_ti_str", $M.getArrStr(start_ti, option));
            $M.setValue(frm, "end_ti_str", $M.getArrStr(end_ti, option));
            $M.setValue(frm, "edit_str", $M.getArrStr(edit, option));
            $M.setValue(frm, "work_cmd_str", $M.getArrStr(work_cmd, option));
            $M.setValue(frm, "work_seq_no_str", $M.getArrStr(work_seq_no, option));
            $M.setValue(frm, "write_yn_str", $M.getArrStr(write_yn, option));
            $M.setValue(frm, "sms_send_seq_str", $M.getArrStr(sms_send_seq, option));
            $M.setValue(frm, "visit_dt", $M.getValue("in_dt"));
            $M.setValue(frm, "reserve_repair_st_ti",$M.getValue("reserve_repair_ti"));

            if(mode != undefined && mode != 'SMS') {
                $M.setValue(frm, "reserve_confirm_yn", "Y");
                $M.setValue(frm, "job_status_cd", "11");
            }

            //예약 확정일시 확정일시 저장 / 예약확정일경우 배정자 변경시 단순 배정자만 변경
            if(mode == "11" || ($M.getValue("job_status_cd") == 11 && $M.getValue("assign_change_yn") == "Y")){
                $M.setValue(frm,"reserve_repair_confirm_date", $M.getCurrentDate("yyyyMMddHHmmss"));
            }

            $M.goNextPageAjax(this_page + "/save", frm, {method : 'POST'},
                function (result) {
                    if(result.success) {
                        if(result.svc_part_job_yn == "Y"){
                            alert("정비지시서 메모의 부품 구매문의 확인바랍니다.");
                        }
                        if (mode == 'SMS') {
                            window.setTimeout(goSmsSendTravel(), 200);
                        } else {
                            alert("저장이 완료되었습니다.");
                            if(mode != undefined) {
                                //메세지참조기능 사용시 사용메뉴seq,파라미터도 세팅
                                var param = {
                                    'name' 		: $M.getValue("cust_name"),
                                    'cust_no' 	: $M.getValue("cust_no"),
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
                        }
                        window.location.reload();
                    } else {
                        window.location.reload();
                    }
                }
            );
        }

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

        function fnChangeInDt() {
            $("#reserve_confirm_msg").html("");
            $M.setValue("reserve_sms_send_yn", "N");
        }

        // 닫기
        function fnClose() {
            window.close();
        }

        function show(id) {
            document.getElementById(id).style.display="block";
        }
        function hide(id) {
            document.getElementById(id).style.display="none";
        }

        // 예약문자발송
        function goSendSmsReserve() {
            goSave('11');
            /*if($M.getValue("machine_seq") == "") {
                alert("차대번호 조회를 먼저 진행해주세요.");
                return;
            }

            if($M.getValue("in_dt") == "") {
                alert("입고일자를 선택해주세요.");
                return;
            }

            if($M.getValue("eng_mem_no") == "") {
                alert("직원배정 후 다시 시도해주세요.");
                return;
            }

            var param = {
                "job_report_no" : $M.getValue("job_report_no"),
                'reserve_repair_ti' : $M.getValue("reserve_repair_ti"),
                'in_dt' : '${result.in_dt}',
                'cust_name' : '${result.cust_name}',
                'push_cust_no' : '${result.cust_no}',
                'org_name' : '${result.org_name}',
            }

            $M.goNextPageAjaxMsg("예약확정 하시겠습니까?", this_page + "/reserve/confirm", $M.toGetParam(param), {method: "POST"},
                function (result) {
                    if (result.success) {
                        alert("예약확정 처리가 완료되었습니다.");
                        //메세지참조기능 사용시 사용메뉴seq,파라미터도 세팅
                        var param = {
                            'name' 		: $M.getValue("cust_name"),
                            'cust_no' 	: $M.getValue("cust_no"),
                            'org_name' 	: $M.getValue("org_name"),
                            'in_dt' 	: $M.getValue("in_dt"),
                            'reserve_repair_ti' : $M.getValue("reserve_repair_ti"),
                            'hp_no' 	: $M.getValue("hp_no"),
                            'req_msg_yn'  : "Y",
                            'parent_js_name'  : "fnReserveMsgComplete",
                            'menu_seq'	 : ${menu_seq},
                        }

                        openSendSmsPanel($M.toGetParam(param));

                        fnReload();
                    }
                }
            );*/
        }

        function fnReserveMsgComplete() {
            $("#reserve_confirm_msg").html("발송완료");
            $M.setValue("reserve_sms_send_yn", "Y");
            var fileArr = [];
            var jobFileArr = [];

            $("[name=att_file_seqR]").each(function () {
                fileArr.push($(this).val());
            });

            $("[name=att_file_seqJ]").each(function () {
                jobFileArr.push($(this).val());
            });
            fnSave(fileArr, jobFileArr, "11");
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
            if(${result.repair_complete_yn ne 'Y'} && type != "C") {
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

        function myLabelFunction(rowIndex, columnIndex, value, headerText, item) {
            if(item.bookmark_type_jr == 'R' && (item.sort_no != "0" || item.up_job_report_order_seq != "0")) {
                return "";
            }

            return AUIGrid.formatNumber(value, "#,##0");
        }

        function goDayBoardReferPopup() {
            var param = {
                "s_popup_yn": "Y",
                "s_search_dt": $M.getValue("in_dt"),
                "s_org_code": $M.getValue("org_code")
            }
            $M.goNextPage('/mmyy/mmyy0113', $M.toGetParam(param), {popupStatus : getPopupProp(1400, 675)});
        }

        /**
         * 장기/충당재고 팝업
         */
        function goLongPart() {
            var param = {
                "machine_seq" : $M.getValue("machine_seq"),
                "org_code" : $M.getValue("org_code"),
            };

            openSearchLongPartPanel("setPartInfo", "Y", $M.toGetParam(param));
        }

        // 사진파일 저장
        function goSavePic() {
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

            var param = {
                "job_report_no" : $M.getValue("job_report_no"),
                "seq_no_str" : $M.getArrStr(fileSeqNoArr),
                "file_seq_no_str" : $M.getArrStr(fileSeqArr),
                "cmd_str" : $M.getArrStr(fileCmdArr),
                "use_yn_str" : $M.getArrStr(fileUseYnArr),
                "pic_type_str" : $M.getArrStr(filePicTypeArr),
            }


            $M.goNextPageAjaxSave(this_page + "/save/pic", $M.toGetParam(param), {method: "POST"},
                function (result) {
                    if (result.success) {
                        alert("저장 완료되었습니다.");
                    }
                }
            );
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

        function fnJobSafeCheck() {
            if(confirm("현장의 여건과 작업환경이 올바르고 안전한 정비에 적합하지 않는다 판단되는 경우, 작업자는 정비를 거부하고, 환경을 적극적으로 개선할 의무가 있습니다")){
                $M.setValue("job_mem_no", "${SecureUser.mem_no}");
                $M.setValue("job_confirm_date", $M.getCurrentDate("yyyyMMddHHmmss"));
            } else {
                return;
            }
        }

        // 작업지시서 출력
        function fnJobReportSignPrint() {
            if($M.getValue("file_seq_before") == "" && $M.getValue("file_seq_after") == "") {
                alert("고객서명이 완료되지 않았습니다.\n고객서명 완료 후 다시 시도해주세요.");
                return;
            }

            var moduSignFileSeq = $M.getValue("file_seq_after") == "" ? $M.getValue("file_seq_before") : $M.getValue("file_seq_after");

            openFileViewerPanel(moduSignFileSeq);
        }

        // 정비구분 변경 시 체크(Cap으로 변경 시)
        function fnChangeJobType() {
            var jobTypeCd = $M.getValue("job_type_cd");

            if(jobTypeCd == "5" && (${result.cap eq '미적용'} || ${result.real_cap_yn eq 'N'})) {
                alert("장비대장에서 CAP적용 후 해당 화면을 새로고침하여 다시 진행해주세요.");
                $M.setValue("job_type_cd", "4");
                return;
            }

            if(jobTypeCd == "5") {
                if('${result.cap_cnt}' != 0) {
                    // 이미 기존에 cap인 경우
                    $M.setValue("cap_cnt", "${result.cap_cnt}");
                    $M.setValue("next_cap_cnt", "${result.next_cap_cnt}");
                    $M.setValue("cap_plan_dt", "${result.cap_plan_dt}");
                } else {
                    $M.setValue("cap_cnt", "${result.real_cap_cnt}");
                    $M.setValue("next_cap_cnt", "${result.real_next_cap_cnt}");
                    $M.setValue("cap_plan_dt", "${result.real_cap_plan_dt}");
                }
                $M.setValue("cap_use_yn", "Y");
                $("#cap_plan_dt").prop("disabled", false);
                $("#cap").html("적용");
            } else {
                $M.setValue("cap_use_yn", "N");
                $M.setValue("cap_cnt", "0");
                $M.setValue("next_cap_cnt", "1");
                $M.setValue("cap_plan_dt", "");
                $("#cap_plan_dt").prop("disabled", true);
                if('${result.cap eq '적용'}') {
                    $("#cap").html("미적용 [CAP적용]");
                } else {
                    $("#cap").html("미적용");
                }
            }

            // 정비구분 on-time 변경 시 미결등록 팝업 열기
            if(jobTypeCd == "6") {
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

        // 보유쿠폰 팝업
        function goCustCoupon() {
            if($M.getValue("machine_plant_seq") == "") {
                alert("차대번호 조회를 먼저 진행해주세요.");
                return;
            }

            // 적용 될 쿠폰 리스트 str 구하기
            var paramCouponNoStr = '';
            var gridData = AUIGrid.getGridData(auiGridReportOrder);
            gridData.forEach(item => {
              if(item?.cust_svc_coupon_no) {
                  paramCouponNoStr += item?.cust_svc_coupon_no + "#"
              }
            })

            var param = {
                "s_machine_plant_seq" : $M.getValue("machine_plant_seq"),
                "s_machine_seq" : $M.getValue("machine_seq"),
                "s_connect_coupon_str" : paramCouponNoStr,
                "s_cust_no" : $M.getValue("__s_cust_no"),
            };
            param.parent_js_name = "custCouponCallBack";
            $M.goNextPage('/serv/serv0101p19', $M.toGetParam(param), {popupStatus : ''});
        }

        // 고객 쿠폰 사용 콜백
        function custCouponCallBack(data) {
            var item = new Object();
            var parentRowId = null;
            for (var i = 0; i < data.length; i++) {
                var info = data[i].item;

                // 쿠폰 중복 적용 방지
                if (!AUIGrid.isUniqueValue(auiGridReportOrder, "cust_svc_coupon_no", info.cust_svc_coupon_no)) {
                    continue;
                }

                var item = new Object();
                item.job_order_type_cd = "REPAIR";
                item.order_text = '[무상쿠폰] ' + info.svc_coupon_name + ', ' + info.svc_disp_coupon_name;
                item.cust_svc_coupon_no = info.cust_svc_coupon_no;
                item.plan_work_amt = "";
                item.work_amt = "";
                item.work_hour = "";
                item.up_job_report_order_seq = 0;
                item.row_num = rowNum;
                item.bookmark_type_jr = "J";
                item.work_yn = "N";
                item.sort_no = "0";

                if(info?.scope_text ?? '' !== '') item.order_text += ', ' + info.scope_text

                // 부모행일 경우
                AUIGrid.addRow(auiGridReportOrder, item, 'first');

                rowNum++;
            }
        }

        // function isNumberValid(oldValue, newValue, rowItem) { // 에디팅 유효성 검사
        //     const reg = /^[+-]?\d*(\.?\d*)?$/;
        //     return {
        //         "validate" : reg.test(newValue),
        //         "message" : "양수, 음수만 작성 가능합니다."
        //     };
        // }

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
<input type="hidden" name="org_code" id="org_code" value="${result.org_code}">
<input type="hidden" name="svc_travel_expense_seq" id="svc_travel_expense_seq" value="${result.svc_travel_expense_seq}">
<input type="hidden" name="__s_machine_seq" id="__s_machine_seq" value="${result.machine_seq}">
<input type="hidden" name="machine_seq" id="machine_seq" value="${result.machine_seq}">
<input type="hidden" name="machine_plant_seq" id="machine_plant_seq" value="${result.machine_plant_seq}">
<input type="hidden" name="cust_no" id="cust_no" value="${result.cust_no}">
<input type="hidden" name="__s_cust_no" id="__s_cust_no" value="${result.cust_no}">
<input type="hidden" name="assign_mem_no" id="assign_mem_no" value="${result.assign_mem_no}">
<input type="hidden" name="assign_date" id="assign_date">
<input type="hidden" name="eng_mem_no" id="eng_mem_no" value="${result.eng_mem_no}">
<input type="hidden" name="visit_dt" id="visit_dt" value="${result.visit_dt}">
<input type="hidden" name="check_text" id="check_text" value="${result.check_text}">
<input type="hidden" name="svc_chk_list_cd_str" id="svc_chk_list_cd_str">
<input type="hidden" name="reserve_sms_send_target_yn" id="reserve_sms_send_target_yn" value="${result.reserve_sms_send_target_yn}">
<input type="hidden" name="reserve_sms_send_yn" id="reserve_sms_send_yn" value="${result.reserve_sms_send_yn}">
<%-- <input type="hidden" name="reserve_sms_send_date" id="reserve_sms_send_date" value="${result.reserve_sms_send_date}"> --%>
<input type="hidden" name="reserve_sms_show_yn" id="reserve_sms_show_yn" value="${result.reserve_sms_show_yn}">
<input type="hidden" id="__s_reg_type" name="__s_reg_type" value="D">
<input type="hidden" id="__s_menu_type" name="__s_menu_type" value="J">
<input type="hidden" id="sale_mem_hp_no" name="sale_mem_hp_no" value="${result.sale_mem_hp_no}">
<input type="hidden" id="service_mem_hp_no" name="service_mem_hp_no" value="${result.service_mem_hp_no}">
<input type="hidden" id="inout_doc_no" name="inout_doc_no" value="${result.inout_doc_no}">
<input type="hidden" id="cap_use_yn" name="cap_use_yn">
<input type="hidden" id="cap_check_yn" name="cap_check_yn" value="Y">
<input type="hidden" id="job_ed_dt" name="job_ed_dt">
<input type="hidden" id="job_status_type" name="job_status_type" value="R">
<input type="hidden" id="page_type" name="page_type" value="JOB_REPORT">
<input type="hidden" id="svc_travel_expense_hour" name="svc_travel_expense_hour" value="${bean.code_v1}">
<input type="hidden" id="out_cancel" name="out_cancel" value="N">
<input type="hidden" id="consult_dt" name="consult_dt" value="${result.consult_dt}">
<input type="hidden" id="job_status_cd" name="job_status_cd" value="${result.job_status_cd}">
<input type="hidden" id="prev_op_hour" name="prev_op_hour" value="${prev_op_hour}">
<input type="hidden" id="as_no" name="as_no"  value="${result.as_no}">
<input type="hidden" id="day_board_seq" name="day_board_seq"  value="${result.day_board_seq}">

<input type="hidden" name="org_type" id="org_type" value="${SecureUser.org_type}">
<input type="hidden" name="grade_cd" id="grade_cd" value="${SecureUser.grade_cd}">
<input type="hidden" name="job_cd" id="job_cd" value="${SecureUser.job_cd}">
<input type="hidden" name="job_mem_no" id="job_mem_no" value="${result.job_mem_no}">
<input type="hidden" name="job_confirm_date" id="job_confirm_date" value="${result.job_confirm_date}">
<input type="hidden" name="file_seq_before" id="file_seq_before" value="${result.file_seq_before}">
<input type="hidden" name="file_seq_after" id="file_seq_after" value="${result.file_seq_after}">
<input type="hidden" name="__page_type" id="__page_type" value="J">

<input type="hidden" name="self_assign_no" id="self_assign_no" value="">
<input type="hidden" name="reserve_repair_st_ti" id="reserve_repair_st_ti" value="${result.reserve_repair_st_ti}">
<input type="hidden" name="reserve_repair_confirm_date" id="reserve_repair_confirm_date" value="${result.reserve_repair_confirm_date}">

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
                    <div class="left">
                    </div>
                    <div class="right half-print">
                        <div class="form-row inline-pd pr">
                            <div class="col-auto" id="qr_image" name="qr_image">
                                <input type="hidden" id="qr_no" name="qr_no">
                            </div>
                            <span class="condition-item mr5">상태 : ${result.job_status_name}</span>
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
                                    <input type="text" id="body_no" name="body_no" class="form-control essential-bg" readonly="readonly" required="required" alt="차대번호" value="${result.body_no}">
                                    <div class="d-flex mt5">
                                        <div class="mr5">
                                            <jsp:include page="/WEB-INF/jsp/common/commonMachineJob.jsp">
                                                <jsp:param name="li_machine_type" value="__machine_detail#__repair_history#__as_todo#__campaign#__change_cust"/>
                                            </jsp:include>
                                        </div>
                                        <div>
                                            <button type="button" class="btn btn-primary-gra" onclick="javascript:openWorkDB();">업무DB</button>
                                        </div>
                                    </div>
                                </td>
                                <th class="text-right">엔진모델1</th>
                                <td>
                                    <input type="text" id="engine_model_1" name="engine_model_1" class="form-control" readonly="readonly" value="${result.engine_model_1}">
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
                                            <span id="cap">${result.cap}</span>
                                        </div>
                                        <div class="col-5 text-right">
                                            <button type="button" class="btn btn-primary-gra" onclick="javascript:goCapLog();">CAP이력</button>
                                        </div>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <th class="text-right">장비모델</th>
                                <td>
                                    <input type="text" id="machine_name" name="machine_name" class="form-control" readonly="readonly" value="${result.machine_name}">
                                </td>
                                <th class="text-right">엔진번호1</th>
                                <td>
                                    <input type="text" id="engine_no_1" name="engine_no_1" class="form-control" readonly="readonly" value="${result.engine_no_1}">
                                </td>
                                <th class="text-right">CAP회차</th>
                                <td>
                                    <div class="form-row inline-pd widthfix">
                                        <div class="col width33px">
                                            현재
                                        </div>
                                        <div class="col width22px">
                                            <input type="text" id="cap_cnt" name="cap_cnt" class="form-control" readonly="readonly" value="${result.cap_cnt}">
                                        </div>
                                        <div class="col width16px">
                                            차,
                                        </div>
                                        <div class="col width33px pl5">
                                            다음
                                        </div>
                                        <div class="col width22px">
                                            <input type="text" id="next_cap_cnt" name="next_cap_cnt" class="form-control" readonly="readonly" value="${result.next_cap_cnt}">
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
                                    <input type="text" id="out_dt" name="out_dt" class="form-control width120px" readonly="readonly" dateformat="yyyy-MM-dd" value="${result.out_dt}">
                                </td>
                                <th class="text-right">가동시간</th>
                                <td>
                                    <div class="form-row inline-pd widthfix">
                                        <div class="col width70px">
                                            <input type="text" id="op_hour" name="op_hour" class="form-control text-right" value="${result.op_hour}">
                                        </div>
                                        <div class="col width33px">
                                            hr
                                        </div>
                                    </div>
                                </td>
                                <th class="text-right">CAP예정일자</th>
                                <td>
                                    <div class="input-group width120px">
                                        <input type="text" class="form-control border-right-0 calDate" id="cap_plan_dt" name="cap_plan_dt" dateFormat="yyyy-MM-dd" disabled="disabled" value="${result.cap_plan_dt}">
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
                                        <div class="col-5">
                                            <div class="input-group">
                                                <input type="text" id="cust_name" name="cust_name" class="form-control essential-bg" readonly="readonly" required="required" alt="차주명" value="${result.cust_name}">
                                            </div>
                                        </div>
                                        <div class="col-6">
                                            <jsp:include page="/WEB-INF/jsp/common/commonCustJob.jsp">
                                                <jsp:param name="li_type" value="__cust_dtl#__ledger#__visit_history#__as_call#__check_required"/>
                                            </jsp:include>
                                        </div>
                                    </div>
                                </td>
                                <th class="text-right">업체명</th>
                                <td>
                                    <input type="text" id="breg_name" name="breg_name" class="form-control" readonly="readonly" value="${result.breg_name}">
                                </td>
                                <th class="text-right">대표자</th>
                                <td>
                                    <input type="text" id="breg_rep_name" name="breg_rep_name" class="form-control width120px" readonly="readonly" value="${result.breg_rep_name}">
                                </td>
                            </tr>
                            <tr>
                                <th class="text-right">휴대폰</th>
                                <td>
                                    <div class="input-group width140px">
                                        <input type="text" id="hp_no" name="hp_no" class="form-control border-right-0" format="phone" readonly="readonly" value="${result.hp_no}">
                                        <button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSendSms('cust');" ><i class="material-iconsforum"></i></button>
                                    </div>
                                </td>
                                <th class="text-right">휴대폰(장비관리자)</th>
                                <td>
                                    <div class="input-group width120px">
                                        <input type="text" id="mng_hp_no" name="mng_hp_no" class="form-control border-right-0" readonly="readonly" value="${result.mng_hp_no}">
                                        <button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSendSms('mng');"><i class="material-iconsforum"></i></button>
                                    </div>
                                </td>
                                <th class="text-right">휴대폰(장비운영자)</th>
                                <td>
                                    <div class="input-group width120px">
                                        <input type="text" id="driver_hp_no" name="driver_hp_no" class="form-control border-right-0" readonly="readonly" value="${result.driver_hp_no}">
                                        <button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSendSms('driver');"><i class="material-iconsforum"></i></button>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <%--                        <th class="text-right">정비쿠폰<br>사용여부</th>--%>
                                <%--                        <td colspan="5">--%>
                                <%--                            <div class="form-row inline-pd">--%>
                                <%--                                <div class="col-10">--%>
                                <%--                                    <c:forEach items="${codeMap['COUPON_TYPE']}" var="item">--%>
                                <%--                                        <div class="form-check form-check-inline v-align-middle">--%>
                                <%--                                            <input type="checkbox" id="coupon_type_cd" name="coupon_type_cd" class="form-check-input" value="${item.code_value}">--%>
                                <%--                                            <label class="form-check-label">${item.code_name}</label>--%>
                                <%--                                        </div>--%>
                                <%--                                    </c:forEach>--%>
                                <%--                                </div>--%>
                                <%--                                <div class="col-2 text-right">--%>
                                <%--                                    <button type="button" class="btn btn-primary-gra" onclick="javascript:goCouponHistory();" >쿠폰사용이력</button>--%>
                                <%--                                </div>--%>
                                <%--                            </div>--%>
                                <%--                        </td>--%>
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
                                        <div class="col width80px">
                                            <input type="text" id="di_balance_amt" name="di_balance_amt" class="form-control text-right" readonly="readonly" format="decimal" value="${result.di_balance_amt}">
                                        </div> /&nbsp;
                                        <div class="col width80px">
                                            <input type="text" style="color:red;" id="misu_amt" name="misu_amt" class="form-control text-right" readonly="readonly" format="decimal" value="${result.misu_amt}">
                                        </div>
                                    </div>
                                </td>
                            </tr>
                            <%--                    <tr>--%>
                            <%--                        <th class="text-right">프로모션기간</th>--%>
                            <%--                        <td colspan="3">--%>
                            <%--                            <span id="pro_period">${result.pro_period}</span>--%>
                            <%--                        </td>--%>
                            <%--                        <th class="text-right">프로모션내용</th>--%>
                            <%--                        <td colspan="3">--%>
                            <%--                            <span id="pro_content">${result.pro_content}</span>--%>
                            <%--                        </td>--%>
                            <%--                        <th class="text-right">프로모션첨부</th>--%>
                            <%--                        <td id="file_search_td1">--%>
                            <%--                        </td>--%>
                            <%--                        <td id="file_name_td1" class="dpn">--%>
                            <%--                            <div class="table-attfile" id="file_name_div1">--%>
                            <%--                            </div>--%>
                            <%--                        </td>--%>
                            <%--                    </tr>--%>
                        </table>
                    </div>
                    <!-- /2. 고객정보 -->
                </div>
                <div class="row mt10">
                    <!-- 3. 정비접수 -->
                    <div class="col-6">
                        <div class="title-wrap mt10">
                            <h4>정비접수</h4>
                        </div>
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
                                        <input type="text" id="org_name" name="org_name" class="form-control border-right-0 width100px essential-bg" readonly="readonly" required="required" alt="센터" value="${result.org_name}">
                                        <button type="button" class="btn btn-icon btn-primary-gra" disabled onclick="javascript:openOrgMapCenterPanel('setOrgMapCenterPanel');"><i class="material-iconssearch"></i></button>
                                    </div>
                                </td>
                                <th class="text-right">접수번호</th>
                                <td>
                                    <div class="form-row inline-pd widthfix">
                                        <div class="col-auto">
                                            <input type="text" id="job_report_no" name="job_report_no" class="form-control width120px" readonly="readonly" value="${result.job_report_no}">
                                        </div>
                                    </div>
                                </td>
                                <th class="text-right">입고일자</th>
                                <td>
                                    <div class="input-group width120px">
                                        <input type="text" class="form-control border-right-0 calDate" id="in_dt" name="in_dt" dateFormat="yyyy-MM-dd" onchange="javascript:fnChangeInDt()" value="${result.in_dt}">
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <th class="text-right">접수자</th>
                                <td>
                                    <input type="text" class="form-control width120px" name="reg_mem_name" id="reg_mem_name" readonly="readonly" value="${result.reg_mem_name}">
                                </td>
                                <th class="text-right essential-item">접수구분</th>
                                <td>
                                    <div class="form-check form-check-inline">
                                        <input class="form-check-input" type="radio" id="receipt_type_rt_r" name="receipt_type_rt" value="R" <c:if test="${result.receipt_type_rt eq 'R'}">checked="checked"</c:if> required="required" onclick="javascript:goTypeRt();" alt="접수구분">
                                        <label class="form-check-label" for="receipt_type_rt_r">사전</label>
                                    </div>
                                    <div class="form-check form-check-inline">
                                        <input class="form-check-input" type="radio" id="receipt_type_rt_t"  name="receipt_type_rt" value="T" <c:if test="${result.receipt_type_rt eq 'T'}">checked="checked"</c:if> onclick="javascript:goTypeRt();" required="required" alt="접수구분">
                                        <label class="form-check-label" for="receipt_type_rt_t">당일</label>
                                    </div>
                                  <div class="form-check form-check-inline">
                                    <input class="form-check-input" type="radio" id="receipt_type_rt_a"  name="receipt_type_rt" value="A" <c:if test="${result.receipt_type_rt eq 'A'}">checked="checked"</c:if> onclick="javascript:goTypeRt();" required="required" alt="접수구분">
                                    <label class="form-check-label" for="receipt_type_rt_a">APP</label>
                                  </div>
                                </td>
                                <th class="text-right essential-item">정비종류</th>
                                <td>
                                    <div class="form-check form-check-inline">
                                        <input class="form-check-input" type="radio" id="job_case_ti_i" name="job_case_ti" value="I" <c:if test="${result.job_case_ti eq 'I'}">checked="checked"</c:if> onclick="javascript:fnJobCaseTi()" required="required" alt="정비종류">
                                        <label class="form-check-label" for="job_case_ti_i">입고</label>
                                    </div>
                                    <div class="form-check form-check-inline">
                                        <input class="form-check-input" type="radio" id="job_case_ti_t"  name="job_case_ti" value="T" <c:if test="${result.job_case_ti eq 'T'}">checked="checked"</c:if> onclick="javascript:fnJobCaseTi()" required="required" alt="정비종류">
                                        <label class="form-check-label" for="job_case_ti_t">출장</label>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <th class="text-right">배정</th>
                                <td>
                                    <div class="form-row inline-pd">
                                        <div class="col-12">
                                            <%--                                    <div class="input-group">--%>
                                            <%--                                        <input type="text" id="eng_mem_name" name="eng_mem_name" class="form-control border-right-0" value="${result.eng_mem_name}">--%>
                                            <%--&lt;%&ndash;                                        <button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openMemberOrgPanel('setMemberOrgMapPanel', 'N');"><i class="material-iconssearch"></i></button>&ndash;%&gt;--%>
                                            <%--                                        <button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goSearchEngMemInfo();"><i class="material-iconssearch"></i></button>--%>
                                            <%--                                    </div>--%>
                                            <jsp:include page="/WEB-INF/jsp/common/searchMem.jsp">
                                                <jsp:param name="required_field" value=""/>
                                                <jsp:param name="s_org_code" value=""/>
                                                <jsp:param name="s_work_status_cd" value=""/>
                                                <jsp:param name="readonly_field" value=""/>
                                                <jsp:param name="execFuncName" value="setMemberOrgMapPanel"/>
                                            </jsp:include>
                                        </div>
<%--                                        <div class="col-4">--%>
<%--                                            <button type="button" id="_goEngProcess" class="btn btn-primary-gra" onclick="javascript:goEngProcess();">배정처리</button>--%>
<%--                                        </div>--%>
                                    </div>
                                </td>
                                <th class="text-right essential-item">정비구분</th>
                                <td colspan="3">
                                    <c:forEach items="${codeMap['JOB_TYPE']}" var="item">
                                        <div class="form-check form-check-inline v-align-middle">
                                            <input type="radio" id="${item.code_value}" name="job_type_cd" class="form-check-input" value="${item.code_value}" <c:if test="${result.job_type_cd eq item.code_value}">checked="checked"</c:if> required="required" alt="정비구분" onchange="javascript:fnChangeJobType();">
                                            <label class="form-check-label" for="${item.code_value}">${item.code_name}</label>
                                        </div>
                                    </c:forEach>
                                    <span class="form-check form-check-inline v-align-middle">ㅣ</span>
                                    <c:forEach items="${codeMap['JOB_TYPE2']}" var="item">
                                      <div class="form-check form-check-inline v-align-middle">
                                        <input type="radio" id="${item.code_value}" name="job_type2_cd" class="form-check-input" value="${item.code_value}" <c:if test="${result.job_type2_cd eq item.code_value}">checked="checked"</c:if> alt="정비구분2">
                                        <label class="form-check-label" for="${item.code_value}">${item.code_name}</label>
                                      </div>
                                    </c:forEach>
                                </td>
                              <%-- 자동화 개발건 - 제거 --%>
<%--                                <th class="text-right">유/무상</th>--%>
<%--                                <td>--%>
<%--                                    <div class="form-check form-check-inline">--%>
<%--                                        <input class="form-check-input" type="radio" id="cost_yn_y" name="cost_yn" value="Y" <c:if test="${result.cost_yn eq 'Y'}">checked="checked"</c:if> alt="유/무상">--%>
<%--                                        <label class="form-check-label" for="cost_yn_y">유상</label>--%>
<%--                                    </div>--%>
<%--                                    <div class="form-check form-check-inline">--%>
<%--                                        <input class="form-check-input" type="radio" id="cost_yn_n"  name="cost_yn" value="N" <c:if test="${result.cost_yn eq 'N'}">checked="checked"</c:if> alt="유/무상">--%>
<%--                                        <label class="form-check-label" for="cost_yn_n">무상</label>--%>
<%--                                    </div>--%>
<%--                                </td>--%>
                            </tr>
                            </tbody>
                        </table>
                    </div>
                    <!-- 3. 정비접수 -->
                    <!-- 4. 접수상세 -->
                    <div class="col-6">
                        <div class="title-wrap mt10">
                            <h4>접수상세</h4>
                            <div calss="btn-group">
                                <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_M"/></jsp:include>
                                <button type="button" id="sar_oper_btn" style="display : none;" class="btn btn-primary-gra" onclick="javascript:goSarOperationMap('OPERATION');">SA-R 운행정보</button>
                                <button type="button" class="btn btn-default" onclick="javascript:goMap();"><i class="material-iconsplace text-default"></i>지도보기</button>
                            </div>
                        </div>
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
<%--                                                <option value="0830" <c:if test="${result.reserve_repair_ti eq '0830' or empty result.reserve_repair_ti}">selected="selected"</c:if>>08:30</option>--%>
                                                <c:forEach var="hr" varStatus="i" begin="6" end="23" step="1">
                                                    <c:forEach var="min" varStatus="j" begin="0" end="1">
                                                        <option value="<c:if test="${hr < 10}">0</c:if><c:out value="${hr}"/><c:out value="${min eq 0 ? '00' : '30'}"/>"
                                                                <c:if test="${fn:substring(result.reserve_repair_ti,0,2) eq (hr < 10 ? '0' + hr : hr) and fn:substring(result.reserve_repair_ti,2,4) eq (min eq 0 ? '00' : '30')}">selected="selected"</c:if>>
                                                            <c:if test="${hr < 10}">0</c:if><c:out value="${hr}"/>:<c:out value="${min eq 0 ? '00' : '30'}"/>
                                                        </option>
                                                    </c:forEach>
                                                </c:forEach>
<%--                                                <option value="1800" <c:if test="${result.reserve_repair_ti eq '1800'}">selected="selected"</c:if>>18:00</option>--%>
                                            </select>
                                        </div>
                                        ~
                                        <div class="col-4">
                                            <select class="form-control" id="reserve_repair_ed_ti" name="reserve_repair_ed_ti" onchange="javascript:fnChangeInDt()">
                                                <c:forEach var="hr" varStatus="i" begin="6" end="23" step="1">
                                                    <c:forEach var="min" varStatus="j" begin="0" end="1">
                                                        <option value="<c:if test="${hr < 10}">0</c:if><c:out value="${hr}"/><c:out value="${min eq 0 ? '00' : '30'}"/>"
                                                                <c:if test="${fn:substring(result.reserve_repair_ed_ti,0,2) eq (hr < 10 ? '0' + hr : hr) and fn:substring(result.reserve_repair_ed_ti,2,4) eq (min eq 0 ? '00' : '30')}">selected="selected"</c:if>>
                                                            <c:if test="${hr < 10}">0</c:if><c:out value="${hr}"/>:<c:out value="${min eq 0 ? '00' : '30'}"/>
                                                        </option>
                                                    </c:forEach>
                                                </c:forEach>
                                            </select>
                                        </div>
                                        <div class="col-4">
                                            <button type="button" class="btn btn-default" id="_goSendSmsReserve" name="_goSendSmsReserve" onclick="javascript:goSendSmsReserve();">예약확정</button>
                                        </div>
                                        <div class="col-4" id="reserve_confirm_msg">
                                            <c:if test="${result.reserve_sms_send_yn eq 'Y'}">
                                                발송완료
                                            </c:if>
                                        </div>
                                    </div>
                                </td>
                                <th class="text-right">예상규정시간</th>
                                <td>
                                    <div class="form-row inline-pd widthfix">
                                        <div class="col width100px">
                                            <input type="text" id="except_repair_hour" name="except_repair_hour" class="form-control text-right" readonly="readonly" value="${result.except_repair_hour}">
                                        </div>
                                        <div class="col width33px">hr</div>
                                    </div>
                                </td>
                                <th class="text-right">렌탈수리청구고객</th>
                                <td>
                                    <div class="form-row inline-pd pr">
                                        <div class="col-9">
                                            <div class="input-group">
                                                <input type="text" id="rental_cust_name" name="rental_cust_name" class="form-control border-right-0" readonly="readonly" alt="렌탈고객" value="${result.rental_cust_name}">
                                                <input type="hidden" id="rental_cust_no" name="rental_cust_no" value="${result.rental_cust_no}">
                                                <button type="button" id="rental_cust_btn" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchCustPanel('fnSetRentalCust');" <c:if test="${result.cust_no ne '20130603145119670'}">disabled</c:if>><i class="material-iconssearch"></i></button>
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
                                            <option value="${list.svc_travel_info}" <c:if test="${list.svc_travel_info.split(\"#\")[0] == result.svc_travel_expense_seq}">selected="selected"</c:if> >${list.area_name}</option>
                                        </c:forEach>
                                    </select>
                                </td>
                                <th class="text-right">출장위치</th>
                                <td>
                                    <input type="text" id="travel_area_name" name="travel_area_name" class="form-control" value="${result.travel_area_name}">
                                </td>
                                <th class="text-right">출장거리</th>
                                <td>
                                    <div class="form-row inline-pd widthfix">
                                        <div class="col width100px">
                                            <input type="text" id="travel_km" name="travel_km" class="form-control text-right" value="${result.travel_km}">
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
                                            <input type="text" id="distance_min" name="distance_min" class="form-control text-right width35px" placeholder="From" datatype="int" format="decimal" value="${result.distance_min}">
                                        </div>
                                        <div class="col-auto">
                                            km
                                        </div>
                                        <div class="col-auto">
                                            <input type="text" id="distance_max" name="distance_max" class="form-control text-right width35px" placeholder="To" datatype="int" format="decimal" value="${result.distance_max}">
                                        </div>
                                        <div class="col width40px">
                                            km,
                                        </div>

                                        <div class="col-auto">
                                            이동시간
                                        </div>
                                        <div class="col-auto">
                                            <input type="text" id="travel_hour" name="travel_hour" class="form-control text-right width40px" format="decimal"  onchange="javascript:fnCalcPlanTravelPrice();" value="${result.travel_hour}">
                                        </div>
                                        <div class="col-auto">
                                            hr,
                                        </div>

                                        <div class="col-auto">
                                            시간당 금액
                                        </div>
                                        <div class="col-auto">
                                            <input type="text" id="travel_hour_price" name="travel_hour_price" class="form-control text-right width60px" format="decimal" readonly="readonly" value="${result.travel_hour_price}">
                                        </div>
                                        <div class="col-auto">
                                            원,
                                        </div>

                                        <div class="col-auto">
                                            총 금액
                                        </div>
                                        <div class="col-auto">
                                            <input type="text" id="tot_travel_hour_price" name="tot_travel_hour_price" class="form-control text-right width60px" format="decimal" readonly="readonly" value="${result.plan_travel_expense}">
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
                                            <input type="text" id="travel_expense" name="travel_expense" class="form-control text-right" datatype="int" format="decimal" onchange="javascript:fnChangeTravelPrice();" value="${result.travel_expense}">
                                        </div>
                                        <div class="col width16px mr5">원</div>
                                        <input type="hidden" id="travel_discount_amt" name="travel_discount_amt" class="form-control text-right" datatype="int" format="decimal" onchange="javascript:fnChangeTravelPrice();" value="${result.travel_discount_amt}">
                                        <input type="hidden" id="travel_final_expense" name="travel_final_expense" class="form-control text-right" datatype="int" format="decimal" value="${result.travel_final_expense}">
                                    </div>
                                </td>
                            </tr>
                            </tbody>
                        </table>
                    </div>
                    <!-- 4. 정비접수 -->
                </div>
            </div>
            <!-- /상단 폼테이블 -->
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
                            <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_L"/></jsp:include>
                        </div>
                    </div>
                    <div id="auiGridReportOrder" style="margin-top: 5px; height: 620px;"></div>
                    <!-- /4. 작업지시 -->
                    <!-- 8. 메모 -->
                    <div class="row mt10">
                        <div class="col-6">
                            <div class="title-wrap">
                                <h4>고객 앱 수신정보</h4>
                            </div>
                            <table class="table-border mt5">
                                <colgroup>
                                    <col width="80px">
                                    <col width="150px">
                                    <col width="75px">
                                    <col width="">
                                </colgroup>
                                <tbody>
                                    <tr>
                                        <th class="text-right">고객희망시간</th>
                                        <td>
                                            <input type="text" class="form-control" alt="고객희망시간" value="${result.request_date}" disabled>
                                        </td>
                                        <th class="text-right">고장증상</th>
                                        <td>
                                            <input type="text" class="form-control" alt="고장증상" value="${result.c_mch_break_name}" disabled>
                                        </td>
                                    </tr>
                                    <tr>
                                        <th class="text-right">고장사진</th>
                                        <td colspan="3">
                                            <div class="table-attfile att_file_divC" style="width:100%;">
                                                <div class="table-attfile" style="float:left">
                                                    <button type="button" class="btn btn-primary-gra mr5" onclick="javascript:fnShowFile('C');">파일 이미지보기</button>
                                                </div>
                                            </div>
                                        </td>
                                    </tr>
                                    <tr>
                                        <th class="text-right">출장요청지역</th>
                                        <td colspan="3">
                                            <input type="text" class="form-control" alt="출장요청지역" value="${result.cust_travel_area}" disabled>
                                        </td>
                                    </tr>
                                    <tr>
                                        <th class="text-right">고장내용</th>
                                        <td colspan="3">
                                            <textarea class="form-control" style="height: 75px;" disabled>${result.request_text}</textarea>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                        <div class="col-6">
                            <div class="title-wrap">
                                <h4>8. 메모</h4>
                                <div class="right">
                                    <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_M"/></jsp:include>
                                </div>
                            </div>
                            <textarea class="form-control" id="job_text" name="job_text" style="margin-top: 5px; height: 200px;" maxlength="2000">${result.job_text}</textarea>
                        </div>
                    </div>
                    <!-- /8. 메모 -->
                </div>
                <!-- /하단좌측 폼테이블 -->
                <!-- 하단우측 폼테이블 -->
                <div class="col-6">
                    <!-- 5. 부품목록 -->
                    <div class="title-wrap mt10">
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
                    <div class="title-wrap mt5">
                        <div class="left">
                            <h4>정비작업</h4>
                        </div>
                        <div calss="btn-group">
                            <div class="right dpf">
                                <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_M"/></jsp:include>
                                <span class="mr3"></span>
                                <span class="mr3">정비시간</span>
                                <input type="text" id="work_ti" name="work_ti" class="form-control width60px text-right mr3" readonly="readonly">
                                <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
                            </div>
                        </div>
                    </div>
                    <div id="auiGridReportWork" style="margin-top: 5px; height: 130px;"></div>
                    <!-- /6. 정비작업 -->
                    <div class="title-wrap mt5">
                        <h4>정비사진</h4>
                        <c:if test="${(SecureUser.mem_no eq result.reg_mem_no or SecureUser.mem_no eq result.eng_mem_no) and result.repair_complete_yn ne 'Y'}">
                            <div class="btn-group">
                                <div class="right">
                                    <button type="button" class="btn btn-primary-gra" onclick="javascript:goSavePic();">파일저장</button>
                                </div>
                            </div>
                        </c:if>
                    </div>
                    <table class="table-border mt5">
                        <colgroup>
                            <col width="120px">
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
                            <th class="text-right">정비지시서</th>
                            <td>
                                <div class="table-attfile att_file_divJ" style="width:100%;">
                                    <div class="table-attfile" style="float:left">
                                        <button type="button" class="btn btn-primary-gra mr5" onclick="javascript:fnShowFile('J');">파일 이미지보기</button>
                                        <c:if test="${result.repair_complete_yn ne 'Y'}">
                                            <button type="button" class="btn btn-primary-gra mr10" onclick="javascript:fnAddFile('J');">파일찾기</button>
                                        </c:if>
                                    </div>
                                </div>
                                <div class="table-attfile att_file_divM mt5">
                                </div>
                            </td>
                        </tr>
                        </tbody>
                    </table>
                    <!-- 7. 비용 -->
                    <div class="title-wrap mt10">
                        <div class="left">
                            <h4>비용</h4>
                            <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BASE_R"/></jsp:include>
                        </div>
                        <c:if test="${not empty useCustSvcCouponText}">
                            <div class="rigth" style="font-weight: bold">
                                쿠폰사용내역 :
                                <span class="text-warning">
                                        ${useCustSvcCouponText}
                                </span>
                            </div>
                        </c:if>
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
                                <input type="text" class="form-control text-right" id="plan_travel_expense" name="plan_travel_expense" format="decimal" readonly="readonly" value="${result.plan_travel_expense}">
                            </td>
                            <td>
                                <input type="text" class="form-control text-right" id="plan_work_total_amt" name="plan_work_total_amt" format="decimal" readonly="readonly" value="${plan_work_total_amt}">
                            </td>
                            <td>
                                <input type="text" class="form-control text-right" id="plan_part_total_amt" name="plan_part_total_amt" format="decimal" readonly="readonly" value="${plan_part_total_amt}">
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
                                <input type="text" class="form-control text-right" id="work_total_amt" name="work_total_amt" format="decimal" readonly="readonly" value="${result.work_total_amt}">
                            </td>
                            <td>
                                <input type="text" class="form-control text-right" id="part_total_amt" name="part_total_amt" format="decimal" readonly="readonly" value="${result.part_total_amt}">
                            </td>
                            <td>
                                <input type="text" class="form-control text-right" id="total_amt" name="total_amt" format="decimal" readonly="readonly" value="${result.total_amt}">
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
