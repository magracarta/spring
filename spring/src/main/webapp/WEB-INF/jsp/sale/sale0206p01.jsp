<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 장비코드관리 > 장비코드관리 > null > 장비코드상세
-- 작성자 : 황빛찬
-- 최초 작성일 : 2020-03-25 10:52:36
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var moneyUnitJson = JSON.parse('${codeMapJsonObj["MONEY_UNIT"]}'); // 화폐단위
		var machineSubTypeMap = ${machineSubTypeMap};

		// 첨부파일의 index 변수
		var chartFileIndex = 1;
		// 첨부할 수 있는 파일의 개수
		var chartFileMaxCount = 3;

		// 첨부할 수 있는 파일의 개수
		var fileCount = 1;

		var mchFileSeq;

		$(document).ready(function() {
			<c:forEach var="list" items="${job_file}">setJobFileInfo('${list.file_seq}', '${list.file_name}');</c:forEach>
			mchFileSeq='${map.mch_file_seq }';
			if(mchFileSeq>0) {
				fnAttatchImg(mchFileSeq);
			} else {
				fnNoImg();
			}
			fnMoneyNameChange('${map.money_unit_cd}');
		});

		function fnAddFile() {
			if($("input[name='file_seq']").size() >= fileCount && $M.getValue("file_seq") != "0") {
				alert("파일은 " + fileCount + "개만 첨부하실 수 있습니다.");
				return false;
			}
			openFileUploadPanel('setFileInfo', 'upload_type=SERVICE&file_type=etc&max_size=5048&file_ext_type=pdf');
		}

		function setFileInfo(result) {
			var str = '';
			str += '<div class="table-attfile-item file_1" style="float:left; display:block;">';
			str += '<a href="javascript:fileDownload(' + result.file_seq + ');" style="color: blue;">' + result.file_name + '</a>&nbsp;';
			str += '<input type="hidden" name="file_seq" value="' + result.file_seq + '"/>';
			str += '<button type="button" class="btn-default" onclick="javascript:fnRemoveFile(1,'  + result.file_seq + ')"><i class="material-iconsclose font-18 text-default"></i></button>';
			str += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
			str += '</div>';
			$('.file_div').append(str);
		}

		// 첨부파일 삭제
		function fnRemoveFile(fileIndex, fileSeq) {
			var result = confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.");
			if (result) {
				$(".file_" + fileIndex).remove();
				$M.setValue("file_seq", 0);
			} else {
				return false;
			}

		}

		// 닫기
		function fnClose() {
			window.close();
		}

		// 기종에 따른 규격 세팅
		function fnMachineSubTypeList() {
			var machineTypeCd = $M.getValue("machine_type_cd");
			// select box 옵션 전체 삭제
			$("#machine_sub_type_cd option").remove();
			// select box option 추가
			$("#machine_sub_type_cd").append(new Option('- 선택 -', ""));

			// 기종에 따른 규격 list를 세팅
			if (machineSubTypeMap.hasOwnProperty(machineTypeCd)) {
				var machineSubTypeCdList = machineSubTypeMap[machineTypeCd];
				for (item in machineSubTypeCdList) {
					$("#machine_sub_type_cd").append(new Option(machineSubTypeCdList[item].code_name, machineSubTypeCdList[item].code));
				}
			}
		}

		// 판매가 변동내역(구 단가관리) 팝업 호출
		function fnMachinePriceHistoryPopup() {
			var param = {
					machine_plant_seq : $M.getValue("machine_plant_seq"),
					s_sort_key : "change_dt",
					s_sort_method : "desc"
			};

			var poppupOption = "";
			$M.goNextPage('/sale/sale0206p02', $M.toGetParam(param), {popupStatus : poppupOption});
		}

		// 수정
		function goModify() {
			var param = {
					"origin_machine_name" : $M.getValue("origin_machine_name"),
					"machine_name" : $M.getValue("machine_name")
			}

			$M.goNextPageAjax(this_page + '/duplicate/check/', $M.toGetParam(param), {method : 'GET'},
					function(result) {
			    		if(result.success) {
							if($M.validation(document.main_form) == false) {
								return;
							};

							// if($M.getValue("machine_group_cd")=="") {
							// 	alert("씨리즈는 필수선택입니다.");
							// 	return;
							// }

							if($M.getValue("money_unit_cd")=="") {
								alert("화폐구분은 필수선택입니다.");
								return;
							}

							$M.setValue("machine_group_name", $("#machine_group_cd").combogrid("getText"));

							var frm = document.main_form;

							var idx = 1;
							$("input[class='job_file_list']").each(function() {
								var str = 'job_file_seq_' + idx;
								$M.setValue(str, $(this).val());
								idx++;
							});
							for(; idx <= chartFileMaxCount; idx++) {
								$M.setValue('job_file_seq_' + idx, 0);
							}

							$M.goNextPageAjaxModify(this_page + '/modify', $M.toValueForm(frm), {method : 'POST'},
								function(result) {
						    		if(result.success) {
						    			alert("정상 처리되었습니다.");
						    			fnClose();
						    			if (window.opener.goSearch) {
						    				window.opener.goSearch();
						    			}
									}
								}
							);
						} else {
							return;
						}
					}
				);
		}

		// 기간차트 첨부파일열기
		function goSearchFile(){
			if($("input[class='job_file_list']").size() >= chartFileMaxCount) {
				alert("파일은 " + chartFileMaxCount + "개만 첨부하실 수 있습니다.");
				return false;
			}

            var param = {
                max_width: 768,
                max_height: 1024,
                upload_type: 'SERVICE',
                file_type: 'img',
                max_size: 300
            };

			openFileUploadPanel('fnPrintFileInfo', $M.toGetParam(param));
		}

		function fnPrintFileInfo(result) {
			setJobFileInfo(result.file_seq, result.file_name)
		}

		//첨부파일 세팅
		function setJobFileInfo(fileSeq, fileName) {
			var str = '';
			str += '<div class="table-attfile-item chart_file_' + chartFileIndex + '" style="float:left; display:block;">';
			str += '<a href="javascript:fileDownload(' + fileSeq + ');" style="color: blue;">' + fileName + '</a>&nbsp;';
			str += '<input type="hidden" class="job_file_list" name="job_file_seq_'+ chartFileIndex + '" value="' + fileSeq + '"/>';
			str += '<button type="button" class="btn-default" onclick="javascript:fnRemoveJobFile(' + chartFileIndex + ', ' + fileSeq + ')"><i class="material-iconsclose font-18 text-default"></i></button>';
			str += '</div>';
			$('.chart_file_div').append(str);
			chartFileIndex++;
		}

		// 첨부파일 삭제
		function fnRemoveJobFile(chartFileIndex, fileSeq) {
			var result = confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.");
			if (result) {
				$(".chart_file_" + chartFileIndex).remove();
				$("#job_file_seq_" + chartFileIndex).remove();
			} else {
				return false;
			}
		}

		function fnNoImg(){
			$("#machine_img").attr("src", "/static/img/no-image.png" );
			$("#machine_img").attr("width", "200px");
			$("#machine_img").attr("height", "280px");
			$(".attachfile-item").show();
			$("#delete_btn").attr("class", "invisible");
		}

		function fnAttatchImg(mchFileSeq){
			var fileSeq = "/file/" + mchFileSeq;
			$("#machine_img").attr("src", fileSeq );
			$(".attachfile-item").show();
			$("#delete_btn").attr("class", "");

			//이미지 로딩
			if(fileSeq > 0 ){
				$M.goNextPageAjax(fileSeq, '', {method : "GET"},
					function(result){
						if(result.success) {
							if(result.file_exists_yn == 'Y') {
								fnExistsFileSelect(result);
							} else {
								alert('파일이 없습니다.');
							}
						}
					});
			}
		}

		// 대표이미지 업로드
		function goUploadImg() {
			openFileUploadPanel("fnSetImage", 'upload_type=HELP&file_type=img&max_width=200&max_height=280&max_size=2048&file_seq='+$("#mch_file_seq").attr('value'));
		}

		// 파일업로드 팝업창에서 받아온 값
		function fnSetImage(result) {
			if (result !== null && result.file_seq !== null) {
				mchFileSeq = result.file_seq;
				$("#mch_file_seq").attr('value', mchFileSeq);
				fnAttatchImg(mchFileSeq);
			}
		}

		//이미지 삭제하기
		function imgDel() {
			var agent = navigator.userAgent.toLowerCase();
			var browserType = "";
			if ((navigator.appName == 'Netscape' && navigator.userAgent.search('Trident') != -1) || (agent.indexOf("msie") != -1)) {
				browserType = "IE"
			}
			else {
				browserType = "ETC"
				//드래그이벤트는 IE가 아닌 경우만 처리
			}

			//input file 초기화
			if (browserType == 'IE') {
				$("#mch_file_seq").replaceWith( $("#mch_file_seq").clone(true) );
			}
			else {
				$("#mch_file_seq").val("");
			}

			fnNoImg();
		}

		function fnMoneyUnitChanged(codeValue) {
			alert('화폐구분이 있는 경우 동일한 메이커는 같은 화폐구분으로 적용됩니다.');
			fnMoneyNameChange(codeValue);
		}

		function fnMoneyNameChange(codeValue){
			var item;
			if(codeValue) {
				item = moneyUnitJson.filter(item => item.code_value === codeValue)[0];
			}
			
			var money_unit = "원";
			if(item) {
				money_unit = item.code_desc;
			}
			// switch($M.getValue("money_unit_cd")){
			// 	case "JPY" :
			// 		money_unit = "엔(Y)";
			// 		break;
			// 	case "USD" :
			// 		money_unit = "달러($)";
			// 		break;
			// 	case "CNY" :
			// 		money_unit = "위안(C)";
			// 		break;
			// 	case "EUR" :
			// 		money_unit = "유로(E)";
			// 		break;
			// }
			$("#order_price_name").html(money_unit);
		}

		// 업무DB 연결 함수 21-08-31이강원
     	function openWorkDB(){
     		openWorkDBPanel('',$M.getValue("machine_plant_seq"));
     	}

     	//textarea 바이트 수 체크하는 함수
     	function fn_checkByte(obj){
     		alert("ffff");
     	    const maxByte = 100; //최대 100바이트
     	    const text_val = obj.value; //입력한 문자
     	    const text_len = text_val.length; //입력한 문자수

     	    let totalByte=0;
     	    for(let i=0; i<text_len; i++){
     	    	const each_char = text_val.charAt(i);
     	        const uni_char = escape(each_char) //유니코드 형식으로 변환
     	        if(uni_char.length>4){
     	        	// 한글 : 2Byte
     	            totalByte += 2;
     	        }else{
     	        	// 영문,숫자,특수문자 : 1Byte
     	            totalByte += 1;
     	        }
     	    }

     	    if(totalByte>maxByte){
  	        	document.getElementById("nowByte").innerText = totalByte;
  	            document.getElementById("nowByte").style.color = "red";
  	        }else{
  	        	document.getElementById("nowByte").innerText = totalByte;
  	            document.getElementById("nowByte").style.color = "green";
  	        }
     	}

	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" id="origin_machine_name" name="origin_machine_name" value="${map.machine_name}">
<input type="hidden" id="job_file_seq_1" name="job_file_seq_1" value="${map.job_file_seq_1}"/>
<input type="hidden" id="job_file_seq_2" name="job_file_seq_2" value="${map.job_file_seq_2}"/>
<input type="hidden" id="job_file_seq_3" name="job_file_seq_3" value="${map.job_file_seq_3}"/>
<input type="hidden" id="mch_file_seq" name="mch_file_seq" value="${map.mch_file_seq }"/>
<div class="layout-box">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">

                <div class="content-wrap">
            <div class="row widthfix">
<!-- 좌측 상세사진 영역 -->
                <div class="col width210px">
                    <div class="title-wrap">
                        <h4 class="primary">대표이미지 등록/수정</h4>
                    </div>
                    <div class="detailimg-item">
		                <div id="delete_btn" style="width: 22px;position: inherit;left:180px;top: 25px;border-radius: 50%;background: #cc0000;opacity: 0.6;filter: Alpha(opacity=60);z-index:999;">
							<button type="button" class="btn btn-icon-md text-light"  onclick="javascript:imgDel();" ><i class="material-iconsclose"></i></button>
						</div>
		                <img id="machine_img" name="machine_img" alt="사진" class="detailphoto" style="width: 200px; height:280px; object-fit: contain;" >
                    </div>
                    <button type="button" class="btn btn-default btn-block" onclick="javascript:goUploadImg()">파일찾기</button>
                </div>
<!-- /좌측 상세사진 영역 -->
<!-- 우측 폼테이블 -->
                <div class="col pl10" style="width: calc(100% - 210px);">
                    <table class="table-border mt5">
						<colgroup>
							<col width="135px">
							<col width="">
							<col width="135px">
							<col width="">
							<col width="135px">
							<col width="">
						</colgroup>
						<tbody>
							<tr>
								<th class="text-right essential-item">모델명/형식명</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-4">
											<input type="hidden" id="machine_plant_seq" name="machine_plant_seq" value="${map.machine_plant_seq}">
											<input type="text" class="form-control essential-bg" id="machine_name" name="machine_name" alt="모델명" required="required" value="${map.machine_name}" placeholder="모델명">
										</div>
										<div class="col-5">
											<input type="text" class="form-control" id="machine_form_name" name="machine_form_name" alt="형식명" value="${map.machine_form_name}" placeholder="형식명">
										</div>
										<div class="col-auto">
					                        <button type="button" class="btn btn-primary-gra" onclick="javascript:openWorkDB();">업무DB</button>
							            </div>
									</div>
	<!-- 								<input type="hidden" id="machine_group_name" name="machine_group_name"> 임시로 장비명과 동일하게 등록 -->
								</td>
                                <th class="text-right essential-item">메이커/씨리즈</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-4">
											<select id="maker_cd" name="maker_cd" class="form-control essential-bg" alt="메이커" required="required">
												<option value="" ${map.maker_cd == "" ? 'selected' : ''} >- 선택 - </option>
												<c:forEach items="${makerList}" var="item">
													<option value="${item.code_value}" ${item.code_value == map.maker_cd ? 'selected' : ''}>${item.code_name}</option>
												</c:forEach>
											</select>
										</div>
										<div class="col-5">
												<input class="form-control essential-bg width120px" type="text" id="machine_group_cd" name="machine_group_cd" easyui="combogrid"
										   		easyuiname="machineGroupList" panelwidth="150" idfield="code_value" textfield="code_name" multi="N" value="${map.machine_group_cd}"/>
										</div>
									</div>
								</td>
                                <th class="text-right essential-item">발주단가</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col width100px">
											<input type="text" class="form-control text-right essential-bg width120px" alt="발주단가" id="order_price" name="order_price" datatype="int" required="required" value="${map.order_price}" format="num">
										</div>
										<div class="col width50px" id="order_price_name">원</div>
									</div>
								</td>
							</tr>
                            <tr>
								<th class="text-right">판매가격리스트</th>
								<td>
									<div class="form-row inline-pd widthfix">
                                        <div class="col width100px">
                                            <input type="text" class="form-control text-right" value="${map.list_sale_price }" id="list_sale_price" name="list_sale_price" format="num" readonly>
                                        </div>
                                        <div class="col width33px">원</div>
                                    </div>
								</td>
                                <th class="text-right">최저판매가격</th>
								<td>
									<div class="form-row inline-pd widthfix">
                                        <div class="col width100px">
                                            <input type="text" class="form-control text-right" value="${map.min_sale_price }" id="min_sale_price" name="min_sale_price" format="num" readonly>
                                        </div>
                                        <div class="col width33px">원</div>
                                    </div>
								</td>
								<th class="text-right essential-item">기종/규격</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-5">
											<select id="machine_type_cd" name="machine_type_cd" class="form-control essential-bg" alt="기종" required="required" onchange="javascript:fnMachineSubTypeList();">
												<option value="" ${map.machine_type_cd == "" ? 'selected' : ''} >- 선택 -</option>
												<c:forEach items="${codeMap['MACHINE_TYPE']}" var="item">
													<option value="${item.code_value}" ${item.code_value == map.machine_type_cd ? 'selected' : ''}>${item.code_name}</option>
												</c:forEach>
											</select>
										</div>
										<div class="col-4">
											<select id="machine_sub_type_cd" name="machine_sub_type_cd" class="form-control essential-bg" alt="규격" required="required">
												<option value="" ${map.machine_sub_type_cd == "" ? 'selected' : ''}>- 선택 -</option>
												<c:forEach items="${list}" var="item">
													<option value="${item.code}" ${item.code == map.machine_sub_type_cd ? 'selected' : ''}>${item.code_name}</option>
												</c:forEach>
											</select>
										</div>
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right">일괄발송서류</th>
								<td>
									<div class="table-attfile file_div" style="width:100%;">
										<div class="table-attfile" style="float:left">
										<button type="button" class="btn btn-primary-gra mr10" name="fileAddBtn" id="fileAddBtn" onclick="javascript:fnAddFile();">파일찾기</button>
										&nbsp;&nbsp;
										<c:if test="${not empty map.file.file_seq }">
											<div class="table-attfile-item file_1" style="float:left; display:block;">
												<a href="javascript:fileDownload('${map.file.file_seq}');" style="color: blue;">${map.file.origin_file_name}</a>&nbsp;
												<input type="hidden" name="file_seq" value="${map.file.file_seq}"/>
												<button type="button" class="btn-default" onclick="javascript:fnRemoveFile('1', '${map.file.file_seq}')"><i class="material-iconsclose font-18 text-default"></i></button>
											</div>
										</c:if>
										</div>
									</div>
								</td>
                                <th class="text-right essential-item">판매진행</th>
								<td>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="sale_y" name="sale_yn" value="Y" ${map.sale_yn eq 'Y' ? 'checked' : '' }>
										<label class="form-check-label" for="sale_y">Y</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="sale_n" name="sale_yn" value="N" ${map.sale_yn eq 'N' ? 'checked' : '' }>
										<label class="form-check-label" for="sale_n">N</label>
									</div>
								</td>
                                <th class="text-right essential-item">원동기형식1</th>
								<td>
									<input type="text" class="form-control essential-bg width140px" alt="원동기형식1" id="motor_type" name="motor_type" required="required" value="${map.motor_type}">
								</td>
							</tr>
                            <tr>
                            	<th class="text-right essential-item">화폐구분</th>
								<td colspan="3" >
									<%-- [재호 - Q&A 15585] 화폐구분 통일 --%>
									<c:forEach var="item" items="${codeMap['MONEY_UNIT']}">
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" id="money_unit_${item.code_value}" name="money_unit_cd" onclick="javascript:fnMoneyUnitChanged('${item.code_value}')" value="${item.code_value}" ${map.money_unit_cd eq item.code_value ? 'checked' : '' }>
											<label class="form-check-label" for="money_unit_${item.code_value}">${item.code_desc}</label>
										</div>
									</c:forEach>
<%--									<div class="form-check form-check-inline">--%>
<%--										<input class="form-check-input" type="radio" id="money_unit_krw" name="money_unit_cd" onclick="javascript:fnMoneyUnitChanged()" value="KRW" ${map.money_unit_cd eq 'KRW' ? 'checked' : '' }>--%>
<%--										<label class="form-check-label" for="money_unit_krw">원(W)</label>--%>
<%--									</div>--%>
<%--									<div class="form-check form-check-inline">--%>
<%--										<input class="form-check-input" type="radio" id="money_unit_jpy" name="money_unit_cd" onclick="javascript:fnMoneyUnitChanged()" value="JPY" ${map.money_unit_cd eq 'JPY' ? 'checked' : '' }>--%>
<%--										<label class="form-check-label" for="money_unit_jpy">엔(Y)</label>--%>
<%--									</div>--%>
<%--									<div class="form-check form-check-inline">--%>
<%--										<input class="form-check-input" type="radio" id="money_unit_usd" name="money_unit_cd" onclick="javascript:fnMoneyUnitChanged()" value="USD" ${map.money_unit_cd eq 'USD' ? 'checked' : '' }>--%>
<%--										<label class="form-check-label" for="money_unit_usd">달러($)</label>--%>
<%--									</div>--%>
<%--									<div class="form-check form-check-inline">--%>
<%--										<input class="form-check-input" type="radio" id="money_unit_cny" name="money_unit_cd" onclick="javascript:fnMoneyUnitChanged()" value="CNY" ${map.money_unit_cd eq 'CNY' ? 'checked' : '' }>--%>
<%--										<label class="form-check-label" for="money_unit_cny">위안(C)</label>--%>
<%--									</div>--%>
<%--									<div class="form-check form-check-inline">--%>
<%--										<input class="form-check-input" type="radio" id="money_unit_eur" name="money_unit_cd" onclick="javascript:fnMoneyUnitChanged()" value="EUR" ${map.money_unit_cd eq 'EUR' ? 'checked' : '' }>--%>
<%--										<label class="form-check-label" for="money_unit_eur">유로(E)</label>--%>
<%--									</div>--%>
								</td>
								<th class="text-right">원동기형식2</th>
								<td>
									<input type="text" class="form-control width140px" alt="원동기형식2" id="motor_type_2" name="motor_type_2" value="${map.motor_type_2}">
								</td>
							</tr>
                            <tr>
								<th class="text-right essential-item">사용여부</th>
								<td>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="use_y" name="use_yn" value="Y" ${map.use_yn eq 'Y' ? 'checked' : '' }>
										<label class="form-check-label" for="use_y">사용</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="use_n" name="use_yn" value="N" ${map.use_yn eq 'N' ? 'checked' : '' }>
										<label class="form-check-label" for="use_n">사용안함</label>
									</div>
								</td>
                                <th class="text-right essential-item">CAP적용대상</th>
								<td>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="cap_y" name="cap_yn" value="Y" ${map.cap_yn eq 'Y' ? 'checked' : '' }>
										<label class="form-check-label" for="cap_y">적용</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="cap_n" name="cap_yn" value="N" ${map.cap_yn eq 'N' ? 'checked' : '' }>
										<label class="form-check-label" for="cap_n">미적용</label>
									</div>
								</td>
                                <th class="text-right">YK취급여부</th>
								<td>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="yk_sale_y" name="yk_sale_yn" value="Y" ${map.yk_sale_yn eq 'Y' ? 'checked' : '' }>
										<label class="form-check-label" for="yk_sale_y">Y</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="yk_sale_n" name="yk_sale_yn" value="N" ${map.yk_sale_yn eq 'N' ? 'checked' : '' }>
										<label class="form-check-label" for="yk_sale_n">N</label>
									</div>
								</td>
							</tr>
                            <tr>
								<%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체 --%>
								<%--<th class="text-right">대리점최저공급가</th>--%>
								<th class="text-right">위탁판매점최저공급가</th>
								<td>
									<div class="form-row inline-pd widthfix">
                                        <div class="col width100px">
                                            <input type="text" class="form-control text-right" value="${map.agency_min_sale_price }" id="agency_min_sale_price" name="agency_min_sale_price" format="num" readonly>
                                        </div>
                                        <div class="col width33px">원</div>
                                    </div>
								</td>
                                <th class="text-right">센터DI적용대상</th>
								<td>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="center_di_y" name="center_di_yn" value="Y" ${map.center_di_yn eq 'Y' ? 'checked' : '' }>
										<label class="form-check-label" for="center_di_y">적용</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="center_di_n" name="center_di_yn" value="N" ${map.center_di_yn eq 'N' ? 'checked' : '' }>
										<label class="form-check-label" for="center_di_n">미적용</label>
									</div>
								</td>
                                <th class="text-right">SA-R적용대상</th>
								<td>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="sar_y" name="sar_yn" value="Y" ${map.sar_yn eq 'Y' ? 'checked' : '' }>
										<label class="form-check-label" for="sar_y">적용</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="sar_n" name="sar_yn" value="N" ${map.sar_yn eq 'N' ? 'checked' : '' }>
										<label class="form-check-label" for="sar_n">미적용</label>
									</div>
								</td>
							</tr>
                            <tr>
                                <th class="text-right">프로모션가(본사)</th>
								<td>
									<div class="form-row inline-pd widthfix">
                                        <div class="col width100px">
                                            <input type="text" class="form-control text-right" value="${map.base_pro_sale_price }" id="base_pro_sale_price" name="base_pro_sale_price" format="num" readonly>
                                        </div>
                                        <div class="col width33px">원</div>
                                    </div>
								</td>
                                <th class="text-right">정기검사주기</th>
								<td>
									<input type="text" class="form-control width60px" id="check_cycle_year" name="check_cycle_year" datatype="int" value="${map.check_cycle_year}">
								</td>
                                <th class="text-right">구코드</th>
								<td>
									<input type="text" class="form-control width140px" id="old_machine_name" name="old_machine_name" value="${map.old_machine_name}">
								</td>
							</tr>
                            <tr>
								<%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체 --%>
                                <%--<th class="text-right">프로모션공급가(대리점)</th>--%>
                                <th class="text-right">프로모션공급가(위탁판매점)</th>
								<td>
									<div class="form-row inline-pd widthfix">
                                        <div class="col width100px">
                                            <input type="text" class="form-control text-right" value="${map.agency_pro_sale_price }" id="agency_pro_sale_price" name="agency_pro_sale_price" format="num" readonly>
                                        </div>
                                        <div class="col width33px">원</div>
                                    </div>
								</td>
                                <th class="text-right">작성전결</th>
								<td>
                                    <div class="form-row inline-pd widthfix">
                                        <div class="col width100px">
                                            <input type="text" class="form-control text-right" value="${map.write_price }" id="write_price" name="write_price" format="num" readonly>
                                        </div>
                                        <div class="col width33px">원</div>
                                    </div>
								</td>
                                <th class="text-right">등록자/수정자</th>
								<td>
									<c:if test='${empty map.upt_mem_no}'>
										<input type="text" class="form-control width140px" readonly value="${map.reg_mem_name} <fmt:formatDate value="${map.reg_date}" pattern="yyyy-MM-dd"/>">
									</c:if>
									<c:if test='${!empty map.upt_mem_no}'>
										<input type="text" class="form-control width240px" readonly value="${map.reg_mem_name} <fmt:formatDate value="${map.reg_date}" pattern="yyyy-MM-dd"/> / ${map.upt_mem_name} <fmt:formatDate value="${map.upt_date}" pattern="yyyy-MM-dd"/>">
									</c:if>
								</td>
							</tr>
                            <tr>
								<%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체 --%>
                                <%--<th class="text-right">대리점수수료</th>--%>
                                <th class="text-right">위탁판매점수수료</th>
								<td>
                                    <div class="form-row inline-pd widthfix">
                                        <div class="col width100px">
                                            <input type="text" class="form-control text-right" value="${map.ma_agency_margin_amt }" id="ma_agency_margin_amt" name="ma_agency_margin_amt" format="num" readonly>
                                        </div>
                                        <div class="col width33px">원</div>
                                    </div>
								</td>
                                <th class="text-right">심사전결</th>
								<td>
                                    <div class="form-row inline-pd widthfix">
                                        <div class="col width100px">
                                            <input type="text" class="form-control text-right" value="${map.review_price }" id="review_price" name="review_price" format="num" readonly>
                                        </div>
                                        <div class="col width33px">원</div>
                                    </div>
								</td>
                                <th class="text-right">기간차트첨부</th>
								<td>
									<div class="table-attfile chart_file_div" style="width:100%;">
										<div class="table-attfile" style="float:left">
											<button type="button" class="btn btn-primary-gra mr10" name="fileAddBtn1" id="fileAddBtn1" onclick="javascript:goSearchFile();">파일찾기</button>&nbsp;&nbsp;
										</div>
									</div>
								</td>
							</tr>
                            <tr>
                                <th class="text-right">할인한도</th>
                                <td>
                                    <div class="form-row inline-pd widthfix">
                                        <div class="col width100px">
                                            <input type="text" class="form-control text-right" value="${map.max_dc_price}" id="max_dc_price" name="max_dc_price" format="num" readonly>
                                        </div>
                                        <div class="col width33px">원</div>
                                    </div>
								</td>
                                <th class="text-right">합의전결</th>
								<td>
                                    <div class="form-row inline-pd widthfix">
                                        <div class="col width100px">
                                            <input type="text" class="form-control text-right" value="${map.agree_price }" id="agree_price" name="agree_price" format="num" readonly>
                                        </div>
                                        <div class="col width33px">원</div>
                                    </div>
								</td>
                                <th class="text-right">지정출고</th>
								<td>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="fix_out_y" name="fix_out_yn" value="Y" ${map.fix_out_yn eq 'Y' ? 'checked' : '' }>
										<label class="form-check-label" for="fix_out_y">적용</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="fix_out_n" name="fix_out_yn" value="N" ${map.fix_out_yn eq 'N' ? 'checked' : '' }>
										<label class="form-check-label" for="fix_out_n">미적용</label>
									</div>
								</td>
							</tr>
                            <tr>
								<th class="text-right">적용일자</th>
								<td>
									<input type="text" class="form-control width120px" id="change_dt" name="change_dt" readonly value="${map.change_dt}" dateformat="yyyy-MM-dd">
								</td>
                                <th class="text-right">MMS 발송용 카다로그</th>
								<td>
                                	<input type="text" class="form-control" style="width: 100%;" id="catalog_url" name="catalog_url" placeholder="https://erp.sunnyyk.co.kr/" value="${map.catalog_url}">
								</td>
                                <th class="text-right">출하증명서발급</th>
								<td>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="out_certi_y" name="out_certi_yn" value="Y" ${map.out_certi_yn eq 'Y' ? 'checked' : '' }>
										<label class="form-check-label" for="out_certi_y">적용</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="out_certi_n" name="out_certi_yn" value="N" ${map.out_certi_yn eq 'N' ? 'checked' : '' }>
										<label class="form-check-label" for="out_certi_n">미적용</label>
									</div>
								</td>
							</tr>
						</tbody>
					</table>

					<div class="title-wrap mt10">
						<div class="doc-info" style="flex: 1;">
							<h4>출하증명서 제원</h4>
						</div>
					</div>
					<table class="table-border mt5">
						<colgroup>
							<col width="135px">
							<col width="">
							<col width="135px">
							<col width="">
							<%-- <col width="135px">
							<col width="">
							<col width="135px">
							<col width=""> --%>
						</colgroup>
						<tbody>
							<tr>
								<th class="text-right">사용유종</th>
								<td>
									<input type="text" class="form-control" id="use_oil" name="use_oil" value="${map.use_oil}" maxlength="24" >
								</td>
								<th class="text-right">상용출력</th>
								<td>
									<input type="text" class="form-control" id="normal_power" name="normal_power" value="${map.normal_power}" maxlength="24">
								</td>
							</tr>
							<tr>
								<th class="text-right">총중량</th>
								<td>
									<input type="text" class="form-control" id="total_weight" name="total_weight" value="${map.total_weight}" maxlength="24">
								</td>
								<th class="text-right">규격</th>
								<td>
									<input type="text" class="form-control" id="mch_std" name="mch_std" value="${map.mch_std}" maxlength="24">
								</td>
							</tr>
						</tbody>
					</table>
				</div>
            </div>
<!-- /우측 폼테이블 -->
			</div>
<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">
				<div class="right">
<%--					<button type="button" class="btn btn-info" onclick="javascript:fnMachinePriceHistoryPopup()">판매가 변동내역</button>--%>
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
        </div>
    </div>
<!-- /팝업 -->
</div>
</form>
</body>
</html>
