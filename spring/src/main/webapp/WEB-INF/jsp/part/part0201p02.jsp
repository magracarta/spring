<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 창고이동/부품출하 > 부품이동요청 > null > 배송정보
-- 작성자 : 손광진
-- 최초 작성일 : 2020-02-26 13:27:12
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		// 배송 주소저장
		function setAddress(data) {
			var frm = document.main_form;
			$M.setValue(frm, "biz_post_no", data.zipNo);
			$M.setValue(frm, "biz_addr1", data.roadAddrPart1);
			$M.setValue(frm, "biz_addr2", data.addrDetail);
		}
		
		function fnSendListPopup() {
			// part_trans_req_no opener 팝업 호출하여 데이터 받아야함
			var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=900, height=300, left=0, top=0";
			$M.goNextPage("/part/part0201p03", "", {popupStatus : poppupOption});
		}

		function goSave() {
			alert("저장 버튼입니다.");
		}

		//팝업 닫기
		function fnClose() {
			window.close(); 
		}
	</script>
</head>
<body class="bg-white class">
	<form id="main_form" name="main_form">
		<!-- 팝업 -->
	    <div class="popup-wrap width-100per">
			<!-- 타이틀영역 -->
			<div class="main-title">
				<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp" />
			</div>
			<!-- /타이틀영역 -->
	        <div class="content-wrap">	
				<!-- 폼테이블 -->					
				<div>
					<div class="title-wrap">
						<h4>배송정보</h4>
					</div>
					<table class="table-border mt5">
						<colgroup>
							<col width="100px">
							<col width="">
							<col width="100px">
							<col width="">
						</colgroup>
						<tbody>
							<tr>
								<th class="text-right">발송구분</th>
								<td>
									<select class="form-control">
										<option>방문</option>
										<option>방문</option>
									</select>
								</td>	
								<th class="text-right">배송구분</th>
								<td>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio">
										<label class="form-check-label">선불</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio">
										<label class="form-check-label">착불</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio">
										<label class="form-check-label">발신</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio">
										<label class="form-check-label">착신</label>
									</div>
								</td>					
							</tr>
							<tr>
								<th class="text-right">고객명</th>
								<td>
									<input type="text" class="form-control">
								</td>	
								<th class="text-right">전화번호</th>
								<td>
									<input type="text" class="form-control">
								</td>						
							</tr>
							<tr>
								<th class="text-right">휴대폰</th>
								<td>
									<input type="text" class="form-control">
								</td>	
								<th class="text-right">송장</th>
								<td>
									<input type="text" class="form-control">
								</td>						
							</tr>	
							<tr>
								<th class="text-right">배송비</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-10">
											<input type="text" class="form-control text-right">
										</div>
										<div class="col-2">원</div>
									</div>
								</td>	
								<th class="text-right">수량</th>
								<td>
									<input type="text" class="form-control text-right">
								</td>						
							</tr>
							<tr>
								<th class="text-right">주소</th>
								<td colspan="3">
									<div class="form-row inline-pd mb7">
										<div class="col-4">
											<input type="text" id="biz_post_no" name="biz_post_no" class="form-control">
										</div>
										<div class="col-auto">
											<button type="button" onclick="javascript:openSearchAddrPanel('setAddress')" class="btn btn-primary-gra">주소찾기</button>
											<button type="button" class="btn btn-primary-gra" onclick="javascript:fnSendListPopup();">이전발송지</button>
										</div>											
									</div>
									<div class="form-row inline-pd mb7">
										<div class="col-12">
											<input type="text" class="form-control" id="biz_addr1" name="biz_addr1">
										</div>
									</div>
									<div class="form-row inline-pd">
										<div class="col-12">
											<input type="text" class="form-control" id="biz_addr2" name="biz_addr2">
										</div>
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
		<!-- /팝업 -->
	</form>
</body>
</html>