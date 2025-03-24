<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 재직증명서 > null > 재직증명서 상세
-- 작성자 : 황빛찬
-- 최초 작성일 : 2021-05-10 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
	$(document).ready(function() {
		// 작성중일경우에만 신청버튼 show
		if ($M.getValue("doc_status_cd") != "01") {
			$("#_goAppProcessing").hide();
			$("#_goRemove").hide();
		} else {
			$("#_goAppProcessing").show();
			$("#_goRemove").show();
		}
		
		// 신청일경우에만 승인버튼 show
		if ($M.getValue("doc_status_cd") == "02") {
			$("#_goCompleteApproval").show();
		} else {
			$("#_goCompleteApproval").hide();			
		}
		
		// 결재상태에 따라 수정가능 제어
		if (($M.getValue("doc_status_cd") == '03' || $M.getValue("mem_no") != '${inputParam.login_mem_no}') && '${page.fnc.F02023_001}' != 'Y') {
			$("#main_form :input").prop("disabled", true);
			$("#main_form :checkbox").prop("disabled", false);
			$("#main_form :button[onclick='javascript:fnClose();']").prop("disabled", false);
			$("#main_form :button[onclick='javascript:fnPrint();']").prop("disabled", false);
			$("#_goModify").hide();
			$("#_goRemove").hide();
		}
		
		// 승인이면서, 본인이거나 관리부일경우에만 재직증명서 출력 가능
		if ($M.getValue("doc_status_cd") == '03' && ($M.getValue("mem_no") == '${inputParam.login_mem_no}' || '${page.fnc.F02023_001}' == 'Y')) {
			$("#_fnPrint").show();
		} else {
			$("#_fnPrint").hide();
		}
	});
	
	// 신청
	function goAppProcessing() {
		if ($M.getValue("doc_status_cd") != "01") {
			alert("작성중인 자료만 신청 가능합니다.");
			return;
		}
		
		if (confirm("신청하시겠습니까?") == false) {
			return false;
		}
		
		$M.setValue("appr", "Y");
		goModify("appr");
	}
	
	function fnClose() {
		window.close();
	}
	
	// 승인
	function goCompleteApproval() {
		if ($M.getValue("doc_status_cd") != "02") {
			alert("신청완료된 자료만 승인이 가능합니다.");
			return;
		}
		
		if (confirm("승인하시겠습니까?") == false) {
			return false;
		}
		
		$M.setValue("complete", "Y");
		goModify("complete");
	}
	
	// 수정
	function goModify(val) {
// 		if ($M.getValue("doc_status_cd") == "03") {
// 			alert("승인완료된 자료는 수정이 불가합니다.");
// 			return;
// 		}

		var frm = document.main_form;
		
		// validation check
		if($M.validation(document.main_form) == false) {
			return;
		};
		
		// 승인,신청 / 수정일경우 알림메시지 때문에 나눔.		
		if (val == undefined) {
			$M.goNextPageAjaxModify(this_page + '/modify', $M.toValueForm(frm), {method : 'POST'},
				function(result) {
		    		if(result.success) {
		    			location.reload();
		    			if (window.opener.goSearch) {
		    				window.opener.goSearch();						    				
		    			}
					}
				}
			);			
		} else {
			$M.goNextPageAjax(this_page + '/modify', $M.toValueForm(frm), {method : 'POST'},
				function(result) {
		    		if(result.success) {
		    			location.reload();
		    			if (window.opener.goSearch) {
		    				window.opener.goSearch();						    				
		    			}
					}
				}
			);
		}
	}
	
	// 삭제
	function goRemove() {
		if ($M.getValue("doc_status_cd") != "01") {
			alert("작성중인 자료만 삭제 가능합니다.");
			return;
		}	
	
		var frm = document.main_form;
		
		$M.goNextPageAjaxRemove(this_page + '/remove', $M.toValueForm(frm), {method : 'POST'},
			function(result) {
	    		if(result.success) {
	    			fnClose();
	    			if (window.opener.goSearch) {
	    				window.opener.goSearch();						    				
	    			}
				}
			}
		);
	}
	
	function fnPrint() {
		var docDt = $M.getValue("doc_dt");
		var ipsaDt = $M.getValue("ipsa_dt") == "" ? docDt : $M.getValue("ipsa_dt");
		var retireDt = $M.getValue("retire_dt") == "" ? docDt : $M.getValue("retire_dt"); 
		var applyCnt = $M.toNum($M.getValue("apply_cnt"));
		
		var datas = [];
		
		for (var i = 0; i < applyCnt; i++) {
			var data = {
					"mem_name" : $M.getValue("mem_name")
					, "resi_no" : "${info.resi_no}"
					, "addr" : $M.getValue("addr")
					, "org_name" : $M.getValue("org_name")
					, "grade_name" : $M.getValue("grade_name")
					, "doc_dt" : docDt
					, "ipsa_dt" : ipsaDt
					, "retire_dt" : retireDt
					, "career_time" : "${info.career_time}"
					, "submit_text" : $M.getValue("submit_text")
					, "reg_org_name" : "${SecureUser.org_name}"
					, "reg_mem_name" : "${SecureUser.kor_name}"
// 		 			, "yk_doc_no" : $M.getValue("apply_cnt")
				};
			
			datas[i] = data 
		}
		
		var param = {
			"data" : datas
		}
		
		openReportPanel('mmyy/mmyy011106p01_01.crf', param);
	}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" id="doc_no" name="doc_no" value="${info.doc_no}">
<input type="hidden" id="doc_status_cd" name="doc_status_cd" value="${info.doc_status_cd}">
<input type="hidden" id="doc_type_cd" name="doc_type_cd" value="${info.doc_type_cd}">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
            
<!-- 폼테이블 -->						
            <div class="title-wrap mt10">
                <div class="left">
                    <h4 class="primary">재직증명서 상세</h4>		
                </div>
                <div class="right">
                    <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
                </div>
            </div>								
<!-- 폼테이블 -->					
            <table class="table-border mt5">
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
                        <th class="text-right">연락처</th>
                        <td>
                            <input type="text" class="form-control width120px" readonly id="hp_no" name="hp_no" value="${info.hp_no}" format="phone">
                        </td>		
                        <th class="text-right">입사일</th>
                        <td>
                            <input type="text" class="form-control width120px" readonly id="ipsa_dt" name="ipsa_dt" value="${info.ipsa_dt}" dateformat="yyyy-MM-dd">
                        </td>							
                    </tr>
                    <tr>
                        <th class="text-right">주소</th>
                        <td colspan="3">
                            <input type="text" class="form-control" readonly id="addr" name="addr" value="${info.addr}">
                        </td>						
                    </tr>
                    <tr>
                        <th class="text-right essential-item">제출용도</th>
                        <td>
                            <input type="text" class="form-control width240px rb" id="submit_text" name="submit_text" required="required" value="${info.submit_text}">
                        </td>		
                        <th class="text-right essential-item">신청매수</th>
                        <td>
                            <input type="text" class="form-control width60px rb" id="apply_cnt" name="apply_cnt" required="required" min="1" datatype="int" value="${info.apply_cnt}">
                        </td>							
                    </tr>			
                </tbody>
            </table>				
<!-- /폼테이블 -->	
<!-- 하단 내용 -->                  
            <div class="doc-com width750px">
                <div class="text">
                    위와 같이 재직증명서를 신청 하오니 재가하여 주시기 바랍니다.<br>
                    ${info.doc_dt.substring(0,4)}년 ${info.doc_dt.substring(4,6)}월 ${info.doc_dt.substring(6,8)}일
                </div>
                <div class="detail-info">
                    부서 : ${info.org_name}<br>
                    성명 : ${info.mem_name}
                </div> 
            </div>			
<!-- /하단 내용 -->	
			<div class="btn-group mt10">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>	
				</div>
			</div>
        </div>
    </div>
<!-- /팝업 -->	
</form>
</body>
</html>