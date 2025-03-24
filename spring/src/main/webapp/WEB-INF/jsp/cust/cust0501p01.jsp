<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 고객 App관리 > 앱 고객정보관리 > 앱 고객정보 상세
-- 작성자 : 정선경
-- 최초 작성일 : 2023-07-26 10:44:37
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">

        $(document).ready(function() {
            fnInit();
        });

        // 화면 초기화
        function fnInit() {
            // 탈퇴고객은 전체 버튼 비활성화, 저장버튼 미노출
            if ($M.getValue("c_cust_status_cd") == "03") {
                $("#approval_check").attr("disabled", true);
                $("#btn_custSearch").attr("disabled", true);
                $("#_goWithdraw").attr("disabled", true);
                $("#_fnAddCust").attr("disabled", true);
                $("#_goMappingRemove").attr("disabled", true);
                $("#_fnCustDetailPopup").attr("disabled", true);
                $("#_goSave").hide();
            } else {
                // 이외 고객 상태에 따라 활성화/비활성화 처리
                if ($M.getValue("c_cust_status_cd") != "01") {
                    $("#approval_check").attr("disabled", true);
                }
                if ($M.getValue("c_cust_status_cd") != "01" && $M.getValue("cust_no") != "") {
                    $("#_fnAddCust").attr("disabled", true);
                    $("#btn_custSearch").attr("disabled", true);
                } else {
                    $("#_goMappingRemove").attr("disabled", true);
                    if ($M.getValue("cust_no") == "") {
                        $("#_fnCustDetailPopup").attr("disabled", true);
                    }
                }
            }
        }

        // 매칭이력 팝업
        function fnCustMappingListPopup() {
            var param = {
                app_cust_no : $M.getValue("app_cust_no")
            }
            $M.goNextPage("/cust/cust0501p02", $M.toGetParam(param), {popupStatus : ""});
        }

        // 고객대장 팝업
        function fnCustDetailPopup() {
            var param = {
                "cust_no" : $M.getValue("cust_no")
            };

            var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=750, left=0, top=0";
            $M.goNextPage('/cust/cust0102p01/', $M.toGetParam(param), {popupStatus : poppupOption});
        }

        // 탈퇴처리
        function goWithdraw() {
            var param = {
                "app_cust_no": $M.getValue("app_cust_no")
            }
            var msg = "탈퇴처리 시 복원이 불가능합니다.\n탈퇴처리 하시겠습니까?";
            $M.goNextPageAjaxMsg(msg, this_page + "/withdraw", $M.toGetParam(param), {method: "POST"},
                function (result) {
                    if (result.success) {
                        fnClose();
                        opener.goSearch();
                    }
                }
            );
        }

        // 고객신규등록 팝업
        function fnAddCust() {
            var param = {
                "s_popup_yn" : "Y",
                "parent_js_name" : "fnSetCustInfo",
                "cust_name": $M.getValue("app_cust_name"),
                "hp_no": $M.getValue("hp_no"),
                "post_no": $M.getValue("post_no"),
                "addr1": $M.getValue("addr1"),
                "addr2": $M.getValue("addr2"),
                "email": $M.getValue("email"),
                "solar_cal_yn": $M.getValue("solar_cal_yn"),
                "birth_dt": $M.getValue("birth_dt")
            };
            $M.goNextPage("/cust/cust010201", $M.toGetParam(param), {popupStatus : getPopupProp(720, 330)});
        }

        // 앱고객정보 세팅
        function fnSetCustInfo(data) {
            var param = {
                "cust_no": data.cust_no
            }
            $M.goNextPageAjax(this_page + "/mappingYn", $M.toGetParam(param), {method: "GET"},
                function (result) {
                    if (result.success) {
                        var param = {};
                        if (result.mapping_yn == "Y") {
                            alert("다른 앱고객과 매칭된 고객입니다. 확인 후 진행해주세요.");
                            param = {
                                "cust_no": "",
                                "cust_name": "",
                                "cust_hp_no": "",
                                "cust_email": "",
                                "cust_birth_dt": "",
                                "cust_solar_cal_yn": "",
                                "cust_post_no": "",
                                "cust_addr1": "",
                                "cust_addr2": ""
                            }
                        } else {
                            param = {
                                "cust_no": data.cust_no,
                                "cust_name": data.real_cust_name,
                                "cust_hp_no": data.real_hp_no,
                                "cust_email": data.email,
                                "cust_birth_dt": data.birth_dt.replaceAll("-", ""),
                                "cust_solar_cal_yn": data.solar_cal_yn,
                                "cust_post_no": data.post_no,
                                "cust_addr1": data.addr1,
                                "cust_addr2": data.addr2
                            }
                        }
                        $M.setValue(param);
                    }
                }
            );
        }

        // 매칭해제
        function goMappingRemove() {
            var param = {
                "app_cust_no": $M.getValue("app_cust_no")
            }
            var msg = "기존 고객과 매칭된 연결고리를 해제하시겠습니까?";
            $M.goNextPageAjaxMsg(msg, this_page + "/mapping/remove", $M.toGetParam(param), {method: "POST"},
                function (result) {
                    if (result.success) {
                        location.reload();
                        opener.goSearch();
                    }
                }
            );
        }

        // 저장
        function goSave() {
            var frm = document.main_form;
            if ($M.validation(frm) == false) {
                return false;
            }

            var param = {
                "app_cust_no": $M.getValue("app_cust_no"),
                "c_cust_status_cd": $M.getValue("c_cust_status_cd"),
                "email": $M.getValue("email"),
                "birth_dt": $M.getValue("birth_dt"),
                "solar_cal_yn": $M.getValue("solar_cal_yn"),
                "post_no": $M.getValue("post_no"),
                "addr1": $M.getValue("addr1"),
                "addr2": $M.getValue("addr2"),
                "marketing_yn": $M.getValue("marketing_yn"),
                "approval_yn": $M.getValue("approval_yn"),
                "cust_no": $M.getValue("cust_no"),
                "center_org_code": $M.getValue("center_org_code")
            };

            // 승인필요 상태에서 '승인' 체크시 고객매칭 필수
            if ($M.getValue("c_cust_status_cd") == "01" && $M.getValue("approval_yn") == "Y" && $M.getValue("cust_no") == "") {
                alert("승인처리는 고객 매칭 후 가능합니다.");
                return false;
            }

            $M.goNextPageAjaxSave(this_page + "/save", $M.toGetParam(param), {method : 'POST'},
                function (result) {
                    if (result.success) {
                        location.reload();
                        opener.goSearch();
                    }
                }
            );
        }

        // 체크변경
        function fnCheckChange(name) {
            var checkYn = $("input:checkbox[name='"+name+"_check']").is(":checked");
            if(checkYn) {
                $M.setValue(name+"_yn", "Y");
            } else {
                $M.setValue(name+"_yn", "N");
            }

            if (name == "marketing") {
                if (checkYn) {
                    $M.setValue(name+"_dt", $M.getCurrentDate());
                } else {
                    $M.setValue(name+"_dt", "");
                }
            }
        }

        // 주소결과
        function fnSetAddr(data) {
            var param = {
                "post_no" : data.zipNo,
                "addr1" : data.roadAddr,
                "addr2" : data.addrDetail
            }
            $M.setValue(param);
        }

        // 문자전송
        function goSendSms(gubun) {
            var name = $M.getValue("cust_name");
            var hpNo = $M.getValue("cust_hp_no");
            if (gubun == "app") {
                name = $M.getValue("app_cust_name");
                hpNo = $M.getValue("hp_no");
            }

            var param = {
                "name" : name,
                "hp_no" : hpNo
            }
            openSendSmsPanel($M.toGetParam(param));
        }

        // 이메일전송
        function fnSendMail(gubun) {
            var to = $M.getValue('cust_email');
            if (gubun == "app") {
                to = $M.getValue("email");
            }

            var param = {
                "to" : to
            };
            openSendEmailPanel($M.toGetParam(param));
        }

        // 닫기
        function fnClose() {
            window.close();
        }

    </script>
</head>

<body>
<form id="main_form" name="main_form">
    <input type="hidden" id="app_cust_no" name="app_cust_no" value="${result.app_cust_no}">
    <input type="hidden" id="c_cust_status_cd" name="c_cust_status_cd" value="${result.c_cust_status_cd}">
    <input type="hidden" id="center_org_code" name="center_org_code" value="${result.center_org_code}">

    <!-- 팝업 -->
    <div class="popup-wrap width-100per">
        <!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp" />
        </div>
        <!-- /타이틀영역 -->
        <div class="content-wrap">
            <!-- 앱 고객정보 상세 -->
            <div class="title-wrap">
                <h4>앱 고객정보 상세</h4>
            </div>
            <table class="table-border">
                <colgroup>
                    <col width="100px">
                    <col width="">
                    <col width="100px">
                    <col width="">
                </colgroup>
                <tbody>
                <tr>
                    <th class="text-right">가입일자</th>
                    <td>
                        <div class="input-group">
                            <input type="text" class="form-control border-right-0 calDate" id="reg_dt" name="reg_dt" value="<fmt:formatDate value="${result.reg_date}" pattern="yyyy-MM-dd"/>" alt="가입일자" disabled>
                        </div>
                    </td>
                    <th class="text-right">아이디</th>
                    <td>
                        <div class="form-row inline-pd">
                            <div class="col width110px">
                                <input type="text" id="web_id" name="web_id" value="${result.web_id}" class="form-control" alt="아이디" readonly>
                            </div>
                            <div class="col-auto">
                                <button type="button" class="btn btn-primary-gra" onclick="javascript:fnCustMappingListPopup();">매칭이력</button>
                            </div>
                        </div>
                    </td>
                </tr>
                <tr>
                    <th class="text-right">고객명</th>
                    <td>
                        <input type="text" id="app_cust_name" name="app_cust_name" value="${result.app_cust_name}" class="form-control" alt="앱고객명" readonly>
                    </td>
                    <th class="text-right">휴대폰</th>
                    <td>
                        <div class="input-group" >
                            <input type="text" class="form-control border-right-0" value="${result.hp_no}" id="hp_no" name="hp_no" format="phone" readonly="readonly">
                            <button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goSendSms('app');"><i class="material-iconsforum"></i></button>
                        </div>
                    </td>
                </tr>
                <tr>
                    <th class="text-right">이메일</th>
                    <td>
                        <div class="form-row inline-pd">
                            <div class="col-10">
                                <input type="text" class="form-control" id="email" name="email" format="email" value="${result.email}" alt="이메일">
                            </div>
                            <div class="col-2">
                                <button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSendMail('app');"><i class="material-iconsmail"></i></button>
                            </div>
                        </div>
                    </td>
                    <th class="text-right">휴대폰인증여부</th>
                    <td>
                        <input type="text" id="proc_date" name="proc_date" value="<fmt:formatDate value="${result.proc_date}" pattern="yyyy-MM-dd HH:mm "/>${result.hp_auth_yn}" class="form-control" alt="휴대폰인증여부" readonly>
                    </td>
                </tr>
                <tr>
                    <th class="text-right">생년월일</th>
                    <td>
                        <div class="form-row inline-pd">
                            <diYK_ERP_NEWv class="col-6">
                                <div class="input-group">
                                    <input type="text" class="form-control border-right-0 calDate" dateFormat="yyyy-MM-dd" id="birth_dt" name="birth_dt" value="${result.birth_dt}" alt="생년월일">
                                </div>
                            </diYK_ERP_NEWv>
                            <div class="col-6">
                                <div class="form-check form-check-inline">
                                    <input class="form-check-input" type="radio" id="solar_cal_y" name="solar_cal_yn" value="Y" ${result.solar_cal_yn == 'Y' ? 'checked="checked"' : ''}>
                                    <label class="form-check-label" for="solar_cal_y">양력</label>
                                </div>
                                <div class="form-check form-check-inline">
                                    <input class="form-check-input" type="radio" id="solar_cal_n" name="solar_cal_yn" value="N" ${result.solar_cal_yn == 'N' ? 'checked="checked"' : ''}>
                                    <label class="form-check-label" for="solar_cal_n">음력</label>
                                </div>
                            </div>
                        </div>
                    </td>
                    <th class="text-right">탈퇴처리일</th>
                    <td>
                        <div class="form-row inline-pd">
                            <div class="col-auto">
                                <div class="input-group">
                                    <input type="text" class="form-control border-right-0 calDate" dateFormat="yyyy-MM-dd" id="withdraw_dt" name="withdraw_dt" value="${result.withdraw_dt}" alt="탈퇴처리일" disabled>
                                </div>
                            </div>
                            <div class="col-auto">
                                <button type="button" id="_goWithdraw" class="btn btn-primary-gra" onclick="goWithdraw();">탈퇴처리</button>
                            </div>
                        </div>
                    </td>
                </tr>
                <tr>
                    <th class="text-right essential-item">주소</th>
                    <td colspan="3">
                        <div class="form-row inline-pd mb7">
                            <div class="col width120px">
                                <input type="text" class="form-control" readonly="readonly" id="post_no" name="post_no" alt="우편번호" value="${result.post_no}" required="required">
                            </div>
                            <div class="col-auto">
                                <button type="button" class="btn btn-primary-gra" style="width: 60px;" onclick="javascript:openSearchAddrPanel('fnSetAddr');">주소찾기</button>
                            </div>
                            <div class="col-8">
                                <input type="text" class="form-control width-100per" readonly="readonly" id="addr1" name="addr1" alt="주소" value="${result.addr1}" required="required">
                            </div>
                        </div>
                        <div class="form-row inline-pd">
                            <div class="col-12">
                                <input type="text" class="form-control"  id="addr2" name="addr2" alt="상세주소" value="${result.addr2}">
                            </div>
                        </div>
                    </td>
                </tr>
                <tr>
                    <th class="text-right">약관 동의 완료</th>
                    <td colspan="3">
                        <div class="form-row inline-pd mb7 widthfix">
                            <div class="col-4">
                                <div class="form-check form-check-inline">
                                    <input class="form-check-input" type="checkbox" id="use_agree_check" name="use_agree_check" disabled value="Y" ${result.use_agree_yn == 'Y'? 'checked="checked"' : ''}>
                                    <label class="form-check-label mr5">이용약관 동의</label>
                                    <input type="hidden" id="use_agree_yn" name="use_agree_yn" value="${result.use_agree_yn}">
                                </div>
                            </div>
                            <div class="col-2 text-right">확인일자</div>
                            <div class="col-auto">
                                <div class="input-group">
                                    <input type="text" class="form-control border-right-0 calDate" id="use_agree_dt" name="use_agree_dt" dateFormat="yyyy-MM-dd"
                                           value="${result.use_agree_dt}" readonly="readonly" disabled>
                                </div>
                            </div>
                        </div>
                        <div class="form-row inline-pd mb7 widthfix">
                            <div class="col-4">
                                <div class="form-check form-check-inline">
                                    <input class="form-check-input" type="checkbox" id="personal_check" name="personal_check" disabled value="Y" ${result.personal_yn == 'Y'? 'checked="checked"' : ''}>
                                    <label class="form-check-label mr5">개인정보 수집동의</label>
                                    <input type="hidden" id="personal_yn" name="personal_yn" value="${result.personal_yn}">
                                </div>
                            </div>
                            <div class="col-2 text-right">확인일자</div>
                            <div class="col-auto">
                                <div class="input-group">
                                    <input type="text" class="form-control border-right-0 calDate" id="personal_dt" name="personal_dt" dateFormat="yyyy-MM-dd"
                                           value="${result.personal_dt}" readonly="readonly" disabled>
                                </div>
                            </div>
                        </div>
                        <div class="form-row inline-pd mb7 widthfix">
                            <div class="col-4">
                                <div class="form-check form-check-inline">
                                    <input class="form-check-input" type="checkbox" id="three_check" name="three_check" disabled  value="Y" ${result.three_yn == 'Y'? 'checked="checked"' : ''}>
                                    <label class="form-check-label mr5">제 3자 정보제공동의</label>
                                    <input type="hidden" id="three_yn" name="three_yn" value="${result.three_yn}">
                                </div>
                            </div>
                            <div class="col-2 text-right">확인일자</div>
                            <div class="col-auto">
                                <div class="input-group">
                                    <input type="text" class="form-control border-right-0 calDate" id="three_dt" name="three_dt" dateFormat="yyyy-MM-dd"
                                           value="${result.three_dt}" readonly="readonly" disabled>
                                </div>
                            </div>
                        </div>
                        <div class="form-row inline-pd widthfix">
                            <div class="col-4">
                                <div class="form-check form-check-inline">
                                    <input class="form-check-input" type="checkbox" id="marketing_check" name="marketing_check" value="Y"
                                           onchange="javascript:fnCheckChange('marketing');" ${result.marketing_yn == 'Y'? 'checked="checked"' : ''}>
                                    <label class="form-check-label mr5">마케팅 활용동의</label>
                                    <input type="hidden" id="marketing_yn" name="marketing_yn" value="${result.marketing_yn}">
                                </div>
                            </div>
                            <div class="col-2 text-right">확인일자</div>
                            <div class="col-auto">
                                <div class="input-group">
                                    <input type="text" class="form-control border-right-0 calDate" id="marketing_dt" name="marketing_dt" dateFormat="yyyy-MM-dd"
                                           value="${result.marketing_dt}" readonly="readonly" disabled>
                                </div>
                            </div>
                        </div>
                    </td>
                </tr>
                </tbody>
            </table>
            <!-- /앱 고객정보 상세-->
            <!-- 기존 고객 매칭 -->
            <div class="title-wrap mt30">
                <h4>기존 고객 매칭</h4>
                <div class="btn-group mb5">
                    <div class="right">
                        <c:if test="${not empty result.use_yn}">사용여부: ${result.use_yn eq 'Y'? '사용' : '미사용'}</c:if>
                        <input type="checkbox" id="approval_check" name="approval_check" class="ml15 " value="Y"
                               onchange="javascript:fnCheckChange('approval');" ${result.approval_yn eq 'Y' ? 'checked':''}>
                        <label class="form-check-label mr5" for="approval_yn">승인</label>
                        <input type="hidden" id="approval_yn" name="approval_yn" value="${result.approval_yn}">
                        <button type="button" id="_fnAddCust" class="btn btn-primary-gra" onclick="fnAddCust();">신규등록</button>
                        <button type="button" id="_goMappingRemove" class="btn btn-primary-gra" onclick="goMappingRemove();">매칭해제</button>
                    </div>
                </div>
            </div>
            <table class="table-border">
                <colgroup>
                    <col width="100px">
                    <col width="">
                    <col width="100px">
                    <col width="">
                </colgroup>
                <tbody>
                <tr>
                    <th class="text-right">고객명</th>
                    <td>
                        <div class="form-row inline-pd pr">
                            <div class="col-auto">
                                <div class="input-group">
                                    <input type="text" id="cust_name" name="cust_name" value="${result.cust_name}" class="form-control border-right-0 width120px" readonly="readonly" alt="고객명">
                                    <input type="hidden" id="cust_no" name="cust_no" value="${result.cust_no}">
                                    <button type="button" id="btn_custSearch" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchCustPanel('fnSetCustInfo');">
                                        <i class="material-iconssearch"></i>
                                    </button>
                                </div>
                            </div>
                            <div class="col-auto">
                                <button type="button" id="_fnCustDetailPopup" class="btn btn-primary-gra" style="width: 100%;" onclick="javascript:fnCustDetailPopup()">고객대장</button>
                            </div>
                        </div>
                    </td>
                    <th class="text-right">휴대폰</th>
                    <td>
                        <div class="input-group" >
                            <input type="text" class="form-control border-right-0" value="${result.cust_hp_no}" id="cust_hp_no" name="cust_hp_no" format="phone" readonly="readonly">
                            <button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goSendSms('web');"><i class="material-iconsforum"></i></button>
                        </div>
                    </td>
                </tr>
                <tr>
                    <th class="text-right">이메일</th>
                    <td>
                        <div class="form-row inline-pd">
                            <div class="col-10">
                                <input type="text" class="form-control" id="cust_email" name="cust_email" format="email" value="${result.cust_email}" alt="이메일" readonly="readonly">
                            </div>
                            <div class="col-2">
                                <button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSendMail('web');"><i class="material-iconsmail"></i></button>
                            </div>
                        </div>
                    </td>
                    <th class="text-right">생년월일</th>
                    <td>
                        <div class="form-row inline-pd">
                            <div class="col-6">
                                <div class="input-group">
                                    <input type="text" class="form-control border-right-0 calDate" dateFormat="yyyy-MM-dd" id="cust_birth_dt" name="cust_birth_dt" value="${result.cust_birth_dt}" alt="생년월일" disabled="disabled">
                                </div>
                            </div>
                            <div class="col-6">
                                <div class="form-check form-check-inline">
                                    <input class="form-check-input" type="radio" id="cust_solar_cal_y" name="cust_solar_cal_yn" value="Y" ${result.cust_solar_cal_yn == 'Y' ? 'checked="checked"' : ''} disabled="disabled">
                                    <label class="form-check-label" for="cust_solar_cal_y">양력</label>
                                </div>
                                <div class="form-check form-check-inline">
                                    <input class="form-check-input" type="radio" id="cust_solar_cal_n" name="cust_solar_cal_yn" value="N" ${result.cust_solar_cal_yn == 'N' ? 'checked="checked"' : ''} disabled="disabled">
                                    <label class="form-check-label" for="cust_solar_cal_n">음력</label>
                                </div>
                            </div>
                        </div>
                    </td>
                </tr>
                <tr>
                    <th class="text-right">주소</th>
                    <td colspan="3">
                        <div class="form-row inline-pd mb7">
                            <div class="col-3">
                                <input type="text" class="form-control" readonly="readonly" id="cust_post_no" name="cust_post_no" alt="우편번호" value="${result.cust_post_no}">
                            </div>
                            <div class="col-9">
                                <input type="text" class="form-control width-100per" readonly="readonly" id="cust_addr1" name="cust_addr1" alt="주소" value="${result.cust_addr1}">
                            </div>
                        </div>
                        <div class="form-row inline-pd">
                            <div class="col-12">
                                <input type="text" class="form-control" readonly="readonly" id="cust_addr2" name="cust_addr2" alt="상세주소" value="${result.cust_addr2}">
                            </div>
                        </div>
                    </td>
                </tr>
                </tbody>
            </table>
            <!-- /기존 고객 매칭-->
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
