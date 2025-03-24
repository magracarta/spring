<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp" /><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt"%><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%><%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 판매관리 > 계약추이 > 계약추이 비교그래프 > null
-- 작성자 : 김경빈
-- 최초 작성일 : 2023-02-28 12:27:15
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp" />
<script type="text/javascript" src="/static/Chartjs/Chart.min.js"></script>
<script type="text/javascript">

	let chartObj; // 차트 오브젝트
	const dataList = ${list}; // 차트 데이터
	const xAxis = ${labels}; // X축
	const colors = ["red", "#5b9bd5", "#ffd966", "#65a832", "grey"];
	const pointShapes = ['circle', 'rect', 'rectRounded', 'rectRot', 'triangle'];

	$(document).ready(function() {
		fnCreateChart();
	});

	function fnCreateChart() {
		
		// 차트데이터
		let chartData = {
			type : "line",
			data : {
				labels : xAxis,
				datasets : []
			},
			options: {
				// 툴팁을 모두 보이게
			    tooltips: { 
			        mode: 'label'
			    },
			    legend: {
			    	 position: 'right',
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
							callback: function(value) {
								return value + '건';
							}
		                }
		            }]
		        }
			},
		};

		for (let i=0; i<dataList.length; i++) {
			// 라인 데이터
			const row = dataList[i];
			let dataArray = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

			for (let j=0; j<row.length; j++) {
				row[j].yyyymm.substring(4, 6)
				// X축의 해당 데이터 인덱스
				const index = xAxis.indexOf(row[j].yyyymm.substring(4, 6) + '월');
				dataArray[index] = row[j].qty;
			}

			// 라인데이터
			chartData.data.datasets.push({
				type : "line",
				label: row[0].yyyymm.substring(0,4) + '.' + row[0].yyyymm.substring(4,6) + ' ~ ' + row[row.length-1].yyyymm.substring(0,4) + '.' + row[row.length-1].yyyymm.substring(4,6),
				borderColor: colors[i],
				pointBackgroundColor : colors[i],
				pointStyle: pointShapes[i],
				borderWidth: 2,
				data : dataArray,
				tension : 0,
				fill: false,
			});
		}
		
		chartData.data.labels = xAxis;
		
		// 캔버스 context
		const context = $("#chartObj").get(0).getContext('2d');
		
		// 이미 생성된 차트가 있으면 삭제
		if (!jQuery.isEmptyObject(chartObj)) {
			chartObj.destroy();
		}
		
		// 차트 그리기
		chartObj = new Chart(context, chartData);
	}

	// 닫기
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
				<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp" />
			</div>
			<div class="content-wrap">
				<div class="search-wrap mb10">
                	<div class="boxing bd0 pd0 vertical-line mt5">
                	    <span>
                	        <span class="text-default bd0 pr5">조회연도</span>
                	        ${s_start_dt} ~ ${s_end_dt}
                	    </span>
                	</div>
                	<div class="boxing bd0 pd0 vertical-line mt5">
                	    <span class="bd0">
                	        <span class="text-default bd0 pr5">해당지역</span>
                	       		 ${inputParam.area_name}
                	    </span>
                	</div>
				</div>
				<!-- ChartJS -->
				<canvas id="chartObj"></canvas>
				<!-- 하단 버튼 영역 -->
				<div class="btn-group mt5">
					<div class="right">
						 <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R" /></jsp:include>
					</div>
				</div>
            </div>
		</div>
		<!-- /팝업 -->
	</form>
</body>
</html>