<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 자산 > 예금코드관리 > 예금신규등록 > null
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
		
		function goSave() {
			var frm = document.main_form;
			if($M.validation(frm) == false) { 
				return;
			};
			if ($M.getValue("search_auth_pcm") == "C") {
				if ($M.validation(frm, {field : ["imprest_name"]}) == false) {
					return false;
				}
			};
			$M.goNextPageAjaxSave(this_page + '/save', $M.toValueForm(frm) , {method : 'POST'},
				function(result) {
					if(result.success) {
						fnList();
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

		function fnList() {
			history.back();
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
<body>
<form id="main_form" name="main_form">
<div class="layout-box">
<!-- contents 전체 영역 -->
		<div class="content-wrap" style="width:70%;">
			<div class="content-box">
<!-- 상세페이지 타이틀 -->
				<div class="main-title detail">
					<div class="detail-left" style="align-items: flex-start;">
						<button type="button" class="btn btn-outline-light" onclick="javascript:fnList();"><i class="material-iconskeyboard_backspace text-default"></i></button>
						<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
					</div>
				</div>
<!-- /상세페이지 타이틀 -->
				<div class="contents">
<!-- 폼테이블 -->	
					<div>
						<table class="table-border">
							<colgroup>
								<col width="150px">
								<col width="">
								<col width="150px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th class="text-right essential-item">계정코드번호</th>
									<td>										
										<input type="text" class="form-control width120px essential-bg" id="deposit_code" name="deposit_code" dataType="int" placeholder="숫자 6자리" maxlength="6" required="required" alt="계정코드번호">
									</td>
									<th class="text-right">이자수령주기</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width60px">
												<input type="text" class="form-control" id="interest_mon" name="interest_mon" dataType="int">
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
										<input type="text" class="form-control essential-bg width200px" id="deposit_name" name="deposit_name" placeholder="영문 30자 / 한글 15자 이내" required="required" alt="명칭">
									</td>
									<th class="text-right">이자수령날짜</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width60px">
												<input type="text" class="form-control" id="interest_day" name="interest_day" dataType="int">
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
													<input type="text" class="form-control border-right-0" id="deposit_bank_no" name="deposit_bank_no" required="required" readonly="readonly" alt="거래은행코드">
													<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchCustPanel('setCustInfo');"><i class="material-iconssearch"></i></button>
												</div>
											</div>
											<div class="col width120px">
												<input type="text" class="form-control" id="deposit_bank_name" name="deposit_bank_name" readonly="readonly">
											</div>
										</div>
									</td>
									<th class="text-right">사용제한사항(설권설정등)</th>
									<td>
										<input type="text" class="form-control width120px" id="use_not_text" name="use_not_text">
									</td>
								</tr>	
								<tr>
									<th class="text-right essential-item">예금종류</th>
									<td>
										<select class="form-control width120px essential-bg" id="deposit_type_cd" name="deposit_type_cd" required="required" alt="예금종류">
											<c:forEach items="${codeMap['DEPOSIT_TYPE']}" var="item">
											<option value="${item.code_value}">${item.code_name}</option>
											</c:forEach>
										</select>
									</td>
									<th class="text-right essential-item">추가코드입력여부</th>
									<td>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" name="add_yn" id="add_n" value="N" checked="checked">
											<label for="add_n" class="form-check-label">입력안함</label>
										</div>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" name="add_yn" id="add_y" value="Y">
											<label for="add_y" class="form-check-label">입력함</label>
										</div>
									</td>
								</tr>	
								<tr>
									<th class="text-right essential-item">관리계정코드</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width180px">
												<div class="input-group">
													<input type="text" class="form-control border-right-0" id="acnt_code" name="acnt_code" readonly="readonly" required="required" alt="관리계정코드">
													<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openAccountInfoPanel('setAccountInfoPanel');"><i class="material-iconssearch"></i></button>
												</div>
											</div>
											<div class="col width120px">
												<input type="text" class="form-control" id="acnt_name" name="acnt_name" readonly="readonly">
											</div>
										</div>
									</td>
									<th class="text-right essential-item">계좌번호</th>
									<td>
										<input type="text" class="form-control essential-bg width200px" id="account_no" name="account_no" alt="계좌번호" placeholder="영문 30자 / 한글 15자 이내" maxlength="30" required="required">
									</td>
								</tr>	
								<tr>
									<th class="text-right essential-item">권한구분</th>
									<td>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" id="search_auth_p" name="search_auth_pcm" value="P" checked="checked" onchange="fnChangeImprest()">
											<label for="search_auth_p" class="form-check-label">공용</label>
										</div>
										<div class="form-check form-check-inline"> 
											<input class="form-check-input" type="radio" id="search_auth_c" name="search_auth_pcm" value="C" onchange="fnChangeImprest()">
											<label for="search_auth_c" class="form-check-label">센터전도금</label>
											<input type="text" class="form-control rb" id="imprest_name" name="imprest_name" alt="센터전도금명" style="width: 100px; margin-left: 5px;" placeholder="센터전도명">
										</div>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" id="search_auth_m" name="search_auth_pcm" value="M" onchange="fnChangeImprest()">
											<label for="search_auth_m" class="form-check-label">자금</label>
										</div>
									</td>
									<th class="text-right essential-item">사용여부</th>
									<td>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" name="use_yn" id="use_y" value="Y" checked="checked">
											<label for="use_y"  class="form-check-label">사용</label>
										</div>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" name="use_yn" id="use_n" value="N">
											<label for="use_n"  class="form-check-label">미사용</label>
										</div>
									</td>
								</tr>				
							</tbody>
						</table>
					</div>
<!-- /폼테이블 -->	
<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">						
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
					</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
				</div>
			</div>		
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
		</div>
<!-- /contents 전체 영역 -->	
</div>
</form>	
</body>
</html>