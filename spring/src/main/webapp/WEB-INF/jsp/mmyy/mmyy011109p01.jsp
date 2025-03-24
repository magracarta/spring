<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 업무품의서 > null > 업무품의서 상세
-- 작성자 : 황빛찬
-- 최초 작성일 : 2021-07-27 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
	$(document).ready(function() {
	    // 결재상태에 따라 수정가능 제어
	    if (!(($M.getValue("appr_proc_status_cd") == 01 && $M.getValue("mem_no") == '${inputParam.login_mem_no}') 
	          || ($M.getValue("appr_proc_status_cd") == 05 && '${page.fnc.F03123_001}' == 'Y'))
	    ) {
	       $("#main_form :input").prop("disabled", true);
	       $("#main_form :button[onclick='javascript:fnClose();']").prop("disabled", false);
	       $("#main_form :button[onclick='javascript:goApproval();']").prop("disabled", false);
	       $("#main_form :button[onclick='javascript:goApprCancel();']").prop("disabled", false);
	    }
	    
	    console.log("last_appr_mem_no : ", $M.getValue("last_appr_mem_no"));
	    
	    if ($M.getValue("last_appr_mem_no") == '${inputParam.login_mem_no}' && $M.getValue("appr_proc_status_cd") == 05) {
			// $("#couponProc").prop("disabled", false);
	    }
	});
	
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
		} else {
			$M.goNextPageAjax('/session/check', '', {method: 'GET'},
				function (result) {
					if (result.success) {
						// fnCouponProc('Y');
                        alert("처리가 완료되었습니다.");
                        location.reload();
					}
				}
			);
		}
	}

    // 2024-07-02 자동화추가개발 - 쿠폰발행 -> 마일리지적립으로 변경으로 인하여 주석처리
    //                           마일리지는 결재완료 1일 후 자동적립
	// 쿠폰발행하기
	// function fnCouponProc(passYn) {
	// 	if (passYn == "N") {
	//
	// 		if ($M.getValue("appr_proc_status_cd") != "05") {
	// 			alert("쿠폰발행은 최종결재 완료 후 가능합니다.");
	// 			return;
	// 		}
    //
	// 		if ($M.getValue("cust_coupon_no") != "") {
	// 			alert("이미 쿠폰발행이 완료되었습니다.");
	// 			return;
	// 		}
	//
	// 		if (confirm("쿠폰 발행을 진행하시겠습니까 ?") == false) {
	// 			return;
	// 		}
	// 	}
	//
	// 	var param = {
	// 			doc_no : $M.getValue("doc_no")
	// 	}
	//
	// 	// 최종 결재완료 후 쿠폰발행 처리
	// 	$M.goNextPageAjax(this_page + "/coupon/proc", $M.toGetParam(param), {method: "POST"},
	// 		function (result) {
	// 			if (result.success) {
	// 				if (passYn == "N") {
	// 					alert("쿠폰 발행이 완료되었습니다.");
	// 				}
	//
	// 				location.reload();
	//
	// 			}
	// 		}
	// 	);
	// }
	
	// 결재요청
	function goRequestApproval() {
		goModify('requestAppr');
	}
	
	// 수정
	function goModify(isRequestAppr) {
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
		
		var frm = $M.toValueForm(document.main_form);
		console.log("frm : ", frm);
		
		$M.goNextPageAjaxMsg(msg, this_page + "/modify", frm , {method : 'POST'},
			function(result) {
	    		if(result.success) {
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
	
	// 할인쿠폰상세내역 팝업 호출
	// function goGouponDetail() {
	// 	var param = {
	// 			cust_coupon_no : $M.getValue("cust_coupon_no")
	// 	}
	//
	// 	var popupOption = "";
	// 	$M.goNextPage('/cust/cust0305p01', $M.toGetParam(param), {popupStatus : popupOption});
	//
	// }

    // 마일리지 전표 상세 팝업 호출
    function goMileDetail() {
        var param = {
            inout_doc_no : $M.getValue("inout_doc_no")
        }

        $M.goNextPage("/cust/cust0306p02", $M.toGetParam(param), {popupStatus : ""});
    }

	</script>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" id="doc_no" name="doc_no" value="${info.doc_no}">
<input type="hidden" id="appr_proc_status_cd" name="appr_proc_status_cd" value="${info.appr_proc_status_cd}">
<input type="hidden" id="appr_job_seq" name="appr_job_seq" value="${info.appr_job_seq}" />
<input type="hidden" id="doc_type_cd" name="doc_type_cd" value="${info.doc_type_cd}" />
<input type="hidden" id="last_appr_mem_no" name="last_appr_mem_no" value="${last_appr_mem_no}" />
<input type="hidden" id="inout_doc_no" name="inout_doc_no" value="${info.inout_doc_no}" />
<%--<input type="hidden" id="cust_coupon_no" name="cust_coupon_no" value="${info.cust_coupon_no}" />--%>
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp" />
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
<!-- 폼테이블 -->						
            <div class="title-wrap">
                <div class="left approval-left">
<%--                    <h4 class="primary">쿠폰품의서 상세</h4>		--%>
                    <h4 class="primary">마일리지 지급품의서 상세</h4>
                </div>
<!-- 결재영역 -->
				<div class="pl10">
					<jsp:include page="/WEB-INF/jsp/common/apprHeader.jsp"></jsp:include>
				</div>
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
                        <th class="text-right">직책</th>
                        <td>
                            <input type="text" class="form-control width120px" readonly value="${info.grade_name}">
                            <input type="hidden" id="grade_cd" name="grade_cd" value="${info.grade_cd}">
                            <input type="hidden" id="job_cd" name="job_cd" value="${info.job_cd}">
                        </td>							
                    </tr>
                    <tr>
                        <th class="text-right">구분</th>
                        <td colspan="3">
                           <div class="form-check form-check-inline">
                               <input class="form-check-input" type="radio" id="doc_job_sales" name="doc_job_cd" value="01" ${info.doc_job_cd == '01' ? 'checked="checked"' : ''} disabled>
                               <label class="form-check-label" for="doc_job_sales">마케팅</label>
                           </div>                        
                           <div class="form-check form-check-inline">
                               <input class="form-check-input" type="radio" id="doc_job_report" name="doc_job_cd" value="02" ${info.doc_job_cd == '02' ? 'checked="checked"' : ''} disabled>
                               <label class="form-check-label" for="doc_job_report">정비지시서</label>
                           </div>                        
                           <div class="form-check form-check-inline">
                               <input class="form-check-input" type="radio" id="doc_job_part" name="doc_job_cd" value="03" ${info.doc_job_cd == '03' ? 'checked="checked"' : ''} disabled>
                               <label class="form-check-label" for="doc_job_part">수주</label>
                           </div>                        
                           <div class="form-check form-check-inline">
                               <input class="form-check-input" type="radio" id="doc_job_rental" name="doc_job_cd" value="04" ${info.doc_job_cd == '04' ? 'checked="checked"' : ''} disabled>
                               <label class="form-check-label" for="doc_job_rental">렌탈</label>
                           </div>                        
                        </td>						
                    </tr>
                    <tr>
                        <th class="text-right essential-item">제목</th>
                        <td colspan="3">
                            <input type="text" class="form-control rb" id="title" name="title" required="required" alt="제목" value="${info.title}">
                        </td>						
                    </tr>	                    
                    <tr>
                        <th class="text-right essential-item">품의사유</th>
                        <td colspan="3">
                            <textarea class="form-control rb" style="height: 70px;" placeholder="내용을 입력하세요." id="reason_text" name="reason_text" alt="품의사유" required="required">${info.reason_text}</textarea>
                        </td>						
                    </tr>
                    <tr>
                        <th class="text-right essential-item">마일리지 금액</th>
                        <td colspan="3">
							<div class="form-row inline-pd widthfix">
								<div class="col width140px">
		                        	<input type="text" class="form-control rb text-right width140px" id="doc_amt" name="doc_amt" required="required" alt="품의금액" format="num" value="${info.doc_amt}">
								</div>
								<div class="col width16px">원</div>
							</div>	                                
                        </td>						
                    </tr>
                    <tr>
                        <th class="text-right">마일리지 전표</th>
                        <td colspan="3">
                        	<c:choose>
                        		<c:when test="${info.inout_doc_no eq ''}">
<%--                        			<button type="button" id="couponProc" class="btn btn-default" style="width: 80px;" onclick="javascript:fnCouponProc('N');">마일리지적립</button>--%>
<%--		                        	<span style="float: right; margin-top: 2px; color:red">※ 최종 결재 완료시 자동으로 쿠폰 발행이 됩니다.</span>--%>
		                        	<span style="float: right; margin-top: 2px; color:red">※ 최종 결재 완료 1일 후에 자동으로 마일리지가 적립 됩니다.</span>
                        		</c:when>
	                        	<c:otherwise>
<%--		                            <a href="javascript:goGouponDetail();" style="text-decoration : underline; color:black; vertical-align: middle;">${info.inout_doc_no}</a> --%>
		                            <a href="javascript:goMileDetail();" style="text-decoration : underline; color:black; vertical-align: middle;">${info.inout_doc_no}</a>
	                        	</c:otherwise>
                        	</c:choose>
                        </td>						
                    </tr>                    
                </tbody>
            </table>	
<!-- /폼테이블 -->
<!-- 폼테이블 -->					
				<div class="title-wrap mt10 width750px">
					<h4>고객정보</h4>
				</div>			
                    <table class="table-border width750px">
                        <colgroup>
                            <col width="100px">
                            <col width="">
                            <col width="100px">
                            <col width="">
                        </colgroup>
                        <tbody>
                            <tr>
                                <th class="text-right essential-item">고객명</th>
                                <td>
                                	<div class="input-group">
	                                    <input type="text" class="form-control width140px" readonly="readonly" id="cust_name" name="cust_name" required="required" alt="고객" value="${info.cust_name}">
	                                    <input type="hidden" id="cust_no" name="cust_no" value="${info.cust_no}">
                                	</div>
                                </td>		
                                <th class="text-right essential-item">휴대전화</th>
                                <td>
                                    <input type="text" class="form-control width140px" readonly id="real_hp_no" name="real_hp_no" required="required" value="${info.hp_no}" alt="휴대전화">
<%--                                     <input type="hidden" id="hp_no" name="hp_no" value="${info.hp_no}"> --%>
                                </td>							
                            </tr>
                            <tr>
                                <th class="text-right">업체명</th>
                                <td>
                                    <input type="text" class="form-control width140px" readonly id="breg_name" name="breg_name" value="${info.breg_name}">
                                </td>		
                                <th class="text-right">사업자번호</th>
                                <td>
                                    <input type="text" class="form-control width140px" readonly id="real_breg_no" name="real_breg_no" value="${info.breg_no}">
<%--                                     <input type="hidden" id="breg_no" name="breg_no" value="${info.breg_no}"> --%>
<%--                                     <input type="hidden" id="breg_seq" name="breg_seq" value="${info.breg_seq}"> --%>
                                </td>							
                            </tr>
							<tr>
								<th class="text-right">주소</th>
								<td colspan="3">
									<div class="form-row inline-pd mb7">
										<div class="col-12">
											<input type="text" class="form-control" readonly="readonly" id="addr1" name="addr1" value="${info.addr1}">
										</div>
									</div>
									<div class="form-row inline-pd">
										<div class="col-12">
											<input type="text" class="form-control" readonly="readonly" id="addr2" name="addr2" value="${info.addr2}">
										</div>
									</div>
								</td>
							</tr>				
                        </tbody>
                    </table>	
<!-- /폼테이블 -->
<!-- 하단 내용 -->                  
                    <div class="doc-com ">
                        <div class="text">
                            위와 같이 품의서를 신청 하오니 재가하여 주시기 바랍니다<br>
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
 					<c:if test="${page.fnc.F03123_001 eq 'Y' and info.appr_proc_status_cd == '05'}">
 						<button type="button" class="btn btn-info" id="_goModify" name="_goModify" onclick="javascript:goModify()">수정</button>
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