<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jstl/fmt_rt" %>
<%-- 년도와 월 보이기 콤보 생성	  
### param 설명 ###
-- <jsp:param name="show_field" value="hour, minute"/> 			==> 보여줄필드
-- <jsp:param name="required_field" value="hour, minute"/> 		==> 필수필드 기술 
-- <jsp:param name="min_hour_minute" value="0000"/> 			==> 최소로 보여주는 시/분 (00/00)
-- <jsp:param name="max_hour_minute" value="2350"/> 			==> 최대로 보여주는 시/분 (23/50)	
-- <jsp:param name="select_hour_minute" value="0000"/>			==> 선택되는 년/월 (기본은 선택 )
-- <jsp:param name="hour_name" value="s_hour"/>					==> select 이름(기본 s_hour)
-- <jsp:param name="minute_name" value="s_minute"/>				==> select 이름(기본 s_minute)
-- <jsp:param name="hour_alt" value=""/>						==> alt value
-- <jsp:param name="minute_alt" value=""/>						==> alt value

--%>
<%-- 셋팅할 변수 초기화 --%>
<c:set var="hour_name">${param.hour_name eq null ? 's_hour' : param.hour_name }</c:set>
<c:set var="minute_name">${param.minute_name eq null ? 's_minute' : param.minute_name }</c:set>
<c:set var="from_hour">${param.min_hour_minute eq null ? 00 : fn:substring(param.min_hour_minute, 0, 2) }</c:set>
<c:set var="to_hour">${param.max_hour_minute eq null ? 23 : fn:substring(param.max_hour_minute, 0, 2) }</c:set>
<c:set var="from_minute">${param.min_hour_minute eq null ? 00 : fn:substring(param.min_hour_minute, 2, 4) }</c:set>
<c:set var="to_minute">${param.max_hour_minute eq null ? 50 : fn:substring(param.max_hour_minute, 2, 4) }</c:set>
<c:set var="sel_hour">${param.select_hour_minute eq null ? 99 : fn:substring(param.select_hour_minute, 0, 2) }</c:set>
<c:set var="sel_minute">${param.select_hour_minute eq null ? 99 : fn:substring(param.select_hour_minute, 2, 4) }</c:set>
<c:set var="hour_alt">${param.hour_alt eq null ? '시' : param.hour_alt }</c:set>
<c:set var="minute_alt">${param.minute_alt eq null ? '분' : param.minute_alt }</c:set>


<c:set var="show_f" value="${param.show_field}"/><%-- 보여줄 필드 --%>
<c:set var="req_f" value="${param.required_field}"/><%-- 필수 필드 --%>
<c:if test="${fn:contains(show_f, 'hour')}">
<select id="${hour_name }" name="${hour_name }" style="width: 60px;" alt="${hour_alt}" ${fn:contains(req_f, 'hour') ? 'required="required"' : '' } >
	<option value="" ${sel_hour eq 99 ? "selected='selected'" : "" }>- 시 -</option>
	<c:forEach var="optVal" begin="${from_hour}" end="${to_hour }">
		<c:choose>
			<c:when test="${optVal < 10}">
				<option value="0${optVal}" ${optVal eq sel_hour ? "selected='selected'" : ""} >0${optVal}</option>
			</c:when>
			<c:otherwise>
				<option value="${optVal }" ${optVal eq sel_hour ? "selected='selected'" : ""} >${optVal}</option>
			</c:otherwise>
		</c:choose>
	</c:forEach>
</select>
</c:if>
<c:if test="${fn:contains(show_f, 'minute')}">
<select id="${minute_name }" name="${minute_name }" style="width: 60px;" alt="${minute_alt}" ${fn:contains(req_f, 'minute') ? 'required="required"' : '' } >
	<option value="" ${sel_minute eq 99 ? "selected='selected'" : "" }>- 분 -</option>
	<c:forEach var="optVal" begin="${from_minute }" end="${to_minute }" step="10">
		<c:choose>
			<c:when test="${optVal < 10}">
				<option value="0${optVal }" ${optVal eq sel_minute ? "selected='selected'" : ""} >0${optVal}</option>
			</c:when>
			<c:otherwise>
				<option value="${optVal }" ${optVal eq sel_minute ? "selected='selected'" : ""} >${optVal}</option>
			</c:otherwise>
		</c:choose>
		
	</c:forEach>
</select>
</c:if>