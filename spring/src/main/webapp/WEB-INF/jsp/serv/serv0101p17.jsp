<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 정비 > 정비지시서 > null > 미결사항상세
-- 작성자 : 성현우
-- 최초 작성일 : 2020-06-29 14:00:05
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		// 저장
		function goSave() {
			var check = $M.getValue("check");
			if(check) {
				if($M.getValue("change_assign_mem_no") == "") {
					alert("담당자이관처리를 선택한 경우\n이관할 담당자를 지정해주세요.");
					return;
				}
			}

			var procText = $M.getValue("proc_text");

			var params = {
				"machine_seq" : $M.getValue("machine_seq"),
				"as_todo_seq" : $M.getValue("as_todo_seq"),
				"as_no" : $M.getValue("as_no"),
				"todo_dt" : $M.getValue("todo_dt"),
				"as_todo_status_cd" : $M.getValue("as_todo_status_cd"),
				"as_todo_type_cd" : $M.getValue("as_todo_type_cd"),
				"assign_mem_no" : $M.getValue("assign_mem_no"),
				"todo_text" : $M.getValue("todo_text"),
				"plan_dt" : $M.getValue("plan_dt"),
				"proc_text" : procText
			};

			// 처리내용이 있는경우
			if(procText != "") {
				params.as_todo_status_cd = "9";
				params.proc_mem_no = '${SecureUser.mem_no}';
			}

			var msg = "저장하시겠습니까?";

			// 담당자 이관처리를 하는 경우
			if(check) {
				params.change_assign_mem_no = $M.getValue("change_assign_mem_no");
				params.proc_text = "[" + $M.getValue("change_assign_mem_name") + "]에게 이관";
				params.as_todo_status_cd = "9";
				params.proc_mem_no = '${SecureUser.mem_no}';
				params.cmd = "U";
				msg = "담장자 이관처리를 하시겠습니까?";
			}

			$M.goNextPageAjaxMsg(msg, this_page + "/save", $M.toGetParam(params), {method : 'POST'},
				function (result) {
					if(result.success) {
						alert("처리가 완료되었습니다.");
						fnClose();
						window.opener.location.reload();
					}
				}
			);
		}

		// 닫기
		function fnClose() {
			window.close();
		}

		// 담당자이관 정보 Setting
		function setMemberOrgMapPanel(data) {
			$M.setValue("change_assign_mem_name", data.mem_name);
			$M.setValue("change_assign_mem_no", data.mem_no);
		}


		// 담당자이관 checkbox 체크여부 확인
		function fnChange() {
			var check = $M.getValue("check");

			if(check) {
				$('.section-inner').addClass('active');
				$("#proc_text").prop("readonly", true);
				$M.clearValue({field:["proc_text"]});
			} else {
				$('.section-inner').removeClass('active');
				$("#proc_text").prop("readonly", false);
				$M.clearValue({field:["change_assign_mem_no", "change_assign_mem_name", "proc_text"]});
			}
		}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<input type="hidden" id="assign_mem_no" name="assign_mem_no" value="${result.assign_mem_no}">
	<input type="hidden" id="proc_mem_no" name="proc_mem_no">
	<input type="hidden" id="change_assign_mem_no" name="change_assign_mem_no">
	<input type="hidden" id="cmd" name="cmd" value="C">
	<input type="hidden" id="as_todo_status_cd" name="as_todo_status_cd" value="${result.as_todo_status_cd}">
	<input type="hidden" id="todo_dt" name="todo_dt" value="${result.todo_dt}">
	<input type="hidden" id="machine_seq" name="machine_seq" value="${result.machine_seq}">
	<input type="hidden" id="as_todo_seq" name="as_todo_seq" value="${result.as_todo_seq}">
	<input type="hidden" id="as_no" name="as_no" value="${result.as_no}">

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
						<th class="text-right">구분</th>
						<td>
							<select class="form-control width120px" id="as_todo_type_cd" name="as_todo_type_cd">
								<c:forEach items="${codeMap['AS_TODO_TYPE']}" var="item">
									<option value="${item.code_value}" ${result.as_todo_type_cd == item.code_value ? 'selected="selected"' : ''}>${item.code_name}</option>
								</c:forEach>
							</select>
						</td>
						<th class="text-right">처리자</th>
						<td>
							<input type="text" id="assign_mem_name" name="assign_mem_name" class="form-control" readonly="readonly" value="${result.assign_mem_name}">
						</td>
					</tr>
					<tr>
						<th class="text-right">미결사항</th>
						<td colspan="3">
							<input type="text" id="todo_text" name="todo_text" class="form-control" value="${result.todo_text}">
						</td>
					</tr>
					<tr>
						<th class="text-right">예정일자</th>
						<td>
							<div class="input-group width120px">
								<input type="text" class="form-control border-right-0 calDate" id="plan_dt" name="plan_dt" dateformat="yyyy-MM-dd" value="${result.plan_dt}">
							</div>
						</td>
						<th class="text-right">연기일자</th>
						<td>
							<input type="text" id="delay_dt" name="delay_dt" class="form-control width100px" readonly="readonly" value="${result.delay_dt}">
						</td>
					</tr>
					<tr>
						<th class="text-right">처리사항</th>
						<td colspan="3">
							<input type="text" id="proc_text" name="proc_text" class="form-control" value="${result.proc_text}">
						</td>
					</tr>
					</tbody>
				</table>
			</div>
			<!-- /폼테이블 -->
			<!-- 그리드 서머리, 컨트롤 영역 -->
			<c:if test="${SecureUser.mem_no == result.assign_mem_no}">
				<div class="btn-group mt5">
					<div class="left dpf">
						<div class="form-check form-check-inline">
							<input class="form-check-input" id="check" name="check" type="checkbox" onclick="javascript:fnChange();">
							<label class="form-check-label">담당자이관처리</label>
						</div>
						<div class="input-group width100px section-inner">
							<input type="text" id="change_assign_mem_name" name="change_assign_mem_name"  class="form-control border-right-0" readonly="readonly">
							<button type="button" class="btn btn-icon btn-primary-gra" style="min-width: initial;" onclick="javascript:openMemberOrgPanel('setMemberOrgMapPanel', 'N');"><i class="material-iconssearch"></i></button>
						</div>
					</div>
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
					</div>
				</div>
			</c:if>
			<!-- /그리드 서머리, 컨트롤 영역 -->
		</div>
	</div>
	<!-- /팝업 -->
</form>
</body>
</html>