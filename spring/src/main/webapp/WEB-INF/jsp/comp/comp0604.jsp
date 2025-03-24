<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 부품연관팝업 > 부품연관팝업 > null > 부품이동요청
-- 작성자 : 박예진
-- 최초 작성일 : 2020-02-19 19:53:41
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		$(document).ready(function() {
		});
	
		// 부품이동요청
		function goSave() {
			var frm = document.main_form;
			var qty = parseInt($M.getValue("qty"));
			
			// 콤보그리드 유효성 추가
			if($M.getValue("from_warehouse_cd") == ''){
				alert("보내는 창고는 필수입력입니다.");
				$('#from_warehouse_cd').next().find('input').focus()
				return;
			}
			if($M.getValue("from_warehouse_cd") == $M.getValue("to_warehouse_cd")) {
				alert("동일한 창고로는 이동할 수 없습니다.");
				return;
			}
			if($M.validation(frm, {field:['to_warehouse_cd', 'qty']}) == false) {
				return;
			}
			if (qty <= 0){
				alert("요청 수량을 다시 확인해주세요.");
				return false;
			}
			/* if (qty > confirm_qty){
				alert("요청 수량을 다시 확인해주세요.");
				return false;
			} */
			$M.goNextPageAjaxSave(this_page, $M.toValueForm(frm), { method : "POST"},
				function(result) {
					if(result.success) {
						alert("이동요청 처리되었습니다.");
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
<body class="bg-white class">
<form id="main_form" name="main_form">
<input type="hidden" id="part_no" name="part_no" value="${inputParam.part_no}">
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
				<table class="table-border">
					<colgroup>
						<col width="100px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right">보내는창고</th>
							<td>
								<div class="form-row inline-pd">
								<c:choose>
									<c:when test="${ page.fnc.F00403_001 eq 'Y' }">
										<div class="col-6">
											<input type="text" class="form-control border-right-0" style="width:100%;" alt="보내는 창고" required="required"
												id="from_warehouse_cd"
												name="from_warehouse_cd" 
												idfield="code_value"
												textfield="code_name"
												easyui="combogrid"
												header="Y"
												easyuiname="fromWarehouseList" 
												panelwidth="180"
												maxheight="155"
												multi="N"/>
										</div>
										</c:when>
										<c:otherwise>
											<div class="col-3">
												<input type="text" class="form-control width100px" value="${SecureUser.part_org_code}" id="from_warehouse_cd" name="from_warehouse_cd" readonly="readonly" required="required" alt="보내는 창고"> 
											</div>
											<div class="col-3">
												<input type="text" class="form-control width100px" value="${SecureUser.part_org_name}" readonly="readonly">
											</div>
										</c:otherwise>
										</c:choose>
									<div class="col-2">
											에서
									</div>	
								</div>		
							</td>
						</tr>
						<tr>
							<th class="text-right">받는창고</th>
							<td>
								<div class="form-row inline-pd">
										<div class="col-3">
											<input type="text" class="form-control width100px" readonly="readonly" value="${SecureUser.warehouse_cd ne '' ? SecureUser.warehouse_cd : SecureUser.org_code}" id="to_warehouse_cd" name="to_warehouse_cd" required="required" alt="받는 창고">
										</div>
										<div class="col-3">
											<input type="text" class="form-control width100px" readonly="readonly" value="${SecureUser.warehouse_cd eq partOrgCode ? partOrgName : SecureUser.org_name}">
										</div>
										<div class="col-3">
											로 이동 요청
										</div>						
								</div>
							</td>
						</tr>
						
						<tr>
							<th class="text-right">미결수량</th>
							<td>
								<input type="int" class="form-control width60px text-right" id="confirm_qty" name="confirm_qty" readonly="readonly" value="${list.qty}">
							</td>
						</tr>
						<tr>
							<th class="text-right">요청수량</th>
							<td>
								<input type="int" class="form-control width60px text-right" id="qty" name="qty" required="required" alt="요청수량" format="decimal">
							</td>
						</tr>
						<tr>
							<th class="text-right">비고</th>
							<td>
								<textarea class="form-control" style="height: 100px;" id="remark" name="remark"></textarea>
							</td>
						</tr>				
					</tbody>
				</table>
			</div>
<!-- /폼테이블 -->	

<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">						
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>