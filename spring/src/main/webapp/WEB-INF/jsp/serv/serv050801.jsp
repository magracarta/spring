<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 서비스관리 > Yammar가동현황(SA-R) > null > null
-- 작성자 : 성현우
-- 최초 작성일 : 2021-04-09 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGrid;
		var memMap = ${memMap};
		var dateListJson;

		$(document).mouseup(function(e) {
			var container = $(".dev_search_dt_type_cd_str_div");
			if (!container.is(e.target) && container.has(e.target).length === 0) {
				if (container.is(":visible")) {
					container.toggleClass('dpn');
				}
			}
		});

		$(document).ready(function () {
			// 초기 Setting
			fnInit();
			// AUIGrid 생성
			createAUIGrid();

			goSearch();
		});

		// 초기 Setting
		function fnInit() {
			dateListJson = ${dateList};
			
			console.log("dateListJson : ", dateListJson);

			<%--if("${SecureUser.org_type}" != "BASE") {--%>
			if(${page.fnc.F03102_001 ne 'Y'}) {
				$("#s_org_code").prop("disabled", true);
			}

			fnSettingDate();
			fnSearchDateTypeCode();
			goMemNoListChange();
		}

		// 부서 선택 시 직원 리스트
		function goMemNoListChange() {
			var orgCode = $M.getValue("s_org_code");
			// select box 옵션 전체 삭제
			$("#s_mem_no option").remove();
			// select box option 추가
			$("#s_mem_no").append(new Option('- 전체 -', ""));

			if (memMap.hasOwnProperty(orgCode)) {
				var memList = memMap[orgCode];
				for (item in memList) {
					$("#s_mem_no").append(new Option(memList[item].mem_name, memList[item].mem_no));
				}
			}
		}

		// 월별 평균 가동시간
		function goFirstGraphPopup() {
			var params = {
				"s_start_year_mon": fnSetYearMon($M.getValue("s_start_year"), $M.getValue("s_start_mon")),
				"s_end_year_mon": fnSetYearMon($M.getValue("s_end_year"), $M.getValue("s_end_mon")),
				"s_org_code": $M.getValue("s_org_code"),
				"s_mem_no": $M.getValue("s_mem_no"),
				"search_type" : "MODEL"
			};

			var popupOption = 'scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1000, height=531, left=0, top=0';
			$M.goNextPage('/serv/serv0508p01', $M.toGetParam(params), {popupStatus : popupOption});
		}

		// 모델별 평균 가동시간
		function goSecondGraphPopup() {
			var params = {
				"s_start_year_mon": fnSetYearMon($M.getValue("s_start_year"), $M.getValue("s_start_mon")),
				"s_end_year_mon": fnSetYearMon($M.getValue("s_end_year"), $M.getValue("s_end_mon")),
				"s_org_code": $M.getValue("s_org_code"),
				"s_mem_no": $M.getValue("s_mem_no")
			};

			var popupOption = 'scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1000, height=531, left=0, top=0';
			$M.goNextPage('/serv/serv0508p02', $M.toGetParam(params), {popupStatus : popupOption});
		}

		// 엑셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "Yammar가동현황(SA-R)-모델별");
		}

		// 조회
		function goSearch() {
			var params = {
				"s_start_year_mon": fnSetYearMon($M.getValue("s_start_year"), $M.getValue("s_start_mon")),
				"s_end_year_mon": fnSetYearMon($M.getValue("s_end_year"), $M.getValue("s_end_mon")),
				"s_org_code": $M.getValue("s_org_code"),
				"s_mem_no": $M.getValue("s_mem_no"),
				"s_search_dt_type_cd" : $M.getValue("s_search_dt_type_cd"),
				"this_page" : this_page
			};

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(params), {method: 'GET'},
					function (result) {
						if (result.success) {
							$M.setValue("s_start_year_mon", params.s_start_year_mon);
							$M.setValue("s_end_year_mon", params.s_end_year_mon);
							fnSetGridData(result);
						}
					}
			);
		}

		// Data Setting
		function fnSetGridData(data) {
			destroyGrid();
			dateListJson = data.dateList;
			createAUIGrid();
			AUIGrid.setGridData(auiGrid, data.list);
		}

		// 그리드 초기화
		function destroyGrid() {
			AUIGrid.destroy("#auiGrid");
			auiGrid = null;
		};

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

				console.log(edDate);

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
								st = $M.addMonths(edDate, -11 * dt_cnt);
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

		// 기본 날짜 Setting
		function fnSettingDate() {
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
		}

		// 날짜 Setting
		function fnSetYearMon(year, mon) {
			return year + (mon.length == 1 ? "0" + mon : mon);
		}

		function createAUIGrid() {
			var gridPros = {
				// rowIdField 설정
				rowIdField: "_$uid",
				showFooter: true,
				footerPosition : "top",
				showRowNumColumn: false,
				enableCellMerge: true, // 셀병합 사용여부
			};

			var columnLayout = [
				{
					headerText: "",
					dataField: "model_name",
					cellMerge: true, // 셀 세로병합
					width: "40",
					minWidth: "30",
					renderer: { // 템플릿 렌더러 사용
						type: "TemplateRenderer"
					}
				},
				{
					headerText: "분류",
					dataField: "decal_model",
					width: "100",
					minWidth: "90"
				},
				{
					headerText: "대수현황",
					dataField: "machine_cnt",
					width: "70",
					minWidth: "60",
					style : "aui-right aui-popup",
					headerTooltip : { // 헤더 툴팁 표시 HTML 양식
						show : true,
						tooltipHtml : '<div>검색조건과 상관없이<br>SAR등록 대수현황</div>'
					},
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						return value == "" || value == null || value == 0 ? "" : $M.setComma(value);
					}
				},
				{
					headerText: "누적 총시간",
					dataField: "tot_run_time",
					width: "100",
					minWidth: "90",
					style : "yammar-machine-col",
					headerStyle : "yammar-machine-header",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						return value == "" || value == null || value == 0 ? "" : $M.setComma(value);
					}
				},
				{
					headerText: "월 평균 가동시간",
					dataField: "avg_hour_per_month",
					width: "100",
					minWidth: "90",
					style : "yammar-machine-col",
					headerStyle : "yammar-machine-header",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						return value == "" || value == null || value == 0 ? "" : $M.setComma(value);
					}
				}
			];

			// 월별 평균 가동시간 동적 생성 시작
			var columnObj = {};
			columnObj.headerText = "월별 평균 가동시간";
			columnObj.children = [];
			for(var i=0; i<dateListJson.length; i++) {
				var headerTextName = dateListJson[i].field_name;
				var dataFiledName = "a_" + dateListJson[i].year_mon + "_sum";
				var obj = {
					headerText : headerTextName,
					dataField : dataFiledName,
					width : "70",
					minWidth : "60",
					style : "aui-right",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						return value == "" || value == null || value == 0 ? "" : $M.setComma(value);
					}
				};
				columnObj.children.push(obj);
			}

			columnLayout.push(columnObj);
			// 월별 평균 가동시간 동적 생성 끝

			// 푸터레이아웃
			var footerColumnLayout = [
				{
					labelText: "전체",
					positionField: "model_name"
				},
				{
					labelText: "얀마굴삭기",
					positionField: "decal_model"
				},
				{
					dataField: "machine_cnt",
					positionField: "machine_cnt",
					formatString: "#,##0",
					style: "aui-right aui-footer",
					expFunction : function(columnValues) {
						var sum = 0;
						for (var i = 0; i < columnValues.length; i++) {
						    sum += $M.toNum(columnValues[i]);
						}
						return sum;
					}
				},
				{
					dataField: "tot_run_time",
					positionField: "tot_run_time",
					formatString: "#,##0",
					style : "yammar-machine-col aui-footer",
					expFunction : function(columnValues) {
						var sum = 0;
						for (var i = 0; i < columnValues.length; i++) {
						    sum += $M.toNum(columnValues[i]);
						}
						return sum;
					}
				},
				{
					dataField: "avg_hour_per_month",
					positionField: "avg_hour_per_month",
					formatString: "#,##0.##",
					style : "yammar-machine-col aui-footer",
					expFunction : function(columnValues) {
						var sum = 0;
						for (var i = 0; i < columnValues.length; i++) {
						    sum += $M.toNum(columnValues[i]);
						}
						return $M.toNum(sum / columnValues.length);
					},
				}
			]
			

			for(var i=0; i<dateListJson.length; i++) {
				var dataFiledName = "a_" + dateListJson[i].year_mon + "_sum";
				var obj = {
					dataField : dataFiledName,
					positionField : dataFiledName,
					formatString: "#,##0.##",
					style: "aui-right aui-footer",
					labelFunction : function(value, columnValues, footerValues) {
					      var gridData = AUIGrid.getGridData(auiGrid);
					      var val = 0;
					      
					      for(var j = 0; j < gridData.length; j++) {
					    	  val += $M.toNum(columnValues[j]/ gridData[j].machine_cnt);
					      }
					      return val;
					   
					}
				};
				footerColumnLayout.push(obj);
			}
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.setFooter(auiGrid, footerColumnLayout);
			
			AUIGrid.bind(auiGrid,"cellClick",function(event){
				if(event.dataField == "machine_cnt"){
					var params = {
						"s_start_year_mon": $M.getValue("s_start_year_mon"),
						"s_end_year_mon": $M.getValue("s_end_year_mon"),
						"gubun_type": event.item.decal_model,
						"decal_model": event.item.decal_model,
						"s_org_code" : $M.getValue("s_org_code"),
						"s_mem_no" : $M.getValue("s_mem_no"),
					};
					var popupOption = "";
					$M.goNextPage('/serv/serv0508p04', $M.toGetParam(params), {popupStatus: popupOption});
				}
			});
			
			$("#auiGrid").resize();
		}

	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<input type="hidden" id="s_search_dt_type_cd" name="s_search_dt_type_cd" value="${searchDtMap.search_dt_type_cd}"/>
	<div class="layout-box">
		<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="search-wrap mt10">
				<table class="table">
					<colgroup>
						<col width="65px">
						<col width="320px">
						<col width="40px">
						<col width="80px">
						<col width="60px">
						<col width="120px">
						<col width="*">
					</colgroup>
					<tbody>
					<tr>
						<th>조회년월</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width80px">
									<select class="form-control" id="s_start_year" name="s_start_year">
										<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
											<c:set var="year_option" value="${inputParam.s_current_year - i + 2000}"/>
											<option value="${year_option}" <c:if test="${year_option eq inputParam.s_start_year}">selected</c:if>>${year_option}년</option>
										</c:forEach>
									</select>
								</div>
								<div class="col width60px">
									<select class="form-control" id="s_start_mon" name="s_start_mon">
										<c:forEach var="i" begin="1" end="12" step="1">
											<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i eq inputParam.s_start_mon}">selected</c:if>>${i}월</option>
										</c:forEach>
									</select>
								</div>
								<div class="col width16px text-center">~</div>
								<div class="col width80px">
									<select class="form-control" id="s_end_year" name="s_end_year">
										<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
											<c:set var="year_option" value="${inputParam.s_current_year - i + 2000}"/>
											<option value="${year_option}" <c:if test="${year_option eq inputParam.s_end_year}">selected</c:if>>${year_option}년</option>
										</c:forEach>
									</select>
								</div>
								<div class="col width60px">
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
												<label><input type="radio" name="_s_search_dt_type_cd" value="${item.code_value }" ${item.code_value eq searchDtMap.search_dt_type_cd ? 'checked' : '' }>${item.code_name}</label>
											</c:if>
										</c:forEach>
									</div>
								</div>
							</div>
						</td>
						<th>센터</th>
						<td>
							<select class="form-control" name="s_org_code" id="s_org_code" onchange="javascript:goMemNoListChange();">
								<option value="">- 전체 -</option>
								<c:forEach var="list" items="${codeMap['WAREHOUSE']}">
									<c:if test="${list.code_value ne '5010' and list.code_value ne '6000' and list.code_v2 eq 'Y'}">
										<option value="${list.code_value}" <c:if test="${list.code_value eq inputParam.s_org_code}">selected</c:if> >${list.code_name}</option>
									</c:if>
								</c:forEach>
							</select>
						</td>
						<th>담당자</th>
						<td>
							<select class="form-control" id="s_mem_no" , name="s_mem_no">
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
			<div id="auiGrid" style="margin-top: 5px; height: 500px;"></div>
		</div>
		<!-- /contents 전체 영역 -->
	</div>
</form>
</body>
</html>