<%@ page contentType="text/html;charset=utf-8" language="java"%><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>

<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>

	<script type="text/javascript">
	
		var custGradeList = JSON.parse('${codeMapJsonObj['CUST_GRADE']}');		
		var i = 1;
		
		var dateidx = 0;
		var now = "${inputParam.s_current_dt}";
		
		$(document).ready(function() {
			
			
			
			setCustGradeDesc("N");
			
			// 핸드폰번호 중복체크 완료 후 번호 변경 시 중복체크 다시 실행
			$("#hp_no").on("propertychange change keyup paste input", function() {
				console.log($M.getValue("lastChk_hp_no") + " / " + $M.getValue("hp_no"));
				if ($M.getValue("lastChk_hp_no") == this.value) {
					$M.setValue("hp_no_chk", "Y");					
					$("#btn_hp_no_chk").prop("disabled", true);
				} else {
					$M.setValue("hp_no_chk", "N");
					$("#btn_hp_no_chk").prop("disabled", false);
				};
			});

		});
			
		
		function goHpNoCheck() {
			
			if($M.getValue("hp_no") == '' || $M.getValue("hp_no") == undefined) {
				alert("핸드폰 번호를 입력해주세요"); 
				return;	
			}
			
			if ($M.getValue("hp_no_chk") != "Y" ) {	
				//핸드폰번호 중복체크
				$M.goNextPageAjax(this_page + "/custHpNoCheck/" + $M.getValue("hp_no"), '', {method : 'get'},
					function(result) {
			    		if(result.success) {
			    			$M.setValue("hp_no_chk","Y");
			    			$M.setValue("lastchk_hp_no",$M.getValue("hp_no"));
			    			$("#btn_hp_no_chk").prop("disabled", true);
						}else{
							$M.setValue("hp_no_chk","N");
							$("#btn_hp_no_chk").prop("disabled", false);
			    		}
					}
				);			
			}		
			else{
				alert("사용가능한 핸드폰 번호 입니다");
			}
		}
		
		function fnAddRows() {
			
			i++;	
			dateidx++;
			
			$('#consult_body').append(	'<tr id="tr_consult_'+i+'" >'+
								'<th class="text-right essential-item ">'+
								'상담내용 '+i+'</th>'+
								'<td colspan="5">'+
								'<div class=" inline-pd ">'+
								'<div class="input-group ">'+
								'<div class="pl5 pr5">'+
								'<div class="input-group">'+
								'상담일자</div>'+
								'</div>'+
								'<div class="">'+
								'<div class="input-group">'+
								'<input type="text" class="form-control essential-bg  border-right-0 calDate" style="max-width: 79px;" id="consult_dt_'+i+'" name="consult_dt_'+i+'" dateformat="yyyy-MM-dd" alt="상담일자" value="" required="required"  >'+
								'</div>'+
								'</div>'+
								'<div class="pl10 pr5">'+
								'<div class="input-group">'+
								'상담자</div>'+
								'</div>'+
								'<div class="">'+
								'<div class="">'+
								'<input type="text" class="form-control  width120px"  value="${SecureUser.kor_name}" name="reg_name_'+i+'" readonly="readonly" >'+
								'</div>'+
								'</div>'+
								'<div class="pl10 pr5">'+
								'<div class="input-group">'+
								'상담시간</div>'+
								'</div>'+
								'<div class="">'+
								'<div class="input-group">'+
								'<input type="text" class="form-control essential-bg  width60px" style="border-radius: 4px;" name="consult_st_ti_'+i+'" id="consult_st_ti_'+i+'"  placeholder="HH:MM" required="required" onkeyup="javascript:fnCalcCunsultTi(this);" minlength="4"  maxlength="5" alt="상담시작시간" >'+
								'<div class="form-row inline-pd">'+
								'<div class="input-group">'+
								'&nbsp;&nbsp;~&nbsp;&nbsp;</div>'+
								'</div>'+
								'<input type="text" class="form-control essential-bg  width60px" style="border-radius: 4px;" name="consult_ed_ti_'+i+'" id="consult_ed_ti_'+i+'"  placeholder="HH:MM" required="required" onkeyup="javascript:fnCalcCunsultTi(this);" minlength="4"  maxlength="5" alt="상담종료시간"  >'+
								'&nbsp;&nbsp;</div>'+
								'</div>'+
								'<div class="pl5">'+
								'<div class="input-group">'+
								'<input type="text" class="form-control  text-right  width50px" id="consult_min_'+i+'"   name="consult_min_'+i+'"  style="border-radius: 4px;" readonly="readonly">'+
								'</div>'+
								'</div>'+
								'<div class="pr5">'+
								'<div class="input-group">'+
								'<div class="input-group">'+
								'&nbsp;&nbsp;분</div>'+
								'</div>'+
								'</div>'+
								'<div class="pl10 pr5">'+
								'<div class="input-group">'+
								'상담방법</div>'+
								'</div>'+
								'<div class="dpf algin-item-center">'+
								'<div class="form-check form-check-inline">'+
								'<input class="form-check-input" type="radio" id="consult_case_cd_'+i+'_1"  name="consult_case_cd_'+i+'" value="0" checked="checked" >'+
								'<label  for="consult_case_cd_'+i+'_1"  class="form-check-label">'+
								'전화</label>'+
								'</div>'+
								'<div class="form-check form-check-inline mr3">'+
								'<input class="form-check-input" type="radio" id="consult_case_cd_'+i+'_2"  name="consult_case_cd_'+i+'" value="1" >'+
								'<label  for="consult_case_cd_'+i+'_2" class="form-check-label">'+
								'약속</label>'+
								'</div>'+
								'<div class="form-check form-check-inline mr3">'+
								'<input class="form-check-input" type="radio" id="consult_case_cd_'+i+'_3"   name="consult_case_cd_'+i+'" value="2">'+
								'<label  for="consult_case_cd_'+i+'_3"  class="form-check-label">'+
								'임의방문</label>'+
								'</div>'+
								'</div>'+
								'<div class="pl10">'+
								'<div class="form-check form-check-inline">'+
								'<input class="form-check-input" type="checkbox" id="complete_yn_'+i+'" name="complete_yn_'+i+'"  onclick="javascript:fnChangeComplete(this)" value="N" >'+
								'<label class="form-check-label">'+
								'미결사항</label>'+
								'</div>'+
								'</div>'+
								'<div class="right">'+
								'<button type="button" class="btn btn-primary-gra" style="width: 60px;" onclick="fnRemoveRow(this);">'+
								'상담삭제</button>'+
								'</div>'+
								'</div>'+
								'</div>'+
								'<div class="mt5">'+
								'<textarea class="essential-bg" style="height: 100px;" id="consult_text_'+i+'" name="consult_text_'+i+'" required="required" alt="상담내용" >'+
								'</textarea>'+
								'</div>'+
								'</td>'+
								'</tr>'
							);	

			$("#consult_dt_" + i ).val($M.formatDate($M.addDates($M.toDate(now), dateidx)));					
			$(".calDate").datepicker();
			

	        $('html, body').animate({scrollTop : $("#consult_text_" + i ).offset().top}, 500);
		}

		// 간편 등록 제거 - 22.09.16
		// function fnAddCustSimple() {
		// 	param = {};
		// 	openCustSimplePanel('fnsetCustSimpleInfo', $M.toGetParam(param));
		// }

		// 간편 등록 제거 -> 사용자 등록으로 대체 22.09.16
		function fnAddCust() {
			param = {
				s_popup_yn : 'Y',
			};
			$M.goNextPage('/cust/cust010201', $M.toGetParam(param), {popupStatus : getPopupProp(720, 330)});
		}
		
		function fnsetCustSimpleInfo(data) {

			$M.setValue("hp_no", data.hp_no);
			$M.setValue("cust_no", data.cust_no);
			$M.setValue("cust_name", data.cust_name);
			$M.setValue("post_no", data.post_no);
			$M.setValue("addr1", data.addr1);
			$M.setValue("addr2", data.addr2);
			$M.setValue("eng_addr", data.eng_addr);
			$M.setValue("sale_area_code", data.sale_area_code);
			$M.setValue("sale_mem_name", data.sale_mem_name);
			$M.setValue("service_mem_name", data.service_mem_name);
			$M.setValue("service_mem_no", data.service_mem_no);
			$M.setValue("sale_mem_no", data.sale_mem_no);
			$M.setValue("area_si",data.area_si);
			$M.setValue("center_org_code", data.center_org_code);
			$M.setValue("center_org_name", data.center_org_name);
			$M.setValue("lastchk_hp_no",data.hp_no);

			$M.setValue("hp_no_chk", "Y");

			$("#hp_no").prop("disabled", false);			
			$("#hp_no").blur();
			$("#btn_hp_no_chk").prop("disabled", true);	
		}
		
		 function chkTime24H(time) {

	        // replace 함수를 사용하여 콜론( : )을 공백으로 치환한다.
	        var replaceTime = time.value.replace(/\:/g, "");

	        // 텍스트박스의 입력값이 4이상부터 실행한다.
	        if(replaceTime.length >= 4) {

	        	if(replaceTime.length >= 5) {
	        		alert("시간은 4자리로 입력해 주세요 ");
	        	 	time.value = "00:00";
	                return false;
	        	}
	        	else {
		            var hours = replaceTime.substring(0, 2);      // 선언한 변수 hours에 시간값을 담는다.
		            var minute = replaceTime.substring(2, 4);    // 선언한 변수 minute에 분을 담는다.
	
		            // isFinite함수를 사용하여 문자가 선언되었는지 확인한다.
		            if(isFinite(hours + minute) == false) {
		                alert("문자는 입력하실 수 없습니다.");
		                time.value = "00:00";
		                return false;
		            }
	
		            // 두 변수의 시간과 분을 합쳐 입력한 시간이 24시가 넘는지를 체크한다.
		            if(hours + minute > 2400) {
		                alert("시간은 24시를 넘길 수 없습니다.");
		                time.value = "24:00";
		                return false;
		            }
	
		            // 입력한 분의 값이 60분을 넘는지 체크한다.
		            if(minute > 60) {
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

			var starttime = $("input[id='consult_st_ti_"+ last + "']").val();
			var endtime = $("input[id='consult_ed_ti_"+ last + "']").val();

			if (starttime != 0) {
				var hour = parseInt(endtime.substring(0, 2), 10)
						- parseInt(starttime.substring(0, 2), 10);
				var minute = parseInt(endtime.substring(3, 5), 10)
						- parseInt(starttime.substring(3, 5), 10);
				var consulttime = (hour * 60) + minute;
				$("input[id='consult_min_"+ last + "']").val(consulttime);
			}
			
			if( !$.isNumeric( $("input[id='consult_min_"+ last + "']").val()) ){
				$("input[id='consult_min_"+ last + "']").val("");
			}
		}
		
		
		function fnChangeComplete(obj){
			console.log(obj);
			
			// 체크여부 확인
			if($(obj).is(":checked") == true) {
				$(obj).val("Y");
			}
			else{
				$(obj).val("N");
			}
		}
		
		function fnRemoveRow(button) {
			if (confirm("작성한 내용을 삭제 하시겠습니까?") == false) {
				return;
			}
			
			button.closest("tr").remove();
			dateidx--;
		}

		function goSave() {
			if (confirm("저장 하시겠습니까?") == false) {
				return false;
			}

			console.log("?? -> ", $M.getValue("consult_type_cd"));
			
			var frm = document.main_form;
			//validationcheck
			if ($M.validation(frm,
					{field: ["cust_name", "hp_no", "machine_name"]}) == false) {
				return;
			}
			
			//상담내용은 배열로 만들어서 넘기기
			var consultDtArr = [];
			var consultCaseCdArr = [];
			var consultStTiArr = [];
			var consultEdTiArr = [];
			var consultMinArr = [];
			var consultTextArr = [];
			var completeYnArr = [];
			var cmdArr = [];

			// 기존 hidden 값 제거
			$('input:hidden[id^=consult_], #complete_yn, #cmd').remove();

			var consultTimeTrueFalse = true;
			//테이블에서 한개씩 선택해서 배열에 넣기
			$('tr[id^="tr_consult"]').each(function () {
				var tr = $(this);
				var td = tr.children();

				if(td.find('[id^="consult_st_ti"]').val() != "" || td.find('[id^="consult_ed_ti"]').val() != "") {
					$M.setHiddenValue(frm, "consult_dt", td.find('[id^="consult_dt"]').val().replace(/-/gi, ""));
					$M.setHiddenValue(frm, "consult_case_cd", td.find('input[name^="consult_case_cd"]:checked').val());
					$M.setHiddenValue(frm, "consult_st_ti", td.find('[id^="consult_st_ti"]').val());
					$M.setHiddenValue(frm, "consult_ed_ti", td.find('[id^="consult_ed_ti"]').val());
					$M.setHiddenValue(frm, "consult_min", td.find('[id^="consult_min"]').val());
					$M.setHiddenValue(frm, "consult_text", td.find('[id^="consult_text"]').val());
					$M.setHiddenValue(frm, "complete_yn", td.find('[id^="complete_yn"]').val());
					$M.setHiddenValue(frm, "cmd", "C");
				} else {
					consultTimeTrueFalse = false;
				}

			});

			if(consultTimeTrueFalse == false) {
				alert("상담시간은 필수입니다.");
				return;
			}

			var bDupleConsultDt = false;
			var chkConsultDt = "";

			//동일한 날에 1개이상 상담 등록 불가
			for (i = 0; i < consultDtArr.length; i++) {
				if (chkConsultDt == "") {
					chkConsultDt = consultDtArr[i];
				} else {
					if (chkConsultDt == consultDtArr[i]) {
						bDupleConsultDt = true;
					}
				}
			}

			if (bDupleConsultDt) {
				alert("동일한 날짜로 상담내역을 2번이상 등록할 수 없습니다.");
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

// 			frm = $M.toValueForm(document.main_form);
// 			var option = {
// 				isEmpty : true
// 			};
				
			$M.setValue("consult_type_cd", $M.getValue("consult_type_cd_val"));
			console.log("frm : ", frm);
			
// /* /* /* /* 			$M.setValue(frm, "consult_dt", consultDtArr);
// 			$M.setValue(frm, "consult_case_cd", consultCaseCdArr);
// 			$M.setValue(frm, "consult_st_ti", consultStTiArr);
// 			$M.setValue(frm, "consult_ed_ti", consultEdTiArr);
// 			$M.setValue(frm, "consult_min", consultMinArr);
// 			$M.setValue(frm, "consult_text", consultTextArr);
// 			$M.setValue(frm, "complete_yn", completeYnArr);
// 			$M.setValue(frm, "cmd", cmdArr); */ */ */ */
			
// 			consultDtArr.push(td.find('[id^="consult_dt"]').val().replace(/-/gi, ""));
// 			consultCaseCdArr.push(td.find('input[name^="consult_case_cd"]:checked').val());
// 			consultStTiArr.push(td.find('[id^="consult_st_ti"]').val());
// 			consultEdTiArr.push(td.find('[id^="consult_ed_ti"]').val());
// 			consultMinArr.push(td.find('[id^="consult_min"]').val());
// 			consultTextArr.push(td.find('[id^="consult_text"]').val());
// 			completeYnArr.push(td.find('[id^="complete_yn"]').val());
// 			cmdArr.push("C");


// 			$M.setValue(frm, "consult_dt_str", $M.getArrStr(consultDtArr, option));
// 			$M.setValue(frm, "consult_case_cd_str", $M.getArrStr(consultCaseCdArr, option));
// 			$M.setValue(frm, "consult_st_ti_str", $M.getArrStr(consultStTiArr, option));
// 			$M.setValue(frm, "consult_ed_ti_str", $M.getArrStr(consultEdTiArr, option));
// 			$M.setValue(frm, "consult_min_str", $M.getArrStr(consultMinArr, option));
// 			$M.setValue(frm, "consult_text_str", $M.getArrStr(consultTextArr, option));
// 			$M.setValue(frm, "complete_yn_str", $M.getArrStr(completeYnArr, option));
// 			$M.setValue(frm, "cmd_str", $M.getArrStr(cmdArr, option));

			$M.goNextPageAjax(this_page + "/save", frm, {method: 'POST'},
				function (result) {
					if (result.success) {
						if (result.dupl_yn == "Y") {
							if (confirm(result.result_msg)) {
								var params = {
									"cust_consult_seq": result.cust_consult_seq,
									"cust_no": result.cust_no,
									"own_machine_seq": result.own_machine_seq
								};
			
								var poppupOption = "";
								if ($M.getValue("consult_type_cd") == '03') {
									$M.goNextPage('/cust/cust0101p04', $M.toGetParam(params), {popupStatus: poppupOption});
								} else {
									$M.goNextPage('/cust/cust0101p01', $M.toGetParam(params), {popupStatus: poppupOption});
								}
								window.close();
							}
						} else {
							alert("처리가 완료되었습니다.");
							fnSetCustConsultMachine(result);
						}
					}
				}
			);
		}

		function setCustGradeDesc(value) {
			for (var i = 0; i < custGradeList.length; i++) {
				if (value == custGradeList[i].code_value) {
					$M.setValue("cust_grade_desc", custGradeList[i].code_desc);
				}
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
	    	 $M.setValue("machine_name",row.machine_name);
	    	 $M.setValue("machine_plant_seq",row.machine_plant_seq);
	     }
		
		function fnClose() {
			window.close();
		}

		function fnSetCustInfo(data) {
			$M.setValue("cust_name", data.real_cust_name);
			$M.setValue("cust_no", data.cust_no);
			$M.setValue("hp_no", data.real_hp_no);
			$M.setValue("sale_mem_no", data.sale_mem_no);
			$M.setValue("sale_mem_name", data.sale_mem_name);
			$M.setValue("service_mem_no", data.service_mem_no);
			$M.setValue("service_mem_name", data.service_mem_name);
			$M.setValue("post_no", data.post_no);
			$M.setValue("addr1", data.addr1);
			$M.setValue("addr2", data.addr2);

			fnSearchConsultMachine(data);
		}

		function fnSearchConsultMachine(data) {
			var param = {
				"s_cust_no": data.cust_no
			};

			// $M.goNextPageAjax(this_page + "/search/custMachine", $M.toGetParam(param), {method: 'GET'},
			
			$M.goNextPageAjax(this_page + "/search/consultMachine", $M.toGetParam(param), {method: 'GET'},
					function (result) {
						if (result.success) {
							console.log(result.total_cnt);
							if(result.total_cnt > 0) {
								goCustConsultMachineList();
							}
						}
					}
			);
		}

		function goCustConsultMachineList() {
			var params = {
				"s_cust_no" : $M.getValue("cust_no"),
				"parent_js_name" : "fnSetCustConsultMachine"
			};

			var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=300, height=200, left=0, top=0";
			$M.goNextPage('/cust/cust0101p03', $M.toGetParam(params), {popupStatus: popupOption});
		}

		function fnSetCustConsultMachine(data) {
			
			var params = {
				"cust_consult_seq": data.cust_consult_seq,
				"cust_no": data.cust_no,
				"own_machine_seq": data.machine_seq
			};

			var poppupOption = "";
			$M.goNextPage('/cust/cust0101p01', $M.toGetParam(params), {popupStatus: poppupOption});
			fnClose();
		}

		function fnSetCustConsultRental(data) {
			
			var params = {
				"cust_consult_seq": data.cust_consult_seq,
				"cust_no": data.cust_no,
				"own_machine_seq": data.machine_seq
			};

			var poppupOption = "";
			$M.goNextPage('/cust/cust0101p04', $M.toGetParam(params), {popupStatus: poppupOption});
			fnClose();
		}
		
		function fnOpenSearchCustpanel() {
			var param = {
					s_consult_yn : "Y"
			};
			openSearchCustPanel('fnSetCustInfo', $M.toGetParam(param));
		}
		
		function fnSetReplaceConsult(data) {
			console.log("data : ", data);
			
			$("#parent_consult_machine_name").html(" ("+data.machine_name+")");
			$M.setValue("up_cust_consult_seq", data.cust_consult_seq);
			$M.setValue("consult_type_cd", "02");
			$("#consult_type_cd_02").prop('checked', true);
		}
		
		function fnSetNewConsult() {
			$("#parent_consult_machine_name").html("");
			$M.setValue("up_cust_consult_seq", "");
			$M.setValue("consult_type_cd", "01");
			$("#consult_type_cd_01").prop('checked', true);
		}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" id="hp_no_chk" name="hp_no_chk" value="N">
<input type="hidden" id="lastchk_hp_no" name="lastchk_hp_no" value="">
<input type="hidden" id="sale_area_code" name="sale_area_code" value="">
<input type="hidden" id="eng_addr" name="eng_addr" value="">
<input type="hidden" id="area_si" name="area_si" value="">
<input type="hidden" id="center_org_code" name="center_org_code" value="">
<input type="hidden" id="center_org_name" name="center_org_name" value="">
<input type="hidden" id="sale_mem_no" name="sale_mem_no" value="">
<input type="hidden" id="service_mem_no" name="service_mem_no" value="">
<input type="hidden" id="cust_no" name="cust_no" value="">
<input type="hidden" id="machine_plant_seq" name="machine_plant_seq" value="">
<input type="hidden" id="org_code" name="org_code" value="${SecureUser.org_code}">
<input type="hidden" id="mem_no" name="mem_no" value="${SecureUser.mem_no}">
<input type="hidden" id="up_cust_consult_seq" name="up_cust_consult_seq" value="">
<!-- <input type="hidden" id="consult_type_cd" name="consult_type_cd" value="01"> -->

	<div class="popup-wrap width-100per">
		<!-- 타이틀영역 -->
		<div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
		</div>
		<!-- /타이틀영역 -->
		<div class="content-wrap">
			<!-- 폼테이블 -->
			<div>
				<div class="title-wrap">
					<h4>안건상담등록</h4>
				</div>
				<table class="table-border" id="empTable">
					<colgroup>
						<col width="100px">
						<col width="">
						<col width="100px">
						<col width="200px">
						<col width="100px">
						<col width="">
					</colgroup>
					<tbody id="consult_body">
					<tr>
						<th class="text-right essential-item">고객명</th> <!-- 필수항목일때 클래스 essential-item 추가 -->
						<td>
							<div class="form-row inline-pd">
								<div class="col-auto">
									<div class="input-group">
										<input type="text" class="form-control border-right-0 width100px" id="cust_name" name="cust_name" required="required" alt="고객명" readonly="readonly">
<!-- 										<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchCustPanel('fnSetCustInfo')"><i class="material-iconssearch"></i></button> -->
 										<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnOpenSearchCustpanel()"><i class="material-iconssearch"></i></button>
									</div>
								</div>
								<div class="col-auto">
<%--									<button type="button" class="btn btn-primary-gra" style="width: 100%;" onclick="javascript:fnAddCustSimple();">간편고객등록</button>--%>
									<button type="button" class="btn btn-primary-gra" style="width: 100%;" onclick="javascript:fnAddCust();">고객등록</button>
								</div>
							</div>
						</td>
						<th class="text-right essential-item">휴대폰</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width140px">
									<input type="text" class="form-control essential-bg" id="hp_no" name="hp_no" format="phone" readonly="readonly" required="required" ale="휴대폰">
								</div>
							</div>
						</td>
						<th class="text-right essential-item">상담모델</th>
						<td>
							<div class="form-row inline-pd">
								<div class="col-5">
									<div class="input-group">
										<input type="text" class="form-control border-right-0 width140px essential-bg" id="machine_name" name="machine_name" alt="모델명" readonly="readonly">
										<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goModelInfoClick();"><i class="material-iconssearch"></i></button>
									</div>
								</div>
								<div class="algin-item-center">
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="consult_type_cd_01" name="consult_type_cd_val" value="01" checked="checked" disabled="disabled">
										<label for="consult_type_cd_01" class="form-check-label">신차</label>
									</div>
									<div class="form-check form-check-inline mr3">
										<input class="form-check-input" type="radio" id="consult_type_cd_02" name="consult_type_cd_val" value="02" disabled="disabled">
										<label for="consult_type_cd_02" class="form-check-label">대차</label>
										<sapn id="parent_consult_machine_name"></sapn>
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
						<th class="text-right">고객등급</th>
						<td>
							<div class="form-row ">
								<div class="col-10">
									<input type="text" class="form-control" id="cust_grade_desc" name="cust_grade_desc" readonly="readonly">
								</div>
								<div class="col-2">
									<select class="form-control" name="s_cust_grade_cd" id="s_cust_grade_cd" onchange="javascript:setCustGradeDesc(this.options[this.selectedIndex].value);" disabled="disabled">
										<c:forEach items="${codeMap['CUST_GRADE']}" var="item">
											<option value="${item.code_value}" ${ item.code_value eq 'N' ? 'selected="selected"' : '' } >${item.code_name} </option>
										</c:forEach>
									</select>
								</div>
							</div>
						</td>
						<th class="text-right  essential-item">마케팅담당자</th>
						<td>
							<div class="form-row inline-pd">
								<div class="col width140px">
									<input type="text" class="form-control essential-bg" id="sale_mem_name" name="sale_mem_name" alt="마케팅담당자" readonly="readonly" required="required">
								</div>
							</div>
						</td>
						<th class="text-right  essential-item">서비스담당자</th>
						<td>
							<div class="form-row inline-pd">
								<div class="col-3">
									<input type="text" class="form-control essential-bg" id="service_mem_name" name="service_mem_name" alt="서비스담당자" readonly="readonly" required="required">
								</div>
							</div>
						</td>
					</tr>
					<tr>
						<th class="text-right">주소</th>
						<td colspan="5">
							<div class="form-row inline-pd">
								<div class="col-auto">
									<input type="text" class="form-control width100px" id="post_no" name="post_no" readonly="readonly" alt="자택주소">
								</div>
								<div class="col-4">
									<input type="text" class="form-control" id="addr1" name="addr1" readonly="readonly" alt="자택주소">
								</div>
								<div class="col-4">
									<input type="text" class="form-control" id="addr2" name="addr2" readonly="readonly" alt="자택주소">
								</div>
							</div>
						</td>
					</tr>
					<tr id="tr_consult_1">
						<th class="text-right essential-item ">상담내용 1</th>
						<td colspan="5">
							<div class=" inline-pd ">
								<div class="input-group ">
									<div class="pl5 pr5">
										<div class="input-group">상담일자</div>
									</div>
									<div class="">
										<div class="input-group">
											<input type="text" class="form-control essential-bg  border-right-0 calDate" id="consult_dt_1" name="consult_dt_1" dateformat="yyyy-MM-dd" required="required" alt="상담일자" value="${inputParam.s_current_dt}">
										</div>
									</div>
									<div class="pl10 pr5">
										<div class="input-group">상담자</div>
									</div>
									<div class="">
										<div class="">
											<input type="text" class="form-control" value="${SecureUser.kor_name}" id="reg_name_1" name="reg_name_1" readonly="readonly">
										</div>
									</div>
									<div class="pl10 pr5">
										<div class="input-group">상담시간</div>
									</div>
									<div class="">
										<div class="input-group">
											<input type="text" class="form-control  essential-bg width60px" style="border-radius: 4px;" id="consult_st_ti_1" name="consult_st_ti_1" onkeyup="javascript:fnCalcCunsultTi(this);"
												   placeholder="HH:MM" minlength="4" maxlength="5" required="required" alt="상담시작시간">
											<div class="form-row inline-pd">
												<div class="input-group">&nbsp;&nbsp;~&nbsp;&nbsp;</div>
											</div>
											<input type="text" class="form-control  essential-bg  width60px" style="border-radius: 4px;" id="consult_ed_ti_1" name="consult_ed_ti_1" onkeyup="javascript:fnCalcCunsultTi(this);"
												   placeholder="HH:MM" minlength="4" maxlength="5" required="required" alt="상담종료시간">&nbsp;&nbsp;
										</div>
									</div>
									<div class="pl5">
										<div class="input-group">
											<input type="text" class="form-control  text-right width50px" id="consult_min_1" name="consult_min_1" style="border-radius: 4px;" readonly="readonly">
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
											<input class="form-check-input" type="radio" id="consult_case_cd_1_1" name="consult_case_cd_1" value="0" checked="checked">
											<label for="consult_case_cd_1_1" class="form-check-label">전화</label>
										</div>
										<div class="form-check form-check-inline mr3">
											<input class="form-check-input" type="radio" id="consult_case_cd_1_2" name="consult_case_cd_1" value="1">
											<label for="consult_case_cd_1_2" class="form-check-label">약속</label>
										</div>
										<div class="form-check form-check-inline mr3">
											<input class="form-check-input" type="radio" id="consult_case_cd_1_3" name="consult_case_cd_1" value="2">
											<label for="consult_case_cd_1_3" class="form-check-label">임의방문</label>
										</div>
									</div>
									<div class="pl10 algin-item-center">
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="checkbox" id="complete_yn_1" name="complete_yn_1" onclick="javascript:fnChangeComplete(this)" value="N">
											<label for="complete_yn_1" class="form-check-label">미결사항</label>
										</div>
									</div>
									<div class="right">
										<button type="button" class="btn btn-primary-gra" style="width: 60px;" onclick="javascript:fnAddRows();">상담추가</button>
									</div>
								</div>
							</div>
							<div class="mt5">
								<textarea class="essential-bg" style="height: 100px;" id="consult_text_1" name="consult_text_1" required="required" alt="상담내용"></textarea>
							</div>
						</td>
					</tr>
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
