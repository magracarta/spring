<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 자산 > 예금코드관리 > null > 예금코드상세
-- 작성자 : 박예진
-- 최초 작성일 : 2020-04-08 18:03:57
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		
		$(document).ready(function() {
			fnChangeImprest();
		});
		
		// 수정
		function goModify() {
			var frm = document.main_form;
			if($M.validation(frm) == false) { 
				return;
			};
			if ($M.getValue("search_auth_pcm") == "C") {
				if ($M.validation(frm, {field : ["imprest_name"]}) == false) {
					return false;
				}
			}
			$M.goNextPageAjaxModify(this_page + '/modify', $M.toValueForm(frm), {method : 'POST'},
				function(result) {
		    		if(result.success) {
		    			alert("수정이 완료되었습니다.");
						fnClose();
						window.opener.goSearch();
					}
				}
			);
		}
		
		// 계정 조회
		function setAccountInfoPanel(result) {
			$M.setValue("acnt_code", result.acnt_code);
			$M.setValue("acnt_name", result.acnt_name);
		}
		
		// 거래은행 조회
		function setCustInfo(result) {
			$M.setValue("deposit_bank_no", result.cust_no);
			$M.setValue("deposit_bank_name", result.cust_name);
		}
		
		// 닫기
		function fnClose() {
			window.close();
		}
		
		function fnChangeImprest() {
			if ($M.getValue("search_auth_pcm") == "C") {
				$("#imprest_name").css("display", "block");
			} else {
				$("#imprest_name").css("display", "none");
			}
		}
		
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
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
						<col width="150px">
						<col width="">
						<col width="150px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right">계정코드번호</th>
							<td>										
								<input type="text" class="form-control width120px" id="deposit_code" name="deposit_code" value="${result.deposit_code}" readonly="readonly">
							</td>
							<th class="text-right">이자수령주기</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width60px">
										<input type="text" class="form-control" id="interest_mon" name="interest_mon" dataType="int" value="${result.interest_mon}">
									</div>
									<div class="col width200px">
										정기수령인 경우 월단위
									</div> 
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">명칭</th>
							<td>										
								<input type="text" class="form-control essential-bg width200px" id="deposit_name" name="deposit_name" value="${result.deposit_name}" placeholder="영문 30자 / 한글 15자 이내" required="required" alt="명칭">
							</td>
							<th class="text-right">이자수령날짜</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width60px">
										<input type="text" class="form-control" id="interest_day" name="interest_day" dataType="int" value="${result.interest_day}">
									</div>
									<div class="col width200px">
										정기수령인 경우 일단위
									</div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">거래은행코드</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width180px">
										<div class="input-group">
											<input type="text" class="form-control border-right-0 essential-bg" id="deposit_bank_no" name="deposit_bank_no" value="${result.deposit_bank_no}" required="required" alt="거래은행코드">
											<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchCustPanel('setCustInfo');"><i class="material-iconssearch"></i></button>
										</div>
									</div>
									<div class="col width120px">
										<input type="text" class="form-control" id="deposit_bank_name" name="deposit_bank_name" value="${result.deposit_bank_name}" readonly="readonly">
									</div>
								</div>
							</td>
							<th class="text-right">사용제한사항(설권설정등)</th>
							<td>
								<input type="text" class="form-control width120px" id="use_not_text" name="use_not_text" value="${result.use_not_text}">
							</td>
						</tr>	
						<tr>
							<th class="text-right essential-item">예금종류</th>
							<td>
								<select class="form-control width120px essential-bg" id="deposit_type_cd" name="deposit_type_cd" required="required" alt="예금종류">
									<c:forEach items="${codeMap['DEPOSIT_TYPE']}" var="item">
									<option value="${item.code_value}" ${item.code_value == result.deposit_type_cd ? 'selected' : '' }>${item.code_name}</option>
									</c:forEach>
								</select>
							</td>
							<th class="text-right essential-item">추가코드입력여부</th>
							<td>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" name="add_yn" id="add_y" value="N" ${result.add_yn == "N" ? 'checked' : '' } checked="checked">
									<label for="add_y" class="form-check-label">입력안함</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" name="add_yn" id="add_n" value="Y" ${result.add_yn == "Y" ? 'checked' : '' }>
									<label for="add_n" class="form-check-label">입력함</label>
								</div>
							</td>
						</tr>	
						<tr>
							<th class="text-right essential-item">관리계정코드</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width180px">
										<div class="input-group">
											<input type="text" class="form-control border-right-0 essential-bg" id="acnt_code" name="acnt_code" value="${result.acnt_code}" required="required" alt="관리계정코드">
											<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openAccountInfoPanel('setAccountInfoPanel');"><i class="material-iconssearch"></i></button>
										</div>
									</div>
									<div class="col width120px">
										<input type="text" class="form-control" id="acnt_name" name="acnt_name" value="${result.acnt_name}" readonly="readonly">
									</div>
								</div>
							</td>
							<th class="text-right essential-item">계좌번호</th>
							<td>
								<input type="text" class="form-control essential-bg width200px" id="account_no" name="account_no" alt="계좌번호" value="${result.account_no}" placeholder="영문 30자 / 한글 15자 이내" maxlength="30" required="required">
							</td>
						</tr>	
						<tr>
							<th class="text-right essential-item">권한구분</th>
							<td>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" id="search_auth_p" name="search_auth_pcm" value="P" ${result.search_auth_pcm == "P" ? 'checked' : '' } checked="checked" onchange="fnChangeImprest()">
									<label for="search_auth_p" class="form-check-label">공용</label>
								</div>
								<div class="form-check form-check-inline"> 
									<input class="form-check-input" type="radio" id="search_auth_c" name="search_auth_pcm" value="C" ${result.search_auth_pcm == "C" ? 'checked' : '' } onchange="fnChangeImprest()">
									<label for="search_auth_c" class="form-check-label">센터전도금</label>
									<input type="text" class="form-control rb" id="imprest_name" name="imprest_name" alt="센터전도금명" style="width: 100px; margin-left: 5px;" placeholder="센터전도명" value="${result.imprest_name}">
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" id="search_auth_m" name="search_auth_pcm" value="M" ${result.search_auth_pcm == "M" ? 'checked' : '' } onchange="fnChangeImprest()">
									<label for="search_auth_m" class="form-check-label">자금</label>
								</div>
							</td>
							<th class="text-right essential-item">사용여부</th>
							<td>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" name="use_yn" id="use_y" value="Y" ${result.use_yn == "Y" ? 'checked' : '' }>
									<label for="use_y" class="form-check-label">사용</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" name="use_yn" id="use_n" value="N" ${result.use_yn == "N" ? 'checked' : '' }>
									<label for="use_n" class="form-check-label">미사용</label>
								</div>
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