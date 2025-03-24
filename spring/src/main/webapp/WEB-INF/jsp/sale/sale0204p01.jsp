<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 장비관리 > 장비통합조회 > null > 장비통합조회상세
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <h2>장비통합조회</h2>
            <button type="button" class="btn btn-icon"><i class="material-iconsclose"></i></button>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">	
			<div class="title-wrap">		
				<h4 class="primary">장비통합조회상세</h4>	
				<div class="text-secondary">주의! 장비 상태를 <span class="text-primary">정비후</span>로 선택하였을 경우, 반드시 완료 예정일자와 사유를 반드시 입력!</div>			
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
					</colgroup>
					<tbody>						
						<tr>
							<th class="text-right">차대번호</th>
							<td>
								<input type="text" class="form-control" readonly>
							</td>									
							<th class="text-right essential-item">장비상태</th>
							<td colspan="3">
								<div class="form-row inline-pd">
									<div class="col-2">
										<select class="form-control" disabled>
											<option>정비후</option>
										</select>
									</div>
									<div class="col-2">
										<select class="form-control" disabled>
											<option>정상</option>
										</select>
									</div>
									<div class="col-3 text-right">
										정비완료 예정일자
									</div>
									<div class="col-3">
										<div class="input-group">
											<input type="text" class="form-control border-right-0" readonly>
											<button type="button" class="btn btn-icon btn-primary-gra"><i class="material-iconsdate_range"></i></button>
										</div>
									</div>
								</div>
							</td>	
						</tr>
						<tr>
							<th class="text-right">모델명</th>
							<td>
								<input type="text" class="form-control" readonly>
							</td>	
							<th class="text-right">엔진번호</th>
							<td>
								<input type="text" class="form-control" readonly>
							</td>
							<th class="text-right">관리번호</th>
							<td>
								<input type="text" class="form-control" readonly>
							</td>
						</tr>
						<tr>
							<th class="text-right">전시점</th>
							<td>
								<input type="text" class="form-control" readonly>
							</td>	
							<th class="text-right">판매점</th>
							<td>
								<input type="text" class="form-control" readonly>
							</td>
							<th class="text-right">판매일</th>
							<td>
								<div class="input-group">
									<input type="text" class="form-control border-right-0" readonly>
									<button type="button" class="btn btn-icon btn-primary-gra"><i class="material-iconsdate_range"></i></button>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">출하일</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-6">
										<div class="input-group">
											<input type="text" class="form-control border-right-0" readonly>
											<button type="button" class="btn btn-icon btn-primary-gra"><i class="material-iconsdate_range"></i></button>
										</div>
									</div>
									<div class="col-6">
										<select class="form-control" disabled>
											<option>보유</option>
										</select>
									</div>
								</div>
							</td>	
							<th class="text-right">입고처리일</th>
							<td>
								<div class="input-group">
									<input type="text" class="form-control border-right-0" readonly>
									<button type="button" class="btn btn-icon btn-primary-gra"><i class="material-iconsdate_range"></i></button>
								</div>
							</td>
							<th class="text-right">출하처리일</th>
							<td>
								<div class="input-group">
									<input type="text" class="form-control border-right-0" readonly>
									<button type="button" class="btn btn-icon btn-primary-gra"><i class="material-iconsdate_range"></i></button>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">화물기사명</th>
							<td>
								<input type="text" class="form-control" readonly>
							</td>	
							<th class="text-right">기사전화번호</th>
							<td>
								<input type="text" class="form-control" readonly>
							</td>
							<th class="text-right">출하처리담당자</th>
							<td>
								<input type="text" class="form-control" readonly>
							</td>
						</tr>
						<tr>
							<th class="text-right">차주명</th>
							<td>
								<div class="form-row inline-pd pr">
									<div class="col-8">
										<input type="text" class="form-control" readonly>
									</div>
									<div class="col-4">
										<button type="button" class="btn btn-primary-gra" style="width: 100%;">연관업무<i class="material-iconsexpand_more text-primary"></i></button>					
									</div>
<!-- 연관업무 버튼 마우스 오버시 레이어팝업 -->
									<div class="con-info" style="max-height: 100px; left: auto; right: 5px; width: 140px;">
										<ul class="">
											<li>수리내역조회</li>							<li>출하이력조회</li>
											<li>리콜처리확인</li>
											<li>서비스미결조회</li>
											<li>거래시 필수확인사항</li>
										</ul>
									</div>					
<!-- /연관업무 버튼 마우스 오버시 레이어팝업 -->	
								</div>
							</td>	
							<th class="text-right">휴대폰</th>
							<td>
								<input type="text" class="form-control" readonly>
							</td>
							<th class="text-right">마케팅담당</th>
							<td>
								<input type="text" class="form-control" readonly>
							</td>
						</tr>
						<tr>
							<th class="text-right">사업자번호</th>
							<td>
								<input type="text" class="form-control" readonly>
							</td>	
							<th class="text-right">업체명</th>
							<td>
								<input type="text" class="form-control" readonly>
							</td>
							<th class="text-right">대표자</th>
							<td>
								<input type="text" class="form-control" readonly>
							</td>
						</tr>
						<tr>
							<th class="text-right">주소</th>
							<td colspan="5">
								<div class="form-row inline-pd">
									<div class="col-2">
										<input type="text" class="form-control" readonly>
									</div>
									<div class="col-5">
										<input type="text" class="form-control" readonly>
									</div>
									<div class="col-5">
										<input type="text" class="form-control" readonly>
									</div>
								</div>							
							</td>
						</tr>
						<tr>
							<th class="text-right">비고</th>
							<td colspan="5">
								<textarea class="form-control" style="height: 100px;" readonly></textarea>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">						
				<div class="right">
					<button type="button" class="btn btn-info" style="width: 50px;">닫기</button>
				</div>
			</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
<!-- /상단 폼테이블 -->
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>