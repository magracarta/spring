<%@ page contentType="text/html;charset=utf-8" language="java"%><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 영업대상고객 > 안건상담관리
-- 작성자 : myeongjikang
-- 최초 작성일 : 2019-12-05
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>

	<script type="text/javascript">

		var custGradeList = JSON.parse('${codeMapJsonObj['CUST_GRADE']}');
		var listCnt = 0;
		var now;
		var listNum = -1;
		var list;
		var itemSubMap = ${item_sub_map};

		$(document).ready(function() {
			now = $M.getCurrentDate("yyyyMMdd");
			$M.setValue("cust_no", $M.nvl("${inputParam.cust_no}", ""));
		});

		window.onload = function () {
			if ($M.getValue("cust_no") != "") {
				goPageInitSet();
			}
		}

		// 고객이 선택 되어 있는지 확인
		// - 선택이 안되있으면 true, 선택이 되어있으면 false
		function isCustNoNotSelected() {
			var custNo = $M.getValue("cust_no");
			if ($M.nvl(custNo, "") == "") {
				alert("고객을 선택해주세요.");
				return true;
			}

			return false;
		}

		function goPageInitSet() {
			$M.setValue("s_machine_plant_seq", $M.nvl("${inputParam.s_machine_plant_seq}", ""));
			<c:if test="${not empty inputParam.s_dt_yn}">
			$M.setValue("s_start_dt", "");
			</c:if>
			<%--$M.setValue("s_end_dt", $M.nvl("${inputParam.s_end_dt}", ""));--%>
			<%--$M.setValue("s_dt_yn", $M.nvl("${inputParam.s_dt_yn}", ""));--%>
			goSearchCustInfo();
			goSearch();
			if ($M.getValue("s_machine_plant_seq") === "blank" || $M.getValue("s_machine_plant_seq") == "0") {
				$M.setValue("s_machine_plant_seq", "");
			}
		}

		function goSearchCustInfo() {
			var custNo = $M.getValue("cust_no");
			$M.goNextPageAjax("/sale/custInfo/" + custNo, "", {method: 'GET'},
				function(result) {
					if(result.success) {
						fnDataSetCustInfo(result);
					}
				}
			);
		}

		function fnDataSetCustInfo(data) {
			$M.setValue("cust_name", data.cust_name);
			$M.setValue("cust_no", data.cust_no);
			$M.setValue("__s_cust_no", data.cust_no);
			$M.setValue("hp_no", data.hp_no);
			$M.setValue("sale_mem_name", data.sale_mem_name);
			$M.setValue("service_mem_name", data.service_mem_name);
			$M.setValue("post_no", data.post_no);
			$M.setValue("addr1", data.addr1);
			$M.setValue("addr2", data.addr2);
			$M.setValue("svc_loyal_name", data.svc_loyal_name == "" || data.svc_loyal_name == undefined? "" : "서비스충성도: " + data.svc_loyal_name);

			$('#cust_grade_cd').combogrid("setValues", data.cust_grade_cd_str == ""? "" : data.cust_grade_cd_str.split("^"));
			$M.setHiddenValue(document.main_form, "cust_grade_cd_str", $M.getValue("cust_grade_cd").replaceAll("#", "^"));

			setCustGradeDesc(data.cust_grade_cd_str);
		}

		function goSearch() {
			if(isCustNoNotSelected()) {
				return;
			}

			var params = {
				"s_cust_no": $M.getValue("cust_no"),
				"s_start_dt": $M.getValue("s_start_dt"),
				"s_end_dt": $M.getValue("s_end_dt"),
				"s_machine_plant_seq_str": $M.getValue("s_machine_plant_seq"),
				"s_maker_cd": $M.getValue("s_maker_cd"),
				"s_dt_yn" : $M.getValue("s_dt_yn"),
				"s_consult_type_cd" : $M.getValue("s_consult_type_cd"),
			};
			_fnAddSearchDt(params, 's_start_dt', 's_end_dt');
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(params), {method: 'GET'},
					function(result) {
						if (result.success) {
							if (result.list.length > 0) {
								$M.setValue("s_dt_yn", "Y");
							}
							// 조회기간 시작날짜를 조회된 상담일자 중 첫번째 일자로 변경 - 김경빈
							$M.setValue("s_start_dt", result.min_consult_dt);
							fnCounselListTemplate(result.list);
							$M.setValue("list", result.list);
						}
					}
			);
		}

		function fnCounselListTemplate(data) {
			listCnt = data.length;
			if (listCnt > 0) {
				list = data;
			}
			var innerHtml = '';
			for (var i=0; i<data.length; i++) {
				innerHtml += fnMakeCounselHtml(data[i], i);
			}

			document.getElementById("counselList").innerHTML = innerHtml;
			$(".calDate").datepicker();
		}

		function fnMakeCounselHtml(counsel, i) {
			var idx = listCnt - i - 1;
			var machineName 	= $M.nvl(counsel.machine_name, "");
			var machinePlantSeq = $M.nvl(counsel.machine_plant_seq, "");
			var stTi = counsel.consult_st_ti == ""? "" : counsel.consult_st_ti.substring(0, 2) + ":" + counsel.consult_st_ti.substring(2, 4);
			var edTi = counsel.consult_ed_ti == ""? "" : counsel.consult_ed_ti.substring(0, 2) + ":" + counsel.consult_ed_ti.substring(2, 4);
			var consultDt = $M.dateFormat(counsel.consult_dt, 'yyyy-MM-dd');
			var isUpdateAuth = counsel.cmd == "C"? true : ( counsel.consult_dt == $M.getCurrentDate("yyyyMMdd") || counsel.reg_dt == $M.getCurrentDate("yyyyMMdd") ) ? true : false;

			var innerHtml = '';
			innerHtml += '<tr id="tr_consult_' + idx + '">';
			innerHtml += '	<th class="text-right essential-item">상담내용 ' + (idx+1) + '</th>';
			innerHtml += '	<td colspan="5">';
			innerHtml += '		<div class="inline-pd">';
			innerHtml += '			<div class="input-group">';
			innerHtml += '				<input type="hidden"  id="cust_counsel_seq_' + idx + '"  	name="cust_counsel_seq_' + idx + '" 	value="' + counsel.cust_counsel_seq + '" >';
			innerHtml += '				<input type="hidden"  id="reg_dt_' + idx + '"  	name="reg_dt_' + idx + '" 	value="' + counsel.reg_dt + '" >';
			innerHtml += '				<input type="hidden"  id="use_yn_' + idx + '"  	name="use_yn_' + idx + '" 	value="' + counsel.use_yn + '" >';
			innerHtml += '				<input type="hidden"  id="end_yn_' + idx + '"  	name="end_yn_' + idx + '" 	value="' + counsel.end_yn + '" >';
			innerHtml += '				<div class="pl5 pr5">';
			innerHtml += '					<div class="input-group">상담일자</div>';
			innerHtml += '				</div>';
			innerHtml += '				<div class="">';
			innerHtml += '					<div class="input-group">';
			innerHtml += '						<input type="text" class="form-control border-right-0 calDate" id="consult_dt_' + idx + '" name="consult_dt_' + idx + '" dateformat="yyyy-MM-dd" required="required" alt="상담일자" value="' + consultDt + '" ' + ( isUpdateAuth == true ? "" : "disabled='disabled'" ) + '>';
			innerHtml += '					</div>';
			innerHtml += '				</div>';
			innerHtml += '				<div class="pl10 pr5">';
			innerHtml += '					<div class="input-group">상담자</div>';
			innerHtml += '				</div>';
			innerHtml += '				<div class="width80px">';
			innerHtml += '					<div class="">';
			innerHtml += '						<input type="text" class="form-control" style="border-radius: 4px;" value="' + counsel.counsel_mem_name + '" id="counsel_mem_name_' + idx + '" name="counsel_mem_name_' + idx + '" readonly="readonly">';
			innerHtml += '						<input type="hidden" value="' + counsel.counsel_mem_no + '" id="counsel_mem_no_' + idx + '" name="counsel_mem_no_' + idx + '">';
			innerHtml += '						<input type="hidden" value="' + counsel.counsel_org_code + '" id="counsel_org_code_' + idx + '" name="counsel_org_code_' + idx + '">';
			innerHtml += '					</div>';
			innerHtml += '				</div>';
			innerHtml += '				<div class="pl10 pr5">';
			innerHtml += '					<div class="input-group">상담모델</div>';
			innerHtml += '				</div>';
			innerHtml += '				<div class="">';
			innerHtml += '					<div class="input-group">';
			innerHtml += '						<input type="text" class="form-control border-right-0 width140px ' + (isUpdateAuth == true ? 'essential-bg"' : '"' ) + ' id="machine_name_' + idx + '" name="machine_name_' + idx + '" alt="상담모델명" readonly="readonly" value="' + machineName + '">';
			innerHtml += '						<input type="hidden" id="machine_plant_seq_' + idx + '" name="machine_plant_seq_' + idx + '" value="' + machinePlantSeq + '">';
			innerHtml += '						<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goModelInfoClick(' + idx + ');" ' + (isUpdateAuth == true ? "" : "disabled='disabled'" ) + '><i class="material-iconssearch"></i></button>';
			innerHtml += '						<div class="algin-item-center" style="margin-left: 5px;">';
			innerHtml += '							<div class="algin-item-center ml5">';
			innerHtml += '								<select class="form-control ' + (isUpdateAuth == true ? "essential-bg" : "" ) + ' " style="border-radius: 4px;" id="consult_type_cd_' + idx + '" name="consult_type_cd_' + idx + '" ' + (isUpdateAuth == true ? "" : "disabled='disabled' " ) + '>';
			innerHtml += '									<option value="01"' + (counsel.consult_type_cd == '01' ? " selected" : "" ) + '>신차</option>';
			innerHtml += '									<option value="03"' + (counsel.consult_type_cd == '03' ? " selected" : "" ) + '>렌탈</option>';
			innerHtml += '								</select>';
			innerHtml += '							</div>';
			innerHtml += '						</div>';
			innerHtml += '					</div>';
			innerHtml += '				</div>';
			innerHtml += '				<div class="pl10 pr5">';
			innerHtml += '					<div class="input-group">상담시간</div>';
			innerHtml += '				</div>';
			innerHtml += '				<div class="">';
			innerHtml += '					<div class="input-group">';
			innerHtml += '						<input type="text" class="form-control ' + ( isUpdateAuth == true ? 'essential-bg ' : '' ) + ' width60px" style="border-radius: 4px;" value="' + stTi + '" id="consult_st_ti_' + idx + '" name="consult_st_ti_' + idx + '" onkeyup="fnCalcCunsultTi(this);" placeholder="HH:MM" minlength="4" maxlength="5" required="required" alt="상담시작시간" ' + ( isUpdateAuth == true ? "" : "readonly='readonly'" ) + '>';
			innerHtml += '						<div class="form-row inline-pd">';
			innerHtml += '							<div class="input-group">&nbsp;&nbsp;~&nbsp;&nbsp;</div>';
			innerHtml += '						</div>';
			innerHtml += '						<input type="text" class="form-control ' + ( isUpdateAuth == true ? 'essential-bg ' : '' ) + ' width60px" style="border-radius: 4px;" value="' + edTi + '" id="consult_ed_ti_' + idx + '" name="consult_ed_ti_' + idx + '" onkeyup="fnCalcCunsultTi(this);" placeholder="HH:MM" minlength="4" maxlength="5" required="required" alt="상담종료시간" ' + ( isUpdateAuth == true ? "" : "readonly='readonly'" ) + '>&nbsp;&nbsp;';
			innerHtml += '					</div>';
			innerHtml += '				</div>';
			innerHtml += '				<div class="pl5">';
			innerHtml += '					<div class="input-group">';
			innerHtml += '						<input type="text" class="form-control text-right width50px" value="' + counsel.consult_min + '" id="consult_min_' + idx + '" name="consult_min_' + idx + '" style="border-radius: 4px;" readonly="readonly">';
			innerHtml += '					</div>';
			innerHtml += '				</div>';
			innerHtml += '				<div class="pr5">';
			innerHtml += '					<div class="input-group">';
			innerHtml += '						<div class="input-group">&nbsp;&nbsp;분</div>';
			innerHtml += '					</div>';
			innerHtml += '				</div>';
			innerHtml += '				<div class="pl10 pr5">';
			innerHtml += '					<div class="input-group">상담방법</div>';
			innerHtml += '				</div>';
			innerHtml += '				<div class="algin-item-center ml5">';
			innerHtml += '					<select class="form-control ' + (isUpdateAuth == true ? "essential-bg" : "" ) + ' " style="border-radius: 4px;" id="consult_case_cd_' + idx + '" name="consult_case_cd_' + idx + '" ' + ( isUpdateAuth == true ? "" : "disabled='disabled'" ) + '>';
			<c:forEach items="${codeMap['CONSULT_CASE']}" var="item">
				var itemCode = "${item.code_value}";
				var itemName = "${item.code_name}";
				innerHtml += '					<option value="'+itemCode+'" '+(itemCode == counsel.consult_case_cd? 'selected':'')+'>'+itemName+'</option>';
			</c:forEach>
			innerHtml += '					</select>';
			innerHtml += '				</div>';
			innerHtml += '				<div class="algin-item-center ml5">';
			innerHtml += '					<select class="form-control" style="border-radius: 4px;" id="consult_interest_cd_' + idx + '" name="consult_interest_cd_' + idx + '" ' + ( isUpdateAuth == true ? "" : "disabled='disabled'" ) + '>';
			innerHtml += '						<option value="">- 관심도 -</option>';
			<c:forEach items="${codeMap['CONSULT_INTEREST']}" var="item">
				var itemCode = "${item.code_value}";
				var itemName = "${item.code_name}";
				innerHtml += '					<option value="'+itemCode+'" '+(itemCode == counsel.consult_interest_cd? 'selected':'')+'>'+itemName+'</option>';
			</c:forEach>
			innerHtml += '					</select>';
			innerHtml += '				</div>';
			innerHtml += '				<div class="algin-item-center ml5">';
			innerHtml += '					<select class="form-control" style="border-radius: 4px;" id="consult_buy_plan_cd_' + idx + '" name="consult_buy_plan_cd_' + idx + '" ' + ( isUpdateAuth == true ? "" : "disabled='disabled'" ) + '>';
			innerHtml += '						<option value="">- 구매계획 -</option>';
			<c:forEach items="${codeMap['CONSULT_BUY_PLAN']}" var="item">
				var itemCode = "${item.code_value}";
				var itemName = "${item.code_name}";
				innerHtml += '					<option value="'+itemCode+'" '+(itemCode == counsel.consult_buy_plan_cd? 'selected':'')+'>'+itemName+'</option>';
			</c:forEach>
			innerHtml += '					</select>';
			innerHtml += '				</div>';
			// innerHtml += '				<div class="pl10 algin-item-center">';
			// innerHtml += '					<div class="form-check form-check-inline">';
			// innerHtml += '						<input class="form-check-input" type="checkbox" id="complete_yn_' + idx + '" name="complete_yn_' + idx + '" onclick="fnChangeComplete(this)" ' + (counsel.complete_yn == 'Y' ? "value='N'" : "value='Y'" ) + ' ' + (counsel.complete_yn == 'N' ? "checked='checked'" : "" ) + ' ' + ( isUpdateAuth == true ? "" : "disabled='disabled'" ) + '>';
			// innerHtml += '						<label for="complete_yn_' + idx + '" class="form-check-label">미결사항</label>';
			// innerHtml += '					</div>';
			// innerHtml += '				</div>';
			innerHtml += '				<div class="pl10 right">';

			// 상담 당일이 아닌 경우 용건추가/상담삭제 미노출
			// 상담자가 아닌 경우 용건추가/안건종결(미종결건)/상담삭제 버튼 비활성화
			if (isUpdateAuth) {
				innerHtml += '					<button type="button" class="btn btn-primary-gra" style="width: 60px;" onclick="fnAddItem(' + idx + ');"' + ( counsel.counsel_mem_no == "${SecureUser.mem_no}" ? "" : "disabled='disabled'" ) + '>용건추가</button>';
			}
			innerHtml += '					<button type="button" class="btn btn-primary-gra" style="width: 60px;" onclick="fnConsultEnd(this);"' + ( counsel.end_yn == "Y" || counsel.counsel_mem_no != "${SecureUser.mem_no}" ? "disabled='disabled'" : "" ) + '>안건종결</button>';
			if (isUpdateAuth) {
				innerHtml += '					<button type="button" class="btn btn-default ml5" onclick="fnUpdateUseYnRow(this);"' + ( counsel.counsel_mem_no == "${SecureUser.mem_no}" ? "" : "disabled='disabled'" ) + '><i class="material-iconsclose text-default"></i>상담삭제</button>';
			}
			innerHtml += '				</div>';
			innerHtml += '			</div>';
			innerHtml += '		</div>';
			innerHtml += '		<div style="width: 100%; border-top: 1px solid #d6d6d6; background: #fff; padding: 0px; margin-top: 10px;">';
			innerHtml += '			<div class="mt10" id="itemListDiv_' + idx + '">';

			// 상담용건 목록 세팅
			var itemList = JSON.parse(counsel.item_list);
			for (j=0; j<itemList.length; j++) {
				innerHtml += fnMakeItemHtml(itemList[j], idx, j, isUpdateAuth);
			}
			innerHtml += '			</div>';
			innerHtml += '		</div>';
			innerHtml += '	</td>';
			innerHtml += '</tr>';

			return innerHtml;
		}

		function fnMakeItemHtml(sub, i, j, isUpdateAuth) {
			var idIndex = i + "_" + j;
			var innerHtml = '';
			innerHtml += '			<div class="form-row inline-pd widthfix align-items-start pl5 pr5 mt7" id="itemDiv_'+ idIndex +'">';
			innerHtml += '				<div class="col width110px">';
			innerHtml += '					<input type="hidden"  id="seq_no_' + idIndex + '"  		name="seq_no_' + idIndex + '" 		value="' + sub.seq_no + '" >';
			innerHtml += '					<input type="hidden"  id="item_use_yn_' + idIndex + '"  name="item_use_yn_' + idIndex + '" 	value="' + sub.item_use_yn + '" >';
			innerHtml += '					<select class="form-control" style="border-radius: 4px;" id="consult_item_cd_' + idIndex + '" name="consult_item_cd_' + idIndex + '" ' + ( isUpdateAuth == true ? "" : "disabled='disabled'" ) + '" onchange="javascript:fnItemSubList('+i+', '+j+', this.value);">';
			innerHtml += '						<option value="">- 용건 -</option>';
			<c:forEach items="${codeMap['CONSULT_ITEM']}" var="item">
				var itemCode = "${item.code_value}";
				var itemName = "${item.code_name}";
				innerHtml += '					<option value="'+itemCode+'" '+(itemCode == sub.consult_item_cd? 'selected':'')+'>'+itemName+'</option>';
			</c:forEach>
			innerHtml += '					</select>';
			innerHtml += '				</div>';
			innerHtml += '				<div class="col width110px">';
			innerHtml += '					<select class="form-control" style="border-radius: 4px;" id="consult_item_sub_cd_' + idIndex + '" name="consult_item_sub_cd_' + idIndex + '" ' + ( isUpdateAuth == true ? "" : "disabled='disabled'" ) + '>';
			innerHtml += '						<option value="">- 서브용건 -</option>';
			<c:forEach items="${codeMap['CONSULT_ITEM_SUB']}" var="item">
				var itemCode = "${item.code_value}";
				var itemName = "${item.code_name}";
				if (sub.consult_item_sub_cd != "") {
					innerHtml += '				<option value="'+itemCode+'" '+(itemCode == sub.consult_item_sub_cd? 'selected':'')+'>'+itemName+'</option>';
				}
			</c:forEach>
			innerHtml += '					</select>';
			innerHtml += '				</div>';
			innerHtml += '				<div class="col-10">';
			innerHtml += '					<textarea style="height: 100px;" id="consult_text_' + idIndex + '" name="consult_text_' + idIndex + '" alt="상담내용" ' + ( isUpdateAuth == true ? "" : "readonly='readonly'" ) + ' maxlength="4000">' + sub.consult_text + '</textarea>';
			innerHtml += '				</div>';
			innerHtml += '			</div>';
			return innerHtml;
		}

		function fnItemSubList(i, j, val) {
			var itemSubId = "consult_item_sub_cd_" + i + "_" + j;
			var itemCd = val;
			// select box 옵션 전체 삭제
			$("#" + itemSubId + " option").remove();
			// select box option 추가
			$("#" + itemSubId).append(new Option('- 서브용건 -', ''));
			$("#" + itemSubId).prop("disabled", false);

			if (val == '') {
				return false;
			}

			// 용건에 따른 서브용건 list를 세팅
			if (itemSubMap.hasOwnProperty(itemCd)) {
				var itemSubCdList = itemSubMap[itemCd];

				for (item in itemSubCdList) {
					$("#" + itemSubId).append(new Option(itemSubCdList[item].code_name, itemSubCdList[item].code_value, false, item==0));
				}
			}
		}

		function fnClose() {
			window.close();
		}

		function fnAddRows() {
			if(isCustNoNotSelected()) {
				return;
			}

			// $M.setValue("cust_no", data.cust_no);
			var machinePlantSeq = $M.getValue("s_machine_plant_seq");
			// 모델이 다중 선택된 상태에서 상담추가 시, 상담모델이 DUMMY로 찍히는 버그 수정 - 김경빈
			if(machinePlantSeq.includes("#")) {
				alert("상담모델은 여러개 선택할 수 없습니다.");
				return;
			}

			var i = -1;
			var innerHtml = '';

			var newCounsel = {
				"cmd": "C",
				"cust_counsel_seq": 0,
				"machine_name": "",
				"machine_plant_seq": "",
				"reg_dt": "",
				"consult_st_ti": "",
				"consult_ed_ti": "",
				"consult_min": "",
				"consult_dt": "",
				"counsel_mem_name": "${SecureUser.kor_name}",
				"counsel_mem_no": "${SecureUser.mem_no}",
				"counsel_org_code": "${SecureUser.org_code}",
				"use_yn": "Y",
				"end_yn": "N",
				"item_list": JSON.stringify([
					{
						"cmd": "C",
						"seq_no": 0,
						"consult_item_cd": "",
						"consult_item_sub_cd": "",
						"consult_text": "",
						"item_use_yn": "Y"
					}
				]),
			}

            innerHtml += fnMakeCounselHtml(newCounsel, i);
			$('#counselTable > tbody:last').prepend(innerHtml);
			listCnt++;

			$("#consult_dt_" + (i+listCnt)).val($M.formatDate($M.toDate(now)));
			$(".calDate").datepicker();
			/*$('html, body').animate({scrollTop: $("#consult_text_" + i).offset().top}, 500);*/

			// 모델이 설정되어있을 때, 상담추가 시 상담모델 자동 적용 - 김경빈
			var machinePlantName = $('#_easyui_textbox_input2').val();
			if (machinePlantSeq.length) {
				$M.setValue("machine_name_" + (i+listCnt), machinePlantName);
				$M.setValue("machine_plant_seq_" + (i+listCnt), machinePlantSeq);
			}

			var endYn = $M.getValue("end_yn_" + (i+listCnt-1));
			var prevMachinePlantSeq = $M.getValue("machine_plant_seq_" + (i+listCnt-1));
			var currMachinePlantSeq = $M.getValue("machine_plant_seq_" + (i+listCnt));

			var consultInterestCd = $M.getValue("consult_interest_cd_" + (i+listCnt-1));
			if (endYn != "Y" && consultInterestCd != "" && prevMachinePlantSeq == currMachinePlantSeq) {
				$M.setValue("consult_interest_cd_" + (i+listCnt), consultInterestCd);
			}
			var consultBuyPlanCd = $M.getValue("consult_buy_plan_cd_" + (i+listCnt-1));
			if (endYn != "Y" && consultBuyPlanCd != "" && prevMachinePlantSeq == currMachinePlantSeq ) {
				$M.setValue("consult_buy_plan_cd_" + (i+listCnt), consultBuyPlanCd);
			}
		}

		function goSave(flag) {
			if (flag != "Y") {
				if (confirm("저장 하시겠습니까?") == false) {
					return false;
				}
				if (fnValidationConsult()==false) {
					return false;
				}
			}

			var counselArr = [];
			var checkYn = true;
			//테이블에서 한개씩 선택해서 배열에 넣기
			$('tr[id^="tr_consult"]').each(function () {
				var counsel = {};
				var tr = $(this);
				var td = tr.children();
				var isUpdateAuth = ( td.find('[id^="consult_dt"]').val().replace(/-/gi, "") == now || td.find('[id^="reg_dt"]').val() == now ) ? true : false;

				//상담내용 등록,수정 및 삭제는 본인이 등록한 내용만 처리함
				if (td.find('[id^="counsel_mem_no"]').val() == "${SecureUser.mem_no}") {
					if (!isUpdateAuth && !(!isUpdateAuth && td.find('[id^="end_yn"]').val() == "Y")) {
						return false; // 당일 제한
					}

					counsel.cust_counsel_seq = td.find('[id^="cust_counsel_seq"]').val();
					counsel.consult_dt = td.find('[id^="consult_dt"]').val().replace(/-/gi, "");
					counsel.mem_no = td.find('[id^="counsel_mem_no"]').val();
					counsel.org_code = td.find('[id^="counsel_org_code"]').val();
					counsel.machine_plant_seq = td.find('[id^="machine_plant_seq"]').val();
					counsel.consult_st_ti = td.find('[id^="consult_st_ti"]').val();
					counsel.consult_ed_ti = td.find('[id^="consult_ed_ti"]').val();
					counsel.consult_min = td.find('[id^="consult_min"]').val();
					counsel.complete_yn = td.find('[id^="complete_yn"]').is(":checked") ? "N" : "Y";
					counsel.consult_type_cd = td.find('[id^="consult_type_cd"]').val();
					counsel.consult_case_cd = td.find('[id^="consult_case_cd"]').val();
					counsel.consult_interest_cd = td.find('[id^="consult_interest_cd"]').val();
					counsel.consult_buy_plan_cd = td.find('[id^="consult_buy_plan_cd"]').val();
					counsel.use_yn = td.find('[id^="use_yn"]').val();
					counsel.end_yn = td.find('[id^="end_yn"]').val() ?? 'N';

					//등록정보가 없으면 신규로
					if (td.find('[id^="cust_counsel_seq"]').val() == "0") {
						counsel.cmd = "C";
					} else {
						counsel.cmd = "U";
					}

					var itemList = [];
					var itemDiv = td.find('[id^="itemDiv"]');
					for (i = 0; i < itemDiv.length; i++) {
						var item = {};
						var itemTr = $(itemDiv[i]);

						item.seq_no = itemTr.find('[id^="seq_no"]').val() ?? '0';
						item.consult_item_cd = itemTr.find('[id^="consult_item_cd"]').val() ?? '';
						item.consult_item_sub_cd = itemTr.find('[id^="consult_item_sub_cd"]').val() ?? '';
						item.consult_text = itemTr.find('[id^="consult_text"]').val() ?? '';

						//등록정보가 없으면 신규로
						if (item.seq_no == "0") {
							item.cmd = "C";
						} else {
							item.cmd = "U";
						}

						if (counsel.cmd == 'U' && counsel.use_yn == 'N') {
							item.use_yn = "N";
						} else {
							item.use_yn = itemTr.find('[id^="item_use_yn"]').val();
						}

						if (item.consult_item_cd == "" && (item.consult_item_sub_cd != '' || item.consult_text != '')) {
							alert("서브용건 및 상담내용 입력시 용건은 필수 선택사항입니다.");
							checkYn = false;
							return false;
						}
						
						if (item.cmd == "C" && item.consult_item_cd == '' && item.consult_item_sub_cd == '' && item.consult_text == '') {
							continue;
						} else if (item.cmd == "U" && item.consult_item_cd == '' && item.consult_item_sub_cd == '' && item.consult_text == '') {
							item.use_yn = "N";
						}
						
						itemList.push(item);
					}

					counsel.item_list = itemList;

					const saveItemSize = counsel?.item_list?.filter(item => item.use_yn === 'Y')?.length ?? 0;
					if (counsel.cmd == "U" && saveItemSize == 0) {
						counsel.use_yn = "N";
						td.find('[id^="use_yn"]').val("N");
					}

					if (!(counsel.cmd == "C" && counsel.item_list.length == 0)) {
						counselArr.push(counsel);
					}
				}
			});

			if (!checkYn) {
				return false;
			}

			if(counselArr.length == 0) {
				alert("수정한 내용이 없습니다.");
				return;
			}
			
			var param = {
				"cust_no" : $M.getValue("cust_no"),
				"mem_no" : $M.getValue("mem_no"),
				"cust_grade_cd_str" : $M.getValue("cust_grade_cd").replaceAll("#", "^")
			}

			// '=' 포함시 서버에서 짤림현상, 이를 방지하기 위해 encoding
			param.consult_list = encodeURIComponent(JSON.stringify(counselArr.reverse()));

			$M.goNextPageAjax(this_page + "/update", $M.toGetParam(param), {method: 'POST'},
					function (result) {
						if (result.success) {
							alert("처리가 완료되었습니다.");
							// 저장 시 조회기간 끝 날짜를 현재로 설정 - 김경빈
							$M.setValue("s_end_dt", $M.toDate(now));
							goSearch();
						}
					}
			);
		}

		function fnValidationConsult(cmd) {
			var checkInxList = [];

			// [14665] 상담내역이 음수인 경우를 체크 - 김경빈
			for (var i=0; i<=listCnt; i++) {
				if (!$("#consult_ed_ti_" + i).prop("readonly") && $("#consult_ed_ti_" + i).length > 0) {
					checkInxList.push(i);
					if ($M.getValue("consult_min_" + i) < 0) {
						alert("상담시간은 음수가 될 수 없습니다.");
						$("#consult_ed_ti_" + i).focus();
						return false;
					}
				}
			}

			// 상담내용이 많은 경우 validation 소요시간이 너무 오래걸려, readonly가 아닌 상담내용만 validation 처리 - 김경빈
			var checkFieldList = ["cust_name", "service_mem_name", "sale_mem_name"];
			checkInxList.map(function(i) {
				if (cmd != "D") {
					checkFieldList.push("machine_name_" + i);
					checkFieldList.push("consult_st_ti_" + i);
					checkFieldList.push("consult_ed_ti_" + i);
					checkFieldList.push("consult_dt_" + i);
					checkFieldList.push("consult_type_cd_" + i);
					checkFieldList.push("consult_case_cd_" + i);
					// checkFieldList.push("consult_text_" + i);
				}
			});
			if ($M.validation(null, {field:checkFieldList}) === false) {
				return false;
			}

			return true;
		}

		function setCustGradeDesc(value) {
			value = value.replaceAll(" ", "");
			var valueArr = [ value ];
			if (value.indexOf("#") > -1) {
				valueArr = value.split("#");
			} else if (value.indexOf("^") > -1) {
				valueArr = value.split("^");
			} else if (value.indexOf(",") > -1) {
				valueArr = value.split(",");
			}

			var codeDesc = "";
			if (valueArr != null && valueArr.length > 0) {
				for (var i = 0; i < custGradeList.length; i++) {
					for (var j=0; j< valueArr.length; j++) {
						if (valueArr[j] == custGradeList[i].code_value) {
							codeDesc = (codeDesc==""? custGradeList[i].code_desc : codeDesc + ", " + custGradeList[i].code_desc);
							break;
						}
					}
				}
			}
			$M.setValue("cust_grade_desc", codeDesc);
			$("#cust_grade_desc").prop("title", codeDesc);
		}

		function fnChangeComplete(obj) {
			// 체크여부 확인
			if ($(obj).is(":checked") == true) {
				$(obj).val("N");
			} else {
				$(obj).val("Y");
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

		// 상담삭제
		function fnUpdateUseYnRow(obj) {
			var tr = $(obj).closest("tr");
			var td = tr.children();
			td.find('[id^="use_yn"]').val("N");

			if (fnValidationConsult('D')==false) {
				return false;
			}

			if (td.find('[id^="cust_counsel_seq"]').val() == "0") {
				if (confirm("작성한 내용을 삭제 하시겠습니까?") == false) {
					return;
				}
				tr.remove();
			} else {
				if (confirm("작성중이던 상담내용은 저장됩니다.\n해당 상담건을 삭제하시겠습니까?") == false) {
					return false;
				}
				goSave("Y");
			}
		}

		// 용건추가
		function fnAddItem(idx) {
			if (listCnt > 0) {
				var innerHtml = '';
				var itemDivs = $("#itemListDiv_"+idx).find("[id^='itemDiv']");

				var newItem = {
					"cmd": "C",
					"seq_no": 0,
					"consult_item_cd": "",
					"consult_item_sub_cd": "",
					"consult_text": "",
					"item_use_yn": "Y"
				}
				innerHtml = fnMakeItemHtml(newItem, idx, itemDivs.length, true);

				$("#itemListDiv_"+idx).append(innerHtml);
			}
		}

		// 안건종결
		function fnConsultEnd(obj) {
			var tr = $(obj).closest("tr");
			var td = tr.children();

			if (fnValidationConsult()==false) {
				return false;
			}

			if (td.find('[id^="end_yn"]').val() == "Y") {
				alert("이미 종결처리된 건입니다.");
				return false;
			}

			if (confirm("작성중이던 상담내용은 저장됩니다.\n종결처리 하시겠습니까?") == false) {
				return false;
			}

			td.find('[id^="end_yn"]').val("Y");
			goSave("Y");
		}
	</script>


	<script type="text/javascript">
		// 팝업호출 script

		// 고객조회 팝업
		function fnOpenSearchCustpanel() {
			var param = {
				s_consult_yn : "Y"
			};
			openSearchCustPanel('fnSetCustInfo', $M.toGetParam(param));
		}

		function fnSetCustInfo(data) {
			$M.setValue("cust_name", data.real_cust_name);
			$M.setValue("cust_no", data.cust_no);
			$M.setValue("__s_cust_no", data.cust_no);
			$M.setValue("hp_no", data.real_hp_no);
			$M.setValue("sale_mem_no", data.sale_mem_no);
			$M.setValue("sale_mem_name", data.sale_mem_name);
			$M.setValue("service_mem_no", data.service_mem_no);
			$M.setValue("service_mem_name", data.service_mem_name);
			$M.setValue("post_no", data.post_no);
			$M.setValue("addr1", data.addr1);
			$M.setValue("addr2", data.addr2);
			$M.setValue("svc_loyal_name", data.svc_loyal_name == "" || data.svc_loyal_name == undefined? "" : "서비스충성도: " + data.svc_loyal_name);

			$('#cust_grade_cd').combogrid("setValues", data.cust_grade_cd_str == ""? "" : data.cust_grade_cd_str.split("^"));
			$M.setHiddenValue(document.main_form, "cust_grade_cd_str", $M.getValue("cust_grade_cd").replaceAll("#", "^"));

			setCustGradeDesc(data.cust_grade_cd_str);
			fnSearchCustCounselList(data.cust_no);
		}

		// 문자발송
		function fnSendSms() {
			var params = {
				"name": $M.getValue("cust_name"),
				"hp_no": $M.getValue("hp_no")
			};
			openSendSmsPanel($M.toGetParam(params));
		}



		// 상담목록 모델팝업
		function goModelInfoClick(seq) {

			listNum = seq;

			var param = {
				s_machine_name: $M.getValue("machine_name"),
				s_price_present_yn: "Y"
			};
			openSearchModelPanel('fnSetModelInfo', 'N', $M.toGetParam(param));
		}

		//모델조회 결과반영
		function fnSetModelInfo(row) {
			$M.setValue("machine_name_" + listNum, row.machine_name);
			$M.setValue("machine_plant_seq_" + listNum, row.machine_plant_seq);
		}

		// 고객등록 팝업
		function fnAddCust() {
			param = {
				s_popup_yn : 'Y',
			};
			$M.goNextPage('/cust/cust010201', $M.toGetParam(param), {popupStatus : getPopupProp(720, 330)});
		}

		function fnSearchCustCounselList(custNo) {
			var param = {
				s_cust_no : custNo,
				s_dt_yn : 'N',
			};

			$M.goNextPageAjax("/cust/cust0101/search", $M.toGetParam(param), {method: 'GET'},
				function (result) {
					if (result.success) {
						if (result.total_cnt > 0) {
							var param2 = {
								s_cust_no : custNo,
							};
							$M.setValue("s_dt_yn", "Y");
							openCustCounselListPanel('fnSetCustCounselInfo', $M.toGetParam(param2));
						} else {
							// 최초 안건상담 고객인 경우
							$M.setValue("s_cust_no", custNo);
							$M.setValue("s_dt_yn", "N");
							goSearch();
						}
					}
				}
			);
		}

		//고객상담 결과반영
		function fnSetCustCounselInfo(data) {
			$M.setValue("s_cust_no", data.cust_no);
			$M.setValue("s_start_dt", data.consult_dt_min);
			$M.setValue("s_end_dt", data.consult_dt_max);
			$M.setValue("s_machine_plant_seq", [data.machine_plant_seq]);
			goSearch();
		}

		// 타사장비 판매가 등록 팝업 호출
		function goAddCompetiorPrice() {
			$M.goNextPage("/sale/sale0409p01", "", {popupStatus : ""});
		}

	</script>


</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<input type="hidden" id="s_dt_yn" name="s_dt_yn">
	<input type="hidden" id="__s_cust_no" name="__s_cust_no">
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
				<h4>안건상담관리</h4>
			</div>
			<div class="form-group mt5">
				<table class="table-border">
					<colgroup>
						<col width="100px">
						<col width="">
						<col width="100px">
						<col width="300px">
						<col width="100px">
						<col width="300px">
					</colgroup>
					<tbody>
					<tr>
						<th class="text-right">고객명</th> <!-- 필수항목일때 클래스 essential-item 추가 -->
						<td>
							<div class="form-row inline-pd">
								<div class="col-auto">
									<div class="input-group">
										<input type="text" class="form-control border-right-0 width100px" id="cust_name" name="cust_name" required="required" alt="고객명" readonly="readonly">
										<input type="hidden" id="cust_no" name="cust_no" value=""/>
										<button type="button" class="btn btn-icon btn-primary-gra" onclick="fnOpenSearchCustpanel()"><i class="material-iconssearch"></i></button>
									</div>
								</div>
                                <div class="col-auto">
                                    <jsp:include page="/WEB-INF/jsp/common/commonCustJob.jsp">
                                        <jsp:param name="li_type" value="__cust_dtl#__ledger#__sms_popup#__sms_info#__check_required#__have_machine_cust#__cust_rental_history"/>
                                    </jsp:include>
                                </div>
								<div class="col-auto">
									<button type="button" class="btn btn-primary-gra" style="width: 100%;" onclick="fnAddCust();">고객등록</button>
								</div>
							</div>
						</td>
						<th class="text-right">휴대폰</th>
						<td colspan="3">
							<div class="form-row inline-pd">
								<div class="col-12">
									<div class="input-group">
										<input type="text" class="form-control  border-right-0" id="hp_no" name="hp_no" format="phone" readonly="readonly"/>
										<button type="button" class="btn btn-icon btn-primary-gra" onclick="fnSendSms();"><i class="material-iconsforum"></i></button>
									</div>
								</div>
							</div>
						</td>
					</tr>
					<tr>
						<th class="text-right">고객등급</th>
						<td>
							<div class="form-row inline-pd ">
								<div class="col-9">
									<input type="text" class="form-control" id="cust_grade_desc" name="cust_grade_desc" readonly="readonly" disabled="disabled">
								</div>
								<div class="col-3">
									<input class="form-control" style="width: 99%;" type="text" id="cust_grade_cd" name="cust_grade_cd" easyui="combogrid" change="javascript:setCustGradeDesc(this.value);"
										   easyuiname="custGradeList" panelwidth="250" idfield="code_value" textfield="code_name" multi="Y"/>
								</div>
							</div>
						</td>
						<th class="text-right">마케팅담당자</th>
						<td>
							<div class="form-row inline-pd">
								<div class="col width140px">
									<input type="text" class="form-control" id="sale_mem_name" name="sale_mem_name" alt="마케팅담당자" readonly="readonly" required="required" disabled="disabled">
								</div>
							</div>
						</td>
						<th class="text-right">서비스담당자</th>
						<td>
							<div class="form-row inline-pd">
								<div class="col width140px">
									<input type="text" class="form-control" id="service_mem_name" name="service_mem_name" alt="서비스담당자" readonly="readonly" required="required" disabled="disabled">
								</div>
							</div>
						</td>
					</tr>
					<tr>
						<th class="text-right">주소</th>
						<td colspan="5">
							<div class="form-row inline-pd widthfix">
								<div class="col-auto">
									<input type="text" class="form-control width100px" id="post_no" name="post_no" readonly="readonly" alt="자택주소">
								</div>
								<div class="col-3">
									<input type="text" class="form-control" id="addr1" name="addr1" readonly="readonly" alt="자택주소">
								</div>
								<div class="col-5">
									<input type="text" class="form-control width400px" id="addr2" name="addr2" readonly="readonly" alt="자택주소">
								</div>
								<div class="col-auto">
									<button type="button" class="btn btn-primary-gra" style="width: 100px;" onclick="goAddCompetiorPrice();">경쟁사정보</button>
								</div>
								<div class="col width160px">
									<input type="text" class="form-control text-center" id="svc_loyal_name" name="svc_loyal_name" readonly="readonly" alt="서비스충성도" placeholder="서비스충성도">
								</div>
							</div>
						</td>
					</tr>
					</tbody>
				</table>
			</div>
			<div class="search-wrap mt10" style="margin-top:3px;">
				<table class="table">
					<colgroup>
						<col width="60px">
						<col width="260px">
						<col width="50px">
						<col width="100px">
						<col width="70px">
						<col width="100px">
						<col width="70px">
						<col width="200px">
						<col width="">
					</colgroup>
					<tbody>
					<tr>
						<th>조회기간</th>
						<td>
							<div class="form-row inline-pd">
								<div class="col-5">
									<div class="input-group">
										<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="상담일자시작일" size="12" maxlength="8" value="${searchDtMap.s_start_dt}" />
									</div>
								</div>
								<div class="col-auto">~</div>
								<div class="col-5">
									<div class="input-group">
										<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="상담일자종료일" size="12" maxlength="8" value="${searchDtMap.s_end_dt}" />
									</div>
								</div>
								<jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp">
									<jsp:param name="st_field_name" value="s_start_dt"/>
									<jsp:param name="ed_field_name" value="s_end_dt"/>
									<jsp:param name="click_exec_yn" value="N"/>
									<jsp:param name="exec_func_name" value=""/>
								</jsp:include>
							</div>
						</td>
						<th>메이커</th>
						<td>
							<select class="form-control" id="s_maker_cd" name="s_maker_cd">
								<option value="">- 전체 -</option>
								<c:forEach var="item" items="${codeMap['MAKER']}">
									<option value="${item.code_value}">${item.code_name}</option>
								</c:forEach>
							</select>
						</td>
						<th>종류</th>
						<td>
							<select class="form-control" id="s_consult_type_cd" name="s_consult_type_cd">
								<option value="">- 전체 -</option>
								<c:forEach var="item" items="${codeMap['CONSULT_TYPE']}">
									<c:if test="${item.code_name ne '대차'}">
										<option value="${item.code_value}">${item.code_name}</option>
									</c:if>
								</c:forEach>
							</select>
						</td>
						<th>모델</th>
						<td>
							<input class="form-control" style="width: 99%;" type="text" id="s_machine_plant_seq" name="s_machine_plant_seq" easyui="combogrid"
								   easyuiname="machineList" panelwidth="300" idfield="machine_plant_seq" textfield="machine_name" multi="Y"/>
						</td>
						<td>
							<div style="float: left">
								<button type="button" class="btn btn-important ml5" style="width: 50px;" onclick="goSearch();">조회</button>
								<button type="button" class="btn btn-default ml5" style="width: 80px;" onclick="fnAddRows();"><i class="material-iconsadd text-default"></i>상담추가</button>
							</div>
							<div style="float: right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</td>
					</tr>
					</tbody>
				</table>
			</div>
			<table class="table-border" style="margin-top:3px;" id="counselTable">
				<colgroup>
					<col width="100px">
					<col width="500px">
					<col width="100px">
					<col width="">
					<col width="100px">
					<col width="">
				</colgroup>
				<%-- 상담목록 --%>
				<tbody id="counselList">

				</tbody>
			</table>


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