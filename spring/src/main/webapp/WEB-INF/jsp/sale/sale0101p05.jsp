<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 계약관리 > 계약/출하 > null > 세금계산서발행
-- 작성자 : 김태훈
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		$(document).ready(function() {
			if ("${outDoc.taxbill_no}" != "" || "${outDoc.acnt_taxbill_no}" != "") {
				$("#_goBill").css("display", "none");
			} else {
				$("#_goPrint").css("display", "none");
				$("#_goCancel").css("display", "none");
			}
			if ("${outDoc.report_yn}" == "Y") {
				$("#_goCancel").css("display", "none");
				$("#reported").show();
			}
			if ("${outDoc.duzon_trans_yn}" == "Y") {
				$("#_goCancel").css("display", "none");
				$("#transed").show();
			}
			if ("${outDoc.report_yn}" == "Y" && "${outDoc.duzon_trans_yn}" == "Y") {
				$("#divider").show();
			}
		});
		
		function goPrint() {
			// 세금계산서 번호 뒷자리 4자리중 첫번호가 '9'로 시작할경우 인쇄, 취소 막기 - 황빛찬 (관리부 이유경 요청)
			var taxbillNo = $M.getValue("taxbill_no");
			if (taxbillNo.substring(taxbillNo.length-4).charAt(0) == '9') {
				alert("인쇄할 수 없는 세금계산서 입니다.");
				return;
			}

			if ('${inputParam.inout_doc_no}' == "") {
				openReportPanel('acnt/acnt0301p01_01.crf', 'fake_yn=Y&taxbill_no='+$M.getValue("taxbill_no"));
			} else {
				openReportPanel('acnt/acnt0301p01_01.crf','inout_doc_no=' + '${inputParam.inout_doc_no}');
			}
		}
	
		function fnClose() {
			window.close();
		}
		
		function goCancel() {
			// 세금계산서 번호 뒷자리 4자리중 첫번호가 '9'로 시작할경우 인쇄, 취소 막기 - 황빛찬 (관리부 이유경 요청)
			var taxbillNo = $M.getValue("taxbill_no");
			if (taxbillNo.substring(taxbillNo.length-4).charAt(0) == '9') {
				alert("취소할 수 없는 세금계산서 입니다.");
				return;
			}

			if ($M.getValue("taxbill_amt") == "0") {
				alert("세금계산서를 발행할 수 없습니다. 물품대가 0원입니다.");
				return false;
			}
			var msg = "세금계산서를 취소하시겠습니까?";
			var url = this_page+"/delete";
			if ("${inputParam.type}" == "part") {
				url = this_page+"/deletePart"
			}
			$M.goNextPageAjaxMsg(msg, url, $M.toValueForm(document.main_form), {method: 'post'},
	                  function (result) {
	                       if (result.success) {
	                    	   opener.location.reload();
	                    	   setTimeout(function () {
	                    		   fnClose();                    		   
	                           }, 100);
	                       }
	                  }
	             );
		}
		
		function goBill() {
			if ($M.getValue("taxbill_amt") == "0") {
				alert("세금계산서를 발행할 수 없습니다. 물품대가 0원입니다.");
				return false;
			}
			var msg = "세금계산서를 발행하시겠습니까?";
			if($M.validation(document.main_form) == false) {
				return false;
			}
			var url = this_page+"/save";
			if ("${inputParam.type}" == "part") {
				url = this_page+"/savePart"
			}
			$M.goNextPageAjaxMsg(msg, url, $M.toValueForm(document.main_form), {method: 'post'},
                  function (result) {
                       if (result.success) {
                    	   if ("${inputParam.fake_yn }" == "Y") {
                    		   openReportPanel('acnt/acnt0301p01_01.crf', 'fake_yn=Y&taxbill_no='+result.taxbill_no+'&taxbill_type_cd='+$M.getValue("taxbill_type_cd"));
                    		   if (opener != null) {
                    			   opener.location.reload();   
                    		   }
                    		   setTimeout(function () {
                        		   fnClose();                   		   
                               }, 2000);
                    	   } else {
                    		   if (opener != null) {
                    			   opener.location.reload();
                    		   }
                    		   location.reload();
                    	   }
                    	   
                       }
                  }
             );
		}
		
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" id="machine_out_doc_seq" name="machine_out_doc_seq" value="${outDoc.machine_out_doc_seq }">
<input type="hidden" id="inout_doc_no" name="inout_doc_no" value="${outDoc.inout_doc_no}">
<input type="hidden" id="fake_yn" name="fake_yn" value="${inputParam.fake_yn }">
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
					<h4 class="primary">세금계산서 발행</h4>
				</div>
				<table class="table-border mt5">
					<colgroup>
						<col width="100px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right rs">발행번호</th>
							<td>
								<div class="input-group">
                                    <input type="text" class="form-control border-right-0 maxWidth95px calDate rb" dateformat="yyyy-MM-dd" id="taxbill_dt" name="taxbill_dt" required="required" alt="발행일자" value="${outDoc.taxbill_dt }"
                                    <c:if test="${not empty outDoc.taxbill_no }">disabled</c:if>
                                    >
                                    <div style="display: inline-block; margin-left: 5px; margin-right: 5px; line-height: 2">-</div>
                                    <c:choose>
                                    	<c:when test="${not empty outDoc.acnt_taxbill_no }">
                                    		<input type="text" class="form-control width120px" style="border-radius: 4px" id="taxbill_no" name="taxbill_no" readonly="readonly" value="${outDoc.acnt_taxbill_no }">	
                                    	</c:when>
                                    	<c:otherwise>
                                    		<input type="text" class="form-control width120px" style="border-radius: 4px" id="taxbill_no" name="taxbill_no" readonly="readonly" value="${outDoc.taxbill_no }">
                                    	</c:otherwise>
                                    </c:choose>
                                    <span style="line-height: 2;padding-left: 5px; color: red; display: none" id="reported">국세청신고</span>
                                    <span style="line-height: 2;padding-left: 5px; color: red; display: none" id="divider">/</span>
                                    <span style="line-height: 2;padding-left: 5px; color: red; display: none" id="transed">회계전송</span>
                                </div>
                                
							</td>									
						</tr>	
						<tr>
							<th class="text-right rs">거래처</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-8">
										<input type="text" class="form-control" readonly="readonly" id="breg_name" name="breg_name" value="${outDoc.breg_name }">
									</div>
									<div class="col-4">
										<input type="text" class="form-control" readonly="readonly" id="breg_rep_name" name="breg_rep_name" value="${outDoc.breg_rep_name }">
									</div>
								</div>
							</td>									
						</tr>	
						<tr>
							<th class="text-right rs">물품대</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-10 width130px">
										<input type="text" class="form-control text-right" readonly="readonly" id="taxbill_amt" name="taxbill_amt" format="decimal" value="${outDoc.taxbill_amt }">
									</div>
									<div class="col-2">원</div>
								</div>
							</td>								
						</tr>	
						<tr>
							<th class="text-right rs">발급구분</th>
							<td>
								<select class="form-control width120px rb" name="taxbill_type_cd" id="taxbill_type_cd"
								<c:if test="${not empty outDoc.taxbill_no }">disabled</c:if>
								>
									<!-- <option value="1">영수</option>
									<option value="2">청구</option>
									<option value="3">영수(카드)</option>
									<option value="4">영수 청구</option> -->
									<c:forEach items="${codeMap['TAXBILL_TYPE']}" var="item" varStatus="status">
										<c:choose>
											<c:when test="${empty outDoc.taxbill_type_cd }">
												<option value="${item.code_value }" <c:if test="${ '1' eq item.code_value }">selected="selected"</c:if>>${item.code_name }</option>
											</c:when>
											<c:otherwise>
												<option value="${item.code_value }" <c:if test="${ outDoc.taxbill_type_cd eq item.code_value }">selected="selected"</c:if>>${item.code_name }</option>
											</c:otherwise>
										</c:choose>
									</c:forEach>
								</select>
							</td>									
						</tr>						
						<tr>
							<th class="text-right rs">수령구분</th>
							<td>
								<select class="form-control width120px rb" name="taxbill_send_cd" id="taxbill_send_cd"
								<c:if test="${not empty outDoc.taxbill_no }">disabled</c:if>
								>
									<!-- <option value="1">본인수령</option>
									<option value="2">택배동봉</option>
									<option value="3">우편발송</option>
									<option value="4" selected="selected">전자세금계산서</option> -->
									<c:forEach items="${codeMap['TAXBILL_SEND']}" var="item" varStatus="status">
										<c:if test="${'인쇄안함' ne item.code_name}">
											<c:choose>
												<c:when test="${empty outDoc.taxbill_send_cd }">
													<option value="${item.code_value }" <c:if test="${ '4' eq item.code_value }">selected="selected"</c:if>>${item.code_name }</option>
												</c:when>
												<c:otherwise>
													<option value="${item.code_value }" <c:if test="${ outDoc.taxbill_send_cd eq item.code_value }">selected="selected"</c:if>>${item.code_name }</option>
												</c:otherwise>
											</c:choose> 
										</c:if>
									</c:forEach>
								</select>
							</td>									
						</tr>	
						<tr>
							<th class="text-right rs">인쇄자</th>
							<td>
								<!-- ASIS도 인쇄자는 현재 사용자 이름 가져옴.. -->
								<input type="text" class="form-control width120px" value="${SecureUser.kor_name }" readonly="readonly">
							</td>									
						</tr>		
					</tbody>
				</table>
			</div>		
<!-- /폼테이블 -->
			<div class="btn-group mt10">
				<div class="right">
					<button class="btn btn-info" id="_goBill" onclick="javascript:goBill()">발행</button>
					<button class="btn btn-info" id="_goCancel" onclick="javascript:goCancel()">취소</button>
					<button class="btn btn-info" id="_goPrint" onclick="javascript:goPrint()">인쇄</button>
					<button class="btn btn-info" id="_fnClose" onclick="javascript:fnClose()">닫기</button>
					<%-- <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include> --%>
				</div>
			</div>
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>