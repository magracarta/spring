<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 부품판매 > 매출처리 > null > 매출처리(수주)
-- 작성자 : 박예진
-- 최초 작성일 : 2020-04-28 16:36:24
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var vatTreatCd = ${info}.vat_treat_cd;
		var saveYn = "N";
	// 처리구분이 세금계산서일 시에만 세금계산서 html 보이기
	// 처리구분이 건별, 합산, 발행보류일 시 세금계산서 html 숨기기
	
		$(document).ready(function() {
			// 권한에 따라 html 변경
			fnAuthChange();
			fnInitPage();

		});
		
// 		window.onbeforeunload = function() {
// 			if(saveYn != "Y") {
// 			    return false;
// 			} else {
// 				return true;
// 			}
// 		}
		function fnInitPage() {
			var info = ${info};
			$M.setValue(info);
			$M.setValue("print_breg_name", info.breg_name);
			$M.setValue("print_breg_rep_name", info.breg_rep_name);
			$M.setValue("print_inout_doc_no", info.inout_doc_no);
			$M.setValue("taxbill_type_cd", "2");	// 청구를 기본값으로
			
			if("${inputParam.early_return_yn}" == "Y" && vatTreatCd == "F") {
				$M.setValue("taxbill_send_cd", "5");
			}
		}
		
		// 권한에 따라 html 변경
 		function fnAuthChange() {
			if(vatTreatCd != "Y" && vatTreatCd != "F") {
				$(".vat-treat-y").hide();
				var vwidth = document.getElementById('main_form').clientWidth;
				var vheight = document.getElementById('main_form').clientHeight + 90;  
				window.resizeTo(vwidth,vheight);
			} else {
				$(".vat-treat-y").show();
			}
		} 
		
 		// 저장
		function goSave() {
			var frm = document.main_form;
			
	     	if(vatTreatCd == "Y") {
	     		if($M.getValue("taxbill_type_cd") == "") {
	     			alert("발급구분은 필수입력입니다.");
	     			return false;
	     		}
	     	}
	     	
			if($M.validation(frm) === false) {
	     		return;
	     	};
	     	
			frm = $M.toValueForm(document.main_form);
			
			var msg = "";
			
			if(vatTreatCd == "Y") {
				msg = confirm("세금계산서 발행 및 미수금 입금예정일을 처리하시겠습니까?");
			} else {
				msg = confirm("미수금 입금예정일을 처리하시겠습니까?");
			}
			if(!msg) {
				return false;
		    }

			$M.goNextPageAjax(this_page + "/save", frm, {method : 'POST'},
				function(result) {
			    	if(result.success) {
			    		fnClose();
// 			    		alert("정상 처리되었습니다.");
			    		
			    		// 매출처리 팝업으로 저장 시 페이지 닫아줌
			    		if("${inputParam.popup_yn}" != "Y") {
				    		opener.location.reload();
			    		} else {
			    			opener.fnDetail();
			    		}
					}
				}
			);
		}
	
		function fnClose() {
			window.close();
		}
		
		// 거래명세서 출력
        function goDocPrint() {
        	openReportPanel('cust/cust0202p01_01.crf','inout_doc_no=' + $M.getValue("inout_doc_no"));
        }
		
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" id="cust_no" name="cust_no">
<input type="hidden" id="cust_name" name="cust_name">
<input type="hidden" id="cust_fax_no" name="cust_fax_no">
<input type="hidden" id="cust_hp_no" name="cust_hp_no">
<input type="hidden" id="breg_seq" name="breg_seq">
<input type="hidden" id="breg_no" name="breg_no">
<input type="hidden" id="breg_cor_type" name="breg_cor_type">
<input type="hidden" id="breg_cor_part" name="breg_cor_part">
<input type="hidden" id="biz_addr1" name="biz_addr1">
<input type="hidden" id="biz_addr2" name="biz_addr2">
<input type="hidden" id="biz_post_no" name="biz_post_no">
<input type="hidden" id="dese_text" name="dese_text">
<input type="hidden" id="vat_amt" name="vat_amt">
<input type="hidden" id="email" name="email">
<input type="hidden" id="norl_email" name="norl_email">
<input type="hidden" id="deposit_old_dt" name="deposit_old_dt">
<input type="hidden" id="taxbill_no" name="taxbill_no">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
     	   <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
<!-- 세금계산서 -->	
			<div class="vat-treat-y">			
				<div class="title-wrap">
					<h4>세금계산서</h4>
				</div>				
				<table class="table-border mt5">
					<colgroup>
						<col width="100px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right">발행번호</th>
							<td>
								<input type="text" class="form-control width120px" readonly="readonly" id="" name="">
							</td>
						</tr>
						<tr>
							<th class="text-right">거래처</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width120px">
										<input type="text" class="form-control" readonly="readonly" id="breg_name" name="breg_name">
									</div>
									<div class="col width100px">
										<input type="text" class="form-control" readonly="readonly" id="breg_rep_name" name="breg_rep_name">
									</div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">물품대</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width100px">
										<input type="text" class="form-control text-right" readonly="readonly" format="decimal" id="taxbill_amt" name="taxbill_amt">	
									</div>
									<div class="col width33px">원</div>
								</div>	
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">발급구분</th>
							<td>
								<select class="form-control width140px rb" id="taxbill_type_cd" name="taxbill_type_cd" alt="발급구분">
									<option value="">- 선택 -</option>
									<c:forEach items="${codeMap['TAXBILL_TYPE']}" var="item">
									<option value="${item.code_value}">${item.code_name}</option>
									</c:forEach>
								</select>
							</td>
						</tr>
						<tr>
							<th class="text-right">수령구분</th>
							<td>
								<select class="form-control width140px" id="taxbill_send_cd" name="taxbill_send_cd" readonly="readonly">
									<option value="4">전자세금계산서</option>
									<option value="5">수정세금계산서</option>
								</select>
							</td>
						</tr>
						<tr>
							<th class="text-right">인쇄자</th>
							<td>${SecureUser.kor_name}</td>
						</tr>																		
					</tbody>
				</table>
			</div>
<!-- /세금계산서-->
<!-- 거래명세서 -->	
			<div>			
				<div class="title-wrap mt10">
					<h4>거래명세서</h4>
					<button type="button" class="btn btn-primary-gra"onclick="javascript:goDocPrint();"><i class="material-iconsprint text-primary"></i> 인쇄</button>	
				</div>				
				<table class="table-border mt5">
					<colgroup>
						<col width="100px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right">전표번호</th>
							<td>
								<input type="text" class="form-control width120px" id="print_inout_doc_no" name="print_inout_doc_no" readonly="readonly">
							</td>
						</tr>
						<tr>
							<th class="text-right">고객명</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width120px">
										<input type="text" class="form-control" readonly="readonly" id="print_breg_name" name="print_breg_name">
									</div>
									<div class="col width100px">
										<input type="text" class="form-control" readonly="readonly" id="print_breg_rep_name" name="print_breg_rep_name">
									</div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">발급구분</th>
							<td>거래명세서</td>
						</tr>
						<tr>
							<th class="text-right">금액</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width100px">
										<input type="text" class="form-control text-right" readonly="readonly" format="decimal" id="doc_amt" name="doc_amt">	
									</div>
									<div class="col width33px">원</div>
								</div>	
							</td>
						</tr>
						<tr>
							<th class="text-right">인쇄자</th>
							<td>${SecureUser.kor_name}</td>
						</tr>																		
					</tbody>
				</table>
			</div>
<!-- /거래명세서-->
<!-- 입금예정처리 -->	
			<div>			
				<div class="title-wrap mt10">
					<h4>입금예정처리</h4>
				</div>				
				<table class="table-border mt5">
					<colgroup>
						<col width="100px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right">전표번호</th>
							<td>
								<input type="text" class="form-control width120px" id="inout_doc_no" name="inout_doc_no" readonly="readonly">
							</td>
						</tr>
						<tr>
							<th class="text-right">미수금</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width100px">
										<input type="text" class="form-control text-right" readonly="readonly" format="decimal" id="ed_misu_amt" name="ed_misu_amt">	
									</div>
									<div class="col width33px">원</div>
								</div>	
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">입금예정일</th>
							<td>
								<div class="input-group">
									<input type="text" class="form-control border-right-0 calDate rb" id="deposit_plan_dt" name="deposit_plan_dt" dateformat="yyyy-MM-dd" alt="입금예정일" required="required" value="${inputParam.s_current_dt}">
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">처리자</th>
							<td>${SecureUser.kor_name}</td>
						</tr>																		
					</tbody>
				</table>
			</div>
<!-- /입금예정처리-->
			<div class="btn-group mt10">
				<div class="right">
				<div style="color:red; font-weight:600; float:left; font-size:14px;">
				※ 저장 버튼을 클릭하셔야 세금계산서가 발행됩니다.
				</div>
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>