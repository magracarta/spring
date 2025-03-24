<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 고객현황 > ARS > ARS상담정보 > null
-- 작성자 : 이강원
-- 최초 작성일 : 2023-08-11 09:47:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript" src="/static/js/yk_ntsconnect.min.js?ver=20230701017"></script>
	<script type="text/javascript">
		var listCnt = 0;
		var inputHpNo = '${inputParam.hp_no}';
		var confirmCheck = false;
		var orgList = JSON.parse('${orgList}');
		var memList = JSON.parse('${memList}');
		var gubun1List = JSON.parse('${codeMapJsonObj['CALL_SVC']}');
		// [{code_value : '정비상담'}, {code_value : '부품문의'}, {code_value : '신차문의'}, {code_value : '렌탈문의'},];
		var gubun2Map =  JSON.parse('${codeMapJsonObj['CALL_GR']}');
		// {'정비상담' : [{code_value : '정비예약'}, {code_value : '장비문의'}, {code_value : '출장요청'}]
		// 			, '부품문의' : [{code_value : '부품문의'}]
		// 			, '신차문의' : [{code_value : '신차문의'}]
		// 			, '렌탈문의' : [{code_value : '굴삭기'},{code_value : '굴삭기외장비'}]};

		// 정상적인 부모창에서 팝업으로 열려 전화걸기/받기 버튼 노출 여부
		var showCallBtn = opener.this_page == '/cust/cust0108';;
		$(document).ready(function() {
			var str = "";
			if(${empty custInfo.cust_no}) {
				str += '<option value="${inputParam.hp_no}">' + $M.phoneFormat('${inputParam.hp_no}') + '</option>'
			}
			if(${not empty custInfo.hp_no}) {
				str += '<option value="${custInfo.hp_no}">' + $M.phoneFormat('${custInfo.hp_no}') + '</option>'
			}
			if(${not empty custInfo.mng_hp_no}) {
				str += '<option value="${custInfo.mng_hp_no}">' + $M.phoneFormat('${custInfo.mng_hp_no}') + '</option>'
			}
			if(${not empty custInfo.driver_hp_no}) {
				str += '<option value="${custInfo.driver_hp_no}">' + $M.phoneFormat('${custInfo.driver_hp_no}') + '</option>'
			}

			var gubunOption1 = '<option value="">구분 1 전체</option>';
			for(var i = 0; i < gubun1List.length; i++) {
				var item = gubun1List[i];
				gubunOption1 += '<option value="' + item.code_value + '">' + item.code_name + '</option>';
			}

			$("#calling_hp_no").append(str);
			$("#s_gubun_1").append(gubunOption1);

			goSearch('init');

			// ARS 상담페이지에서 열렸을때만 상태 체크함
			if(showCallBtn) {
				setInterval(function () {
					fnStatusCheck();
				}, 1000);
			} else {
				alert('전화걸기/받기 기능은 ARS상담화면에서 진입해야 가능합니다.\n\n현재는 상담내역만 처리가능합니다.');
				// 전화걸기/끊기 버튼 감춤
				$("[id^='btn_cti']").css("display", "none");
				$("#la_call_status, #login_gubun_1, #login_gubun_2, #change_label, #change_status, #btn_change_status").css("display", "none");
				$("#show_call_div").css("display", "block");
			}
		});

		// 1초마다 본창의 상태를 체크
		function fnStatusCheck() {
			// 로그인된 ars관리 본창을 닫은 경우
			if(opener == undefined || opener == null) {
				alert("ARS관리 화면이 종료되어 해당 화면을 종료합니다.");
				fnClose();
			} else {
				// 상위정보 동기화
				$('#la_call_status').html($('#la_call_status',opener.document).html());
				$M.setValue('change_status', opener.$M.getValue('change_status'));
				if(opener.cti.statusCd == 1 || opener.cti.statusCd == 7) {
					// 전화통화 상태
					$("#btn_cti_call").attr("disabled", true);
					$("#btn_cti_call_stop").attr("disabled", false);
					$("[id^='btn_call_back']").attr("disabled", true);
					$("[id^='btn_call_stop']").attr("disabled", false);
					confirmCheck = false;
				} else if(opener.cti.statusCd == 2) {
					// 전화대기 상태
					$("#btn_cti_call").attr("disabled", true);
					$("#btn_cti_call_stop").attr("disabled", true);
					$("[id^='btn_call_back']").attr("disabled", true);
					$("[id^='btn_call_stop']").attr("disabled", true);
					confirmCheck = false;
				} else if(opener.cti.statusCd == 3) {
					// 전화불가 상태
					$("#btn_cti_call").attr("disabled", false);
					$("#btn_cti_call_stop").attr("disabled", true);
					$("[id^='btn_call_back']").attr("disabled", false);
					$("[id^='btn_call_stop']").attr("disabled", true);
					confirmCheck = false;
				}  else if(opener.cti.statusCd == 8) {
					$("#btn_cti_call").attr("disabled", true);
					$("#btn_cti_call_stop").attr("disabled", true);
					$("[id^='btn_call_back']").attr("disabled", true);
					$("[id^='btn_call_stop']").attr("disabled", true);
					// 전화걸기가 아니고 아직 확인을 안받은 상태면
					if(!confirmCheck && !opener.callingCheck && opener.call_cust_info.txt_CID != '') {
						// 전화가 걸려온 상태
						//window.blur();
						//setTimeout(function() { window.focus(); }, 100);
						//if(confirm("전화를 받을 시 창이 새로고침됩니다.\n해당 화면을 저장하시겠습니까?")) {
						//	this.goSave();
						//}
						//confirmCheck = true;

						// 엑션이 중복되는 경향이 있어 창을 닫아버림
						self.close();
					}
				} else if(opener.cti.statusCd == '') {
					// 본창은 남아있지만 로그인은 안한 상태
					$("#btn_cti_call").attr("disabled", true);
					$("#btn_cti_call_stop").attr("disabled", true);
					$("[id^='btn_call_back']").attr("disabled", true);
					$("[id^='btn_call_stop']").attr("disabled", true);
					confirmCheck = false;
				}

				// 전화를 하고 있는 상태(다이얼링) - 끊기 활성화
				if(opener.cti.statusCd != 2 && opener.callingCheck) {
					$("#btn_cti_call").attr("disabled", true);
					$("#btn_cti_call_stop").attr("disabled", false);
					$("[id^='btn_call_back']").attr("disabled", true);
					$("[id^='btn_call_stop']").attr("disabled", false);
				}
			}
		}

		function fnChangeGubun() {
			var gubun1 = $M.getValue("s_gubun_1");

			$("#s_gubun_2 option").remove();
			var gubunOption2 = '<option value="">구분 2 전체</option>';
			if(gubun1 != "") {
				for(var i = 0; i < gubun2Map.length; i++) {
					var item = gubun2Map[i];
					if(item.code_v1 == gubun1) {
						gubunOption2 += '<option value="' + item.code_value + '">' + item.code_name + '</option>';
					}
				}
			}
			$("#s_gubun_2").append(gubunOption2);
		}

		function fnChangeRowGubun(index) {
			var gubun1 = $M.getValue("call_gr_cd_"+index);

			$("#call_svc_cd_" + index + " option").remove();
			var gubunOption2 = '<option value="">구분 2 전체</option>';
			if(gubun1 != "") {
				for(var i = 0; i < gubun2Map.length; i++) {
					var item = gubun2Map[i];
					if(item.code_v1 == gubun1) {
						gubunOption2 += '<option value="' + item.code_value + '">' + item.code_name + '</option>';
					}
				}
			}
			$("#call_svc_cd_" + index).append(gubunOption2);
			$M.setValue("call_svc_cd_" + index, gubun1 != "" ? $M.getValue("before_call_svc_cd_" + index) : "");
		}

		// 조회
		function goSearch(init) {
			if($M.checkRangeByFieldName('s_start_dt', 's_end_dt', true) == false) {
				return;
			};

			var sGubunName1 = $M.getValue("s_gubun_1") == "" ? "" : $("#s_gubun_1 option:selected").text();
			var sGubunName2 = $M.getValue("s_gubun_2") == "" ? "" : $("#s_gubun_2 option:selected").text();

			var param = {
				s_start_dt : $M.getValue("s_start_dt"),
				s_end_dt : $M.getValue("s_end_dt"),
				s_gubun_name_1 : sGubunName1,
				s_gubun_name_2 : sGubunName2,
				s_gubun_1 : $M.getValue("s_gubun_1"),
				s_gubun_2 : $M.getValue("s_gubun_2"),
				s_hp_no : $M.getValue("input_hp_no"),
			};
			_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
			if (param.s_start_dt == "" && param.s_end_dt == "") {
				delete param['s_st_dt'];delete param['s_ed_dt'];
			}

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
					function(result) {
						if(result.success) {
							var data = result.list

							// 조회된 ars의 첫 번째 ars_dt로 검색 시작일자 설정
							var first_st_dt = result.first_st_dt;
							if(first_st_dt != "") {
								$M.setValue("s_start_dt", first_st_dt);
							}

							listCnt = 0;
							$("tbody[id='consultList'] tr").remove();

							for (var i = data.length -1; i >= 0; i--) {
								fnAddRows(data[i])
							}

							if(init != undefined && ${empty syncYn}) {
								var arsDate = $M.getCurrentDate("yyyy-MM-dd HH:mm:ss");
								var conKey = '${inputParam.connect_key}';
								if(conKey.length == 18) {
									arsDate = $M.dateFormat(conKey.substring(0, 14), 'yyyy-MM-dd HH:mm:ss');
								}
								var row = {
									ars_date : arsDate
									, ars_seq : '0'
									, call_telnum : '${inputParam.hp_no}'
									, send_no : '${inputParam.hp_no}'
									, call_minute : ''
									, consult_text : ''
									, call_cticonkey : conKey
									, call_gr_nm : '${inputParam.gubun_1}'
									, call_svc_nm : '${inputParam.gubun_2}'
									, org_name : ''
									, ars_mem_no : ''
									, ars_mem_name : ''
									, complete_yn : 'N'
									, cb_telnum : ''
									, cb_gkcid : ''
									, file_seq : '0'
									, rec_url : ''
									, reg_id : 'SYSTEM'
									, paper_info : ''
								}

								fnAddRows(row);
							}
						};
						if(showCallBtn == false) {
							$("[id^='btn_cti']").css("visibility", "hidden");
							$("[id^='btn_call']").css("visibility", "hidden");
						}
					}
			)
		}

		// 상담추가
		function fnAddRows(row) {
			var addRow = false;
			if(row == undefined) {
				addRow = true;
				row = {
					ars_date : $M.getCurrentDate("yyyy-MM-dd HH:mm:ss")
					, ars_seq : '0'
					, send_no : '${inputParam.hp_no}'
					, call_telnum : ''
					, call_minute : ''
					, consult_text : ''
					, call_gr_cd : ''
					, call_svc_cd : ''
					, before_call_svc_cd : ''
					, org_name : ''
					, ars_mem_no : ''
					, ars_mem_name : ''
					, complete_yn : 'N'
					, cb_telnum : ''
					, cb_gkcid : ''
					, file_seq : '0'
					, rec_url : ''
					, call_cticonkey : 'N'
					, reg_id : 'SYSTEM'
					, paper_info : ''
				}
			}

			var i = ++listCnt;

			var totalList = $('tr[id^="ars_contents_"]').length + 1;
			var completeYn = row.complete_yn;
			var editYn = (row.ars_mem_no == '${SecureUser.mem_no}' || row.ars_mem_no == "") && completeYn == 'N' ? 'Y' : 'N';

			var innerHtml = '';
			innerHtml += '<tr id="ars_contents_' + i + '">';
			innerHtml += '<th class="text-right essential-item" id="ars_consult_cnt_'+ i +'">상담내용 ' + totalList + '<br>' + row.ars_seq + '</th>';
			innerHtml += '<td>';
			innerHtml += '	<div class="form-row inline-pd">';
			innerHtml += '		<div class="col width60px text-right">상담일시</div>';
			innerHtml += '		<div class="col width160px">';
			innerHtml += '			<input type="hidden" class="form-control" id="edit_yn_' + i + '" name="edit_yn_' + i + '" readonly value="' + editYn + '">';
			innerHtml += '			<input type="hidden" class="form-control" id="ars_seq_' + i + '" name="ars_seq_' + i + '" readonly value="' + row.ars_seq + '">';
			innerHtml += '			<input type="hidden" class="form-control" id="call_cticonkey_' + i + '" name="call_cticonkey_' + i + '" readonly value="' + row.call_cticonkey + '">';
			innerHtml += '			<input type="text" class="form-control" id="ars_date_' + i + '" name="ars_date_' + i + '" dateformat="yyyy-MM-dd HH:mm:ss" readonly value="' + row.ars_date + '">';
			innerHtml += '		</div>';
			innerHtml += '		<div class="col width60px text-right">수신번호</div>';
			innerHtml += '		<div class="col width120px">';
			innerHtml += '			<input type="hidden" class="form-control" id="send_no_' + i + '" name="send_no_' + i + '" format="phone" readonly value="' + row.send_no + '">';
			innerHtml += '			<input type="text" class="form-control" id="call_telnum_' + i + '" name="call_telnum_' + i + '" format="phone" readonly value="' + row.call_telnum + '">';
			innerHtml += '		</div>';
			innerHtml += '		<div class="col width60px text-right">통화시간</div>';
			innerHtml += '		<div class="col width80px">';
			innerHtml += '			<input type="text" class="form-control text-right" id="call_minute_' + i + '" name="call_minute_' + i + '"  readonly value="' + row.call_minute + '">';
			innerHtml += '		</div>';
			innerHtml += '		<div class="col width16px">';
			innerHtml += '			분';
			innerHtml += '		</div>';
			if((row.call_cticonkey == 'N' | row.call_cticonkey == '') && row.cb_gkcid == '' && completeYn != 'Y') {
				innerHtml += '		<div class="col width60px text-right">구분</div>';
				innerHtml += '		<div class="col width100px">';
				innerHtml += '			<select class="form-control" id="call_gr_cd_' + i + '" name="call_gr_cd_' + i + '" onchange="javascript:fnChangeRowGubun(' + i + ');">'
				innerHtml += '				<option value="">구분 1 전체</option>';
				for(var k = 0; k < gubun1List.length; k++) {
					var gubunTemp = gubun1List[k];
					innerHtml += '<option value="' + gubunTemp.code_value + '">' + gubunTemp.code_name + '</option>';
				}
				innerHtml += '			</select>';
				innerHtml += '		</div>';
				innerHtml += '		<div class="col width100px">';
				innerHtml += '			<select class="form-control" id="call_svc_cd_' + i + '" name="call_svc_cd_' + i + '">';
				innerHtml += '				<option value="">구분 2 전체</option>';
				innerHtml += '			</select>';
				innerHtml += '			<input type="hidden" class="form-control"  id="before_call_svc_cd_' + i + '" name="before_call_svc_cd_' + i + '" value="' + row.before_call_svc_cd + '">';
				innerHtml += '		</div>';
			} else {
				innerHtml += '		<div class="col width60px text-right">구분</div>';
				innerHtml += '		<div class="col width100px">';
				innerHtml += '			<input type="text" class="form-control"  id="call_gr_nm_' + i + '" name="call_gr_nm_' + i + '" readonly value="' + row.call_gr_nm + '">';
				innerHtml += '		</div>';
				innerHtml += '		<div class="col width100px">';
				innerHtml += '			<input type="text" class="form-control"  id="call_svc_nm_' + i + '" name="call_svc_nm_' + i + '"  readonly value="' + row.call_svc_nm + '">';
				innerHtml += '		</div>';
			}
			innerHtml += '	</div>';
			innerHtml += '	<div class="form-row inline-pd mt5">';
			innerHtml += '		<div class="col width60px text-right">기타용건</div>';
			innerHtml += '		<div class="col width160px">';
			innerHtml += '			<select class="form-control" readonly>';
			innerHtml += '				<option>선택</option>';
			innerHtml += '			</select>';
			innerHtml += '		</div>';
			innerHtml += '		<div class="col width60px text-right">부서</div>';
			innerHtml += '		<div class="col width120px">';
			innerHtml += '			<input type="text" class="form-control"  id="org_name_' + i + '" name="org_name_' + i + '" value="' + (row.org_name == "" ? "${SecureUser.org_name}" : row.org_name) + '" readonly>';
			innerHtml += '		</div>';
			innerHtml += '		<div class="col width60px text-right">상담자</div>';
			innerHtml += '		<div class="col width100px">';
			innerHtml += '			<input type="hidden" class="form-control" id="ars_mem_no_' + i + '" name="ars_mem_no_' + i + '" value="' + (row.ars_mem_no == "" ? "${SecureUser.mem_no}" : row.ars_mem_no) + '">';
			innerHtml += '			<input type="text" class="form-control"  id="ars_mem_name_' + i + '" name="ars_mem_name_' + i + '" value="' + (row.ars_mem_name == "" ? "${SecureUser.kor_name}" : row.ars_mem_name) + '" readonly>';
			innerHtml += '		</div>';
			if(completeYn == 'Y') {
				innerHtml += '		<div class="col width60px text-right">';
				innerHtml += '			완료일';
				innerHtml += '		</div>';
				innerHtml += '		<div class="col width140px">';
				innerHtml += '			' + row.complete_date;
				innerHtml += '		</div>';
			}
			if(completeYn == 'N' && editYn == 'Y') {
				innerHtml += '<div class="col-auto text-right" style="flex: 1;">';
				innerHtml += '	<button type="button" class="btn btn-md btn-outline-primary" id="modify_btn_' + i + '" onclick="javascript:' + (row.ars_seq == "0" ? "goSave" : "goModifyRow") + '(' + listCnt + ')">' + (row.ars_seq == "0" ? "저장" : "수정") + '</button>';
				// 2025-02-25 황빛찬 (Q&A:24773) ARS 상담내용 삭제 불가능하도록 요청 적용 (삭제버튼 제거)
				// innerHtml += '	<button type="button" class="btn btn-md btn-outline-secondary" onclick="javascript:goRemoveRow(' + listCnt + ')">삭제</button>';
				innerHtml += '</div>';
			}
			innerHtml += '	</div>';

			innerHtml += '	<div class="form-row inline-pd mt5">';
			innerHtml += '		<div class="col width80px text-right">콜백요청번호</div>';
			innerHtml += '		<div class="col width120px">';
			innerHtml += '			<input type="text" class="form-control" id="cb_telnum_' + i + '" name="cb_telnum_' + i + '" value="' + row.cb_telnum + '" readonly>';
			innerHtml += '			<input type="hidden" class="form-control" id="cb_gkcid_' + i + '" name="cb_gkcid_' + i + '" value="' + row.cb_gkcid + '" readonly>';
			innerHtml += '		</div>';
			innerHtml += '		<div class="col-auto">';
			innerHtml += '			<button type="button" class="btn btn-success btn-md btn-rounded" id="btn_call_' + (row.cb_telnum == "" || editYn == "N" ? "complete_" : "") + 'back_'+ i + '" onclick="javascript:fnCallingCust(' + i + ')"' + (row.cb_telnum == "" || editYn == "N" ? "disabled" : "disabled") + '>전화걸기</button>';	// 버튼상태 일단 비활성
			innerHtml += '		</div>';
			innerHtml += '		<div class="col-auto">';
			innerHtml += '			<button type="button" class="btn btn-warning btn-md btn-rounded" id="btn_call_' + (row.cb_telnum == "" || editYn == "N" ? "complete_" : "") + 'stop_' + i + '" onclick="javascript:fnCallStop(' + i + ')" ' + (row.cb_telnum == "" || editYn == "N" ? "disabled" : "disabled") + '>전화끊기</button>';	// 버튼상태 일단 비활성
			innerHtml += '		</div>';
			innerHtml += '		<div class="col width70px ver-line">콜백전달</div>';
			innerHtml += '		<div class="col width120px">';
			innerHtml += '			<select class="form-control"  id="org_code_' + i + '" name="org_code_' + i + '" onchange="javascript:fnCenterChange(' + i + ')"' + ((row.cb_telnum != "" && editYn == "Y") || addRow ? "" : "readonly") + '>';
			innerHtml += '				<option value="">- 센터선택 -</option>';
			for(var j =0; j < orgList.length; j++) {
				var item = orgList[j];
				innerHtml += '								<option value="' + item.org_code + '">' + item.org_name + '</option>';
			}
			innerHtml += '			</select>';
			innerHtml += '		</div>';
			innerHtml += '		<div class="col width120px">';
			innerHtml += '			<select class="form-control" id="mem_no_' + i + '" name="mem_no_' + i + '" onchange="javascript:fnMemChange(' + i + ')"' + ((row.cb_telnum != "" && editYn == "Y") || addRow ? "" : "readonly") + '>';
			innerHtml += '				<option value="">- 직원선택 -</option>';
			for(var k =0; k < memList.length; k++) {
				var item = memList[k];
				innerHtml += '								<option value="' + item.mem_no + '">' + item.mem_name + '</option>';
			}
			innerHtml += '			</select>';
			innerHtml += '		</div>';
			innerHtml += '		<div class="col-auto">';
			innerHtml += '			<button type="button" class="btn btn-outline-primary" onclick="javascript:sendPaper(' + listCnt + ');" ' + ((row.cb_telnum != "" && editYn == "Y") || addRow ? "" : "disabled") + '>쪽지발송</button>';
			innerHtml += '		</div>';
			innerHtml += '		<div class="col width200px" id="paper_info_' + i + '">' + row.paper_info + '</div>';
			innerHtml += '		<div class="col width70px ver-line">녹취파일</div>';
			innerHtml += '		<div class="col-auto">';
			if(row != undefined && row.rec_url != '') {
				if(row.end_store_yn == 'N') {
					if(row.file_seq != '0') {
						innerHtml += '			<a href="javascript:fnOpenFileViewerPanel(' + row.file_seq + ',\'' + row.ars_mem_no + '\');" class="text-primary">';
					} else {
						innerHtml += '			<a href="javascript:fnWindowOpen(\'' + row.rec_url  + '\');" class="text-primary">';
					}
					innerHtml += '				'+ row.vls_fname;
					innerHtml += '			</a>';
				} else {
					innerHtml += '장기보관';
				}
			}
			innerHtml += '		</div>';
			innerHtml += '	</div>';

			innerHtml += '	<div class="mt5">';
			innerHtml += '		<textarea class="form-control" placeholder="상담내용이 들어갑니다." style="height: 100px;"   id="consult_text_' + i + '" name="consult_text_' + i + '"' + (completeYn == "N" && editYn == "Y" ? "" : "readonly") + '>' + row.consult_text + '</textarea>';
			innerHtml += '	</div>';

			innerHtml += '</td>';
			innerHtml += '</tr>';
			$('#consultTable > tbody:last').prepend(innerHtml);

			if((row.call_cticonkey == 'N' | row.call_cticonkey == '') && row.cb_gkcid == '' && completeYn != 'Y') {
				$M.setValue("call_gr_cd_" + i, row.call_gr_cd);
				fnChangeRowGubun(i);
			}

			$M.setValue("call_telnum_" + i, ($M.phoneFormat($M.getValue("call_telnum_" + i))));
			$M.setValue("cb_telnum_" + i, ($M.phoneFormat($M.getValue("cb_telnum_" + i))));

			if(showCallBtn == false) {
				$("[id^='btn_cti']").css("visibility", "hidden");
				$("[id^='btn_call']").css("visibility", "hidden");
			}
		}

		function goModifyRow(index) {
			var param = {
				ars_seq : $M.getValue("ars_seq_" + index),
				ars_mem_no : $M.getValue("ars_mem_no_" + index),
				call_svc_cd : $M.getValue("call_svc_cd_" + index),
				call_gr_cd : $M.getValue("call_gr_cd_" + index),
				cust_no : $M.getValue("cust_no"),
				consult_text : $M.getValue("consult_text_" + index),
			}

			$M.goNextPageAjaxModify(this_page + "/modify", $M.toGetParam(param), {method : 'post'},
					function(result) {
						if(result.success) {
							alert("처리가 완료되었습니다.");
						};
					}
			)
		}

		// 2025-02-25 황빛찬 (Q&A:24773) ARS 상담내용 삭제 불가능하도록 요청 적용
		// function goRemoveRow(index) {
		// 	if($M.getValue("ars_seq_" + index) == '0') {
		// 		// 저장을 하지않은 상담추가인 경우
		// 		$('th[id="ars_consult_cnt_' + index + '"').parent().remove();
		// 		fnSetRowCnt();
		// 	} else {
		// 		// 저장된 상담인 경우
		// 		var param = {
		// 			ars_seq : $M.getValue("ars_seq_" + index),
		// 		}
		//
		// 		$M.goNextPageAjaxRemove(this_page + "/remove", $M.toGetParam(param), {method : 'post'},
		// 				function(result) {
		// 					if(result.success) {
		// 						$('th[id="ars_consult_cnt_' + index + '"').parent().remove();
		// 						alert("처리가 완료되었습니다.");
		// 						fnSetRowCnt();
		// 					};
		// 				}
		// 		)
		// 	}
		// }

		function fnCenterChange(index) {
			var orgCode = $M.getValue("org_code_" + index);

			if(orgCode == "") {
				$("#mem_no_"+index).prop("disabled", false);
			} else {
				$("#mem_no_"+index).prop("disabled", true);
			}
		}

		function fnMemChange(index) {
			var memNo = $M.getValue("mem_no_" + index);

			if(memNo == "") {
				$("#org_code_"+index).prop("disabled", false);
			} else {
				$("#org_code_"+index).prop("disabled", true);
			}
		}

		function sendPaper(index) {
			var memNo = $M.getValue("mem_no_" + index);
			var orgCode = $M.getValue("org_code_" + index);

			if(memNo == "" && orgCode == "") {
				alert("쪽지를 발송할 인원 또는 부서를 선택해주세요.");
				return;
			}

			var param = {
				send_mem_no : memNo,
				send_org_code : orgCode,
				send_org_name : jQuery('#org_code_' + index + ' option:checked').text(),
				consult_text : $M.getValue("consult_text_" + index),
				cust_name : $M.getValue("cust_name"),
				hp_no : $M.getValue("cb_telnum_" + index),
				ars_seq : $M.getValue("ars_seq_" + index),
				pop_param : '${inputParam.ctrl_query_string}',
			}

			$M.goNextPageAjaxMsg("쪽지를 발송하시겠습니까?",this_page + "/sendPaper", $M.toForm(param), {method : 'post'},
				function(result) {
					if(result.success) {
						alert("쪽지가 발송되었습니다.");
						jQuery('#paper_info_' + index).text(result.paper_info);
					};
				}
			)
		}

		function fnSetRowCnt() {
			// 전체 상담 row수를 확인하여 상담내용 1 ~ length까지 재명명
			var totalList = $('th[id^="ars_consult_cnt"]');

			for(var i = 0; i < totalList.length; i++) {
				$('#'+totalList[i].id).text('상담내용 ' + (totalList.length - i));
			}
		}

		function goSave(index) {
			var param;
			var sendJson;
			if(index == undefined) {
				// 전체저장
				if($('tr[id^="ars_contents"]').length == 0) {
					alert("저장할 상담이 없습니다.");
					return;
				}

				var arsArr = [];
				// 콜백이 하나라도 있는 경우
				// 기존에 있는 모든 콜백들을 전부 처리완료로 만들기 위해 플래그 설정
				var callBackYn = false;

				//테이블에서 한개씩 선택해서 배열에 넣기
				$('tr[id^="ars_contents"]').each(function () {
					var ars = {};
					var tr = $(this);
					var td = tr.children();
					if(td.find('[id^="edit_yn"]').val() != "Y") {
						return ;
					}

					ars.ars_seq = td.find('[id^="ars_seq"]').val();
					ars.ars_dt = $M.dateFormat($M.removeDateFormat(td.find('[id^="ars_date"]').val()), 'yyyyMMdd');
					ars.send_no = $M.removeHyphenFormat(td.find('[id^="send_no"]').val());
					ars.cti_conkey = td.find('[id^="call_cticonkey"]').val();
					ars.consult_text = td.find('[id^="consult_text"]').val();
					ars.cb_gkcid = $M.removeHyphenFormat(td.find('[id^="cb_gkcid"]').val());
					ars.call_svc_cd = td.find('[id^="call_svc_cd"]').val();
					ars.call_gr_cd = td.find('[id^="call_gr_cd"]').val();
					if(ars.cb_gkcid != "") {
						callBackYn = true;
					}

					arsArr.push(ars);
				});

				if(arsArr.length == 0) {
					alert("모든 상담이 처리완료되어 저장할 내역이 없습니다.");
					return;
				}

				param = {
					ars_mem_no : '${SecureUser.mem_no}',
					cust_no : $M.getValue("cust_no"),
					complete_yn : $M.getValue("complete_yn") == "Y" ? "Y" : "N",
					callback_complete_yn : callBackYn && ($M.getValue("complete_yn") == "Y") ? "Y" : "N",
					p_hp_no : '${inputParam.hp_no}'		<%-- 페이지에서 넘어온 전화번호 --%>
				}

				arsArr.push(param);

				sendJson = $M.jsonArrayToForm(arsArr.reverse());
			} else {
				// 단일 row 저장
				param = {
					ars_seq : $M.getValue("ars_seq_" + index),
					ars_dt : $M.dateFormat($M.removeDateFormat($M.getValue("ars_date_" + index)), 'yyyyMMdd'),
					reg_date : $M.getValue("ars_date_" + index),
					ars_mem_no : $M.getValue("ars_mem_no_" + index),
					cust_no : $M.getValue("cust_no"),
					consult_text : $M.getValue("consult_text_" + index),
					cti_conkey : $M.getValue("call_cticonkey_" + index),
					send_no : $M.removeHyphenFormat($M.getValue("send_no_" + index)),
					call_svc_cd : $M.getValue("call_svc_cd_" + index),
					call_gr_cd : $M.getValue("call_gr_cd_" + index),
				}

				sendJson = $M.toGetParam(param);
			}

			$M.goNextPageAjaxSave(this_page + "/save", sendJson, {method : 'post'},
					function(result) {
						if(result.success) {
							alert("처리가 완료되었습니다.");
							if(index != undefined) {
								$("#ars_seq_"+index).val(result.ars_seq);
								$("#modify_btn_"+index).text("수정");
							} else {
								goSearch();
							}
						};
					}
			)
		}

		function fnWindowOpen(recUrl) {
			window.open(recUrl, target="_blank", "width=400, height=400");
		}

		function fnClose() {
			window.close();
		}

		////////////////////////////////////////////////////////////////////////////////////
		////////////////  CTI 관련 메소드  ///////////////////
		////////////////////////////////////////////////////////////////////////////////////

		/**
		 * 로딩바제어 (동작안함..)
		 * @param show true:보이기, false:감추기
		 */
		function fnLoadingBar(show) {
			if(show) {
				top.$('#popup-bg-loading').show();
				top.$('#bowlG').show();
			} else {
				top.$('#popup-bg-loading').hide();
				top.$('#bowlG').hide();
			}
		}

		function fnCalling() {
			opener.fnCalling($M.getValue("input_hp_no"));
		}

		function fnCallingCust(index) {
			opener.fnCalling($M.removeHyphenFormat($M.getValue("cb_telnum_"+index)));
		}

		function fnCallReceive() {
			alert('전화받기입니다.');
		}

		function fnCallStop() {
			opener.fnCallStop();
		}

		function fnTransAg(agId) {
			alert(agId + ' 호전환 전환자 선택했습니다.');
		}

		function fnTransTry() {
			alert('전환시도입니다.');
		}

		function fnTransOK() {
			alert('전환완료입니다.');
		}

		function fnTransCancel() {
			alert('전환취소입니다.');
		}

		function fnChangeStatus() {
			var changeStatusCd = $M.getValue('change_status');
			if(changeStatusCd == '') {
				alert('변경할 상태를 선택하세요.');
				return;
			}

			// WAIT(2, 인대기), NO(전화불가), 3: 후처리
			var currentStatusCd = opener.cti.statusCd == '2' ? 'WAIT' : 'NO';

			if(currentStatusCd == changeStatusCd) {
				alert('현재 상태와 변경하려고 하는 상태가 동일합니다.');
				return;
			}
			opener.fnChangeStatusValue(changeStatusCd);
		}
		//////////////////////////////////////////////////////
		//////// 하위는 CTI 업체에서 제공해주는 Method  Start /////
		//////////////////////////////////////////////////////
		function RT_NTSCTIOpen_EVT() {
			console.log("cti gw 접속 성공");
		}

		function RT_NTSCTIClose_EVT(evt) {
			console.log("cti gw 접속 종료 : " + evt.code);
			fnLoadingBar(false);
		}

		/*  전화걸기 , 전화끊기등 1차 결과 성공시   */
		function RT_NTSCTICOMSUCC_EVT(txt_rtnnm, txt_rtncd) {
			var log = "RT_NTSCTICOMSUCC_EVT =>";
			log = log + "EVENT명 : " + txt_rtnnm + ",";
			log = log + "EVENT결과 : " + txt_rtncd + ",";

			console.log(log);
		}

		/* 전화 통화 연결 되었을때  */
		function RT_NTSCTICONINFO_EVT(txt_CON_CALLER_ID, txt_CON_CALLCONNECT_KEY, txt_CON_CALLINOB, txt_CON_CALLTYPE) {
			var log = "RT_NTSCTICONINFO_EVT =>";
			log = log + "전화번호 : " + txt_CON_CALLER_ID + ",";
			log = log + "연결키 : " + txt_CON_CALLCONNECT_KEY + ",";
			log = log + "콜종류 : " + txt_CON_CALLINOB + ",";
			log = log + "콜구분 : " + txt_CON_CALLTYPE + ",";

			console.log(log);
		}

		/* 전화 올때   */
		function RT_NTSCTIRINGINFO_EVT(txt_CID, txt_ARSGROUP_NM, txt_ARSSVC_NM, txt_WAITTIME, txt_DNIS_NM, txt_ARSCID, txt_ETC_ARS_1, txt_ETC_ARS_2, txt_ETC_ARS_3, txt_CONNECTKEY, txt_ENC_1, txt_ENC_2, txt_SP_GROUP_CODE,
									   txt_SP_SVC_CODE, txt_AG_DEGREE, txt_GK_ETC_INFO, txt_AG_TOTTIME, txt_CTI_DNIS_CD, txt_CTI_DNIS_NM, txt_RING_CALLTYPE, txt_RING_INOB, txt_RING_SPYN, txt_ETC_TEL
		) {
			var log = "RT_NTSCTIRINGINFO_EVT =>";
			log = log + "txt_CID : " + txt_CID + ",";
			log = log + "txt_ARSGROUP_NM : " + txt_ARSGROUP_NM + ",";
			log = log + "txt_ARSSVC_NM : " + txt_ARSSVC_NM + ",";
			log = log + "txt_WAITTIME : " + txt_WAITTIME + ",";
			log = log + "txt_DNIS_NM : " + txt_DNIS_NM + ",";
			log = log + "txt_ARSCID : " + txt_ARSCID + ",";
			log = log + "txt_ETC_ARS_1 : " + txt_ETC_ARS_1 + ",";
			log = log + "txt_ETC_ARS_2 : " + txt_ETC_ARS_2 + ",";
			log = log + "txt_ETC_ARS_3 : " + txt_ETC_ARS_3 + ",";
			log = log + "txt_CONNECTKEY : " + txt_CONNECTKEY + ",";
			log = log + "txt_ENC_1 : " + txt_ENC_1 + ",";
			log = log + "txt_ENC_2 : " + txt_ENC_2 + ",";
			log = log + "txt_SP_GROUP_CODE : " + txt_SP_GROUP_CODE + ",";
			log = log + "txt_SP_SVC_CODE : " + txt_SP_SVC_CODE + ",";
			log = log + "txt_AG_DEGREE : " + txt_AG_DEGREE + ",";
			log = log + "txt_GK_ETC_INFO : " + txt_GK_ETC_INFO + ",";
			log = log + "txt_AG_TOTTIME : " + txt_AG_TOTTIME + ",";
			log = log + "txt_CTI_DNIS_CD : " + txt_CTI_DNIS_CD + ",";
			log = log + "txt_CTI_DNIS_NM : " + txt_CTI_DNIS_NM + ",";
			log = log + "txt_RING_CALLTYPE : " + txt_RING_CALLTYPE + ",";
			log = log + "txt_RING_INOB : " + txt_RING_INOB + ",";
			log = log + "txt_RING_SPYN : " + txt_RING_SPYN + ",";
			log = log + "txt_ETC_TEL : " + txt_ETC_TEL + ",";

			console.log(log);
		}

		/* 전화 할때   */
		function RT_NTSCTIDIALNFO_EVT(txt_CID) {
			var log = "RT_NTSCTIDIALNFO_EVT =>";
			log = log + "txt_CID : " + txt_CID + ",";

			console.log(log);
		}

		/* 전화 종료   */
		function RT_NTSCTIDROPNFO_EVT(etc) {
			var log = "RT_NTSCTIDROPNFO_EVT =>";
			log = log + "etc : " + etc + ",";

			console.log(log);
		}

		/* CTI 상태값 Recv - 1초에 한번씩 RECV : 상태변경,전화상태을 표시 */
		function RT_NTSCTICOMMINFO_EVT(txt_AGSTATE, txt_TELSTATE, txt_USER_USE_TIME, txt_USER_WAITCALLCNT, txt_SEND_TIME, txt_AGSTATE_CD, txt_CB_CNT, txt_ETC_CNT_1, txt_ETC_CNT_2, txt_ETC_CNT_3) {
			var log = "RT_NTSCTICOMMINFO_EVT =>";
			log = log + "상담원상태 : " + txt_AGSTATE + ",";
			log = log + "전화기상태 : " + txt_TELSTATE + ",";
			log = log + "사용시간 : " + txt_USER_USE_TIME + ",";
			log = log + "접속시간 : " + txt_SEND_TIME + ",";
			log = log + "상담원상태코드: " + txt_AGSTATE_CD + ",";
			log = log + "대기호 : " + txt_USER_WAITCALLCNT + ",";
			log = log + "콜백 : " + txt_CB_CNT + ",";
			log = log + "기타1 : " + txt_ETC_CNT_1 + ",";
			log = log + "기타2 : " + txt_ETC_CNT_2 + ",";
			log = log + "기타3 : " + txt_ETC_CNT_3 + ",";

			console.log(log);

			var disTime = '';	//20230821 180341
			if(txt_SEND_TIME.length == 14) {
				disTime = txt_SEND_TIME.substring(8, 10) + ':' + txt_SEND_TIME.substring(10, 12) + ':' + txt_SEND_TIME.substring(12, 14);
			}

			$('#la_txt_AGSTATE').html(txt_AGSTATE);
			$('#la_txt_SEND_TIME').html(disTime);
		}
		//////////////////////////////////////////////////////
		//////// 여기까지 CTI 업체에서 제공해주는 Method End  /////
		//////////////////////////////////////////////////////


			// 업무접수현황 등록팝업 호출
		function goSelfAssign(){
			var popupOption = "";
			var params = {
				"s_popup_yn": "Y",
				"s_cust_no": "${custInfo.cust_no}"
			};
			$M.goNextPage('/mmyy/mmyy0114p01', $M.toGetParam(params), {popupStatus: popupOption});
		}

		// 2025-02-25 황빛찬 (Q&A:24773) ARS 상담녹취 상담자 본인, 서비스관리, 서비스부서장만 허용
		function fnOpenFileViewerPanel(fileSeq, arsMemNo) {
			if ("${SecureUser.mem_no}" == arsMemNo || '${page.fnc.F05123_001}' == 'Y') {
				openFileViewerPanel(fileSeq)
			} else {
				alert("본 상담건의 상담자만 녹취파일을 확인 할 수 있습니다.");
			}
		}
	</script>
</head>
<body>
<form id="main_form" name="main_form">
	<!-- 팝업 -->
	<div class="popup-wrap width-100per">
		<!-- 메인 타이틀 -->
		<div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
		</div>
		<!-- /메인 타이틀 -->
		<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="title-wrap">
				<h4 class="primary">ARS상담정보</h4>
			</div>
			<!-- 기본 -->
			<div class="ars-bg login" style="height: 60px;">
				<select class="form-control" id="calling_hp_no" name="calling_hp_no">
				</select>
				<strong>${empty custInfo.cust_name ? '고객정보없음' : custInfo.cust_name }님</strong>
				&nbsp;&nbsp;
				<button type="button" class="btn btn-success btn-md" id="btn_cti_call" onclick="javascript:fnCalling();" disabled="disabled">전화걸기</button>
				<button type="button" class="btn btn-warning btn-md" id="btn_cti_call_stop" onclick="javascript:fnCallStop();" disabled="disabled">전화끊기</button>
				<div id="login_gubun_1">&nbsp;&nbsp; | &nbsp;&nbsp;</div>
				<div id="la_call_status" class="text-primary">전화상태 체크 중입니다.</div>
				<div id="login_gubun_2">&nbsp;&nbsp; | &nbsp;&nbsp;</div>
				<div class="mr5" id="change_label">상태설정</div>
				<select  id="change_status" name="change_status" class="form-control mr5" style="flex-basis: 100px;" onchange="javascript:opener.$M.setValue('change_status', this.value);">
					<option value="">- 상태선택 -</option>
					<option value="WAIT">전화대기</option>
					<option value="NO">전화불가</option>
				</select>
				<button id="btn_change_status" type="button" class="btn btn-outline-primary" onclick="javascript:fnChangeStatus();">변경</button>
				<div style="display: none;font-size: medium;font-weight:bold; color: red" id="show_call_div">전화걸기/받기 기능을 사용하려면, ARS상담화면에서 진입하세요.</div>
			</div>
			<div class="mt10">
				<table class="table-border mt5">
					<colgroup>
						<col width="120px">
						<col width="">
						<col width="120px">
						<col width="">
						<col width="120px">
						<col width="">
					</colgroup>
					<tbody>
					<tr>
						<th class="text-right">수신전화번호</th>
						<td>
							<input type="text" class="form-control width120px" id="input_hp_no" name="input_hp_no" format="phone" readonly value="${inputParam.hp_no}">
						</td>
						<th class="text-right">고객명</th>
						<td>
							<div class="form-row inline-pd pr">
								<div class="col width130px">
									<input type="text" class="form-control" id="cust_name" name="cust_name" value="${empty custInfo.cust_name ? '고객정보없음' : custInfo.cust_name}" readonly>
								</div>
								<div class="col width80px">
									<input type="hidden" name="__s_cust_no" value="${custInfo.cust_no}">
									<input type="hidden" name="__s_hp_no" value="${custInfo.hp_no}">
									<input type="hidden" name="__s_cust_name" value="${custInfo.cust_name}">
									<c:if test="${not empty custInfo.cust_no}">
										<jsp:include page="/WEB-INF/jsp/common/commonCustJob.jsp">
											<jsp:param name="jobType" value="C"/>
											<jsp:param name="li_type" value="__cust_dtl#__have_machine_cust#__ledger#__cust_rental_history#__sms_popup#__check_required"/>
										</jsp:include>
									</c:if>
								</div>
								<c:if test="${not empty custInfo.cust_no}">
									<div class="col width120px">
										담당 : ${custInfo.center_org_name}
									</div>
								</c:if>
							</div>
						</td>
						<th class="text-right">미수금</th>
						<td>
							<div class="form-row inline-pd">
								<div class="col width130px">
									<input type="text" class="form-control text-right" id="ed_misu_amt" name="ed_misu_amt" format="num" id="misu_amt" value="${custInfo.ed_misu_amt}" readonly>
								</div>
								<div class="col width22px">원</div>
							</div>
						</td>
					</tr>
					<tr>
						<th class="text-right">휴대폰(장비소유자)</th>
						<td>
							<input type="text" class="form-control width120px" id="own_hp_no" name="own_hp_no" format="phone" value="${custInfo.hp_no}" readonly>
						</td>
						<th class="text-right">휴대폰(장비관리자)</th>
						<td>
							<input type="text" class="form-control width120px" id="mng_hp_no" name="mng_hp_no" format="phone" value="${custInfo.mng_hp_no}" readonly>
						</td>
						<th class="text-right">휴대폰(장비운영자)</th>
						<td>
							<input type="text" class="form-control width120px" id="driver_hp_no"  name="driver_hp_no" format="phone" value="${custInfo.driver_hp_no}" readonly>
						</td>
					</tr>
					<tr>
						<th class="text-right">고객등급</th>
						<td>
							<div class="form-row inline-pd">
								<div class="col-3">
									<input type="text" class="form-control" value="${custInfo.cust_grade_cd_str}" readonly>
								</div>
								<div class="col-9">
									<input type="text" class="form-control" value="${custInfo.cust_grade_name_str}" readonly>
								</div>
							</div>
						</td>
						<th class="text-right">주소</th>
						<td colspan="3">
							<div class="form-row inline-pd">
								<div class="col-6">
									<input type="text" class="form-control" value="${custInfo.addr1}" readonly>
								</div>
								<div class="col-6">
									<input type="text" class="form-control" value="${custInfo.addr2}" readonly>
								</div>
							</div>
						</td>
					</tr>
					</tbody>
				</table>
			</div>

			<!-- 검색영역 -->
			<div class="search-wrap mt10">
				<table class="table">
					<colgroup>
						<col width="70px">
						<col width="270px">
						<col width="100px">
						<col width="100px">
						<col width="50px">
						<col width="70px">
						<col width="70px">
						<col width="">
						<col width="60px">
					</colgroup>
					<tbody>
					<tr>
						<th>조회기간</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width115px">
									<div class="input-group">
										<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateFormat="yyyy-MM-dd" value="${searchDtMap.s_start_dt}" alt="시작일자" >
									</div>
								</div>
								<div class="col width16px text-center">~</div>
								<div class="col width110px">
									<div class="input-group">
										<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateFormat="yyyy-MM-dd" value="${searchDtMap.s_end_dt}" alt="종료일자">
									</div>
								</div>
								<jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp">
									<jsp:param name="st_field_name" value="s_start_dt"/>
									<jsp:param name="ed_field_name" value="s_end_dt"/>
									<jsp:param name="click_exec_yn" value="Y"/>
									<jsp:param name="exec_func_name" value="goSearch();"/>
								</jsp:include>
							</div>
						</td>
						<td>
							<select class="form-control" id="s_gubun_1" name="s_gubun_1" onchange="javascript:fnChangeGubun();">
							</select>
						</td>
						<td>
							<select class="form-control" id="s_gubun_2" name="s_gubun_2">
								<option value="">구분 2 전체</option>
							</select>
						</td>
						<td>
							<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
						</td>
						<td>
							<button type="button" class="btn btn-outline-primary" style="width: 70px;" onclick="javascript:fnAddRows();">상담추가</button>
						</td>
						<td>
							<button type="button" class="btn btn-outline-primary" style="width: 70px;" onclick="javascript:goSelfAssign();">접수추가</button>
						</td>
						<td class="pl10 text-right">
							<div class="form-check form-check-inline">
								<input class="form-check-input" type="checkbox" id="complete_yn" name="complete_yn" value="Y">
								<label for="complete_yn" class="form-check-label">처리완료</label>
							</div>
						</td>
						<td>
							<button type="button" class="btn btn-info" style="width: 50px;" onclick="javascript:goSave();">저장</button>
						</td>
					</tr>
					</tbody>
				</table>
			</div>
			<!-- /검색영역 -->
			<div>
				<table class="table-border mt10" id="consultTable">
					<colgroup>
						<col width="120px">
						<col>
					</colgroup>
					<tbody id="consultList">
					</tbody>
				</table>
			</div>
			<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">
				<div class="right"><%-- 버튼위치는 pos param 에 따라 나옴 (없으면 기본 상단나옴) T_CODE.CODE_VALUE='BTN_POS' 참고 --%>
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
			<!-- /그리드 서머리, 컨트롤 영역 -->
		</div>
	</div>
	</div>
	<!-- /contents 전체 영역 -->
	</div>
</form>
</body>
</html>