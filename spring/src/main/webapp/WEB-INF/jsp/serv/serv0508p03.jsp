<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 서비스관리 > Yammar가동현황(SA-R) > null > 지역별 평균 가동시간
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
		var listJson = ${listJson}; // 모델별 Data
		var maxAvgShtdwnRunTime = ${maxAvgShtdwnRunTime}; // Y축 최대값
		$(document).ready(function() {
			fnCreateChart();
		});

		function getRandomColor() {
			var trans = '0.5'; // 50% transparency
			var color = 'rgba(';
			for (var i = 0; i < 3; i++) {
				color += Math.floor(Math.random() * 255) + ',';
			}
			color += trans + ')'; // add the transparency
			return color;
		}

		// 차트 생성
		function fnCreateChart() {
			var fixedLabels = ${labels} // x축
			fixedLabels.push("");
			var dataList = listJson;

			// 연도별 그룹핑
			var groupBy = function(xs, key) {
				return xs.reduce(function(rv, x) {
					(rv[x[key]] = rv[x[key]] || []).push(x);
					return rv;
				}, {});
			};

			var dataListGroup = groupBy(dataList, "decal_model");
			var chartData = {
				type : "line",
				data : {
					labels : fixedLabels,
					datasets : []
				},
				options : {
					plugins: {
						// Change options for ALL labels of THIS CHART
						datalabels: {
							backgroundColor: function(context) {
								return context.dataset.backgroundColor;
							},
							borderRadius: 4,
							color: 'black',
							font: {
								weight: 'bold'
							},
							// formatter: Math.round,
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
						position: "right",
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
								beginAtZero: true,
								callback: function (value, index, values) {
									return value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
								},
								max : maxAvgShtdwnRunTime
							}
						}]
					}
				}
			}

			for(var decal_model in dataListGroup) {
				var color = getRandomColor();
				var item = dataListGroup[decal_model];
				var itemLength = item.length;
				var dataArray = new Array(itemLength);
				for(var i=0; i<dataArray.length; i++) {
					dataArray[i] = 0;
				}

				for(var i=0; i<itemLength; ++i) {
					var row = item[i];
					for(var prop in row) {
						if(prop == "op_mon") {
							var yearMon = row[prop];
							var index = fixedLabels.indexOf(yearMon);
							dataArray[index] += $M.toNum(row["avg_shtdwn_run_time"]);
						}
					}
				}

				chartData.data.datasets.push({
					type : "line",
					label: item[0].decal_model,
					borderColor: color,
					pointBackgroundColor : color,
					borderWidth: 2,
					data : dataArray,
					tension : 0,
					fill: false,
					datalabels: {
						align: 'top',
						anchor: 'top',
						formatter: function(value) {
				            return value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
					    },
					}
				});
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
		// 닫기
		function fnClose() {
			window.close();
		}
	</script>
</head>
<body class="bg_white">
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
					<span>
                        <span class="text-default bd0 pr5">담당자</span>
                      	<c:choose>
							<c:when test="${empty beanMem}">- 전체 -</c:when>
							<c:otherwise>${beanMem.kor_name}</c:otherwise>
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