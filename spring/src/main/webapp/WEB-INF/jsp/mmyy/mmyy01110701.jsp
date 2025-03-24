<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 경력증명서 > 경력증명서 등록 > null
-- 작성자 : 황빛찬
-- 최초 작성일 : 2021-05-10 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
	var memNo = '${SecureUser.mem_no}';
	
	$(document).ready(function() {
		var data = ${infoJson}
		
		console.log("data : ", data);
		// 관리부가 아닐경우 신청자 disabled 처리 및 기본 데이터 세팅
		if ('${page.fnc.F02025_001}' != 'Y') {
			$("#s_web_id").prop("disabled", true);
			$('[name="__mem_search_btn"]').prop("disabled", true);
		}
			
			$M.setValue("___mem_name", data.kor_name);
			$M.setValue("s_web_id", data.web_id);
			$M.setValue("apply_mem_no", data.mem_no);
			$M.setValue("org_code", data.org_code);
			$M.setValue("org_name", data.org_name);
			$M.setValue("grade_cd", data.grade_cd);
			$M.setValue("grade_name", data.grade_name);
			$M.setValue("job_cd", data.job_cd);
			$M.setValue("hp_no", data.hp_no);
			$M.setValue("ipsa_dt", data.ipsa_dt);
			$M.setValue("retire_dt", data.retire_dt);
			$M.setValue("home_post_no", data.home_post_no);
			$M.setValue("home_addr1", data.home_addr1);
			$M.setValue("home_addr2", data.home_addr2);
			$M.setValue("addr", data.home_addr1 + ' ' + data.home_addr2);
			$("#org_name_text").html(data.org_name);
			$("#reg_mem_name_text").html(data.kor_name);
		
		
	});
	
	function fnList() {
// 		history.back();
		
		var param = {
				"init_yn" : "Y"
			}
		$M.goNextPage("/mmyy/mmyy011107", $M.toGetParam(param));
	}
	
	// 직원조회
	// 관리부일경우 신청자 선택하여 정보 세팅.
	function setMemberOrgMapPanel(data) {
// 		$M.setValue("mem_name", data.mem_name);
// 		$M.setValue("mem_no", data.mem_no);
		$M.setValue("apply_mem_no", data.mem_no);
		$M.setValue("org_code", data.org_code);
		$M.setValue("org_name", data.org_name);
		$M.setValue("grade_cd", data.grade_cd);
		$M.setValue("grade_name", data.grade_name);
		$M.setValue("job_cd", data.job_cd);
		$M.setValue("hp_no", data.hp_no_real);
		$M.setValue("ipsa_dt", data.ipsa_dt);
		$M.setValue("retire_dt", data.retire_dt);
		$M.setValue("home_post_no", data.home_post_no);
		$M.setValue("home_addr1", data.home_addr1);
		$M.setValue("home_addr2", data.home_addr2);
		$M.setValue("addr", data.home_addr1 + ' ' + data.home_addr2);
		$("#org_name_text").html(data.org_name);
		$("#reg_mem_name_text").html(data.mem_name);
	}
	
	// 결재요청
	function goRequestApproval() {
		if ($M.getValue("apply_mem_no") != $M.getValue("mem_no")) {
			alert("작성자와 신청자가 다를 경우 저장 후 \n상세에서 회사의견 입력 후 결재를 진행 해 주시기 바랍니다.");
			return;
		}
		
		goSave('requestAppr');
	}
	
	// 저장
	function goSave(isRequestAppr) {
		if ($M.getValue("apply_mem_no") == "") {
			alert("신청자는 필수 입력입니다.")
			return;
		}
		
		// validation check
		if($M.validation(document.main_form) == false) {
			return;
		};

		var frm = document.main_form;
		
		console.log("frm : ", frm);
		
		var msg = "";
		if (isRequestAppr != undefined) {
			$M.setValue("save_mode", "appr"); // 결재요청
			msg = "결재요청 하시겠습니까?";
		} else {
			$M.setValue("save_mode", "save"); // 저장
			msg = "저장 하시겠습니까?";
		}
		
		console.log($M.toValueForm(frm));
		
		$M.goNextPageAjaxMsg(msg, this_page + "/save", $M.toValueForm(frm) , {method : 'POST'},
			function(result) {
	    		if(result.success) {
	    			fnList();
				}
			}
		);
	}

    function fnChangeGradeCd(obj) {
        $M.setValue("job_cd", obj.value);
    }
	
	</script>
</head>
<body style="background : #fff">
<form id="main_form" name="main_form">
<div class="layout-box">
<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
<!-- 상세페이지 타이틀 -->
				<div class="main-title detail width780px">
					<div class="detail-left">
						<button type="button" class="btn btn-outline-light" onclick="javascript:fnList()"><i class="material-iconskeyboard_backspace text-default"></i></button>
<%-- 						<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/> --%>
						<h2>경력증명서 등록</h2>
                    </div>
<!-- 결재영역 -->
					<div class="p10" style="margin-left: 10px;">
						<jsp:include page="/WEB-INF/jsp/common/apprHeader.jsp"></jsp:include>
					</div>
<!-- /결재영역 -->
				</div>
<!-- /상세페이지 타이틀 -->
				<div class="contents">
<!-- 폼테이블 -->					
                    <table class="table-border width750px">
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
                                    <input type="text" class="form-control width120px" readonly id="mem_name" name="mem_name" value="${info.kor_name}">
                                    <input type="hidden" id="mem_no" name="mem_no" value="${info.mem_no}">
                                </td>		
                                <th class="text-right">작성일</th>
                                <td>
                                    <input type="text" class="form-control width120px" readonly id="doc_dt" name="doc_dt" value="${inputParam.s_current_dt}" dateformat="yyyy-MM-dd">
                                </td>							
                            </tr>
                            <tr>
                                <th class="text-right essential-item">신청자</th>
                                <td>
                                    <div class="form-row inline-pd widthfix">
                                        <div class="col width280px">
											<jsp:include page="/WEB-INF/jsp/common/searchMem.jsp">
		                                        <jsp:param name="execFuncName" value="setMemberOrgMapPanel"/>
		                                        <jsp:param name="s_work_status_cd" value="01#04"/>
		                                    </jsp:include>
                                        </div>
                                    </div>
                                    <input type="hidden" id="apply_mem_no" name="apply_mem_no">
                                </td>	
                                <th class="text-right essential-item">매수</th>
                                <td>
                                    <input type="text" class="form-control width40px essential-bg" id="apply_cnt" name="apply_cnt" required="required" min="1" datatype="int" value="1">
                                </td>					
                            </tr>                            
                            <tr>
                                <th class="text-right">부서</th>
                                <td>
                                    <input type="text" class="form-control width120px" readonly id="org_name" name="org_name">
                                    <input type="hidden" id="org_code" name="org_code">
                                </td>		
                                <th class="text-right essential-item">직위</th>
                                <td>
                                    <select class="form-control width120px essential-bg" id="grade_cd" name="grade_cd" required="required" alt="직위" onchange="fnChangeGradeCd(this);">
                                        <option value="">- 선택 -</option>
                                        <c:forEach items="${codeMap['GRADE']}" var="item">
                                            <option value="${item.code_value}">${item.code_name}</option>
                                        </c:forEach>
                                    </select>
                                    <input type="hidden" type="text" id="job_cd" name="job_cd">
                                </td>
                            </tr>
                            <tr>
                                <th class="text-right">연락처</th>
                                <td>
                                    <input type="text" class="form-control width120px" readonly id="hp_no" name="hp_no" format="phone">
                                </td>			
                                <th class="text-right essential-item">직무</th>
                                <td>
                                    <input type="text" class="form-control width120px essential-bg" id="jjob_text" name="jjob_text" required="required">
                                </td>							
                            </tr>
                            <tr>
                                <th class="text-right">입사일</th>
                                <td>
                                    <input type="text" class="form-control width120px" id="ipsa_dt" name="ipsa_dt" readonly dateformat="yyyy-MM-dd">
                                </td>		
                                <th class="text-right">퇴사일</th>
                                <td>
                                    <input type="text" class="form-control width120px" id="retire_dt" name="retire_dt" readonly dateformat="yyyy-MM-dd">
                                </td>							
                            </tr>
                            <tr>
                                <th class="text-right">주소</th>
                                <td colspan="3">
                                    <input type="text" class="form-control" readonly id="addr" name="addr">
                                    <input type="hidden" id="home_post_no" name="home_post_no">
                                    <input type="hidden" id="home_addr1" name="home_addr1">
                                    <input type="hidden" id="home_addr2" name="home_addr2">
                                </td>							
                            </tr>
<%--                             <c:if test="${page.fnc.F02025_001 eq 'Y'}"> --%>
<!-- 	                            <tr> -->
<!-- 	                                <th class="text-right">회사의견</th> -->
<!-- 	                                <td colspan="3"> -->
<!-- 	                                    <textarea class="form-control" placeholder="회사의견이 들어갑니다." alt="회사의견" style="height: 70px;" id="cmp_text" name="cmp_text"></textarea> -->
<!-- 	                                </td>						 -->
<!-- 	                            </tr>				 -->
<%--                             </c:if> --%>
                        </tbody>
                    </table>				
<!-- /폼테이블 -->	
<!-- 하단 내용 -->                  
                    <div class="doc-com width750px">
                        <div class="text">
                            상기와 같은 용도로 경력증명서를 신청합니다.<br>
                            ${inputParam.s_current_dt.substring(0,4)}년 ${inputParam.s_current_dt.substring(4,6)}월 ${inputParam.s_current_dt.substring(6,8)}일
                        </div>
                        <div class="detail-info">
                            부서 : <span id="org_name_text"></span><br>
                            성명 : <span id="reg_mem_name_text"></span>
                        </div> 
                    </div>			
<!-- /하단 내용 -->
					<div class="btn-group mt10 width750px">
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
					</div>
				</div>						
			</div>		
		</div>
<!-- /contents 전체 영역 -->
</div>
</form>	
</body>
</html>