<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 영업관리 > 위탁판매점직원관리 > 위탁판매점직원등록
-- 작성자 : 김태훈
-- 최초 작성일 : 2021-07-15 14:50:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var orgListJson;

		$(document).ready(function() {
			orgListJson = ${orgListJson};
		});

		var isIdChecked = false;
		var isHpChecked = false;

		// 대리점명 변경
		function fnChangeOrgCode() {
			var orgCode = $M.getValue("org_code");
			for (var i = 0; i < orgListJson.length; ++i) {
				if (orgListJson[i].org_code == orgCode) {
					$M.setValue(orgListJson[i]);
				}
			}
		}

		// 지사장 선택
		function fnSetAgencyMaster(row) {
			$M.setValue("cust_no", row.cust_no);
			$M.setValue("cust_name", row.real_cust_name);
			fnCheckRep();
		}

		// 아이디체크
		function fnCheckWebId() {
			var email = $M.getValue("email");
			var webId = $M.getValue("web_id");

			if($M.validation(null, {field:['web_id', 'email']}) == false) {
				return;
			}

			var param = {
				"web_id": webId,
				"email": email,
			};

			$M.goNextPageAjax("/acnt/acnt060101/webIdCheck", $M.toGetParam(param), {method: "get"},
					function (result) {
						if (result.success) {
							isIdChecked = true;
						} else {
							isIdChecked = false;
						}
					}
			);
		}

		// 핸드폰번호체크
		function fnCheckHp() {
			var hpNoCheck = $M.getValue("hp_no");

			if (hpNoCheck == "") {
				alert("핸드폰번호를 입력해주세요");
				return;
			}

			$M.goNextPageAjax("/acnt/acnt060101/hpNoCheck/" + hpNoCheck, "", {method: "get"},
					function (result) {
						if (result.success) {
							isHpChecked = true;
						} else {
							isHpChecked = false;
						}
					}
			);
		}

		// 핸드폰변경
		function fnChangeHp() {
			isHpChecked = false;
		}

		// 아이디변경
		function fnChangeWebId() {
			isIdChecked = false;
		}

		// 지사장이랑 직원명이랑 같은지 체크, 같으면 대표로 변경
		function fnCheckRep() {
			var korName = $M.getValue("kor_name");
			var custName = $M.getValue("cust_name");
			if (korName != "" && custName != "") {
				if (korName.indexOf(custName) > -1 || custName.indexOf(korName) > -1) {
					$M.setValue("agency_rep_yn", "Y");
				} else {
					$M.setValue("agency_rep_yn", "N");
				}
			} else {
				$M.setValue("agency_rep_yn", "N");
			}
		}

		// 저장
		function goSave() {
			fnCheckRep();
			var frm = document.main_form;

			if($M.validation(frm) == false) {
				return false;
			}

			if($M.getValue("org_code") == ""){
                // [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
				// alert("대리점을 선택해주세요.");
				alert("위탁판매점을 선택해주세요.");
				return false;
			}

			if (isHpChecked == false) {
				alert("핸드폰 중복체크를 해주세요.");
				return false;
			}

			if (isIdChecked == false) {
				alert("아이디 중복체크를 해주세요.");
				return false;
			}

			if (confirm("저장하시겠습니까?") == false) {
				return false;
			}

			// 답변자 리스트에 작성자 포함
 			$M.goNextPageAjax(this_page + '/save', $M.toValueForm(frm) , {method : 'POST'},
				function(result) {
					if(result.success) {
						fnList();
					}
				}
			);
		}

		function fnList() {
			$M.goNextPage("/sale/sale0303");
		}


		function goMove(){
			parent.goContent("조직관리",'/comm/comm0101');
		}
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<div class="layout-box">
<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box" style="width: 60%">
<!-- 상세페이지 타이틀 -->
				<div class="main-title detail">
					<div class="detail-left">
						<button type="button" class="btn btn-outline-light" onclick="javascript:fnList();"><i class="material-iconskeyboard_backspace text-default"></i></button>
						<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
					</div>
					<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
					</div>
				</div>
<!-- /상세페이지 타이틀 -->
<div class="contents">
<!-- 폼테이블 -->
                    <table class="table-border">
                        <colgroup>
                            <col width="100px">
                            <col width="">
                            <col width="100px">
                            <col width="">
                        </colgroup>
                        <tbody>
                            <tr>
                                <%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체 --%>
								<%--<th class="text-right rs">대리점명</th>--%>
								<th class="text-right rs">위탁판매점명</th>
								<td colspan="3">
									<input class="form-control" style="width:240px;" type="text" change="javascript:fnChangeOrgCode()" id="org_code" name="org_code" easyui="combogrid"
								   		easyuiname="orgList" panelwidth="280" idfield="org_code" textfield="org_name" multi="N"/>
								</td>
                            </tr>
                            <tr>
                                <th class="text-right rs">아이디</th>
                                <td colspan="3">
									<div class="form-row inline-pd">
                                        <div class="col width210px">
                                            <input type="text" class="form-control rb" placeholder="" name="web_id" onchange="javascript:fnChangeWebId()" required="required" alt="아이디">
                                        </div>
                                        <div class="col-auto">
                                            <button type="button" class="btn btn-primary-gra" onclick="javascript:fnCheckWebId()">중복확인</button>
                                        </div>
                                    </div>
								</td>
                            </tr>
                            <tr>
                                <th class="text-right">상호</th>
                                <td colspan="3">
									<input type="text" class="form-control width200px" readonly="readonly" name="breg_name">
								</td>
                            </tr>
                            <tr>
                                <th class="text-right">주소</th>
                                <td colspan="3">
									<div class="form-row inline-pd mb7 widthfix">
                                        <div class="col width100px">
                                            <input type="text" class="form-control" readonly="readonly" name="post_no">
                                        </div>
                                    </div>
                                    <div class="form-row inline-pd mb7">
                                        <div class="col-12">
                                            <input type="text" class="form-control" readonly="readonly" name="addr1">
                                        </div>
                                    </div>
                                    <div class="form-row inline-pd">
                                        <div class="col-12">
                                            <input type="text" class="form-control" readonly="readonly" name="addr2">
                                        </div>
                                    </div>
								</td>
                            </tr>
                            <tr>
                                <th class="text-right rs">직원구분</th>
                                <td>
                                    <div class="form-check form-check-inline">
                                        <label class="form-check-label"><input class="form-check-input" type="radio" name="agency_rep_yn" value="Y" disabled="disabled">대표</label>
                                    </div>
                                    <div class="form-check form-check-inline">
                                        <label class="form-check-label"><input class="form-check-input" type="radio" name="agency_rep_yn" checked="checked" value="N" disabled="disabled">직원</label>
                                    </div>
                                </td>
                                <th class="text-right rs">지사장</th>
                                <td>
                                    <div class="input-group widthfix">
                                        <input type="text" class="form-control border-right-0 width140px" readonly="readonly" name="cust_name">
                                        <button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchCustPanel('fnSetAgencyMaster');"><i class="material-iconssearch"></i></button>
                                        <input type="hidden" name="cust_no">
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <th class="text-right rs">직원명</th>
                                <td>
                                    <input type="text" class="form-control width160px rb" required="required" alt="직원명" name="kor_name" onchange="javascript:fnCheckRep()">
                                </td>
                                <th class="text-right rs">이메일</th>
                                <td>
                                    <input type="text" class="form-control width160px rb" required="required" alt="이메일" name="email">
                                </td>
                            </tr>
                            <tr>
                                <th class="text-right rs">핸드폰</th>
                                <td>
                                    <div class="form-row inline-pd">
                                        <div class="col width110px">
                                            <input type="text" class="form-control rb" placeholder="" onchange="javascript:fnChangeHp()" id="hp_no" name="hp_no" required="required" alt="핸드폰" format="phone">
                                        </div>
                                        <div class="col-auto">
                                            <button type="button" class="btn btn-primary-gra" onclick="javascript:fnCheckHp()">중복확인</button>
                                        </div>
                                    </div>
                                </td>
                                <th class="text-right">사무실전화</th>
                                <td>
                                    <input type="text" class="form-control width160px" readonly="readonly" name="tel_no">
                                </td>
                            </tr>
                            <tr>
                                <th class="text-right rs">직원앱사용여부</th>
                                <td>
                                    <div class="form-check form-check-inline">
                                        <label class="form-check-label"><input class="form-check-input" type="radio" name="app_yn" value="Y">Y</label>
                                    </div>
                                    <div class="form-check form-check-inline">
                                        <label class="form-check-label"><input class="form-check-input" type="radio" name="app_yn" checked="checked" value="N">N</label>
                                    </div>
                                </td>
                                <th class="text-right">기기정보</th>
                                <td>
                                    <input type="text" class="form-control" name="app_uuid" maxlength="50">
                                </td>
                            </tr>
                        </tbody>
                    </table>
<!-- /폼테이블 -->
<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">
                        <div class="left text-warning">
                            ※ 직원앱 최초로그인 인증시 직원앱사용여부(Y)와 기기정보가 자동으로 저장됩니다.<br/>
                            &nbsp;&nbsp;&nbsp;&nbsp;이후 기기정보 수정시 수기로 입력해주세요.
                        </div>
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
					</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
				</div>
			</div>
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
		</div>
<!-- /contents 전체 영역 -->
</div>
</form>
</body>
</html>
