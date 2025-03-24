<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 공통업무 > 인사일정관리 > null > null
-- 작성자 : 성현우
-- 최초 작성일 : 2020-03-04 13:25:41
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGrid;
		$(document).ready(function() {
			$("#_goTemporaryHoliday").hide();
			$("#_goTemporaryHolidayRemove").hide();
			createAUIGrid();
		});

		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				wrapSelectionMove : false,
				showRowNumColumn : false,
				enableFilter :true,
				editable : false

			};

			var columnLayout = [
				{
					headerText : "요청자",
					dataField : "mem_name",
					width : "20%",
					style : "aui-center"
				},
				{
					headerText : "구분",
					dataField : "holiday_type_name",
					width : "20%",
					style : "aui-center"
				},
				{
					headerText : "일정기간",
					dataField : "schedule_term",
					width : "30%",
					style : "aui-center"
				},
				{
					headerText : "내용",
					dataField : "content",
					width : "30%",
					style : "aui-center"
				}
			];

			// 실제로 #grid_wrap에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);

		}

		// 이전 달
		function prevCalendar() {
			var sYearMon = $M.getValue("s_year_mon");
			var prevDate = $M.addMonths($M.toDate(sYearMon), -1);

			$M.setValue("s_year_mon", $M.dateFormat(prevDate, 'yyyyMM'));

			goSearch();
		}

		// 다음 달
		function nextCalendar() {
			var sYearMon = $M.getValue("s_year_mon");
			var prevDate = $M.addMonths($M.toDate(sYearMon), +1);

			$M.setValue("s_year_mon", $M.dateFormat(prevDate, 'yyyyMM'));

			goSearch();
		}

		// 셀렉트박스에서 변경 시
		function yearMonChange() {
			var sYear = $M.getValue("s_year");
			var sMon = $M.getValue("s_mon");

			if(sMon.length == 1) {
				sMon = "0" + sMon;
			}
			var sYearMon = sYear + sMon;

			$M.setValue("s_year_mon", $M.dateFormat($M.toDate(sYearMon), 'yyyyMM'));
			goSearch();
		}

		// 조회
		function goSearch() {
			var param = {
				"s_year_mon" : $M.getValue("s_year_mon")
		};

		$M.goNextPage(this_page, $M.toGetParam(param), {method : "GET"})
		}

		function goDetail(work_dt) {
			$("#s_work_dt").val(work_dt);
			var schedule = $M.dateFormat($M.toDate(work_dt), 'yyyy-MM-dd');
			$("#schedule").html(schedule + " 인사일정");

			var param = {
				"s_work_dt": work_dt,
				"s_year": $M.getValue("s_year")
			};

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: "GET"},
					function (result) {
						if (result.success) {
							AUIGrid.setGridData(auiGrid, result.list);
							// 22.09.02 임시공휴일 취소 때문에 추가
							AUIGrid.setFilter(auiGrid, "mem_name",  function(dataField, value, item) {
								return value != null ? true : false; // 값이 있는것만 출력
							});
							$M.setValue("s_holi_name", result.list[0].holi_name);
							$M.setValue("s_event_name", result.list[0].event_name);
							$M.setValue("s_week_name", result.list[0].week_name);
							if($M.getValue("s_holi_name") != "임시공휴일") {
								$("#_goTemporaryHoliday").show();
								$("#_goTemporaryHolidayRemove").hide();
							} else {
								$("#_goTemporaryHoliday").hide();
								$("#_goTemporaryHolidayRemove").show();
							}
						}
					}
			);

		}

		// 22.09.01 임시 공휴일 지정
		function goTemporaryHoliday() {
			var work_year =   $M.getValue("s_work_dt").substring(0,4);
			var work_mon =   $M.getValue("s_work_dt").substring(4,6);
			var work_dt =   $M.getValue("s_work_dt").substring(6,8);
			var param = {
				"work_dt_str" : $M.getValue("s_work_dt"),
				"work_yn_str" : "N",
				"holi_yn_str" : "Y",
				"holi_name_str" : "임시공휴일"
			}
			var check = confirm("" + work_year + "년 " + work_mon + "월 " + work_dt + "일을 임시공휴일로 지정하시겠습니까?");
			if(!check){
				return false;
			}
			$M.goNextPageAjax(this_page + "/save", $M.toGetParam(param) , {method : 'POST'},
					function(result) {
						if(result.success) {
							goSearch();
						}
					}
			);
		}

		// 22.09.02 임시 공휴일 취소
		function goTemporaryHolidayRemove(){
			var work_year =   $M.getValue("s_work_dt").substring(0,4);
			var work_mon =   $M.getValue("s_work_dt").substring(4,6);
			var work_dt =   $M.getValue("s_work_dt").substring(6,8);
			var	work_yn_str;
			var	holi_yn_str;
			var	holi_name_str;
			//주말
			if($M.getValue("s_week_name") == "토요일" || $M.getValue("s_week_name") == "일요일"){
				work_yn_str = "N"
				if($M.getValue("s_event_name") != "휴일"){ //주말에 공휴일인 경우
					console.log("주말에 공휴일");
					holi_name_str = $M.getValue("s_event_name");
					holi_yn_str = "Y";
				}else{ // 주말이지만 공휴일이 아닌 경우
					console.log("주말에 공휴일아님");
					holi_name_str = "";
                    holi_yn_str = "N";
				}
			}else{ //평일
				if($M.getValue("s_event_name") != ""){ // 평일에 공휴일인 경우
					work_yn_str = "N"
					holi_name_str = $M.getValue("s_event_name");
					holi_yn_str = "Y";
				}else{ // 평일이고 공휴일이 아닌 경우
					work_yn_str = "Y"
					holi_name_str = "";
					holi_yn_str = "N";
				}
			}
			var param = {
				"work_dt_str" : $M.getValue("s_work_dt"),
				"work_yn_str" : work_yn_str,
				"holi_yn_str" : holi_yn_str,
				"holi_name_str" : holi_name_str
			}
			var check = confirm("" + work_year + "년 " + work_mon + "월 " + work_dt + "일 임시공휴일을 취소하시겠습니까?");
			if(!check){
				return false;
			}
			$M.goNextPageAjax(this_page + "/save", $M.toGetParam(param) , {method : 'POST'},
					function(result) {
						if(result.success) {
							goSearch();
						}
					}
			);
		}

	</script>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" id="s_year_mon" name="s_year_mon" value="${inputParam.s_year_mon}" />
<input type="hidden" id="s_work_dt" name="s_work_dt"/>
<input type="hidden" id="s_week_name" name="s_week_name"/>
<input type="hidden" id="s_event_name" name="s_event_name"/>
<input type="hidden" id="s_holi_name" name="s_holi_name"/>
	<div class="layout-box">
		<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
				<div class="contents">
					<div class="search-wrap mt10">
						<!-- 날짜 선택 -->
						<table class="table table-fixed">
							<colgroup>
								<col width="">
								<col width="">
								<col width="">
								<col width="">
							</colgroup>
							<tbody>
							<tr>
								<td style="width: 28px;">
									<button type="button" class="btn btn-icon btn-primary-gra" onclick="prevCalendar()"><i class="material-iconsarrow_left"></i></button>
								</td>
								<td style="width: 80px;" align="center">
									<select class="form-control" id="s_year" name="s_year" onchange="javascript:yearMonChange()">
										<c:forEach var="i" begin="2000" end="${inputParam.s_current_year+1}" step="1">
											<option value="${i}" <c:if test="${i==inputParam.s_year}">selected</c:if>>${i}년</option>
										</c:forEach>
									</select>
								<td style="width: 60px;" align="center">
									<select class="form-control" id="s_mon" name="s_mon" onchange="javascript:yearMonChange()">
										<c:forEach var="i" begin="1" end="12" step="1">
											<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i==inputParam.s_mon}">selected</c:if>>${i}월</option>
										</c:forEach>
									</select>
								</td style="width: 24px;">
								<td>
									<button type="button" class="btn btn-icon btn-primary-gra" onclick="nextCalendar()"><i class="material-iconsarrow_right"></i></button>
								</td>
							</tr>
							</tbody>
						</table>
						<!-- /날짜 선택 -->
					</div>
					<div class="row mt10">
						<!-- 달력 -->
						<div class="col-8">
							<table class="calendar-table" id="calendar" style="text-align: left;">
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
										<th class="sunday-bg" align="center" id="sun">일</th>
										<th align="center" value="mon">월</th>
										<th align="center" value="tue">화</th>
										<th align="center" value="wed">수</th>
										<th align="center" value="thu">목</th>
										<th align="center" value="fri">금</th>
										<th class="satuday-bg" align="center" value="sat">토</th>
									</tr>
								</thead>
								<tbody id="calendarTbody">
								<c:forEach var="rows" items="${list}">
									<tr>
										<c:forEach var="lines" items="${rows}">
											<c:choose>
												<c:when test="${lines.today_yn eq 'Y'}"><td class="today-bg" onclick="javascript:goDetail('${lines.work_dt}')" style="cursor: pointer"></c:when>
												<c:when test="${lines.week == 1}"><td class="sunday-bg" onclick="javascript:goDetail('${lines.work_dt}')" style="cursor: pointer"></c:when>
												<c:when test="${lines.week == 7}"><td class="satuday-bg" onclick="javascript:goDetail('${lines.work_dt}')" style="cursor: pointer"></c:when>
												<c:when test="${lines.holi_yn eq 'Y'}"><td class="holiday-bg" onclick="javascript:goDetail('${lines.work_dt}')" style="cursor: pointer"></c:when>
												<c:otherwise><td onclick="javascript:goDetail('${lines.work_dt}')" style="cursor: pointer"></c:otherwise>
											</c:choose>
											<div class="date-item">
												<div class="date<c:if test="${lines.same_mon_yn eq 'N'}"> prev</c:if>">${lines.work_day}</div>
												<div class="text-holiday">${lines.holi_name}</div>
											</div>
											<div class="datail-list">
												<c:forEach var="i" items="${lines.holi_list}">
													<c:choose>
														<c:when test="${i.holiday_type_cd == 10}"><span class="badge badge-pill badge-success">${i.holiday_type_name}</span></c:when>
														<c:when test="${i.holiday_type_cd == 20}"><span class="badge badge-pill badge-info">${i.holiday_type_name} </span></c:when>
														<c:when test="${i.holiday_type_cd == 30}"><span class="badge badge-pill badge-danger">${i.holiday_type_name}</span></c:when>
													</c:choose>
														<span>${i.display_text}</span> <br>
												</c:forEach>
											</div>
											</td>
										</c:forEach>
									</tr>
								</c:forEach>
								</tbody>
							</table>
						</div>
						<!-- /달력 -->
						<!-- 인사일정 -->
						<div class="col-4">
							<div class="title-wrap mt10">
								<h4 id="schedule" name="schedule"></h4>
							</div>
							<div id="auiGrid" class="mt10" style="margin-top: 5px; height: 300px;"></div>
							<div class="btn-group">
								<div class="right" id="holidayBtn">
									<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
									<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
								</div>
							</div>

						</div>
						<!-- /인사일정 -->
					</div>
				</div>
			</div>
		</div>
	</div>
</form>
</body>
</html>