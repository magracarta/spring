<%@ page contentType="text/html;charset=utf-8" language="java" %>
<jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 부품연관팝업 > 부품연관팝업 > null > 부품문의쪽지팝업
-- 작성자 : 정재호
-- 최초 작성일 : 2022-10-07 10:00:00
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">
        var partNo = '${result.part_no}';
        var partName = '${result.part_name}';

        $(document).ready(function () {
            init();
        });

        // 초기화
        function init() {
            if(partNo != '') {
                $('#part_no').attr("readonly",true);
            }

            if(partName != '') {
                $('#part_name').attr("readonly",true);
            }
        }

        // 모델명 콜백 함수
        function fnSetMachineInfo(data) {
            $M.setValue('maker_name', data.maker_name);
            $M.setValue('machine_name', data.machine_name);
        }

        // 닫기 버튼
        function fnClose() {
            window.close();
        }

        // 쪽지 전송
        function goMessageSend() {
            var frm = document.main_form;

            if($M.validation(frm) == false) {
                return;
            }
            // title_name            : 쪽지 타이틀
            // invoice_send_cd_name : 발송 구분 - 0 : 일반 - 1 : 긴급
            // maker_name           : 메이커 이름
            // machine_name         : 모델명
            // body_no              : 차대번호
            // part_no              : 부품번호
            // part_name            : 부품명
            // qty                  : 필요수량
            $M.setValue(frm, "title_name", $M.getValue("title_name"));
            $M.goNextPageAjax(this_page + "/send", $M.toValueForm(frm), {method: 'POST'},
                function (result) {
                    if (result.success) {
                        alert("쪽지 발송에 성공했습니다.");
                        window.close();
                    }
                }
            );

            console.log($M.toValueForm(frm));
        }

    </script>
</head>
<body class="bg-white class">
<form id="main_form" name="main_form">
    <input type="hidden" name="part_check_yn" id="part_check_yn" value="${result.part_check_yn}" >
    <!-- 팝업 -->
    <div class="popup-wrap width-100per">
        <input type="hidden" name="title_name" id="title_name" alt="쪽지 타이틀" value="${result.title_name}" required="required"/>
        <!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
        <!-- /타이틀영역 -->
        <div class="content-wrap">
            <!-- 폼테이블 -->
            <div>
                <table class="table-border">
                    <colgroup>
                        <col width="100px">
                        <col width="300px">
                    </colgroup>
                    <tbody>
                    <tr>
                        <th class="essential-item">발송구분</th>
                        <td>
                            <div class="form-check form-check-inline">
                                <label for="invoice_send_type_nomal" class="form-check-label">
                                    <input class="form-check-input" type="radio" id="invoice_send_type_nomal"
                                           name="invoice_send_cd_name"
                                           alt="발송구분"
                                           checked="checked" value="0">일반</label>
                            </div>
                            <div class="form-check form-check-inline">
                                <label for="invoice_send_type_emergency" class="form-check-label">
                                    <input class="form-check-input" type="radio" id="invoice_send_type_emergency"
                                           name="invoice_send_cd_name"
                                           alt="발송구분"
                                           value="1">긴급</label>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <th class="essential-item">메이커 / 모델명</th>
                        <td>
                            <div class="form-row inline-pd">
                                <div class="col-auto">
                                    <input type="text" class="form-control width100px" readonly="readonly"
                                           alt="메이커, 모델명"
                                           value="" id="maker_name" name="maker_name" required="required">
                                </div>
                                <div class="col-auto">
                                    <div class="input-group">
                                        <input type="text" class="form-control border-right-0" readonly="readonly"
                                               alt="메이커, 모델명"
                                               id="machine_name" name="machine_name">
                                        <button type="button" class="btn btn-icon btn-primary-gra"
                                                onclick="javascript:openSearchModelPanel('fnSetMachineInfo', 'N');"
                                                id="machineSearchbtn">
                                            <i class="material-iconssearch"></i>
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <th class="essential-item">차대번호</th>
                        <td>
                            <input type="text" id="body_no" name="body_no" class="form-control rb" alt="차대번호" required="required">
                        </td>
                    </tr>
                    <tr>
                        <th class="essential-item">부품번호</th>
                        <td>
                            <input type="text" id="part_no" name="part_no" class="form-control rb" alt="부품번호" value="${result.part_no}" required="required">
                        </td>
                    </tr>
                    <tr>
                        <th class="essential-item">부품명</th>
                        <td>
                            <input type="text" id="part_name" name="part_name" class="form-control rb" alt="부품명" value="${result.part_name}" required="required">
                        </td>
                    </tr>
                    <tr>
                        <th class="essential-item">필요수량</th>
                        <td>
                            <input type="text" id="qty" name="qty" class="form-control rb width80px" alt="필요수량" value="" required="required" format="num">
                        </td>
                    </tr>
                    </tbody>
                </table>
            </div>
            <!-- /폼테이블 -->
            <div class="btn-group mt5">
                <div class="right">
                    <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
                        <jsp:param name="pos" value="BOM_R"/>
                    </jsp:include>
                </div>
            </div>
            <!-- /그리드 서머리, 컨트롤 영역 -->
        </div>
    </div>
    <!-- /팝업 -->
</form>
</body>
</html>