<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 생산/선적오더관리 > 어테치먼트 발주관리 > 어테치먼트 발주관리-출하 > null
-- 작성자 : 이강원
-- 최초 작성일 : 2021-08-13 09:54:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function(){
		});
		
		// 조회
		function goSearch(type) {
			
			// 2021-07-02 추가 (황빛찬) 
			// 1. 검색조건에 오른쪽, 왼쪽 화살표 표시하여 이동 추가
			var sCurrentMon = $M.getValue("s_year") + $M.getValue("s_mon");
			
			if (type != undefined) {
				sCurrentMon = (type == 'pre' ? '${inputParam.s_before_year_mon}' : '${inputParam.s_next_year_mon}');
			}
			
			var param = {
				"s_current_mon": sCurrentMon
			};
			
			$M.goNextPage(this_page, $M.toGetParam(param), {method: "GET"});
		}
	
	</script>
	
	<style type="text/css">
		.datail-list2 .show_machine {
			padding-left: 3px;
		}
		.datail-list2 .show_total {
			background: #ffff2266;
			color: #000;
			padding: 5px;
			border-radius: 5px;
		}
		.datail-list2 ul ~ ul {
			margin-top: 1%;
		}
		.calendar-table .datail-list2 {
			font-size: 12px;
			letter-spacing: -1.5px;
		}
	</style>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<div class="layout-box">
		<!-- contents 전체 영역 -->
		<div class="content-wrap">
					<!-- 기본 -->
					<div class="search-wrap mt10">
						<table class="table table-fixed">
							<colgroup>
								<col width="30px">
								<col width="100px">
								<col width="80px">
								<col width="40px">
							</colgroup>
							<tbody>
							<tr>
								<td>
									<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goSearch('pre');" ><i class="material-iconsarrow_left"></i></button>
								</td>										
								<td>
									<jsp:include page="/WEB-INF/jsp/common/yearSelect.jsp">
										<jsp:param name="max_year" value="${s_start_year+1}"/>
										<jsp:param name="select_year" value="${s_start_year}"/>
										<jsp:param name="change" value="goSearch()"/>
									</jsp:include>
								</td>
								<td>
									<select class="form-control" id="s_mon" name="s_mon" alt="조회월" onchange="javascript:goSearch();">
										<c:forEach var="i" begin="1" end="12" step="1">
											<option value="<c:if test="${i < 10}">0</c:if><c:out value="${i}" />" <c:if test="${i==s_start_mon}">selected</c:if>>${i}월</option>
										</c:forEach>
									</select>
								</td>
								<td>
									<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goSearch('next');" ><i class="material-iconsarrow_right"></i></button>
								</td>								
								<td>
									<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
								</td>
							</tr>
							</tbody>
						</table>
					</div>
					<!-- /기본 -->
					<!-- 달력 -->
					<table class="calendar-table mt10">
						<colgroup>
							<col width="">
							<col width="">
							<col width="">
							<col width="">
							<col width="">
							<col width="">
							<col width="">
						</colgroup>
						<thead>
						<tr>
							<th class="sunday-bg">일</th>
							<th>월</th>
							<th>화</th>
							<th>수</th>
							<th>목</th>
							<th>금</th>
							<th class="satuday-bg">토</th>
						</tr>
						</thead>
						<tbody>
						<c:forEach var="rows" items="${list}">
							<tr>
								<c:forEach var="days" items="${rows}" varStatus="status">
									<c:choose>
										<c:when test="${days.today_yn eq 'Y'}">
											<td style="cursor:pointer; border: 3px solid #ffcc00;" >
										</c:when>
										<c:when test="${days.week eq 1}"><td class="sunday-bg"></c:when>
										<c:when test="${days.week eq 7}"><td class="satuday-bg"></c:when>
										<c:otherwise>
											<td style="cursor:pointer;">
										</c:otherwise>
									</c:choose>
									<div class="date-item">
										<div class="date <c:if test="${days.same_mon_yn eq 'N'}">prev</c:if> ">${days.day}</div>
									</div>
									<c:if test="${not empty detail[days.work_dt]}">
										<div class="datail-list2" style="padding-top: 0">
											<c:forEach var="item" items="${detail[days.work_dt]}">
												<c:forEach var="type" items="${item.key}">

													<c:if test="${type eq '1'}">
														<ul class="show_machine">
															<c:forEach var="li" items="${detail[days.work_dt][type]}" varStatus="index">
																<li style="cursor: pointer;">
																	<span class="text-new"> ${li.machine_name}</span>
																</li>
															</c:forEach>
														</ul>
													</c:if>

													<c:if test="${type eq '2'}">
														<ul class="show_total">
															<c:forEach var="li" items="${detail[days.work_dt][type]}" varStatus="index">
																<li style="cursor: pointer;">
																	<span class="text-new"> ${li.machine_name}</span>
																</li>
															</c:forEach>
														</ul>
													</c:if>

												</c:forEach>
											</c:forEach>
										</div>
									</c:if>
									</td>
								</c:forEach>
							</tr>
						</c:forEach>
						</tbody>
					</table>
				<!-- /달력 -->
	</div>
		<!-- /contents 전체 영역 -->
</div>
</form>
</body>
</html>