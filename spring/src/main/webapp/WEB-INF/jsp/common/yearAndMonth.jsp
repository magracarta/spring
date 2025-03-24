<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jstl/fmt_rt" %>
<%-- 년도와 월 보이기 콤보 생성	  
### param 설명 ###
-- <jsp:param name="show_field" value="year, month"/> 			==> 보여줄필드
-- <jsp:param name="required_field" value=""year, month"/> 		==> 필수필드 기술 
-- <jsp:param name="min_year_month" value="201601"/> 				==> 최소로 보여주는 년/월 (기본년도는 올해 - 5년)
-- <jsp:param name="max_year_month" value="201712"/> 				==> 최대로 보여주는 년/월 (기본년도는 올해 + 5년)	
-- <jsp:param name="select_year_month" value="201707"/>				==> 선택되는 년/월 (기본은 해당월)
-- <jsp:param name="year_name" value="s_year"/>				==> select 이름(기본 s_year)
-- <jsp:param name="month_name" value="s_month"/>				==> select 이름(기본 s_month)
--%>
<%-- 셋팅할 변수 초기화 --%>
<jsp:useBean id="toDay" class="java.util.Date" />
<fmt:formatDate value="${toDay}" pattern="yyyy" var="currYear" />
<fmt:formatDate value="${toDay}" pattern="MM" var="currMonth" />

<c:set var="year_name">${param.year_name eq null ? 's_year' : param.year_name }</c:set>
<c:set var="month_name">${param.year_name eq null ? 's_month' : param.month_name }</c:set>
<c:set var="from_year">${param.min_year_month eq null ? currYear - 5 : fn:substring(param.min_year_month, 0, 4) }</c:set>
<c:set var="to_year">${param.max_year_month eq null ? currYear + 5 : fn:substring(param.max_year_month, 0, 4) }</c:set>
<c:set var="from_month">${param.min_year_month eq null ? 1 : fn:substring(param.min_year_month, 4, 6) }</c:set>
<c:set var="to_month">${param.max_year_month eq null ? 12 : fn:substring(param.max_year_month, 4, 6) }</c:set>
<c:set var="sel_year">${param.select_year_month eq null ? currYear : fn:substring(param.select_year_month, 0, 4) }</c:set>
<c:set var="sel_month">${param.select_year_month eq null ? currMonth : fn:substring(param.select_year_month, 4, 6) }</c:set>

<c:set var="show_f" value="${param.show_field}"/><%-- 보여줄 필드 --%>
<c:set var="req_f" value="${param.required_field}"/><%-- 필수 필드 --%>
<c:if test="${fn:contains(show_f, 'year')}">
<select id="${year_name }" name="${year_name }" style="width: 80px;" alt="연도" ${fn:contains(req_f, 'year') ? 'required="required"' : '' } >
	<option value="">- 선택 -</option>
	<c:forEach var="optVal" begin="${from_year }" end="${to_year }">
		<option value="${optVal }" ${optVal eq sel_year ? "selected='selected'" : ""} >${optVal}년</option>
	</c:forEach>
</select>
</c:if>
<c:if test="${fn:contains(show_f, 'month')}">
<select id="${month_name }" name="${month_name }" style="width: 60px;" alt="월" ${fn:contains(req_f, 'month') ? 'required="required"' : '' } >
	<option value="">- 선택 -</option>
	<c:forEach var="optVal" begin="${from_month }" end="${to_month }">
		<option value="${optVal }" ${optVal eq sel_month ? "selected='selected'" : ""} >${optVal}월</option>
	</c:forEach>
</select>
</c:if>