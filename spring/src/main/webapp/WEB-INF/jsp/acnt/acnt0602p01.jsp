<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 자산 > 휴가원관리 > null > 휴가원등록
-- 작성자 : 손광진
-- 최초 작성일 : 2020-07-17 10:18:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp" />
<script type="text/javascript">
	$(document).ready(function() {
		fnInitDate();
	});

	function fnInitDate() {
		var today = new Date();

		month = today.getMonth() + 1;
		day = today.getDate();
		year = today.getFullYear();

		if (month.length < 2) {
			month = '0' + month;
		};

		if (day.length < 2) {
			day = '0' + day;
		};
		var curDate = year + "년 " + month + "월 " + day + "일";
		
		$("#curDate").text(curDate);
	}


	// 휴가원등록
	function goSave() {

		if($M.nvl($M.getValue("holiday_type_cd"), "") === "") {
			alert("휴가 종류를 선택해주세요.")
			return;
		};
		
		if($M.nvl($M.getValue("day_cnt"), "") === "") {
			alert("휴가 일수를 입력해주세요.")
			return;
		};
		
		if($M.nvl($M.getValue("content"), "") === "") {
			alert("사유를 입력해주세요.")
			return;
		};

		// 날짜 검증 추가 20220901 정윤수
		if($M.checkRangeByFieldName("start_dt", "end_dt", true) === false) {
			return;
		};

		var frm = document.main_form;
		frm = $M.toValueForm(frm);
		
		$M.goNextPageAjax(this_page + "/save", frm, {method : 'POST'},
			function(result) {
				if(result.success) {
					alert("처리가 완료되었습니다.");
					window.close();
				}
			}
		)
	}

	// 휴가 일 수 계산 수정!
	function goSearch() {

		// 날짜 검증
		if ($M.checkRangeByFieldName("s_start_dt", "s_end_dt", true) == false) {
			return;
		}
		;

		// 1. 검색할 직원 조회
		var s_mem_no = $M.nvl($M.getValue("s_mem_no"), ""); // 1-1. 직원목록 selectBox의 값을 받음, 전체 조회시 value = "ALL"

		if (s_mem_no === "") {
			// 1-1. selectBox
			s_mem_no = $M.getValue("login_mem_no");
		}
		;

		var param = {
			"s_mem_no" : s_mem_no,
			"s_start_dt" : $M.getValue("s_start_dt"),
			"s_end_dt" : $M.getValue("s_end_dt"),
			"s_appr_proc_status_cd" : $M.getValue("s_appr_proc_status_cd"),
			"s_sort_key" : "start_dt",
			"s_sort_method" : "desc"
		};
		
		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {
			method : "get"
		}, function(result) {
			if (result.success) {
				AUIGrid.setGridData(auiGrid, result.list);
				$("#total_cnt").html(result.total_cnt);
			}
			;
		});
	}
	// 휴가일수 계산추가 20220901 정윤수
	function fnGetHolidayCnt() {

		var holidayTypeCd 	= $M.nvl($M.getValue("holiday_type_cd"), "");
		var start_dt 		= $M.nvl($M.getValue("start_dt"), "");
		var end_dt 			= $M.nvl($M.getValue("end_dt"), "");
		// 필수값 확인
		if(holidayTypeCd === "" || start_dt === "" || end_dt === "") {
			return;
		};

		// 날짜 검증
		if($M.checkRangeByFieldName("start_dt", "end_dt", true) === false) {
			return;
		};

		var param = {
			"s_start_dt" 	: $M.getValue("start_dt"),
			"s_end_dt" 		: $M.getValue("end_dt"),
		};

		$M.goNextPageAjax(this_page + "/holidayCnt", $M.toGetParam(param), {method : "get"},
				function(result) {
					if(result.success) {
						var day_cnt = result.day_cnt;
						if(holidayTypeCd == "21" || holidayTypeCd == "22") {
							day_cnt = $M.toNum(result.day_cnt / 2);
						};
						$M.setValue("day_cnt", day_cnt);

					};
				}
		);

	}

	function fnClose() {
		window.close();
	}
	
	// 직원조회 
	function fnSetMemberInfo(data) {
		$M.setValue("mem_no", data.mem_no);
		$M.setValue("org_name", data.org_name);
		$M.setValue("org_code", data.org_code);
		$M.setValue("contact_no", data.hp_no_real);
		$M.setValue("grade_name", data.grade_name);
		$M.setValue("grade_cd", data.grade_cd);

		
		// 결재선라인 세팅
		var apprMemNoStr = [];				// mem_no
		var apprMemNo	 = data.mem_no;		// memNo
		
		apprMemNoStr.push(apprMemNo);	
		apprMemNoStr.push("${SecureUser.mem_no}");
		
		var setApprMemNoStr = $M.getArrStr(apprMemNoStr);
		var frm 	= document.main_form;
		$M.setValue(frm, "appr_mem_no_str", setApprMemNoStr);
	}

	// 22.11.15 Q&A 15065 휴가원 작성 수정
	function fnChangeEndDate () {
		$M.setValue("end_dt", $M.getValue("start_dt"));
		fnGetHolidayCnt();
	}
	
</script>
</head>
<body class="bg-white">
	<form id="main_form" name="main_form">
		<!-- appr(결재요청 후 저장), save(저장) -->
		<input type="hidden" id="mem_no" name="mem_no" value="">
		<input type="hidden" id="org_code" name="org_code" value="">
		<input type="hidden" name="appr_job_cd" id="appr_job_cd" value="MEM_HOLIDAY" alt="결재업무" required="required"/>
		<input type="hidden" name="appr_status_cd" id="appr_proc_status" value="01" alt="작업상태" required="required"/>
		<input type="hidden" name="appr_mem_no_str" id="appr_mem_no_str" alt="결재라인" required="required"/>
		<!-- 팝업 -->
		<div class="popup-wrap width-100per">
			<!-- 타이틀영역 -->
			<div class="main-title">
				<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp" />
			</div>
			<!-- /타이틀영역 -->
			<div class="content-wrap">
				<div>
					<div class="title-wrap">
						<div class="left">
							<h4>휴가, 공가신청서</h4>
						</div>
					</div>
					<!-- 폼테이블 -->
					<table class="table-border mt10">
						<colgroup>
							<col width="80px">
							<col width="">
							<col width="80px">
							<col width="">
						</colgroup>
						<tbody>
							<tr>
								<th class="text-right">성명</th>
								<td>														
									<div class="inline-pd">
										<jsp:include page="/WEB-INF/jsp/common/searchMem.jsp">
											<jsp:param name="required_field" value=""/>
											<jsp:param name="execFuncName" value="fnSetMemberInfo"/>
										</jsp:include>
									</div></td>
								<th class="text-right">소속</th>
								<td><input type="text" class="form-control width120px" readonly="readonly" value="" id="org_name" name="org_name"></td>
							</tr>
							<tr>
								<th class="text-right essential-item">연락처</th>
								<td><input type="text" class="form-control essential-bg width120px" id="contact_no" name="contact_no" value="" format="phone" placeholder="숫자만 입력" required="required" alt="핸드폰"></td>
								<th class="text-right">직책</th>
								<td><input type="text" class="form-control width120px" readonly="readonly" id="grade_name" name="grade_name" value=""></td>
									
							</tr>
							<tr>
								<th class="text-right essential-item">종류</th>
								<td colspan="3"><select class="form-control width100px"
									id="holiday_type_cd" name="holiday_type_cd" alt="결재선 상태구분" onChange="fnGetHolidayCnt();">
										<option value="">- 선택 -</option>
										<c:forEach items="${codeMap['HOLIDAY_TYPE']}" var="item">
											<option value="${item.code_value}"
												${item.code_value == "0" ? 'selected' : '' }>${item.code_name}</option>
										</c:forEach>
								</select></td>
							</tr>
							<tr>
								<th class="text-right essential-item">기간</th>
								<td colspan="3">
									<div class="form-row inline-pd widthfix">
										<div class="col width45px">시작일</div>
										<div class="col width120px">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="start_dt" name="start_dt" dateFormat="yyyy-MM-dd" value="" alt="시작일" onChange="fnChangeEndDate();">
											</div>
										</div>
										<div class="col width16px text-center">~</div>
										<div class="col width120px">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="end_dt" name="end_dt" dateFormat="yyyy-MM-dd" value="" alt="완료일" onChange="fnGetHolidayCnt();">
											</div>
										</div>
										<div class="col width120px">
											<input type="text" id="day_cnt" name="day_cnt" format="num" size="3" value="" alt="조회 완료일" disabled="disabled"> 일간
										</div>
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right essential-item">사유</th>
								<td colspan="3"><textarea class="form-control" style="height: 150px;" id="content" name="content"></textarea></td>
							</tr>
						</tbody>
					</table>
					<!-- /폼테이블 -->
					<div class="contract-info pr">
						<p class="font-13 text-dark mb10" id="curDate"></p>
						<div class="contract-name">
							<p class="mb5"> </p>
							<p></p>
						</div>
					</div>
				</div>

				<div class="btn-group mt10">
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param
								name="pos" value="BOM_R" /></jsp:include>
					</div>
				</div>
			</div>
		</div>
		<!-- /팝업 -->
	</form>
</body>
</html>