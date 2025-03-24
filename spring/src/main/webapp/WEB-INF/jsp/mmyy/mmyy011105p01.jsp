<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 경조금 지급 신청서 > null > 경조금 지급 신청서 상세
-- 작성자 : 황빛찬
-- 최초 작성일 : 2021-05-10 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
	// 경조구분
	var docMoneyTypeJson = JSON.parse('${codeMapJsonObj['DOC_MONEY_TYPE']}');
	
	// 첨부파일의 index 변수
	var fileIndex = 1;
	// 첨부할 수 있는 파일의 개수
	var fileMaxCount = 5;
	
	$(document).ready(function() {
		<c:forEach var="list" items="${doc_file}">setFileInfo('${list.file_seq}', '${list.file_name}');</c:forEach>
		
		// 결재상태에 따라 수정가능 제어
	    if (!(($M.getValue("appr_proc_status_cd") == 01 && $M.getValue("mem_no") == '${inputParam.login_mem_no}') 
	          || ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F02020_001}' == 'Y'))
	    ) {
			$("#main_form :input").prop("disabled", true);
			$("#main_form :button[onclick='javascript:fnPrint();']").prop("disabled", false);
			$("#main_form :button[onclick='javascript:fnClose();']").prop("disabled", false);
			$("#main_form :button[onclick='javascript:goApproval();']").prop("disabled", false);
			$("#main_form :button[onclick='javascript:goApprCancel();']").prop("disabled", false);
		}
		
		if ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F02020_001}' == 'Y') {
			$("#_fnPrint").show();
		} else {
			$("#_fnPrint").hide();
		}
		
		// 경조금액 수정 제어
		fnMoneyAmtControl();
	});
	
	// 첨부파일
	function goSearchFile(){
		if($("input[class='doc_file_list']").size() >= fileMaxCount) {
			alert("파일은 " + fileMaxCount + "개만 첨부하실 수 있습니다.");
			return false;
		}
		
        var param = {
            upload_type: 'DOC',
            file_type: 'both',
        };
        
		openFileUploadPanel('fnPrintFileInfo', $M.toGetParam(param));
	}
	
	function fnPrintFileInfo(result) {
		setFileInfo(result.file_seq, result.file_name)
	}
	
	//첨부파일 세팅
	function setFileInfo(fileSeq, fileName) {
		var str = ''; 
		str += '<div class="table-attfile-item doc_file_' + fileIndex + '" style="float:left; display:block;">';
		str += '<a href="javascript:fileDownload(' + fileSeq + ');" style="color: blue;" id="file_name_seq_' + fileIndex +'" >' + fileName + '</a>&nbsp;';
		str += '<input type="hidden" class="doc_file_list" name="doc_file_seq_'+ fileIndex + '" value="' + fileSeq + '"/>';
		str += '<button type="button" class="btn-default" onclick="javascript:fnRemoveFile(' + fileIndex + ', ' + fileSeq + ')"><i class="material-iconsclose font-18 text-default"></i></button>';
		str += '</div>';
		$('.doc_file_div').append(str);
		fileIndex++;
	}
	
	// 첨부파일 삭제
	function fnRemoveFile(fileIndex, fileSeq) { 
		var result = confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.");
		if (result) {
			$(".doc_file_" + fileIndex).remove();
			$("#doc_file_seq_" + fileIndex).remove();
		} else {
			return false;
		}
	}
	
	function fnClose() {
		window.close();
	}
	
	// 인쇄
	function fnPrint() {
		
		var apprMemoListJson = JSON.parse('${apprMemoListJson}');
		var apprList = [];
		if (apprMemoListJson.length > 0) {
			apprMemoListJson[0].grade_name = "작성자";
		
			// 결재 요청자
			var regMemInfo = {};
			regMemInfo.grade_name = apprMemoListJson[0].grade_name;
			regMemInfo.appr_status_name = apprMemoListJson[0].appr_status_name;
			regMemInfo.proc_date = apprMemoListJson[0].proc_date;
			regMemInfo.appr_mem_name = apprMemoListJson[0].appr_mem_name;
			apprList.push(regMemInfo);
			
			// 결재 처리자
			var procMemInfo = {};
			procMemInfo.grade_name = apprMemoListJson[apprMemoListJson.length-1].grade_name;
			procMemInfo.appr_status_name = apprMemoListJson[apprMemoListJson.length-1].appr_status_name;
			procMemInfo.proc_date = apprMemoListJson[apprMemoListJson.length-1].proc_date;
			procMemInfo.appr_mem_name = apprMemoListJson[apprMemoListJson.length-1].appr_mem_name;
			apprList.push(procMemInfo);
		}
		
		var fileName = "";
		
		for (var i = 1; i <= fileMaxCount; i++) {
			fileName += $("#file_name_seq_"+i).text() + " ";
		}
		
		var data = {
			"mem_name" : $M.getValue("apply_mem_name")
			, "grade_name" : $M.getValue("grade_name")
			, "org_name" : $M.getValue("org_name")
			, "doc_dt" : $M.getValue("doc_dt")
			, "ipsa_dt" : $M.getValue("ipsa_dt")
			, "money_amt" : $M.getValue("money_amt")
			, "doc_money_content" : $("#doc_money_man_type_cd option:selected").text() + " " + $("#doc_money_type_cd option:selected").text()
			, "money_dt" : $M.getValue("money_dt")
			, "file_name" : fileName
		};
		
		var param = {
			"data" : data
			, "apprData" : apprList
		}
		
		openReportPanel('mmyy/mmyy011105p01_01.crf', param);
	}
	
	// 경조구분 변경시
	function fnDocMoneyTypeSet(data) {
		var docMoneyTypeCd = data;
		$M.setValue("money_amt", 0);
		
		// 경조금액 수정 제어
		fnMoneyAmtControl();
		
		if (docMoneyTypeCd != "") {
			var param = {
				"doc_money_type_cd" : docMoneyTypeCd
			};
			
			$M.goNextPageAjax("/mmyy/mmyy01110501/search/money/def", $M.toGetParam(param) , {method : 'GET'},
				function(result) {
		    		if(result.success) {
		    			var list = result.list; // 경조대상 리스트
		    			$("#doc_money_man_type_cd option").remove();
		    			
		    			$("#doc_money_man_type_cd").append(new Option('- 선택 -', ""));
		    			
		    			for (item in list) {
		    				$("#doc_money_man_type_cd").append(new Option(list[item].doc_money_man_type_name, list[item].doc_money_man_type_cd));
		    			}
					}
				}
			);
		} else {
			// 경조구분이 선택일경우
			$("#doc_money_man_type_cd option").remove();
			$("#doc_money_man_type_cd").append(new Option('- 선택 -', ""));
		}
	}
	
	// 경조구분의 code_v2값 (Y : 수정가능) 에 따라 경조금액 수정 제어
	function fnMoneyAmtControl() {
		var editAmtYn = false;
		
		for (var i = 0; i < docMoneyTypeJson.length; i++) {
			if (docMoneyTypeJson[i].code_value == $M.getValue("doc_money_type_cd")) {
				if (docMoneyTypeJson[i].code_v2 == "Y") {
					editAmtYn = true;
				}
			}
		}
		
		if (editAmtYn) {
			$("#money_amt").removeAttr("readonly");
		} else {
			$("#money_amt").attr("readonly", true);
		}
	}
	
	// 경조대상 변경시
	function fnGetMoneyAmt(data) {
		var docMoneyManTypeCd = data;
		var ipsaDt = $M.getValue("ipsa_dt");
		$M.setValue("money_amt", 0);
		
		// 경조금액 수정 제어
		fnMoneyAmtControl();
		
		var param = {
				"doc_money_type_cd" : $M.getValue("doc_money_type_cd"),
				"doc_money_man_type_cd" : docMoneyManTypeCd,
				"ipsa_dt" : $M.getValue("ipsa_dt")
		}
		
		if (docMoneyManTypeCd != "") {
			$M.goNextPageAjax("/mmyy/mmyy01110501/get/money/amt", $M.toGetParam(param) , {method : 'GET'},
				function(result) {
		    		if(result.success) {
		    			console.log("result : ", result);
		    			$M.setValue("money_amt", result.money_amt);
					}
				}
			);			
		}
	}
	
	// 결재취소
	function goApprCancel() {
		var param = {
			appr_job_seq: "${apprBean.appr_job_seq}",
			seq_no: "${apprBean.seq_no}",
			appr_cancel_yn: "Y"
		};
		openApprPanel("goApprovalResultCancel", $M.toGetParam(param));
	}
	
	function goApprovalResultCancel(result) {
		$M.goNextPageAjax('/session/check', '', {method: 'GET'},
			function (result) {
				if (result.success) {
					alert("결재취소가 완료됐습니다.");
					location.reload();
				}
			}
		);
	}
	
	// 결재처리
	function goApproval() {
		var param = {
			appr_job_seq: "${apprBean.appr_job_seq}",
			seq_no: "${apprBean.seq_no}"
		};
		$M.setValue("save_mode", "approval"); // 승인
		openApprPanel("goApprovalResult", $M.toGetParam(param));
	}
	
	// 결재처리 결과
	function goApprovalResult(result) {
		// 반려이면 페이지 리로딩
		if (result.appr_status_cd == '03') {
			$M.goNextPageAjax('/session/check', '', {method: 'GET'},
				function (result) {
					if (result.success) {
						alert("반려가 완료되었습니다.");
						location.reload();
					}
				}
			);
		} else if (result.appr_status_cd == '05') {
            $M.goNextPageAjax('/session/check', '', {method: 'GET'},
                function (result) {
                    if (result.success) {
                        alert("종결처리가 완료되었습니다.");
                        location.reload();
                    }
                }
            );
        } else {
			$M.goNextPageAjax('/session/check', '', {method: 'GET'},
				function (result) {
					if (result.success) {
						alert("처리가 완료되었습니다.");
						location.reload();
					}
				}
			);
		}
	}
	
	// 결재요청
	function goRequestApproval() {
		goModify('requestAppr');
	}

    // 종결처리
    function goApprovalEnd() {
        var param = {
            appr_job_seq : "${apprBean.appr_job_seq}",
            seq_no : "${apprBean.seq_no}",
            appr_end_only : 'Y',
        };
        openApprPanel("goApprovalResult", $M.toGetParam(param));
    }
	
	// 수정
	function goModify(isRequestAppr) {
		// validationcheck
		if($M.validation(document.main_form) == false) {
			return;
		};
		
		if ($M.getValue("money_amt") == 0) {
			alert("경조금액을 입력해 주세요.");
			$("#money_amt").focus();
			return;
		}

		var idx = 1;
		$("input[class='doc_file_list']").each(function() {
			var str = 'doc_file_seq_' + idx;
			$M.setValue(str, $(this).val());
			idx++;
		});
		
		for(; idx <= fileMaxCount; idx++) {
			$M.setValue('doc_file_seq_' + idx, 0);
		}

		var msg = "";
		if (isRequestAppr != undefined) {
			// 결재요청 Setting
			$M.setValue("save_mode", "appr");
			msg = "결재요청 하시겠습니까?";
		} else {
			$M.setValue("save_mode", "modify");
			msg = "수정 하시겠습니까?";
		}
		
		var frm = $M.toValueForm(document.main_form);

		$M.goNextPageAjaxMsg(msg, this_page + "/modify", frm, {method: "POST"},
			function (result) {
				if (result.success) {
					alert("처리가 완료되었습니다.");
					window.location.reload();
	    			if (opener != null && opener.goSearch) {
	    				opener.goSearch();
	    			}
				}
			}
		);
	}
	
	// 삭제
	function goRemove() {
		var frm = $M.toValueForm(document.main_form);
		
		$M.goNextPageAjaxRemove(this_page + "/remove", frm, {method: "POST"},
			function (result) {
				if (result.success) {
					alert("처리가 완료되었습니다.");
	    			fnClose();
	    			if (opener != null && opener.goSearch) {
	    				opener.goSearch();
	    			}
				}
			}
		);
	}		
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" id="ipsa_dt" name="ipsa_dt" value="${info.ipsa_dt}">
<input type="hidden" id="doc_no" name="doc_no" value="${info.doc_no}">
<input type="hidden" id="appr_proc_status_cd" name="appr_proc_status_cd" value="${info.appr_proc_status_cd}">
<input type="hidden" id="appr_job_seq" name="appr_job_seq" value="${info.appr_job_seq}" />
<input type="hidden" id="doc_type_cd" name="doc_type_cd" value="${info.doc_type_cd}" />
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
            <div class="text-right">
                <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
            </div>
<!-- 폼테이블 -->						
            <div class="title-wrap mt10">
                <div class="left approval-left">
                    <h4 class="primary">경조금지급신청상세</h4>		
                </div>
<!-- 결재영역 -->
                <div class="pl10">
                    <jsp:include page="/WEB-INF/jsp/common/apprHeader.jsp"></jsp:include>
                </div>
<!-- /결재영역 -->
            </div>								
<!-- 폼테이블 -->					
            <table class="table-border mt10">
                <colgroup>
                    <col width="100px">
                    <col width="">
                    <col width="100px">
                    <col width="">
                </colgroup>
                <tbody>
                    <tr>
                        <th class="text-right">작성자</th>
                        <td>
                            <input type="text" class="form-control width120px" readonly value="${info.mem_name}" id="mem_name" name="mem_name">
                            <input type="hidden" id="mem_no" name="mem_no" value="${info.mem_no}">
                        </td>		
                        <th class="text-right">작성일</th>
                        <td>
                            <input type="text" class="form-control width120px" readonly id="doc_dt" name="doc_dt" value="${info.doc_dt}" dateformat="yyyy-MM-dd">
                        </td>							
                    </tr>
                    <tr>
                        <th class="text-right">신청자</th>
                        <td colspan="3">
                            <input type="text" class="form-control width120px" readonly value="${info.apply_mem_name}" id="apply_mem_name" name="apply_mem_name">
                            <input type="hidden" class="form-control width120px" readonly id="apply_mem_no" name="apply_mem_no" value="${info.apply_mem_no}">
                        </td>	
                    </tr>                      
                    <tr>
                        <th class="text-right">부서</th>
                        <td>
                            <input type="text" class="form-control width120px" readonly value="${info.org_name}" id="org_name" name="org_name">
                            <input type="hidden" id="org_code" name="org_code" value="${info.org_code}">
                        </td>		
                        <th class="text-right">직위</th>
                        <td>
                            <input type="text" class="form-control width120px" readonly value="${info.grade_name}" id="grade_name" name="grade_name">
                            <input type="hidden" id="grade_cd" name="grade_cd" value="${info.grade_cd}">
                            <input type="hidden" id="job_cd" name="job_cd" value="${info.job_cd}">
                        </td>							
                    </tr>
                    <tr>
                        <th class="text-right essential-item">경조구분</th>
                        <td>
                            <select class="form-control width120px rb" id="doc_money_type_cd" name="doc_money_type_cd" required="required" alt="경조구분" onChange="javascript:fnDocMoneyTypeSet(this.value);">
								<option value="">- 선택 -</option>
								<c:forEach items="${codeMap['DOC_MONEY_TYPE']}" var="item">
									<option value="${item.code_value}" ${item.code_value == info.doc_money_type_cd ? 'selected' : ''}>${item.code_name}</option>
								</c:forEach>
                            </select>
                        </td>		
                        <th class="text-right essential-item">경조대상</th>
                        <td>
							<select class="form-control width120px rb" id="doc_money_man_type_cd" name="doc_money_man_type_cd" required="required" alt="경조대상" onChange="javascript:fnGetMoneyAmt(this.value);">
								<option value="">- 선택 -</option>
								<c:forEach items="${list}" var="item">
									<option value="${item.doc_money_man_type_cd}" ${item.doc_money_man_type_cd == info.doc_money_man_type_cd ? 'selected' : ''}>${item.doc_money_man_type_name}</option>
								</c:forEach>
							</select>
                        </td>	                        
                    </tr>
                    <tr>
                        <th class="text-right">경조일자</th>
                        <td>
                            <div class="input-group width120px">
								<input type="text" class="form-control border-right-0 rb width100px calDate" id="money_dt" name="money_dt" dateformat="yyyy-MM-dd" alt="경조일자" required="required" value="${info.money_dt}">
                            </div>
                        </td>						
                    <th class="text-right">경조금액</th>
                    <td>
                        <div class="form-row inline-pd widthfix">
                            <div class="col width130px">
                                <input type="text" class="form-control text-right" readonly id="money_amt" name="money_amt" required="required" alt="경조금액" value="${info.money_amt}" format="num">
                            </div>
                            <div class="col width16px">원</div>
                        </div>
                    </td>	                    
                    </tr>
                    <tr>
                        <th class="text-right">비고</th>
                        <td colspan="3">
                            <textarea class="form-control" placeholder="내용을 입력하세요." id="remark" name="remark" style="height: 70px;">${info.remark}</textarea>
                        </td>						
                    </tr>	
                    <tr>
                        <th class="text-right">첨부파일</th>
                        <td colspan="3">
							<div class="table-attfile doc_file_div" style="width: 100%;">
								<div class="table-attfile" style="float: left">
									<button type="button" class="btn btn-primary-gra mr10" name="fileAddBtn" id="fileAddBtn" onclick="javascript:goSearchFile();">파일찾기</button>
									&nbsp;&nbsp;
								</div>
							</div>
                        </td>						
                    </tr>				
                </tbody>
            </table>				
<!-- /폼테이블 -->	
<!-- 하단 내용 -->                  
            <div class="doc-com width750px">
                <div class="text">
                    위와 같이 경조금지급을 신청 하오니 재가하여 주시기 바랍니다.<br>
                    ${info.apply_date.substring(0,4)}년 ${info.apply_date.substring(4,6)}월 ${info.apply_date.substring(6,8)}일
                </div>
                <div class="detail-info">
                    부서 : ${info.org_name}<br>
                    성명 : ${info.apply_mem_name}
                </div> 
            </div>			
<!-- /하단 내용 -->	
<!-- 결재자 의견 -->   
            <div class="title-wrap mt10">
                <div class="left">
                    <h4>결재자 의견</h4>
                </div>                    
            </div>
				<table class="table mt5">
					<colgroup>
						<col width="40px">
						<col width="">
						<col width="60px">
						<col width="">
					</colgroup>
					<thead>
					<tr>
						<td colspan="5">
							<div class="fixed-table-container" style="width: 100%; height: 110px;">
								<!-- height값 인라인 스타일로 주면 타이틀 영역이 고정됨  -->
								<div class="fixed-table-wrapper">
									<table class="table-border doc-table md-table">
										<colgroup>
											<col width="40px">
											<col width="140px">
											<col width="55px">
											<col width="">
										</colgroup>
										<thead>
										<!-- 퍼블리싱 파일의 important 속성 때문에 dev에 선언한 클래스가 안되서 인라인 CSS로함 -->
										<tr>
											<th class="th" style="font-size: 12px !important">구분</th>
											<th class="th" style="font-size: 12px !important">결재일시</th>
											<th class="th" style="font-size: 12px !important">담당자</th>
											<th class="th" style="font-size: 12px !important">특이사항</th>
										</tr>
										</thead>
										<tbody>
										<c:forEach var="list" items="${apprMemoList}">
											<tr>
												<td class="td"
													style="text-align: center; font-size: 12px !important">${list.appr_status_name }</td>
												<td class="td"
													style="font-size: 12px !important">${list.proc_date }</td>
												<td class="td"
													style="text-align: center; font-size: 12px !important">${list.appr_mem_name }</td>
												<td class="td" style="font-size: 12px !important">${list.memo }</td>
											</tr>
										</c:forEach>
										</tbody>
									</table>
								</div>
							</div>
						</td>
					</tr>
					</tbody>
				</table>
<!-- /결재자 의견 -->
			<div class="btn-group mt10">
				<div class="right">
					<!-- 관리부는 수정가능 -->
					<c:if test="${page.fnc.F02020_001 eq 'Y' and info.appr_proc_status_cd == '05'}">
						<button type="button" class="btn btn-info" id="_goModify" name="_goModify" onclick="javascript:goModify()">수정</button>
					</c:if>					
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/><jsp:param name="appr_yn" value="Y"/></jsp:include>
				</div>
			</div>
        </div>
    </div>
<!-- /팝업 -->
<input type="hidden" id="doc_file_seq_1" name="doc_file_seq_1" value="${info.doc_file_seq_1 }" />
<input type="hidden" id="doc_file_seq_2" name="doc_file_seq_2" value="${info.doc_file_seq_2 }" />
<input type="hidden" id="doc_file_seq_3" name="doc_file_seq_3" value="${info.doc_file_seq_3 }" />
<input type="hidden" id="doc_file_seq_4" name="doc_file_seq_4" value="${info.doc_file_seq_4 }" />
<input type="hidden" id="doc_file_seq_5" name="doc_file_seq_5" value="${info.doc_file_seq_5 }" />
</form>
</body>
</html>