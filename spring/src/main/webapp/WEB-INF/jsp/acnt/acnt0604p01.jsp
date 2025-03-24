<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 인사 > 징계관리 > null > 징계상세
-- 작성자 : 황빛찬
-- 최초 작성일 : 2021-05-03 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
	var memPntCutJson = JSON.parse('${codeMapJsonObj['MEM_PNT_CUT']}');  // 감봉구분코드 (1~6)
	var memPntReprimandJson = JSON.parse('${codeMapJsonObj['MEM_PNT_REPRIMAND']}');  // 견책등급 (징계등급)
	
	var fileIndex = 1;
	
	var memNo = '${SecureUser.mem_no}';
	var nextApprMemNo = '${info.next_appr_mem_no}';

	$(document).ready(function () {

		// 각 징계구분에 따라 영역 show, hide
		switch($M.getValue("mem_penalty_cd")) {
		// 견책
		case "02" : $(".reprimand").removeClass("dpn");
					$(".down_cut").addClass("dpn");
					$(".down_grade").addClass("dpn");
					$(".stop_dt").addClass("dpn");
					
					// 수정제어
					$("#main_form :input").prop("disabled", true);
					$("#main_form :button[onclick='javascript:fnClose();']").prop("disabled", false);
		 			$("#main_form :button[onclick='javascript:goApproval();']").prop("disabled", false);
					
		 			if (('${page.fnc.F01993_001}' == 'Y' && $M.getValue("appr_proc_status_cd") == 05)
		 					|| ($M.getValue("mem_no") != '${inputParam.login_mem_no}' && nextApprMemNo == memNo)) {
		 				$("#mem_pnt_reprimand_cd").prop("disabled", false);
		 				$("#goModify2").show();
		 				$("#goModify2").prop("disabled", false);
		 				$("#main_form :button[onclick='javascript:goModify();']").attr("disabled", false);
		 			} else {
		 				$("#goModify2").hide();
		 			}
		 			
		 			// 파일
		 			<c:forEach var="list" items="${doc_file}">setFileInfo('${list.file_seq}', '${list.file_name}');</c:forEach>
					
					break;
		// 감봉
		case "03" : $(".down_cut").removeClass("dpn");
					$(".down_grade").addClass("dpn");
					$(".stop_dt").addClass("dpn");
// 					$(".reprimand").addClass("dpn");
					break;
		// 강직
		case "04" : $(".down_grade").removeClass("dpn");
					$(".down_cut").addClass("dpn");
					$(".stop_dt").addClass("dpn");
// 					$(".reprimand").addClass("dpn");
					break;
		// 정직
		case "05" : $(".stop_dt").removeClass("dpn");
					$(".down_cut").addClass("dpn");
					$(".down_grade").addClass("dpn");
// 					$(".reprimand").addClass("dpn");
					break;
		// 훈계, 징계해고
		default : $(".stop_dt").addClass("dpn");
				  $(".down_cut").addClass("dpn");
				  $(".down_grade").addClass("dpn");
// 				  $(".reprimand").addClass("dpn");
				  break;
		}
	});
	
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
	
	// 견책 등급 (징계등급) 변경시 금액 세팅.
	function fnReprimandAmt(val) {
		var downAmt = 0;  // 차감액
		
		for (var i = 0; i < memPntReprimandJson.length; i++) {
			if (val == memPntReprimandJson[i].code_value) {
				downAmt = memPntReprimandJson[i].code_v1;  // 코드값에 맞는 차감금액 세팅
			}
		} 
		
		$M.setValue("mem_pnt_reprimand_amt", $M.setComma(parseInt(downAmt + "0000")));
	}
	
	// 징계구분 - 감봉 선택시 기존 코드값 세팅
	function fnChangeDownCutAmt(val) {
		var downAmt = 0;  // 감봉액
		
		for (var i = 0; i < memPntCutJson.length; i++) {
			if (val == memPntCutJson[i].code_value) {
				downAmt = memPntCutJson[i].code_v1;  // 코드값에 맞는 감봉액 세팅
			}
		} 
		
		$M.setValue("down_cut_amt_text", $M.setComma(parseInt(downAmt + "0000") * -1));
		$M.setValue("down_cut_amt", parseInt(downAmt + "0000"));
	}
	
	// 감봉금액 직접 입력시 값 세팅
	function fnChangeAmt(val) {
		$M.setValue("down_cut_amt_text", $M.setComma(parseInt(val) * -1));
		$M.setValue("down_cut_amt", parseInt(val));
	}
	
	// 닫기
	function fnClose() {
		window.close();
	}
	
	// 수정
	function goModify() {
		if ($M.getValue("save_mode") != "approval") {
			if (confirm("수정하시겠습니까?") == false) {
				return;
			}
		}

		var frm = document.main_form;
		
		$M.goNextPageAjax(this_page + '/modify', $M.toValueForm(frm), {method : 'POST'},
			function(result) {
	    		if(result.success) {
	    			alert("정상 처리되었습니다.");
	    			location.reload();
	    			if (window.opener.goSearch) {
	    				window.opener.goSearch();						    				
	    			}
				}
			}
		);
	}
	
	// 삭제
	function goRemove() {
		var frm = document.main_form;
		
		$M.goNextPageAjaxRemove(this_page + '/remove', $M.toValueForm(frm), {method : 'POST'},
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
		} else {
			// (SR : 16570 - 황빛찬) 결재처리 후 변경내역 수정되도록 처리
			setTimeout(goModify, 600);
			// $M.goNextPageAjax('/session/check', '', {method: 'GET'},
			// 	function (result) {
			// 		if (result.success) {
			// 			alert("처리가 완료되었습니다.");
			// 			location.reload();
			// 		}
			// 	}
			// );
		}
	}
	
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" id="mem_penalty_no" name="mem_penalty_no" value="${info.mem_penalty_no}">
<input type="hidden" id="doc_no" name="doc_no" value="${info.doc_no}">
<input type="hidden" id="appr_proc_status_cd" name="appr_proc_status_cd" value="${info.appr_proc_status_cd}">
<input type="hidden" id="appr_job_seq" name="appr_job_seq" value="${info.appr_job_seq}" />
<input type="hidden" id="mem_no" name="mem_no" value="${info.mem_no}">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
<!-- 상단 폼테이블 -->					
			<div>
<!-- 1. 장비정보 -->				
				<div class="title-wrap">
					<div class="left approval-left">
						<h4 class="primary">징계상세</h4>			
					</div>
				<c:if test="${info.mem_penalty_cd eq '02'}">
<!-- 결재영역 -->
	                <div class="pl10">
	                    <jsp:include page="/WEB-INF/jsp/common/apprHeader.jsp"></jsp:include>
	                </div>
                </c:if>
<!-- /결재영역 -->
                </div>	
                <table class="table-border mt10">
					<colgroup>
						<col width="100px">
						<col width="">
						<col width="100px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right essential-item">직원명</th>
							<td>
								<input type="text" class="form-control width120px" readonly id="mem_name" name="mem_name" value="${info.mem_name}">
							</td>
							<th class="text-right">부서</th>
							<td>
								<input type="text" class="form-control width120px" readonly id="org_name" name="org_name" value="${info.org_name}">
							</td>
						</tr>
						<tr>
							<th class="text-right">연락처</th>
							<td>
								<input type="text" class="form-control width120px" readonly id="hp_no" name="hp_no" value="${info.hp_no}" format="phone">
							</td>
							<th class="text-right">직위</th>
							<td>
								<input type="text" class="form-control width120px" readonly id="grade_name" name="grade_name" value="${info.grade_name}">
							</td>
						</tr>
					</tbody>
                </table>
<!-- 징계 -->
                <div class="title-wrap mt10">
                    <h4>징계</h4>
                </div>
                <table class="table-border mt5">
                    <colgroup>
                        <col width="100px">
                        <col width="">
                        <col width="100px">
                        <col width="">
                    </colgroup>
                    <tbody>
                        <tr>
                            <th class="text-right essential-item">징계구분</th>
                            <td>
                            	<input type="text" class="form-control width120px" readonly id="mem_penalty_name" name="mem_penalty_name" value="${info.mem_penalty_name}">
                            	<input type="hidden" id="mem_penalty_cd" name="mem_penalty_cd" value="${info.mem_penalty_cd}">
                            </td>
                            <th class="text-right essential-item">반영일자</th>
                            <td>
                               <div class="input-group width120px">
                                   <input type="text" class="form-control border-right-0 width100px calDate rb" id="apply_dt" name="apply_dt" dateformat="yyyy-MM-dd" alt="반영일자" required="required" value="${info.apply_dt}">
                               </div>
                            </td>
                        </tr>
                        <tr>
                            <th class="text-right reprimand dpn">징계등급</th>
                            <td class="reprimand dpn">
								<div class="form-row inline-pd widthfix">
									<div class="col width80px">
										<select class="form-control width80px" id="mem_pnt_reprimand_cd" name="mem_pnt_reprimand_cd" onchange="javascript:fnReprimandAmt(this.value);">
											<option value="">- 선택 -</option>
											<c:forEach items="${codeMap['MEM_PNT_REPRIMAND']}" var="item">
												<option value="${item.code_value}" ${item.code_value == info.mem_pnt_reprimand_cd ? 'selected' : ''}>${item.code_name}</option>
											</c:forEach>
										</select>
									</div>
									<div class="col width120px">
										<input type="text" placeholder="차감금액" class="form-control text-right" readonly id="mem_pnt_reprimand_amt" name="mem_pnt_reprimand_amt" value="${info.mem_pnt_reprimand_amt}0000" format="num">
									</div>	
									<div class="col width16px">원</div>
								</div>
							</td>
                            <th class="text-right reprimand dpn">시말서</th>
                            <td class="reprimand dpn">
								<div class="table-attfile doc_file_div" style="width: 100%;">
									<div class="table-attfile" style="float: left">
<!-- 										<button type="button" class="btn btn-primary-gra mr10" name="fileAddBtn" id="fileAddBtn"  -->
<!-- 										onclick="javascript:goSearchFile();">파일찾기</button> -->
										&nbsp;&nbsp;
									</div>
								</div>
                            </td>
                        </tr>
                        <tr>
                            <th class="text-right down_cut dpn">감봉등급</th>
                            <td class="down_cut dpn">
								<select class="form-control width100px" id="mem_pnt_cut_cd" name="mem_pnt_cut_cd" onchange="javascipt:fnChangeDownCutAmt(this.value);">
									<option value="">- 선택 -</option>
									<c:forEach items="${codeMap['MEM_PNT_CUT']}" var="item">
										<option value="${item.code_value}" ${item.code_value == info.mem_pnt_cut_cd ? 'selected' : ''}>${item.code_name}</option>
									</c:forEach>
								</select>
                            </td>
                            <th class="text-right down_cut dpn">감봉액</th>
                            <td class="down_cut dpn">
                                <div class="form-row inline-pd widthfix">
                                    <div class="col width120px">
	                                	<input type="text" class="form-control text-right" id="down_cut_amt_text" name="down_cut_amt_text" onchange="javascipt:fnChangeAmt(this.value);" value="${info.down_cut_amt_text}" format="num">
	                                	<input type="hidden" id="down_cut_amt" name="down_cut_amt" value="${info.down_cut_amt}">
                                    </div>
                                    <div class="col width16px">원</div>
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <th class="text-right down_grade dpn">강등처리</th>
                            <td colspan="3" class="down_grade dpn">
								<select class="form-control width80px" id="down_grade_cd" name="down_grade_cd">
									<option value="">- 선택 -</option>
									<c:forEach items="${codeMap['GRADE']}" var="item">
										<option value="${item.code_value}" ${item.code_value == info.down_grade_cd ? 'selected' : ''}>${item.code_name}</option>
									</c:forEach>
								</select>
                            </td>
                        </tr>
                        <tr>
                            <th class="text-right stop_dt dpn">정직기간</th>
                            <td colspan="3" class="stop_dt dpn">
                                <div class="form-row inline-pd widthfix">
                                    <div class="col width120px">
                                        <div class="input-group">
                                        	<input type="text" class="form-control border-right-0 width80px calDate" id="stop_st_dt" name="stop_st_dt" dateformat="yyyy-MM-dd" alt="정직시작일" value="${info.stop_st_dt}">
                                        </div>
                                    </div>
                                    <div class="col width16px">~</div>
                                    <div class="col width120px">
                                        <div class="input-group">
                                        	<input type="text" class="form-control border-right-0 width80px calDate" id="stop_ed_dt" name="stop_ed_dt" dateformat="yyyy-MM-dd" alt="정직종료일" value="${info.stop_ed_dt}">
                                        </div>
                                    </div>
								</div>
                            </td>
                        </tr>
                        <tr>
                            <th class="text-right">비고</th>
                            <td colspan="3">
								<textarea class="form-control" placeholder="내용을 입력하세요." style="height: 200px;" id="remark" name="remark" >${info.remark}</textarea>
							</td>
                        </tr>
                    </tbody>
                </table>
<!-- /징계 -->
			</div>
<!-- /상단 폼테이블 -->	
			
		<c:if test="${info.mem_penalty_cd eq '02'}">
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
			
		</c:if>		
			<div class="btn-group mt10">
				<div class="right">
				<c:choose>
					<c:when test="${info.mem_penalty_cd eq '02'}">
						<c:if test="${(page.fnc.F01993_001 eq 'Y' and info.appr_proc_status_cd == '05') or (info.next_appr_mem_no eq inputParam.login_mem_no and inputParam.login_mem_no ne info.mem_no)}">
							<button type="button" class="btn btn-info" id="goModify2" name="goModify2" onclick="javascript:goModify()">수정</button>
						</c:if>					
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/><jsp:param name="appr_yn" value="Y"/></jsp:include>
					</c:when>
					<c:otherwise>
<%-- 						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include> --%>
						<button type="button" class="btn btn-info" onclick="javascript:goModify();">수정</button>
						<button type="button" class="btn btn-info" onclick="javascript:goRemove();">삭제</button>
						<button type="button" class="btn btn-info" onclick="javascript:fnClose();">닫기</button>
					</c:otherwise>
				</c:choose>
<!-- 					<button type="button" class="btn btn-success">결재</button> -->
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