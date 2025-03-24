<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 재직증명서 > 재직증명서 등록 > null
-- 작성자 : 황빛찬
-- 최초 작성일 : 2021-05-10 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

	// 신청
	function goAppProcessing() {
		if (confirm("신청하시겠습니까?") == false) {
			return false;
		}
		
		goSave("Y");
	}
	
	// 저장
	function goSave(val) {
		var frm = document.main_form;
		
		// validation check
		if($M.validation(document.main_form) == false) {
			return;
		};
		
		if (val == "Y") {
			// 신청
			$M.setValue("appr_yn", "Y");
			$M.goNextPageAjax(this_page + "/save", $M.toValueForm(frm) , {method : 'POST'},
				function(result) {
		    		if(result.success) {
		    			fnList();
					}
				}
			);
		} else {
			// 일반저장
			$M.setValue("appr_yn", "N");
			$M.goNextPageAjaxSave(this_page + "/save", $M.toValueForm(frm) , {method : 'POST'},
				function(result) {
		    		if(result.success) {
		    			fnList();		    			
					}
				}
			);
		}
	}
	
	// 목록
	function fnList() {
// 		history.back();
		
		var param = {
				"init_yn" : "Y"
			}
		$M.goNextPage("/mmyy/mmyy011106", $M.toGetParam(param));
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
						<h2>재직증명서 등록</h2>
                    </div>
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
                                <th class="text-right">부서</th>
                                <td>
                                    <input type="text" class="form-control width120px" readonly id="org_name" name="org_name" value="${info.org_name}">
                                    <input type="hidden" id="org_code" name="org_code" value="${info.org_code}">
                                </td>		
                                <th class="text-right">직위</th>
                                <td>
                                    <input type="text" class="form-control width120px" readonly id="grade_name" name="grade_name" value="${info.grade_name}">
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
                                    <input type="text" class="form-control width120px" id="ipsa_dt" name="ipsa_dt" readonly value="${info.ipsa_dt}" dateformat="yyyy-MM-dd">
                                </td>							
                            </tr>
                            <tr>
                                <th class="text-right">주소</th>
                                <td colspan="3">
                                    <input type="text" class="form-control" readonly id="addr" name="addr" value="${info.addr}">
                                    <input type="hidden" id="home_post_no" name="home_post_no" value="${info.home_post_no}">
                                    <input type="hidden" id="home_addr1" name="home_addr1" value="${info.home_addr1}">
                                    <input type="hidden" id="home_addr2" name="home_addr2" value="${info.home_addr2}">
                                </td>						
                            </tr>
                            <tr>
                                <th class="text-right essential-item">제출용도</th>
                                <td>
                                    <input type="text" class="form-control width120px essential-bg" id="submit_text" name="submit_text" required="required">
                                </td>		
                                <th class="text-right essential-item">신청매수</th>
                                <td>
                                    <input type="text" class="form-control width40px essential-bg" id="apply_cnt" name="apply_cnt" required="required" min="1" datatype="int" value="1">
                                </td>							
                            </tr>			
                        </tbody>
                    </table>				
<!-- /폼테이블 -->	
<!-- 하단 내용 -->                  
                    <div class="doc-com width750px">
                        <div class="text">
                            상기와 같은 용도로 재직증명서를 신청합니다.<br>
                            ${inputParam.s_current_dt.substring(0,4)}년 ${inputParam.s_current_dt.substring(4,6)}월 ${inputParam.s_current_dt.substring(6,8)}일
                        </div>
                        <div class="detail-info">
                            부서 : ${info.org_name}<br>
                            성명 : ${info.kor_name}
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