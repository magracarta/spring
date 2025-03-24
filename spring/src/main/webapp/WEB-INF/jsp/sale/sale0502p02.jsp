<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > MS관리 > MS관리-부서별 > null > 차량관리
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		function goList(){
			var poppupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=420, left=0, top=0";
			$M.goNextPage('/sale/sale0502p03', "", {popupStatus : poppupOption});
		} 
		
		function goSave(){
			alert("실주저장");
		}
		
		function fnCancel (){
			alert("실주 취소");
		}
		
		function fnClose() {
			window.close(); 
		}
		
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
        <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">	
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
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right">연월</th>
							<td>
								<input type="text" class="form-control" readonly>
							</td>
							<th class="text-right">국가</th>
							<td>
								<input type="text" class="form-control" readonly>
							</td>	
							<th class="text-right">메이커명</th>
							<td>
								<input type="text" class="form-control" readonly>
							</td>						
						</tr>
						<tr>
							<th class="text-right">모델</th>
							<td>
								<input type="text" class="form-control" readonly>
							</td>
							<th class="text-right">중량</th>
							<td>
								<input type="text" class="form-control" readonly>
							</td>	
							<th class="text-right">수량</th>
							<td>
								<input type="text" class="form-control" readonly>
							</td>						
						</tr>
						<tr>
							<th class="text-right">시</th>
							<td>
								<input type="text" class="form-control" readonly>
							</td>
							<th class="text-right">군/구</th>
							<td>
								<input type="text" class="form-control" readonly>
							</td>	
							<th class="text-right">읍/면/동</th>
							<td>
								<input type="text" class="form-control" readonly>
							</td>						
						</tr>
						<tr>
							<th class="text-right">마케팅/자가</th>
							<td>
								<select class="form-control" disabled>
									<option>마케팅</option>
									<option>마케팅</option>
								</select>
							</td>
							<th class="text-right">기종명</th>
							<td>
								<input type="text" class="form-control" readonly>
							</td>	
							<th class="text-right">규격명</th>
							<td>
								<input type="text" class="form-control" readonly>
							</td>						
						</tr>
						<tr>
							<th class="text-right">YK메이커명</th>
							<td>
								<input type="text" class="form-control" readonly>
							</td>		
							<th class="text-right">지역명</th>
							<td>
								<input type="text" class="form-control" readonly>
							</td>	
							<th class="text-right">우편번호</th>
							<td>
								<input type="text" class="form-control" readonly>
							</td>						
						</tr>
						<tr>
							<th class="text-right">등록자</th>
							<td>
								<input type="text" class="form-control" readonly>
							</td>		
							<th class="text-right">등록일</th>
							<td>
								<input type="text" class="form-control" readonly>
							</td>	
							<th class="text-right">수정일</th>
							<td>
								<input type="text" class="form-control" readonly>
							</td>						
						</tr>								
					</tbody>
				</table>
			</div>
<!-- /상단 폼테이블 -->	
<!-- 하단 폼테이블 -->					
			<div>
<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt20">
				<div class="left">
					<div class="form-check form-check-inline">
						<input class="form-check-input" type="checkbox">
						<label class="form-check-label">렌탈여부</label>
					</div>
				</div>				
				<div class="right">				
				<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
				</div>
			</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
				<table class="table-border mt5">
					<colgroup>
						<col width="100px">
						<col width="30%">
						<col width="100px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right">고객명</th>
							<td>
								<input type="text" class="form-control">
							</td>
							<th rowspan="2" class="text-right">주소</th>
							<td rowspan="2">
								<div class="form-row inline-pd mb7">
									<div class="col-4">
										<div class="input-group">
											<input type="text" class="form-control border-right-0">
											<button type="button" class="btn btn-icon btn-primary-gra"><i class="material-iconssearch"></i></button>
										</div>
									</div>
									<div class="col-8">
										<input type="text" class="form-control">
									</div>
								</div>
								<div class="form-row inline-pd">
									<div class="col-12">
										<input type="text" class="form-control">
									</div>
								</div>
							</td>		
						</tr>
						<tr>
							<th class="text-right">핸드폰</th>
							<td>
								<input type="text" class="form-control">
							</td>
						</tr>
						<tr>
							<th class="text-right">전화번호</th>
							<td>
								<input type="text" class="form-control">
							</td>
							<th class="text-right">특이사항</th>
							<td>
								<input type="text" class="form-control">
							</td>
						</tr>
						<tr>
							<th class="text-right">판매유형</th>
							<td colspan="3">
								<div class="form-row inline-pd mb10">
									<div class="col-2">
										<select class="form-control">
											<option>선택</option>
											<option>선택</option>
										</select>
									</div>
									<div class="col-2">
										<select class="form-control">
											<option>선택</option>
											<option>선택</option>
										</select>
									</div>
								</div>
<!-- 2depth콤보가 반복구매/경쟁사 정보면 아래 체크항목 호출 -->						
								<div class="form-row inline-pd">
									<div class="col-4">
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="checkbox">
											<label class="form-check-label">장비성능이 좋아서</label>
										</div>
									</div>
									<div class="col-4">
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="checkbox">
											<label class="form-check-label">기존장비의 익숙성</label>
										</div>
									</div>
									<div class="col-4">
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="checkbox">
											<label class="form-check-label">정비공장의 접근성</label>
										</div>
									</div>
								</div>
								<div class="form-row inline-pd">
									<div class="col-4">
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="checkbox">
											<label class="form-check-label">서비스 만족</label>
										</div>
									</div>
									<div class="col-4">
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="checkbox">
											<label class="form-check-label">중고가격이 높아서</label>
										</div>
									</div>
									<div class="col-4">
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="checkbox">
											<label class="form-check-label">유지관리비 저렴</label>
										</div>
									</div>
								</div>
								<div class="form-row inline-pd">
									<div class="col-4">
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="checkbox">
											<label class="form-check-label">가격이 싸서</label>
										</div>
									</div>
									<div class="col-4">
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="checkbox">
											<label class="form-check-label">부품의 원할한 공급</label>
										</div>
									</div>
									<div class="col-4">
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="checkbox">
											<label class="form-check-label">외형디자인 만족</label>
										</div>
									</div>
								</div>
								<div class="form-row inline-pd">
									<div class="col-4">
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="checkbox">
											<label class="form-check-label">마케팅력</label>
										</div>
									</div>
									<div class="col-4">
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="checkbox">
											<label class="form-check-label">부품 가격이 싸서</label>
										</div>
									</div>
									<div class="col-4">
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="checkbox">
											<label class="form-check-label">안전성</label>
										</div>
									</div>
								</div>
<!-- /2depth콤보가 반복구매/경쟁사 정보면 아래 체크항목 호출 -->
<!-- 2depth콤보가 신규고객이면 아래 체크항목 호출 						
								<div class="form-row inline-pd">
									<div class="col-4">
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="checkbox">
											<label class="form-check-label">시장호평</label>
										</div>
									</div>
									<div class="col-4">
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="checkbox">
											<label class="form-check-label">임대장비에 대한 이미지</label>
										</div>
									</div>
									<div class="col-4">
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="checkbox">
											<label class="form-check-label">주변권유</label>
										</div>
									</div>
								</div>
								<div class="form-row inline-pd">
									<div class="col-4">
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="checkbox">
											<label class="form-check-label">사업확장</label>
										</div>
									</div>
									<div class="col-4">
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="checkbox">
											<label class="form-check-label">인터넷검색</label>
										</div>
									</div>
									<div class="col-4">
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="checkbox">
											<label class="form-check-label">기존장비의 익숙성(기사)</label>
										</div>
									</div>
								</div>
								<div class="form-row inline-pd">
									<div class="col-4">
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="checkbox">
											<label class="form-check-label">영업력</label>
										</div>
									</div>
								</div>
<!-- /2depth콤보가 신규고객이면 아래 체크항목 호출 -->
							</td>
						</tr>									
					</tbody>
				</table>
			</div>
<!-- /하단 폼테이블 -->	
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