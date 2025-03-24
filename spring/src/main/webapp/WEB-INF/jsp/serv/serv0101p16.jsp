<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 정비 > 정비지시서 > null > 서비스 점검리스트
-- 작성자 : 성현우
-- 최초 작성일 : 2020-04-07 19:54:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

	// 저장
	function goSave() {
		var checkText = $M.getValue("check_text");

		if(checkText == "") {
			alert("특이사항을 반드시 입력하셔야 점검리스트 작성이 완료됩니다.");
			return;
		}

		var codeList = JSON.parse('${codeMapJsonObj['SVC_CHK_LIST']}');
		var essentialArr = codeList.filter(item => item.code_value.indexOf('L10') > -1);
		var chkListArr = $M.getValue("svc_chk_list_cd");

		for(var i = 0; i < essentialArr.length; i++) {
			if(chkListArr.indexOf(essentialArr[i].code_value) == -1) {
				alert("'당일 점검 및 정비'는 반드시 모두 체크하셔야\n점검리리스트 작성이 완료됩니다.");
				return;
			}
		}

		var data = new Object();
		data.svc_chk_list_cd_str = $M.getValue("svc_chk_list_cd");
		data.check_text = checkText;

		try {
			opener.${inputParam.parent_js_name}(data);
			window.close();
		} catch(e) {
			alert("호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.");
		}
	}

	// 닫기
    function fnClose() {
    	window.close();
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
<!-- 당일 점검 및 정비 -->
			<div class="checklist-im-wrap">
				<div class="checklist-im">
					<div class="checklist-im-inner">
						<div class="header">
							당일 점검 및 정비
						</div>
						<div class="body">
							<c:forEach var="item" items="${codeMap['SVC_CHK_LIST']}">
								<c:if test="${fn:contains(item.code_value, 'L10')}">
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="checkbox" id="${item.code_value}" name="svc_chk_list_cd" <c:if test="${fn:contains(result.svc_chk_list_cd_str, item.code_value)}">checked="checked"</c:if> value="${item.code_value}">
										<label class="form-check-label" for="${item.code_value}">${item.code_name}</label>
									</div>
								</c:if>
							</c:forEach>
						</div>	
					</div>
				</div>
			</div>
<!-- /당일 점검 및 정비 -->
<!-- 체크리스트 -->
			<div class="row mt10">
<!-- 좌측 체크리스트 -->
				<div class="col-6">
					<table class="table-border mt5">
						<colgroup>
							<col width="90px">
							<col width="">
						</colgroup>
						<tbody>
							<tr>
								<th class="text-right">엔진</th>
								<td>
									<c:forEach var="item" items="${codeMap['SVC_CHK_LIST']}">
										<c:if test="${fn:contains(item.code_value, 'L20')}">
											<div class="form-check mb5">
												<input class="form-check-input" type="checkbox" id="${item.code_value}" name="svc_chk_list_cd" <c:if test="${fn:contains(result.svc_chk_list_cd_str, item.code_value)}">checked="checked"</c:if> value="${item.code_value}">
												<label class="form-check-label" for="${item.code_value}">${item.code_name}</label>
											</div>
										</c:if>
									</c:forEach>
								</td>
							</tr>	
							<tr>
								<th class="text-right">냉각시스템</th>
								<td>
									<c:forEach var="item" items="${codeMap['SVC_CHK_LIST']}">
										<c:if test="${fn:contains(item.code_value, 'L30')}">
											<div class="form-check mb5">
												<input class="form-check-input" type="checkbox" id="${item.code_value}" name="svc_chk_list_cd" <c:if test="${fn:contains(result.svc_chk_list_cd_str, item.code_value)}">checked="checked"</c:if> value="${item.code_value}">
												<label class="form-check-label" for="${item.code_value}">${item.code_name}</label>
											</div>
										</c:if>
									</c:forEach>
								</td>
							</tr>	
							<tr>
								<th class="text-right">연료시스템</th>
								<td>
									<c:forEach var="item" items="${codeMap['SVC_CHK_LIST']}">
										<c:if test="${fn:contains(item.code_value, 'L35')}">
											<div class="form-check mb5">
												<input class="form-check-input" type="checkbox" id="${item.code_value}" name="svc_chk_list_cd" <c:if test="${fn:contains(result.svc_chk_list_cd_str, item.code_value)}">checked="checked"</c:if> value="${item.code_value}">
												<label class="form-check-label" for="${item.code_value}">${item.code_name}</label>
											</div>
										</c:if>
									</c:forEach>
								</td>
							</tr>
							<tr>
								<th class="text-right">장비외부</th>
								<td>
									<c:forEach var="item" items="${codeMap['SVC_CHK_LIST']}">
										<c:if test="${fn:contains(item.code_value, 'L40')}">
											<div class="form-check mb5">
												<input class="form-check-input" type="checkbox" id="${item.code_value}" name="svc_chk_list_cd" <c:if test="${fn:contains(result.svc_chk_list_cd_str, item.code_value)}">checked="checked"</c:if> value="${item.code_value}">
												<label class="form-check-label" for="${item.code_value}">${item.code_name}</label>
											</div>
										</c:if>
									</c:forEach>
								</td>
							</tr>	
							<tr>
								<th class="text-right">안건문의</th>
								<td>
									<c:forEach var="item" items="${codeMap['SVC_CHK_LIST']}">
										<c:if test="${fn:contains(item.code_value, 'L50')}">
											<div class="form-check mb5">
												<input class="form-check-input" type="checkbox" id="${item.code_value}" name="svc_chk_list_cd" <c:if test="${fn:contains(result.svc_chk_list_cd_str, item.code_value)}">checked="checked"</c:if> value="${item.code_value}">
												<label class="form-check-label" for="${item.code_value}">${item.code_name}</label>
											</div>
										</c:if>
									</c:forEach>
								</td>			
						</tbody>
					</table>
				</div>
<!-- /좌측 체크리스트 -->	
<!-- 우측 체크리스트 -->			
				<div class="col-6">
					<table class="table-border mt5">
						<colgroup>
							<col width="90px">
							<col width="">
						</colgroup>
						<tbody>
							<tr>
								<th class="text-right">유압시스템</th>
								<td>
									<c:forEach var="item" items="${codeMap['SVC_CHK_LIST']}">
										<c:if test="${fn:contains(item.code_value, 'R10')}">
											<div class="form-check mb5">
												<input class="form-check-input" type="checkbox" id="${item.code_value}" name="svc_chk_list_cd" <c:if test="${fn:contains(result.svc_chk_list_cd_str, item.code_value)}">checked="checked"</c:if> value="${item.code_value}">
												<label class="form-check-label" for="${item.code_value}">${item.code_name}</label>
											</div>
										</c:if>
									</c:forEach>
								</td>
							</tr>
							<tr>
								<th class="text-right">주행시스템</th>
								<td>
									<c:forEach var="item" items="${codeMap['SVC_CHK_LIST']}">
										<c:if test="${fn:contains(item.code_value, 'R20')}">
											<div class="form-check mb5">
												<input class="form-check-input" type="checkbox" id="${item.code_value}" name="svc_chk_list_cd" <c:if test="${fn:contains(result.svc_chk_list_cd_str, item.code_value)}">checked="checked"</c:if> value="${item.code_value}">
												<label class="form-check-label" for="${item.code_value}">${item.code_name}</label>
											</div>
										</c:if>
									</c:forEach>
								</td>
							</tr>
							<tr>
								<th class="text-right">연료시스템</th>
								<td>
									<c:forEach var="item" items="${codeMap['SVC_CHK_LIST']}">
										<c:if test="${fn:contains(item.code_value, 'R30')}">
											<div class="form-check mb5">
												<input class="form-check-input" type="checkbox" id="${item.code_value}" name="svc_chk_list_cd" <c:if test="${fn:contains(result.svc_chk_list_cd_str, item.code_value)}">checked="checked"</c:if> value="${item.code_value}">
												<label class="form-check-label" for="${item.code_value}">${item.code_name}</label>
											</div>
										</c:if>
									</c:forEach>
								</td>
							</tr>
							<tr>
								<th class="text-right">옵션 구비</th>
								<td>
									<c:forEach var="item" items="${codeMap['SVC_CHK_LIST']}">
										<c:if test="${fn:contains(item.code_value, 'R51')}">
											<div class="form-check mb5">
												<input class="form-check-input" type="checkbox" id="${item.code_value}" name="svc_chk_list_cd" <c:if test="${fn:contains(result.svc_chk_list_cd_str, item.code_value)}">checked="checked"</c:if> value="${item.code_value}">
												<label class="form-check-label" for="${item.code_value}">${item.code_name}</label>
											</div>
										</c:if>
									</c:forEach>
								</td>
							</tr>
						</tbody>
					</table>
				</div>	
<!-- /우측 체크리스트 -->				
			</div>
<!-- 체크리스트 -->
<!-- 특이사항 -->		
			<div class="title-wrap mt10">
				<h4>특이사항</h4>
			</div>	
			<table class="table-border mt5">
				<colgroup>
					<col width="300px">
					<col width="">
				</colgroup>
				<tbody>
					<tr>
						<td class="td-gray">
							특이란에는 반드시 점검자의 이름, 점검 시행 일자, 점검에 대하여 고객에게 설명 여부, 고객 서명 날인 여부를 남기도록 한다. 또한 점검 리스트를 통한 점검 시행 결과도 남기도록 한다.
						</td>
						<td>
							<textarea id="check_text" name="check_text" class="form-control essential-bg" style="height: 100%;">${result.check_text}</textarea>
						</td>
					</tr>
				</tbody>
			</table>
<!-- /특이사항 -->	
<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt10">						
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>