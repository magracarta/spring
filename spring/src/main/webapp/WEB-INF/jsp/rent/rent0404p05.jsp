<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 렌탈현황 > 렌탈장비수요분석 > 모델별 > 수요 분석 그래프
-- 작성자 : 정윤수
-- 최초 작성일 : 2024-01-26 17:42:19
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript" src="/static/Chartjs/Chart.min.js"></script>
	<script type="text/javascript" src="/static/Chartjs/chartjs-plugin-colorschemes.js"></script>
	<script type="text/javascript" src="/static/Chartjs/chartjs-plugin-datalabels.js"></script>
	<script type="text/javascript">

		var chartObj; // 메이커별 차트 오브젝트
		var chartObj2; // 모델별 차트 오브젝트
		var auiGrid1; // 지역별 그리드
		var auiGrid2; // 용도별 그리드
		var labels1 = ${labels}; //차트1라벨
		var labels2 = ${labels}; //차트2라벨
		var saleAreaListJson = ${saleAreaListJson}; // 지역 데이터
		var mchUseCdListJson = ${mchUseCdListJson}; // 용도 데이터
		
		var tab_id = "tab1";
		var machineGroupByMaker = ${machineGroupByMaker}
		var machineList = ${machineList}
		var s_machine_plant_seq = "";				
		$(document).ready(function() {
			createAUIGrid1();
			createAUIGrid2();
			goSearch();
			$('#tab2').addClass('dpn');


			// 탭 이벤트
			$('ul.tabs-c li a').click(function() {
				var el = $(this);
				tab_id = el.attr('data-tab');
				$('ul.tabs-c li a').removeClass('active');
				$('.tabs-inner').removeClass('active');
				el.addClass('active');
				$("#"+tab_id).addClass('active');

				switch (tab_id) {
					case 'tab1':
						$('#tab2').addClass('dpn');
						$('#tab1').removeClass('dpn');
						break;
					case 'tab2':
						$('#tab1').addClass('dpn');
						$('#tab2').removeClass('dpn');
						break;
				}

				goSearch();
			});
		});


		// AUIGrid 생성
		function createAUIGrid1() {
			var gridPros = {
				rowIdField: "_$uid",
				showRowNumColumn: false,
				showFooter : true,
				footerPosition : "top",
				headerHeight : 40,
			};

			var columnLayout = [
				{
					headerText: "구분",
					dataField: "machine_name",
					width: "90",
					minWidth: "80",
					style: "aui-center aui-popup",
				},
				{
					dataField: "machine_plant_seq",
					visible: false
				},
				{
					headerText: 'TOTAL',
					dataField: "total",
					width: "70",
					minWidth: "60",
					style: "aui-center",
				}
			];

			for (var i = 0; i < saleAreaListJson.length; i++) {
				var areaDataFieldName = "area_" + (i+1);

				var areaQtyObj = {
					headerText: saleAreaListJson[i].sale_area_name,
					dataField: areaDataFieldName,
					width: "70",
					minWidth: "60",
					style: "aui-center",
				}

				columnLayout.push(areaQtyObj);
			}

			// 푸터레이아웃
			var footerColumnLayout = [
				{
					labelText : "합계",
					positionField : "machine_name",
					style : "aui-center aui-footer",
				},
				{
					dataField : "total",
					positionField : "total",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-center aui-footer",
				},
			];
			
			for (var i = 0; i < saleAreaListJson.length; i++) {
				var areaDataFieldName = "area_" + (i+1);

				var areaQtyObj = {
					dataField: areaDataFieldName,
					positionField: areaDataFieldName,
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-center aui-footer",
				}

				footerColumnLayout.push(areaQtyObj);
			}
			
			auiGrid1 = AUIGrid.create("#auiGrid1", columnLayout, gridPros);
			AUIGrid.setFooter(auiGrid1, footerColumnLayout);
			AUIGrid.setGridData(auiGrid1, []);
			$("#auiGrid1").resize();

			// 셀 클릭 이벤트
			AUIGrid.bind(auiGrid1, "cellClick", function(event) {
				if(event.dataField == "machine_name"){
					goSearch(event.item["machine_plant_seq"])
				}
			});
		}

		// AUIGrid 생성
		function createAUIGrid2() {
			var gridPros = {
				rowIdField: "_$uid",
				showRowNumColumn: false,
				showFooter : true,
				footerPosition : "top",
				headerHeight : 40,
			};

			var columnLayout = [
				{
					headerText: "구분",
					dataField: "machine_name",
					width: "90",
					minWidth: "80",
					style: "aui-center aui-popup",
				},
				{
					dataField: "machine_plant_seq",
					visible: false
				},
				{
					headerText: 'TOTAL',
					dataField: "total",
					width: "70",
					minWidth: "60",
					style: "aui-center",
				},
				{
					headerText: '미선택',
					dataField: "미선택",
					width: "70",
					minWidth: "60",
					style: "aui-center",
				}
			];

			for (var i = 0; i < mchUseCdListJson.length; i++) {
				var mchUseDataFieldName = "mch_use_" + (i+1);

				var areaQtyObj = {
					headerText: mchUseCdListJson[i].code_name,
					dataField: mchUseDataFieldName,
					width: mchUseCdListJson[i].code_name.length > 4 ? "95" : "60",
					minWidth: "60",
					style: "aui-center",
				}

				columnLayout.push(areaQtyObj);
			}

			// 푸터레이아웃
			var footerColumnLayout = [
				{
					labelText : "합계",
					positionField : "machine_name",
					style : "aui-center aui-footer",
				},
				{
					dataField : "total",
					positionField : "total",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-center aui-footer",
				},
				{
					dataField : "미선택",
					positionField : "미선택",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-center aui-footer",
				},
			];

			for (var i = 0; i < mchUseCdListJson.length; i++) {
				var mchUseDataFieldName = "mch_use_" + (i+1);

				var areaQtyObj = {
					dataField: mchUseDataFieldName,
					positionField: mchUseDataFieldName,
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-center aui-footer",
				}

				footerColumnLayout.push(areaQtyObj);
			}

			auiGrid2 = AUIGrid.create("#auiGrid2", columnLayout, gridPros);
			AUIGrid.setFooter(auiGrid2, footerColumnLayout);
			AUIGrid.setGridData(auiGrid2, []);
			$("#auiGrid2").resize();

			// 셀 클릭 이벤트
			AUIGrid.bind(auiGrid2, "cellClick", function(event) {
				if(event.dataField == "machine_name"){
					goSearch(event.item["machine_plant_seq"])
				}
			});
		}
		
		// 첫번째 탭 차트
		function fnCreateChartForTab1(dataList) {

			// 차트데이터
			var chartData = {
				type: 'pie',
				data: {
					labels: labels1,
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
								weight: 'bold'
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
							offset: 75,
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
				var dataArray = JSON.parse(JSON.stringify(labels1));

				for (var i=0; i<row.length; i++) {
					// X축의 해당 데이터 인덱스
					var index = tab_id == "tab1" ? labels1.indexOf(row[i].area_disp) : labels1.indexOf(row[i].mch_use_name);
					dataArray[index] = row[i].cnt;	
				}

				// 라인데이터
				chartData.data.datasets.push({
					data : dataArray,
				});

			chartData.data.labels = labels1;
			
			// 캔버스 context
			var context = $("#chartObj").get(0).getContext('2d');

			// 이미 생성된 차트가 있으면 삭제
			if (!jQuery.isEmptyObject(chartObj)) {
				chartObj.destroy();
			}

			// 차트 그리기
			chartObj = new Chart(context, chartData);
		};
		
		// 두번째 탭 차트
		function fnCreateChartForTab2(dataList) {
			// 차트데이터
			var chartData = {
				type: 'pie',
				data: {
					labels: labels2,
					datasets: []
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
								weight: 'bold'
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
							offset: 75,
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
			var dataArray = JSON.parse(JSON.stringify(labels2));

			for (var i=0; i<row.length; i++) {
				// X축의 해당 데이터 인덱스
				var index = tab_id == "tab1" ? labels2.indexOf(row[i].area_disp) : labels2.indexOf(row[i].mch_use_name);
				dataArray[index] = row[i].cnt;
			}

			// 라인데이터
			chartData.data.datasets.push({
				data : dataArray,
			});

			chartData.data.labels = labels2;

			// 캔버스 context
			var context = $("#chartObj2").get(0).getContext('2d');

			// 이미 생성된 차트가 있으면 삭제
			if (!jQuery.isEmptyObject(chartObj2)) {
				chartObj2.destroy();
			}
			// 차트 그리기
			chartObj2 = new Chart(context, chartData);
		}

		
		
		// 메이커에 따라 모델 세팅
		function fnChangeMakerCd() {
			$('#s_machine_plant_seq').combogrid("reset");
			var makerCd = $M.getValue("s_maker_cd");
			var list = [];
			if (makerCd != "") {
				list = machineGroupByMaker[makerCd];
			} else {
				list = machineList;
			}
			$M.reloadComboData("s_machine_plant_seq", list);
		}

		// 조회
		function goSearch(machinePlantSeq) {
			s_machine_plant_seq = machinePlantSeq == null ? $M.getValue("s_machine_plant_seq") : machinePlantSeq
			var params = {
				"tab_id": tab_id,
				"s_year": $M.getValue("s_year"),
				"s_maker_cd": $M.getValue("s_maker_cd"),
				"s_machine_plant_seq": machinePlantSeq == null ? $M.getValue("s_machine_plant_seq") : machinePlantSeq,
			}
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(params), {method: 'GET'},
					function (result) {
						if (result.success) {
							labels1 = result.labels1;
							labels2 = result.labels2;
							// 지역별
							if(tab_id == "tab1"){
								var makerCd = $M.getValue("s_maker_cd");
								if(makerCd != ''){
									document.getElementById('chartObj1_title').innerHTML = "모델별 지역별 렌탈수요(" + $('#s_maker_cd option:checked').text() + "전체)";
								} else {
									document.getElementById('chartObj1_title').innerHTML = "모델별 지역별 렌탈수요(전체)";
								}
								fnCreateChartForTab1(result.makerDataList);

								var machineName = result.machineName;
								// 모델별 조회할때만 차트2 생성
								if(machineName != undefined){
									document.getElementById('chartObj2_title').innerHTML = "모델별 지역별 렌탈수요(" + machineName + ")";
									$('.chartObj2').removeClass('dpn');
									fnCreateChartForTab2(result.modelDataList);
								} else {
									$('.chartObj2').addClass('dpn');
									if (!jQuery.isEmptyObject(chartObj2)) {
										chartObj2.destroy();
									}
								}
							} else {
								// 용도별
								var makerCd = $M.getValue("s_maker_cd");
								if(makerCd != ''){
									document.getElementById('chartObj1_title').innerHTML = "모델별 용도별 렌탈수요(" + $('#s_maker_cd option:checked').text() + "전체)";
								} else {
									document.getElementById('chartObj1_title').innerHTML = "모델별 용도별 렌탈수요(전체)";
								}
								fnCreateChartForTab1(result.makerDataList);

								var machineName = result.machineName;
								// 모델별 조회할때만 차트2 생성
								if(machineName != undefined){
									document.getElementById('chartObj2_title').innerHTML = "모델별 용도별 렌탈수요(" + machineName + ")";
									$('.chartObj2').removeClass('dpn');
									fnCreateChartForTab2(result.modelDataList);
								} else {
									$('.chartObj2').addClass('dpn');
									if (!jQuery.isEmptyObject(chartObj2)) {
										chartObj2.destroy();
									}
								}
							}
							// 조회버튼 누를때만 그리드 데이터 세팅
							if(machinePlantSeq == null) {
								AUIGrid.setGridData(auiGrid1, result.saleAreaGridList);
								AUIGrid.setGridData(auiGrid2, result.mchUseGridList);
							}
						}
					}
			);
		}

		// 그래프 보기 팝업 호출
		function goGraphPopup(type) {
			var params = {
				"labels1" : labels1,
				"tab_id": tab_id,
				"s_year": $M.getValue("s_year"),
				"s_machine_plant_seq" : type == 'maker' ? "" : s_machine_plant_seq,
				"graphType": type == 'maker' ? $('#chartObj1_title').text() : $('#chartObj2_title').text(),
			};

			var popupOption = '';
			$M.goNextPage('/rent/rent0404p0501', $M.toGetParam(params), {popupStatus : popupOption});
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
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp" />
		</div>
		<!-- /타이틀영역 -->
		<div class="content-wrap">
			<!-- 탭 -->
			<ul class="tabs-c">
				<li class="tabs-item">
					<a href="#" class="tabs-link font-12 active" data-tab="tab1">지역별</a>
				</li>
				<li class="tabs-item">
					<a href="#" class="tabs-link font-12" data-tab="tab2">업종별</a>
				</li>
			</ul>
			<div class="tabs-inner" style="display: block;">
				<div>
					<div class="search-wrap mb5">
                        <!-- 검색영역 -->
                        <table class="table table-fixed">
                            <colgroup>
                                <col width="60px">
                                <col width="80px">
                                <col width="50px">
                                <col width="100px">
                                <col width="40px">
                                <col width="310px">
                                <col width="60px">
                                <col width="*">
                            </colgroup>
                            <tbody>
                            <tr>
                                <th>기준년도</th>
                                <td>
                                    <select class="form-control" id="s_year" name="s_year">
										<option value="">- 전체 -</option>
                                        <c:forEach var="i" begin="2022" end="${inputParam.s_current_year}" step="1">
                                            <c:set var="year_option" value="${inputParam.s_current_year - i + 2022}"/>
                                            <option value="${year_option}" <c:if test="${year_option eq inputParam.s_current_year}">selected</c:if>>${year_option}년</option>
                                        </c:forEach>
                                    </select>
                                </td>
                                <th>메이커</th>
                                <td>
									<select id="s_maker_cd" name="s_maker_cd" class="form-control" onchange="fnChangeMakerCd()">
                                        <option value="">- 전체 -</option>
                                        <c:forEach items="${rentalMchList}" var="item">
                                            <option value="${item.maker_cd}">${item.maker_name}</option>
                                        </c:forEach>
                                    </select>
                                </td>
                                <th>모델</th>
                                <td>
                                    <input type="text" style="width : 300px;"
                                           id="s_machine_plant_seq"
                                           name="s_machine_plant_seq"
                                           easyui="combogrid"
                                           header="Y"
                                           easyuiname="machineList"
                                           panelwidth="300"
                                           maxheight="300"
                                           textfield="machine_name"
                                           multi="Y"
                                           idfield="machine_plant_seq" />
                                </td>
                                <td>
                                    <button type="button" class="btn btn-important" style="width: 50px;" onclick="goSearch();">조회</button>
                                </td>
                            </tr>
                            </tbody>
                        </table>
                    </div>
                    <!-- /검색영역 -->
					</div>
				</div>
			</div>
			<div class="mt10">
				<div class="chartObj" style="display: inline-block; width: 700px">
					<div style="text-align: center; font-size: medium;font-weight:bold; color: blue" id="chartObj1_title"></div>
					<!-- 차트JS -->
					<div class="mt5" style="height: 400px">
						<canvas id="chartObj" height="160"></canvas>
					</div>
					<div class="btn-group mt5">
						<div class="right">
							<button type="button" class="btn btn-info" onclick="javascript:goGraphPopup('maker');">그래프 보기</button>
						</div>
					</div>
				</div>
				<div class="chartObj2" style="display: inline-block;  width: 700px">
					<div style="text-align: center; font-size: medium;font-weight:bold; color: blue" id="chartObj2_title"></div>
					<!-- 차트JS -->
					<div class="mt5" style="height: 400px">
						<canvas id="chartObj2"  height="160"></canvas>
					</div>
					<div class="btn-group mt5">
						<div class="right">
							<button type="button" class="btn btn-info" onclick="javascript:goGraphPopup('model');">그래프 보기</button>
						</div>
					</div>
				</div>
			</div>
			<div id="tab1" class="tabs-inner active">
				<div class="content-wrap">
				<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap">
						<h4>모델별-지역별 임대횟수</h4>
					</div>
					<!-- /그리드 타이틀, 컨트롤 영역 -->
					<div id="auiGrid1" style="margin-top: 5px; height: 290px;"></div>
				</div>
			</div>
			<div id="tab2" class="tabs-inner active">
				<div class="content-wrap">
					<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap">
						<h4>모델별-업종별 임대횟수</h4>
					</div>
					<!-- /그리드 타이틀, 컨트롤 영역 -->
					<div id="auiGrid2" style="margin-top: 5px; height: 290px;"></div>
				</div>
			</div>
			<!-- /탭내용 -->
		</div>
	</div>
</form>
</body>
</html>