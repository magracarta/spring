<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 매출관리 > 세금계산서관리 > null > 매출 세금계산서 관리
-- 작성자 : 박예진
-- 최초 작성일 : 2020-04-08 18:03:57
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var ReceiptTypeText = ""; // 영수 타입 텍스트
		var ClaimingTypeText = "농협 : 041-01-161731 예금주 : ㈜와이케이건기"; // 청구 타입 텍스트
		var CardTypeText = "카드결제건"; // 카드 타입 텍스트
	
		$(document).ready(function() {
			fnInitPage();
			fnCheckTaxbillType();
		});
		
		function fnInitPage() {
			var info = ${info};

			$M.setValue(info);

			// 해당 로직 수정 시 - ACNT0301ServiceImpl - sendTaxbill365() 메서드 조건 또한 수정 해줘야함
			if (info.remark == ""){ // 2.5 08.04 예금주 추가
				// Q&A 14319 - 이유경 사원 요청 (수주/정비/렌탈/중고장비/출하지급품/렌탈장비) 일 경우 적용되게
				if(info.taxbill_doc_type_cd == '05' || info.taxbill_doc_type_cd == '07'
					|| info.taxbill_doc_type_cd == '08' || info.taxbill_doc_type_cd == '11'
					|| info.taxbill_doc_type_cd == '12' || info.taxbill_doc_type_cd == '13'
				) {
					if(info.taxbill_type_cd == '1') { // 영수 타입 일때
						$("#remark").val(ReceiptTypeText);
					} else if(info.taxbill_type_cd == '2') { // 청구 타입 일때
						$("#remark").val(ClaimingTypeText);
					} else if(info.taxbill_type_cd == '3') { // 카드발행 타입 일때
						$("#remark").val(CardTypeText);
					}
				}


			}

			// [3차 - 14625] 버튼 권한
			// 관리부 계정이 아니면 버튼 숨김 처리
			<c:if test="${page.fnc.F00649_001 ne 'Y'}">
				// - 마감 처리된 내용은 "닫기 버튼만 활성화"
				// - 미마감 처리된 내용은 "수정,삭제,닫기" 버튼 활성화
				if(info.end_yn == "Y") {
					$("#main_form :input").prop("disabled", true);
					$("#main_form :button").prop("disabled", false);
					$("#_goModify").addClass("dpn");
					$("#_goRemove").addClass("dpn");
				}
			</c:if>

			// 카드발행 선택 시, 카드수금액 활성화
			if ($("input[name='taxbill_type_cd']:checked").val() === '3') {
				$('#card_amt').prop("disabled", false);
			}
		}
		
		// 전표조회
		function goSearchInout() {
			var taxbillIssueCd = $M.getValue("taxbill_issue_cd");
			if(taxbillIssueCd == "2") {
				var params = {
						"taxbill_no" : $M.getValue("taxbill_no")
				};
				var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=900, height=360, left=0, top=0";
				$M.goNextPage('/acnt/acnt0301p03', $M.toGetParam(params), {popupStatus : popupOption});
			} else {
				var inoutDocTypeCd = $M.getValue("inout_doc_type_cd");
				var inoutDocNo = $M.getValue("inout_doc_no");
				var param = {
				};
				var popupOption = "";
				switch(inoutDocTypeCd) {
				case "00" : 
					param.inout_doc_no = inoutDocNo;
					$M.goNextPage("/cust/cust0203p01", $M.toGetParam(param), {popupStatus : popupOption});		// 입출금전표처리 상세
					break;
				case "02" :
// 					param.part_order_no = event.item["part_order_no"];
					param.inout_doc_no = inoutDocNo;
					$M.goNextPage("/part/part0302p01", $M.toGetParam(param), {popupStatus : popupOption});		// 매입처리 상세
					break;
				case "05" :
					param.inout_doc_no = inoutDocNo;
					$M.goNextPage("/cust/cust0202p01", $M.toGetParam(param), {popupStatus : popupOption});		// 매출처리 상세
					break;
				case "06" :
					param.cust_coupon_no = $M.getValue("cust_coupon_no");
					$M.goNextPage("/cust/cust0305p01", $M.toGetParam(param), {popupStatus : popupOption});	// 쿠폰처리 상세
					break;
				case "07" :
// 					alert("정비지시서 상세-거래명세서");
					// 정비지시서 상세의 거래명세서
					// AS-IS에서 나오지 않으므로 매출처리 상세 오픈
					// $M.goNextPage("/cust/cust0305p01", $M.toGetParam(param), {popupStatus : popupOption});	// 서비스 정비 거래명세서
					param.inout_doc_no = inoutDocNo;
					$M.goNextPage("/cust/cust0202p01", $M.toGetParam(param), {popupStatus : popupOption});		// 매출처리 상세
					break;
				case "08" :
					param.machine_doc_no = $M.getValue("machine_doc_no");
					$M.goNextPage("/sale/sale0101p03", $M.toGetParam(param), {popupStatus : popupOption});	// 출하의뢰서
					break;
				case "09" :
					param.cust_no = $M.getValue("cust_no");
					$M.goNextPage("/comp/comp0703", $M.toGetParam(param), {popupStatus : popupOption});		//  ARS 결제
					break;
// 				case "10" :
// 					alert("장비입고시 옵션부품 입고");
// 					param.part_order_no = event.item["part_order_no"];
// 					$M.goNextPage("/part/part0302p01", $M.toGetParam(param), {popupStatus : popupOption});
// 					break;
				case "11" :
					param.inout_doc_no = inoutDocNo;
					$M.goNextPage("/cust/cust0202p01", $M.toGetParam(param), {popupStatus : popupOption});		// 매출처리 상세
					break;
				case "12" :
					param.inout_doc_no = inoutDocNo;
					$M.goNextPage("/cust/cust0202p01", $M.toGetParam(param), {popupStatus : popupOption});		// 매출처리 상세
					break;
				case "13" :
					param.inout_doc_no = inoutDocNo;
					$M.goNextPage("/cust/cust0202p01", $M.toGetParam(param), {popupStatus : popupOption});		// 매출처리 상세
					break;
				case "22" :
					param.machine_doc_no = $M.getValue("machine_doc_no");
					$M.goNextPage("/sale/sale0101p03", $M.toGetParam(param), {popupStatus : popupOption});	// 출하의뢰서
					break;
				}
			}
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
		
		// 합계금액 계산
		function fnCalcTotalAmt() {
			var vatAmt = $M.toNum($M.getValue("taxbill_amt")) * 0.1;
			$M.setValue("vat_amt", vatAmt); 
			
			var totalAmt = $M.toNum($M.getValue("taxbill_amt")) + $M.toNum($M.getValue("vat_amt"));
			$M.setValue("total_amt", totalAmt); 
		}
		
		function goModify() {
	    	var frm = document.main_form;
	    	
	    	if($M.getValue("taxbill_type_cd") == "") {
	    		alert("영수구분은 필수입니다.");
	    		return false;
	    	}
	    	
		  	// validation check
	     	if($M.validation(frm) === false) {
	     		return;
	     	};

			if($M.getValue("duzon_trans_yn") == "Y") {
				alert("회계전송된 건은 수정할 수 없습니다.");
				return false;
			}

	     	$M.goNextPageAjaxModify(this_page + '/modify', $M.toValueForm(frm) , {method : 'POST'},
					function(result) {
						if(result.success) {
							alert("수정이 완료되었습니다.");
							if (opener != null && opener.goSearch) {
								opener.goSearch();
							}
							fnClose();
						}
					}
				);
	    	
	    }
		
		// 삭제
	    function goRemove() {
			var frm = document.main_form;

			if($M.getValue("duzon_trans_yn") == "Y") {
				alert("회계전송된 건은 삭제할 수 없습니다.");
				return false;
			}
	     	
			if($M.getValue("report_yn") == "Y") {
				alert("현 자료는 신고되어 삭제할 수 없습니다.");
				return false;
			}
			
			$M.goNextPageAjaxRemove(this_page + '/remove', $M.toValueForm(frm) , {method : 'POST'},
				function(result) {
					if(result.success) {
						alert("삭제가 완료되었습니다.");
						if (opener != null && opener.goSearch) {
							opener.goSearch();
						}
						fnClose();
					}
				}
			);
		}

		// 닫기
		function fnClose() {
			window.close();
		}

		// 카드발행 선택 시, 카드수금액 활성화
		function fnCheckTaxbillType() {
			$("input[name='taxbill_type_cd']").change(function(){
				var value = $("input[name='taxbill_type_cd']:checked").val();
				var taxbillDocType = $M.getValue("taxbill_doc_type_cd");

				// 비고 변경
				// Q&A 14319 - 이유경 사원 요청 (수주/정비/렌탈/중고장비/출하지급품/렌탈장비) 일 경우 적용되게
				if(taxbillDocType === '05' || taxbillDocType === '07' || taxbillDocType === '08'
					|| taxbillDocType === '11' || taxbillDocType === '12' || taxbillDocType === '13') {
					if (value === '1') {
						$("#remark").val(ReceiptTypeText);
					} else if (value === '2') {
						$("#remark").val(ClaimingTypeText);
					} else if (value === '3') {
						$("#remark").val(CardTypeText);
					}
				}

				// 카드수금액 disabled 처리
				if (value === '3') {
					$('#card_amt').prop("disabled", false);
				} else {
					$('#card_amt').prop("disabled", true);
				}
			});
		}
	
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" id="inout_doc_no" name="inout_doc_no">
<input type="hidden" id="cust_fax_no" name="cust_fax_no">
<input type="hidden" id="cust_no" name="cust_no">
<input type="hidden" id="breg_seq" name="breg_seq">
<input type="hidden" id="sale_mem_no" name="sale_mem_no">
<input type="hidden" id="report_yn" name="report_yn">
<input type="hidden" id="duzon_trans_yn" name="duzon_trans_yn">
<input type="hidden" id="taxbill_issue_cd" name="taxbill_issue_cd">
<input type="hidden" id="inout_doc_type_cd" name="inout_doc_type_cd">
<input type="hidden" id="cust_coupon_no" name="cust_coupon_no">
<input type="hidden" id="machine_doc_no" name="machine_doc_no">
<input type="hidden" id="taxbill_doc_type_cd" name="taxbill_doc_type_cd">
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
					<h4>매출 세금계산서 관리</h4>
				</div>
				<table class="table-border mt5">
					<colgroup>
						<col width="100px">
						<col width="140px">
						<col width="90px">
						<col width="140px">
						<col width="100px">
						<col width="*">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right">발행번호</th>
							<td colspan="3">
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
									<div class="col width80px">
										<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_L"/></jsp:include>
									</div>
								</div>
							</td>	
							<th class="text-right essential-item">발행일자</th>
							<td>
								<div class="input-group width120px">
									<input type="text" class="form-control border-right-0 calDate sale-rb" id="taxbill_dt" name="taxbill_dt" dateformat="yyyy-MM-dd" alt="발행일자" required="required" disabled>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">고객명</th>
							<td colspan="3">
								<input type="text" class="form-control width120px"  id="cust_name" name="cust_name" readonly="readonly">
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
							<td colspan="3">
								<input type="text" class="form-control width120px" readonly="readonly" id="sale_mem_name" name="sale_mem_name">
							</td>
							<th class="text-right">업체명</th>
							<td>
								<input type="text" class="form-control" readonly="readonly" id="breg_name" name="breg_name">
							</td>
						</tr>
						<tr>
							<th class="text-right">사업자No</th>
							<td colspan="3">
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
							<td colspan="3">
								<input type="text" class="form-control width120px" readonly="readonly" id="breg_cor_type" name="breg_cor_type">
							</td>
							<th class="text-right">종목</th>
							<td>
								<input type="text" class="form-control width120px" readonly="readonly" id="breg_cor_part" name="breg_cor_part">
							</td>
						</tr>
						<tr>
							<th class="text-right">주소</th>
							<td colspan="5">
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
							<th class="text-right essential-item">마일리지사용</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width100px">
										<input type="text" class="form-control text-right" required="required" alt="마일리지사용" id="use_mile_amt" name="use_mile_amt" format="decimal" readonly="readonly">
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
							<td colspan="3">
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
							<td colspan="3">
								<div class="form-row inline-pd widthfix">
									<div class="col width100px">
										<input type="text" class="form-control text-right" readonly="readonly" id="total_amt" name="total_amt" format="decimal">
									</div>
									<div class="col width22px">원</div>
								</div>
							</td>
							<th class="text-right essential-item">영수구분</th>
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
								<div>
									<label for="card_amt">카드수금액</label>
<%--									<input type="text" class="form-control text-right" id="card_amt" name="card_amt" alt="카드수금액" format="decimal" disabled="disabled" style="width: 80px; display: inline"> 원--%>
<%--									2024-03-15 (Q&A 20427) 카드수금액 - 입력 가능하게 수정 요청--%>
									<input type="text" class="form-control text-right" id="card_amt" name="card_amt" alt="카드수금액" format="minusNum" disabled="disabled" style="width: 80px; display: inline"> 원
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">비고</th>
							<td colspan="5">
								<textarea class="form-control" style="height: 100px;" id="remark" name="remark">
<%--									농협 : 041-01-161731 예금주 : ㈜와이케이건기--%>
								</textarea>
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">적요</th>
							<td colspan="5">
								<textarea class="form-control sale-rb" style="height: 100px;" alt="적요" id="desc_text" name="desc_text" required="required"></textarea>
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