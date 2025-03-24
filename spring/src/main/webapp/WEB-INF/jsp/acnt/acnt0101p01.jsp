<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 비용관리 > 카드사용내역관리 > null > 카드사용내역상세
-- 작성자 : 담당자 이름을 넣어주세요.
-- 최초 작성일 : 2020-04-08 17:55:01
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

	$(document).ready(function () {		

		$("#btnHide").children().eq(0).attr('id','btnSave');
		$("#btnHide").children().eq(1).attr('id','btnRemove');
		
		//사용구분 여부에 따라 참조구분 검색유무 결정
		switch("${bean.card_use_cd}")
		{				
			case "01" :   $("#btnReportRfqSearch").attr("disabled", true);  
			 			  $("#btnPartRfqSearch").attr("disabled", true); 
			 			  break;		//일반
			case "02" :   $("#btnReportRfqSearch").attr("disabled", false);  
 			   			  $("#btnPartRfqSearch").attr("disabled", true); 
 			  			  break;		//정비
			case "03" :   $("#btnReportRfqSearch").attr("disabled", true);  
   			              $("#btnPartRfqSearch").attr("disabled", false); 
						  break;		//수주
			default   :  $("#btnReportRfqSearch").attr("disabled", true);  
						 $("#btnPartRfqSearch").attr("disabled", true); 
						 break;
		}
					
		//radiochange 이벤트 ( 카드 사용구분 여부 )
		$("input[name=card_use_cd]").change(function() {

  			$M.setValue("job_report_no", "");
			$M.setValue("part_sale_no", "");
			
		 	//선택값에 따라 정비,수주선택 팝업 호출
			var radioValue = $(this).val();
			if (radioValue == "01") {			//일반
		 			$("#btnReportRfqSearch").attr("disabled", true);  
			  			$("#btnPartRfqSearch").attr("disabled", true); 

			} else if (radioValue == "02") {	//정비
					$("#btnReportRfqSearch").attr("disabled", false);  
			  			$("#btnPartRfqSearch").attr("disabled", true); 
			} else if (radioValue == "03") {	//수주
					$("#btnReportRfqSearch").attr("disabled", true);  
			  			$("#btnPartRfqSearch").attr("disabled", false); 
	
			}
						
		});
		
		
		//관리번호 차량관련이 해당무인경우에는 안보이게
		switch("${bean.card_car_use_cd}")
		{				
			case "01" :  //유류비
			case "02" :  //수리비
			case "03" :  //통행료
			case "04" :  $("#btnCarSearch").attr("disabled", false);	break;			//주차료
			default   :  $("#btnCarSearch").attr("disabled", true);   break;
		}
		
		//경리 확인된 건은 저장,삭제버튼 비노출 및 모든 버튼 disable,readonly 처리

		if('${bean.acnt_confirm_yn}' == 'Y' ){	
			
			$('#btnSave').hide();
			$('#btnRemove').hide();
			$("#btnReportRfqSearch").attr("disabled", true);  
			$("#btnPartRfqSearch").attr("disabled", true); 
			$("#btnCarSearch").attr("disabled", true); 
			$("#btnUseMemSearch").attr("disabled", true); 
			$("#btnAcntSearch").attr("disabled", true); 
			$("#card_car_use_cd").attr("disabled", true); 
			$("#tax_dudect_yn").attr("disabled", true); 
			$("#acnt_dt").attr("disabled", true); 
          	$("input[name=card_use_cd]").each(function(i) {       
              	$(this).attr('disabled', "true");
          	});
          	$("#remark").attr("readonly", true); 
		}
		
	});
		
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

	function fnDetail() {

		var param = {
			"ibk_ccm_appr_seq": $M.getValue("ibk_ccm_appr_seq")
		};

		var poppupOption = "";
		$M.goNextPage('/comp/comp0902', $M.toGetParam(param), {popupStatus: poppupOption});
	}
	
	function fnSetMemberInfo(data) {

		$M.setValue("use_mem_no", data.mem_no); 
		$M.setValue("use_mem_name", data.mem_name); 
	}
	
	function fnSetCarInfo(data) {

		$M.setValue("car_no", data.car_no); 
		$M.setValue("car_code", data.car_code); 
		// $M.setValue("remark", "주유 / " + data.car_no  + " / 주행거리 ???? Km");
		fnSetRemark($M.getValue("card_car_use_cd"));
	}

	function fnSetRemark(cardCarUseCd) {
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
		$M.setValue("remark", $M.getValue("remark") + remark);

	}

	// 수주 상세
	function goSalePopup() {
		var partSaleNo = $M.getValue("part_sale_no");
		if (partSaleNo != "") {
			var param = {
				part_sale_no: partSaleNo
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
		 $M.setValue("job_report_no", "");
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
		$M.setValue("part_sale_no", "");
	}


	// 계정관리 목록 팝업호출
	function goAccountListPopup() {

		var param = {};
		param.parent_js_name = "fnSetAccountInfo";
		var poppupOption = "";
		$M.goNextPage("/comp/comp0901", $M.toGetParam(param), {popupStatus : poppupOption});
	}
	
	// 계정과목 선택 결과
	function fnSetAccountInfo(data) {
		console.log(data.acnt_code);
		if($M.nvl(data.acnt_code, "") == "") {
			return;
		}
		
		$M.setValue("acnt_code",data.acnt_code);
		$M.setValue("acnt_name",data.acnt_name);
	}
	
	
	
	//초기화 ( 수정가능한 값을 공백으로 처리) 
	function goReset() {
		
		if (confirm("초기화 하시겠습니까?") == false) {
			return false;
		}
		
// 		$M.setValue("use_mem_no","");
// 		$M.setValue("use_mem_name","");
		$M.setValue("car_no","");
		$M.setValue("car_code","");
		$M.setValue("remark","");
		$M.setValue("job_report_no","");
		$M.setValue("part_sale_no","");
		$M.setValue("card_car_use_cd","");
		$M.setValue("card_use_cd","01");
		$M.setValue("acnt_dt","");
		$M.setValue("acnt_name","");
		$M.setValue("acnt_code","");
		$M.setValue("tax_dudect_yn","N");
		$("#btnReportRfqSearch").attr("disabled", true);  
		$("#btnPartRfqSearch").attr("disabled", true); 
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

     	if( $M.getValue("card_use_cd") == "02"  &&  $M.getValue("job_report_no") == ""  ) {
     		alert("정비번호를 선택해주세요.");
			return;
		} 
     	
    	if( $M.getValue("card_use_cd") == "03"  &&  $M.getValue("part_sale_no") == ""  ) {
     		alert("수주번호를 선택해주세요.");
			return;
		} 
     	
		if( $M.getValue("card_use_cd") == "01"){
			$M.setValue("part_sale_no", "");	
		 	$M.setValue("job_report_no", "");		
		}
    	
		if( $M.getValue("card_use_cd") == "02"){
			$M.setValue("part_sale_no", "");
		}

    	if( $M.getValue("card_use_cd") == "03"){
    		$M.setValue("job_report_no", "");
    	}
    	
   	
		$M.goNextPageAjaxSave(this_page + "/save", $M.toValueForm(frm) , {method : 'POST'},
			function(result) {
	    		if(result.success) {
	    			<c:if test="${not empty inputParam.parent_js_name}">
						var item = {
							type : "M",
							acnt_dt : $M.getValue("acnt_dt"),
							acnt_code : $M.getValue("acnt_code"),
							acnt_name : $M.getValue("acnt_name"),
							tax_dudect_yn : $M.getValue("tax_dudect_yn"),
							remark : $M.getValue("remark"),
							mem_no : $M.getValue("use_mem_no"),
							mem_name : $M.getValue("use_mem_name"),
						}
						opener.${inputParam.parent_js_name}(item);
						fnClose();	
					</c:if>
					
					<c:if test="${empty inputParam.parent_js_name}">
						alert("처리가 완료되었습니다.");
						if (opener != null && opener.goSearch) {
							opener.goSearch();
						}
						fnClose();
					</c:if>
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
<!-- 팝업 -->
	<div class="popup-wrap width-100per">
		<!-- 타이틀영역 -->
		<div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
		</div>
		<!-- /타이틀영역 -->
		<div class="content-wrap">
			<!-- 카드사용내역상세 -->
			<input type="hidden" name="card_code" id="card_code" value="${bean.card_code}" />
			<input type="hidden" name="own_car_code" id="own_car_code" value="${bean.own_car_code}" />
			<input type="hidden" name="own_car_no" id="own_car_no" value="${bean.own_car_no}" />
			<input type="hidden" name="car_code" id="car_code" value="${bean.car_code}" />		
			<input type="hidden" name="use_mem_no" id="use_mem_no" value="${bean.mem_no}" />
<%-- 			<input type="hidden" name="use_mem_no" id="use_mem_no" value="${bean.use_mem_no}" /> --%>
			<input type="hidden" name="ibk_ccm_appr_seq" id="ibk_ccm_appr_seq" value="${bean.ibk_ccm_appr_seq}" />
			<input type="hidden" name="acnt_code" id="acnt_code" value="${bean.acnt_code}" />

			<div>
				<div class="title-wrap">
					<h4>카드사용내역상세</h4>
				</div>
				<table class="table-border mt5">
					<colgroup>
						<col width="100px">
						<col width="">
					</colgroup>
					<tbody>
					<tr>
						<th class="text-right">카드번호</th>
						<td>					
							<input type="text" class="form-control col-6" id="card_no" name="card_no"  value="${bean.card_no}" readonly="readonly" >
						</td>
					</tr>
					<tr>
						<th class="text-right">승인일시</th>
						<td>
							<div class="form-row inline-pd">
								<div class="col-6">
									<input type="text" class="form-control" id="approval_date" name="approval_date" value="<fmt:formatDate value="${bean.approval_date}" pattern="yyyy-MM-dd HH:mm:ss"/>"  readonly="readonly" />
								</div>
								<div class="col-6">
									<button type="button" class="btn btn-primary-gra" onclick="javascript:fnDetail();">상세보기</button>
								</div>
							</div>
						</td>
					</tr>
	
					<tr>
						<th class="text-right">가맹점명</th>
						<td>
							<input type="text" class="form-control col-8" id="chain_nm" name="chain_nm"  value="${bean.chain_nm}" readonly="readonly">
						</td>
					</tr>
					<tr>
						<th class="text-right">승인금액</th>
						<td>
							<input type="text" class="form-control text-right width120px" format="num" id="approval_amt" name="approval_amt"  value="${bean.approval_amt}" readonly="readonly" >
						</td>
					</tr>
					<tr>
						<th class="text-right">사용자</th>
						<td>
							<div class="input-group width140px">
								<input type="text" class="form-control border-right-0"  id="use_mem_name" name="use_mem_name" value="${bean.mem_name}" alt="사용자명"  required="required" readonly="readonly">
								<button type="button"  id="btnUseMemSearch" name="btnUseMemSearch" class="btn btn-icon btn-primary-gra" onclick="openSearchMemberPanel('fnSetMemberInfo');"><i class="material-iconssearch"></i></button>
							</div>
						</td>
					</tr>
					<tr>
						<th class="text-right">사용구분</th>
						<td>
							<div class="dpf algin-item-center">
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" name="card_use_cd" id="card_use_cd_1"  value="01" ${bean.card_use_cd == '01'? 'checked="checked"' : ''} >
									<label for="card_use_cd_1" class="form-check-label">일반</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" name="card_use_cd" id="card_use_cd_2"  value="02"  ${bean.card_use_cd == '02'? 'checked="checked"' : ''} >
									<label for="card_use_cd_2" class="form-check-label">정비</label>
								</div>								
								<div class="input-group width120px mr10">					
									<input type="text" class="form-control border-right-0 width100px"  id="job_report_no" name="job_report_no"  value="${bean.job_report_no}" readonly="readonly" onclick="goReportPopup()">
									<button type="button" class="btn btn-icon btn-primary-gra" id="btnReportRfqSearch" name="btnReportRfqSearch"  onclick="javascript:goReportReferPopup();" ><i class="material-iconssearch"></i></button>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" name="card_use_cd" id="card_use_cd_3"  value="03" ${bean.card_use_cd == '03'? 'checked="checked"' : ''}>
									<label class="form-check-label" for="card_use_cd_3">수주</label>
								</div>
								<div class="input-group width120px">
									<input type="text" class="form-control border-right-0 width100px"  id="part_sale_no" name="part_sale_no"  value="${bean.part_sale_no}"    readonly="readonly" onclick="goSalePopup()">
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
					</tr>
					<tr>			
						<th class="text-right">차량번호</th>
						<td>
							<div class="input-group width140px">
								<input type="text" class="form-control border-right-0"  id="car_no" name="car_no"  value="${bean.car_no}"  readonly="readonly" >
								<button type="button" class="btn btn-icon btn-primary-gra" id="btnCarSearch" name="btnCarSearch"  onclick="javascript:openCarInfoPanel('fnSetCarInfo');" ><i class="material-iconssearch"></i></button>
							</div>
						</td>
					</tr>
					<tr>
						<th class="text-right">거래처코드</th>
						<td>
							<input type="text" class="form-control width140px" id="chain_no" name="chain_no"  value="${bean.chain_no}" readonly="readonly"  >
						</td>
					</tr>
					<c:if test="${page.fnc.F00656_001 eq 'Y'}">
						<tr>
							<th class="text-right">회계일자</th>
							<td>
								<div class="input-group">												
									<input type="text" class="form-control border-right-0 calDate" id="acnt_dt" name="acnt_dt" dateFormat="yyyy-MM-dd" value="${bean.acnt_dt}" alt="회계일자">
								</div>
							</td>
						</tr>
						<tr>
								<th class="text-right">계정과목</th>
								<td>
									<div class="input-group width140px">
										<input type="text" class="form-control border-right-0"  id="acnt_name" name="acnt_name" value="${bean.acnt_name}" readonly="readonly" >
										<button type="button" class="btn btn-icon btn-primary-gra"  id="btnAcntSearch" name="btnAcntSearch" onclick="javascript:goAccountListPopup();"  ><i class="material-iconssearch"></i></button>
									</div>
								</td>
						</tr>	
						<tr>
							<th class="text-right">세액공제</th>
							<td>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" id="tax_dudect_yn_1" name="tax_dudect_yn" value="Y"  ${bean.tax_dudect_yn == 'Y'? 'checked="checked"' : ''} >
									<label for="tax_dudect_yn_1" class="form-check-label">처리</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" id="tax_dudect_yn_2" name="tax_dudect_yn" value="N"  ${bean.tax_dudect_yn == 'N'? 'checked="checked"' : ''} >
									<label  for="tax_dudect_yn_2"  class="form-check-label">미처리</label>
								</div>
							</td>
						</tr>				
					</c:if>
					<tr>
						<th class="text-right">사업자번호</th>
						<td>
							<input type="text" class="form-control width140px" id="chain_id" name="chain_id"  value="${bean.chain_id}" readonly="readonly"  >
						</td>
					</tr>
					<tr>
						<th class="text-right">비고</th>
						<td>
							<textarea class="form-control" style="height: 100px;" id="remark" name="remark" alt="비고"  maxlength="100" required="required" >${bean.remark}</textarea>
						</td>
					</tr>
					</tbody>
				</table>
			</div>
			<!-- /카드사용내역상세 -->
			<div class="btn-group mt10">
				<div class="right" id="btnHide" >
				   <!--  공통영역의 버튼을 조건에 따라 비노출시 공통영역 버튼에 아이디 발급하고 비노출처리하기 -->
				   <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
		</div>
	</div>
<!-- /팝업 -->
</form>
</body>
</html>