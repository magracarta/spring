<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 장부 > 운송사별운임정산 > null > 별도운임관리상세
-- 작성자 : 황빛찬
-- 최초 작성일 : 2020-04-08 18:03:57
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

	$(document).ready(function() {
		fnInit();
	});

	function fnInit() {
		var radioVal = $M.getValue("radioCheck");
		if (radioVal == "member") {
			$("#order_org_btn").attr("disabled", true);
		} else {
			$("#order_mem_btn").attr("disabled", true);
		}
	}

	// 출고지시자 - 센터
	function fnSetOrderOrgCode(result) {
		console.log("result center : ", result);
		$M.setValue("order_org_code", result.org_code);
		$M.setValue("order_org_name", result.org_name);
	}

	// 출고지시자 - 직원
	function fnSetOrderMemberInfo(result) {
		console.log("result mem_no : ", result);
		$M.setValue("order_mem_no", result.mem_no);
		$M.setValue("order_mem_name", result.mem_name);
	}

	// 정산대리점
	function fnSetOrgMapPanel(result) {
		$M.setValue("calc_org_code", result.org_code);
		$M.setValue("calc_org_name", result.org_name);

	}

	// 출고자
	function fnSetOutMemberInfo(result) {
		console.log("result2 : ", result);
		$M.setValue("out_mem_no", result.mem_no);
		$M.setValue("out_mem_name", result.mem_name);
	}

	// 주소팝업
	function fnJusoBiz(data) {
		$M.setValue("arrival1_post_no", data.zipNo);
		$M.setValue("arrival1_addr1", data.roadAddrPart1);
		$M.setValue("arrival1_addr2", data.addrDetail);
	}

	// 출고지시자 센터/직원 radio 제어
	function fnOrderChange() {
		var val = $M.getValue("radioCheck");

		if (val == "center") {
			$M.setValue("order_mem_no", "");
			$M.setValue("order_mem_name", "");
// 			$M.clearValue({field : ["order_mem_no", "order_mem_name"]});
			$("#order_org_btn").attr("disabled", false);
			$("#order_mem_btn").attr("disabled", true);
		} else {
			$M.setValue("order_org_code", "");
			$M.setValue("order_org_name", "");
// 			$M.clearValue({field : ["order_org_code", "order_org_name"]});
			$("#order_org_btn").attr("disabled", true);
			$("#order_mem_btn").attr("disabled", false);
		}
	}

	// 닫기
	function fnClose() {
		window.close();
	}

	// 수정
	function goModify() {
		var frm = document.main_form;
		// 입력폼 벨리데이션
		if($M.validation(frm) == false) {
			return;
		}

		if (confirm("수정 하시겠습니까 ?") == false) {
			return false;
		}

		frm = $M.toValueForm(frm);

		console.log("frm : ", frm);

		$M.goNextPageAjax(this_page + "/modify", frm , {method : 'POST'},
			function(result) {
	    		if(result.success) {
	    			alert("수정이 완료되었습니다.");
	    			fnClose();
	    			window.opener.location.reload();
				}
			}
		);
	}

	// 삭제
	function goRemove() {
		if (confirm("삭제 하시겠습니까 ?") == false) {
			return false;
		}

		var param = {
				machine_delivery_no : $M.getValue("machine_delivery_no")
		}

		$M.goNextPageAjax(this_page + "/remove", $M.toGetParam(param) , {method : 'POST'},
			function(result) {
	    		if(result.success) {
	    			alert("삭제가 완료되었습니다.");
	    			fnClose();
	    			window.opener.location.reload();
				}
			}
		);
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
		<div>
			<div class="title-wrap">
				<h4>별도운임관리상세</h4>
			</div>
			<!-- 폼테이블 -->
			<div>
				<table class="table-border mt5">
					<colgroup>
						<col width="100px">
						<col width="">
					</colgroup>
					<tbody>
					<tr>
						<th class="text-right essential-item">관리번호</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width120px">
									<input type="text" class="form-control" id="machine_delivery_no" name="machine_delivery_no" value="${map.machine_delivery_no}" readonly>
								</div>
							</div>
						</td>
					</tr>
					<tr>
						<th class="text-right essential-item">품목</th>
						<td>
							<input type="text" class="form-control essential-bg" id="prod_name" name="prod_name" alt="품목" required="required" value="${map.prod_name}">
						</td>
					</tr>
					<tr>
						<th class="text-right">수량(비고)</th>
						<td>
							<input type="text" class="form-control" id="remark" name="remark" alt="수량(비고)" value="${map.remark}">
						</td>
					</tr>
					<tr>
						<th class="text-right">출고지시자</th>
						<td>
							<div class="form-row inline-pd mb7">
								<div class="col-4">
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="radio1" name="radioCheck" checked="checked" value="center" onchange="javascript:fnOrderChange();" ${map.order_org_code != '' ? 'checked="checked"' : ''}>
										<label class="form-check-label" for="radio1">센터</label>
									</div>
								</div>
								<div class="col-8">
									<div class="input-group">
										<input type="text" class="form-control border-right-0" id="order_org_name" name="order_org_name" value="${map.order_org_name}" readonly>
										<input type="hidden" id="order_org_code" name="order_org_code" value="${map.order_org_code}">
<!-- 											<button type="button" class="btn btn-icon btn-primary-gra"><i class="material-iconssearch"></i></button> -->
										<button type="button" class="btn btn-icon btn-primary-gra" id="order_org_btn" name="order_org_btn" onclick="openOrgMapPanel('fnSetOrderOrgCode');"><i class="material-iconssearch"></i></button>
									</div>
								</div>
							</div>
							<div class="form-row inline-pd">
								<div class="col-4">
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="radio2" name="radioCheck" value="member" onchange="javascript:fnOrderChange();" ${map.order_mem_no != '' ? 'checked="checked"' : ''}>
										<label class="form-check-label" for="radio2">직원</label>
									</div>
								</div>
								<div class="col-8">
									<div class="input-group">
										<input type="text" class="form-control border-right-0" id="order_mem_name" name="order_mem_name" value="${map.order_mem_name}" readonly>
										<input type="hidden" id="order_mem_no" name="order_mem_no" value="${map.order_mem_no}">
<!-- 											<button type="button" class="btn btn-icon btn-primary-gra"><i class="material-iconssearch"></i></button> -->
										<button type="button" class="btn btn-icon btn-primary-gra" id="order_mem_btn" name="order_mem_btn" onclick="openSearchMemberPanel('fnSetOrderMemberInfo');"><i class="material-iconssearch"></i></button>
									</div>
								</div>
							</div>
						</td>
					</tr>
					<tr>
						<th class="text-right essential-item">화물도착지</th>
							<td>
								<div class="form-row inline-pd mb7">
									<div class="col-5">
										<input type="text" class="form-control essential-bg width120px" name="arrival1_post_no" id="arrival1_post_no" required="required" alt="주소" value="${map.arrival1_post_no}" readonly>
									</div>
									<div class="col-auto">
										<button type="button" class="btn btn-primary-gra" onclick="javascript:openSearchAddrPanel('fnJusoBiz');">주소찾기</button>
									</div>
								</div>
								<div class="form-row inline-pd mb7">
									<div class="col-10">
										<input type="text" class="form-control essential-bg width280px" name="arrival1_addr1" id="arrival1_addr1" maxlength="100" required="required" alt="주소" value="${map.arrival1_addr1}" readonly>
									</div>
								</div>
								<div class="form-row inline-pd mb7">
									<div class="col-10">
										<input type="text" class="form-control width280px" name="arrival1_addr2" id="arrival1_addr2" maxlength="100" value="${map.arrival1_addr2}">
									</div>
								</div>
							</td>
					</tr>
					<tr>
						<th class="text-right">도착지연락처</th>
						<td>
							<input type="text" class="form-control width120px" id="receive_user_tel_no" name="receive_user_tel_no" alt="도착지연락처" value="${map.receive_user_tel_no}">
						</td>
					</tr>
					<tr>
						<th class="text-right essential-item">운송사</th>
						<td>
							<select class="form-control essential-bg width160px" id="transport_cmp_cd" name="transport_cmp_cd" alt="운송사" required="required">
								<option value="">- 전체 -</option>
								<c:forEach items="${codeMap['TRANSPORT_CMP']}" var="item">
									<option value="${item.code_value}" ${item.code_value == map.transport_cmp_cd ? 'selected' : ''}>${item.code_name}</option>
								</c:forEach>
							</select>
						</td>
					</tr>
					<tr>
						<%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체 --%>
						<%--<th class="text-right">정산대리점</th>--%>
						<th class="text-right">정산위탁판매점</th>
						<td>
							<div class="input-group width120px">
								<input type="text" class="form-control border-right-0" id="calc_org_name" name="calc_org_name" alt="정산위탁판매점" readonly value="${map.calc_org_name}">
								<input type="hidden" id="calc_org_code" name="calc_org_code" value="${map.calc_org_code}">
								<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openOrgMapPanel('fnSetOrgMapPanel');"><i class="material-iconssearch"></i></button>
							</div>
						</td>
					</tr>
					<tr>
						<th class="text-right">연락처</th>
						<td>
							<input type="text" class="form-control width120px" id="transport_tel_no" name="transport_tel_no" alt="연락처" value="${map.transport_tel_no}">
						</td>
					</tr>
					<tr>
						<th class="text-right essential-item">운임</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width100px">
									<input type="text" class="form-control essential-bg text-right" id="transport_amt" name="transport_amt" alt="운임" required="required" format="num" value="${map.transport_amt}">
								</div>
								<div class="col width22px">원</div>
								<div class="col width100px">
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="checkbox" id="delivery_type_ot" name="delivery_type_ot" alt="배송구분" value="T" ${map.delivery_type_ot == 'T' ? 'checked="checked"' : ''}>
										<label class="form-check-label" for="delivery_type_ot">왕복</label>
									</div>
								</div>
							</div>
						</td>
					</tr>
					<tr>
						<th class="text-right">출고일자</th>
						<td>
							<div class="input-group width120px">
								<input type="text" class="form-control border-right-0 calDate" id="out_dt" name="out_dt" dateFormat="yyyy-MM-dd" value="${map.out_dt}" alt="출고일" readonly>
							</div>
						</td>
					</tr>
					<tr>
						<th class="text-right">출고자</th>
						<td>
							<div class="input-group width120px">
								<input type="text" class="form-control border-right-0" id="out_mem_name" name="out_mem_name" alt="출고자" readonly value="${map.out_mem_name}">
								<input type="hidden" id="out_mem_no" name="out_mem_no" value="${map.out_mem_no}">
								<button type="button" class="btn btn-icon btn-primary-gra" onclick="openSearchMemberPanel('fnSetOutMemberInfo');"><i class="material-iconssearch"></i></button>
							</div>
						</td>
					</tr>
					</tbody>
				</table>
			</div>
			<!-- /폼테이블 -->
		</div>
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
