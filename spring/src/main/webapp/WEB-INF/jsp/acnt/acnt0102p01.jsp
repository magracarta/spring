<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 비용관리 > 전도금정산서 > null > 전표처리
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-04-08 17:55:01
-- 전도금 전표처리
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		
		$(document).ready(function () {	
			
			//관리번호 차량관련이 해당무인경우에는 안보이게
			switch("${bean.card_car_use_cd}")
			{				
				case "01" :  //유류비
				case "02" :  //수리비
				case "03" :  //통행료
				case "04" :  $("#btnCarSearch").attr("disabled", false);	break;			//주차료
				default   :  $("#btnCarSearch").attr("disabled", true);   break;
			}
			
			//경리 확인된 건은 저장,삭제버튼 비노출 및 모든 버튼 disable,readonly="readonly" 처리
			if('${bean.duzon_trans_yn}' == 'Y' ) {	
				$("#btnMachineRfqSearch").attr("disabled", true);  
				$("#btnPartRfqSearch").attr("disabled", true); 
				$("#btnCarSearch").attr("disabled", true); 
				$("#btnUseMemSearch").attr("disabled", true); 
				$("#card_car_use_cd").attr("disabled", true); 
	          	$("input[name=card_use_cd]").each(function(i) {       
	              	$(this).attr('disabled', "true");
	          	});
	          	$("#remark").attr("readonly", true);
	          	$("#_goSave").css("display", "none");
	          	$("#_goRemove").css("display", "none");
			}
			
			// asis casebycase5 3이면 disabled
			if ("3" == "${bean.imprest_status_cd}") {
				$("#inout_type_cd").attr("disabled", true);
				$("#acc_type_cd").attr("disabled", true);
				$("#account_no").attr("disabled", true);
				$("#btnSearchUser").attr("disabled", true);
				$("#btnSearchAcnt").attr("disabled", true);
			}
			
			var responseMessage = "<c:out value="${error}" />";
	        if(responseMessage != "") {
	            alert(responseMessage);
	        }
			
			fnSetAccTypeCd();
			fnChangeUse();
		});

		// 2023-07-25 주석처리 황빛찬 (Q&A 14323) 차량관련 카드사용내역 상세와 동일하게 적용
		// 셀렉트박스 변경시 처리 ( 카드차량사용코드 )
		// function fnChangeCardCarUse(obj){
		//
		// 	switch(obj.value)
		// 	{
		// 		case "01" :  $("#btnCarSearch").attr("disabled", false);
		//
		// 					if($M.getValue("own_car_no") != "" ) {
		// 						 $M.setValue("car_code",$M.getValue("own_car_code"));
		// 						 $M.setValue("car_no",$M.getValue("own_car_no"));
		// 					}
		// 					$(".car_show").css("display", "block");
		// 					$M.setValue("remark", "주유 / " + $M.getValue("car_no")  + " / 주행거리 ???? Km");
		// 					break;			//유류비
		// 		case "02" :  				//수리비
		// 		case "03" : 				//통행료
		// 		case "04" :  $("#btnCarSearch").attr("disabled", false);
		// 					if($M.getValue("own_car_no") != "" ) {
		// 						$M.setValue("car_code",$M.getValue("own_car_code"));
		// 						$M.setValue("car_no",$M.getValue("own_car_no"));
		// 					}
		// 					$(".car_show").css("display", "block");
		// 					break;			//주차료
		// 		default   : $M.setValue("car_code","");
		// 					$M.setValue("car_no","");
		// 					$(".car_show").css("display", "none");
		// 					$("#btnCarSearch").attr("disabled", true);
		// 					break;
		// 	}
		// }

		// 2023-07-25 황빛찬 (Q&A 14323) 차량관련 카드사용내역 상세와 동일하게 적용
		// 셀렉트박스 변경시 처리 ( 카드차량사용코드 )
		function fnChangeCardCarUse(obj){
			switch(obj.value)
			{
				case "01" : //유류비
				case "02" : //수리비
				case "03" : //통행료
				case "04" : //주차료
					$("#btnCarSearch").attr("disabled", false);
					break;
				default   :
					$("#btnCarSearch").attr("disabled", true);
					$M.setValue("car_code", "");
					$M.setValue("car_no", "");
					break;
			}
			// (Q&A 14323) 이유경 협의. 차량관련 선택히 변화X, 차량선택했을때 현재비고란에 차량내용 붙히기. 2022-12-16 김상덕
			// fnSetRemark($M.getValue("card_car_use_cd"));
		}
		
		function fnSetMemberInfo(data) {
			$M.setValue("use_mem_no", data.mem_no); 
			$M.setValue("use_mem_name", data.mem_name); 
		}
	
		function goRemove() {
			if ("Y" == "${bean.duzon_trans_yn}") {
				alert("경리확인 자료는 삭제할 수 없습니다.");
				return false;
			}
			var msg = "삭제하시겠습니까?";
			$M.goNextPageAjaxMsg(msg, this_page+"/"+$M.getValue("imprest_doc_no")+"/remove",  '', {method : 'POST'},
					function(result) {
			    		if(result.success) {
			    			try {
			    				<c:if test="${not empty inputParam.parent_js_name}">
			    					var item = {
			    						type : "D"
				    				}
				    				opener.${inputParam.parent_js_name}(item);
				    				fnClose();	
			    				</c:if>
			    			} catch (e) {
			    				console.log(e);
			    			} finally {
			    				alert("정상처리 되었습니다.");
			    				fnClose();	
			    			}
						}
					}
				);
		}
	
		function fnClose() {
			window.close();
		}
		
		function goAccountInfo() {
			if ($M.getValue("imprest_dt") == "") {
				alert("전표일자를 선택하세요.");
				return false;
			}
			var param = {
				"parent_js_name" : "fnSetBankInfo",
				"inout_type_io" : $M.getValue("inout_type_cd") == "01" ? "O" : "I",
				"imprest_yn" : "Y",
				"s_dt" : $M.getValue("imprest_dt"),
				"s_imprest_account_no" : "${account_no}"
			};
			var popupOption = "scrollbars=yes, resizable=yes, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1300, height=450, left=0, top=0";
			$M.goNextPage('/cust/cust0301p03', $M.toGetParam(param), {popupStatus : popupOption});
		}
		
		// 은행조회 callback
		function fnSetBankInfo(data) {
			console.log(data);
			$M.setValue("bank_name", data.ibk_bank_name);
			$M.setValue("ibk_bank_cd", data.ibk_bank_cd);
			$M.setValue("account_no", data.account_no);
			$M.setValue("acct_no", data.acct_no);
			$M.setValue("acct_txday", data.deal_dt);
			$M.setValue("acct_txday_seq", data.acct_txday_seq);
			if(data.in_tx_amt == "") {
				$M.setValue("tx_amt", data.out_tx_amt);
				$M.setValue("doc_amt", data.out_tx_amt);
			} else {
				$M.setValue("tx_amt", data.in_tx_amt);
				$M.setValue("doc_amt", data.in_tx_amt);
			}
			$M.setValue("jeokyo", data.deposit_name);
			$M.setValue("site_no", data.site_no);
			$M.setValue("ibk_iss_acct_his_seq", data.ibk_iss_acct_his_seq);
		}
		
		function goSave() {			
			var frm = document.main_form;
			
		     // validation check
	     	if($M.validation(frm) == false) {
	     		return;
	     	}
		     
	     	if( $M.getValue("card_car_use_cd") != ""  &&  $M.getValue("car_no") == ""  ) {
	     		alert("차량을 선택 후 처리하시오.");
				return;
			} 

	     	if( $M.getValue("card_use_cd") == "02"  &&  $M.getValue("machineRfq") == ""  ) {
	     		alert("장비번호를 선택해주세요.");
				return;
			} 
	     	
	    	if( $M.getValue("card_use_cd") == "03"  &&  $M.getValue("partRfq") == ""  ) {
	     		alert("수주번호를 선택해주세요.");
				return;
			};
			
			if( $M.getValue("used_mem_name") == "") {
				alert("사용자는 필수입니다.");
				$("#used_mem_name").focus();
				return false;
			}
			
			/* if ($M.getValue("imprest_use_cd") == "") {
				alert("사용구분은 필수입니다.");
				return false;
			} */
			
			// 현금일 경우 ibk 순번을 null 로 -> 쿼리에서 null로 업데이트 치기 위함.
			if ($M.getValue("acc_type_cd") == "1") {
				$M.setValue("ibk_iss_acct_his_seq", null);
			} else {
				if ($M.toNum($M.getValue("ibk_iss_acct_his_seq")) == 0) {
					alert("입금정보를 등록하세요.");
					$("#account_no").focus();
					return false;
				} 
			}
			
			var msg = "저장하시겠습니까?";
			if ($M.getValue("imprest_doc_no") != "") {
				msg = "수정하시겠습니까?";
			}
	     	
			$M.goNextPageAjaxMsg(msg, this_page, $M.toValueForm(frm) , {method : 'POST'},
				function(result) {
		    		if(result.success) {
		    			if ($M.getValue("imprest_doc_no") != "") {
		    				<c:if test="${not empty inputParam.parent_js_name}">
		    					var item = {
		    						type : "M",
		    						acnt_dt : $M.getValue("acnt_dt"),
		    						acnt_code : $M.getValue("acnt_code"),
		    						acnt_name : $M.getValue("acnt_name"),
		    						remark : $M.getValue("remark"),
		    						used_mem_no : $M.getValue("used_mem_no"),
		    					}
		    					opener.${inputParam.parent_js_name}(item);
		    					fnClose();	
		    				</c:if>
		    			} else {
		    				try {
		    					<c:if test="${not empty inputParam.parent_js_name}">
		    					var item = {
		    						type : "C",
		    						add : result
			    				}
			    				opener.${inputParam.parent_js_name}(item);
			    				fnClose();	
			    				</c:if>
			    			} catch (e) {
			    				console.log(e);
			    			} finally {
			    				fnClose();	
			    			}
		    			}
					}
				}
			);
		}
	
		function fnSetMemberInfo(data) {
			console.log(data);
			$M.setValue("used_mem_no", data.mem_no); 
			$M.setValue("used_mem_name", data.mem_name);
		}
		
		function fnSetCarInfo(data) {
			$M.setValue("car_no", data.car_no);
			$M.setValue("car_code", data.car_code); 
			// $M.setValue("remark", "주유 / " + data.car_no  + " / 주행거리 ???? Km");
			fnSetRemark($M.getValue("card_car_use_cd"));
		}

		function fnSetRemark(cardCarUseCd) {
			console.log("cardCarUseCd : ", cardCarUseCd);
			var remark = "";
			switch(cardCarUseCd) {
				case "01" :
					remark = " 주유 / " + $M.getValue("car_no") + " / 주행거리 ???? Km";
					break;
				case "02" :
					remark = " 수리비 / " + $M.getValue("car_no") + " / ";
					break;
				case "04" :
					remark = " 주차료 / " + $M.getValue("car_no") + " / ";
					break;
				default :
					break;
			}

			<%--$M.setValue("remark", `${bean.remark}` + remark);--%>
			// (Q&A 14323) 이유경 협의. 차량관련 선택히 변화X, 차량선택했을때 현재비고란에 차량내용 붙히기. 2022-12-16 김상덕
			// (Q&A 14323) 금전출납부 - 전도금전표처리 적요에는 적용 안되던 사항 추가 2023-07-25 황빛찬
			$M.setValue("remark", $M.getValue("remark") + remark);

		}
		
		// 계정과목 목록 팝업호출
		function goAccountListPopup() {

			/* var param = {};
			param.parent_js_name = "fnSetAccountInfo";
			var poppupOption = "";
			$M.goNextPage("/acnt/acnt0101p03", $M.toGetParam(param), {popupStatus : poppupOption}); */
			var param = {
				s_search_type : "IMPREST"
			}
			openAccountInfoPanel("fnSetAccountInfo", $M.toGetParam(param));
		}
		
		// 계정과목 선택 결과
		function fnSetAccountInfo(data) {
			console.log(data.acnt_code);
			if($M.nvl(data.acnt_code, "") == "") {
				return;
			}
			
			$M.setValue("acnt_code",data.acnt_code);
			$M.setValue("acnt_name",data.acnt_name.replace(/(\s*)/g, ""));
		}
		
		function fnSetAccTypeCd(obj) {
			switch($M.getValue("acc_type_cd")) {
				// 현금
				case "1" : $(".bankShow").css("display", "none"); $("#doc_amt").attr("disabled", false); break;
				// 은행
				case "3" : $(".bankShow").css("display", "flex"); $("#doc_amt").attr("disabled", true); break;
			}
		}
		
		function fnSetAccountLinkCd(row) {
			if (row.account_link_cd == null || row.account_link_cd == "") {
				alert("회계거래처코드가 없습니다.");
				return false;
			}
			$M.setValue("account_link_cd", row.account_link_cd);
		}
		
		// 수주참조
		function goSaleReferPopup() {
			var params = {
				"s_refer_yn" : "Y",
				"parent_js_name" : "fnSetPartInfo"
			};
			var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1000, height=400, left=0, top=0";
			$M.goNextPage('/cust/cust0202p02', $M.toGetParam(params), {popupStatus : popupOption});
		}
		
		// 수주참조 시 데이터 콜백
		function fnSetPartInfo(data) {
			$M.setValue("part_sale_no", data.part_sale_no);
		}
		
		// 정비참조
		function goReportReferPopup() {
			var params = {
				"s_refer_yn" : "Y",
				"parent_js_name" : "fnSetReportInfo"
			};
			var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1000, height=400, left=0, top=0";
			$M.goNextPage('/cust/cust0202p03', $M.toGetParam(params), {popupStatus : popupOption});
		}
		
		// 정비참조 시 데이터 콜백
		function fnSetReportInfo(data) {
			$M.setValue("job_report_no", data.job_report_no);
		}
		
		// 수주 상세
		function goSalePopup() {
			var partSaleNo = $M.getValue("part_sale_no");
			if (partSaleNo != "") {
				var param = {
					part_sale_no : partSaleNo
				}
				var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=600, height=400, left=0, top=0";
				$M.goNextPage('/cust/cust0201p01', $M.toGetParam(param), {popupStatus : popupOption});
			}
		}
		
		// 정비 상세
		function goReportPopup() {
			var jobReportNo = $M.getValue("job_report_no");
			if (jobReportNo != "") {
				var param = {
					s_job_report_no : jobReportNo
				}
				var popupOption = "scrollbars=yes, resizable=1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=600, height=400, left=0, top=0";
				$M.goNextPage('/serv/serv0101p01', $M.toGetParam(param), {popupStatus : popupOption});
			}
		}
		
		function fnChangeUse() {
			var cd = $M.getValue("imprest_use_cd");
			if (cd == "01") {
				var param = {
					job_report_no : "", 
					part_sale_no : ""
				}
				$M.setValue(param);
				$("#btnMachineRfqSearch").attr("disabled", true);
				$("#btnPartRfqSearch").attr("disabled", true);
				$("#job_report_no").attr("disabled", true);
				$("#part_sale_no").attr("disabled", true);
			} else if (cd == "02") {
				var param = {
					part_sale_no : ""
				}
				$M.setValue(param);
				$("#btnMachineRfqSearch").attr("disabled", false);
				$("#btnPartRfqSearch").attr("disabled", true);
				$("#job_report_no").attr("disabled", false);
				$("#part_sale_no").attr("disabled", true);
			} else {
				var param = {
					job_report_no : ""
				}
				$M.setValue(param);
				$("#btnMachineRfqSearch").attr("disabled", true);
				$("#btnPartRfqSearch").attr("disabled", false);
				$("#part_sale_no").attr("disabled", true);
				$("#part_sale_no").attr("disabled", false);
			}
		}
		
	</script>
</head>
<body class="bg-white">
<!-- 팝업 -->
<form id="main_form" name="main_form">
<input type="hidden" name="org_code" id="org_code" value="${inputParam.s_org_code}">
<input type="hidden" name="inout_money_seq" id="inout_money_seq" value="${bean.inout_money_seq }">
<input type="hidden" name="imprest_status_cd" id="imprest_status_cd" value="${bean.imprest_status_cd }">
<input type="hidden" name="ibk_iss_acct_his_seq" id="ibk_iss_acct_his_seq" value="${bean.ibk_iss_acct_his_seq }">
<div class="popup-wrap width-100per">
	<!-- 타이틀영역 -->
	<div class="main-title">
		<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
	</div>
	<!-- /타이틀영역 -->
	<div class="content-wrap">
		<!-- 카드사용내역상세 -->
		<div>
			<div class="title-wrap">
				<h4>전도금전표처리</h4>
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
					<th class="text-right">전표번호</th>
					<td>
						<div class="form-row inline-pd widthfix">
							<div class="col width120px">
								<input type="text" class="form-control" readonly="readonly" id="imprest_doc_no" name="imprest_doc_no" value="${bean.imprest_doc_no }">
							</div>
						</div>
					</td>
					<th class="text-right"><div class="bankShow" style="float: right">은행명</div></th>
					<td>
						<div class="bankShow"><input type="text" class="form-control" readonly="readonly" id="bank_name" name="bank_name" value="${bean.ibk_bank_name }"></div>
					</td>
				</tr>
				<tr>
					<th class="text-right rs">전표일자</th>
					<td>
						<div class="input-group width120px">
							<c:if test="${'Y' ne acc_user_yn }">
								<input type="text" class="form-control border-right-0 limitCalDate" id="imprest_dt" name="imprest_dt" start="0" end="0" dateformat="yyyy-MM-dd" value="${bean.imprest_dt }" required="required" disabled="disabled">
							</c:if>
							<c:if test="${'Y' eq acc_user_yn}">
								<input type="text" class="form-control border-right-0 calDate" id="imprest_dt" name="imprest_dt" dateformat="yyyy-MM-dd" value="${bean.imprest_dt }" required="required" readonly="readonly">
							</c:if>
						</div>
					</td>
					<th class="text-right"><div class="bankShow" style="float: right">계좌번호</div></th>
					<td>
						<div class="input-group width140px">
							<div class="bankShow">
								<input type="text" class="form-control border-right-0" readonly="readonly" id="account_no" name="account_no" value="${bean.account_no }">
								<button type="button" class="btn btn-icon btn-primary-gra"><i class="material-iconssearch" onclick="javascript:goAccountInfo()"></i></button>
							</div>
						</div>
					</td>
				</tr>
				<tr>
					<th class="text-right rs">전표구분</th>
					<td>
						<select class="form-control rb width120px" id="inout_type_cd" name="inout_type_cd" alt="전표구분">
							<option value="01" ${'01' eq bean.inout_type_cd ? 'selected' : '' }>입금</option>
							<option value="02" ${'02' eq bean.inout_type_cd ? 'selected' : '' }>출금</option>
						</select>
					</td>
					<th class="text-right"><div class="bankShow" style="float: right">입금일자</div></th>
					<td>
						<div class="bankShow"><input type="text" class="form-control" readonly="readonly" id="acct_txday" name="acct_txday" value="${bean.acct_txday}" dateformat="yyyy-MM-dd"></div>
					</td>
				</tr>
				<tr>
					<th class="text-right rs">계정구분</th>
					<td>
						<select class="form-control width120px rb" id="acc_type_cd" name="acc_type_cd" alt="계정구분" onchange="javascript:fnSetAccTypeCd(this)" required="required">
							<option value="1" ${empty bean.acc_type_cd or '1' eq bean.acc_type_cd ? 'selected' : ''}>현금</option>
							<option value="3" ${'3' eq bean.acc_type_cd ? 'selected' : ''}>은행</option>
						</select>
					</td>
					<th class="text-right"><div class="bankShow" style="float: right">입금액</div></th>
					<td>
						<div class="form-row inline-pd widthfix bankShow">
							<div class="col width100px">
								<input type="text" class="form-control text-right" readonly="readonly" id="tx_amt" name="tx_amt" value="${bean.tx_amt }" format="decimal">
							</div>
							<div class="col width22px">원</div>
						</div>
					</td>
				</tr>
				<tr>
					<th class="text-right rs">금액</th>
					<td>
						<div class="form-row inline-pd widthfix">
							<div class="col width100px">
								<input type="text" class="form-control rb text-right" id="doc_amt" name="doc_amt" value="${bean.doc_amt}" format="decimal" required="required" alt="금액">
							</div>
							<div class="col width22px">원</div>
						</div>
					</td>
					<th class="text-right"><div class="bankShow" style="float: right">입금자</div></th>
					<td>
						<div class="bankShow"><input type="text" class="form-control" readonly="readonly" value="${bean.jeokyo }" name="jeokyo"></div>
					</td>
				</tr>
				<tr>
					<th class="text-right">적요</th>
					<td colspan="3">
						<input type="text" class="form-control" placeholder="적요란에 실사용일자등을 기재하십시오." id="remark" name="remark" alt="적요" value="${bean.remark }">
					</td>
				</tr>

				<tr>
					<th class="text-right">계정과목</th>
					<!-- 전도금(11190) -->
					<td>${bean.imprest_acnt_name } <input type="hidden" value="${bean.imprest_acnt_code}" id="imprest_acnt_code" name="imprest_acnt_code"></td>
					<th class="text-right"><c:if test="${'Y' eq acc_user_yn }"><div>회계일자</div></c:if></th>
					<td>
						<c:if test="${'Y' eq acc_user_yn }">
						<div class="input-group width120px">
							<input type="text" class="form-control border-right-0 calDate" id="acnt_dt" name="acnt_dt" dateFormat="yyyy-MM-dd" value="${bean.acnt_dt}" alt="회계일자" readonly="readonly">
						</div>
						</c:if>
					</td>
				</tr>
				<tr>
					<th class="text-right rs">사용자</th>
					<td>
						<div class="input-group width120px">
							<div class="input-group width180px">
								<input type="text" class="form-control border-right-0 rb" readonly="readonly" id="used_mem_name" name="used_mem_name" alt="사용자" value="${bean.used_mem_name }">
								<input type="hidden" id="used_mem_no" name="used_mem_no" value="${bean.used_mem_no }">
								<button type="button" id="btnSearchUser" class="btn btn-icon btn-primary-gra" onclick="openSearchMemberPanel('fnSetMemberInfo');"><i class="material-iconssearch"></i></button>
							</div>
						</div>
					</td>
					<th class="text-right"><c:if test="${'Y' eq acc_user_yn }">계정과목</c:if></th>
					<td>
						<c:if test="${'Y' eq acc_user_yn }">
							<div class="input-group width120px">
								<input type="hidden" id="acnt_code" name="acnt_code" value="${bean.acnt_code }">
								<input type="text" class="form-control border-right-0" readonly="readonly" id="acnt_name" name="acnt_name" value="${fn:replace(bean.acnt_name,' ', '')}">
								<button type="button" class="btn btn-icon btn-primary-gra" id="btnSearchAcnt" onclick="javascript:goAccountListPopup();"><i class="material-iconssearch"></i></button>
							</div>
						</c:if>
					</td>
				</tr>
				<tr>
					<th class="text-right rs">사용구분</th>
					<td colspan="3">
						<div class="dpf algin-item-center">
							<div class="form-check form-check-inline">
								<!-- 이관 시, 새로 생긴기능이라 00으로 들어갈 경우 01로 체크되게 처리 -->
								<input onchange="javascript:fnChangeUse()" class="form-check-input" type="radio" name="imprest_use_cd"  id="imprest_use_cd_1"   value="01" ${bean.imprest_use_cd == '01' or empty bean.imprest_use_cd or bean.imprest_use_cd eq '00' ? 'checked="checked"' : ''} >
								<label for="imprest_use_cd_1" class="form-check-label">일반</label>
							</div>
							<div class="form-check form-check-inline">
								<input onchange="javascript:fnChangeUse()" class="form-check-input" type="radio" name="imprest_use_cd"  id="imprest_use_cd_2"  value="02"  ${bean.imprest_use_cd == '02'? 'checked="checked"' : ''} >
								<label for="imprest_use_cd_2" class="form-check-label">정비</label>
							</div>
							<div class="input-group width130px mr10">					
								<input type="text" class="form-control border-right-0 width120px"  id="job_report_no" name="job_report_no" readonly="readonly" value="${bean.job_report_no }" onclick="goReportPopup()">
								<button type="button" class="btn btn-icon btn-primary-gra" id="btnMachineRfqSearch" name="btnMachineRfqSearch"  onclick="javascript:goReportReferPopup();" ><i class="material-iconssearch"></i></button>
							</div>
							<div class="form-check form-check-inline">
								<input onchange="javascript:fnChangeUse()" class="form-check-input" type="radio" name="imprest_use_cd" id="imprest_use_cd_3"  value="03" ${bean.imprest_use_cd == '03'? 'checked="checked"' : ''}>
								<label for="imprest_use_cd_3" class="form-check-label" >수주</label>
							</div>
							<div class="input-group width130px">
								<input type="text" class="form-control border-right-0 width90px"  id="part_sale_no" name="part_sale_no"   readonly="readonly" value="${bean.part_sale_no }" onclick="goSalePopup()">
								<button type="button" class="btn btn-icon btn-primary-gra" id="btnPartRfqSearch" name="btnPartRfqSearch"  onclick="javascript:goSaleReferPopup();" ><i class="material-iconssearch"></i></button>
							</div>
						</div>
					</td>
				</tr>
				<tr>
					<th class="text-right">차량관련</th>
					<td>
						<select class="form-control width100px" id="card_car_use_cd" name="card_car_use_cd"  onchange="javascript:fnChangeCardCarUse(this);" >
							<option value="">해당무</option>
							<c:forEach items="${codeMap['CARD_CAR_USE']}" var="item">
								<option value="${item.code_value}" ${item.code_value == bean.card_car_use_cd ? 'selected' : '' }>
									${item.code_name}
								</option>
							</c:forEach>
						</select>
					</td>
					<th class="text-right">관리번호</th>
					<td>
						<c:if test="${'Y' eq acc_user_yn}">
							<input type="text" class="form-control car_show width120px" id="car_code" name="car_code" value="${bean.car_code}" readonly="readonly">
						</c:if>
					</td>
				</tr>
				<tr>
					<th class="text-right">차량번호</th>
					<td>
						<div class="input-group width130px">
							<input type="text" class="form-control border-right-0"  id="car_no" name="car_no"  value="${bean.car_no}"  readonly="readonly" >
							<button type="button" class="btn btn-icon btn-primary-gra" id="btnCarSearch" name="btnCarSearch"  onclick="javascript:openCarInfoPanel('fnSetCarInfo');" ><i class="material-iconssearch"></i></button>
						</div>
					</td>
					<th class="text-right"><c:if test="${'Y' eq acc_user_yn }">회계거래처코드</c:if></th>
					<td>
						<c:if test="${'Y' eq acc_user_yn }">
							<div class="input-group width120px">
								<input type="text" class="form-control border-right-0" readonly="readonly" id="account_link_cd" name="account_link_cd" value="${bean.account_link_cd }">
								<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchCustPanel('fnSetAccountLinkCd')"><i class="material-iconssearch"></i></button>
							</div>
						</c:if>
					</td>
				</tr>
				<tr>
					<th class="text-right">처리자</th>
					<td colspan="3">
						<input type="hidden" id="reg_id" name="reg_id" value="${bean.reg_id}">
						<input type="text" class="form-control" readonly="readonly" id="reg_mem_name" name="reg_mem_name" value="${bean.reg_mem_name}">
					</td>
				</tr>
				</tbody>
			</table>
		</div>
		<!-- /카드사용내역상세 -->
		<div class="btn-group mt10">
			<div class="right" id="btnHide">
				<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
			</div>
		</div>
	</div>
</div>
</form>
<!-- /팝업 -->
</body>
</html>