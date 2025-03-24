<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 인사 > 고과평가관리 > null > 메이커별 정비시간
-- 작성자 : 김태훈
-- 최초 작성일 : 2021-04-09 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>
	
		$(document).ready(function() {
			
		});
		
		// 닫기
	    function fnClose() {
	    	window.close();
	    }
		
	</script>
</head>
<body class="bg-white" >
<form id="main_form" name="main_form">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
        	<c:if test="${inputParam.s_amt_yn eq 'Y'}">
        		<h2>메이커별 비용</h2>
        	</c:if>
        	<c:if test="${inputParam.s_amt_yn ne 'Y'}">
            	<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
            </c:if>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
        	<table class="table-border mt5">
                <colgroup>
                    <col width="">
                    <col width="">
                </colgroup>
                <tbody>
                	<c:forEach var="item" items="${list}">
                		<tr>
	                        <th>${item.maker_name}</th>
	                        <c:if test="${inputParam.s_amt_yn eq 'Y'}">
	                        	<td style="text-align: right;"><fmt:formatNumber value="${item.total_cnt}" pattern="#,###"/>원</td>
	                        </c:if>
	                        <c:if test="${inputParam.s_amt_yn ne 'Y'}">
	                        	<td style="text-align: right;">${item.total_cnt}hr</td>
	                        </c:if>
	                        							
	                    </tr>
                	</c:forEach>
                </tbody>			
            </table>				
			<div class="btn-group mt10">
				<div class="right">
					<button type="button" id="_fnClose" class="btn btn-info" onclick="javascript:fnClose();" style="width: 60px;">닫기</button>	
				</div>
			</div>
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>