<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 서비스관리 > 전국 Network현황 > null > 지역별 위탁판매점 개설 분포 현황
-- 작성자 : 성현우
-- 최초 작성일 : 2021-04-09 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript" src="https://oapi.map.naver.com/openapi/v3/maps.js?ncpClientId=${clientId}&submodules=geocoder"></script>

	<script>
		var cAddressData = ${cList}; // 건기대리점
		var aAddressData = ${aList}; // 농기대리점

		$(document).ready(function () {
			fnInit();
		});

		function fnInit() {
			// 지도 생성
			var mapOptions = {
				center: new naver.maps.LatLng("35.5642135", "127.0016985"),
				zoom: 7
			};
			var map = new naver.maps.Map('map', mapOptions);

			// 건기대리점 마커 생성
			for (var i in cAddressData) {
				if (cAddressData[i].addr1 != "") {
					naver.maps.Service.geocode({
						query: cAddressData[i].addr1
					}, function (status, response) {
						if (status !== naver.maps.Service.Status.OK) {
							return;
						}

						var result = response.v2; // 검색 결과의 컨테이너
						var items = result.addresses; // 검색 결과의 배열

						var x = parseFloat(items[0].x); // 경도
						var y = parseFloat(items[0].y); // 위도

						var defaultMarker = new naver.maps.Marker({
							position: new naver.maps.LatLng(y, x),
							map: map,
							icon: {
								content: '<img src="/static/img/red_icon.png" alt="" ' +
										'style="margin: 0px; padding: 0px; border: 0px solid transparent; display: block; max-width: none; max-height: none; ' +
										'-webkit-user-select: none; position: absolute; width: 12px; height: 12px; left: 0px; top: 0px;">'
							}
						});
					});
				}
			}

			// 농기대리점 마커 생성
			for (var i in aAddressData) {
				if (aAddressData[i].addr1 != "") {
					naver.maps.Service.geocode({
						query: aAddressData[i].addr1
					}, function (status, response) {
						if (status !== naver.maps.Service.Status.OK) {
							return;
						}

						var result = response.v2; // 검색 결과의 컨테이너
						var items = result.addresses; // 검색 결과의 배열

						var x = parseFloat(items[0].x); // 경도
						var y = parseFloat(items[0].y); // 위도

						var defaultMarker = new naver.maps.Marker({
							position: new naver.maps.LatLng(y, x),
							map: map,
							icon: {
								content: '<img src="/static/img/blue_icon.png" alt="" ' +
										'style="margin: 0px; padding: 0px; border: 0px solid transparent; display: block; max-width: none; max-height: none; ' +
										'-webkit-user-select: none; position: absolute; width: 12px; height: 12px; left: 0px; top: 0px;">'
							}
						});
					});
				}
			}
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
                        <span class="text-default bd0 pr5">기준 : </span>
						${fn:substring(inputParam.s_current_mon, 0, 4)}년 ${fn:substring(inputParam.s_current_mon, 4, 6)}월
                    </span>
					<span>
						<img src="/static/img/red_icon.png" style="width: 12px; height: 12px; left: 0px; top: 0px;"/>
                        <span class="text-default bd0 pr5">건기 : </span>
                      	${cList_cnt}
                    </span>
					<span>
						<img src="/static/img/blue_icon.png" style="width: 12px; height: 12px; left: 0px; top: 0px;"/>
                        <span class="text-default bd0 pr5">농기 : </span>
                      	${aList_cnt}
                    </span>
					<span>
                        <span class="text-default bd0 pr5">Total : </span>
                      	${total_cnt}
                    </span>
				</div>
			</div>
		</div>
		<div class="content-wrap">

			<div id="map" style="width:100%; height:580px; border: 2px solid #DDDDDD;"></div>

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
