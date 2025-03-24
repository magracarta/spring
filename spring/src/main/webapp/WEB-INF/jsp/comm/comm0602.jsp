<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 근무관리 > 부서근로시간정산표(관리) > null > null
-- 작성자 : 성현우
-- 최초 작성일 : 2020-03-27 09:24:19
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var auiGrid;
		var memNoMap = ${memNoMap};
		$(document).ready(function() {
			fnInit();
			createAUIGrid();
		});

		function goSearch() {
			var sYear = $M.getValue("s_year");
			var sMon = $M.getValue("s_mon");

			if (sMon.length == 1) {
				sMon = "0" + sMon;
			}
			var sYearMon = sYear + sMon;
			$M.setValue("s_year_mon", $M.dateFormat($M.toDate(sYearMon), 'yyyyMM'));

			var param = {
				"s_org_code": $M.getValue("s_org_code"),
				"s_mem_no": $M.getValue("s_mem_no"),
				"s_year_mon": $M.getValue("s_year_mon")
			};

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: 'GET'},
					function (result) {
						if (result.success) {
							AUIGrid.setGridData(auiGrid, result.list);
							$("#total_cnt").html(result.total_cnt);

							// 결산일자, 기준근무일수, 근무시간 Setting
							$("#mon_st_dt").text(result.accountsYmMap.mon_st_dt);
							$("#mon_ed_dt").text(result.accountsYmMap.mon_ed_dt);
							$("#base_work_hours").text(result.accountsYmMap.base_work_hour);
							$("#work_day_cnt").text(result.accountsYmMap.work_day_cnt);
						}
					}
			)
		}

		// 엑셀 다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "부서근로시간정산표(관리)");
		}

		// 부서 선택 시 직원 리스트
		function goMemNoListChange() {
			var orgCode = $M.getValue("s_org_code");
			// select box 옵션 전체 삭제
			$("#s_mem_no option").remove();
			// select box option 추가
			$("#s_mem_no").append(new Option('- 전체 -', ""));

			if(memNoMap.hasOwnProperty(orgCode)) {
				var memNoList = memNoMap[orgCode];
				for(item in memNoList) {
					$("#s_mem_no").append(new Option(memNoList[item].mem_name, memNoList[item].mem_no));
				}
			}
		}

		// 로그인 된 사용자 정보
		function fnInit() {
			var orgCode = ${SecureUser.org_code};
			var memNo = '${SecureUser.mem_no}';
			$("#s_mem_no option").remove();
			$("#s_mem_no").append(new Option('- 전체 -', ""));
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

			// 결산일자, 기준근무일수, 근무시간 Setting
			$("#mon_st_dt").text("${accountsYmMap.mon_st_dt}");
			$("#mon_ed_dt").text("${accountsYmMap.mon_ed_dt}");
			$("#base_work_hours").text("${accountsYmMap.base_work_hour}");
			$("#work_day_cnt").text("${accountsYmMap.work_day_cnt}");
		}
		
		// 그리드 생성
		function createAUIGrid() {
			var gridPros = {
				showRowNumColum: true
			};

			var columnLayout = [
				{
					headerText : "년월",
					dataField : "work_mon",
					dataType : "date",
					formatString : "yyyy-mm",
					width : "6%"
				},
				{
					headerText : "부서명",
					dataField : "org_name",
					width : "6%"
				},
				{
					headerText : "사원",
					dataField : "mem_name",
					width : "6%"
				},
				{
					headerText : "근무기간",
					dataField : "term",
					width : "12%"
				},
				{
					headerText : "근무일수",
					dataField : "work_day",
					width : "6%"
				},
				{
					headerText : "편성시간",
					dataField : "plan_work_time",
					width : "6%"
				},
				{
					headerText : "월 근로시간",
					dataField : "work_time",
					width : "6%"
				},
				{
					headerText : "연장근로일",
					dataField : "add_work_day",
					style : "aui-center aui-popup",
					width : "6%"
				},
				{
					headerText : "월 신청 연장 시간",
					dataField : "add_work_time",
					width : "6%"
				},
				{
					headerText : "월 인정 연장 시간",
					dataField : "add_work_allow_time",
					width : "8%"
				},
				{
					headerText : "조정",
					dataField : "adjust_time",
					width : "6%"
				},
				{
					headerText : "사유",
					dataField : "adjust_remark",
					style : "aui-left",
					width : "26%"
				},
				{
					headerTest : "사원코드",
					dataField : "mem_no",
					visible : false
				},
				{
					headerTest : "부서코드",
					dataField : "org_code",
					visible : false
				}
			];

			// 실제로 #grid_wrap에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);

			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, []);

			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == 'add_work_day') {

					var param = {
						"s_work_mon" : event.item.work_mon,
						"s_org_code" : event.item.org_code,
						"s_mem_no" : event.item.mem_no,
						"s_org_name" : event.item.org_name,
						"s_mem_name" : event.item.mem_name
					};

					var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=430, left=0, top=0";
					$M.goNextPage('/comm/comm0602p01', $M.toGetParam(param), {popupStatus : poppupOption});
				}
			});
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
					<table class="table table-fixed">
						<colgroup>
							<col width="65px">
							<col width="150px">
							<col width="55px">
							<col width="230px">
							<col width="">
						</colgroup>
						<tbody>
						<tr>
							<th>근무년월</th>
							<td>
								<div class="form-row inline-pd">
									<div class="col-7">
										<select class="form-control" id="s_year" name="s_year">
											<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
												<option value="${i}" <c:if test="${i == inputParam.s_year}">selected</c:if>>${i}년</option>
											</c:forEach>
										</select>
									</div>
									<div class="col-5">
										<select class="form-control" id="s_mon" name="s_mon">
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
												<option value="${item.org_code}" <c:if test="${SecureUser.org_code == item.org_code}">selected</c:if>>${item.org_name}</option>
											</c:forEach>
										</select>
									</div>
									<div class="col-7">
										<select class="form-control" id="s_mem_no", name="s_mem_no">
										</select>
									</div>
								</div>
							</td>
							<td>
								<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch()">조회</button>
							</td>
							<td class="text-right text-warning">
								<span style="font-weight: bold">월 근로 시간은 근무 관리에 [총 근무 시간 + 월 인정 연장 시간] 으로 산정됩니다.</span><br>
								결산일자 : <span id="mon_st_dt"></span> ~ <span id="mon_ed_dt"></span>
								<br>기준근무일수 : <span id="work_day_cnt"></span>일 || 기준근무시간 : <span id="base_work_hours"></span>시간
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
				<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
	<!-- 그리드 서머리, 컨트롤 영역 -->
				<div class="btn-group mt5">
					<div class="left">
						총 <strong class="text-primary" id="total_cnt">0</strong>건
					</div>						
				</div>
	<!-- /그리드 서머리, 컨트롤 영역 -->
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