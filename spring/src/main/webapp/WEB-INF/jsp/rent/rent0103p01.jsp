<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 렌탈운영 > 고객 앱 신청현황 > 고객 앱 신청현황 상세 > null
-- 작성자 : 이강원
-- 최초 작성일 : 2023-08-04 15:06:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		$(document).ready(function() {
			if (${item.complete_yn eq 'Y'}) {
				$("#_goComplete").hide();
			}
		});
	
	    function goComplete() {
			if($M.getValue("remark") == "") {
				alert("종결처리 시 종결내용은 필수입력입니다.");
				return;
			}

			var param = {
				c_rental_request_seq : $M.getValue("c_rental_request_seq"),
				remark : $M.getValue("remark"),
			}

			$M.goNextPageAjaxMsg("종결처리 하시겠습니까?", this_page + '/complete', $M.toGetParam(param) , {method : 'POST'},
				function(result) {
					if(result.success) {
						alert("처리가 완료되었습니다.");
						window.location.reload();
					}
				}
			);
	    }
	    
	    function fnClose() {
	    	window.close();
	    }
	</script>
</head>
<body   class="bg-white"  >
<form id="main_form" name="main_form">
<input type="hidden" id="c_rental_request_seq" name="c_rental_request_seq" value="${item.c_rental_request_seq }">
<!-- 팝업 -->
    <div class="popup-wrap width-100per" style="min-width: 1000px">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">	
			<div class="title-wrap">
				<h4>신청상세</h4>
			</div>	
<!-- 폼 테이블 -->			
			<table class="table-border mt5">
				<colgroup>
					<col width="100px">
					<col width="200px">
					<col width="100px">
					<col width="200px">
					<col width="100px">
					<col width="200px">
				</colgroup>
				<tbody>
					<tr>
						<th class="text-right">구분</th>
						<td>
							<div class="input-group width200px">
								<input type="text" class="form-control" id="rental_gubun" name="rental_gubun" value="${item.rental_gubun}" disabled="disabled">
							</div>
						</td>
						<th class="text-right">신청일자</th>
						<td>
							<div class="input-group width200px">
								<input type="text" class="form-control" dateFormat="yyyy-MM-dd" id="request_dt" name="request_dt" value="${item.request_dt}" alt="신청일자" disabled="disabled">
							</div>
						</td>
						<th class="text-right">렌탈신청기간</th>
						<td>
							<div class="input-group width200px">
								<input type="text" class="form-control" id="rental_dt" name="rental_dt" value="${item.rental_dt}" alt="렌탈신청기간" disabled="disabled">
							</div>
						</td>
					</tr>
					<tr>

						<th class="text-right">고객명</th>
						<td>
							<div class="form-row inline-pd">
								<div class="col-6">
									<input type="text" class="form-control" id="cust_name" name="cust_name" readonly="readonly" required="required" alt="고객명" value="${item.cust_name }">
									<input type="hidden" id="cust_no" name="cust_no" value="${item.cust_no }">
									<!-- 연관업무 버튼 마우`스 오버시 레이어팝업 -->
									<input type="hidden" name="__s_cust_no" value="${item.cust_no}">
									<input type="hidden" name="__s_hp_no" value="${item.hp_no}">
									<input type="hidden" name="__s_cust_name" value="${item.cust_name}">
									<!-- /연관업무 버튼 마우스 오버시 레이어팝업 -->
								</div>
								<div class="col-3">
									<jsp:include page="/WEB-INF/jsp/common/commonCustJob.jsp">
										<jsp:param name="li_type" value="__ledger#__sms_popup#__sms_info#__check_required#__cust_rental_history#__rental_consult_history"/>
									</jsp:include>
								</div>
							</div>
						</td>
						<th class="text-right">연락처</th>
						<td>
							<div class="input-group width200px">
								<input type="text" class="form-control width200px" readonly="readonly" id="hp_no" name="hp_no" value="${item.hp_no}" format="tel">
							</div>
						</td>
						</td>
						<th class="text-right">연장신청기간</th>
						<td>
							<div class="input-group width200px">
								<input type="text" class="form-control width200px" readonly="readonly" id="extend_dt" name="extend_dt" value="${item.extend_dt}">
							</div>
						</td>
					</tr>
					<tr>
						<th class="text-right">메이커</th>
						<td>
							<div class="input-group width200px">
								<input type="text" class="form-control" id="maker_name" name="maker_name" value="${item.maker_name}" disabled="disabled">
							</div>
						</td>
						<th class="text-right">모델명</th>
						<td>
							<div class="input-group width200px">
								<input type="text" class="form-control" id="machine_name" name="machine_name" value="${item.machine_name}" alt="모델명" disabled="disabled">
							</div>
						</td>
						<th class="text-right">처리일자</th>
						<td>
							<div class="input-group width200px">
								<input type="text" class="form-control" dateFormat="yyyy-MM-dd" id="complete_dt" name="complete_dt" value="${item.complete_dt}" alt="처리일자" disabled="disabled">
							</div>
						</td>
					</tr>
					<tr>
						<th class="text-right">일정구분</th>
						<td>
							<div class="input-group width200px">
								<input type="text" class="form-control" id="fix_day_yn" name="fix_day_yn" value="${item.fix_day_yn}" disabled="disabled">
							</div>
						</td>
						<th class="text-right">처리상태</th>
						<td>
							<div class="input-group width200px">
								<input type="text" class="form-control" id="complete_yn" name="complete_yn" value="${item.complete_yn}" alt="처리상태" disabled="disabled">
							</div>
						</td>
						<th class="text-right">처리자</th>
						<td>
							<div class="input-group width200px">
								<input type="text" class="form-control" id="complete_mem_name" name="complete_mem_name" value="${item.complete_mem_name}" alt="처리자" disabled="disabled">
							</div>
						</td>
					</tr>
					<tr>
						<th class="text-right">실 사용지역</th>
						<td colspan="5">
							<div class="input-group width900px">
								<input type="text" class="form-control" id="addr" name="addr" value="${item.addr}" disabled="disabled">
							</div>
						</td>
					</tr>
					<tr>
						<th class="text-right">추가요청사항</th>
						<td colspan="5">
							<textarea class="form-control" style="height: 200px;" id="add_text" name="add_text" disabled>${item.add_text}</textarea>
						</td>
					</tr>
					<tr>
						<th class="text-right">종결내용</th>
						<td colspan="5">
							<textarea class="form-control" style="height: 200px;" id="remark" name="remark" <c:if test="${item.complete_yn eq 'Y'}">disabled</c:if>>${item.remark}</textarea>
						</td>
					</tr>
				</tbody>
			</table>			
<!-- /폼 테이블 -->	
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