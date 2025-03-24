<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp" /><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt"%><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%><%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 계약관리 > 계약/출하 > null > 계약품의서 간편등록(스탭5 기타의견)
-- 작성자 : 김태훈
-- 최초 작성일 : 2021-04-09 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<script>

	// 등록대행 비용 = 기준판매가의 4% (21.4.27 신정애 쪽지 참고)
	function fnCalcProxyAmt() {
		var regProxyAmt = "";
		var proxyCheck = $M.getValue("reg_proxy_yn_check");
		if (proxyCheck != "") {
			var salePrice = $M.getValue("sale_price");
			if (salePrice == "") {
				alert("기준판매가가 없습니다.");
			}
			regProxyAmt = salePrice * 0.04;
		}
		$M.setValue("reg_proxy_amt", regProxyAmt);
	}

	// 결재요청
	function goAppr() {
		// 결재요청하기 전에 스탭1~4까지 다시 확인함
		if (fnCheckStep1() == false) {
			fnMoveStep(1);
			return false;
		}
		if (fnCheckStep2() == false) {
			fnMoveStep(2);
			return false;
		}
		if (fnCheckStep3() == false) {
			fnMoveStep(3);
			return false;
		}
		if (fnCheckStep4() == false) {
			fnMoveStep(4);
			return false;
		}

		// Yk렌탈장비일때 서류 체크안함
		if ($M.getValue("cust_no") != "20130603145119670") {
			// if ($M.getValue("file_seq_integrated_contract") == "") {
			if ($M.getValue("file_seq_mch_contract") == "") {
				alert("결재요청하려면, 장비계약서를 저장해주세요.");
				return false;
			}
			if ($M.getValue("file_seq_per_agree_contract") == "") {
				alert("결재요청하려면, 개인정보동의서를 저장해주세요.");
				return false;
			}

			// CAP 체크시 첨부파일 필수 체크 추가
			if ($("#cap_yn_check").is(":checked") && $M.getValue("file_seq_cap_contract") === "") {
				alert("결재요청하려면, CAP계약서를 저장해주세요.");
				return false;
			}

			// SA-R 체크시 첨부파일 필수 체크 추가
			if ($("#sar_yn_check").is(":checked") && $M.getValue("file_seq_sar_contract") == "") {
				alert("결재요청하려면, SA-R계약서를 저장해주세요.");
				return false;
			}
		}

		$M.getValue("center_di_yn_check") == "" ? $M.setValue("center_di_yn", "N") : $M.setValue("center_di_yn", "Y");
		$M.getValue("cap_yn_check") == "" ? $M.setValue("cap_yn", "N") : $M.setValue("cap_yn", "Y");
		$M.getValue("sar_yn_check") == "" ? $M.setValue("sar_yn", "N") : $M.setValue("sar_yn", "Y");
		$M.getValue("reg_proxy_yn_check") == "" ? $M.setValue("reg_proxy_yn", "N") : $M.setValue("reg_proxy_yn", "Y");
		$M.getValue("cost_taxbill_yn_check") == "" ? $M.setValue("cost_taxbill_yn", "N") : $M.setValue("cost_taxbill_yn", "Y");
		$M.getValue("assist_yn_check") == "" ? $M.setValue("assist_yn", "N") : $M.setValue("assist_yn", "Y");

		if($M.getValue("cap_yn_check") == ""){
			$M.setValue("file_seq_cap_contract","");
		}

		if($M.getValue("sar_yn_check") == ""){
			$M.setValue("file_seq_sar_contract","");
		}

		if($M.getValue("assist_yn_check") == ""){
			// $M.setValue("file_seq_assist_contract","");
			$M.setValue("file_seq_assist_contract_06","");
			$M.setValue("file_seq_assist_contract_13","");
			$M.setValue("file_seq_assist_contract_14","");
			$M.setValue("file_seq_assist_contract_15","");
			$M.setValue("file_seq_assist_contract_16","");
		}

		var frm = $M.toValueForm(document.main_form);
		var concatCols = [];
		var concatList = [];

		// 유상 그리드 업데이트
		AUIGrid.removeSoftRows(auiGridPart);
		AUIGrid.resetUpdatedItems(auiGridPart);

		// 무상 그리드 업데이트
		AUIGrid.removeSoftRows(auiGridPartFree);
		AUIGrid.resetUpdatedItems(auiGridPartFree);

		// 임의비용 그리드 업데이트
		AUIGrid.removeSoftRows(auiGridOppCost);
		AUIGrid.resetUpdatedItems(auiGridOppCost);

		AUIGrid.updateAllToValue(auiGridPart, "paid_free_yn", "N");
		AUIGrid.updateAllToValue(auiGridPartFree, "free_free_yn", "Y");

		var gridIds = [auiGridBasic, auiGridOption, auiGridAttach, auiGridPart, auiGridPartFree, auiGridOppCost];
		for (var i = 0; i < gridIds.length; ++i) {
			concatList = concatList.concat(AUIGrid.exportToObject(gridIds[i]));
			concatCols = concatCols.concat(fnGetColumns(gridIds[i]));
		}
		var gridFrm = fnGridDataToForm(concatCols, concatList);
		$M.copyForm(gridFrm, frm);

		var msg = "결재 요청 하시겠습니까?\n요청 후 수정이 불가능 합니다";
		$M.goNextPageAjaxMsg(msg, this_page+"/save", gridFrm, {method : 'POST'},
			function(result) {
		    	if(result.success) {
		    		// 여기서 뒤로가기
		    		fnClose();
				}
			}
		);
	}

	// 제출서류
	// 파일첨부팝업
	// function goFileUploadPopup(type) {
	// 	var param = {
	// 		upload_type : 'MC',
	// 		file_type : 'both',
	// 		file_ext_type : 'pdf#img',
	// 		max_size : 5000
	// 	}
	// 	submitType = type+"";
	// 	openFileUploadPanel('fnSetFile', $M.toGetParam(param));
	// }

	// 제출서류
	// 파일첨부팝업 (그룹다중 드래그앤드롭 적용)
	function goFileUploadPopup(type) {
		var maxCount = 1;
		var param = {
			upload_type : 'MC',
			file_type : 'both',
			file_ext_type : 'pdf#img',
			max_size : 5000
		}

		// 파일 정보 세팅
		// jsonData :
		//    - type_id : 파일을 지정할 각 항목 (각 영역의 HTML 태그 ID)
		//    - type_name : 파일을 지정할 항목의 필드명
		//    - max_count : 각 항목마다 파일첨부 최대 개수 (각각 지정 가능)
		//    - file_seq_str : 각 항목마다 기존에 있던 file_seq를 '#'으로 묶음

		var fileList = [];

		$("[name='fileAttach']").each(function () {
			var isCheckedTypeYn = $(this).attr("checkd_type_yn");

			if("Y" == isCheckedTypeYn) {
				var chekcdTagId = $(this).attr("checked_id");
				if($("#"+chekcdTagId).is(":checked") == false) {
					return true;
				}
			}

			var tempObj = {};
			tempObj.type_id = $(this).attr("id");
			tempObj.type_name = $(this).attr("type_name");
			tempObj.max_count = maxCount;
			var fileSeqs = [];
			$(this).find('input').each(function() {
				fileSeqs.push($(this).val());
			})
			tempObj.file_seq_str = $M.getArrStr(fileSeqs);

			fileList.push(tempObj);
		})

		var jsonData = {}
		jsonData.file_list = fileList;

		openFileUploadGroupMultiPanel('fnSetFile', $M.toGetParam(param), jsonData);
	}

	// 파일세팅
	function fnSetFile(result) {
		var fileList = result.list;

		// 기존 파일들 삭제
		$('.typeDiv').remove();
		// 파일찾기 버튼 삭제
		$("[name=fileAttach]").parent().children('button').remove();

		for (var item in fileList) {
			var typeId = item;

			for (var i = 0; i < fileList[typeId].length; i++) {
				var fileSeq = fileList[typeId][i].file_seq;
				var fileExt = fileList[typeId][i].file_ext;
				var fileName = fileList[typeId][i].file_name;
				var fileSize = fileList[typeId][i].file_size;

				var str = '';
				str += '<div class="table-attfile-item submit_' + typeId + ' typeDiv" id="'+typeId+'">';
				if (fileExt == "pdf") {
					str += '<a href="javascript:fileDownload(' + fileSeq + ');">' + fileName + '</a>&nbsp;';
				} else {
					str += '<a href="javascript:fnLayerImage(' + fileSeq + ');">' + fileName + '</a>&nbsp;';
				}
				// str += '<input type="hidden" name="file_seq_'+submitType+'" value="' + fileSeq + '"  />';
				str += '<input type="hidden" name="file_seq_'+typeId+'" value="' + fileSeq + '"  />';
				str += '<button type="button" class="btn-default check-dis" onclick="javascript:fnRemoveFile(\'' +  typeId + '\')"><i class="material-iconsclose font-18 text-default"></i></button>';
				str += '</div>';
				$('#'+typeId).append(str);
				$("#btn_submit_"+typeId).remove();
			}
		}

		// 파일찾기 버튼 다시 그려주기
		$("[name=fileAttach]").each(function (){
			var tagId = $(this).attr('id');

			if (fileList.hasOwnProperty(tagId) == false) {
				var str = '<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goFileUploadPopup()" id="btn_submit_'+tagId+'">파일찾기</button>'
				$(this).parent().append(str);
			}
		});

	}

	// 파일삭제
	function fnRemoveFile(typeId) {
		console.log(typeId);
		var result = confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.");
		if (result) {
			$(".submit_" + typeId).remove();
			var str = '<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goFileUploadPopup(\''+typeId+'\')" id="btn_submit_'+typeId+'">파일찾기</button>'
			// $('.submit_'+typeId+'_div').append(str);
			$('#'+typeId).append(str);
		} else {
			return false;
		}
	}

	// // 파일세팅
	// function fnSetFile(file) {
	// 	var str = '';
	// 	str += '<div class="table-attfile-item submit_' + submitType + '">';
	// 	if (file.file_ext == "pdf") {
	// 		str += '<a href="javascript:fileDownload(' + file.file_seq + ');">' + file.file_name + '</a>&nbsp;';
	// 	} else {
	// 		str += '<a href="javascript:fnLayerImage(' + file.file_seq + ');">' + file.file_name + '</a>&nbsp;';
	// 	}
	// 	str += '<input type="hidden" name="file_seq_'+submitType+'" value="' + file.file_seq + '"/>';
	// 	str += '<button type="button" class="btn-default check-dis" onclick="javascript:fnRemoveFile(\'' +  submitType + '\')"><i class="material-iconsclose font-18 text-default"></i></button>';
	// 	str += '</div>';
	// 	$('.submit_'+submitType+'_div').append(str);
	// 	$("#btn_submit_"+submitType).remove();
	// }
	//
	// // 파일삭제
	// function fnRemoveFile(type) {
	// 	console.log(type);
	// 	var result = confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.");
	// 	if (result) {
	// 		$(".submit_" + type).remove();
	// 		var str = '<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goFileUploadPopup(\''+type+'\')" id="btn_submit_'+type+'">파일찾기</button>'
	// 		$('.submit_'+type+'_div').append(str);
	// 	} else {
	// 		return false;
	// 	}
	// }

    function fnLayerImage(fileSeq) {
//     	$M.goNextPageLayerImage("${inputParam.ctrl_host}" + "/file/svc/" + fileSeq);
		var params = {
				file_seq : fileSeq
		};

		var popupOption = "";
		$M.goNextPage('/comp/comp0709', $M.toGetParam(params), {popupStatus : popupOption});
    }

	// 보조 체크시 특이사항에 문구 추가.
	function fnAssistCheck() {
		if ($("#assist_yn_check").is(":checked")) {
			$("#remark").attr("placeholder", "보조사업 계약의 경우 이행하자기간 및 % 기재");
		} else {
			$("#remark").attr("placeholder", "");
		}
	}
</script>
<div class="step-title" style="display: inline-block;">
	<span class="step-num">step05</span> <span class="step-title">기타의견</span>
</div>
<div style="display: inline-block; width: 50%; float: right;">
	<jsp:include page="/WEB-INF/jsp/common/apprHeader.jsp"></jsp:include>
</div>
<ul class="step-info">
	<li>특이사항 및 의견을 작성하시기 바랍니다.</li>
	<li>작성이 끝나면 하단에 &lt;결재요청&gt;버튼을 클릭하시면 계약품의서 등록이 완료됩니다.</li>
</ul>
<table class="table-border">
	<colgroup>
		<col width="">
		<col width="">
		<col width="">
		<col width="">
	</colgroup>
	<thead>
		<tr>
			<th>고객명</th>
			<th>휴대폰</th>
			<th>모델명</th>
			<th>출하희망일</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td class="text-center cust_name_view"></td>
			<td class="text-center hp_no_view"></td>
			<td class="text-center machine_name_view"></td>
			<td class="text-center receive_plan_dt_view"></td>
		</tr>
	</tbody>
</table>

<!-- 기획에는 없지만 CAP 등을 추가함 -->
<div class="title-wrap mt5">
	<h4>부가정보</h4>
</div>
<div id="ynWrapper">
	<table class="table-border doc-table mt5" id="yCnt">
		<tbody>
			<tr>
				<th class="diYn">센터 DI</th>
				<td class="text-center diYn">
					<div class="form-check">
						<input class="form-check-input position-static mt0" type="checkbox" name="center_di_yn_check" value="Y">
					</div>
				</td>
				<th class="capYn">CAP</th>
				<td class="text-center capYn">
					<div class="form-check">
						<input class="form-check-input position-static mt0" type="checkbox" id="cap_yn_check" name="cap_yn_check" value="Y">
					</div>
				</td>
				<th class="sarYn">SA-R</th>
				<td class="text-center sarYn">
					<div class="form-check">
						<input class="form-check-input position-static mt0" type="checkbox" id="sar_yn_check" name="sar_yn_check" value="Y">
					</div>
				</td>
				<th class="proxyYn" style="width: 67px;">등록대행</th>
				<td class="text-center proxyYn" style="width: 157px">
					<div class="form-check">
						<input class="form-check-input position-static mt0" style="margin-right: 5px;" type="checkbox" id="reg_proxy_yn_check" name="reg_proxy_yn_check" onclick="fnCalcProxyAmt()" value="Y">
						<input type="text" id="reg_proxy_amt" name="reg_proxy_amt" format="decimal" class="form-control text-right" style="width: 100px; display: inline-block;" readonly="readonly"><span style="margin-left: 5px;">원</span>
					</div>
				</td>
				<th class="assistYn">보조</th>
				<td class="text-center assistYn">
					<div class="form-check">
						<input class="form-check-input position-static mt0" type="checkbox" id="assist_yn_check" name="assist_yn_check" onchange="javascript:fnAssistCheck();">
					</div>
				</td>
			</tr>
		</tbody>
	</table>
</div>

<!-- 특이사항 및 담당자 의견 -->
<%--<div class="title-wrap mt5">--%>
<%--	<h4>특이사항 및 담당자 의견</h4>--%>
<%--</div>--%>
<%--<textarea class="form-control mt5" style="height: 50px;" name="remark" id="remark"></textarea>--%>
<div class="row">
	<div class="col-6">
		<div class="title-wrap mt5">
			<h4>담당자 의견</h4>
		</div>
		<textarea class="form-control mt5" style="height: 100px;" name="remark" id="remark"></textarea>
	</div>
	<div class="col-6">
		<div class="title-wrap mt5">
			<h4>특약사항</h4>
		</div>
		<textarea class="form-control mt5" style="height: 100px;" name="special_remark" id="special_remark"></textarea>
	</div>
</div>
<div id="submitList">
	<div class="title-wrap mt10">
		<h4>제출서류</h4>
		<div class="btn-group mt5">
			<div class="right">
				<button type="button" class="btn btn-primary-gra" onclick="javascript:goFileUploadPopup()" id="btn_submit_">파일찾기</button>
			</div>
		</div>
	</div>
	<table class="table-border doc-table mt5">
		<colgroup>
			<col width="20%">
			<col width="">
		</colgroup>
		<thead>
			<tr>
				<th class="title-bg">제출서류명</th>
				<th class="title-bg">첨부파일</th>
			</tr>
		</thead>
		<tbody>
<%--			<c:if test="${agency_yn eq 'Y'}">--%>
				<tr>
					<th id="title_mch_contract1">장비계약서</th>
					<td>
						<div class="table-attfile submit_01_div">
							<div name="fileAttach" id="mch_contract" type_name="장비계약서" checkd_type_yn="N">
							</div>
							<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goFileUploadPopup()" id="btn_submit_mch_contract">파일찾기</button>
						</div>
					</td>
				</tr>
				<tr class="capFileYn" style="display:none;">
					<th class="rs">CAP계약서</th>
					<td>
						<div class="table-attfile submit_02_div">
							<div name="fileAttach" id="cap_contract" type_name="CAP계약서" checkd_type_yn="Y" checked_id="cap_yn_check" >
							</div>
							<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goFileUploadPopup()" id="btn_submit_cap_contract">파일찾기</button>
						</div>
					</td>
				</tr>
				<tr class="sarFileYn" style="display:none;">
					<th class="rs">SA-R계약서</th>
					<td>
						<div class="table-attfile submit_03_div">
							<div name="fileAttach" id="sar_contract" type_name="SA-R계약서" checkd_type_yn="Y" checked_id="sar_yn_check" >
							</div>
							<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goFileUploadPopup()" id="btn_submit_sar_contract">파일찾기</button>
						</div>
					</td>
				</tr>
<%--			</c:if>--%>
<%--			<c:if test="${agency_yn eq 'N'}">--%>
<%--				<tr>--%>
<%--					<th id="title_mch_contract2">통합계약서</th>--%>
<%--					<td>--%>
<%--						<div class="table-attfile submit_07_div">--%>
<%--							<div name="fileAttach" id="integrated_contract" type_name="통합계약서" checkd_type_yn="N">--%>
<%--							</div>--%>
<%--							<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goFileUploadPopup()" id="btn_submit_integrated_contract">파일찾기</button>--%>
<%--						</div>--%>
<%--					</td>--%>
<%--				</tr>--%>
<%--			</c:if>--%>
			<tr>
				<th id="title_per_agree_contract">개인정보동의서</th>
				<td>
					<div class="table-attfile submit_04_div">
						<div name="fileAttach" id="per_agree_contract" type_name="개인정보동의서" checkd_type_yn="N">
						</div>
						<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goFileUploadPopup()" id="btn_submit_per_agree_contract">파일찾기</button>
					</div>
				</td>
			</tr>
<%--			<tr class="assistFileYn" style="display:none;">--%>
<%--				<th>보조</th>--%>
<%--				<td>--%>
<%--					<div class="table-attfile submit_06_div">--%>
<%--						<div name="fileAttach" id="assist_contract" type_name="보조" checkd_type_yn="Y" checked_id="assist_yn_check">--%>
<%--						</div>--%>
<%--						<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goFileUploadPopup()" id="btn_submit_assist_contract">파일찾기</button>--%>
<%--					</div>--%>
<%--				</td>--%>
<%--			</tr>--%>
			<c:forEach items="${codeMap['MCH_SALE_DOC_FILE']}" var="item">
				<c:if test="${item.code_v2 eq '06'}">
					<tr class="assistFileYn" style="display:none;">
						<th>${item.code_name}</th>
						<td>
							<div class="table-attfile submit_${item.code_value}_div">
								<div name="fileAttach" id="assist_contract_${item.code_value}" type_name="${item.code_name}" checkd_type_yn="Y" checked_id="assist_yn_check">
								</div>
								<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goFileUploadPopup()" id="btn_submit_assist_contract_${item.code_value}">파일찾기</button>
							</div>
						</td>
					</tr>
				</c:if>
			</c:forEach>
		</tbody>
	</table>
</div>
<!-- /특이사항 및 담당자 의견 -->
<div class="btn-group mt10">
	<div class="right">
		<button type="button" class="btn btn-md btn-success" onclick="javascript:goAppr()">결재요청</button>
	</div>
</div>
