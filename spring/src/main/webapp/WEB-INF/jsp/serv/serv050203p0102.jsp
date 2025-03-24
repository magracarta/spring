<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 서비스관리 > 서비스업무평가-센터 > 실적분석 > 유상 정비순익 변화추이
-- 작성자 : 성현우
-- 최초 작성일 : 2021-04-09 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<%--<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.9.4/Chart.min.js"  crossorigin="anonymous"></script>
	<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.9.4/Chart.bundle.min.js"  crossorigin="anonymous"></script>
	<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.9.4/Chart.min.css"  crossorigin="anonymous"/>--%>
	<%--<script type="text/javascript" src="https://cdn.jsdelivr.net/npm/chartjs-plugin-datalabels@0.7.0"></script>--%>
	<script type="text/javascript" src="/static/Chartjs/Chart.min.js"></script>
	<script type="text/javascript" src="/static/Chartjs/chartjs-plugin-datalabels.js"></script>
	<script type="text/javascript">

		var chartObj; // 차트 오브젝트
		var costProfitAmt = ${listJson}; // 유상 정비순익 변화추이 데이터
		var maxAmt = ${maxAmt};
		var colors = ["#a83232", "#a87332", "#a8a432", "#65a832", "#32a889", "#326da8", "#4a32a8", "#9232a8", "#a83285", "#a83240"];
		var labels = ["12", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", ""];
		var labelsKey = ["12", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", ""];

		$(document).ready(function () {
			fnCreateChart();
		});

		function fnCreateChart() {
			// 데이터
			var dataList = costProfitAmt;

			// 연도별 그룹핑
			var groupBy = function (xs, key) {
				return xs.reduce(function (rv, x) {
					(rv[x[key]] = rv[x[key]] || []).push(x);
					return rv;
				}, {});
			};

			var dataListGroup = groupBy(dataList, 'yyyy');

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
							backgroundColor: function (context) {
								return context.dataset.backgroundColor;
							},
							borderRadius: 4,
							color: 'black',
							font: {
								weight: 'bold'
							},
							formatter: Math.round,
							padding: 0,
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
								max: maxAmt
							}
						}]
					}
				}
			}

			var yearCnt = 0;
			for (var year in dataListGroup) {
				var dataArray = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
				var item = dataListGroup[year];
				var itemLength = item.length;
				for (var i = 0; i < itemLength; ++i) {
					var row = item[i];
					for (var prop in row) {
						if (prop == "yyyymm") {
							var month = row[prop].substr(4);
							var index = labelsKey.indexOf(month);
							dataArray[index] += $M.toNum(row["cost_profit_amt"]);
						}
					}
				}

				chartData.data.datasets.push({
					type: "line",
					label: item[0].yyyy,
					borderColor: colors[yearCnt],
					pointBackgroundColor: colors[yearCnt],
					borderWidth: 2,
					data: dataArray,
					tension: 0,
					fill: false,
					datalabels: {
						align: 'top',
						anchor: 'top',
						formatter: function(value) {
			                return value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
					    },
					}
				});

				yearCnt++;
			}

			// 캔버스 context
			var ctx = $("#chartObj").get(0).getContext('2d')

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
			<div class="search-wrap">
				<div class="boxing bd0 pd0 vertical-line mt5">
                    <span>
                        <span class="text-default bd0 pr5">조회년월</span>
                        ${fn:substring(inputParam.s_start_year_mon,0,4) }-${fn:substring(inputParam.s_start_year_mon,4,6) }
                        ~
                        ${fn:substring(inputParam.s_end_year_mon,0,4) }-${fn:substring(inputParam.s_end_year_mon,4,6) }
                    </span>
					<span>
                        <span class="text-default bd0 pr5">센터</span>
                      	<c:choose>
							<c:when test="${empty beanOrg}">- 전체 -</c:when>
							<c:otherwise>${beanOrg.org_kor_name}</c:otherwise>
						</c:choose>
                    </span>
				</div>
			</div>
		</div>
		<div class="content-wrap">

			<!-- 차트JS -->
			<canvas id="chartObj"></canvas>

			<div class="btn-group mt10">
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