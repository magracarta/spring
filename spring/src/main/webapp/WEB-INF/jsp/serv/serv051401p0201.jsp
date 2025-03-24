<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 서비스관리 > 서비스업무평가-센터 > 실적분석 > 그래프보기
-- 작성자 : 정선경
-- 최초 작성일 : 2023-12-07 11:33:24
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript" src="/static/Chartjs/Chart.min.js"></script>
	<script type="text/javascript" src="/static/Chartjs/chartjs-plugin-datalabels.js"></script>
	<script type="text/javascript">

		var chartObj1; // 차트 오브젝트 1
		var chartObj2; // 차트 오브젝트 2
		var minValue;
		var maxValue;
		var colors = ["#a83232", "#a87332", "#a8a432", "#65a832", "#32a889", "#326da8", "#4a32a8", "#9232a8", "#a83285", "#a83240"];
		var labels = ["12", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", ""];
		var labelsKey = ["12", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", ""];

		$(document).ready(function() {
			goSearch();
		});

		function goSearch() {
			if (!jQuery.isEmptyObject(chartObj1)) {
				chartObj1.destroy();
			}
			if (!jQuery.isEmptyObject(chartObj2)) {
				chartObj2.destroy();
			}
			var param = {
				"s_graph_gubun": $M.getValue("s_graph_gubun"),
				"s_org_code_1" : $M.getValue("s_org_code_1"),
				"s_org_code_2" : $M.getValue("s_org_code_2"),
				"s_end_year" : "${inputParam.s_end_year}"
			};

			$M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'get'},
					function(result) {
						if(result.success) {
							minValue = result.minValue;
							maxValue = result.maxValue;

							var listData1 = result.listData1;
							fnCreateChart(1, chartObj1, listData1);

							if ($M.getValue("s_org_code_2") != "") {
								var listData2 = result.listData2;
								$("#chartObj2").removeClass("dpn");
								fnCreateChart(2, chartObj2, listData2);
							} else {
								$("#chartObj2").addClass("dpn");
							}
						}
					}
			);
		}

		function fnCreateChart(idx, chartObj, listData) {
			// 연도별 그룹핑
			var groupBy = function(xs, key) {
				return xs.reduce(function(rv, x) {
					(rv[x[key]] = rv[x[key]] || []).push(x);
					return rv;
				}, {});
			};

			var dataListGroup = groupBy(listData, 'yyyy');

			var chartData = {
				type: 'line',
				data: {
					labels: labels,
					datasets: []
				},
				options: {
					plugins: {
						// Change options for ALL labels of THIS CHART
						datalabels: {
							backgroundColor: function(context) {
								return context.dataset.backgroundColor;
							},
							borderRadius: 4,
							color: 'black',
							font: {
								// weight: 'bold'
							},
							formatter: Math.round,
							padding: 2
						}
					},
					// 툴팁을 모두 보이게
					tooltips: {
						mode: 'label'
					},
					hover: {
						animationDuration: 0
					},
					legend: {
						position: "bottom",
						onHover: function (e, datasetIndex) {
							e.target.style.cursor = 'pointer';
						},
						onLeave: function (e) {
							e.target.style.cursor = 'default'
						}
					},
					scales: {
						yAxes: [{
							ticks: {
								beginAtZero: false,
								callback: function (value, index, values) {
									return value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
								},
								suggestedMin: minValue,
								suggestedMax: maxValue,
								padding: 10,
							}
						}],
						xAxes: [{
							ticks: {
								padding: 10,
							}
						}]
					},
				}
			}

			var yearCnt = 0;
			for(var year in dataListGroup) {
				var dataArray = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
				var item = dataListGroup[year];
				var itemLength = item.length;
				for(var i=0; i<itemLength; ++i) {
					var row = item[i];
					for(var prop in row) {
						if(prop == "yyyymm") {
							var month = row[prop].substr(4);
							var index = labelsKey.indexOf(month);
							dataArray[index] += $M.toNum(row[$M.getValue("s_graph_gubun")]);
						}
					}
				}

				chartData.data.datasets.push({
					type : "line",
					label: item[0].yyyy,
					borderColor: colors[yearCnt],
					pointBackgroundColor : colors[yearCnt],
					borderWidth: 2,
					data : dataArray,
					tension : 0,
					fill: false,
					datalabels: {
						// align: 'top',
						align: function(ctx) {
							var idx = ctx.dataIndex;
							var val = ctx.dataset.data[idx];
							var datasets = ctx.chart.data.datasets;
							var min, max, i, ilen, ival;

							min = max = val;

							for (i = 0, ilen = datasets.length; i < ilen; ++i) {
								if (i === ctx.datasetIndex) {
									continue;
								}

								ival = datasets[i].data[idx];
								min = Math.min(min, ival);
								max = Math.max(max, ival);

								if (val > min && val < max) {
									return 'center';
								}
							}

							return val <= min ? 'start' : 'end';
						},
						anchor: 'top',
						formatter: function(value) {
							return value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
						},
					}
				});

				yearCnt++;
			}
			$("#chartDiv"+idx).html('<canvas id="chartObj'+ idx +'"></canvas>');

			// 캔버스 context
			var ctx = $("#chartObj"+idx).get(0).getContext('2d');

			// 이미 생성된 차트가 있으면 삭제
			if (!jQuery.isEmptyObject(chartObj)) {
				chartObj.destroy();
			}

			// 차트 그리기
			chartObj = new Chart(ctx, chartData);
		}

		function fnClose() {
			window.close();
		}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<!-- 팝업 -->
	<div class="popup-wrap width-100per">
		<!-- 타이틀영역 -->
		<div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
		</div>
		<!-- /타이틀영역 -->
		<div class="content-wrap">
			<div>
				<select class="form-control width200px" id="s_graph_gubun" name="s_graph_gubun" onchange="javascript:goSearch();">
					<option value="as_repair_tot">유상+무상 정비건수 변화추이</option>
					<option value="cost_profit_amt">유상 정비순익 변화추이</option>
					<option value="total_profit_amt">최종 순익 변화추이</option>
					<option value="rental_profit_amt">렌탈 순익 변화추이</option>
					<option value="tot_valid_hour">유효활동시간</option>
					<option value="free_profit_amt">무상정비수익</option>
					<option value="part_profit_amt">부품판매</option>
				</select>
			</div>

			<div class="search-wrap mt10">
				<div class="boxing bd0 pd0 vertical-line mt5">
                    <span>
                        <span class="text-default bd0 pr5">조회년월</span>
                        ${fn:substring(inputParam.s_start_year_mon,0,4) }-${fn:substring(inputParam.s_start_year_mon,4,6) }
                        ~
                        ${fn:substring(inputParam.s_end_year_mon,0,4) }-${fn:substring(inputParam.s_end_year_mon,4,6) }
                    </span>
					<span>
						<div class="form-row inline-pd">
							<div class="col-auto">
								<span class="text-default bd0 pr5">센터</span>
							</div>
							<div class="col-auto">
								<select class="form-control width200px" id="s_org_code_1" name="s_org_code_1" onchange="javascript:goSearch();">
									<option value="">- 전체 -</option>
									<c:forEach var="item" items="${orgList}">
										<option value="${item.org_code}" <c:if test="${beanOrg.org_code eq item.org_code}">selected="selected"</c:if>>${item.org_kor_name}</option>
									</c:forEach>
								</select>
							</div>
						</div>
                    </span>
				</div>
			</div>
			<!-- 차트JS -->
			<div id="chartDiv1" class="title-wrap mt20"></div>

			<div class="search-wrap mt40">
				<div class="boxing bd0 pd0 vertical-line mt5">
                    <span>
                        <span class="text-default bd0 pr5">조회년월</span>
                        ${fn:substring(inputParam.s_start_year_mon,0,4) }-${fn:substring(inputParam.s_start_year_mon,4,6) }
                        ~
                        ${fn:substring(inputParam.s_end_year_mon,0,4) }-${fn:substring(inputParam.s_end_year_mon,4,6) }
                    </span>
					<span>
						<div class="form-row inline-pd">
							<div class="col-auto">
								<span class="text-default bd0 pr5">센터</span>
							</div>
							<div class="col-auto">
								<select class="form-control width200px" id="s_org_code_2" name="s_org_code_2" onchange="javascript:goSearch();">
									<option value="" selected="selected">- 선택 -</option>
									<c:forEach var="item" items="${orgList}">
										<option value="${item.org_code}">${item.org_kor_name}</option>
									</c:forEach>
								</select>
							</div>
						</div>
                    </span>
				</div>
			</div>
			<!-- 차트JS -->
			<div id="chartDiv2" class="title-wrap mt20"></div>

			<div class="btn-group mt5">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
		</div>
	</div>
	<!-- /팝업 -->
</form>
</body>
</html>