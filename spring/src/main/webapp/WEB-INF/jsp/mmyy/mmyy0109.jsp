<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 주간계획 및 예약현황(관리) > null > null
-- 작성자 : 성현우
-- 최초 작성일 : 2021-04-09 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var weekCntMap = ${weekCntMap}; // 주차
		var weekList = ${weekList}; // 이전달, 다음달
		var detailJson = ${detailJson};
		$(document).ready(function () {
			fnInit();
		});

		function enter(fieldObj) {
			var field = ["s_mem_name"];
			$.each(field, function () {
				if (fieldObj.name == this) {
					goSearch(document.main_form);
				}
			});
		}

		function fnInit() {
			fnChangeYearMon();

			if("${page.fnc.F02051_001}" != "Y") {
				$("#s_org_code").prop("disabled", true);
			}
		}

		function fnChangeYearMon() {
			var yearMonth = $M.getValue("s_year") + $M.getValue("s_mon");

			$("#s_week_of_month option").remove();

			if (weekCntMap.hasOwnProperty(yearMonth)) {
				var weekCntList = weekCntMap[yearMonth];
				for (var i = 0; i < weekCntList.length; i++) {
					if (weekCntList[i].week_of_mon == "${inputParam.week_of_mon}") {
						$("#s_week_of_month").append(new Option(weekCntList[i].week_of_mon_name, weekCntList[i].week_of_mon, '', true));
					} else {
						$("#s_week_of_month").append(new Option(weekCntList[i].week_of_mon_name, weekCntList[i].week_of_mon, '', false));
					}
				}
			}
		}

		// 조회
		function goSearch(type) {
			console.log("type : ", type);
			// 2021-07-02 추가 (황빛찬)
			// 1. 검색조건에 오른쪽, 왼쪽 화살표 표시하여 이동 추가
			// 2. 주차 표시 오류 수정. (ex> 2021-07-02는 7월 1주차가 아닌 6월 4주차임.)
			var s_current_mon = $M.getValue("s_year") + $M.getValue("s_mon");
			var week_of_mon = $M.getValue("s_week_of_month");
			var tempRnk;
			
			for (var i = 0; i < weekList.length; i++) {
				if ((weekList[i].mon_week_of_mon + weekList[i].week_of_mon) == (s_current_mon + week_of_mon)) {
					if (type == 'next') {
						tempRnk = i+1;
					} else if (type == 'pre') {
						tempRnk = i-1;
					}
					break;
				}
			}
			
			if (type == "next" || type == "pre") {
				s_current_mon = weekList[tempRnk].mon_week_of_mon; 
				week_of_mon = weekList[tempRnk].week_of_mon;
			}
			
			if (type == "year" || type == "mon") {
				week_of_mon = "1";
			}
			
			var params = {
				"s_week_st_dt": week_of_mon,
				"week_of_mon" : week_of_mon,
				"s_year_mon_week": s_current_mon,
				"s_org_code": $M.getValue("s_org_code"),
				"s_mem_name": $M.getValue("s_mem_name"),
				"s_type" : type
			}
			
			$M.goNextPage(this_page, $M.toGetParam(params), {method: "GET"});
		}

		// 주간계획 상세 조회
		function goDetailSearch(planWeekNo, workDt) {
			var param = {
				"plan_week_no": planWeekNo,
				"s_start_dt" : workDt
			};

			var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=400, height=300, left=0, top=0";
			$M.goNextPage('/mmyy/mmyy0108p02', $M.toGetParam(param), {popupStatus: popupOption});
		}

		// 정비지시서 상세 조회
		function goJobReportDetail(jobReportNo) {
			if(jobReportNo == undefined || jobReportNo == '') {
				alert("연결된 정비지시서가 없습니다.");
				return;
			}
			var params = {
				"s_job_report_no": jobReportNo
			};

			var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=300, height=200, left=0, top=0";
			$M.goNextPage('/serv/serv0101p01', $M.toGetParam(params), {popupStatus: popupOption});
		}

		function goNewJobReport(workdt, memNo) {
			if(detailJson[workdt] != undefined) {
				if(detailJson[workdt][memNo] != undefined) {
					return;
				}
			}

			var popupOption = "";
			var params = {
				"s_popup_yn": "Y"
			};

			$M.goNextPage('/serv/serv010101', $M.toGetParam(params), {popupStatus: popupOption});
		}

		function goDayBoardMenu(searchDt, orgCode) {
			top.goContent("업무스케쥴관리", "/mmyy/mmyy0113?s_search_dt=" + searchDt + "&s_org_code=" + orgCode);
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
		.datail-list2 > .am + .pm{
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
								<col width="60px">
								<col width="80px">
								<col width="45px">
								<col width="100px">
								<col width="50px">
								<col width="100px">
								<col width="*">
							</colgroup>
							<tbody>
							<tr>
								<td>
									<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goSearch('pre');" ><i class="material-iconsarrow_left"></i></button>
								</td>							
								<td>
									<select class="form-control" id="s_year" name="s_year" required="required" alt="조회년도 " onchange="javascript:goSearch('year');">
										<c:forEach var="i" begin="1" end="22" varStatus="status">
											<option value="${s_start_year-i+1}" <c:if test="${i==s_year}">selected</c:if> >${s_start_year-i+1}년</option>
										</c:forEach>
									</select>
								</td>
								<td>
									<select class="form-control" id="s_mon" name="s_mon" alt="조회월" onchange="javascript:goSearch('mon');">
										<c:forEach var="i" begin="1" end="12" step="1">
											<option value="<c:if test="${i < 10}">0</c:if><c:out value="${i}" />" <c:if test="${i==s_start_mon}">selected</c:if> >${i}월</option>
										</c:forEach>
									</select>
								</td>
								<td>
									<select class="form-control" style="width: 70px;" id="s_week_of_month" name="s_week_of_month" onchange="javascript:goSearch();">
									</select>
								</td>
								<td>
									<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goSearch('next');" ><i class="material-iconsarrow_right"></i></button>
								</td>								
								<th>부서</th>
								<td>
									<select class="form-control" name="s_org_code" id="s_org_code">
										<option value="">- 전체 -</option>
										<c:forEach var="list" items="${codeMap['WAREHOUSE']}">
											<c:if test="${list.code_value ne '5010' and list.code_value ne '6000' and list.code_v2 eq 'Y'}">
												<option value="${list.code_value}" <c:if test="${list.code_value eq inputParam.s_org_code}">selected</c:if> >${list.code_name}</option>
											</c:if>
										</c:forEach>
									</select>
								</td>
								<th>사원명</th>
								<td>
									<input type="text" class="form-control" id="s_mem_name" name="s_mem_name">
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
						<div class="btn-group">
							<div class="right state">
								<span class="text-title pr5">폰트상태컬러 :</span>
								<span class="text-complete">완료건</span>
								<span class="ver-line text-delay">연장건</span>
								<span class="ver-line text-new">신규</span>
							</div>
						</div>
					</div>
					<!-- /그리드 타이틀, 컨트롤 영역 -->
					<!-- 달력 -->
					<table class="calendar-table mt5">
						<colgroup>
							<col width="40px">
							<col width="60px">
							<col width="60px">
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
							<th>NO</th>
							<th>부서</th>
							<th>사원</th>
							<c:forEach var="dates" items="${workDtList}">
								<c:choose>
									<c:when test="${not empty dates.am_yn or not empty dates.pm_yn}">
										<th>
											<div class="form-row inline-pd widthfix">
												<div class="col-5 text-right">${dates.day_of_week}</div>
												<div class="col-7 text-left">
													<c:if test="${not empty dates.am_yn and dates.am_yn eq 'Y'}"><div style="color: blue;">[오전 예약가능]</div></c:if>
													<c:if test="${not empty dates.am_yn and dates.am_yn ne 'Y'}"><div style="color: red;">[오전 예약마감]</div></c:if>
													<c:if test="${not empty dates.pm_yn and dates.pm_yn eq 'Y'}"><div style="color: blue;">[오후 예약가능]</div></c:if>
													<c:if test="${not empty dates.pm_yn and dates.pm_yn ne 'Y'}"><div style="color: red;">[오후 예약마감]</div></c:if>
												</div>
											</div>
										</th>
									</c:when>
									<c:otherwise>
										<th>${dates.day_of_week}</th>
									</c:otherwise>
								</c:choose>
							</c:forEach>
							<th>확인</th>
						</tr>
						</thead>
						<c:forEach var="rows" items="${list}">
							<tr>
								<c:forEach var="days" items="${rows}" varStatus="status">
									<c:if test="${status.index eq 0}">
										<td class="complete-bg week-title">
											<div class="week-item" style="font-size: 12px">${days.row_no}</div>
										</td>
										<td class="complete-bg week-title">
											<div class="week-item" style="font-size: 12px">${days.org_name}</div>
										</td>
										<td class="complete-bg week-title">
											<div class="week-item" style="font-size: 12px">${days.mem_name}</div>
										</td>
									</c:if>
									<c:choose>
										<c:when test="${days.today_yn eq 'Y'}"><td style="border: 3px solid #ffcc00; cursor:pointer;" onclick="javascript:goNewJobReport('${days.work_dt}', '${days.mem_no}')"></c:when>
										<c:when test="${days.week eq 1}"><td class="sunday-bg" ></c:when>
										<c:when test="${days.week eq 7}"><td class="satuday-bg" ></c:when>
										<c:otherwise><td style="cursor:pointer" onclick="javascript:goNewJobReport('${days.work_dt}', '${days.mem_no}')"></c:otherwise>
									</c:choose>
										<div class="date-item">
											<div class="date <c:if test="${days.same_mon_yn eq 'N'}">prev</c:if> "></div>
										</div>
										<c:if test="${not empty detail[days.work_dt]}">
											<div class="datail-list2" style="padding-top: 0">
												<c:forEach var="item" items="${detail[days.work_dt]}">
													<c:forEach var="type" items="${item.key}">
														<c:if test="${type eq days.mem_no}">
															<c:forEach var="lli" items="${detail[days.work_dt][type]}">
																<c:forEach var="type2" items="${lli.key}">

																	<c:if test="${type2 eq '1'}">
																		<ul class="am">
																			<c:forEach var="li" items="${detail[days.work_dt][type][type2]}" varStatus="index">
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

																	<c:if test="${type2 eq '2'}">
																		<ul class="pm">
																			<c:forEach var="li" items="${detail[days.work_dt][type][type2]}" varStatus="index">
																				<li onclick="javascript:goJobReportDetail('${li.plan_week_no}')" style="cursor: pointer;">
																					<c:choose>
																						<c:when test="${li.plan_status_cd eq '01'}"><span class="text-new"> </c:when>
																						<c:when test="${li.plan_status_cd eq '02'}"> <span class="text-delay"> </c:when>
																						<c:when test="${li.plan_status_cd eq '09'}"> <span class="text-complete"> </c:when>
																					</c:choose>
																					${li.plan_text}</span>
																				</li>
																			</c:forEach>
																		</ul>
																	</c:if>

																	<c:if test="${type2 eq '3'}">
																		<ul class="apm">
																			<c:forEach var="li" items="${detail[days.work_dt][type][type2]}" varStatus="index">
																				<li>
																					<span class="text-new">${li.plan_text}</span>
																				</li>
																			</c:forEach>
																		</ul>
																	</c:if>

																	<c:if test="${type2 eq '4'}">
																		<ul class="apm">
																			<c:forEach var="li" items="${detail[days.work_dt][type][type2]}" varStatus="index">
																				<li onclick="javascript:goDayBoardMenu('${li.plan_dt}', '${li.org_code}')">
																					<span class="text-new">${li.plan_text}</span>
																				</li>
																			</c:forEach>
																		</ul>
																	</c:if>
																</c:forEach>
															</c:forEach>
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