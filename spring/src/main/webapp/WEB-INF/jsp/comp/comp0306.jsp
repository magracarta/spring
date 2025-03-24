<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 고객연관팝업 > 고객연관팝업 > null > 개인정보수집동의
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-05-22 09:31:37
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		
		$(document).ready(function() {
			if ("${result.marketing_yn}"!="Y") {
				fnSetDisabled();				
			} 
			console.log("${result}");
		});
		
		function fnSetDisabled() {
			var temp = ['tel', 'sms', 'email', 'dm'];
			for (var i = 0; i < temp.length; ++i) {
				$("#"+temp[i]).prop("checked", false);
				$("#"+temp[i]).prop("disabled", function (){return ! $(this).prop('disabled');});
			}
			$("#marketing_collect_cd").prop("disabled", function (){return ! $(this).prop('disabled');});
			$M.setValue("marketing_collect_cd", "");
			fnCheck();
		}
		
		function goCustInfo() {
			var param = {
				cust_no : "${inputParam.cust_no}"
			}
			var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=750, left=0, top=0";
			$M.goNextPage('/cust/cust0102p01', $M.toGetParam(param), {popupStatus : poppupOption});
		}
		
		function fnPersonalChange(param) {
			var yn = $("input:checkbox[name='"+param+"Yn']").is(":checked");
			if(yn) {
				$M.setValue(param+"_yn", "Y");
				$M.setValue(param+"_dt", $M.getCurrentDate());
				$M.setValue(param+"_mem_name", '${SecureUser.user_name }');
				$M.setValue(param+"_mem_no", '${SecureUser.mem_no }');
			} else {
				$M.setValue(param+"_yn", "");
				$M.setValue(param+"_dt", "");
				$M.setValue(param+"_mem_name", "");
				$M.setValue(param+"_mem_no", '');
			} 
			if (param == "marketing") {
				fnSetDisabled();
			}
		}
		
		function fnCheck() {
			var ynCheck = ['tel', 'sms', 'email', 'dm'];
			for (i=0; i<ynCheck.length; i++) {
				var check = $("input:checkbox[id='"+ynCheck[i]+"']").is(":checked");
				if(check) {
					$M.setValue(ynCheck[i]+"_yn", "Y");
				} else {
					$M.setValue(ynCheck[i]+"_yn", "N");
				}
			}
		}
		
		function goSave() {
			fnCheck();
			$M.setValue("cust_no", "${inputParam.cust_no}");
			if($M.validation(document.main_form) == false) {
				return;
			};
			var ynTemp = ["personal", "three", "marketing"];
			for (var i = 0; i < ynTemp.length; ++i) {
				var collectCd = ynTemp[i]+"_collect_cd";
				if ($M.getValue(ynTemp[i]+"_yn") == "Y" && $M.getValue(collectCd) == "") {
					alert($("#"+collectCd).attr("alt")+"을 선택해주세요.");
					$("#"+collectCd).focus();
					return false;
				}
			}
			if ($M.getValue("personal_yn") != "Y") {
				alert("개인정보수집에 동의해주세요.");
				return false;
			}
			if ($M.getValue("three_yn") != "Y") {
				alert("제3자 정보제공에 동의해주세요.");
				return false;
			}
			var frm = document.main_form;			
			$M.goNextPageAjaxSave(this_page+'/save', $M.toValueForm(frm) , {method : 'POST'},
				function(result) {
		    		if(result.success) {
		    			alert("저장에 성공했습니다.");
		    			fnClose();
					}
				}
			); 
		}
		
		function fnClose() {
			window.close(); 
		}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <h2>개인정보 수집동의 입력</h2>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
<!-- 폼테이블 -->					
			<div>
				<div class="title-wrap">
					<h4><span class="text-primary">${result.cust_name}</span> 고객</h4>	
					<button type="button" class="btn btn-default" onclick="javascript:goCustInfo()">고객정보</button>			
				</div>
				<table class="table-border mt5" style="min-width: 800px">
					<colgroup>
						<col width="190px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right essential-item">			
								<div class="form-check form-check-inline">
									<label class="form-check-label mr5">개인정보 수집동의</label>
									<input class="form-check-input" type="checkbox" id="personalYn" name="personalYn" value="${result.personal_yn}" ${result.personal_yn == 'Y'? 'checked="checked"' : ''} onchange="javascript:fnPersonalChange('personal');" >
									<input type="hidden" id="personal_yn" name="personal_yn" value="${result.personal_yn}" alt="개인정보 수집동의"  required="required">	
								</div>
							</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width70px text-right">확인일자</div>
									<div class="col width120px">
										<div class="input-group">
											<input type="text" class="form-control border-right-0 calDate essential-bg" id="personal_dt" name="personal_dt" dateFormat="yyyy-MM-dd" value="${result.personal_dt}" disabled="disabled">
										</div>
									</div>
									<div class="col width60px text-right">확인자</div>
									<div class="col width100px">
										<input type="text" class="form-control essential-bg" id="personal_mem_name" name="personal_mem_name" value="${result.personal_mem_name}"  readonly="readonly">
										<input type="hidden" class="form-control" id="personal_mem_no" name="personal_mem_no" value="${result.personal_mem_no}">
									</div>
									<div class="col width70px text-right">수집구분</div>
									<div class="col width120px">
										<select class="form-control essential-bg" id="personal_collect_cd" name="personal_collect_cd" alt="개인정보 수집구분" required="required">
											<option value="">- 선택 -</option>
											<c:forEach var="personal" items="${codeMap['PERSONAL_COLLECT']}">
												<option value="${personal.code_value}"<c:if test="${result.personal_collect_cd eq personal.code_value }"> selected="selected"</c:if>>${personal.code_name}</option>
											</c:forEach>
										</select>
									</div>
								</div>				
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">		
								<div class="form-check form-check-inline">
									<label class="form-check-label mr5">제3자 정보제공동의</label>
									<input class="form-check-input" type="checkbox"id="threeYn" name="threeYn" onchange="javascript:fnPersonalChange('three');" value="${result.three_yn}" ${result.three_yn == 'Y'? 'checked="checked"' : ''} >
									<input type="hidden" id="three_yn" name="three_yn" value="${result.three_yn}" alt="제3자 정보제공동의"  required="required">
								</div>
							</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width70px text-right">확인일자</div>
									<div class="col width120px">
										<div class="input-group">
											<input type="text" class="form-control border-right-0 calDate essential-bg" id="three_dt" name="three_dt" dateFormat="yyyy-MM-dd" value="${result.three_dt}"  disabled="disabled">
										</div>
									</div>
									<div class="col width60px text-right">확인자</div>
									<div class="col width100px">
										<input type="text" class="form-control essential-bg" id="three_mem_name" name="three_mem_name" value="${result.three_mem_name}"  readonly="readonly">
										<input type="hidden" class="form-control" id="three_mem_no" name="three_mem_no" value="${result.three_mem_no}">
									</div>
									<div class="col width70px text-right">수집구분</div>
									<div class="col width120px">
										<select class="form-control essential-bg" id="three_collect_cd" name="three_collect_cd" alt="제3자 정보제공동의 수집구분" required="required">
											<option value="">- 선택 -</option>
											<c:forEach var="three" items="${codeMap['THREE_COLLECT']}">
												<option value="${three.code_value}"<c:if test="${result.three_collect_cd eq three.code_value }"> selected="selected"</c:if>>${three.code_name}</option>
											</c:forEach>
										</select>
									</div>
								</div>				
							</td>
						</tr>
						<tr>
							<th class="text-right">			
								<div class="form-check form-check-inline">
									<label class="form-check-label mr5">마케팅 활용동의</label>
									<input class="form-check-input" type="checkbox" id="marketingYn" name="marketingYn" value="${result.marketing_yn}" ${result.marketing_yn == 'Y'? 'checked="checked"' : ''} onchange="javscript:fnPersonalChange('marketing')">
									<input type="hidden" id="marketing_yn" name="marketing_yn" value="${result.marketing_yn}">
								</div>
							</th>
							<td>
								<div class="form-row inline-pd widthfix mb7">
									<div class="col width70px text-right">확인일자</div>
									<div class="col width120px">
										<div class="input-group">
											<input type="text" class="form-control border-right-0 calDate" id="marketing_dt" name="marketing_dt" dateFormat="yyyy-MM-dd" value="${result.marketing_dt}"  disabled="disabled">
										</div>
									</div>
									<div class="col width60px text-right">확인자</div>
									<div class="col width100px">
										<input type="text" class="form-control" id="marketing_mem_name" name="marketing_mem_name" value="${result.marketing_mem_name}"  readonly="readonly">
										<input type="hidden" class="form-control" id="marketing_mem_no" name="marketing_mem_no" value="${result.marketing_mem_no}">
									</div>
									<div class="col width70px text-right">수집구분</div>
									<div class="col width120px">
										<select class="form-control" id="marketing_collect_cd" name="marketing_collect_cd" alt="마케팅 활용동의 수집구분">
											<option value="">- 선택 -</option>
											<c:forEach var="marketing" items="${codeMap['MARKETING_COLLECT']}">
												<option value="${marketing.code_value}"<c:if test="${result.marketing_collect_cd eq marketing.code_value }"> selected="selected"</c:if>>${marketing.code_name}</option>
											</c:forEach>
										</select>
									</div>									
								</div>	
<%--								<div class="form-row inline-pd widthfix">								--%>
<%--									<div class="col width280px text-right">--%>
<%--										<div class="form-check form-check-inline">--%>
<%--											<input class="form-check-input" type="checkbox" id="tel" name="tel" <c:if test="${result.tel_yn eq 'Y'}">value="${result.tel_yn}" ${result.tel_yn == 'Y'? 'checked' : ''}</c:if>>--%>
<%--											<input type="hidden" id="tel_yn" name="tel_yn">--%>
<%--											<label class="form-check-label">전화</label>--%>
<%--										</div>--%>
<%--										<div class="form-check form-check-inline">--%>
<%--											<input class="form-check-input" type="checkbox" id="sms" name="sms" <c:if test="${result.sms_yn eq 'Y'}">value="${result.sms_yn}" ${result.sms_yn == 'Y'? 'checked' : ''}</c:if>>--%>
<%--											<input type="hidden" id="sms_yn" name="sms_yn">--%>
<%--											<label class="form-check-label">SMS</label>--%>
<%--										</div>--%>
<%--										<div class="form-check form-check-inline">--%>
<%--											<input class="form-check-input" type="checkbox" id="email" name="email" <c:if test="${result.email_yn eq 'Y'}">value="${result.email_yn}" ${result.email_yn == 'Y'? 'checked' : ''}</c:if>>--%>
<%--											<input type="hidden" id="email_yn" name="email_yn">--%>
<%--											<label class="form-check-label">이메일</label>--%>
<%--										</div>--%>
<%--										<div class="form-check form-check-inline">--%>
<%--											<input class="form-check-input" type="checkbox" id="dm" name="dm" <c:if test="${result.dm_yn eq 'Y'}">value="${result.dm_yn}" ${result.dm_yn == 'Y'? 'checked' : ''}</c:if>>--%>
<%--											<input type="hidden" id="dm_yn" name="dm_yn">--%>
<%--											<label class="form-check-label">우편발송</label>--%>
<%--										</div>--%>
<%--									</div>--%>
<%--								</div>		--%>
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
</form>
</body>
</html>