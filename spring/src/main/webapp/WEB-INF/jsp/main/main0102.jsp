<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 메인 > 메인 > null > null
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
<div class="layout-box">
<!-- contents 전체 영역 -->
	<div class="content-wrap">
		<div class="content-box">
	<!-- 메인 타이틀 -->
			<div class="main-title">
				<h2>여기에 Sub제목을 넣으세요.</h2>
			</div>
	<!-- /메인 타이틀 -->
			<div class="contents">
	<!-- 기본 -->					
				<div class="search-wrap">
					<table class="table">
						<colgroup>
							<col width="150px">
							<col width="300px">
							<col width="50px">
							<col width="130px">
							<col width="70px">
							<col width="130px">
							<col width="70px">
							<col width="130px">
							<col width="70px">
							<col width="130px">
							<col width="*">
						</colgroup>
						<tbody>
							<tr>
								<td>
									<select class="form-control">
										<option>장비출하일</option>
										<option></option>
										<option></option>
									</select>
								</td>
								<td>
									<div class="row mg0">
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0">
												<button type="button" class="btn btn-icon btn-light"><i class="material-iconsdate_range"></i></button>
											</div>
										</div>
										<div class="col-auto">~</div>
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0">
												<button type="button" class="btn btn-icon btn-light"><i class="material-iconsdate_range"></i></button>
											</div>
										</div>
									</div>
								</td>									
								<th>고객명</th>
								<td>
									<div class="icon-btn-cancel-wrap">
										<input type="text" class="form-control">
										<button type="button" class="icon-btn-cancel"><i class="material-iconsclose font-16 text-default"></i></button>
									</div>
								</td>
								<th>담당자명</th>
								<td>
									<div class="icon-btn-cancel-wrap">
										<input type="text" class="form-control">
										<button type="button" class="icon-btn-cancel"><i class="material-iconsclose font-16 text-default"></i></button>
									</div>
								</td>
								<th>가동시간</th>
								<td>
									<input type="text" class="form-control" placeholder="시간(h)이상">
								</td>
								<th>등급</th>
								<td>
									<select class="form-control">
										<option>선택</option>
										<option></option>
										<option></option>
									</select>
								</td>
								<td class="">
									<button type="button" class="btn btn-important" style="width: 50px;">조회</button>
								</td>
							</tr>								
						</tbody>
					</table>
				</div>
	<!-- /기본 -->	
	<!-- 그리드 타이틀, 컨트롤 영역 -->
				<div class="title-wrap mt10">
					<h4>조회결과</h4>
					<div class="btn-group">
						<div class="right"><%-- 버튼위치는 pos param 에 따라 나옴 (없으면 기본 상단나옴) T_CODE.CODE_VALUE='BTN_POS' 참고 --%>
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							<button type="button" class="btn btn-default"><i class="material-iconstextsms text-default"></i> 문자발송</button>
							<button type="button" class="btn btn-default"><i class="icon-btn-excel inline-btn"></i>엑셀다운로드</button>
						</div>
					</div>
				</div>
	<!-- /그리드 타이틀, 컨트롤 영역 -->					
				<div style="margin-top: 5px; height: 300px; border: 1px solid #ffcc00;">그리드영역</div>
	<!-- 그리드 서머리, 컨트롤 영역 -->
				<div class="btn-group mt5">
					<div class="left">
						총 <strong class="text-primary">25</strong>건
					</div>						
					<div class="right"><%-- 버튼위치는 pos param 에 따라 나옴 (없으면 기본 상단나옴) T_CODE.CODE_VALUE='BTN_POS' 참고 --%>
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						<button type="button" class="btn btn-info">신차안건상담등록</button>
					</div>
				</div>
	<!-- /그리드 서머리, 컨트롤 영역 -->
			</div>
		</div>		
	</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>