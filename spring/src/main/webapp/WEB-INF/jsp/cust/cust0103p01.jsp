<%@ page contentType="text/html;charset=utf-8" language="java" %><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 고객현황 > 장비차주변경이력
-- 작성자 : 성현우
-- 최초 작성일 : 2020-09-15 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">

        $(document).ready(function () {
        });

        // 고객조회 정보 setting
		function setCustInfo(data) {
			// alert(JSON.stringify(data));
			var addr = data.addr1 + " " + data.addr2;
			$M.setValue("cust_name", data.real_cust_name);
			$M.setValue("cust_no", data.cust_no);
			$M.setValue("hp_no", $M.phoneFormat(data.real_hp_no));
			$M.setValue("addr", addr);
			$M.setValue("sale_mem_name", data.sale_mem_name);
			$M.setValue("sale_mem_no", data.sale_mem_no);
			$M.setValue("breg_name", data.breg_name);
			$M.setValue("breg_no", data.real_breg_no);
			$M.setValue("addr1", data.addr1);
			$M.setValue("addr2", data.addr2);
			$M.setValue("breg_rep_name", data.breg_rep_name);
		}
        
        function goSave() {
        	var frm = document.main_form;
			//validationcheck
			if ($M.validation(frm,
					{field: ["cust_no"]}) == false) {
				return;
			}

			if($M.getValue("origin_cust_no") == $M.getValue("cust_no")) {
				alert("변경 전 고객명과 변경 후 고객명이 같습니다.");
				return;
			}

			$M.goNextPageAjaxSave(this_page + '/save', $M.toValueForm(frm), {method: 'POST'},
					function (result) {
						if (result.success) {
							alert("저장이 완료되었습니다.");

							var data = {
								"cust_name" : $M.getValue("cust_name"),
								"cust_no" : $M.getValue("cust_no"),
								"hp_no" : $M.getValue("hp_no"),
								"breg_name" : $M.getValue("breg_name"),
								"breg_no" : $M.getValue("breg_no"),
								"addr1" : $M.getValue("addr1"),
								"addr2" : $M.getValue("addr2"),
								"breg_rep_name" : $M.getValue("breg_rep_name")
							}
							
							try {
								opener.${inputParam.parent_js_name}(data);
								fnClose();
							} catch(e) {
								alert("호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.");
							}
						}
					}
			);
		}

		function fnClose() {
			window.close();
		}
    </script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" id="machine_seq" name="machine_seq" value="${result.machine_seq}">
<input type="hidden" id="job_report_no" name="job_report_no" value="${inputParam.job_report_no}">
<input type="hidden" id="breg_name" name="breg_name">
<input type="hidden" id="breg_no" name="breg_no">
<input type="hidden" id="breg_rep_name" name="breg_rep_name">
<input type="hidden" id="addr1" name="addr1">
<input type="hidden" id="addr2" name="addr2">
<input type="hidden" id="page_type" name="page_type" value="${inputParam.page_type}">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">					

<!-- 상단 폼테이블 -->
            <table class="table-border mt5">
                <colgroup>
                    <col width="100px">
                    <col width="">
                    <col width="100px">
                    <col width="">
                </colgroup>
                <tbody>
                    <tr>
                        <th class="text-right">차대번호</th>
                        <td>
                            <input type="text" class="form-control width150px" id="body_no" name="body_no" readonly="readonly" value="${result.body_no}">
                        </td>
                        <th class="text-right">기종</th>
                        <td>
                            <input type="text" class="form-control width150px" id="machine_type_name" name="machine_type_name" readonly="readonly" value="${result.machine_type_name}">
                        </td>
                    </tr>
                    <tr>
                        <th class="text-right">엔진번호</th>
                        <td>
                            <input type="text" class="form-control width150px" id="engine_no_1" name="engine_no_1" readonly="readonly" value="${result.engine_no_1}">
                        </td>
                        <th class="text-right">규격</th>
                        <td>
                            <input type="text" class="form-control width150px" id="machine_sub_type_name" name="machine_sub_type_name" readonly="readonly" value="${result.machine_sub_type_name}">
                        </td>
                    </tr>
                    <tr>
                        <th class="text-right">모델명</th>
                        <td>
                            <input type="text" class="form-control width150px" id="machine_name" name="machine_name" readonly="readonly" value="${result.machine_name}">
                        </td>
                        <th class="text-right">메이커</th>
                        <td>
                            <input type="text" class="form-control width150px" id="maker_name" name="maker_name" readonly="readonly" value="${result.maker_name}">
                        </td>
                    </tr>
                </tbody>
            </table>
<!-- /상단 폼테이블 -->
<!-- 하단 폼테이블 -->
            <table class="table-border mt10">
                <colgroup>
                    <col width="100px">
                    <col width="">
                    <col width="">
                </colgroup>
                <thead>
                    <tr>
                        <th></th>
                        <th>변경전</th>
                        <th>변경후</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <th class="text-right">차주명</th>
                        <td>
                            <div class="form-row inline-pd widthfix">
                                <div class="col width110px">
                                    <input type="text" class="form-control" id="origin_cust_name" name="origin_cust_name" readonly="readonly" value="${result.cust_name}">
                                </div>
                                <div class="col width150px">
                                    <input type="text" class="form-control" id="origin_cust_no" name="origin_cust_no" readonly="readonly" value="${result.cust_no}">
                                </div>
                            </div>
                        </td>
                        <td>
                            <div class="form-row inline-pd widthfix">
                                <div class="col width120px">
                                    <div class="input-group">
                                        <input type="text" class="form-control border-right-0" id="cust_name" name="cust_name" readonly="readonly" required="required" alt="고객명">
                                        <button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchCustPanel('setCustInfo');"><i class="material-iconssearch"></i></button>
                                    </div>
                                </div>
                                <div class="col width150px">
                                    <input type="text" class="form-control" id="cust_no" name="cust_no" readonly="readonly" required="required" alt="고객명">
                                </div>
                            </div>				
                        </td>
                    </tr>
                    <tr>
                        <th class="text-right">휴대폰</th>
                        <td>
                        	<div class="form-row inline-pd widthfix">
	                        	<div class="col width120px">
	                            	<input type="text" class="form-control" id="origin_hp_no" name="origin_hp_no" readonly="readonly" format="phone" value="${result.hp_no}">
	                            </div>
                            </div>
                        </td>
                        <td>
                        	<div class="form-row inline-pd widthfix">
	                        	<div class="col width120px">
	                            	<input type="text" class="form-control" id="hp_no" name="hp_no" readonly="readonly" format="phone">
	                            </div>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <th class="text-right">주소</th>
                        <td>
                            <input type="text" class="form-control" id="origin_addr" name="origin_addr" readonly="readonly" value="${result.addr}">
                        </td>
                        <td>
                            <input type="text" class="form-control" id="addr" name="addr" readonly="readonly">
                        </td>
                    </tr>
                    <tr>
                        <th class="text-right">고객담당</th>
                        <td>
                            <div class="form-row inline-pd widthfix">
                                <div class="col width110px">
                                    <input type="text" class="form-control" id="origin_sale_mem_name" name="origin_sale_mem_name" readonly="readonly" value="${result.sale_mem_name}">
                                </div>
                                <div class="col width150px">
                                    <input type="text" class="form-control" id="origin_sale_mem_no" name="origin_sale_mem_no" readonly="readonly" value="${result.sale_mem_no}">
                                </div>
                            </div>
                        </td>
                        <td>
                            <div class="form-row inline-pd widthfix">
                                <div class="col width110px">
                                    <input type="text" class="form-control" id="sale_mem_name" name="sale_mem_name" readonly="readonly">
                                </div>
                                <div class="col width150px">
                                    <input type="text" class="form-control" id="sale_mem_no" name="sale_mem_no" readonly="readonly">
                                </div>
                            </div>
                        </td>
                    </tr>
                </tbody>
            </table>
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