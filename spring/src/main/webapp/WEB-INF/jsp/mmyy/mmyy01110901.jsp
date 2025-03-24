<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 업무품의서 > 업무품의서 등록 > null
-- 작성자 : 황빛찬
-- 최초 작성일 : 2021-07-26 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
	// 목록
	function fnList() {
		var param = {
				"init_yn" : "Y"
			}
		$M.goNextPage("/mmyy/mmyy011109", $M.toGetParam(param));	
	}
	
	// 고객조회 팝업
	function goCustInfoClick() {
		var param = {
				s_cust_no : $M.getValue("cust_name")
		};
		openSearchCustPanel('fnSetCustInfo', $M.toGetParam(param));
	}
	
	// 고객정보 세팅
	function fnSetCustInfo(data) {
		$M.setValue("cust_no", data.cust_no);
		$M.setValue("cust_name", data.real_cust_name);
		$M.setValue("breg_seq", data.breg_seq);
		$M.setValue("breg_name", data.breg_name);
		$M.setValue("breg_no", data.real_breg_no);
		$M.setValue("real_breg_no", $M.bregNoFormat(data.real_breg_no));
		$M.setValue("hp_no", data.real_hp_no);
		$M.setValue("real_hp_no", $M.phoneFormat(data.real_hp_no));
		$M.setValue("post_no", data.post_no);
		$M.setValue("addr1", data.addr1);
		$M.setValue("addr2", data.addr2);
	}
	
	// 결재요청
	function goRequestApproval() {
		goSave('requestAppr');
	}
	
	// 저장
	function goSave(isRequestAppr) {
		// validation check
		if($M.validation(document.main_form) == false) {
			return;
		};
		
		if ($M.getValue("doc_amt") == "0") {
			alert("품의금액은 필수입력 입니다.");
			return;
		}
		
		var msg = "";
		if (isRequestAppr != undefined) {
			$M.setValue("save_mode", "appr"); // 결재요청
			msg = "결재요청 하시겠습니까?";
		} else {
			$M.setValue("save_mode", "save"); // 저장
			msg = "저장 하시겠습니까?";
		}
		
		var frm = $M.toValueForm(document.main_form);
		console.log("frm : ", frm);
		
		$M.goNextPageAjaxMsg(msg, this_page + "/save", frm , {method : 'POST'},
			function(result) {
	    		if(result.success) {
	    			fnList();
				}
			}
		);
	}
	
	</script>
</head>
<body>
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
						<h2>마일리지 지급품의서 등록</h2>
                    </div>
<!-- 결재영역 -->
                    <div class="pl10">
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
                                <th class="text-right">작성일자</th>
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
                                <th class="text-right">직책</th>
                                <td>
                                    <input type="text" class="form-control width120px" readonly id="grade_name" name="grade_name" value="${info.grade_name}">
                                    <input type="hidden" id="grade_cd" name="grade_cd" value="${info.grade_cd}">
                                    <input type="hidden" id="job_cd" name="job_cd" value="${info.job_cd}">
                                </td>							
                            </tr>
                            <tr>
                                <th class="text-right essential-item">구분</th>
                                <td colspan="3">
                                    <div class="form-check form-check-inline">
                                        <input class="form-check-input" type="radio" id="doc_job_sales" name="doc_job_cd" value="01" checked="checked">
                                        <label class="form-check-label" for="doc_job_sales">마케팅</label>
                                    </div>
                                    <div class="form-check form-check-inline">
                                        <input class="form-check-input" type="radio" id="doc_job_report" name="doc_job_cd" value="02">
                                        <label class="form-check-label" for="doc_job_report">정비지시서</label>
                                    </div>
                                    <div class="form-check form-check-inline">
                                        <input class="form-check-input" type="radio" id="doc_job_part" name="doc_job_cd" value="03">
                                        <label class="form-check-label" for="doc_job_part">수주</label>
                                    </div>
                                    <div class="form-check form-check-inline">
                                        <input class="form-check-input" type="radio" id="doc_job_rental" name="doc_job_cd" value="04">
                                        <label class="form-check-label" for="doc_job_rental">렌탈</label>
                                    </div>
                                </td>						
                            </tr>
                            <tr>
                                <th class="text-right essential-item">제목</th>
                                <td colspan="3">
                                    <input type="text" class="form-control rb" id="title" name="title" required="required" alt="제목">
                                </td>						
                            </tr>	                            
                            <tr>
                                <th class="text-right essential-item">품의사유</th>
                                <td colspan="3">
                                    <textarea class="form-control rb" style="height: 70px;" placeholder="내용을 입력하세요." id="reason_text" name="reason_text" alt="품의사유" required="required"></textarea>
                                </td>						
                            </tr>		
               				<tr>
                                <th class="text-right essential-item">마일리지 금액</th>
                                <td colspan="3">
									<div class="form-row inline-pd widthfix">
										<div class="col width140px">
		                                   	<input type="text" class="form-control rb text-right width140px" id="doc_amt" name="doc_amt" required="required" alt="품의금액" format="num">
										</div>
										<div class="col width16px">원</div>
									</div>	                                
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
	                                    <input type="text" class="form-control width140px rb" readonly="readonly" id="cust_name" name="cust_name" required="required" alt="고객">
	                                    <button type="button" class="btn btn-icon btn-primary-gra mr3 agencyY" onclick="javascript:goCustInfoClick();"><i class="material-iconssearch"></i></button>
	                                    <input type="hidden" id="cust_no" name="cust_no">
                                	</div>
                                </td>		
                                <th class="text-right essential-item">휴대전화</th>
                                <td>
                                    <input type="text" class="form-control width140px" readonly id="real_hp_no" name="real_hp_no" required="required" alt="휴대전화">
                                    <input type="hidden" id="hp_no" name="hp_no">
                                </td>							
                            </tr>
                            <tr>
                                <th class="text-right">업체명</th>
                                <td>
                                    <input type="text" class="form-control width140px" readonly id="breg_name" name="breg_name">
                                </td>		
                                <th class="text-right">사업자번호</th>
                                <td>
                                    <input type="text" class="form-control width140px" readonly id="real_breg_no" name="real_breg_no">
                                    <input type="hidden" id="breg_no" name="breg_no">
                                    <input type="hidden" id="breg_seq" name="breg_seq">
                                </td>							
                            </tr>
							<tr>
								<th class="text-right">주소</th>
								<td colspan="3">
									<div class="form-row inline-pd mb7">
										<div class="col-12">
											<input type="text" class="form-control" readonly="readonly" id="addr1" name="addr1">
											<input type="hidden" id="post_no" name="post_no">
										</div>
									</div>
									<div class="form-row inline-pd">
										<div class="col-12">
											<input type="text" class="form-control" readonly="readonly" id="addr2" name="addr2">
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
                            위와 같이 품의서를 신청 하오니 재가하여 주시기 바랍니다<br>
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