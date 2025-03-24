<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 업무일지(일반계정) > null > null
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2020-04-09 11:51:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<style>
		/* 클릭 포커스 하이라이트 제거 */
		#calendar {
			min-width: 1675px;
		}
		
		.fc-highlight {
			background: none !important;
		}

		/* 일요일 색상 */
		td.fc-day.fc-day-sun.fc-day-past.fc-daygrid-day,
		td.fc-day.fc-day-sun.fc-day-future.fc-daygrid-day {
			background-color: #FFF5F5;
		}

		/* 토요일 색상 */
		td.fc-day.fc-day-sat.fc-day-past.fc-daygrid-day,
		td.fc-day.fc-day-sat.fc-day-future.fc-daygrid-day {
			background-color: #F5FAFF;
		}

		/* 월~토 헤더 */
		.day-header-custom {
			background-color: #EFEFEF;
			font-size: 0.875rem;
			display: table-cell;
			vertical-align: inherit;
			font-weight: bold;
			padding: 0.45rem !important;
		}

		/* 기본 일자 단위 */
		.day-cell {
			height: 11.3rem;
			position: relative;
			text-align: center;
			background-color: #FFFFFF;
		}

		/* 일자 휴일인 경우 (현재월 넘어가는 것은 제외) */
		.day-cell-holiday:not(.fc-day-other) {
			height: 11.3rem;
			position: relative;
			text-align: center;
			background-color: #FFF5F5;
		}

		/* ~일 구역 */
		.fc .fc-daygrid-day-top {
			flex-direction: row;
		}

		/* 일자 하단 구역 */
		.fc-daygrid-day-bg {
			position: absolute;
			bottom: 0;
			width: 100%;
			height: 30px;
		}

		/* 달력 날짜에 마우스 올렸을 때 나오는 영역 (업무일지 상세 팝업이 나와야 하는 부분 - 노란색) */
		.day-work-click-div {
			position: absolute;
			bottom: -155px;
			width: 14.8rem;
			height: 45px;
			left: 0;
		}
		.day-work-click-div:hover:not(.fc-popover-body ) {
			background: rgba(232, 232, 183, 0.29);
		}
		
		/* 달력 날짜에 마우스 올렸을 때 나오는 영역 (일정등록/상세 팝업이 나와야 하는 부분 - 빨간색) */
		.day-hover-div {
			position: absolute;
			top: 0;
			width: 14.8rem;
			height: 135px;
			left: 0;
		}
		.day-hover-div:hover:not(.fc-popover-body) {
			background: rgba(252, 171, 171, 0.29);
		}

		/* 일자 하단 구역 커스텀 노출 */
		.day-cell-vacation:not(.fc-day-other) .fc-daygrid-day-bg:before {
			content: "휴가" !important;
			border-radius: 0.375rem !important;
			font-size: 14px;
			padding: 3px !important;
			margin: 2px;

			border: 1.5px solid #ff0000 !important;
			color: #ff0000 !important;
		}

		.day-cell-vacation-other:not(.fc-day-other) .fc-daygrid-day-bg:before {
			content: "출장" !important;
			border-radius: 0.375rem !important;
			font-size: 14px;
			padding: 3px !important;
			margin: 2px;

			border: 1.5px solid #17d300 !important;
			color: #17d300 !important;
		}

		.day-work-none-text:not(.fc-day-other) .fc-daygrid-day-bg:after {
			content: "일지작성" !important;
			border-radius: 0.375rem !important;
			font-size: 14px;
			padding: 3px !important;
			margin: 2px;

			border: 1.5px solid #225CA4 !important;
			color: #225CA4 !important;
		}

		.day-work-ing-text:not(.fc-day-other) .fc-daygrid-day-bg:after {
			content: '\00a0작성중\00a0' !important;
			border-radius: 0.375rem !important;
			font-size: 14px;
			padding: 3px !important;
			margin: 2px;

			border: 1.5px solid #FF8307 !important;
			color: #FF8307 !important;
		}

		.day-work-comp-text:not(.fc-day-other) .fc-daygrid-day-bg:after {
			content: '작성완료' !important;
			border-radius: 0.375rem !important;
			font-size: 14px;
			padding: 3px !important;
			margin: 2px;

			border: 1.5px solid #bbb !important;
			color: #bbb !important;
		}

		/* /일자 하단 구역 커스텀 노출 */

		/* 일자 텍스트 */
		.day-number-text:not(.fc-day-other) {
			color: #E85F5F !important
		}

		/* 일자 휴일 텍스트 */
		.day-holiday-text:not(.fc-day-other) {
			font-size: 12px;
			padding-left: 8px;
		}

		/* 이벤트 부모 div */
		.fc-h-event {
			border-color: white;
		}

		/* 이벤트 막대기 */
		.fc-event-main {
			border-radius: 4px;
		}

		.event-color-0 {
			background: red;
		}

		.event-color-1 {
			background: blue;
		}

		.event-color-2 {
			background: green;
		}
		
		/* 일수 a 태그 밑줄 제거 */
		.fc-daygrid-day-number {
			text-decoration: none !important;
		}
		
	</style>
	<%-- 캘린더 라이브러리 import --%>
	<script src='https://cdn.jsdelivr.net/npm/fullcalendar@6.1.9/index.global.min.js'></script>
	<script type="text/javascript">
		var calendar;
		// 휴가, 휴일, 업무일지 상태 관련 리스트
		var list = ${list};
		// 일정 리스트
		var planList = ${planList};
		// 오늘 날짜
		var toDay = '${inputParam.today}';
		// 검색 날짜
		var yearMon = '${inputParam.s_year_mon}';
		// 센터 코드
		var orgCode = '${inputParam.s_org_code}';
		// 직원 번호
		var memNo = '${inputParam.s_mem_no}'

		$(document).ready(function () {
			if( yearMon == "" || yearMon == undefined){
				location.reload();
			}

			// 캘린더 초기화
			calendarInit();
		});

		// 달력 init
		function calendarInit() {
			const events = getEventArr(planList);
			var calendarEl = document.getElementById('calendar');
			calendar = new FullCalendar.Calendar(calendarEl, {
				// initialView: 'dayGridMonth',
				headerToolbar: false, // 헤더 사용 여부
				selectable: true, // 셀 선택 사용 여부
				fixedWeekCount: false, // 다음 달 주차 노출 여부
				navLinks: true, // 일자 선택 가능 여부
				unselectAuto: true, //
				dayMaxEvents : 3, // 이벤트 최대 노출 횟수
				locale : 'ko', // 언어
				events : events, // 이벤트
				height : '80vh', // 달력 높이 조절 (없을 시 스크롤 형태로 변경됨)
				dayHeaderClassNames : 'day-header-custom', // header (요일 custom class name)
				dayCellClassNames : dayCellClassNames, // day cell (일자 custom class name)
				dayCellContent : dayCellContent, // 각 날짜별 셀 컨텐츠
				moreLinkContent : moreLinkContent, // 더 보기 컨텐츠
				dateClick: dateClick, // 날짜 클릭 이벤트
				eventClick: dateClick, // 막대기(일정) 클릭 이벤트 (날짜 셀 클릭과 동일하게 사용)
				navLinkDayClick: ()=>{}, // 일자(1일,2일...) 클릭 이벤트
			});

			// 캘린더 랜더링
			calendar.render();
			// 검색년월로 셋팅
			calendar.gotoDate("${inputParam.s_year_mon}");
		}

		// 이벤트 데이터 구하기
		function getEventArr(planList) {
			const resultArr = [];

			planList?.forEach((plan, idx) => {
				const number = (idx % 3) ;

				const temp = {
					start: plan.plan_st_dt,
					end: $M.dateFormat($M.addDate($M.toDate(plan.plan_ed_dt), 'date', 1), 'yyyyMMdd'),
					title: plan.plan_text,
					classNames: 'event-color-' + number,
				};

				resultArr.push(temp);
			});

			return resultArr;
		}

		// 날짜 셀 className
		function dayCellClassNames(arg) {
			// 클릭된 날짜
			const workDt = $M.dateFormat(arg.date, 'yyyyMMdd');

			// 리턴될 className
			const returnClassNameArr = ['day-cell'];

			// 업무 일지 작성중 여부 표시
			// - day-work-ing-text : 작성중
			// - day-work-comp-text : 작성완료
			// - day-work-none-text : 일지작성 (일주일 단위로 노출)
			if (getWorkDiaryObj(workDt, 'N')) {
				returnClassNameArr.push('day-work-ing-text');
			} else if (getWorkDiaryObj(workDt, 'Y')) {
				returnClassNameArr.push('day-work-comp-text');
			} else if (isAWeekAgo(workDt)) {
				returnClassNameArr.push('day-work-none-text');
			}

			// 휴일 표시
			const sameHolidayObj = getSameHolidayObj(workDt);
			if (sameHolidayObj) {
				returnClassNameArr.push('day-cell-holiday');
			}


			// 휴가 표시
			const vacationObj = getVacationObj(workDt);
			if (vacationObj) {
				if (vacationObj.vacation_name === '휴가') {
					returnClassNameArr.push('day-cell-vacation');
				} else {
					returnClassNameArr.push('day-cell-vacation-other');
				}
			}

			return returnClassNameArr;
		}

		// 일자 셀 컨텐츠
		function dayCellContent(arg) {
			// 더보기 버튼을 눌렀을 때(작업일자가 3개 이상일 때) 나오는 모달에 해당 로직이 들어가서 예외처리
			if(arg.dayNumberText === "") {
				return ""
			}
			
			const workDt = $M.dateFormat(arg.date, 'yyyyMMdd');
			const holidayObj = getSameHolidayObj(workDt);

			var html = /* 날짜 클릭 공간 (일수가 표시 됨) - 일지작성 팝업 호출 */
				"<div class='" + (holidayObj ? 'day-text day-number-text' : 'day-text') +"' onclick='javascript:dateClick(" + JSON.stringify({date : workDt}) + ")' >"
				+ arg.dayNumberText.replace('일', '')
				+ "<span class='day-holiday-text'>"+ (holidayObj?.holi_name ?? '') +"</span>"
				+ "</div>";

			// day-work-click-div : 하단 일지작성 클릭 공간 (따로 그려지진 않음, 클릭 영역용) - 업무일지 상세 팝업 호출
			// day-hover-div : 하단 제외한 부분 (따로 그려지진 않음, 클릭 영역용) - 일지작성 상세 팝업 호출
			// - 클릭 가능한지 판별
			if(isClick(workDt)) {
				html += "<div class='day-work-click-div' onclick='javascript:navLinkDayClick(" + workDt + ")'>"
				html += "</div>"
				html += "<div class='day-hover-div' onclick='javascript:dateClick(" + JSON.stringify({date : workDt}) + ")' />";
			}

			return {
				html: html
			};
		}

		// 더보기 컨텐츠
		function moreLinkContent(arg) {
			return {
				html: "<span>" + arg.shortText + "일정</span>"
			};
		}

		// 날짜 셀 클릭 이벤트
		function dateClick(arg) {
			let start = '';

			// event 객체가 있으면 event 클릭
			if (arg.event) {
				start = arg.event.start;
			} else {
				// 없으면 셀 클릭
				start = arg.date;
			}

			const startDt = $M.dateFormat(start, 'yyyyMMdd');
			// 이전, 다음달의 날짜 클릭의 경우 return
			if (isClick(startDt + "")) {
				goPlanDetail(startDt);
			}
		}

		// 같은 년월인지 체크
		// - 같은 년월이면 가능
		const isClick = (workDt) => {
			return yearMon.substring(0, 6) === workDt.substring(0, 6);
		};

		// 일자 클릭 이벤트
		function navLinkDayClick(date) {
			const workDt = $M.dateFormat(date, 'yyyyMMdd') + "";
			// 이전, 다음달의 일자 클릭의 경우 return
			if (!isClick(workDt)) {
				return;
			}

			goDetail(workDt);
		}

		// 일자랑 매칭 되는 휴일 데이터 구하기
		const getSameHolidayObj = (workDt) => {
			const holidayList = list?.filter((item) => item.holi_yn === 'Y') ?? [];
			return holidayList.filter((item) => item.work_dt === workDt)[0];
		};

		// 일자랑 매칭 되는 일지 데이터 구하기
		const getWorkDiaryObj = (workDt, complete_yn) => {
			return list?.filter((item) => item.complete_yn === complete_yn && item.work_dt === workDt)[0];
		};

		// 일자랑 매칭 되는 휴일 데이터 구하기
		const getVacationObj = (workDt) => {
			const vacationList = list?.filter((item) => item.vacation_yn === 'Y') ?? [];
			return vacationList.filter((item) => item.work_dt === workDt)[0];
		};

		// 날짜에서 일주일 뒤가 맞는지
		const isAWeekAgo = (workDt) => {
			const diff = $M.getDiff(workDt, toDay);
			return diff <= 1 && diff >= -6
		};

		// 이전달/다음달 조회
		function goSearch(type) {

			// 여러번 눌리는걸 방지하기 위해 버튼 disable
			$(':button').attr('disabled', true);
			var s_year_mon = (type == 'pre' ? '${inputParam.s_before_year_mon}' : '${inputParam.s_next_year_mon}');

			var param = {
					"s_year_mon"  :  s_year_mon
				};
			$M.goNextPage(this_page, $M.toGetParam(param), {method:"GET"});

		}

		// 업무일지 상세 팝업
		function goDetail(workDt) {
			var param = {
					"s_mem_no" : memNo,
					"s_work_dt" : workDt ?? toDay
				};

			var org_gubun = '${inputParam.s_org_code}'.substr( 0, 1);
			//서비스부, 기획부(김태공상무님 부서, 20210302)
			if(org_gubun == "5" || org_gubun == "8"){
				var poppupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1450, height=590, left=0, top=0";
				<%--if ("${SecureUser.org_type}" == 'CENTER') {--%>
				if ("${page.fnc.F00628_001}"=="Y") { // 서비스관리,서비스부서장 제외
					$M.goNextPage('/mmyy/mmyy0103p06', $M.toGetParam(param), {popupStatus : poppupOption});
				} else {
					$M.goNextPage('/mmyy/mmyy0103p01', $M.toGetParam(param), {popupStatus : poppupOption});
				}
			}
			//영업부,경영지원부 (Q&A 21367. 경영지원부 업무일지상세-관리부로 보여지도록 수정 요청)
			if(org_gubun == "4" || org_gubun == "3"){
				var poppupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1450, height=610, left=0, top=0";
				$M.goNextPage('/mmyy/mmyy0103p02', $M.toGetParam(param), {popupStatus : poppupOption});
			}
			//관리부
			if(org_gubun == "2"){
				var poppupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1450, height=850, left=0, top=0";
				$M.goNextPage('/mmyy/mmyy0103p03', $M.toGetParam(param), {popupStatus : poppupOption});
			}
			//부품부
			if(org_gubun == "6" ){
				var poppupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1450, height=610, left=0, top=0";
				$M.goNextPage('/mmyy/mmyy0103p04', $M.toGetParam(param), {popupStatus : poppupOption});
			}
		}

		// [14447] 상세검색 기능 추가
		function goSearchDetail() {
			var param = {
				"s_mem_no" : '${SecureUser.mem_no}'
			};
			$M.goNextPage('/mmyy/mmyy010301p03', $M.toGetParam(param), {popupStatus : ""});
		}

		// [17421] '일정등록/상세' 팝업 호출 - 김경빈
		function goPlanDetail(date) {
			const param = {
				"s_work_dt" : date ? date : toDay
			}

			$M.goNextPage('/mmyy/mmyy010301p04', $M.toGetParam(param), {popupStatus : ""});
		}
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
					<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
				</div>
				<!-- /메인 타이틀 -->
				<div class="contents">
					<!-- 기본 -->
					<div class="search-wrap">
						<table class="table">
							<colgroup>
								<col width="28px">
								<col width="100px">
								<col width="28px">
								<col width="">
							</colgroup>
							<tbody>
							<tr>
								<td>
									<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goSearch('pre');" ><i class="material-iconsarrow_left"></i></button>
								</td>
								<td>
									<input type="text" class="form-control text-center" value="${inputParam.s_year} - ${inputParam.s_mon}" disabled>
								</td>
								<td>
									<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goSearch('next');" ><i class="material-iconsarrow_right"></i></button>
								</td>
								<td>
									<div class="btn-group">
										<div class="left">
											<!-- [14447] 상세검색 버튼 추가 -->
											<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_M"/></jsp:include>
										</div>
										<div class="right">
											<!-- [17421] '일정등록' 버튼 추가 - 김경빈 -->
											<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
										</div>
									</div>
								</td>
							</tr>
							</tbody>
						</table>
					</div>
					<!-- /기본 -->
					<div id="calendar"></div>
				</div>
			</div>
		</div>
		<!-- /contents 전체 영역 -->
	</div>
</form>
</body>
</html>
