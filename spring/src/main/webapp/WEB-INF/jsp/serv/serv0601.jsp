<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 고품관리 > 고품관리 > null > null
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

			var startYear =  $M.dateFormat(st, "yyyy");
			var startMon = $M.toNum($M.dateFormat(st, "MM"));
			$M.setValue("s_start_year", startYear);
			$M.setValue("s_start_mon", startMon)

			var endYear = $M.dateFormat(ed, "yyyy");
			var endMon = $M.toNum($M.dateFormat(ed, "MM"));
			$M.setValue("s_end_year", endYear);
			$M.setValue("s_end_mon", endMon);

			// 본사가 아닌 경우 본인 센터만
			<%--var orgType = "${SecureUser.org_type}";--%>

			// if(orgType != "BASE") {
			if(${page.fnc.F01995_001 ne 'Y'}) {
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

		// 조회
		function goSearch() {

			var sStartYearMon = fnSetDate($M.getValue("s_start_year"), $M.getValue("s_start_mon"));
			var sEndYearMon = fnSetDate($M.getValue("s_end_year"), $M.getValue("s_end_mon"));

			var param = {
				"s_start_year_mon" : sStartYearMon,
				"s_end_year_mon" : sEndYearMon,
				"s_org_code" : $M.getValue("s_org_code"),
				"s_appr_proc_status_cd" : $M.getValue("s_appr_proc_status_cd"),
				"s_search_dt_type_cd" : $M.getValue("s_search_dt_type_cd"),
				"this_page" : this_page
			};

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: 'GET'},
					function (result) {
						if (result.success) {
							$("#total_cnt").html(result.total_cnt);
							AUIGrid.setGridData(auiGrid, result.list);
						}
					}
			);
		}

		function fnSetDate(year, mon) {
			if(mon.length == 1) {
				mon = "0" + mon;
			}
			var sYearMon = year + mon;

			return $M.dateFormat($M.toDate(sYearMon), 'yyyyMM');
		}

		// 고품결재등록
		function goNew() {
			var param = {};
			$M.goNextPageAjax(this_page + "/check/partOld", $M.toGetParam(param), {method: 'GET'},
					function (result) {
						if (result.success) {
							if(result.data != undefined) {
								console.log(result.data.part_old_no);
								alert("이미 해당월에 작성한 고품이 존재합니다.");
								var params = {
									"part_old_no": result.data.part_old_no
								};
								var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=400, height=300, left=0, top=0";
								$M.goNextPage('/serv/serv0601p01', $M.toGetParam(params), {popupStatus: popupOption});
							} else {
								$M.goNextPage("/serv/serv060101");
							}
						}
					}
			);
		}

		// 제출현황
		function goCurrSituation() {
			var params = {
				"s_year" : $M.getValue("s_end_year")
			};
			var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=400, height=300, left=0, top=0";
			$M.goNextPage('/serv/serv0601p02', $M.toGetParam(params), {popupStatus: popupOption});
		}

		// 이동이력
		function goMoveHisPopup() {
			var params = {
				"s_start_year" : $M.getValue("s_start_year"),
				"s_start_mon" : $M.getValue("s_start_mon"),
				"s_end_year" : $M.getValue("s_end_yaer"),
				"s_end_mon" : $M.getValue("s_end_mon")
			};

			var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=400, height=300, left=0, top=0";
			$M.goNextPage('/serv/serv0601p03', $M.toGetParam(params), {popupStatus: popupOption});
		}

		// 엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "고품관리");
		}

		// AUIGrid 생성
		function createAUIGrid() {
			var gridPros = {
				// rowIdField 설정
				rowIdField: "_$uid",
				showRowNumColumn: true
			};

			var columnLayout = [
				{
					headerText: "년-월",
					dataField: "part_old_mon",
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
					headerText: "전체고품건수",
					dataField: "a_total_qty",
					width: "100",
					minWidth: "90",
					style: "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						return value == "" || value == null ? 0 : $M.setComma(value);
					}
				},
				{
					headerText: "이동",
					dataField: "a_move_qty",
					width: "100",
					minWidth: "90",
					style: "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						return value == "" || value == null ? 0 : $M.setComma(value);
					}
				},
				{
					headerText: "보관",
					dataField: "a_keep_qty",
					width: "100",
					minWidth: "90",
					style: "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						return value == "" || value == null ? 0 : $M.setComma(value);
					}
				},
				{
					headerText: "폐기",
					dataField: "a_abrogate_qty",
					width: "100",
					minWidth: "90",
					style: "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						return value == "" || value == null ? 0 : $M.setComma(value);
					}
				},
				{
					headerText: "고객회수",
					dataField: "a_recovery_qty",
					width: "100",
					minWidth: "90",
					style: "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						return value == "" || value == null ? 0 : $M.setComma(value);
					}
				},
				{
					headerText: "결재",
					dataField: "path_appr_job_status_name",
					width: "300",
					minWidth: "290",
					style: "aui-left"
				},
				{
					headerText: "상태",
					dataField: "appr_proc_status_name",
					width: "100",
					minWidth: "90",
					style: "aui-center"
				},
				{
					headerText: "부서코드",
					dataField: "org_code",
					visible: false
				},
				{
					headerText: "업무결재번호",
					dataField: "appr_job_seq",
					visible: false
				},
				{
					headerText: "부품고품번호",
					dataField: "part_old_no",
					visible: false
				},
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();

			// 상세팝업
			AUIGrid.bind(auiGrid, "cellClick", function (event) {
				if (event.dataField == "part_old_mon") {
					var params = {
						"part_old_no": event.item.part_old_no
					};
					var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=400, height=300, left=0, top=0";
					$M.goNextPage('/serv/serv0601p01', $M.toGetParam(params), {popupStatus: popupOption});
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
								<col width="45px">
								<col width="100px">
								<col width="45px">
								<col width="80px">
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
									<select class="form-control" name="s_org_code" id="s_org_code">
										<option value="">- 전체 -</option>
										<c:forEach var="list" items="${codeMap['WAREHOUSE']}">
											<option value="${list.code_value}" <c:if test="${list.code_value eq SecureUser.org_code}">selected</c:if> >${list.code_name}</option>
										</c:forEach>
									</select>
								</td>
								<th>상태</th>
								<td>
									<select class="form-control" name="s_appr_proc_status_cd" id="s_appr_proc_status_cd">
										<option value="">- 전체 -</option>
										<c:forEach var="list" items="${codeMap['APPR_PROC_STATUS']}">
											<c:if test="${list.code_value ne '04'}">
												<option value="${list.code_value}" ${(SecureUser.appr_auth_yn == "Y" && list.code_value == "03") ? 'selected' : list.code_value == "0" ? 'selected' : ''}>${list.code_name}</option>
											</c:if>
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
					<div id="auiGrid" style="margin-top: 5px; height: 420px;"></div>
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