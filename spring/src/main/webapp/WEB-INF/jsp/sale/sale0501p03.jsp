<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > MS관리 > MS관리-지역별 > null > 계약추이분석
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2021-04-09 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<style>
		.gray {
			background: #eee !important
		}
		.yellow {
			background: #FFFFE0 !important 
		}
	</style>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript" src="/static/Chartjs/Chart.min.js"></script>
	<script type="text/javascript" src="/static/Chartjs/chartjs-plugin-colorschemes.js"></script>
	<script type="text/javascript">
	
		var chartObj; // 탭 1 차트 오브젝트
		var chartObj2; // 탭 2 차트 오브젝트
		
		var tab_id = "tab1";
		var auiGrids = {
			tab1 : "auiGridTab1",
			tab2 : "auiGridTab2",
		};
		var fixedDivLabels = ["서울", "경기", "인천", "강원", "충북", "충남", "대전", "경북", "대구", "경남", "울산", "부산", "전북", "전남", "광주", "제주"];
		var divRefers = ["a_seoul", "a_gyeonggi", "a_incheon", "a_gangwon", "a_chungbuk", "a_chungnam", "a_daejeon", "a_gyeongbuk", "a_daegu", "a_gyeongnam", "a_ulsan", "a_busan", "a_jeonbuk", "a_jeonnam", "a_gwangju", "a_jeju"];
		
		var auiGridTab1;
		var auiGridTab2;
		var gubun = "1.5톤";
	
		$(document).ready(function() {
			createAuiGridTab1();
			createAuiGridTab2();
			
			// 탭 이벤트
			$('ul.tabs-c li a').click(function() {
				var el = $(this);
				tab_id = el.attr('data-tab');
				$('ul.tabs-c li a').removeClass('active');
				$('.tabs-inner').removeClass('active');
				el.addClass('active');
				$("#"+tab_id).addClass('active');
				
				// 탭 후 그리드 리사이징
				setTimeout(function() {
					$("#"+auiGrids[tab_id]).resize();
				}, 100);
			});
			
			goSearch();
		});
		
		function goSearch() {
        	var param = {
        		s_search_year : $M.getValue("s_search_year"),
        		s_machine_sub_type_cd : $M.getValue("s_machine_sub_type_cd"), 
        	}
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: "GET"},
				function (result) {
					if (result.success) {
						console.log("result : ", result);
						console.log(auiGrids[tab_id]);
						
						// 탭1
						AUIGrid.setGridData(auiGridTab1, result.yearDivlist);
						fnCreateChartForTab1(result.yearDivlist);
						
						// 탭2
						AUIGrid.setGridData(auiGridTab2, result.yearMonList);
						fnCreateChartForTab2(result.yearMonList);
						
						$("#"+auiGrids[tab_id]).resize();
					}
				}
			);
		}
		
		// 두번째 탭 차트
		function fnCreateChartForTab2(dataList) {

			// 계약 데이터
			var lineDataSet = [];
			
			// MS 데이터
			var barDataSet = [];
			
			var chartData = {
				type : 'bar',
				data : {
					labels : ["1월", "2월", "3월", "4월", "5월", "6월", "7월", "8월", "9월", "10월", "11월", "12월"], 
					datasets : []
				},
				options: {
					// 툴팁을 모두 보이게
				    tooltips: { 
				        mode: 'label' 
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
			                	userCallback: function(label, index, labels) {
			                        if (Math.floor(label) === label) {
			                            return label;
			                        }
			                    },
			                }
			            }]
			        },
			        plugins: {
			            colorschemes: {
			            	scheme: 'brewer.Spectral8',
			            }
			        }
				},
			}
			
			for (var i = 0; i < dataList.length; ++i) {
				var data = [];
				var label = "";
				var row = dataList[i];
				
				for (var prop in row) { // 숫자가 키이기 때문에 인덱스로 찾지않는다! -> 숫자키의 순서가 보존
					if (prop != "ms_year" && prop != "total") {
						data.push(row[prop]);
					}
					if (prop == "ms_year") {
						label = row[prop];
					}
				}
				
				// 계약 데이터면 라인 데이터셋에 넣기
				if (row.ms_year.indexOf("총수요") == -1) {
					chartData.data.datasets.push({
						type : "line",
						label: label,
						borderWidth: 2,
						data : data,
						tension : 0,
						fill: false,
					});
				} else { // MS 데이터면 바 데이터셋에 넣기
					chartData.data.datasets.push({
						type : 'bar',
						label : label,
						data : data,
						maxBarThickness : 40,
					});
				}
			}
			
			// 캔버스 context
			var ctx = $("#chartObj2").get(0).getContext('2d');
			
			// 이미 생성된 차트가 있으면 삭제
			if (!jQuery.isEmptyObject(chartObj2)) {
				chartObj2.destroy();
			}
			
			// 차트 그리기
			chartObj2 = new Chart(ctx, chartData);
		}
		
		// 첫번째 탭 차트
		function fnCreateChartForTab1(dataList) {
			var fixedLabels = fixedDivLabels // x축
			
			// 차트데이터
			var chartData = {
				// 비율일때 라인차트, 수량일때 바 차트 혼용
				type : 'bar',
				data : {
					labels : fixedLabels, 
					datasets : [
						{
							label : "Total",
							data : [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
							maxBarThickness : 40,
							order: 1
						}
					]
				},
				options: {
					// 툴팁을 모두 보이게
				    tooltips: { 
				        mode: 'label' 
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
			                	userCallback: function(label, index, labels) {
			                        if (Math.floor(label) === label) {
			                            return label;
			                        }
			                    },
			                }
			            }]
			        },
			        plugins: {
			            colorschemes: {
			            	scheme: 'brewer.Paired6',
			            }
			        }
				},
			};
			for (var i = 0; i < dataList.length; ++i) {
				var row = dataList[i];
				if (row.gubun != "연도 별 얀마<br>등록수량<br>(MS)") {
					// 라인 데이터
					var dataArray = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
					if (row.ms_year != "Total") {
						for (var prop in row) {
							// 수량일때
							if (prop.indexOf('a_', prop.length - prop.length) !== -1) {
								var index = divRefers.indexOf(prop);
								dataArray[index] = row[prop];
							}
						}
						// 라인데이터
						chartData.data.datasets.push({
							type : "line",
							label: row.ms_year,
							borderWidth: 2,
							data : dataArray,
							tension : 0,
							fill: false,
						});
					} else {
						for (var prop in row) {
							// 수량일때
							if (prop.indexOf('a_', prop.length - prop.length) !== -1) {
								var index = divRefers.indexOf(prop);
								chartData.data.datasets[0].data[index] = row[prop];
							}
						}
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
		};
		
		function createAuiGridTab2() {
			var gridPros = {
				showRowNumColumn : false,
				height : 250,
				rowStyleFunction : function(rowIndex, item) {
					if (item.ms_year.indexOf("얀마 등록수량") != -1) {
						return "yellow";
					}
				}
			};
			var width = "45";
			var minWidth = "30";
			var columnLayout = [
				{
					headerText : "연도", 
					dataField : "ms_year", 
					width : "140",
					minWidth : "60",
					style : "aui-center",
					labelFunction : function (rowIndex, columnIndex, value, headerText, item ) { //HTML 템플릿 작성
						if (rowIndex < 4) {
							return value +" 계약수량";
						} else {
							return value;
						}
			     	}
				},
				{ 
					headerText : "1월", 
					dataField : "'01'", 
					width : width,
					minWidth : minWidth,
					style : "aui-center"
				}, 
				{ 
					headerText : "2월", 
					dataField : "'02'", 
					width : width,
					minWidth : minWidth,
					style : "aui-center"
				},
				{ 
					headerText : "3월", 
					dataField : "'03'", 
					width : width,
					minWidth : minWidth,
					style : "aui-center"
				},
				{ 
					headerText : "4월", 
					dataField : "'04'", 
					width : width,
					minWidth : minWidth,
					style : "aui-center"
				},
				{ 
					headerText : "5월", 
					dataField : "'05'", 
					width : width,
					minWidth : minWidth,
					style : "aui-center"
				},
				{ 
					headerText : "6월", 
					dataField : "'06'", 
					width : width,
					minWidth : minWidth,
					style : "aui-center"
				},
				{ 
					headerText : "7월", 
					dataField : "'07'", 
					width : width,
					minWidth : minWidth,
					style : "aui-center"
				},
				{ 
					headerText : "8월", 
					dataField : "'08'", 
					width : width,
					minWidth : minWidth,
					style : "aui-center"
				},
				{ 
					headerText : "9월", 
					dataField : "'09'", 
					width : width,
					minWidth : minWidth,
					style : "aui-center"
				},
				{ 
					headerText : "10월", 
					dataField : "'10'", 
					width : width,
					minWidth : minWidth,
					style : "aui-center"
				},
				{ 
					headerText : "11월", 
					dataField : "'11'", 
					width : width,
					minWidth : minWidth,
					style : "aui-center"
				},
				{ 
					headerText : "12월", 
					dataField : "'12'", 
					width : width,
					minWidth : minWidth,
					style : "aui-center"
				},
				{ 
					headerText : "Total", 
					dataField : "total", 
					width : width,
					minWidth : minWidth,
					style : "aui-center",
				}
			];
			auiGridTab2 = AUIGrid.create("#auiGridTab2", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridTab2, []);
		}
		
		
		// 연도별 지역별 계약추이 탭 그리드
		function createAuiGridTab1() {
			var gridPros = {
				showRowNumColumn : false,
				enableCellMerge : true,
				height : 300,
				rowStyleFunction : function(rowIndex, item) {
					if (item.ms_year == "Total") {
						return "yellow";
					}
				}
			};
			var width = "38";
			var minWidth = "30";
			var columnLayout = [
				{ 
					headerText : "구분",
					dataField : "gubun",
					width : "80",
					minWidth : "70",
					cellMerge : true,
					style : "gray",
					renderer : {
			            type : "TemplateRenderer"
			     	},
					labelFunction : function (rowIndex, columnIndex, value, headerText, item ) { //HTML 템플릿 작성
			            return value +"<br>계약수량";
			     	}
				},
				{
					headerText : "연도", 
					dataField : "ms_year", 
					width : "40",
					minWidth : "30",
					style : "aui-center"
				},
				{ 
					headerText : "서울", 
					dataField : "a_seoul", 
					width : width,
					minWidth : minWidth,
					style : "aui-center",
					labelFunction : function (rowIndex, columnIndex, value, headerText, item ) { //HTML 템플릿 작성
			            return value == "0" ? "" : value;
			     	}
				}, 
				{ 
					headerText : "경기", 
					dataField : "a_gyeonggi", 
					width : width,
					minWidth : minWidth,
					style : "aui-center",
					labelFunction : function (rowIndex, columnIndex, value, headerText, item ) { //HTML 템플릿 작성
			            return value == "0" ? "" : value;
			     	}
				},
				{ 
					headerText : "인천", 
					dataField : "a_incheon", 
					width : width,
					minWidth : minWidth,
					style : "aui-center",
					labelFunction : function (rowIndex, columnIndex, value, headerText, item ) { //HTML 템플릿 작성
			            return value == "0" ? "" : value;
			     	}
				},
				{ 
					headerText : "강원", 
					dataField : "a_gangwon", 
					width : width,
					minWidth : minWidth,
					style : "aui-center",
					labelFunction : function (rowIndex, columnIndex, value, headerText, item ) { //HTML 템플릿 작성
			            return value == "0" ? "" : value;
			     	}
				},
				{ 
					headerText : "충북", 
					dataField : "a_chungbuk", 
					width : width,
					minWidth : minWidth,
					style : "aui-center",
					labelFunction : function (rowIndex, columnIndex, value, headerText, item ) { //HTML 템플릿 작성
			            return value == "0" ? "" : value;
			     	}
				},
				{ 
					headerText : "충남", 
					dataField : "a_chungnam", 
					width : width,
					minWidth : minWidth,
					style : "aui-center",
					labelFunction : function (rowIndex, columnIndex, value, headerText, item ) { //HTML 템플릿 작성
			            return value == "0" ? "" : value;
			     	}
				},
				{ 
					headerText : "대전", 
					dataField : "a_daejeon", 
					width : width,
					minWidth : minWidth,
					style : "aui-center",
					labelFunction : function (rowIndex, columnIndex, value, headerText, item ) { //HTML 템플릿 작성
			            return value == "0" ? "" : value;
			     	}
				},
				{ 
					headerText : "경북", 
					dataField : "a_gyeongbuk", 
					width : width,
					minWidth : minWidth,
					style : "aui-center",
					labelFunction : function (rowIndex, columnIndex, value, headerText, item ) { //HTML 템플릿 작성
			            return value == "0" ? "" : value;
			     	}
				},
				{
					headerText : "대구",
					dataField : "a_daegu",
					width : width,
					minWidth : minWidth,
					style : "aui-center",
					labelFunction : function (rowIndex, columnIndex, value, headerText, item ) { //HTML 템플릿 작성
						return value == "0" ? "" : value;
					}
				},
				{ 
					headerText : "경남", 
					dataField : "a_gyeongnam", 
					width : width,
					minWidth : minWidth,
					style : "aui-center",
					labelFunction : function (rowIndex, columnIndex, value, headerText, item ) { //HTML 템플릿 작성
			            return value == "0" ? "" : value;
			     	}
				},
				{ 
					headerText : "울산", 
					dataField : "a_ulsan", 
					width : width,
					minWidth : minWidth,
					style : "aui-center",
					labelFunction : function (rowIndex, columnIndex, value, headerText, item ) { //HTML 템플릿 작성
			            return value == "0" ? "" : value;
			     	}
				},
				{ 
					headerText : "부산", 
					dataField : "a_busan", 
					width : width,
					minWidth : minWidth,
					style : "aui-center",
					labelFunction : function (rowIndex, columnIndex, value, headerText, item ) { //HTML 템플릿 작성
			            return value == "0" ? "" : value;
			     	}
				},
				{ 
					headerText : "전북", 
					dataField : "a_jeonbuk", 
					width : width,
					minWidth : minWidth,
					style : "aui-center",
					labelFunction : function (rowIndex, columnIndex, value, headerText, item ) { //HTML 템플릿 작성
			            return value == "0" ? "" : value;
			     	}
				},
				{ 
					headerText : "전남", 
					dataField : "a_jeonnam", 
					width : width,
					minWidth : minWidth,
					style : "aui-center",
					labelFunction : function (rowIndex, columnIndex, value, headerText, item ) { //HTML 템플릿 작성
			            return value == "0" ? "" : value;
			     	}
				},
				{ 
					headerText : "광주", 
					dataField : "a_gwangju", 
					width : width,
					minWidth : minWidth,
					style : "aui-center",
					labelFunction : function (rowIndex, columnIndex, value, headerText, item ) { //HTML 템플릿 작성
			            return value == "0" ? "" : value;
			     	}
				},
				{ 
					headerText : "제주", 
					dataField : "a_jeju", 
					width : width,
					minWidth : minWidth,
					style : "aui-center",
					labelFunction : function (rowIndex, columnIndex, value, headerText, item ) { //HTML 템플릿 작성
			            return value == "0" ? "" : value;
			     	}
				},
				{
					headerText : "Total", 
					dataField : "a_total", 
					width : width,
					minWidth : minWidth,
					style : "aui-center",
					labelFunction : function (rowIndex, columnIndex, value, headerText, item ) { //HTML 템플릿 작성
			            return value == "0" ? "" : value;
			     	}
				},
			];
			auiGridTab1 = AUIGrid.create("#auiGridTab1", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridTab1, []);
		}
		
		function fnClose() {
			window.close();
		}
		
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<div class="popup-wrap width-100per"> 
<!-- 타이틀영역 -->
        <div class="main-title">
            <h2>계약추이분석</h2>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">	
<!-- 탭 -->			
			<ul class="tabs-c">
				<li class="tabs-item">
					<a href="#" class="tabs-link font-12 active" data-tab="tab1">연도별 지역별 계약추이</a>
				</li>
				<li class="tabs-item">
					<a href="#" class="tabs-link font-12" data-tab="tab2">연도별 월별 계약추이</a>
				</li>
			</ul>
			<div class="tabs-inner" style="display: block;">
				<div class="tabs-inner-line">
                    <div class="form-row inline-pd widthfix search">
                        <div class="col width60px">기준년도</div>
                        <div class="col width100px">
                            <select class="form-control" id="s_search_year" name="s_search_year">
                                <c:forEach var="i" begin="1" end="22" varStatus="status">
                                	<option value="${inputParam.s_current_year-i+1}" ${inputParam.s_search_year eq inputParam.s_current_year-i+1 ? 'selected' : ''}>${inputParam.s_current_year-i+1}년</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col width50px text-right">구분</div>
                        <div class="col width100px">
                            <select class="form-control" id="s_machine_sub_type_cd" name="s_machine_sub_type_cd">
                                <option value="0102">1.5톤</option>
                                <option value="0103">2톤</option>
                                <option value="0104">3톤</option>
                                <option value="0105">5톤</option>
                                <option value="0106">8톤</option>
                                <option value="0107">5톤휠</option>
                                <option value="미니합계">미니합계</option>
                            </select>
                        </div>
                        <div class="col width60px">
                            <button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch()">조회</button>
                        </div>
                    </div>
				</div>
			</div>
			<div class="mt5"></div>
			
			<div id="tab1" class="tabs-inner active">
				<div style="display: block; width: 100%">
					<!-- 차트JS -->
					<div class="mt5" style="height: 400px">
						<canvas id="chartObj" height="130"></canvas>
						<div class="mt5" style="height: 280px">
							<div id="auiGridTab1"></div>
						</div>
					</div>
				</div>
			</div>
			<div id="tab2" class="tabs-inner">
				<div style="display: block;  width: 100%">
					<!-- 차트JS -->
					<div class="mt5" style="height: 400px">
						<canvas id="chartObj2"  height="130"></canvas>
						<div class="mt5" style="height: 280px">
							<div id="auiGridTab2"></div>
						</div>
					</div>
				</div>
			</div>
<!-- /탭내용 -->	
            <!-- <div class="btn-group mt10">
                <div class="right">
                    <button type="button" class="btn btn-info" onclick="javascript:fnClose()">닫기</button>
                </div>
            </div> -->
        </div>
    </div>
</form>
</body>
</html>