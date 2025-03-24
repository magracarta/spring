<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 사후사고보고 > null > 사후사고보고 상세
-- 작성자 : 황빛찬
-- 최초 작성일 : 2025-02-11 14:47:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
	// 첨부파일의 index 변수
	var fileIndex = 1;
	// 첨부할 수 있는 파일의 개수
	var fileMaxCount = 5;
	
	var regMemNo = '${info.mem_no}';
	var memNo = '${SecureUser.mem_no}';
	var nextApprMemNo = '${info.next_appr_mem_no}';
	
	$(document).ready(function() {
		<c:forEach var="list" items="${doc_file}">setFileInfo('${list.file_seq}', '${list.file_name}');</c:forEach>
		
		// 결재상태에 따라 수정가능 제어
	    if (!(($M.getValue("appr_proc_status_cd") == 01 && $M.getValue("mem_no") == '${inputParam.login_mem_no}') 
	          || ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F06085_001}' == 'Y'))
	    ) {
			$("#main_form :input").prop("disabled", true);
			$("#main_form :button[onclick='javascript:fnPrint();']").prop("disabled", false);
			$("#main_form :button[onclick='javascript:fnClose();']").prop("disabled", false);
			$("#main_form :button[onclick='javascript:goApproval();']").prop("disabled", false);
			$("#main_form :button[onclick='javascript:goApprCancel();']").prop("disabled", false);
		}
		
		if (('${page.fnc.F06085_001}' == 'Y' && $M.getValue("appr_proc_status_cd") == 05)
				|| ($M.getValue("mem_no") != '${inputParam.login_mem_no}' && nextApprMemNo == memNo)) {
			$("#mem_pnt_reprimand_cd").prop("disabled", false);
			$("#goModify2").show();
			$("#goModify2").prop("disabled", false);
			$("#main_form :button[onclick='javascript:goModify();']").attr("disabled", false);
		} else {
			$("#goModify2").hide();
		}

        $("#fileDownBtn").prop("disabled", false);
        $("#fileViewBtn").prop("disabled", false);
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
		str += '<a href="javascript:fileDownload(' + fileSeq + ');" style="color: blue;">' + fileName + '</a>&nbsp;';
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
                    console.log("완료 ? ", result);
					alert("결재취소가 완료됐습니다.");
					location.reload();
				}
			}
		);
	}
	
	// 결재요청
	function goRequestApproval() {
		goModify('requestAppr');
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

    function goApprovalResult(result) {
        // 반려이면 페이지 리로딩
        if (result.appr_status_cd == '03') {
            $M.goNextPageAjax('/session/check', '', {method: 'GET'},
                function (result) {
                    if (result.success) {
                        alert("반려가 완료되었습니다.");
                        location.reload();
                        if (opener != null && opener.goSearch) {
                            opener.goSearch();
                        }
                    }
                }
            );
        } else if (result.appr_status_cd == '05') {
            $M.goNextPageAjax('/session/check', '', {method: 'GET'},
                function (result) {
                    if (result.success) {
                        alert("결재처리가 완료되었습니다.");
                        location.reload();
                        if (opener != null && opener.goSearch) {
                            opener.goSearch();
                        }
                    }
                }
            );
        } else {
            $M.goNextPageAjax('/session/check', '', {method: 'GET'},
                function (result) {
                    if (result.success) {
                        alert("처리가 완료되었습니다.");
                        location.reload();
                        if (opener != null && opener.goSearch) {
                            opener.goSearch();
                        }
                    }
                }
            );
        }
    }
	
	// 수정
	function goModify(isRequestAppr) {
		// validationcheck
		if($M.validation(document.main_form) == false) {
			return;
		};
		
		if($("input[class='doc_file_list']").size() == 0) {
			alert("첨부파일은 필수입니다.");
			return false;
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
		
		if (confirm(msg) == false) {
			return false;
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
		
		var frm = $M.toValueForm(document.main_form);

		$M.goNextPageAjax(this_page + "/modify", frm, {method: "POST"},
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

    function fnStaticFileDown() {
        var param = {
            real_path : "/static/img/pdf"
            , file_name : "산업재해조사표.pdf"
        };
        $M.goNextPage("/file/static/file_down", $M.toGetParam(param), {method: "GET"});
    }
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
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
<!-- 폼테이블 -->						
            <div class="title-wrap">
                <div class="left approval-left">
                    <h4 class="primary">사후사고보고 상세</h4>
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
                            <input type="text" class="form-control width120px" readonly value="${info.mem_name}">
                            <input type="hidden" id="mem_no" name="mem_no" value="${info.mem_no}">
                        </td>		
                        <th class="text-right">작성일</th>
                        <td>
                            <input type="text" class="form-control width120px" readonly id="doc_dt" name="doc_dt" value="${info.doc_dt}" dateformat="yyyy-MM-dd">
                        </td>							
                    </tr>
                    <tr>
                        <th class="text-right">부서</th>
                        <td>
                            <input type="text" class="form-control width120px" readonly value="${info.org_name}">
                            <input type="hidden" id="org_code" name="org_code" value="${info.org_code}">
                        </td>		
                        <th class="text-right">직위</th>
                        <td>
                            <input type="text" class="form-control width120px" readonly value="${info.grade_name}">
                            <input type="hidden" id="grade_cd" name="grade_cd" value="${info.grade_cd}">
                            <input type="hidden" id="job_cd" name="job_cd" value="${info.job_cd}">
                        </td>							
                    </tr>
                    <tr>
                        <th class="text-right essential-item">제목</th>
                        <td colspan="3">
                            <input type="text" class="form-control rb" alt="제목" id="title" name="title" required="required" value="${info.title}">
                        </td>						
                    </tr>
                    <tr>
                        <th class="text-right essential-item">사고경위</th>
                        <td colspan="3">
                            <textarea class="form-control rb" placeholder="내용을 입력하세요." id="accident_remark" name="accident_remark" required="required" style="height: 70px;">${info.accident_remark}</textarea>
                        </td>						
                    </tr>
                    <tr>
                        <th class="text-right">조사표 다운로드</th>
                        <td colspan="3">
                            <button type="button" class="btn btn-primary-gra mr10" name="fileDownBtn" id="fileDownBtn" onclick="fnStaticFileDown();">산업재해 조사표 다운로드</button></button>
                            <button type="button" class="btn btn-primary-gra mr10" name="fileViewBtn" id="fileViewBtn">
                                <a href="javascript:openFileViewerPanel('456528')">산업재해 조사표 작성예시</a>
                            </button>
                        </td>
                    </tr>
                    <tr>
                        <th class="text-right essential-item">첨부파일</th>
                        <td colspan="3">
							<div class="table-attfile doc_file_div" style="width: 100%;">
								<div class="table-attfile" style="float: left">
									<button type="button" class="btn btn-primary-gra mr10" name="fileAddBtn" id="fileAddBtn" onclick="javascript:goSearchFile();">파일찾기</button>
									&nbsp;&nbsp;
								</div>
							</div>
                            <div class="text-warning mt5">
                                ※ 사유서는 자필로 작성 후 스캔해서 올려주세요!
                            </div>
                        </td>
                    </tr>	
                </tbody>
            </table>				
<!-- /폼테이블 -->	
<!-- 하단 내용 -->                  
            <div class="doc-com">
                <div class="text">
                    상기 작성 내용에 허위가 없습니다.<br>
                    ${info.apply_date.substring(0,4)}년 ${info.apply_date.substring(4,6)}월 ${info.apply_date.substring(6,8)}일
                </div>
                <div class="detail-info">
                    부서 : ${info.org_name}<br>
                    성명 : ${info.mem_name}
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
<%--					<c:if test="${(page.fnc.F06085_001 eq 'Y' and info.appr_proc_status_cd == '05') or (info.next_appr_mem_no eq inputParam.login_mem_no and inputParam.login_mem_no ne info.mem_no)}">--%>
                    <c:if test="${(page.fnc.F06085_001 eq 'Y' and info.appr_proc_status_cd == '05')}">
						<button type="button" class="btn btn-info" id="goModify2" name="goModify2" onclick="javascript:goModify()">수정</button>
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