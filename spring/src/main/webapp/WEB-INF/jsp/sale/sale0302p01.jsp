<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 영업관리 > 해외거래선관리 > null > 해외거래선상세
-- 작성자 : 성현우
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		// 수정
		function goModify() {
			var formData = document.main_form;
			// validation check
			if($M.validation(formData,
					{field:["maker_cd", "seq_no",  "biz_kor_name", "biz_eng_name", "charge_name"]}) == false) {
				return;
			};

			$M.goNextPageAjaxModify(this_page + '/modify', $M.toValueForm(formData), {method : "POST"},
				function(result) {
					if(result.success) {
						alert("수정이 완료되었습니다.");
						location.reload();
					}
				}
			);
		}

		// 삭제
		function goRemove() {
			var formData = document.main_form;

			// validation check
			if($M.validation(formData,
					{field:["maker_cd", "seq_no"]}) == false) {
				return;
			};

			$M.setValue(formData, "use_yn", "N");

			$M.goNextPageAjaxRemove(this_page + '/remove', $M.toValueForm(formData), {method : "POST"},
				function(result) {
					if(result.success) {
						alert("삭제가 완료되었습니다.");
						fnClose();
						window.opener.goSearch();
					}
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
	<input type="hidden" id="seq_no" name="seq_no" value="${result.seq_no}">
	<input type="hidden" id="use_yn" name="use_yn">
	<!-- 팝업 -->
	<div class="popup-wrap width-100per">
		<!-- 타이틀영역 -->
		<div class="main-title"><jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/></div>
		<!-- /타이틀영역 -->
		<div class="content-wrap">
			<div class="title-wrap">
				<h4 class="primary">해외거래선 상세</h4>
			</div>
			<!-- 상단 폼테이블 -->
			<div>
				<table class="table-border mt5">
					<colgroup>
						<col width="100px">
						<col width="">
						<col width="100px">
						<col width="">
						<col width="100px">
						<col width="">
						<col width="100px">
						<col width="">
					</colgroup>
					<tbody>
					<tr>
						<th class="text-right essential-item">거래선</th>
						<td>
							<select class="form-control width120px essential-bg" id="maker_cd" name="maker_cd" required="required" alt="거래선">
								<option value="">- 전체 -</option>
								<c:forEach items="${codeMap['MAKER']}" var="item">
									<c:if test="${item.code_v1 eq 'Y' && item.code_v2 eq 'Y'}">
										<option value="${item.code_value}" <c:if test="${result.maker_cd == item.code_value}">selected</c:if>>${item.code_name}</option>
									</c:if>
								</c:forEach>
							</select>
						</td>
						<th class="text-right essential-item">사업부</th>
						<td>
							<input type="text" class="form-control width150px essential-bg" id="biz_kor_name" name="biz_kor_name" required="required" alt="사업부" value="${result.biz_kor_name}">
						</td>
						<th class="text-right essential-item">사업부영문명</th>
						<td>
							<input type="text" class="form-control width120px essential-bg" id="biz_eng_name" name="biz_eng_name" required="required" alt="사업부 영문명" value="${result.biz_eng_name}">
						</td>
						<th class="text-right essential-item">영문명</th>
						<td>
							<input type="text" class="form-control width150px essential-bg" id="charge_name" name="charge_name" required="required" alt="영문명" value="${result.charge_name}">
						</td>
					</tr>
					<tr>
						<th class="text-right">현지어</th>
						<td>
							<input type="text" class="form-control width150px" id="local_lang" name="local_lang" value="${result.local_lang}">
						</td>
						<th class="text-right">직책</th>
						<td>
							<input type="text" class="form-control width150px" id="charge_grade" name="charge_grade" value="${result.charge_grade}">
						</td>
						<th class="text-right">근무시작일</th>
						<td>
							<div class="input-group date-wrap">
								<input type="text" class="form-control border-right-0 calDate" dateFormat="yyyy-MM-dd" id="job_start_dt" name="job_start_dt" value="${result.job_start_dt}">
							</div>
						</td>
						<th class="text-right">전배일</th>
						<td>
							<div class="input-group date-wrap">
								<input type="text" class="form-control border-right-0 calDate" dateFormat="yyyy-MM-dd" id="job_trans_dt" name="job_trans_dt" value="${result.job_trans_dt}">
							</div>
						</td>
					</tr>
					<tr>
						<th class="text-right">담당업무</th>
						<td>
							<input type="text" class="form-control width150px" id="charge_job" name="charge_job" value="${result.charge_job}">
						</td>
						<th class="text-right">근무국가</th>
						<td>
							<input type="text" class="form-control width150px" id="work_country" name="work_country" value="${result.work_country}">
						</td>
						<th class="text-right">근무상태</th>
						<td colspan="3">
							<c:forEach var="item" items="${codeMap['OVERSEAS_WORK_STATUS']}">
								<div class="form-check form-check-inline">
									<input class="form-check-input overseas_work_status_cd" type="radio" id="${item.code_value}" name="overseas_work_status_cd" value="${item.code_value}" <c:if test="${result.overseas_work_status_cd == item.code_value}">checked="checked"</c:if>>
									<label class="form-check-label" for="${item.code_value}">${item.code_name}</label>
								</div>
							</c:forEach>
						</td>
					</tr>
					<tr>
						<th class="text-right">회사전화</th>
						<td>
							<input type="text" class="form-control width150px" id="tel_no" name="tel_no" value="${result.tel_no}">
						</td>
						<th class="text-right">Mobile</th>
						<td>
							<input type="text" class="form-control width150px" id="hp_no" name="hp_no" value="${result.hp_no}">
						</td>
						<th class="text-right">FAX</th>
						<td>
							<input type="text" class="form-control width150px" id="fax_no" name="fax_no" value="${result.fax_no}">
						</td>
						<th class="text-right">E-mail</th>
						<td>
							<input type="text" class="form-control width200px" id="email" name="email" maxlength="100" format="email" value="${result.email}">
						</td>
					</tr>
					<tr>
						<th class="text-right">현업</th>
						<td>
							<div class="form-check form-check-inline">
								<input class="form-check-input" type="radio" id="current_job_yn_y" name="current_job_yn" value="Y" <c:if test="${result.current_job_yn eq 'Y'}">checked="checked"</c:if>>
								<label class="form-check-label" for="current_job_yn_y">현재</label>
							</div>
							<div class="form-check form-check-inline">
								<input class="form-check-input" type="radio" id="current_job_yn_n" name="current_job_yn" value="N" <c:if test="${result.current_job_yn eq 'N'}">checked="checked"</c:if>>
								<label class="form-check-label" for="current_job_yn_n">전배</label>
							</div>
						</td>
						<th class="text-right">도시</th>
						<td>
							<input type="text" class="form-control width150px" id="work_city" name="work_city" value="${result.work_city}">
						</td>
						<th class="text-right">주소</th>
						<td colspan="3">
							<input type="text" class="form-control" id="addr" name="addr" value="${result.addr}">
						</td>
					</tr>
					<tr>
						<th class="text-right">메모</th>
						<td colspan="7">
							<textarea class="form-control" style="height: 100px;" id="remark" name="remark">${result.remark}</textarea>
						</td>
					</tr>
					</tbody>
				</table>
			</div>
			<!-- /상단 폼테이블 -->
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