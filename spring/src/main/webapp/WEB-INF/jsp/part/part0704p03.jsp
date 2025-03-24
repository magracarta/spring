<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 코드관리 > 부품판가산출지표 > null > 환율경고설정
-- 작성자 : 정윤수
-- 최초 작성일 : 2022-09-23 13:55:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
	// 저장
	function goSave() {
		var arr = $('.money_unit_cd').map(function() {
			return this.value;
		}).get();
		var groupCodeArr = $('.group_code').map(function() {
			return this.value;
		}).get();
		var waringArr = [];
		for (var i = 0; i < arr.length; ++i) {
			waringArr.push($M.getValue(arr[i]+"_waring"));
		}
		var param = {
			group_code_str : groupCodeArr.join("#"),
			code_str :  arr.join("#"),
			code_v2_str : waringArr.join("#")
		}
		$M.goNextPageAjaxSave(this_page + "/save", $M.toGetParam(param), {method : 'POST'},
				function(result) {
					if(result.success) {
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
				<!-- 환율경고 설정 -->
				<div class="title-wrap mt10">
					<h4>환율경고설정</h4>
				</div>
				<table class="table-border mt5">
					<colgroup>
						<col width="100px">
						<col width="120px">
						<col width="">
					</colgroup>
					<tbody>
					<c:forEach var="item" items="${list}">
						<tr>
							<th style="width:100px; background: #efefef !important">
									${item.code}
									<input type="hidden" class="money_unit_cd input-div" value="${item.code}" disabled="disabled" style="background: #efefef !important">
							</th>
							<td class="text-right">
								<input type="text" class="form-control text-right" format="decimal" id="${item.code}_waring" name="${item.code}_waring" maxlength="8" value="${item.code_v2}">
								<input type="hidden" class="group_code input-div" value="MONEY_UNIT" disabled="disabled" style="background: #efefef !important">
							</td>
							<td>
								<div><span> 원 이상이면 담당자에게 쪽지발송</span></div>
							</td>
						</tr>
					</c:forEach>
					</tbody>
				</table>
				<!-- / 환율경고 설정  -->

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