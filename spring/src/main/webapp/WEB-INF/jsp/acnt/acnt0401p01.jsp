<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 정산 > 장비입고관리-통관 > null > 통관처리
-- 작성자 : 김상덕
-- 최초 작성일 : 2020-04-08 18:03:57
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
	var parentData = opener.setData;
	var mngList = parentData.mng_cost; // 부모창의 부대비용정보
	var amtData = ${mngCostJsonList};  // 이미저장했다면 저장한 부대비용정보
	var passInfoJsonData = ${passInfoJosnData};
	var passInfo = opener.passInfo;
	
		$(document).ready(function() {
			fnInit();
		});
	
		function fnInit() {
			console.log("부모창에서 넘겨준 : ", parentData);
			console.log("부모창에서 넘겨준 passInfo : ", passInfo);
			console.log("passInfoJsonData : ", passInfoJsonData);
// 			$M.setValue("pass_dt", parentData.pass_dt);
// 			$M.setValue("pass_mng_no", parentData.pass_mng_no);
// 			$M.setValue("pass_report_no", parentData.pass_report_no);
// 			$M.setValue("pass_proc_date", parentData.pass_proc_date);
// 			$M.setValue("pass_yn", parentData.pass_yn);
			$M.setValue("pass_dt", passInfo.pass_dt);
			$M.setValue("apply_er_price", passInfo.apply_er_price);
			$M.setValue("load_cost_amt", passInfo.load_cost_amt);
			$M.setValue("pass_mng_no", passInfo.pass_mng_no);
			$M.setValue("pass_report_no", passInfo.pass_report_no);
// 			$M.setValue("pass_proc_date", passInfo.pass_proc_date);
			$M.setValue("pass_yn", passInfo.pass_yn);
			
			console.log("mngList : ", mngList);
			console.log("amtData : ", amtData);
			// 부대비용 세팅
			var idx;
			for (var i = 0; i < 10; i++) {
				if (i != 9) {
					idx = "0" + (i+1);
				} else {
					idx = "" + (i+1);
				}
				
				// 부모창에서 보낸 부대비용정보가 없을시 기존 저장된 데이터를 세팅
				if (amtData.length == 0) {
					if (passInfo.mng_cost != undefined) {
						$M.setValue("amt" + idx, passInfo.mng_cost[i].amt);
					}
				} else {
					$M.setValue("amt" + idx, amtData[i].amt);
				}
			}
		}
	
		// 닫기
		function fnClose() {
			window.close();
		}
		
		function goSave() {
			var frm = document.main_form;
			if($M.validation(frm) == false) { 
				return false;
			};
			
// 			if (confirm("저장 하시겠습니까 ?") == false) {
// 				return false;
// 			}

			// 부대비용
			var idx;
			var mngCostList = [];
			var machineShipMngCostCdArr = [];
			var machineShipMngCostAmtArr = [];
			
			for (var i = 1; i <= 10; i++) {
				if (i != 10) {
					idx = "0" + i;
				} else {
					idx = "" + i;
				}
				var code = $M.getValue("machine_ship_mng_cost_cd" + idx);
				var amt;
				
				amt = $M.getValue("amt" + idx)
				
				if (amt == "") {
					amt = 0;
				}
					
				console.log("코드 : ", $M.getValue("machine_ship_mng_cost_cd" + idx));
				console.log("값 : ", $M.getValue("amt" + idx));
				
				var row = new Object();
				row.machine_seq = $M.getValue("machine_seq");
				row.machine_ship_mng_cost_cd = code;
				row.amt = amt;
				mngCostList.push(row);
				machineShipMngCostCdArr.push(code);
				machineShipMngCostAmtArr.push(amt);
			}
			
			console.log("mngCostList : ", mngCostList);
			console.log("machineShipMngCostCdArr : ", machineShipMngCostCdArr);
			console.log("machineShipMngCostAmtArr : ", machineShipMngCostAmtArr);
			var codeList = $M.getArrStr(machineShipMngCostCdArr, {sep : "^", isEmpty : true});
			var amtList = $M.getArrStr(machineShipMngCostAmtArr, {sep : "^", isEmpty : true});
			
			console.log("codeList : ", codeList);
			console.log("amtList : ", amtList);
			
			var toGridParam = {
					machine_seq : $M.getValue("machine_seq")
					, pass_dt : $M.getValue("pass_dt")
					, pass_mng_no : $M.getValue("pass_mng_no")
					, apply_er_price : $M.getValue("apply_er_price")
					, pass_report_no : $M.getValue("pass_report_no")
					, pass_proc_date : $M.getValue("pass_proc_date")
// 					, pass_yn : $M.getValue("pass_yn")
					, load_cost_amt : $M.getValue("load_cost_amt")
					, machine_ship_mng_cost_cd : codeList
					, machine_ship_mng_cost_amt : amtList
					, mng_cost : mngCostList
					, made_year : $M.getValue("pass_dt").substring(0, 4)
			};
			
// 			alert("본창에서 저장시 최종 저장처리가 완료 됩니다.");
   			try {
//     			opener.goSearch();
				opener.fnSetData(toGridParam);
				opener.goSave("CHILD");
				fnClose();
   			} catch(e) {
				alert("통관처리는 장비통관등록 팝업(본창)을 닫으시면 진행이 불가능합니다.");		
				return;
   			}			
// 			opener.fnSetData(toGridParam);
// 			opener.goSave("CHILD");
		}
		
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" id="machine_seq" name="machine_seq" value="${inputParam.machine_seq}">
<input type="hidden" id="maker_cd" name="maker_cd" value="${inputParam.maker_cd}">
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
				<table class="table-border mt5">
					<colgroup>
						<col width="100px">
						<col width="">
						<col width="100px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right essential-item">통관일자</th>
							<td>
								<div class="input-group width120px">
									<input type="text" class="form-control border-right-0 essential-bg calDate" dateformat="yyyy-MM-dd" id="pass_dt" name="pass_dt" value="" alt="통관일자" required="required">
								</div>
							</td>
							<th class="text-right essential-item">관리번호</th>
							<td>
								<input type="text" class="form-control width120px essential-bg" id="pass_mng_no" name="pass_mng_no" value="${passInfo.pass_mng_no}" alt="관리번호" required="required">
							</td>
						</tr>
						<tr>
							<th class="text-right essential-item">기준환율</th>
							<td>
<%-- 								<input type="text" class="form-control width120px" id="apply_er_price" name="apply_er_price" value="${exchangeRate.fixed_er_price}" alt="기준환율" required="required" format="decimal" readonly> --%>
								<input type="text" class="form-control text-right width120px essential-bg" id="apply_er_price" name="apply_er_price" value="" alt="기준환율" required="required" format="decimal4">
							</td>
							<th class="text-right essential-item">신고번호</th>
							<td>
								<input type="text" class="form-control width120px essential-bg" id="pass_report_no" name="pass_report_no" value="${passInfo.pass_report_no}" alt="신고번호" required="required">
							</td>
						</tr>
						<tr>
							<th class="text-right">처리일자</th>
							<td>
<!-- 								<div class="input-group width120px"> -->
									<input type="text" class="form-control width80px" dateformat="yyyy-MM-dd" id="pass_proc_date" name="pass_proc_date" value="${s_today_date}" alt="처리일자" required="required" readonly>
<!-- 								</div> -->
							</td>
							<th class="text-right">처리구분</th>
							<td>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio">
									<label class="form-check-label">취소</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" checked>
									<label class="form-check-label">처리</label>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">입항료</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width100px">
										<input type="hidden" name="machine_ship_mng_cost_cd01" value="01">
										<input type="text" class="form-control text-right" id="amt01" name="amt01" format="decimal">
									</div>
									<div class="col width22px">원</div>
								</div>
							</td>
							<th class="text-right">세관검사</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width100px">
										<input type="hidden" name="machine_ship_mng_cost_cd02" value="02">
										<input type="text" class="form-control text-right" id="amt02" name="amt02" format="decimal">
									</div>
									<div class="col width22px">원</div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">선박운임</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width100px">
										<input type="hidden" name="machine_ship_mng_cost_cd03" value="03">
										<input type="text" class="form-control text-right" id="amt03" name="amt03" format="decimal">
									</div>
									<div class="col width22px">원</div>
								</div>
							</td>
							<th class="text-right">시외운송</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width100px">
										<input type="hidden" name="machine_ship_mng_cost_cd04" value="04">
										<input type="text" class="form-control text-right" id="amt04" name="amt04" format="decimal">
									</div>
									<div class="col width22px">원</div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">하역료</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width100px">
										<input type="hidden" name="machine_ship_mng_cost_cd05" value="05">
										<input type="text" class="form-control text-right" id="amt05" name="amt05" format="decimal">
									</div>
									<div class="col width22px">원</div>
								</div>
							</td>
							<th class="text-right">취급수수</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width100px">
										<input type="hidden" name="machine_ship_mng_cost_cd06" value="06">
										<input type="text" class="form-control text-right" id="amt06" name="amt06" format="decimal">
									</div>
									<div class="col width22px">원</div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">컨테이너</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width100px">
										<input type="hidden" name="machine_ship_mng_cost_cd07" value="07">
										<input type="text" class="form-control text-right" id="amt07" name="amt07" format="decimal">
									</div>
									<div class="col width22px">원</div>
								</div>
							</td>
							<th class="text-right">통관수수</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width100px">
										<input type="hidden" name="machine_ship_mng_cost_cd08" value="08">
										<input type="text" class="form-control text-right" id="amt08" name="amt08" format="decimal">
									</div>
									<div class="col width22px">원</div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">보관료</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width100px">
										<input type="hidden" name="machine_ship_mng_cost_cd09" value="09">
										<input type="text" class="form-control text-right" id="amt09" name="amt09" format="decimal">
									</div>
									<div class="col width22px">원</div>
								</div>
							</td>
							<th class="text-right">기타</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width100px">
										<input type="hidden" name="machine_ship_mng_cost_cd10" value="10">	
										<input type="text" class="form-control text-right" id="amt10" name="amt10" format="decimal">
									</div>
									<div class="col width22px">원</div>
								</div>
							</td>
						</tr>
						<!-- 부대비용 -->
<%-- 						<c:forEach var="item" items="${mngCostList}" varStatus="status"> --%>
<%-- 								<c:if test="${ status.count % 2 == 1 }"><tr></c:if> --%>
<%-- 								<th class="text-right">${item.code_name}</th> --%>
<!-- 								<td> -->
<!-- 									<div class="form-row inline-pd widthfix"> -->
<!-- 										<div class="col width100px"> -->
<%-- 											<input type="text" class="form-control text-right" id="mng_cost" name="mng_cost" value="${item.amt}" format="num"> --%>
<%-- 											<input type="hidden" id="machine_ship_mng_cost_cd" name="machine_ship_mng_cost_cd" value="${item.machine_ship_mng_cost_cd}"> --%>
<!-- 										</div> -->
<!-- 										<div class="col width22px">원</div> -->
<!-- 									</div> -->
<!-- 								</td> -->
<%-- 								<c:if test="${ status.count % 2 == 0 }"></c:if> --%>
<%-- 						</c:forEach> --%>
						<!-- 부대비용 -->
<%-- 						<c:forEach var="item" items="${codeMap.MACHINE_SHIP_MNG_COST}" varStatus="status"> --%>
<%-- 							<c:if test="${item.show_yn eq 'Y' && item.use_yn eq 'Y'}"> --%>
<%-- 								<c:if test="${ status.count % 2 == 1 }"><tr></c:if> --%>
<%-- 								<th class="text-right">${item.code_name}</th> --%>
<!-- 								<td> -->
<!-- 									<div class="form-row inline-pd widthfix"> -->
<!-- 										<div class="col width100px"> -->
<%-- 											<c:set var="codeValue" value="${item.code_value}"/> --%>
<%-- 											<input type="text" class="form-control text-right" id="${item.code_value}" name="${item.code_value}" value="" format="num"> --%>
<%-- 											<input type="hidden" name="machine_ship_mng_cost_cd" value="${item.code_value}"> --%>
<!-- 										</div> -->
<!-- 										<div class="col width22px">원</div> -->
<!-- 									</div> -->
<!-- 								</td> -->
<%-- 								<c:if test="${ status.count % 2 == 0 }"></tr></c:if> --%>
<%-- 							</c:if> --%>
<%-- 						</c:forEach> --%>
						<tr>
							<th class="text-right essential-item">선임외화</th>
							<td colspan="3">
								<div class="form-row inline-pd widthfix">
									<div class="col width100px">
										<input type="text" class="form-control text-right essential-bg" id="load_cost_amt" name="load_cost_amt" value="${loadCost.amt}" alt="선임외화" required="required" format="num">
									</div>
									<div class="col width22px">원</div>
								</div>
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