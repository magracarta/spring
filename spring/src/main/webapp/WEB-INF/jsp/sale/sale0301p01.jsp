<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 영업관리 > 출하종결처리 > null > 센터출하확인
-- 작성자 : 김태훈
-- 최초 작성일 : 2019-12-19 14:23:48
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
			if ("${outDoc.out_confirm_dt}" == "") {
				$M.setValue("out_confirm_dt", "${inputParam.s_current_dt}");
			}
		}
	
		function goContract() {
			var params = {
				"machine_doc_no" : "${outDoc.machine_doc_no}"
			};
			var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1300, height=750, left=0, top=0";
			$M.goNextPage('/sale/sale0101p01', $M.toGetParam(params), {popupStatus : popupOption});
		}
		
		function setOrgMapCenterPanel(row) {
			var param = {
				account_org_code : row.org_code,
				account_org_name : row.org_name
			}
			$M.setValue(param);
		}
		
		function goCalculate() {
			if($M.validation(document.main_form) == false) {
				return false;
			}
			var frm = document.main_form;
			var confirmDt = $M.getValue("out_confirm_dt");
			var msg = "확인일자가 "+$M.dateFormat(confirmDt, 'yyyy-MM-dd')+"입니다.\n서비스 정산 처리하시겠습니까?"
			$M.goNextPageAjaxMsg(msg, this_page, $M.toValueForm(frm), {method: 'post'},
                  function (result) {
                       if (result.success) {
                    	   if (opener != null && opener.goSearch) {
                    		   opener.goSearch();
                    	   }
                       }
                  }
            );
		}
		
		// 업무DB 연결 함수 21-08-06이강원
     	function openWorkDB(){
     		openWorkDBPanel('',${outDoc.machine_plant_seq});
     	}
		
		function fnClose() {
			window.close(); 
		}

		// 판매가 변동내역 팝업 호출
		function fnMachinePriceHistoryPopup() {
			var param = {
				machine_plant_seq : $M.getValue("machine_plant_seq"),
				s_sort_key : "change_dt",
				s_sort_method : "desc"
			};

			var poppupOption = "";
			$M.goNextPage('/sale/sale0206p02', $M.toGetParam(param), {popupStatus : poppupOption});
		}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" value="${outDoc.machine_out_doc_seq}" name="machine_out_doc_seq">
<input type="hidden" value="${outDoc.machine_plant_seq}" name="machine_plant_seq">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
           <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">	
			<div class="title-wrap">		
				<h4 class="primary">센터출하확인</h4>			
			</div>	
<!-- 상단 폼테이블 -->	
			<div>
				<table class="table-border mt5" style="min-width : 700px;">
					<colgroup>
						<col width="100px">
						<col width="">
						<col width="100px">
						<col width="">
						<col width="100px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right">판매자</th>
							<td>${outDoc.doc_mem_name}</td>
							<th class="text-right">고객명</th>
							<td>${outDoc.cust_name}</td>
							<th class="text-right">모델명</th>
							<td>
								<div class="form-row inline-pd pr">
									<div class="col-auto">
										${outDoc.machine_name}
									</div>
									<div class="col-auto">
				                        <button type="button" class="btn btn-primary-gra" onclick="javascript:openWorkDB();">업무DB</button>
						            </div>
								</div>
							</td>
						</tr>						
						<tr>
							<th class="text-right rs">처리구분</th>
							<td>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" id="out_confirm_yn_n" name="out_confirm_yn" value="N" <c:if test="${outDoc.out_confirm_yn eq 'N'}">checked="checked"</c:if>>
									<label class="form-check-label" for="out_confirm_yn_n">미확인</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" id="out_confirm_yn_y" name="out_confirm_yn" value="Y" <c:if test="${outDoc.out_confirm_yn eq 'Y'}">checked="checked"</c:if>>
									<label class="form-check-label" for="out_confirm_yn_y">확인</label>
								</div>
							</td>									
							<th class="text-right">판매금액</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width110px">
										<input type="text" class="form-control text-right" readonly="readonly" value="${outDoc.sale_price }" format="decimal" id="sale_price" name="sale_price">
									</div>
									<div class="col width10px">원</div>
								</div>
							</td>	
							<th class="text-right">가격할인</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width110px">
										<input type="text" class="form-control text-right" readonly="readonly" value="${outDoc.discount_amt }" format="decimal" id="discount_amt" name="discount_amt">
									</div>
									<div class="col width10px">원</div>
								</div>
							</td>	
						</tr>
						<tr>
							<th class="text-right">중고손실</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width110px">
										<input type="text" class="form-control text-right" readonly="readonly" value="${outDoc.machine_used_loss_amt }" format="decimal" id="machine_used_loss_amt" name="machine_used_loss_amt">
									</div>
									<div class="col width10px">원</div>
								</div>
							</td>									
							<th class="text-right">지급품계</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width110px">
										<input type="text" class="form-control text-right" readonly="readonly" value="${outDoc.out_part_amt}" format="decimal" id="out_part_amt" name="out_part_amt">
									</div>
									<div class="col width10px">원</div>
								</div>
							</td>	
							<th class="text-right">기회비용</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width110px">
										<input type="text" class="form-control text-right" readonly="readonly" format="decimal" value="${outDoc.opportunity_cost}" id="opportunity_cost" name="opportunity_cost">
									</div>
									<div class="col width10px">원</div>
								</div>
							</td>	
						</tr>
						<tr>
							<th class="text-right">계약금액</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width110px">
										<input type="text" class="form-control text-right" readonly="readonly" value="${outDoc.contract_amt }" format="decimal" id="contract_amt" name="contract_amt">
									</div>
									<div class="col width10px">원</div>
								</div>
							</td>									
							<th class="text-right">서비스정산</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width110px">
										<input type="text" class="form-control text-right" value="${outDoc.service_account_amt }" format="decimal" id="service_account_amt" name="service_account_amt" >
									</div>
									<div class="col width10px">원</div>
								</div>
							</td>	
							<th class="text-right rs">확인일자</th>
							<td>
								<div class="input-group">
									<input type="text" class="form-control border-right-0 calDate rb width100px" value="${outDoc.out_confirm_dt }" dateFormat="yyyy-MM-dd" required="required" alt="확인일자" id="out_confirm_dt" name="out_confirm_dt">
								</div>
							</td>
						</tr>		
						<tr>
							<!-- 천태욱(강릉), 정성희(일산)일 경우에만 보임 -->
							<c:if test="${outDoc.doc_mem_no eq 'MB00000278' or outDoc.doc_mem_no eq 'MB00000587'}">
								<th class="text-right">정산센터</th>
								<td>
									<div class="input-group width110px">
										<input type="text" class="form-control border-right-0" value="${outDoc.account_org_name}" id="account_org_name" name="account_org_name" readonly="readonly" style="background: white;">
										<input type="hidden" id="account_org_code" name="account_org_code" value="${outDoc.account_org_code}">
										<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openOrgMapCenterPanel('setOrgMapCenterPanel');"><i class="material-iconssearch"></i></button>
									</div>
								</td>
							</c:if>
							<!-- Q&A 11657 관련. t_machine_sale_out_doc.account_org_code에 안들어가서 통계테이블 값이 안만들어져서 추가 210616 김상덕 -->
							<c:if test="${outDoc.doc_mem_no ne 'MB00000278' and outDoc.doc_mem_no ne 'MB00000587'}">
								<input type="hidden" id="account_org_code" name="account_org_code" value="${outDoc.account_org_code}">
							</c:if>
							<th class="text-right">기타사항</th>
							<td colspan="3">
								<input type="text" class="form-control" id="out_end_remark" name="out_end_remark" value="${outDoc.out_end_remark}">
							</td>	
						</tr>					
					</tbody>
				</table>
			</div>
<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">						
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
<!-- /상단 폼테이블 -->
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>