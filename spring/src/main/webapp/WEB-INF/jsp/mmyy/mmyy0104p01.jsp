<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 근무관리 > null > 편성근무표작성
-- 작성자 : 성현우
-- 최초 작성일 : 2020-04-09 11:51:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	var planStHour = "";
	var planStMin = "";
	var planEdHour = "";
	var planEdMin = "";
	$(document).ready(function() {
		fnInit();
	});

	function fnInit() {
		setInterval(calcTime, 100);
	}

	function calcTime() {
		var sPlanStHour = $M.getValue("s_plan_st_hour");
		var sPlanStMin = $M.getValue("s_plan_st_min");
		var sPlanEdHour = $M.getValue("s_plan_ed_hour");
		var sPlanEdMin = $M.getValue("s_plan_ed_min");

		if(planStHour != sPlanStHour) {
			planStHour = sPlanStHour;
		}

		if(planStMin != sPlanStMin) {
			planStMin = sPlanStMin;
		}

		if(planEdHour != sPlanEdHour) {
			planEdHour = sPlanEdHour;
		}

		if(planEdMin != sPlanEdMin) {
			planEdMin = sPlanEdMin;
		}

		var lapsetime = 0;
		var planStTime = getTime(planStHour, planStMin);
		var planEdTime = getTime(planEdHour, planEdMin);

		if(planEdTime.getTime() < planStTime.getTime()) {
			planEdTime.setDate(planEdTime.getDate() + 1);
		}

		try{
			lapsetime = (Math.floor(((planEdTime.getTime() - planStTime.getTime()) / 1000 / 60 / 60) * 10) / 10) ;
			//5시간이상 근무 시 점시시간 한시간 포함한다.
			if(lapsetime >= 5) {
				lapsetime--;
			}

			var temp = (lapsetime + '').split(".");
			var templapsetime0 = temp[0];
			var templapsetime1 = temp[1];

			if(templapsetime1 >= 5) {
				templapsetime1 = 5
			} else {
				templapsetime1 = 0
			}

			if(templapsetime0 <= 0) {
				lapsetime = 0;
			}else{
				lapsetime = templapsetime0 + '.' + templapsetime1;
			}
		} catch(Exception) {
		}

		$M.setValue("diff_time", lapsetime);
	}

	function getTime(hour, min) {
		var d = new Date();

		if("" == hour) {
			hour = 0;
		}

		if("" == min) {
			min = 0;
		}

		return new Date(d.getFullYear(), d.getMonth(), d.getDay(), Number(hour), Number(min));
	}

	//저장
	function goSave() {
		var frm = document.main_form;
		//validationcheck
		if($M.validation(frm,
				{field:["s_plan_st_hour", "s_plan_st_min", "s_plan_ed_hour", "s_plan_ed_min"]}) == false) {
			return;
		};

		var startTiH = $M.toNum($M.getValue("s_plan_st_hour"));
		var startTiM = $M.toNum($M.getValue("s_plan_st_min"));
		var endTiH = $M.toNum($M.getValue("s_plan_ed_hour"));
		var endTiM = $M.toNum($M.getValue("s_plan_ed_min"));

		if(startTiH < 1 || startTiH > 23) {
			alert("근무시간 입력 시 시간은 (01 ~ 23)시로 입력 해야합니다.");
			return;
		}

		if(startTiM > 59) {
			alert("근무시간 입력 시 분은 (01 ~ 59)분으로 입력 해야합니다.");
			return;
		}

		if(endTiH < 1 || endTiH > 23) {
			alert("근무시간 입력 시 시간은 (01 ~ 23)시로 입력 해야합니다.");
			return;
		}

		if(endTiM > 59) {
			alert("근무시간 입력 시 분은 (01 ~ 59)분으로 입력 해야합니다.");
			return;
		}

		if(startTiH > endTiH) {
			alert("근무시작시간은 근무종료시간보다 늦을 수 없습니다.");
			return;
		}

		var memNo = $M.getValue("s_mem_no");
		var workDt = $M.getValue("s_work_dt");
		var orgCode = $M.getValue("s_org_code");

		var planSt = $M.getValue("s_plan_st_hour") + $M.getValue("s_plan_st_min");
		var planEd = $M.getValue("s_plan_ed_hour") + $M.getValue("s_plan_ed_min");

		var params = {
			"mem_no" : memNo,
			"work_dt" : workDt,
			"org_code" : orgCode,
			"plan_in_ti" : planSt,
			"plan_out_ti" : planEd
		};

		$M.goNextPageAjaxSave(this_page + "/save", $M.toGetParam(params), {method : 'POST'},
			function(result) {
				if(result.success) {
					alert("저장이 완료되었습니다.");
					fnClose();
					window.opener.goSearch();
				};
			}
		);
	}

	// 닫기
	function fnClose() {
		window.close();
	}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" name="s_mem_no" id="s_mem_no" value="${inputParam.s_mem_no}">
<input type="hidden" name="s_org_code" id="s_org_code" value="${inputParam.s_org_code}">
	<div class="popup-wrap width-100per">
		<!-- 메인 타이틀 -->
		<div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"></jsp:include>
		</div>
		<!-- /메인 타이틀 -->
		<div class="content-wrap">
			<div class="title-wrap half-print" style="min-width: 600px;">
				<div class="doc-info" style="flex: 1;">
					<h4>편성근무표작성</h4>
				</div>
			</div>
			<table class="table-border mt10">
				<colgroup>
					<col width="80px">
					<col width="">
					<col width="80px">
					<col width="">
				</colgroup>
				<tbody>
				<tr>
					<th class="text-right">작성일자</th>
					<td>
						<input type="text" class="form-control width120px" name="s_work_dt" id="s_work_dt" dateFormat="yyyy-MM-dd" value="${inputParam.s_work_dt}" readonly="readonly">
					</td>
					<th class="text-right">작성자</th>
					<td>
						<input type="text" class="form-control width120px" name="s_mem_name" id="s_mem_name" readonly="readonly" value="${inputParam.s_mem_name}">
					</td>
					<th class="text-right">센터</th>
					<td>
						<input type="text" class="form-control width120px" name="s_org_name" id="s_org_name" readonly="readonly" value="${list.org_name == null ? SecureUser.org_name : list.org_name}">
					</td>
				</tr>
				<tr>
					<th class="text-right">근무시간</th>
					<td colspan="3">
						<div id="temp" class="form-row inline-pd widthfix">
							<div class="col width40px">
								<input type="text" id="s_plan_st_hour" name="s_plan_st_hour" class="form-control text-right" minlength="2" maxlength="2" dataType="int" required="required" alt="출근시간(시)" value="${list.plan_st_hour}">
							</div>
							<div class="col width16px">시</div>
							<div class="col width35px">
								<input type="text" id="s_plan_st_min" name="s_plan_st_min" class="form-control text-right" minlength="2" maxlength="2" dataType="int" required="required" alt="출근시간(분)" value="${list.plan_st_min}">
							</div>
							<div class="col width16px">분</div>
							<div class="col width16px text-center">~</div>
							<div class="col width35px">
								<input type="text" id="s_plan_ed_hour" name="s_plan_ed_hour" class="form-control text-right" minlength="2" maxlength="2" dataType="int" required="required" alt="퇴근시간(시)" value="${list.plan_ed_hour}">
							</div>
							<div class="col width16px">시</div>
							<div class="col width35px">
								<input type="text" id="s_plan_ed_min" name="s_plan_ed_min" class="form-control text-right" minlength="2" maxlength="2" dataType="int" required="required" alt="퇴근시간(분)" value="${list.plan_ed_min}">
							</div>
							<div class="col width16px">분</div>
							<div class="col width65px">
								<input type="text" class="form-control text-right" name="diff_time" id="diff_time" readonly="readonly">
							</div>
							<div class="col width35px">시간</div>
						</div>
					</td>
				</tr>
				</tbody>
			</table>
			<div class="btn-group mt10">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
		</div>
	</div>
</form>
</body>
</html>