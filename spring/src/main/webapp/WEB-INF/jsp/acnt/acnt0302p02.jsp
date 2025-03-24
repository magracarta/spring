<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 매출관리 > 세금계산서-기간내 일괄병행 > null > 세금계산서발행
-- 작성자 : 박예진
-- 최초 작성일 : 2020-04-08 18:03:57
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		
		$(document).ready(function(){
			fnInitPage();
		});
		
		// 데이터 셋팅
		function fnInitPage() {
			var info = ${info};
			console.log(info);
			$M.setValue(info);
			
			// 품명 외 몇건
	     	var list = ${list};
	     	var listLength = list.length - 1;
	     	var descText = list[0].count_remark;
	     	
	     	if(listLength <= 0) {
	     		$M.setValue("desc_text", descText);
	     	} else {
	     		$M.setValue("desc_text", descText + " 외 " + listLength + "건");
	     	}
		}
		
		// 저장
		function goSave() {
			var frm = document.main_form;

			var sendDt = $M.dateFormat($M.toDate($M.getValue("taxbill_dt")), "yyyy-MM-dd");
			$M.setValue("send_dt", sendDt);
			
			if($M.validation(frm) === false) {
				return false;
			}
			
			var msg = confirm("세금계산서를 발행하시겠습니까?");
			
			if(!msg) {
				return false;
			}
			
			$M.goNextPageAjax(this_page + "/save", $M.toValueForm(frm), {method : "POST"},
					function(result) {
						if(result.success) {
							alert("세금계산서 발행이 완료되었습니다.");
							window.opener.fnClose();
						//	window.opener.opener.location.reload();
							window.opener.opener.goSearch();
							fnClose();
						}
			})
		}
		
		// 닫기
		function fnClose() {
			window.close();
		}

	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" id="breg_seq" name="breg_seq">
<input type="hidden" id="desc_text" name="desc_text">
<input type="hidden" id="breg_cor_part" name="breg_cor_part">
<input type="hidden" id="breg_cor_type" name="breg_cor_type">
<input type="hidden" id="breg_no" name="breg_no">
<input type="hidden" id="cust_hp_no" name="cust_hp_no">
<input type="hidden" id="cust_fax_no" name="cust_fax_no">
<input type="hidden" id="cust_no" name="cust_no">
<input type="hidden" id="cust_name" name="cust_name">
<input type="hidden" id="biz_addr1" name="biz_addr1">
<input type="hidden" id="biz_addr2" name="biz_addr2">
<input type="hidden" id="biz_post_no" name="biz_post_no">
<input type="hidden" id="vat_amt" name="vat_amt">
<input type="hidden" id="email" name="email">
<input type="hidden" id="taxbill_dt" name="taxbill_dt" value="${inputParam.taxbill_dt}">
<input type="hidden" id="send_dt" name="send_dt">
<input type="hidden" id="origin_breg_no" name="origin_breg_no">
<input type="hidden" id="inout_doc_no_str" name="inout_doc_no_str" value="${inputParam.inout_doc_no_str}">
<input type="hidden" id="inout_org_code" name="inout_org_code" value="${inoutOrgCode}">
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
				<table class="table-border mt5">
					<colgroup>
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
						</tr>
						<tr>
							<th class="text-right">거래처</th>
							<td>
								<input type="text" class="form-control width180px" id="breg_name" name="breg_name" readonly="readonly">
							</td>
						</tr>
						<tr>
							<th class="text-right">대표자</th>
							<td>
								<input type="text" class="form-control width120px" id="breg_rep_name" name="breg_rep_name" readonly="readonly">
							</td>
						</tr>
						<tr>
							<th class="text-right">물품대</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width100px">
										<input type="text" class="form-control text-right" id="taxbill_amt" name="taxbill_amt" readonly="readonly" format="decimal">
									</div>
									<div class="col width22px">원</div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">발급구분</th>
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
							</td>
						</tr>
						<tr>
							<th class="text-right">수령구분</th>
							<td>
								<select class="form-control width120px" id="taxbill_send_cd" name="taxbill_send_cd" disabled="disabled">
									<option>전자계산서</option>
								</select>
							</td>
						</tr>
						<tr>
							<th class="text-right">처리자</th>
							<td>
								<input type="text" class="form-control width120px" readonly="readonly" id="reg_name" name="reg_name" value="${SecureUser.kor_name}">
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