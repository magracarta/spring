<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jstl/fmt_rt" %>
<%-- 년도 보이기 콤보 생성	  
### param 설명 ###
-- <jsp:param name="min_year" value="2000"/> 				==> 시작연도의 최소로 보여주는 연도 (기본년도는 2000년)
-- <jsp:param name="max_year" value="2021"/> 				==> 시작연도의 최대로 보여주는 연도 (기본년도는 올해)	
-- <jsp:param name="plus_minus" value=""/> 				    ==> 시작년도를 현재년도에서 +-로 보여줄 범위 (기본은 미적용, 만약 존재시 min_year, max_year가 있어도 해당값 적용)	
-- <jsp:param name="select_year" value="2021"/>				==> 선택되는 연도 (기본은 올해)
-- <jsp:param name="year_name" value="s_year"/>				==> select 이름(기본 s_year)
-- <jsp:param name="sort_type" value="u"/>				    ==> 연도 정렬기준 (기본은 u) u : 오름차순, d : 내림차순
-- <jsp:param name="change" value="goSearch()"/>				==> 시작연도의 onchange함수 (기본은 없음)
-- <jsp:param name="end_year_yn" value="n"/>				==> 종료년도 출력여부 (기본은 n)
-- <jsp:param name="end_year_name" value="s_end_year"/>		==> 종료년도 select 이름 (기본은 s_end_year)
-- <jsp:param name="end_min_year" value="from_year+1"/>		==> 종료년도의 최소로 보여주는 연도(기본은 from_year + 1년)
-- <jsp:param name="end_max_year" value="to_year+1"/>		==> 종료년도의 최대로 보여주는 연도(기본은 to_year + 1년)
-- <jsp:param name="end_plus_minus" value=""/> 				==> 종료년도를 현재년도에서 +-로 보여줄 범위 (기본은 미적용, 만약 존재시 min_year, max_year가 있어도 해당값 적용)	
-- <jsp:param name="end_select_year" value="2021"/>		    ==> 종료년도의 선택되는 연도 (기본은 올해)
-- <jsp:param name="end_change" value="goSearch()"/>		    ==> 종료년도의 onchange함수 (기본은 없음)
--%>
<%-- 셋팅할 변수 초기화 --%>
<jsp:useBean id="toDay" class="java.util.Date" />
<fmt:formatDate value="${toDay}" pattern="yyyy" var="currYear" />
<fmt:formatDate value="${toDay}" pattern="MM" var="currMonth" />

<c:set var="year_name">${param.year_name eq null ? 's_year' : param.year_name }</c:set>
<c:set var="sel_year">${param.select_year eq null ? currYear : param.select_year }</c:set>
<c:if test="${param.plus_minus eq null}">
	<c:set var="from_year">${param.min_year eq null ? 2000 : param.min_year }</c:set>
	<c:set var="to_year">${param.max_year eq null ? currYear : param.max_year }</c:set>
</c:if>
<c:if test="${param.plus_minus ne null}">
	<c:set var="from_year">${currYear - param.plus_minus }</c:set>
	<c:set var="to_year">${currYear + param.plus_minus}</c:set>
</c:if>


<c:if test="${param.end_year_yn eq 'y'}">
	<div class="form-row inline-pd">
		<div class="col-auto">
</c:if>

<c:if test="${param.sort_type ne 'd'}">
<select id="${year_name }" name="${year_name }" class="form-control" alt="연도" required="required" <c:if test="${param.change ne null }">onchange="javascript:${param.change };"</c:if>>
	<c:forEach var="optVal" begin="${from_year }" end="${to_year }">
		<option value="${optVal }" ${optVal eq sel_year ? "selected='selected'" : ""} >${optVal}년</option>
	</c:forEach>
</select>
</c:if>
<c:if test="${param.sort_type eq 'd'}">
<select id="${year_name }" name="${year_name }" class="form-control" alt="연도" required="required"  <c:if test="${param.change ne null }">onchange="javascript:${param.change };"</c:if>>
	<c:forEach var="optVal" begin="${from_year }" end="${to_year }">
		<option value="${to_year - optVal + from_year }" ${to_year - optVal + from_year eq sel_year ? "selected='selected'" : ""} >${to_year - optVal + from_year}년</option>
	</c:forEach>
</select>
</c:if>

<c:if test="${param.end_year_yn eq 'y'}">
	<c:set var="end_year_name">${param.end_year_name eq null ? 's_year' : param.end_year_name }</c:set>
	<c:set var="end_sel_year">${param.end_select_year eq null ? currYear : param.end_select_year }</c:set>
	<c:if test="${param.end_plus_minus eq null}">
		<c:set var="end_from_year">${param.end_min_year eq null ? from_year + 1 : param.end_min_year }</c:set>
		<c:set var="end_to_year">${param.end_max_year eq null ? to_year + 1 : param.end_max_year }</c:set>
	</c:if>
	<c:if test="${param.end_plus_minus ne null}">
		<c:set var="end_from_year">${currYear - param.end_plus_minus }</c:set>
		<c:set var="end_to_year">${currYear + param.end_plus_minus}</c:set>
	</c:if>
	
	</div>
	<div class="col-auto text-center">~</div>
	<div class="col-auto">
	<c:if test="${param.sort_type ne 'd'}">
		<select id="${end_year_name }" name="${end_year_name }" class="form-control" alt="연도" required="required" <c:if test="${param.end_change ne null }">onchange="javascript:${param.end_change };"</c:if>>
			<c:forEach var="optVal" begin="${end_from_year }" end="${end_to_year }">
				<option value="${optVal }" ${optVal eq end_sel_year ? "selected='selected'" : ""} >${optVal}년</option>
			</c:forEach>
		</select>
	</c:if>
	<c:if test="${param.sort_type eq 'd'}">
		<select id="${end_year_name }" name="${end_year_name }" class="form-control" alt="연도" required="required" <c:if test="${param.end_change ne null }">onchange="javascript:${param.end_change };"</c:if> >
			<c:forEach var="optVal" begin="${end_from_year }" end="${end_to_year }">
				<option value="${end_to_year - optVal + end_from_year }" ${end_to_year - optVal + end_from_year eq end_sel_year ? "selected='selected'" : ""} >${end_to_year - optVal + end_from_year}년</option>
			</c:forEach>
		</select>
	</c:if>
	</div>
</c:if>