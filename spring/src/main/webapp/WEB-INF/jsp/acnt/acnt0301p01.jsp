<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 매출관리 > 세금계산서관리 > null > 세금계산서 추가발행
-- 작성자 : 박예진
-- 최초 작성일 : 2020-04-08 18:03:57
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var isCust = false;
	
		function goCustInfoClick() {
			var param = {
					s_cust_no : $M.getValue("cust_name")
			};
			openSearchCustPanel('fnSetCustInfo', $M.toGetParam(param));
		}	
	
		function fnSetCustInfo(data) {
			isCust = true;
			$M.goNextPageAjax(this_page + "/custInfo/" + data.cust_no, "", {method : 'GET'},
				function(result) {
		    		if(result.success) {
		    			var info = result.info;
		    			$M.setValue(info);
		    			$M.setValue("norl_email", info.taxbill_email);
					}
				}
			);
		}
		
		// 사업자명세 팝업
		function goBregSpecInfo() {
			if($M.getValue("cust_no") == "") {
				alert("고객을 검색하여 먼저 입력해주세요.");
				return false;
			}
			var param = {
	    			 "s_cust_no" : $M.getValue("cust_no")
	    	  };
	    	  openSearchBregSpecPanel("fnSetBregSpec", $M.toGetParam(param));
		}
		
		// 사업자명세
	    function fnSetBregSpec(row) {
	    	 var param = {
	 	        	"breg_name" : row.breg_name,
	 	        	"breg_no" : row.breg_no,
	 	        	"breg_rep_name" : row.breg_rep_name,
	 	        	"breg_cor_type" : row.breg_cor_type,
	 	        	"breg_cor_part" : row.breg_cor_part,
	 	        	"breg_seq" : row.breg_seq,
	 	        	"biz_post_no" : row.biz_post_no,
	 	        	"biz_addr1" : row.biz_addr1,
	 	        	"biz_addr2" : row.biz_addr2,
	 	        };
	 	        $M.setValue(param);
	    }
		
		// 문자발송
		function fnSendSms() {
			var param = {
					"name" : $M.getValue("cust_name"),
					"hp_no" : $M.getValue("cust_hp_no")
			}
			openSendSmsPanel($M.toGetParam(param));
		}
	
		// 이메일1 전송
		function fnSendEmail() {
			var email = $M.getValue("email");
			var param = {
					"to" : email
			};
			openSendEmailPanel($M.toGetParam(param));
		}
		
		// 이메일2 전송
		function fnSendNorlEmail() {
			var norlEmail =  $M.getValue("norl_email");
			var param = {
					"to" : norlEmail
			};
			openSendEmailPanel($M.toGetParam(param));
		}
		
		// 전표조회
		function goSearchInout() {
			var params = {
					"taxbill_no" : $M.getValue("taxbill_no")
			};
			var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=900, height=360, left=0, top=0";
			$M.goNextPage('/acnt/acnt0301p03', $M.toGetParam(params), {popupStatus : popupOption});
		}
		
		// 합계금액 계산
		function fnCalcTotalAmt() {
			var vatAmt = $M.toNum($M.getValue("taxbill_amt")) * 0.1;
			$M.setValue("vat_amt", vatAmt); 
			
			var totalAmt = $M.toNum($M.getValue("taxbill_amt")) + $M.toNum($M.getValue("vat_amt"));
			$M.setValue("total_amt", totalAmt); 
		}
		
		function goSave() {
	    	var frm = document.main_form;
	    	
		  	// validation check
	     	if($M.validation(frm) === false) {
	     		return;
	     	};

	     	$M.goNextPageAjaxSave(this_page + '/save', $M.toValueForm(frm) , {method : 'POST'},
					function(result) {
						if(result.success) {
							alert("저장이 완료되었습니다.");
							window.opener.location.reload();
							fnClose();
						}
					}
				);
	    	
	    }
		
		
		// 닫기
		function fnClose() {
			window.close();
		}
		
		
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" id="cust_fax_no" name="cust_fax_no">
<input type="hidden" id="cust_no" name="cust_no">
<input type="hidden" id="breg_seq" name="breg_seq">
<input type="hidden" id="sale_mem_no" name="sale_mem_no">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
           <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">	
<!-- 폼테이블 -->				
			<div>
				<div class="title-wrap">
					<h4>세금계산서관리</h4>
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
							<th class="text-right">발행번호</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width130px">
										<input type="text" class="form-control" readonly="readonly" id="taxbill_no" name="taxbill_no">
									</div>
									<div class="col width10px">
										-
									</div>
									<div class="col width30px">
										<input type="text" class="form-control" readonly="readonly" id="taxbill_control_no" name="taxbill_control_no">	
									</div>
								</div>
							</td>	
							<th class="text-right essential-item">발행일자</th>
							<td>
								<div class="input-group width120px">
									<input type="text" class="form-control border-right-0 calDate rb" id="taxbill_dt" name="taxbill_dt" dateformat="yyyy-MM-dd" alt="발행일자" required="required" value="${inputParam.s_current_dt}">
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">고객명</th>
							<td>
								<div class="input-group">
									<input type="text" class="form-control border-right-0 width120px" id="cust_name" name="cust_name" required="required" alt="고객명" readonly="readonly">
									<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goCustInfoClick();"><i class="material-iconssearch"></i></button>							
								</div>
							</td>
							<th class="text-right">연락처</th>
							<td>
								<div class="input-group width140px">
									<input type="text" class="form-control border-right-0" id="cust_hp_no" name="cust_hp_no" readonly="readonly">
									<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSendSms();"><i class="material-iconsforum"></i></button>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">마케팅담당자</th>
							<td>
								<input type="text" class="form-control width120px" readonly="readonly" id="sale_mem_name" name="sale_mem_name">
							</td>
							<th class="text-right">업체명</th>
							<td>
								<input type="text" class="form-control" readonly="readonly" id="breg_name" name="breg_name">
							</td>
						</tr>
						<tr>
							<th class="text-right">사업자No</th>
							<td>
								<div class="input-group width200px">
									<input type="text" class="form-control border-right-0" readonly="readonly" id="breg_no" name="breg_no">
									<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goBregSpecInfo();"><i class="material-iconssearch"></i></button>
								</div>
							</td>
							<th class="text-right">대표자</th>
							<td>
								<input type="text" class="form-control width120px" readonly="readonly" id="breg_rep_name" name="breg_rep_name">
							</td>
						</tr>
						<tr>
							<th class="text-right">업태</th>
							<td>
								<input type="text" class="form-control width120px" readonly="readonly" id="breg_cor_type" name="breg_cor_type">
							</td>
							<th class="text-right">종목</th>
							<td>
								<input type="text" class="form-control width160px" readonly="readonly" id="breg_cor_part" name="breg_cor_part">
							</td>
						</tr>
						<tr>
							<th class="text-right">주소</th>
							<td colspan="3">
								<div class="form-row inline-pd mb7">
									<div class="col-2">
										<input type="text" class="form-control" readonly="readonly" id="biz_post_no" name="biz_post_no">
									</div>
									<div class="col-10">
										<input type="text" class="form-control" readonly="readonly" id="biz_addr1" name="biz_addr1">
									</div>
								</div>
								<div class="form-row inline-pd">
									<div class="col-12">
										<input type="text" class="form-control" readonly="readonly" id="biz_addr2" name="biz_addr2">
									</div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">물품대</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width100px">
										<input type="text" class="form-control text-right rb" required="required" alt="물품대" id="taxbill_amt" name="taxbill_amt" format="decimal" onChange="javascript:fnCalcTotalAmt();">
									</div>
									<div class="col width22px">원</div>
								</div>
							</td>
							<th class="text-right">이메일1</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-8">
										<input type="text" class="form-control" id="email" name="email"  alt="이메일1">
									</div>
									<div class="col-4">
										<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSendEmail();"><i class="material-iconsmail"></i></button>	
									</div>									
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">부가세</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width100px">
										<input type="text" class="form-control text-right" id="vat_amt" name="vat_amt" format="decimal" onChange="javascript:fnCalcTotalAmt();">
									</div>
									<div class="col width22px">원</div>
								</div>
							</td>
							<th class="text-right">이메일2</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-8">
										<input type="text" class="form-control" id="norl_email" name="norl_email"  alt="이메일2">
									</div>
									<div class="col-4">
										<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSendNorlEmail();"><i class="material-iconsmail"></i></button>	
									</div>									
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">합계</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width100px">
										<input type="text" class="form-control text-right" readonly="readonly" id="total_amt" name="total_amt" format="decimal">
									</div>
									<div class="col width22px">원</div>
								</div>
							</td>
							<th class="text-right">영수구분</th>
							<td>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" value="1" id="taxbill_type_1" name="taxbill_type_cd">
									<label for="taxbill_type_1" class="form-check-label">영수</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" value="2" id="taxbill_type_2" name="taxbill_type_cd" checked="checked">
									<label for="taxbill_type_2" class="form-check-label">청구</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" value="3" id="taxbill_type_3" name="taxbill_type_cd">
									<label for="taxbill_type_3" class="form-check-label">카드발행</label>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">비고</th>
							<td colspan="3">
								<textarea class="form-control" style="height: 100px;" id="remark" name="remark"></textarea>
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">적요</th>
							<td colspan="3">
								<textarea class="form-control sale-rb" style="height: 100px;" id="desc_text" name="desc_text" required="required" alt="적요"></textarea>
							</td>
						</tr>																		
					</tbody>
				</table>
			</div>
<!-- /폼테이블 -->	
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