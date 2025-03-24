<%@ page contentType="text/html;charset=utf-8" language="java"%><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>

<!DOCTYPE html>
<html>
<head>
<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var custGradeList = JSON.parse('${codeMapJsonObj['CUST_GRADE']}');
		var i = ${total_cnt == 0 ? 1 : total_cnt};

		var dateidx = 0;
		var now = "${inputParam.s_current_dt}";

		
		$(document).ready(function () {
			setCustGradeDesc("${bean.cust_grade_cd}");
			
			$("#consult_type_cd_03").prop('checked', true);
		});

		// 문자발송
		function fnSendSms() {
			var params = {
				"name": $M.getValue("cust_name"),
				"hp_no": $M.getValue("hp_no")
			};
			openSendSmsPanel($M.toGetParam(params));
		}

		function fnChangeComplete(obj) {
			console.log(obj);

			// 체크여부 확인
			if ($(obj).is(":checked") == true) {
				$(obj).val("N");
			} else {
				$(obj).val("Y");
			}
		}

		function fnRemoveRow(button) {
			if (confirm("작성한 내용을 삭제 하시겠습니까?") == false) {
				return;
			}
			
			button.closest("tr").remove();
			i--;
			dateidx--;
		}

		//본인이 작성한 상담정보 삭제할때
		function fnUpdateUseYnRow(obj) {
			if (confirm("해당 상담건을 삭제하시겠습니까?") == false) {
				return false;
			}
			
			var tr = $(obj).closest("tr");
			var td = tr.children();
			td.find('[id^="use_yn"]').val("N");
			td.find('[id^="consult_dt"]').val("1900-01-01");
			td.find('[id^="consult_dt"]').removeAttr("required");

			$(obj).closest("tr").hide();
			
			goModify("Y");
			
		}


		function setCustGradeDesc(value) {
			for (var i = 0; i < custGradeList.length; i++) {
				if (value == custGradeList[i].code_value) {
					$M.setValue("cust_grade_desc", custGradeList[i].code_desc);
				}
				;
			}

		}

		function goModelInfoClick() {

			var param = {
				s_machine_name: $M.getValue("machine_name"),
				s_price_present_yn: "Y"
			};
			openSearchModelPanel('fnSetModelInfo', 'N', $M.toGetParam(param));
		}


		//모델조회 결과반영
		function fnSetModelInfo(row) {

			$M.setValue("machine_name", row.machine_name);
			$M.setValue("machine_plant_seq", row.machine_plant_seq);
		}


		function chkTime24H(time) {

			// replace 함수를 사용하여 콜론( : )을 공백으로 치환한다.
			var replaceTime = time.value.replace(/\:/g, "");

			// 텍스트박스의 입력값이 4이상부터 실행한다.
			if (replaceTime.length >= 4) {

				if (replaceTime.length >= 5) {
					alert("시간은 4자리로 입력해 주세요 ");
					time.value = "00:00";
					return false;
				} else {
					var hours = replaceTime.substring(0, 2);      // 선언한 변수 hours에 시간값을 담는다.
					var minute = replaceTime.substring(2, 4);    // 선언한 변수 minute에 분을 담는다.

					// isFinite함수를 사용하여 문자가 선언되었는지 확인한다.
					if (isFinite(hours + minute) == false) {
						alert("문자는 입력하실 수 없습니다.");
						time.value = "00:00";
						return false;
					}

					// 두 변수의 시간과 분을 합쳐 입력한 시간이 24시가 넘는지를 체크한다.
					if (hours + minute > 2400) {
						alert("시간은 24시를 넘길 수 없습니다.");
						time.value = "24:00";
						return false;
					}

					// 입력한 분의 값이 60분을 넘는지 체크한다.
					if (minute > 60) {
						alert("분은 60분을 넘길 수 없습니다.");
						time.value = hours + ":00";
						return false;
					}
					time.value = hours + ":" + minute;
				}
			}
		}


		function fnCalcCunsultTi(obj) {

			chkTime24H(obj);

			var str = $(obj).attr('id');
			var last = "";

			last = str.split('_').pop();

			var starttime = $("input[id='consult_st_ti_" + last + "']").val();
			var endtime = $("input[id='consult_ed_ti_" + last + "']").val();

			if (starttime != 0) {
				var hour = parseInt(endtime.substring(0, 2), 10)
						- parseInt(starttime.substring(0, 2), 10);
				var minute = parseInt(endtime.substring(3, 5), 10)
						- parseInt(starttime.substring(3, 5), 10);
				var consulttime = (hour * 60) + minute;
				$("input[id='consult_min_" + last + "']").val(consulttime);
			}

			if (!$.isNumeric($("input[id='consult_min_" + last + "']").val())) {
				$("input[id='consult_min_" + last + "']").val("");
			}

		}


		function goModify(flag) {
			if (flag != "Y") {
				if (confirm("저장 하시겠습니까?") == false) {
					return false;
				}
			}
			
			var frm = document.main_form;
			// validation check
			if ($M.validation(frm) === false) {
				return;
			}

			//상담내용은 배열로 만들어서 넘기기
			var consultSeqArr = [];
			var seqNoArr = [];
			var consultDtArr = [];
			var consultCaseCdArr = [];
			var consultStTiArr = [];
			var consultEdTiArr = [];
			var consultMinArr = [];
			var consultTextArr = [];
			var completeYnArr = [];
			var regMemNoArr = [];
			var useYnArr = [];
			var regIdArr = [];
			var cmdArr = [];

			//테이블에서 한개씩 선택해서 배열에 넣기
			$('tr[id^="tr_consult"]').each(function () {
				var tr = $(this);
				var td = tr.children();

				//상담내용 등록,수정 및 삭제는 본인이 등록한 내용만 처리함
				if (td.find('[id^="reg_mem_no"]').val() == "${SecureUser.mem_no}") {

					consultSeqArr.push($M.getValue("cust_consult_seq"));
					
// 					seqNoArr.push(td.find('[id^="seq_no"]').val());
// 					consultDtArr.push(td.find('[id^="consult_dt"]').val().replace(/-/gi, ""));
// 					consultCaseCdArr.push(td.find('input[name^="consult_case_cd"]:checked').val());
// 					consultStTiArr.push(td.find('[id^="consult_st_ti"]').val());
// 					consultEdTiArr.push(td.find('[id^="consult_ed_ti"]').val());
// 					consultMinArr.push(td.find('[id^="consult_min"]').val());
// 					consultTextArr.push(td.find('[id^="consult_text"]').val());
// 					completeYnArr.push(td.find('[id^="complete_yn"]').val());
// 					regMemNoArr.push(td.find('[id^="reg_mem_no"]').val());
// 					useYnArr.push(td.find('[id^="use_yn"]').val());
					regIdArr.push("${SecureUser.mem_no}");
					
					$M.setHiddenValue(frm, "seq_no", td.find('[id^="seq_no"]').val());
					$M.setHiddenValue(frm, "consult_dt", td.find('[id^="consult_dt"]').val().replace(/-/gi, ""));
					$M.setHiddenValue(frm, "consult_case_cd", td.find('input[name^="consult_case_cd"]:checked').val());
					$M.setHiddenValue(frm, "consult_st_ti", "0000");
					$M.setHiddenValue(frm, "consult_ed_ti", "0000");
					$M.setHiddenValue(frm, "consult_min", "0");
					$M.setHiddenValue(frm, "consult_text", td.find('[id^="consult_text"]').val());
					$M.setHiddenValue(frm, "complete_yn", td.find('[id^="complete_yn"]').val());
					$M.setHiddenValue(frm, "reg_mem_no", td.find('[id^="reg_mem_no"]').val());
					$M.setHiddenValue(frm, "use_yn", td.find('[id^="use_yn"]').val());

					console.log("consult_seq : ", td.find('[id^="consult_seq"]').val());
					console.log("seq_no : ", td.find('[id^="seq_no"]').val());
					
					//등록정보가 없으면 신규로
					if (td.find('[id^="consult_seq"]').val() == "" || td.find('[id^="seq_no"]').val() == "") {
// 						cmdArr.push("C");
						$M.setHiddenValue(frm, "cmd", "C");
					} else {
						//나머지는 모두 수정으로
// 						cmdArr.push("U");
						$M.setHiddenValue(frm, "cmd", "U");
					}
				}
			});

			var bDupleConsultDt = false;
			var chkConsultDt = "";

			//동일한 사람이 동일한 날에 1개이상 상담 등록 불가
			for (i = 0; i < consultDtArr.length; i++) {
				if (useYnArr[i] == "Y") {
					chkConsultDt = consultDtArr[i];
					for (j = 0; j < consultDtArr.length; j++) {
						if (i != j && chkConsultDt == consultDtArr[j] && useYnArr[j] == "Y") {
							bDupleConsultDt = true;
						}
					}
				}
			}

			if (bDupleConsultDt) {
				alert("동일한 사람이 동일한 날짜로 상담내역을 2번이상 등록할 수 없습니다.");
				return;
			}

			for (i = 0; i < consultMinArr.length; i++) {
				if (!$.isNumeric(consultMinArr[i])) {
					alert("상담시간이 올바르지 않습니다.");
					return;
				} else if (consultMinArr[i] < 0) {
					alert("상담시간은 0이상이어야 합니다.");
					return;
				}
			}

			/*
			seq_no_str: $M.getArrStr(seqNoArr, option),
				consult_dt_str: $M.getArrStr(consultDtArr, option),
				consult_case_cd_str: $M.getArrStr(consultCaseCdArr, option),
				: $M.getArrStr(, option),
				: $M.getArrStr(, option),
				: $M.getArrStr(, option),
				: $M.getArrStr(, option),
				: $M.getArrStr(, option),
				: $M.getArrStr(, option),
				: $M.getArrStr(, option),
				: $M.getArrStr(, option)
			 */

			console.log("frm : ", frm);
			 
// 			frm = $M.toValueForm(document.main_form);
// 			var option = {
// 				isEmpty : true
// 			};

// 			$M.setValue(frm, "seq_no_str", $M.getArrStr(seqNoArr, option));
// 			$M.setValue(frm, "consult_dt_str", $M.getArrStr(consultDtArr, option));
// 			$M.setValue(frm, "consult_case_cd_str", $M.getArrStr(consultCaseCdArr, option));
// 			$M.setValue(frm, "consult_st_ti_str", $M.getArrStr(consultStTiArr, option));
// 			$M.setValue(frm, "consult_ed_ti_str", $M.getArrStr(consultEdTiArr, option));
// 			$M.setValue(frm, "consult_min_str", $M.getArrStr(consultMinArr, option));
// 			$M.setValue(frm, "consult_text_str", $M.getArrStr(consultTextArr, option));
// 			$M.setValue(frm, "complete_yn_str", $M.getArrStr(completeYnArr, option));
// 			$M.setValue(frm, "use_yn_str", $M.getArrStr(useYnArr, option));
// 			$M.setValue(frm, "reg_id_str", $M.getArrStr(regIdArr, option));
// 			$M.setValue(frm, "cmd_str", $M.getArrStr(cmdArr, option));

			$M.goNextPageAjax("/cust/cust0101p01/update", frm, {method: 'POST'},
				function (result) {
					if (result.success) {
						alert("처리가 완료되었습니다.");
						var param = {
							"cust_consult_seq" : result.cust_consult_seq,
							"cust_no" : result.cust_no
						};

						$M.goNextPage('/cust/cust0101p04', $M.toGetParam(param));
					}
				}
			);
		}

		function goRemove() {
			if (confirm("현재 작성된 상담내용을 포함한 \n과거 모든 상담내용을 삭제하시겠습니까?") == false) {
				return;
			}
			
			if ($M.getValue("cust_consult_seq") != "") {
				var param = {
					cust_consult_seq: $M.getValue("cust_consult_seq")
				}

				$M.goNextPageAjaxRemove("/cust/cust0101p01/remove", $M.toGetParam(param), {method: 'POST'},
						function (result) {
							if (result.success) {
								fnClose();
								window.opener.goSearch();
							}
						}
				);
			} else {
				alert("등록된 안건상담정보가 없습니다.");
				return;
			}
		}

		function fnClose() {
			window.close();
		}

		function fnAddRows() {
			i++;
			$('#cust_info > tbody:last').prepend('<tr id="tr_consult_' + i + '" >' +
					'<th class="text-right essential-item ">' +
					'상담내용 ' + i + '</th>' +
					'<td colspan="5">' +
					'<div class=" inline-pd ">' +
					'<div class="input-group ">' +
					'<input type="hidden"  id="consult_seq_' + i + '"  	name="consult_seq_' + i + '" 	value="" >' +
					'<input type="hidden"  id="seq_no_' + i + '"  		name="seq_no_' + i + '" 		value="" >' +
					'<input type="hidden"  id="use_yn_' + i + '"  		name="use_yn_' + i + '" 		value="Y" >' +
					'<input type="hidden"  id="reg_mem_no_' + i + '"  	name="reg_mem_no_' + i + '" 	value="${SecureUser.mem_no}" >' +
					'<div class="pl5 pr5">' +
					'<div class="input-group">' +
					'상담일자</div>' +
					'</div>' +
					'<div class="">' +
					'<div class="input-group">' +
					'<input type="text" class="form-control border-right-0 calDate"  id="consult_dt_' + i + '" name="consult_dt_' + i + '" dateformat="yyyy-MM-dd" alt="상담일자" value=""  required="required"  >' +
					'</div>' +
					'</div>' +
					'<div class="pl10 pr5">' +
					'<div class="input-group">' +
					'상담자</div>' +
					'</div>' +
					'<div class="">' +
					'<div class="">' +
					'<input type="text" class="form-control   width120px"  value="${SecureUser.kor_name}" name="consult_reg_name_' + i + '"  readonly="readonly"  >' +
					'</div>' +
					'</div>' +
// 					'<div class="pl10 pr5">' +
// 					'<div class="input-group">' +
// 					'상담시간</div>' +
// 					'</div>' +
// 					'<div class="">' +
// 					'<div class="input-group">' +
// 					'<input type="text" class="form-control essential-bg   width60px" style="border-radius: 4px;" name="consult_st_ti_' + i + '" id="consult_st_ti_' + i + '"  placeholder="HH:MM"  onkeyup="javascript:fnCalcCunsultTi(this);"  minlength="4"  maxlength="5" required="required" alt="상담시작시간"  >' +
// 					'<div class="form-row inline-pd">' +
// 					'<div class="input-group">' +
// 					'&nbsp;&nbsp;~&nbsp;&nbsp;</div>' +
// 					'</div>' +
// 					'<input type="text" class="form-control essential-bg   width60px" style="border-radius: 4px;" name="consult_ed_ti_' + i + '" id="consult_ed_ti_' + i + '"  placeholder="HH:MM"  onkeyup="javascript:fnCalcCunsultTi(this);"  minlength="4"  maxlength="5" required="required" alt="상담종료시간"  >' +
// 					'&nbsp;&nbsp;</div>' +
// 					'</div>' +
// 					'<div class="pl5">' +
// 					'<div class="input-group">' +
// 					'<input type="text" class="form-control text_right width50px" id="consult_min_' + i + '"   name="consult_min_' + i + '"  style="border-radius: 4px;" readonly="readonly">' +
// 					'</div>' +
// 					'</div>' +
// 					'<div class="pr5">' +
// 					'<div class="input-group">' +
// 					'<div class="input-group">' +
// 					'&nbsp;&nbsp;분</div>' +
// 					'</div>' +
// 					'</div>' +
					'<div class="pl10 pr5">' +
					'<div class="input-group">' +
					'상담방법</div>' +
					'</div>' +
					'<div class="algin-item-center">' +
					'<div class="form-check form-check-inline">' +
					'<input class="form-check-input" type="radio" id="consult_case_cd_' + i + '_1"  name="consult_case_cd_' + i + '" value="0" checked="checked" >' +
					'<label for="consult_case_cd_' + i + '_1" class="form-check-label">' +
					'전화</label>' +
					'</div>' +
					'<div class="form-check form-check-inline mr3">' +
					'<input class="form-check-input" type="radio" id="consult_case_cd_' + i + '_2"  name="consult_case_cd_' + i + '" value="1" >' +
					'<label for="consult_case_cd_' + i + '_2" class="form-check-label">' +
					'약속</label>' +
					'</div>' +
					'<div class="form-check form-check-inline mr3">' +
					'<input class="form-check-input" type="radio" id="consult_case_cd_' + i + '_3"  name="consult_case_cd_' + i + '" value="2">' +
					'<label for="consult_case_cd_' + i + '_3" class="form-check-label">' +
					'임의방문</label>' +
					'</div>' +
					'</div>' +
					'<div class="pl10">' +
					'<div class="form-check form-check-inline">' +
					'<input class="form-check-input" type="checkbox" id="complete_yn_' + i + '" name="complete_yn_' + i + '"  onclick="javascript:fnChangeComplete(this)" value="N" >' +
					'<label class="form-check-label">' +
					'미결사항</label>' +
					'</div>' +
					'</div>' +
					'<div class="right">' +
					'<button type="button" class="btn btn-primary-gra" style="width: 60px;" onclick="fnRemoveRow(this);">' +
					'상담삭제</button>' +
					'</div>' +
					'</div>' +
					'</div>' +
					'<div class="mt5">' +
					'<textarea class="essential-bg" style="height: 100px;" id="consult_text_' + i + '" name="consult_text_' + i + '" required="required" alt="상담내용" >' +
					'</textarea>' +
					'</div>' +
					'</td>' +
					'</tr>'
			);

			$("#consult_dt_" + i).val($M.formatDate($M.addDates($M.toDate(now), dateidx)));
			$(".calDate").datepicker();

			$('html, body').animate({scrollTop: $("#consult_text_" + i).offset().top}, 500);
			dateidx++;
		}
		
		// 상담종료
		function fnEndConsult() {
			if ($M.getValue("end_yn") == "Y") {
				alert("이미 종료된 상담입니다.");
				return false;
			}
			
			if (confirm("상담을 종료하시겠습니까?") == false) {
				return false;
			}
			
			var param = {
					cust_consult_seq : $M.getValue("cust_consult_seq"),
			}
			
			$M.goNextPageAjax("/cust/cust0101p01/endConsult", $M.toGetParam(param) , {method : 'POST'},
				function(result) {
		    		if(result.success) {
		    			alert("상담종료가 완료되었습니다.");
		    			location.reload();
					}
				}
			);
		}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" id="cust_no" name="cust_no" value="${bean.cust_no}">
<input type="hidden" id="mem_no" name="mem_no" value="${bean.mem_no == '' ? SecureUser.mem_no : bean.mem_no }">
<input type="hidden" id="org_code" name="org_code" value="${bean.org_code == '' ? SecureUser.org_code : bean.org_code }">
<input type="hidden" id="cust_consult_seq" name="cust_consult_seq" value="${inputParam.cust_consult_seq}">
<input type="hidden" id="machine_seq" name="machine_seq" value="${bean.own_machine_seq}">
<input type="hidden" id="end_yn" name="end_yn" value="${bean.end_yn}">
	<!-- 팝업 -->
	<div class="popup-wrap width-100per">
		<!-- 타이틀영역 -->
		<div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
		</div>
		<!-- /타이틀영역 -->

		<div class="content-wrap">
			<!-- 폼테이블 -->
			<div class="title-wrap">
				<h4>렌탈안건상담상세</h4>
			</div>
			<div class="form-group mt5">
				<table id="cust_info" class="table-border">
					<colgroup>
						<col width="100px">
						<col width="">
						<col width="100px">
						<col width="">
						<col width="100px">
						<col width="">
					</colgroup>
					<tbody>
					<tr>
						<th class="text-right">고객명</th> <!-- 필수항목일때 클래스 essential-item 추가 -->
						<td>
							<div class="input-group">
								<input type="text" class="form-control width120px " value="${bean.cust_name}" id="cust_name" name="cust_name" readonly="readonly">
								<!-- 필수항목일때 클래스 essential-bg 추가 -->
							</div>
						</td>
						<th class="text-right">휴대폰</th>
						<td>
							<div class="form-row inline-pd">
								<div class="col-12">
									<div class="input-group">
										<input type="text" class="form-control  border-right-0" value="${bean.hp_no}" id="hp_no" name="hp_no" format="phone" readonly="readonly">
										<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSendSms();"><i class="material-iconsforum"></i></button>
									</div>
								</div>
							</div>
						</td>
						<th class="text-right">고객등급</th>
						<td>
							<div class="form-row ">
								<div class="col-10">
									<input type="text" class="form-control" id="cust_grade_desc" name="cust_grade_desc" readonly="readonly" disabled="disabled">
								</div>
								<div class="col-2">
									<select class="form-control" name="cust_grade_cd" id="cust_grade_cd" onchange="javascript:setCustGradeDesc(this.value);">
										<c:forEach items="${codeMap['CUST_GRADE']}" var="item">
											<option value="${item.code_value}" <c:if test="${item.code_value eq bean.cust_grade_cd}">selected="selected"</c:if> >${item.code_name}</option>
										</c:forEach>
									</select>
								</div>
							</div>
						</td>
					</tr>
					<tr>
						<th class="text-right">담당지역</th>
						<td>
							<div class="form-row inline-pd">
								<div class="col width140px">
									<input type="text" class="form-control" id="area_si" name="area_si" alt="담당지역" readonly="readonly" value="${bean.area_si}">
								</div>
							</div>
						</td>
						<th class="text-right">담당센터</th>
						<td>
							<div class="form-row inline-pd">
								<div class="col-3">
									<input type="text" class="form-control" id="center_org_name" name="center_org_name" alt="담당센터" readonly="readonly" value="${bean.center_org_name}">
								</div>
							</div>
						</td>
						<th class="text-right">보유모델</th>
						<td>
							<div class="form-row inline-pd">
								<div class="col-5">
									<div class="input-group">
										<input type="text" class="form-control   width120px" readonly="readonly" value="${bean.own_machine_name}" readonly="readonly">
									</div>
								</div>
								<div class="algin-item-center">
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="consult_type_cd_01" name="consult_type_cd_val" value="01" disabled="disabled">
										<label for="consult_type_cd_01" class="form-check-label">신차</label>
									</div>
									<div class="form-check form-check-inline mr3">
										<input class="form-check-input" type="radio" id="consult_type_cd_02" name="consult_type_cd_val" value="02" disabled="disabled">
										<label for="consult_type_cd_02" class="form-check-label">대차</label>
										<c:if test="${bean.parent_machine_name ne ''}">
											<sapn id="parent_consult_machine_name"> (${bean.parent_machine_name})</sapn>
										</c:if>
									</div>
									<div class="form-check form-check-inline mr3">
										<input class="form-check-input" type="radio" id="consult_type_cd_03" name="consult_type_cd_val" value="03" disabled="disabled">
										<label for="consult_type_cd_03" class="form-check-label">렌탈</label>
									</div>
								</div>								
							</div>
						</td>
					</tr>
					<tr>
						<th class="text-right">주소</th>
						<td colspan="3">
							<div class="form-row inline-pd">
								<div class="col-2">
									<input type="text" class="form-control " readonly="readonly" value="${bean.post_no}">
								</div>
								<div class="col-5">
									<input type="text" class="form-control" readonly="readonly" value="${bean.addr1}">
								</div>
								<div class="col-5">
									<input type="text" class="form-control" readonly="readonly" value="${bean.addr2}">
								</div>
							</div>
						</td>
						<th class="text-right essential-item">상담모델</th>
						<td>
							<div class="form-row inline-pd">
								<div class="col-10">
									<div class="input-group">
										<input type="text" class="form-control border-right-0 width140px essential-bg" id="machine_name" name="machine_name" ${bean.machine_plant_seq != '' ? 'readonly="readonly"' : '' } value="${bean.machine_name}" alt="모델명" readonly="readonly" required="required">
										<button type="button" class="btn btn-icon btn-primary-gra" ${bean.machine_plant_seq != '' ? 'disabled="disabled"' : '' } onclick="javascript:goModelInfoClick();"><i class="material-iconssearch"></i></button>
										<input type="hidden" id="machine_plant_seq" name="machine_plant_seq">
										<div class="right ml5">
											<button type="button" class="btn btn-primary-gra" style="width: 60px;" onclick="javascript:fnAddRows();">상담추가</button>
											<button type="button" class="btn btn-primary-gra" style="width: 60px;" onclick="javascript:fnEndConsult();">상담종료</button>
										</div>
									</div>
								</div>
							</div>
						</td>
					</tr>
					</tbody>
					<tbody>
							<c:forEach var="consultDtlList" items="${list}" varStatus="status">
								<tr id="tr_consult_${status.count }">
									<c:if test="${consultDtlList.reg_mem_no eq SecureUser.mem_no}">
										<th class="text-right essential-item ">상담내용 ${status.count }</th>
										<td colspan="5">
											<div class=" inline-pd ">
												<div class="input-group">
													<input type="hidden" id="consult_seq_${status.count }" name="consult_seq_${status.count }" value="${bean.cust_consult_seq}">
													<input type="hidden" id="seq_no_${status.count }" name="seq_no_${status.count }" value="${consultDtlList.seq_no}">
													<input type="hidden" id="use_yn_${status.count }" name="use_yn_${status.count }" value="${consultDtlList.use_yn}">
													<input type="hidden" id="reg_mem_no_${status.count }" name="reg_mem_no_${status.count }" value="${consultDtlList.reg_mem_no}">
													<div class="pl5 pr5">
														<div class="input-group">상담일자</div>
													</div>
													<div class="">
														<div class="input-group">
															<input type="text" class="form-control border-right-0 essential-bg calDate" id="consult_dt_${status.count }" name="consult_dt_${status.count }" dateformat="yyyy-MM-dd" required="required" alt="상담일자" value="${consultDtlList.consult_dt}">
														</div>
													</div>
													<div class="pl10 pr5">
														<div class="input-group">상담자</div>
													</div>
													<div class="">
														<div class="">
															<input type="text" class="form-control" id="consult_reg_name_${status.count }" name="consult_reg_name_${status.count }" value="${consultDtlList.reg_mem_name}" readonly="readonly">
														</div>
													</div>
<!-- 													<div class="pl10 pr5"> -->
<!-- 														<div class="input-group">상담시간</div> -->
<!-- 													</div> -->
<!-- 													<div class=""> -->
<!-- 														<div class="input-group"> -->
<%-- 															<input type="text" class="form-control  essential-bg width60px" style="border-radius: 4px;" id="consult_st_ti_${status.count }" name="consult_st_ti_${status.count }" value="${consultDtlList.consult_st_ti}" onkeyup="javascript:fnCalcCunsultTi(this);" placeholder="HH:MM" minlength="4" maxlength="5" required="required" alt="상담시작시간"> --%>
<!-- 															<div class="form-row inline-pd"> -->
<!-- 																<div class="input-group">&nbsp;&nbsp;~&nbsp;&nbsp;</div> -->
<!-- 															</div> -->
<%-- 															<input type="text" class="form-control   essential-bg width60px" style="border-radius: 4px;" id="consult_ed_ti_${status.count }" name="consult_ed_ti_${status.count }" value="${consultDtlList.consult_ed_ti}" onkeyup="javascript:fnCalcCunsultTi(this);" placeholder="HH:MM" minlength="4" maxlength="5" required="required" alt="상담종료시간">&nbsp;&nbsp; --%>
<!-- 														</div> -->
<!-- 													</div> -->
<!-- 													<div class="pl5"> -->
<!-- 														<div class="input-group"> -->
<%-- 															<input type="text" class="form-control text-right width50px" style="border-radius: 4px;" readonly="readonly" id="consult_min_${status.count }" name="consult_min_${status.count }" value="${consultDtlList.consult_min}"> --%>
<!-- 														</div> -->
<!-- 													</div> -->
<!-- 													<div class="pr5"> -->
<!-- 														<div class="input-group"> -->
<!-- 															<div class="input-group">&nbsp;&nbsp;분</div> -->
<!-- 														</div> -->
<!-- 													</div> -->
													<div class="pl10 pr5">
														<div class="input-group">상담방법</div>
													</div>
													<div class="algin-item-center">
														<div class="form-check form-check-inline">
															<input class="form-check-input" type="radio" id="consult_case_cd_${status.count }_1" name="consult_case_cd_${status.count }" value="0"  ${consultDtlList.consult_case_cd == '0'? 'checked="checked"' : ''}>
															<label for="consult_case_cd_${status.count }_1" class="form-check-label">전화</label>
														</div>
														<div class="form-check form-check-inline mr3">
															<input class="form-check-input" type="radio" id="consult_case_cd_${status.count }_2" name="consult_case_cd_${status.count }" value="1"  ${consultDtlList.consult_case_cd == '1'? 'checked="checked"' : ''}>
															<label for="consult_case_cd_${status.count }_2" class="form-check-label">약속</label>
														</div>
														<div class="form-check form-check-inline mr3">
															<input class="form-check-input" type="radio" id="consult_case_cd_${status.count }_3" name="consult_case_cd_${status.count }" value="2"  ${consultDtlList.consult_case_cd == '2'? 'checked="checked"' : ''}>
															<label for="consult_case_cd_${status.count }_3" class="form-check-label">임의방문</label>
														</div>
													</div>
													<div class="pl10">
														<div class="form-check form-check-inline">
															<input class="form-check-input" type="checkbox" id="complete_yn_${status.count }" name="complete_yn_${status.count }" onclick="javascript:fnChangeComplete(this)" ${consultDtlList.complete_yn == 'Y'? 'value="N"' : 'value="Y"'} ${consultDtlList.complete_yn == 'N'? 'checked="checked"' : ''}>
															<label class="form-check-label">미결사항</label>
														</div>
													</div>
													<c:if test="${status.count eq 1}">
<%--														<div class="right">--%>
<%--															<button type="button" class="btn btn-primary-gra" style="width: 60px;" onclick="javascript:fnAddRows();">상담추가</button>--%>
<%--														</div>--%>
													</c:if>
													<c:if test="${consultDtlList.consult_dt eq inputParam.s_current_dt || consultDtlList.reg_dt eq inputParam.s_current_dt}">
														<div class="right">
															<button type="button" class="btn btn-primary-gra" style="width: 60px;" onclick="fnUpdateUseYnRow(this);">상담삭제</button>
														</div>
													</c:if>
												</div>
											</div>
											<div class="mt5">
											<!-- 2021.10.12 (SR:9707) 당일에 한하여 작성자가 상담건을 수정 및 삭제 가능-->
												<c:choose>
													<c:when test="${consultDtlList.consult_dt eq inputParam.s_current_dt || consultDtlList.reg_dt eq inputParam.s_current_dt}">
														<textarea class="essential-bg" style="height: 100px;" id="consult_text_${status.count }" name="consult_text_${status.count }" required="required" alt="상담내용">${consultDtlList.consult_text}</textarea>
													</c:when>
													<c:otherwise>
														<textarea class="essential-bg" style="height: 100px;" id="consult_text_${status.count }" name="consult_text_${status.count }" readonly="readonly" alt="상담내용">${consultDtlList.consult_text}</textarea>
													</c:otherwise>
												</c:choose>
											</div>
										</td>
									</c:if>
									<c:if test="${consultDtlList.reg_mem_no ne SecureUser.mem_no}">
										<th class="text-right essential-item ">상담내용 ${status.count }</th>
										<td colspan="5">
											<div class=" inline-pd ">
												<div class="input-group">
													<input type="hidden" id="consult_seq_${status.count }" name="consult_seq_${status.count }" value="${consultDtlList.cust_consult_seq}">
													<input type="hidden" id="seq_no_${status.count }" name="seq_no_${status.count }" value="${consultDtlList.seq_no}">
													<input type="hidden" id="use_yn_${status.count }" name="use_yn_${status.count }" value="${consultDtlList.use_yn}">
													<input type="hidden" id="reg_mem_no_${status.count }" name="reg_mem_no_${status.count }" value="${consultDtlList.reg_mem_no}">
													<div class="pl5 pr5">
														<div class="input-group">상담일자</div>
													</div>
													<div class="">
														<div class="input-group">
															<input type="text" class="form-control border-right-0 essential-bg calDate" id="consult_dt_${status.count }" name="consult_dt_${status.count }" dateformat="yyyy-MM-dd" alt="상담일" value="${consultDtlList.consult_dt}" disabled="disabled">
<%-- 															<input type="text" class="form-control border-right-0 essential-bg calDate" id="consult_dt_${status.count }" name="consult_dt_${status.count }" dateformat="yyyy-MM-dd" alt="상담일" value="${consultDtlList.consult_dt}" > --%>
														</div>
													</div>
													<div class="pl10 pr5">
														<div class="input-group">상담자</div>
													</div>
													<div class="">
														<div class="">
															<input type="text" class="form-control" id="consult_reg_name_${status.count }" name="consult_reg_name_${status.count }" value="${consultDtlList.reg_mem_name}" readonly="readonly">
														</div>
													</div>
													<div class="pl10 pr5">
														<div class="input-group">상담시간</div>
													</div>
													<div class="">
														<div class="input-group">
															<input type="text" class="form-control  essential-bg width60px" style="border-radius: 4px;" placeholder="HH:MM" maxlength="5" id="consult_st_ti_${status.count }" name="consult_st_ti_${status.count }" value="${consultDtlList.consult_st_ti}" onkeyup="javascript:fnCalcCunsultTi(this);" readonly="readonly">
<%-- 															<input type="text" class="form-control  essential-bg width60px" style="border-radius: 4px;" placeholder="HH:MM" maxlength="5" id="consult_st_ti_${status.count }" name="consult_st_ti_${status.count }" value="${consultDtlList.consult_st_ti}" onkeyup="javascript:fnCalcCunsultTi(this);" > --%>
															<div class="form-row inline-pd">
																<div class="input-group">&nbsp;&nbsp;~&nbsp;&nbsp;</div>
															</div>
															<input type="text" class="form-control  essential-bg width60px" style="border-radius: 4px;" placeholder="HH:MM" maxlength="5" id="consult_ed_ti_${status.count }" name="consult_ed_ti_${status.count }" value="${consultDtlList.consult_ed_ti}" onkeyup="javascript:fnCalcCunsultTi(this);" readonly="readonly">&nbsp;&nbsp;
<%-- 															<input type="text" class="form-control  essential-bg width60px" style="border-radius: 4px;" placeholder="HH:MM" maxlength="5" id="consult_ed_ti_${status.count }" name="consult_ed_ti_${status.count }" value="${consultDtlList.consult_ed_ti}" onkeyup="javascript:fnCalcCunsultTi(this);" >&nbsp;&nbsp; --%>
														</div>
													</div>
													<div class="pl5">
														<div class="input-group">
															<input type="text" class="form-control width50px text-right" style="border-radius: 4px;" placeholder="HH:MM" maxlength="5" id="consult_min_${status.count }" name="consult_min_${status.count }" value="${consultDtlList.consult_min}" readonly="readonly">
														</div>
													</div>
													<div class="pr5">
														<div class="input-group">
															<div class="input-group">&nbsp;&nbsp;분</div>
														</div>
													</div>
													<div class="pl10 pr5">
														<div class="input-group">상담방법</div>
													</div>
													<div class="algin-item-center">
														<div class="form-check form-check-inline">
															<input class="form-check-input" type="radio" id="consult_case_cd_${status.count }_1" name="consult_case_cd_${status.count }" value="0"  ${consultDtlList.consult_case_cd == '0'? 'checked="checked"' : ''} disabled="disabled">
															<label for="consult_case_cd_${status.count }_1" class="form-check-label">전화</label>
														</div>
														<div class="form-check form-check-inline mr3">
															<input class="form-check-input" type="radio" id="consult_case_cd_${status.count }_2" name="consult_case_cd_${status.count }" value="1"  ${consultDtlList.consult_case_cd == '1'? 'checked="checked"' : ''} disabled="disabled">
															<label for="consult_case_cd_${status.count }_2" class="form-check-label">약속</label>
														</div>
														<div class="form-check form-check-inline mr3">
															<input class="form-check-input" type="radio" id="consult_case_cd_${status.count }_3" name="consult_case_cd_${status.count }" value="2"  ${consultDtlList.consult_case_cd == '2'? 'checked="checked"' : ''} disabled="disabled">
															<label for="consult_case_cd_${status.count }_3" class="form-check-label">임의방문</label>
														</div>
													</div>
													<div class="pl10">
														<div class="form-check form-check-inline">
															<input class="form-check-input" type="checkbox" id="complete_yn_${status.count }" name="complete_yn${status.count }" onclick="javascript:fnChangeComplete(this)" ${consultDtlList.complete_yn == 'Y'? 'value="N"' : 'value="Y"'} ${consultDtlList.complete_yn == 'N'? 'checked="checked"' : ''} disabled="disabled">
															<label class="form-check-label">미결사항</label>
														</div>
													</div>
													<c:if test="${status.count eq 1}">
<%--														<div class="right">--%>
<%--															<button type="button" class="btn btn-primary-gra" style="width: 60px;" onclick="javascript:fnAddRows();">상담추가</button>--%>
<%--														</div>--%>
													</c:if>
												</div>
											</div>
											<div class="mt5">
												<textarea class="essential-bg" style="height: 100px;" id="consult_text_${status.count }" name="consult_text_${status.count }" readonly="readonly">${consultDtlList.consult_text}</textarea>
<%-- 												<textarea class="essential-bg" style="height: 100px;" id="consult_text_${status.count }" name="consult_text_${status.count }" >${consultDtlList.consult_text}</textarea> --%>
											</div>
										</td>
									</c:if>
								</tr>
							</c:forEach>
<%--						</c:otherwise>--%>
<%--					</c:choose>--%>
					</tbody>
				</table>
			</div>
			<div class="btn-group mt10">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
			<!-- /폼테이블 -->
		</div>
	</div>
	<!-- /팝업 -->
</form>
</body>
</html>