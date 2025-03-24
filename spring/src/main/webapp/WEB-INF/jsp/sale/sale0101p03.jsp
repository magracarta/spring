<%@ page contentType="text/html;charset=utf-8" language="java" %><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 계약관리 > 계약/출하 > null > 출하의뢰서작성
-- 작성자 : 김태훈
-- 최초 작성일 : 2019-12-19 14:23:48
-- 장비출하할때 가상계좌 입금액이 0원이면 미할당으로 변경하기로 함 2020-11-03
-- 관공서, 고객이 렌탈일때 입금액 확인 X, 렌탈고객 (20130603145119670) 일때 판매구분 렌탈
-- Q&A 요청 10505 = 도착일자, 도착시간 -> 출발일자, 출발시간 적용 2021-02-17
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">

        var auiGrid_part;
        var auiGrid_option;

    	var parentPaidList; // 유상부품 그리드 데이터 ( 유무상 팝업창으로 넘길 그리드 데이터)
    	var parentFreeList; // 무상부품 그리드 데이터 ( 유무상 팝업창으로 넘길 그리드 데이터)

    	var statusCd = "${outDoc.machine_out_status_cd}";

        var isNeedSar = true;

        // 자꾸 중복으로 저장되서 변수로 체크~!!!!!!!!!
        var isRun = false;

    	var submitType = ""; // 첨부서류
    	var codeMapDocFileArray = JSON.parse('${codeMapJsonObj['MCH_SALE_DOC_FILE']}');

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

    	// 차대 선지정 요청 쪽지발송
    	function goRequestPreMachine() {
    		if ($M.getValue("out_org_code") == "") {
    			alert("출하센터가 지정되지 않았습니다.");
    			return false;
    		};
    		var param = {
    			out_org_code : $M.getValue("out_org_code"),
    			machine_doc_no : "${outDoc.machine_doc_no}",
   	       		cust_name : "${custInfo.cust_name}", // 쪽지용
   	       		machine_name : "${machineInfo.machine_name}" // 쪽지용
    		}
    		$M.goNextPageAjaxMsg("차대선지정요청하시겠습니까?", "/sale/sale0101p03/requestPreMachine", $M.toGetParam(param), {method : 'POST'},
        			function(result) {
        		    	if(result.success) {

        				}
        			}
        		);
    	}

    	function fnSetPlanTi(row) {
    		console.log(row);
    		var ti1 = row.code.substr(0, 2);
    		var ti2 = row.code.substr(2, 4);
    		$M.setValue("receive_plan_ti_1", ti1);
    		$M.setValue("receive_plan_ti_2", ti2);

    		var tempTi = ti1+"시 "+ti2+"분";
    		$M.setValue("receive_plan_ti_temp", tempTi);
    	}

    	function fnInitPlanTi() {
    		$M.setValue("receive_plan_ti_1", "00");
    		$M.setValue("receive_plan_ti_2", "00");
    		$M.setValue("receive_plan_ti_temp", "00시 00분");
    	}

    	function goPlanTiPopup() {
    		var planDt = $M.getValue("receive_plan_dt");
    		if (planDt == "") {
    			alert("출하 예정일자를 선택해주세요.");
    			$("#receive_plan_dt").focus();
    			return false;
    		}
    		var outOrgCode = $M.getValue("out_org_code");
    		// 센터가 지정되지않으면(기타센터) 모든 시간 가능 -> 출하지가 센터가 아니기때문에 시간관리 못함!
    		/* if (outOrgCode == "") {
    			alert("출하센터를 선택해주세요.");
    			$("#out_org_code").focus();
    			return false;
    		} */
        	var params = {
        		"parent_js_name" : "fnSetPlanTi",
   				"s_receive_plan_dt" : planDt,
   				"s_out_org_code" : outOrgCode,
   				"s_machine_out_doc_seq" : "${outDoc.machine_out_doc_seq}", // 같은 출하의뢰서면 취소했다가 다시 설정할 수 있도록함
   				<c:if test="${outDoc.machine_out_status_cd < '1'}">
   				"s_doc_mem_yn" : "${outDoc.doc_mem_no}" == "${SecureUser.mem_no}" && ${page.add.ACNT_MNG_YN ne 'Y'} ? "Y" : "N"
   				</c:if>
   			}

   			var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1000, height=480, left=0, top=0";
   			$M.goNextPage('/sale/sale0101p16', $M.toGetParam(params), {popupStatus: poppupOption});
    	}

    	// 서류저장
    	function goSaveSubmit() {

    		<c:if test="${SecureUser.mem_no ne doc_mem_no}">
				alert("작성자만 서류를 저장할 수 있습니다.");
				return false;
			</c:if>

    		var machineDocNo = $M.getValue("machine_doc_no");

    		var param = {};
    		var codeArr = [];
    		var fileSeqArr = [];
    		// param["mch_sale_doc_file_cd"] = code;

    		var array = codeMapDocFileArray.filter(function(value) {
    		    return value.code_v1 == "출고";
    		});
    		for (var i = 0; i < array.length; ++i) {
    			var code = array[i].code_value;
    			var fileSeq = $M.getValue("file_seq_"+code);
    			if (fileSeq != "") {
    				codeArr.push(code);
    				fileSeqArr.push(fileSeq);
    			} else {
    				codeArr.push(code);
    				fileSeqArr.push("0");
    			}
    		}

    		if (fileSeqArr.length == 0) {
    			alert("저장할 파일이 없습니다.");
    			return false;
    		}

    		param["mch_sale_doc_file_cd_str"] = $M.getArrStr(codeArr);
    		param["file_seq_str"] = $M.getArrStr(fileSeqArr);

    		// 담당자가 올리는 기능 삭제 -> 영업관리가 올리는걸로 변경
    		/* if ($M.getValue("file_seq_10") != "" && $M.getValue("file_seq_10") != "0") {
    			if($M.validation(document.main_form, {field:["handover_mem_name", "handover_dt"]}) == false) {
    				return false;
    			}
    			param["machine_seq"] = $M.getValue("machine_seq");
    			param["handover_mem_no"] = $M.getValue("handover_mem_no");
    			param["handover_dt"] = $M.getValue("handover_dt");
    			param["handover_remark"] = $M.getValue("handover_remark");
    		}

    		if ($M.getValue("handover_mem_no") != "" && ($M.getValue("file_seq_10") == "" || $M.getValue("file_seq_10") == "0")) {
    			alert("인도점검만 등록할 수 없습니다. DI리포트 함께 첨부해주세요.");
    			return false;
    		} */

    		$M.goNextPageAjaxSave("/sale/sale0101p01/"+machineDocNo+"/submit", $M.toGetParam(param), {method : 'POST'},
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
    			type : "출고",
    		};
    		var codeArr = [];
    		var ypnArr = [];

    		var array = codeMapDocFileArray.filter(function(value) {
    		    return value.code_v1 == "출고";
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

    		// QA 12199
    		if ($M.getValue("file_seq_10") != "" && $M.getValue("file_seq_10") != "0") {
    			if($M.validation(document.main_form, {field:["handover_mem_name", "handover_dt"]}) == false) {
    				return false;
    			}
    			param["machine_seq"] = $M.getValue("machine_seq");
    			param["handover_mem_no"] = $M.getValue("handover_mem_no");
    			param["handover_dt"] = $M.getValue("handover_dt");
    			param["handover_remark"] = $M.getValue("handover_remark");
    		}

    		$M.goNextPageAjaxSave("/sale/sale0101p01/"+machineDocNo+"/submitConfirm", $M.toGetParam(param), {method : 'POST'},
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
    		var param = {
    			upload_type : 'MC',
    			file_type : 'both',
    			file_ext_type : 'pdf#img',
    			max_size : 5000
    		}
    		submitType = type+"";
    		openFileUploadPanel('fnSetFile', $M.toGetParam(param));
    	}

    	// 파일세팅
    	function fnSetFile(file) {
    		var str = '';
    		str += '<div class="table-attfile-item submit_' + submitType + '">';
    		if (file.file_ext == "pdf") {
    			str += '<a href="javascript:fileDownload(' + file.file_seq + ');">' + file.file_name + '</a>&nbsp;';
    		} else {
    			str += '<a href="javascript:fnLayerImage(' + file.file_seq + ');">' + file.file_name + '</a>&nbsp;';
    		}
    		str += '<input type="hidden" name="file_seq_'+submitType+'" value="' + file.file_seq + '"/>';
    		str += '<button type="button" class="btn-default check-dis" onclick="javascript:fnRemoveFile(\'' +  submitType + '\')"><i class="material-iconsclose font-18 text-default"></i></button>';
    		str += '</div>';
    		$('.submit_'+submitType+'_div').append(str);
    		$("#btn_submit_"+submitType).remove();
    	}

    	// 파일삭제
    	function fnRemoveFile(type) {
    		console.log(type);
    		var result = confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.");
    		if (result) {
    			$(".submit_" + type).remove();
    			var str = '<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goFileUploadPopup(\''+type+'\')" id="btn_submit_'+type+'">파일찾기</button>'
    			$('.submit_'+type+'_div').append(str);
    		} else {
    			return false;
    		}
    	}

        function fnLayerImage(fileSeq) {
//         	$M.goNextPageLayerImage("${inputParam.ctrl_host}" + "/file/svc/" + fileSeq);
    		var params = {
    				file_seq : fileSeq
    		};

    		var popupOption = "";
    		$M.goNextPage('/comp/comp0709', $M.toGetParam(params), {popupStatus : popupOption});
        }

        // 인감주소 수정
        function goModifySeal() {
        	var param = {
        		machine_out_doc_seq : "${outDoc.machine_out_doc_seq}",
        		seal_post_no : $M.getValue("seal_post_no"),
        		seal_addr1 : $M.getValue("seal_addr1"),
        		seal_addr2 : $M.getValue("seal_addr2")
        	}
        	$M.goNextPageAjaxModify("/sale/sale0101p03/updateOutDoc", $M.toGetParam(param), {method: 'post'},
                    function (result) {
                         if (result.success) {

                         }
                    }
               );
        }

        $(document).ready(function () {
            if("Y" == "${process_stop_yn}") {
                alert("출하의뢰서 미작성 상태이기 때문에\n계약담당자만 처리 가능합니다");
                window.close();
            }
            createAUIGrid();
            fnInitPage();
        });

        function goPartoutPage() {
        	var params = {
				"machine_out_doc_seq" : "${outDoc.machine_out_doc_seq}",
				"parent_js_name" : "fnCalcNoOutAfterPartOut"
			}

			var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1000, height=480, left=0, top=0";
			$M.goNextPage('/part/part0203p04', $M.toGetParam(params), {popupStatus: poppupOption});
        }

    	// 부품출고처리 후 콜백
    	function fnCalcNoOutAfterPartOut(data) {
    		var row = data;
    		if (row == null || row == undefined) {
    			return false;
    		}
    		var rowIndexs = AUIGrid.getRowIndexesByValue(auiGrid_part, "part_seq_no", row.out_seq_no);
    		if (rowIndexs != null) {
    			rowIndexs = rowIndexs[0];
    			var rows = AUIGrid.getGridData(auiGrid_part);
    			var temp = rows[rowIndexs];
    			var no_out_qty = $M.toNum(temp.part_no_out_qty);
    			if (row.no_out_operation == "-") { // 출고처리
    				if (no_out_qty - row.qty > -1) {
    					temp["part_no_out_qty"] = no_out_qty - row.qty;
    				} else {
    					console.error("미출고수량이 마이너스일 수 없음");
    				}
    			} else if (row.no_out_operation == "+") { //출고 취소
    				if (no_out_qty + row.qty <= temp.part_qty) {
    					temp["part_no_out_qty"] = no_out_qty + row.qty;
    				} else {
    					console.error("미출고수량이 출고수량을 초과함");
    				}
    			}
    			AUIGrid.updateRowsById(auiGrid_part, temp);
    			AUIGrid.resetUpdatedItems(auiGrid_part);

    			var overShort = 0;
    			for (var i = 0; i < rows.length; ++i) {
    				if ($M.toNum(rows[i].part_no_out_qty) != 0) {
    					overShort+=1;
    				}
    			}
    			$("#no_out_qty").html(overShort);
    		} else {
    			alert("미출고 행을 찾을 수 없음");
    		}
    	}

        function fnInitPage() {

            $M.setValue("sum_amt", "${virtual.sum_amt}");
            $M.setValue("in_max_amt", "${virtual.in_max_amt}");

            fnSetYn();
            fnSetVisible();
            if ("${machineInfo.sar_yn_info}" == "Y") {
            	if ("${sarInfo}"=="") {
            		isNeedSar = true;
            	} else {
            		isNeedSar = false;
            	}
            } else {
            	isNeedSar = false;
            }
            setTimeout(function () {
            	if (statusCd == "" || statusCd == "0") {
            		goSearchPrivacyAgree();
            	}
            }, 500);
            // hp_no 옆에 버튼 disabled 제외
            $(".btn.btn-icon.btn-primary-gra").attr("disabled", false);

            if ("${outDoc.mch_type_cad}" == "A") {
            	$M.setValue("cap_yn", "N");
	            $("#cap_yn_y").prop("disabled", true);
	            $("#cap_yn_n").prop("disabled", true);
            }

            // 입금완료 후 1시간 이내 고객앱 배송지 확인(저장) 안했으면 도착지1 빨간색으로 표시 (관리확인 전)
            if (${outDoc.cust_confirm_yn eq 'N' and (empty outDoc.machine_out_status_cd or outDoc.machine_out_status_cd < 1)}) {
                $("#arrival1_post_no").css("color", "red");
                $("#arrival1_addr1").css("color", "red");
                $("#arrival1_addr2").css("color", "red");

                if (${empty outDoc.arrival1_post_no}) {
                    $("#arrival1_post_no").val("${outDoc.post_no}");
                    $("#arrival1_addr1").val("${outDoc.addr1}");
                    $("#arrival1_addr2").val("${outDoc.addr2}");
                }
            }
        }

        function goAddPartPopup() {
        	if (statusCd != "1") {
        		alert("관리확인 단계에서 가능합니다.");
        		return false;
        	}
    		parentFreeList = [];
    		parentPaidList = [];
    		var tempList = AUIGrid.exportToObject(auiGrid_part);
    		for (var i = 0; i < tempList.length; i++) {
    			var obj = new Object();
    			for (var prop in tempList[i]) {
    				obj[prop.substring(5,prop.length)] = tempList[i][prop];
    			}
    			if (obj['attach_yn'] != 'Y') {
    				if (obj['free_yn'] === 'Y') {
    					parentFreeList.push(obj);
    				} else {
    					parentPaidList.push(obj);
    				}
    			}
    		}
    		var param = {
    			cost_part_breg_no : $M.getValue("cost_part_breg_no"), // 사업자번호
    			machine_plant_seq : "${outDoc.machine_plant_seq}",
    			page_type : "OUT"
    		}
    		openFreeAndPaidMachinePart('fnSetFreeAndPaidMachinePart', $M.toGetParam(param));
    	}

        function fnSetFreeAndPaidMachinePart(list) {
        	var row = $.extend(true, [], list);
        	for (var i = 0; i < row.parentPaidList.length; ++i) {
        		row.parentPaidList[i]['paid_part_name_change_yn'] = row.parentPaidList[i].paid_part_name_change_yn;
 	        	row.parentPaidList[i]['paid_free_yn'] = "N";
 	        	row.parentPaidList[i]['paid_attach_yn'] = "N";
 	        	row.parentPaidList[i]['paid_default_qty'] = row.parentPaidList[i].paid_default_qty == null ? 0 : row.parentPaidList[i]['paid_default_qty'];
 	        	row.parentPaidList[i]['paid_add_qty'] = row.parentPaidList[i].paid_add_qty == null ? 0 : row.parentPaidList[i]['paid_add_qty'];
 	        	row.parentPaidList[i]['paid_no_out_qty'] = row.parentPaidList[i].paid_no_out_qty == null ? 0 : row.parentPaidList[i]['paid_no_out_qty'];
 	        	row.parentPaidList[i]['paid_use_yn'] = 'Y';
 	        	row.parentPaidList[i]['paid_add_doc_yn'] = 'N';
 	        	row.parentPaidList[i]['paid_doc_seq_no'] = row.parentPaidList[i].paid_doc_seq_no == null ? null : row.parentPaidList[i]['paid_doc_seq_no'];
 	        	row.parentPaidList[i]['paid_qty'] = row.parentPaidList[i].paid_add_qty;
 	        }
 	        for (var i = 0; i <row.parentFreeList.length; ++i) {
 	        	row.parentFreeList[i]['free_part_name_change_yn'] = row.parentFreeList[i].free_part_name_change_yn;
 	        	row.parentFreeList[i]['free_free_yn'] = "Y";
 	        	row.parentFreeList[i]['free_attach_yn'] = "N";
 	        	row.parentFreeList[i]['free_default_qty'] = row.parentFreeList[i].free_default_qty == null ? 0 : row.parentFreeList[i]['free_default_qty'];
 	        	row.parentFreeList[i]['free_add_qty'] = row.parentFreeList[i].free_add_qty == null ? 0 : row.parentFreeList[i]['free_add_qty'];
 	        	row.parentFreeList[i]['free_no_out_qty'] = row.parentFreeList[i].free_no_out_qty == null ? 0 : row.parentFreeList[i]['free_no_out_qty'];
 	        	row.parentFreeList[i]['free_use_yn'] = 'Y';
 	        	row.parentFreeList[i]['free_add_doc_yn'] = 'N';
 	        	row.parentFreeList[i]['free_doc_seq_no'] = row.parentFreeList[i].free_doc_seq_no == null ? null : row.parentFreeList[i]['free_doc_seq_no'];
 	        	row.parentFreeList[i]['free_qty'] = $M.toNum(row.parentFreeList[i].free_add_qty)+$M.toNum(row.parentFreeList[i].free_default_qty);
 	        }
        	var tempList = AUIGrid.exportToObject(auiGrid_part);
        	var partList = [];
        	var concatPartList = [];
        	for (var i = 0; i < tempList.length; ++i) {
        		if (tempList[i].part_attach_yn === "Y") {
        			partList.push(tempList[i]);
        		}
        	}
        	concatPartList = row.parentFreeList.concat(row.parentPaidList);
        	for (var i = 0; i < concatPartList.length; i++) {
    			var obj = new Object();
    			for (var prop in concatPartList[i]) {
    				var tempProp = "part"+prop.substring(4,prop.length);
    				obj[tempProp] = concatPartList[i][prop];
    			}
    			partList.push(obj);
        	}
        	Array.isArray(partList) == true ? partList.sort($M.sortMulti("-part_no_out_qty")) : "";
        	AUIGrid.setGridData(auiGrid_part, partList);

			var prmArr = [];
			var pArr = AUIGrid.getGridData(auiGrid_part);
			for (var i = 0; i <  pArr.length; ++i) {
				if (pArr[i].part_cmd == "D") {
					prmArr.push(AUIGrid.rowIdToIndex(auiGrid_part, pArr[i]._$uid));
				}
			}
			AUIGrid.removeRow(auiGrid_part, prmArr);

        	fnCalcNoOutQty();
        }

        // 개인정보동의 팝업
        function goSearchPrivacyAgree() {
            var param = {
                cust_no: "${custInfo.cust_no}"
            }
            $M.goNextPageAjax("/comp/comp0306/search", $M.toGetParam(param), {method: 'get', loader: false},
                function (result) {
                    if (result.success) {
                        var custInfo = result.custInfo;
                        if (custInfo.personal_yn != "Y") {
                            if (confirm("개인정보 동의사항을 확인하세요") == true) {
                                openPrivacyAgreePanel('fnSetPrivacy', $M.toGetParam(param));
                            }
                        }
                    }
                }
            );
        }

        // 개인정보 동의 세팅
        function fnSetPrivacy(data) {
            //alert(JSON.stringify(data));
        }

        function fnSetVisible() {
            if ("${outDoc.hp_no}" != "") {
                $("#hp_no").prop("readonly", true);
            }
            switch (statusCd) {
            	case "" :
            		$(".process2 :input, .process3 :input, .process1 :input").attr("disabled", true);
            		$("#receive_user_remark").prop("disabled", false);
            		break;
            	case "0" :
            		$(".process2 :input, .process3 :input, .process1 :input").attr("disabled", true);
            		$("#receive_user_remark").prop("disabled", false);
            		break;
            	case "1" :
            		$(".process2 :input, .process3 :input").attr("disabled", true);
            		$("#receive_mng_remark").prop("disabled", false);
            		$("#di_coupon_yn_check").prop("disabled", false);
            		break;
            	case "2" :
            		$(".process01 :input").attr("disabled", true);
            		$("#out_remark").attr("disabled", false);
            		$("#di_coupon_yn_check").prop("disabled", true);
            		var tempArrival = "${outDoc.arrival1_addr1}"+" "+"${outDoc.arrival1_addr2}";
            		$M.getValue("arrival_area_name") == "" ? $M.setValue("arrival_area_name", tempArrival) : "";
            		"${custInfo.cust_no}" === "20130603145119670" ? $M.setValue("sale_type_sr", "R") : "";
            		<c:if test="${'2' eq outDoc.machine_out_status_cd and empty outDoc.fix_out_dt}">
            			$(".fixOutDiv :input").attr("disabled", false);

            			// 영업일+3일까지 선택가능
            			var plantDt = "${planDtInWorkDays}";
            			$("#fix_out_dt").datepicker({
        					minDate : $M.toDate("${outDoc.receive_plan_dt}"),
        					maxDate : $M.toDate(plantDt),
        				});
            			$("#fix_out_dt").attr("readonly", true);
            		</c:if>
            		<c:if test="${'2' eq outDoc.machine_out_status_cd and not empty outDoc.fix_out_dt and 'N' eq outDoc.fix_out_confirm_yn}">
            			$("#btnFixDtConfirm").attr("disabled", false);
            		</c:if>
            	case "3" :
            	case "4" :
            		$(".p2s").addClass("rs");
            		$(".p2b").addClass("rb");
            }
            // 출하완료 전까지 캡 수정 가능
            if (statusCd != "3") {
            	$("input[name*='cap_yn']").attr("disabled", false);
            }
            if (statusCd == "3") {
            	// test용 주석
            	$(".process01 :input, .process2 :input").attr("disabled", true);
            	// 출하완료 후 가능한 것 : 출하관련서류발송, 계산서 가발행 및 취소
            	// 출하의뢰서 인쇄, 출하사항변경, 서비스쿠폰발행, 고객거래원장, 창닫기
            }
            if (statusCd != "1") {
            	$("#customerSave").css("display", "none");
            }
            if ("${modifySealYn}"=="Y") {
            	$("#btnModifySeal").css("display", "block");
            	$("#seal_addr_search").attr("disabled", false);
            	$("#btnModifySeal").attr("disabled", false);
            	$("#breg_no").attr("disabled", false);
            	$("#breg_seq").attr("disabled", false);
            	$("#breg_search_btn").attr("disabled", false);
        		$("#customerSave").css("display", "block");
        		$("#customerSave").attr("disabled", false);
            }
            <%--if ("${SecureUser.web_id}" != "it_manager") {--%>
            <%--	if ("${authority}" != "4091" && "${authority}" != "4092" && "${authority}" != "4095") {--%>
            // 메뉴내기능 누락되서 추가함 -> 부서권한으로 관리하겠다고 함, 출하의뢰서인쇄 버튼은 출하담당여부와 상관없이 다 보여져도 된다고 신정애 대리님한테 전달받음
            <%--if (${page.fnc.F00111_008 ne 'Y'}) {--%>
            <%--    $("#_goPrintCertificate").css("display", "none");--%>
            <%--    $("#_goPrintBundleDoc").css("display", "none");--%>
            <%--    $("#_goPrintShip").css("display", "none");--%>
            <%--}--%>
            <%--if (${page.add.OUT_MNG_YN eq 'Y'}) {--%>
            <%--    $("#_goPrintShip").css("display", "inline-block");--%>
            <%--}--%>
            // }

         // disabled되면 그리드 내용 복사 안되서 추가
            $(".aui-grid :input").prop("disabled", false);

         	// 스탁에서 등록했을 경우
         	if ("${outDoc.stock_machine_doc_no}" != "") {
         		$M.setValue("machine_send_cd", "3");
         	}

         	// 업무DB 버튼 추가  21-08-05 이강원
         	$("#work_db_btn").attr("disabled", false);
        }

        function fnSetYn() {
            if ("${machineInfo.cap_yn_info}" !== "Y") {
                $("#cap_yn_y").prop("disabled", true);
                $("#cap_yn_n").prop("disabled", true);
                $M.setValue("cap_yn", "N");
            } else {
                $M.setValue("cap_yn", "${outDoc.cap_yn}");
            }
            if ("${machineInfo.sar_yn_info}" !== "Y") {
                $M.setValue("sar_yn", "N");
            } else {
                $M.setValue("sar_yn", "${outDoc.sar_yn}");
            }
            if ("${machineInfo.center_di_yn_info}" !== "Y") {
                $("#center_di_yn_check").prop("disabled", true);
                $M.setValue("center_di_yn", "N");
            } else {
                $M.setValue("center_di_yn", "${outDoc.center_di_yn}");
            }
            if ("${outDoc.used_car_doc_yn}" == "Y") {
            	$M.setValue("used_car_doc_yn_check", "Y");
            }
            if ("${outDoc.used_move_doc_yn}" == "Y") {
            	$M.setValue("used_move_doc_yn_check", "Y");
            }
        }

        function fnClose() {
            window.close();
        }

        // 양도증명서 인쇄
        function goPrintCertificate() {
        	if ("${outDoc.seal_addr1}" == "") {
        		alert("인감주소 저장 후 다시 시도해주세요.");
        		return false;
        	}
        	openReportPanel('sale/sale0101p03_02.crf','machine_doc_no=' + $M.getValue("machine_doc_no"));
        }

        // 출하증명서 인쇄
        function goPrintOutCert() {
        	openReportPanel('sale/sale0101p03_04.crf','machine_doc_no=' + $M.getValue("machine_doc_no")+'&machine_plant_seq=' + "${outDoc.machine_plant_seq}");
        }

        // (Q&A 12185) 고객정보 출하스티커 추가 211020 김상덕
        function goPrint() {
        	var bodyNo = "${outDoc.body_no}";
        	if ("" != bodyNo) {
        		fnGoCustPrint({body_no : bodyNo});
        	} else {
	        	goMachineToOut("fnGoCustPrint", "Y");
        	}
        }

        function fnGoCustPrint(row) {

			var item = {
				"cust_name" : "${custInfo.cust_name}"
				, "hp_no" : "${outDoc.hp_no}"
				, "body_no" : row.body_no
				, "receive_plan_dt" : "${outDoc.receive_plan_dt}"
			};

			var data = [];
			data.push(item);

			var param = {
				"data" : data
			}

        	openReportPanel('sale/sale0101p03_05.crf', param);
        }

        // 출하증명서 발급이력
        function goDocPrintHistory() {
        	var params = {
   				"machine_doc_no" : $M.getValue("machine_doc_no"),
   			}
   			var poppupOption = "";
   			$M.goNextPage('/sale/sale0101p14', $M.toGetParam(params), {popupStatus: poppupOption});
        }

        function goPrintBundleDoc() {
        	var fileSeq = $M.toNum("${outDoc.file_seq}");
        	if (fileSeq == 0) {
        		alert("마케팅 > 장비관리 > 장비코드관리에서 해당 모델의 일괄서류파일을 첨부해주세요.");
        		return false;
        	} else {
        		var param = {
       				contentType : "application/pdf"
        		}
        		fileDownload(fileSeq, param, "Y");
        	}
        }

        // 출하의뢰서 인쇄
        function goPrintShip() {
        	if (statusCd == "") {
        		alert("저장 후 다시 시도해주세요.");
        		return false;
        	}
        	var param = {
        		machine_doc_no : $M.getValue("machine_doc_no")
        	}
        	// 프린트 출력여부 업데이트
        	$M.goNextPageAjax(this_page+"/reportPrint", $M.toGetParam(param), {method: 'post'},
                    function (result) {
		        		if (result.success) {
                            // openReportPanel('sale/sale0101p03_01.crf','machine_doc_no=' + $M.getValue("machine_doc_no"));

                            // (Q&A 15596) 3-2차 리포트 수정.
                            var paramPKStr = "machine_doc_no=" + $M.getValue("machine_doc_no");

                            // $("#셀렉트박스ID option:selected").val();

                            var paramCenterNameStr = "&print_center_org_name=" + $("#out_org_code option:selected").attr("org_name");
                            var paramEtcStr = "&etc_text=";

                            var BREAKER_PART_NAME = "BREAKER";

                            var etcArr = ["","","",""];
                            var NEW_LINE = "\n";

                            // 출하시 기타사항 START
                            //  CAP 여부
                            var etcCap = $M.getValue("cap_yn") == "Y" ? "CAP적용" : "CAP미적용";
                            etcArr[0] = etcCap;

                            var partGridData = AUIGrid.getGridData(auiGrid_part);
                            for (var i = 0; i < partGridData.length; i++) {
                                // 지급품중 YK520-01 (캐노피 절단) 체크
                                if("YK520-01" == partGridData[i].part_part_no) {
                                    etcArr[1] = "캐노피절단";
                                }
                                // breaker 포함 체크
                                if(partGridData[i].part_part_name.toUpperCase().includes(BREAKER_PART_NAME)) {
                                    etcArr[2] = "브레이커 지급";
                                }
                                if (etcArr[1] != "" && etcArr[2] != "") {
                                    break;
                                }
                            }

                            // 선택사항 체크
                            var optStr = $("#opt_code option:selected").text();
                            etcArr[3] = optStr != "" ? optStr + " 1EA" : "";

                            for (var i = 0; i < etcArr.length; i++) {
                                if (etcArr[i]) {
                                    paramEtcStr += NEW_LINE + etcArr[i];
                                }
                            }
                            // 출하시 기타사항 END

                            var preortParamStr = paramPKStr + paramCenterNameStr + paramEtcStr;
                            openReportPanel('sale/sale0101p03_01_v32.crf', preortParamStr);
                        }
                    }
               );
        }


        // 저장
        function goSave() {

        	goProcess('save');
        }

        // 관리확인요청
        function goConfirm() {
            if (statusCd != "" && statusCd != "0") {
                alert("마케팅작성중인 자료가 아닙니다.");
                return false;
            }
            if (isNeedSar == true) {
                alert("SA-R 계약정보를 등록해주세요.");
                return false;
            }
            // 공통필수와 관리확인요청 시 필수체크

            // 도착지정보, 인도예정일, 희망시간, 인수자, 연락처, 인감주소, 지입사명, 지입사연락처, 등록서류수령지, 사업자정보, 인감주소
            if($M.validation(document.main_form,
                {field:["receive_plan_dt", "receive_user_name", "receive_user_tel_no", "allo_name", "allo_tel_no"
                        , "paper_post_no", "breg_no", "breg_name", "breg_rep_name", "seal_post_no"
                        , "machine_send_cd"
                        , "receive_plan_ti"
                        , "seal_addr1", "seal_addr1"
                        , "arrival1_post_no", "arrival1_addr1"
                        , "breg_no"]}) == false) {
                return false;
            }

            var ti1 = $M.getValue("receive_plan_ti_1");
            var ti2 = $M.getValue("receive_plan_ti_2");

            console.log(ti1, ti2);

            // 스탁 출하의뢰서가 아닐경우 출하예상시간입력필수!
            if ("${outDoc.stock_machine_doc_no}" == "" && ti1+ti2 == "0000") {
                alert("출하예상시간을 설정하세요.");
                $("#receive_plan_ti_temp").focus();
                return false;
            };

            goProcess('requestConfirm');
        }

        // 출하처리요청
        function goRequestOut() {
            // 2023-05-31 황빛찬 (SR : 18386) YK렌탈장비 경우 유상부품대 체크 X
            if ($M.getValue("cust_no") != "20130603145119670") {
                // 2022-12-07 황빛찬 (SR : 14503) 유상부품대 연동 추가.
                var param = {
                    "machine_doc_no" : $M.getValue("machine_doc_no")
                }

                $M.goNextPageAjax("/sale/sale0101p03/partCostCheck", $M.toGetParam(param), {method : 'GET', async : false},
                    function(result) {
                        if(result.success) {
                            goRequestOutProc();
                        }
                    }
                );
            } else {
                goRequestOutProc();
            }
        }

        // 출하처리요청 처리
        function goRequestOutProc() {
            if ($M.getValue("center_di_yn_check") == "Y" && $M.getValue("di_coupon_yn_check") != "Y") {
                alert("센터DI마일리지적립여부를 확인하십시오.");
                $("#di_coupon_yn_check").focus();
                return;
            }
            var partList = AUIGrid.getGridData(auiGrid_part);
            var partNoList = [];
            for (var i = 0; i < partList.length; ++i) {
                if (partList[i].part_cmd != "D") {
                    partNoList.push(partList[i].part_part_no);
                }
            }

            // Q&A 16344 유상,무상 같은 부품있을경우 아래내용에 걸려 진행되지 않아서 제거함. 20220928 김상덕.
            // var valuesSoFar = [];
            // for (var i = 0; i < partNoList.length; ++i) {
            //      var value = partNoList[i];
            //      if (valuesSoFar.indexOf(value) !== -1) {
            //         alert("지급품목 중 "+partNoList[i]+" 는 중복된 부품입니다.\n관리자에게 문의하세요");
            //         return false;
            //      }
            //      valuesSoFar.push(value);
            // }
            // 출하처리요청할때 asis에서 mimoney(중고, 부가세 제외한 입금액) 페이지에서 확인하던거
            // tobe에서는 서버에서 함

            var ti1 = $M.getValue("receive_plan_ti_1");
            var ti2 = $M.getValue("receive_plan_ti_2");

            console.log(ti1, ti2);

            // 스탁 출하의뢰서가 아닐경우 출하예상시간입력필수!
            if ("${outDoc.stock_machine_doc_no}" == "" && ti1+ti2 == "0000") {
                alert("출하예상시간을 설정하세요.");
                $("#receive_plan_ti_temp").focus();
                return false;
            }

            goProcess('requestOut');
        }

        // 출하처리
        function goOut() {
        	if ($M.getValue("out_hold_yn") != "N") {
        		alert("출하 보류 중인 자료입니다.");
        		return false;
        	}
        	// 출하 공통필수 : 차대번호,엔진번호,출고일자, 운송사, 운송사연락처, 도착일시, 출고유형, 출고유형이 판매일경우 판매일시(tobe삭제)
        	// 운송사가 고객인수가 아닐경우 총운임
        	// 공통필수와 출하처리 시 필수체크
            // 2023-04-04 황빛찬 : 출고유형 erp,직원앱 둘다 삭제 (04.설계 > 기획 > 직원앱 - tablet_직원용_04 영업_v0.8pptx)
        	// if($M.validation(document.main_form, {field:["body_no", "out_dt", "sale_dt", "arrival_dt", "transport_cmp_cd", "transport_tel_no", "out_type_cd", "agency_transport_amt"]}) == false) {
			// 	return false;
			// }
			// 2024-06-03 황빛찬 : 판매일자 삭제
            // if($M.validation(document.main_form, {field:["body_no", "out_dt", "sale_dt", "arrival_dt", "transport_cmp_cd", "transport_tel_no", "agency_transport_amt"]}) == false) {
            //     return false;
            // }
            if($M.validation(document.main_form, {field:["body_no", "out_dt", "arrival_dt", "transport_cmp_cd", "transport_tel_no", "agency_transport_amt"]}) == false) {
                return false;
            }
        	if ("${outDoc.stock_machine_doc_no}" == "" && $M.getValue("transport_cmp_cd") != "96" && $M.toNum($M.getValue("transport_amt")) == "0") {
				alert("고객인수가 아닌 경우 총운임을 입력해주세요.");
				$("#transport_amt").focus();
				return false;
			}
        	var ti1 = $M.getValue("arrival_ti_1");
        	var ti2 = $M.getValue("arrival_ti_2");
        	if(ti1 == "00" && ti2 == "00") {
        		alert("출발시간을 선택하세요");
        		$("#arrival_ti_1").focus();
        		return false;
        	} else {
        		$M.setValue("arrival_ti", ti1+ti2);
        	}
        	if ($M.toDate($M.getValue("out_dt")) > $M.toDate($M.getValue("arrival_dt"))) {
        		alert("출발일자가 출고일자 이전입니다.");
        		$("#arrival_dt").focus();
        		return false;
        	}
          
        	goProcess('out');
        }

        function fnValidation() {
        	// $M.getValue("receive_confirm_yn_check") == "" ? $M.setValue("receive_confirm_yn", "N") : $M.setValue("receive_confirm_yn", "Y");
        	$M.getValue("di_coupon_yn_check") == "" ? $M.setValue("di_coupon_yn", "N") : $M.setValue("di_coupon_yn", "Y");
        	$M.getValue("center_di_yn_check") == "" ? $M.setValue("center_di_yn", "N") : $M.setValue("center_di_yn", "Y");
        	$M.getValue("used_car_doc_yn_check") == "" ? $M.setValue("used_car_doc_yn", "N") : $M.setValue("used_car_doc_yn", "Y");
        	$M.getValue("used_move_doc_yn_check") == "" ? $M.setValue("used_move_doc_yn", "N") : $M.setValue("used_move_doc_yn", "Y");

        	if($M.validation(document.main_form) == false) {
				return false;
			}
        	return true;
        }

        function goProcess(control) {
          if (control != "hold" && control != "holdCancel" && control != "outCancel") {
            if (fnValidation() == false) {
              return false;
            }
          }

          var msg = "";
          switch (control) {
            case "save" :
              msg = "저장하시겠습니까?";
              break;
            case "requestConfirm" :
              msg = "관리확인요청 하시겠습니까?\n요청 후 수정이 불가능합니다.";
              break;
            case "requestOut" :
              msg = "출하처리요청 하시겠습니까?\n요청 후 수정이 불가능합니다.";
              break;
            case "out" :
              msg = "출하 처리하시겠습니까?\n처리 후 수정이 불가능합니다.";
              break;
            case "hold" :
              msg = "출하 보류하시겠습니까?";
              break;
            case "holdCancel" :
              msg = "출하보류를 취소하시겠습니까?";
              break;
            case "outCancel" :
              msg = "출하업무를 취소하시겠습니까?\n처리 후 반드시 품의서를 확인하세요!";
              break;
            case "reject" :
              msg = "반려 처리하겠습니까?\n처리 후 복구가 불가능합니다.";
              break;
          }

          if (confirm(msg) == false) {
            return false;
          }

          // 필수
          var ti1 = $M.getValue("receive_plan_ti_1");
          var ti2 = $M.getValue("receive_plan_ti_2");
          $M.setValue("receive_plan_ti", ti1 + ti2);

          var frm = $M.toValueForm(document.main_form);
          var concatCols = [];
          var concatList = [];
          var gridIds = [auiGrid_part, auiGrid_option];
          for (var i = 0; i < gridIds.length; ++i) {
            concatList = concatList.concat(AUIGrid.exportToObject(gridIds[i]));
            concatCols = concatCols.concat(fnGetColumns(gridIds[i]));
          }
          var gridFrm = fnGridDataToForm(concatCols, concatList);

          $M.copyForm(gridFrm, frm);

          if (isRun == false) {
            isRun = true;
          } else {
            return false;
          }
          $M.goNextPageAjax(this_page + "/process/" + control, gridFrm, {method: 'post'},
            function (result) {
              isRun = false;
              if (result.success) {
                if (opener != null && opener.goSearch) {
                  opener.goSearch();
                }
                if (control == "outCancel") {
                  fnClose();
                } else if (control == "out") {
                  setTimeout(function () {
                    // [재호] 추가개발건 - 출하처리 시 고객 모두싸인 발송을 위한 데이터
                    // - 출하처리(무상) 에서 출하처리 로직이 이루어 짐으로 해당 팝업에서 모두싸인 발송
                    var moduSignData = getModuSignData("출하처리 후, 장비인수증 싸인이 전송됩니다." + "\\n" +"출하 처리 하시겠습니까?");
                    var param = {
                      machine_out_doc_seq: "${outDoc.machine_out_doc_seq}",
                      type: "MF", // MF : 장비와 무상부품, P : 유상, A : 추가출고
                      modu_sign_data: JSON.stringify(moduSignData),
                    }
                    var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1000, height=850, left=0, top=0";
                    $M.goNextPage('/sale/sale0101p08', $M.toGetParam(param), {popupStatus: poppupOption});
                  }, 100);
                } else {
                  location.reload();
                }
              }
            }
          );
        }

        // 장비인수증 모두싸인 데이터 return 함수 
        function getModuSignData(confirm_msg) {
          return {
            "is_trans" : true,
            "trans_ref_key" : $M.getValue('machine_out_doc_seq'),
            "trans_ref_type" : "MC",
            "trans_send_hp_no" : $M.getValue('transport_tel_no'),
            "cust_name" : $M.getValue("receive_user_name"),
            "hp_no" : $M.getValue("receive_user_tel_no"),
            "email" : $M.getValue(""),
            "breg_name" : $M.getValue("breg_name"),
            "confirm_msg" : confirm_msg,
            "machine_doc_no" : "${outDoc.machine_doc_no}",
            "machine_out_doc_seq" : "${outDoc.machine_out_doc_seq}",
          }
        }

        function fnReload() {
        	location.reload();
        }

        // 출하취소 == 계약취소?
        function goCancelShip() {
            /* if ("${outDoc.out_hold_yn}" != "Y") {
            	alert("출하보류된 자료가 아닙니다.");
            	return false;
            }
            for (var i = 0; i < 6; ++i) {
        		if ($M.toNum($M.getValue("plan_amt_"+i)) != $M.toNum($M.getValue("deposit_amt_"+i))) {
        			alert("입금액이 있습니다.");
        			$("#deposit_amt_"+i).focus();
        			return false;
        		}
        	} */
            //alert("계약취소");
            goProcess('outCancel');
        }

        // 출하사항변경
        function goChangeOutInfo() {
        	if (statusCd != "3") {
        		alert("출하완료된 자료가 아닙니다.");
        		return false;
        	}
        	if ("${outDoc.machine_out_doc_seq}" == "") {
        		alert("출하 완료 후 진행하세요.");
        		return false;
        	}
        	//test="${ (userSession.roleCd < '4020' and userSession.roleCd >= '4000') or userSession.webId == '160302' }"
        	var param = {
            	machine_out_doc_seq : $M.getValue("machine_out_doc_seq")
            }
            var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=600, height=360, left=0, top=0";
            $M.goNextPage('/sale/sale0101p07', $M.toGetParam(param), {popupStatus : poppupOption});
        }

        function goSarInfo() {
        	var param = {
        		machine_doc_no: $M.getValue("machine_doc_no"),
                cust_no: $M.getValue("cust_no"),
                cust_name: $M.getValue("cust_name"),
                hp_no: $M.getValue("hp_no"),
                email: $M.getValue("email"),
                modusign_id: $M.getValue("doc_modusign_id")
            }
            var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=800, height=250, left=0, top=0";
            $M.goNextPage('/sale/sale0101p10', $M.toGetParam(param), {popupStatus : poppupOption});
        }

        function goDocumentPopup() {
        	if ($M.getValue("machine_out_doc_seq") == "") {
        		alert("출하의뢰서를 먼저 저장하세요.");
        		return false;
        	}
        	var param = {
        		machine_out_doc_seq : $M.getValue("machine_out_doc_seq")
        	}
            var poppupOption = "";
            $M.goNextPage('/sale/sale0101p04', $M.toGetParam(param), {popupStatus : poppupOption});
        }

        function goBillCheckPopup() {
        	if ("${inoutList}" != "" && "${inoutList}" != "[]") {
        		alert("장비전표에서 처리하세요.");
        		goInoutDetail('${inoutList[0].inout_doc_no }', 'M');
        		return false;
        	}
        	if(confirm("가발행 후, 화면갱신을 위해 페이지를 다시 불러오면서\n입력중인 정보가 사라집니다.\n가발행 부서는 마케팅이며 출하완료 시,\n출하처리 부서로 변경처리됩니다.\n\n발행 후 결과를 반드시 확인하십시오.") == false) {
        		return false;
        	}
            var param = {
            	machine_out_doc_seq : "${outDoc.machine_out_doc_seq}",
            	fake_yn : "Y"
            }
            var poppupOption = "scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=375, height=340, left=0, top=0";
            $M.goNextPage('/sale/sale0101p05', $M.toGetParam(param), {popupStatus : poppupOption});
        }

        function goTaxbillCancel(taxbillNo) {
        	if ("${inoutList}" != "" && "${inoutList}" != "[]") {
        		alert("장비전표에서 처리하세요.");
        		goInoutDetail('${inoutList[0].inout_doc_no }', 'M');
        		return false;
        	}
        	var msg = "세금계산서를 취소하시겠습니까?";
        	var param = {
        		taxbill_no : taxbillNo
        	};
        	$M.goNextPageAjaxMsg(msg, "/sale/sale0101p05/delete", $M.toGetParam(param), {method: 'post'},
                    function (result) {
                         if (result.success) {
                        	 location.reload();
                         }
                    }
               );
        }
        
        function goTaxbillReportOpen(taxbill_no) {
          openReportPanel('acnt/acnt0301p01_01.crf', 'fake_yn=Y&taxbill_no='+taxbill_no);
        }

        function fnCalcNoOutQty() {
            var partLength = 0;
            var part = AUIGrid.getGridData(auiGrid_part);
            var noOutQty = 0;
            for (var i = 0; i < part.length; ++i) {
            	if ($M.toNum(part[i].part_no_out_qty) != 0) {
            		noOutQty+=1;
            	}
            	if (part[i].part_cmd != "D") {
            		partLength+=1;
            	}
            }
            $("#part_total_cnt").html(partLength);
            $("#no_out_qty").html(noOutQty);
        }

        //그리드생성
        function createAUIGrid() {
            //그리드 생성 _ 지급품목
            var gridPros_part = {
                /* rowIdField: "part_no", */
                rowIdField : "_$uid",
                headerHeight : 20,
    			rowHeight : 11,
    			footerHeight : 20,
                fillColumnSizeMode : false,
                //editable: statusCd == "2" ? true : false,
                rowStyleFunction : function(rowIndex, item) {
            		if ($M.toNum(item.part_no_out_qty) !== 0 && statusCd >= "2") {
						return "aui-color-red";
            		}
            	}
            };
            var visibles = false;
            var columnLayout_part = [
            	{
            		dataField : "_$uid",
            		visible : visibles
            	},
            	{
            		dataField : "part_seq_no",
            		visible : visibles
            	},
                {
                    headerText: "부품번호",
                    dataField: "part_part_no",
                    width: "30%",
                    style: "aui-center",
                    editable : false
                },
                {
                    headerText: "부품명",
                    dataField: "part_part_name",
                    /* width : "50%", */
                    style: "aui-left",
                    editable : false
                },
                {
                    headerText: "수량",
                    dataField: "part_qty",
                    width: "10%",
                    style: "aui-center",
                    editable : false
                },
                {
                    headerText: "미출고",
                    dataField: "part_no_out_qty",
                    dataType: "numeric",
                    width: "10%",
                    style: "aui-center",
                    /* styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
                        if (statusCd == "2" && $M.toNum(item.part_no_out_qty) == 0) {
                            return "aui-editable";
                        } else {
                            return "";
                        }
                    }, */
                    //editable: statusCd == "2" ? true : false,
                    editable: false,
                    editRenderer: {
                        type: "InputEditRenderer",
                        onlyNumeric: true,
                        allowPoint: false,
                        validator: function (ov, nv, item, dataField) {
                            var newValue = parseInt(nv);
                            var oldValue = parseInt(ov);
                            var qty = parseInt(item.part_qty);
                            var msg = "";
                            var isValid = true;
                            if (newValue < 0) {
                            	isValid = false;
                            	msg = "0보다 작을 수 없습니다.";
                            } else {
                            	if (newValue > qty) {
                                    isValid = false;
                                    msg = "지급품 수량보다 클 수 없습니다.";
                                } else {
                                    isValid = true;
                                }
                            }
                            return {"validate": isValid, "message": msg};
                        }
                    }
                },
                {
                    dataField: "part_attach_yn",
                    visible: visibles
                },
                {
                    dataField: "part_add_doc_yn",
                    visible: visibles
                },
                {
                    dataField: "part_machine_doc_no",
                    visible: visibles
                },
                {
                    dataField: "part_doc_seq_no",
                    visible: visibles
                },
                {
                    dataField: "part_default_qty",
                    visible: visibles
                },
                {
                    dataField: "part_add_qty",
                    visible: visibles
                },
                {
                    dataField: "part_free_yn",
                    visible: visibles
                },
                {
                    dataField: "part_unit_price",
                    visible: visibles
                },
                {
                    dataField: "part_total_amt",
                    visible: visibles
                },
                {
                    dataField: "part_use_yn",
                    visible: visibles
                },
                {
                	dataField: "part_cmd",
                	visible: visibles
                },
                {
                	dataField : "part_part_name_change_yn",
                	visible : visibles
                }
            ];
            auiGrid_part = AUIGrid.create("#auiGrid_part", columnLayout_part, gridPros_part);
            AUIGrid.setGridData(auiGrid_part, ${partList});
            AUIGrid.bind(auiGrid_part, "cellEditEnd", function (event) {
            	if (event.dataField == "part_no_out_qty") {
            		fnCalcNoOutQty();
                }
            });
            fnCalcNoOutQty();
            $("#auiGrid_part").resize();
            var optCodeDom = $("#opt_code");
            optCodeDom.html("");
            var optList = ${optList};
            if (optList.length > 0) {
                optCodeDom.css("display", "inline-block");
                var selectedOptCode = optList[0].option_opt_code;
                optCodeDom.append("<option value='" + selectedOptCode + "'>" + optList[0].option_kor_name + "</option>");
                $M.setValue("opt_code", selectedOptCode);
            }

            //그리드 생성 _ 옵션품목
            var gridPros_option = {
                rowIdField: "part_no",
                fillColumnSizeMode : false,
                headerHeight : 20,
    			rowHeight : 11,
    			footerHeight : 20,
                editable: statusCd == "2" ? true : false,
                rowStyleFunction : function(rowIndex, item) {
            		if ($M.toNum(item.option_no_out_qty) !== 0) {
						return "aui-color-red";
            		}
            	}
            };
            var columnLayout_option = [
                {
                    dataField: "option_machine_plant_seq",
                    visible: false
                },
                {
                    dataField: "option_machine_doc_no",
                    visible: false
                },
                {
                    dataField: "option_opt_code",
                    visible: false
                },
                {
                    dataField: "option_seq_no",
                    visible: false
                },
                {
                    dataField: "option_cmd",
                    visible: false
                },
                {
                    headerText: "부품번호",
                    dataField: "option_part_no",
                    width: "30%",
                    style: "aui-center",
                    editable : false
                },
                {
                    headerText: "부품명",
                    dataField: "option_part_name",
                    style: "aui-left",
                    editable : false
                },
                {
                    headerText: "수량",
                    dataField: "option_qty",
                    width: "10%",
                    style: "aui-center",
                    editable : false
                },
                {
                    headerText: "미출고",
                    dataField: "option_no_out_qty",
                    visible : false,
                    dataType: "numeric",
                    width: "10%",
                    style: "aui-center",
                    /* styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
                        if (statusCd == "2" && $M.toNum(item.option_no_out_qty) == 0) {
                            return "aui-editable";
                        } else {
                            return "";
                        }
                    }, */
                    editable: statusCd == "2" ? true : false,
                    editRenderer: {
                        type: "InputEditRenderer",
                        onlyNumeric: true,
                        allowPoint: false,
                        validator: function (ov, nv, item, dataField) {
                            var newValue = parseInt(nv);
                            var oldValue = parseInt(ov);
                            var qty = parseInt(item.option_qty);
                            var msg = "";
                            var isValid = true;
                            if (newValue < 0) {
                            	isValid = false;
                            	msg = "0보다 작을 수 없습니다.";
                            } else {
                            	if (newValue > qty) {
                                    isValid = false;
                                    msg = "지급품 수량보다 클 수 없습니다.";
                                } else {
                                    isValid = true;
                                }
                            }
                            return {"validate": isValid, "message": msg};
                        }
                    }
                }
            ];
            auiGrid_option = AUIGrid.create("#auiGrid_option", columnLayout_option, gridPros_option);
            AUIGrid.setGridData(auiGrid_option, ${optList});
            $("#auiGrid_option").resize();
        }

        function goOutNoQtyPopup(t) {
        	var type = t;
        	var isNoOut = false
        	var partList = AUIGrid.getGridData(auiGrid_part);
        	for (var i = 0; i < partList.length; ++i) {
        		if ($M.toNum(partList[i].part_no_out_qty) != 0) {
        			isNoOut = true;
        			break;
        		}
        	}
        	if (isNoOut == false) {
        		var optList = AUIGrid.getGridData(auiGrid_option);
        		for (var i = 0; i < optList.length; ++i) {
        			if ($M.toNum(optList[i].option_no_out_qty) != 0) {
        				isNoOut = true;
        				break;
        			}
        		}
        	}

        	if (statusCd != "3") {
        		alert("출하완료된 자료가 아닙니다.");
        		return false;
        	}
        	if (isNoOut == false) {
        		alert("미출고 수량이 없습니다.");
        		return false;
        	}
        	goInoutIssue(type);
        }

        function fnSetSealAddr(row) {
            var param = {
                seal_post_no: row.zipNo,
                seal_addr1: row.roadAddr,
                seal_addr2: row.addrDetail
            };
            $M.setValue(param);
        }

        function fnSetArrival1Addr(row) {
            var param = {
                arrival1_post_no: row.zipNo,
                arrival1_addr1: row.roadAddr,
                arrival1_addr2: row.addrDetail
            };
            $M.setValue(param);
        }

        function fnSetArrival2Addr(row) {
            var param = {
                arrival2_post_no: row.zipNo,
                arrival2_addr1: row.roadAddr,
                arrival2_addr2: row.addrDetail
            };
            $M.setValue(param);
        }

        function fnSetPaperAddr(row) {
            var param = {
                paper_post_no: row.zipNo,
                paper_addr1: row.roadAddr,
                paper_addr2: row.addrDetail
            };
            $M.setValue(param);
        }

        // 문자발송
        function fnSendSms() {
            var param = {
                'name': $M.getValue('cust_name'),
                'hp_no': $M.getValue('hp_no')
            }
            openSendSmsPanel($M.toGetParam(param));
        }

        // 사업자조회
        function goSearchBregInfo() {
            var param = {
                's_cust_no': $M.getValue("cust_no")
            };
            openSearchBregSpecPanel('fnSetBregInfo', $M.toGetParam(param));
        }

        // 사업자정보조회 결과
        function fnSetBregInfo(row) {
            var param = {
            	breg_seq : row.breg_seq,
                breg_no: row.breg_no,
                breg_rep_name: row.breg_rep_name,
                breg_name: row.breg_name
            }
            $M.setValue(param);
        }

        function goSaveCustomerBreg() {
        	if ($M.getValue("breg_no") == "") {
        		alert("사업자 정보를 입력해주세요");
        		$("#breg_name").focus();
        		return false;
        	}
        	var param = {
        		cust_no : $M.getValue("cust_no"),
        		breg_seq : $M.getValue("breg_seq"),
        		breg_no : $M.getValue("breg_no"),
        		breg_name : $M.getValue("breg_name"),
        		breg_rep_name : $M.getValue("breg_rep_name"),
        		machine_out_doc_seq : $M.getValue("machine_out_doc_seq")
        	}

        	var msg = "고객 정보를 반영 하시겠습니까?";
        	$M.goNextPageAjaxMsg(msg, this_page+"/updateCustBreg", $M.toGetParam(param), {method: 'post'},
                    function (result) {
                         if (result.success) {

                         }
                    }
               );
        }

        // 출하장비 선택
        function goMachineToOut(jsName, custPrintYn) {
        	var param = {
        		machine_plant_seq : "${outDoc.machine_plant_seq}",
				out_org_code : $M.getValue("out_org_code"),
				parent_js_name : jsName,
				machine_doc_no : "${inputParam.machine_doc_no}",
				cust_print_yn : custPrintYn
			}
        	// 스탁품의일 경우 (스탁출하할때 장비는 대리점코드로 나감!)
        	if ("${outDoc.stock_machine_doc_no}" != "") {
        		param["stock_machine_doc_no"] = "${outDoc.stock_machine_doc_no}";
        	}
			var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=900, height=400, left=0, top=0";
			$M.goNextPage('/sale/sale0101p06', $M.toGetParam(param), {popupStatus : poppupOption});
        }

        function fnSetMachineToOut(row) {
        	var param = {
        		body_no : row.body_no,
        		engine_no_1 : row.engine_no_1,
        		engine_no_2 : row.engine_no_2,
        		engine_model_1 : row.engine_model_1,
        		engine_model_2 : row.engine_model_2,
        		opt_model_1 : row.opt_model_1,
        		opt_model_2 : row.opt_model_2,
        		opt_no_1 : row.opt_no_1,
        		opt_no_2 : row.opt_no_2,
        		machine_seq : row.machine_seq
        	}
        	$M.setValue(param);

        	// 계약출하순번관리에 MACHINE_SEQ, MACHINE_DOC_NO 업데이트. (03-26 황빛찬)
        	var val = {
        		machine_seq : row.machine_seq,
        		machine_doc_no : $M.getValue("machine_doc_no")
        	}

        	$M.goNextPageAjax(this_page + "/saleTurnModify", $M.toGetParam(val), {method: 'post'},
                 function (result) {
                      if (result.success) {

                      }
                 }
            );
        }

        // 2023-04-04 황빛찬 : 렌탈대리점 erp,직원앱 둘다 삭제 (04.설계 > 기획 > 직원앱 - tablet_직원용_04 영업_v0.8pptx)
        // function fnSetRentalOrgCd(row) {
        // 	$M.setValue("rental_org_name", row.org_name);
        // 	$M.setValue("rental_org_code", row.org_code);
        // }

        function goOutReject() {
        	if (statusCd == "" || statusCd == "0") {
        		alert("반려할 수 없는 자료입니다.");
        		return false;
        	}
        	goProcess('reject');
        }

        // 출하보류
        function goHold() {
        	if ($M.getValue("out_hold_yn") != "N") {
        		alert("이미 출하 보류 중인 자료입니다.");
        		return false;
        	}
        	goProcess('hold');
        }

        // 보류취소
        function goHoldCancel() {
        	if ($M.getValue("out_hold_yn") != "Y") {
        		alert("출하 보류 중인 자료가 아닙니다.");
        		return false;
        	}
        	goProcess('holdCancel');
        }

        // 출하업무취소
        function goOutCancel() {
        	goProcess('outCancel');
        }


        // 무상부품+장비출하 후 유상부품 전표처리할게 있는지 조회 후
        // 있으면 다시 sale0101p08 type P로 팝업호출
        // 이 function은 무상전표 처리 완료 후 에만 호출한다.
        function goCallbackByMf() {
        	var param = {
   				machine_out_doc_seq : "${outDoc.machine_out_doc_seq}"
            }
        	$M.goNextPageAjax("/sale/sale0101p08/checkCostOutPart", $M.toGetParam(param), {method: 'get', loader : false},
                    function (result) {
                         if (result.success) {
                        	if (result.type == "P") {
                        		alert("이어서 유상부품 전표를 처리하세요.");
                        		var param = {
                   					machine_out_doc_seq : "${outDoc.machine_out_doc_seq}",
                   					type : "P" // MF : 장비와 무상부품, P : 유상, A : 추가출고
                   	            }
                   	            var poppupOption = "scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1000, height=850, left=0, top=0";
                   	            $M.goNextPage('/sale/sale0101p08', $M.toGetParam(param), {popupStatus : poppupOption});
                        	} else {
                        		alert("처리가 완료되었습니다.");
                        		   setTimeout(function () {
                         		   window.location.reload();
                                }, 100);
                        	}
                         }
                    }
               );
        }

        function goInoutDetail(inoutDocNo, type) {
        	var param = {
        		inout_doc_no : inoutDocNo
        	}
        	 if (type == "M") {
        		 var poppupOption = "scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=700, height=550, left=0, top=0";
                 $M.goNextPage('/sale/sale0101p12', $M.toGetParam(param), {popupStatus : poppupOption});
        	 } else {
        		 var poppupOption = "scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1000, height=850, left=0, top=0";
                 $M.goNextPage('/sale/sale0101p08', $M.toGetParam(param), {popupStatus : poppupOption});
        	 }
        }

        function goInoutIssue(type) {
        	var param = {
				machine_out_doc_seq : "${outDoc.machine_out_doc_seq}",
				type : type // M : 장비, F : 무상부품, P : 유상, A : 추가출고
            }
        	// 추가출고일 경우 유상 부품이 있는지 체크
        	if (type == "A") {
        		$M.goNextPageAjax("/sale/sale0101p08/checkCostOutPart", $M.toGetParam(param), {method: 'get', loader : false},
                        function (result) {
                             if (result.success) {
                            	if (result.type == "P") {
                            		alert("유상전표를 먼저 처리하세요.");
                            	} else {
                            		var poppupOption = "scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1000, height=850, left=0, top=0";
                                    $M.goNextPage('/sale/sale0101p08', $M.toGetParam(param), {popupStatus : poppupOption});
                            	}
                             }
                        }
                   );
        	} else {
        		var poppupOption = "scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1000, height=850, left=0, top=0";
                $M.goNextPage('/sale/sale0101p08', $M.toGetParam(param), {popupStatus : poppupOption});
        	}
        }

        function goCalcDuration(num) {
        	/* if (confirm("센터에서 도착지까지 소요시간을 계산하시겠습니까?") == false) {
        		return false;
        	}	 */
        	var orgCode = $M.getValue("out_org_code");
        	var addr = $M.getValue("arrival"+num+"_addr1");

        	if (orgCode == "") {
        		alert("센터를 선택하세요");
        		return false;
        	}
        	if (addr == "") {
        		alert("도착지"+num+"이 없습니다.");
        		return false;
        	}
        	var param = {
        		org_code : orgCode,
        		addr : addr
        	}
        	$M.goNextPageAjax("/sale/sale0101p03/duration", $M.toGetParam(param), {method: 'get'},
                    function (result) {
                         if (result.success) {
                        	console.log(result);
                        	$M.setValue("arrival"+num+"_move_min", result.move_min);
                        	$M.setValue("arrival"+num+"_move_min_view", result.move_min_view);
                         }
                    }
               );
        }

        // 인도점검 직원 세팅
        function setHandoverMemNo(row) {
			var param = {
				handover_mem_no: row.mem_no,
				handover_mem_name: row.mem_name,
			}
			$M.setValue(param);
		}

        // 지정출고 저장
        function goSaveFixDt() {

        	var dt = $M.getValue("fix_out_dt");
        	if (dt == "") {
        		alert("지정출고일을 선택해주세요.");
        		$("#fix_out_dt").focus();
        		return false;
        	}

        	var param = {
        		machine_out_doc_seq : "${outDoc.machine_out_doc_seq}",
        		machine_doc_no : "${outDoc.machine_doc_no}",
        		fix_out_dt : $M.getValue("fix_out_dt"),
        		fix_out_ti : $M.getValue("fix_out_ti_1")+$M.getValue("fix_out_ti_2"),
        		cust_name : "${custInfo.cust_name}", // 쪽지용
        		machine_name : "${machineInfo.machine_name}", // 쪽지용
        		doc_mem_no : "${outDoc.doc_mem_no}"
        	}

        	if (param.fix_out_ti == "0000") {
        		alert("지정출고시간을 선택해주세요.");
        		$("#fix_out_ti_1").focus();
        		return false;
        	}

        	$M.goNextPageAjaxMsg("지정출고일을 "+param.fix_out_dt+" "+$M.getValue("fix_out_ti_1")+"시 "+$M.getValue("fix_out_ti_2")+"분으로 저장하시겠습니까?\n저장 후 취소할 수 없습니다.", "/sale/sale0101p03/fixDt", $M.toGetParam(param), {method: 'post'},
                    function (result) {
                         if (result.success) {
                        	 $("#btnFixDt").css("display", "none");
                         }
                    }
               );
        }

     	// 지정출고 확정
        function goSaveFixDtConfirm() {
        	var param = {
           		machine_out_doc_seq : "${outDoc.machine_out_doc_seq}",
           		cust_name : "${custInfo.cust_name}", // 쪽지용
           		machine_name : "${machineInfo.machine_name}" // 쪽지용
           	}
        	$M.goNextPageAjaxMsg("지정출고일을 확정하시겠습니까?\n확정 후 취소할 수 없습니다.", "/sale/sale0101p03/fixDtConfirm", $M.toGetParam(param), {method: 'post'},
                    function (result) {
                         if (result.success) {
                        	$("#btnFixDtConfirm").css("display", "none");
                         }
                    }
               );
        }

     	// 업무DB 연결 함수 21-08-05이강원
     	function openWorkDB(){
     		openWorkDBPanel('', "${outDoc.machine_plant_seq}");
     	}

        // 3-2차 (Q&A 14467) 출고 완료 후 출하취소 2022-12-21 김상덕
        function goCancelAfterOut() {


            if (confirm("관리확인요청 상태로 돌아갑니다.\n출하 취소처리 하시겠습니까?") == false) {
                return false;
            }

            $M.goNextPageAjax(this_page+"/outCancel/"+"${outDoc.machine_doc_no}", '', {method: 'post'},
                function (result) {
                    if (result.success) {
                        alert("출하 취소처리 완료되었습니다.");
                        if (opener != null && opener.goSearch) {
                            opener.goSearch();
                        }
                        fnClose();
                    }
                }
            );

        }

        // Q&A 18285 : 운송사 고객운수 선택시 고객 휴대폰번호 셋팅
        function fnTransportChange(val) {
            var transportTelNo = $M.getValue("transport_tel_no");
            var hpNo = $M.getValue("hp_no");

            if (val == '96') {
                $M.setValue("transport_tel_no", hpNo);
            } else {
                if (transportTelNo == '') {
                    $M.setValue("transport_tel_no", "");
                }
            }
        }
        
        // 모두싸인 콜백
        function moduSignPanelCallBack(data) {
          var driverParam = {
            'sign_file_seq' : data.sign_file_seq,
            'machine_out_doc_seq' : $M.getValue('machine_out_doc_seq'),
            'driver_name' : data.trans_send_name,
            'driver_hp_no' : data.trans_send_hp_no,
            'driver_car_no' : data.trans_send_car_no,
          }
          
          // 1. 운송자싸인 저장
          $M.goNextPageAjax(this_page + "/save/driverInfo", $M.toGetParam(driverParam), {method : 'POST'},
            function(result) {
              if(result.success) {
                var moduSignParam = {
                  machine_out_doc_seq: $M.getValue('machine_out_doc_seq'),
                  machine_doc_no: $M.getValue('machine_doc_no'),
                  modusign_doc_cd: 'MCH_OUT_DOC',
                  // 인수자
                  modusign_send_cd: data.modusign_send_cd,
                  send_hp_no: data.modusign_send_value,
                  send_email: data.modusign_send_value,
                  // 운송자 (자동화건으로 운송자 삭제)
                  // trans_modusign_send_cd: data.trans_modusign_send_cd,
                  // transport_name: data.trans_send_name,
                  // transport_email: data.trans_modusign_send_value,
                  // transport_hp_no: data.trans_modusign_send_value,
                  modu_modify_yn : $M.getValue("modu_modify_yn") == ""? "N":$M.getValue("modu_modify_yn"),
                  modusign_id : "${outDoc.out_modusign_id}",
                }
                
                // 2. 장비인수 모두싸인 요청
                $M.goNextPageAjax("/modu/request_document", $M.toGetParam(moduSignParam), {method : 'POST'},
                  function(result) {
                    if(result.success) {
                      location.reload();
                    }
                  }
                );
              }
            }
          );
        }

        // 모두싸인 대면요청 (저장 후 진행)
        function sendModusignPanel() {
          var params = getModuSignData("장비인수증 싸인 요청을 하시겠습니까?");
          openSendModusignPanel('moduSignPanelCallBack', $M.toGetParam(params));
        }
        
        // 모두싸인 취소
        function sendModusignCancel() {
          var msg = "싸인을 취소하시겠습니까?";

          var param = {
            "modusign_id" : "${outDoc.out_modusign_id}",
          };

          $M.goNextPageAjaxMsg(msg, "/modu/request/cancel", $M.toGetParam(param), {method : 'POST'},
            function(result) {
              if(result.success) {
                location.reload();
              }
            }
          );
        }
        
        // 모두싸인 완료된 거 취소 함수
        function fnModusignModify() {
          var frm = document.main_form;

          $("#_sendModusignPanel").show();
          $("#_sendContactModusignPanel").show();
          $("#_fnModusignModify").hide();
          $("#_file_name").hide();
          $M.setValue(frm, "modu_modify_yn", "Y");
          
        }

    </script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<input type="hidden" id="fix_out_yn" name="fix_out_yn" value="${outDoc.fix_out_yn}">
	<input type="hidden" id="machine_name" name="machine_name" value="${machineInfo.machine_name}">
    <input type="hidden" id="cust_no" name="cust_no" value="${custInfo.cust_no}">
    <input type="hidden" id="sar_yn" name="sar_yn" value="${outDoc.sar_yn}">
    <input type="hidden" id="di_coupon_yn" name="di_coupon_yn" value="${outDoc.di_coupon_yn}">
    <input type="hidden" id="center_di_yn" name="center_di_yn" value="${outDoc.center_di_yn}">
    <input type="hidden" id="receive_confirm_yn" name="receive_confirm_yn" value="Y">
    <input type="hidden" id="machine_doc_status_cd" name="machine_doc_status_cd" value="${outDoc.machine_doc_status_cd}">
    <input type="hidden" id="machine_out_status_cd" name="machine_out_status_cd" value="${outDoc.machine_out_status_cd}">
    <input type="hidden" id="machine_doc_no" name="machine_doc_no" value="${outDoc.machine_doc_no}">
    <input type="hidden" id="receive_plant_ti" name="receive_plant_ti" value="${outDoc.receive_plant_ti}">
    <input type="hidden" id="machine_out_doc_seq" name="machine_out_doc_seq" value="${outDoc.machine_out_doc_seq}">
    <input type="hidden" id="machine_seq" name="machine_seq" value="${outDoc.machine_seq}">
    <input type="hidden" id="out_hold_yn" name="out_hold_yn" value="${outDoc.out_hold_yn}">
    <input type="hidden" id="used_car_doc_yn" name="used_car_doc_yn" value="${outdoc.used_car_doc_yn}">
    <input type="hidden" id="used_move_doc_yn" name="used_move_doc_yn" value="${outdoc.used_move_doc_yn}">

    <input type="hidden" id="cost_part_breg_no" name="cost_part_breg_no" value="${outDoc.cost_part_breg_no }">
    <input type="hidden" id="doc_modusign_id" name="doc_modusign_id" value="${outDoc.doc_modusign_id}">
    <input type="hidden" id="driver_name" name="driver_name" value="${outDoc.driver_name}">
    <input type="hidden" id="driver_hp_no" name="driver_hp_no" value="${outDoc.driver_hp_no}">
    <input type="hidden" id="driver_car_no" name="driver_car_no" value="${outDoc.driver_car_no}">
    <input type="hidden" id="sign_file_seq" name="sign_file_seq" value="${outDoc.sign_file_seq}">
    <!-- 팝업 -->
    <div class="popup-wrap width-100per" style="min-width: 1250px">
        <!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
        <!-- /타이틀영역 -->
        <div class="content-wrap">
            <div class="title-wrap">
                <h4 class="primary">출하의뢰서작성</h4>
                <div>
                    <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
                        <jsp:param name="pos" value="TOP_R"/>
                    </jsp:include>
                </div>
            </div>
            <!-- 폼테이블 -->
            <div class="row">
                <!-- 좌측 폼테이블-->
                <div class="col-7">
                    <div class="title-wrap">
                        <h4>기본정보</h4>
                        <div>${outDoc.reg_date} ${outDoc.reg_mem_name}
                            <c:if test="${not empty outDoc.reg_date}">[작성완료]</c:if>
                            <c:if test="${page.add.ACNT_MNG_YN eq 'Y' and outDoc.machine_out_status_cd eq '3' and 'Y' eq outDoc.out_certi_yn}">
                        		<button type="button" class="btn btn-default" onclick="javascript:goDocPrintHistory()">출하증명서 발급이력</button>
                        	</c:if>
                        </div>
                    </div>
                    <div class="process01">
                        <table class="table-border mt5">
                            <colgroup>
                                <col width="80px">
                                <col width="">
                                <col width="70px">
                                <col width="150px">
                                <col width="60px">
                                <col width="150px">
                            </colgroup>
                            <tbody>
                            <tr>
                                <th class="text-right">관리번호</th>
                                <td>
                                    <div class="form-row inline-pd">
                                        <div class="pl5" style="width: 115px;">
                                            <input type="text" class="form-control" readonly="readonly"
                                                   value="${outDoc.machine_doc_no}">
                                        </div>
                                        <div class="col-3"></div>
                                    </div>
                                </td>
                                <th class="text-right">상태</th>
                                <td style="color: red">
                                    <c:choose>
                                    	<c:when test="${outDoc.machine_doc_status_cd ne '3' and not empty outDoc.machine_out_status_cd}">
	                                        <c:if test="${outDoc.machine_out_status_cd eq '0' }">마케팅작성중</c:if>
	                                        <c:if test="${outDoc.machine_out_status_cd eq '1' }">관리확인중</c:if>
	                                        <c:if test="${outDoc.machine_out_status_cd eq '2' }">출하처리중</c:if>
	                                        <c:if test="${outDoc.machine_out_status_cd eq '3' }">출하완료</c:if>
	                                        <c:if test="${outDoc.machine_out_status_cd eq '4' }"><span style="color: red">계약취소</span></c:if>
                                   		</c:when>
                                   		<c:when test="${outDoc.machine_doc_status_cd eq '4'}">
                                   			계약취소
                                   		</c:when>
                                   		<c:when test="${outDoc.machine_doc_status_cd eq '3' and not empty outDoc.machine_out_status_cd}">
                                   			출하처리중
                                   		</c:when>
                                   		<c:otherwise>미작성</c:otherwise>
                                    </c:choose>
                                </td>
                                <th class="text-right">CAP구분</th>
                                <td>
                                    <div class="form-check form-check-inline">
                                        <input class="form-check-input" type="radio" name="cap_yn" id="cap_yn_n"
                                               value="N" checked="checked">
                                        <label class="form-check-label" for="cap_yn_n" style="margin-top: 1px">미적용</label>
                                    </div>
                                    <div class="form-check form-check-inline">
                                        <input class="form-check-input" type="radio" name="cap_yn" id="cap_yn_y"
                                               value="Y">
                                        <label class="form-check-label" for="cap_yn_y" style="margin-top: 1px">적용</label>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <th class="text-right">고객명</th>
                                <td>
                                    <div class="form-row inline-pd pr">
                                        <div class="col-6">
                                            <input type="text" class="form-control" readonly="readonly"
                                                   value="${custInfo.cust_name }" id="cust_name" name="cust_name">
                                        </div>
                                        <%-- (Q&A 16821) 대리점직원은 연관업무 안보이도록.2022-11-18 김상덕. --%>
										<c:if test="${page.fnc.F00111_004 eq 'Y'}">
	                                        <!-- 연관업무 버튼 마우스 오버시 레이어팝업 -->
	                                        <input type="hidden" name="__s_cust_no" value="${custInfo.cust_no}">
	                                        <input type="hidden" name="__s_hp_no" value="${outDoc.hp_no}">
	                                        <input type="hidden" name="__s_cust_name" value="${custInfo.cust_name}">
	                                        <input type="hidden" name="__s_machine_doc_no" value="${outDoc.machine_doc_no}">

		                                        <jsp:include page="/WEB-INF/jsp/common/commonCustJob.jsp">
		                                            <jsp:param name="jobType" value="O"/>
		                                            <jsp:param name="li_type" value="__ledger#__sms_popup#__machine_doc"/>
		                                        </jsp:include>
	                                        <!-- /연관업무 버튼 마우스 오버시 레이어팝업 -->
                                        </c:if>
                                    </div>
                                </td>
                                <th class="text-right rs">휴대폰</th>
                                <td>
                                    <div class="input-group">
                                        <input type="text" class="form-control border-right-0"
                                               value="${outDoc.hp_no }" id="hp_no" name="hp_no" alt="휴대폰"
                                               required="required" format="phone" readonly="readonly">
                                        <button type="button" class="btn btn-icon btn-primary-gra"
                                                onclick="javascript:fnSendSms();"><i class="material-iconsforum"></i>
                                        </button>
                                    </div>
                                </td>
                                <th class="text-right">관리등급</th>
                                <td>${custInfo.cust_grade_cd}</td>
                            </tr>
                            <tr>
                                <th class="text-right rs">사업자번호</th>
                                <td>
                                    <div class="input-group">
                                        <input type="text" class="form-control border-right-0"
                                               value="${outDoc.breg_no}" id="breg_no" name="breg_no" alt="사업자번호"
                                               required="required" readonly="readonly" format="bregno">
                                        <input type="hidden" id="breg_seq" name="breg_seq" value="${outDoc.breg_seq }">
                                        <button type="button" class="btn btn-icon btn-primary-gra" id="breg_search_btn"
                                                onclick="javascript:goSearchBregInfo();"><i
                                                class="material-iconssearch"></i></button>
                                        <button type="button" class="btn btn-default" id="customerSave" onclick="javascript:goSaveCustomerBreg()" style="margin-left: 2px;border-radius: 4px;">고객반영</button>
                                    </div>
                                </td>
                                <th class="text-right rs">사업자명</th>
                                <td>
                                    <input type="text" class="form-control" value="${outDoc.breg_name}" id="breg_name"
                                           name="breg_name" alt="사업자명" required="required" readonly="readonly">
                                </td>
                                <th class="text-right rs">대표자</th>
                                <td>
                                    <input type="text" class="form-control" value="${outDoc.breg_rep_name}"
                                           id="breg_rep_name" name="breg_rep_name" alt="대표자" required="required" readonly="readonly">
                                </td>
                            </tr>
                            <tr>
                                <th class="text-right rs">인감주소</th>
                                <td colspan="5">
                                    <div class="form-row inline-pd">
                                        <div class="col-1 pdr0">
                                            <input type="text" class="form-control mw45" readonly="readonly"
                                                   value="${outDoc.seal_post_no}" id="seal_post_no" name="seal_post_no"
                                                   alt="인감주소 우편번호">
                                        </div>
                                        <div class="col-auto pdl5">
                                            <button type="button" class="btn btn-primary-gra full" id="seal_addr_search"
                                                    onclick="javascript:openSearchAddrPanel('fnSetSealAddr');">주소찾기
                                            </button>
                                        </div>
                                        <div class="col-5">
                                            <input type="text" class="form-control" readonly="readonly"
                                                   value="${outDoc.seal_addr1}" id="seal_addr1" name="seal_addr1"
                                                   alt="인감주소1">
                                        </div>
                                        <div class="col-4">
                                            <input type="text" class="form-control" value="${outDoc.seal_addr2}"
                                                   id="seal_addr2" name="seal_addr2" alt="인감주소2" maxlength="75">
                                        </div>
                                        <div>
                                        	<button type="button" class="btn btn-info" id="btnModifySeal" style="display: none;" onclick="javascript:goModifySeal()">수정</button>
                                        </div>
                                    </div>
                                    <div class="font-11 text-secondary">※ 법인의 경우에는 사업장소재지, 개인사업자의 경우 인감증명서상의 주소지를
                                        입력하십시오.
                                    </div>
                                </td>
                            </tr>

                            </tbody>
                        </table>
                    </div>

                    <div class="process01">
                        <table class="table-border mt5">
                            <colgroup>
                                <col width="95px">
                                <col width="">
                                <col width="95px">
                                <col width="">
                            </colgroup>
                            <tbody>
                            <tr>
                                <th class="text-right">장비명</th>
                                <td colspan="3">
                                    <div class="form-row inline-pd">
                                        <div class="col-auto">
                                            ${machineInfo.machine_name }
                                        </div>
                                        <div class="col-auto">
											<c:if test="${page.fnc.F00111_004 eq 'Y'}">
		                                   		<button type="button" id="work_db_btn" class="btn btn-primary-gra" onclick="javascript:openWorkDB();")>업무DB</button>
		                                   	</c:if>
		                                </div>
                                        <div class="col-auto">
                                            <c:if test="${machineInfo.sar_yn_info == 'Y'}">
                                                <button type="button" class="btn btn-primary-gra" onclick="goSarInfo()">
                                                    SA-R 계약정보
                                                </button>
                                            </c:if>
                                        </div>
                                    </div>
                                </td>
                                <%-- <th></th>
                                <td><div>저장 전 희망시간 : ${fn:substring(outDoc.receive_plan_ti,0,2)}시 ${fn:substring(outDoc.receive_plan_ti,2,4)}분</div></td> --%>
                            </tr>
                            <tr>
                                <th class="text-right rs">운송구분</th>
                                <td>
                                    <select class="form-control rb width140px" id="machine_send_cd" alt="운송구분"
                                            name="machine_send_cd">
                                        <option value="">- 선택 -</option>
                                        <c:forEach var="item" items="${codeMap['MACHINE_SEND']}">
                                            <option value="${item.code_value}"
                                                    <c:if test="${outDoc.machine_send_cd == item.code_value}">selected="selected"</c:if>>
                                                    ${item.code_name}
                                            </option>
                                        </c:forEach>
                                    </select>
                                </td>
                                <th class="text-right">센터</th>
                                <td>
                                    <div class="form-row inline-pd">
                                        <div class="pl5 pr5">
                                        	<c:choose>
                                        		<c:when test="${empty outDoc.pre_in_org_code}">
                                        			<c:if test="${empty outDoc.stock_machine_doc_no}">
		                                        		<c:if test="${not empty outDoc.machine_out_status_cd and outDoc.machine_out_status_cd >= '1'}">
			                                        		<select class="form-control" id="out_org_code" name="out_org_code" onchange="javascript:fnInitPlanTi()">
				                                                <c:forEach var="item" items="${outOrgCodeList}">
				                                                    <option value="${item.org_code}" org_name="${item.org_name}"
				                                                            <c:if test="${outDoc.out_org_code == item.org_code}">selected="selected"</c:if>>
				                                                            ${item.machine_cnt}
				                                                    </option>
				                                                </c:forEach>
				                                            </select>
			                                        	</c:if>
			                                        	<c:if test="${empty outDoc.machine_out_status_cd or outDoc.machine_out_status_cd < '1'}">
			                                        		<select class="form-control" id="out_org_code" name="out_org_code" onchange="javascript:fnInitPlanTi()">
				                                                <c:forEach var="item" items="${outOrgCodeList}">
				                                                    <option value="${item.org_code}" org_name="${item.org_name}"
				                                                            <c:if test="${outDoc.out_org_code == item.org_code}">selected="selected"</c:if>>
				                                                            ${item.org_name}
				                                                    </option>
				                                                </c:forEach>
				                                            </select>
			                                        	</c:if>
		                                        	</c:if>
		                                        	<c:if test="${not empty outDoc.stock_machine_doc_no}">
		                                        		마케팅
		                                        	</c:if>
                                        		</c:when>
                                        		<c:otherwise>
                                        			<select class="form-control" id="out_org_code" name="out_org_code" onchange="javascript:fnInitPlanTi()">
                                        				<option value="${outDoc.pre_in_org_code}" org_name="${outDoc.pre_in_org_name}">${outDoc.pre_in_org_name }</option>
                                        			</select>
                                        		</c:otherwise>
                                        	</c:choose>
                                        </div>
<%--                                        <input class="form-check-input" type="hidden" id="receive_confirm_yn" name="receive_confirm_yn" value="Y">--%>
<%--                                        <div class="">--%>
<%--                                            <div class="form-check form-check-inline" style="margin-right: 0px">--%>
<%--                                                <input class="form-check-input" type="checkbox" id="receive_confirm_yn_check"--%>
<%--                                                       name="receive_confirm_yn_check" value="Y"--%>
<%--                                                       <c:if test="${outDoc.receive_confirm_yn == 'Y'}">checked="checked"</c:if>>--%>
<%--                                                <label for="receive_confirm_yn_check" class="form-check-label">예정일 및 도착지 확정</label>--%>
<%--                                            </div>--%>
<%--                                        </div>--%>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <th class="text-right rs">도착지1</th>
                                <td colspan="3">
                                    <div class="form-row inline-pd">
                                        <div class="col-1 pdr0">
                                            <input type="text" class="form-control mw45" readonly="readonly"
                                                   id="arrival1_post_no" name="arrival1_post_no"
                                                   value="${outDoc.arrival1_post_no}">
                                        </div>
                                        <div class="col-auto pdl5">
                                            <button type="button" class="btn btn-primary-gra full"
                                                    onclick="javascript:openSearchAddrPanel('fnSetArrival1Addr');">주소찾기
                                            </button>
                                        </div>
                                        <div class="col-5">
                                            <input type="text" class="form-control" readonly="readonly"
                                                   id="arrival1_addr1" name="arrival1_addr1"
                                                   value="${outDoc.arrival1_addr1}">
                                        </div>
                                        <div class="col-2">
                                            <input type="text" class="form-control" id="arrival1_addr2" maxlength="75"
                                                   name="arrival1_addr2" value="${outDoc.arrival1_addr2}">
                                        </div>
                                        <div  style="padding-right: 5px;">
                                        	<c:if test="${not empty outDoc.machine_out_status_cd and outDoc.machine_out_status_cd > '0' and empty outDoc.stock_machine_doc_no}">
                                        		<button type="button" class="btn btn-default" onclick="javascript:goCalcDuration(1)">소요시간</button>
                                        	</c:if>
                                        </div>
                                        <div class="col-1">
                                        	<input type="text" class="form-control" id="arrival1_move_min_view" name="arrival1_move_min_view" placeholder="hh:mm" readonly="readonly" value="${outDoc.arrival1_move_min_view}">
                                        	<input type="hidden" id="arrival1_move_min" name="arrival1_move_min" value="${outDoc.arrival1_move_min}">
                                        </div>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <th class="text-right">도착지2</th>
                                <td colspan="3">
                                    <div class="form-row inline-pd">
                                        <div class="col-1 pdr0">
                                            <input type="text" class="form-control mw45" readonly="readonly"
                                                   id="arrival2_post_no" name="arrival2_post_no"
                                                   value="${outDoc.arrival2_post_no}">
                                        </div>
                                        <div class="col-auto pdl5">
                                            <button type="button" class="btn btn-primary-gra full"
                                                    onclick="javascript:openSearchAddrPanel('fnSetArrival2Addr');">주소찾기
                                            </button>
                                        </div>
                                        <div class="col-5">
                                            <input type="text" class="form-control" readonly="readonly"
                                                   id="arrival2_addr1" name="arrival2_addr1"
                                                   value="${outDoc.arrival2_addr1}">
                                        </div>
                                        <div class="col-2">
                                            <input type="text" class="form-control" id="arrival2_addr2" maxlength="75"
                                                   name="arrival2_addr2" value="${outDoc.arrival2_addr2}">
                                        </div>
                                        <div  style="padding-right: 5px;">
                                        	<c:if test="${not empty outDoc.machine_out_status_cd and outDoc.machine_out_status_cd > '0' and empty outDoc.stock_machine_doc_no}">
                                        		<button type="button" class="btn btn-default" onclick="javascript:goCalcDuration(2)">소요시간</button>
                                        	</c:if>
                                        </div>
                                        <div class="col-1">
                                        	<input type="text" class="form-control" id="arrival2_move_min_view" name="arrival2_move_min_view" placeholder="hh:mm" readonly="readonly" value="${outDoc.arrival2_move_min_view}">
                                        	<input type="hidden" id="arrival2_move_min" name="arrival2_move_min" value="${outDoc.arrival2_move_min}">
                                        </div>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <!-- <th class="text-right rs">인도예정</th> -->
                                <th class="text-right rs">출하예정일자</th> <!-- 2차개발, 인도예정을 출하예정일자로 변경 -->
                                <td>
                                    <div class="input-group width120px">
                                        <input type="text" class="form-control border-right-0 calDate rb" alt="인도예정일"
                                               id="receive_plan_dt" name="receive_plan_dt" dateFormat="yyyy-MM-dd" required="required" value="${outDoc.receive_plan_dt}" onchange="fnInitPlanTi()">
                                    </div>
                                </td>
                                <!-- <th class="text-right rs">희망시간</th> -->
                                <th class="text-right rs">
                               		<c:if test="${outDoc.machine_out_status_cd >= '1'}">
                               			출하예상시간
                               		</c:if>
                                	<c:if test="${outDoc.machine_out_status_cd < '1'}">
                                		출하희망시간
                                	</c:if>
                                </th><!-- 2차개발, 희망시간을 출하예상시간으로 변경 -->
                                <td>
                                	<div class="input-group">
                                		<c:if test="${not empty outDoc.receive_plan_ti}">
                                			<input type="text" class="form-control border-right-0" style="max-width: 76px;" id="receive_plan_ti_temp" name="receive_plan_ti_temp" required="required" readonly="readonly" value="${fn:substring(outDoc.receive_plan_ti,0,2)}시 ${fn:substring(outDoc.receive_plan_ti,2,4)}분">
                                		</c:if>
                                		<c:if test="${empty outDoc.receive_plan_ti}">
                                			<input type="text" class="form-control border-right-0" style="max-width: 76px;" id="receive_plan_ti_temp" name="receive_plan_ti_temp" required="required" readonly="readonly" value="" alt="출하예상시간">
                                		</c:if>
                                   		<input type="hidden" id="receive_plan_ti_1" name="receive_plan_ti_1" value="${fn:substring(outDoc.receive_plan_ti,0,2) }">
                                   		<input type="hidden" id="receive_plan_ti_2" name="receive_plan_ti_2" value="${fn:substring(outDoc.receive_plan_ti,2,4) }">
                                   		<button type="button" class="btn btn-icon btn-primary-gra" id="breg_search_btn" onclick="javascript:goPlanTiPopup()"><i class="material-iconssearch"></i></button>
                                        <div class="form-check form-check-inline" style="margin-left: 5px;">
                                               <input class="form-check-input" type="checkbox" id="center_di_yn_check"
                                                      name="center_di_yn_check" value="Y"
                                                      <c:if test="${outDoc.center_di_yn == 'Y'}">checked="checked"</c:if>>
                                               <label class="form-check-label" for="center_di_yn_check">센터 DI</label>
                                        </div>
                                   	</div>
                                </td>
                            </tr>
                            <tr>
                                <th class="text-right rs">인수자</th>
                                <td>
                                    <input type="text" class="form-control width140px rb" id="receive_user_name" maxlength="30"
                                           name="receive_user_name" alt="인수자" value="${outDoc.receive_user_name }">
                                </td>
                                <th class="text-right rs">연락처</th>
                                <td>
                                    <input type="text" class="form-control width140px rb" id="receive_user_tel_no" maxlength="14" format="tel"
                                           name="receive_user_tel_no" alt="연락처" value="${outDoc.receive_user_tel_no }">
                                </td>
                            </tr>
                            <tr>
                                <th class="text-right rs">지입사명</th>
                                <td>
                                    <input type="text" class="form-control width140px rb" id="allo_name" maxlength="30"
                                           name="allo_name" alt="지입사명" value="${outDoc.allo_name }">
                                </td>
                                <th class="text-right rs">지입사연락처</th>
                                <td>
                                    <input type="text" class="form-control width140px rb" id="allo_tel_no" maxlength="14" format="tel"
                                           name="allo_tel_no" alt="지입사연락처" value="${outDoc.allo_tel_no }">
                                </td>
                            </tr>
                            <tr>
                                <th class="text-right rs" style="padding-left: 0 !important;">등록서류수령지</th>
                                <td colspan="3">
                                    <div class="form-row inline-pd mb3">
                                        <div class="col-1 pdr0">
                                            <input type="text" class="form-control mw45" readonly="readonly"
                                                   id="paper_post_no" name="paper_post_no" value="${outDoc.paper_post_no}">
                                        </div>
                                        <div class="col-auto pdl5">
                                            <button type="button" class="btn btn-primary-gra full"
                                                    onclick="javascript:openSearchAddrPanel('fnSetPaperAddr');">주소찾기
                                            </button>
                                        </div>
                                        <div class="col-5">
                                            <input type="text" class="form-control" readonly="readonly"
                                                   id="paper_addr1" name="paper_addr1" value="${outDoc.paper_addr1}">
                                        </div>
                                        <div class="col-4">
                                            <input type="text" class="form-control" id="paper_addr2" name="paper_addr2" value="${outDoc.paper_addr2}" maxlength="75">
                                        </div>
                                    </div>
                                    <div class="font-11 text-secondary">※ 지입사명이 없는 경우 지입사명에는 "자가등록", 지입사연락처란에는 연락가능한 전화번호를 입력하십시오.
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <th class="text-right">담당요청사항</th>
                                <td>
                                    <input type="text" class="form-control" id="receive_user_remark" maxlength="100"
                                           name="receive_user_remark" value="${outDoc.receive_user_remark}" disabled="disabled">
                                </td>
                                <th class="text-right">관리요청사항</th>
                                <td>
                                    <input type="text" class="form-control" id="receive_mng_remark" value="${outDoc.receive_mng_remark}" maxlength="100"
                                           name="receive_mng_remark" disabled="disabled">
                                </td>
                            </tr>
                            <c:if test="${'Y' eq outDoc.fix_out_yn and (('2' eq outDoc.machine_out_status_cd) or ('3' eq outDoc.machine_out_status_cd))}">
                            <tr>
                            	<th class="text-right">지정출고일</th>
                            	<td colspan="3" class="fixOutDiv">
                            		<div class="form-row inline-pd" style="padding-left: 5px;">
										<input type="text" class="form-control p2b" id="fix_out_dt" name="fix_out_dt" alt="출고일자" value="${outDoc.fix_out_dt}" dateFormat="yyyy-MM-dd" style="width: 80px;" ${not empty ouDoc.fix_out_dt ? 'readonly' : ''}>
										<div class="pl5">
	                                       <select class="form-control width45px p2b" id="fix_out_ti_1" name="fix_out_ti_1">
	                                           <c:forEach var="ti" varStatus="i" begin="8" end="18" step="1">
	                                               <option value="<c:if test="${ti < 10}">0</c:if><c:out value="${ti}" />"
	                                                       <c:if test="${not empty outDoc.fix_out_ti and ti == fn:substring(outDoc.fix_out_ti,0,2)}">selected="selected"</c:if>>
	                                                   <c:if test="${ti < 10}">0</c:if><c:out value="${ti}"/>
	                                               </option>
	                                           </c:forEach>
	                                       </select>
										</div>
										<div class="pl5">
	                                       	시
										</div>
										<div class="pl5">
	                                       <select class="form-control width45px p2b" id="fix_out_ti_2" name="fix_out_ti_2">
	                                           <c:forEach var="ti" varStatus="i" begin="0" end="30" step="30">
	                                               <option value="<c:if test="${ti < 10}">0</c:if><c:out value="${ti}" />"
	                                                       <c:if test="${not empty outDoc.fix_out_ti and ti == fn:substring(outDoc.fix_out_ti,2,4)}">selected="selected"</c:if>>
	                                                   <c:if test="${ti < 10}">0</c:if><c:out value="${ti}"/>
	                                               </option>
	                                           </c:forEach>
	                                       </select>
										</div>
										<div class="pl5">
	                                       	분
										</div>
										<c:if test="${'N' eq outDoc.fix_out_confirm_yn and page.add.OUT_MNG_YN eq 'Y' and empty outDoc.fix_out_ti}">
											<button type="button" class="btn btn-info pl5" id="btnFixDt" onclick="javascript:goSaveFixDt()" style="margin-left: 5px !important">지정출고저장</button>
										</c:if>
										<c:if test="${'N' eq outDoc.fix_out_confirm_yn and outDoc.doc_mem_no eq SecureUser.mem_no and not empty outDoc.fix_out_ti}">
											<button type="button" class="btn btn-info pl5" id="btnFixDtConfirm" onclick="javascript:goSaveFixDtConfirm()" style="margin-left: 5px !important">지정출고확정</button>
										</c:if>
	                               </div>
                            	</td>
                            </tr>
                            </c:if>
                            </tbody>
                        </table>
                    </div>
                    <!-- 특이사항 및 담당자의견 -->
<%--                    <div>--%>
<%--                        <div class="title-wrap mt10">--%>
<%--                            <h4>특이사항 및 담당자 의견</h4>--%>
<%--                        </div>--%>
<%--                        <textarea class="form-control mt5" style="height: 130px;" id="saleDoc_remark" disabled="disabled">${outDoc.remark}</textarea>--%>
<%--                    </div>--%>
                    <div class="row">
                        <div class="col-6">
                            <div class="title-wrap mt5">
                                <h4>담당자 의견</h4>
                            </div>
                            <textarea class="form-control mt5" style="height: 130px;" id="saleDoc_remark" disabled="disabled">${outDoc.remark}</textarea>
                        </div>
                        <div class="col-6">
                            <div class="title-wrap mt5">
                                <h4>특약사항</h4>
                            </div>
                            <textarea class="form-control mt5" style="height: 130px;" id="special_remark" disabled="disabled">${outDoc.special_remark}</textarea>
                        </div>
                    </div>
                    <!-- /특이사항 및 담당자의견 -->
                    <div>
                        <!-- 그리드 타이틀, 컨트롤 영역 -->
                        <div class="title-wrap mt10">
                            <div class="title-sum">
                                <h4>지급품목</h4>
                                <div>전체 <span id="part_total_cnt"></span>건 중 <span class="text-secondary"><span
                                        id="no_out_qty">0</span>건 </span>미출고
                                </div>
                            </div>

                            <div>
                            	<c:if test="${outDoc.machine_out_status_cd eq '2'}">
                            		<span>부품출하에서 처리 시, 미출고 수량이 반영됩니다.</span>
                            		<span><button type="button" class="btn btn-info" onclick="javascript:goPartoutPage()">부품출고</button></span>
                            	</c:if>
                            	<c:if test="${'1' eq outDoc.machine_out_status_cd and empty outDoc.stock_machine_doc_no}"> <!-- 관리확인 단계 부품 추가 -->
                            		<button type="button" class="btn btn-default" onclick="javascript:goAddPartPopup()">추가출고처리</button>
                            	</c:if>
                            	<c:if test="${'3' eq outDoc.machine_out_status_cd}"> <!-- 출하 후 미출고분 추가출고 -->
                            		<c:forEach items="${addTypeList}" var="add" varStatus="addStatus">
                            				<c:if test="${add.free_yn eq 'Y'}">
                            					<button type="button" class="btn btn-default" onclick="javascript:goOutNoQtyPopup('AF')">무상 추가출고처리</button>
                            				</c:if>
                            				<c:if test="${add.free_yn eq 'N'}">
                            					<button type="button" class="btn btn-default" onclick="javascript:goOutNoQtyPopup('AP')">유상 추가출고처리</button>
                            				</c:if>
                            		</c:forEach>
                            	</c:if>
                            </div>
                        </div>
                        <!-- /그리드 타이틀, 컨트롤 영역 -->
                        <div id="auiGrid_part" style="margin-top: 5px; height: 171px;"></div>
                    </div>

                    <div>
                        <!-- 그리드 타이틀, 컨트롤 영역 -->
                        <div class="title-wrap mt10">
                            <h4>옵션품목</h4>
                            <div class="btn-group">
                                <div class="right">
                                    <select name="opt_code" id="opt_code" style="height: 24px; display: none;" disabled="disabled"></select>
                                </div>
                            </div>
                        </div>
                        <!-- /그리드 타이틀, 컨트롤 영역 -->
                        <div id="auiGrid_option" style="margin-top: 5px; height: 130px;"></div>
                    </div>

                </div>
                <!-- 좌측 폼테이블-->
                <!-- 우측 폼테이블-->
                <div class="col-5">
                    <div>
                        <!-- 결제조건 -->
                        <div class="title-wrap">
                            <h4>결제조건</h4>
                            <div><c:if
                                    test="${not empty outDoc.out_req_mem_no}">${outDoc.out_req_date}  ${outDoc.out_req_mem_name} [확인완료]</c:if></div>
                        </div>
                        <table class="table-border doc-table mt5">
                            <colgroup>
                                <col width="20%">
                                <col width="30%">
                                <col width="22%">
                                <col width="30%">
                            </colgroup>
<%--                            <thead>--%>
<%--                            <tr>--%>
<%--                                <th class="title-bg">구분</th>--%>
<%--                                <th class="title-bg">금액</th>--%>
<%--                                <th class="title-bg">입금예정일</th>--%>
<%--                                <th class="title-bg">입금액</th>--%>
<%--                            </tr>--%>
<%--                            </thead>--%>
                            <tbody>
                            <tr>
                                <th>현금</th>
                                <td>
                                    <div class="form-row inline-pd widthfix">
                                        <div class="col width120px">
                                            <input type="text" class="form-control text-right" readonly="readonly"
                                                   format="decimal" id="plan_amt_0" name="plan_amt_0"
                                                   value="${depositMap.plan_amt_cash}">
                                        </div>
                                        <div class="col width16px">원</div>
                                    </div>
                                </td>
<%--                                <td>--%>
<%--                                    <div class="input-group width120px">--%>
<%--                                        <input type="text" class="form-control border-right-0" id="plan_dt_cash"--%>
<%--                                               name="plan_dt_cash" disabled="disabled" dateFormat="yyyy-MM-dd"--%>
<%--                                               value="${depositMap.plan_dt_cash}">--%>
<%--                                        <button type="button" class="btn btn-icon btn-primary-gra"><i--%>
<%--                                                class="material-iconsdate_range"></i></button>--%>
<%--                                    </div>--%>
<%--                                </td>--%>
<%--                                <td>--%>
<%--                                    <div class="form-row inline-pd widthfix">--%>
<%--                                        <div class="col width120px">--%>
<%--                                            <input type="text" class="form-control text-right" id="deposit_amt_0"--%>
<%--                                                   name="deposit_amt_0" format="decimal" readonly="readonly"--%>
<%--                                                   value="${depositMap.deposit_amt_cash}">--%>
<%--                                        </div>--%>
<%--                                        <div class="col width16px">원</div>--%>
<%--                                    </div>--%>
<%--                                </td>--%>
                                <th>카드</th>
                                <td>
                                    <div class="form-row inline-pd widthfix">
                                        <div class="col width120px">
                                            <input type="text" class="form-control text-right" id="plan_amt_1"
                                                   name="plan_amt_1" format="decimal" readonly="readonly"
                                                   value="${depositMap.plan_amt_card}">
                                        </div>
                                        <div class="col width16px">원</div>
                                    </div>
                                </td>
                            </tr>
<%--                            <tr>--%>
<%--                                <th>카드</th>--%>
<%--                                <td>--%>
<%--                                    <div class="form-row inline-pd widthfix">--%>
<%--                                        <div class="col width120px">--%>
<%--                                            <input type="text" class="form-control text-right" id="plan_amt_1"--%>
<%--                                                   name="plan_amt_1" format="decimal" readonly="readonly"--%>
<%--                                                   value="${depositMap.plan_amt_card}">--%>
<%--                                        </div>--%>
<%--                                        <div class="col width16px">원</div>--%>
<%--                                    </div>--%>
<%--                                </td>--%>
<%--                                <td>--%>
<%--                                    <div class="input-group width120px">--%>
<%--                                        <input type="text" class="form-control border-right-0" id="plan_dt_card"--%>
<%--                                               name="plan_dt_card" dateFormat="yyyy-MM-dd" disabled="disabled"--%>
<%--                                               value="${depositMap.plan_dt_card}">--%>
<%--                                        <button type="button" class="btn btn-icon btn-primary-gra"><i--%>
<%--                                                class="material-iconsdate_range"></i></button>--%>
<%--                                    </div>--%>
<%--                                </td>--%>
<%--                                <td>--%>
<%--                                    <div class="form-row inline-pd widthfix">--%>
<%--                                        <div class="col width120px">--%>
<%--                                            <input type="text" class="form-control text-right" id="deposit_amt_1"--%>
<%--                                                   name="deposit_amt_1" format="decimal" readonly="readonly"--%>
<%--                                                   value="${depositMap.deposit_amt_card}">--%>
<%--                                        </div>--%>
<%--                                        <div class="col width16px">원</div>--%>
<%--                                    </div>--%>
<%--                                </td>--%>
<%--                            </tr>--%>
                            <tr>
                                <th>중고</th>
                                <td>
                                    <div class="form-row inline-pd widthfix">
                                        <div class="col width120px">
                                            <input type="text" class="form-control text-right" id="plan_amt_2"
                                                   name="plan_amt_2" format="decimal" readonly="readonly"
                                                   value="${depositMap.plan_amt_used}">
                                        </div>
                                        <div class="col width16px">원</div>
                                    </div>
                                </td>
<%--                                <td>--%>
<%--                                    <div class="input-group width120px">--%>
<%--                                        <input type="text" class="form-control border-right-0" id="plan_dt_used"--%>
<%--                                               name="plan_dt_used" dateFormat="yyyy-MM-dd" disabled="disabled"--%>
<%--                                               value="${depositMap.plan_dt_used}">--%>
<%--                                        <button type="button" class="btn btn-icon btn-primary-gra"><i--%>
<%--                                                class="material-iconsdate_range"></i></button>--%>
<%--                                    </div>--%>
<%--                                </td>--%>
<%--                                <td>--%>
<%--                                    <div class="form-row inline-pd widthfix">--%>
<%--                                        <div class="col width120px">--%>
<%--                                            <input type="text" class="form-control text-right" id="deposit_amt_2"--%>
<%--                                                   name="deposit_amt_2" format="decimal" readonly="readonly"--%>
<%--                                                   value="${depositMap.deposit_amt_used}">--%>
<%--                                        </div>--%>
<%--                                        <div class="col width16px">원</div>--%>
<%--                                    </div>--%>
<%--                                </td>--%>
                                <th>캐피탈</th>
                                <td>
                                    <div class="form-row inline-pd widthfix">
                                        <div class="col width120px">
                                            <input type="text" class="form-control text-right" id="plan_amt_3"
                                                   name="plan_amt_3" format="decimal" readonly="readonly"
                                                   value="${depositMap.plan_amt_finance}">
                                        </div>
                                        <div class="col width16px">원</div>
                                    </div>
                                </td>
                            </tr>
<%--                            <tr>--%>
<%--                                <th>캐피탈</th>--%>
<%--                                <td>--%>
<%--                                    <div class="form-row inline-pd widthfix">--%>
<%--                                        <div class="col width120px">--%>
<%--                                            <input type="text" class="form-control text-right" id="plan_amt_3"--%>
<%--                                                   name="plan_amt_3" format="decimal" readonly="readonly"--%>
<%--                                                   value="${depositMap.plan_amt_finance}">--%>
<%--                                        </div>--%>
<%--                                        <div class="col width16px">원</div>--%>
<%--                                    </div>--%>
<%--                                </td>--%>
<%--                                <td>--%>
<%--                                    <div class="input-group width120px">--%>
<%--                                        <input type="text" class="form-control border-right-0" id="plan_dt_finance"--%>
<%--                                               name="plan_dt_finance" dateFormat="yyyy-MM-dd" disabled="disabled"--%>
<%--                                               value="${depositMap.plan_dt_finance}">--%>
<%--                                        <button type="button" class="btn btn-icon btn-primary-gra"><i--%>
<%--                                                class="material-iconsdate_range"></i></button>--%>
<%--                                    </div>--%>
<%--                                </td>--%>
<%--                                <td>--%>
<%--                                    <div class="form-row inline-pd widthfix">--%>
<%--                                        <div class="col width120px">--%>
<%--                                            <input type="text" class="form-control text-right" id="deposit_amt_3"--%>
<%--                                                   name="deposit_amt_3" format="decimal" readonly="readonly"--%>
<%--                                                   value="${depositMap.deposit_amt_finance}">--%>
<%--                                        </div>--%>
<%--                                        <div class="col width16px">원</div>--%>
<%--                                    </div>--%>
<%--                                </td>--%>
<%--                            </tr>--%>
                            <tr>
                                <th>보조</th>
                                <td>
                                    <div class="form-row inline-pd widthfix">
                                        <div class="col width120px">
                                            <input type="text" class="form-control text-right" id="plan_amt_4"
                                                   name="plan_amt_4" format="decimal" readonly="readonly"
                                                   value="${depositMap.plan_amt_assist}">
                                        </div>
                                        <div class="col width16px">원</div>
                                    </div>
                                </td>
<%--                                <td>--%>
<%--                                    <div class="input-group width120px">--%>
<%--                                        <input type="text" class="form-control border-right-0" id="plan_dt_assist"--%>
<%--                                               name="plan_dt_assist" dateFormat="yyyy-MM-dd" disabled="disabled"--%>
<%--                                               value="${depositMap.plan_dt_assist}">--%>
<%--                                        <button type="button" class="btn btn-icon btn-primary-gra"><i--%>
<%--                                                class="material-iconsdate_range"></i></button>--%>
<%--                                    </div>--%>
<%--                                </td>--%>
<%--                                <td>--%>
<%--                                    <div class="form-row inline-pd widthfix">--%>
<%--                                        <div class="col width120px">--%>
<%--                                            <input type="text" class="form-control text-right" id="deposit_amt_4"--%>
<%--                                                   name="deposit_amt_4" format="decimal" readonly="readonly"--%>
<%--                                                   value="${depositMap.deposit_amt_assist}">--%>
<%--                                        </div>--%>
<%--                                        <div class="col width16px">원</div>--%>
<%--                                    </div>--%>
<%--                                </td>--%>
                                <th>VAT</th>
                                <td>
                                    <div class="form-row inline-pd widthfix">
                                        <div class="col width120px">
                                            <input type="text" class="form-control text-right" id="plan_amt_5"
                                                   name="plan_amt_5" format="decimal" readonly="readonly"
                                                   value="${depositMap.plan_amt_vat}">
                                        </div>
                                        <div class="col width16px">원</div>
                                    </div>
                                </td>
                            </tr>
<%--                            <tr>--%>
<%--                                <th>VAT</th>--%>
<%--                                <td>--%>
<%--                                    <div class="form-row inline-pd widthfix">--%>
<%--                                        <div class="col width120px">--%>
<%--                                            <input type="text" class="form-control text-right" id="plan_amt_5"--%>
<%--                                                   name="plan_amt_5" format="decimal" readonly="readonly"--%>
<%--                                                   value="${depositMap.plan_amt_vat}">--%>
<%--                                        </div>--%>
<%--                                        <div class="col width16px">원</div>--%>
<%--                                    </div>--%>
<%--                                </td>--%>
<%--                                <td>--%>
<%--                                    <div class="input-group width120px">--%>
<%--                                        <input type="text" class="form-control border-right-0" id="plan_dt_vat"--%>
<%--                                               name="plan_dt_vat" dateFormat="yyyy-MM-dd" disabled="disabled"--%>
<%--                                               value="${depositMap.plan_dt_vat}">--%>
<%--                                        <button type="button" class="btn btn-icon btn-primary-gra"><i--%>
<%--                                                class="material-iconsdate_range"></i></button>--%>
<%--                                    </div>--%>
<%--                                </td>--%>
<%--                                <td>--%>
<%--                                    <div class="form-row inline-pd widthfix">--%>
<%--                                        <div class="col width120px">--%>
<%--                                            <input type="text" class="form-control text-right" id="deposit_amt_5"--%>
<%--                                                   name="deposit_amt_5" format="decimal" readonly="readonly"--%>
<%--                                                   value="${depositMap.deposit_amt_vat}">--%>
<%--                                        </div>--%>
<%--                                        <div class="col width16px">원</div>--%>
<%--                                    </div>--%>
<%--                                </td>--%>
<%--                            </tr>--%>
<%--                            <tr>--%>
<%--                                <th>캐피탈선택</th>--%>
<%--                                <td colspan="3">--%>
<%--                                    <select class="form-control width200px" name="finance_cmp_cd" disabled="disabled">--%>
<%--                                        <option value="">- 선택 -</option>--%>
<%--                                        <c:forEach var="item" items="${codeMap['FINANCE_CMP']}">--%>
<%--                                            <option value="${item.code_value}"--%>
<%--                                                    <c:if test="${outDoc.finance_cmp_cd == item.code_value}">selected="selected"</c:if>>${item.code_name}</option>--%>
<%--                                        </c:forEach>--%>
<%--                                    </select>--%>
<%--                                </td>--%>
<%--                            </tr>--%>
                            <tr>
                                <th class="th-sum">총액(VAT포함)</th>
                                <td>
                                    <div class="form-row inline-pd widthfix">
                                        <div class="col width120px">
                                            <input type="text" class="form-control text-right" readonly="readonly"
                                                   id="total_vat_amt" name="total_vat_amt" format="decimal"
                                                   value="${depositMap.totalPlanAmt}">
                                        </div>
                                        <div class="col width16px">원</div>
                                    </div>
                                </td>
                                <th class="th-sum">결제조건잔액</th>
                                <td>
                                    <div class="form-row inline-pd widthfix">
                                        <div class="col width120px">
                                            <input type="text" class="form-control text-right" readonly="readonly"
                                                   id="balance" name="balance" format="decimal"
                                                   value="${depositMap.balance}">
                                        </div>
                                        <div class="col width16px">원</div>
                                    </div>
                                </td>
                            </tr>
                            <c:if test="${not empty virtual && not empty virtual.virtual_account_no}">
                                <tr>
                                    <th class="th-sum">가상계좌번호</th>
                                    <td colspan="2">
                                        <input type="text" class="form-control" value="${virtual.virtual_account_no }" readonly="readonly">
                                    </td>
                                    <td>
                                        <div class="title-wrap"
                                             style="flex-direction: row; justify-content: space-evenly">
                                            <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
                                                <jsp:param name="pos" value="BOM_M"/>
                                            </jsp:include>
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
                            </c:if>
                            <c:if test="${(outDoc.machine_out_status_cd > 1) and (depositMap.plan_amt_used > 0)}">
                            <tr>
                                <th class="th-sum">관련서류</th>
                                <td colspan="3">
                                    <div class="form-row inline-pd widthfix process1">
                                        <input type="checkbox" id="used_car_doc_yn_check" name="used_car_doc_yn_check" value="Y"><label for="used_car_doc_yn_check">자동차등록원부</label>
                                        <input type="checkbox" id="used_move_doc_yn_check" name="used_move_doc_yn_check" value="Y"><label for="used_move_doc_yn_check">이전서류일체</label>
                                    </div>
                                </td>
                            </tr>
                            </c:if>
                            </tbody>
                        </table>


                    </div>
                    <!-- /결제조건 -->
                    <!-- 출하사항 -->
                    <div class="title-wrap mt10">
                        <h4>출하사항</h4>
                        <div>
                        	<%-- <c:if test="${not empty outDoc.machine_out_status_cd && outDoc.machine_out_status_cd ne '3' and page.add.ACNT_MNG_YN eq 'Y'}">
                        		<button type="button" class="btn btn-info" onclick="javascript:goRequestPreMachine()">차대선지정요청</button>
                        	</c:if> --%>
                        	<c:if test="${not empty outDoc.machine_out_status_cd && outDoc.machine_out_status_cd ne '0'}">
                            	<button type="button" class="btn btn-default" onclick="javascript:goDocumentPopup()">서류발송</button>
                            </c:if>
                            <c:if test="${not empty outDoc.machine_out_status_cd and '' ne outDoc.machine_out_status_cd}">
	                            <c:choose>

		                            	<c:when test="${not empty outDoc.taxbill_no}">
                                    <%-- q&a 20388 - 발행 계산서 확인 기능 필요 --%>
		                            		<button type="button" class="btn btn-default" onclick="javascript:goTaxbillReportOpen('${outDoc.taxbill_no}')">계산서확인</button>
		                            		<button type="button" class="btn btn-default" onclick="javascript:goTaxbillCancel('${outDoc.taxbill_no}')">계산서취소</button>
		                            	</c:when>
		                            	<c:otherwise>
		                            		<button type="button" class="btn btn-default" onclick="javascript:goBillCheckPopup()">계산서가발행</button>
		                            	</c:otherwise>

	                            </c:choose>
                            </c:if>
                        </div>
                    </div>
                    <table class="table-border mt5 process2">
                        <colgroup>
                            <col width="15%">
                            <col width="40%">
                            <col width="15%">
                            <col width="30%">
                        </colgroup>
                        <tbody>
                        <tr>
                            <th class="text-right p2s">차대번호</th>
                            <td colspan="3">
                                <div class="input-group">
                                    <input type="text" class="form-control border-right-0" readonly="readonly" id="body_no" name="body_no" alt="차대번호" value="${outDoc.body_no}">
                                    <button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goMachineToOut('fnSetMachineToOut');"><i class="material-iconssearch"></i></button>
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <th class="text-right">엔진모델1</th>
                            <td>
                                <input type="text" class="form-control" id="engine_model_1" name="engine_model_1" alt="엔진모델1" value="${outDoc.engine_model_1}" readonly="readonly">
                            </td>
                            <th class="text-right">엔진번호1</th>
                            <td>
                                <input type="text" class="form-control" id="engine_no_1" name="engine_no_1" alt="엔진번호1" value="${outDoc.engine_no_1}" readonly="readonly">
                            </td>
                        </tr>
                        <tr>
<%--                            2023-04-10 황빛찬 : 엔진모델2, 엔진번호2 erp,직원앱 둘다 삭제 (04.설계 > 기획 > 직원앱 - tablet_직원용_06 서비스_v0.4.pptx - 11p)--%>
<%--                            <th class="text-right">엔진모델2</th>--%>
<%--                            <td>--%>
<%--                                <input type="text" class="form-control" id="engine_model_2" name="engine_model_2" alt="엔진모델2" value="${outDoc.engine_model_2}" readonly="readonly">--%>
<%--                            </td>--%>
<%--                            <th class="text-right">엔진번호2</th>--%>
<%--                            <td>--%>
<%--                                <input type="text" class="form-control" id="engine_no_2" name="engine_no_2" alt="엔진번호2" value="${outDoc.engine_no_2}" readonly="readonly">--%>
<%--                            </td>--%>
                        </tr>
                        <tr>
                            <th class="text-right">옵션모델1</th>
                            <td>
                                <input type="text" class="form-control" id="opt_model_1" name="opt_model_1" alt="옵션모델1" value="${outDoc.opt_model_1}" readonly="readonly">
                            </td>
                            <th class="text-right">옵션번호1</th>
                            <td>
                                <input type="text" class="form-control" id="opt_no_1" name="opt_no_1" alt="옵션번호1" value="${outDoc.opt_no_1}" readonly="readonly">
                            </td>
                        </tr>
                        <tr>
                            <th class="text-right">옵션모델2</th>
                            <td>
                                <input type="text" class="form-control" id="opt_model_2" name="opt_model_2" alt="옵션모델2" value="${outDoc.opt_model_2}" readonly="readonly">
                            </td>
                            <th class="text-right">옵션번호2</th>
                            <td>
                                <input type="text" class="form-control" id="opt_no_2" name="opt_no_2" alt="옵션번호2" value="${outDoc.opt_no_2}" readonly="readonly">
                            </td>
                        </tr>
                        <tr>
                            <th class="text-right p2s">출고일자</th>
                            <td>
                                <div class="input-group width120px">
                                    <input type="text" class="form-control border-right-0 calDate p2b" id="out_dt" name="out_dt" alt="출고일자" value="${outDoc.out_dt}" dateFormat="yyyy-MM-dd">
                                </div>
                            </td>
                            <th class="text-right p2s">운송사</th>
                            <td>
                                <select class="form-control p2b" id="transport_cmp_cd" name="transport_cmp_cd" alt="운송사" onchange="javascript:fnTransportChange(this.value)">
                                	<option value="">- 선택 -</option>
                                    <c:forEach var="item" items="${codeMap['TRANSPORT_CMP']}">
                                        <option value="${item.code_value}"
                                        	<c:if test="${outDoc.transport_cmp_cd == item.code_value}">selected="selected"</c:if>>${item.code_name}
                                        </option>
                                    </c:forEach>
                                </select>
                            </td>
                        </tr>
                        <tr>
                            <th class="text-right">판매구분</th>
                            <td>
                                <div class="form-check form-check-inline">
                                    <input class="form-check-input" type="radio" id="sale_type_sr_s" name="sale_type_sr" value="S" <c:if test="${(empty outDoc.sale_type_sr) or (outDoc.sale_type_sr eq 'S')}">checked="checked"</c:if>>
                                    <label for="sale_type_sr_s" class="form-check-label">판매</label>
                                </div>
                                <div class="form-check form-check-inline">
                                    <input class="form-check-input" type="radio" id="sale_type_sr_r" name="sale_type_sr" value="R" <c:if test="${outDoc.sale_type_sr eq 'R'}">checked="checked"</c:if>>
                                    <label for="sale_type_sr_r" class="form-check-label">렌탈</label>
                                </div>
                            </td>
                            <th class="text-right p2s">운송사<br/>연락처</th>
                            <td>
                                <input type="text" class="form-control width120px p2b" id="transport_tel_no" name="transport_tel_no" alt="운송사 연락처" value="${outDoc.transport_tel_no}" maxlength="14" format="tel">
                            </td>
                        </tr>
                        <tr>
                            <th class="text-right p2s">출발일자</th>
                            <td>
                                <div class="input-group width120px">
                                    <input type="text" class="form-control border-right-0 calDate p2b" id="arrival_dt" name="arrival_dt" value="${outDoc.arrival_dt}" dateFormat="yyyy-MM-dd" alt="출발일자">
                                </div>
                            </td>
                            <th class="text-right p2s">출발시간</th>
                            <td>
                                <div class="form-row inline-pd">
                                   <div class="col-4" style="min-width: 60px">
                                       <select class="form-control p2b" id="arrival_ti_1" name="arrival_ti_1">
                                           <option value="00">00</option>
                                           <c:forEach var="ti" varStatus="i" begin="1" end="23" step="1">
                                               <option value="<c:if test="${ti < 10}">0</c:if><c:out value="${ti}" />"
                                                       <c:if test="${not empty outDoc.arrival_ti and ti == fn:substring(outDoc.arrival_ti,0,2)}">selected="selected"</c:if>>
                                                   <c:if test="${ti < 10}">0</c:if><c:out value="${ti}"/>
                                               </option>
                                           </c:forEach>
                                       </select>
                                   </div>
                                   <div class="col-1">
                                       	시
                                   </div>
                                   <div class="col-4" style="padding-left: 5px; min-width: 60px">
                                       <select class="form-control p2b" id="arrival_ti_2" name="arrival_ti_2">
                                           <option value="00">00</option>
                                           <c:forEach var="ti" varStatus="i" begin="1" end="59" step="1">
                                               <option value="<c:if test="${ti < 10}">0</c:if><c:out value="${ti}" />"
                                                       <c:if test="${not empty outDoc.arrival_ti and ti == fn:substring(outDoc.arrival_ti,2,4)}">selected="selected"</c:if>>
                                                   <c:if test="${ti < 10}">0</c:if><c:out value="${ti}"/>
                                               </option>
                                           </c:forEach>
                                       </select>
                                   </div>
                                   <div class="col-1">
                                       	분
                                   </div>
                               </div>
                            </td>
                        </tr>
                        <tr>
<%--                            2023-04-04 황빛찬 : 출고유형 erp,직원앱 둘다 삭제 (04.설계 > 기획 > 직원앱 - tablet_직원용_04 영업_v0.8pptx)--%>
<%--                            <th class="text-right p2s">출고유형</th>--%>
<%--                            <td>--%>
<%--                                <select class="form-control p2b" id="out_type_cd" name="out_type_cd" alt="출고유형">--%>
<%--                                    <option value="">- 선택 -</option>--%>
<%--                                    <c:forEach var="item" items="${codeMap['OUT_TYPE']}">--%>
<%--                                        <option value="${item.code_value}"--%>
<%--                                        	<c:if test="${(empty outDoc.out_type_cd and item.code_value eq '01') or (outDoc.out_type_cd == item.code_value)}">selected="selected"</c:if>>${item.code_name}--%>
<%--                                        </option>--%>
<%--                                    </c:forEach>--%>
<%--                                </select>--%>
<%--                            </td>--%>
<%--                            2023-04-10 황빛찬 : 렌탈대리점 erp,직원앱 둘다 삭제 (04.설계 > 기획 > 직원앱 - tablet_직원용_06 서비스_v0.4.pptx - 11p)--%>
<%--                            <th class="text-right">렌탈대리점</th>--%>
<%--                            <td>--%>
<%--                                <div class="input-group">--%>
<%--                                    <input type="text" class="form-control border-right-0" readonly="readonly" id="rental_org_name" name="rental_org_name" alt="렌탈대리점" value="${outDoc.rental_org_name }">--%>
<%--                                    <input type="hidden" id="rental_org_code" name="rental_org_code" value="${outDoc.rental_org_code }">--%>
<%--                                    <button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openOrgMapPanel('fnSetRentalOrgCd');"><i--%>
<%--                                            class="material-iconssearch"></i></button>--%>
<%--                                </div>--%>
<%--                            </td>--%>
                        </tr>
                        <tr>
                            <th class="text-right p2s">도착지</th>
                            <td colspan="3">
                                <div class="form-row inline-pd">
                                    <div class="col">
                                        <input type="text" class="form-control p2b" id="arrival_area_name" name="arrival_area_name" value="${outDoc.arrival_area_name}" alt="도착지" maxlength="50">
                                    </div>
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <th class="text-right">총운임</th>
                            <td>
                                <div class="form-row inline-pd widthfix">
                                    <div class="col width120px">
                                        <input type="text" class="form-control text-right" id="transport_amt" name="transport_amt" value="${outDoc.transport_amt }" alt="총운임" format="decimal">
                                    </div>
                                    <div class="col width16px">원</div>
                                </div>
                            </td>
                            <%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체 --%>
                            <%--<th class="text-right">대리점운임</th>--%>
                            <th class="text-right">위탁판매점운임</th>
                            <td>
                                <div class="form-row inline-pd widthfix">
                                    <div class="col width120px">
                                        <input type="text" class="form-control text-right" id="agency_transport_amt" name="agency_transport_amt" value="${outDoc.agency_transport_amt }" alt="위탁판매점운임" format="decimal">
                                    </div>
                                    <div class="col width16px">원</div>
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <th class="text-right p1s">센터DI<br>마일리지<br>적립</th>
                            <td>
                                <div class="form-check form-check-inline">
                                    <input class="form-check-input" type="checkbox" id="di_coupon_yn_check" name="di_coupon_yn_check" value="Y"
                                    <c:if test="${outDoc.di_coupon_yn == 'Y'}">checked="checked"</c:if>>
                                    <label class="form-check-label" for="di_coupon_yn_check">마일리지적립</label>
                                </div>
                            </td>
                            <th class="text-right">세금계산서</th>

                            <td>
                            <c:if test="${not empty outDoc.taxbill_no }">
                            	${outDoc.taxbill_no }-${outDoc.taxbill_control_no }
                            </c:if>
                            </td>
                        </tr>
                        <tr>
<%--                            <th class="text-right p2s">판매일자</th>--%>
<%--                            <td>--%>
<%--                                <div class="input-group width120px">--%>
<%--                                    <input type="text" class="form-control border-right-0 calDate p2b" id="sale_dt" name="sale_dt" value="${outDoc.sale_dt}" dateFormat="yyyy-MM-dd" alt="판매일자">--%>
<%--                                </div>--%>
<%--                            </td>--%>
<%--                            <th class="text-right"></th>--%>

<%--                            <td>--%>
<%--                            </td>--%>
                            <th class="text-right">출하담당</th>
                            <td>
                                <input type="text" class="form-control width100px" readonly="readonly" value="${outDoc.out_mem_name}">
                            </td>
                            <th class="text-right">확인일자</th>
                            <td>
                                <input type="text" class="form-control width120px" readonly="readonly" id="out_proc_date" name="out_proc_date" value="${outDoc.out_proc_date}" dateformat="yyyy-MM-dd">
                            </td>
                        </tr>
                        </tbody>
                    </table>
                    <!-- /출하사항 -->
                    <!-- 출하담당 -->
                    <table class="table-border mt10">
                        <colgroup>
                            <col width="20%">
                            <col width="30%">
                            <col width="20%">
                            <col width="30%">
                        </colgroup>
                        <tbody>
<%--                        <tr>--%>
<%--                            <th class="text-right">출하담당</th>--%>
<%--                            <td>--%>
<%--                                <input type="text" class="form-control width100px" readonly="readonly" value="${outDoc.out_mem_name}">--%>
<%--                            </td>--%>
<%--                            <th class="text-right">확인일자</th>--%>
<%--                            <td>--%>
<%--                                <input type="text" class="form-control width120px" readonly="readonly" id="out_proc_date" name="out_proc_date" value="${outDoc.out_proc_date}" dateformat="yyyy-MM-dd">--%>
<%--                            </td>--%>
<%--                        </tr>--%>
                        <c:if test="${not empty inout}">
                        	<c:forEach items="${inout}" var="outer" varStatus="outerStatus">
                        		<tr>
                        			<c:forEach items="${outer}" var="inner" varStatus="innerStatus">
                        				<th class="text-right">
                        					<c:choose>
                        						<c:when test="${not empty inner.inout_doc_type_cd and inner.inout_doc_type_cd eq '22'}">
                        							장비전표
                        						</c:when>
                        						<c:otherwise>
                        							부품전표
                        						</c:otherwise>
                        					</c:choose>
		                        		</th>
		                        		<td>
			                                <div class="form-row inline-pd">
			                                    <div class="col-9">
			                                        <input type="text" class="form-control" readonly="readonly" value="${inner.inout_doc_no }">
			                                    </div>
			                                    <div class="col-3">
			                                    	<c:choose>
			                                    		<c:when test="${not empty inner.inout_doc_type_cd and inner.inout_doc_type_cd eq '22'}">
			                                    			<button type="button" class="btn btn-primary-gra" onclick="javascript:goInoutDetail('${inner.inout_doc_no }', 'M')">상세</button>
			                                    		</c:when>
			                                    		<c:otherwise>
			                                    			<c:choose>
			                                    				<c:when test="${not empty inner.inout_doc_no}">
			                                    					<button type="button" class="btn btn-primary-gra" onclick="javascript:goInoutDetail('${inner.inout_doc_no}')">상세</button>
			                                    				</c:when>
			                                    				<c:when test="${not empty inner.doc_type}">
			                                    					<button type="button" class="btn btn-primary-gra" onclick="javascript:goInoutIssue('${inner.doc_type}')">발행</button>
			                                    				</c:when>
			                                    				<c:otherwise>
			                                    					<button type="button" class="btn btn-primary-gra" disabled="disabled">상세</button>
			                                    				</c:otherwise>
			                                    			</c:choose>
			                                    		</c:otherwise>
			                                    	</c:choose>
			                                    </div>
			                                </div>
			                            </td>
                        			</c:forEach>
	                        	</tr>
                        	</c:forEach>
                        </c:if>
                        </tbody>
                    </table>
                    <!-- /출하담당 -->
                    <!-- 고객요청사항 -->
                    <div>
                        <div class="title-wrap mt10">
                            <h4>고객요청사항</h4>
                        </div>
                        <textarea class="form-control mt5 process2" style="height: 125px;" id="cust_req_text" name="cust_req_text" disabled="disabled">${outDoc.cust_req_text}</textarea>
                    </div>
                    <!-- /출하 고객요청사항 -->
                    <!-- 출하 특이사항 -->
                    <div>
                        <div class="title-wrap mt10">
                            <h4>출하 특이사항</h4>
                        </div>
                        <textarea class="form-control mt5 process2" style="height: 170px;" id="out_remark" name="out_remark" disabled="disabled" maxlength="48">${outDoc.out_remark}</textarea>
                    </div>
                    
                  
                    <!-- /출하 특이사항 -->
                    <c:if test="${not empty submitList and outDoc.machine_out_status_cd eq '3'}">
						<div id="submitList">
							<div class="title-wrap mt10">
								<h4>제출서류</h4>
								<div>
									<span class="text-warning" tooltip="">※ [서류저장] 버튼을 눌러야 첨부파일이 저장됩니다.</span>
									<button type="button" class="btn btn-info" onclick="javascript:goSaveSubmit()">서류저장</button>
									<c:if test="${page.add.ACNT_MNG_YN eq 'Y' or page.fnc.F00111_001 eq 'Y'}">
										<button type="button" class="btn btn-info" onclick="javascript:goConfirmSubmit()">서류확인</button>
									</c:if>
								</div>
							</div>
							<table class="table-border doc-table mt5">
								<colgroup>
									<col width="30%">
									<col width="">
									<col width="30%">
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
                                        <tr>
                                            <th>${item.code_name }</th>
                                            <td>
                                                <div class="table-attfile submit_${item.mch_sale_doc_file_cd}_div">
                                                    <c:if test="${not empty item.origin_file_name }">
                                                        <div class="table-attfile-item submit_${item.mch_sale_doc_file_cd}">
                                                            <c:if test="${fn:endsWith(item.origin_file_name, 'pdf') eq true}">
                                                            </c:if>
                                                            <c:if test="${fn:endsWith(item.origin_file_name, 'pdf') eq true}">
                                                                <a href="javascript:fileDownload(${item.file_seq})">${item.origin_file_name }</a>
                                                            </c:if>
                                                            <c:if test="${fn:endsWith(item.origin_file_name, 'pdf') eq false}">
                                                                <a href="javascript:fnLayerImage(${item.file_seq})">${item.origin_file_name }</a>
                                                            </c:if>
                                                            <input type="hidden" name="file_seq_${item.mch_sale_doc_file_cd}" value="${item.file_seq }">
                                                            <c:if test="${item.pass_ypn ne 'Y'}">
                                                                <button type="button" class="btn-default" onclick="javascript:fnRemoveFile('${item.mch_sale_doc_file_cd}')"><i class="material-iconsclose font-18 text-default"></i></button>
                                                            </c:if>
                                                        </div>
                                                    </c:if>
                                                    <c:if test="${empty item.origin_file_name }">
                                                        <button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goFileUploadPopup('${item.mch_sale_doc_file_cd}')" id="btn_submit_${item.mch_sale_doc_file_cd}">파일찾기</button>
                                                    </c:if>
                                                </div>
                                            </td>
                                            <td>
                                                <c:if test="${item.code_v2 eq '11'}">
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
                                                </c:if>
                                            </td>
                                        </tr>
                                        <c:if test="${item.mch_sale_doc_file_cd eq '10' and page.fnc.F00111_004 eq 'Y'}">
                                            <tr>
                                                <th>출하사진</th>
                                                <td colspan="6" style="border-right: white;">
                                                    <div class="table-attfile att_file_div" style="width:100%;">
                                                    <c:forEach var="diItem" items="${diFileList}">
                                                        <div class="table-attfile">
                                                            <c:if test="${not empty diItem.origin_file_name }">
                                                                <div class="table-attfile-item">
                                                                    <c:if test="${fn:endsWith(diItem.origin_file_name, 'pdf') eq true}">
                                                                        <a href="javascript:fileDownload(${diItem.file_seq})">${diItem.origin_file_name }</a>
                                                                    </c:if>
                                                                    <c:if test="${fn:endsWith(diItem.origin_file_name, 'pdf') eq false}">
                                                                        <a href="javascript:fnLayerImage(${diItem.file_seq})">${diItem.origin_file_name }</a>
                                                                    </c:if>
                                                                </div>
                                                            </c:if>
                                                        </div>
                                                    </c:forEach>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
												<th>인도점검</th>
												<td colspan="2">
													<div class="row">
														<div class="col-4">
															<div class="input-group">
																<input type="text" class="form-control border-right-0 calDate" id="handover_dt" name="handover_dt" dateformat="yyyy-MM-dd" value="${outDoc.handover_dt}" style="max-width: 120px!important;" placeholder="인도점검일" alt="인도점검일" <c:if test="${page.add.ACNT_MNG_YN ne 'Y'}">disabled="disabled"</c:if>>
															</div>
														</div>
														<div class="col-4">
														    <input type="hidden" class="form-control" id="handover_mem_no" name="handover_mem_no" readonly="readonly" value="${outDoc.handover_mem_no}">
															<div class="input-group">
																<input type="text" class="form-control border-right-0" id="handover_mem_name" name="handover_mem_name" readonly="readonly" value="${outDoc.handover_mem_name }" style="background: white" size="20" maxlength="20" placeholder="점검자" alt="인도점검자" <c:if test="${page.add.ACNT_MNG_YN ne 'Y'}">disabled="disabled"</c:if>>
																<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchMemberPanel('setHandoverMemNo');" <c:if test="${page.add.ACNT_MNG_YN ne 'Y'}">disabled="disabled"</c:if>><i class="material-iconssearch"></i></button>
															</div>
														</div>
														<div class="col-4">
														    <input type="text" class="form-control" id="handover_remark" name="handover_remark" size="20" maxlength="20" alt="인도점검비고" placeholder="비고" value="${outDoc.handover_remark}" <c:if test="${page.add.ACNT_MNG_YN ne 'Y'}">disabled="disabled"</c:if>>
														</div>
													</div>
												</td>
											</tr>
										</c:if>
									</c:forEach>
                  <tr>
                      <th>장비인수증</th>
                      <td colspan="2">
                          <div class="form-row inline-pd widthfix">
                              <div class="col-auto">
                                  <%-- q&a 22990 - 출하의뢰서에서도 장비인수증 파일 업로드 가능하게 변경 --%>
                                  <%-- 파일 업로드 버튼 --%>
                                  <div style="display: flex">
                                      <c:if test="${modusignFileYn eq 'N'}">
                                        <c:if test="${empty mch_sale_doc_12_file_seq or mch_sale_doc_12_file_seq eq '0'}">
                                          <div class="table-attfile submit_12_div">
                                            <button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goFileUploadPopup('12')" id="btn_submit_12">파일찾기</button>
                                          </div>
                                        </c:if>
                                        
                                        <%-- 업로드로 만들어진 파일 --%>
                                        <a href="javascript:fileDownload('${mch_sale_doc_12_file_seq}');" style="margin-right: 5px; color: blue; vertical-align: middle;" id="_12_file_name">${mch_sale_doc_12_file_name}</a>
                                      </c:if>
                                    
                                      <%-- 모두싸인으로 만들어진 파일 --%>
                                      <c:if test="${modusignFileYn ne 'N'}">
                                          <a href="javascript:fileDownload('${modusignMap.file_seq}');" style="color: blue; vertical-align: middle;" id="_file_name">${modusignMap.file_name}</a>
                                      </c:if>
                                      
                                      <%-- 모두싸인 발송 버튼 --%>
                                      <button type="button" class="btn btn-primary-gra mr5"  onclick="javascript:sendModusignPanel()" id="_sendModusignPanel" <c:if test="${!(empty outDoc.out_modusign_id and page.add.MODUSIGN_YN eq 'Y')}">style="display:none;"</c:if>>발송</button>
                                  </div>
                                
                                  <%-- 모두싸인 요청 중 --%>
                                  <c:if test="${not empty outDoc.out_modusign_id and page.add.MODUSIGN_YN eq 'Y' and modusignMap.sign_proc_yn eq 'Y'}">
                                      <button type="button" class="btn btn-primary-gra"  onclick="javascript:void();" disabled>${modusignMap.modusign_status_label}</button>
                                      <button type="button" class="btn btn-primary-gra ml5" onclick="javascript:sendModusignCancel()">싸인취소</button>
                                  </c:if>
                                
                                  <%-- 모두싸인 완료 --%>
                                  <c:if test="${modusignMap.file_seq ne 0}">
                                      <input type="hidden" name="file_seq_12" value="${mch_sale_doc_12_file_seq }">
                                      <c:if test="${page.add.MODUSIGN_YN eq 'Y' and modusignMap.modu_modify_yn eq 'N'}">
                                          <button type="button" class="btn btn-primary-gra ml5" onclick="javascript:fnModusignModify()" id="_fnModusignModify">수정</button>
                                      </c:if>
                                  </c:if>
                              </div>
                              <c:if test="${modusignMap.modu_modify_yn eq 'Y'}">
                                  <div class="col-auto">(수정중)</div>
                              </c:if>
                          </div>
                      </td>
                  </tr>
                                    
								</tbody>
							</table>
						</div>
						<span class="text-warning" tooltip="">※ 기타서류는 원본을 서비스 지원부서(평택센터) <b>최승희 대리</b>에게 발송해 주시기 바랍니다!</span>
					</c:if>
                </div>
                <!-- 우측 폼테이블-->
            </div>
            <!-- /폼테이블 -->
            <!-- 그리드 서머리, 컨트롤 영역 -->
            <div class="btn-group mt5">
                <div class="right">
                	<!-- <button type="button" class="btn btn-info" onclick="javascript:goSave();">저장</button>
                	<button type="button" class="btn btn-info" onclick="javascript:goOut()">출하처리</button>
					<button type="button" class="btn btn-info" onclick="javascript:goHold()">출하보류</button>
                	<button type="button" class="btn btn-info" onclick="javascript:goHoldCancel()">출하보류 취소</button>
                	<button type="button" class="btn btn-info" onclick="javascript:goOutCancel()">출하취소</button>
                	<button type="button" class="btn btn-info" onclick="javascript:goOutReject()">출하반려</button>
                	<button type="button" class="btn btn-info" onclick="javascript:goRequestOut();">출하처리요청</button>
                	<button type="button" class="btn btn-info" onclick="javascript:goChangeOutInfo();">출하사항변경</button> -->
                    <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
                        <jsp:param name="pos" value="BOM_R"/>
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
