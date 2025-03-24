<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 영업관리 > 위탁판매점직원관리 > 위탁판매점직원상세
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

			$('#org_code').combogrid("setValues", "${item.org_code}");

            //퇴직여부 확인
            fnRetireYn($M.getValue("work_status_cd"));
		});

        // 재직구분 선택 시 이벤트
        function fnRetireYn(workStatusCd) {
            var flag = workStatusCd == "04"? true : false;

            if(flag) {
                $("#retire_dt").prop("readonly", false);						// 퇴직일 입력가능
                $("#retireField").children("button").attr('disabled', false);	// 퇴직일 달력 사용가능
                $("#retire_dt").attr("required", true);							// 퇴직일 필수

                if (${item.work_status_cd eq '01'}) {                           // 퇴직일 설정
                    $M.setValue("retire_dt", $M.getCurrentDate("yyyyMMdd"));
                }
            } else {
                $("#retire_dt").prop("readonly", true);							// 퇴직일 입력불가
                $("#retireField").children("button").attr('disabled', true);	// 퇴직일 달력 사용불가
                $("#retire_dt").attr("required", false);						// 퇴직일 필수X

                $M.setValue("retire_dt", "");									// 퇴직일 초기화
            }
        }

		var isHpChecked = true;

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

		// 핸드폰번호체크
		function fnCheckHp() {
			var hpNoCheck = $M.getValue("hp_no");

			if (hpNoCheck == "") {
				alert("핸드폰번호를 입력해주세요");
				return;
			}

			if (hpNoCheck == "${item.hp_no}") {
				isHpChecked = true;
				alert("변경사항이 없습니다.");
				return false;
			}

			$M.goNextPageAjax("/acnt/acnt060101/hpNoCheck/" + hpNoCheck, "", {method: "get"},
					function (result) {
						if (result.success) {
							isHpChecked = true;
						} else {
							isHpChecked = false;
						};
					}
			);
		}

		// 핸드폰변경
		function fnChangeHp() {
			isHpChecked = false;
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
		function goModify() {
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

			if (confirm("수정하시겠습니까?") == false) {
				return false;
			}

			// 답변자 리스트에 작성자 포함
 			$M.goNextPageAjax(this_page + '/modify', $M.toValueForm(frm) , {method : 'POST'},
				function(result) {
					if(result.success) {
						location.reload();
                        if (opener != null) {
                            opener.goSearch();
                        }
					}
				}
			);
		}

		// 삭제
		function goRemove() {
			var frm = document.main_form;

			if($M.validation(frm) == false) {
				return false;
			}

			// 답변자 리스트에 작성자 포함
 			$M.goNextPageAjaxRemove(this_page + '/remove', $M.toValueForm(frm) , {method : 'POST'},
				function(result) {
					if(result.success) {
						if (opener != null) {
							opener.goSearch();
						}
						fnClose();
					}
				}
			);
		}

		function fnClose() {
			window.close();
		}

	</script>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" name="mem_no" value="${item.mem_no }">
<input type="hidden" name="before_work_status_cd" value="${item.work_status_cd }">
<div class="popup-wrap width-100per">
		<div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
		</div>
		<div class="content-wrap">
			<div>
<!-- 상세페이지 타이틀 -->
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
                                            <input type="text" class="form-control rb" placeholder="" name="web_id" onchange="javascript:fnChangeWebId()" required="required" alt="아이디" disabled="disabled" value="${item.web_id }">
                                        </div>
                                    </div>
								</td>
                            </tr>
                            <tr>
                                <th class="text-right">상호</th>
                                <td colspan="3">
									<input type="text" class="form-control width200px" readonly="readonly" name="breg_name" value="${item.breg_name }">
								</td>
                            </tr>
                            <tr>
                                <th class="text-right">주소</th>
                                <td colspan="3">
									<div class="form-row inline-pd mb7 widthfix">
                                        <div class="col width100px">
                                            <input type="text" class="form-control" readonly="readonly" name="post_no" value="${item.post_no }">
                                        </div>
                                    </div>
                                    <div class="form-row inline-pd mb7">
                                        <div class="col-12">
                                            <input type="text" class="form-control" readonly="readonly" name="addr1" value="${item.addr1 }">
                                        </div>
                                    </div>
                                    <div class="form-row inline-pd">
                                        <div class="col-12">
                                            <input type="text" class="form-control" readonly="readonly" name="addr2" value="${item.addr2 }">
                                        </div>
                                    </div>
								</td>
                            </tr>
                            <tr>
                            	<!-- 대표 선택 시, 부서장으로 등록됨 -->
                                <th class="text-right rs">직원구분</th>
                                <td>
                                    <div class="form-check form-check-inline">
                                        <label class="form-check-label"><input class="form-check-input" type="radio" name="agency_rep_yn" ${item.agency_rep_yn eq 'Y' ? 'checked="checked"' : '' } value="Y" disabled="disabled">대표</label>
                                    </div>
                                    <div class="form-check form-check-inline">
                                        <label class="form-check-label"><input class="form-check-input" type="radio" name="agency_rep_yn" ${item.agency_rep_yn eq 'N' ? 'checked="checked"' : '' } value="N" disabled="disabled">직원</label>
                                    </div>
                                </td>
                                <th class="text-right rs">지사장</th>
                                <td>
                                    <div class="input-group widthfix">
                                        <input type="text" class="form-control border-right-0 width140px" readonly="readonly" name="cust_name" value="${item.cust_name }">
                                        <button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchCustPanel('fnSetAgencyMaster');"><i class="material-iconssearch"></i></button>
                                        <input type="hidden" name="cust_no" value="${item.cust_no }">
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <th class="text-right rs">직원명</th>
                                <td>
                                    <input type="text" class="form-control width160px rb" required="required" alt="직원명" name="kor_name" value="${item.kor_name }" onchange="javascript:fnCheckRep()">
                                </td>
                                <th class="text-right rs">이메일</th>
                                <td>
                                    <input type="text" class="form-control width160px rb" required="required" alt="이메일" name="email" value="${item.email }">
                                </td>
                            </tr>
                            <tr>
                                <th class="text-right rs">핸드폰</th>
                                <td>
                                    <div class="form-row inline-pd">
                                        <div class="col width110px">
                                            <input type="text" class="form-control rb" placeholder="" onchange="javascript:fnChangeHp()" id="hp_no" name="hp_no" required="required" alt="핸드폰" format="phone" value="${item.hp_no }">
                                        </div>
                                        <div class="col-auto">
                                            <button type="button" class="btn btn-primary-gra" onclick="javascript:fnCheckHp()">중복확인</button>
                                        </div>
                                    </div>
                                </td>
                                <th class="text-right">사무실전화</th>
                                <td>
                                    <input type="text" class="form-control width160px" readonly="readonly" name="tel_no" value="${item.tel_no }">
                                </td>
                            </tr>
                            <tr>
                                <th class="text-right rs">직원앱사용여부</th>
                                <td>
                                    <div class="form-check form-check-inline">
                                        <label class="form-check-label"><input class="form-check-input" type="radio" name="app_yn" value="Y" <c:if test="${item.app_yn eq 'Y'}" > checked</c:if>>Y</label>
                                    </div>
                                    <div class="form-check form-check-inline">
                                        <label class="form-check-label"><input class="form-check-input" type="radio" name="app_yn" value="N" <c:if test="${item.app_yn ne 'Y'}" > checked</c:if>>N</label>
                                    </div>
                                </td>
                                <th class="text-right">기기정보</th>
                                <td>
                                    <input type="text" class="form-control" name="app_uuid" value="${item.app_uuid }" maxlength="50">
                                </td>
                            </tr>
                            <tr>
                                <th class="text-right essential-item">재직구분</th>
                                <td>
                                    <select class="form-control essential-bg width160px rb" id="work_status_cd" name="work_status_cd" required="required" alt="재직구분"
                                        onchange="javascript:fnRetireYn(this.value);">
                                        <option value="">- 선택 -</option>
                                        <c:forEach items="${codeMap['WORK_STATUS']}" var="code">
                                            <option value="${code.code_value}" ${code.code_value == item.work_status_cd ? 'selected' : '' }>${code.code_name}</option>
                                        </c:forEach>
                                    </select>
                                </td>
                                <th class="text-right">퇴직일</th>
                                <td>
                                    <div class="input-group width120px" id="retireField" name="retireField">
                                        <input type="text" id="retire_dt" name="retire_dt" dateFormat="yyyy-MM-dd" class="form-control border-right-0 calDate" alt="퇴직일" value="${item.retire_dt }">
                                    </div>
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
		</div>
<!-- /contents 전체 영역 -->
</div>
</form>
</body>
</html>
