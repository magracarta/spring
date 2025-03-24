<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 장비관리 > 장비대장관리 > null > 운행정보
-- 작성자 : 김태훈
-- 최초 작성일 : 2021-07-28 15:27:16
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript" src="https://oapi.map.naver.com/openapi/v3/maps.js?ncpClientId=${clientId }"></script>
	<script type="text/javascript">
	
	var auiGrid;
	var map;
	var isError = false; // 검색 결과 플래그(운행 : 파랑, 에러 : 빨강)
	var isClicked = false;
	
	var markers = [];
	var infoWindows = [];
	
	$(document).ready(function() {
		createAUIGrid();
		
		var mapOptions = {
		    zoom: 10,
		};
		
		map = new naver.maps.Map('map', mapOptions);
		
		goSearch();
	});
	
	function fnDrawMap(list) {
		console.log(list);
		fnHideMarkers();
		markers = [];
		infoWindows = [];
		var redIcon = '<div style="background:url(/static/img/icon-pin-red.png); background-size:contain;';
		var blueIcon = '<div style="background:url(/static/img/icon-pin-blue.png); background-size:contain;';
		var indx = 1;
		for (var i in list) {
			
			/* if (i == 99) {
				break;
			} */
			
			var lng = parseFloat(list[i].lng); 
			var lat = parseFloat(list[i].lat); 
			
			var param = {
				position: new naver.maps.LatLng(lat, lng),
				map: map,
				icon: {
					//scaledSize: new naver.maps.Size(25, 34),
					anchor: new naver.maps.Point(15, 37),
					origin: new naver.maps.Point(15, 30),
					content: (isError ? redIcon : blueIcon) +
							'margin: 0px; padding: 0px; border: 0px solid transparent; display: block; max-width: none; max-height: none; ' +
							'-webkit-user-select: none; position: absolute; width: 30px; height: 30px; left: 0px; top: 0px;"><div style="text-align: center; font-weight : 900; margin-top: 2px">'+indx+'</div></div>'
				}
			};
			
			var marker = new naver.maps.Marker(param);
			
			if (indx == 1) {
				map.setCenter(new naver.maps.LatLng(lat, lng));
			}
			
			++indx;
			
			var infoWindow = new naver.maps.InfoWindow({
		        content: '<div style="padding : 5px;"><div style="text-align:left">'+list[i].loc_dt.substr(0, 10)+" "+list[i].loc_time+'</div><div style="text-align:left;">현재위치 : '+ list[i].addr +'</div></div>'
		    });
		    markers.push(marker);
		    infoWindows.push(infoWindow);
		    
		    naver.maps.Event.addListener(marker, 'mouseover mouseout', fnOverHandler(i));
			
		    // 마커 안보일때 감추기
		    // https://navermaps.github.io/maps.js/docs/tutorial-marker-viewport.example.html
			naver.maps.Event.addListener(map, 'idle', function() {
			    updateMarkers(map, marker);
			});
		}
	}

	function updateMarkers(map, marker) {
	    var mapBounds = map.getBounds();
	    var marker, position;
	    position = marker.getPosition();
        if (mapBounds.hasLatLng(position)) {
            showMarker(map, marker);
        } else {
            hideMarker(map, marker);
        }
	}

	function showMarker(map, marker) {

	    if (marker.getMap()) {
	    	return;
	    }
	    marker.setMap(map);
	}

	function hideMarker(map, marker) {

	    if (!marker.getMap()) {
	    	return;
	    }
	    marker.setMap(null);
	}
	
	// 마커 삭제
	function fnHideMarkers() {
	    fnSetMarkers(null);    
	}
	
	function fnSetMarkers(map) {
	    for (var i = 0; i < markers.length; i++) {
	        markers[i].setMap(map);
	    }            
	}

	function fnOverHandler(seq) {
	    return function(e) {
	        var marker = markers[seq], infoWindow = infoWindows[seq];

	        if (infoWindow.getMap()) {
	        	marker.setZIndex(100);
	        	if (isClicked) {
	        		isClicked = false;
	        		return;
	        	}
	            infoWindow.close();
	        } else {
	        	marker.setZIndex(1000);
	            infoWindow.open(map, marker);
	        }
	    }
	}
	
	//그리드생성
	function createAUIGrid() {
		var gridPros = {
			height : 500 
		};
		var dtWidth = "70";
		var columnLayout = [
			{ 
				headerText : "날짜", 
				dataField : "loc_dt", 
				dataType : "date",   
				width : dtWidth, 
				minWidth : "65",
				style : "aui-center",
				formatString : "yy-mm-dd",
			},
			{ 
				headerText : "시간", 
				dataField : "loc_time", 
				width : "50", 
				minWidth : "50",
				style : "aui-center",
			},
			{ 
				headerText : "위치", 
				dataField : "addr", 
				style : "aui-left aui-link",
			},
			{ 
				headerText : "에러내용", 
				dataField : "error_text", 
				width : dtWidth, 
				minWidth : "65",
				style : "aui-left",
			},
			{ 
				headerText : "시동", 
				dataField : "run_status", 
				width : "40", 
				minWidth : "40",
				style : "aui-center",
			},
			{
				dataField : "lat",
				visible : false
			},
			{
				dataField : "lng",
				visible : false
			}
		];
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		AUIGrid.setGridData(auiGrid, []);
		AUIGrid.bind(auiGrid, "cellClick", function(event) {
			if(event.dataField == 'addr') {
				var seq = event.rowIndex;
				var marker = markers[seq], infoWindow = infoWindows[seq];
				marker.setZIndex(Math.floor(Date.now() / 1000));
				infoWindow.open(map, marker);
				isClicked = true;
				
				var center = new naver.maps.LatLng(event.item.lat, event.item.lng);
				map.setCenter(center);
			}
		})
	}
		
	function goSearch() {
		if($M.checkRangeByFieldName("s_start_dt", "s_end_dt", true) == false) {				
			return;
		}; 
		
		map = new naver.maps.Map('map', {zoom: 10});

		var param = {
			s_type : $M.getValue("s_type"), // ERROR : 에러, 아니면 운행정보
			s_start_dt : $M.getValue("s_start_dt"),
			s_end_dt : $M.getValue("s_end_dt"),
			s_machine_seq : ${inputParam.machine_seq}
		}
		_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
			function(result) {
				isLoading = false;
				if(result.success) {
					isError = param.s_type == "ERROR" ? true : false;
					AUIGrid.setGridData(auiGrid, result.list);
					if (result.list.length > 0) {
						fnDrawMap(result.list);
					} else {
						fnHideMarkers();
					}
				};
			}
		); 
	}

	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<input type="hidden" name="machine_seq" id="machine_seq" value="${inputParam.machine_seq}">
	<!-- 팝업 -->
	<div class="popup-wrap width-100per">
		<!-- 타이틀영역 -->
		<div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
		</div>
		<!-- /타이틀영역 -->
		<div class="content-wrap" style="height: 100%">
			<!-- 폼테이블 -->
			<div class="row" style="height: 100%">
				<div class="col-5" style="height: 100%">
					<!-- 검색영역 -->
					<div class="search-wrap">
						<table class="table table-fixed">
							<colgroup>
								<col width="75px">
								<col width="260px">
								<col width="">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<td>
										<select class="form-control" name="s_type">
											<option value="OPERATION">운행일자</option>
											<option value="ERROR" ${inputParam.s_type eq 'ERROR' ? 'selected="selected"' : '' }>에러일자</option>
										</select>
									</td>
									<td style="min-width: 260px">
										<div class="form-row inline-pd">
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateFormat="yyyy-MM-dd" alt="시작일자" value="${searchDtMap.s_start_dt }">
												</div>
											</div>
											<div class="col-auto">~</div>
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateFormat="yyyy-MM-dd" alt="종료일자" value="${searchDtMap.s_end_dt }">
												</div>
											</div>
											<jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp">
					                     		<jsp:param name="st_field_name" value="s_start_dt"/>
					                     		<jsp:param name="ed_field_name" value="s_end_dt"/>
					                     		<jsp:param name="click_exec_yn" value="Y"/>
					                     		<jsp:param name="exec_func_name" value="goSearch();"/>
					                     	</jsp:include>
										</div>
									</td>
									<td>
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
									</td>	
								</tr>
							</tbody>
						</table>
					</div>
					<table class="table-border mt5">
						<colgroup>
							<col width="80px">
							<col width="">
							<col width="100px">
							<col width="">
						</colgroup>
						<tbody>
							<tr>
								<th class="text-right">장비모델</th>
								<td>
									${item.machine_name }
								</td>	
								<th class="text-right">SA-R계약번호</th>
								<td>
									${item.contract_no }
								</td>
							 </tr>
							 <tr>
								<th class="text-right">차대번호</th>
								<td>
									${item.body_no }
								</td>	
								<th class="text-right">개통일자</th>
								<td>
									${item.contract_dt }
								</td>
							</tr>
							<tr>	
								<th class="text-right">차주명</th>
								<td>
									${item.cust_name }
								</td>
								<th class="text-right">총 가동시간</th>
								<td>
									${item.run_time }
								</td>
							</tr>
						</tbody>
					</table>
					<div id="auiGrid" class="mt5"></div>
				</div>
				<div class="col-7" style="border: 1px solid;">
					<div id="map" style="width:100%;height: 100%"></div>
				</div>
			</div>
		</div>
	</div>
	<!-- /팝업 -->
</form>
</body>
</html>