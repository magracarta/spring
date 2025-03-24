<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 경력증명서 > null > 경력증명서 상세
-- 작성자 : 황빛찬
-- 최초 작성일 : 2021-05-10 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		var regMemNo = '${info.apply_mem_no}';
		var memNo = '${SecureUser.mem_no}';
		var nextApprMemNo = '${info.next_appr_mem_no}';
	
		$(document).ready(function() {
			
			// 결재상태에 따라 수정가능 제어
		    if (!(($M.getValue("appr_proc_status_cd") == 01 && $M.getValue("mem_no") == '${inputParam.login_mem_no}') 
		          || ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F02026_001}' == 'Y'))
		    ) {
				$("#main_form :input").prop("disabled", true);
				$("#main_form :button[onclick='javascript:fnPrint();']").prop("disabled", false);
				$("#main_form :button[onclick='javascript:fnClose();']").prop("disabled", false);
				$("#main_form :button[onclick='javascript:goApproval();']").prop("disabled", false);
				$("#main_form :button[onclick='javascript:goApprCancel();']").prop("disabled", false);
				$("#main_form :button[onclick='javascript:goModify();']").prop("disabled", false);
                $("#grade_cd").prop("disabled", true);
			}

			if ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F02026_001}' == 'Y') {
				$("#_fnPrint").show();
			} else {
				$("#_fnPrint").hide();
			}

			// TODO : 회사의견 제어
			// 1. 관리부 : 입력가능
			// 2. 결재자 : 입력가능
			// 3. 작성자 : 입력불가
			if (('${page.fnc.F02026_001}' == 'Y' && $M.getValue("appr_proc_status_cd") == 05)
					 || ($M.getValue("apply_mem_no") != '${inputParam.login_mem_no}' && nextApprMemNo == memNo)) {
				$("#cmp_text").prop("disabled", false);
			} else {
				$("#cmp_text").prop("disabled", true);
			}
		});

		function fnClose() {
			window.close();
		}

		// 인쇄
		function fnPrint() {

			var docDt = $M.getValue("doc_dt");
			var ipsaDt = $M.getValue("ipsa_dt") == "" ? docDt : $M.getValue("ipsa_dt");
			var retireDt = $M.getValue("retire_dt") == "" ? docDt : $M.getValue("retire_dt");
			var applyCnt = $M.toNum($M.getValue("apply_cnt"));

			var datas = [];

			for (var i = 0; i < applyCnt; i++) {
				var data = {
					"mem_name" : $M.getValue("apply_mem_name")
					, "resi_no" : "${info.resi_no}"
					, "grade_name" : $("#grade_cd option:selected").text()
					, "org_name" : $M.getValue("org_name")
					, "addr" : $M.getValue("addr")
					, "jjob_text" : $M.getValue("jjob_text")
					, "doc_dt" : docDt
					, "ipsa_dt" : ipsaDt
					, "retire_dt" : retireDt
					, "career_time" : "${info.career_time}"
					, "cmp_text" : $M.getValue("cmp_text")
					, "reg_org_name" : "${SecureUser.org_name}"
					, "reg_mem_name" : "${SecureUser.kor_name}"
				};

				datas[i] = data
			}

			var param = {
				"data" : datas
			}

			openReportPanel('mmyy/mmyy011107p01_01.crf', param);
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
			if (($M.getValue("apply_mem_no") != '${inputParam.login_mem_no}' && nextApprMemNo == memNo)) {
				if ($M.getValue("cmp_text") == "") {
					alert("회사의견은 필수 입력입니다.");
					$("#cmp_text").focus();
					return;
				}
			}

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
// 							alert("처리가 완료되었습니다.");
// 							location.reload();

							// 결재처리 후 회사의견 수정.
							var frm = document.main_form;
							$M.setValue("save_mode", "modify");

							$M.goNextPageAjax("/mmyy/mmyy011107p01/modify", $M.toValueForm(frm), {method: "POST"},
								function (result) {
									if (result.success) {
										window.location.reload();
						    			if (opener != null && opener.goSearch) {
						    				opener.goSearch();
						    			}
									}
								}
							);

						}
					}
				);
			}
		}

		// 결재요청
		function goRequestApproval() {
			// 21.09.06 (SR : 12494) 경력증명서 관리부이면서 다음결재자가 없을 경우에만 회사의견 필수 체크.
			if (($M.getValue("apply_mem_no") != '${inputParam.login_mem_no}' && nextApprMemNo == memNo) && ('${page.fnc.F02026_001}' == 'Y' && $M.getValue("apprNum2") == "")) {
				if ($M.getValue("cmp_text") == "") {
					alert("회사의견은 필수 입력입니다.");
					$("#cmp_text").focus();
					return;
				}
			}
			
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
			var frm = document.main_form;
			
			// validationcheck
			if($M.validation(document.main_form) == false) {
				return;
			};

			var msg = "";
			if (isRequestAppr != undefined) {
				// 결재요청 Setting
				$M.setValue("save_mode", "appr");
				msg = "결재요청 하시겠습니까?";
			} else {
				$M.setValue("save_mode", "modify");
				msg = "수정 하시겠습니까?";
			}

			$M.goNextPageAjaxMsg(msg, this_page + "/modify", $M.toValueForm(frm), {method: "POST"},
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
			var frm = document.main_form;

			$M.goNextPageAjaxRemove(this_page + "/remove", $M.toValueForm(frm), {method: "POST"},
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

        function fnChangeGradeCd(obj) {
            $M.setValue("job_cd", obj.value);
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
            <div class="text-right">
                <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
            </div>
<!-- 폼테이블 -->						
            <div class="title-wrap mt10">
                <div class="left approval-left">
                    <h4 class="primary">경력증명서 상세</h4>		
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
                        <th class="text-right">신청자</th>
                        <td>
                            <input type="text" class="form-control width120px" readonly value="${info.apply_mem_name}" id="apply_mem_name" name="apply_mem_name">
                            <input type="hidden" class="form-control width120px" readonly id="apply_mem_no" name="apply_mem_no" value="${info.apply_mem_no}">
                        </td>	
                        <th class="text-right essential-item">매수</th>
                        <td>
                            <input type="text" class="form-control width60px rb" id="apply_cnt" name="apply_cnt" required="required" min="1" datatype="int" value="${info.apply_cnt}">
                        </td>					
                    </tr>                    
                    <tr>
                        <th class="text-right">부서</th>
                        <td>
                            <input type="text" class="form-control width120px" readonly value="${info.org_name}" id="org_name" name="org_name">
                            <input type="hidden" id="org_code" name="org_code" value="${info.org_code}">
                        </td>
                        <th class="text-right essential-item">직위</th>
                        <td>
                            <select class="form-control width120px rb" id="grade_cd" name="grade_cd" required="required" alt="직위" onchange="fnChangeGradeCd(this);">
                                <option value="">- 선택 -</option>
                                <c:forEach items="${codeMap['GRADE']}" var="item">
                                    <option value="${item.code_value}" ${item.code_value == info.grade_cd ? 'selected="selected"' : ''}>${item.code_name}</option>
                                </c:forEach>
                            </select>
                            <input type="hidden" id="job_cd" name="job_cd" value="${info.job_cd}">
                        </td>					
                    </tr>
                    <tr>
                        <th class="text-right">연락처</th>
                        <td>
                            <input type="text" class="form-control width120px" readonly id="hp_no" name="hp_no" value="${info.hp_no}" format="phone">
                        </td>			
                        <th class="text-right essential-item">직무</th>
                        <td>
                            <input type="text" class="form-control width120px rb" id="jjob_text" name="jjob_text" required="required" value="${info.jjob_text}">
                        </td>							
                    </tr>
                    <tr>
                        <th class="text-right">입사일</th>
                        <td>
                            <input type="text" class="form-control width120px" readonly id="ipsa_dt" name="ipsa_dt" value="${info.ipsa_dt}" dateformat="yyyy-MM-dd">
                        </td>				
                        <th class="text-right">퇴사일</th>
                        <td>
                            <input type="text" class="form-control width120px" readonly id="retire_dt" name="retire_dt" value="${info.retire_dt}" dateformat="yyyy-MM-dd">
                        </td>								
                    </tr>
                    <tr>
                        <th class="text-right">주소</th>
                        <td colspan="3">
                            <input type="text" class="form-control" readonly id="addr" name="addr" value="${info.addr}">
                        </td>						
                    </tr>
                    <tr>
                        <th class="text-right">회사의견</th>
                        <td colspan="3">
                            <textarea class="form-control" placeholder="회사의견이 들어갑니다." id="cmp_text" name="cmp_text" style="height: 70px;">${info.cmp_text}</textarea>
                        </td>						
                    </tr>				
                </tbody>
            </table>				
<!-- /폼테이블 -->
<!-- 하단 내용 -->                  
            <div class="doc-com">
                <div class="text">
                    상기와 같은 용도로 경력증명서를 신청합니다.<br>
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
					<c:if test="${(page.fnc.F02026_001 eq 'Y' and info.appr_proc_status_cd == '05')}">
						<button type="button" class="btn btn-info" id="goModify2" name="goModify2" onclick="javascript:goModify()">수정</button>
					</c:if>				
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/><jsp:param name="appr_yn" value="Y"/></jsp:include>
				</div>
			</div>
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>