<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 근무관리 > null > null
-- 작성자 : 성현우
-- 최초 작성일 : 2020-04-09 11:51:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	var auiGrid;
	var memNoMap = ${memNoMap};
	var weekCntMap = ${weekCntMap};
	
	var extendStr = "연장";
	var extendReqStr = "연장 근로 신청";
	
	$(document).ready(function() {
		fnInit();
		createAUIGrid();
	});

	// 부서 선택 시 직원 리스트
	function goMemNoListChange() {
		var orgCode = $M.getValue("s_org_code");
		// select box 옵션 전체 삭제
		$("#s_mem_no option").remove();
		// select box option 추가
		// $("#s_mem_no").append(new Option('- 전체 -', ""));

		if(memNoMap.hasOwnProperty(orgCode)) {
			var memNoList = memNoMap[orgCode];

			// [재호] [3차-Q&A 미등록] 근무 관리 리스트 내용 맞지 않는 부분
			// - 전체 누락 부분 추가
			$("#s_mem_no").append(new Option("- 전체 -", ""));
			for(item in memNoList) {
				$("#s_mem_no").append(new Option(memNoList[item].mem_name, memNoList[item].mem_no));
			}
		}
	}

	function fnWeekCntChange() {
		var year = $M.getValue("s_year");
		var month = $M.getValue("s_mon");
		if(month.length == 1) {
			month = "0" + month;
		}

		var yearMon = year + month;
		$("#s_start_week option").remove();
		$("#s_start_week").append(new Option('- 전월 마지막주 -', "0"));

		$("#s_end_week option").remove();

		if(weekCntMap.hasOwnProperty(yearMon)) {
			var weekCntList = weekCntMap[yearMon];
			for(var i=0; i<weekCntList.length; i++) {
				$("#s_start_week").append(new Option(weekCntList[i].week_cnt_name, weekCntList[i].week_cnt));
				$("#s_end_week").append(new Option(weekCntList[i].week_cnt_name, weekCntList[i].week_cnt));
			}
		}

		goSearch();
	}

	function fnClose() {
		window.close();
	}

	// 로그인 된 사용자 정보
	function fnInit() {
		$("#__fnDummy").addClass("dpn");

		var grade = "${SecureUser.grade_cd}";
		if(grade) {
			grade = grade.substring(2);
		}

		grade = $M.toNum(grade);
		var orgCode = "${inputParam.s_org_code}";
		var memNo = "${inputParam.s_mem_no}";
		$("#s_mem_no option").remove();

		if(grade < 15) {
			$("#s_org_code").prop("disabled", true);
		}

		// 직급이 매니저인 직원부터 전체 조회 가능.
		if(grade >= 8) {
			$("#s_mem_no").append(new Option('- 전체 -', ""));
		} else {
			$("#s_mem_no").prop("disabled", true);
		}

		if(memNoMap.hasOwnProperty(orgCode)) {
			var memNoList = memNoMap[orgCode];
			for(var i=0; i<memNoList.length; i++) {
				if(memNoList[i].mem_no == memNo) {
					$("#s_mem_no").append(new Option(memNoList[i].mem_name, memNoList[i].mem_no, '', true));
				} else {
					$("#s_mem_no").append(new Option(memNoList[i].mem_name, memNoList[i].mem_no, '', false));
				}
			}
		}

		fnWeekCntChange();
	}

	function fnCopyPlanSchedule() {
		var startWeek = $M.getValue("s_start_week");
		var endWeek = $M.getValue("s_end_week");
		var today = $M.getCurrentDate("yyyyMM");
		var sYear = $M.getValue("s_year");
		var sMon = $M.getValue("s_mon");

		if(sMon.length == 1) {
			sMon = "0" + sMon;
		}
		var sYearMon = sYear + sMon;
		sYearMon = $M.dateFormat($M.toDate(sYearMon), 'yyyyMM');

		if(today > sYearMon) {
			alert("과거의 날짜는 변경이 불가능합니다.");
			return;
		}

		var startGridData;
		var sunDt;
		var satDt;
		var memNo;
		var orgCode;
		var msg = startWeek + "주차 근무를 " + endWeek + "주차 근무로 복사하시겠습니까?\n금일 이전의 편성근무표는 변경이 불가능합니다.";
		var endGridData = AUIGrid.getItemsByValue(auiGrid, "week_cnt", endWeek);

		if(endGridData.length < 1) {
			alert("근무표 조회를 먼저 진행해주세요.");
			return;
		}

		if(startWeek == endWeek) {
			alert("같은 주차로는 복사가 불가능합니다.");
			return;
		}

		if(startWeek == 0) {
			startGridData = AUIGrid.getItemsByValue(auiGrid, "week_cnt", 1);
			sunDt = startGridData[0].sun.split(" ")[0].replace(/-/gi, "");
			satDt = startGridData[0].sat.split(" ")[0].replace(/-/gi, "");
			sunDt = $M.formatDate($M.addDates($M.toDate(sunDt), -7)).replace(/-/gi, "");
			satDt = $M.formatDate($M.addDates($M.toDate(satDt), -7)).replace(/-/gi, "");

			msg = "전월 마지막주 근무를 " + endWeek + "주차 근무로 복사하시겠습니까?\n금일 이전의 편성근무표는 변경이 불가능합니다.";
		} else {
			startGridData =  AUIGrid.getItemsByValue(auiGrid, "week_cnt", startWeek);
			sunDt = startGridData[0].sun.split(" ")[0].replace(/-/gi, "");
			satDt = startGridData[0].sat.split(" ")[0].replace(/-/gi, "");
		}

		var endSunDt = endGridData[0].sun.split(" ")[0].replace(/-/gi, "");
		var endSatDt = endGridData[0].sat.split(" ")[0].replace(/-/gi, "");

		memNo = startGridData[0].children[0].mem_no;
		orgCode = startGridData[0].children[0].org_code;

		var params = {
			"s_sun_dt" : sunDt,
			"s_sat_dt" : satDt,
			"s_end_sun_dt" : endSunDt,
			"s_end_sat_dt" : endSatDt,
			"s_mem_no" : memNo,
			"s_org_code" : orgCode
		};

		if (confirm(msg) == true) {
			$M.goNextPageAjax(this_page + "/lastWeek/save", $M.toGetParam(params), {method: "POST"},
					function (result) {
						if (result.success) {
							alert("전주복사를 완료하였습니다.");
							goSearch();
						}
					}
			);
		}
	}

	// 조회
	function goSearch() {
		var sYear = $M.getValue("s_year");
		var sMon = $M.getValue("s_mon");

		if(sMon.length == 1) {
			sMon = "0" + sMon;
		}
		var sYearMon = sYear + sMon;

		$M.setValue("s_year_mon", $M.dateFormat($M.toDate(sYearMon), 'yyyyMM'));

		var param = {
			"s_year_mon" : $M.getValue("s_year_mon"),
			"s_mem_no" : $M.getValue("s_mem_no"),
			"s_org_code" : $M.getValue("s_org_code")
		};

		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: "GET"},
			function (result) {
				if (result.success) {
					$M.setValue("base_work_hour", result.base_work_hour);
					$M.setValue("add_limit_hour", result.add_limit_hour);

					$("#mon_st_dt").text(result.mon_st_dt);
					$("#mon_ed_dt").text(result.mon_ed_dt);
					$("#base_work_hours").text(result.base_work_hour);
					$("#work_day_cnt").text(result.work_day_cnt);

					AUIGrid.setGridData(auiGrid, result.list);
				}
			}
		);
	}

	// 편성근무표작성
	function goNewPlan(rowIndex, workDt) {
		var item = AUIGrid.getItemByRowIndex(auiGrid, rowIndex);

		var memNo = item.mem_no;
		var loginMemNo = "${SecureUser.mem_no}";
		if(loginMemNo != memNo) {
			alert("편성근무표는 본인만 작성할 수 있습니다.");
			return;
		}

		var today = $M.getCurrentDate();
		if(today > workDt) {
			alert("지난 날짜의 편성근무표는 작성 또는 수정 할 수 없습니다.");
			return;
		}

		var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=900, height=220, left=0, top=0";
		var param = {
			"s_mem_no" : item.mem_no,
			"s_mem_name" : item.week_cnt,
			"s_work_dt" : workDt,
			"s_org_code" : item.org_code
		};
		$M.goNextPage('/mmyy/mmyy0104p01', $M.toGetParam(param), {popupStatus : poppupOption});
	}

	// 연장근무신청서
	function goNewAddTime(rowIndex, workDt, memWorkSeq) {
		var item = AUIGrid.getItemByRowIndex(auiGrid, rowIndex);

		console.log("workDt :: " + workDt);
		console.log("memWorkSeq :: " + memWorkSeq);

		var memNo = item.mem_no;

		if(memWorkSeq == 0) {
			alert("편성근무표를 작상해야 연장근무를 신청 할 수 있습니다.");
			return;
		}

		var today = $M.getCurrentDate();
		if(today != workDt) {
			alert("연장근무 신청은 당일 편성근무 시간 내에 신청이 가능합니다.");
			return;
		}

		var param = {
			"s_mem_no" : item.mem_no,
			"s_mem_name" : item.week_cnt,
			"s_org_code" : item.org_code,
			"s_work_dt" : workDt,
			"s_mem_work_add_seq" : memWorkSeq,
			"add_limit_hour" : $M.getValue("add_limit_hour")
		};

		// 연장근무신청서
		var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=430, left=0, top=0";
		$M.goNextPage('/mmyy/mmyy0104p02', $M.toGetParam(param), {popupStatus : poppupOption});
	}

	function goAddTimeDtl(rowIndex, workDt, memWorkSeq) {
		var item = AUIGrid.getItemByRowIndex(auiGrid, rowIndex);

		console.log("workDt :: " + workDt);
		console.log("memWorkSeq :: " + memWorkSeq);

		var memNo = item.mem_no;

		if(memWorkSeq == 0) {
			alert("편성근무표를 작상해야 연장근무를 신청 할 수 있습니다.");
			return;
		}

		var param = {
			"s_mem_no" : item.mem_no,
			"s_mem_name" : item.week_cnt,
			"s_org_code" : item.org_code,
			"s_work_dt" : workDt,
			"s_mem_work_add_seq" : memWorkSeq,
			"add_limit_hour" : $M.getValue("add_limit_hour")
		};

		// 연장근무신청서
		var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=430, left=0, top=0";
		$M.goNextPage('/mmyy/mmyy0104p03', $M.toGetParam(param), {popupStatus : poppupOption});
	}

	// [재호] [3차-Q&A 13306] 센터별 비상대기표 변경으로 인한 기능 제거
	// - fnClickCheck() 메서드 삭제

	// 업무일지 호출
	function goDailyWork(rowIndex, workDt) {
		var item = AUIGrid.getItemByRowIndex(auiGrid, rowIndex);
		
		var param = {
			"s_mem_no" : item.mem_no,
			"s_work_dt" : workDt,
		};

		// 업무일지
		var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=430, left=0, top=0";
		$M.goNextPage('/mmyy/mmyy0103p01', $M.toGetParam(param), {popupStatus : poppupOption});
	}

	function fnCustomLabelEvent(rowIndex, columnIndex, value, dataField, item, dayStr) {
		var workType = item["work_type"];
		var memWorkInfo = value.split("#");
		var apprInfo = value.split("<br>");
		var baseWorkHour = $M.getValue("base_work_hour");
		var totTime = item['tot_time'];
		var monStDt = item.mon_st_dt;
		var monEdDt = item.mon_ed_dt;

		if(value.indexOf("~") == -1 && workType == 1) {
			if(value >= monStDt && value <= monEdDt) {
				return '<button type="button" class="btn btn-outline-default" style="width: 90%" onclick="javascript:goNewPlan(' + rowIndex + ',' + value + ');">편성근무표작성</button>';
			} else {
				return "";
			}
		} else if(workType == 2) {
			if(memWorkInfo[1] >= monStDt && memWorkInfo[1] <= monEdDt) {
				var isWorkAdd = item["is_excess_work_" + memWorkInfo[1]];
				// 최평석 상무 요청 : 연장 버튼은 기준근무시간을 넘었을 경우에만 보여지게 함.
				// if ((parseFloat(baseWorkHour) < parseFloat(totTime)) && isWorkAdd === 'true') {
				if (isWorkAdd === 'true') {
					if (value.indexOf("[") == -1) {
						if (value.indexOf("~") == -1) {
							return '<button type="button" class="btn btn-outline-default" style="width: 90%" onclick="javascript:goNewAddTime(' + rowIndex + ',' + memWorkInfo[1] + ',' + memWorkInfo[2].split('<br>')[0] + ');">'+extendReqStr+'</button>';
						} else {
							return memWorkInfo[0] + '\t<button type="button" class="btn btn-outline-default" style="width: 20%" onclick="javascript:goNewAddTime(' + rowIndex + ',' + memWorkInfo[1] + ',' + memWorkInfo[2].split('<br>')[0] + ');">'+extendStr+'</button>';
						}
					} else {
						var memWorkSeq = memWorkInfo[2].split("<br>");
						var info = memWorkInfo[0] + '<br>' + apprInfo[1];
						var template = '<div>' + '<span style="color:blue; cursor: pointer;" onclick="javascript:goAddTimeDtl(' + rowIndex + ',' + memWorkInfo[1] + ',' + memWorkSeq[0] + ');">' + info + '</span>' + '</div>';
						return template;
					}
				} else if (value.indexOf("~") == -1) {
					// return apprInfo[1];
					var memWorkSeq = memWorkInfo[2].split("<br>");
					var info = apprInfo[1];
					var template = '<div>' + '<span style="color:blue; cursor: pointer;" onclick="javascript:goAddTimeDtl(' + rowIndex + ',' + memWorkInfo[1] + ',' + memWorkSeq[0] + ');">' + info + '</span>' + '</div>';
					return template;
				} else {
					var memWorkSeq = memWorkInfo[2].split("<br>");
					var info = memWorkInfo[0] + '<br>' + apprInfo[1];
					if (apprInfo[1] != null && apprInfo[1] != "") {
						template = '<div>' + '<span style="color:blue; cursor: pointer;" onclick="javascript:goAddTimeDtl(' + rowIndex + ',' + memWorkInfo[1] + ',' + memWorkSeq[0] + ');">' + info + '</span>' + '</div>';
					} else {
						template = info;
					}
					return template;
				}
			} else {
				return "";
			}
		} else {
			if(workType == 1) {
				var beforeRowIndex = rowIndex - 1;
				var item = AUIGrid.getItemByRowIndex(auiGrid, beforeRowIndex);
				var workDt = item[dayStr].split(" ")[0].replace(/-/gi, "");
				var template = '<div>' + '<span style="color:black; cursor: pointer; text-decoration: underline;"  onclick="javascript:goNewPlan('+ rowIndex + ',' + workDt +');">' + value + '</span>' + '</div>';
				return template;
			} else if(workType == 3) {
				var beforeRowIndex = rowIndex - 1;
				var item = AUIGrid.getItemByRowIndex(auiGrid, beforeRowIndex);
				var workDt = item[dayStr].split("#")[1];
				if(workDt >= monStDt && workDt <= monEdDt) {
					var template = '<div>' + '<span style="color:black; cursor: pointer; text-decoration: underline;" onclick="javascript:goDailyWork('+ rowIndex + ',' + workDt +');">' + value + '</span>' + '</div>';
					return template;
				} else {
					return "";
				}
			} else {
				return value;
			}
		}
	}

	// 그리드 생성
	function createAUIGrid() {
		var gridPros = {
			showRowCheckColumn : false,
			showRowNumColumn : false,
			rowIdField : "_$uid",
			displayTreeOpen : true,
			showHeader: false, // header표시 여부
			enableCellMerge : true, // 셀병함 사용
			wrapText : true,
			rowHeight : 40,
			rowStyleFunction : function(rowIndex, item) {
				if(!isNaN(item.week_cnt) && item.week_cnt.length < 2) {
					// return "aui-grid-selection-row-sunday-bg"
					return "aui-calendar-weekday-bg";
				}
				return "";

			}
		};

		var columnLayout = [
			{
				headerText : "주차",
				dataField : "week_cnt",
				width : "6%",
				cellMerge : true,
				mergeRef : "mem_no", // 대분류(mem_no 필드) 셀머지의 값을 비교해서 실행함. (mergePolicy : "restrict" 설정 필수)
				mergePolicy : "restrict",
				style : "aui-center",
				labelFunction : function( rowIndex, columnIndex, value) {
					if(!isNaN(value)) {
						return value + "주차";
					} else {
						return value;
					}
				}
			},
			// [재호] [3차-Q&A 13306] 센터별 비상대기표 변경으로 인한 기능 제거
			// 당직 컬럼 삭제
			{
				headerText : "당직근무번호",
				dataField : "holiday_work_seq",
				visible : false
			},
			{
				headerText : "조직구분",
				dataField : "org_type",
				visible : false
			},
			{
				headerText : "직책",
				dataField : "grade_cd",
				visible : false
			},
			{
				headerText : "구분",
				dataField : "category",
				width : "6%"
			},
			{
				headerText : "일요일",
				dataField : "sun",
				renderer : { // HTML 템플릿 렌더러 사용
					type : "TemplateRenderer"
				},
				labelFunction : (rowIndex, columnIndex, value, dataField, item) => fnCustomLabelEvent(rowIndex, columnIndex, value, dataField, item, 'sun'),
				styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if(item.time_depth == "1") {
						return "aui-grid-selection-row-sunday-bg";
					}
				}
			},
			{
				headerText : "월요일",
				dataField : "mon",
				renderer : { // HTML 템플릿 렌더러 사용
					type : "TemplateRenderer"
				},
				labelFunction : (rowIndex, columnIndex, value, dataField, item) => fnCustomLabelEvent(rowIndex, columnIndex, value, dataField, item, 'mon'),
				styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
					var holiName = value.split("<br>")[1];
					if(item.time_depth == "1" && holiName != "") {
						return "aui-calendar-holiday-bg";
					}
				}
			},
			{
				headerText : "화요일",
				dataField : "tue",
				renderer : { // HTML 템플릿 렌더러 사용
					type : "TemplateRenderer"
				},
				labelFunction : (rowIndex, columnIndex, value, dataField, item) => fnCustomLabelEvent(rowIndex, columnIndex, value, dataField, item, 'tue'),
				styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
					var holiName = value.split("<br>")[1];
					if(item.time_depth == "1" && holiName != "") {
						return "aui-calendar-holiday-bg";
					}
				}
			},
			{
				headerText : "수요일",
				dataField : "wed",
				renderer : { // HTML 템플릿 렌더러 사용
					type : "TemplateRenderer"
				},
				labelFunction : (rowIndex, columnIndex, value, dataField, item) => fnCustomLabelEvent(rowIndex, columnIndex, value, dataField, item, 'wed'),
				styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
					var holiName = value.split("<br>")[1];
					if(item.time_depth == "1" && holiName != "") {
						return "aui-calendar-holiday-bg";
					}
				}
			},
			{
				headerText : "목요일",
				dataField : "thu",
				renderer : { // HTML 템플릿 렌더러 사용
					type : "TemplateRenderer"
				},
				labelFunction : (rowIndex, columnIndex, value, dataField, item) => fnCustomLabelEvent(rowIndex, columnIndex, value, dataField, item, 'thu'),
				styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
					var holiName = value.split("<br>")[1];
					if(item.time_depth == "1" && holiName != "") {
						return "aui-calendar-holiday-bg";
					}
				}
			},
			{
				headerText : "금요일",
				dataField : "fri",
				renderer : { // HTML 템플릿 렌더러 사용
					type : "TemplateRenderer"
				},
				labelFunction :  (rowIndex, columnIndex, value, dataField, item) => fnCustomLabelEvent(rowIndex, columnIndex, value, dataField, item, 'fri'),
				// 22.11.15 Q&A 14306 금요일도 공휴일인 경우 bg색상 변경
				styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
					var holiName = value.split("<br>")[1];
					if(item.time_depth == "1" && holiName != "") {
						return "aui-calendar-holiday-bg";
					}
				}
			},
			{
				headerText : "토요일",
				dataField : "sat",
				renderer : { // HTML 템플릿 렌더러 사용
					type : "TemplateRenderer"
				},
				labelFunction : (rowIndex, columnIndex, value, dataField, item) => fnCustomLabelEvent(rowIndex, columnIndex, value, dataField, item, 'sat'),
				styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
					if(item.time_depth == "1") {
						return "aui-grid-selection-row-satuday-bg";
					}
				}
			},
			{
				headerText : "합계",
				dataField : "total",
				width : "5%"
			},
			{
				headerText : "촣 근무시간",
				dataField : "tot_time",
				width : "5%",
				cellMerge : true,
				mergeRef : "week_cnt", // 대분류(week_cnt 필드) 셀머지의 값을 비교해서 실행함. (mergePolicy : "restrict" 설정 필수)
				mergePolicy : "restrict"
			},
			{
				headerText : "타입",
				dataField : "work_type",
				visible : false
			},
			{
				headerText : "직원번호",
				dataField : "mem_no",
				visible : false
			},
			{
				headerText : "편성근무표작성 여부",
				dataField : "plan_yn",
				visible : false
			},
			{
				headerText : "월시작일",
				dataField : "mon_st_dt",
				visible : false
			},
			{
				headerText : "월종료일",
				dataField : "mon_ed_dt",
				visible : false
			},
		];

		// 실제로 #grid_wrap에 그리드 생성
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);

		// 그리드 갱신
		AUIGrid.setGridData(auiGrid, []);
	}
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" id="s_year_mon" name="s_year_mon" value="${inputParam.s_year_mon}"/>
<input type="hidden" id="base_work_hour" name="base_work_hour"/>
<input type="hidden" id="add_limit_hour" name="add_limit_hour"/>
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
						<table class="table table-fixed">
							<colgroup>
								<col width="65px">
								<col width="150px">
								<col width="55px">
								<col width="230px">
								<col width="90px">
								<col width="120px">
								<col width="230px">
								<col width="100px">
								<col width="">
							</colgroup>
							<tbody>
							<tr>
								<th>결산년월</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-7">
											<select class="form-control" id="s_year" name="s_year">
												<c:forEach var="i" begin="2012" end="${inputParam.last_year}" step="1">
													<option value="${i}" <c:if test="${i == inputParam.s_year}">selected</c:if>>${i}년</option>
												</c:forEach>
											</select>
										</div>
										<div class="col-5">
											<select class="form-control" id="s_mon" name="s_mon" onchange="javascript:fnWeekCntChange()">
												<c:forEach var="i" begin="1" end="12" step="1">
													<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i==inputParam.s_mon}">selected</c:if>>${i}월</option>
												</c:forEach>
											</select>
										</div>
									</div>
								</td>
								<th>부서</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-5">
											<select class="form-control" id="s_org_code" name="s_org_code" onchange="javascript:goMemNoListChange()">
												<option value="">- 전체 -</option>
												<c:forEach var="item" items="${orgList}">
													<option value="${item.org_code}" <c:if test="${inputParam.s_org_code == item.org_code}">selected</c:if>>${item.org_name}</option>
												</c:forEach>
											</select>
										</div>
										<div class="col-7">
											<select class="form-control" id="s_mem_no" name="s_mem_no">
											</select>
										</div>
									</div>
								</td>
								<td>
									<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch()">조회</button>
								</td>
								<th>편성근무표 복사(본인)</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-auto">
											<select class="form-control" id="s_start_week" name="s_start_week">
												<option value="0">- 전월 마지막주 -</option>
											</select>
										</div>
										<div class="col-auto">근무를</div>
										<div class="col-auto">
											<select class="form-control" id="s_end_week" name="s_end_week">
											</select>
										</div>
										<div class="col-auto">로</div>
									</div>
								</td>
								<td>
									<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:fnCopyPlanSchedule()">복사</button>
								</td>
								<td class="text-right text-warning">
									※ 당사는 포괄임금제로 인해 총 근무시간 중 6시간은 기본으로 포함되어 있습니다.
									<br>※ 휴가는 전산에서 자동으로 계산되니 고려하지 말고 편성시간을 작성해주세요.
									<br>결산일자 : <span id="mon_st_dt"></span> ~ <span id="mon_ed_dt"></span>
									<br>기준근무일수 : <span id="work_day_cnt"></span>일 || 기준근무시간 : <span id="base_work_hours"></span>시간
								</td>
							</tr>
							</tbody>
						</table>
					</div>
					<!-- /기본 -->
					<div id="auiGrid" style="margin-top: 5px; height: 600px;"></div>
				</div>
			</div>
			<div class="btn-group mt10">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
		</div>
		<!-- /contents 전체 영역 -->
	</div>
	<c:if test="${inputParam.s_popup_yn ne 'Y'}">
		<div>
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
		</div>
	</c:if>
</form>
</body>
</html>