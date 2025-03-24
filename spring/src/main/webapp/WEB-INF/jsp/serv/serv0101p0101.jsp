<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 정비 > 정비지시서 > null > 정비지시서 상세
-- 작성자 : 성현우
-- 최초 작성일 : 2020-06-11 19:54:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript" src="/static/js/qrcode.min.js"></script>
    <script type="text/javascript">
        // 문자발송
        function goSend() {
            var frm = document.main_form;
            if($M.validation(frm) == false) {
                return;
            }

            var confirmMsg ="발송하시겠습니까?";
            $M.goNextPageAjaxMsg(confirmMsg, this_page+"/sendSms", $M.toValueForm(frm), {method : 'POST'},
                function(result) {
                    if(result.success) {
                        try{
                            opener.${inputParam.parent_js_name}($M.getValue("row_index"), result.sms_send_seq);
                            window.close();
                        } catch(e) {
                            alert('호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.');
                        }
                    }
                }
            );
        }

        // 닫기
        function fnClose() {
            window.close();
        }
    </script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
    <input type="hidden" name="row_index" id="row_index" value="${inputParam.row_index}">
    <input type="hidden" name="job_report_no" id="job_report_no" value="${inputParam.job_report_no}">
    <input type="hidden" name="as_no" id="as_no" value="${inputParam.as_no}">
    <input type="hidden" name="seq_no" id="seq_no" value="${inputParam.seq_no}">
    <input type="hidden" name="eng_mem_no" id="eng_mem_no" value="${inputParam.eng_mem_no}">
    <input type="hidden" name="travel_area_name" id="travel_area_name" value="${inputParam.travel_area_name}">
    <input type="hidden" name="start_ti" id="start_ti" value="${inputParam.start_ti}">
    <input type="hidden" name="cust_name" id="cust_name" value="${inputParam.cust_name}">
    <!-- 팝업 -->
    <div class="popup-wrap width-100per">
        <!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
        <!-- /타이틀영역 -->
        <div class="content-wrap">
            <div class="font-11 text-secondary"></div>
            <div class="row mt10">
                <table class="table-border mt5">
                    <colgroup>
                        <col width="140px">
                        <col width="">
                    </colgroup>
                    <tbody>
                    <tr>
                        <th class="text-right essential-item">고객 연락처</th>
                        <td>
                            <input type="text" id="cust_hp_no" name="cust_hp_no" class="form-control essential-bg width200px" required="required" alt="연락처"
                                   maxlength="11" minlength="10" placeholder="휴대폰 번호('-'없이 입력)" format="phone" value="${inputParam.hp_no}">
                        </td>
                    </tr>
                    <tr>
                        <th class="text-right essential-item">도착예정시간</th>
                        <td>
                            <select class="form-control essential-bg width80px" id="arrival_plan_ti" name="arrival_plan_ti">
                                <c:forEach var="hr" varStatus="i" begin="6" end="23" step="1">
                                    <c:forEach var="min" varStatus="j" begin="0" end="1">
                                        <c:if test="${fn:substring(inputParam.start_ti,0,2) < hr
                                            or (fn:substring(inputParam.start_ti,0,2) eq hr and fn:substring(inputParam.start_ti,2,4) < 30 and min eq 1)}">
                                            <option value="<c:if test="${hr < 10}">0</c:if><c:out value="${hr}"/><c:out value="${min eq 0 ? '00' : '30'}"/>">
                                                <c:if test="${hr < 10}">0</c:if><c:out value="${hr}"/>:<c:out value="${min eq 0 ? '00' : '30'}"/>
                                            </option>
                                        </c:if>
                                    </c:forEach>
                                </c:forEach>
                            </select>
                        </td>
                    </tr>
                    <tr>
                        <th class="text-right essential-item">담당기사 연락처</th>
                        <td>
                            <input type="text" id="eng_mem_hp_no" name="eng_mem_hp_no" class="form-control essential-bg width200px" required="required" alt="담당기사 연락처"
                                   maxlength="11" minlength="10" placeholder="휴대폰 번호('-'없이 입력)" format="phone" value="">
                        </td>
                    </tr>
                    </tbody>
                </table>
            </div>
            <!-- /하단 폼테이블 -->
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
