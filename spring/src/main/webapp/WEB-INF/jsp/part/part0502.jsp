<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<jsp:useBean id="now" class="java.util.Date"/>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 재고관리 > HOMI관리 > null > null
-- 작성자 : 김인석
-- 최초 작성일 : 2020-02-13 17:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<style type="text/css">
		.date-item:hover {
			background:#F6F6F6
		}
	</style>
	
	<script type="text/javascript">
	
		$(document).ready(function() {
			
		});

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
			var nextDate = $M.addMonths($M.toDate(sYearMon), +1);
			
			$M.setValue("s_year_mon", $M.dateFormat(nextDate, 'yyyyMM'));
			
			goSearch();
		}

		// 검색
		function goSearch() { 
			var param = {
					"s_year_mon" : $M.getValue("s_year_mon")
			};
			
			$M.goNextPage(this_page, $M.toGetParam(param), {method:"GET"});
		}

		// 센터 변경항목 호출
		function fnCenterInfo(changeCenterList, warehouseCd, workDt, changeTxt, warehouseName) {
			event.stopPropagation();

			$M.setValue("warehouse_cd_str", warehouseCd);
			$M.setValue("work_dt", workDt);
			
			var sYearMon = ${inputParam.s_year_mon};
// 			$("#center_title").html(changeCenterList);
			$("#center_title").html($M.dateFormat(workDt, 'yyyy-MM-dd')+" "+warehouseName);
			$("#change_txt").html(changeTxt);

			var param = {
					"s_year_mon" : sYearMon,
					"warehouse_cd" : warehouseCd,
					"homi_dt" : workDt
			};

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$("#sel_change_center").html("");

						var comboList = result.list;
						$("#sel_change_center").append("<option value=''> - 선택 -</option>");
						for(var i=0; i<comboList.length; i++) {
							var option = $("<option></option>");
							option.val(comboList[i].homi_dt + "," + comboList[i].warehouse_cd);
							option.text(comboList[i].homi_md + " " + comboList[i].warehouse_name);
							$("#sel_change_center").append(option);
						}
						
						// 휴일정보 세팅
						var detail = result.detail;
						$M.setValue("homi_holi_yn", detail.homi_holi_yn);
						$M.setValue("homi_holi_name", detail.homi_holi_name);
						fnSetHoliName(detail.homi_holi_yn);
					}
				}
			);
		}

		function changeTxtReset() {
			$M.setValue("change_txt", "");
		}

		// 센터 변경 항목 저장
		function goSave() {
		
			var frm = document.main_form;
			if($M.validation(frm) == false) {
				return;
			}

			var selChangeCenter = $M.getValue("sel_change_center");

			var warehouseCd = $M.getValue("warehouse_cd_str");
			var workDt = $M.getValue("work_dt");
			
			if (workDt == "") {
				alert("달력을 선택해주세요.");
				return false;
			}
			
			console.log("selChangeCenter :: " + selChangeCenter);
			console.log("warehouseCd :: " + warehouseCd);
			console.log("work_dt :: " + workDt);

			var selChangeCenterSplit = "";
			if(selChangeCenter.indexOf(",") != -1) {
				selChangeCenterSplit = selChangeCenter.split(",");
				$M.setValue("homi_dt_str", workDt + "#" + selChangeCenterSplit[0]);
				// $M.setValue("warehouse_cd_str", warehouseCd + "#" + selChangeCenterSplit[1]);
				$M.setValue("warehouse_cd_str", selChangeCenterSplit[1] + "#" + warehouseCd);
				$M.setValue("before_homi_dt_str", selChangeCenterSplit[0] + "#" + workDt);
				// $M.setValue("before_warehouse_cd_str", selChangeCenterSplit[1] + "#" + warehouseCd);
				$M.setValue("before_warehouse_cd_str", warehouseCd + "#" + selChangeCenterSplit[1]);
			}

			console.log("homi_dt_str :: " + $M.getValue("homi_dt_str"));
			console.log("warehouse_cd_str :: " + $M.getValue("warehouse_cd_str"));
			console.log("before_warehouse_cd_str :: " + $M.getValue("before_warehouse_cd_str"));
			console.log("before_homi_dt_str :: " + $M.getValue("before_homi_dt_str"));

			$M.setValue("work_dt", workDt);
			$M.goNextPageAjaxSave(this_page + '/save', $M.toValueForm(frm), {method : 'POST'},
					function(result) {
						if(result.success) {
							goSearch();
						}
					}
			);
		}

		// 운영센터설정 팝업 호출
		function goCenterSetting() {
			var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=500, height=430, left=0, top=0";
			$M.goNextPage('/part/part0502p02', "", {popupStatus : poppupOption});
		}

		// 센터설정적용 버튼
		function goCenterApply() {
			var sYearMon = $M.getValue("s_year_mon");

			// 전월
			var beforeYearMon = $M.addMonths($M.toDate(sYearMon), -1);
			$M.setValue("s_before_year_mon", $M.dateFormat(beforeYearMon, 'yyyyMM'));

			var param = {
				"s_year_mon" : $M.getValue("s_year_mon"),
				"s_before_year_mon" : $M.getValue("s_before_year_mon")
			};

			var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=500, height=430, left=0, top=0";
			$M.goNextPage('/part/part0502p05', $M.toGetParam(param), {popupStatus : poppupOption});
		}

		// 페이지 이동
		function goDetail(seqNo, homiDt, warehouseCd, warehouseName) {
			var popupOption = "scrollbars=yes, resizable-1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1100, height=580, left=0, top=0";
			var param = {
					"warehouse_cd" : warehouseCd,
// 					"warehouse_name" : warehouseName,
					"homi_dt" : homiDt,
					"seq_no" : seqNo
			};
			$M.goNextPage('/part/part0502p04', $M.toGetParam(param), {popupStatus : popupOption});
		}
		
		function fnSetHoliName(homiHoliYn) {
			if ("Y" == homiHoliYn) {
				$("#homi_holi_name").prop("readonly", false);
				$("#sel_change_center").prop("disabled", true);
				$("#change_txt").prop("readonly", true);
			} else {
				$("#homi_holi_name").prop("readonly", true);
				$("#sel_change_center").prop("disabled", false);
				$("#change_txt").prop("readonly", false);
				$M.setValue("homi_holi_name", "");
			}
		}

	</script>
</head>
<body id="body">
<form id="main_form" name="main_form">
<input type="hidden" id="s_year" name="s_year" value="${inputParam.s_year}" />
<input type="hidden" id="s_mon" name="s_mon" value="${inputParam.s_mon}" />
<input type="hidden" id="s_year_mon" name="s_year_mon" value="${inputParam.s_year_mon}" />

<input type="hidden" id="warehouse_cd_str" name="warehouse_cd_str"/>
<input type="hidden" id="homi_dt_str" name="homi_dt_str"/>
<input type="hidden" id="work_dt" name="work_dt"/>
<input type="hidden" id="before_homi_dt_str" name="before_homi_dt_str"/>
<input type="hidden" id="before_warehouse_cd_str" name="before_warehouse_cd_str"/>
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
<!-- 검색영역 -->					
					<div class="search-wrap">				
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
									<td style="width: 80px" align="center">
										<div>${inputParam.s_year}년  ${inputParam.s_mon}월</div>
									</td>
									<td> 
										<button type="button" class="btn btn-icon btn-primary-gra" onclick="nextCalendar()"><i class="material-iconsarrow_right"></i></button>
									</td>		
								</tr>										
							</tbody>
						</table>					
					</div>
<!-- /검색영역 -->	

					<div class="row mt10">
<!-- 달력 -->
						<div class="col-8">
							<table class="calendar-table" id="calendar" style="text-align: right;">
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
													<c:when test="${lines.today_yn eq 'Y'}"><td class="today-bg" onclick="javascript:goDetail('${lines.seq_no}', '${lines.homi_dt}', '${lines.warehouse_cd}', '${lines.warehouse_name}')" style="cursor:pointer"></c:when>
													<c:when test="${lines.week == 1}"><td class="sunday-bg"></c:when>
													<c:when test="${lines.week == 7}"><td class="satuday-bg"></c:when>
													<c:when test="${lines.holi_yn eq 'Y'}"><td class="holiday-bg"></c:when>
													<c:otherwise>	
														<c:if test="${page.fnc.F00357_001 eq 'Y'}">
															<td>
														</c:if>
														<c:if test="${page.fnc.F00357_001 ne 'Y'}">
															<td>
														</c:if>																																					
													</c:otherwise>
												</c:choose>
													<c:if test="${page.fnc.F00357_001 eq 'Y'}">
														<div class="date-item"  onclick="javascript:fnCenterInfo('${lines.change_center_list}', '${lines.warehouse_cd}', '${lines.work_dt}', '${lines.change_txt}', '${lines.warehouse_name}')" style="cursor:pointer; width: 100%;">
													</c:if>
													<c:if test="${page.fnc.F00357_001 ne 'Y'}">
														<div class="date-item" style="cursor:pointer; width: 100%;">
													</c:if>
														<div class="date<c:if test="${lines.same_mon_yn eq 'N'}"> prev</c:if>">${lines.work_day}</div>
														<div class="text-holiday" style="height: 18px">${lines.holi_name}</div>	
														<div class="center" >${lines.warehouse_name}</div>												
													</div>
													<c:choose>
														<c:when test="${lines.today_yn ne 'Y' && page.fnc.F00357_001 eq 'Y'}">
															<div class="datail-list"  onclick="javascript:goDetail('${lines.seq_no}', '${lines.homi_dt}', '${lines.warehouse_cd}', '${lines.warehouse_name}')" style="cursor:pointer">${lines.change_center_txt}</div>
														</c:when>
														<c:otherwise>
															<div class="datail-list">${lines.change_center_txt}</div>
														</c:otherwise>
													</c:choose>
														
												</td>
											</c:forEach>
										</tr>
									</c:forEach>
								</tbody>
							</table>
							<div class="btn-group mt5">						
								<div class="right">
									<c:if test="${page.fnc.F00357_001 eq 'Y'}">
										<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
									</c:if>
								</div>
							</div>
						</div>
						
<!-- /달력 -->
<!-- 고령센터 -->
					<c:if test="${page.fnc.F00357_001 eq 'Y'}">
						<div class="col-4">
							<div class="title-wrap">
								<h4 id="center_title"></h4>
							</div>
							<table class="table-border">
								<colgroup>
									<col width="90px">
									<col width="">
								</colgroup>
								<tbody>
									<tr>
										<th class="text-right td-gray">휴일구분</th>
										<td>
											<input type="radio" name="homi_holi_yn" id="homi_holi_n" value="N" onclick="javascript:fnSetHoliName('N')"/>
											<label for="homi_holi_n">평일</label>
<%-- 											<input type="radio" name="homi_holi_yn" id="homi_holi_Y" value="Y" <c:if test="${ list.cap_yn eq 'N'}">checked</c:if>  /> --%>
											<input type="radio" name="homi_holi_yn" id="homi_holi_y" value="Y" onclick="javascript:fnSetHoliName('Y')"/>
											<label for="homi_holi_y">공휴일</label>
										</td>
									</tr>
									<tr>
										<th class="text-right td-gray">공휴일명</th>
										<td>
											<input type="text" class="form-control" id="homi_holi_name" name="homi_holi_name" />
										</td>
									</tr>
									<tr>
										<th class="text-right td-gray">센터변경</th>
										<td>
											<select class="form-control" id="sel_change_center" name="sel_change_center" alt="센터변경" onchange="javascript:changeTxtReset()">
												<option value="">- 선택 -</option>
											</select>
										</td>
									</tr>
									<tr>
										<th class="text-right td-gray">변경사유</th>
										<td>
											<textarea class="form-control" style="height: 100px;" id="change_txt" name="change_txt"></textarea>
										</td>
									</tr>
								</tbody>
							</table>
<!-- 그리드 서머리, 컨트롤 영역 -->
							<div class="btn-group mt5">						
								<div class="right">							
								
										<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
								
								</div>
							</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
						</div>
					</c:if>	
<!-- /고령센터 -->


					</div>
				</div>						
			</div>		
		</div>
<!-- /contents 전체 영역 -->
</div>
	<div>
		<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
	</div>
</form>
</body>
</html>