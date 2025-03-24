<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > MS관리 > MS관리-센터별 > null > 센터담당지역 별 MS자료
-- 작성자 : 김태훈
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
<!-- <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.9.4/Chart.min.js"  crossorigin="anonymous"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.9.4/Chart.bundle.min.js"  crossorigin="anonymous"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.9.4/Chart.min.css"  crossorigin="anonymous"/> -->
<script type="text/javascript" src="/static/Chartjs/Chart.min.js"></script>
	<script type="text/javascript">
	
		var chartObj; // 차트 오브젝트
		var selectMsJson = ${selectMsJson} // MS데이터
		var colors = ["#a83232", "#a87332", "#a8a432", "#65a832", "#32a889", "#326da8", "#4a32a8", "#9232a8", "#a83285", "#a83240"];
		var labelsRefer = ${labelsRefer} // 지역코드(바 차트 총수요 계산용)
		
		$(document).ready(function() {
			fnCreateChart();
		});
		
		function fnCreateChart() {
			
			var fixedLabels = ${labels} // x축(지역명)
			var xAxis = fixedLabels;
			
			// 지역코드인덱스 저장용 배열 초기화(x축 개수와 같아야함)
			var labelsReferIndexInitArray = []; 
			
			// 지역 개수만큼 값이 0인 배열 생성(총수요 데이터에 각 자리수에 더할 배열)
			while (labelsReferIndexInitArray.length != labelsRefer.length) {
				labelsReferIndexInitArray.push(0);
			}
			
			// 선택된 톤수
			var type = $M.getValue("machine_type");
			
			// MS리스트에서 선택된 톤수(MAP)
			var dataList = selectMsJson[type];
			for (var i in dataList) {
				if (!dataList[i].maker_name) {
					dataList[i].maker_name = "기타";
				}
			}
			
			console.log(dataList);

			// 화면에 톤수 표시
			$("#machine_type_name").html(dataList[0].ms_machine_sub_type_name);
			
			// 막대 데이터 기본값
			var barData = labelsReferIndexInitArray;
			
			// 차트데이터
			var chartData = {
				// 비율일때 라인차트, 수량일때 바 차트 혼용
				type : "${inputParam.type eq 'ratio' ? 'line' : 'bar'}",
				data : {
					labels : fixedLabels, 
					datasets : [
					// 수량일때만 총수요
					<c:if test="${inputParam.type ne 'ratio'}">
					{
						label : "총수요",
						data : [],
						backgroundColor : 'rgba(54, 162, 235, 0.2)',
						maxBarThickness: 40,
					}
					</c:if>
					]
				},
				options: {
					// 툴팁을 모두 보이게
				    tooltips: { 
				        mode: 'label',
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
			                    // 비율 그래프일 경우 y축에 % 붙임
			                    callback: function(value, index, values) {
			                    	<c:if test="${inputParam.type eq 'ratio'}">
			                        	value = value+'%';
			                        </c:if>
			                        return value;
			                    },
			                    userCallback: function(label, index, labels) {
			                        if (Math.floor(label) === label) {
			                            return label
			                            <c:if test="${inputParam.type eq 'ratio'}">
			                        	+'%'
				                        </c:if>
			                            <c:if test="${inputParam.type ne 'ratio'}">
			                        	+'건'
				                        </c:if>;
			                        }
			                    },
			                }
			            }]
			        }
				},
			};
			for (var i = 0; i < dataList.length; ++i) {
				var row = dataList[i];
				// 라인 데이터 초기화
				var dataArray = [];
				// 바데이터 길이와 라인데이터 길이는 같기때문에 바 데이터 길이만큼 값이 0인 라인 배열을 생성함.
				var barLen = labelsReferIndexInitArray.length;
				while(barLen--) dataArray.push(0);
				
				for (var prop in row) {
					// 수량일때
					<c:if test="${inputParam.type ne 'ratio'}">
					// a_20210402_qty = 123 에서 라벨에 맞는 데이터 선택
					if (prop.indexOf('_qty', prop.length - prop.length) !== -1 && prop != "a_total_qty") {
						var propRes = prop.substr(2);
						propRes = propRes.replace("_qty", "").toUpperCase();
						var index = labelsRefer.indexOf(propRes);
						
						// 총수요에 더함
						barData[index] = barData[index]+$M.toNum(row[prop]);
						dataArray[index] = row[prop];
					}
					</c:if>
					
					// 비율일때
					<c:if test="${inputParam.type eq 'ratio'}">
					// a_20210402_qty = 123 에서 라벨에 맞는 데이터 선택
					if (prop.indexOf('_rate', prop.length - prop.length) !== -1 && prop != "a_total_rate") {
						var propRes = prop.substr(2);
						propRes = propRes.replace("_rate", "").toUpperCase();
						var index = labelsRefer.indexOf(propRes);
						dataArray[index] = row[prop];
					}
					</c:if>
				}
				// 라인데이터
				chartData.data.datasets.push({
					type : "line",
					label: row.maker_name,
					borderColor: colors[i],
					pointBackgroundColor : colors[i], 
					borderWidth: 2,
					data : dataArray,
					tension : 0,
					fill: false,
				});
			}
			
			<c:if test="${inputParam.type ne 'ratio'}">
				chartData.data.datasets[0].data = barData;
			</c:if>
			
			chartData.data.labels = xAxis;
			
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
		
	
	<%-- 여기에 스크립트 넣어주세요. --%>
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
                        ${fn:substring(inputParam.s_start_dt,0,4) }-${fn:substring(inputParam.s_start_dt,4,6) }
                        ~
                        ${fn:substring(inputParam.s_end_dt,0,4) }-${fn:substring(inputParam.s_end_dt,4,6) }
                    </span>
                    <span>
                        <span class="text-default bd0 pr5">센터</span>
                        <c:if test="${inputParam.s_center_org_code eq ''}">
                        	전체
                        </c:if>
                        ${orgNameMap[inputParam.s_center_org_code]}
                    </span>
                    <span>
                        <span class="text-default bd0 pr5">기종</span>
                        ${s_ms_machine_type_name}
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
				<canvas id="chartObj"></canvas>

				<!-- 그리드 서머리, 컨트롤 영역 -->
				<div class="btn-group mt5">
					<div class="right">
						<%-- <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R" /></jsp:include> --%>
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