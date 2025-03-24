<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 매입관리 > 매입처관리 > null > 매입처상세
-- 작성자 : 박예진
-- 최초 작성일 : 2020-01-10 17:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		//수정
		function goModify(){
			var frm = document.main_form;
			if($M.validation(frm) == false) {
				return;
			};

            // 수정할 경우 관리담당, 관리부서는 로그인 USER로 덮어 씀(전산담당 제외)-[매입처자동화]:황다은
            if('${SecureUser.mem_no}' != 'MB00000431') {
                if (frm.mng_mem_no.value != '${SecureUser.mem_no}') {
                    frm.mng_mem_no.value = '${SecureUser.mem_no}';
                    frm.mng_mem_name.value = '${SecureUser.user_name}'
                    fnSelectOrg('${SecureUser.org_code}');
                }
            }

			// validation check
 			if($M.validation(document.main_form, {field: ["com_buy_group_cd", "cust_name"]}) == false) {
				return;
			};
			$M.goNextPageAjaxModify(this_page + '/modify', $M.toValueForm(frm) , {method : 'POST'},
				function(result) {
					if(result.success) {
						fnClose();
						if (opener != null && opener.goSearch) {
							opener.goSearch();
						}
					}
				}
			);
		}
		//삭제
		function goRemove(){
			var frm = document.main_form;
			$M.goNextPageAjaxRemove(this_page + "/remove", $M.toValueForm(frm), {method: 'POST'},
                function (result) {
                    if (result.success) {
                        fnClose();
                        if (opener != null && opener.goSearch) {
                            opener.goSearch();
                        }
                    }
                }
            );
        }

        // 주소팝업 test
        function fnJusoBiz(data) {
            $M.setValue("post_no", data.zipNo);
            $M.setValue("addr1", data.roadAddrPart1);
            $M.setValue("addr2", data.addrDetail);
            $M.setValue("engAddr", data.engAddr);
        }

        // 사업자정보조회 결과 test
        function fnSetBregInfo(row) {
            $M.setValue("breg_no", row.breg_no);
            $M.setValue("breg_seq", row.breg_seq);
            $M.setValue("breg_name", row.breg_name);
            $M.setValue("breg_rep_name", row.breg_rep_name);
            $M.setValue("breg_cor_type", row.breg_cor_type);
            $M.setValue("breg_cor_part", row.breg_cor_part);
        }

        // 거래원장조회 예비
        function goDealLedger() {
            var param = {
                "s_cust_no": $M.getValue("cust_no")
            };
            $M.goNextPage('/part/part0303p01', $M.toGetParam(param), {popupStatus : getPopupProp(1550, 860)});
        }

        // 상세내역 팝업
        function fnSelectCustClientPartNoList() {
            var param = {
                "cust_no": "${inputParam.cust_no}",
                // "breg_name" : $M.getValue("cust_name"), // 22.11.15 정윤수 매입처의 상호명이 없는 경우 모든 부품이 조회되어 수정
                "cust_name": $M.getValue("cust_name"),
            };
            var popupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1000, height=400, left=0, top=0";
            $M.goNextPage('/part/part0301p02', $M.toGetParam(param), {popupStatus: popupOption});

        }

        // 관리담당 팝업
        function fnSetMemberInfo(row) {
            $M.setValue("mng_mem_name", row.mem_name);
            $M.setValue("mng_mem_no", row.mem_no);

            fnSelectOrg(row.org_code)	// 관리부서와 연동
        }

        // 관리부서 -> 관리당담에 맞는 부서로 세팅, 없을 시 선택
        function fnSelectOrg(orgCode) {
            var orgList = document.getElementById('mng_org_code');
            var isOrgList = false;
            orgCode = orgCode.substring(0,1) == 5 ? '5000' : orgCode;   // 서비스&서비스하위 센터들은 관리부서가 '서비스/센터'로
            for (var i = 0; i < orgList.options.length; i++) {
                if (orgList.options[i].value == orgCode) {
                    orgList.selectedIndex = i;
                    isOrgList = true;
                    break;
                }
            }
            // 관리담당자의 부서가 orgList에 없는 경우, '- 선택 -'으로 설정
            if (!isOrgList) {
                orgList.selectedIndex = 0;
            }
        }

        // 업체 문자 발송
        function fnSendSmsBregInfo() {
            var param = {
                'name': document.getElementById("breg_rep_name").value,
                'hp_no': document.getElementById("hp_no").value
            }
            openSendSmsPanel($M.toGetParam(param));
        }

        // 영업담당 문자 발송
        function fnSendSmsChargeInfo() {
            var param = {
                'name': document.getElementById("charge_name").value,
                'hp_no': document.getElementById("charge_hp_no").value
            }
            openSendSmsPanel($M.toGetParam(param));
        }


        // 업체 대표자 이메일 발송 팝업
        function fnSendBregMail() {
            var param = {
                'to': document.getElementById("email").value
            };
            openSendEmailPanel($M.toGetParam(param));
        }

        // 영업담당 이메일 발송
        function fnSendChargeMail() {
            var param = {
                'to': document.getElementById("charge_email").value
            };
            openSendEmailPanel($M.toGetParam(param));
        }

        //팝업 끄기
        function fnClose() {
            window.close();
        }

        // 화폐단위
        function fnMoneyUnitChange() {
            var param = {
                "money_unit_cd": $M.getValue("money_unit_cd")
            }
            $M.goNextPageAjax(this_page + '/money', $M.toGetParam(param), {method: 'GET'},
                function (result) {
                    if (result.success) {
                        var data = result.money_unit;
                        $M.setValue("money_unit", data);
                    }
                    ;
                }
            );
        }

        // 사업자정보조회 팝업
        function fnSearchBregInfo() {
            var param = {};
            openSearchBregInfoPanel('fnSetBregInfo', $M.toGetParam(param));
        }

        // 관리담당정보 초기화
        function fnDeleteMngName() {
            $M.setValue("mng_mem_name", "");
            $M.setValue("mng_mem_no", "");
            $M.setValue("mng_org_code", "");
        }

    </script>
</head>
<body class="bg-white class">
<form id="main_form" name="main_form">
    <input type="hidden" class="form-control" id="cust_no" name="cust_no" value="${inputParam.cust_no}">
    <!-- 팝업 -->
    <div class="popup-wrap width-100per">
        <!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
        <!-- /타이틀영역 -->
        <div class="content-wrap">
            <!-- 상단 폼테이블 -->
            <div>
                <div class="title-wrap">
                    <h4>매입처상세</h4>
                </div>
                <table class="table-border mt5">
                    <colgroup>
                        <col width="100px">
                        <col width="">
                        <col width="100px">
                        <col width="">
                        <col width="90px">
                        <col width="">
                        <col width="90px">
                        <col width="">
                    </colgroup>
                    <tbody>
                    <tr>
                        <th class="text-right essential-item">업체그룹</th>
                        <td>
                            <select class="form-control width140px essential-bg" id="com_buy_group_cd" name="com_buy_group_cd" alt="업체그룹">
                                <c:forEach var="item" items="${codeMap['COM_BUY_GROUP']}">
                                    <option value="${item.code_value}" ${item.code_value == result.com_buy_group_cd ? 'selected' : '' }>${item.code_desc}</option>
                                </c:forEach>
                            </select>
                        </td>
                        <th class="text-right essential-item">업체명</th>
                        <td>
                            <input type="text" class="form-control width120px essential-bg" id="cust_name" name="cust_name" value="${result.cust_name}" alt="업체명">
                        </td>
                        <th class="text-right">관리담당</th>
                        <td>
                            <div class="input-group width120px">
                                <input type="text" class="form-control width120px border-right-0" id="mng_mem_name" name="mng_mem_name" value="${result.mng_mem_name}" readonly="readonly" alt="관리담당">
                                <input type="hidden" id="mng_mem_no" name="mng_mem_no" value="${result.mng_mem_no}">
                                <button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchMemberPanel('fnSetMemberInfo');"><i class="material-iconssearch"></i></button>
                                <button type="button" class="btn btn-icon btn-primary-gra" onclick="fnDeleteMngName()"><i class="material-iconsclose"></i></button>
                            </div>
                        </td>
                        <th class="text-right">매입구분</th>
                        <td>
                            <%-- <input class="form-check-input" type="radio" id="" name="" ${result.매입구분 == "내자" ? 'checked' : '' }> --%>
                            <div class="form-check form-check-inline">
                                <input class="form-check-input" type="radio" id="nation_type_d" name="nation_type_df" value="D" ${result.nation_type_df == 'D'? 'checked="checked"' : ''}>
                                <label class="form-check-label">내자</label>
                            </div>
                            <div class="form-check form-check-inline">
                                <input class="form-check-input" type="radio" id="nation_type_f" name="nation_type_df" value="F" ${result.nation_type_df == 'F'? 'checked="checked"' : ''}>
                                <label class="form-check-label">외자</label>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <th class="text-right">송금조건/일</th>
                        <td>
                            <div class="form-row inline-pd">
                                <div class="col-8">
                                    <input type="text" class="form-control width100px" id="send_money_text" name="send_money_text" alt="송금조건" value="${result.send_money_text}">
                                </div>
                                /&nbsp;&nbsp;
                                <div class="col-2">
                                    <input type="text" class="form-control width40px" id="send_money_day_cnt" name="send_money_day_cnt" alt="송금조건일" value="${result.send_money_day_cnt}" format="num">
                                </div>
                            </div>
                        </td>
                        <th class="text-right">고객풀네임</th>
                        <td>
                            <input type="text" class="form-control width120px" id="cust_full_name" name="cust_full_name" alt="고객풀네임" value="${result.cust_full_name}">
                        </td>
                        <th class="text-right">회계거래처코드</th>
                        <td>
<%--                            <input type="text" class="form-control width120px" id="account_link_cd" name="account_link_cd" alt="회계거래처코드" value="${result.account_link_cd}" readonly="readonly">--%>
<%--                            2024-09-20 황빛찬 (Q&A : 23985) 매입처 상세에서 회계거래처코드 수정가능하도록 변경--%>
                            <input type="text" class="form-control width120px" id="account_link_cd" name="account_link_cd" alt="회계거래처코드" value="${result.account_link_cd}">
                        </td>
                        <th class="text-right">관리부서</th>
                        <td>
                            <select id="mng_org_code" name="mng_org_code" class="form-control width100px">
                                <option value="" ${result.mng_org_code == "" ? 'selected' : '' }>- 선택 -</option>
                                <c:forEach var="item" items="${orgList}">
                                    <option value="${item.org_code }" ${item.org_code == result.mng_org_code ? 'selected':''}>${item.org_name}</option>
                                </c:forEach>
                            </select>
                        </td>

                    </tr>
                    <tr>
                        <th class="text-right">사업자번호</th>
                        <td colspan="3">
                            <div class="form-row inline-pd">
                                <div class="col-4">
                                    <div class="input-group">
                                        <input type="text" class="form-control border-right-0 width140px" id="breg_no" name="breg_no" alt="사업자번호" value="${result.breg_no}" readonly="readonly" alt="사업자번호">
                                        <input type="hidden" class="form-control border-right-0" id="breg_seq" name="breg_seq" value="${result.breg_seq}" readonly="readonly">
                                        <button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchBregInfoPanel('fnSetBregInfo');"><i class="material-iconssearch"></i></button>
                                    </div>
                                </div>
                                <div class="col-3">
                                    <input type="text" class="form-control width120px" id="breg_name" name="breg_name" value="${result.breg_name}" readonly="readonly">
                                </div>
                                <div class="col-5">
                                    <input type="text" class="form-control width120px" id="breg_rep_name" name="breg_rep_name" value="${result.breg_rep_name}" readonly="readonly">
                                </div>
                            </div>
                        </td>
                        <th rowspan="3" class="text-right">주소</th>
                        <td colspan="3" rowspan="3">
                            <div class="form-row inline-pd mb7">
                                <div class="col-3">
                                    <input type="text" class="form-control width100px" id="post_no" name="post_no" value="${result.post_no}">
                                </div>
                                <div class="col-3">
                                    <button type="button" class="btn btn-primary-gra" onclick="javascript:openSearchAddrPanel('fnJusoBiz');">주소찾기</button>
                                </div>
                            </div>
                            <div class="form-row inline-pd mb7">
                                <div class="col-12">
                                    <input type="text" class="form-control width280px" id="addr1" name="addr1" value="${result.addr1}">
                                </div>
                            </div>
                            <div class="form-row inline-pd">
                                <div class="col-12">
                                    <input type="text" class="form-control width280px" id="addr2" name="addr2" value="${result.addr2}">
                                </div>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <th class="text-right">업태</th>
                        <td>
                            <input type="text" class="form-control width120px" id="breg_cor_type" name="breg_cor_type" value="${result.breg_cor_type}" readonly="readonly">
                        </td>
                        <th class="text-right">업종</th>
                        <td>
                            <input type="text" class="form-control width120px" id="breg_cor_part" name="breg_cor_part" value="${result.breg_cor_part}" readonly="readonly">
                        </td>
                    </tr>
                    <tr>
                        <th class="text-right">휴대폰</th>
                        <td>
                            <div class="input-group">

                                <input type="text" class="form-control width140px border-right-0" placeholder="숫자만 입력" value="${result.hp_no}" id="hp_no" name="hp_no" format="tel">
                                <button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSendSmsBregInfo();"><i class="material-iconsforum"></i></button>
                            </div>
                        </td>
                        <th class="text-right">전화번호</th>
                        <td>
                            <input type="text" class="form-control width140px" placeholder="하이픈(-)포함" id="tel_no" name="tel_no" value="${result.tel_no}">
                        </td>
                    </tr>
                    <tr>
                        <th class="text-right">팩스</th>
                        <td>
                            <input type="text" class="form-control width140px" placeholder="하이픈(-)포함" id="fax_no" name="fax_no" value="${result.fax_no}">
                        </td>
                        <th class="text-right">이메일</th>
                        <td>
                            <div class="form-row inline-pd">
                                <div class="col-9">
                                    <input type="text" class="form-control width140px" id="email" name="email" value="${result.email}">
                                </div>
                                <div class="col-3">
                                    <button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSendBregMail();"><i class="material-iconsmail"></i></button>
                                </div>
                            </div>
                        </td>
                        <th class="text-right">거래은행</th>
                        <td>
                            <input type="text" class="form-control width120px" id="bank_name" name="bank_name" value="${result.bank_name}">
                        </td>
                        <th class="text-right">계좌번호</th>
                        <td>
                            <input type="text" class="form-control width140px" id="account_no" name="account_no" value="${result.account_no}">
                        </td>
                    </tr>
                    <tr>
                        <th class="text-right">마케팅담당자명</th>
                        <td>
                            <input type="text" class="form-control width120px" id="charge_name" name="charge_name" value="${result.charge_name}">
                        </td>
                        <th class="text-right">마케팅담당직책</th>
                        <td>
                            <input type="text" class="form-control width120px" id="charge_grade" name="charge_grade" value="${result.charge_grade}">
                        </td>
                        <th class="text-right">예금주</th>
                        <td  colspan="3">
                            <input type="text" class="form-control width-100per" id="client_deposit_name" name="client_deposit_name" value="${result.client_deposit_name}">
                        </td>
                    </tr>
                    <tr>
                        <th class="text-right">마케팅담당휴대폰</th>
                        <td>
                            <div class="input-group">
                                <input type="text" class="form-control width140px border-right-0" id="charge_hp_no" name="charge_hp_no" placeholder="숫자만 입력" value="${result.charge_hp_no}" format="phone" maxlength="11">
                                <button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSendSmsChargeInfo();"><i class="material-iconsforum"></i></button>
                            </div>
                        </td>
                        <th class="text-right">마케팅담당이메일</th>
                        <td>
                            <div class="form-row inline-pd">
                                <div class="col-9">
                                    <input type="text" class="form-control width140px" id="charge_email" name="charge_email" value="${result.charge_email}">
                                </div>
                                <div class="col-3">
                                    <button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSendChargeMail();"><i class="material-iconsmail"></i></button>
                                </div>
                            </div>
                        </td>
                    </tr>
                    </tbody>
                </table>
            </div>
<!-- /상단 폼테이블 -->
<!-- 하단 폼테이블 -->
            <div class="row">
<!-- 구매조건 -->
                <div class="col-4">
                    <div class="title-wrap mt10">
                        <h4>구매조건</h4>
                    </div>
                    <table class="table-border mt5">
                        <colgroup>
                            <col width="100px">
                            <col width="">
                        </colgroup>
                        <tbody>
                        <tr>
                            <th class="text-right">거래외환</th>
                            <td>
                                <div class="form-row inline-pd">
                                    <div class="col-4">
                                        <select class="form-control width60px" id="money_unit_cd" name="money_unit_cd" onchange="fnMoneyUnitChange()">
                                            <c:forEach var="item" items="${codeMap['MONEY_UNIT']}">
                                                <option value="${item.code_value}" ${item.code_value == result.money_unit_cd ? 'selected' : '' }>${item.code_value}</option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                    <div class="col-8">
                                        <input type="text" class="form-control width75px" id="money_unit" name="money_unit" value="${result.money_unit}" readonly="readonly" style="background-color:#FFF;">
                                    </div>
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <th class="text-right essential-item">지불조건</th>
                            <td>
                                <select class="form-control width100px essential-bg" alt="지불조건" id="out_case_cd" name="out_case_cd" required="required">
                                    <option value="" ${result.out_case_cd == "" ? 'selected' : ''} > - 선택 -</option>
                                    <c:forEach var="item" items="${codeMap['OUT_CASE']}">
                                        <option value="${item.code_value}" ${item.code_value == result.out_case_cd ? 'selected' : '' }>${item.code_name}</option>
                                    </c:forEach>
                                </select>
                            </td>
                        </tr>
                        <tr>
                            <th class="text-right">PPM</th>
                            <td>
                                <input type="text" class="form-control width120px" id="ppm" name="ppm" value="${result.ppm}">
                            </td>
                        </tr>
                        <tr>
                            <th class="text-right">Inconterms</th>
                            <td>
                                <input type="text" class="form-control width120px" id="incoterms" name="incoterms" value="${result.incoterms}">
                            </td>
                        </tr>
                        <tr>
                            <th class="text-right">계약L/T</th>
                            <td>
                                <input type="text" class="form-control width120px" id="lead_time" name="lead_time" placeholder="숫자만 입력" value="${result.lead_time}" datatype="int">
                            </td>
                        </tr>
                        <tr>
                            <th class="text-right">납기율</th>
                            <td>
                                <input type="text" class="form-control width120px" id="delivery_rate" name="delivery_rate" value="${result.delivery_rate}">
                            </td>
                        </tr>
                        </tbody>
                    </table>
                </div>
<!-- /구매조건 -->
<!-- 업체관리 -->
                <div class="col-4">
                    <div class="title-wrap mt10">
                        <h4>업체관리</h4>
                    </div>
                    <table class="table-border mt5">
                        <colgroup>
                            <col width="100px">
                            <col width="">
                        </colgroup>
                        <tbody>
                        <tr>
                            <th class="text-right">계약서</th>
                            <td>
                                <select class="form-control width100px" id="contract_mng_cd" name="contract_mng_cd">
                                    <option value="" ${result.contract_mng_cd == "" ? 'selected' : '' }>- 선택 -</option>
                                    <c:forEach var="item" items="${codeMap['CONTRACT_MNG']}">
                                        <option value="${item.code_value}" ${item.code_value == result.contract_mng_cd ? 'selected' : '' }>${item.code_name}</option>
                                    </c:forEach>
                                </select>
                            </td>
                        </tr>
                        <tr>
                            <th class="text-right">금형관리</th>
                            <td>
                                <select class="form-control width100px" id="kuemhng_yn" name="kuemhng_yn">
                                    <option value="Y" ${result.kuemhng_yn == "Y" ? 'selected' : '' }>Y</option>
                                    <option value="N" ${result.kuemhng_yn == "N" ? 'selected' : '' }>N</option>
                                </select>
                            </td>
                        </tr>
                        <tr>
                            <th class="text-right">도면관리</th>
                            <td>
                                <select class="form-control width100px" id="domuen_yn" name="domuen_yn">
                                    <option value="Y" ${result.domuen_yn == "Y" ? 'selected' : '' }>Y</option>
                                    <option value="N" ${result.domuen_yn == "N" ? 'selected' : '' }>N</option>
                                </select>
                            </td>
                        </tr>
                        <tr>
                            <th class="text-right">입고품질검사</th>
                            <td>
                                <select class="form-control width100px" id="ware_qual_cd" name="ware_qual_cd">
                                    <option value="" ${result.ware_qual_cd == "" ? 'selected' : '' }>- 선택 -</option>
                                    <c:forEach var="item" items="${codeMap['WARE_QUAL']}">
                                        <option value="${item.code_value}" ${item.code_value == result.ware_qual_cd ? 'selected' : '' }>${item.code_name}</option>
                                    </c:forEach>
                                </select>
                            </td>
                        </tr>
                        <tr>
                            <th class="text-right">업체평가</th>
                            <td>
                                <div class="form-row inline-pd">
                                    <div class="col-6">
                                        <input type="text" class="form-control width120px" value="${result.point_case}" id="point_case" name="point_case">
                                    </div>
                                    <div class="col-6">
                                        <button type="button" class="btn btn-primary-gra" style="width:100%;"
                                                onclick="javascript:goDealLedger();">매입처 거래원장상세
                                        </button>
                                    </div>
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <th class="text-right">관리부품</th>
                            <td>
                                <div class="form-row inline-pd">
                                    <div class="col-6">
                                        <input type="text" class="form-control width120px" id="mng_part_cnt" name="mng_part_cnt" value="${result.mng_part_cnt}" readonly="readonly" format="decimal">
                                    </div>
                                    <div class="col-6">
                                        <button type="button" class="btn btn-primary-gra" style="width: 75%;" onclick="javascript:fnSelectCustClientPartNoList();">상세내역</button>
                                    </div>
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <th class="text-right">주거래업체</th>
                            <td>
                                <input type="text" class="form-control width140px" id="main_deal_com_name" name="main_deal_com_name" value="${result.main_deal_com_name}">
                            </td>
                        </tr>
                        </tbody>
                    </table>
                </div>
<!-- /업체관리 -->
<!-- 거래이력 -->
                <div class="col-4">
                    <div class="title-wrap mt10">
                        <h4>거래이력</h4>
                    </div>
                    <table class="table-border mt5">
                        <colgroup>
                            <col width="100px">
                            <col width="">
                        </colgroup>
                        <tbody>
                        <tr>
                            <th class="text-right">전전년도</th>
                            <td>
                                <input type="text" class="form-control width100px text-right" id="be2_in_qty" name="be2_in_qty" value="${result.be2_in_qty}" readonly="readonly" format="decimal">
                            </td>
                        </tr>
                        <tr>
                            <th class="text-right">전년도</th>
                            <td>
                                <input type="text" class="form-control width100px text-right" id="be1_in_qty" name="be1_in_qty" value="${result.be1_in_qty}" readonly="readonly" format="decimal">
                            </td>
                        </tr>
                        <tr>
                            <th class="text-right">당해년도</th>
                            <td>
                                <input type="text" class="form-control width100px text-right" id="curr_in_qty" name="curr_in_qty" value="${result.curr_in_qty}" readonly="readonly" format="decimal">
                            </td>
                        </tr>
                        </tbody>
                    </table>
                    <div class="title-wrap mt10">
                        <h4>메모</h4>
                    </div>
                    <div>
                        <textarea class="form-control" id="memo" name="memo" style="height: 113px;">${result.memo}</textarea>
                    </div>
                </div>
            </div>
<!-- /거래이력 -->
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