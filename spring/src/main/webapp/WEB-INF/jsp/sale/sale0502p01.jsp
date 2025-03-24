<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > MS관리 > MS관리-시도별 > null 
-- 작성자 : 김태훈
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp" />
<!-- <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.9.4/Chart.min.js" crossorigin="anonymous"></script> -->
<script type="text/javascript" src="/static/Chartjs/Chart.min.js"></script>
<script type="text/javascript">

	var chartObj; // 차트 오브젝트
	var lineColors = ["#a83232", "#a87332", "#a8a432", "#65a832", "#32a889", "#326da8", "#4a32a8", "#9232a8", "#a83285", "#a83240"];
	var barColors = [];
	var labels = ["서울", "경기", "인천", "강원", "충북", "충남", "대전", "경북", "대구", "경남", "울산", "부산", "전북", "전남", "광주", "제주", "세종"];
	var labelsKey = ["seoul", "gyeonggi", "incheon", "gangwon", "chungbuk", "chungnam", "daejeon", "gyeongbuk", "daegu", "gyeongnam", "ulsan", "busan", "jeonbuk", "jeonnam", "gwangju", "jeju", "sejong"];
	var selectMsJson = ${selectMsJson}
	var makerList = "${inputParam.s_maker_cd_str}".split("#");

	$(document).ready(function() {
		makerList.push("46"); // 기타
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

	function fnCreateChart() {
		
		// 선택된 톤수
		var type = $M.getValue("machine_type");
		
		// MS리스트에서 선택된 톤수(MAP)
		var dataList = selectMsJson[type];
		
		// 화면에 톤수 표시
		$("#machine_type_name").html(dataList[0].ms_machine_sub_type_name);
		
		// 연도별 그룹핑
		var groupBy = function(xs, key) {
			return xs.reduce(function(rv, x) {
				(rv[x[key]] = rv[x[key]] || []).push(x);
				return rv;
			}, {});
		};
		
		var dataListGroup = groupBy(dataList, 'ms_year');
		
		console.log(dataListGroup);
		
		// 막대색깔 지정(연도 개수만큼 배열에 삽입)
		if (Object.keys(dataListGroup).length != barColors.length) {
			barColors.length = 0;
			var dom = $("#customBarLegends");
			var text = []; 
			text.push('<ul style="display: inline-flex;">');
			var index = 0;
			for (var key in dataListGroup) {
				var color = getRandomColor();
				barColors.push(color);
				// 바 차트의 커스텀 레전드 생성.. 
				text.push('<li style="display: flex; margin-left: 10px; cursor : pointer;" onclick="updateDataset(event, ' + '\'' + index + '\'' + ')"><div style="width : 25px; height: 15px;line-height: 1; background-color:'+color+'"></div>');
				text.push('<div style="margin-left: 5px;line-height: 1;" id="legend_'+index+'">'+key+'</div>');
				index++;
				text.push('</li>'); 
			}
			text.push('</ul>');
			dom.html(text.join(""));
		}

		// 차트데이터
		var chartData = {
			// 수량일때 바 차트 혼용
			type : 'bar',
			data : {
				labels : labels,
				datasets : []
			},
			options : {
				// 툴팁을 모두 보이게
				tooltips: { 
			        mode: 'label' 
			    },
				legend : {
					display : false,
				},
				legendCallback: function(chart) { 
				    return drawCustomLegendForLine(chart)
				},
				scales: {
			    	yAxes: [{
		                ticks: {
		                	beginAtZero: true,
		                    userCallback: function(label, index, labels) {
		                        if (Math.floor(label) === label) {
		                            return label+"건";
		                        }
		                    },
		                }
		            }]
		        }
			},
		};
		var yearCnt = 0;
		for (var year in dataListGroup) {
			var backgroundColor = barColors[yearCnt];
			yearCnt++;
			var data = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
			var item = dataListGroup[year];
			var len = item.length;
			for (var i = 0; i < len; ++i) {
				var row = item[i];
				for ( var prop in row) {
					// 수량일때
					if (prop.indexOf('a_', prop.length - prop.length) !== -1 && prop != "a_total") {
						var resion = prop.substr(2);
						var index = labelsKey.indexOf(resion);
						data[index] = data[index]+row[prop];
					}
				}
			}
			chartData.data.datasets.push({
				label : year,
				data : data,
				backgroundColor : backgroundColor
			});
		}
		var dataListMakerGroup = groupBy(dataList, 'maker_cd');
		
		// 그룹바이할때 메이커 순서가 maker_cd 순으로 바껴서 다시 정렬하기 위해 배열생성(코드값때문에 얀마가 먼저 안나오고 두산이 먼저나옴!)
		var tempLineDataSet = [];
		for (var maker in dataListMakerGroup) {
			var data = [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ];
			var item = dataListMakerGroup[maker];
			var len = dataListMakerGroup[maker].length;
			for (var i = 0; i < len; ++i) {
				var row = item[i];
				for (var prop in row) {
					// 수량일때
					if (prop.indexOf('a_', prop.length - prop.length) !== -1 && prop != "a_total") {
						var resion = prop.substr(2);
						var index = labelsKey.indexOf(resion);
						data[index] = data[index]+row[prop];
					}
				}
			}
			
			// 라인데이터
			
			tempLineDataSet.push({
				type : "line",
				label : item[0].maker_name,
				code : item[0].maker_cd,
				/* borderColor : borderColor,
				pointBackgroundColor : borderColor, */
				borderWidth : 2,
				data : data,
				tension : 0,
				fill : false,
			});
		}
		// chartData.data.datasets
		console.log(chartData.data.datasets);
		for (var i = 0; i < makerList.length; ++i) {
			for (var j = 0; j < tempLineDataSet.length; ++j) {
				if (makerList[i] == tempLineDataSet[j].code) {
					tempLineDataSet[j]["borderColor"] = lineColors[i];
					tempLineDataSet[j]["pointBackgroundColor"] = lineColors[i];
					chartData.data.datasets.push(tempLineDataSet[j]);
					break;
				}
			}
		}

		// 캔버스 context
		var ctx = $("#chartObj").get(0).getContext('2d');

		// 이미 생성된 차트가 있으면 삭제
		if (!jQuery.isEmptyObject(chartObj)) {
			chartObj.destroy();
		}

		// 차트 그리기
		chartObj = new Chart(ctx, chartData);
		$("#customLegends").html(chartObj.generateLegend());
		
		$(".chartHide").removeClass("chartHide");
	};

	function fnClose() {
		window.close();
	}
	
	// 커스텀레전드
	function drawCustomLegendForLine(chart) { 
		var text = []; 
		text.push('<ul class="' + chart.id + '-legend">'); 
		for (i = 0; i <chart.data.datasets.length; i++) {
			if (chart.data.datasets[i].type == "line") {
				if(!(chart.data.datasets[i].hideLegend) && chart.data.datasets[i].label) {
					text.push('<li datasetIndex="'+i+'" style="width : 100%; display: flex;align-items: center;margin-left: 5px; margin-top: 5px; cursor : pointer;"  onclick="updateDataset(event, ' + '\'' + chart.legend.legendItems[i].datasetIndex + '\'' + ')"><div class="line" style="width : 40px; height: 15px; background-color:' + chart.data.datasets[i].borderColor + '"></div>'); 
					text.push('<div style="margin-left: 5px;" id="legend_'+chart.legend.legendItems[i].datasetIndex+'">'+chart.data.datasets[i].label+'</div>'); 
					text.push('</li>'); 
				} 
			}
		}
		text.push('</ul>'); 
		return text.join(""); 
	}
	
	// 커스텀 레전드 이벤트
	function updateDataset(e, datasetIndex) {
	    var index = datasetIndex;
	    var ci = e.view.chartObj;
	    var meta = ci.getDatasetMeta(index);
	    meta.hidden = meta.hidden === null? !ci.data.datasets[index].hidden : null;
	    ci.update();
	    
	    // 차트 토글 클래스 표시
	    var element = document.getElementById("legend_"+datasetIndex);
	    element.classList.toggle("chartHide");
	};
		
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
		<!-- /타이틀영역 -->
		<div class="content-wrap">
			<div class="search-wrap">
               <div class="boxing bd0 pd0 vertical-line mt5">
                   <span>
                       <span class="text-default bd0 pr5">조회년월</span>
                       ${inputParam.s_start_year}년 ${inputParam.s_start_mon}월
                       ~
                       ${inputParam.s_end_year}년 ${inputParam.s_end_mon}월
                   </span>
                   <span class="bd0">
                   		기종 : ${ms_machine_type_name }
                   </span>
                   <span class="bd0">
                       <select class="form-control" onchange="javascript:fnCreateChart()" id="machine_type" name="machine_type">
                       	<c:forEach items="${selectMsMap}" var="item">
                       		<option value="${item.key}">${item.value[0].ms_machine_sub_type_name}</option>
                       	</c:forEach>
                       </select>
                   </span>
               </div>               		
           </div>
			<div class="title-wrap mt5" style="padding-bottom: 5px;">
				<h4 id="machine_type_name">여기에 타이틀이 들어갑니다.</h4>
				<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R" /></jsp:include>
			</div>

			<!-- 차트JS -->
			<div style="display: flex; align-items: center;">
				<div style="display: inline-block; width: 80%;">
					<canvas id="chartObj"></canvas>
				</div>
				<div style="display: inline-block; width: 20%;">
					<div id="customLegends"></div>
				</div>
			</div>
			<!-- 커스텀 레전드 영역 -->
			<div class="mt5" style="display: inline-block; width: 100%;">
				<div style="width: 80%; display: inline-block;">
					<div id="customBarLegends" style="text-align: center;"></div>
				</div>
				<div style="width: 20%; display: inline-block; text-align: right;"></div>
			</div>
			<div class="btn-group mt5">		
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
			<!-- /그리드 서머리, 컨트롤 영역 -->
		</div>
	</div>
	<!-- /팝업 -->
</form>
</body>
</html>