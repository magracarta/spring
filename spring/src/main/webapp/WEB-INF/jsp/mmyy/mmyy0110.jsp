<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 부서 별 월 예정사항 > null > null
-- 작성자 : 성현우
-- 최초 작성일 : 2021-04-09 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var auiGrid;
		$(document).mouseup(function (e) {
			var container = $(".dev_search_dt_type_cd_str_div");
			if (!container.is(e.target) && container.has(e.target).length === 0) {
				if (container.is(":visible")) {
					container.toggleClass('dpn');
				}
			}
		});

		$(document).ready(function () {
			// AUIGrid 생성
			createAUIGrid();
			fnInit();
			fnSearchDateTypeCode();

			goSearch();
		});

		function fnInit() {
			var st = "${searchDtMap.s_start_dt}";
			var ed = "${searchDtMap.s_end_dt}";

			var startYear = $M.dateFormat(st, "yyyy");
			var startMon = $M.toNum($M.dateFormat(st, "MM"));
			$M.setValue("s_start_year", startYear);
			$M.setValue("s_start_mon", startMon)

			var endYear = $M.dateFormat(ed, "yyyy");
			var endMon = $M.toNum($M.dateFormat(ed, "MM"));
			$M.setValue("s_end_year", endYear);
			$M.setValue("s_end_mon", endMon);

			// 본사가 아닌 경우 본인 센터만
			var orgType = "${SecureUser.org_type}";
			if ('${page.fnc.F02004_001}' != 'Y') {
				$("#s_org_code").prop("disabled", true);
			}
		}

		function fnSearchDateTypeCode() {
			$('.dev_popover_activator').click(function (event) {
				var container = $('.dev_search_dt_type_cd_str_div');
				container.toggleClass('dpn');
			});

			$('input[type=radio][name=_s_search_dt_type_cd]').click(function (event) {
				var today = "${inputParam.s_current_dt}";
				var st = today;
				var ed = $M.getValue("${s_end_dt}");
				if (ed == "") {
					ed = today;
				}
				// 당일 기준일 경우, 당일 기준이 아닌 끝날자 기준일 경우 주석처리
				if (event.ctrlKey == false) {
					ed = today;
				}

				var edDate = $M.toDate(ed);

				var s_val = this.value;
				var dt_cnt = $M.toNum(s_val.substr(0, 1));
				var dt_type = s_val.substr(1, 2);

				switch (s_val) {
					case '00' :
						st = "";
						ed = "";
						break;
					case '0D' :
						st = ed;
						break;
					case '0M' :
						st = ed.substr(0, 6) || '01';
						break;
					default :
						switch (dt_type) {
							case 'W' :
								st = $M.addDates(edDate, -7 * dt_cnt);
								break;
							case 'M' :
								st = $M.addMonths(edDate, -1 * dt_cnt);
								break;
							case 'Y' :
								st = $M.addMonths(edDate, -12 * dt_cnt);
								break;
							default :
								st = ed.substr(0, 6) || '01';
								break;
						}
						break;
				}

				var startYear = $M.dateFormat(st, "yyyy");
				var startMon = $M.toNum($M.dateFormat(st, "MM"));
				$M.setValue("s_start_year", startYear);
				$M.setValue("s_start_mon", startMon)

				var endYear = $M.dateFormat(ed, "yyyy");
				var endMon = $M.toNum($M.dateFormat(ed, "MM"));
				$M.setValue("s_end_year", endYear);
				$M.setValue("s_end_mon", endMon);

				$M.setValue("s_search_dt_type_cd", this.value);

				$('.dev_search_dt_type_cd_str_div').toggleClass('dpn');

				goSearch();
			});
		}

		// 엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "부서 별 월 예정사항");
		}

		// 월 예정사항 등록
		function goNew() {
			var params = {
			};
			var popupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1600, height=650, left=0, top=0";
			$M.goNextPage("/mmyy/mmyy011001", $M.toGetParam(params), {popupStatus: popupOption});
		}

		// 조회
		function goSearch() {
			var sStartYearMon = fnSetYearMon($M.getValue("s_start_year"), $M.getValue("s_start_mon"));
			var sEndYearMon = fnSetYearMon($M.getValue("s_end_year"), $M.getValue("s_end_mon"));

			var params = {
				"s_start_year_mon": sStartYearMon,
				"s_end_year_mon": sEndYearMon,
				"s_org_code": $M.getValue("s_org_code"),
				"s_write_comp_yn": $M.getValue("s_write_comp_yn"),
				"s_search_dt_type_cd": $M.getValue("s_search_dt_type_cd"),
				"this_page": this_page
			};

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(params), {method: 'GET'},
					function (result) {
						if (result.success) {
							$("#total_cnt").html(result.total_cnt);
							AUIGrid.setGridData(auiGrid, result.list);
						}
					}
			);
		}

		// 날짜 Setting
		function fnSetYearMon(year, mon) {
			return year + (mon.length == 1 ? "0" + mon : mon);
		}

		// 그리드 생성
		function createAUIGrid() {
			var gridPros = {
				// rowIdField 설정
				rowIdField: "_$uid",
				showRowNumColumn: true
			};

			var columnLayout = [
				{
					headerText: "월예정사항번호",
					dataField: "plan_mon_no",
					visible: false
				},
				{
					headerText: "년-월",
					dataField: "plan_mon",
					width: "100",
					minWidth: "90",
					style: "aui-center aui-popup",
					dataType: "date",
					formatString: "yyyy-mm",
				},
				{
					headerText: "부서",
					dataField: "org_name",
					width: "100",
					minWidth: "90",
					style: "aui-center"
				},
				{
					headerText: "전체진행건수",
					dataField: "a_total_cnt",
					width: "100",
					minWidth: "90",
					style: "aui-center",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						return value == "" || value == null || value == 0 ? "" : $M.setComma(value);
					}
				},
				{
					headerText: "전월미결건수",
					dataField: "a_undecided_cnt",
					width: "100",
					minWidth: "90",
					style: "aui-center",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						return value == "" || value == null || value == 0 ? "" : $M.setComma(value);
					}
				},
				{
					headerText: "신규등록건수",
					dataField: "a_01_cnt",
					width: "100",
					minWidth: "90",
					style: "aui-center",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						return value == "" || value == null || value == 0 ? "" : $M.setComma(value);
					}
				},
				{
					headerText: "연장건수",
					dataField: "a_02_cnt",
					width: "100",
					minWidth: "90",
					style: "aui-center",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						return value == "" || value == null || value == 0 ? "" : $M.setComma(value);
					}
				},
				{
					headerText: "상태",
					dataField: "write_comp_name",
					width: "100",
					minWidth: "90",
					style: "aui-center"
				}
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();

			var colSizeList = AUIGrid.getFitColumnSizeList(auiGrid, true);

			// 구해진 칼럼 사이즈를 적용 시킴.
			AUIGrid.setColumnSizeList(auiGrid, colSizeList);

			// 상세팝업
			AUIGrid.bind(auiGrid, "cellClick", function (event) {
				if (event.dataField == "plan_mon") {
					var params = {
						"plan_mon_no": event.item.plan_mon_no
					};
					var popupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1600, height=650, left=0, top=0";
					console.log(popupOption);
					$M.goNextPage('/mmyy/mmyy0110p01', $M.toGetParam(params), {popupTitle : event.item.plan_mon, popupStatus: popupOption});
				}
			});
		}
	</script>
</head>
<body>
<form id="main_form" name="main_form">
	<input type="hidden" id="s_search_dt_type_cd" name="s_search_dt_type_cd" value="${searchDtMap.search_dt_type_cd}"/>
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
						<table class="table">
							<colgroup>
								<col width="65px">
								<col width="300px">
								<col width="40px">
								<col width="100px">
								<col width="50px">
								<col width="100px">
								<col width="*">
							</colgroup>
							<tbody>
							<tr>
								<th>조회년월</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-auto">
											<select class="form-control" id="s_start_year" name="s_start_year">
												<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
													<c:set var="year_option" value="${inputParam.s_current_year - i + 2000}"/>
													<option value="${year_option}" <c:if test="${year_option eq inputParam.s_start_year}">selected</c:if>>${year_option}년</option>
												</c:forEach>
											</select>
										</div>
										<div class="col-auto">
											<select class="form-control" id="s_start_mon" name="s_start_mon">
												<c:forEach var="i" begin="1" end="12" step="1">
													<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i eq inputParam.s_start_mon}">selected</c:if>>${i}월</option>
												</c:forEach>
											</select>
										</div>
										<div class="col-auto">~</div>
										<div class="col-auto">
											<select class="form-control" id="s_end_year" name="s_end_year">
												<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
													<c:set var="year_option" value="${inputParam.s_current_year - i + 2000}"/>
													<option value="${year_option}" <c:if test="${year_option eq inputParam.s_end_year}">selected</c:if>>${year_option}년</option>
												</c:forEach>
											</select>
										</div>
										<div class="col-auto">
											<select class="form-control" id="s_end_mon" name="s_end_mon">
												<c:forEach var="i" begin="1" end="12" step="1">
													<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i eq inputParam.s_end_mon}">selected</c:if>>${i}월</option>
												</c:forEach>
											</select>
										</div>

										<div class="dev_search_dt_type_cd_str_wrap">
											<button type="button" class="ui-datepicker-trigger btn btn-primary-gra dev_popover_activator ml5"><i class="material-iconsmore_horiz text-dark"></i></button>
											<div class="con-info dev_search_dt_type_cd_str_div dpn" title="컨트롤 키를 누른채 클릭하면 끝 날짜 기준으로 설정됩니다." style="transform: translateX(0) translateY(0);">
												<c:forEach items="${codeMap['SEARCH_DT_TYPE']}" var="item">
													<c:if test="${fn:contains(searchDtMap.search_dt_type_cd_str, item.code_value)}">
														<label><input type="radio" name="_s_search_dt_type_cd" value="${item.code_value }" ${item.code_value eq searchDtMap.search_dt_type_cd ? 'checked' : '' }>${item.code_name }</label>
													</c:if>
												</c:forEach>
											</div>
										</div>
									</div>
								</td>
								<th>부서</th>
								<td>
									<select class="form-control" id="s_org_code" name="s_org_code">
										<option value="">- 전체 -</option>
										<c:forEach items="${orgList}" var="item">
											<option value="${item.org_code}" <c:if test="${item.org_code eq SecureUser.org_code}">selected="selected"</c:if> >${item.org_name}</option>
										</c:forEach>
									</select>
								</td>
								<th>상태</th>
								<td>
									<select class="form-control width80px" id="s_write_comp_yn" name="s_write_comp_yn">
										<option value="">- 전체 -</option>
										<option value="N">작성중</option>
										<option value="Y">작성완료</option>
									</select>
								</td>
								<td>
									<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
								</td>
							</tr>
							</tbody>
						</table>
					</div>
					<!-- /검색영역 -->
					<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<h4>조회결과</h4>
						<div class="btn-group">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
					<!-- /그리드 타이틀, 컨트롤 영역 -->
					<div id="auiGrid" style="margin-top: 5px; height: 450px;"></div>
					<div class="btn-group mt5">
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">0</strong>건
						</div>
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
					</div>
				</div>
			</div>
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
		</div>
		<!-- /contents 전체 영역 -->
	</div>
</form>
</body>
</html>