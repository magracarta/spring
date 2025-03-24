<%@ page pageEncoding="UTF-8"%><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><c:set var="uri" value="${fn:replace(pageContext.request.requestURI, '/WEB-INF/jsp/', '')}"/><c:set var="prefix" value="${fn:split(uri, '/')}"/><c:set var="tmp" value=""/><c:forEach var="str" items="${prefix}"><c:set var="tmp" value="${str}"/></c:forEach><c:set var="thisDir" value="${fn:replace(uri, tmp, '')}"/><c:set var="thisPage" value="${fn:replace(uri, '.jsp', '')}"/><c:set var="dataSet" value="${DATA_SET}"/><c:set var="pageNavi" value="${dataSet.pageNavi}"/><c:set var="listIdx" value="0"/><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no">
<title>네이버 맵</title>
<script type="text/javascript" src="https://oapi.map.naver.com/openapi/v3/maps.js?ncpClientId=${clientId}"></script>
</head>
<body>
<div id="map" style="width:100%;height:840px;"></div>

<script>
var mapOptions = {
    center: new naver.maps.LatLng("${inputParam.lat}","${inputParam.lng}"),
    zoom: 20
};

var map = new naver.maps.Map('map', mapOptions);

var markerOptions = {
		position: new naver.maps.LatLng("${inputParam.lat}","${inputParam.lng}"),
		map: map
}

var marker = new naver.maps.Marker(markerOptions);
</script>
</body>
</html>