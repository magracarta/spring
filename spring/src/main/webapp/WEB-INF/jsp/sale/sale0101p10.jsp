<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 계약관리 > 계약/출하 > null > SA-R 계약정보
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-06-04 19:22:38
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		<%-- 여기에 스크립트 넣어주세요. --%>
		function goSave() {
			if($M.validation(document.main_form) == false) {
				return false;
			}
			msg = "저장하시겠습니까?";
			var frm = document.main_form;
			$M.goNextPageAjaxMsg(msg, this_page, $M.toValueForm(frm), {method : 'POST'},
					function(result) {
				    	if(result.success) {
				    		opener.isNeedSar = false;
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
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" id="cust_no" name="cust_no" value="${inputParam.cust_no}">
<input type="hidden" id="machine_doc_no" name="machine_doc_no" value="${inputParam.machine_doc_no}">
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
					<h4><span class="text-primary"></span> SA-R 계약정보</h4>	
				</div>
				<table class="table-border mt5">
                 <colgroup>
                     <col width="95px">
                     <col width="">
                     <col width="95px">
                     <col width="">
                 </colgroup>
                 <tbody>
                 <tr>
                     <th class="text-right rs">고객명</th>
                     <td>
                         <input type="text" class="form-control rb" id="cust_name" name="cust_name" alt="고객명" value="${sarInfo.cust_name}" required="required">
                     </td>
                     <th class="text-right rs">고객영문명</th>
                     <td>
                         <input type="text" class="form-control rb" id="cust_eng_name" name="cust_eng_name" alt="고객영문명" value="${sarInfo.cust_eng_name}" required="required">
                     </td>
                 </tr>
                 <tr>
                     <th class="text-right rs">휴대전화</th>
                     <td>
                         <input type="text" class="form-control rb" id="cust_hp_no" name="cust_hp_no" alt="휴대전화" value="${sarInfo.cust_hp_no}" required="required" format="phone">
                     </td>
                     <th class="text-right rs">이메일</th>
                     <td>
                         <input type="text" class="form-control rb" id="cust_email" name="cust_email" alt="이메일" value="${sarInfo.cust_email}" required="required" maxlength="100">
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