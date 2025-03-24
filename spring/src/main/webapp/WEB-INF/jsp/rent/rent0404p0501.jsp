<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 렌탈현황 > 렌탈장비수요분석 > 모델별 > 그래프 보기
-- 작성자 : 정윤수
-- 최초 작성일 : 2024-04-08 10:42:19
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript" src="/static/Chartjs/Chart.min.js"></script>
	<script type="text/javascript" src="/static/Chartjs/chartjs-plugin-colorschemes.js"></script>
	<script type="text/javascript" src="/static/Chartjs/chartjs-plugin-datalabels.js"></script>
	<script type="text/javascript">

		var chartObj; // 차트 오브젝트
		var labels1; //차트 라벨
		var labels2; //차트 라벨
		var graphType = "${inputParam.graphType}";
		var tab_id = "${inputParam.tab_id}"; 
		var chartOffset = "125"; // 150% 기준 offset
		$(document).ready(function() {
			goSearch();
		});

		// 첫번째 탭 차트
		function fnCreateChart(dataList) {

			// 차트데이터
			var chartData = {
				type: 'pie',
				data: {
					labels: graphType == 'maker' ? labels1 : labels2,
					datasets: [],
				},
				options: {
					// datalabels이 잘리는 경우가 발생하여 패딩줌
					layout: {
						padding: 35
					},
					plugins: {
						datalabels: {
							color: 'black',
							font: {
								weight: 'bold',
							},
							formatter: function (value, context) {
								if(isNaN(value)){
									return "";
								} else {
									var idx = context.dataIndex; // 각 데이터 인덱스
									// 출력 텍스트
									var text = context.chart.data.labels[idx] +"\n"+ Math.round(value / context.chart.getDatasetMeta(0).total * 100);
									return text + "%";
								}
							},
							align: 'end',
							offset: chartOffset,
						}
					},
					// 툴팁을 모두 보이게
					tooltips: {
						mode: 'label'
					},
					legend: {
						position: "right",
						onHover: function (e, datasetIndex) {
							e.target.style.cursor = 'pointer';
						},
						onLeave: function (e) {
							e.target.style.cursor = 'default'
						},
					},
				}
			};

				// 라인 데이터
				var row = dataList;
				var dataArray = graphType == 'maker' ? JSON.parse(JSON.stringify(labels1)) : JSON.parse(JSON.stringify(labels2));

				for (var i=0; i<row.length; i++) {
					// X축의 해당 데이터 인덱스
					var index;
					if(tab_id == "tab1"){
						index = graphType == "maker" ? labels1.indexOf(row[i].area_disp) : labels2.indexOf(row[i].area_disp);
					} else {
						index = graphType == "maker" ? labels1.indexOf(row[i].mch_use_name) : labels2.indexOf(row[i].mch_use_name);
					}
					dataArray[index] = row[i].cnt;	
				}

				// 라인데이터
				chartData.data.datasets.push({
					data : dataArray,
				});

			chartData.data.labels = graphType == 'maker' ? labels1 : labels2;
			
			// 캔버스 context
			var context = $("#chartObj").get(0).getContext('2d');

			// 이미 생성된 차트가 있으면 삭제
			if (!jQuery.isEmptyObject(chartObj)) {
				chartObj.destroy();
			}

			// 차트 그리기
			chartObj = new Chart(context, chartData);
		};

		// 조회
		function goSearch() {
			var params = {
				"tab_id": tab_id,
				"s_year": "${inputParam.s_year}",
				"s_machine_plant_seq": "${inputParam.s_machine_plant_seq}",
			}
			$M.goNextPageAjax("/rent/rent0404p05/search", $M.toGetParam(params), {method: 'GET'},
					function (result) {
						if (result.success) {
							labels1 = result.labels1;
							labels2 = result.labels2;

							// 지역별
							if(graphType == "maker"){
								fnCreateChart(result.makerDataList);
							} else {
								fnCreateChart(result.modelDataList);
							}
						}
					}
			);
		}
		
		function fnChartPercent(percent) {
			var width = (700 * percent.value / 100) + "px";
			$('.chartObj').width(width);
			switch (percent.value) {
				case "100" :
					chartOffset = "75";
					break;
				case "150" :
					chartOffset = "125";
					break;
				case "200" :
					chartOffset = "170";
					break;
				case "250" :
					chartOffset = "215";
					break;
			}
			goSearch();
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
			<div class="search-wrap mt10">
				<div class="boxing bd0 pd0 vertical-line mt5">
                    <span>
                        <span class="text-default bd0 pr5">기준년도: ${inputParam.s_year}년</span>
                    </span>
					<span>
						<div class="form-row inline-pd">
							<div class="col-auto">
								<span class="text-default bd0 pr5">${inputParam.graphType}</span>
							</div>
						</div>
                    </span>
					<span class="text-default bd0 pr5">배율</span>
					<select class="form-control width80px" id="chart_percent" name="chart_percent" onchange="javascript:fnChartPercent(this);">
						<option value="100">100%</option>
						<option value="150" selected="selected">150%</option>
						<option value="200">200%</option>
						<option value="250">250%</option>
					</select>
				</div>
			</div>
			<!-- 차트JS -->
			<div class="chartObj" style="display: inline-block; width: 1050px">
				<div style="text-align: center; font-size: medium;font-weight:bold; color: blue" id="chartObj1_title"></div>
				<div class="mt5">
					<canvas id="chartObj" height="160"></canvas>
				</div>
				<div class="btn-group mt5">
					<div class="right">
						<button type="button" class="btn btn-info" onclick="javascript:fnClose();">닫기</button>
					</div>
				</div>
			</div>
			</div>
			
		</div>
	</div>
	<!-- /팝업 -->
</form>
</body>
</html>