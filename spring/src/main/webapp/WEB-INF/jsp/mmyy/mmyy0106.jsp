<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 휴가원 > null > null
-- 작성자 : 손광진
-- 최초 작성일 : 2020-07-16 09:30:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var auiGrid;
		$(document).ready(function () {
			createAUIGrid();
			fnInitDate();
			goSearch();
		});
		
		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_kor_name"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch(document.main_form);
				};
			});
		}
		
		// 시작일자 세팅 현재날짜 년도의 1월1일
		function fnInitDate() {
			var currentYear = $M.getCurrentDate('yyyy');
	
			$M.setValue("s_start_dt", currentYear + '0101');
			$M.setValue("s_end_dt", currentYear + '1231');
		}
		
		// 직원목록 조회(현재 임시조회 view 테이블 생성 시 변경예정)
		function goSearch() {
			
			// 필수값
			if ($M.validation(document.main_form) == false) {
				return;
			};
			
	     	var stYear  = $M.getValue("s_start_dt").substring(0, 4);
	     	var endYear = $M.getValue("s_end_dt").substring(0, 4);
	     	
	     	if(stYear != endYear) {
	     		alert("시작일과 종료일을 같은 연도로 입력해 주세요.");
	     		return;
	     	};
			
			// 날짜 검증
			if($M.checkRangeByFieldName("s_start_dt", "s_end_dt", true) == false) {				
				return;
			};

			var param = {
				"s_mem_no" 				: $M.getValue("s_my_yn") == "Y" ? "${SecureUser.mem_no}" : "",
				"s_start_dt" 			: $M.getValue("s_start_dt"),
				"s_end_dt" 				: $M.getValue("s_end_dt"),
				"s_appr_proc_status_cd" : $M.getValue("s_appr_proc_status_cd"),
				"s_sort_key" 			: "start_dt desc, apply_date",
				"s_sort_method" 		: "desc",
				"s_holiday_type_cd" 	: $M.getValue("s_holiday_type_cd"), // 22.11.15 Q&A 15065 휴가종류 검색조건 추가

			};
			
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : "get"},
				function(result) {
					if(result.success) {
						AUIGrid.setGridData(auiGrid, result.list);
						$("#total_cnt").html(result.total_cnt);
						$("#currYear").html("<b>${SecureUser.kor_name}</b>" + "님 " +  $M.getValue("s_start_dt").substring(0, 4) + "년 휴가사용현황");
						console.log($M.nvl(result.memHolidayInfo, null) );
						
						if($M.nvl(result.memHolidayInfo, null) != null) {
							// 검색f시 해당년도
							$("#issue_cnt").text(result.memHolidayInfo.issue_cnt); 					// 발생 연차 일수
							$("#remainder_day_cnt").text(result.memHolidayInfo.remainder_day_cnt); 	// 남은 연차 일수
						 	$("#total_use_day_cnt").text(result.memHolidayInfo.tsotal_use_day_cnt); 	// 총 사용 휴가일수
							$("#days1").text(result.memHolidayInfo.days1); 							// 국내출장 일수
							$("#days2").text(result.memHolidayInfo.days2); 							// 국외출장 일수
							$("#days3").text(result.memHolidayInfo.days3); 							// 종일휴가 일수
							$("#days4").text(result.memHolidayInfo.days4); 							// 오전휴가 일수
							$("#days5").text(result.memHolidayInfo.days5); 							// 오후휴가 일수
							$("#days6").text(result.memHolidayInfo.days6); 							// 공가 일수
							$("#days7").text(result.memHolidayInfo.days7); 							// 특별휴가 일수
							$("#days8").text(result.memHolidayInfo.days8); 							// 무급휴가 일수
							$("#days9").text(result.memHolidayInfo.days9); 							// 휴직 일수
							$("#mi_proc_days").text(result.memHolidayInfo.mi_proc_days);			// 미결신청 일수	
						} else {
							// 검색시 해당년도
							$("#issue_cnt").text(""); 			// 발생 연차 일수
							$("#remainder_day_cnt").text(""); 	// 남은 연차 일수
						 	$("#total_use_day_cnt").text(""); 	// 총 사용 휴가일수
							$("#days1").text(""); 				// 국내출장 일수
							$("#days2").text(""); 				// 국외출장 일수
							$("#days3").text(""); 				// 종일휴가 일수
							$("#days4").text(""); 				// 오전휴가 일수
							$("#days5").text(""); 				// 오후휴가 일수
							$("#days6").text(""); 				// 공가 일수
							$("#days7").text(""); 				// 특별휴가 일수
							$("#days8").text(""); 				// 무급휴가 일수
							$("#days9").text(""); 				// 휴직 일수
							$("#mi_proc_days").text("");		// 미결신청 일수	
						}
						
					};
				}
			);
		}
		
	
		function goNew() {
			var popupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=950, height=750, left=0, top=0";
			
			$M.goNextPage('/mmyy/mmyy0106p01', "", {popupStatus : popupOption});
		}
	
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "휴가원 목록", "");
		}
		
		function createAUIGrid() {
			var gridPros = {
				// Row번호 표시 여부
				showRowNumColum : true,
				rowIdField : "mem_holiday_seq",
			};
	
			var columnLayout = [
				{
					headerText: "신청일자",
				    dataField: "apply_date",
				    width : "90", 
					minWidth : "45",
					style : "aui-center",
					dataType : "date",
					formatString : "yy-mm-dd",
				},
				{
					headerText : "종류",
					dataField : "holiday_type_name",
					width : "100", 
					minWidth : "45",
					style : "aui-center",
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if (value != "") {
							return "aui-popup"
						};
						return null;
					}
				},
				{
					headerText : "시작일",
					dataField : "start_dt",
					dataType : "date",
					width : "90", 
					minWidth : "45",
					style : "aui-center",
					formatString : "yy-mm-dd"
				},
				{
					headerText : "종료일",
					dataField : "end_dt",
					dataType : "date",
					width : "90", 
					minWidth : "45",
					style : "aui-center",
					formatString : "yy-mm-dd"
				},
				{
					headerText : "일수",
					dataField : "day_cnt",
					width : "70", 
					minWidth : "45",
					style : "aui-center",
// 					formatString : "yyyy-mm-dd"
				},
				{
					headerText : "사유",
					dataField : "content",
					width : "300", 
					minWidth : "45",
					style : "aui-left"
				},
				{
					headerText : "결재",
					dataField : "path_appr_job_status_name",
					width : "380", 
					minWidth : "45",
					style : "aui-left"
				},
				{
					headerText : "상태",
					dataField : "appr_proc_status_name",
					width : "100", 
					minWidth : "45",
					style : "aui-center"
				}
			];
	
			// 실제로 #grid_wrap에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, []);
	
			// 클릭 시 팝업페이지 호출
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == "holiday_type_name" && event.item.holiday_type_name != "") {
					var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=760, left=0, top=0";
					var param = {
						"mem_holiday_seq" : event.item.mem_holiday_seq,
					}
					$M.goNextPage("/mmyy/mmyy0106p02", $M.toGetParam(param), {popupStatus : poppupOption});
				};
	
			});
		}
	</script>
</head>
<body style="background : #fff">
	<form id="main_form" name="main_form">
		<input type="hidden" class="form-control" id="login_mem_no"   name="login_mem_no"   readonly="readonly" value="${SecureUser.mem_no}">
		<input type="hidden" class="form-control" id="s_org_code"   name="s_org_code"   readonly="readonly" value="${SecureUser.org_code}">
		<div class="layout-box">
		<!-- contents 전체 영역 -->
			<div class="content-wrap">
				<div class="content-box">
			<!-- 메인 타이틀 -->
<!-- 					<div class="main-title"> -->
<%-- 						<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/> --%>
<!-- 					</div> -->
			<!-- /메인 타이틀 -->
					<div class="contents">
			<!-- 기본 -->					
						<div class="search-wrap mt10">
							<table class="table">
								<colgroup>
									<col width="60px">
									<col width="260px">
									<col width="60px">
									<col width="100px">
									<col width="60px">
									<col width="100px">
									<col width="1px">
									<col width="100px">
								</colgroup>
								<tbody>
								<tr>
									<th>신청일자</th>
									<td>
										<div class="form-row inline-pd ">
			                            	<div class="col-5">
			                                	<div class="input-group">
			                                    	<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="시작일" value="" >
			                                    </div>
			                                </div>
			                                <div class="col-auto">~</div>
			                                <div class="col-5">
			                                	<div class="input-group">
			                                    	<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="종료일" value="${inputParam.s_current_dt}">
			                                    </div>
		                               	  	</div>
	                              		</div>
<!-- 	                              	<th>작성자</th> -->
<!-- 									<td> -->
<!-- 										<select class="form-control" id="s_mem_no" name="s_mem_no" alt="직원번호"> -->
<!-- 											<option value="">- 전체 -</option> -->
<%-- 											<c:forEach items="${apprMemList}" var="item"> --%>
<%-- 													<option value="${item.mem_no}" ${item.mem_no == SecureUser.mem_no ? 'selected' : '' }> --%>
<%-- 													${item.mem_name} --%>
<!-- 												</option> -->
<%-- 											</c:forEach>	 --%>
<!-- 										</select> -->
<!-- 									</td> -->

									<%-- 22.11.15 Q&A 15065 휴가종류 검색조건 추가 --%>
									<th>휴가종류</th>
									<td>
										<select class="form-control width100px" id="s_holiday_type_cd" name="s_holiday_type_cd" alt="휴가종류">
											<option value="">- 전체 -</option>
											<c:forEach items="${codeMap['HOLIDAY_TYPE']}" var="item">
												<option value="${item.code_value}" >${item.code_name}</option>
											</c:forEach>
										</select>
									</td>
									<th>상태구분</th>
									<td>
										<select class="form-control width100px" id="s_appr_proc_status_cd" name="s_appr_proc_status_cd" alt="결재선 상태구분">
											<option value="">- 전체 -</option>
											<c:forEach items="${codeMap['APPR_PROC_STATUS']}" var="item">
												<c:if test="${item.code_value ne '06'}">
												<option value="${item.code_value}" ${(SecureUser.appr_auth_yn == "Y" && item.code_value == "03") ? 'selected' : item.code_value == "0" ? 'selected' : '' }>${item.code_name}</option>
												</c:if>
											</c:forEach>
										</select>
									</td>
									<th></th>
									<td>
										<div class="form-check form-check-inline">
										<input class="form-check-input" type="checkbox" id="s_my_yn"  name="s_my_yn" value="Y">
										<label class="form-check-input" for="s_my_yn">본인 휴가만</label>
									</div>
									</td>
									<td>
										<div class="left text-warning">
											<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
				                    	</div>
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
								</div>
							</div>
						</div>
			<!-- /그리드 타이틀, 컨트롤 영역 -->					
						<div id="auiGrid" style="margin-top: 5px; height: 500px;"></div>
			<!-- 그리드 서머리, 컨트롤 영역 -->
						<div class="btn-group mt5">
							<div class="left">
								총 <strong class="text-primary" id="total_cnt">0</strong>건
							</div>
						</div>
						<!-- 휴가사용현황-->
						<div class="title-wrap mt10">
							<h4 id="currYear"><b>${SecureUser.kor_name}</b>님 ${inputParam.s_current_year}년 휴가사용현황</h4>
						</div>
						<table class="table-border mt5">
							<colgroup>
								<col width="8.3333%">
								<col width="8.3333%">
								<col width="8.3333%">
								<col width="8.3333%">
								<col width="8.3333%">
								<col width="8.3333%">
								<col width="8.3333%">
								<col width="8.3333%">
								<col width="8.3333%">
								<col width="8.3333%">
								<col width="8.3333%">
								<col width="8.3333%">
							</colgroup>
							<thead>
							<tr>
								<th>국내출장</th>
								<th>국외출장</th>
								<th>종일휴가</th>
								<th>오전휴가</th>
								<th>오후휴가</th>
								<th>공가</th>
								<th>특별휴가</th>
								<th>무급휴가</th>
								<th>연간휴가일수</th>
								<th>연간사용일수</th>
								<th>미결신청일수</th>
								<th>잔여휴가일수</th>
							</tr>
							</thead>
							<tbody>
							<tr>
								<td class="text-center" id="days1">${memHoliday.days1}</td>
								<td class="text-center" id="days2">${memHoliday.days2}</td>
								<td class="text-center" id="days3">${memHoliday.days3}</td>
								<td class="text-center" id="days4">${memHoliday.days4}</td>
								<td class="text-center" id="days5">${memHoliday.days5}</td>
								<td class="text-center" id="days6">${memHoliday.days6}</td>
								<td class="text-center" id="days7">${memHoliday.days7}</td>
								<td class="text-center" id="days8">${memHoliday.days8}</td>
								<td class="text-center" id="issue_cnt">${memHoliday.issue_cnt}</td>
								<td class="text-center" id="total_use_day_cnt">${memHoliday.total_use_day_cnt}</td>
								<td class="text-center" id="mi_proc_days">${memHoliday.mi_proc_days}</td>
								<td class="text-center" id="remainder_day_cnt">${memHoliday.remainder_day_cnt}</td>	
							</tr>
							</tbody>
						</table>
						<div class="btn-group mt5">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
							</div>
						</div>

						<!-- /휴가사용현황 -->
						<!-- /그리드 서머리, 컨트롤 영역 -->
					</div>
				</div>
<%-- 					<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>			 --%>
			</div>
		<!-- /contents 전체 영역 -->	
		</div>	
	</form>
</body>
</html>