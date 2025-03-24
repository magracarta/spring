<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 계약관리 > 계약/출하 > null > 계약품의서상세
-- 작성자 : 김태훈
-- 최초 작성일 : 2019-12-19 14:23:48
-- 주요변경사항!
-- 2021.1.21 : 신정애씨가 대리점은 중고가격 바로 입력하게 해달라고함.(대리점일 경우 중고정보 탭 입력안하고, 바로 입력할수있게함)
-- 2022.10.27 : [erp3차] 계약취소/출하보류시 사유를 입력받을 수 있는 메모 기능 추가
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

	var isCust = true;
	var isMachine = true;
	var isRfq = false; // 견적서 참조로 등록한 경우 true, 장비 수정불가
	var optList = [];
	var auiGridOption; // 선택사항
	var auiGridAttach; // 어테치먼트
	var auiGridPart; // 유상부품
	var auiGridPartFree; // 기본지급품
	var auiGridOppCost; // 임의비용
	var auiGridCostApply; // 원가반영 (3차 QNA 14464)
	var auiGridBasic; // 기본제공품(hidden)
	var parentPaidList; // 유상부품 그리드 데이터 ( 유무상 팝업창으로 넘길 그리드 데이터)
	var parentFreeList; // 기본지급품 그리드 데이터 ( 유무상 팝업창으로 넘길 그리드 데이터)
	var parentOppCost; // 임의비용 그리드 데이터 ( 유무상 팝업창으로 넘길 그리드 데이터)
	var parentCostApply; // 원가반영 그리드 데이터 ( 유무상 팝업창으로 넘길 그리드 데이터) (3차 QNA 14464)
	var codeMapCostItemArray = JSON.parse('${codeMapJsonObj['COST_ITEM']}');
	var codeMapCostApplyArray = JSON.parse('${codeMapJsonObj['COST_APPLY']}');
	var machineDocStatus;
	var msgOnlyWriting = "작성중인 자료만 수정가능합니다.";

	var submitType = ""; // 첨부서류
	var codeMapDocFileArray = JSON.parse('${codeMapJsonObj['MCH_SALE_DOC_FILE']}');
	var isDaeCha = false; // 대차가 선택되었는지 확인하는 변수

	var submitList = ${fileSubmitList};

	$(document).ready(function() {
		// isOppInfoNeed();
		createAUIGrid();
		fnInitPage();
		fnToggle();

		fnCapCheck();
		fnSarCheck();
		fnDaeChaCheck();
		fnAssistCheck();
		fnCostTaxbillCheck();
	});

	// 차대선지정 센터 선택팝업
	function goRequestPreMachine(type) {
		var param = {
			s_machine_out_yn : "Y"
		};
		if (type == "CANCEL") {
			var obj = {
				org_code : "${pre_body_no_map.in_org_code}",
				machine_seq : "${pre_body_no_map.machine_seq}"
			};
			goRequestCancelPreMachineResult(obj);
		} else {
			openOrgMapCenterPanel('goRequestPreMachineResult', $M.toGetParam(param));
		}
	}

	// 차대 선지정 취소요청 쪽지발송
	function goRequestCancelPreMachineResult(temp) {
		temp["cancel_yn"] = "Y";
		goRequestPreMachineResult(temp);
	}

	// 차대 선지정 요청 쪽지발송
	function goRequestPreMachineResult(result) {
		if (result.org_code == "") {
			alert("센터가 지정되지 않았습니다.");
			return false;
		};

		setTimeout(function() {
			var param = {
				out_org_code : result.org_code,
				machine_doc_no : $M.getValue("machine_doc_no"),
		       	cust_name : $M.getValue("cust_name"), // 쪽지용
		       	machine_name : $M.getValue("machine_name"), // 쪽지용
		       	cancel_yn : result.cancel_yn
			}
			var msg = "차대선지정 요청하시겠습니까?";
			if (result.cancel_yn == "Y") {
				msg = "취소요청하시겠습니까?";
				param["machine_seq"] = "${pre_body_no_map.machine_seq}";
			}
			$M.goNextPageAjaxMsg(msg, "/sale/sale0101p01/requestPreMachine", $M.toGetParam(param), {method : 'POST'},
	    			function(result) {
	    		    	if(result.success) {
	    		    		if (result.already_send_yn == "Y") {
	    		    			if (confirm("이미 요청을 보냈습니다. 다시 보내시겠습니까?") == false) {
	    		    				return false;
	    		    			} else {
	    		    				param["force_request_yn"] = "Y";
	    		    				$M.goNextPageAjax("/sale/sale0101p01/requestPreMachine", $M.toGetParam(param), {method : 'POST'},
	    		    		    			function(result) {
	    		    		    		    	if(result.success) {

	    		    		    				}
	    		    		    			}
	    		    		    		);
	    		    			}
	    		    		}
	    				}
	    			}
	    		);
		}, 100);
	}

	// 가상계좌 문자 보내기
	function fnVirtualSendSms() {
		var param = {
			'name' : $M.getValue('cust_name'), // 고객명
			'hp_no' : $M.getValue('hp_no'), // 핸드폰 번호
			'menu_seq' : "${page.menu_seq}", // 메뉴 시퀀스
			'virtual_account_no' : "${virtual.virtual_account_no}", // 가상계좌 번호
			'req_msg_yn' : 'Y', // 발송 내용을 참조해서 받는지
			'ref_key' : $M.getValue('machine_doc_no'), // 참조키 (발송 내역 저장시 사용될 ref_key)
		}

		openSendSmsPanel($M.toGetParam(param));
	}

	// 가상계좌 문자 내역 조회
	function fnSmsHistory() {
		var param = {
			'machine_doc_no' : $M.getValue('machine_doc_no'), // 참조키 (발송 내역 저장시 사용될 ref_key)
		};

		$M.goNextPage('/comm/comm0203', $M.toGetParam(param), {popupStatus : ""});
	}

	// 가상계좌 연결
	function fnAssignVirtualAccount() {
		var param = {
			"machine_doc_no" : $M.getValue("machine_doc_no"),
		}

		$M.goNextPageAjax("/sale/assignvirtual", $M.toGetParam(param), {method : 'GET'},
				function(result) {
					if(result.success) {
						location.reload();
					}
				}
		);
	}

	// 서류저장
	function goSaveSubmit(noConfirm) {
		// 버튼을 눌렀을때만 물어봄(본창 저장 후 이어서 실행할때는 안물어봐야함!)
		console.log(noConfirm);

		<c:if test="${SecureUser.mem_no ne doc_mem_no}">
			alert("작성자만 서류를 저장할 수 있습니다.");
			return false;
		</c:if>

		if (noConfirm == undefined) {
			if (confirm("서류를 저장하시겠습니까?\n저장되지 않은 품의내용은 사라집니다.") == false) {
				return false;
			}
		}

		var machineDocNo = $M.getValue("machine_doc_no");

		var param = {};
		var codeArr = [];
		var fileSeqArr = [];
		// param["mch_sale_doc_file_cd"] = code;

		var array = codeMapDocFileArray.filter(function(value) {
		    return value.code_v1 == "계약";
		});

		var checkFileCnt = 0;

		for (var i = 0; i < array.length; ++i) {
			var code = array[i].code_value;
			var fileSeq = $M.getValue("file_seq_"+code);
			if (fileSeq != "") {
				codeArr.push(code);
				fileSeqArr.push(fileSeq);
				checkFileCnt++;
			} else {
				codeArr.push(code);
				fileSeqArr.push("0");
			}
		}

		// if (checkFileCnt == 0) {
		// 	alert("저장할 파일이 없습니다.");
		// 	return false;
		// }

		param["mch_sale_doc_file_cd_str"] = $M.getArrStr(codeArr);
		param["file_seq_str"] = $M.getArrStr(fileSeqArr);

		$M.goNextPageAjax(this_page+"/"+machineDocNo+"/submit", $M.toGetParam(param), {method : 'POST'},
			function(result) {
		    	if(result.success) {
		    		location.reload();
				}
			}
		);
	}

	// 담당확인
	function goConfirmSubmit() {
		var machineDocNo = $M.getValue("machine_doc_no");

		var param = {
    		type : "계약",
		};
		var codeArr = [];
		var ypnArr = [];

		var array = codeMapDocFileArray.filter(function(value) {
		    return value.code_v1 == "계약";
		});

		for (var i = 0; i < array.length; ++i) {
			var code = array[i].code_value;
			var ypn = $M.getValue("pass_ypn_"+code);
			var fileSeq = $M.getValue("file_seq_"+code);
			if (fileSeq != "") {
				if (ypn != "") {
					codeArr.push(code);
					ypnArr.push(ypn);
				} else {
					codeArr.push(code);
					ypnArr.push("P");
				}
			}
		}

		if (ypnArr.indexOf('Y') == -1 && ypnArr.indexOf('N') == -1) {
			alert("확인한 내용이 없습니다.");
			return false;
		}

		param["mch_sale_doc_file_cd_str"] = $M.getArrStr(codeArr);
		param["pass_ypn_str"] = $M.getArrStr(ypnArr);

		$M.goNextPageAjaxSave(this_page+"/"+machineDocNo+"/submitConfirm", $M.toGetParam(param), {method : 'POST'},
			function(result) {
		    	if(result.success) {
		    		location.reload();
				}
			}
		);
	}

	// 제출서류
	// 파일첨부팝업
	function goFileUploadPopup(type) {
		<c:if test="${SecureUser.mem_no ne doc_mem_no}">
			alert("작성자만 서류를 저장할 수 있습니다.");
			return false;
		</c:if>

		var param = {
			upload_type : 'MC',
			file_type : 'both',
			file_ext_type : 'pdf#img',
			max_size : 5000
		}

		var fileList = [];

		$("[name='fileAttach']").each(function () {
			var typeId = $(this).attr("id");

			// CAP계약서일 경우 체크여부 판단
			if (typeId == "tag_02" && $M.getValue("cap_yn_check") != "Y") {
				return true;
			}

			// SA-R계약서일 경우 체크여부 판단
			if (typeId == "tag_03" && $M.getValue("sar_yn_check") != "Y") {
				return true;
			}

			// 보조 계약서일 경우 체크여부 판단
			// if (typeId == "tag_06" && $M.getValue("assist_yn_check") != "Y") {
			// 	return true;
			// }
			if ((typeId == "tag_06" || typeId == "tag_13" || typeId == "tag_14" || typeId == "tag_15" || typeId == "tag_16") && $M.getValue("assist_yn_check") != "Y") {
				return true;
			}

			for (var i = 0; i < submitList.length; i++) {
				var passYpn = submitList[i].pass_ypn;
				var mchSaleDocFileCd = submitList[i].mch_sale_doc_file_cd;

				if (passYpn == "Y" && mchSaleDocFileCd == typeId.slice(-2, typeId.length)) {
					return true;
				}
			}

			if ($M.getValue("doc_mem_no") != "${SecureUser.mem_no}") {
				return true;
			}

			var maxCount = 1;
			// if (typeId == "tag_06") {
			// 	maxCount = 5;
			// }

			var tempObj = {};
			tempObj.type_id = typeId;
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
	function fnSetFile(file) {
		var fileList = file.list;

		for (var i = 0; i < submitList.length; i++) {
			var passYpn = submitList[i].pass_ypn;
			var mchSaleDocFileCd = submitList[i].mch_sale_doc_file_cd;

			if (passYpn != "Y") {
				// 기존 파일들 삭제
				$('#'+mchSaleDocFileCd).remove();
				$("#tag_"+mchSaleDocFileCd).children().remove();
				$("#tag_"+mchSaleDocFileCd).parent().children('button').remove();
			}
		}

		for (var item in fileList) {
			var typeId = item;

			for (var i = 0; i < fileList[typeId].length; i++) {
				var fileSeq = fileList[typeId][i].file_seq;
				var fileExt = fileList[typeId][i].file_ext;
				var fileName = fileList[typeId][i].file_name;
				var fileSize = fileList[typeId][i].file_size;

				var sliceTypeId = typeId.slice(-2, typeId.length);

		var str = '';
				str += '<div class="table-attfile-item submit_' + sliceTypeId + ' typeDiv" id="'+sliceTypeId+'">';
				if (fileExt == "pdf") {
					str += '<a href="javascript:openFileViewerPanel(' + fileSeq + ');">' + fileName + '</a>&nbsp;';
		} else {
					str += '<a href="javascript:fnLayerImage(' + fileSeq + ');">' + fileName + '</a>&nbsp;';
		}
				// str += '<input type="hidden" name="file_seq_'+submitType+'" value="' + fileSeq + '"  />';
				str += '<input type="hidden" name="file_seq_'+sliceTypeId+'" value="' + fileSeq + '"  />';
				str += '<button type="button" class="btn-default check-dis" onclick="javascript:fnRemoveFile(\'' +  sliceTypeId + '\')"><i class="material-iconsclose font-18 text-default"></i></button>';
		str += '</div>';
				$('#'+typeId).append(str);
				$("#btn_submit_"+sliceTypeId).remove();
			}
		}

		// 파일찾기 버튼 다시 그려주기
		$("[name=fileAttach]").each(function (){
			var tagId = $(this).attr('id');
			var sliceTagId = tagId.slice(-2, tagId.length);

			if (fileList.hasOwnProperty(tagId) == false) {
				var str = '<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goFileUploadPopup()" id="btn_submit_'+sliceTagId+'">파일찾기</button>'
				$(this).parent().append(str);
			}
		});

		// 담당자확인 - 적합일경우 파일찾기 버튼 삭제
		for (var i = 0; i < submitList.length; i++) {
			var passYpn = submitList[i].pass_ypn;
			var mchSaleDocFileCd = submitList[i].mch_sale_doc_file_cd;

			if (passYpn == "Y") {
				$("#tag_"+mchSaleDocFileCd).parent().children('button').remove();
			}
		}

		goSaveSubmit('NOCONFIRM');
	}

	// 파일삭제
	function fnRemoveFile(type) {
		<c:if test="${SecureUser.mem_no ne doc_mem_no}">
			alert("작성자만 서류를 저장할 수 있습니다.");
			return false;
		</c:if>

		// 장비계약서 파일인경우 ERP에서 삭제 불가능
		var param = {
			"file_type" : type,
			"machine_doc_no" : $M.getValue("machine_doc_no")
		}

		$M.goNextPageAjax(this_page + "/file/check/", $M.toGetParam(param), {method : 'GET'},
			function(result) {
				if(result.success) {
					console.log(type);
					var result = confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.");
					if (result) {
						$(".submit_" + type).remove();
						var str = '<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goFileUploadPopup(\''+type+'\')" id="btn_submit_'+type+'">파일찾기</button>'
						$('.submit_'+type+'_div').append(str);
					} else {
						return false;
					}
					goSaveSubmit('NOCONFIRM');
					fnCapCheck();
					fnSarCheck();
				} else {

				}
			}
		);
	}

    function fnLayerImage(fileSeq) {
//     	$M.goNextPageLayerImage("${inputParam.ctrl_host}" + "/file/svc/" + fileSeq);
		var params = {
				file_seq : fileSeq
		};

		var popupOption = "";
		$M.goNextPage('/comp/comp0709', $M.toGetParam(params), {popupStatus : popupOption});
    }

	// 등록대행 비용 = 기준판매가의 4% (21.4.27 신정애 쪽지 참고)
	function fnCalcProxyAmt() {
		var regProxyAmt = "";
		var proxyCheck = $M.getValue("reg_proxy_yn_check");
		if (proxyCheck != "") {
			// [재호] [3차-Q&A 14464] 등록대행비 산출 기준 변경 = 최종판매가의 4%
			var salePrice = $M.getValue("sale_amt");
			if (salePrice == "") {
				alert("기준판매가가 없습니다.");
			}
			regProxyAmt = salePrice * 0.04;
		}
		$M.setValue("reg_proxy_amt", regProxyAmt);
	}

	function fnInitPage() {
		var info = ${info}

		$M.setValue("sum_amt", "${virtual.sum_amt}");
		$M.setValue("in_max_amt", "${virtual.in_max_amt}");
		$M.setValue("__s_machine_doc_no", info.basicInfo.machine_doc_no);
		$M.setValue("__s_cust_no", info.basicInfo.cust_no);
		machineDocStatus = info.basicInfo.machine_doc_status_cd;
		if (machineDocStatus != "0") {
			$("#main_form :input").prop("disabled", true);
			$("#main_form :button").not("#addr").prop("disabled", false);
			$("#hp_no").prop("disabled", false);
			$("#btnUsedInit").prop("disabled", true);

			// disabled되면 그리드 내용 복사 안되서 추가
			$(".aui-grid :input").prop("disabled", false);
		}
		var codes = JSON.parse('${codeMapJsonObj['MACHINE_DOC_STATUS']}');
		for (var i = 0; i < codes.length; ++i) {
			if (codes[i].code_value == machineDocStatus) {
				$("#machine_doc_status_text").html(codes[i].code_name);
			}
		}
		if (info.basicInfo.cust_no != null) {
			isCust = true;
			$M.setValue("used_cust_name", info.basicInfo.cust_name);
			$M.setValue("used_hp_no", $M.phoneFormat(info.basicInfo.hp_no));
		}
		if (info.basicInfo.machine_name != null) {
			isMachine = true;
		}
		if (info.basicInfo.rfq_no != "") {
			console.log(info.basicInfo.rfq_no);
			isRfq = true;
			processDisabled(['cust_name'], true, null, null);
			var btnReferDom = $("#btnRefer");
			btnReferDom.css('display', 'block');
			btnReferDom.html("(견)"+info.basicInfo.rfq_no);
		}
		if (info.basicInfo.doc_org_gubun_cd != "AGENCY") {
			$("#plan_amt_4").attr('readonly', true);
		}
		if (machineDocStatus == "4") {
			$("#_goApprCancel").css("display", "none");
		}
		$("#submitList :input").prop("disabled", false);
		fnSetData(info);

		// Q&A 11704 결재중, 작성자x, 결재처리자 의경우 유무상 수정여부 용도 210629 김상덕
		if(machineDocStatus == 1 && "Y" == "${apprBean.appr_proc_yn}" && $M.getValue("doc_mem_no") != "${SecureUser.mem_no}") {
			$M.setValue("part_part_free_yn", "Y");
		}

		// 스탁에서 왔을 경우 수정불가
		if ("${stock_machine_doc_no}" != "") {
			// $M.disabled(['machine_name', 'receive_plan_dt', 'plan_dt_6', 'opt_code', '_goAddPartPopup', '_goSearchBregInfo']);
			$M.disabled(['machine_name', 'receive_plan_dt', 'opt_code', '_goAddPartPopup', '_goSearchBregInfo']);
		}

		// 'YK렌탈장비'가 아니면 필수 값을 나타내는 CSS 표기 - 김경빈
		if (info.basicInfo.cust_no !== "20130603145119670") {
			$('.title_code_name').each(function() {
				if ($(this).text() === "장비계약서" || $(this).text() === "개인정보동의서" || $(this).text() === "통합계약서") {
					$(this).addClass("rs");
				}
			});
		} else {
			$('.title_code_name').each(function() {
				if ($(this).text() === "장비계약서" || $(this).text() === "개인정보동의서" || $(this).text() === "통합계약서") {
					$(this).removeClass("rs");
				}
			});
		}
	}

	// 견적서 참조(상세에서는 조회만!)
	function goReferEstimate() {
		var rfqNo = $M.getValue("rfq_no");
		if (rfqNo == "") {
			var param = {
				rfq_type : "MACHINE",
				type_select_yn : "N"
			}
			openRfqReferPanel("fnSetRfqRefer", $M.toGetParam(param));
		} else {
			var param = {
				cust_no : $M.getValue("cust_no"),
					rfq_no : rfqNo,
					disabled_yn : "Y"
			}
			var poppupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=600, left=0, top=0";
			$M.goNextPage('/cust/cust0107p01', $M.toGetParam(param), {popupStatus : poppupOption});
		}
	}

	/**
	* 확인사항
	* 어테치먼트가 = 옵션 선택시 + / 기본 선택 해제 -
	* 최종판매금액(sale_amt) = (기준판매가 + 어테치먼트가) - 가격할인금액
	* 총액(total_vat_amt) = 최종판매가 + VAT (10%)
	* 합계(total_amt) = 기준판매가 + 장비대에 영향을 미치는 합계(유상, 어테치먼트.. ) 화면에 안보이게 hidden 처리
	*
	* 0 현금, 1 카드, 2 어음, 3 금융, 4 중고, 5 보조, 6 부가세
	* 가상계좌 : 결제완료 후 현금 결제 조건에 자동 발번(신규기능)
	**/

	// 작업하다가 중간에 멈춤(안씀)
	function fnChangePriceVat() {

		var total_vat_amt = $M.toNum($M.getValue("plan_amt_6"))+$M.toNum($M.getValue("sale_amt"));
		var total = 0;
		for (var i = 0; i < 6; ++i) {
			var amt = $M.getValue("plan_amt_"+i);
			total += $M.toNum(amt);
		}
		var balance = total_vat_amt-total; // 결제조건잔액 = 최종판매가 - 결제조건 0~6
		var param = {
			total_vat_amt : total_vat_amt,
			balance : balance
		}
		$M.setValue(param);
	}

	// 결제조건
	function fnChangePrice() {
		var dc = $M.toNum($M.getValue("discount_amt")); // 할인(소수점 입력 불가)
		var salePrice = $M.toNum($M.getValue("sale_price")); // 기준판매가
		var attach = $M.toNum($M.getValue("attach_amt")); // 어테치먼트
		var paid = $M.toNum($M.getValue("part_cost_amt")); // 유상
		var saleAmt = salePrice+attach-dc; // 최종판매가
		var price = {
			sale_amt : saleAmt,
			plan_amt_6 : $M.toNum((saleAmt*0.1).toFixed(0)), // 부가세 : 최종판매가 * 0.1
			total_vat_amt : $M.toNum((saleAmt*1.1).toFixed(0)), // 총액(VAT포함) : 최종판매가 + VAT
			total_amt : saleAmt
		};
		var info = ${info}
		if (info.basicInfo.machine_doc_status_cd < "2" && info.basicInfo.doc_org_gubun_cd != "AGENCY") {
			$M.setValue("plan_amt_4", $M.toNum($M.getValue("used_used_price")));
		}
		var total = 0;
		for (var i = 0; i < 6; ++i) {
			var amt = $M.getValue("plan_amt_"+i);
			if (amt != "" && amt != "0" && $M.getValue("plan_dt_"+i) == "") {
				$M.setValue("plan_dt_"+i, "${inputParam.s_current_dt}");
			}
			total += $M.toNum(amt);
		}
		price['balance'] = price.total_vat_amt-total-$M.toNum((saleAmt*0.1).toFixed(0)); // 결제조건잔액 = 최종판매가 - 결제조건 0~6
		price.balance = Math.floor(price.balance);
		price.total_vat_amt = price.total_vat_amt;

		$M.setValue(price);

		// 실판매가 추가(21.4.6) = 최종판매가-무상-임의비용
		var realSaleAmt = price.sale_amt - $M.toNum($M.getValue("part_free_amt"));
		$M.setValue("real_sale_amt", realSaleAmt);
	}

	// 초기화
	function fnInit() {
		var param = {
			sale_price : "0",
			part_free_amt : "0",
			discount_amt : "0",
			contract_amt : "0",
			agency_price : "0",
			part_cost_amt : "0",
			part_free_amt : "0",
			attach_amt : "0",
			total_vat_amt : "0",
			sale_amt : "0",
			balance : "0",
			write_price : "",
			review_price : "",
			agree_price : "",
			max_dc_price : "",
			fee_price : "",
			discount_amt : "",
			contract_amt : "",
			pay_complete_yn : "N",
			total_amt : "",
			center_di_yn_check : "",
			center_di_yn : "",
			cap_yn_check : "",
			cap_yn : "",
			sar_yn_check : "",
			sar_yn : "",
			assist_yn : "",
			assist_yn_check : "",
			cost_taxbill_yn_check : "",
			cost_taxbill_yn : "",
			machine_name_temp : "",
			reg_proxy_yn : "",
			reg_proxy_yn_check : "",
			reg_proxy_amt : ""
		}
		$M.clearValue();
		// 선택사항 그리드 초기화
		AUIGrid.setGridData(auiGridOption, []);
		// 어테치먼트 그리드 초기화
		AUIGrid.setGridData(auiGridAttach, []);
		// 기본제공품 그리드 초기화
		AUIGrid.setGridData(auiGridBasic, []);
		// 유상그리드 초기화
		AUIGrid.setGridData(auiGridPart, []);
		// 기본지급품 그리드 초기화
        AUIGrid.setGridData(auiGridPartFree, []);
		// 임의비용그리드 초기화
        AUIGrid.setGridData(auiGridOppCost, []);
		$M.setValue(param);
		fnCostTaxbillCheck();
	}

	// 중고장비 조회
	function goUsedModelInfoClick() {
		var param = {
			s_machine_name : $M.getValue("used_machine_name")
		};
		openSearchModelPanel('fnSetUsedModelInfo', 'N', $M.toGetParam(param));
	}

	function fnSetUsedInfo(row) {
		console.log(row);
		var param = {
			used_machine_plant_seq : row.machine_plant_seq,
			used_machine_name : row.machine_name,
			used_maker_name : row.maker_name,
			used_machine_sub_type_name : row.machine_sub_type_name,
			used_machine_type_name : row.machine_type_name
		};
		return param;
	}

	function fnSetUsedModelInfo(row) {
		$M.setValue(fnSetUsedInfo(row));
	}

	function fnSetUsedBodyNo(row) {
		var param = fnSetUsedInfo(row);
		param['used_body_no'] = row.body_no;
		param['used_machine_seq'] = row.machine_seq === undefined ? null : row.machine_seq;
		$M.setValue(param);
		$("#used_body_no").attr("readonly", true);
		$("#clear-btn").toggleClass("dpn");
	}

	function fnSetClearUsedBodyNo() {
		if (confirm("장비대장에서 입력한 차대번호를 없애고, 수동입력하시겠습니까? YK장비가 아님으로 입력됩니다.") == false) {
			return false;
		}
		$("#used_body_no").attr("readonly", false);
		$M.setValue("used_machine_seq", "");
		$M.setValue("used_body_no", "");
		$("#clear-btn").toggleClass("dpn");
	};

	function fnRemoveUsedMachineInfo() {
		if (confirm("중고장비 입력을 취소하시겠습니까?") == false){
			return false;
		}
		var buy_status_cd = "3";
		var elements = document.getElementsByName("used_used_buy_status_cd");
		if (elements.length) {
			buy_status_cd = elements[0].value;
		}
		var param = {
			used_used_buy_status_cd : buy_status_cd,
			used_machine_plant_seq : "",
			used_machine_name : "",
			used_machine_seq : "",
			used_maker_name : "",
			used_machine_sub_type_name : "",
			used_machine_type_name : "",
			used_reg_year : "",
			used_op_hour : "",
			used_mng_org_code : "",
			used_body_no : "",
			used_used_price : "",
			used_agent_price : "",
			used_remark : "",
			plan_amt_4 : "",
			plan_dt_4 : "",
		}
		$M.setValue(param);
		console.log($M.getValue("used_used_buy_status_cd"));
		// 무조건 삭제하기 위해 remove하고 add함(toggle 시 에러)
		$("#clear-btn").removeClass("dpn");
		$("#clear-btn").addClass("dpn");
		$("#used_body_no").attr("readonly", false);
		fnChangePrice();
	}

	function fnClose() {
		window.close();
	}

	function fnReload(searchYn) {
		searchYn = searchYn? "N" : searchYn;
		if (searchYn == "Y" && opener != null && opener.goSearch) {
		    			opener.goSearch();
		    		}
		    		location.reload();
				}

	// 계약품의메모(사유) 입력 - 출하보류, 계약취소
	// gubun : 출하보류-hold, 계약취소-cancel
	function goMemoText(gubun) {
		var param = {
			gubun: gubun,
			machine_doc_no: $M.getValue("machine_doc_no"),
			parent_js_name: "fnReload"
		};
		$M.goNextPage("/sale/sale0101p17", $M.toGetParam(param), {popupStatus : ""});
		}

	// 계약취소 - 2022.10.27 jsk sale0101p17 이동
	// function goCancelContract(memo) {
	// 	var msg = "계약을 취소하시겠습니까? 취소 후 복구가 불가능하며 입금액이 있으면, 계약취소할 수 없습니다. 품의서는 삭제되지않습니다.\n정말 계약을 취소하시겠습니까?";
	// 	var machineDocNo = $M.getValue("machine_doc_no");
	// 	var param = { memo_text: memo };
	// 	$M.goNextPageAjaxMsg(msg, this_page+"/"+machineDocNo+"/cancel", $M.toGetParam(param), {method : 'POST'},
	// 		function(result) {
	// 	    	if(result.success) {
	// 	    		if (opener != null && opener.goSearch) {
	// 	    			opener.goSearch();
	// 	    		}
	// 	    		location.reload();
	// 			}
	// 		}
	// 	);
	// }

	// 출하보류 - 2022.10.27 jsk sale0101p17 이동
	// function goHold(memo) {
	// 	var msg = "출하업무를 보류하시겠습니까?\n보류 시, 출하처리가 제한됩니다.";
	// 	var param = {
	// 		machine_doc_no : $M.getValue("machine_doc_no"),
	// 		memo_text: memo
	// 	};
	// 	$M.goNextPageAjaxMsg(msg, "/sale/sale0101p03/process/hold", $M.toGetParam(param), {method : 'POST'},
	// 		function(result) {
	// 	    	if(result.success) {
	// 	    		location.reload();
	// 			}
	// 		}
	// 	);
	// }

	// 등록대행 수동 문자발송
	function goProxySms() {

		if ("${apprBean.appr_proc_status_cd}" != "05") {
			alert("결재 완료 후 가능합니다.");
			return false;
		}

		var param = {
			machine_doc_no : $M.getValue("machine_doc_no")
		}

		$M.goNextPageAjaxMsg("등록대행 문자를 발송하시겠습니까?", "/sale/sale0101p01/proxySmsSend", $M.toGetParam(param), {method : 'POST'},
				function(result) {
			    	if(result.success) {

					}
				}
			);
	}

	// 출하보류 취소
	function goHoldCancel() {
		var msg = "출하보류를 취소하시겠습니까?";
		var param = {
			machine_doc_no : $M.getValue("machine_doc_no")
		}
		$M.goNextPageAjaxMsg(msg, "/sale/sale0101p03/process/holdCancel", $M.toGetParam(param), {method : 'POST'},
			function(result) {
		    	if(result.success) {
		    		location.reload();
				}
			}
		);
	}

	// 결재요청
	function goRequestApproval() {
		var paid = AUIGrid.getGridData(auiGridPart);
		if (paid.length != 0 && $M.getValue("cost_part_breg_no") == "" && $M.getValue("cost_taxbill_yn_check") == "") { // 계산서미발행 체크 추가 QA 11435
			alert("유상부품 사업자번호를 입력하세요.");
			$("#cost_part_breg_no").focus();
			return false;
		}

		// Yk렌탈장비일때 서류 체크안함
		if ($M.getValue("cust_no") != "20130603145119670") {
			var checkFile = "${checkFile}";

			if (checkFile == "Y" && ($M.getValue("file_seq_01") == "" || $M.getValue("file_seq_04") == "")) {
				alert("장비계약서 또는 개인정보동의서를 저장해주세요.");
				return false;
			}

			if (checkFile == "N" && ($M.getValue("file_seq_07") == "" || $M.getValue("file_seq_04") == "")) {
				alert("통합계약서 또는 개인정보동의서를 저장해주세요.");
				return false;
			}
		}

		goModify('appr');
	}

	// 상신취소
	function goApprCancel() {
		var param = {
			appr_job_seq : "${apprBean.appr_job_seq}",
			seq_no : "${apprBean.seq_no}",
			appr_cancel_yn : "Y"
		};
		openApprPanel("goApprovalResult", $M.toGetParam(param));
	}

	// 결재처리
	function goApproval() {
		var param = {
			appr_job_seq : "${apprBean.appr_job_seq}",
			seq_no : "${apprBean.seq_no}"
		};
		if ("${apprBean.appr_proc_status_cd}" == "05") {
			param["appr_reject_only"] = "Y";
		}
		openApprPanel("goApprovalResult", $M.toGetParam(param));
	}

	// 결재처리 결과
	function goApprovalResult(result) {
		console.log(result);
		// 반려이면 페이지 리로딩
		if(result.appr_status_cd == '03') {
			alert("반려가 완료됐습니다.");
			fnAttachPriceUpdate();
			location.reload();
		} else if (result.appr_status_cd == '04') {
			$M.goNextPageAjax('/session/check', '', {method : 'GET'},
					function(result) {
				    	if(result.success) {
				    		alert("결재취소가 완료됐습니다.");
							fnAttachPriceUpdate();
				    		location.reload();
						}
					}
				);
		} else {
			var form = $M.createForm();
			$M.setHiddenValue(form, 'cust_name', $M.getValue("cust_name"));
			$M.setHiddenValue(form, 'hp_no', $M.getValue("hp_no"));
			$M.setHiddenValue(form, 'appr_job_seq', $M.getValue("appr_job_seq"));
			var machineDocNo = $M.getValue("machine_doc_no");
			$M.goNextPageAjax(this_page+"/"+machineDocNo+"/approval", form, {method : 'POST'},
				function(result) {
			    	if(result.success) {
			    		alert("처리가 완료됐습니다.");
			    		location.reload();
			    		if (opener != null && opener.goSearch) {
			    			opener.goSearch();
			    		}
					}
				}
			);
		}
	}

	function goModify(appr) {
		if (isMachine == false) {
			alert("모델명을 검색해서 입력해주세요.");
			$("#machine_name").focus();
			return false;
		};
		if (isCust == false) {
			alert("고객명을 검색해서 입력해주세요.");
			$("#cust_name").focus();
			return false;
		};
		if ($M.getValue("mch_type_cad") == "") {
			alert("장비계약을 선택해주세요");
			$("#mch_type_c").focus();
			return false;
		}
		if($M.getValue("cost_taxbill_yn_check") == "Y" && $('input[name=vat_treat_cd]').is(":checked") == false) {
			alert("매출전표 처리구분을 선택해주세요.");
			$("#vat_treat_type_a").focus();
			return false;
		}

		if ($M.getValue("cost_taxbill_yn_check") != "" && $M.getValue("cost_part_breg_no") != "") {
			if (confirm("계산서 미발행 시, 유상부품사업자를 삭제해야합니다.\n계속하시겠습니까?") == true) {
				$M.setValue("cost_part_breg_seq", "");
				$M.setValue("cost_part_breg_no", "");
				$M.setValue("cost_part_breg_rep_name", "");
				$M.setValue("cost_part_breg_name", "");
			} else {
				alert("계산서미발행 체크를 해제하세요.");
				$("#cost_taxbill_yn_check").focus();
				return false;
			}
		}

		// 중고입력 확인
		var arrayList = [];
		// 중고장비 > 매입구분에 따른, 필수항목 변경
		if (isDaeCha) {
			arrayList.push("used_machine_name", "used_body_no");
		} else {
			arrayList.push("used_machine_name", "used_body_no", "used_reg_year", "used_op_hour", "used_mng_org_code", "used_used_price", "used_agent_price");
		}
		$M.setValidationPair(arrayList);

		var validation = $M.validation(document.main_form, {returnType : 'name'});
		if(validation != "") {
			alert(validation.msg);
			if (arrayList.indexOf(validation.name) != -1) {
				document.getElementById("used-tab").click();
				$("#"+validation.name).focus();
			}
			return;
		}

		// 2023-03-17 황빛찬 - 캐피탈 필수선택 해제 (직원앱,ERP 둘다 적용)
		// 결재조건 중 금융을 입력했을 경우 캐피탈 필수
		// if ($M.toNum($M.getValue("plan_amt_3")) > 0 && $M.getValue("finance_cmp_cd") == "") {
		// 	alert("캐피탈을 선택해주세요.");
		// 	$("#finance_cmp_cd").focus();
		// 	return false;
		// }

		// 결제구분(0:현금, 1:카드, 2:어음, 3:금융, 4:중고, 5:보조, 6:부가세)
		var payArr = ["현금", "카드", "어음", "금융", "중고", "보조", "부가세"]
		// 입금예정일 확인
		for (var i = 0; i < 7; ++i) {
			if($M.toNum($M.getValue("plan_amt_"+i)) > 0 && $M.getValue("plan_dt_"+i) == "") {
				$M.setValue("plan_dt_"+i, "${inputParam.s_current_dt}");
				// alert(payArr[i]+" 입금예정일이 지정되지 않았습니다."+payArr[i]+" 금액만 입력할 수 없습니다.");
				// $("#plan_dt_"+i).focus();
				// return false;
			}
			// if($M.toNum($M.getValue("plan_amt_"+i)) < 1 && $M.getValue("plan_dt_"+i) != "") {
			// 	alert(payArr[i]+" 금액이 입력되지 않았습니다."+payArr[i]+" 입금예정일만 입력할 수 없습니다.");
			// 	$("#plan_amt_"+i).focus();
			// 	return false;
			// }
		}

		// 2021-07-01 (Q&A 11303) 농기계일 경우 CAP 체크 불가능.
		if ($M.getValue("mch_type_cad") == 'A') {
			if ($M.getValue("cap_yn_check") != "") {
				alert("농기계일 경우 CAP 적용이 불가합니다.\nCAP 체크 해제 후 진행 해주세요.");
				return false;
			}
		}

		// Yk렌탈장비일때 서류 체크안함 and 통합계약서인 경우 sar, cap서류가 없으므로 체크안함
		if ($M.getValue("cust_no") != "20130603145119670" && "${checkFile}" == "Y") {
			// CAP 체크시 첨부파일 필수 체크 추가
			if ($("#cap_yn_check").is(":checked")) {
				if ($M.getValue("file_seq_02") == "" || $M.getValue("file_seq_02") == 0) {
					alert("CAP계약서를 저장해주세요.");
					return false;
				}
			}

			// SA-R 체크시 첨부파일 필수 체크 추가
			if ($("#sar_yn_check").is(":checked")) {
				if ($M.getValue("file_seq_03") == "" || $M.getValue("file_seq_03") == 0) {
					alert("SA-R계약서를 저장해주세요.");
					return false;
				}
			}
		}

		$M.setValue("save_mode", "modify");

		var msg = "수정하시겠습니까?";
		// 결재요청일 경우
		if (appr != undefined) {
			$M.setValue("save_mode", "appr");
			// 출하희망일 = 인수예정일
			if ($M.getValue("receive_plan_dt") == "") {
				alert("출하희망일을 입력해주세요.");
				$("#receive_plan_dt").focus();
				return false;
			}

			// VAT 출하희망일과 같은날로, 출하희망일이 들어가면 그날짜로, 최대 기간은 출하희망일
			if ($M.getValue("plan_dt_6") == "") {
				$M.setValue("plan_dt_6", $M.getValue("receive_plan_dt"));
			}
			// else {
			// 	if ($M.toDate($M.getValue("plan_dt_6")) > $M.toDate($M.getValue("receive_plan_dt"))) {
			// 		alert("VAT 입금예정일의 최대일은 출하희망일입니다.");
			// 		$("#plan_dt_6").focus();
			// 		return false;
			// 	}
			// }

			// TODO: 중고매입손실 체크 추가해야함..(ASIS sales020104ContractForm.fn_submit(2) 823라인 참고)

			if ($M.toNum($M.getValue("balance")) != 0) {
				alert("계약금액과 결재요청하려는 금액이 다릅니다.");
				$("#balance").focus();
				return false;
			}
			var optCode = $M.getValue("opt_code");
			var optName = "";
			if (optCode != "") {
				for (var i = 0; i < optList.length; ++i) {
					if (optList[i].opt_code == optCode) {
						optName = optList[i].opt_name;
						break;
					}
				}
				if (confirm("선택하신 옵션품목이 "+optName+"이(가) 맞다면 확인\n변경하시려면 취소를 선택하십시오.") == false) {
					return false;
				}
			}
			msg = "결재 요청 하시겠습니까?\n요청 후 수정이 불가능 합니다.";
		}

		$M.getValue("center_di_yn_check") == "" ? $M.setValue("center_di_yn", "N") : $M.setValue("center_di_yn", "Y");
		$M.getValue("cap_yn_check") == "" ? $M.setValue("cap_yn", "N") : $M.setValue("cap_yn", "Y");
		$M.getValue("sar_yn_check") == "" ? $M.setValue("sar_yn", "N") : $M.setValue("sar_yn", "Y");
		$M.getValue("assist_yn_check") == "" ? $M.setValue("assist_yn", "N") : $M.setValue("assist_yn", "Y");
		$M.getValue("reg_proxy_yn_check") == "" ? $M.setValue("reg_proxy_yn", "N") : $M.setValue("reg_proxy_yn", "Y");

		// 계산서 미발행여부(QA 11435 Y체크 시, 미발행)
		$M.getValue("cost_taxbill_yn_check") == "" ? $M.setValue("cost_taxbill_yn", "N") : $M.setValue("cost_taxbill_yn", "Y");

		var frm = $M.toValueForm(document.main_form);
		var concatCols = [];
		var concatList = [];
		var gridIds = [auiGridBasic, auiGridOption, auiGridAttach, auiGridPart, auiGridPartFree, auiGridOppCost, auiGridCostApply]; // (3차 QNA 14464)
		for (var i = 0; i < gridIds.length; ++i) {
			// 체크된것만 저장안하고 ASIS처럼 전체 저장함
			/* if (gridIds[i] == auiGridAttach) {
				concatList = concatList.concat(AUIGrid.getItemsByValue(gridIds[i], "checked", "Y"));
			} else {
				concatList = concatList.concat(AUIGrid.exportToObject(gridIds[i]));
			} */
			concatList = concatList.concat(AUIGrid.exportToObject(gridIds[i]));
			concatCols = concatCols.concat(fnGetColumns(gridIds[i]));
		}
		var gridFrm = fnGridDataToForm(concatCols, concatList);
		$M.copyForm(gridFrm, frm);
		console.log(gridFrm);
		var machineDocNo = $M.getValue("machine_doc_no");

		console.log("frm : ", frm);

		$M.goNextPageAjaxMsg(msg, this_page+"/"+machineDocNo+"/modify", gridFrm, {method : 'POST'},
			function(result) {
		    	if(result.success) {
		    		var checkFileCnt = 0;
		    		var array = codeMapDocFileArray.filter(function(value) {
		    		    return value.code_v1 == "계약";
		    		});
		    		for (var i = 0; i < array.length; ++i) {
		    			var code = array[i].code_value;
		    			var fileSeq = $M.getValue("file_seq_"+code);
		    			if (fileSeq != "") {
		    				checkFileCnt++;
		    			}
		    		}
		    		alert("처리가 완료되었습니다.");
	    			location.reload();
				}
			}
		);
	}

	function goRemove() {
		var amt = "${virtual.sum_amt}";
		// 금액이 있다면
		if(amt != '0') {
			if(confirm("가상계좌에 입금액이 있습니다.\n삭제해도 거래 내역은 남아있습니다.\n삭제하시겠습니까?") != 0) {
				goRemovePost();
			}
		} else {
			goRemovePost();
		}
	}

	// 삭제 처리 전송
	function goRemovePost() {
		var machineDocNo = $M.getValue("machine_doc_no");
				$M.goNextPageAjaxRemove(this_page+"/"+machineDocNo+"/remove", '', {method : 'POST'},
						function(result) {
							if(result.success) {
								// 여기서 뒤로가기
								alert("삭제에 성공했습니다.");
								fnClose();
								if (opener != null && opener.goSearch) {
									opener.goSearch();
								}
							}
						}
				);
	}

	function fnToggle() {
		$('ul.tabs-c li a').click(function() {
		    var tab_id = $(this).attr('data-tab');

		    $('ul.tabs-c li a').removeClass('active');
		    $('.tabs-inner').removeClass('active');

		    $(this).addClass('active');
		    $("#"+tab_id).addClass('active');
		});
	};

	// 엔터키 이벤트
	function enter(fieldObj) {
		var name = fieldObj.name;
		if (name == "machine_name") {
			goModelInfo();
		} /* else if (name == "cust_name") {
			goCustInfo();
		} */
	}

	// 사업자조회
	function goSearchBregInfo() {
		if (machineDocStatus != "0") {
			alert(msgOnlyWriting);
			return false;
		}
		var param = {
     		's_breg_no' : $M.getValue("cost_part_breg_no")
     	};
     	openSearchBregInfoPanel('fnSetBregInfo', $M.toGetParam(param));
	}

  	function fnSetBregInfo(row) {
    	var param = {
    		cost_breg_seq : row.breg_seq,
    		cost_part_breg_no : row.real_breg_no,
    		cost_part_breg_rep_name : row.breg_rep_name,
    		cost_part_breg_name : row.breg_name
    	}
    	$M.setValue(param);
  	}

  	function goModelInfoClick() {
  		if (machineDocStatus != "0") {
			alert(msgOnlyWriting);
			return false;
		} else {
			if (isRfq == true) {
				alert("견적서를 참조하여 등록한 자료입니다.");
				return false;
			}
		}
  		if (isMachine == true) {
			if (confirm("모델을 다시 조회하면 입력한 값이 초기화됩니다.\n다시 조회하시겠습니까?") == false) {
				return false;
			}
		}
  		var param = {
			/* s_machine_name : $M.getValue("machine_name"), */
			s_price_present_yn : "Y"
		};
		openSearchModelPanel('fnSetModelInfo', 'N', $M.toGetParam(param));
  	}

	// 모델조회(단일)
	function goModelInfo() {
		if (machineDocStatus != "0") {
			alert(msgOnlyWriting);
			return false;
		}
		if (isMachine == true) {
			/* if ($M.getValue("machine_name_temp") == $M.getValue("machine_name") && $M.getValue("machine_name") != "") {
				alert("모델을 변경하시려면, 다른 장비를 입력해주세요.");
				return false;
			} */
			if (confirm("모델을 다시 조회하면 입력한 값이 초기화됩니다.\n다시 조회하시겠습니까?") == false) {
				return false;
			}
		}
		var param = {
			s_machine_name : $M.getValue("machine_name"),
			s_price_present_yn : "Y"
		};
		var url = "/comp/comp0501";
		$M.goNextPageAjax(url + "/search", $M.toGetParam(param), {method : 'get'},
			function(result) {
				if(result.success) {
					$("#machine_name").blur();
					var list = result.list;
					switch(list.length) {
						case 0 :
							$M.clearValue({field:["machine_name", "machine_plant_seq"]});
							break;
						case 1 :
							var row = list[0];
							fnSetModelInfo(row)
							break;
						default :
							openSearchModelPanel('fnSetModelInfo', 'N', $M.toGetParam(param));
						break;
					}
				}
			}
		);
	}

	function fnSetModelInfo(row) {
		fnInit();
		isMachine = true;
		$M.setValue("machine_name", row.machine_name);
		$M.setValue("machine_plant_seq", row.machine_plant_seq);
		$M.setValue("machine_name_temp", row.machine_name);
		$M.goNextPageAjax("/machine/supplement/"+row.machine_plant_seq, "", {method : 'GET'},
			function(result) {
	    		if(result.success) {
	    			 console.log(result);
	    			 if (result.basicInfo) {
	    				fnSetData(result);
	    				alert("모델을 변경했습니다.");
	    			 } else {
	    				alert("이 모델에 대한 가격정보가 없습니다.");
	    				return false;
	    			 }
				}
			}
		);
	}

	function fnSetData(result) {
		 // 가격
		 if (result.basicInfo) {
			 $M.setValue(result.basicInfo);
		 }
		 $M.setValue("machine_name_temp", $M.getValue("machine_name"));
		 if (result.basicInfo.hp_no != null) {
			 $M.setValue("hp_no", $M.phoneFormat(result.basicInfo.hp_no));
		 }
		 // 결제조건
		 // TODO: CD_MACHINE_PAY_TYPE 어음 코드 넣기
		 if (result.planList != null) {
        	 var planList = result.planList;
        	 console.log(planList);
        	 var payTypes = ["CASH", "CARD", "BILL","FINANCE", "USED", "ASSIST", "VAT"];
        	 console.log(planList);
        	 for (var i = 0; i < planList.length; ++i) {
        		 var j = payTypes.indexOf(planList[i].machine_pay_type_cd);
        		 if (j != -1) {
        			 var jsonVariable = {};
        			 jsonVariable['plan_amt_'+j] = planList[i].plan_amt;
        			 jsonVariable['plan_dt_'+j] = planList[i].plan_dt;
        			 // 중고 60일 유예처럼 보이게
        			 if (planList[i].machine_pay_type_cd == "USED" && machineDocStatus != "0") {
        				 jsonVariable['plan_dt_'+j] = $M.addDates($M.toDate(planList[i].plan_dt), 60);
        			 }
        			 jsonVariable['deposit_amt_'+j] = planList[i].deposit_amt;
        			 $M.setValue(jsonVariable);
        		 }
        	 }
         }

		 // 조회 시, 정상판매가(sale_price) = 최종판매금액(sale_amt) default
		 // 부가정보 조작 시, 최종판매금액을 수정함.
		 $M.setValue("sale_amt", result.basicInfo.sale_price);

		 // 작성중일뗴만 결제조건 바꿀수 있으므로 작성중 조건 추가
		 if (result.basicInfo.machine_doc_status_cd == "0") {
			 fnChangePrice();
		 } else if (result.basicInfo.machine_doc_status_cd == "5") {
			$M.setValue("sale_amt", result.basicInfo.sale_amt);
			var realSaleAmt = result.basicInfo.sale_amt - $M.toNum($M.getValue("part_free_amt"));
			$M.setValue("real_sale_amt", realSaleAmt);
		 } else {
			var dc = $M.toNum($M.getValue("discount_amt")); // 할인(소수점 입력 불가)
			var price = $M.toNum($M.getValue("sale_price")); // 기준판매가
			var attach = $M.toNum($M.getValue("attach_amt")); // 어테치먼트
			var saleAmt = price+attach-dc; // 최종판매가
			$M.setValue("sale_amt", saleAmt);

			// 실판매가 추가(21.4.6) = 최종판매가-기본지급품-임의비용
			var realSaleAmt = saleAmt - $M.toNum($M.getValue("part_free_amt"));
			$M.setValue("real_sale_amt", realSaleAmt);

		 }

		 // YN
		 fnMakeYn(result.basicInfo);
		 result.basicInfo.cap_yn == "Y" ? $M.setValue("cap_yn_check", "Y") : "";
		 result.basicInfo.sar_yn == "Y" ? $M.setValue("sar_yn_check", "Y") : "";
		 result.basicInfo.assist_yn == "Y" ? $M.setValue("assist_yn_check", "Y") : "";
		 result.basicInfo.center_di_yn == "Y" ? $M.setValue("center_di_yn_check", "Y") : "";
		 result.basicInfo.reg_proxy_yn == "Y" ? $M.setValue("reg_proxy_yn_check", "Y") : "";
		// 22.12.15 Q&A 14448 계산서미발행 시 유상부품 매출전표 처리구분 선택할 수 있도록 추가
		 switch (result.basicInfo.vat_treat_cd){
			 case "A" :
				 $("#vat_treat_type_a").prop("checked", true);
				 break;
			 case "C" :
				 $("#vat_treat_type_c").prop("checked", true);
				 break;
			 case "N" :
				 $("#vat_treat_type_n").prop("checked", true);
				 break;
		 }
		 // 계산서미발행 여부 QA 11435
		 result.basicInfo.cost_taxbill_yn == "Y" ? $M.setValue("cost_taxbill_yn_check", "Y") : "";

		 // 선택사항
		 optList = result.optionList;
		 var optCode = $("#opt_code");
		 optCode.html("");
		 if (optList.length > 0) {
			 optCode.css("display", "inline-block");
			 var selectedOptCode = result.basicInfo.selected_opt_code;
			 var selectedOptCodeIdx = 0;
			 for (var i = 0; i < optList.length; ++i) {
				 optCode.append("<option value='"+optList[i].opt_code+"'>"+optList[i].opt_name+"</option>");
				 if (optList[i].opt_code == selectedOptCode) {
					 selectedOptCodeIdx = i;
				 }
			 }
			 if (selectedOptCode != null) {
				 $M.setValue("opt_code", selectedOptCode);
			 } else {
				 $M.setValue("opt_code", optList[0].opt_code);
			 }
			 AUIGrid.setGridData("#auiGridOption", optList[selectedOptCodeIdx].list);
		 } else {
			 optCode.css("display", "none");
			 AUIGrid.setGridData("#auiGridOption", []);
		 }
		 // 어테치먼트
		 if (result.attachList) {
			 /* for (var i = 0; i < result.attachList.length; ++i) {
				 result.attachList[i]['gubun'] = result.attachList[i].attach_base_yn === "Y" ? "기본" : "옵션";
				 if (result.attachList[i].attach_base_yn === "Y" && result.attachList[i].attach_checked == null) {
					 result.attachList[i]['checked'] = "Y"
				 } else if (result.attachList[i].attach_base_yn === "N" && result.attachList[i].attach_checked == null) {
					 result.attachList[i]['checked'] = "N"
				 } else {
					 result.attachList[i]['checked'] = result.attachList[i].attach_checked;
				 }
			 } */
			 AUIGrid.setGridData("#auiGridAttach", result.attachList);
		 }

		 // 기본지급품내역
		 AUIGrid.setGridData("#auiGridBasic", result.basicInfo.basicItemList);
		 var basicItemListDom = $("#basicItemList");
		 basicItemListDom.css("display", "flex");
		 basicItemListDom.html("");
		 var basicDtlBtnDom = $("#basicDtlBtn");
		 basicDtlBtnDom.css("display", "none");
		 if (result.basicInfo.basicItemList) {
			 for (var i = 0; i < result.basicInfo.basicItemList.length; ++i) {
				 basicItemListDom.append("<span>"+result.basicInfo.basicItemList[i].basic_item_name+"</span>");
			 }
			 if (result.basicInfo.basicItemList.length > 0) {
				 basicDtlBtnDom.css("display", "inline-block");
			 }
		 }
		 AUIGrid.setGridData("#auiGridPartFree", result.freeList != null ? result.freeList.sort($M.sortMulti("-free_add_qty")) : []);
		 AUIGrid.setGridData("#auiGridPart", result.paidList);
		 AUIGrid.setGridData("#auiGridOppCost", result.oppCostList);
		 AUIGrid.setGridData("#auiGridCostApply", result.costApplyList);
     	 // 유무상 부품계 반영
         $M.setValue("part_cost_amt", AUIGrid.getFooterData(auiGridPart)[1].text);

     	 // 등록대행비는 무상부품계에서 제외함
     	 var partFreeAmtTemp = $M.toNum(AUIGrid.getFooterData(auiGridPartFree)[1].text);
     	 var oppCostTemp = 0;
     	 var oppCostGrid = AUIGrid.getGridData(auiGridOppCost);
     	 for (var i = 0; i < oppCostGrid.length; ++i) {
     		 if (oppCostGrid[i].cost_item_cd != "22") { // 등록대행코드
     			oppCostTemp+=$M.toNum(oppCostGrid[i].amt);
     		 }
     	 }
         $M.setValue("part_free_amt", partFreeAmtTemp+oppCostTemp);
	}

	function fnMakeYn(info) {
		fnHideYn("diYn"); fnHideYn("capYn"); fnHideYn("sarYn"); fnHideYn("proxyYn"); fnHideYn("assistYn")
		var isDiExist = info.center_di_yn_info === "Y" ? fnShowYn("diYn") : fnHideYn("diYn");
		var isCapExist = info.cap_yn_info === "Y" ? fnShowYn("capYn") : fnHideYn("capYn");
		var isSarExist = info.sar_yn_info === "Y" ? fnShowYn("sarYn") : fnHideYn("sarYn");
		fnShowYn("proxyYn");
		fnShowYn("assistYn");
		var tempArr = [isDiExist, isSarExist, isCapExist];
		var yCnt = tempArr.filter(Boolean).length;
		// if (yCnt !== 3) {
		// 	if (yCnt == 0) {
		// 		yCnt = 1;
		// 	}
		// 	var percent = yCnt*33;
		// 	if (percent < 50) {
		// 		percent = 60;
		// 	}
		// 	$("#yCnt").css("width", (percent)+"%");
		// } else {
		// 	$("#yCnt").css("width", "100%");
		// }
	}

	function fnChangeOpt() {
		var opt = $M.getValue("opt_code");
		var tempOptList = [];
		for (var i = 0; i < optList.length; ++i) {
			if (optList[i].opt_code === opt) {
				tempOptList = optList[i].list;
			}
		}
		AUIGrid.setGridData("#auiGridOption", tempOptList);
	}

	function fnHideYn(type) {
		$("."+type).hide();
		return false;
	}

	function fnShowYn(type) {
		$("."+type).show();
		return true;
	}

	function goCustInfo() {
		var param = {
				s_cust_no : $M.getValue("cust_name")
		};
		var url = "/comp/comp0301";
		$M.goNextPageAjax(url + "/search", $M.toGetParam(param), {method : 'get'},
			function(result) {
				if(result.success) {
					$("#cust_name").blur();
					var list = result.list;
					switch(list.length) {
						case 0 :
							$M.clearValue({field:["cust_name"]});
							break;
						case 1 :
							var row = list[0];
							fnSetCustInfo(row)
							break;
						default :
							openSearchCustPanel('fnSetCustInfo', $M.toGetParam(param));
						break;
					}
				}
			}
		);
	}

	function fnSetCustInfo(row) {
		isCust = true;
		$M.goNextPageAjax("/sale/custInfo/"+row.cust_no, "", {method : 'GET'},
			function(result) {
	    		if(result.success) {
	    			$M.setValue(result);
	    			$M.setValue("hp_no", $M.phoneFormat(result.hp_no));
				}
			}
		);
	}

	function goItemDetailPopup() {
		var param = {
			machine_plant_seq  : $M.getValue("machine_plant_seq")
		}
		var poppupOption = "";
		$M.goNextPage('/sale/sale0101p02', $M.toGetParam(param), {popupStatus : poppupOption});
	}

	function goAddPartPopup() {

		// Q&A 11704 결재중, 작성자x, 결재처리자 의경우 유무상 수정여부 용도 210629 김상덕
		if ("Y" == $M.getValue("part_part_free_yn")) {

		} else if (machineDocStatus != 0) {
			alert(msgOnlyWriting);
			return false;
		}
		// 모델 검색해야 sale_price가 세팅되므로 0이면 검색안한거로 판단
		if ($M.getValue("sale_price") == "0") {
			alert("모델을 먼저 검색해주세요.");
			$("#machine_name").focus();
			return false;
		}
		parentFreeList = [];
		freeTemp = AUIGrid.exportToObject(auiGridPartFree);
		for (var i = 0; i < freeTemp.length; i++) {
			var obj = new Object();
			for (var prop in freeTemp[i]) {
				obj[prop.substring(5,prop.length)] = freeTemp[i][prop];
			}
			parentFreeList.push(obj);
		}
		parentPaidList = [];
		paidTemp = AUIGrid.exportToObject(auiGridPart);
		console.log(paidTemp);
		for (var i = 0; i < paidTemp.length; i++) {
			var obj = new Object();
			for (var prop in paidTemp[i]) {
				obj[prop.substring(5,prop.length)] = paidTemp[i][prop];
			}
			parentPaidList.push(obj);
		}

		parentOppCost = AUIGrid.exportToObject(auiGridOppCost);
		parentCostApply = AUIGrid.exportToObject(auiGridCostApply); // (3차 QNA 14464)

		var param = {
			/* cost_part_breg_seq : $M.getValue("cost_part_breg_seq"), */
			cost_part_breg_no : $M.getValue("cost_part_breg_no"), // 사업자번호
			machine_plant_seq : $M.getValue("machine_plant_seq"),
			page_type : "doc"
		}
		openFreeAndPaidMachinePart('fnSetFreeAndPaidMachinePart', $M.toGetParam(param));
	}

	function fnSetFreeAndPaidMachinePart(list) {
		var row = $.extend(true, [], list);
     	// 유상 부품계 반영
        for (var i = 0; i < row.parentPaidList.length; ++i) {
        	row.parentPaidList[i]['paid_free_yn'] = "N";
        }
        for (var i = 0; i <row.parentFreeList.length; ++i) {
        	row.parentFreeList[i]['free_free_yn'] = "Y";
        }
        var freelist = row.parentFreeList;
        freelist.sort($M.sortMulti("-free_add_qty"));
        AUIGrid.setGridData(auiGridPart, row.parentPaidList);
        AUIGrid.setGridData(auiGridPartFree, row.parentFreeList);
        AUIGrid.setGridData(auiGridOppCost, row.parentOppList);
		AUIGrid.setGridData(auiGridCostApply, row.parentCostList); // (3차 QNA 14464)

     	// 유무상 부품계 반영
        $M.setValue("part_cost_amt", AUIGrid.getFooterData(auiGridPart)[1].text);
        $M.setValue("part_free_amt", ($M.toNum(AUIGrid.getFooterData(auiGridPartFree)[1].text) + $M.toNum(AUIGrid.getFooterData(auiGridOppCost)[1].text)));

     // 실판매가 추가(21.4.6) = 최종판매가-무상-임의비용
		var realSaleAmt = $M.toNum($M.getValue("sale_amt")) - $M.toNum($M.getValue("part_free_amt"));
		$M.setValue("real_sale_amt", realSaleAmt);

		// Q&A 11704 결재중, 작성자x, 결재처리자 의경우 유무상 수정 210629 김상덕
		if("Y" == $M.getValue("part_part_free_yn")) {
			goSavePart();
		}
    }

	function goSavePart() {
		$M.getValue("center_di_yn_check") == "" ? $M.setValue("center_di_yn", "N") : $M.setValue("center_di_yn", "Y");
		$M.getValue("cap_yn_check") == "" ? $M.setValue("cap_yn", "N") : $M.setValue("cap_yn", "Y");
		$M.getValue("sar_yn_check") == "" ? $M.setValue("sar_yn", "N") : $M.setValue("sar_yn", "Y");
		// $M.getValue("assist_yn_check") == "" ? $M.setValue("assist_yn", "N") : $M.setValue("assist_yn", "Y");

		var frm = $M.toValueForm(document.main_form);
		var concatCols = [];
		var concatList = [];
		var gridIds = [auiGridBasic, auiGridPart, auiGridPartFree, auiGridOppCost];
		for (var i = 0; i < gridIds.length; ++i) {
			concatList = concatList.concat(AUIGrid.exportToObject(gridIds[i]));
			concatCols = concatCols.concat(fnGetColumns(gridIds[i]));
		}
		var gridFrm = fnGridDataToForm(concatCols, concatList);
		$M.copyForm(gridFrm, frm);
		console.log(gridFrm);
		var machineDocNo = $M.getValue("machine_doc_no");
		$M.goNextPageAjax(this_page+"/"+machineDocNo+"/part/modify", gridFrm, {method : 'POST'},
			function(result) {
		    	if(result.success) {
	    			alert("수정이 완료되었습니다.");
		    		location.reload();
				}
			}
		);
	}

	//그리드생성
	function createAUIGrid() {
		// 그리드생성_ 임의비용
		var gridProsOppCost = {
			showFooter : true,
			footerPosition : "top",
			rowIdField : "_$uid",
			fillColumnSizeMode : false,
			headerHeight : 20,
			rowHeight : 11,
			footerHeight : 20,
            /* rowStyleFunction : function(rowIndex, item) {
                  return "aui-row-free-part-cost"
            } */
		};

		var columLayoutOppCost = [
			{
				dataField : "cost_item_cd",
				visible : false
			},
			{
				headerText : "임의비용명",
				dataField : "cost_item_name",
				width : "25%",
				style : "aui-center",
				labelFunction : function(rowIndex, columnIndex, value, headerText, item ) {
					var retStr = value;
					for(var i = 0, len = codeMapCostItemArray.length; i < len; i++) {
						if(codeMapCostItemArray[i]["code_value"] == value) {
							retStr = codeMapCostItemArray[i]["code_name"];
							break;
						}
					}
					return retStr;
				},
			},
			{
				headerText : "비고",
				dataField : "cost_name",
				style : "aui-left",
			},
			{
				headerText : "금액",
				dataField : "amt",
				style : "aui-right",
				dataType : "numeric",
				formatString : "#,##0",
				width : "20%"
			},
			{
				dataField : "cost_apply_cd",
				visible : false
			},
			{
				dataField : "cost_cust_no",
				visible : false
			}
		];

		// 푸터레이아웃
		var footerColumnLayoutOppCost = [
			{
				labelText : "합계",
				positionField : "cost_item_name"
			},
			{
				dataField : "amt",
				positionField : "amt",
				operation : "SUM",
				formatString : "#,##0",
				style : "aui-right aui-footer",
			}
		];

		auiGridOppCost = AUIGrid.create("#auiGridOppCost", columLayoutOppCost , gridProsOppCost);
		AUIGrid.setGridData(auiGridOppCost, []);
		AUIGrid.setFooter(auiGridOppCost, footerColumnLayoutOppCost);
		$("#auiGridOppCost").resize();

		// 그리드 생성_ 기본제공품(화면에 안보임)
		var gridProsBasic = {};
		var columnLayoutBasic = [
			{
				dataField : "basic_item_name"
			},
			{
				dataField : "basic_qty"
			},
			{
				dataField : "basic_machine_name"
			},
			{
				dataField : "machine_plant_seq"
			},
			{
				dataField : "basic_seq_no"
			}
		]
		auiGridBasic = AUIGrid.create("#auiGridBasic", columnLayoutBasic, gridProsBasic);
		var basicItemList = [];
		AUIGrid.setGridData(auiGridBasic, basicItemList);
		//그리드 생성 _ 선택사항
		var gridProsOption = {
			fillColumnSizeMode : false,
			rowIdField : "option_part_no",
			headerHeight : 20,
			rowHeight : 11,
			footerHeight : 20,
		};
		var columnLayoutOption = [
			{
				headerText : "부품번호",
				dataField : "option_part_no",
				width : "20%",
				style : "aui-center",
			},
			{
				headerText : "부품명",
				dataField : "option_part_name",
				style : "aui-left",
			},
			{
				headerText : "단위",
				dataField : "option_unit",
				width : "10%",
				style : "aui-center",
				labelFunction :  function( rowIndex, columnIndex, value, headerText, item ) {
					return value == null || value == "" ? "-" : value;
				}
			},
			{
				headerText : "구성수량",
				dataField : "option_qty",
				width : "10%",
				style : "aui-center",
			},
			{
				dataField : "option_machine_plant_seq",
				visible : false
			}
		];
		auiGridOption = AUIGrid.create("#auiGridOption", columnLayoutOption, gridProsOption);
		AUIGrid.setGridData(auiGridOption, []);
		AUIGrid.resize(auiGridOption);

		//그리드 생성 _ 어테치먼트
		var gridProsAttach = {
			rowIdField : "attach_part_no",
			headerHeight : 20,
			rowHeight : 11,
			footerHeight : 20,
			fillColumnSizeMode : false,
			rowStyleFunction : function(rowIndex, item) {
				 if(item.attach_check_yn == "Y") {
				  	return "aui-row-highlight";
				 }
				 return "";
			}
		};
		var columnLayoutAttach = [
			{
				headerText : "구분",
				dataField : "gubun",
				width : "10%",
				style : "aui-center",
				labelFunction :  function( rowIndex, columnIndex, value, headerText, item ) {
					if (item.attach_base_yn == "Y") {
						return "기본옵션";
					} else {
						return "추가옵션";
					}
				}
			},
			{
				dataField : "attach_base_yn",
				visible : false
			},
			{
				headerText : "선택",
				dataField : "attach_check_yn",
				width : "10%",
				style : "aui-center",
				renderer : {
					type : "CheckBoxEditRenderer",
					editable : true,
					checkValue : "Y",
					unCheckValue : "N"
				}
			},
			{
				headerText : "부품번호",
				dataField : "attach_part_no",
				width : "20%",
				style : "aui-center",
			},
			{
				headerText : "부품명",
				dataField : "attach_part_name",
				width : "30%",
				style : "aui-left",
			},
			{
				headerText : "수량",
				dataField : "attach_qty",
				style : "aui-center"
			},
			{
				// headerText : "단가",
				headerText : "전략가",
				dataField : "attach_part_amt",
				dataType : "numeric",
				formatString : "#,##0",
				style : "aui-right",
			},
			{
				dataField : "attach_machine_plant_seq",
				visible : false
			}
		];
		auiGridAttach = AUIGrid.create("#auiGridAttach", columnLayoutAttach, gridProsAttach);
		AUIGrid.bind(auiGridAttach, "cellEditEnd", function(event) {
			if (event.dataField == "attach_check_yn") {
				// 2024-02-19 / 3-4차 계약품의서 옵션단가 변경 체크
				if (event.value == 'Y' && event.item.attach_base_yn != "Y") {
					var param = {
						"attach_machine_plant_seq": event.item.attach_machine_plant_seq,
						"attach_part_no" : event.item.attach_part_no,
						"attach_part_amt" : event.item.attach_part_amt
					};

					$M.goNextPageAjax(this_page + "/attach/price/check", $M.toGetParam(param), {method : 'GET'},
							function(result) {
								if(result.success) {
									if (result.changeYn == 'Y') {
										alert("선택하신 부품의 가격이 변동되었습니다.\n수정시 변경된 금액이 반영됩니다.");
										AUIGrid.updateRow(auiGridAttach, { "attach_part_amt" : result.result_part_amt}, event.rowIndex);
									}

									var amt = $M.toNum($M.getValue("attach_amt"));
									var attachPrice = $M.toNum(result.result_part_amt);
									var discount = $M.toNum($M.getValue("discount_amt"));
									var salePrice = $M.toNum($M.getValue("sale_price"));
									var calcPrice = 0;
									if (event.value == "N") {
										calcPrice = amt-attachPrice;
										$M.setValue("sale_amt", amt-attachPrice);
									} else {
										calcPrice = amt+attachPrice;
										$M.setValue("attach_amt", amt+attachPrice);
									};
									$M.setValue("sale_amt", salePrice+calcPrice-discount);
									$M.setValue("attach_amt", calcPrice);
									fnChangePrice();
								}
							}
					);
				} else {
					var amt = $M.toNum($M.getValue("attach_amt"));
					var attachPrice = $M.toNum(event.item.attach_part_amt);
					var discount = $M.toNum($M.getValue("discount_amt"));
					var salePrice = $M.toNum($M.getValue("sale_price"));
					var calcPrice = 0;
					if (event.value == "N") {
						calcPrice = amt-attachPrice;
						$M.setValue("sale_amt", amt-attachPrice);
					} else {
						calcPrice = amt+attachPrice;
						$M.setValue("attach_amt", amt+attachPrice);
					};
					$M.setValue("sale_amt", salePrice+calcPrice-discount);
					$M.setValue("attach_amt", calcPrice);
					fnChangePrice();
				}
			}
		});

		AUIGrid.setGridData(auiGridAttach, []);
		$("#auiGridAttach").resize();

		//그리드 생성 _ 유상
		var gridProsPart = {
			showFooter : true,
			footerPosition : "top",
			fillColumnSizeMode : false,
			rowIdField : "part_no",
			headerHeight : 20,
			rowHeight : 11,
			footerHeight : 20,
		};
		var columnLayoutPart = [
			{
				dataField : "paid_machine_basic_part_seq",
				visible : false
			},
			{
				dataField : "paid_free_yn",
				visible : false
			},
			{
				headerText : "부품번호",
				dataField : "paid_part_no",
				width : "20%",
				style : "aui-center"
			},
			{
				headerText : "부품명",
				dataField : "paid_part_name",
				style : "aui-left",
			},
			{
				headerText : "추가",
				dataField : "paid_add_qty",
				width : "11%",
				style : "aui-center",
			},
			{
				// headerText : "단가",
				headerText : "VIP가",
				dataField : "paid_unit_price",
				width : "15%",
				dataType : "numeric",
				formatString : "#,##0",
				style : "aui-right",
			},
			{
				headerText : "금액",
				dataField : "paid_total_amt",
				width : "15%",
				dataType : "numeric",
				formatString : "#,##0",
				style : "aui-right",
			},
			{
				dataField : "paid_part_name_change_yn",
				visible : false
			},
			{
				dataField : "paid_machine_plant_seq",
				visible : false
			}
		];
		// 푸터레이아웃
		var footerColumnLayoutPart = [
			{
				labelText : "합계",
				positionField : "paid_part_no"
			},{
				dataField : "paid_total_amt",
				positionField : "paid_total_amt",
				operation : "SUM",
				formatString : "#,##0",
				style : "aui-right aui-footer",
			}
		];

		auiGridPart = AUIGrid.create("#auiGridPart", columnLayoutPart, gridProsPart);
		AUIGrid.setFooter(auiGridPart, footerColumnLayoutPart);
		AUIGrid.setGridData(auiGridPart, []);
		$("#auiGridPart").resize();

		//그리드 생성 _ 무상
		var gridProsPartFree = {
			showFooter : true,
			footerPosition : "top",
			fillColumnSizeMode : false,
			/* rowIdField : "row", */
			headerHeight : 20,
			rowHeight : 11,
			footerHeight : 20,
            rowStyleFunction : function(rowIndex, item) {
                if(item.free_cost_item_yn == "Y") {
                   // 임의비용 : 빨간색
                   return "aui-row-free-part-cost"
                } else {
                   if(item.free_add_qty == "0") {
                      // 기본 부품 : 파란색
                      return "aui-row-free-part-default";
                   } else {
                      // 추가 부품 : 검정색
                      return "aui-row-free-part-add";
                   }
                }
                return "";
            }
		};
		var columnLayoutPartFree = [
			{
				dataField : "free_machine_basic_part_seq",
				visible : false
			},
			{
				dataField : "free_free_yn",
				visible : false
			},
			{
				headerText : "부품번호",
				dataField : "free_part_no",
				width : "20%",
				style : "aui-center",
			},
			{
				headerText : "부품명",
				dataField : "free_part_name",
				style : "aui-left",
			},
			{
				headerText : "추가",
				dataField : "free_add_qty",
				width : "8%",
				style : "aui-center",
			},
			{
				headerText : "기본",
				dataField : "free_default_qty",
				width : "8%",
				style : "aui-center",
			},
			{
				// headerText : "단가",
				headerText : "VIP가",
				dataField : "free_unit_price",
				width : "15%",
				dataType : "numeric",
				formatString : "#,##0",
				style : "aui-right",
			},
			{
				headerText : "금액",
				dataField : "free_total_amt",
				width : "15%",
				dataType : "numeric",
				formatString : "#,##0",
				style : "aui-right"
			},
			{
				dataField : "free_part_name_change_yn",
				visible : false
			},
			{
				dataField : "free_machine_plant_seq",
				visible : false
			}
		];
		// 푸터레이아웃
		var footerColumnLayoutPartFree = [
			{
				labelText : "합계",
				positionField : "free_part_no"
			},
			{
				dataField : "free_total_amt",
				positionField : "free_total_amt",
				operation : "SUM",
				formatString : "#,##0",
				style : "aui-right aui-footer"
			}
		];
		auiGridPartFree = AUIGrid.create("#auiGridPartFree", columnLayoutPartFree, gridProsPartFree);
		AUIGrid.setGridData(auiGridPartFree, []);
		AUIGrid.setFooter(auiGridPartFree, footerColumnLayoutPartFree);
		$("#auiGridPartFree").resize();

		// 그리드 생성 - 원가반영
		// (3차 QNA 14464)
		var gridProsCostApply = {
			showFooter : true,
			footerPosition : "top",
			fillColumnSizeMode : false,
			rowIdField : "row",
			headerHeight : 20,
			rowHeight : 11,
			footerHeight : 20,
		};
		var columnLayoutCostApply = [
			{
				headerText : "원가반영 명",
				dataField : "cost_apply_cd",
				width : "20%",
				style : "aui-center",
				editable : true,
				labelFunction : function(rowIndex, columnIndex, value, headerText, item ) {
					var retStr = value;
					for(var i = 0, len = codeMapCostApplyArray.length; i < len; i++) {
						if(codeMapCostApplyArray[i]["code_value"] == value) {
							retStr = codeMapCostApplyArray[i]["code_name"];
							break;
						}
					}
					return retStr;
				},
			},
			{
				headerText : "비고",
				dataField : "cost_name",
				style : "aui-left",
				renderer : { // HTML 템플릿 렌더러 사용
					type : "TemplateRenderer"
				},
			},
			{
				headerText : "금액",
				dataField : "amt",
				width : "13%",
				style : "aui-right",
				dataType : "numeric",
				editable : true,
				formatString : "#,##0",
				editRenderer : {
					type : "InputEditRenderer",
					onlyNumeric : true, // Input 에서 숫자만 가능케 설정
				},
			},
			{
				dataField : "cost_item_cd",
				visible : false
			},
		];
		var footerColumnLayoutCostApply = [
			{
				labelText : "합계",
				positionField : "cost_apply_cd"
			},
			{
				dataField : "amt",
				positionField : "amt",
				operation : "SUM",
				formatString : "#,##0",
				style : "aui-right aui-footer",
	}
		];

		auiGridCostApply = AUIGrid.create("#auiGridCostApply", columnLayoutCostApply, gridProsCostApply);
		AUIGrid.setGridData(auiGridCostApply, []);
		AUIGrid.setFooter(auiGridCostApply, footerColumnLayoutCostApply);
		AUIGrid.resize(auiGridCostApply);
	}

	// 출하희망일 세팅 시, VAT 입금예정일을 출하희망일로 세팅
	function fnSetReceivePlan() {
		$M.setValue("plan_dt_6", $M.getValue("receive_plan_dt"));
	}

    // 문자발송
	function fnSendSms() {
	   var param = {
			   'name' : $M.getValue('cust_name'),
			   'hp_no' : $M.getValue('hp_no')
	   }
	   openSendSmsPanel($M.toGetParam(param));
	}

	// 고객핸드폰 변경 시 중고장비 고객 핸드폰 변경
    function fnChangeHpNo() {
    	$M.setValue("used_hp_no", $M.phoneFormat($M.getValue("hp_no")));
    }

	// 캡체크하면 캡 서류저장버튼 나오게
	function fnCapCheck(click) {
		var yn = $M.getValue("cap_yn_check");
		if (yn == "Y") {
			$("#btn_submit_02").show();
			// 필수값을 나타내는 CSS 추가
			$('.title_code_name').each(function() {
				if ($(this).text() === "CAP계약서") {
					$(this).addClass("rs");
				}
			});
		} else {
			yn = "N";
			$("#btn_submit_02").hide();
			// 필수값을 나타내는 CSS 삭제
			$('.title_code_name').each(function() {
				if ($(this).text() === "CAP계약서") {
					$(this).removeClass("rs");
		}
			});
		}
		console.log(click);
		if (click != undefined) {
			var machineDocNo = $M.getValue("machine_doc_no");
			var param = {
				machine_doc_no : machineDocNo,
				cap_yn : yn
			}
			console.log(param);
			$M.goNextPageAjax(this_page+"/checkUpdate", $M.toGetParam(param), {method : 'POST', loader : false},
				function(result) {
			    	if(result.success) {

					}
				}
			);
		}
	}

	// SAR체크하면 SAR 서류저장버튼 나오게
	function fnSarCheck(click) {
		var yn = $M.getValue("sar_yn_check");
		if (yn == "Y") {
			$("#btn_submit_03").show();
			// 필수값을 나타내는 CSS 추가
			$('.title_code_name').each(function() {
				if ($(this).text() === "SA-R계약서") {
					$(this).addClass("rs");
				}
			});
		} else {
			yn = "N";
			$("#btn_submit_03").hide();
			// 필수값을 나타내는 CSS 삭제
			$('.title_code_name').each(function() {
				if ($(this).text() === "SA-R계약서") {
					$(this).removeClass("rs");
				}
			});
		}

		console.log(click);
		if (click != undefined) {
			var machineDocNo = $M.getValue("machine_doc_no");
			var param = {
				machine_doc_no : machineDocNo,
				sar_yn : yn
			}
			$M.goNextPageAjax(this_page+"/checkUpdate", $M.toGetParam(param), {method : 'POST', loader : false},
				function(result) {
			    	if(result.success) {

					}
				}
			);
		}
	}

	// 업무DB 연결 함수 21-08-05이강원
 	function openWorkDB(){
 		openWorkDBPanel('',$M.getValue("machine_plant_seq"));
 	}

	// [14673] 중고장비 > 매입구분 - 라디오버튼에 따른 값 변경 - 김경빈
	function fnDaeChaCheck() {
		if ($M.getValue("used_used_buy_status_cd") === "7") { // 대차
			isDaeCha = true;
		}
		fnSetDaeCha();

		$('input[name="used_used_buy_status_cd"]').change(function() {
			// 대차 선택 시
			if($('#7').prop('checked')){
				isDaeCha = true;
			}else{
				isDaeCha = false;
			}
			fnSetDaeCha();
		});
	}

	// 대차 선택 시 필수 값 및 경고문 변경
	function fnSetDaeCha() {
		if (isDaeCha) {
			// 타이틀 필수 css 제거 : 전차주명 / 연락처 / 메이커 / 연식 / 가동시간 / 매입처 / 중고금액 / 상사금액
			$("#title_used_cust_name, #title_used_hp_no, #title_used_maker_name, #title_used_reg_year, #title_used_op_hour, #title_used_mng_org_code, #title_used_used_price, #title_used_agent_price").removeClass("rs");
			// input 필수 css 제거 : 연식 / 가동시간 / 매입처 / 중고금액 / 상사금액
			$("#used_reg_year, #used_op_hour, #used_mng_org_code, #used_used_price, #used_agent_price").removeClass("rb");
			// 경고문 보이기
			$("#daecha_warning_text").show();
			// 차대번호 임의 기입 - 불가
			$("#used_body_no").attr("readonly", "readonly").removeClass("rb");
		} else {
			// 타이틀 필수 css 복구 : 전차주명 / 연락처 / 메이커 / 연식 / 가동시간 / 매입처 / 중고금액 / 상사금액
			$("#title_used_cust_name, #title_used_hp_no, #title_used_maker_name, #title_used_reg_year, #title_used_op_hour, #title_used_mng_org_code, #title_used_used_price, #title_used_agent_price").addClass("rs");
			// input 필수 css 제거 : 연식 / 가동시간 / 매입처 / 중고금액 / 상사금액
			$("#used_reg_year, #used_op_hour, #used_mng_org_code, #used_used_price, #used_agent_price").addClass("rb");
			// 경고문 숨기기
			$("#daecha_warning_text").hide();
			// 차대번호 임의 기입 - 가능
			$("#used_body_no").attr("readonly", false).addClass("rb");
		}
	}

	// 보조 체크시 특이사항에 문구 추가.
	function fnAssistCheck() {
		if ($("#assist_yn_check").is(":checked")) {
			$("#remark").attr("placeholder", "보조사업 계약의 경우 이행하자기간 및 % 기재");
			$("#btn_submit_06").show();
			$("#btn_submit_13").show();
			$("#btn_submit_14").show();
			$("#btn_submit_15").show();
			$("#btn_submit_16").show();

			// $("#tr_06").show();
			$("#tr_13").show();
			$("#tr_14").show();
			$("#tr_15").show();
			$("#tr_16").show();
		} else {
			// yn = "N";
			$("#btn_submit_06").hide();
			$("#btn_submit_13").hide();
			$("#btn_submit_14").hide();
			$("#btn_submit_15").hide();
			$("#btn_submit_16").hide();

			// $("#tr_06").hide();
			$("#tr_13").hide();
			$("#tr_14").hide();
			$("#tr_15").hide();
			$("#tr_16").hide();

			$("#remark").attr("placeholder", "");
		}
	}

	// 22.12.15 Q&A 14448 계산서미발행 시 유상부품 매출전표 처리구분 선택할 수 있도록 추가
	function fnCostTaxbillCheck(){
		if ($("#cost_taxbill_yn_check").is(":checked")) {
			$("#vat_treat_type").removeClass("dpn");
		} else {
			$("#vat_treat_type").addClass("dpn");
		}
	}

	// 주소팝업
	function fnJusoBiz(data) {
		$M.setValue("post_no", data.zipNo);
		$M.setValue("addr1", data.roadAddrPart1);
		$M.setValue("addr2", data.addrDetail);
	}

	// 2024-02-19 / 3-4차 계약품의서 결재취소, 반려로 작성중으로 돌아갈 시 어태치 갱신
	function fnAttachPriceUpdate() {
		var param = {
			"machine_doc_no" : $M.getValue("machine_doc_no"),
			"machine_plant_seq" : $M.getValue("machine_plant_seq"),
		}

		$M.goNextPageAjax(this_page + "/attach/price/update", $M.toGetParam(param), {method : 'POST', async: false},
			function(result) {
				if(result.success) {
					console.log("result : ", result);
					if (result.changeYn == 'Y') {
						alert("가격이 변동된 부품이 있습니다.\n" + result.partNameStr);
					}
				}
			}
		);
	}
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" name="appr_job_seq">
<input type="hidden" name="doc_org_code">
<input type="hidden" name="doc_mem_no">
<input type="hidden" name="write_price"> <!-- 작성자 전결가 -->
<input type="hidden" name="review_price"> <!-- 심사자 전결가 -->
<input type="hidden" name="agree_price"> <!-- 합의자 전결가 -->
<input type="hidden" name="max_dc_price"> <!-- 할인한도 -->
<input type="hidden" name="fee_price"> <!-- 수수료 -->
<input type="hidden" name="cust_no"> <!-- 고객번호 -->
<input type="hidden" name="tel_no">
<input type="hidden" name="fax_no">
<input type="hidden" name="email">
<input type="hidden" name="post_no">
<input type="hidden" name="addr1">
<input type="hidden" name="addr2">
<input type="hidden" name="breg_name">
<input type="hidden" name="breg_seq">
<input type="hidden" name="cost_breg_seq">
<input type="hidden" name="breg_no">
<input type="hidden" name="breg_rep_name">
<input type="hidden" name="cap_yn">
<input type="hidden" name="center_di_yn">
<input type="hidden" name="sar_yn">
<input type="hidden" name="assist_yn">
<input type="hidden" name="cost_taxbill_yn"> <!-- 계산서 발행여부 -->
<input type="hidden" name="reg_proxy_yn">
<input type="hidden" name="total_amt">
<input type="hidden" name="pay_complete_yn"> <!-- 결제완료여부 -->
<input type="hidden" name="save_mode">
<input type="hidden" name="machine_plant_seq">
<input type="hidden" name="machine_name_temp"> <!-- 같은 장비명 검색 여부체크용 -->
<input type="hidden" name="rfq_no">
<input type="hidden" name="machine_used_no" value="${used.machine_used_no}">
<input type="hidden" name="part_part_free_yn"> <!-- Q&A 11704 결재중, 작성자x, 결재처리자 의경우 유무상 수정여부 용도 210629 김상덕 -->
<div id="auiGridBasic" style="display: none"></div>
<!-- 팝업 -->
    <div class="popup-wrap width-100per" style="min-width: 1280px">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
			<div class="title-wrap half-print">
				<h4 class="primary">계약품의서상세</h4>
<!-- 결재영역 -->
				<div>
					<jsp:include page="/WEB-INF/jsp/common/apprHeader.jsp"></jsp:include>
				</div>
<!-- /결재영역 -->
			</div>
<!-- 폼테이블 -->
				<div class="row mt7">
<!-- 좌측 폼테이블-->
					<div class="col-7">
						<div>
							<table class="table-border">
								<colgroup>
									<col width="80px">
									<col width="220px">
									<col width="80px">
									<col width="">
									<col width="80px">
									<col width="120px">
								</colgroup>
								<tbody>
									<tr>
										<th class="text-right">관리번호</th>
										<td>
											<div class="form-row inline-pd">
												<div class="col-6">
													<input type="text" class="form-control" readonly="readonly" id="machine_doc_no" name="machine_doc_no">
												</div>
												<div class="col-3">
													<button type="button" class="btn btn-primary-gra spacing-sm" onclick="javascript:goReferEstimate();" id="btnRefer" style="display: none;">견적서참조</button>
												</div>
											</div>
										</td>
										<th class="text-right">등록일자</th>
										<td>
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate width120px" id="doc_dt" name="doc_dt" dateFormat="yyyy-MM-dd" disabled="disabled">
											</div>
										</td>
										<th class="text-right">출하희망일</th>
										<td>
											<div class="input-group" style="min-width: 130px;">
												<input type="text" class="form-control border-right-0 calDate width120px" id="receive_plan_dt" name="receive_plan_dt" dateFormat="yyyy-MM-dd" onchange="fnSetReceivePlan()">
											</div>
										</td>
									</tr>
									<tr>
										<th class="text-right rs">모델명</th>
										<td>
											<div class="form-row inline-pd">
												<div class="col-auto">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 width120px rb" id="machine_name" name="machine_name" required="required" alt="모델명">
												<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goModelInfoClick();"><i class="material-iconssearch"></i></button>
											</div>
												</div>
												<div class="col-auto">
													<c:if test="${page.fnc.F00105_003 eq 'Y'}">
				                                    	<button type="button" class="btn btn-primary-gra" onclick="javascript:openWorkDB();")>업무DB</button>
				                                    </c:if>
				                                </div>
				                             </div>
										</td>
										<th class="text-right">계약구분</th>
										<td>
											<div class="form-check form-check-inline">
												<input class="form-check-input" type="radio" id="sale_type_pg_p" name="sale_type_pg" checked="checked" value="P">
												<label for="sale_type_pg_p" class="form-check-label">일반</label>
											</div>
											<div class="form-check form-check-inline">
												<input class="form-check-input" type="radio" id="sale_type_pg_g" name="sale_type_pg" value="G">
												<label for="sale_type_pg_g" class="form-check-label">관공서</label>
											</div>
										</td>
										<th class="text-right">상태</th>
										<td id="machine_doc_status_text"></td>
									</tr>
									<tr>
										<th class="text-right">고객명</th>
										<td>
											<div class="form-row inline-pd pr">
												<div class="col-6">
													<input type="text" class="form-control" readonly="readonly" name="cust_name">
												</div>
												<input type="hidden" name="__s_machine_doc_no">
												<input type="hidden" name="__s_cust_no">
												<%-- (Q&A 16821) 대리점직원은 연관업무 안보이도록.2022-11-18 김상덕. --%>
												<c:if test="${page.fnc.F00105_003 eq 'Y'}">
													<jsp:include page="/WEB-INF/jsp/common/commonCustJob.jsp">
			                                            <jsp:param name="jobType" value="O"/>
		                                            <jsp:param name="li_type" value="__deposit#__cust_dtl#__ledger"/>
			                                        </jsp:include>
			                                    </c:if>
											</div>
										</td>
										<th class="text-right">휴대폰</th>
										<td>
											<div class="input-group" style="width: 130px">
												<input type="text" class="form-control border-right-0 width120px" readonly="readonly" id="hp_no" name="hp_no" format="phone" onchange="javascript:fnChangeHpNo()">
												<button type="button" class="btn btn-icon btn-primary-gra"  onclick="javascript:fnSendSms();"><i class="material-iconsforum"></i></button>
											</div>
										</td>
										<th class="text-right">관리등급</th>
										<td><input type="text" class="inputDiv" name="cust_grade_cd" disabled="disabled"></td>
									</tr>
									<tr>
										<th class="text-right rs">고객주소</th>
										<td colspan="5">
											<div class="form-row inline-pd">
												<div class="col-1 pdr0">
													<input type="text" class="form-control mw45" id="post_no" name="post_no" readonly="readonly" alt="고객주소">
												</div>
												<div class="col-auto pdl5">
<%--													<button type="button" class="btn btn-primary-gra" style="width: 100%;" id="addr" readonly="readonly" disabled="disabled" onclick="javascript:void(0)">주소찾기</button>--%>
													<button type="button" class="btn btn-primary-gra" style="width: 100%;" id="addr" readonly="readonly" onclick="javascript:openSearchAddrPanel('fnJusoBiz');">주소찾기</button>
												</div>
												<div class="col-5">
													<input type="text" class="form-control" id="addr1" name="addr1" readonly="readonly">
												</div>
												<div class="col-4">
													<input type="text" class="form-control" id="addr2" name="addr2" readonly="readonly">
												</div>
											</div>
										</td>
									</tr>
								</tbody>
							</table>
						</div>

						<div>
							<table class="table-border mt5">
								<colgroup>
									<col width="80px">
									<col width="190px">
									<col width="80px">
									<col width="">
									<col width="80px">
									<col width="">
								</colgroup>
								<tbody>
									<tr>
										<th class="text-right">기준판매가</th>
										<td>
											<div class="form-row inline-pd">
												<div class="col width120px">
													<input type="text" class="form-control text-right" readonly="readonly" id="sale_price" name="sale_price" value="0" format="decimal">
												</div>
												<div class="">원</div>
											</div>
										</td>
										<th class="text-right">무상부품계</th>
										<td>
											<div class="form-row inline-pd">
												<div class="col width120px">
													<input type="text" class="form-control text-right" readonly="readonly" id="part_free_amt" name="part_free_amt" value="0" format="decimal">
												</div>
												<div class="">원</div>
											</div>
										</td>
										<th class="text-right">할인</th>
										<td>
											<div class="form-row inline-pd">
												<div class="col width120px">
													<input type="text" class="form-control text-right" id="discount_amt" name="discount_amt" value="0" onchange="fnChangePrice()" format="minusNum">
												</div>
												<div class="">원</div>
											</div>
										</td>
									</tr>
									<!-- opp_cost_yn == 'Y' 일 경우 show -->
									<tr class="opp_cost" style="display: none;">
										<th class="text-right">기타매출</th>
										<td>
											<div class="form-row inline-pd">
												<div class="col width120px">
													<input type="text" class="form-control text-right" readonly="readonly" id="attach_amt" name="attach_amt" value="0" format="decimal">
												</div>
												<div class="">원</div>
											</div>
										</td>
										<th class="text-right">기회비용</th>
										<td>
											<div class="form-row inline-pd">
												<div class="col width120px">
													<input type="text" class="form-control text-right" readonly="readonly" name="opp_cost_amt" value="0" format="decimal">
												</div>
												<div class="">원</div>
											</div>
										</td>
										<th class="text-right">할인율</th>
										<td>
											<div class="form-row inline-pd">
												<div class="col width120px">
													<input type="text" class="form-control text-right" id="discount_rate" name="discount_rate" value="0" format="decimal">
												</div>
												<div class="">%</div>
											</div>
										</td>
									</tr>
									<tr>
										<%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체 --%>
										<%-- <th class="text-right">대리점가</th> --%>
										<th class="text-right">위탁판매점가</th>
										<td>
											<div class="form-row inline-pd">
												<div class="col width120px">
													<input type="text" class="form-control text-right" readonly="readonly" id="agency_price" name="agency_price" value="0" format="decimal">
												</div>
												<div class="">원</div>
											</div>
										</td>
										<th class="text-right">유상부품계</th>
										<td>
											<div class="form-row inline-pd">
												<div class="col width120px">
													<input type="text" class="form-control text-right" readonly="readonly" id="part_cost_amt" name="part_cost_amt" value="0" format="decimal" onchange="fnChangePrice()">
												</div>
												<div class="">원</div>
											</div>
										</td>
										<th class="text-right">최종판매가</th>
										<td>
											<div class="form-row inline-pd">
												<div class="col width120px">
													<input type="text" class="form-control text-right" readonly="readonly" id="sale_amt" name="sale_amt" value="0" format="decimal">
												</div>
												<div class="">원</div>
											</div>
										</td>
									</tr>
									<tr>
										<th class="text-right">본사전결가</th>
										<td>
											<div class="form-row inline-pd">
												<div class="col width120px">
													<!-- ASIS에서 대리점가 = 본사전결가 -->
													<input type="text" class="form-control text-right" readonly="readonly" name="agency_price" value="0" format="decimal">
												</div>
												<div class="">원</div>
											</div>
										</td>
										<th class="text-right">옵션관리계</th>
										<td>
											<div class="form-row inline-pd">
												<div class="col width120px">
													<input type="text" class="form-control text-right" readonly="readonly" id="attach_amt" name="attach_amt" value="0" format="decimal" onchange="fnChangePrice()">
												</div>
												<div class="">원</div>
											</div>
										</td>
										<th class="text-right rs">장비계약</th>
										<td>
											<div class="form-check form-check-inline">
												<input class="form-check-input" type="radio" id="mch_type_c" name="mch_type_cad" value="C" alt="장비계약">
												<label for="mch_type_c" class="form-check-label">건설기계</label>
											</div>
											<div class="form-check form-check-inline">
												<input class="form-check-input" type="radio" id="mch_type_a" name="mch_type_cad" value="A" alt="장비계약">
												<label for="mch_type_a" class="form-check-label">농기계</label>
											</div>
										</td>
									</tr>
									<tr>
										<th class="text-right">실판매가</th>
										<td>
											<div class="form-row inline-pd">
												<div class="col width120px">
													<input type="text" class="form-control text-right" readonly="readonly" id="real_sale_amt" name="real_sale_amt" value="0" format="decimal">
												</div>
												<div class="">원</div>
											</div>
										</td>
										<th class="text-right">
											<c:if test="${machine_doc_status_cd eq '2' and page.add.ACNT_MNG_YN eq 'Y'}">
												차대선지정
											</c:if>
										</th>
										<td>
											<c:if test="${machine_doc_status_cd eq '2' and page.add.ACNT_MNG_YN eq 'Y' and empty pre_body_no_map}">
												<button type="button" class="btn btn-info" onclick="javascript:goRequestPreMachine('REQUEST')">선지정요청</button>
											</c:if>
											<c:if test="${machine_doc_status_cd eq '2' and page.add.ACNT_MNG_YN eq 'Y' and not empty pre_body_no_map}">
												<button type="button" class="btn btn-info" onclick="javascript:goRequestPreMachine('CANCEL')">선지정취소요청</button>
											</c:if>
										</td>
										<th class="text-right">계약금</th>
										<td>
											<div class="form-row inline-pd">
												<div class="col width120px">
													<input type="text" class="form-control text-right" id="contract_amt" name="contract_amt" format="decimal">
												</div>
												<div class="">원</div>
											</div>
										</td>
									</tr>
								</tbody>
							</table>
						</div>

						<div>
<!-- 그리드 타이틀, 컨트롤 영역 -->
							<div class="title-wrap mt5">
								<h4>선택사항</h4>
								<div class="btn-group">
									<div class="right">
										<select name="opt_code" id="opt_code" style="height: 24px; display: none;" onchange="fnChangeOpt()"></select>
									</div>
								</div>
							</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->
							<div id="auiGridOption" style="margin-top: 5px; height: 100px;"></div>
						</div>
						<div>
<!-- 그리드 타이틀, 컨트롤 영역 -->
							<div class="title-wrap mt5">
								<h4>옵션관리</h4>
							</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->
							<div id="auiGridAttach" style="margin-top: 5px;"></div>
						</div>
<!-- 그리드 타이틀, 컨트롤 영역 -->
						<div class="title-wrap mt5">
							<div class="btn-group">
								<div class="right">
									<button type="button" class="btn btn-default" onclick="javascript:goItemDetailPopup();" id="basicDtlBtn" style="display: none;">기본지급품 상세</button>
								</div>
							</div>
						</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->
						<div class="boxing vertical-line mt5" id="basicItemList" style="height: 33px;"></div>

<!-- 센터DI 외 -->
							<div id="ynWrapper">
								<table class="table-border doc-table mt5" id="yCnt" style="width: 100%;">
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
													<input class="form-check-input position-static mt0" type="checkbox" name="cap_yn_check" id="cap_yn_check" value="Y" onchange="javascript:fnCapCheck('click')">
												</div>
											</td>
											<th class="sarYn">SA-R</th>
											<td class="text-center sarYn">
												<div class="form-check">
													<input class="form-check-input position-static mt0" type="checkbox" name="sar_yn_check" id="sar_yn_check" value="Y" onchange="javascript:fnSarCheck('click')">
												</div>
											</td>
											<!-- 신정애요청에 의해 대리점은 21.6.24 등록대행못함 -->
											<c:if test="${base_yn eq 'Y'}">
												<th class="proxyYn" style="width: 67px;">등록대행</th>
												<td class="text-center proxyYn" style="width: 230px">
													<div class="form-check">
														<input class="form-check-input position-static mt0" style="margin-right: 5px;" type="checkbox" id="reg_proxy_yn_check" name="reg_proxy_yn_check" onclick="fnCalcProxyAmt()" value="Y">
														<input type="text" id="reg_proxy_amt" name="reg_proxy_amt" format="decimal" class="form-control text-right" style="width: 100px; display: inline-block;" readonly="readonly"><span style="margin-left: 5px;">원</span>
														<input type="button" class="btn btn-info" value="문자전송" style="margin-left: 5px;" onclick="javascript:goProxySms()">
													</div>
												</td>
											</c:if>
											<th class="assistYn">보조</th>
											<td class="text-center assistYn">
												<div class="form-check">
													<input class="form-check-input position-static mt0" type="checkbox" id="assist_yn_check" name="assist_yn_check" value="Y" onchange="javascript:fnAssistCheck('click');">
												</div>
											</td>
										</tr>
									</tbody>
								</table>
							</div>
<!-- /센터DI 외 -->
<!-- 특이사항 및 담당자의견 -->
						<div class="row">
							<div class="col-6">
								<div class="title-wrap mt5">
									<h4>담당자 의견</h4>
								</div>
								<textarea class="form-control mt5" style="height: 160px;" name="remark" id="remark"></textarea>
							</div>
							<div class="col-6">
								<div class="title-wrap mt5">
									<h4>특약사항</h4>
								</div>
								<textarea class="form-control mt5" style="height: 160px;" name="special_remark" id="special_remark"></textarea>
							</div>
						</div>
						<c:if test="${not empty submitList}">
							<div id="submitList">
								<div class="title-wrap mt10">
									<h4>제출서류</h4>
									<div>
										<button type="button" class="btn btn-primary-gra" onclick="javascript:goFileUploadPopup()" id="btn_submit_">파일찾기</button>
										<button type="button" class="btn btn-info" onclick="javascript:goSaveSubmit()">서류저장</button>
										<c:if test="${page.add.ACNT_MNG_YN eq 'Y' or apprBean.doc_confirm_yn eq 'Y' or page.fnc.F00105_001 eq 'Y'}">
											<c:if test="${page.fnc.F00105_003 eq 'Y'}">
												<button type="button" class="btn btn-info" onclick="javascript:goConfirmSubmit()">서류확인</button>
											</c:if>
										</c:if>
									</div>
								</div>
								<table class="table-border doc-table mt5">
									<colgroup>
										<col width="20%">
										<col width="">
										<col width="20%">
									</colgroup>
									<thead>
										<tr>
											<th class="title-bg">제출서류명</th>
											<th class="title-bg">첨부파일</th>
											<th class="title-bg">담당자확인</th>
										</tr>
									</thead>
									<tbody>
									<c:forEach var="item" items="${submitList}">
										<c:if test="${(checkFile eq 'N' and item.mch_sale_doc_file_cd ne '01' and item.mch_sale_doc_file_cd ne '02' and item.mch_sale_doc_file_cd ne '03') or
										(checkFile ne 'N' and item.mch_sale_doc_file_cd ne '07')}">
										<tr id="tr_${item.mch_sale_doc_file_cd}">
											<th class="title_code_name">${item.code_name }</th>
											<td>
												<div class="table-attfile submit_${item.mch_sale_doc_file_cd}_div">
													<div name="fileAttach" id="tag_${item.mch_sale_doc_file_cd}" type_name="${item.code_name}">
													<c:if test="${not empty item.origin_file_name }">
														<div class="table-attfile-item submit_${item.mch_sale_doc_file_cd}">
															<c:if test="${fn:endsWith(item.origin_file_name, 'pdf') eq true}">
																<a href="javascript:openFileViewerPanel(${item.file_seq})">${item.origin_file_name }</a>
															</c:if>
															<c:if test="${fn:endsWith(item.origin_file_name, 'pdf') eq false}">
																<a href="javascript:fnLayerImage(${item.file_seq})">${item.origin_file_name }</a>
															</c:if>
															<input type="hidden" name="file_seq_${item.mch_sale_doc_file_cd}" value="${item.file_seq }">
															<c:if test="${(item.mch_sale_doc_file_cd eq '04' and basic.cust_modu_modify_yn eq 'Y') or (item.mch_sale_doc_file_cd eq '07' and basic.doc_modu_modify_yn eq 'Y')}">
																(수정중)
															</c:if>
															<c:if test="${item.pass_ypn ne 'Y'}">
																<button type="button" class="btn-default" onclick="javascript:fnRemoveFile('${item.mch_sale_doc_file_cd}')"><i class="material-iconsclose font-18 text-default"></i></button>
															</c:if>
														</div>
													</c:if>
													<c:if test="${empty item.origin_file_name }">
														<c:choose>
															<c:when test="${(item.mch_sale_doc_file_cd eq '04' and cust_check_yn eq 'Y') or (item.mch_sale_doc_file_cd eq '07' and doc_check_yn eq 'Y') }">
																고객확인중
															</c:when>
															<c:otherwise>
																<c:if test="${SecureUser.mem_no eq doc_mem_no}">
																	<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goFileUploadPopup('${item.mch_sale_doc_file_cd}')" id="btn_submit_${item.mch_sale_doc_file_cd}">파일찾기</button>
																</c:if>
																<c:if test="${SecureUser.mem_no ne doc_mem_no }">
																	작성자만 첨부가능
																</c:if>
															</c:otherwise>
														</c:choose>
													</c:if>
												</div>
												</div>
											</td>
											<td>
												<c:if test="${not empty item.origin_file_name}">
													<div class="form-check form-check-inline">
														<input class="form-check-input" type="radio" id="pass_ypn_${item.mch_sale_doc_file_cd }_Y" name="pass_ypn_${item.mch_sale_doc_file_cd }" value="Y" ${item.pass_ypn eq 'Y' ? 'checked' : '' }>
														<label class="form-check-label" for="pass_ypn_${item.mch_sale_doc_file_cd }_Y">적합</label>
													</div>
													<div class="form-check form-check-inline">
														<input class="form-check-input" type="radio" id="pass_ypn_${item.mch_sale_doc_file_cd }_N" name="pass_ypn_${item.mch_sale_doc_file_cd }" value="N" ${item.pass_ypn eq 'N' ? 'checked' : '' }
															<c:if test="${empty item.origin_file_name}">disabled</c:if>>
														<label class="form-check-label" for="pass_ypn_${item.mch_sale_doc_file_cd }_N">부적합</label>
													</div>
												</c:if>
												<c:if test="${empty item.origin_file_name}">
													확인할 파일없음
												</c:if>
											</td>
										</tr>
										</c:if>
									</c:forEach>
									</tbody>
								</table>
							</div>
							</c:if>
<!-- /특이사항 및 담당자의견 -->
					</div>
<!-- 좌측 폼테이블-->
<!-- 우측 폼테이블-->
					<div class="col-5">
						<!-- 결제조건 -->
						<div class="mb5">
								<div class="title-wrap">
								<h4>결제조건</h4>
								<!-- machine deposit plan -->
								<!-- 0 현금, 1 카드, 2 어음, 3 금융, 4 중고, 5 보조, 6 부가세 -->
							</div>
							<table class="table-border doc-table mt5" id="paymentTable">
								<colgroup>
									<col width="25%" id="c1">
									<col width="25%" id="c2">
									<col width="25%" id="c3">
									<col width="25%" id="c4">
									<col width="25%" id="c5">
									<col width="25%" id="c6">
								</colgroup>
<%--								<thead>--%>
<%--									<tr>--%>
<%--										<th class="title-bg">구분</th>--%>
<%--										<th class="title-bg">금액</th>--%>
<%--										<th class="title-bg opp_cost">일수</th>--%>
<%--										<th class="title-bg">입금예정일</th>--%>
<%--										<th class="title-bg">입금액</th>--%>
<%--										<th class="title-bg opp_cost">기회비용</th>--%>
<%--									</tr>--%>
<%--								</thead>--%>
								<tbody>
										<tr>
											<th>현금</th>
											<td>
												<div class="form-row inline-pd">
													<div class="col-10">
														<input type="text" class="form-control text-right" id="plan_amt_0" name="plan_amt_0" format="num" onchange="fnChangePrice()">
													</div>
													<div class="col-2">원</div>
												</div>
											</td>
<%--											<td>--%>
<%--												<div class="input-group">--%>
<%--													<input type="text" class="form-control border-right-0 calDate" id="plan_dt_0" name="plan_dt_0" dateFormat="yyyy-MM-dd">--%>
<%--												</div>--%>
<%--											</td>--%>
<%--											<td>--%>
<%--												<div class="form-row inline-pd">--%>
<%--													<div class="col-10">--%>
<%--														<input type="text" class="form-control text-right" id="deposit_amt_0" name="deposit_amt_0" format="decimal" readonly="readonly">--%>
<%--													</div>--%>
<%--													<div class="col-2">원</div>--%>
<%--												</div>--%>
<%--											</td>--%>
											<th>카드</th>
											<td>
												<div class="form-row inline-pd">
													<div class="col-10">
														<input type="text" class="form-control text-right" id="plan_amt_1" name="plan_amt_1" format="num" onchange="fnChangePrice()">
													</div>
													<div class="col-2">원</div>
												</div>
											</td>
<%--											<td>--%>
<%--												<div class="input-group">--%>
<%--													<input type="text" class="form-control border-right-0 calDate" id="plan_dt_1" name="plan_dt_1" dateFormat="yyyy-MM-dd">--%>
<%--												</div>--%>
<%--											</td>--%>
<%--											<td>--%>
<%--												<div class="form-row inline-pd">--%>
<%--													<div class="col-10">--%>
<%--														<input type="text" class="form-control text-right" id="deposit_amt_1" name="deposit_amt_1" format="decimal" readonly="readonly">--%>
<%--													</div>--%>
<%--													<div class="col-2">원</div>--%>
<%--												</div>--%>
<%--											</td>--%>
										</tr>
										<tr>
											<th>중고</th>
											<td>
												<div class="form-row inline-pd">
													<div class="col-10">
														<input type="text" class="form-control text-right" id="plan_amt_4" name="plan_amt_4" format="num" onchange="fnChangePrice()">
													</div>
													<div class="col-2">원</div>
												</div>
											</td>
<%--											<td>--%>
<%--												<div class="input-group">--%>
<%--													<input type="text" class="form-control border-right-0 calDate" id="plan_dt_4" name="plan_dt_4" dateFormat="yyyy-MM-dd">--%>
<%--												</div>--%>
<%--											</td>--%>
<%--											<td>--%>
<%--												<div class="form-row inline-pd">--%>
<%--													<div class="col-10">--%>
<%--														<input type="text" class="form-control text-right" id="deposit_amt_4" name="deposit_amt_4" format="decimal" readonly="readonly">--%>
<%--													</div>--%>
<%--													<div class="col-2">원</div>--%>
<%--												</div>--%>
<%--											</td>--%>
											<th>캐피탈</th>
											<td>
												<div class="form-row inline-pd">
													<div class="col-10">
														<input type="text" class="form-control text-right" id="plan_amt_3" name="plan_amt_3" format="num" onchange="fnChangePrice()">
													</div>
													<div class="col-2">원</div>
												</div>
											</td>
<%--											<td>--%>
<%--												<div class="input-group">--%>
<%--													<input type="text" class="form-control border-right-0 calDate" id="plan_dt_3" name="plan_dt_3" dateFormat="yyyy-MM-dd">--%>
<%--												</div>--%>
<%--											</td>--%>
<%--											<td>--%>
<%--												<div class="form-row inline-pd">--%>
<%--													<div class="col-10">--%>
<%--														<input type="text" class="form-control text-right" id="deposit_amt_3" name="deposit_amt_3" format="decimal" readonly="readonly">--%>
<%--													</div>--%>
<%--													<div class="col-2">원</div>--%>
<%--												</div>--%>
<%--											</td>--%>
										</tr>
										<tr>
											<th>보조</th>
											<td>
												<div class="form-row inline-pd">
													<div class="col-10">
														<input type="text" class="form-control text-right" id="plan_amt_5" name="plan_amt_5" format="num" onchange="fnChangePrice()">
													</div>
													<div class="col-2">원</div>
												</div>
											</td>
<%--											<td>--%>
<%--												<div class="input-group">--%>
<%--													<input type="text" class="form-control border-right-0 calDate" id="plan_dt_5" name="plan_dt_5" dateFormat="yyyy-MM-dd">--%>
<%--												</div>--%>
<%--											</td>--%>
<%--											<td>--%>
<%--												<div class="form-row inline-pd">--%>
<%--													<div class="col-10">--%>
<%--														<input type="text" class="form-control text-right" id="deposit_amt_5" name="deposit_amt_5" format="decimal" readonly="readonly">--%>
<%--													</div>--%>
<%--													<div class="col-2">원</div>--%>
<%--												</div>--%>
<%--											</td>--%>
											<th>VAT</th>
											<td>
												<div class="form-row inline-pd">
													<div class="col-10">
														<input type="text" class="form-control text-right" id="plan_amt_6" name="plan_amt_6" format="decimal" onchange="fnChangePrice()" readonly="readonly">
													</div>
													<div class="col-2">원</div>
												</div>
											</td>
<%--											<td>--%>
<%--												<div class="input-group">--%>
<%--													<input type="text" class="form-control border-right-0 calDate" id="plan_dt_6" name="plan_dt_6" dateFormat="yyyy-MM-dd">--%>
<%--												</div>--%>
<%--											</td>--%>
<%--											<td>--%>
<%--												<div class="form-row inline-pd">--%>
<%--													<div class="col-10">--%>
<%--														<input type="text" class="form-control text-right" id="deposit_amt_6" name="deposit_amt_6" format="decimal" readonly="readonly">--%>
<%--													</div>--%>
<%--													<div class="col-2">원</div>--%>
<%--												</div>--%>
<%--											</td>--%>
										</tr>
<%--										<tr>--%>
<%--											<th class="pdl0 pdr0">캐피탈선택</th>--%>
<%--											<td colspan="3" id="opp_capital_select">--%>
<%--												<select class="form-control" name="finance_cmp_cd">--%>
<%--													<option value="">- 선택 -</option>--%>
<%--													<c:forEach var="item" items="${codeMap['FINANCE_CMP']}">--%>
<%--														<option value="${item.code_value}">${item.code_name}</option>--%>
<%--													</c:forEach>--%>
<%--												</select>--%>
<%--											</td>--%>
<%--										</tr>--%>
										<tr>
											<th class="th-sum" id="opp_total_vat_th">총액(VAT포함)</th>
											<td id="opp_total_vat_td">
												<div class="form-row inline-pd">
													<div class="col-10">
														<input type="text" class="form-control text-right" readonly="readonly" id="total_vat_amt" name="total_vat_amt" format="num">
													</div>
													<div class="col-2">원</div>
												</div>
											</td>
											<th class="th-sum">결제조건 잔액</th>
											<td id="opp_balance">
												<div class="form-row inline-pd">
													<div class="col-10">
														<input type="text" class="form-control text-right" readonly="readonly" id="balance" name="balance" format="num">
													</div>
													<div class="col-2">원</div>
												</div>
											</td>
										</tr>
										<tr>
											<th class="th-sum">가상계좌번호</th>
											<td colspan="2">
												<input type="text" class="form-control" value="${virtual.virtual_account_no }" readonly="readonly">
											</td>
											<td>
												<div class="title-wrap"
													 style="flex-direction: row; justify-content: space-evenly">
											<c:if test="${not empty virtual && not empty virtual.virtual_account_no}">
													<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
														<jsp:param name="pos" value="BOM_M"/>
													</jsp:include>
											</c:if>

											<c:if test="${empty virtual && empty virtual.virtual_account_no}">
												<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
											</c:if>
												</div>
											</td>
										</tr>
										<tr>
										<th class="th-sum">가상계좌한도액</th>
											<td>
												<div class="form-row inline-pd">
													<div class="col-10">
														<input type="text" class="form-control text-right" readonly="readonly" format="num" id="in_max_amt" name="in_max_amt">
													</div>
													<div class="col-2">원</div>
												</div>
											</td>
											<th class="th-sum">가상계좌입금액</th>
											<td>
												<div class="form-row inline-pd">
													<div class="col-10">
														<input type="text" class="form-control text-right" readonly="readonly" format="num" id="sum_amt" name="sum_amt">
													</div>
													<div class="col-2">원</div>
												</div>
											</td>
										</tr>
								</tbody>
							</table>
						</div>
						<!-- /결제조건 -->
						<!-- 탭 -->
						<ul class="tabs-c">
							<li class="tabs-item">
								<a href="#" class="tabs-link font-12 active" data-tab="inner1">유무상부품관리</a>
							</li>
							<li class="tabs-item">
								<a href="#" class="tabs-link font-12" data-tab="inner2" id="used-tab">중고장비</a>
							</li>
						</ul>
<!-- /탭 -->
						<div class="tabs-inner active" id="inner1">
							<div class="tabs-inner-line">
<!-- 유상 -->
								<div class="title-wrap">
									<h4>유상</h4>
									<div class="condition-items pl10">
										<div class="left">
											<div class="form-row inline-pd">
												<div class="col-4">
													<div class="input-group">
														<input type="text" class="form-control border-right-0" id="cost_part_breg_no" name="cost_part_breg_no" format="bregno" placeholder="유상부품 사업자번호 " readonly="readonly" style="background: white">
														<input type="hidden" id="cost_part_breg_seq" name="cost_part_breg_seq">
														<button type="button" class="btn btn-icon btn-primary-gra" id="_goSearchBregInfo" onclick="javascript:goSearchBregInfo();"><i class="material-iconssearch"></i></button>
													</div>
												</div>
												<div class="col-2">
													<input type="text" class="form-control" readonly="readonly" id="cost_part_breg_rep_name" name="cost_part_breg_rep_name">
												</div>
												<div class="col-3">
													<input type="text" class="form-control" readonly="readonly" id="cost_part_breg_name" name="cost_part_breg_name">
												</div>
												<div class="col-3">
													<div class="form-check" style="text-align: center;">
														<input class="form-check-input" type="checkbox" name="cost_taxbill_yn_check" id="cost_taxbill_yn_check" value="Y" onclick="javascript:fnCostTaxbillCheck();">
														<label for="cost_taxbill_yn_check">계산서미발행</label>
													</div>
												</div>
											</div>
										</div>
										<div>
											<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
										</div>
									</div>
								</div>
								<div class="text-right" id="vat_treat_type">
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="vat_treat_type_a" name="vat_treat_cd" value="A">
										<label for="vat_treat_type_a" class="form-check-label">현금영수증</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="vat_treat_type_c" name="vat_treat_cd" value="C">
										<label for="vat_treat_type_c" class="form-check-label">카드매출</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="vat_treat_type_n" name="vat_treat_cd" value="N">
										<label for="vat_treat_type_n" class="form-check-label">무증빙</label>
									</div>
								</div>
								<div id="auiGridPart" style="margin-top: 5px; height: 100px"></div>
<!-- /유상 -->
<!-- 무상 -->
								<div class="title-wrap mt5">
									<!-- [14458] 무상 -> 기본지급품으로 변경 -->
									<h4>기본지급품</h4>
								</div>
								<div id="auiGridPartFree" style="margin-top: 5px; height: 240px"></div>
<!-- /무상 -->
								<div class="title-wrap mt5">
									<h4>임의비용</h4>
								</div>
								<div id="auiGridOppCost" style="margin-top: 5px; height: 110px"></div>

								<div class="title-wrap mt5">
									<h4>원가반영</h4>
								</div>
								<div id="auiGridCostApply" style="margin-top: 5px; height: 110px"></div>
							</div>
						</div>
						<!-- 중고장비 탭-->
						<div class="tabs-inner" id="inner2">
								<div class="tabs-inner-line">
<!-- 테이블 -->
									<table class="table-border">
										<colgroup>
											<col width="75px">
											<col width="">
											<col width="75px">
											<col width="">
										</colgroup>
										<tbody>
											<tr>
												<th class="text-right rs">매입구분</th>
												<td colspan="3">
													<div class="form-row inline-pd">
														<div class="col-6">
															<c:forEach items="${codeMap['USED_BUY_STATUS']}" var="item" varStatus="status">
																<c:if test="${item.code_v1 eq 'Y'}">
																	<div class="form-check form-check-inline v-align-middle" style="margin-right: 0.5rem">
																		<input type="radio" id="${item.code_value}" name="used_used_buy_status_cd" class="form-check-input" value="${item.code_value}"
																		<c:choose>
																			<c:when test="${empty used.used_buy_status_cd}">
																				<c:if test="${status.first }">checked="checked"</c:if>
																			</c:when>
																			<c:otherwise>
																				<c:if test="${used.used_buy_status_cd eq item.code_value}">checked="checked"</c:if>
																			</c:otherwise>
																		</c:choose>
																		> <!-- 꺽쇠 지우지 말것 input의 끝임. -->
																		<label for="${item.code_value}" class="form-check-label">${item.code_name}</label>
																	</div>
																</c:if>
															</c:forEach>
														</div>
														<div class="col-4" style="text-align: right">
															<span id="daecha_warning_text" class="text-warning">※ 대차는 자사장비만 해당</span>
														</div>
														<div class="col-2" style="text-align: right">
															<button type="button" class="btn btn-info" onclick="javascript:fnRemoveUsedMachineInfo()" id="btnUsedInit">초기화</button>
														</div>
													</div>
												</td>
											</tr>
											<tr>
												<th id="title_used_cust_name" class="text-right rs">전차주명</th>
												<td>
													<input type="text" class="form-control width120px" name="used_cust_name" id="used_cust_name" alt="중고장비 전차주명" readonly="readonly">
												</td>
												<th id="title_used_hp_no" class="text-right rs">연락처</th>
												<td>
													<input type="text" class="form-control width120px" name="used_hp_no" id="used_hp_no" alt="중고장비 연락처" readonly="readonly">
												</td>
											</tr>
											<tr>
												<th class="text-right rs">모델</th>
												<td>
													<div class="input-group">
														<input type="text" class="form-control border-right-0 width120px used" name="used_machine_name" id="used_machine_name" alt="중고장비 모델" value="${used.machine_name}" readonly="readonly">
														<input type="hidden" name="used_machine_plant_seq" value="${used.used_machine_plant_seq}">
														<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goUsedModelInfoClick();"><i class="material-iconssearch"></i></button>
													</div>
												</td>
												<th id="title_used_maker_name" class="text-right rs">메이커</th>
												<td>
													<div class="input-group">
														<input type="text" class="form-control width120px" name="used_maker_name" id="used_maker_name" alt="중고장비 메이커" readonly="readonly" value="${not empty used.temp_maker_name ? used.temp_maker_name : used.maker_name}">
													</div>
												</td>
											</tr>
											<tr>
												<th class="text-right rs">차대번호</th>
												<td>
													<div class="input-group">
														<div class="icon-btn-cancel-wrap " style="width : calc(100% - 24px);">
															<input type="text" class="form-control border-right-0 used rb" name="used_body_no" id="used_body_no" alt="중고장비 차대번호" ${empty used.machine_seq ? '' : 'readonly="readonly"'} value="${used.body_no}">
															<button type="button" class="icon-btn-cancel ${empty used.machine_seq ? 'dpn' : ''}" style="top: 50%;transform: translateY(-50%); margin-top: -1px;" onclick="fnSetClearUsedBodyNo()" id="clear-btn"><i class="material-iconsclose font-16 text-default"></i></button>
														</div>
														<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchDeviceHisPanel('fnSetUsedBodyNo');"><i class="material-iconssearch"></i></button>
													</div>
													<input type="hidden" name="used_machine_seq" value="${used.machine_seq }">
												</td>
												<th id="title_used_reg_year" class="text-right rs">연식</th>
												<td>
													<select class="form-control width120px rb used" name="used_reg_year" id="used_reg_year" alt="중고장비 연식">
														<option value="">- 선택 -</option>
														<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
															<option value="${i}" <c:if test="${used.reg_year eq i}">selected="selected"</c:if>>${i}년</option>
														</c:forEach>
													</select>
												</td>
											</tr>
											<tr>
												<th class="text-right">기종</th>
												<td>
													<input type="text" class="form-control width120px" name="used_machine_type_name" id="used_machine_type_name" alt="중고장비 기종" readonly="readonly" value="${not empty used.temp_machine_type_name ? used.temp_machine_type_name : used.machine_type_name}">
												</td>
												<th class="text-right">규격</th>
												<td>
													<input type="text" class="form-control width120px" name="used_machine_sub_type_name" id="used_machine_sub_type_name" alt="중고장비 규격" readonly="readonly" value="${not empty used.temp_machine_sub_type_name ? used.temp_machine_sub_type_name : used.machine_sub_type_name}">
												</td>
											</tr>
											<tr>
												<th id="title_used_op_hour" class="text-right rs">가동시간</th>
												<td>
													<input type="text" class="form-control width120px rb used" name="used_op_hour" id="used_op_hour" alt="중고장비 가동시간" format="num" value="${used.op_hour}">
												</td>
												<th id="title_used_mng_org_code" class="text-right rs">매입처</th>
												<td>
													<select class="form-control rb" name="used_mng_org_code" id="used_mng_org_code" alt="중고장비 매입처">
														<option value="">- 선택 -</option>
														<c:forEach items="${usedMngOrgCdList}" var="item">
															<option value="${item.org_code}" <c:if test="${used.mng_org_code eq item.org_code}">selected="selected"</c:if>>${item.org_name}</option>
														</c:forEach>
													</select>
												</td>
											</tr>
											<tr>
												<th id="title_used_used_price" class="text-right rs">중고금액</th>
												<td>
													<div class="form-row inline-pd">
														<div class="col width120px">
															<input type="text" class="form-control text-right rb used" name="used_used_price" id="used_used_price" alt="중고장비 중고금액" datatype="int" format="decimal" onchange="fnChangePrice()" value="${used.used_price}">
														</div>
														<div class="col-2">원</div>
													</div>
												</td>
												<th id="title_used_agent_price" class="text-right rs">상사금액</th>
												<td>
													<div class="form-row inline-pd">
														<div class="col width120px">
															<input type="text" class="form-control text-right rb used" name="used_agent_price" id="used_agent_price" alt="중고장비 상사금액" datatype="int" format="decimal" value="${used.agent_price}">
														</div>
														<div class="col-2">원</div>
													</div>
												</td>
											</tr>
											<tr>
												<th class="text-right">특이사항</th>
												<td colspan="3">
													<input type="text" class="form-control used" id="used_remark" name="used_remark" maxlength="35" value="${used.remark}">
												</td>
											</tr>

									</tbody>
							</table>
<!-- /테이블 -->
								</div>
						</div>
<!-- /중고장비 탭-->

<!-- 입금자정보-->
						<!-- [14466] 입금자정보 삭제 -->
						<!-- <div>
							<div class="title-wrap mt5">
								<h4>입금자정보</h4>
								<c:if test="${empty virtual && empty virtual.virtual_account_no}">
									<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
								</c:if>
							</div>
							<table class="table-border mt5">
								<colgroup>
									<col width="80px">
									<col width="">
									<col width="80px">
									<col width="">
									<col width="80px">
									<col width="">
								</colgroup>
								<tbody>
									<tr>
										<th class="title-bg">입금자명</th>
										<td>
											<input type="text" class="form-control text-right width120px" name="deposit_name">
										</td>
										<th class="title-bg">입금은행</th>
										<td>
											<input type="text" class="form-control text-right width120px" name="bank_name">
										</td>
										<th class="title-bg">입금예정금액</th>
										<td>
											<div class="form-row inline-pd">
												<div class="col-10">
													<input type="text" class="form-control text-right width120px" id="deposit_plan" name="deposit_plan" alt="입금예정금액" format="decimal">
												</div>
												<div class="col-2">원</div>
											</div>
										</td>
									</tr>
								</tbody>
							</table>
						</div> -->
<!-- /입금자정보-->
<!-- 결재자의견-->
						<c:if test="${(apprMemoList != null || mchDocMemoList != null) && (apprMemoList.size()+mchDocMemoList.size()) != 0}">
							<div id="apprMemoList">
								<div class="title-wrap mt5">
									<h4>결재자의견</h4>
								</div>
								<table class="table-border doc-table md-table">
									<colgroup>
										<col width="55px">
										<col width="140px">
										<col width="55px">
										<col width="">
									</colgroup>
									<thead>
										<!-- 퍼블리싱 파일의 important 속성 때문에 dev에 선언한 클래스가 안되서 인라인 CSS로함 -->
										<tr><th class="th" style="font-size: 12px !important">구분</th>
										<th class="th" style="font-size: 12px !important">결재일시</th>
										<th class="th" style="font-size: 12px !important">담당자</th>
										<th class="th" style="font-size: 12px !important">특이사항</th>
									</tr></thead>
									<tbody>
										<c:forEach var="list" items="${apprMemoList}">
											<tr>
												<td class="td" style="text-align: center; font-size: 12px !important">${list.appr_status_name }</td>
												<td class="td" style="font-size: 12px !important">${list.proc_date }</td>
												<td class="td" style="text-align: center; font-size: 12px !important">${list.appr_mem_name }</td>
												<td class="td" style="font-size: 12px !important">${list.memo }</td>
											</tr>
										</c:forEach>
										<c:forEach var="list" items="${mchDocMemoList}">
											<tr>
												<td class="td" style="text-align: center; font-size: 12px !important">${list.m_mch_doc_memo_type_name }</td>
												<td class="td" style="font-size: 12px !important">${list.m_reg_date }</td>
												<td class="td" style="text-align: center; font-size: 12px !important">${list.m_mem_name }</td>
												<td class="td" style="font-size: 12px !important">${list.m_memo_text }</td>
											</tr>
										</c:forEach>
									</tbody>
								</table>
							</div>
						</c:if>
<!-- /결재자의견-->
					</div>
<!-- 우측 폼테이블-->
				</div>
<!-- /폼테이블 -->
<!-- 그리드 서머리, 컨트롤 영역 -->
				<div class="btn-group mt5">
					<div class="right">
						<c:if test="${machine_doc_status_cd ne '0' and machine_doc_status_cd ne '4' and machine_doc_status_cd ne '5' }">
							<c:choose>
								<c:when test="${'N' eq out_hold_yn }">
									<button type="button" class="btn btn-info" onclick="javascript:goMemoText('hold')">보류</button>
								</c:when>
								<c:otherwise>
									<button type="button" class="btn btn-danger" onclick="javascript:goMemoText('cancel')">계약취소</button>
									<button type="button" class="btn btn-info" onclick="javascript:goHoldCancel()">보류취소</button>
								</c:otherwise>
							</c:choose>
						</c:if>
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
							<jsp:param name="pos" value="BOM_R"/>
							<jsp:param name="mem_no" value="${doc_mem_no }"/>
							<jsp:param name="appr_yn" value="Y"/>
						</jsp:include>
					</div>
				</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>
