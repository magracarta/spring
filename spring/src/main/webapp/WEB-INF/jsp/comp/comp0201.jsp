<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 메인 > 문자발송 > null > 문자발송
-- 작성자 : 박준영
-- 최초 작성일 : 2020-10-05 10:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var maxBytes, inputBytes;
		var smsMode = 'SMS';
		var sendYn = "";

		var hpRegex  = /^(?:(010-?\d{4})|(01[1|6|7|8|9]-?\d{3,4}))-?(\d{4})$/;
		var auiGridTop;
		var auiGridBottom;
		var isGroupSend = false;
		var caretPos;
		var commercialBytes = 33;

		//SMS전송대상 ( 참조로 가져온 경우)
		var reqSendTargetList = "";
		// SMS전송대상 ( 배열 )
		var phoneNoArr = [];
		var receiverNameArr = [];
		var refKeyArr = [];
    
    // 단체 발송 최대 인원 수
    var maxGroupSize = 1000;

		$(document).ready(function() {

			// 발송대상 참조인 경우 ( 발송대상을 가져와서 세팅함)
			if ( '${inputParam.req_sendtarger_yn}' == 'Y' ) {
				createAUIGridReq();
				fnSetReqSmsTargetList();
			}

			// SMS 전송타입이 마케팅인경우
			if ( '${inputParam.sms_send_type_cd}' == 'M' ) {
				fnSetMarketingFix();
			}

			fnChangeSmsMode(smsMode);
			fnSetSpecialChar();
			createAUIGridTop();
			createAUIGridBottom();
			if ('${inputParam.hp_no}'.split("^").length > 1) {
				var nameArr = '${inputParam.name}'.split("^");
				var hpArr = '${inputParam.hp_no}'.split("^");
				var result = [];
				for (var i = 0; i < nameArr.length; ++i) {
					var obj = new Object();
					obj.name = nameArr[i];
					obj.hp_no = hpArr[i];
					result.push(obj);
				}
				AUIGrid.setGridData(auiGridTop, result);
				fnUpdateCnt(auiGridTop);
			} else {
				var param = {
					indi_name : "${inputParam.name}" == "" ? "${templateInfo.cust_name}" : "${inputParam.name}",
					indi_hp_no : "${inputParam.hp_no}" != "" ? $M.phoneFormat("${inputParam.hp_no}") : "${templateInfo.cust_hp_no}",
				}

				var callBack = "${inputParam.callback}";
				if(callBack != "") {
					param.callback = "${inputParam.callback}";
					param.callback_no = "${inputParam.callback}";
					if("${inputParam.msg}" != "") {
						param.msg = "${inputParam.msg}";
					}

					// callbackReadOnlyYN 없으면 readonly
					$("#callback").prop("disabled", "${inputParam.callbackReadOnlyYN}" == "N" ? false : true);
					$("#reserve_yn").prop("disabled", true);
					$("#send_purpose_bm_b").prop("disabled", true);
					$("#send_purpose_bm_m").prop("disabled", true);

					fnChangeSmsMode('LMS');
				}

				$M.setValue(param);
			}

			if ("${inputParam.hp_no}".indexOf("^") != -1) {
				fnToggleTarget('group');
			}

		});

		// 특수문자 입력 팝업
		function fnOpenSpecialCharPopup() {
			caretPos = $('#msg').prop("selectionStart");
			$M.goNextPageLayerDiv('open_layer_specialChar');
		}


		// 셀렉트박스 변경시 처리 ( 발신번호 )
		function fnChangeCallBackNo(obj){
			console.log(obj);
			$M.setValue("callback_no", obj);
		}

		function fnChangeReserve(obj){
			// 체크여부 확인
			if($(obj).is(":checked") == true) {
				$(obj).val("Y");
				$("#send_dt").attr("disabled", false); 		//활성화
				$("#send_hour").attr("disabled", false); 	//활성화
				$("#send_minute").attr("disabled", false); 	//활성화
				if( $M.getValue("send_dt") == "" ){
					$M.setValue("send_dt","${inputParam.s_current_dt}" );
				}
			}
			else{
				$(obj).val("N");
				$("#send_dt").attr("disabled", true); 		//비활성화
				$("#send_hour").attr("disabled", true); 	//비활성화
				$("#send_minute").attr("disabled", true); 	//비활성화
			}
		}

		//발송대상 참조인경우
		function fnSetReqSmsTargetList(){
			try
			{
				//1.발송처리 화면 숨김 및 발송대상 참조 화면 보이기
				$("#div_single_send").hide();
				$("#div_group_send").hide();
				$("#div_req_send").show();

				//2.참조정보가져오기 ( 발송대상자 )
				console.log("부모창의 데이터 : ", opener.reqSendTargetList());
				reqSendTargetList = opener.reqSendTargetList();

			 	// 화면에 보여지는 그리드 데이터 목록
				if(reqSendTargetList.length < 1 ){
					alert("참조된  고객정보가 없습니다.");
					return;
				}

			 	for(i=0; i<reqSendTargetList.length; i++ ){

			 		if(AUIGrid.isUniqueValue(auiGridReq, "phone_no", reqSendTargetList[i].phone_no)){
						var item = new Object();
						item = {
								phone_no : reqSendTargetList[i].phone_no,
								receiver_name : reqSendTargetList[i].receiver_name,
								ref_key :  reqSendTargetList[i].ref_key
						}
						AUIGrid.addRow(auiGridReq, item, 'last');
					}
			 	}

			 	$("#auiGridReq").resize();
				$("#req_total_cnt").html(reqSendTargetList.length);

			}
			catch (e) {
			  	alert("고객정보를 참조할 수 없습니다.");
			  	window.close();
			}
		}

		// 파라미터 - SMS 전송타입이 마케팅인경우
		function fnSetMarketingFix() {
			//SMS TYPE ( 장문 - 기본)
			smsMode = 'LMS';
			$("input:radio[name='send_purpose_bm']:radio[value='M']").prop('checked', true);
			$("input:radio[name='send_purpose_bm']").prop('disabled', true);

		}

		// 발송
		function goSend() {

			var frm = document.main_form;

		  	// validation check
	     	if($M.validation(frm) === false) {
	     		return;
	     	};

	     	//SMS전송메세지(공통)
			var msg = $("#msg").val();												//발신메세지

			var purposeBm = $("input:radio[name=send_purpose_bm]:checked").val();  	//발신목적
			var reqFileCnt = 0;														//첨부파일수량
			var callbackNo = $M.getValue("callback_no");							//발신번호

			var sendDate= "";														//전송일시
			var sendDt = $M.getValue("send_dt");
			var sendHour = $M.getValue("send_hour");
			var sendMinute = $M.getValue("send_minute");
			var reserveYn = $M.getValue("reserve_yn");

			if (reserveYn == "Y"){
				if ( sendDt != "" ){
					if (sendDt < "${inputParam.s_current_dt}" ){
						alert("예약일자는 오늘날짜부터 지정 가능합니다.");
						return;
					}
					sendDate =  sendDt + sendHour + sendMinute + "00";
				}
				else {
					alert("예약발송을 선택한 경우 예약일자는 필수값입니다.");
					return;
				}
			}
			var smsTypeSlm =  $M.getValue("sms_type_slm");							//SMS타입
			var smsSendTypeCd = $M.getValue("sms_send_type_cd");					//SMS전송타입코드


			//발송대상 배열 초기화
			phoneNoArr = [];
			receiverNameArr = [];
			refKeyArr = [];


			// 발송대상 참조인 경우 ( 발송대상은 부모창에서 가져온 값)
			if ( '${inputParam.req_sendtarger_yn}' == 'Y' ) {
				try
				{
					var gridAllReqList = AUIGrid.getGridData(auiGridReq);
					if(gridAllReqList.length < 1 ){
						alert("선택된 고객정보가 없습니다.");
						return;
					}

					for (var i = 0; i < gridAllReqList.length; i++) {
						phoneNoArr.push(gridAllReqList[i].phone_no);
						receiverNameArr.push(gridAllReqList[i].receiver_name);
						refKeyArr.push(gridAllReqList[i].ref_key);
					}
				}
				catch (e) {
				  	alert("고객정보를 가져올 수 없습니다.");
				  	return;
				}
			}
			else {

				//발송대상 참조가 아닌경우  - 단일전송,그룹전송 여부에 따라 분기
				if (isGroupSend){	//단체발송
          
				 	// 화면에 보여지는 그리드 데이터 목록
					var gridAllTopList = AUIGrid.getGridData(auiGridTop);
          if(gridAllTopList.length > maxGroupSize) {
            alert("단체발송 최대 인원은 1000명 입니다.");
            return;
          }
          
					if(gridAllTopList.length < 1 ){
						alert("선택된 고객정보가 없습니다.");
						return;
					}

					for (var i = 0; i < gridAllTopList.length; i++) {
						phoneNoArr.push(gridAllTopList[i].phone_no);
						receiverNameArr.push(gridAllTopList[i].receiver_name);
						refKeyArr.push(gridAllTopList[i].ref_key);
					}
				}
				else{		//개별발송
					var indiName = $M.getValue("indi_name");
					var indiHpNo = $M.getValue("indi_hp_no");
					var indiRefKey = $M.getValue("indi_ref_key");

					if(indiName == ""){
						alert("이름을 입력해주세요.");
						return;
					}
					if(indiHpNo == "" ){
						alert("수신번호를 입력해주세요");
						return;
					}

					smsSendTypeCd = "3";	//개별발송은 주소록



					phoneNoArr.push(indiHpNo);
					receiverNameArr.push(indiName);
					refKeyArr.push(indiRefKey == "" ? indiHpNo : indiRefKey);		//개별발송인데  참조키 없는경우 : 참조키 = 전화번호
				}
			}


			// SMS전송파일  ( MMS전송일때만  사용 )
			var fileUrlArr = [];
			var fileSeqNoArr = [];

			var sendType = $M.getValue("sendType");
			if (smsTypeSlm == "M") {

				var gridBottom = AUIGrid.getGridData(auiGridBottom);
	    		var gridBottomCnt = gridBottom.length;
		    	if (gridBottomCnt > 3){
		    		alert("첨부파일 제한수량을 초과하였습니다. (최대 3개까지 가능 )");
		    		return;
		    	}

		    	var totalSize = 0;
		    	for(var i in gridBottom) {
		    		totalSize += $M.toNum(gridBottom[i].file_size);

		    		if ("JPG" != gridBottom[i].file_ext.toUpperCase()) {
		    			alert("jpg만 첨부가능합니다.");
				    	return false;
		    		}
		    	}

				// 2024-09-04 황빛찬 (Q&A:23925) MMS 첨부파일 총 용량 300KB -> 1024KB로 수정
				// SMS AGENT에서 300KB로 제한하고있어서 우선 다시 300KB로 적용
		    	if (totalSize > 300) {
			    	alert("최대 용량 300KB를 초과하였습니다.");
			    	return false;
		    	}

		    	reqFileCnt = gridBottomCnt;

				// 화면에 보여지는 그리드 데이터 목록
				var gridBottomAllList = AUIGrid.getGridData(auiGridBottom);

				for (var i = 0; i < gridBottomAllList.length; i++) {

					fileUrlArr.push(gridBottomAllList[i].file_url);
					fileSeqNoArr.push(gridBottomAllList[i].file_seq_no);
				}
			}

			var option = {
					isEmpty : true
			};

			var param = {

				//1. SMS전송메세지 세팅	(단일 )
				send_date : sendDate,
				msg : msg,
				callback_no : callbackNo,
				sms_send_type_cd : smsSendTypeCd,
				purpose_bm : purposeBm,
				req_file_cnt : reqFileCnt,
				proc_ypn: "N",
				sms_slm : smsTypeSlm,
				send_limit_yn : "N",
				job_report_no : $M.getValue("job_report_no"),
				survey_url : $M.getValue("survey_url"),

				//2. SMS전송대상자 세팅	(배열)
				phone_no_str: $M.getArrStr(phoneNoArr, option),
				receiver_name_str : $M.getArrStr(receiverNameArr, option),
				ref_key_str : $M.getArrStr(refKeyArr, option),

				//3. SMS전송파일 세팅   (배열)
				file_url_str: $M.getArrStr(fileUrlArr, option),
				file_seq_no_str : $M.getArrStr(fileSeqNoArr, option),

				// 4. 정비지시서에서 예약발송 시 체크용 메뉴번호
				menu_seq : '${inputParam.menu_seq}',
				push_cust_no : '${inputParam.cust_no}',
			}

			if(${not empty inputParam.ref_key}) { // ref_key 값이 있다면 전달받은 키값으로 매핑
				param.ref_key_str = "${inputParam.ref_key}";
			}

			var confirmMsg ="발송하시겠습니까?";
			$M.goNextPageAjaxMsg(confirmMsg,this_page+"/sendSms", $M.toForm(param), {method : 'POST'},
				function(result) {
		    		if(result.success) {
		    			sendYn = "Y";

		    			//전송성공시 팝업 띄우기
		    			fnOpenSmsSendedPopup();

						<c:if test="${not empty inputParam.parent_js_name}">
							try{
									if('${inputParam.parent_js_name}' != '') {
										opener.${inputParam.parent_js_name}();
									}

							} catch(e) {
								alert('호출 페이지에서 ${inputParam.parent_js_name} 함수를 구현해주세요.');
							}
						</c:if>
					}
				}
			);
		}

		// 견본문자등록
		function goAddSample(commYn) {
			var frm = document.main_form;
			$M.setValue("comm_yn", commYn);

			if($M.validation(frm) == false) {
				return;
			};

			$M.goNextPageAjaxSave("/comp/comp0204/save", $M.toValueForm(frm) , {method : 'POST'},
					function(result) {
						if(result.success) {

							fnClose();
						}
					}
				);

		}

		// 견본문자 팝업
		function fnSearchSampleIndiSMS() {
			var param = {

			};
			openSearchSampleSMSPanel('setSampleSMSInfo', 'indi', $M.toGetParam(param));
		}

		//견본문자 결과 callback
		function setSampleSMSInfo(row) {

			$M.setValue("msg", row.msg);
			var object = document.getElementById('msg');
			fnChkByte(object, maxBytes);
		}

		// 템플릿선택 결과 callback
		function setTemplateInfo(row) {
			goMachineCustInfo(row);
		}

		// 장비 및 고객 정보 조회
		function goMachineCustInfo(data) {
			var param = {
               "s_machine_seq" : $M.getValue("machine_seq"),
            };

            $M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: 'GET'},
                function (result) {
                    if (result.success) {
                    	console.log(JSON.stringify(result));

                    	var templateText = data.template_text;
                    	if(result.info != null) {
	                    	templateText = templateText.replace(/\\$CUST_NAME\\$/g, "[" + result.info.cust_name + "]");
	                    	templateText = templateText.replace(/\\$MODEL_NAME\\$/g, "[" + result.info.machine_name + "]");
	                    	templateText = templateText.replace(/\\$BODY_NO\\$/g, "[" + result.info.body_no + "]");

	                    	templateText = templateText.replace(/\\$WARRANT_DT\\$/g, "[" + result.info.warrant_dt + "]");
                    	}
                        $M.setValue("msg", templateText);
                        var object = document.getElementById('msg');
            			fnChkByte(object, maxBytes);
                    }
                }
            );
		}

		// sms 발송완료 팝업 호출
		function fnOpenSmsSendedPopup() {
			$M.goNextPageLayerDiv('open_layer_smsSended');
		}

		// 레이어 팝업 닫기
		function fnLayerPopup() {
			$.magnificPopup.close();
		}
		// 고객 조회
		function fnSetCustInfo(row) {
      if(isMaxGroupSendSize()) {
        setTimeout(() => {
          alert("단체발송 최대 인원은 1000명 입니다.");
        } , 1);
        return;
      }
      
			if(row.hp_no == "" || row.real_hp_no == ""){
				alert("휴대폰번호가 없습니다.");
				return false;
			}

			if(AUIGrid.isUniqueValue(auiGridTop, "phone_no", row.real_hp_no)){
				var item = new Object();
				item = {
						phone_no : row.real_hp_no,
						receiver_name : row.real_cust_name,
						ref_key : row.cust_no
				}

				AUIGrid.addRow(auiGridTop, item, 'last');
				fnUpdateCnt(auiGridTop);
			}
			$M.setValue("sms_send_type_cd","2");	//SMS전송구분  -  고객(2)으로 세팅
		}

		// 사원 조회
		function setMemberOrgMapPanel(result) {
			var data = []
			for(var i = 0 ; i < result.length ; i++){
        if(isMaxGroupSendSize()) {
          return;
        }

				if(result[i].mem_no != "" && result[i].real_hp_no != "" &&  AUIGrid.isUniqueValue(auiGridTop, "phone_no", result[i].real_hp_no)){
					var item = new Object();
					item = {
							phone_no : result[i].real_hp_no,
							receiver_name : result[i].mem_name,
							ref_key : result[i].mem_no
					}
          
					AUIGrid.addRow(auiGridTop, item, 'last');
					fnUpdateCnt(auiGridTop);
				}
			}
			$M.setValue("sms_send_type_cd","6");	//SMS전송구분  -  사원(6)으로 세팅
		}

		function fnUpdateCnt(gridName) {
			var cnt = AUIGrid.getGridData(gridName).length;
			$("#sms_total_cnt").html(cnt);
		}

	    //홍보파일 참조
      	function setPromoteFileInfo(result) {
    	 	console.log(JSON.stringify(result));

			if(result.file_seq_1 != "" && AUIGrid.isUniqueValue(auiGridBottom, "file_seq_no", result.file_seq_1)){

				var item = new Object();
				item = {
						file_name : result.file_name_1.split(".")[0],
						file_size : result.file_size_1,
						file_size_name : result.file_size_1,
						file_ext : result.file_ext_1,
						file_seq_no : result.file_seq_1,
						file_url : "${inputParam.ctrl_host}" + "/file/svc/" + result.file_seq_1
				}
				AUIGrid.addRow(auiGridBottom, item, 'last');

			}

			if(result.file_seq_2 != "" && AUIGrid.isUniqueValue(auiGridBottom, "file_seq_no", result.file_seq_2)){

				var item = new Object();
				item = {
						file_name : result.file_name_2.split(".")[0],
						file_size : result.file_size_2,
						file_size_name : result.file_size_2,
						file_ext : result.file_ext_2,
						file_seq_no : result.file_seq_2,
						file_url : "${inputParam.ctrl_host}"  + "/file/svc/" + result.file_seq_2
				}
				AUIGrid.addRow(auiGridBottom, item, 'last');

			}

			if(result.file_seq_3 != "" && AUIGrid.isUniqueValue(auiGridBottom, "file_seq_no", result.file_seq_3)){

				var item = new Object();
				item = {
						file_name : result.file_name_3.split(".")[0],
						file_size : result.file_size_3,
						file_size_name : result.file_size_3,
						file_ext : result.file_ext_3,
						file_seq_no : result.file_seq_3,
						file_url : "${inputParam.ctrl_host}"  + "/file/svc/" + result.file_seq_3
				}
				AUIGrid.addRow(auiGridBottom, item, 'last');

			}
     	}

		// 선택한 로우 삭제 ( 첨부파일 )
		function fnRemoveRowBottom() {
			// 상단 그리드의 체크된 행들 얻기
			var rows = AUIGrid.getCheckedRowItemsAll(auiGridBottom);
			if(rows.length <= 0) {
				alert('삭제할 데이터가 없습니다.');
				return;
			};
			// 선택한 하단 그리드 행들 삭제
			// 삭제하면  "이동" 이고, 삭제하지 않으면 "복사" 를 구현할 수 있음.
			AUIGrid.removeCheckedRows(auiGridBottom);
		}

	  	// 파입업로드(첨부파일)
		function fnFileDragAndDrop() {
			var param = {
			   'upload_type': "MMS",
			   // 'max_width': "",
			   // 'max_height': "",
			   'pixel_limit_yn': "",
			   'max_size': "300",
			   'file_type': "img",
			   'file_ext_type' : "jpg",
				'open_yn' : 'Y'
			};

			openFileUploadPanel('setSaveFileInfo', $M.toGetParam(param));
		}

		function setSaveFileInfo(result) {
			console.log(result);


			if(result.file_seq != "" ){
				var item = new Object();
				item = {
						file_name 	: 	result.file_name.split(".")[0],
						file_size 	: 	result.file_size,
						file_size_name 	: 	result.file_size,
						file_ext 	: 	result.file_ext,
						file_seq_no : 	result.file_seq,
						file_url 	: 	"${inputParam.ctrl_host}" + "/file/svc/" + result.file_seq
				}
				AUIGrid.addRow(auiGridBottom, item, 'last');
			}
		}


		function fnSetSendType(type) {

			if (type == "M") {	//발신구분 - 광고홍보용으로 변경하는 경우
				//단문인 경우 장문으로 변경
				if ( $M.getValue("sms_type_slm") == "S" ) {
					fnChangeSmsMode("LMS");
				}

				$("#alertText").css("display", "block");
				$("#preventText").css("display", "block");
				$("#msg").css("height", "323px");
			} else {
				$("#alertText").css("display", "none");
				$("#preventText").css("display", "none");
				$("#msg").css("height", "362px");
			}
			fnChangeSmsMode(smsMode);
		}

		// 글자수 체크
		function fnChkByte(obj, maxByte) {

			if (maxByte == undefined) {
				maxByte = parseInt($('#maxBytes').html());
			}
			var str = obj.value;
			var str_len = str.length;
			var rbyte = 0;
			var rlen = 0;
			var one_char = "";
			var str2 = "";
			for (var i = 0; i < str_len; i++) {
				one_char = str.charAt(i);
				if (escape(one_char).length > 4) {
					rbyte += 2; //한글2Byte
				} else {
					rbyte++; //영문 등 나머지 1Byte
				};
				if (rbyte <= maxByte) {
					rlen = i + 1; //return할 문자열 갯수
				};
			}
			if (rbyte > maxByte) {

				//단문에서 작성중에 글자 제한이 넘어간겅우
				if($M.getValue("sms_type_slm") == "S"){
					fnChangeSmsMode("LMS");
				}

			} else {
				document.getElementById('inputBytes').innerText = rbyte;
			};
		}

		// 문자 모드 변경
		function fnChangeSmsMode(mode) {

			var purposeBm = $("input:radio[name=send_purpose_bm]:checked").val();  	//발신목적
			smsMode = mode;

			if ( smsMode == "SMS" && purposeBm == "M" ){
				alert("광고홍보용 문구는 장문이나 MMS로만 작성 가능합니다.");
				return;
			}

			$('.tabs-link').removeClass("active");


			var maxBytes = 0;
			switch(smsMode) {
			  case 'SMS':
				  $($('.tabs-link')[0]).addClass('active');
				  $('#smsMode').html('단문');
				  $M.setValue("sms_type_slm", "S");
				  if (purposeBm == "M") {
					  maxBytes = 90-commercialBytes;
				  } else {
					  maxBytes = 90;
				  }
				  $('.mms-send-box').hide();
			    break;
			  case 'LMS':
				  $($('.tabs-link')[1]).addClass('active');
				  $('#smsMode').html('장문');
				  $M.setValue("sms_type_slm", "L");
				  if (purposeBm == "M") {
					  maxBytes = 2000-commercialBytes;
				  } else {
					  maxBytes = 2000;
				  }
				  $('.mms-send-box').hide();

			    break;
			  case 'MMS':
				  $($('.tabs-link')[2]).addClass('active');
				  $('#smsMode').html('MMS');
				  $M.setValue("sms_type_slm", "M");
				  if (purposeBm == "M") {
					  maxBytes = 2000-commercialBytes;
				  } else {
					  maxBytes = 2000;
				  }
				  $('.mms-send-box').show();
				  AUIGrid.resize(auiGridBottom);
				break;

			};
			console.log(maxBytes);
			 $('#maxBytes').html(maxBytes);
			var object = document.getElementById('msg');
			fnChkByte(object, maxBytes);
		}

		function fnToggleTarget(type) {
			$('.personal-send-box').toggleClass("dpn");
			$('#personalIcon').toggleClass("material-iconsexpand_less material-iconsexpand_more");
			$('.group-send-box').toggleClass("dpn");
			$('#groupIcon').toggleClass("material-iconsexpand_less material-iconsexpand_more");

			AUIGrid.resize(auiGridTop);

			var sendType = $M.getValue("sendType");
			switch(smsMode) {
			  case 'MMS':
				  AUIGrid.resize(auiGridBottom);
				break;
			};

			if(isGroupSend == true){
				isGroupSend = false;
			} else {
				isGroupSend = true;
			}
		}


		// 특수문자 넣기
		function fnSetSpecialChar() {
			$('.specialchar button').click(function(v) {
				var text = $(event.target).text();
				fnTypeInTextarea($("#msg"),text);
				var object = document.getElementById('msg');
				fnChkByte(object, maxBytes);
				return false;
			})
		}

		// 커서에 입력
		function fnTypeInTextarea(el, newText) {
			  var start = el.prop("selectionStart")
			  var end = el.prop("selectionEnd")
			  var text = el.val()
			  var before = text.substring(0, start)
			  var after  = text.substring(end, text.length)
			  el.val(before + newText + after)
			  el[0].selectionStart = el[0].selectionEnd = start + newText.length
			  el.focus()
			  return false
		}

		// 선택한 로우 삭제
		function fnRemoveRow(gridName) {
			// 상단 그리드의 체크된 행들 얻기
			var rows = AUIGrid.getCheckedRowItemsAll(gridName);
			if(rows.length <= 0) {
				alert('삭제할 데이터가 없습니다.');
				return;
			};
			// 선택한 상단 그리드 행들 삭제
			// 삭제하면  "이동" 이고, 삭제하지 않으면 "복사" 를 구현할 수 있음.
			AUIGrid.removeCheckedRows(gridName);
			fnUpdateCnt(gridName);
		}

		// 문자팝업 닫기
		function fnClose() {
			window.close();
			<c:if test="${not empty inputParam.parent_js_name && empty inputParam.reserve_repair_ti}">
    		if (opener.${inputParam.parent_js_name}) {
    			sendYn = "Y";
				opener.${inputParam.parent_js_name}(sendYn);
			}
			</c:if>
		}

		function createAUIGridTop() {
			// 그리드 속성 설정
			var gridPros = {
				rowIdField : "$uid",
				showRowNumColumn : false,
				//체크박스 출력 여부
				showRowCheckColumn: true,
				//전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
				softRemoveRowMode : false,
			};
			var columnLayout = [

				{
					dataField : "receiver_name",
					headerText : "이름"
				},
				{
					dataField : "phone_no",
					headerText : "수신번호",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
					     return $M.phoneFormat(value);
					}
				},
				{
					dataField : "ref_key",
					headerText : "참조키",
					visible : false
				},

			];
			auiGridTop = AUIGrid.create("#auiGridTop", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridTop, []);

		}

		function createAUIGridReq() {
			// 그리드 속성 설정
			var gridPros = {
				rowIdField : "$uid",
				showRowNumColumn : false,
				//체크박스 출력 여부
				showRowCheckColumn: true,
				//전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
				softRemoveRowMode : false
			};
			var columnLayout = [

				{
					dataField : "receiver_name",
					headerText : "이름"
				},
				{
					dataField : "phone_no",
					headerText : "수신번호",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
					     return $M.phoneFormat(value);
					}
				},
				{
					dataField : "ref_key",
					headerText : "참조키",
					visible : false
				},

			];
			auiGridReq = AUIGrid.create("#auiGridReq", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridReq, []);

		}


		function createAUIGridBottom() {

			// 그리드 속성 설정
			var gridPros = {
				rowIdField : "$uid",
				showRowNumColumn : false,
				//체크박스 출력 여부
				showRowCheckColumn: true,
				//전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
				softRemoveRowMode : false
			};

			var columnLayout = [
				{
					dataField : "file_name",
					headerText : "파일명",
					style : "aui-left aui-link",
					width : "50%",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
					     return value;
					}
				},
				{
					dataField : "file_size",
					visible : false
				},
				{
					dataField : "file_size_name",
					headerText : "용량",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
					     return ( value == '' )? '' : + value +'KB';
					}
				},
				{
					dataField : "file_ext",
					headerText : "확장명"
				},
				{
					dataField : "file_seq_no",
					visible : false
				},
				{
					dataField : "file_url",
					visible : false
				}
			];
			// 실제로 #grid_wrap에 그리드 생성
			auiGridBottom = AUIGrid.create("#auiGridBottom", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridBottom, []);

			AUIGrid.bind(auiGridBottom, "cellClick", function(event) {
				var tempArr = [];
				// 이미지 클릭 시
				if(event.dataField == "file_name" ) {
					//이미지 미리보기 ( 레이어방식)
					$M.goNextPageLayerImage(event.item.file_url);

				}
			});
		}




		// 행 추가, 삽입
		function fnAddRow(gridName, phoneField, nameField) {

			if($M.validation(document.main_form, {field:[phoneField, nameField]}) == false) {
				return;
			};

      if(isMaxGroupSendSize()) {
        return;
      }

			var hp_no = $M.getValue(phoneField);

			if(AUIGrid.isUniqueValue(gridName, "phone_no", hp_no) == false) {
				alert("이미 등록된 휴대폰번호입니다.");
				$("#"+phoneField).focus();
				return false;
			}

			if (!hpRegex.test(hp_no)){
				alert("올바른 휴대폰번호를 입력해주세요");
				$("#"+phoneField).focus();
				return false;
			}

			var item = new Object();
			item = {
					phone_no : $M.getValue(phoneField),
					receiver_name : $M.getValue(nameField),
					ref_key : ""
			}

			$M.setValue(nameField, "");
			$M.setValue(phoneField, "");
			// parameter
			// item : 삽입하고자 하는 아이템 Object 또는 배열(배열인 경우 다수가 삽입됨)
			// rowPos : rowIndex 인 경우 해당 index 에 삽입, first : 최상단, last : 최하단, selectionUp : 선택된 곳 위, selectionDown : 선택된 곳 아래
			AUIGrid.addRow(gridName, item, 'last');
			fnUpdateCnt(gridName);
		}


		// 사전 등록 번호 관리 팝업 오픈
		function goSetting(){
			var param = {
				group_code : "SMS_CALLBACK_ALLOW",
				all_yn: "Y",
				show_extra_cols : "v1",
				s_sort_key : "code_name",
				s_sort_method : "desc"
			}
			openGroupCodeDetailPanel($M.toGetParam(param));
		}

		// 고객쿠폰 테스트용
		// 견본문자등록
		function goTempSave() {
			var param = {};
			$M.goNextPageAjaxSave(this_page + "/send/test", $M.toGetParam(param) , {method : 'POST'},
					function(result) {
						if(result.success) {
							fnClose();
						}
					}
			);

		}
		
		// 엑셀 업로드
		function openUploadExcel() {
			var param = {
				parent_js_name: 'setExcelData'
			}
			$M.goNextPage('/comp/comp0201p01', $M.toGetParam(param), {popupStatus: {}});
		}
		
		// 엑셀 업로드 데이터 셋팅
		function setExcelData(sendDataList) {
			var regex = /[^0-9]/g;
			for (let i = 0; i < sendDataList.length; i++) {
				var name = sendDataList[i].name; // 이름
				var hp_no = sendDataList[i].hp_no.replace(regex, ""); // 특수문자 제거
				
				// 중복 체크
				if(AUIGrid.isUniqueValue(auiGridTop, "phone_no", hp_no) === false) {
					continue;
				}

				var item = {
					receiver_name : name,
					phone_no : hp_no,
					ref_key : ""
				}

        if(isMaxGroupSendSize()) {
          return;
        }

				AUIGrid.addRow(auiGridTop, item, 'last');
				fnUpdateCnt(auiGridTop);
			}
		}
    
    function isMaxGroupSendSize() {
      const isMax = AUIGrid.getGridData(auiGridTop).length >= maxGroupSize;
      if(isMax) {
        setTimeout(() => {
          alert("단체발송 최대 인원은 1000명 입니다.");
        }, 1);
      }
      return isMax;
    }

	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" id="comm_yn" name="comm_yn"  alt="공통여부">
<input type="hidden" id="sms_type_slm" name="sms_type_slm" required="required" alt="문자타입">
<input type="hidden" id="sms_send_type_cd" name="sms_send_type_cd" value="${inputParam.sms_send_type_cd}"  alt="sms전송타입코드">	<!-- 디폴트 : 주소록 (3) -->
<input type="hidden"  id="indi_ref_key" name="indi_ref_key"  value="${ref_key}" ale="참조키">
<input type="hidden"  id="job_report_no" name="job_report_no"  value="${inputParam.job_report_no}">
<input type="hidden"  id="survey_url" name="survey_url"  value="${inputParam.survey_url}">
<input type="hidden"  id="machine_seq" name="machine_seq"  value="${inputParam.s_machine_seq}">

<div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
			<div class="row mg0">
<!-- 좌측 폰 문자 입력 -->
				<div class="col-6">
					<div class="phone-sms-bg">
						<div class="sms-content">
							<ul class="tabs-c tabs-ink-bar tabs-justified" required="required">
								<li class="tabs-item" onclick="fnChangeSmsMode('SMS')">
									<a class="tabs-link active">단문</a>
								</li>
								<li class="tabs-item" onclick="fnChangeSmsMode('LMS')">
									<a class="tabs-link">장문</a>
								</li>
								<li class="tabs-item" onclick="fnChangeSmsMode('MMS')">
									<a class="tabs-link">MMS</a>
								</li>
							</ul>
							<div class="sms-text">
								<!-- MMS -->
								<!-- <div contenteditable="true" id="contenteditable" class="contenteditable" placeholder="보낼 문자를 입력하세요." onchange="change(event)"></div> -->
								<!-- SMS, LMS -->
								<div id="alertText" style="display: none;">(광고)</div>
								<textarea class="sms-textarea" id="msg" name="msg" alt="메세지" required="required" placeholder="보낼 문자를 입력하세요." onkeyUp="javascript:fnChkByte(this, maxBytes)">${msg}</textarea>
								<div id="preventText" style="display: none;">무료수신거부 080-133-3806</div>
							</div>
							<div class="sms-btn-group">
								<div class="btn-group">
									<button type="button" class="btn btn-outline-info" style="width: 89px;" onclick="javascript:fnOpenSpecialCharPopup();">특수문자</button>
									<button type="button" class="btn btn-outline-info" style="width: 89px;" onclick="javascript:fnSearchSampleIndiSMS();">견본문자</button>
									<button type="button" class="btn btn-outline-info" style="width: 89px;" onclick="javascript:openSearchTemplatePanel('setTemplateInfo');">템플릿</button>
								</div>
							</div>
							<!-- <div class="text-deny">무료수신거부 080-133-3806</div> -->
							<div class="text-bytes"><div id="smsMode" class="inline">단문</div> : <div id="inputBytes" class="inline">0</div> / <div id="maxBytes" class="inline">90</div> bytes</div>
						</div>
					</div>
				</div>
<!-- /좌측 폰 문자 입력 -->
<!-- 우측 문자 내용 -->
				<div class="col-6" >
					<div class="row boxing">
						<div class="col-3 col-form-label">발신구분</div>
						<div class="col-auto form-check form-check-inline">
							<input class="form-check-input" type="radio" id="send_purpose_bm_b" name="send_purpose_bm" value="B" checked="checked" onclick="javascript:fnSetSendType('B')">
							<label class="form-check-label" for="send_purpose_bm_b">업무용</label>
						</div>
						<div class="col-auto form-check form-check-inline">
							<input class="form-check-input" type="radio" id="send_purpose_bm_m" name="send_purpose_bm" value="M" onclick="javascript:fnSetSendType('M')">
							<label class="form-check-label" for="send_purpose_bm_m">광고홍보용</label>
						</div>
					</div>
<!-- 개별발송 펼침 -->
					 <div class="row-accordion" id="div_single_send" name="div_single_send" >
						<div class="row boxing pd0">
							<div class="col-12 boxing-header" onclick="javascript:fnToggleTarget('indi')" style="cursor: pointer;">
								<div>개별발송</div>
								<div><i class="material-iconsexpand_less" id="personalIcon"></i></div>
							</div>
						</div>
						<div class="row boxing mt-9 personal-send-box">
							<div class="col-12 boxing-body">
								<div class="row">
									<div class="col-2 col-form-label">이름</div>
									<div class="col-4">
										<input type="text" class="form-control" id="indi_name" name="indi_name">
									</div>
									<div class="col-2 col-form-label">수신번호</div>
									<div class="col-4">
										<input type="text" class="form-control" id="indi_hp_no" name="indi_hp_no" format="phone" placeholder="숫자만입력">
									</div>
								</div>
							</div>
						</div>
					</div>
<!-- /개별발송 펼침 -->
<!-- 단체발송 펼침 -->
					<div class="row-accordion"  id="div_group_send" name="div_group_send" >
						<div class="row boxing pd0">
							<div class="col-12 boxing-header" onclick="javascript:fnToggleTarget('group')" style="cursor: pointer;">
								<div>단체발송</div>
								<div><i class="material-iconsexpand_more" id="groupIcon"></i></div>
							</div>
						</div>
						<div class="row boxing mt-9 group-send-box dpn">
							<div class="col-12 boxing-body">
								<div class="btn-group">
									<div class="right">
										<button type="button" class="btn btn-default" style="width: 50px;" onclick="javascript:openSearchCustPanel('fnSetCustInfo');" >고객</button>
										<button type="button" class="btn btn-default" style="width: 50px;" onclick="javascript:openMemberOrgPanel('setMemberOrgMapPanel', 'Y')">사원</button>
										<button type="button" class="btn btn-default" style="width: 80px;" onclick="javascript:openUploadExcel('fnSetCustInfo')">엑셀업로드</button>
										<button type="button" class="btn btn-default" style="width: 70px;" onclick="javascript:fnRemoveRow(auiGridTop)">선택삭제</button>
									</div>
								</div>

								<div class="mt5" style="width: 100%; height: 150px; border: 1px solid" id="auiGridTop"></div>
								<div class="table-summary">총 <strong class="text-primary" id="sms_total_cnt">0</strong>건</div>
								<div class="row each-add">
									<div class="col-2">
										<label>이름</label>
									</div>
									<div class="col-3">
										<input type="text" class="form-control" id="add_name" name="add_name" alt="이름">
									</div>
									<div class="col-2">
										<label>수신번호</label>
									</div>
									<div class="col-3">
										<input type="text" class="form-control" id="add_hp" name="add_hp" alt="수신번호" placeholder="숫자만" datatype="int">
									</div>
									<div class="col-2">
										<button type="button" class="btn btn-primary-gra" onclick="javascript:fnAddRow(auiGridTop, 'add_hp', 'add_name')">개별추가</button>
									</div>
								</div>
							</div>
						</div>
					</div>
<!-- /단체발송 펼침 -->

<!-- 발송대상참조 -->
					<div  id="div_req_send" name="div_req_send" style="display:none"; >
						<div class="row boxing pd0">
							<div class="col-12 boxing-header" >
								<div>발송대상</div>
							</div>
						</div>
						<div class="row boxing mt-9">
							<div class="col-12 boxing-body">
								<div class="btn-group">
									<div class="right">
										<button type="button" class="btn btn-default" style="width: 70px;" onclick="javascript:fnRemoveRow(auiGridReq)">선택삭제</button>
									</div>
								</div>

								<div class="mt5" style="width: 100%; height: 150px;" id="auiGridReq"></div>
								<div class="table-summary">총 <strong class="text-primary" id="req_total_cnt">0</strong>건</div>
								<div class="row each-add">
									<div class="col-2">
										<label>이름</label>
									</div>
									<div class="col-3">
										<input type="text" class="form-control" id="add_name_req" name="add_name_req" alt="이름">
									</div>
									<div class="col-2">
										<label>수신번호</label>
									</div>
									<div class="col-3">
										<input type="text" class="form-control" id="add_hp_req" name="add_hp_req" alt="수신번호" placeholder="숫자만" datatype="int">
									</div>
									<div class="col-2">
										<button type="button" class="btn btn-primary-gra" onclick="javascript:fnAddRow(auiGridReq, 'add_hp_req', 'add_name_req')">개별추가</button>
									</div>
								</div>
							</div>
						</div>
					</div>
<!-- 발송대상참조 -->

<!-- 발신번호 -->
					<div class="row boxing">
						<div class="col-2 col-form-label">발신번호</div>
						<div class="col-6">
							<select class="form-control"  id="callback" name="callback" style="width: 100%;"  onchange="javascript:fnChangeCallBackNo(this.options[this.selectedIndex].value);" >
								<option value="">- 선택 -</option>
								<c:forEach items="${callBackNoList}" var="item">
									<option value="${item.code_value}" ${item.code_value eq inputParam.callback ? 'selected="selected"' : ''}>${item.code_name}</option>
								</c:forEach>
<%--								<c:forEach var="list" items="${codeMap['']}">--%>
<%--									<option value="${list.code_value}" <c:if test="${list.code_value eq inputParam.login_org_code}">selected</c:if> >${list.code_name}</option>--%>
<%--								</c:forEach>--%>
							</select>
						</div>
						<div class="col-4">
							<input type="text"   class="form-control"  id="callback_no" name="callback_no" alt="발신번호"  readonly="readonly" required="required" >
						</div>
						<br/><br/>
						<div>
							◎ <font color="red">사전등록이 되지 않은 번호는 표시되지 않음.</font>
						</div>
					</div>
<!-- /발신번호 -->
					<div class="row boxing  mms-send-box" >
						<div class="col-12  boxing-body">
							<div class="btn-group">
								<div class="right">
									<button type="button" class="btn btn-default"   onclick="javascript:openSearchPromoteFilePanel('setPromoteFileInfo');" style="width: 80px;">홍보파일참조</button>
									<button type="button" class="btn btn-default"  onclick="javascript:fnRemoveRowBottom();" style="width: 80px;" >선택삭제</button>
								</div>
							</div>
							<div class="mt5" style="width: 100%; height: 150px; border: 1px solid" id="auiGridBottom"></div>
							<div class="row each-add mt10">
								<div class="col-2 col-form-label">첨부파일</div>
								<input type="text" class="col-7 form-control mr5" id="attach_file_name" name="attach_file_name" alt="파일명" readonly="readonly" >
								<button type="button" class="btn btn-primary-gra" name="fileAddBtn" id="fileAddBtn" onclick="javascript:fnFileDragAndDrop();" >파일찾기</button>
								<span class="form-text text-secondary">주의! 이미지는 jpg, 최대 3개, 용량총합 300KB이내</span>
							</div>
						</div>
					</div>
<!-- 예약발송 -->
					<div class="row boxing">
						<div class="form-check-inline width10px">
							<input class="form-check-input "  type="checkbox" id="reserve_yn" name="reserve_yn" value="Y" onclick="javascript:fnChangeReserve(this)" >
						</div>
						<div class="col-2 col-form-label">예약발송</div>
						<div class="col-4" style="max-width:150px;">
							<div class="input-group">
								<input type="text" class="form-control border-right-0 calDate" placeholder="발송일" id="send_dt" name="send_dt"  disabled="disabled" dateformat="yyyy-MM-dd" >
							</div>
						</div>
						<div class="col-5">
							<div class="form-row  inline-pd">

								<div class="pl5 pr5">
									<select class="form-control width40px" style="min-width:40px;" id="send_hour" name="send_hour"  disabled="disabled" alt="시" style="width: 100%;" >
										<c:forEach var="i" begin="01" end="24" step="1">
											<option value="${i>9?i:'0'}${i>9?'':i}" <c:if test="${i==inputParam.s_current_hour}">selected</c:if>>${i>9?i:'0'}${i>9?'':i}</option>
										</c:forEach>
									</select>
								</div>
								<div >시</div>
								<div class="pl5 pr5">
									<select class="form-control  width40px" style="min-width:40px;"  id="send_minute" name="send_minute"  disabled="disabled" alt="분" style="width: 100%;" >
										<c:forEach var="i" begin="00" end="59" step="1">
											<option value="${i>9?i:'0'}${i>9?'':i}" <c:if test="${i==inputParam.s_current_minute}">selected</c:if>>${i>9?i:'0'}${i>9?'':i}</option>
										</c:forEach>
									</select>
								</div>
								<div>분</div>

							</div>
						</div>
					</div>
<!-- /예약발송 -->
					<div class="btn-group">
						<div class="right smsFuncBtn">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
						</div>
					</div>
				</div>
<!-- /우측 문자 내용 -->
			</div>
<!-- 문자발송 안내사항 -->
			<div class="row mg0">
				<div class="col-12 alert alert-secondary mt10">
					<div class="title">
						<i class="material-iconserror font-16"></i>
						<span>문자발송 안내사항</span>
					</div>
					<ul>
						<li>홍보, 마케팅 등의 영리를 목적으로 하는 문자발송 시에는 발송구분에서 광고/홍보문자를 선택하신 후 발송하시기 바랍니다.</li>
						<li>문자발송요금 : SMS(건당&nbsp;12원), LMS(건당&nbsp;30원)</li>
					</ul>
				</div>
			</div>
<!-- /문자발송 안내사항 -->
		</div>
    </div>
<!-- 문자발송완료 -->
<div class="popup-wrap width-300 mfp-hide" id="open_layer_smsSended" name="open_layer_smsSended" style="margin-top: -100px;">
<!-- 타이틀영역 -->
	<div class="main-title">
		<h2>문자발송완료</h2>
		<button type="button" class="btn btn-icon" onclick="javascript:fnLayerPopup()"><i class="material-iconsclose"></i></button>
	</div>
<!-- /타이틀영역 -->
	<div class="content-wrap">
		<div>문자 발송이 완료되었습니다.<br>발송한 문자는 견본문자로 등록이 가능합니다.<br>지금 등록하시겠습니까?</div>
		<div class="btn-group mt20">
			<div class="center">
				<button type="button" class="btn btn-info" style="width: 100px;" onclick="javascript:goAddSample('N')">개별견본문자등록</button>
				<button type="button" class="btn btn-info" style="width: 100px;" onclick="javascript:goAddSample('Y')">공통견본문자등록</button>
				<button type="button" class="btn btn-info" style="width: 60px;" onclick="javascript:fnClose()">닫기</button>
			</div>
		</div>
	</div>
</div>

<!-- 특수문자 -->
<div class="popup-wrap width-300 mfp-hide" id="open_layer_specialChar" name="open_layer_specialChar" style="margin-top: -200px;">
<!-- 타이틀영역 -->
	<div class="main-title">
		<h2>특수문자선택</h2>
		<button type="button" class="btn btn-icon" onclick="javascript:fnLayerPopup()"><i class="material-iconsclose"></i></button>
	</div>
<!-- /타이틀영역 -->
	<div class="content-wrap">
		<div class="specialchar">
			<button type="button">☆</button>
			<button type="button">★</button>
			<button type="button">♡</button>
			<button type="button">♥</button>
			<button type="button">♧</button>
			<button type="button">♣</button>
			<button type="button">◁</button>
			<button type="button">◀</button>
			<button type="button">▷</button>
			<button type="button">▶</button>
			<button type="button">♤</button>
			<button type="button">♠</button>
			<button type="button">♧</button>
			<button type="button">♣</button>
			<button type="button">⊙</button>
			<button type="button">○</button>
			<button type="button">●</button>
			<button type="button">◎</button>
			<button type="button">◇</button>
			<button type="button">◆</button>
			<button type="button">⇔</button>
			<button type="button">△</button>
			<button type="button">▲</button>
			<button type="button">▽</button>
			<button type="button">▼</button>
			<button type="button">▒</button>
			<button type="button">▤</button>
			<button type="button">▥</button>
			<button type="button">▦</button>
			<button type="button">▩</button>
			<button type="button">◈</button>
			<button type="button">▣</button>
			<button type="button">◐</button>
			<button type="button">◑</button>
			<button type="button">♨</button>
			<button type="button">☏</button>
			<button type="button">☎</button>
			<button type="button">☜</button>
			<button type="button">☞</button>
			<button type="button">♭</button>
			<button type="button">♩</button>
			<button type="button">♪</button>
			<button type="button">♬</button>
			<button type="button">㉿</button>
			<button type="button">㈜</button>
			<button type="button">℡</button>
			<button type="button">㏇</button>
			<button type="button">±</button>
			<button type="button">㏂</button>
			<button type="button">㏘</button>
			<button type="button">€</button>
			<button type="button">®</button>
			<button type="button">↗</button>
			<button type="button">↙</button>
			<button type="button">↖</button>
			<button type="button">↘</button>
			<button type="button">↕</button>
			<button type="button">↔</button>
			<button type="button">↑</button>
			<button type="button">↓</button>
			<button type="button">∀</button>
			<button type="button">∃</button>
			<button type="button">∮</button>
			<button type="button">∑</button>
			<button type="button">∏</button>
			<button type="button">℉</button>
			<button type="button">‰</button>
			<button type="button">￥</button>
			<button type="button">￡</button>
			<button type="button">￠</button>
			<button type="button">Å</button>
			<button type="button">℃</button>
			<button type="button">♂</button>
			<button type="button">♀</button>
			<button type="button">∴</button>
			<button type="button">《</button>
			<button type="button">》</button>
			<button type="button">『</button>
			<button type="button">』</button>
			<button type="button">【</button>
			<button type="button">】</button>
			<button type="button">±</button>
			<button type="button">×</button>
			<button type="button">÷</button>
			<button type="button" style="font-family: dotum;">∥</button>
			<button type="button">＼</button>
			<button type="button">©</button>
			<button type="button">√</button>
			<button type="button">∽</button>
			<button type="button">∵</button>
		</div>
	</div>
</div>
</form>
</body>
</html>