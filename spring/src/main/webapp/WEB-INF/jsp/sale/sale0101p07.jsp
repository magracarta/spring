<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 계약관리 > 계약/출하 > null > 출하사항변경
-- 작성자 : 김태훈
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		function fnClose() {
			window.close();
		}
		
		function goSave() {
			if (confirm("반드시 관리부에 확인 후 변경하세요.") == false) {
				return false;
			}
			if($M.validation(document.main_form) == false) {
				return false;
			}
			if ($M.getValue("transport_cmp_cd") != "96" && $M.toNum($M.getValue("transport_amt")) == "0") {
				alert("고객인수가 아닌 경우, 총운임을 입력해주세요.");
				$("#transport_amt").focus();
				return false;
			}
				
			var frm = $M.toValueForm(document.main_form);

			$M.goNextPageAjaxSave("/sale/sale0101p03/change/outDoc", frm, {method: 'post'},
                 function (result) {
                      if (result.success) {
                    	  setTimeout(function () {
                    		  try {
                    			  opener.fnReload();                    			  
                    		  } catch (e) {
                    			  console.log(e);
                    		  }
                    		  fnClose();
                          }, 100);
                      }
                 }
            );
		}
		
		// 출하장비 선택
        function goMachineToOut() {
        	var param = {
        		machine_plant_seq : "${outDoc.machine_plant_seq}",
				out_org_code : "${outDoc.out_org_code}",
				parent_js_name : "fnSetMachineToOut"
			}
			var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=900, height=400, left=0, top=0";
			$M.goNextPage('/sale/sale0101p06', $M.toGetParam(param), {popupStatus : poppupOption});
        }
        
        function fnSetMachineToOut(row) {
        	var param = {
        		body_no : row.body_no,
        		engine_no_1 : row.engine_no_1,
        		opt_model_1 : row.opt_model_1,
        		opt_no_1 : row.opt_no_1,
        		machine_seq : row.machine_seq
        	}
        	$M.setValue(param);
        }
		
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" value="${outDoc.machine_plant_seq}" name="machine_plant_seq">
<input type="hidden" value="${outDoc.machine_out_doc_seq}" name="machine_out_doc_seq">
<input type="hidden" value="${stockYn}" name="stock_yn">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
<!-- 폼테이블 -->					
			<div>
				<div class="title-wrap">
					<h4 class="primary">출하사항변경<span style="color: red">(운임 관련 변경 시 운임비가 이미 정산되지 않았는지 반드시 관리부에 확인 후 처리하세요)</span></h4>
				</div>
				<table class="table-border mt5">
					<colgroup>
						<col width="100px">
						<col width="">
						<col width="100px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right rs">차대번호</th>
							<td>
								<div class="input-group">
									<input type="text" class="form-control border-right-0" readonly="readonly" id="body_no" name="body_no" alt="차대번호" value="${outDoc.body_no}" required="required" disabled="disabled">
                                    <!-- <button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goMachineToOut();"><i class="material-iconssearch"></i></button> -->
                                    <input type="hidden" id="machine_seq" name="machine_seq" value="${outDoc.machine_seq }">				
								</div>
							</td>

							<c:if test="${stockYn ne 'Y'}">
								<th class="text-right rs">출고유형</th>
								<td>
									<select class="form-control rb" id="out_type_cd" name="out_type_cd" alt="출고유형" required="required">
										<option value="">- 선택 -</option>
										<c:forEach var="item" items="${codeMap['OUT_TYPE']}">
											<option value="${item.code_value}"
													<c:if test="${outDoc.out_type_cd == item.code_value}">selected="selected"</c:if>>${item.code_name}
											</option>
										</c:forEach>
									</select>
								</td>
							</c:if>


						</tr>	
						<tr>
							<th class="text-right">엔진번호1</th>
							<td>
								<input type="text" class="form-control" id="engine_no_1" name="engine_no_1" alt="엔진번호1" value="${outDoc.engine_no_1}" readonly="readonly">
								<input type="hidden" class="form-control" id="opt_model_1" name="opt_model_1" alt="옵션모델1" value="${outDoc.opt_model_1}" readonly="readonly">
								<input type="hidden" class="form-control" id="opt_no_1" name="opt_no_1" alt="옵션번호1" value="${outDoc.opt_no_1}" readonly="readonly">	
							</td>
							<th class="text-right rs">운송사</th>
							<td>
								<select class="form-control rb" id="transport_cmp_cd" name="transport_cmp_cd" required="required" ${not empty outDoc.transport_mem_no ? 'disabled' : ''}>
                                	<option value="">- 선택 -</option>
                                    <c:forEach var="item" items="${codeMap['TRANSPORT_CMP']}">
                                        <option value="${item.code_value}"
                                        	<c:if test="${outDoc.transport_cmp_cd == item.code_value}">selected="selected"</c:if>>${item.code_name}
                                        </option>
                                    </c:forEach>
                                </select>
							</td>									
						</tr>	
						<tr>
							<th class="text-right">총운임</th>
							<td>
								<div class="form-row inline-pd widthfix">
                                    <div class="col width120px">
                                        <input type="text" class="form-control text-right" id="transport_amt" name="transport_amt" value="${outDoc.transport_amt }" alt="총운임" format="decimal" ${not empty outDoc.transport_mem_no ? 'disabled' : ''}>
                                    </div>
                                    <div class="col width16px">원</div>
                                </div>
							</td>	
							<th class="text-right rs">연락처</th>
							<td>
								<div class="form-row inline-pd widthfix">
                                    <div class="col width120px">
                                        <input type="text" class="form-control rb" id="transport_tel_no" name="transport_tel_no" alt="연락처" value="${outDoc.transport_tel_no}" maxlength="14" format="tel" size="20" required="required">
                                    </div>
                                </div>
							</td>	
						</tr>
						<tr>
							<th class="text-right">특이사항</th>
							<td colspan="3">
								<div style="line-height: 60px; height: 60px">
									<textarea id="out_remark" name="out_remark" style="height: 60px;">${outDoc.out_remark}</textarea>
								</div>
							</td>
						</tr>	
					</tbody>
				</table>
			</div>		
<!-- /폼테이블 -->
			<div class="btn-group mt10">
				<div class="right">
					<span style="float: left">운임비 정산 직원 : ${outDoc.transport_mem_name }</span>
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>