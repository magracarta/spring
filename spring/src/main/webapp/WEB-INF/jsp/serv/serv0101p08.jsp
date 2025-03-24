<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 정비 > 정비지시서 > null > 미결사항등록/상세
-- 작성자 : 성현우
-- 최초 작성일 : 2020-06-29 19:54:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

	// 저장
	function goSave() {
		var frm = document.main_form;
		//validationcheck
		if($M.validation(frm,
				{field:["as_todo_type_cd", "todo_text", "plan_dt"]})==false) {
			return;
		};

		var procText = $M.getValue("proc_text");
		var params = {
			"machine_seq" : '${inputParam.machine_seq}',
			"todo_dt" : '${inputParam.s_current_dt}',
			"as_todo_status_cd" : "0",
			"as_todo_type_cd" : $M.getValue("as_todo_type_cd"),
			"assign_mem_no" : '${SecureUser.mem_no}',
			"todo_text" : $M.getValue("todo_text"),
			"plan_dt" : $M.getValue("plan_dt"),
			"proc_text" : procText,
			"as_no" : $M.getValue("as_no")
		};

		if(procText != "") {
			params.as_todo_status_cd = "9";
			params.proc_mem_no = $M.getValue("proc_mem_no");
		}

		$M.goNextPageAjaxSave(this_page + "/save", $M.toGetParam(params), {method : 'POST'},
			function (result) {
				alert("저장이 완료되었습니다.");
				fnClose();
        
        <c:if test="${inputParam.no_reload ne 'Y'}">
				  window.opener.location.reload();
        </c:if>
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
<input type="hidden" id="assign_mem_no" name="assign_mem_no" value="${result.mem_no}">
<input type="hidden" id="proc_mem_no" name="proc_mem_no" value="${result.mem_no}">
<input type="hidden" id="as_todo_status_cd" name="as_todo_status_cd">
<input type="hidden" id="as_no" name="as_no" value="${inputParam.as_no}">

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
						<col width="100px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right essential-item">구분</th>
							<td>
								<select class="form-control width120px essential-bg" id="as_todo_type_cd" name="as_todo_type_cd" alt="구분">
									<c:forEach items="${codeMap['AS_TODO_TYPE']}" var="item">
										<option value="${item.code_value}" ${item.code_value == init_as_todo_type ? 'selected' : ''}>${item.code_name}</option>
									</c:forEach>
								</select>
							</td>
							<th class="text-right">처리자</th>
							<td>
								<input type="text" id="assign_mem_name" name="assign_mem_name" class="form-control" readonly="readonly" value="${result.mem_name}">
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">미결사항</th>
							<td colspan="3">
								<input type="text" id="todo_text" name="todo_text" class="form-control essential-bg" alt="미결사항" maxlength="500">
							</td>						
						</tr>
						<tr>
							<th class="text-right essential-item">예정일자</th>
							<td>
								<div class="input-group width120px">
									<input type="text" class="form-control border-right-0 essential-bg calDate" id="plan_dt" name="plan_dt" value="${plan_dt}" dateformat="yyyy-MM-dd" alt="예정일자">
								</div>
							</td>
							<th class="text-right">연기일자</th>
							<td>
								<input type="text" id="delay_dt" name="delay_dt" class="form-control width100px" readonly="readonly">
							</td>							
						</tr>
						<tr>
							<th class="text-right">처리사항</th>
							<td colspan="3">
								<input type="text" id="proc_text" name="proc_text" class="form-control">
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
<!-- /팝업 -->
</form>
</body>
</html>