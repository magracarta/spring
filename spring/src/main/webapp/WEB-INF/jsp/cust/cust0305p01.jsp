<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 거래현황 > 할인쿠폰관리 > null > 할인쿠폰상세
-- 작성자 : 박준영
-- 최초 작성일 : 2020-09-29 10:52:26
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		
		$(document).ready(function() {
			// 업무품의서에 의해 발행된 쿠폰은 수정, 삭제 불가.
			if ($M.getValue("coupon_issue_cd") == "04") {
				$("#main_form :input").prop("disabled", true);
				$("#main_form :button[onclick='javascript:fnClose();']").prop("disabled", false);
			}
		});
	
	 	// 문자발송
		function fnSendSms() {
			var param = {
					  name : $M.getValue("cust_name"),
					  hp_no : $M.getValue("cust_hp_no")
			  }
			openSendSmsPanel($M.toGetParam(param));
		}
	
	
	    function goModify() {
	    	if ($M.getValue("coupon_issue_cd") == "04") {
	    		alert("업무품의서에서 발행된 쿠폰입니다.\n수정이 불가능 합니다.");
	    		return;
	    	}
	    	    	
	    	var param = {
					"cust_coupon_no" : $M.getValue("cust_coupon_no")
			};
	    	
	    	$M.goNextPageAjax(this_page+"/chkCouponStat", $M.toGetParam(param), {method : "post"},
				function(result) {
		    		if(result.success) {
    						if(result.coupon_use_yn == "Y"){
	    						alert("사용하지 않은 쿠폰만 수정가능합니다.");
	    						return;
    						}
    						
    						if(result.expire_yn == "Y"){
    							alert("마감되지 않은 쿠폰만 수정가능합니다.");
    							return;
    						}
    						
    						var frm = document.main_form;
    						
    					  	// validation check
    				     	if($M.validation(frm) === false) {
    				     		return;
    				     	};
    						
    						if ($M.getValue("expire_plan_dt") <= $M.getValue("inout_dt") ){
    							alert("소멸예정일은 전표일자 이후로만 지정 가능합니다.");
    							return;
    						}
    				     	
    						
    						frm = $M.toValueForm(frm);
    						console.log("frm : ", frm);
    						
    						$M.goNextPageAjaxModify(this_page + "/modify", frm, {method : 'POST'}, 
    							function(result) {
    								if(result.success) {
    									alert("처리가 완료되었습니다.");
    									fnClose();
    					    			window.opener.goSearch();
    								};
    							}
    						);  
    						return;
		    		}
		    		else {
		    			alert("올바르지 않은 정보입니다.");
		    			return;
		    		}
				}
			);
		
		
	    }

	    function goRemove() {
	    	if ($M.getValue("coupon_issue_cd") == "04") {
	    		alert("업무품의서에서 발행된 쿠폰입니다.\n삭제가 불가능 합니다.");
	    		return;
	    	}
	    	
			var param = {
					"cust_coupon_no" : $M.getValue("cust_coupon_no")
			};
			
			$M.goNextPageAjax(this_page+"/chkCouponStat", $M.toGetParam(param), {method : "post"},
					function(result) {
			    		if(result.success) {
			    			
    						if(result.coupon_use_yn == "Y"){
	    						alert("사용하지 않은 쿠폰만 삭제가능합니다.");
	    						return;
    						}
    						
    						if(result.expire_yn == "Y"){
    							alert("마감되지 않은 쿠폰만 삭제가능합니다.");
    							return;
    						}
    						
    						var frm = document.main_form;
    						
    						frm = $M.toValueForm(frm);
    						console.log("frm : ", frm);
    						
    						$M.goNextPageAjaxRemove(this_page + "/remove", frm, {method : 'POST'}, 
    							function(result) {
    								if(result.success) {
    									alert("삭제에 성공했습니다.");
    									fnClose();
    					    			window.opener.goSearch();
    								};
    							}
    						);
    						return;
	    						
			    		}
			    		else {
			    			alert("올바르지 않은 정보입니다.");
			    			return;
			    		}
					}
				);				
	    }
	    
		function fnClose() {
			window.close();
		}
		
		// 쿠폰품의서 상세 호출
		function goCouponDocDetail() {
			var param = {
					doc_no : $M.getValue("doc_no")
				};
					
			var popupOption = "";
			$M.goNextPage('/mmyy/mmyy011109p01', $M.toGetParam(param), {popupStatus : popupOption});
		}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" id="coupon_issue_cd" name="coupon_issue_cd" value="${custCoupon.coupon_issue_cd}">
<input type="hidden" id="doc_no" name="doc_no" value="${custCoupon.doc_no}">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
        <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">     
        	<input type="hidden" id="cust_coupon_no" 	name="cust_coupon_no" 	value="${custCoupon.cust_coupon_no}" >
<!-- 폼테이블 -->					
			<div>
				<div class="title-wrap">
					<div class="left">
						<h4>할인쿠폰전표처리</h4>
						<c:choose>
                       		<c:when test="${custCoupon.doc_no ne ''}">
								&nbsp;&nbsp;<a href="javascript:goCouponDocDetail();" style="text-decoration : underline; color:black; vertical-align: middle;">(쿠폰품의번호 : ${custCoupon.doc_no})</a>
                       		</c:when>
                       	</c:choose>						
					</div>
				</div>
				<div>
					<table class="table-border mt5">
						<colgroup>
							<col width="100px">
							<col width="">
							<col width="100px">
							<col width="">
						</colgroup>
						<tbody>
							<tr>
								<th class="text-right">전표번호</th>
								<td>										
									<input type="text" class="form-control width120px"  id="inout_doc_no" name="inout_doc_no" value="${custCoupon.inout_doc_no}" readonly="readonly" >
								</td>
								<th class="text-right">전표일자</th>
								<td>
									<div class="input-group width120px">
										<input type="text" class="form-control border-right-0 calDate" id="inout_dt" name="inout_dt" value="${custCoupon.inout_dt}"  ${custCoupon.end_yn == 'Y'? 'disabled="disabled"' : ''} required="required" dateformat="yyyy-MM-dd" alt="전표일자" >
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right">고객명</th>
								<td>
									<div class="input-group">
										<input type="text" class="form-control border-right-0 width100px" id="cust_name" 	name="cust_name" 	value="${custCoupon.cust_name}"  readonly="readonly"  >
										<input type="hidden" id="cust_no" 	name="cust_no" 	value="${custCoupon.cust_no}" >
										<button type="button" class="btn btn-icon btn-primary-gra" disabled="disabled" onclick="javascript:openSearchCustPanel('fnSetCustInfo');"><i class="material-iconssearch"></i></button>
								</div>
								</td>
								<th class="text-right">연락처</th>
								<td>
									<div class="input-group">
										<input type="text" class="form-control border-right-0 width100px" id="cust_hp_no" name="cust_hp_no"  value="${custCoupon.cust_hp_no}"  alt="연락처" readonly="readonly"  >
										<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSendSms();" ><i class="material-iconsforum"></i></button>
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right">담당자</th>
								<td>
									<input type="text" class="form-control width120px" id="sale_mem_name" name="sale_mem_name" value="${custCoupon.sale_mem_name}" readonly="readonly" >
								</td>
								<th class="text-right">처리자</th>
								<td>
									<input type="text" class="form-control width120px" id="reg_name" name="reg_name" value="${custCoupon.reg_name}" readonly="readonly" >
								</td>
							</tr>
							<tr>
								<th class="text-right">업체명</th>
								<td>
									<input type="text" class="form-control width120px" id="breg_name" name="breg_name" value="${custCoupon.breg_name}" readonly="readonly" >
								</td>
								<th class="text-right">대표자</th>
								<td>
									<input type="text" class="form-control width120px" id="breg_rep_name" name="breg_rep_name" value="${custCoupon.breg_rep_name}" readonly="readonly" >
								</td>
							</tr>
							<tr>
								<th class="text-right">사업자No</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width160px">
											<input type="text" class="form-control" id="breg_no" name="breg_no" value="${custCoupon.breg_no}" readonly="readonly" >
										</div>
										<div class="col width60px">
											<button type="button" class="btn btn-primary-gra" disabled="disabled" onclick="javasctipt:openSearchBregInfoPanel('fnSetBregInfo');">변경</button>
										</div>
									</div>										
								</td>
								<th class="text-right">입금자</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width120px">
											<input type="text" class="form-control" id="deposit_name" name="deposit_name" value="${custCoupon.deposit_name}" readonly="readonly" >
										</div>
										<div class="col-auto" id="btnChange" disabled="disabled">
											<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_M"/></jsp:include>
										</div>
									</div>	
								</td>
							</tr>
							<tr>
								<th class="text-right">주소</th>
								<td colspan="3">
									<div class="form-row inline-pd mb7 widthfix">
										<div class="col-2">
											<input type="text" class="form-control" id="biz_post_no" name="biz_post_no" value="${custCoupon.biz_post_no}" readonly="readonly" >
										</div>
										<div class="col-10">
											<input type="text" class="form-control" id="biz_addr1" name="biz_addr1" value="${custCoupon.biz_addr1}" readonly="readonly" >
										</div>
									</div>
									<div class="form-row inline-pd">
										<div class="col-12">
											<input type="text" class="form-control" id="biz_addr2" name="biz_addr2" value="${custCoupon.biz_addr2}" readonly="readonly" >
										</div>
									</div>
								</td>
							</tr>	
							<tr>
								<th class="text-right">쿠폰금액</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width120px">
											<input type="text" class="form-control text-right" id="coupon_amt" name="coupon_amt" value="${custCoupon.coupon_amt}"  ${custCoupon.end_yn == 'Y'? 'readonly="readonly"' : ''} alt="쿠폰금액" datatype="int" format="decimal" >
										</div>
										<div class="col width16px">원</div>
									</div>
								</td>
								<th class="text-right">쿠폰 잔액</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width120px">
											<input type="text" class="form-control text-right" id="balance_amt" name="balance_amt" value="${custCoupon.balance_amt}" datatype="int" format="decimal"  readonly="readonly">
										</div>
										<div class="col width16px">원</div>
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right">소멸예정일</th>
								<td>
									<div class="input-group width120px">
										<input type="text" class="form-control border-right-0 calDate" id="expire_plan_dt" name="expire_plan_dt" dateformat="yyyy-MM-dd" alt="" ${custCoupon.end_yn == 'Y'? 'disabled="disabled"' : ''}  required="required" value="${custCoupon.expire_plan_dt}" >
									</div>
								</td>
								<th class="text-right">쿠폰 현 잔액</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width120px">
											<input type="text" class="form-control text-right" id="sum_balance_amt" name="sum_balance_amt" datatype="int" format="decimal"  value="${custCoupon.sum_balance_amt}"  readonly="readonly">
										</div>
										<div class="col width16px">원</div>
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right">최종메모</th>
								<td colspan="3">
									<textarea class="form-control" readonly="readonly"     style="height: 50px;">${custCoupon.last_memo}</textarea>
								</td>
							</tr>
							<tr>
								<th class="text-right">비고</th>
								<td colspan="3">
									<textarea class="form-control"   id="remark" name="remark" ${custCoupon.end_yn == 'Y'? 'readonly="readonly"' : ''}  style="height:50px;">${custCoupon.remark}</textarea>
								</td>
							</tr>
							<tr>
								<th class="text-right">적요</th>
								<td colspan="3">
									<textarea class="form-control"   id="desc_text" name="desc_text"  ${custCoupon.end_yn == 'Y'? 'readonly="readonly"' : ''}  style="height:50px;">${custCoupon.desc_text}</textarea>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
			</div>
<!-- /폼테이블-->					
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