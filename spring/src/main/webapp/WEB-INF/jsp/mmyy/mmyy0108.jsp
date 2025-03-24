<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 주간계획 및 예약현황(일반) > null > null
-- 작성자 : 성현우
-- 최초 작성일 : 2021-04-09 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var detailJson = ${detailJson};
		var listJson = ${listJson};
		$(document).ready(function () {
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

		// 주간계획 등록
		function goNew(workDt) {
			var currentDt = $M.getCurrentDate();
			var weekEdDt = listJson[workDt][0].week_ed_dt;

			if (weekEdDt < currentDt) {
				alert("지나간 주는 작성이 불가능합니다.");
				return;
			}

			var param = {
				"s_start_dt": workDt
			};

			$M.goNextPageAjax(this_page + "/check/lastWeek", $M.toGetParam(param), {method: 'GET'},
					function (result) {
						if (result.success) {
							// Q&A 12246. 내용없는 신규상태가 있을 수 있어 완료여부로 판단. 210813 김상덕
							if (result.data != undefined && result.data.write_comp_yn == "N") {
								alert("지난계획서의 완료 또는 연장처리 여부를 확인하시기 바랍니다.");
								goDetailSearch(result.data.plan_week_no, result.data.plan_dt);
							} else {
								var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=400, height=300, left=0, top=0";
								$M.goNextPage('/mmyy/mmyy0108p01', $M.toGetParam(param), {popupStatus: popupOption});
							}
						}
					}
			);
		}

		// 주간계획 상세 조회
		function goDetailSearch(planWeekNo, workDt) {
			var param = {
				"plan_week_no": planWeekNo,
				"s_start_dt" : workDt
			};

			$M.goNextPageAjax(this_page + "/check/lastWeek", $M.toGetParam(param), {method: 'GET'},
					function (result) {
						if (result.success) {
							// Q&A 12246. 내용없는 신규상태가 있을 수 있어 완료여부로 판단. 210813 김상덕
							if (result.data != undefined && result.data.write_comp_yn == "N") {
								alert("지난계획서의 완료 또는 연장처리 여부를 확인하시기 바랍니다.");
								goDetailSearch(result.data.plan_week_no, result.data.plan_dt);
							} else {
								var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=400, height=300, left=0, top=0";
								$M.goNextPage('/mmyy/mmyy0108p02', $M.toGetParam(param), {popupStatus: popupOption});
							}
						}
					}
			);

			if (!e) var e = window.event;
			e.cancelBubble = true;
			if (e.stopPropagation) e.stopPropagation();
		}

		// 정비지시서 상세 조회
		function goJobReportDetail(jobReportNo) {
			if(jobReportNo == undefined || jobReportNo == '') {
				alert("연결된 정비지시서가 없습니다.");
				if (!e) var e = window.event;
				e.cancelBubble = true;
				if (e.stopPropagation) e.stopPropagation();
				return;
			}
			var params = {
				"s_job_report_no": jobReportNo
			};

			var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=300, height=200, left=0, top=0";
			$M.goNextPage('/serv/serv0101p01', $M.toGetParam(params), {popupStatus: popupOption});

			if (!e) var e = window.event;
			e.cancelBubble = true;
			if (e.stopPropagation) e.stopPropagation();
		}

	</script>

	<style type="text/css">
		.datail-list2 .apm {
			background: #e6f3dc;
			color: #000;
			padding: 5px;
			border-radius: 5px;
		}
		.datail-list2 > .pm {
			/* 오후만 있을때 공간 */
			/* margin-top: 65%; */
		}
		.datail-list2 > .am + .pm + .apm{
			/* margin-top: 1%; */
		}
		.datail-list2 > .lc + .am{
			/* margin-top: 1%; */
		}
		.datail-list2 ul ~ ul {
			margin-top: 1%;
		}
		.calendar-table .datail-list2 {
			font-size: 12px;
			letter-spacing: -1.5px;
		}
		.datail-list2 .lc {
			background: #fffabf;
			color: #000;
			padding: 5px;
			border-radius: 5px;
		}
	</style>

</head>
<body>
<form id="main_form" name="main_form">
	<div class="layout-box">
		<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
				<!-- 메인 타이틀 -->
				<div class="main-title">
					<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
				</div>
				<!-- /메인 타이틀 -->
				<div class="contents">
					<!-- 기본 -->
					<div class="search-wrap">
						<table class="table">
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
									<select class="form-control" id="s_year" name="s_year" required="required" alt="조회년도" onchange="javascript:goSearch();">
										<c:forEach var="i" begin="1" end="22" varStatus="status">
										<c:set var="sYear" value="${s_start_year-i+2}" />
											<option value="${sYear}" <c:if test="${s_start_year==sYear}">selected</c:if>>${sYear}년</option>
										</c:forEach>
									</select>
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
					<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<h4>주간계획서</h4>
						<div class="right state">
							<span class="text-title pr5">폰트상태컬러 :</span>
							<span class="text-complete">완료건</span>
							<span class="ver-line text-delay">연장건</span>
							<span class="ver-line text-new">신규</span>
						</div>
					</div>
					<!-- /그리드 타이틀, 컨트롤 영역 -->

					<!-- 달력 -->
					<table class="calendar-table mt5">
						<colgroup>
							<col width="">
							<col width="">
							<col width="">
							<col width="">
							<col width="">
							<col width="">
							<col width="">
							<col width="50px">
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
							<th class="complete-bg">확인</th>
						</tr>
						</thead>
						<tbody>
						<c:forEach var="rows" items="${list}">
							<tr>
								<c:forEach var="days" items="${rows}" varStatus="status">
									<c:choose>
										<c:when test="${days.today_yn eq 'Y'}">
											<c:choose>
												<c:when test="${days.write_comp_yn eq 'I'}"><td style="border: 3px solid #ffcc00;" onclick="javascript:goNew('${days.work_dt}');" ></c:when>
												<c:otherwise>
													<td style="cursor:pointer; border: 3px solid #ffcc00;" onclick="javascript:goDetailSearch('${days.plan_week_no}', '${days.work_dt}');" >
												</c:otherwise>
											</c:choose>
										</c:when>
										<c:when test="${days.week eq 1}"><td class="sunday-bg" <c:if test="${days.write_comp_yn eq 'I'}"> style="cursor:pointer" onclick="javascript:goNew('${days.work_dt}');" </c:if> ></c:when>
										<c:when test="${days.week eq 7}"><td class="satuday-bg" <c:if test="${days.write_comp_yn eq 'I'}"> style="cursor:pointer" onclick="javascript:goNew('${days.work_dt}');" </c:if> ></c:when>
										<c:otherwise>
											<c:choose>
												<c:when test="${days.write_comp_yn eq 'I'}"><td style="cursor:pointer" onclick="javascript:goNew('${days.work_dt}');" ></c:when>
												<c:otherwise>
													<td style="cursor:pointer" onclick="javascript:goDetailSearch('${days.plan_week_no}', '${days.work_dt}');" >
												</c:otherwise>
											</c:choose>
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
														<ul class="am">
															<c:forEach var="li" items="${detail[days.work_dt][type]}" varStatus="index">
																<li onclick="javascript:goDetailSearch('${li.plan_week_no}', '${li.plan_dt}')" style="cursor: pointer;">
																	<c:choose>
																		<c:when test="${li.plan_status_cd eq '01'}"> <span class="text-new"> </c:when>
																		<c:when test="${li.plan_status_cd eq '02'}"> <span class="text-delay"> </c:when>
																		<c:when test="${li.plan_status_cd eq '09'}"> <span class="text-complete"> </c:when>
																	</c:choose>
																	${li.plan_text}</span>
																</li>
															</c:forEach>
														</ul>
													</c:if>

													<c:if test="${type eq '2'}">
														<ul class="pm">
															<c:forEach var="li" items="${detail[days.work_dt][type]}" varStatus="index">
																<li onclick="javascript:goJobReportDetail('${li.plan_week_no}')" style="cursor: pointer;">
																	<c:choose>
																		<c:when test="${li.plan_status_cd eq '01'}"> <span class="text-new"> </c:when>
																		<c:when test="${li.plan_status_cd eq '02'}"> <span class="text-delay"> </c:when>
																		<c:when test="${li.plan_status_cd eq '09'}"> <span class="text-complete"> </c:when>
																	</c:choose>
																	${li.plan_text}</span>
																</li>
															</c:forEach>
														</ul>
													</c:if>

													<c:if test="${type eq '3'}">
														<ul class="apm">
															<c:forEach var="li" items="${detail[days.work_dt][type]}" varStatus="index">
																<li>
																	<span class="text-new">${li.plan_text}</span>
																</li>
															</c:forEach>
														</ul>
													</c:if>

												</c:forEach>
											</c:forEach>
										</div>
									</c:if>
									</td>
									<c:if test="${status.index eq 6}">
										<td class="complete-bg week-title">
											<div class="week-item" style="font-size: 10px">${days.write_comp_name}</div>
										</td>
									</c:if>
								</c:forEach>
							</tr>
						</c:forEach>
						</tbody>
					</table>
					<!-- /달력 -->
				</div>
			</div>
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
		</div>
		<!-- /contents 전체 영역 -->
	</div>
</form>
</body>
</html>