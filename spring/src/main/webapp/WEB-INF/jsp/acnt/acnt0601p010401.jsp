<%@ page contentType="text/html;charset=utf-8" language="java" %>
<jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 자산 > 인사관리 > null > 직원관리상세 크게보기 팝업
-- 작성자 : 이강원
-- 최초 작성일 : 2021-07-14 11:51:27
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">

		$(document).ready(function () {

        // by. 재호
        // mem_eval_item_cd 값에 매칭되는 text값
        <c:forEach var="item" items="${memYearEvalList}">
        	<c:choose>
        		<c:when test="${item.mem_eval_item_cd eq '01'}">
        			$("#id_01").val(fnBrTagToReplaceEnter("${item.self_eval_text}"));
        		</c:when>
        		<c:when test="${item.mem_eval_item_cd eq '02'}">
        			$("#id_02").val(fnBrTagToReplaceEnter("${item.self_eval_text}"));
        		</c:when>
				<c:when test="${item.mem_eval_item_cd eq '03'}">
        			$("#id_03").val(fnBrTagToReplaceEnter("${item.self_eval_text}"));
        		</c:when>
        		<c:when test="${item.mem_eval_item_cd eq '04'}">
        			$("#id_04").val(fnBrTagToReplaceEnter("${item.self_eval_text}"));
        		</c:when>
        	</c:choose>
        </c:forEach>

		});

        // by. 재호
        // <br/> -> \r 변환
        function fnBrTagToReplaceEnter(text) {
            return text.replace(/(<br>|<br\/>|<br \/>)/g, '\r\n');
        }


        function fnClose() {
            window.close();
        }

    </script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form" style="height : 100%">
    <!-- 팝업 -->
    <div class="popup-wrap width-100per" style="height : 100%">
        <!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
        <div class="content-wrap" style="height : 90%">
            <table class="table-border mt5" style="height : 90%">
                <colgroup>
                    <col width="10%">
                    <c:forEach var="i" begin="1" end="${inputParam.total_eval_cnt}">
                        <c:if test="${inputParam.total_eval_cnt == 4}">
                            <col width="20%">
                        </c:if>
                        <c:if test="${inputParam.total_eval_cnt == 3}">
                            <col width="25%">
                        </c:if>
                        <c:if test="${inputParam.total_eval_cnt == 2}">
                            <col width="40%">
                        </c:if>
                    </c:forEach>
                </colgroup>
                <thead>
                <%-- Q&A 12133 매니저가 볼 수있는 항목 제외. 210826 김상덕 --%>
                <c:set var="mng_yn" value="${page.fnc.F03049_001 eq 'Y' ? 'Y' : 'N'}"/>
                <tr>
                    <th class="title-bg">항목</th>
                    <c:if test="${mng_yn ne 'Y'}">
	                    <th class="title-bg">본인평가</th>
	                </c:if>
	                <c:if test="${mng_yn ne 'Y'}">
	                    <c:if test="${inputParam.boss_mem_no ne ''}">
	                        <th class="title-bg">상사평가</th>
	                    </c:if>
	                </c:if>
                    <c:if test="${inputParam.mng_eval_yn eq 'Y'}">
                        <th class="title-bg">매니저평가</th>
                    </c:if>
                    <c:if test="${mng_yn ne 'Y'}">
	                    <c:if test="${page.fnc.F03049_001 ne 'Y'}">
	                    	<th class="title-bg">최종평가</th>
	                    </c:if>
	                </c:if>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="item" items="${memYearEvalList}">
                    <tr>
                        <th class="text-center">
                                ${item.mem_eval_item_name }
                        </th>
                        <c:if test="${mng_yn ne 'Y'}">
	                        <th>
	                            <textarea style="height: 100%; background: #E9ECEF" id="id_${item.mem_eval_item_cd}" name="work_text"
	                                      required="required" alt="본인평가"
	                                      readonly="readonly">${item.self_eval_text }</textarea>
	                        </th>
	                    </c:if>
	                    <c:if test="${mng_yn ne 'Y'}">
	                        <c:if test="${inputParam.boss_mem_no ne ''}">
	                            <th>
	                                <textarea style="height: 100%; background: #E9ECEF" id="work_text" name="work_text"
	                                          required="required" alt="상사평가"
	                                          readonly="readonly">${item.boss_eval_text }</textarea>
	                            </th>
	                        </c:if>
	                    </c:if>
                        <c:if test="${inputParam.mng_eval_yn eq 'Y'}">
                            <th>
                                <textarea style="height: 100%; background: #E9ECEF" id="work_text" name="work_text"
                                          required="required" alt="매니저평가"
                                          readonly="readonly">${item.mng_eval_text }</textarea>
                            </th>
                        </c:if>
                        <c:if test="${mng_yn ne 'Y'}">
	                        <th>
	                            <textarea style="height: 100%; background: #E9ECEF" id="work_text" name="work_text"
	                                      required="required" alt="최종평가"
	                                      readonly="readonly">${item.last_eval_text }</textarea>
	                        </th>
	                    </c:if>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div>
        <div class="btn-group mt10">
            <div class="right" style="margin-right:10px;">
                <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
                    <jsp:param name="pos" value="BOM_R"/>
                </jsp:include>
            </div>
        </div>
    </div>
    <!-- /팝업 -->
</form>
</body>
</html>