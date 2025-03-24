<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 기준정보 > 근무결산월관리 > null > null
-- 작성자 : 손광진
-- 최초 작성일 : 2020-03-11 15:00:43
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function() {
			createAUIGrid();
			goInitSearch();	// 초기화면 호출 시 현재년도로 검색
		});
		
		// 초기화면 화면 검색
		function goInitSearch() {
			$M.setValue("s_accounts_year", $M.getCurrentDate('yyyy'));
			goSearch();
		}
		
		//엑셀다운로드
		function fnDownloadExcel() {
			var accounts_year = $M.getValue("s_accounts_year");
			fnExportExcel(auiGrid, accounts_year + "년 결산월관리", "");
		}
		
		// 그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "accounts_ym",
				showRowNumColumn : true,
				showStateColumn : true,
				editable : true,
				showFooter : true,
				footerPosition : "top",
				fillColumnSizeMode : false
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
					headerText: "결산년도",
				    dataField: "accounts_year",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
				    	return item["accounts_year"] + "년";
					},
				    dataType : "date",   
					width : "20%",
					editable : false,
					style : "aui-center"
				},
				{
				    headerText: "결산월",
				    dataField: "accounts_month",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
				    	return item["accounts_month"] + "월";
					},
					width : "20%",
					editable : false,
					style : "aui-center"
				},
				{
					headerText : "시작일", 
					dataField : "mon_st_dt", 
					dataType : "date",   
					width : "20%",
					style : "aui-center aui-editable",
					dataInputString : "yyyymmdd",
					formatString : "yyyy-mm-dd",
					editRenderer : {
						type : "JQCalendarRenderer", // datepicker 달력 렌더러 사용
						defaultFormat : "yyyymmdd", // 원래 데이터 날짜 포맷과 일치 시키세요. (기본값: "yyyy/mm/dd")
						onlyCalendar : false, // 사용자 입력 불가, 즉 달력으로만 날짜입력 ( 기본값: true )
						maxlength : 8,
						onlyNumeric : true, // 숫자만
						validator : function(oldValue, newValue, rowItem) { // 에디팅 유효성 검사
							return fnCheckDate(oldValue, newValue, rowItem);
						},
						showEditorBtnOver : true
					},
					editable : true
				},
				{
					headerText : "종료일", 
					dataField : "mon_ed_dt", 
					dataType : "date",   
					width : "20%",
					style : "aui-center aui-editable",
					dataInputString : "yyyymmdd",
					formatString : "yyyy-mm-dd",
					editRenderer : {
						type : "JQCalendarRenderer", // datepicker 달력 렌더러 사용
						defaultFormat : "yyyymmdd", // 원래 데이터 날짜 포맷과 일치 시키세요. (기본값: "yyyy/mm/dd")
						onlyCalendar : false, // 사용자 입력 불가, 즉 달력으로만 날짜입력 ( 기본값: true )
						maxlength : 8,
						onlyNumeric : true, // 숫자만
						validator : function(oldValue, newValue, rowItem) { // 에디팅 유효성 검사
							return fnCheckDate(oldValue, newValue, rowItem);
						},
						showEditorBtnOver : true
					},
					editable : true
				},
				{
				    headerText: "월 근무일수",
				    dataField: "work_day",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
				    	return item["work_day"] + "일";
					},
					editable : false, 
					style : "aui-center"
				},
				{
					headerText: "결산년월",
				    dataField: "accounts_ym",
					style : "aui-center",
					editable : false,
					visible : false
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);

			// 푸터 설정
			var footerLayout = [
				{
					dataField : "work_day",
					positionField : "work_day",
					operation : "SUM",
					style : "aui-center aui-footer",
					labelFunction : function(value, columnValues, footerValues) {
						var total_cnt = $M.getValue("work_total_cnt");
						console.log(total_cnt + "/" + value);
						var rest_cnt = total_cnt - value;	// 잔여일자 = 전체근무일수(년) - 월 근무일수 합계
						return "합산일자 : " + AUIGrid.formatNumber(value) + "일 &nbsp;&nbsp; | &nbsp;&nbsp; 잔여일자 : " + AUIGrid.formatNumber(rest_cnt) + "일";
					}
				}
			];
			// 푸터 레이아웃 세팅
			AUIGrid.setFooter(auiGrid, footerLayout);
		}
		
		// 해당 결산년도의 결산월 목록 검색
		function goSearch() {
			
			var param = {
				s_accounts_year : $M.getValue("s_accounts_year")
			};
			
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$("#work_year_cnt").html("전체근무일수 : " + result.work_cnt[0].year_work_cnt + "일");
						$("#work_avg_month_cnt").html("월 평균 근무일수 : " + result.work_cnt[0].work_mon_avg_cnt  + "일");
						$M.setValue("work_total_cnt", result.work_cnt[0].year_work_cnt ); // 전체 근무일수					
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
					};
				}
			);
		}
		
		// 결산달력 저장 및 수정
		function goSave() {
			
			if (fnChangeGridDataCnt(auiGrid) == 0){
				alert("변경된 값이 없습니다.");
				return false;
			};
			
			// 화면에 보여지는 그리드 데이터 목록
			var gridAllList = AUIGrid.getGridData(auiGrid);

			var accounts_ym = [];	// 결산년월
			var mon_st_dt 	= [];	// 시작일
			var mon_ed_dt 	= [];	// 종료일

			for (var i = 0; i < gridAllList.length; i++) {
				// 시작일 종료일 둘중 하나라도 값이 안들어가면 저장X
				if(gridAllList[i].mon_st_dt != "" && gridAllList[i].mon_ed_dt != "") {
					accounts_ym.push(gridAllList[i].accounts_ym);
					mon_st_dt.push(gridAllList[i].mon_st_dt);
					mon_ed_dt.push(gridAllList[i].mon_ed_dt);
					console.log(mon_st_dt[i] + " / " + mon_ed_dt[i] + " / " + accounts_ym[i]);
				};
				
				// 시작일 입력후 종료일 미입력시
				if(gridAllList[i].mon_st_dt != "" && gridAllList[i].mon_ed_dt == "") {
					alert(gridAllList[i].accounts_month + "월 종료일을 입력하세요.");
					return;
				};
			};
			
			var param = {
				"accounts_ym_str" 	: $M.getArrStr(accounts_ym),
				"mon_st_dt_str" 	: $M.getArrStr(mon_st_dt),
				"mon_ed_dt_str" 	: $M.getArrStr(mon_ed_dt),
				"accounts_type_cd"  : "WORK"
			};
			
			console.log(param);
			// var frm = document.main_form;
			// frm = $M.toValueForm(frm);

			$M.goNextPageAjaxSave(this_page + "/save", $M.toGetParam(param), {method : "POST"},
				function(result) {
		    		if(result.success) {
		    			goSearch();
					};
				}
			); 
		}
		
	</script>
</head>
<body>
	<form id="main_form" name="main_form">
		<input type="hidden" class="form-control" id="work_total_cnt"   name="work_total_cnt"   readonly="readonly" value="">
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
								<col width="60px">
								<col width="80px">
								<col width="*">
							</colgroup>
							<tbody>
								<tr>
									<th>결산년도</th>
									<td>
										<select class="form-control" id="s_accounts_year" name="s_accounts_year">
											<c:forEach var="i" begin="${inputParam.s_current_year - 5}" end="${inputParam.s_current_year + 5}" step="1">
												<option value="${i}" <c:if test="${i==inputParam.s_year}">selected</c:if>>${i}년</option>
											</c:forEach>
										</select>
									</td>
									<td class="">
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
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
							<div class="right">
								<span class="text-warning" id="work_year_cnt">전체근무일수 : 0일</span>
								<span class="ver-line text-warning pr10" id="work_avg_month_cnt">월 평균 근무일수 : 0일</span>
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->					

					<div id="auiGrid" style="margin-top: 5px; height: 370px;"></div>

<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">0</strong>건
						</div>		
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>				
					</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
				</div>
						
			</div>		
		</div>
<!-- /contents 전체 영역 -->	
		</div>	
	</form>
</body>
</html>