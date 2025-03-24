<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 자산 > 인사관리 > null > 기타설정 탭
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-05-14 20:03:57
-- 조회 컨트롤러 : ACNT0601P01Controller.selectMemEtcSetting
-- 체크박스 추가는 goModify에 체크박스 어레이에 추가하기! 
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		
		$(document).ready(function() {
			
		});
		
		//팝업 닫기
		function fnClose() {
			top.window.close(); 
		}
		
		function goModify() {
			var checkBoxArray = ["no_masking_yn_check", "name_masking_yn_check"];
			for (var i = 0; i < checkBoxArray.length; ++i) {
				var original = checkBoxArray[i].replace("_check", "");
				if ($M.getValue(checkBoxArray[i]) == "") {
					$M.setValue(original, "N");
				} else {
					$M.setValue(original, "Y");
				}
				console.log(original, $M.getValue(original));
			}
			var form = document.main_form;
			$M.goNextPageAjaxModify(this_page + "/modify", $M.toValueForm(form), {method : "POST"},
				function(result) {
		    		if(result.success) {
		    			
					}
				}
			);
		}
		
	</script>
</head>
<body class="bg-white">
	<form id="main_form" name="main_form">
		<input type="hidden" id="req_mem_no" name="req_mem_no" value="${etc.mem_no}" />
		<input type="hidden" id="req_org_code" name="req_org_code" value="${etc.org_code }"/>
	<!-- 팝업 -->
	    <div class="popup-wrap width-100per" style="margin-top: 4px;">
			<div class="col-12" style="padding: 0">
				<div>
					<table class="table-border">
						<colgroup>
							<col width="300px">
							<!-- 75에서 100으로수정-->
							<col width="">
							<col width="300px">
							<col width="">
						</colgroup>
						<tbody>
							<tr>
								<th class="text-right">입고단가표시함</th>
								<td>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" name="inprice_show_yn" id="inprice_show_yn_y" value="Y"
										 <c:if test="${etc.inprice_show_yn == 'Y'}">checked="checked"</c:if>
										>
										<label class="form-check-label" for="inprice_show_yn_y">Y</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" name="inprice_show_yn" id="inprice_show_yn_n" value="N"
										<c:if test="${etc.inprice_show_yn == 'N'}">checked="checked"</c:if>
										> 
										<label class="form-check-label" for="inprice_show_yn_n">N</label>
									</div>
								</td>
								<th class="text-right">마케팅관리담당: 출하의뢰서 관리확인 요청 쪽지 수신</th>
								<td>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" name="acnt_mng_yn" id="acnt_mng_yn_y" value="Y"
										<c:if test="${etc.acnt_mng_yn == 'Y'}">checked="checked"</c:if>
										>
										<label class="form-check-label" for="acnt_mng_yn_y">Y</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" name="acnt_mng_yn" id="acnt_mng_yn_n" value="N"
										<c:if test="${etc.acnt_mng_yn == 'N'}">checked="checked"</c:if>
										> 
										<label class="form-check-label" for="acnt_mng_yn_n">N</label>
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right">출하담당: 출하의뢰서 출하처리 요청 쪽지 수신</th>
								<td>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" name="out_mng_yn" id="out_mng_yn_y" value="Y"
										<c:if test="${etc.out_mng_yn == 'Y'}">checked="checked"</c:if>
										>
										<label class="form-check-label" for="out_mng_yn_y">Y</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" name="out_mng_yn" id="out_mng_yn_n" value="N"
										<c:if test="${etc.out_mng_yn == 'N'}">checked="checked"</c:if>
										>
										<label class="form-check-label" for="out_mng_yn_n">N</label>
									</div>
								</td>
								<th class="text-right">DI담당(출하의뢰서 관리확인시 쪽지 및 SMS수신)</th>
								<td>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" name="di_mng_yn" id="di_mng_yn_y" value="Y"
										<c:if test="${etc.di_mng_yn == 'Y'}">checked="checked"</c:if>
										>
										<label class="form-check-label" for="di_mng_yn_y">Y</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" name="di_mng_yn" id="di_mng_yn_n" value="N"
										<c:if test="${etc.di_mng_yn == 'N'}">checked="checked"</c:if>
										>
										<label class="form-check-label" for="di_mng_yn_n">N</label>
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right">전도금정산서 사업장 확정 쪽지수신</th>
								<td>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" name="imprest_paper_yn" id="imprest_paper_yn_y" value="Y"
										<c:if test="${etc.imprest_paper_yn == 'Y'}">checked="checked"</c:if>
										>
										<label class="form-check-label" for="imprest_paper_yn_y">Y</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" name="imprest_paper_yn" id="imprest_paper_yn_n" value="N"
										<c:if test="${etc.imprest_paper_yn == 'N'}">checked="checked"</c:if>
										> 
										<label class="form-check-label" for="imprest_paper_yn_n">N</label>
									</div>
								</td>
								<th class="text-right">일마감취소허용</th>
								<td>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" name="day_end_yna" id="day_end_y" value="Y"
										<c:if test="${etc.day_end_yna == 'Y'}">checked="checked"</c:if>
										>
										<label class="form-check-label" for="day_end_y">허용</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" name="day_end_yna" id="day_end_n" value="N"
										<c:if test="${etc.day_end_yna == 'N'}">checked="checked"</c:if>
										> 
										<label class="form-check-label" for="day_end_n">안함</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" name="day_end_yna" id="day_end_a" value="A"
										<c:if test="${etc.day_end_yna == 'A'}">checked="checked"</c:if>
										> 
										<label class="form-check-label" for="day_end_a">마감취소포함 허용</label>
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right">마스킹 여부</th>
								<td>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="checkbox" name="no_masking_yn_check" id="no_masking_yn_check" value="Y"
										<c:if test="${etc.no_masking_yn == 'Y'}">checked="checked"</c:if>
										>
										<label class="form-check-label" for="no_masking_yn_check">전화번호 마스킹 처리여부</label>
										<input type="hidden" name="no_masking_yn">
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="checkbox" name="name_masking_yn_check" id="name_masking_yn_check" value="Y"
										<c:if test="${etc.name_masking_yn == 'Y'}">checked="checked"</c:if>
										> 
										<label class="form-check-label" for="name_masking_yn_check">이름 마스킹 처리여부</label>
										<input type="hidden" name="name_masking_yn">
									</div>
								</td>
								<th class="text-right">부품 분출요청 쪽지수신 여부</th>
								<td>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" name="part_out_paper_yn" id="part_out_paper_y" value="Y"
											   <c:if test="${etc.part_out_paper_yn == 'Y'}">checked="checked"</c:if>
										>
										<label class="form-check-label" for="part_out_paper_y">Y</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" name="part_out_paper_yn" id="part_out_paper_n" value="N"
											   <c:if test="${etc.part_out_paper_yn == 'N'}">checked="checked"</c:if>
										>
										<label class="form-check-label" for="part_out_paper_n">N</label>
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right">장비입고담당여부</th>
								<td>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" name="machine_in_mng_yn" id="machine_in_mng_yn_y" value="Y"
										<c:if test="${etc.machine_in_mng_yn == 'Y'}">checked="checked"</c:if>
										>
										<label class="form-check-label" for="machine_in_mng_yn_y">Y</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" name="machine_in_mng_yn" id="machine_in_mng_yn_n" value="N"
										<c:if test="${etc.machine_in_mng_yn == 'N'}">checked="checked"</c:if>
										> 
										<label class="form-check-label" for="machine_in_mng_yn_n">N</label>
									</div>
								</td>
								<th class="text-right">출하종결건 센터별 조회 허용</th>
								<td>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" name="out_not_end_center_search_yn" id="out_not_end_center_search_yn_y" value="Y"
										<c:if test="${etc.out_not_end_center_search_yn == 'Y'}">checked="checked"</c:if>
										>
										<label class="form-check-label" for="out_not_end_center_search_yn_y">Y</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" name="out_not_end_center_search_yn" id="out_not_end_center_search_yn_n" value="N"
										<c:if test="${etc.out_not_end_center_search_yn == 'N'}">checked="checked"</c:if>
										> 
										<label class="form-check-label" for="out_not_end_center_search_yn_n">N</label>
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right">라인동기화권한여부</th>
								<td>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" name="line_sync_auth_yn" id="line_sync_auth_yn" value="Y"
										<c:if test="${etc.line_sync_auth_yn == 'Y'}">checked="checked"</c:if>
										>
										<label class="form-check-label" for="line_sync_auth_yn_y">Y</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" name="line_sync_auth_yn" id="line_sync_auth_yn" value="N"
										<c:if test="${etc.line_sync_auth_yn == 'N'}">checked="checked"</c:if>
										> 
										<label class="form-check-label" for="line_sync_auth_yn_n">N</label>
									</div>
								</td>
								<th></th>
								<td></td>
							</tr>
						</tbody>
					</table>
				</div>
				<!-- /폼테이블 -->
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