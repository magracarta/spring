<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 부품통계 > KPI집계 > null > Total 매출
-- 작성자 : 김태훈
-- 최초 작성일 : 2021-04-09 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp" />
<!-- <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.9.4/Chart.min.js"  crossorigin="anonymous"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.9.4/Chart.bundle.min.js"  crossorigin="anonymous"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.9.4/Chart.min.css"  crossorigin="anonymous"/> -->
<script type="text/javascript" src="/static/Chartjs/Chart.min.js"></script>
<script type="text/javascript" src="/static/Chartjs/chartjs-plugin-colorschemes.js"></script>
<script type="text/javascript">

	var chartObj; // 차트 오브젝트

	$(document).ready(function() {
		if (opener == null) {
			goSearch();
		} else {
			fnCreateChart(opener.dataList);
		}
	});

	function fnCreateChart(dataList) {
		
		// 차트데이터
		var chartData = {
			// 비율일때 라인차트, 수량일때 바 차트 혼용
			type : "line",
			data : {
				labels : ["12월", "1월", "2월", "3월", "4월", "5월", "6월", "7월", "8월", "9월", "10월", "11월"], 
				datasets : []
			},
			options: {
				// 툴팁을 모두 보이게
			    tooltips: { 
			          callbacks: {
			                label: function(tooltipItem, data) {
			                    return $M.setComma(tooltipItem.value);
			                }
			          } // end callbacks: 
			    }, 
			    legend: {
			    	 position: 'bottom',
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
		                	// 비율 그래프일 경우 y축에 % 붙임
		                    callback: function(value, index, values) {
		                    	return $M.setComma(value);
		                    }
		                }
		            }],
		        },
		        plugins: {
		            colorschemes: {
		            	scheme: 'brewer.PuOr4',
		            }
		        }
			},
		};
		
		for (var i = 0; i < dataList.length; ++i) {
			chartData.data.datasets.push({
				type : "line",
				label: dataList[i].year,
				borderWidth: 2,
				data : dataList[i].data,
				tension : 0,
				fill: false,
			});
		}
		
		// 캔버스 context
		var ctx = $("#chartObj").get(0).getContext('2d');
		
		// 이미 생성된 차트가 있으면 삭제
		if (!jQuery.isEmptyObject(chartObj)) {
			chartObj.destroy();
		}
		
		// 차트 그리기
		chartObj = new Chart(ctx, chartData);
	};

	function fnClose() {
		window.close();
	}
	
	function goSearch() {
		var param = {
			s_year 			: "${inputParam.s_year}",
			s_part_no_str   : "${inputParam.s_part_no_str}",
			s_maker_cd_str 	: "${inputParam.s_maker_cd_str}",
			s_type : "${inputParam.s_type}",
			s_name : "${inputParam.s_name}"
		};
		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
			function(result) {
				if(result.success) {
					fnCreateChart(result.list);
				};
			}
		);
	}
	
</script>
</head>
<body class="bg-white">
	<form id="main_form" name="main_form">
		<!-- 팝업 -->
		<div class="popup-wrap width-100per">
			<!-- 타이틀영역 -->
			<div class="main-title">
				<div style="display: inline-flex;">
					<h2>${inputParam.s_name_view}&nbsp;</h2><jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp" />
				</div>
			</div>
			<!-- /타이틀영역 -->
			<div class="content-wrap">
				<!-- 차트JS -->
				<canvas id="chartObj"></canvas>

				<!-- 그리드 서머리, 컨트롤 영역 -->
				<div class="btn-group mt5">
					<div class="right">
						<button type="button" class="btn btn-info" onclick="javascript:fnClose()">닫기</button>
					</div>
				</div>
				<!-- /그리드 서머리, 컨트롤 영역 -->
			</div>
		</div>
		<!-- /팝업 -->

	</form>
</body>
</html>