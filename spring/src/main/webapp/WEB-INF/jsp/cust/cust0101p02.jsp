<%@ page contentType="text/html;charset=utf-8" language="java" %>
<jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 고객현황 > 영업대상고객 > null > 간편고객등록
-- 작성자 : 박준영
-- 최초 작성일 : 2020-07-08 10:10:56
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">
        <%-- 여기에 스크립트 넣어주세요. --%>

        $(document).ready(function () {

            $("#cust_name").focus();
            // 핸드폰번호 중복체크 완료 후 번호 변경 시 중복체크 다시 실행
            $("#hp_no").on("propertychange change keyup paste input", function () {
                console.log($M.getValue("lastchk_hp_no") + " / " + $M.getValue("hp_no"));
                if ($M.getValue("lastchk_hp_no") == this.value) {
                    $M.setValue("hp_no_chk", "Y");
                    $("#btn_hp_no_chk").prop("disabled", true);
                } else {
                    $M.setValue("hp_no_chk", "N");
                    $("#btn_hp_no_chk").prop("disabled", false);
                }
                ;
            });

            // fnInitPage();
        });

        function fnInitPage() {
            //본창에 고객정보 있을경우 다시 가져오기
            $M.setValue("cust_name", opener.cust_name.value);
            $M.setValue("hp_no", opener.hp_no.value);
            $M.setValue("sale_area_code", opener.sale_area_code.value);
            $M.setValue("eng_addr", opener.eng_addr.value);
            $M.setValue("post_no", opener.post_no.value);
            $M.setValue("addr1", opener.addr1.value);
            $M.setValue("addr2", opener.addr2.value);
            $M.setValue("sale_mem_name", opener.sale_mem_name.value);
            $M.setValue("service_mem_name", opener.service_mem_name.value);
            $M.setValue("sale_mem_no", opener.sale_mem_no.value);
            $M.setValue("service_mem_no", opener.service_mem_no.value);
            $M.setValue("area_si", opener.area_si.value);
            $M.setValue("hp_no_chk", opener.hp_no_chk.value);
            $M.setValue("center_org_name", opener.center_org_name.value);
            $M.setValue("center_org_code", opener.center_org_code.value);

            //이미 중복체크 된 핸드폰번호면 중복체크완료처리
            if (opener.hp_no_chk.value == "Y") {
                $M.setValue("lastchk_hp_no", $M.getValue("hp_no"));
                $("#btn_hp_no_chk").prop("disabled", true);
            }
        }

        function goHpNoCheck() {

            if ($M.getValue("hp_no") == '' || $M.getValue("hp_no") == undefined) {
                alert("핸드폰 번호를 입력해주세요");
                return;
            }

            if ($M.getValue("hp_no_chk") != "Y") {
                //핸드폰번호 중복체크
                $M.goNextPageAjax("/cust/cust010101/custHpNoCheck/" + $M.getValue("hp_no"), '', {method: 'get'},
                    function (result) {
                        if (result.success) {
                            $M.setValue("hp_no_chk", "Y");
                            $M.setValue("lastchk_hp_no", $M.getValue("hp_no"));
                            $("#btn_hp_no_chk").prop("disabled", true);
                        } else {
                            $M.setValue("hp_no_chk", "N");
                            $("#btn_hp_no_chk").prop("disabled", false);
                        }
                    }
                );
            } else {
                alert("사용가능한 핸드폰 번호 입니다");
            }
        }


        // 담당자조회 결과
        function setSaleAreaInfo(data) {
            $M.setValue("area_si", data.area_si);
            $M.setValue("sale_area_code", data.sale_area_code);
            $M.setValue("center_org_name", data.center_name);
            $M.setValue("center_org_code", data.center_org_code);
            $M.setValue("service_mem_name", data.servie_mem_name);
            $M.setValue("service_mem_no", data.service_mem_no);
            $M.setValue("sale_mem_name", data.sale_mem_name);
            $M.setValue("sale_mem_no", data.sale_mem_no);
        }

        function fnJusoBizOffice(data) {
            $M.setValue("eng_addr", data.engAddr);		//영문주소
            $M.setValue("post_no", data.zipNo);
            $M.setValue("addr1", data.roadAddrPart1);
            $M.setValue("addr2", data.addrDetail);
        }

        // 직원조회 결과
        function fnSetMemberInfo(data) {
            $M.setValue("misu_mem_name", data.mem_name);
            $M.setValue("misu_mem_no", data.mem_no);
        }

        function goSave() {
            var frm = document.main_form;
            // validation check
            if ($M.validation(document.main_form) === false) {
                return;
            }

            if ($M.getValue("hp_no_chk") == "N") {
                alert("핸드폰 번호 중복검사를 진행해주세요");
                return;
            }

            var custInfo = {}; // 선택한 고객관련값
            custInfo['hp_no'] = $M.getValue("hp_no");
            custInfo['cust_name'] = $M.getValue("cust_name");
            custInfo['post_no'] = $M.getValue("post_no");
            custInfo['addr1'] = $M.getValue("addr1");
            custInfo['addr2'] = $M.getValue("addr2");
            custInfo['eng_addr'] = $M.getValue("eng_addr");

            custInfo['sale_area_code'] = $M.getValue("sale_area_code");
            custInfo['area_si'] = $M.getValue("area_si");
            custInfo['center_org_code'] = $M.getValue("center_org_code");
            custInfo['center_org_name'] = $M.getValue("center_org_name");
            custInfo['sale_mem_name'] = $M.getValue("sale_mem_name");
            custInfo['service_mem_name'] = $M.getValue("service_mem_name");
            custInfo['sale_mem_no'] = $M.getValue("sale_mem_no");
            custInfo['service_mem_no'] = $M.getValue("service_mem_no");

            $M.goNextPageAjaxSave(this_page + "/save", $M.toValueForm(frm), {method: 'POST'},
                function (result) {
                    if (result.success) {
                        custInfo['cust_no'] = result.cust_no;
                        opener.${inputParam.parent_js_name}(custInfo);
                        fnClose();
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
<input type="hidden" id="hp_no_chk" name="hp_no_chk" value="N">
<input type="hidden" id="lastchk_hp_no" name="lastchk_hp_no" value="">
<input type="hidden" id="eng_addr" name="eng_addr" value="">
    <!-- 팝업 -->
    <div class="popup-wrap width-100per">
        <!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
        <!-- /타이틀영역 -->
        <div class="content-wrap">
            <!-- 폼테이블 -->
            <div class="contents">
                <table class="table-border mt5">
                    <colgroup>
                        <col width="100px">
                        <col width="">
                    </colgroup>
                    <tbody>
                    <tr>
                        <th class="text-right  essential-item">고객명</th>
                        <td>
                            <input type="text" class="form-control essential-bg width120px" maxlength="10" id="cust_name" name="cust_name" required="required" alt="고객명">
                            <!-- 필수항목일때 클래스 essential-bg 추가 -->
                        </td>
                    </tr>
                    <tr>
                        <th class="text-right essential-item">휴대폰</th>
                        <td>
                            <div class="form-row inline-pd widthfix">
                                <div class="col width110px">
                                    <input type="text" class="form-control essential-bg" id="hp_no" name="hp_no" format="phone" minlength="10" maxlength="11" required="required" alt="핸드폰" placeholder="-없이 숫자만">
                                </div>
                                <div class="col width60px">
                                    <button type="button" id="btn_hp_no_chk" name="btn_hp_no_chk" class="btn btn-primary-gra" style="width: 100%;" onclick="javascript:goHpNoCheck();">중복확인</button>
                                </div>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <th class="text-right">주소</th>
                        <td>
                            <div class="form-row inline-pd mb7">
                                <div class="col width110px">
                                    <input type="int" class="form-control" id="post_no" name="post_no" readonly="readonly" alt="우편번호">
                                </div>
                                <div class="col-auto">
                                    <button type="button" class="btn btn-primary-gra" onclick="javascript:openSearchAddrPanel('fnJusoBizOffice');">주소찾기</button>
                                </div>
                            </div>
                            <div class="form-row inline-pd mb7">
                                <div class="col-7">
                                    <input type="text" class="form-control" id="addr1" name="addr1" readonly="readonly" alt="고객 주소">
                                </div>
                            </div>
                            <div class="form-row inline-pd">
                                <div class="col-7">
                                    <input type="text" class="form-control" id="addr2" name="addr2" alt="고객 상세 주소">
                                </div>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <th class="text-right essential-item">고객담당</th>
                        <td>
                            <div class="form-row inline-pd">
                                <div class="col-auto essential-item spacing-sm">
                                    지역
                                </div>
                                <div class="col-2">
                                    <div class="input-group">
                                        <input type="text" class="form-control border-right-0 essential-bg" id="area_si" name="area_si" required="required" readonly="readonly" alt="고객담당 지역">
                                        <input type="hidden" id="sale_area_code" name="sale_area_code"/>
                                        <button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchSaleAreaPanel('setSaleAreaInfo');"><i class="material-iconssearch"></i></button>
                                    </div>
                                </div>
                                <div class="col-auto essential-item spacing-sm">
                                    담당센터
                                </div>
                                <div style="width: 80px;">
                                    <input type="text" class="form-control essential-bg" id="center_org_name" name="center_org_name" alt="고객 담당 센터" readonly="readonly" required="required">
                                    <input type="hidden" id="center_org_code" name="center_org_code">
                                </div>
                                <div class="col-auto essential-item spacing-sm">
                                    서비스담당
                                </div>
                                <div style="width: 80px;">
                                    <input type="text" class="form-control essential-bg" id="service_mem_name" name="service_mem_name" alt="고객 서비스 담당 직원" readonly="readonly" required="required">
                                    <input type="hidden" id="service_mem_no" name="service_mem_no">
                                </div>
                                <div class="col-auto essential-item  spacing-sm">
                                    마케팅담당
                                </div>
                                <div style="width: 80px;">
                                    <input type="text" class="form-control essential-bg" id="sale_mem_name" name="sale_mem_name" alt="마케팅 담당 직원" readonly="readonly" required="required">
                                    <input type="hidden" id="sale_mem_no" name="sale_mem_no">
                                </div>
                            </div>
                        </td>
                    </tr>
                    </tbody>
                </table>
            </div>
            <!-- /폼테이블 -->
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