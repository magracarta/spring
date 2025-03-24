<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 거래현황 > 마일리지관리 > 전표관리 > 상세
-- 작성자 : 한승우
-- 최초 작성일 : 2023-08-14 14:21:00
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">
        $(document).ready(function () {
        });

        function fnClose() {
            window.close();
        }

        // 매출전표가 임시 상태거나 삭제되었으면 매출적립 마일리지여도 버튼 노출 안 됨
        // 매출전표상세 팝업
        function goSaleInoutDoc(){
            var params = {
                inout_doc_no : $M.getValue("sale_inout_doc_no")
            };
            var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1300, height=780, left=0, top=0";
            $M.goNextPage('/cust/cust0202p01', $M.toGetParam(params), {popupStatus : popupOption});
        }

        // 매출전표상세(반품) 팝업
        function goReturnInoutDoc(){
            var params = {
                inout_doc_no : $M.getValue("return_inout_doc_no")
            };
            var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1300, height=780, left=0, top=0";
            $M.goNextPage('/cust/cust0202p01', $M.toGetParam(params), {popupStatus : popupOption});
        }

        // 매출전표상세(조기회수) 팝업
        function goEarlyReturnInoutDoc(){
            var params = {
                inout_doc_no : $M.getValue("early_return_inout_doc_no")
            };
            var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1300, height=780, left=0, top=0";
            $M.goNextPage('/cust/cust0202p01', $M.toGetParam(params), {popupStatus : popupOption});
        }

        function goModify(){
            var param = {
                "cust_mile_no" : $M.getValue("cust_mile_no")
            };

            $M.goNextPageAjax(this_page+"/chkMileStat", $M.toGetParam(param), {method : "get"},
                function(result) {
                    if(result.success) {
                        if(result.mile_use_yn == "Y"){
                            alert("사용하지 않은 마일리지만 수정가능합니다.");
                            return;
                        }

                        if(result.expire_yn == "Y"){
                            alert("마감되지 않은 마일리지만 수정가능합니다.");
                            return;
                        }

                        if(result.duzon_trans_yn == "Y"){
                            alert("회계처리되지 않은 마일리지만 수정가능합니다.");
                            return;
                        }

                        if ($M.getValue("mile_amt") <= 0 ){
                            alert("마일리지금액은 0보다 큰 값만 지정 가능합니다.");
                            return;
                        }

                        var frm = document.main_form;

                        // validation check
                        if($M.validation(frm) === false) {
                            return;
                        };

                        frm = $M.toValueForm(frm);
                        console.log("frm : ", frm);

                        $M.goNextPageAjaxModify(this_page + "/modify", frm, {method : 'POST'},
                            function(result) {
                                if(result.success) {
                                    fnClose();
                                    window.opener.goSearch();
                                };
                            }
                        );
                        return;
                    } else {
                        alert("올바르지 않은 정보입니다.");
                        return;
                    }
                }
            );
        }

        function goRemove(){
            var param = {
                "cust_mile_no" : $M.getValue("cust_mile_no")
            };

            $M.goNextPageAjax(this_page+"/chkMileStat", $M.toGetParam(param), {method : "get"},
                function(result) {
                    if(result.success) {
                        if(result.mile_use_yn == "Y"){
                            alert("사용하지 않은 마일리지만 삭제가능합니다.");
                            return;
                        }

                        if(result.expire_yn == "Y"){
                            alert("마감되지 않은 마일리지만 삭제가능합니다.");
                            return;
                        }

                        if(result.duzon_trans_yn == "Y"){
                            alert("회계처리되지 않은 마일리지만 삭제가능합니다.");
                            return;
                        }

                        var frm = document.main_form;

                        // validation check
                        if($M.validation(frm) === false) {
                            return;
                        };

                        frm = $M.toValueForm(frm);
                        console.log("frm : ", frm);

                        $M.goNextPageAjaxRemove(this_page + "/remove", frm, {method : 'POST'},
                            function(result) {
                                if(result.success) {
                                    fnClose();
                                    window.opener.goSearch();
                                };
                            }
                        );
                        return;
                    } else {
                        alert("올바르지 않은 정보입니다.");
                        return;
                    }
                }
            );
        }

    </script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
    <input type="hidden" id="cust_mile_no" name="cust_mile_no" value="${result.cust_mile_no}" required="required">
    <input type="hidden" id="cust_no" name="cust_no" value="${result.cust_no}" required="required">
    <input type="hidden" id="org_code" name="org_code" value="${result.org_code}" required="required">
    <input type="hidden" id="sale_inout_doc_no" name="sale_inout_doc_no" value="${result.sale_inout_doc_no}" required="required">
    <input type="hidden" id="return_inout_doc_no" name="return_inout_doc_no" value="${result.return_inout_doc_no}" required="required">
    <input type="hidden" id="early_return_inout_doc_no" name="early_return_inout_doc_no" value="${result.early_return_inout_doc_no}" required="required">
    <!-- 팝업 -->
    <div class="popup-wrap width-100per">
        <!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
        <!-- /타이틀영역 -->
        <!-- contents 전체 영역 -->
        <div class="content-wrap" >
            <!-- 폼테이블 -->
            <div>
                <table class="table-border">
                    <colgroup>
                        <col width="100px">
                        <col width="">
                        <col width="100px">
                        <col width="">
                    </colgroup>
                    <tbody>
                    <tr>
                        <th class="text-right">전표번호</th>
                        <td>
                            <input type="text" class="form-control width120px" id="inout_doc_no" name="inout_doc_no" value="${result.inout_doc_no}"  readonly="readonly" required="required">
                        </td>
                        <th class="text-right">전표일자</th>
                        <td>
                            <div class="input-group width120px">
                                <input type="text" class="form-control border-right-0 calDate rb" id="inout_dt" name="inout_dt" disabled="disabled" alt="전표일자" value="${result.reg_dt}">
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <th class="text-right">고객명</th>
                        <td>
                            <input type="text" class="form-control width100px" id="cust_name" name="cust_name" alt="고객명" value="${result.cust_name}" readonly="readonly">
                        </td>
                        <th class="text-right">연락처</th>
                        <td>
                            <input type="text" class="form-control width100px" id="cust_hp_no" name="cust_hp_no" alt="연락처" value="${result.hp_no}" readonly="readonly" >
                        </td>
                    </tr>
                    <tr>
                        <th class="text-right">업체명</th>
                        <td>
                            <input type="text" class="form-control width120px" id="breg_name" name="breg_name" value="${result.breg_name}" readonly="readonly">
                        </td>
                        <th class="text-right">대표자</th>
                        <td>
                            <input type="text" class="form-control width120px" id="breg_rep_name" name="breg_rep_name" value="${result.breg_rep_name}" readonly="readonly">
                        </td>
                    </tr>
                    <tr>
                        <th class="text-right">사업자No</th>
                        <td>
                            <div class="form-row inline-pd widthfix">
                                <div class="col width160px">
                                    <input type="text" class="form-control" id="breg_no" name="breg_no" value="${result.breg_no}" readonly="readonly">
                                </div>
                            </div>
                        </td>
                        <th class="text-right">누적마일리지</th>
                        <td>
                            <div class="form-row inline-pd widthfix">
                                <div class="col width120px">
                                    <input type="text" class="form-control" id="total_amt" name="total_amt" value="${result.total_amt}" format="decimal" readonly="readonly">
                                </div>
                                <div class="col width16px">원</div>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <th class="text-right">주소</th>
                        <td colspan="3">
                            <div class="form-row inline-pd mb7 widthfix">
                                <div class="col-3">
                                    <input type="text" class="form-control" id="biz_post_no" name="biz_post_no" value="${result.biz_post_no}"  readonly="readonly">
                                </div>
                                <div class="col-9">
                                    <input type="text" class="form-control" id="biz_addr1" name="biz_addr1" value="${result.biz_addr1}" readonly="readonly">
                                </div>
                            </div>
                            <div class="form-row inline-pd">
                                <div class="col-12">
                                    <input type="text" class="form-control" id="biz_addr2" name="biz_addr2" value="${result.biz_addr2}" readonly="readonly" >
                                </div>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <th class="text-right">적립 발행구분</th>
                        <td colspan="3">
<%--                            <select class="form-control width120px essential-bg" id="mile_issue_cd" name="mile_issue_cd" required="required" alt="발행구분">--%>
<%--                                <c:forEach var="item" items="${codeMap['MILE_ISSUE']}">--%>
<%--                                    <c:if test="${item.code_name ne '부품' && item.code_name ne '정비' && item.code_name ne '렌탈'}">--%>
<%--                                        <option value="${item.code_value}">${item.code_name}</option>--%>
<%--                                    </c:if>--%>
<%--                                </c:forEach>--%>
<%--                            </select>--%>
                            <div class="form-row inline-pd widthfix">
                                <div class="col width120px">
                                    <input type="text" class="form-control width110px" id="mile_issue_name" name="mile_issue_name" value="${result.mile_issue_name}" readonly="readonly" />
                                </div>
                                <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_L"/></jsp:include>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <th class="text-right">적립일자</th>
                        <td>
                            <input type="text" class="form-control width120px" id="issue_dt" name="issue_dt"  value="${result.issue_dt}" readonly="readonly">
                        </td>
                        <th class="text-right">적립마일리지</th>
                        <td>
                            <input type="text" class="form-control width120px" id="mile_amt" name="mile_amt" format="decimal" value="${result.mile_amt}" ${result.end_yn == 'Y' ? 'readonly="readonly"' : ''} required="required" readonly="readonly">
                        </td>
                    </tr>
                    <tr>
                        <th class="text-right">소멸일자</th>
                        <td>
                            <input type="text" class="form-control width120px" id="lost_dt" name="lost_dt"  value="${result.lost_dt}" readonly="readonly" >
                        </td>
                        <th class="text-right">소멸마일리지</th>
                        <td>
                            <input type="text" class="form-control width120px" id="lost_amt" name="lost_amt" format="decimal" value="${result.lost_amt}" readonly="readonly">
                        </td>
                    </tr>
                    <tr>
                        <th class="text-right">처리자</th>
                        <td>
                            <input type="text" class="form-control width120px" id="proc_mem_name" name="proc_mem_name"  value="${result.proc_mem_name}" readonly="readonly">
                        </td>
                        <th class="text-right">처리일자</th>
                        <td>
                            <input type="text" class="form-control width120px" id="proc_dt" name="proc_dt"  value="${result.proc_dt}" readonly="readonly">
                        </td>
                    </tr>
                    <tr>
                        <th class="text-right">비고</th>
                        <td colspan="3">
                            <textarea class="form-control" id="remark" name="remark" readonly="readonly" style="height: 50px;">${result.remark}</textarea>
                        </td>
                    </tr>
                    </tbody>
                </table>
            </div>
            <!-- /폼테이블 -->
            <!-- 그리드 서머리, 컨트롤 영역 -->
            <div class="btn-group mt5">
                <div class="right">
                    <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
                </div>
            </div>
            <!-- /그리드 서머리, 컨트롤 영역 -->
        </div>
        <!-- /contents 전체 영역 -->
    </div>
    <!-- /팝업 -->
</form>
</body>
</html>
