<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 발주/납기관리 > 미출하부품현황-장비 지급품 > null > 임의처리
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-01-10 17:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function() {
		});
		
		function goSave() {
			var msg = "저장하시겠습니까?"
			var frm = document.main_form;		
			$M.goNextPageAjaxMsg(msg, this_page, $M.toValueForm(frm), {method : 'POST'},
				function(result) {
					if(result.success) {
						if (opener != null && opener.goSearch) {
							opener.goSearch();	
						}
						fnClose();
					};
				}
			);
		}
		
		function fnClose() {
			window.close();
		}
		
	</script>
</head>
<body class="bg-white class">
<form id="main_form" name="main_form">
<input type="hidden" value="${inputParam.machine_doc_no}" id="machine_doc_no" name="machine_doc_no">
<input type="hidden" value="${inputParam.machine_out_doc_seq}" id="machine_out_doc_seq" name="machine_out_doc_seq">
<input type="hidden" value="${inputParam.seq_no}" id="seq_no" name="seq_no">
<input type="hidden" value="${inputParam.part_no}" id="part_no" name="part_no">
<input type="hidden" value="${inputParam.no_out_qty}" id="no_out_qty" name="no_out_qty">
<input type="hidden" value="${inputParam.remark }" id="remark" name="remark">
<input type="hidden" value="${inputParam.cust_no }" id=cust_no name="cust_no">
<input type="hidden" value="${inputParam.cust_name }" id=cust_name name="cust_name">
<input type="hidden" value="${inputParam.hp_no }" id=hp_no name="hp_no">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <h2>메모</h2>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
        	<div class="title-wrap">
				<h4>임의처리메모</h4>						
			</div>
			  <table class="table-border mt5">
                 <colgroup>
                     <col width="80px">
                     <col width="">
                 </colgroup>
                 <tbody>
                 <tr>
                     <th class="text-right">비고</th>
                     <td><input class="form-control" type="text" id="desc_text" name="desc_text"></td>
                 </tr>
                 <tr>
                     <th class="text-right">처리자</th>
                     <td><input class="form-control" type="text" value="${SecureUser.kor_name }" readonly="readonly"></td>
                 </tr>
                 </tbody>
            </table>
<!-- 추가부품목록 -->
<!-- /추가부품목록 -->
<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">						
				<div class="right">
					<button type="button" class="btn btn-info" onclick="javascript:goSave();">저장</button>
					<!-- 다시 열수없으므로 주석 -->
					<!-- <button type="button" class="btn btn-info" onclick="javascript:goRemove();">삭제</button> -->
					<button type="button" class="btn btn-info" onclick="javascript:fnClose();">닫기</button>
				</div>
			</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>