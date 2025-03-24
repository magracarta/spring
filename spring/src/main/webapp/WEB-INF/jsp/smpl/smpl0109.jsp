<%@ page contentType="text/html;charset=utf-8" language="java"%><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<!DOCTYPE html>
<html>
<head>
   <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
   <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.9.4/Chart.min.js"></script>
   <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.9.4/Chart.bundle.min.js"></script>
   <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.9.4/Chart.min.css"/>
	
	   <!-- 그리드 컬럼안 검색 스크립트 -->
	   <script>
		var chartData = {
			labels: ['1월', '2월', '3월', '4월', '5월', '6월', '7월'],
			datasets: [{
				type: 'line', // 차트형식
				label: '라인차트',
				borderColor: "blue",
				borderWidth: 2,
				fill: false,
				data: [
					1,2,3,4,5, 6, 7 // 숫자
				]
			}, {
				type: 'bar',
				label: '바 차트',
				backgroundColor: "red",
				data: [
					1,2,3,4,5, 6, 7 // 숫자
				],
				borderColor: 'white',
				borderWidth: 2
			}, {
				type: 'bar',
				label: '바 차트 2',
				backgroundColor: "green",
				data: [
					1,2,3,4,5, 6, 7 // 숫자
				]
			}]

		};
		window.onload = function() {
			var ctx = document.getElementById('canvas').getContext('2d');
			window.myMixedChart = new Chart(ctx, {
				type: 'bar',
				data: chartData, // 차트로 만들 데이터
				options: {
					responsive: true,
					title: {
						display: true,
						text: '차트 예제'
					},
					tooltips: {
						mode: 'index',
						intersect: true
					}
				}
			});
		};
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<!-- contents 전체 영역 -->
   <div class="content-wrap">
      <div class="content-box">
   <!-- 메인 타이틀 -->
   		  <div class="main-title" style="width:900px;">
	         <h2>차트 (smpl0109.jsp)</h2>
         </div>
         <div class="contents" style="width: 60%">
         	<div>
         		<table class="table-border">
         			<colgroup>
         				<col width="20">
         				<col width="70">
         			</colgroup>
         			<tr>
         				<th>Chartjs (2.9.4) 홈페이지</th>
         				<td><a href="https://www.chartjs.org/" target="_blank" style="color: blue;" >Chartjs (2.9.4)</a></td>
         			</tr>
         			<tr>
         				<th>문서</th>
         				<td>
         					<a href="https://www.chartjs.org/docs/latest/charts/line.html" target="_blank" style="color: blue;" >차트JS 문서</a>
         				</td>
         			</tr>
         			<tr>
         				<th>샘플</th>
         				<td>
         					<a href="https://www.chartjs.org/samples/latest/" target="_blank" style="color: blue;" >차트 샘플</a>
         				</td>
         			</tr>
         		</table>
         		 
         	</div>
         	<canvas id="canvas"></canvas>
         </div>
      </div>
   </div>
<!-- /contents 전체 영역 -->
</form>
</body>
</html>